use FinalProject

-- part 1. descriptive analytics - using anchor-year group
SELECT p.anchor_year_group, COUNT(DISTINCT i.stay_id) AS icu_stays
FROM icustays i
JOIN patients p ON i.subject_id = p.subject_id
GROUP BY p.anchor_year_group
ORDER BY p.anchor_year_group;


--verify icd codes for HAI's
SELECT icd_code, COUNT(*) 
FROM diagnoses_icd 
WHERE icd_code IN ('99931','04112','99664','99731','99859')
GROUP BY icd_code;

-- Verify HAI codes exist
SELECT icd_code, COUNT(*) 
FROM diagnoses_icd 
WHERE icd_code IN ('99931','04112','99664','99731','99859')
GROUP BY icd_code;

-- all hospital admissions: clabsi, mrsa, cauti, ventilator pneumonia, surgical site - WITHOUT ICU DATA 
WITH hai_flags AS (
    SELECT 
        p.subject_id,
        a.hadm_id,  
        p.anchor_year_group,
        MAX(CASE WHEN d.icd_code = '99931' THEN 1 ELSE 0 END) AS clabsi,
        MAX(CASE WHEN d.icd_code = '04112' THEN 1 ELSE 0 END) AS mrsa,
        MAX(CASE WHEN d.icd_code = '99664' THEN 1 ELSE 0 END) AS cauti,
        MAX(CASE WHEN d.icd_code = '99731' THEN 1 ELSE 0 END) AS ventilator_pneu,
        MAX(CASE WHEN d.icd_code = '99859' THEN 1 ELSE 0 END) AS surgical_site
    FROM admissions a
    JOIN patients p ON a.subject_id = p.subject_id
    LEFT JOIN diagnoses_icd d ON a.hadm_id = d.hadm_id  
    GROUP BY p.subject_id, a.hadm_id, p.anchor_year_group
)
SELECT 
    anchor_year_group,
    COUNT(DISTINCT hadm_id) AS total_admissions,
    COUNT(DISTINCT CASE WHEN clabsi = 1 THEN hadm_id END) AS clabsi_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN clabsi = 1 THEN hadm_id END) / COUNT(DISTINCT hadm_id), 2) AS clabsi_percent,
    COUNT(DISTINCT CASE WHEN mrsa = 1 THEN hadm_id END) AS mrsa_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN mrsa = 1 THEN hadm_id END) / COUNT(DISTINCT hadm_id), 2) AS mrsa_percent,
    COUNT(DISTINCT CASE WHEN cauti = 1 THEN hadm_id END) AS cauti_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN cauti = 1 THEN hadm_id END) / COUNT(DISTINCT hadm_id), 2) AS cauti_percent,
    COUNT(DISTINCT CASE WHEN ventilator_pneu = 1 THEN hadm_id END) AS ventilator_pneu_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN ventilator_pneu = 1 THEN hadm_id END) / COUNT(DISTINCT hadm_id), 2) AS ventilator_pneu_percent,
    COUNT(DISTINCT CASE WHEN surgical_site = 1 THEN hadm_id END) AS surgical_site_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN surgical_site = 1 THEN hadm_id END) / COUNT(DISTINCT hadm_id), 2) AS surgical_site_percent
FROM hai_flags
GROUP BY anchor_year_group
ORDER BY anchor_year_group;
--anchor year group 2008-2010 has the most admissions 


-- all icu admissions: clabsi, mrsa, cauti, ventilator pneumonia, surgical site 
WITH icu_hai_flags AS (
    SELECT 
        i.stay_id,
        p.anchor_year_group,
        MAX(CASE WHEN d.icd_code = '99931' THEN 1 ELSE 0 END) AS clabsi,
        MAX(CASE WHEN d.icd_code = '04112' THEN 1 ELSE 0 END) AS mrsa,
        MAX(CASE WHEN d.icd_code = '99664' THEN 1 ELSE 0 END) AS cauti,
        MAX(CASE WHEN d.icd_code = '99731' THEN 1 ELSE 0 END) AS ventilator_pneu,
        MAX(CASE WHEN d.icd_code = '99859' THEN 1 ELSE 0 END) AS surgical_site
    FROM icustays i
    JOIN patients p ON i.subject_id = p.subject_id
    LEFT JOIN diagnoses_icd d ON i.hadm_id = d.hadm_id
    GROUP BY i.stay_id, p.anchor_year_group
)
SELECT 
    anchor_year_group,
    COUNT(DISTINCT stay_id) AS total_icu_stays,
    COUNT(DISTINCT CASE WHEN clabsi = 1 THEN stay_id END) AS clabsi_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN clabsi = 1 THEN stay_id END) / COUNT(DISTINCT stay_id), 2) AS clabsi_percent,
    COUNT(DISTINCT CASE WHEN mrsa = 1 THEN stay_id END) AS mrsa_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN mrsa = 1 THEN stay_id END) / COUNT(DISTINCT stay_id), 2) AS mrsa_percent,
    COUNT(DISTINCT CASE WHEN cauti = 1 THEN stay_id END) AS cauti_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN cauti = 1 THEN stay_id END) / COUNT(DISTINCT stay_id), 2) AS cauti_percent,
    COUNT(DISTINCT CASE WHEN ventilator_pneu = 1 THEN stay_id END) AS ventilator_pneu_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN ventilator_pneu = 1 THEN stay_id END) / COUNT(DISTINCT stay_id), 2) AS ventilator_pneu_percent,
    COUNT(DISTINCT CASE WHEN surgical_site = 1 THEN stay_id END) AS surgical_site_cases,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN surgical_site = 1 THEN stay_id END) / COUNT(DISTINCT stay_id), 2) AS surgical_site_percent
FROM icu_hai_flags
GROUP BY anchor_year_group
ORDER BY anchor_year_group;
--anchor year 2008-2010 has the most icu stays 

--total icu stays with HAI -> 2952
WITH icu_hai_flags AS (
    SELECT 
        i.stay_id,
        MAX(CASE WHEN d.icd_code = '99931' THEN 1 ELSE 0 END) AS clabsi,
        MAX(CASE WHEN d.icd_code = '04112' THEN 1 ELSE 0 END) AS mrsa,
        MAX(CASE WHEN d.icd_code = '99664' THEN 1 ELSE 0 END) AS cauti,
        MAX(CASE WHEN d.icd_code = '99731' THEN 1 ELSE 0 END) AS ventilator_pneu,
        MAX(CASE WHEN d.icd_code = '99859' THEN 1 ELSE 0 END) AS surgical_site
    FROM icustays i
    LEFT JOIN diagnoses_icd d ON i.hadm_id = d.hadm_id
    GROUP BY i.stay_id
)
SELECT 
    COUNT(DISTINCT stay_id) AS total_icu_stays_with_hai
FROM icu_hai_flags
WHERE clabsi = 1 OR mrsa = 1 OR cauti = 1 OR ventilator_pneu = 1 OR surgical_site = 1;


--2. create ICU dataset with HAI flags 
SELECT *
INTO icu_with_hai
FROM (
    SELECT
        i.stay_id,
        i.subject_id,
        i.hadm_id,
        i.intime,
        i.outtime,
        ROUND(DATEDIFF(minute, i.intime, i.outtime)/1440.0, 2) AS icu_los_days,
        p.gender,
        p.anchor_age AS age,
        p.anchor_year_group,       
        p.anchor_year,              
        a.admission_type,
        MAX(CASE WHEN d.icd_code = '99931' THEN 1 ELSE 0 END) AS clabsi,
        MAX(CASE WHEN d.icd_code = '04112' THEN 1 ELSE 0 END) AS mrsa,
        MAX(CASE WHEN d.icd_code = '99664' THEN 1 ELSE 0 END) AS cauti,
        MAX(CASE WHEN d.icd_code = '99731' THEN 1 ELSE 0 END) AS vap,
        MAX(CASE WHEN d.icd_code = '99859' THEN 1 ELSE 0 END) AS ssi
    FROM icustays i
    LEFT JOIN admissions a ON i.hadm_id = a.hadm_id
    LEFT JOIN patients p ON i.subject_id = p.subject_id
    LEFT JOIN diagnoses_icd d ON i.hadm_id = d.hadm_id
    GROUP BY
        i.stay_id, i.subject_id, i.hadm_id, i.intime, i.outtime,
        p.gender, p.anchor_age, p.anchor_year_group, p.anchor_year, a.admission_type
) AS icu_data;
--94458 rows affected 
------------------------------------------------------------
--3. handling data
-- Checks for logical inconsistencies
SELECT COUNT(*) AS inconsistent_los
FROM icu_with_hai
WHERE icu_los_days <> ROUND(DATEDIFF(MINUTE, intime, outtime)/1440.0, 2);
-- zero inconsistent los

-- Check date ranges
SELECT 
    MIN(intime) AS earliest_intime,
    MAX(intime) AS latest_intime,
    MIN(outtime) AS earliest_outtime,
    MAX(outtime) AS latest_outtime
FROM icu_with_hai;
--shows dates ranges are set in future intentionally because of privacy reasons. Not an issue with data, so we focus on anchor year groups

-- Check for missing ages
SELECT COUNT(*) FROM icu_with_hai WHERE age IS NULL;

-- Verify gender distribution
SELECT gender, COUNT(*) FROM icu_with_hai GROUP BY gender;

-- Check duplicate stays
SELECT stay_id, COUNT(*) 
FROM icu_with_hai 
GROUP BY stay_id 
HAVING COUNT(*) > 1;

--displays anchor year to which anchor year group it is associated with. 
SELECT TOP 5 anchor_year, anchor_year_group FROM icu_with_hai;

--export file for modeling in weka
--FOCUSING ON ANCHOR YEAR GROUP 2008-2010 AND ICU-LOS-STAYS > 3
--create table to export to weka
SELECT * 
INTO icu_with_hai_filtered
FROM icu_with_hai
WHERE anchor_year_group = '2008 - 2010' AND icu_los_days > 3;
--9095 rows affected

