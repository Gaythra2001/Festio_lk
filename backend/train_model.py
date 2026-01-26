"""
Model training script for event recommendations
Run this script to train the recommendation model with your data
"""

import pandas as pd
import numpy as np
from models.ml_recommendation_model import EventRecommendationModel


def generate_sample_data():
    """
    Generate sample training data (replace with real database queries)
    In production, fetch this from your database
    """
    print("Generating sample training data...")
    
    np.random.seed(42)
    
    # Create sample users and events
    num_users = 100
    num_events = 50
    num_interactions = 500
    
    users = [f"user_{i}" for i in range(num_users)]
    events = [f"event_{i}" for i in range(num_events)]
    
    data = {
        'user_id': np.random.choice(users, num_interactions),
        'event_id': np.random.choice(events, num_interactions),
        'rating': np.random.randint(1, 6, num_interactions)
    }
    
    df = pd.DataFrame(data)
    # Remove duplicates, keep the last rating
    df = df.drop_duplicates(subset=['user_id', 'event_id'], keep='last')
    
    print(f"Generated {len(df)} interactions")
    return df


def load_real_data():
    """
    Load real data from database
    TODO: Replace with your actual database connection
    """
    # Example: Load from Firebase
    # from firebase_admin import db
    # interactions_ref = db.reference('interactions')
    # data = interactions_ref.get()
    # df = pd.DataFrame(data)
    
    # For now, use sample data
    return generate_sample_data()


def main():
    print("=" * 60)
    print("Event Recommendation Model Training")
    print("=" * 60)
    
    # 1. Load data
    print("\n[1/5] Loading data...")
    df = load_real_data()
    print(f"✅ Loaded {len(df)} interactions")
    print(f"   Users: {df['user_id'].nunique()}")
    print(f"   Events: {df['event_id'].nunique()}")
    
    # 2. Split into train/test
    print("\n[2/5] Splitting data...")
    test_size = 0.2
    test_df = df.sample(frac=test_size, random_state=42)
    train_df = df.drop(test_df.index)
    print(f"✅ Training set: {len(train_df)} interactions")
    print(f"✅ Test set: {len(test_df)} interactions")
    
    # 3. Build and train model
    print("\n[3/5] Training model...")
    model = EventRecommendationModel()
    model.build_user_item_matrix(train_df)
    model.train_collaborative_filtering(n_factors=50)
    print("✅ Model trained successfully")
    
    # 4. Evaluate model
    print("\n[4/5] Evaluating model...")
    metrics = model.evaluate(test_df, k=10)
    print("✅ Evaluation complete")
    
    # 5. Save model
    print("\n[5/5] Saving model...")
    model.save_model('models/recommendation_model.pkl')
    print("✅ Model saved")
    
    # 6. Test recommendations
    print("\n" + "=" * 60)
    print("Sample Recommendations")
    print("=" * 60)
    
    sample_user = train_df['user_id'].iloc[0]
    recommendations = model.get_recommendations(sample_user, n_recommendations=5)
    
    print(f"\nRecommendations for {sample_user}:")
    for i, rec in enumerate(recommendations, 1):
        print(f"  {i}. {rec['event_id']} (score: {rec['score']:.3f})")
    
    print("\n" + "=" * 60)
    print("✅ Training Complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
