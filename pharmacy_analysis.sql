-- Top 10 Most Prescribed Drugs
-- Which drugs were prescribed the most in the last 6 months?
SELECT
    d.drug_name,
    SUM(p.quantity) AS total_prescribed_quantity
FROM
    prescriptions p
JOIN
    drugs d ON p.drug_id = d.drug_id
WHERE
    p.prescription_date >= CURDATE() - INTERVAL 6 MONTH
GROUP BY
    d.drug_name
ORDER BY
    total_prescribed_quantity DESC
LIMIT 10;

-- Monthly Revenue Trends
-- How much total revenue was generated month by month?
-- Formula: quantity * price_per_unit
SELECT
    DATE_FORMAT(p.prescription_date, '%Y-%m') AS sales_month,
    SUM(p.quantity * d.price_per_unit) AS total_revenue
FROM
    prescriptions p
JOIN
    drugs d ON p.drug_id = d.drug_id
GROUP BY
    sales_month
ORDER BY
    sales_month;

-- Revenue per Drug Category
-- Which drug categories brought in the highest revenue?
SELECT
    d.category AS drug_category, -- column name'category'
    SUM(p.quantity * d.price_per_unit) AS total_category_revenue
FROM
    prescriptions p
JOIN
    drugs d ON p.drug_id = d.drug_id
GROUP BY
    drug_category
ORDER BY
    total_category_revenue DESC;

-- Repeat Patients
-- Which patients had more than one prescription filled?
SELECT
    pt.patient_id,
    pt.name AS patient_name, -- column 'name'
    COUNT(DISTINCT pr.prescription_id) AS number_of_prescriptions
FROM
    patients pt
JOIN
    prescriptions pr ON pt.patient_id = pr.patient_id
GROUP BY
    pt.patient_id, pt.name
HAVING
    COUNT(DISTINCT pr.prescription_id) > 1
ORDER BY
    number_of_prescriptions DESC;

-- Top Performing Pharmacists
-- Who filled the most prescriptions? Rank them.
SELECT
    ph.pharmacist_id,
    ph.name AS pharmacist_name, -- column name'name'
    COUNT(pr.prescription_id) AS total_prescriptions_filled
FROM
    pharmacists ph
JOIN
    prescriptions pr ON ph.pharmacist_id = pr.pharmacist_id
GROUP BY
    ph.pharmacist_id, ph.name
ORDER BY
    total_prescriptions_filled DESC;

-- Age Group vs. Most Common Drug Categories
-- What drug categories are most prescribed to different age groups (e.g., <18, 18–35, 36–60, 60+)?
SELECT
    CASE
        WHEN pt.age < 18 THEN '<18'
        WHEN pt.age BETWEEN 18 AND 35 THEN '18-35'
        WHEN pt.age BETWEEN 36 AND 60 THEN '36-60'
        ELSE '60+'
    END AS age_group,
    d.category AS drug_category,
    COUNT(p.prescription_id) AS total_prescriptions
FROM
    prescriptions p
JOIN
    patients pt ON p.patient_id = pt.patient_id
JOIN
    drugs d ON p.drug_id = d.drug_id
GROUP BY
    age_group, drug_category
ORDER BY
    age_group, total_prescriptions DESC;

-- Prescription Trends Over Time (Monthly Trend)
-- What does the prescription volume trend look like month by month?
SELECT
    DATE_FORMAT(prescription_date, '%Y-%m') AS prescription_month,
    COUNT(prescription_id) AS total_prescriptions
FROM
    prescriptions
GROUP BY
    prescription_month
ORDER BY
    prescription_month;

-- Prescription Trends Over Time (Weekly Trend)
-- What does the prescription volume trend look like week by week?
SELECT
    DATE_FORMAT(prescription_date, '%Y-%u') AS prescription_week, -- %u is week number (00-53)
    COUNT(prescription_id) AS total_prescriptions
FROM
    prescriptions
GROUP BY
    prescription_week
ORDER BY
    prescription_week;

-- Average Quantity Per Prescription (Overall Average)
-- What is the average quantity of drugs prescribed per prescription overall?
SELECT
    AVG(quantity) AS average_quantity_per_prescription
FROM
    prescriptions;

-- Average Quantity Per Prescription (Average Quantity by Drug)
-- What is the average quantity of drugs prescribed per prescription by drug?
SELECT
    d.drug_name,
    AVG(p.quantity) AS average_quantity
FROM
    prescriptions p
JOIN
    drugs d ON p.drug_id = d.drug_id
GROUP BY
    d.drug_name
ORDER BY
    average_quantity DESC;
