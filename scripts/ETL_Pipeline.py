import pandas as pd
from sqlalchemy import create_engine

# 1. Load raw CSV
file_path = r"F:\coffee-shop-sales-analytics\data\raw\coffee_shop_raw_data.csv"
df = pd.read_csv(file_path)

# 2. Clean & transform
df['transaction_datetime'] = pd.to_datetime(df['transaction_date'] + " " + df['transaction_time'])
df['transaction_qty'] = df['transaction_qty'].astype(int)
df['unit_price'] = df['unit_price'].astype(float)
df['total_amount'] = df['transaction_qty'] * df['unit_price']

# Extract time features
df['hour'] = df['transaction_datetime'].dt.hour
df['day'] = df['transaction_datetime'].dt.day
df['month'] = df['transaction_datetime'].dt.month
df['weekday'] = df['transaction_datetime'].dt.day_name()

# 3. Connect to PostgreSQL
engine = create_engine("postgresql://postgres:1234@localhost:5432/coffee_shop_sales")

# 4. Load into database
df.to_sql("coffee_shop_sales", engine, if_exists="replace", index=False)

print("ETL pipeline complete — data loaded into PostgreSQL!")