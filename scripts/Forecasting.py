import pandas as pd
from prophet import Prophet

# Load processed dataset
file_path = r"F:\coffee-shop-sales-analytics\data\processed\coffee_shop_clean.xlsx"
df = pd.read_excel(file_path)

print("Available columns:", df.columns.tolist())

# Ensure transaction_datetime exists
if 'transaction_datetime' in df.columns:
    df['transaction_datetime'] = pd.to_datetime(df['transaction_datetime'])
elif 'transaction_date' in df.columns and 'transaction_time' in df.columns:
    df['transaction_datetime'] = pd.to_datetime(
        df['transaction_date'].astype(str) + " " + df['transaction_time'].astype(str)
    )
else:
    raise KeyError("No transaction_datetime or transaction_date/transaction_time columns found!")

# Ensure total_amount exists
if 'total_amount' not in df.columns:
    df['total_amount'] = df['transaction_qty'] * df['unit_price']

# Aggregate daily revenue
daily_sales = df.groupby(df['transaction_datetime'].dt.date).agg({'total_amount': 'sum'}).reset_index()
daily_sales = daily_sales.rename(columns={'transaction_datetime': 'ds', 'total_amount': 'y'})

print("\nDaily sales preview:")
print(daily_sales.head())

# Fit Prophet model
model = Prophet()
model.fit(daily_sales)

# Forecast next 30 days
future = model.make_future_dataframe(periods=30)
forecast = model.predict(future)

# Plot forecast
model.plot(forecast)
model.plot_components(forecast)

