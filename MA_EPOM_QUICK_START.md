# MA-EPOM Quick Start Guide

## 🚀 Getting Started in 5 Minutes

### Step 1: Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

**New packages added:**
- scikit-learn (ML algorithms)
- pandas (data processing)
- transformers (NLP models)
- torch (deep learning backend)

### Step 2: Start Backend Server

```bash
cd backend
.venv\Scripts\activate  # Windows
uvicorn src.main:app --reload
```

Expected output:
```
INFO:     Uvicorn running on http://127.0.0.1:8000
```

### Step 3: Access API Documentation

Open in browser:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

Look for `/api/promotion/*` endpoints

---

## 🧪 Quick Tests

### Test 1: Run Sample Workflow

```bash
curl -X POST http://localhost:8000/api/promotion/sample-promotion-workflow
```

**Expected Response:**
```json
{
  "status": "success",
  "sample_promotion": {
    "user_id": "user_001",
    "language": "si",
    "engagement_probability": 0.82,
    "recommended_send_time": "2026-01-28T19:00:00",
    "translation_quality": 0.87
  },
  "sentiment_analysis": {
    "label": "positive",
    "combined_sentiment": 0.92
  }
}
```

### Test 2: Detect Language

```bash
curl -X POST http://localhost:8000/api/promotion/detect-language \
  -H "Content-Type: application/json" \
  -d '{"text": "සාංස්කෘතික උත්සවය"}'
```

### Test 3: Translate Event

```bash
curl -X POST http://localhost:8000/api/promotion/translate-event \
  -H "Content-Type: application/json" \
  -d '{
    "event_data": {"title": "Music Festival", "description": "Traditional music"},
    "target_language": "si"
  }'
```

### Test 4: Predict Engagement

```bash
curl -X POST http://localhost:8000/api/promotion/predict-engagement \
  -H "Content-Type: application/json" \
  -d '{
    "interaction_data": {
      "past_click_rate": 0.7,
      "past_booking_rate": 0.4,
      "avg_session_duration": 300,
      "notification_open_rate": 0.8,
      "user_activity_level": 0.8,
      "event_category_affinity": 0.9,
      "location_preference_match": 0.85,
      "price_sensitivity_match": 0.75
    }
  }'
```

### Test 5: Optimize Timing

```bash
curl -X POST http://localhost:8000/api/promotion/optimize-notification-time \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_001",
    "interaction_history": [
      {"timestamp": "2026-01-25T18:30:00", "event_id": "evt_002", "action": "click"},
      {"timestamp": "2026-01-25T19:15:00", "event_id": "evt_003", "action": "view"}
    ]
  }'
```

### Test 6: Analyze Sentiment

```bash
curl -X POST http://localhost:8000/api/promotion/analyze-sentiment \
  -H "Content-Type: application/json" \
  -d '{
    "review_text": "Amazing event! The dancers were fantastic!",
    "rating": 5.0
  }'
```

### Test 7: Get Supported Languages

```bash
curl http://localhost:8000/api/promotion/supported-languages
```

---

## 🎨 Frontend Integration

### Step 1: Use MAEPOMService

```dart
import 'package:festio_lk/core/services/ai/ma_epom_service.dart';

final maEpomService = MAEPOMService();

// Generate promotion
final result = await maEpomService.generatePromotion(
  userId: 'user_001',
  eventData: {
    'id': 'evt_001',
    'title': 'Cultural Festival',
    'description': 'Traditional performances',
    'category': 'dance',
    'location': 'Kandy',
    'date': '2026-02-15',
    'price': 25.0,
  },
  userPreferences: {
    'user_id': 'user_001',
    'language': 'si',
    'past_click_rate': 0.7,
    'past_booking_rate': 0.4,
    'avg_session_duration': 300.0,
    'notification_open_rate': 0.8,
    'user_activity_level': 0.8,
    'event_category_affinity': 0.9,
    'location_preference_match': 0.85,
    'price_sensitivity_match': 0.75,
  },
  interactionHistory: [
    {
      'timestamp': '2026-01-25T18:30:00',
      'event_id': 'evt_002',
      'action': 'click',
    },
  ],
);

print(result);
```

### Step 2: Navigate to Promotion Dashboard

```dart
// In your navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PromotionDashboardScreen(),
  ),
);
```

---

## 📊 Understanding the Output

### Sample Promotion Output

```json
{
  "user_id": "user_001",
  "event_id": "evt_001",
  "language": "si",
  "title": "සාංස්කෘතික නසත්ය උත්සවය",
  "description": "ඉතිහාසික නැටුම් ගෙයුරු...",
  "category": "නසත්ය",
  "engagement_probability": 0.82,
  "confidence": 0.78,
  "recommended_send_time": "2026-01-28T19:00:00",
  "optimal_hour": 19,
  "translation_quality": 0.87,
  "feature_importance": {
    "event_category_affinity": 0.25,
    "location_preference_match": 0.18,
    "past_booking_rate": 0.15,
    "notification_open_rate": 0.14,
    "user_activity_level": 0.12,
    "price_sensitivity_match": 0.10,
    "avg_session_duration": 0.04,
    "past_click_rate": 0.02
  }
}
```

### Key Metrics Explained

| Metric | Range | Meaning |
|--------|-------|---------|
| `engagement_probability` | 0-1 | Likelihood user will engage (0=low, 1=high) |
| `confidence` | 0-1 | Model confidence in prediction |
| `translation_quality` | 0-1 | Quality of translation (0=poor, 1=perfect) |
| `optimal_hour` | 0-23 | Best hour to send notification |

---

## 🔍 Component Architecture

```
MA-EPOM Model
├── LanguageProcessor
│   ├── detect_language()
│   ├── translate_event()
│   └── calculate_translation_quality()
├── EngagementPredictor
│   ├── extract_features()
│   ├── train_model()
│   └── predict_engagement()
├── NotificationTimingOptimizer
│   ├── extract_time_features()
│   ├── analyze_user_patterns()
│   └── recommend_notification_time()
├── SentimentAnalyzer
│   ├── extract_sentiment_features()
│   └── analyze_review()
└── MAEPOMModel (Orchestrator)
    ├── generate_personalized_promotion()
    └── evaluate_promotion_performance()
```

---

## ✅ Validation Checklist

After implementation, verify:

- [ ] Backend starts without errors
- [ ] `/api/promotion/model-info` returns 200
- [ ] `/api/promotion/sample-promotion-workflow` works
- [ ] All 10 endpoints are in Swagger docs
- [ ] Frontend service imports successfully
- [ ] PromotionDashboardScreen displays correctly
- [ ] Sample workflow generates promotion with all fields
- [ ] Engagement probability is between 0-1
- [ ] Translation quality is calculated
- [ ] Sentiment analysis produces labels

---

## 🐛 Troubleshooting

### Issue: "Module not found" for ma_epom_model

**Solution:**
```bash
# Make sure __init__.py exists in backend/models/
touch backend/models/__init__.py
```

### Issue: scikit-learn import error

**Solution:**
```bash
pip install scikit-learn --upgrade
```

### Issue: Frontend service connection error

**Solution:**
1. Verify backend is running on port 8000
2. Check CORS settings in main.py
3. Ensure correct baseUrl in MAEPOMService

### Issue: Sample workflow returns empty

**Solution:**
1. Check backend logs for errors
2. Verify all dependencies installed
3. Restart backend server

---

## 📚 File Structure

```
Backend:
├── models/
│   └── ma_epom_model.py          # Main MA-EPOM implementation
├── routes/
│   └── promotion_ma_epom.py      # API endpoints
└── src/
    └── main.py                    # Updated with routes

Frontend:
├── lib/
│   ├── core/services/ai/
│   │   └── ma_epom_service.dart   # Service client
│   └── screens/promotion/
│       └── promotion_dashboard_screen.dart  # UI

Documentation:
├── MA_EPOM_IMPLEMENTATION_GUIDE.md
└── MA_EPOM_QUICK_START.md (this file)
```

---

## 🎯 Next Steps

1. ✅ Start backend server
2. ✅ Run sample workflow
3. ✅ Test all endpoints
4. ✅ Integrate with frontend
5. ✅ Connect to real user data
6. ✅ Monitor performance metrics
7. ✅ Fine-tune engagement predictor

---

## 📞 API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/promotion/generate-promotion` | POST | Generate personalized promotion |
| `/promotion/translate-event` | POST | Translate event to target language |
| `/promotion/detect-language` | POST | Detect language of text |
| `/promotion/predict-engagement` | POST | Predict engagement probability |
| `/promotion/optimize-notification-time` | POST | Get optimal send time |
| `/promotion/analyze-sentiment` | POST | Analyze review sentiment |
| `/promotion/evaluate-campaigns` | POST | Evaluate campaign metrics |
| `/promotion/supported-languages` | GET | List supported languages |
| `/promotion/sample-promotion-workflow` | POST | Run sample workflow |
| `/promotion/model-info` | GET | Get model information |

---

**Version**: 1.0.0  
**Status**: Ready to Deploy ✅  
**Total Endpoints**: 10  
**Components**: 4 major  
**Languages Supported**: 6
