-- ============================================
-- Hospital Readmission & Quality Analytics
-- Data Transformation Views
-- Author: Abhishek Hundalekar
-- Date: July 2026
-- ============================================
-- Purpose: Aggregate 4 cleaned views to hospital-level grain, then join into master
-- Approach: 
--   1. Roll up HRRP, Complications, HCAHPS to 1 row per hospital
--   2. LEFT JOIN with hospital identity to build final master table
--   3. Add derived tiers (Excellent/Average/Poor) and data coverage flags
-- ============================================


-- ============================================
-- VIEW: v_hospital_readmissions
-- Aggregates HRRP data to 1 row per hospital
-- Source: v_hrrp (18,330 rows) → 3,055 hospitals
-- ============================================

CREATE OR REPLACE VIEW v_hospital_readmissions AS
SELECT
    facility_id,
    facility_name,
    state,
    
    COUNT(*) AS measures_reported,
    COUNT(excess_readmission_ratio) AS measures_with_err,
    
    ROUND(AVG(excess_readmission_ratio)::numeric, 4) AS avg_err,
    ROUND(MIN(excess_readmission_ratio)::numeric, 4) AS min_err,
    ROUND(MAX(excess_readmission_ratio)::numeric, 4) AS max_err,
    
    ROUND(AVG(predicted_readmission_rate)::numeric, 4) AS avg_predicted_rate,
    ROUND(AVG(expected_readmission_rate)::numeric, 4) AS avg_expected_rate,
    
    SUM(number_of_discharges) AS total_discharges,
    SUM(number_of_readmissions) AS total_readmissions,
    
    CASE 
        WHEN AVG(excess_readmission_ratio) IS NULL THEN 'No Data'
        WHEN AVG(excess_readmission_ratio) < 0.95 THEN 'Excellent'
        WHEN AVG(excess_readmission_ratio) BETWEEN 0.95 AND 1.05 THEN 'Average'
        WHEN AVG(excess_readmission_ratio) > 1.05 THEN 'Poor'
    END AS performance_tier
    
FROM v_hrrp
GROUP BY facility_id, facility_name, state;


-- ============================================
-- VIEW: v_hospital_outcomes
-- Aggregates clinical outcomes (mortality + complications) to 1 row per hospital
-- Source: v_complications (95,840 rows) → 4,792 hospitals
-- ============================================

CREATE OR REPLACE VIEW v_hospital_outcomes AS
SELECT
    facility_id,
    facility_name,
    state,
    
    COUNT(*) AS total_measures,
    COUNT(score) AS measures_with_score,
    
    COUNT(CASE WHEN measure_id LIKE 'MORT%' THEN 1 END) AS mortality_measures,
    COUNT(CASE WHEN measure_id LIKE 'COMP%' OR measure_id LIKE 'PSI%' THEN 1 END) AS complication_measures,
    
    COUNT(CASE WHEN compared_to_national LIKE '%Better%' THEN 1 END) AS better_count,
    COUNT(CASE WHEN compared_to_national LIKE '%Worse%' THEN 1 END) AS worse_count,
    COUNT(CASE WHEN compared_to_national LIKE '%No Different%' THEN 1 END) AS same_count,
    
    ROUND(AVG(score)::numeric, 4) AS avg_score,
    ROUND(MIN(score)::numeric, 4) AS min_score,
    ROUND(MAX(score)::numeric, 4) AS max_score,
    
    CASE 
        WHEN COUNT(CASE WHEN compared_to_national LIKE '%Better%' THEN 1 END) > 
             COUNT(CASE WHEN compared_to_national LIKE '%Worse%' THEN 1 END)
             THEN 'Above Average'
        WHEN COUNT(CASE WHEN compared_to_national LIKE '%Worse%' THEN 1 END) > 
             COUNT(CASE WHEN compared_to_national LIKE '%Better%' THEN 1 END)
             THEN 'Below Average'
        ELSE 'Average'
    END AS outcome_status
    
FROM v_complications
GROUP BY facility_id, facility_name, state;


-- ============================================
-- VIEW: v_hospital_patient_exp
-- Aggregates HCAHPS patient experience data to 1 row per hospital
-- Source: v_hcahps (325,856 rows) → 4,792 hospitals
-- ============================================

CREATE OR REPLACE VIEW v_hospital_patient_exp AS
SELECT
    facility_id,
    facility_name,
    state,
    
    COUNT(*) AS total_measures,
    
    ROUND(AVG(CASE 
        WHEN hcahps_measure_id LIKE '%_STAR_RATING' 
        THEN patient_survey_star_rating 
    END)::numeric, 2) AS avg_star_rating,
    
    MIN(CASE 
        WHEN hcahps_measure_id LIKE '%_STAR_RATING' 
        THEN patient_survey_star_rating 
    END) AS min_star_rating,
    
    MAX(CASE 
        WHEN hcahps_measure_id LIKE '%_STAR_RATING' 
        THEN patient_survey_star_rating 
    END) AS max_star_rating,
    
    ROUND(AVG(CASE 
        WHEN hcahps_measure_id LIKE '%_LINEAR_SCORE' 
        THEN hcahps_linear_mean_value 
    END)::numeric, 2) AS avg_linear_score,
    
    MAX(number_of_completed_surveys) AS completed_surveys,
    MAX(survey_response_rate_percent) AS response_rate_percent,
    
    CASE 
        WHEN AVG(CASE WHEN hcahps_measure_id LIKE '%_STAR_RATING' 
                 THEN patient_survey_star_rating END) IS NULL THEN 'No Data'
        WHEN AVG(CASE WHEN hcahps_measure_id LIKE '%_STAR_RATING' 
                 THEN patient_survey_star_rating END) >= 4 THEN 'Excellent'
        WHEN AVG(CASE WHEN hcahps_measure_id LIKE '%_STAR_RATING' 
                 THEN patient_survey_star_rating END) BETWEEN 3 AND 3.99 THEN 'Good'
        WHEN AVG(CASE WHEN hcahps_measure_id LIKE '%_STAR_RATING' 
                 THEN patient_survey_star_rating END) BETWEEN 2 AND 2.99 THEN 'Average'
        ELSE 'Poor'
    END AS patient_experience_tier
    
FROM v_hcahps
GROUP BY facility_id, facility_name, state;


-- ============================================
-- VIEW: v_hospital_master
-- Final wide analytical table joining all 4 datasets
-- Grain: 1 row per hospital (5,432 total)
-- Purpose: Single-source-of-truth for cross-dimensional analysis
-- ============================================

CREATE OR REPLACE VIEW v_hospital_master AS
SELECT
    -- Identity
    h.facility_id,
    h.facility_name,
    h.city_town,
    h.state,
    h.zip_code,
    h.hospital_type,
    h.hospital_ownership,
    h.emergency_services,
    
    -- Overall CMS rating
    h.hospital_overall_rating,
    
    -- Readmissions block (from HRRP)
    r.avg_err,
    r.min_err,
    r.max_err,
    r.total_discharges,
    r.total_readmissions,
    r.measures_with_err,
    r.performance_tier AS readmission_tier,
    
    -- Clinical outcomes block (from Complications)
    o.total_measures AS outcome_total_measures,
    o.mortality_measures,
    o.complication_measures,
    o.better_count,
    o.worse_count,
    o.same_count,
    o.outcome_status,
    
    -- Patient experience block (from HCAHPS)
    p.avg_star_rating AS patient_star_rating,
    p.min_star_rating AS patient_min_star,
    p.max_star_rating AS patient_max_star,
    p.avg_linear_score,
    p.completed_surveys,
    p.response_rate_percent,
    p.patient_experience_tier,
    
    -- Derived: Data completeness flag
    CASE 
        WHEN r.facility_id IS NOT NULL AND o.facility_id IS NOT NULL AND p.facility_id IS NOT NULL 
        THEN 'Complete'
        WHEN r.facility_id IS NULL AND o.facility_id IS NULL AND p.facility_id IS NULL 
        THEN 'Identity Only'
        ELSE 'Partial'
    END AS data_coverage
    
FROM v_hospital_info h
LEFT JOIN v_hospital_readmissions r ON h.facility_id = r.facility_id
LEFT JOIN v_hospital_outcomes o ON h.facility_id = o.facility_id
LEFT JOIN v_hospital_patient_exp p ON h.facility_id = p.facility_id;


-- ============================================
-- VERIFICATION QUERIES (optional - for manual check)
-- ============================================
-- SELECT COUNT(*) FROM v_hospital_readmissions;   -- Expected: 3,055
-- SELECT COUNT(*) FROM v_hospital_outcomes;       -- Expected: 4,792
-- SELECT COUNT(*) FROM v_hospital_patient_exp;    -- Expected: 4,792
-- SELECT COUNT(*) FROM v_hospital_master;         -- Expected: 5,432