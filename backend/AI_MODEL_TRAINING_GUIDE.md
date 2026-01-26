# AI Event Promotion Model Training Guide

This guide explains how to build and train a machine learning model for event recommendations in Festio LK.

## 📊 Overview

The recommendation system uses:
- **User Preferences**: Age, location, budget, interests
- **Event Attributes**: Category, price, location, ratings
- **User Behavior**: Past bookings, ratings, search history
- **Collaborative Filtering**: Similar user patterns

## 🛠️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Recommendation Pipeline                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  1. DATA COLLECTION                                           │
│     └─ User profiles, events, bookings, ratings              │
│                                                               │
│  2. FEATURE ENGINEERING                                       │
│     └─ Extract features from raw data                        │
│                                                               │
│  3. MODEL TRAINING                                            │
│     └─ Collaborative Filtering / Matrix Factorization        │
│     └─ Content-Based Filtering                               │
│                                                               │
│  4. EVALUATION                                                │
│     └─ RMSE, Precision, Recall, F1 Score                     │
│                                                               │
│  5. DEPLOYMENT                                                │
│     └─ Save model, serve predictions via API                 │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## 📦 Step 1: Install Required Libraries

Add these to `requirements.txt`:

```bash
pip install scikit-learn==1.5.0
pip install pandas==2.2.0
pip install numpy==1.24.3
pip install joblib==1.4.2
pip install scipy==1.13.1
```

Then install:

```bash
cd backend
pip install -r requirements.txt
```

## 🗂️ Step 2: Create Data Collection Module

Create `backend/models/ml_model.py`:

```python
import numpy as np
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from sklearn.decomposition import TruncatedSVD
from sklearn.metrics.pairwise import cosine_similarity
import joblib

class EventRecommendationModel:
    def __init__(self):
        self.user_item_matrix = None
        self.svd_model = None
        self.user_features = None
        self.event_features = None
        self.scaler = MinMaxScaler()
        
    def build_user_item_matrix(self, interactions_df):
        """
        Build user-event interaction matrix
        interactions_df columns: user_id, event_id, rating
        """
        self.user_item_matrix = interactions_df.pivot_table(
            index='user_id',
            columns='event_id', 
            values='rating',
            fill_value=0
        )
        return self.user_item_matrix
    
    def train_collaborative_filtering(self, n_factors=50):
        """
        Train collaborative filtering using SVD
        """
        self.svd_model = TruncatedSVD(n_components=n_factors, random_state=42)
        self.user_features = self.svd_model.fit_transform(self.user_item_matrix)
        self.event_features = self.svd_model.components_.T
        return self.svd_model
    
    def get_recommendations(self, user_id, n_recommendations=10):
        """
        Get top N event recommendations for a user
        """
        if user_id not in self.user_item_matrix.index:
            return []
        
        user_idx = self.user_item_matrix.index.get_loc(user_id)
        user_vector = self.user_features[user_idx]
        
        # Calculate similarity with all events
        similarities = cosine_similarity([user_vector], self.event_features)[0]
        
        # Get user's already viewed events
        viewed_events = self.user_item_matrix.iloc[user_idx].nonzero()[0]
        
        # Rank events
        recommendations = []
        for event_idx, similarity in enumerate(similarities):
            if event_idx not in viewed_events:
                event_id = self.user_item_matrix.columns[event_idx]
                recommendations.append({
                    'event_id': event_id,
                    'score': float(similarity)
                })
        
        # Sort by score and return top N
        recommendations.sort(key=lambda x: x['score'], reverse=True)
        return recommendations[:n_recommendations]
    
    def save_model(self, path='backend/models/recommendation_model.pkl'):
        """Save trained model"""
        model_data = {
            'svd_model': self.svd_model,
            'user_features': self.user_features,
            'event_features': self.event_features,
            'user_item_matrix': self.user_item_matrix
        }
        joblib.dump(model_data, path)
        print(f"Model saved to {path}")
    
    def load_model(self, path='backend/models/recommendation_model.pkl'):
        """Load trained model"""
        model_data = joblib.load(path)
        self.svd_model = model_data['svd_model']
        self.user_features = model_data['user_features']
        self.event_features = model_data['event_features']
        self.user_item_matrix = model_data['user_item_matrix']
        print(f"Model loaded from {path}")
```

## 📝 Step 3: Create Training Script

Create `backend/train_model.py`:

```python
import pandas as pd
from models.ml_model import EventRecommendationModel

# Sample training data (replace with real database data)
training_data = {
    'user_id': ['user1', 'user1', 'user2', 'user2', 'user3', 'user3'],
    'event_id': ['event1', 'event2', 'event1', 'event3', 'event2', 'event4'],
    'rating': [5, 4, 3, 5, 4, 2]
}

df = pd.DataFrame(training_data)

# Initialize and train model
model = EventRecommendationModel()
model.build_user_item_matrix(df)
model.train_collaborative_filtering(n_factors=50)

# Get recommendations
recommendations = model.get_recommendations('user1', n_recommendations=5)
print("Recommendations for user1:", recommendations)

# Save model
model.save_model()
```

## 🚀 Step 4: Run Training

```bash
cd backend
python train_model.py
```

## 📡 Step 5: Integrate with API

Update `backend/routes/recommendations.py`:

```python
from fastapi import APIRouter, Query
from pydantic import BaseModel
from typing import List
from models.ml_model import EventRecommendationModel

router = APIRouter()
# Load model at startup
model = EventRecommendationModel()
model.load_model()

class Recommendation(BaseModel):
    event_id: str
    score: float

@router.get("/", response_model=List[Recommendation])
async def get_recommendations(user_id: str, limit: int = Query(10, ge=1, le=50)):
    """Get AI-powered event recommendations"""
    recommendations = model.get_recommendations(user_id, n_recommendations=limit)
    return recommendations

@router.post("/train")
async def retrain_model():
    """Retrain model with latest data (admin only)"""
    # Fetch latest data from database
    # df = fetch_latest_interactions()
    # model.build_user_item_matrix(df)
    # model.train_collaborative_filtering()
    # model.save_model()
    return {"status": "Model retrained successfully"}
```

## 📊 Step 6: Data Collection Strategy

### What Data to Collect:

1. **User Interactions**
   ```
   - Event views
   - Event bookings
   - Event ratings
   - Search queries
   - Category preferences
   ```

2. **Event Metadata**
   ```
   - Title, description
   - Category, tags
   - Price, location
   - Average rating
   - Number of bookings
   ```

3. **User Profile**
   ```
   - Age, gender, location
   - Interests/preferences
   - Budget range
   - Event history
   ```

### Data Schema:

```sql
-- User-Event Interactions
CREATE TABLE interactions (
    id INT PRIMARY KEY,
    user_id VARCHAR(255),
    event_id VARCHAR(255),
    interaction_type VARCHAR(50), -- view, booking, rating
    rating INT (1-5),
    timestamp DATETIME
);

-- Events
CREATE TABLE events (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255),
    category VARCHAR(100),
    price FLOAT,
    location VARCHAR(255),
    avg_rating FLOAT,
    total_bookings INT
);

-- User Preferences
CREATE TABLE user_preferences (
    user_id VARCHAR(255) PRIMARY KEY,
    preferred_categories TEXT,
    budget_range VARCHAR(50),
    location VARCHAR(255)
);
```

## 🎯 Step 7: Model Evaluation Metrics

```python
from sklearn.metrics import mean_squared_error, precision_score, recall_score

# RMSE: How close predictions are to actual ratings
rmse = np.sqrt(mean_squared_error(y_true, y_pred))

# Precision: Of recommended events, how many did user like?
precision = precision_score(y_true, y_pred > threshold)

# Recall: Of events user liked, how many were recommended?
recall = recall_score(y_true, y_pred > threshold)

# F1 Score: Harmonic mean of precision and recall
f1 = 2 * (precision * recall) / (precision + recall)
```

## 🔄 Step 8: Continuous Improvement

### Automated Retraining:

```python
# backend/tasks/retrain_scheduler.py
from apscheduler.schedulers.background import BackgroundScheduler
from models.ml_model import EventRecommendationModel

scheduler = BackgroundScheduler()

@scheduler.scheduled_job('cron', day_of_week='0', hour=2)  # Weekly on Sunday at 2 AM
def retrain_model():
    print("Starting scheduled model retraining...")
    # Fetch fresh data
    df = fetch_latest_interactions()
    
    # Train
    model = EventRecommendationModel()
    model.build_user_item_matrix(df)
    model.train_collaborative_filtering()
    model.save_model()
    print("Model retraining completed!")

scheduler.start()
```

## 🧠 Advanced Techniques

### 1. Content-Based Filtering

```python
def content_based_recommendations(user_id, n=10):
    """Recommend events similar to user's past bookings"""
    user_events = get_user_booking_history(user_id)
    event_vectors = extract_event_features(user_events)
    avg_preference = np.mean(event_vectors, axis=0)
    
    all_events = get_all_events()
    similarities = cosine_similarity([avg_preference], 
                                    extract_event_features(all_events))
    # Return top N
```

### 2. Hybrid Approach

```python
def hybrid_recommendations(user_id, n=10):
    """Combine collaborative and content-based"""
    collab_recs = model.get_recommendations(user_id, n=n)
    content_recs = content_based_recommendations(user_id, n=n)
    
    # Merge and weight
    final_recs = merge_recommendations(collab_recs, content_recs, 
                                      weight1=0.6, weight2=0.4)
    return final_recs[:n]
```

### 3. Deep Learning (TensorFlow)

```python
from tensorflow.keras.layers import Embedding, Flatten, Dense
from tensorflow.keras.models import Model

def build_neural_network_model(num_users, num_events):
    user_input = Input(shape=(1,))
    event_input = Input(shape=(1,))
    
    user_embedding = Embedding(num_users, 50)(user_input)
    event_embedding = Embedding(num_events, 50)(event_input)
    
    user_vec = Flatten()(user_embedding)
    event_vec = Flatten()(event_embedding)
    
    concat = Concatenate()([user_vec, event_vec])
    dense = Dense(64, activation='relu')(concat)
    output = Dense(1)(dense)
    
    model = Model([user_input, event_input], output)
    model.compile(optimizer='adam', loss='mse')
    return model
```

## 🚀 Deployment Checklist

- [ ] Model trained and evaluated
- [ ] Model saved to disk/cloud
- [ ] API endpoint for recommendations
- [ ] Automated retraining scheduled
- [ ] Monitoring & logging
- [ ] A/B testing framework
- [ ] Cold start problem handled (new users)
- [ ] Model versioning

## 📞 Support

For questions or issues with model training, refer to:
- scikit-learn docs: https://scikit-learn.org/
- TensorFlow docs: https://www.tensorflow.org/
- Recommendation Systems: https://en.wikipedia.org/wiki/Recommender_system
