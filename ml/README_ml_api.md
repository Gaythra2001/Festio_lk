# AI Event Validation (Python + FastAPI)

## 1) Install dependencies

```bash
pip install -r requirements.txt
```

## 2) Prepare dataset (local file)

Since dataset upload is not available in chat, place your file in this folder as `dataset.csv`, or pass its path with `--csv`.

Required columns:

- `title`
- `description`
- `price`
- `location`
- `category`
- `label` (`real` or `fake`)

## 3) Train model

```bash
python train_model.py --csv "C:\path\to\your\dataset.csv"
```

or if you saved it as `dataset.csv` in this folder:

```bash
python train_model.py
```

This does:

- cleaning and preprocessing
- title + description TF-IDF
- location/category encoding
- price numeric scaling
- train/test split
- training Random Forest + Logistic Regression
- printing accuracy, precision, recall
- saving best model artifacts to `model_artifacts/`

## 4) Run API

```bash
uvicorn main:app --reload
```

API endpoint:

- `POST /predict-event`

## 5) Request example

```json
{
  "title": "Food Festival Colombo 2026",
  "description": "A community event with local food stalls and live music.",
  "price": 1500,
  "location": "Colombo",
  "category": "Food Festival"
}
```

## 6) Response example

```json
{
  "prediction": "Real",
  "confidence_score": 92.31,
  "real_probability": 0.9231,
  "fake_probability": 0.0769
}
```

## 7) Use in Python directly

```python
from predictor import predict_event

result = predict_event(
    title="Music Night",
    description="Official event by verified organizers.",
    price=2000,
    location="Kandy",
    category="Music"
)
print(result)
```
