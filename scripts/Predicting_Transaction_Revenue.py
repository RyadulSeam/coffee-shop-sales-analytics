import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error

# Load processed dataset
file_path = r"F:\coffee-shop-sales-analytics\data\processed\coffee_shop_engineered.csv"
df = pd.read_csv(file_path)

# Define features and target
X = df[['transaction_qty', 'unit_price', 'hour', 'month']]
y = df['total_amount']

# Split into train and test sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train Linear Regression model
reg = LinearRegression()
reg.fit(X_train, y_train)

# Predict on test set
y_pred = reg.predict(X_test)

# Evaluate model (RMSE)
rmse = np.sqrt(mean_squared_error(y_test, y_pred))
print("Root Mean Squared Error (RMSE):", rmse)

# Show coefficients
coefficients = pd.DataFrame({
    'Feature': X.columns,
    'Coefficient': reg.coef_
})
print("\nModel Coefficients:")
print(coefficients)
