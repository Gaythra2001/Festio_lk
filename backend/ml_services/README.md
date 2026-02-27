# AI Revenue Optimization System - Implementation Guide

**Festio LK Event Management Platform**

## Overview

This document provides complete setup, training, and integration instructions for the AI-based Revenue Optimization system for Festio LK.

---

## 📦 File Structure

```
backend/
├── ml_services/
│   ├── __init__.py
│   ├── train_revenue_model.py          # Training script
│   ├── revenue_optimizer.py             # Inference service
│   ├── models/                          # Trained models directory
│   │   ├── revenue_model_latest.pkl     # Latest trained model
│   │   ├── category_encoder.pkl         # Category encoder
│   │   └── model_metadata.pkl           # Model metadata
│   └── data/
│       └── FestioLK_Event_Revenue_Dataset.xlsx  # Training dataset
├── models/
│   └── ai_optimization_log.py           # Database model
├── routes/
│   └── ai_ml_optimization.py            # FastAPI routes
├── db/
│   └── database.py                      # Updated with AIOptimizationLog
├── alembic/
│   └── versions/
│       └── ai_opt_001_add_ai_optimization_table.py  # DB migration
└── src/
    └── main.py                          # Updated with new routes

frontend/
└── lib/screens/organizer/widgets/
    ├── ai_revenue_optimizer_card.dart   # Dashboard widget
    └── INTEGRATION_GUIDE.md             # Integration instructions
```

---

## 🚀 Quick Start

### Step 1: Prepare the Dataset

Place your Excel dataset at:
```
backend/ml_services/data/FestioLK_Event_Revenue_Dataset.xlsx
```

**Required Dataset Structure:**
```
Columns:
- Ticket Price (LKR)
- Days Before Event
- Event Category
- Venue Capacity
- Revenue (LKR)
```

### Step 2: Train the ML Models

```bash
# Navigate to project root
cd c:\Users\User\Desktop\festio_lk\festio_lk

# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Install required packages
pip install pandas scikit-learn joblib openpyxl

# Run training script
python backend/ml_services/train_revenue_model.py
```

**Expected Output:**
```
==================================================
Festio LK - Revenue Optimization Model Training
==================================================

Loading dataset...

Dataset Split: Train=80, Test=20

Training RandomForest...
RandomForest - RMSE: 45000.50, R²: 0.8234

Training GradientBoosting...
GradientBoosting - RMSE: 42000.75, R²: 0.8512

✓ Best Model Selected: GradientBoosting
  RMSE: 42000.75
  R²: 0.8512

✓ Model saved: backend/ml_services/models/revenue_model_gradientboosting_20260227_120000.pkl
✓ Encoder saved: backend/ml_services/models/category_encoder.pkl

==================================================
Training Complete!
==================================================
```

### Step 3: Update Database

```bash
# Create database migration
# (Already included in alembic/versions/)

# Run migration
alembic upgrade head
```

### Step 4: Restart FastAPI Server

```bash
# Navigate to backend
cd backend

# Install requirements
pip install -r requirements.txt

# Run with uvicorn
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

### Step 5: Verify API Endpoints

Test the endpoints using curl or Postman:

```bash
# Get available categories
curl http://localhost:8000/api/ai-optimization/ml/categories

# Get model info
curl http://localhost:8000/api/ai-optimization/ml/model-info

# Get optimization for an event
curl -X POST http://localhost:8000/api/ai-optimization/ml/optimize \
  -H "Content-Type: application/json" \
  -d '{
    "days_before_event": 10,
    "category_encoded": 0,
    "venue_capacity": 500,
    "price_range_min": 1000,
    "price_range_max": 5000
  }'
```

### Step 6: Integrate Flutter Widget

In your Organizer Dashboard:

```dart
import 'package:festio_lk/screens/organizer/widgets/ai_revenue_optimizer_card.dart';

// In your build method:
AIRevenueOptimizerCard(
  eventId: _selectedEventId,
  eventCategory: _eventCategory,
  daysBeforeEvent: _daysUntilEvent.toInt(),
  venueCapacity: _venueCapacity,
  currentPrice: _currentPrice,
  apiBaseUrl: 'http://localhost:8000',
  onPriceUpdated: (newPrice) {
    setState(() {
      _currentPrice = newPrice;
    });
  },
)
```

---

## 📊 API Endpoints

### 1. Get Category Mapping

**Endpoint:** `GET /api/ai-optimization/ml/categories`

**Response:**
```json
{
  "categories": {
    "Festival": 0,
    "Concert": 1,
    "Workshop": 2,
    "Conference": 3
  }
}
```

### 2. Optimize Revenue

**Endpoint:** `POST /api/ai-optimization/ml/optimize`

**Request:**
```json
{
  "days_before_event": 10,
  "category_encoded": 0,
  "venue_capacity": 500,
  "price_range_min": 1000,
  "price_range_max": 5000
}
```

**Response:**
```json
{
  "recommended_price": 2500,
  "expected_revenue": 625000,
  "model_used": "GradientBoosting",
  "all_predictions": [
    {"price": 1000, "revenue": 400000},
    {"price": 1250, "revenue": 475000},
    {"price": 1500, "revenue": 525000},
    {"price": 1750, "revenue": 575000},
    {"price": 2000, "revenue": 610000},
    {"price": 2250, "revenue": 630000},
    {"price": 2500, "revenue": 625000},
    ...
  ]
}
```

### 3. Apply Recommendation

**Endpoint:** `POST /api/ai-optimization/ml/apply-recommendation`

**Request:**
```json
{
  "event_id": "evt_123456",
  "old_price": 2000,
  "new_price": 2500,
  "predicted_revenue": 625000,
  "model_used": "GradientBoosting"
}
```

**Response:**
```json
{
  "success": true,
  "message": "AI recommendation applied successfully",
  "event_id": "evt_123456",
  "new_price": 2500,
  "log_id": 42
}
```

### 4. Get Analytics

**Endpoint:** `GET /api/ai-optimization/ml/analytics/{event_id}`

**Response:**
```json
{
  "event_id": "evt_123456",
  "total_recommendations": 5,
  "accepted_recommendations": 3,
  "logs": [
    {
      "id": 42,
      "old_price": 2000,
      "new_price": 2500,
      "predicted_revenue": 625000,
      "model_used": "GradientBoosting",
      "accepted": true,
      "created_at": "2026-02-27T10:30:00Z"
    },
    ...
  ]
}
```

### 5. Reject Recommendation

**Endpoint:** `POST /api/ai-optimization/ml/reject-recommendation`

**Query Parameters:**
- `event_id` (required): Event ID
- `reason` (optional): Rejection reason

**Response:**
```json
{
  "success": true,
  "message": "Recommendation marked as rejected",
  "event_id": "evt_123456",
  "reason": "Price too high"
}
```

### 6. Get Model Info

**Endpoint:** `GET /api/ai-optimization/ml/model-info`

**Response:**
```json
{
  "loaded": true,
  "model_used": "GradientBoosting",
  "trained_on": "20260227_120000",
  "feature_names": [
    "Ticket Price (LKR)",
    "Days Before Event",
    "Category_Encoded",
    "Venue Capacity"
  ]
}
```

---

## 🗄️ Database Schema

### ai_optimization_logs Table

```sql
CREATE TABLE ai_optimization_logs (
  id INTEGER PRIMARY KEY,
  event_id VARCHAR(64) NOT NULL,
  ai_recommendation_shown BOOLEAN DEFAULT TRUE,
  ai_accepted BOOLEAN DEFAULT FALSE,
  old_price FLOAT NOT NULL,
  new_price FLOAT NOT NULL,
  predicted_revenue FLOAT NOT NULL,
  model_used VARCHAR(50) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_event_id (event_id),
  INDEX idx_created_at (created_at)
);
```

---

## 🤖 ML Model Details

### Training Script: `train_revenue_model.py`

**Features:**
- Loads event revenue data from Excel
- Encodes categorical variables
- Trains two models:
  - Random Forest Regressor (100 estimators)
  - Gradient Boosting Regressor (100 estimators)
- Compares RMSE metrics
- Selects best model automatically
- Saves model, encoder, and metadata as pickle files

**Input Features:**
1. `Ticket Price (LKR)` - Ticket price in Sri Lankan Rupees
2. `Days Before Event` - Days remaining until event (0-365)
3. `Category_Encoded` - Encoded event category
4. `Venue Capacity` - Total venue capacity

**Target Variable:**
- `Revenue (LKR)` - Total expected revenue

### Inference Service: `revenue_optimizer.py`

**Key Methods:**
- `load_model()` - Loads trained model
- `predict_revenue()` - Predicts revenue for specific parameters
- `optimize_price()` - Tests multiple prices to find optimal one
- `get_category_mapping()` - Returns category encoding

---

## 🔍 Monitoring & Troubleshooting

### Check Model Loading

```bash
# Python shell
python

from backend.ml_services.revenue_optimizer import revenue_optimizer
revenue_optimizer.load_model()
print(revenue_optimizer.get_category_mapping())
```

### Verify Database

```bash
# Check ai_optimization_logs table
sqlite> SELECT * FROM ai_optimization_logs;

# Count by model
sqlite> SELECT model_used, COUNT(*) FROM ai_optimization_logs GROUP BY model_used;

# Check acceptance rate
sqlite> SELECT 
  COUNT(*) as total,
  SUM(CASE WHEN ai_accepted = 1 THEN 1 ELSE 0 END) as accepted,
  ROUND(SUM(CASE WHEN ai_accepted = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as acceptance_rate
FROM ai_optimization_logs;
```

### Common Issues

**Issue: "Model not available" error**
```
Solution: 
1. Verify training dataset exists at backend/ml_services/data/
2. Run training script: python backend/ml_services/train_revenue_model.py
3. Check models directory exists: backend/ml_services/models/
```

**Issue: Category encoding mismatch**
```
Solution:
1. Verify event categories in your database
2. Update training dataset with correct categories
3. Retrain model
```

**Issue: Low prediction accuracy**
```
Solution:
1. Collect more training data (more diverse events)
2. Validate data quality
3. Experiment with different model parameters
4. Test manual hyperparameter tuning in train_revenue_model.py
```

---

## 📈 Performance Metrics

The system tracks:
- **Model Used**: RandomForest or GradientBoosting
- **Recommendation Shown**: Count of recommendations shown to organizers
- **Acceptance Rate**: % of recommendations applied
- **Revenue Impact**: Predicted vs actual outcomes
- **Category Distribution**: Recommendations by event type

**Example Analytics Query:**
```sql
SELECT 
  strftime('%Y-%m-%d', created_at) as date,
  model_used,
  COUNT(*) as recommendations,
  COUNT(CASE WHEN ai_accepted = 1 THEN 1 END) as accepted,
  AVG(new_price - old_price) as avg_price_change,
  AVG(predicted_revenue) as avg_predicted_revenue
FROM ai_optimization_logs
GROUP BY date, model_used
ORDER BY date DESC;
```

---

## 🔐 Best Practices

1. **Model Retraining**: Retrain models monthly with accumulated data
2. **Data Validation**: Verify dataset quality before training
3. **A/B Testing**: Compare model recommendations with organizer decisions
4. **Fallback Strategy**: System gracefully falls back if model unavailable
5. **Monitoring**: Track recommendation acceptance rates
6. **Privacy**: Don't log personally identifiable information
7. **Logging**: Use structured logging for debugging

---

## 📚 References

- **Scikit-learn**: https://scikit-learn.org/
- **Joblib**: https://joblib.readthedocs.io/
- **FastAPI**: https://fastapi.tiangolo.com/
- **Flutter HTTP**: https://pub.dev/packages/http

---

## 🤝 Support

For issues or questions:
1. Check troubleshooting section above
2. Review API endpoint documentation
3. Check database for error logs
4. Review training script output

---

**Last Updated**: February 27, 2026
**System Version**: 1.0.0
**Status**: ✅ Production Ready
