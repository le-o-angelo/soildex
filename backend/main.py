from typing import Optional
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import joblib
import pandas as pd
from pydantic import BaseModel

app = FastAPI(title="Soil Quality Rating API")

# Allow your Flutter Web/Mobile app to connect without browser security blocks
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the saved brain once when the server starts
bundle = joblib.load("soil_rating_model.joblib")
model = bundle["model"]
feature_columns = bundle["feature_columns"]

# Map specific user-selected crops to your dataset's 3 categories
CROP_TO_CATEGORY = {
    "rice": "cereal",
    "maize": "cereal",
    "corn": "cereal",
    "wheat": "cereal",
    "soybean": "legume",
    "chickpea": "legume",
    "lentil": "legume",
    "beans": "legume",
    "tomato": "vegetable",
    "lettuce": "vegetable",
    "potato": "vegetable",
    "carrot": "vegetable",
    # You can also pass 'cereal', 'legume', or 'vegetable' directly
    "cereal": "cereal",
    "legume": "legume",
    "vegetable": "vegetable",
}


# Define the exact JSON data Flutter will send
class SoilInput(BaseModel):
    ph: float
    moisture: float
    ec: float
    temperature: float
    plant: Optional[str] = None  # Optional! Leave empty/null for general rating


def predict_for_category(data: SoilInput, category: str) -> float:
    row = pd.DataFrame([{
        "soil_ph": data.ph,
        "soil_moisture_pct": data.moisture,
        "salinity_ec": data.ec,
        "soil_temp_c": data.temperature,
        "plant_category_cereal": 1 if category == "cereal" else 0,
        "plant_category_legume": 1 if category == "legume" else 0,
        "plant_category_vegetable": 1 if category == "vegetable" else 0,
    }])[feature_columns]
    score = float(model.predict(row)[0])
    return round(score * 100, 1)  # Convert 0.0-1.0 to 0-100%


@app.post("/rate-soil")
def rate_soil(data: SoilInput):
    # MODE 1: User selected a specific plant
    if data.plant and data.plant.strip():
        clean_plant = data.plant.strip().lower()
        category = CROP_TO_CATEGORY.get(clean_plant)

        if not category:
            return {
                "error": (
                    f"Unknown plant '{data.plant}'. Supported:"
                    f" {list(CROP_TO_CATEGORY.keys())}"
                )
            }

        score = predict_for_category(data, category)
        return {
            "mode": "plant_specific",
            "plant": data.plant,
            "category_used": category,
            "rating_percent": score,
            "status": (
                "Optimal"
                if score >= 75
                else ("Moderate" if score >= 50 else "Poor")
            ),
        }

    # MODE 2: General soil quality (no plant chosen)
    scores = {
        cat: predict_for_category(data, cat)
        for cat in ["cereal", "legume", "vegetable"]
    }
    avg_score = round(sum(scores.values()) / len(scores), 1)
    best_category = max(scores, key=scores.get)

    return {
        "mode": "general",
        "rating_percent": avg_score,
        "best_suited_for": best_category,
        "breakdown": scores,
        "status": (
            "Optimal"
            if avg_score >= 75
            else ("Moderate" if avg_score >= 50 else "Poor")
        ),
    }