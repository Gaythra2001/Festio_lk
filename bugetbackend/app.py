from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import numpy as np

model = joblib.load("budget_model.pkl")

app = Flask(__name__)
CORS(app)

@app.route("/predict", methods=["POST"])
def predict():
    data = request.json

    guests = data.get("guests")
    eventType = data.get("eventType")
    location = data.get("location")
    venueType = data.get("venueType")
    foodType = data.get("foodType")
    entertainment = data.get("entertainment")
    duration = data.get("duration")
    extras = data.get("extras")

    if None in [guests, eventType, location, venueType, foodType, entertainment, duration, extras]:
        return jsonify({"error": "Missing input values"}), 400

    # ⚠️ MUST MATCH NEW MODEL (8 FEATURES)
    features = np.array([[
        guests,
        eventType,
        location,
        venueType,
        foodType,
        entertainment,
        duration,
        extras
    ]])

    predicted_cost = model.predict(features)

    total_budget = round(predicted_cost[0], 2)

    breakdown = {
        "Food": total_budget * 0.4,
        "Venue": total_budget * 0.3,
        "Decoration": total_budget * 0.2,
        "Entertainment": total_budget * 0.1
    }

    return jsonify({
        "predicted_cost": total_budget,
        "breakdown": breakdown
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)