-- ============================================
-- Hospital Readmission & Quality Analytics
-- Data Loading Script
-- Uses server-side COPY (fast bulk load)
-- ============================================

-- Note: Update file paths to match your local system
-- All CSV files sourced from data.cms.gov (public government data)

-- Load 1: Hospital General Info (5,432 rows)
COPY raw_hospital_info FROM 'C:\Data analytics project\Project 1\Datasets\Hospital_General_Information.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ESCAPE '"', ENCODING 'UTF8');

-- Load 2: Complications and Deaths (95,840 rows)
COPY raw_complications FROM 'C:\Data analytics project\Project 1\Datasets\Complications_and_Deaths-Hospital.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ESCAPE '"', ENCODING 'UTF8');

-- Load 3: HRRP Readmissions (18,330 rows)
COPY raw_hrrp FROM 'C:\Data analytics project\Project 1\Datasets\FY_2026_Hospital_Readmissions_Reduction_Program_Hospital.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ESCAPE '"', ENCODING 'UTF8');

-- Load 4: HCAHPS Patient Survey (325,856 rows)
COPY raw_hcahps FROM 'C:\Data analytics project\Project 1\Datasets\HCAHPS-Hospital.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ESCAPE '"', ENCODING 'UTF8');

-- ============================================
-- Verification
-- ============================================
SELECT 'raw_hospital_info' AS table_name, COUNT(*) AS row_count FROM raw_hospital_info
UNION ALL
SELECT 'raw_complications', COUNT(*) FROM raw_complications
UNION ALL
SELECT 'raw_hrrp', COUNT(*) FROM raw_hrrp
UNION ALL
SELECT 'raw_hcahps', COUNT(*) FROM raw_hcahps;

-- Expected:
-- raw_hospital_info: 5,432
-- raw_complications: 95,840
-- raw_hrrp: 18,330
-- raw_hcahps: 325,856
-- Total: 445,458 rows