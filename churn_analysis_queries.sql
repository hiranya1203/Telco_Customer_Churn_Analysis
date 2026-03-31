CREATE DATABASE Churn_Analysis;
USE Churn_Analysis;
SELECT * 
FROM telco_cusomer_churn LIMIT 5;
ALTER TABLE telco_cusomer_churn
RENAME TO telco_customer_churn;

SELECT COUNT(*)
FROM telco_customer_churn;
-- Over all Churn
SELECT 
    Churn,
    COUNT(*) AS total_customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM telco_customer_churn
GROUP BY Churn;
-- Churn by Contract Type
SELECT 
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS churn_rate
FROM telco_customer_churn
GROUP BY Contract
ORDER BY churn_rate DESC;
-- New vs Old customer churn
SELECT 
    CASE 
        WHEN tenure BETWEEN 0 AND 12 THEN 'New (0-12m)'
        WHEN tenure BETWEEN 13 AND 24 THEN 'Growing (12-24m)'
        WHEN tenure BETWEEN 25 AND 48 THEN 'Established (24-48m)'
        ELSE 'Loyal (48-72m)'
    END AS tenure_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS churn_rate
FROM telco_customer_churn
GROUP BY tenure_group
ORDER BY churn_rate DESC;
-- Churn by Internet Service
SELECT 
    InternetService,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS churn_rate
FROM telco_customer_churn
GROUP BY InternetService
ORDER BY churn_rate DESC;
-- Feature usage leading indicators
SELECT
    TechSupport,
    OnlineSecurity,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS churn_rate
FROM telco_customer_churn
GROUP BY TechSupport, OnlineSecurity
ORDER BY churn_rate DESC;
-- High value customer identification
SELECT 
    customerID,
    tenure,
    MonthlyCharges,
    TotalCharges,
    Contract,
    Churn,
    CASE 
        WHEN MonthlyCharges > 89.85 THEN 'High Value'
        WHEN MonthlyCharges > 35.50 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM telco_customer_churn
ORDER BY MonthlyCharges DESC
LIMIT 20;
-- Segment + contract combination
SELECT 
    CASE 
        WHEN MonthlyCharges > 89.85 THEN 'High Value'
        WHEN MonthlyCharges > 35.50 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_segment,
    Contract,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) 
          * 100.0 / COUNT(*), 2) AS churn_rate
FROM telco_customer_churn
GROUP BY customer_segment, Contract
ORDER BY churn_rate DESC;
-- Churn Playbook triggers flags
SELECT
    customerID,
    tenure,
    MonthlyCharges,
    Contract,
    TechSupport,
    OnlineSecurity,
    Churn,
    CASE
        WHEN tenure < 12 AND Contract = 'Month-to-month' 
            THEN 'High Risk — Immediate Action'
        WHEN MonthlyCharges > 89.85 AND Churn = 'Yes' 
            THEN 'High Value Lost — Investigate'
        WHEN TechSupport = 'No' AND OnlineSecurity = 'No' 
            THEN 'Feature Gap — Upsell Opportunity'
        ELSE 'Stable'
    END AS intervention_flag
FROM telco_customer_churn
ORDER BY intervention_flag
LIMIT 50;
