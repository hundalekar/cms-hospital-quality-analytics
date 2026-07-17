-- ============================================
-- Hospital Readmission & Quality Analytics
-- Data Cleaning Views
-- Author: Abhishek Hundalekar
-- Date: July 2026
-- ============================================
-- Purpose: Transform raw CMS data into clean analytical views
-- Approach: 4 CREATE VIEW statements, one per raw table
-- Cleaning applied:
--   1. Replace "Not Available"/"Not Applicable"/"N/A"/"Too Few to Report" with NULL
--   2. Cast VARCHAR columns to proper types (INT, FLOAT, DATE)
--   3. Drop metadata footnote columns
-- ============================================


-- ============================================
-- VIEW 1: v_hospital_info
-- Source: raw_hospital_info (5,432 rows)
-- Purpose: Clean master hospital identity + quality group metrics
-- Key cleaning: hospital_overall_rating cast to INT, measure counts to INT
-- ============================================

CREATE OR REPLACE VIEW v_hospital_info AS
SELECT
    facility_id,
    facility_name,
    address,
    city_town,
    state,
    zip_code,
    county_parish,
    telephone_number,
    hospital_type,
    hospital_ownership,
    emergency_services,
    
    CASE 
        WHEN hospital_overall_rating IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(hospital_overall_rating AS INT)
    END AS hospital_overall_rating,
    
    -- Mortality group metrics
    CASE 
        WHEN mort_group_measure_count IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(mort_group_measure_count AS INT)
    END AS mort_group_measure_count,
    
    CASE 
        WHEN count_facility_mort_measures IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_facility_mort_measures AS INT)
    END AS count_facility_mort_measures,
    
    CASE 
        WHEN count_mort_measures_better IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_mort_measures_better AS INT)
    END AS count_mort_measures_better,
    
    CASE 
        WHEN count_mort_measures_no_different IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_mort_measures_no_different AS INT)
    END AS count_mort_measures_no_different,
    
    CASE 
        WHEN count_mort_measures_worse IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_mort_measures_worse AS INT)
    END AS count_mort_measures_worse,
    
    -- Safety group metrics
    CASE 
        WHEN safety_group_measure_count IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(safety_group_measure_count AS INT)
    END AS safety_group_measure_count,
    
    CASE 
        WHEN count_facility_safety_measures IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_facility_safety_measures AS INT)
    END AS count_facility_safety_measures,
    
    CASE 
        WHEN count_safety_measures_better IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_safety_measures_better AS INT)
    END AS count_safety_measures_better,
    
    CASE 
        WHEN count_safety_measures_no_different IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_safety_measures_no_different AS INT)
    END AS count_safety_measures_no_different,
    
    CASE 
        WHEN count_safety_measures_worse IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_safety_measures_worse AS INT)
    END AS count_safety_measures_worse,
    
    -- Readmission group metrics
    CASE 
        WHEN readm_group_measure_count IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(readm_group_measure_count AS INT)
    END AS readm_group_measure_count,
    
    CASE 
        WHEN count_facility_readm_measures IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_facility_readm_measures AS INT)
    END AS count_facility_readm_measures,
    
    CASE 
        WHEN count_readm_measures_better IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_readm_measures_better AS INT)
    END AS count_readm_measures_better,
    
    CASE 
        WHEN count_readm_measures_no_different IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_readm_measures_no_different AS INT)
    END AS count_readm_measures_no_different,
    
    CASE 
        WHEN count_readm_measures_worse IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_readm_measures_worse AS INT)
    END AS count_readm_measures_worse,
    
    -- Patient experience group
    CASE 
        WHEN pt_exp_group_measure_count IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(pt_exp_group_measure_count AS INT)
    END AS pt_exp_group_measure_count,
    
    CASE 
        WHEN count_facility_pt_exp_measures IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_facility_pt_exp_measures AS INT)
    END AS count_facility_pt_exp_measures,
    
    -- Timely & Effective care group
    CASE 
        WHEN te_group_measure_count IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(te_group_measure_count AS INT)
    END AS te_group_measure_count,
    
    CASE 
        WHEN count_facility_te_measures IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(count_facility_te_measures AS INT)
    END AS count_facility_te_measures
    
FROM raw_hospital_info;


-- ============================================
-- VIEW 2: v_complications
-- Source: raw_complications (95,840 rows)
-- Purpose: Clean clinical outcomes (mortality + complications)
-- Key cleaning: score/CIs cast to FLOAT, dates cast, includes pre-built 95% CIs
-- ============================================

CREATE OR REPLACE VIEW v_complications AS
SELECT
    facility_id,
    facility_name,
    address,
    city_town,
    state,
    zip_code,
    county_parish,
    telephone_number,
    measure_id,
    measure_name,
    compared_to_national,
    
    CASE 
        WHEN denominator IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(denominator AS INT)
    END AS denominator,
    
    CASE 
        WHEN score IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(score AS FLOAT)
    END AS score,
    
    CASE 
        WHEN lower_estimate IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(lower_estimate AS FLOAT)
    END AS lower_estimate,
    
    CASE 
        WHEN higher_estimate IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(higher_estimate AS FLOAT)
    END AS higher_estimate,
    
    TO_DATE(start_date, 'MM/DD/YYYY') AS start_date,
    TO_DATE(end_date, 'MM/DD/YYYY') AS end_date
    
FROM raw_complications;


-- ============================================
-- VIEW 3: v_hrrp
-- Source: raw_hrrp (18,330 rows)
-- Purpose: Clean HRRP readmission metrics with Excess Readmission Ratio (ERR)
-- Key cleaning: "N/A" and "Too Few to Report" handled; numerics cast
-- Analysis anchor: ERR (>1.0 = worse than expected, <1.0 = better)
-- ============================================

CREATE OR REPLACE VIEW v_hrrp AS
SELECT
    facility_id,
    facility_name,
    state,
    measure_name,
    
    CASE 
        WHEN number_of_discharges IN ('N/A', 'Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(number_of_discharges AS INT)
    END AS number_of_discharges,
    
    CASE 
        WHEN excess_readmission_ratio IN ('N/A', 'Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(excess_readmission_ratio AS FLOAT)
    END AS excess_readmission_ratio,
    
    CASE 
        WHEN predicted_readmission_rate IN ('N/A', 'Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(predicted_readmission_rate AS FLOAT)
    END AS predicted_readmission_rate,
    
    CASE 
        WHEN expected_readmission_rate IN ('N/A', 'Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(expected_readmission_rate AS FLOAT)
    END AS expected_readmission_rate,
    
    CASE 
        WHEN number_of_readmissions IN ('N/A', 'Not Available', 'Not Applicable', 'Too Few to Report', '') THEN NULL
        ELSE CAST(number_of_readmissions AS INT)
    END AS number_of_readmissions,
    
    TO_DATE(start_date, 'MM/DD/YYYY') AS start_date,
    TO_DATE(end_date, 'MM/DD/YYYY') AS end_date
    
FROM raw_hrrp;


-- ============================================
-- VIEW 4: v_hcahps
-- Source: raw_hcahps (325,856 rows)
-- Purpose: Clean patient experience/satisfaction data
-- Key cleaning: 5 numeric columns cast, dates cast
-- Note: 91% of rows have NULL star ratings by design (only summary measures get stars)
-- ============================================

CREATE OR REPLACE VIEW v_hcahps AS
SELECT
    facility_id,
    facility_name,
    address,
    city_town,
    state,
    zip_code,
    county_parish,
    telephone_number,
    hcahps_measure_id,
    hcahps_question,
    hcahps_answer_description,
    
    CASE 
        WHEN patient_survey_star_rating IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(patient_survey_star_rating AS INT)
    END AS patient_survey_star_rating,
    
    CASE 
        WHEN hcahps_answer_percent IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(hcahps_answer_percent AS INT)
    END AS hcahps_answer_percent,
    
    CASE 
        WHEN hcahps_linear_mean_value IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(hcahps_linear_mean_value AS FLOAT)
    END AS hcahps_linear_mean_value,
    
    CASE 
        WHEN number_of_completed_surveys IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(number_of_completed_surveys AS INT)
    END AS number_of_completed_surveys,
    
    CASE 
        WHEN survey_response_rate_percent IN ('Not Available', 'Not Applicable', '') THEN NULL
        ELSE CAST(survey_response_rate_percent AS INT)
    END AS survey_response_rate_percent,
    
    TO_DATE(start_date, 'MM/DD/YYYY') AS start_date,
    TO_DATE(end_date, 'MM/DD/YYYY') AS end_date
    
FROM raw_hcahps;


-- ============================================
-- VERIFICATION QUERIES (optional - for manual check)
-- ============================================
-- SELECT COUNT(*) FROM v_hospital_info;   -- Expected: 5,432
-- SELECT COUNT(*) FROM v_complications;   -- Expected: 95,840
-- SELECT COUNT(*) FROM v_hrrp;            -- Expected: 18,330
-- SELECT COUNT(*) FROM v_hcahps;          -- Expected: 325,856