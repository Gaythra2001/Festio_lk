"""
╔══════════════════════════════════════════════════════╗
║   Festio LK — Event Validation API  (FastAPI)       ║
║   POST /predict-event                               ║
╚══════════════════════════════════════════════════════╝

Setup:
    pip install fastapi uvicorn scikit-learn pandas numpy scipy
    python festio_ml_solution.py   # train & save model_artifacts/
    uvicorn festio_api:app --reload --port 8000

Interactive docs:
    http://localhost:8000/docs
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import pickle, warnings
import numpy as np
from scipy.sparse import hstack, csr_matrix
from pathlib import Path

warnings.filterwarnings("ignore")

# ── Load saved artifacts ───────────────────────────────────────────────────────
_BASE = Path(__file__).parent / "model_artifacts"

def _load(name):
    with open(_BASE / name, "rb") as f:
        return pickle.load(f)

model       = _load("model.pkl")
tfidf       = _load("tfidf.pkl")
scaler      = _load("scaler.pkl")
le_location = _load("le_location.pkl")
le_category = _load("le_category.pkl")

# ── FastAPI app ────────────────────────────────────────────────────────────────
app = FastAPI(
    title="Festio LK — Event Validation API",
    description=(
        "AI-powered event classifier for the **Festio LK** platform.\n\n"
        "Submit any event's details and receive a **Real / Fake** verdict "
        "with a confidence score, ready to integrate into your existing backend."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # ← restrict to your domain in production
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Schemas ────────────────────────────────────────────────────────────────────
class EventRequest(BaseModel):
    title:       str   = Field(..., min_length=3,  example="Music Concert in Kandy")
    description: str   = Field(..., min_length=10, example="A live music night with local Sri Lankan bands.")
    price:       float = Field(..., ge=0,           example=1500)
    location:    str   = Field(..., min_length=2,  example="Kandy")
    category:    str   = Field(..., min_length=2,  example="Music Concert")

    class Config:
        json_schema_extra = {
            "example": {
                "title":       "Music Concert in Kandy",
                "description": "A live music night featuring acclaimed local bands at the Kandy Esplanade.",
                "price":       1500,
                "location":    "Kandy",
                "category":    "Music Concert",
            }
        }


class EventResponse(BaseModel):
    prediction:       str   = Field(..., example="Real", description='"Real" or "Fake"')
    confidence:       float = Field(..., example=97.5,   description="Confidence score 0–100 %")
    real_probability: float = Field(..., example=0.975,  description="Raw model probability for Real")
    fake_probability: float = Field(..., example=0.025,  description="Raw model probability for Fake")
    is_valid:         bool  = Field(..., example=True,   description="True when prediction == 'Real'")


# ── Helper ─────────────────────────────────────────────────────────────────────
def _safe_encode(encoder, value: str) -> int:
    try:
        return int(encoder.transform([value])[0])
    except ValueError:
        return 0


# ── Routes ─────────────────────────────────────────────────────────────────────
@app.get("/", tags=["Health"])
def root():
    return {"status": "ok", "service": "Festio LK Event Validation API v1.0"}


@app.get("/health", tags=["Health"])
def health():
    return {"status": "healthy", "model": type(model).__name__}


@app.post(
    "/predict-event",
    response_model=EventResponse,
    summary="Classify an event as Real or Fake",
    tags=["Prediction"],
)
def predict(event: EventRequest):
    """
    **Validates a submitted event** using a trained Random Forest model.

    ### Input
    | Field | Type | Description |
    |-------|------|-------------|
    | title | str | Event title |
    | description | str | Full event description |
    | price | float | Ticket price (LKR, ≥ 0) |
    | location | str | City / district (e.g. "Colombo") |
    | category | str | Event type (e.g. "Music Concert") |

    ### Output
    | Field | Type | Description |
    |-------|------|-------------|
    | prediction | str | `"Real"` or `"Fake"` |
    | confidence | float | 0–100 % certainty in the predicted class |
    | real_probability | float | Raw P(real) |
    | fake_probability | float | Raw P(fake) |
    | is_valid | bool | `true` when prediction == `"Real"` |
    """
    try:
        text   = f"{event.title} {event.description}"
        X_txt  = tfidf.transform([text])
        loc_e  = _safe_encode(le_location, event.location)
        cat_e  = _safe_encode(le_category, event.category)
        X_n    = scaler.transform([[event.price, loc_e, cat_e]])
        X_feat = hstack([X_txt, csr_matrix(X_n)])

        probs     = model.predict_proba(X_feat)[0]
        real_prob = float(probs[1])
        fake_prob = float(probs[0])
        label     = "Real" if real_prob >= 0.5 else "Fake"
        confidence = real_prob * 100 if label == "Real" else fake_prob * 100

        return EventResponse(
            prediction       = label,
            confidence       = round(confidence, 2),
            real_probability = round(real_prob, 4),
            fake_probability = round(fake_prob, 4),
            is_valid         = label == "Real",
        )

    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Prediction error: {exc}")
