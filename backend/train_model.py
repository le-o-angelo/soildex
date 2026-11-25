import joblib
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, r2_score
from sklearn.model_selection import train_test_split

# 1. Load the dataset
print("Loading dataset...")
df = pd.read_csv("agro_environmental_dataset.csv")

# 2. Keep ONLY the 4 sensor columns, the plant category, and the target score
columns_to_keep = [
    "soil_ph",
    "soil_moisture_pct",
    "salinity_ec",
    "soil_temp_c",
    "plant_category",
    "suitability_score",
]
df = df[columns_to_keep].copy()

# 3. Convert text categories ('cereal', 'legume', 'vegetable') into 1s and 0s
# Computers only understand numbers, so this creates 3 True/False columns
df_encoded = pd.get_dummies(df, columns=["plant_category"], dtype=int)

# Separate the clues (X) from the answer (y)
X = df_encoded.drop("suitability_score", axis=1)
y = df_encoded["suitability_score"]

# 4. Split into 80% Study Material (Train) and 20% Final Exam (Test)
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# 5. Train the model
print("Training the model (this takes ~15-30 seconds)...")
model = RandomForestRegressor(
    n_estimators=50,  # Builds 50 decision trees
    max_depth=12,  # Limits tree depth so the saved file stays lightweight
    random_state=42,
    n_jobs=-1,  # Uses all your computer's CPU cores to train faster
)
model.fit(X_train, y_train)

# 6. Check accuracy on the hidden test data
predictions = model.predict(X_test)
error = mean_absolute_error(y_test, predictions)
accuracy_r2 = r2_score(y_test, predictions)

print(
    f"Done! Average prediction error: ±{error * 100:.1f}% | R2 Score:"
    f" {accuracy_r2:.2f}"
)

# 7. Save the trained model AND the exact column order to a file
model_bundle = {"model": model, "feature_columns": X.columns.tolist()}
joblib.dump(model_bundle, "soil_rating_model.joblib")
print("Saved model to 'soil_rating_model.joblib'")