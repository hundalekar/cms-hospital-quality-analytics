-- ============================================
-- Query 1: Readmission Performance by Hospital Ownership
-- ============================================

SELECT 
    hospital_ownership,
    COUNT(*) AS total_hospitals,
    COUNT(avg_err) AS hospitals_with_data,
    ROUND(AVG(avg_err)::numeric, 4) AS mean_err,
    ROUND(STDDEV(avg_err)::numeric, 4) AS stddev_err,
    ROUND(MIN(avg_err)::numeric, 4) AS best_err,
    ROUND(MAX(avg_err)::numeric, 4) AS worst_err,
    
    -- Count of performance tiers
    COUNT(CASE WHEN readmission_tier = 'Excellent' THEN 1 END) AS excellent_count,
    COUNT(CASE WHEN readmission_tier = 'Average' THEN 1 END) AS average_count,
    COUNT(CASE WHEN readmission_tier = 'Poor' THEN 1 END) AS poor_count,
    
    -- % of hospitals performing well
    ROUND(100.0 * COUNT(CASE WHEN readmission_tier = 'Excellent' THEN 1 END) / 
          NULLIF(COUNT(avg_err), 0), 2) AS pct_excellent
    
FROM v_hospital_master
WHERE avg_err IS NOT NULL
GROUP BY hospital_ownership
HAVING COUNT(avg_err) >= 10  -- Only ownership types with 10+ hospitals
ORDER BY mean_err ASC;

-- ============================================
-- Query 2: State-Level Readmission Performance
-- ============================================

SELECT 
    state,
    COUNT(*) AS hospital_count,
    ROUND(AVG(avg_err)::numeric, 4) AS state_avg_err,
    ROUND(STDDEV(avg_err)::numeric, 4) AS state_stddev,
    ROUND(MIN(avg_err)::numeric, 4) AS best_hospital_err,
    ROUND(MAX(avg_err)::numeric, 4) AS worst_hospital_err,
    
    COUNT(CASE WHEN readmission_tier = 'Excellent' THEN 1 END) AS excellent_hospitals,
    COUNT(CASE WHEN readmission_tier = 'Poor' THEN 1 END) AS poor_hospitals,
    
    ROUND(100.0 * COUNT(CASE WHEN readmission_tier = 'Excellent' THEN 1 END) / 
          COUNT(*), 2) AS pct_excellent,
    ROUND(100.0 * COUNT(CASE WHEN readmission_tier = 'Poor' THEN 1 END) / 
          COUNT(*), 2) AS pct_poor
    
FROM v_hospital_master
WHERE avg_err IS NOT NULL
GROUP BY state
HAVING COUNT(*) >= 20  -- Only states with 20+ hospitals for meaningful comparison
ORDER BY state_avg_err ASC
LIMIT 15;

-- ============================================
-- Query 3: Top 3 Best-Performing Hospitals in Each State
-- Uses window functions (ROW_NUMBER + PARTITION BY)
-- ============================================

WITH ranked_hospitals AS (
    SELECT 
        facility_id,
        facility_name,
        state,
        hospital_ownership,
        hospital_type,
        avg_err,
        readmission_tier,
        
        -- Rank hospitals within each state by ERR (lower = better)
        ROW_NUMBER() OVER (
            PARTITION BY state 
            ORDER BY avg_err ASC
        ) AS state_rank,
        
        -- Show total hospitals in each state
        COUNT(*) OVER (PARTITION BY state) AS state_hospital_count
        
    FROM v_hospital_master
    WHERE avg_err IS NOT NULL
)
SELECT 
    state,
    state_rank,
    facility_id,
    facility_name,
    hospital_ownership,
    hospital_type,
    avg_err,
    readmission_tier,
    state_hospital_count
FROM ranked_hospitals
WHERE state_rank <= 3  -- Top 3 in each state
  AND state_hospital_count >= 20  -- Only states with enough hospitals
ORDER BY state, state_rank
LIMIT 30;

-- ============================================
-- Query 4: CMS Rating vs Patient Satisfaction Alignment
-- ============================================

SELECT 
    hospital_overall_rating AS cms_rating,
    COUNT(*) AS total_hospitals,
    
    -- Average patient star rating for each CMS rating
    ROUND(AVG(patient_star_rating)::numeric, 2) AS avg_patient_star,
    ROUND(STDDEV(patient_star_rating)::numeric, 2) AS patient_star_stddev,
    
    -- Patient satisfaction tier breakdown
    COUNT(CASE WHEN patient_experience_tier = 'Excellent' THEN 1 END) AS patient_excellent,
    COUNT(CASE WHEN patient_experience_tier = 'Good' THEN 1 END) AS patient_good,
    COUNT(CASE WHEN patient_experience_tier = 'Average' THEN 1 END) AS patient_average,
    COUNT(CASE WHEN patient_experience_tier = 'Poor' THEN 1 END) AS patient_poor,
    
    -- % of hospitals where patients agree with CMS (both excellent)
    ROUND(100.0 * COUNT(CASE WHEN patient_experience_tier = 'Excellent' THEN 1 END) / 
          NULLIF(COUNT(patient_star_rating), 0), 2) AS pct_patient_excellent,
    
    -- Average readmission ERR (add readmissions to see 3-way pattern)
    ROUND(AVG(avg_err)::numeric, 4) AS avg_readmission_err
    
FROM v_hospital_master
WHERE hospital_overall_rating IS NOT NULL
  AND patient_star_rating IS NOT NULL
GROUP BY hospital_overall_rating
ORDER BY hospital_overall_rating DESC;

-- ============================================
-- Query 5: Hospitals vs Their State Benchmark
-- Shows top 10 outperformers AND top 10 underperformers
-- ============================================

WITH state_benchmarks AS (
    SELECT 
        facility_id,
        facility_name,
        state,
        hospital_ownership,
        avg_err,
        
        -- State-level benchmark (avg of all hospitals in same state)
        ROUND(AVG(avg_err) OVER (PARTITION BY state)::numeric, 4) AS state_avg_err,
        
        -- Gap between hospital and state benchmark
        ROUND((avg_err - AVG(avg_err) OVER (PARTITION BY state))::numeric, 4) AS gap_from_state,
        
        -- Count of hospitals in the state (for context)
        COUNT(*) OVER (PARTITION BY state) AS state_size
        
    FROM v_hospital_master
    WHERE avg_err IS NOT NULL
)
SELECT 
    facility_id,
    facility_name,
    state,
    hospital_ownership,
    avg_err AS hospital_err,
    state_avg_err,
    gap_from_state,
    state_size,
    CASE 
        WHEN gap_from_state < -0.10 THEN 'Far Better Than State'
        WHEN gap_from_state BETWEEN -0.10 AND -0.03 THEN 'Better Than State'
        WHEN gap_from_state BETWEEN -0.03 AND 0.03 THEN 'Near State Avg'
        WHEN gap_from_state BETWEEN 0.03 AND 0.10 THEN 'Worse Than State'
        WHEN gap_from_state > 0.10 THEN 'Far Worse Than State'
    END AS performance_vs_state
FROM state_benchmarks
WHERE state_size >= 30  -- Only states with 30+ hospitals
ORDER BY gap_from_state ASC  -- Best outperformers first
LIMIT 20;