# MA-EPOM Testing & Verification Guide

## ✅ Comprehensive Testing Checklist

This guide walks through all testing scenarios to verify MA-EPOM is working correctly.

---

## 🔧 Pre-Test Setup

### 1. Install Dependencies
```bash
cd backend
python -m venv venv
venv\Scripts\activate  # Windows

pip install -r requirements.txt
```

### 2. Start Backend Server
```bash
cd backend
uvicorn src.main:app --reload --port 8000
```

**Expected Output:**
```
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Application startup complete
```

---

## 🧪 Test Suite

### Test 1: Backend Health Check

**Command:**
```bash
curl http://localhost:8000/health
```

**Expected Response (200):**
```json
{"status": "healthy"}
```

**Status**: ✅ PASS / ❌ FAIL

---

### Test 2: Get Model Info

**Command:**
```bash
curl http://localhost:8000/api/promotion/model-info
```

**Expected Response (200):**
```json
{
  "model_name": "MA-EPOM",
  "full_name": "Multilingual AI-Based Event Promotion Optimization Model",
  "components": {
    "language_processor": { ... },
    "engagement_predictor": { ... },
    "timing_optimizer": { ... },
    "sentiment_analyzer": { ... }
  },
  "endpoints_total": 10
}
```

**Verification Points:**
- [ ] Contains all 4 components
- [ ] Total endpoints = 10
- [ ] All fields present

**Status**: ✅ PASS / ❌ FAIL

---

### Test 3: Supported Languages

**Command:**
```bash
curl http://localhost:8000/api/promotion/supported-languages
```

**Expected Response (200):**
```json
{
  "supported_languages": {
    "en": "English",
    "si": "Sinhala",
    "ta": "Tamil",
    "es": "Spanish",
    "fr": "French",
    "de": "German"
  },
  "total_languages": 6
}
```

**Verification Points:**
- [ ] 6 languages supported
- [ ] Language codes correct
- [ ] Language names correct

**Status**: ✅ PASS / ❌ FAIL

---

### Test 4: Language Detection

**Command:**
```bash
curl -X POST http://localhost:8000/api/promotion/detect-language \
  -H "Content-Type: application/json" \
  -d '{"text": "සාංස්කෘතික උත්සවය"}'
```

**Expected Response (200):**
```json
{
  "detected_language": "Sinhala",
  "language_code": "si",
  "confidence": 0.9,
  "supported_languages": { ... }
}
```

**Verification Points:**
- [ ] Detected as Sinhala (si)
- [ ] Confidence > 0.8
- [ ] Correct language code

**Status**: ✅ PASS / ❌ FAIL

---

### Test 5: Event Translation

**Command:**
```bash
curl -X POST http://localhost:8000/api/promotion/translate-event \
  -H "Content-Type: application/json" \
  -d '{
    "event_data": {
      "title": "Music Festival",
      "description": "Traditional music performances",
      "category": "music",
      "location": "Colombo"
    },
    "target_language": "si"
  }'
```

**Expected Response (200):**
```json
{
  "status": "success",
  "original_language": "en",
  "target_language": "si",
  "translated_event": {
    "title": "...",
    "description": "...",
    "category": "සංගීතය",
    "location": "..."
  },
  "translation_quality_score": 0.87
}
```

**Verification Points:**
- [ ] Status = "success"
- [ ] Translation quality 0-1 range
- [ ] All fields translated
- [ ] Category field changed

**Status**: ✅ PASS / ❌ FAIL

---

### Test 6: Engagement Prediction

**Command:**
```bash
curl -X POST http://localhost:8000/api/promotion/predict-engagement \
  -H "Content-Type: application/json" \
  -d '{
    "interaction_data": {
      "past_click_rate": 0.7,
      "past_booking_rate": 0.4,
      "avg_session_duration": 300.0,
      "notification_open_rate": 0.8,
      "user_activity_level": 0.8,
      "event_category_affinity": 0.9,
      "location_preference_match": 0.85,
      "price_sensitivity_match": 0.75
    }
  }'
```

**Expected Response (200):**
```json
{
  "status": "success",
  "engagement_prediction": {
    "engagement_probability": 0.82,
    "rf_probability": 0.80,
    "lr_probability": 0.84,
    "confidence": 0.78,
    "feature_importance": { ... }
  }
}
```

**Verification Points:**
- [ ] Engagement probability 0-1
- [ ] Confidence 0-1
- [ ] RF probability exists
- [ ] LR probability exists
- [ ] Ensemble = (RF + LR) / 2
- [ ] Feature importance provided

**Status**: ✅ PASS / ❌ FAIL

---

### Test 7: Notification Timing

**Command:**
```bash
curl -X POST http://localhost:8000/api/promotion/optimize-notification-time \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_001",
    "interaction_history": [
      {
        "timestamp": "2026-01-25T18:30:00",
        "event_id": "evt_002",
        "action": "click"
      },
      {
        "timestamp": "2026-01-25T19:15:00",
        "event_id": "evt_003",
        "action": "view"
      },
      {
        "timestamp": "2026-01-25T20:00:00",
        "event_id": "evt_004",
        "action": "book"
      }
    ]
  }'
```

**Expected Response (200):**
```json
{
  "status": "success",
  "user_patterns": {
    "optimal_hours": [20, 19, 18],
    "peak_hours": [20, 19, 18],
    "engagement_by_hour": {
      "18": 1,
      "19": 1,
      "20": 1
    },
    "sample_size": 3,
    "total_engagements": 3
  },
  "timing_recommendation": {
    "recommended_send_time": "...",
    "optimal_hour": 20,
    "time_until_send": "..."
  }
}
```

**Verification Points:**
- [ ] Optimal hours identified
- [ ] Peak hours ranked
- [ ] Engagement distribution shows
- [ ] Recommended time in ISO format
- [ ] Time until send formatted correctly

**Status**: ✅ PASS / ❌ FAIL

---

### Test 8: Sentiment Analysis

**Command:**
```bash
curl -X POST http://localhost:8000/api/promotion/analyze-sentiment \
  -H "Content-Type: application/json" \
  -d '{
    "review_text": "Amazing event! The dancers were fantastic and the venue was perfect.",
    "rating": 5.0
  }'
```

**Expected Response (200):**
```json
{
  "status": "success",
  "sentiment_analysis": {
    "text_sentiment": 0.5,
    "rating_score": 1.0,
    "combined_sentiment": 0.75,
    "label": "positive",
    "confidence": 0.5
  }
}
```

**Verification Points:**
- [ ] Combined sentiment 0-1
- [ ] Label is positive/neutral/negative
- [ ] Confidence 0-1
- [ ] High rating → high sentiment
- [ ] Positive words detected

**Status**: ✅ PASS / ❌ FAIL

---

### Test 9: Campaign Evaluation

**Command:**
```bash
curl -X POST http://localhost:8000/api/promotion/evaluate-campaigns \
  -H "Content-Type: application/json" \
  -d '{
    "promotions": [
      {
        "id": "promo_001",
        "engagement_probability": 0.8
      },
      {
        "id": "promo_002",
        "engagement_probability": 0.6
      }
    ],
    "feedback": [
      {
        "promotion_id": "promo_001",
        "clicked": true,
        "converted": true
      },
      {
        "promotion_id": "promo_002",
        "clicked": false,
        "converted": false
      }
    ]
  }'
```

**Expected Response (200):**
```json
{
  "status": "success",
  "campaign_evaluation": {
    "ctr": 0.5,
    "conversion_rate": 0.5,
    "avg_engagement_probability": 0.7,
    "f1_score": 1.0,
    "total_promotions": 2,
    "total_clicks": 1,
    "total_conversions": 1
  }
}
```

**Verification Points:**
- [ ] CTR 0-1
- [ ] Conversion rate 0-1
- [ ] F1 score 0-1
- [ ] Total counts match
- [ ] Metrics calculated correctly

**Status**: ✅ PASS / ❌ FAIL

---

### Test 10: Full Promotion Generation (MAIN TEST)

**Command:**
```bash
curl -X POST http://localhost:8000/api/promotion/generate-promotion \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user_001",
    "event": {
      "id": "evt_001",
      "title": "Traditional Kandyan Dance Festival",
      "description": "Experience authentic cultural dance performances",
      "category": "dance",
      "location": "Kandy City Center",
      "date": "2026-02-15",
      "price": 25.0
    },
    "user_preferences": {
      "user_id": "user_001",
      "language": "si",
      "past_click_rate": 0.7,
      "past_booking_rate": 0.4,
      "avg_session_duration": 300.0,
      "notification_open_rate": 0.8,
      "user_activity_level": 0.8,
      "event_category_affinity": 0.9,
      "location_preference_match": 0.85,
      "price_sensitivity_match": 0.75
    },
    "interaction_history": [
      {
        "timestamp": "2026-01-25T18:30:00",
        "event_id": "evt_002",
        "action": "click"
      },
      {
        "timestamp": "2026-01-25T19:15:00",
        "event_id": "evt_003",
        "action": "view"
      }
    ]
  }'
```

**Expected Response (200):**
```json
{
  "status": "success",
  "promotion": {
    "user_id": "user_001",
    "event_id": "evt_001",
    "language": "si",
    "title": "සාංස්කෘතික නසත්ය උත්සවය",
    "description": "...",
    "category": "නසත්ය",
    "engagement_probability": 0.82,
    "confidence": 0.78,
    "recommended_send_time": "2026-01-28T19:00:00",
    "optimal_hour": 19,
    "translation_quality": 0.87,
    "feature_importance": { ... },
    "created_at": "..."
  }
}
```

**Verification Points:**
- [ ] Status = "success"
- [ ] Language translated to Sinhala (si)
- [ ] Event translated
- [ ] Engagement probability 0-1
- [ ] Confidence 0-1
- [ ] Send time in ISO format
- [ ] Translation quality 0-1
- [ ] Feature importance included
- [ ] Created timestamp present

**Status**: ✅ PASS / ❌ FAIL

---

### Test 11: Sample Workflow (COMPREHENSIVE TEST)

**Command:**
```bash
curl -X POST http://localhost:8000/api/promotion/sample-promotion-workflow
```

**Expected Response (200):**
```json
{
  "status": "success",
  "sample_promotion": { /* full promotion */ },
  "sentiment_analysis": { /* sentiment */ },
  "workflow_summary": {
    "event_translated_to": "si",
    "engagement_probability": 0.82,
    "recommended_send_time": "...",
    "translation_quality": 0.87
  }
}
```

**Verification Points:**
- [ ] All components executed
- [ ] Promotion generated
- [ ] Sentiment analyzed
- [ ] Summary shows key metrics
- [ ] No errors returned

**Status**: ✅ PASS / ❌ FAIL

---

## 🎨 Frontend Testing

### Setup

```bash
cd frontend
flutter run -d chrome
```

### Test: Navigate to Promotion Dashboard

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const PromotionDashboardScreen(),
  ),
);
```

**Verification Points:**
- [ ] Screen loads without errors
- [ ] 5 tabs visible (Overview, Translation, Engagement, Timing, Sentiment)
- [ ] Model info card displays
- [ ] Components listed
- [ ] "Run Sample Promotion" button present

**Status**: ✅ PASS / ❌ FAIL

### Test: Run Sample Promotion from UI

1. Click "Run Sample Promotion" button
2. Wait for loading indicator
3. Verify result appears

**Verification Points:**
- [ ] Loading shows during request
- [ ] Result displays after completion
- [ ] All fields populated
- [ ] Engagement probability shown
- [ ] Sentiment analysis displayed

**Status**: ✅ PASS / ❌ FAIL

### Test: View Different Tabs

1. Click each tab
2. Verify content displays
3. Check for information about each component

**Verification Points:**
- [ ] Overview tab: Model info + sample result
- [ ] Translation tab: Supported languages
- [ ] Engagement tab: ML algorithms + features
- [ ] Timing tab: Pattern analysis
- [ ] Sentiment tab: Sentiment labels

**Status**: ✅ PASS / ❌ FAIL

---

## 📊 Performance Tests

### Response Time Test

**Test**: Measure API response times

```bash
# Time 10 requests
for i in {1..10}; do time curl -s http://localhost:8000/api/promotion/sample-promotion-workflow > /dev/null; done
```

**Expected**: <1 second per request

**Status**: ✅ PASS / ❌ FAIL

### Load Test

**Test**: Multiple concurrent requests

```bash
# Install Apache Bench if not present
ab -n 100 -c 10 -X POST http://localhost:8000/api/promotion/model-info
```

**Expected**: 95%+ success rate

**Status**: ✅ PASS / ❌ FAIL

---

## 🐛 Troubleshooting

| Error | Solution |
|-------|----------|
| Connection refused (port 8000) | Start backend with `uvicorn src.main:app --reload` |
| Module not found (ma_epom_model) | Ensure `__init__.py` exists in `backend/models/` |
| JSON decode error | Check request body format is valid JSON |
| Import error (scikit-learn) | Run `pip install scikit-learn --upgrade` |
| 500 Internal Server Error | Check backend logs for detailed error |

---

## ✅ Final Verification Checklist

After all tests:

- [ ] Test 1: Health check - PASS
- [ ] Test 2: Model info - PASS
- [ ] Test 3: Languages - PASS
- [ ] Test 4: Language detection - PASS
- [ ] Test 5: Event translation - PASS
- [ ] Test 6: Engagement prediction - PASS
- [ ] Test 7: Notification timing - PASS
- [ ] Test 8: Sentiment analysis - PASS
- [ ] Test 9: Campaign evaluation - PASS
- [ ] Test 10: Full promotion - PASS
- [ ] Test 11: Sample workflow - PASS
- [ ] Frontend: Dashboard loads - PASS
- [ ] Frontend: Run sample - PASS
- [ ] Frontend: Navigate tabs - PASS
- [ ] Performance: Response time <1s - PASS
- [ ] Load: 95%+ success - PASS

---

## 🎉 Success Criteria

**All tests must PASS for production readiness:**

- ✅ All 11 API tests pass
- ✅ Frontend UI responsive
- ✅ Response times <1 second
- ✅ No error logs
- ✅ Sample workflow completes
- ✅ All metrics calculated correctly
- ✅ Documentation complete
- ✅ Ready for deployment

---

**Testing Status**: Ready  
**Last Updated**: January 28, 2026
