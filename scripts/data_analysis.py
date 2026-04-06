import pyodbc
import warnings
warnings.filterwarnings("ignore")
import pandas as pd
import os
import seaborn as sns
import matplotlib.pyplot as plt

# Connect to SQL server

conn = pyodbc.connect(
    "DRIVER={SQL Server};"
    "SERVER={Server name;"
    "DATABASE=fraud_analysis;"
    "Trusted_Connection = yes;"
)

# Query
query = "SELECT * FROM clean_fraud_data"

df = pd.read_sql(query, conn)

# Basic data check

print("shape:", df.shape)
print("Columns:", df.columns.tolist())
print("data types:\n", df.dtypes)
print("missing values:\n", df.isnull().sum())
print("Duplicate Rows:\n", df.duplicated().sum())

# check missing values
print(df.isnull().sum())

# Missing values replacement
df["merchant_category"].fillna("Unknown", inplace = True)
df.dropna(subset = ["transaction_amount"], inplace = True)


# Change the data type of columns where required

df["transaction_timestamp"] = pd.to_datetime(df["transaction_timestamp"])
df["is_fraud"] = df["is_fraud"].astype(int)
df["is_night"] = df["is_night"].astype(int)

print(df.dtypes)


# Remove duplicates
df.drop_duplicates(subset = "transaction_id", inplace= True)

# Remove invalid transactions
df = df[df["transaction_amount"] > 0]

# We will now perform advanced analysis bby feature engineering
# Here we will create new columns from existing data

# Transaction amount category

df["amount_category"] = pd.cut(
    df["transaction_amount"],
    bins = [0,100, 500, 1000, 5000],
    labels = ["Low", "Medium", "High", "Very High"]
)


# User age group

df["account_age_group"] = pd.cut(
    df["user_account_age_days"],
    bins = [0,30, 180, 365, 1000],
    labels = ["New", "Medium", "Old", "Very Old"]
)

# Fraud by Device

fraud_device = df.groupby('device_type').agg(
    total = ("transaction_id", "count"),
    fraud = ("is_fraud", "sum"),
    fraud_rate = ("is_fraud", "mean")
)
print(fraud_device)


# Fraud rate by country

fraud_country = df.groupby("country").agg(
    total_transactions = ("transaction_id", "count"),
    fraud_transactions = ("is_fraud", "sum"),
    fraud_rate = ("is_fraud", "mean"),
    avg_amount = ("transaction_amount", "mean")
).sort_values(by = "fraud_rate", ascending = False)

print(fraud_country)

# Fraud count at weekend

df["is_weekend"] = df["transaction_timestamp"].dt.dayofweek.isin([5,6]).astype(int)

# Hour category

df["time_of_day"] = pd.cut(
    df["hour"],
    bins = [0,6,12,18,24],
    labels = ["Night", "Morning", "Afternoon", "evening"]
)

# cross tab
# This process is used a lot in data analysis for short analysis

# fraud vs device
print(pd.crosstab(df["device_type"], df["is_fraud"]))

# fraud vs payment method
print(pd.crosstab(df["payment_method"], df["is_fraud"]))

# Fraud vs time of day
print(pd.crosstab(df["time_of_day"], df["is_fraud"]))

#Correlations
corr = df.corr(numeric_only = True)
print(corr["is_fraud"].sort_values(ascending = False))

#Top fraud users

top_fraud_users = df[df["is_fraud"] == 1].groupby("transaction_id").size()
print(top_fraud_users.head())


# Save the clean data

base_path = os.path.dirname(os.path.dirname(__file__))
file_path = os.path.join(base_path, "data", "clean_data_python.csv")

df.to_csv(file_path, index = False)
print("file saved at:", file_path)

# Pivot table
# Below query shows amount for fraud and non-fraud by payment method
pivot_table = pd.pivot_table(
    df,
    values=  "transaction_amount",
    index = "payment_method",
    columns = "is_fraud",
    aggfunc = "mean"
)

print(pivot_table)

# Time based analysis

# Fraud by hour

fraud_by_hour = df.groupby('hour').agg(
    total = ("transaction_id", "count"),
    fraud = ("is_fraud", "sum")
)

fraud_by_hour["fraud_rate"] = fraud_by_hour['fraud'] / fraud_by_hour["total"]

print(fraud_by_hour)

# Now it's time to do data visualization
# Fraud vs non- fraud

sns.countplot(x = "is_fraud", data = df)
plt.title("Fraud vs Non-fraud")
plt.show()

# Fraud by device

sns.countplot(x = "device_type", hue = "is_fraud", data = df)
plt.title("Fraud by device")
plt.show()

# Fraud by Payment
sns.countplot(x='payment_method', hue='is_fraud', data=df)
plt.title("Fraud by Payment Method")
plt.show()

# Transaction Amount Distribution
sns.histplot(df['transaction_amount'], bins=50)
plt.title("Transaction Amount Distribution")
plt.show()

# code to create sample dataset

df_sample = df.sample(n = 5000, random_state = 42)
# Get project root directory
base_path = os.path.dirname(os.path.dirname(__file__))

# Create data folder if it doesn't exist
data_path = os.path.join(base_path, "data")
os.makedirs(data_path, exist_ok=True)

# Save sample file
file_path = os.path.join(data_path, "sample_cleaned_data.csv")
df_sample.to_csv(file_path, index=False)

print("Sample file saved at:", file_path)












