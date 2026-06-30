import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix

# Load engineered dataset
file_path = r"F:\coffee-shop-sales-analytics\data\processed\coffee_shop_engineered.csv"
df = pd.read_csv(file_path)

# Encode product category
le_category = LabelEncoder()
df['product_category_encoded'] = le_category.fit_transform(df['product_category'])

# Define features and target
X = df[['unit_price', 'transaction_qty', 'hour', 'month']]
y = df['product_category_encoded']

# Split into train and test sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Train Random Forest model
clf = RandomForestClassifier(n_estimators=100, random_state=42)
clf.fit(X_train, y_train)

# Predictions
y_pred = clf.predict(X_test)

# Evaluation
print("\nClassification Report:")
print(classification_report(y_test, y_pred, target_names=le_category.classes_))

print("\nConfusion Matrix:")
print(confusion_matrix(y_test, y_pred))

# Optional: Feature importance
feature_importances = pd.DataFrame({
    'Feature': X.columns,
    'Importance': clf.feature_importances_
}).sort_values(by='Importance', ascending=False)

print("\nFeature Importances:")
print(feature_importances)
