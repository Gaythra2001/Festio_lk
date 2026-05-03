"""
╔══════════════════════════════════════════════════════════════════════════════╗
║          Festio LK — AI Event Validation  |  Complete ML Solution           ║
╚══════════════════════════════════════════════════════════════════════════════╝

FILES PRODUCED
──────────────
  train_model.py   — run once to train & save model artifacts
  predictor.py     — import predict_event() anywhere in your backend
  main.py          — FastAPI server   →  uvicorn main:app --reload

QUICK START
───────────
  1.  pip install scikit-learn pandas numpy scipy fastapi uvicorn
  2.  python train_model.py          # produces model_artifacts/
  3.  python predictor.py            # quick smoke-test
  4.  uvicorn main:app --reload      # start the API on :8000
  5.  POST http://localhost:8000/predict-event
"""

# ════════════════════════════════════════════════════════════════════════════
#  PART 1 — DATA LOADING & CLEANING
# ════════════════════════════════════════════════════════════════════════════
import pandas as pd
import numpy as np
import pickle, os, warnings
warnings.filterwarnings("ignore")

from sklearn.ensemble        import RandomForestClassifier
from sklearn.linear_model    import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.preprocessing   import LabelEncoder, StandardScaler
from sklearn.metrics         import (
    accuracy_score, precision_score, recall_score, f1_score,
    classification_report, confusion_matrix,
)
from scipy.sparse import hstack, csr_matrix

# ── Load ──────────────────────────────────────────────────────────────────────
df = pd.read_csv("dataset.csv")
print(f"Loaded {len(df):,} rows  |  columns: {list(df.columns)}")

# ── Clean ─────────────────────────────────────────────────────────────────────
df = df.dropna(subset=["title", "description", "label"])
df["title"]       = df["title"].str.strip()
df["description"] = df["description"].str.strip()
df["location"]    = df["location"].fillna("Unknown").str.strip()
df["price"]       = pd.to_numeric(df["price"], errors="coerce").fillna(0)

# Derive 'category' from title keywords (dataset has no category column)
KEYWORD_MAP = {
    "food festival":      "Food Festival",
    "music concert":      "Music Concert",
    "art exhibition":     "Art Exhibition",
    "educational workshop": "Educational Workshop",
    "community festival": "Community Festival",
    "cultural dance show":"Cultural Dance Show",
    "handicraft fair":    "Handicraft Fair",
    "temple perahera":    "Temple Perahera",
    "village drama":      "Village Drama",
    "buddhist ceremony":  "Buddhist Ceremony",
    "crypto":             "Crypto",
    "lottery":            "Lottery",
    "iphone":             "Iphone",
    "vip ticket":         "Vip Ticket",
    "prize giveaway":     "Prize Giveaway",
}

def extract_category(title: str) -> str:
    t = title.lower()
    for kw, label in KEYWORD_MAP.items():
        if kw in t:
            return label
    return "Other"

df["category"] = df["title"].apply(extract_category)

# Binary label:  1 = real,  0 = fake
df["label_bin"] = (df["label"].str.lower() == "real").astype(int)

print(f"\nReal events : {df['label_bin'].sum():,}")
print(f"Fake events : {(df['label_bin'] == 0).sum():,}")
print(f"Class balance: {df['label_bin'].mean()*100:.1f}% real")


# ════════════════════════════════════════════════════════════════════════════
#  PART 2 — FEATURE ENGINEERING
# ════════════════════════════════════════════════════════════════════════════

# 2a. TF-IDF on title + description (unigrams & bigrams)
df["text"] = df["title"] + " " + df["description"]

tfidf = TfidfVectorizer(
    max_features=500,
    ngram_range=(1, 2),
    sublinear_tf=True,
    stop_words="english",
)
X_text = tfidf.fit_transform(df["text"])

# 2b. Encode categoricals
le_location = LabelEncoder()
le_category  = LabelEncoder()
df["loc_enc"] = le_location.fit_transform(df["location"])
df["cat_enc"] = le_category.fit_transform(df["category"])

# 2c. Scale numerical features
scaler = StandardScaler()
X_num  = scaler.fit_transform(df[["price", "loc_enc", "cat_enc"]].values)

# 2d. Combine into one sparse matrix
X = hstack([X_text, csr_matrix(X_num)])
y = df["label_bin"].values
print(f"\nFinal feature matrix: {X.shape}")


# ════════════════════════════════════════════════════════════════════════════
#  PART 3 — TRAIN / TEST SPLIT
# ════════════════════════════════════════════════════════════════════════════

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.20, random_state=42, stratify=y,
)
print(f"\nTrain: {X_train.shape[0]:,}  |  Test: {X_test.shape[0]:,}")


# ════════════════════════════════════════════════════════════════════════════
#  PART 4 — MODEL TRAINING
# ════════════════════════════════════════════════════════════════════════════

print("\n── Training Random Forest ──────────────────────────────────────────")
rf = RandomForestClassifier(
    n_estimators=200,
    max_depth=None,
    min_samples_leaf=2,
    random_state=42,
    n_jobs=-1,
)
rf.fit(X_train, y_train)

print("── Training Logistic Regression ─────────────────────────────────────")
lr = LogisticRegression(max_iter=1000, C=1.0, random_state=42)
lr.fit(X_train, y_train)


# ════════════════════════════════════════════════════════════════════════════
#  PART 5 — EVALUATION
# ════════════════════════════════════════════════════════════════════════════

def evaluate(model, name: str) -> float:
    y_pred = model.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print(f"\n{'═'*52}")
    print(f"  {name}")
    print(f"{'═'*52}")
    print(f"  Accuracy : {acc:.4f}  ({acc*100:.2f}%)")
    print(f"  Precision: {precision_score(y_test, y_pred):.4f}")
    print(f"  Recall   : {recall_score(y_test, y_pred):.4f}")
    print(f"  F1 Score : {f1_score(y_test, y_pred):.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=["Fake", "Real"]))
    print("Confusion Matrix:")
    print(confusion_matrix(y_test, y_pred))
    return acc

rf_acc = evaluate(rf, "Random Forest")
lr_acc = evaluate(lr, "Logistic Regression")

best_model = rf if rf_acc >= lr_acc else lr
best_name  = "Random Forest" if rf_acc >= lr_acc else "Logistic Regression"
print(f"\n✅  Best model selected: {best_name}  (acc={max(rf_acc, lr_acc):.4f})")


# ════════════════════════════════════════════════════════════════════════════
#  PART 6 — SAVE ARTIFACTS
# ════════════════════════════════════════════════════════════════════════════

os.makedirs("model_artifacts", exist_ok=True)
for obj, fname in [
    (best_model,  "model.pkl"),
    (tfidf,       "tfidf.pkl"),
    (scaler,      "scaler.pkl"),
    (le_location, "le_location.pkl"),
    (le_category, "le_category.pkl"),
]:
    with open(f"model_artifacts/{fname}", "wb") as f:
        pickle.dump(obj, f)

print("\n✅  Artifacts saved to model_artifacts/")


# ════════════════════════════════════════════════════════════════════════════
#  PART 7 — predict_event() FUNCTION
# ════════════════════════════════════════════════════════════════════════════

def _safe_encode(encoder, value: str) -> int:
    """Label-encode; return 0 for unseen categories."""
    try:
        return int(encoder.transform([value])[0])
    except ValueError:
        return 0


def predict_event(
    title: str,
    description: str,
    price: float,
    location: str,
    category: str,
) -> dict:
    """
    Predict whether an event is Real or Fake.

    Parameters
    ----------
    title, description : str
    price              : float  — ticket price in LKR
    location           : str    — e.g. "Colombo", "Kandy"
    category           : str    — e.g. "Music Concert", "Food Festival"

    Returns
    -------
    {
        "prediction":       "Real" | "Fake",
        "confidence":       float   (percentage, 0–100),
        "real_probability": float   (0–1),
        "fake_probability": float   (0–1),
    }
    """
    text   = f"{title} {description}"
    X_txt  = tfidf.transform([text])
    loc_e  = _safe_encode(le_location, location)
    cat_e  = _safe_encode(le_category, category)
    X_n    = scaler.transform([[price, loc_e, cat_e]])
    X_feat = hstack([X_txt, csr_matrix(X_n)])

    probs     = best_model.predict_proba(X_feat)[0]   # [P(fake), P(real)]
    real_prob = float(probs[1])
    fake_prob = float(probs[0])
    label     = "Real" if real_prob >= 0.5 else "Fake"
    confidence = real_prob * 100 if label == "Real" else fake_prob * 100

    return {
        "prediction":       label,
        "confidence":       round(confidence, 2),
        "real_probability": round(real_prob, 4),
        "fake_probability": round(fake_prob, 4),
    }


# ── Demo predictions ──────────────────────────────────────────────────────────
print("\n" + "═"*52)
print("  DEMO PREDICTIONS")
print("═"*52)

demos = [
    {
        "title": "Food Festival in Colombo",
        "description": "Join the food festival in Colombo. Enjoy cultural performances and community activities.",
        "price": 1500,
        "location": "Colombo",
        "category": "Food Festival",
    },
    {
        "title": "Temple Perahera in Kandy",
        "description": "A grand perahera with elephants, drummers, and traditional costumes.",
        "price": 0,
        "location": "Kandy",
        "category": "Temple Perahera",
    },
    {
        "title": "Win Free iPhone Matara",
        "description": "Hurry! Win Free iPhone. Send payment immediately to secure your reward.",
        "price": 2000,
        "location": "Matara",
        "category": "Iphone",
    },
    {
        "title": "Crypto Double Money Event",
        "description": "Send crypto now and double your investment. Limited slots only!",
        "price": 5000,
        "location": "Colombo",
        "category": "Crypto",
    },
]

for d in demos:
    r = predict_event(**d)
    badge = "✅" if r["prediction"] == "Real" else "🚫"
    print(f"\n{badge}  {d['title']}")
    print(f"    Prediction : {r['prediction']}")
    print(f"    Confidence : {r['confidence']:.1f}%")
    print(f"    P(Real)={r['real_probability']}  P(Fake)={r['fake_probability']}")
