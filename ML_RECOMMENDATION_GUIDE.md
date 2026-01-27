# ML Recommendation System - User Guide

## Overview
The Festio LK platform now includes a machine learning-based recommendation system using collaborative filtering with SVD (Singular Value Decomposition). This provides personalized event recommendations based on user behavior and preferences.

## Features

### 1. **Collaborative Filtering**
- Uses SVD matrix factorization to learn user preferences
- Generates personalized recommendations based on similar users
- Handles cold-start problem with popularity-based fallback

### 2. **Similar Events**
- Find events similar to a specific event
- Based on learned event feature vectors

### 3. **Interaction Tracking**
- Records user interactions: views, clicks, bookings, ratings
- Continuously improves recommendations

### 4. **Model Statistics**
- View model training status
- See number of users and events in the model

## Backend Setup

### Initialize the Model

1. **Navigate to backend directory:**
```bash
cd backend
```

2. **Activate virtual environment:**
```bash
# Windows
.venv\Scripts\activate

# Linux/Mac
source .venv/bin/activate
```

3. **Run initialization script:**
```bash
python scripts/init_model.py
```

This will:
- Generate 1000 sample interactions (100 users, 200 events)
- Train the SVD model with 50 latent factors
- Save the model to `backend/models/recommendation_model.pkl`
- Display test recommendations

### API Endpoints

#### Get Recommendations
```http
GET /api/recommendations/?user_id=user_0&limit=10&exclude_viewed=true
```

Response:
```json
[
  {
    "event_id": "event_42",
    "score": 0.856,
    "reason": "Collaborative filtering recommendation"
  }
]
```

#### Get Similar Events
```http
GET /api/recommendations/similar/event_1?limit=5
```

#### Record Interaction
```http
POST /api/recommendations/interaction
Content-Type: application/json

{
  "user_id": "user_123",
  "event_id": "event_456",
  "interaction_type": "booking",
  "rating": 5.0
}
```

Interaction types:
- `view`: User viewed event (rating: 1.0)
- `click`: User clicked event (rating: 2.0)
- `bookmark`: User bookmarked event (rating: 3.0)
- `booking`: User booked event (rating: 4.0)
- `rating`: Explicit rating (provide rating field)

#### Provide Feedback
```http
POST /api/recommendations/feedback?user_id=user_123&event_id=event_456&liked=true
```

#### Get Model Stats
```http
GET /api/recommendations/model/stats
```

Response:
```json
{
  "status": "trained",
  "n_users": 100,
  "n_events": 200,
  "n_factors": 50,
  "explained_variance": 0.82,
  "model_path": "models/recommendation_model.pkl"
}
```

#### Train/Retrain Model
```http
POST /api/recommendations/train
Content-Type: application/json

{
  "interactions": [
    {"user_id": "user1", "event_id": "event1", "rating": 5.0},
    {"user_id": "user2", "event_id": "event2", "rating": 4.0}
  ],
  "n_factors": 50
}
```

## Frontend Integration

### 1. **Import the Service**
```dart
import 'package:festio_lk/core/services/ml_recommendation_service.dart';
```

### 2. **Get Recommendations**
```dart
final mlService = MLRecommendationService();

// Get personalized recommendations
final recommendations = await mlService.getRecommendations(
  userId: 'user_123',
  limit: 10,
  excludeViewed: true,
);

// Display recommendations
for (var rec in recommendations) {
  print('${rec.eventId}: ${rec.score.toStringAsFixed(3)} - ${rec.reason}');
}
```

### 3. **Get Similar Events**
```dart
final similar = await mlService.getSimilarEvents(
  eventId: 'event_42',
  limit: 5,
);
```

### 4. **Record Interactions**
```dart
// When user views an event
await mlService.recordInteraction(
  userId: 'user_123',
  eventId: 'event_42',
  interactionType: 'view',
);

// When user books an event
await mlService.recordInteraction(
  userId: 'user_123',
  eventId: 'event_42',
  interactionType: 'booking',
);

// When user provides explicit rating
await mlService.recordInteraction(
  userId: 'user_123',
  eventId: 'event_42',
  interactionType: 'rating',
  rating: 4.5,
);
```

### 5. **Using Recommendation Provider**
```dart
// Toggle ML recommendations
recommendationProvider.toggleMLEngine();

// Load ML recommendations
await recommendationProvider.loadMLRecommendations(
  userId: currentUser.id,
  limit: 10,
);

// Access recommendations
final recs = recommendationProvider.mlRecommendations;

// Record interaction
await recommendationProvider.recordInteraction(
  userId: currentUser.id,
  eventId: eventId,
  interactionType: 'view',
);

// Provide feedback
await recommendationProvider.provideFeedback(
  userId: currentUser.id,
  eventId: eventId,
  liked: true,
);
```

## Production Deployment

### 1. **Collect Real Data**
Replace sample data with actual user interactions from your database:

```python
from services.recommendation_service import recommendation_service

# Fetch interactions from database
interactions = fetch_interactions_from_db()

# Train model
result = recommendation_service.train_model(
    interactions=interactions,
    n_factors=100  # Increase for more complex patterns
)
```

### 2. **Schedule Regular Retraining**
Set up a cron job or scheduled task to retrain the model weekly:

```bash
# Run every Sunday at 2 AM
0 2 * * 0 /path/to/venv/bin/python /path/to/scripts/retrain_model.py
```

### 3. **Monitor Performance**
- Track recommendation click-through rates
- Monitor model accuracy metrics
- Collect user feedback
- A/B test different model configurations

## Model Tuning

### Hyperparameters

**n_factors** (Number of latent factors):
- Default: 50
- Lower (10-30): Faster, less complex patterns
- Higher (100-200): Slower, more complex patterns
- Adjust based on dataset size and complexity

### Evaluation

The model can be evaluated using:
- **RMSE** (Root Mean Squared Error): How well predictions match actual ratings
- **MAE** (Mean Absolute Error): Average prediction error
- **Coverage**: Percentage of events that can be recommended
- **Diversity**: Variety in recommendations

## Troubleshooting

### Model Not Found
```
⚠️ No model found at models/recommendation_model.pkl
```
**Solution**: Run `python scripts/init_model.py`

### Empty Recommendations
```python
recommendations = []  # Empty list
```
**Possible causes**:
1. Model not trained yet
2. User ID not in training data (cold-start)
3. All events already viewed

**Solutions**:
- Train model with more data
- Implement fallback to popularity-based recommendations
- Reduce exclude_viewed filter

### Import Errors
```
ModuleNotFoundError: No module named 'sklearn'
```
**Solution**: Install dependencies:
```bash
pip install scikit-learn numpy pandas joblib scipy
```

## Best Practices

1. **Regular Updates**: Retrain model weekly with new interaction data
2. **Feedback Loop**: Collect user feedback to improve recommendations
3. **A/B Testing**: Test different algorithms and parameters
4. **Cold Start**: Provide onboarding quiz for new users
5. **Diversity**: Balance personalization with discovery
6. **Privacy**: Anonymize user data, follow GDPR guidelines

## Architecture

```
Frontend (Flutter)
    ↓
MLRecommendationService
    ↓
FastAPI Backend (/api/recommendations)
    ↓
RecommendationService
    ↓
EventRecommendationModel (SVD)
    ↓
Trained Model (recommendation_model.pkl)
```

## Future Enhancements

- [ ] Hybrid model combining collaborative and content-based filtering
- [ ] Deep learning with neural networks
- [ ] Real-time recommendation updates
- [ ] Graph-based recommendations
- [ ] Context-aware recommendations (time, location, weather)
- [ ] Multi-armed bandit for exploration-exploitation
- [ ] Ensemble methods combining multiple models

## Support

For issues or questions:
1. Check API documentation at `/docs`
2. Review logs for error messages
3. Test with sample data first
4. Verify model is trained and loaded

## References

- [Scikit-learn TruncatedSVD](https://scikit-learn.org/stable/modules/generated/sklearn.decomposition.TruncatedSVD.html)
- [Collaborative Filtering](https://en.wikipedia.org/wiki/Collaborative_filtering)
- [Matrix Factorization Techniques](https://datajobs.com/data-science-repo/Recommender-Systems-[Netflix].pdf)
