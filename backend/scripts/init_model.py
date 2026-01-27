"""
Initialize and train the recommendation model with sample data
Run this script to set up the ML model for the first time
"""

import sys
import os

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.recommendation_service import recommendation_service
from utils.sample_data_generator import generate_sample_interactions


def initialize_model():
    """Initialize the recommendation model with sample data"""
    print("=" * 60)
    print("Initializing Festio LK Recommendation Model")
    print("=" * 60)
    
    # Check if model already exists
    model_path = recommendation_service.model_path
    if os.path.exists(model_path):
        print(f"\n✅ Model already exists at {model_path}")
        stats = recommendation_service.get_model_stats()
        print(f"\nCurrent Model Stats:")
        print(f"  - Users: {stats.get('n_users', 'N/A')}")
        print(f"  - Events: {stats.get('n_events', 'N/A')}")
        print(f"  - Status: {stats.get('status', 'N/A')}")
        
        response = input("\nDo you want to retrain the model? (y/n): ")
        if response.lower() != 'y':
            print("Skipping model training.")
            return
    
    # Generate sample training data
    print("\n📊 Generating sample interaction data...")
    interactions = generate_sample_interactions(
        n_users=100,
        n_events=200,
        n_interactions=1000
    )
    print(f"✅ Generated {len(interactions)} interactions")
    
    # Train the model
    print("\n🤖 Training recommendation model...")
    result = recommendation_service.train_model(
        interactions=interactions,
        n_factors=50
    )
    
    if result['status'] == 'success':
        print("\n✅ Model trained successfully!")
        print(f"   - Users: {result['n_users']}")
        print(f"   - Events: {result['n_events']}")
        print(f"   - Latent Factors: {result['n_factors']}")
        print(f"   - Model saved to: {model_path}")
        
        # Test recommendations
        print("\n🧪 Testing recommendations...")
        test_user = 'user_0'
        recs = recommendation_service.get_recommendations(test_user, n_recommendations=5)
        
        if recs:
            print(f"\nTop 5 recommendations for {test_user}:")
            for i, rec in enumerate(recs, 1):
                print(f"  {i}. Event: {rec['event_id']}, Score: {rec['score']:.3f}")
        else:
            print(f"\n⚠️ No recommendations available for {test_user}")
        
    else:
        print(f"\n❌ Model training failed: {result['message']}")
    
    print("\n" + "=" * 60)
    print("Initialization Complete")
    print("=" * 60)


if __name__ == '__main__':
    initialize_model()
