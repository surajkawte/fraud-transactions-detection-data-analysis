# Fraud Detection Data Analysis Project

## Overview

This project performs end-to-end fraud detection data analysis using SQL Server, Python, and Power BI.
The goal of this project is to analyze financial transaction data, identify fraud patterns, and create a dashboard for business insights.

---

## Dataset Information

The original dataset used in this project is large and cannot be uploaded to GitHub due to file size limitations.
Therefore, a **sample dataset** is included in the `data/` folder for demonstration purposes.

You can download the original dataset from Kaggle:
https://www.kaggle.com/datasets/mdmahfuzsumon/large-scale-financial-fraud-dataset

---

## Tools & Technologies Used

* SQL Server – Data Cleaning, Data Transformation, Data Modeling
* Python – Data Cleaning, Feature Engineering, Exploratory Data Analysis
* Pandas, NumPy – Data Manipulation
* Power BI – Dashboard & Visualization
* GitHub – Version Control & Project Portfolio

---

## Project Workflow

1. Raw Data (CSV)
2. Data Cleaning using SQL
3. Data Modeling (Star Schema)
4. Data Analysis using SQL
5. Data Extraction using Python
6. Data Cleaning & Feature Engineering in Python
7. Exploratory Data Analysis (EDA)
8. Power BI Dashboard (Business Insights)

---

## Database Data Model (Star Schema)

The dataset was normalized and divided into multiple tables:

* **transactions** (Fact Table)
* **users** (Dimension Table)
* **devices** (Dimension Table)
* **location** (Dimension Table)
* **payment** (Dimension Table)

This star schema model improves query performance and is suitable for reporting and dashboarding.

---

## Analysis Performed

The following analysis was performed:

* Fraud rate calculation
* Fraud by country
* Fraud by device type
* Fraud by payment method
* Fraud by time of day
* Fraud by transaction amount category
* Fraud by KYC verified vs non-verified users
* Fraud trend by hour
* High-risk transaction analysis
* Feature engineering for fraud analysis

---

## Python – Connecting to SQL Server

Python was connected to SQL Server using **pyodbc** to extract clean data.

Example connection code:

```python
import pyodbc
import pandas as pd

conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=YOUR_SERVER_NAME;"
    "DATABASE=fraud_analysis;"
    "Trusted_Connection=yes;"
)

query = "SELECT * FROM clean_fraud_data"
df = pd.read_sql(query, conn)
```

---

## Project Structure

```
fraud-transactions-detection-data-analysis
│
├── data
│   ├── sample_cleaned_data.csv      -> Sample dataset used for analysis
│   ├── fraud_by_country.csv         -> Fraud analysis by country
│   ├── fraud_by_device.csv          -> Fraud analysis by device
│   ├── fraud_by_payment.csv         -> Fraud analysis by payment method
│   └── fraud_by_hour.csv            -> Fraud analysis by hour
│
├── notebooks
│   └── analysis.ipynb               -> Jupyter notebook for EDA and analysis
│
├── scripts
│   └── data_analysis.py             -> Main Python script for data cleaning and analysis
│
├── sql
│   └── queries.sql                  -> SQL queries for data cleaning and analysis
│
├── requirements.txt                 -> Python libraries required for the project
├── README.md                        -> Project documentation
└── .gitignore                       -> Ignored files (large datasets, venv, cache files)
```

---

## Key Business Insights

* Fraud transactions are higher for high-value transactions.
* Fraud occurs more frequently during night hours.
* Non-KYC verified users have higher fraud probability.
* Certain payment methods and device types are more prone to fraud.
* Fraud rate varies across countries and merchant categories.

---

## Skills Demonstrated

* SQL Data Cleaning & Transformation
* Data Modeling (Star Schema)
* SQL Joins & Aggregations
* Python Data Analysis (Pandas)
* Feature Engineering
* Exploratory Data Analysis (EDA)
* Data Visualization (Power BI)
* GitHub Project Management

---

## Author

**Suraj – Senior Data Analyst**
