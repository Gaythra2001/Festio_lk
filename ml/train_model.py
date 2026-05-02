"""
Train an AI event validation model.

Required dataset columns:
title, description, price, location, category, label
"""

from __future__ import annotations

import argparse
import pickle
from pathlib import Path

import pandas as pd
from scipy.sparse import csr_matrix, hstack
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_score, recall_score
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler

REQUIRED_COLUMNS = ["title", "description", "price", "location", "label"]
ARTIFACT_DIR = Path("model_artifacts")


def build_sample_dataset() -> pd.DataFrame:
    rows = [
        ("Food Festival in Colombo", "Community food event with local chefs", 1200, "Colombo", "Food Festival", "real"),
        ("Live Music Night", "Popular bands and secure online booking", 3000, "Kandy", "Music", "real"),
        ("Temple Ceremony", "Annual religious event with official permits", 0, "Anuradhapura", "Culture", "real"),
        ("Art Workshop", "Beginner painting class at city hall", 1500, "Galle", "Education", "real"),
        ("Free iPhone Giveaway", "Pay processing fee now to claim your iPhone", 2000, "Online", "Giveaway", "fake"),
        ("Crypto Double Return Event", "Send crypto and get 2x in one hour", 5000, "Online", "Finance", "fake"),
        ("VIP Pass Urgent", "Limited seats pay immediately to unknown account", 7500, "Colombo", "Ticket", "fake"),
        ("Lottery Winner Meetup", "Claim prize by sharing card PIN today", 1000, "Matara", "Lottery", "fake"),
    ]
    return pd.DataFrame(rows, columns=REQUIRED_COLUMNS)


def load_dataset(csv_path: str | None) -> pd.DataFrame:
    if csv_path:
        return pd.read_csv(csv_path)

    default_path = Path("dataset.csv")
    if default_path.exists():
        return pd.read_csv(default_path)

    print("No CSV provided. Using built-in sample dataset.")
    return build_sample_dataset()


def preprocess(df: pd.DataFrame) -> pd.DataFrame:
    missing = [c for c in REQUIRED_COLUMNS if c not in df.columns]
    if missing:
        raise ValueError(f"Dataset is missing required columns: {missing}")

    clean = df.copy()
    if "category" not in clean.columns:
        clean["category"] = "Unknown"

    clean = clean.dropna(subset=["title", "description", "label"])
    clean["title"] = clean["title"].astype(str).str.strip()
    clean["description"] = clean["description"].astype(str).str.strip()
    clean["location"] = clean["location"].fillna("Unknown").astype(str).str.strip()
    clean["category"] = clean["category"].fillna("Unknown").astype(str).str.strip()
    clean["price"] = pd.to_numeric(clean["price"], errors="coerce").fillna(0.0)
    clean["label"] = clean["label"].astype(str).str.strip().str.lower()
    clean = clean[clean["label"].isin(["real", "fake"])]
    clean["label_bin"] = (clean["label"] == "real").astype(int)
    clean["text"] = clean["title"] + " " + clean["description"]
    return clean


def evaluate(model, x_test, y_test, model_name: str) -> float:
    y_pred = model.predict(x_test)
    accuracy = accuracy_score(y_test, y_pred)
    precision = precision_score(y_test, y_pred, zero_division=0)
    recall = recall_score(y_test, y_pred, zero_division=0)
    print(f"\n{model_name}")
    print(f"accuracy:  {accuracy:.4f}")
    print(f"precision: {precision:.4f}")
    print(f"recall:    {recall:.4f}")
    return accuracy


def train(csv_path: str | None) -> None:
    df = preprocess(load_dataset(csv_path))
    if len(df) < 4:
        raise ValueError("Dataset too small after cleaning. Need at least 4 rows.")

    tfidf = TfidfVectorizer(max_features=5000, ngram_range=(1, 2), stop_words="english")
    x_text = tfidf.fit_transform(df["text"])

    le_location = LabelEncoder()
    le_category = LabelEncoder()
    df["location_enc"] = le_location.fit_transform(df["location"])
    df["category_enc"] = le_category.fit_transform(df["category"])

    scaler = StandardScaler()
    x_num = scaler.fit_transform(df[["price", "location_enc", "category_enc"]].values)
    x = hstack([x_text, csr_matrix(x_num)])
    y = df["label_bin"].values

    x_train, x_test, y_train, y_test = train_test_split(
        x, y, test_size=0.2, random_state=42, stratify=y if len(set(y)) > 1 else None
    )

    rf = RandomForestClassifier(n_estimators=250, random_state=42, n_jobs=-1)
    lr = LogisticRegression(max_iter=1000, random_state=42)
    rf.fit(x_train, y_train)
    lr.fit(x_train, y_train)

    rf_acc = evaluate(rf, x_test, y_test, "RandomForestClassifier")
    lr_acc = evaluate(lr, x_test, y_test, "LogisticRegression")
    best_model = rf if rf_acc >= lr_acc else lr
    best_name = "RandomForestClassifier" if rf_acc >= lr_acc else "LogisticRegression"
    print(f"\nSelected model: {best_name}")

    ARTIFACT_DIR.mkdir(exist_ok=True)
    artifacts = {
        "model.pkl": best_model,
        "tfidf.pkl": tfidf,
        "scaler.pkl": scaler,
        "le_location.pkl": le_location,
        "le_category.pkl": le_category,
    }
    for name, obj in artifacts.items():
        with (ARTIFACT_DIR / name).open("wb") as f:
            pickle.dump(obj, f)
    print(f"Saved artifacts to: {ARTIFACT_DIR.resolve()}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train event validation model")
    parser.add_argument("--csv", type=str, default=None, help="Path to dataset CSV file")
    args = parser.parse_args()
    train(args.csv)
