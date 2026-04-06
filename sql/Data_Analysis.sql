/*
--CREATE a DATABASE

--Upload the flat file provided in Repo 

--We have one big which is not suitable for analysis
--so we have made a star scheman by splitting the table into
--Fact and dimension table as below

--Split the tables into dimension and fact tables

--users_table
CREATE TABLE users(
	user_id VARCHAR(50) PRIMARY KEY,
	user_account_age_days INT,
	kyc_verified INT
	);

--Devices table
CREATE TABLE devices (
    device_id INT IDENTITY(1,1) PRIMARY KEY,
    device_type VARCHAR(50),
    operating_system VARCHAR(50),
    browser VARCHAR(50)
);

--Location table

CREATE TABLE location (
    location_id INT IDENTITY(1,1) PRIMARY KEY,
    city VARCHAR(50),
    country VARCHAR(50)
);

--Transactions table

CREATE TABLE transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50),
    device_id INT,
    location_id INT,
    payment_id INT,
    organization VARCHAR(50),
    transaction_amount FLOAT,
    fee_amount FLOAT,
    currency VARCHAR(10),
    transaction_timestamp DATETIME,
    merchant_category VARCHAR(100),
    transaction_type VARCHAR(50),
    is_fraud BIT,
    hour INT,
    is_night BIT,
    time_diff FLOAT,

    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (device_id) REFERENCES devices(device_id),
    FOREIGN KEY (location_id) REFERENCES location(location_id),
    FOREIGN KEY (payment_id) REFERENCES payment(payment_id)
);

--Payment table

CREATE TABLE payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    payment_method VARCHAR(50),
    card_type VARCHAR(50),
    otp_used INT
);

--Insert bulk data into dimension and fact tables from main table

INSERT INTO users (user_id, user_account_age_days, kyc_verified)
SELECT 
    user_id,
    MAX(user_account_age_days) AS user_account_age_days,
    MAX(CAST(kyc_verified AS INT)) AS kyc_verified
FROM improved_fraud_dataset
GROUP BY user_id;



INSERT INTO devices (device_type, operating_system, browser)
SELECT DISTINCT device_type, operating_system, browser
FROM improved_fraud_dataset;


INSERT INTO location (city, country)
SELECT DISTINCT city, country
FROM improved_fraud_dataset;


INSERT INTO payment (payment_method, card_type, otp_used)
SELECT DISTINCT payment_method, card_type, otp_used
FROM improved_fraud_dataset;


INSERT INTO transactions (
    transaction_id, user_id, device_id, location_id, payment_id,
    organization, transaction_amount, fee_amount, currency,
    transaction_timestamp, merchant_category, transaction_type,
    is_fraud, hour, is_night, time_diff
)
SELECT 
    f.transaction_id,
    f.user_id,
    d.device_id,
    l.location_id,
    p.payment_id,
    f.organization,
    f.transaction_amount,
    f.fee_amount,
    f.currency,
    f.transaction_timestamp,
    f.merchant_category,
    f.transaction_type,
    f.is_fraud,
    f.hour,
    f.is_night,
    f.time_diff
FROM improved_fraud_dataset f
JOIN devices d 
    ON f.device_type = d.device_type
    AND f.operating_system = d.operating_system
    AND f.browser = d.browser
JOIN location l 
    ON f.city = l.city
    AND f.country = l.country
JOIN payment p 
    ON f.payment_method = p.payment_method
    AND f.card_type = p.card_type
    AND f.otp_used = p.otp_used;


--Test the join


SELECT TOP 10
t.transaction_id,
u.kyc_verified,
d.device_type,
l.country,
p.payment_method,
t.transaction_amount,
t.is_fraud
FROM transactions t
JOIN users u ON t.user_id = u.user_id
JOIN devices d ON t.device_id = d.device_id
JOIN location l ON t.location_id = l.location_id
JOIN payment p ON t.payment_id = p.payment_id;

--Create KPI tables

SELECT 
	COUNT(*) AS total_transactions,
	SUM(CAST(is_fraud AS INT)) AS total_fraud,
	ROUND(SUM(CAST(is_fraud AS INT)) * 100.0 / COUNT(*), 2) AS fraud_percentage,
	ROUND(SUM(transaction_amount), 2) AS total_amount,
	SUM(CASE WHEN is_fraud = 1 THEN transaction_amount ELSE 0 END) AS fraud_amount
FROM transactions;

--Total fraud in Country

SELECT 
    l.country,
    COUNT(*) AS total_transactions,
    SUM(CAST(t.is_fraud AS INT)) AS fraud_transactions,
    ROUND(SUM(CAST(t.is_fraud AS INT)) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM transactions t
JOIN location l ON t.location_id = l.location_id
GROUP BY l.country
ORDER BY fraud_rate DESC;

--Fraud by payment method

SELECT
	p.payment_method,
	COUNT(*) AS total_transactions,
	SUM(CAST(t.is_fraud AS INT)) AS fraud_transactions,
	ROUND(SUM(CAST(t.is_fraud AS INT)) * 100.0 / COUNT(*), 2) AS fraud_rate
	FROM transactions t
	JOIN payment p ON t.payment_id = p.payment_id
	GROUP BY p.payment_method
	ORDER BY	fraud_rate DESC;

--Fraud by Device Type

SELECT 
    d.device_type,
    COUNT(*) AS total_transactions,
    SUM(CAST(t.is_fraud AS INT)) AS fraud_transactions,
    ROUND(SUM(CAST(t.is_fraud AS INT)) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM transactions t
JOIN devices d ON t.device_id = d.device_id
GROUP BY d.device_type
ORDER BY fraud_rate DESC;

--Fraud by KYC verified on not

SELECT 
    u.kyc_verified,
    COUNT(*) AS total_transactions,
    SUM(CAST(t.is_fraud AS INT)) AS fraud_transactions,
    ROUND(SUM(CAST(t.is_fraud AS INT)) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM transactions t
JOIN users u ON t.user_id = u.user_id
GROUP BY u.kyc_verified;


--All frauds usually happens at Night so we should check the rate
--Fraud on Day vs Night

SELECT 
    is_night,
    COUNT(*) AS total_transactions,
    SUM(CAST(is_fraud AS INT)) AS fraud_transactions,
    ROUND(SUM(CAST(is_fraud AS INT)) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY is_night;


--Fraud by amount range

SELECT 
    CASE 
        WHEN transaction_amount < 100 THEN 'Low'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'High'
    END AS amount_range,
    COUNT(*) AS total_transactions,
    SUM(CAST(is_fraud AS INT)) AS fraud_transactions,
    ROUND(SUM(CAST(is_fraud AS INT)) * 100.0 / COUNT(*), 2) AS fraud_rate
FROM transactions
GROUP BY 
    CASE 
        WHEN transaction_amount < 100 THEN 'Low'
        WHEN transaction_amount BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'High'
    END
ORDER BY fraud_rate DESC;

--WE are going to create a view for use in python and power BI

CREATE VIEW fraud_analysis_view AS
SELECT
	t.transaction_id,
    t.transaction_amount,
    t.transaction_timestamp,
    t.is_fraud,
    t.hour,
    t.is_night,
    u.user_account_age_days,
    u.kyc_verified,
    d.device_type,
    d.operating_system,
    l.country,
    l.city,
    p.payment_method,
    p.card_type,
    t.merchant_category
FROM transactions t
JOIN users u ON t.user_id = u.user_id
JOIN devices d ON t.device_id = d.device_id
JOIN location l ON t.location_id = l.location_id
JOIN payment p ON t.payment_id = p.payment_id;

SELECT * FROM fraud_analysis_view

--Create a clean view

CREATE VIEW clean_fraud_data AS
SELECT *
FROM fraud_analysis_view
WHERE transaction_amount > 0;

SELECT * FROM clean_fraud_data
*/

--Now we can export this clean view to use in python and power BI

