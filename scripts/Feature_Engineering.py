import pandas as pd

# Load cleaned dataset
file_path = r"F:\coffee-shop-sales-analytics\data\processed\coffee_shop_clean.xlsx"
df = pd.read_excel(file_path)

print("Available columns:", df.columns.tolist())   


if 'transaction_date' in df.columns and 'transaction_time' in df.columns:
    df['transaction_datetime'] = pd.to_datetime(
        df['transaction_date'].astype(str) + " " + df['transaction_time'].astype(str)
    )
elif 'transaction_datetime' in df.columns:
    df['transaction_datetime'] = pd.to_datetime(df['transaction_datetime'])
else:
    print("Error: transaction date/time column not found!")
    print(df.columns.tolist())

# Feature Engineering
df['hour'] = df['transaction_datetime'].dt.hour
df['day'] = df['transaction_datetime'].dt.day
df['month'] = df['transaction_datetime'].dt.month
df['weekday'] = df['transaction_datetime'].dt.day_name()

# Revenue per transaction
df['total_amount'] = df['transaction_qty'] * df['unit_price']

# Customer basket size
df['basket_size'] = df['transaction_qty']

# Price category
df['price_category'] = pd.cut(df['unit_price'],
                              bins=[0, 2.5, 4, 10],
                              labels=['Low', 'Medium', 'High'])

print("\nFirst 5 rows:")
print(df.head())

# Save the engineered data 
df.to_csv(r"F:\coffee-shop-sales-analytics\data\processed\coffee_shop_engineered.csv", index=False)
print("Feature Engineering completed and saved!")
