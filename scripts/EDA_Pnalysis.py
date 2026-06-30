import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# 1. Load raw CSV (or processed file if you prefer)
file_path = r"F:\coffee-shop-sales-analytics\data\raw\coffee_shop_raw_data.csv"
df = pd.read_csv(file_path)

# 2. Quick EDA
print("Shape:", df.shape)
print("Columns:", df.columns)
print(df.info())
print(df.describe(include='all'))

# Check for missing values
print("Missing values:\n", df.isnull().sum())

# 3. Transform for analysis
df['transaction_datetime'] = pd.to_datetime(df['transaction_date'] + " " + df['transaction_time'])
df['transaction_qty'] = df['transaction_qty'].astype(int)
df['unit_price'] = df['unit_price'].astype(float)
df['total_amount'] = df['transaction_qty'] * df['unit_price']
df['hour'] = df['transaction_datetime'].dt.hour
df['weekday'] = df['transaction_datetime'].dt.day_name()

# 4. Visuals
plt.figure(figsize=(10,6))
sns.countplot(x='product_category', data=df, order=df['product_category'].value_counts().index)
plt.title("Transactions by Product Category")
plt.xticks(rotation=45)
plt.show()

plt.figure(figsize=(10,6))
sns.lineplot(x='hour', y='total_amount', data=df.groupby('hour')['total_amount'].sum().reset_index())
plt.title("Revenue by Hour of Day")
plt.show()

plt.figure(figsize=(10,6))
sns.barplot(x='store_location', y='total_amount', data=df.groupby('store_location')['total_amount'].sum().reset_index())
plt.title("Revenue by Store Location")
plt.show()
