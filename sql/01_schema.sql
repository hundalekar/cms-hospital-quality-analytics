-- ============================================
-- Hospital Readmission & Quality Analytics
-- Project 1 - Schema Definition
-- Author: Abhishek Hundalekar
-- Date: July 2026
-- ============================================

-- ============================================
-- TABLE 1: raw_hospital_info (Master table)
-- Source: CMS Hospital General Information
-- Rows: 5,432 | Columns: 38
-- ============================================
CREATE TABLE raw_hospital_info (
    facility_id VARCHAR(20) PRIMARY KEY,
    facility_name VARCHAR(200),
    address VARCHAR(200),
    city_town VARCHAR(100),
    state VARCHAR(5),
    zip_code INT,
    county_parish VARCHAR(100),
    telephone_number VARCHAR(30),
    hospital_type VARCHAR(100),
    hospital_ownership VARCHAR(100),
    emergency_services VARCHAR(10),
    birthing_friendly VARCHAR(20),
    hospital_overall_rating VARCHAR(20),
    hospital_overall_rating_footnote VARCHAR(20),
    mort_group_measure_count VARCHAR(20),
    count_facility_mort_measures VARCHAR(20),
    count_mort_measures_better VARCHAR(20),
    count_mort_measures_no_different VARCHAR(20),
    count_mort_measures_worse VARCHAR(20),
    mort_group_footnote FLOAT,
    safety_group_measure_count VARCHAR(20),
    count_facility_safety_measures VARCHAR(20),
    count_safety_measures_better VARCHAR(20),
    count_safety_measures_no_different VARCHAR(20),
    count_safety_measures_worse VARCHAR(20),
    safety_group_footnote FLOAT,
    readm_group_measure_count VARCHAR(20),
    count_facility_readm_measures VARCHAR(20),
    count_readm_measures_better VARCHAR(20),
    count_readm_measures_no_different VARCHAR(20),
    count_readm_measures_worse VARCHAR(20),
    readm_group_footnote FLOAT,
    pt_exp_group_measure_count VARCHAR(20),
    count_facility_pt_exp_measures VARCHAR(20),
    pt_exp_group_footnote FLOAT,
    te_group_measure_count VARCHAR(20),
    count_facility_te_measures VARCHAR(20),
    te_group_footnote FLOAT
);

-- ============================================
-- TABLE 2: raw_complications
-- Source: CMS Complications and Deaths - Hospital
-- Rows: 95,840 | Columns: 18
-- ============================================
CREATE TABLE raw_complications (
    facility_id VARCHAR(20),
    facility_name VARCHAR(200),
    address VARCHAR(200),
    city_town VARCHAR(100),
    state VARCHAR(5),
    zip_code INT,
    county_parish VARCHAR(100),
    telephone_number VARCHAR(30),
    measure_id VARCHAR(50),
    measure_name VARCHAR(300),
    compared_to_national VARCHAR(100),
    denominator VARCHAR(20),
    score VARCHAR(20),
    lower_estimate VARCHAR(20),
    higher_estimate VARCHAR(20),
    footnote VARCHAR(20),
    start_date VARCHAR(20),
    end_date VARCHAR(20)
);

CREATE INDEX idx_complications_facility ON raw_complications(facility_id);
CREATE INDEX idx_complications_measure ON raw_complications(measure_id);

-- ============================================
-- TABLE 3: raw_hrrp (HRRP Readmissions)
-- Source: CMS FY 2026 HRRP Hospital Data
-- Rows: 18,330 | Columns: 12
-- Note: All numeric columns loaded as VARCHAR to handle "N/A" and "Too Few to Report" values
-- ============================================
CREATE TABLE raw_hrrp (
    facility_name VARCHAR(200),
    facility_id VARCHAR(20),
    state VARCHAR(5),
    measure_name VARCHAR(300),
    number_of_discharges VARCHAR(20),
    footnote VARCHAR(20),
    excess_readmission_ratio VARCHAR(20),
    predicted_readmission_rate VARCHAR(20),
    expected_readmission_rate VARCHAR(20),
    number_of_readmissions VARCHAR(20),
    start_date VARCHAR(20),
    end_date VARCHAR(20)
);

CREATE INDEX idx_hrrp_facility ON raw_hrrp(facility_id);

-- ============================================
-- TABLE 4: raw_hcahps (HCAHPS Patient Survey)
-- Source: CMS HCAHPS - Hospital
-- Rows: 325,856 | Columns: 22
-- ============================================
CREATE TABLE raw_hcahps (
    facility_id VARCHAR(20),
    facility_name VARCHAR(200),
    address VARCHAR(200),
    city_town VARCHAR(100),
    state VARCHAR(5),
    zip_code INT,
    county_parish VARCHAR(100),
    telephone_number VARCHAR(30),
    hcahps_measure_id VARCHAR(50),
    hcahps_question VARCHAR(500),
    hcahps_answer_description VARCHAR(500),
    patient_survey_star_rating VARCHAR(20),
    patient_survey_star_rating_footnote VARCHAR(20),
    hcahps_answer_percent VARCHAR(20),
    hcahps_answer_percent_footnote VARCHAR(20),
    hcahps_linear_mean_value VARCHAR(20),
    number_of_completed_surveys VARCHAR(20),
    number_of_completed_surveys_footnote VARCHAR(20),
    survey_response_rate_percent VARCHAR(20),
    survey_response_rate_percent_footnote VARCHAR(20),
    start_date VARCHAR(20),
    end_date VARCHAR(20)
);

CREATE INDEX idx_hcahps_facility ON raw_hcahps(facility_id);
CREATE INDEX idx_hcahps_measure ON raw_hcahps(hcahps_measure_id);