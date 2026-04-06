SELECT * FROM clean_fraud_data;

SELECT country, COUNT(*) AS total_txn,
SUM(CAST(is_fraud AS INT)) AS fraud_txn
FROM fraud_analysis_view
GROUP BY country;

SELECT device_type, COUNT(*),
SUM(CAST(is_fraud AS INT))
FROM fraud_analysis_view
GROUP BY device_type;