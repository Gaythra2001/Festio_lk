"""
Recommendation Service - Handles ML model integration for event recommendations
"""

import os
import sys
from typing import List, Dict, Any, Optional
import numpy as np
import pandas as pd
from datetime import datetime

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from models.ml_recommendation_model import EventRecommendationModel


class RecommendationService:
    """Service layer for ML-based event recommendations"""
    
    def __init__(self):
        self.model = EventRecommendationModel()
        self.model_path = os.path.join(os.path.dirname(__file__), '..', 'models', 'recommendation_model.pkl')
        self._load_or_create_model()
    
    def _load_or_create_model(self):
        """Load existing model or create a new one with sample data"""
        try:
            if os.path.exists(self.model_path):
                self.model.load_model(self.model_path)
                print(f"✅ Loaded recommendation model from {self.model_path}")
            else:
                print(f"⚠️ No model found at {self.model_path}, will train on first request")
        except Exception as e:
            print(f"❌ Error loading model: {e}")
    
    def train_model(self, interactions: List[Dict[str, Any]], n_factors: int = 50) -> Dict[str, Any]:
        """
        Train the recommendation model with interaction data
        
        Args:
            interactions: List of dicts with keys: user_id, event_id, rating
            n_factors: Number of latent factors for SVD
        
        Returns:
            Training statistics
        """
        try:
            # Convert to DataFrame
            df = pd.DataFrame(interactions)
            
            # Validate required columns
            required_cols = ['user_id', 'event_id', 'rating']
            if not all(col in df.columns for col in required_cols):
                raise ValueError(f"Missing required columns. Need: {required_cols}")
            
            # Build user-item matrix
            self.model.build_user_item_matrix(df)
            
            # Train collaborative filtering
            self.model.train_collaborative_filtering(n_factors=n_factors)
            
            # Save model
            os.makedirs(os.path.dirname(self.model_path), exist_ok=True)
            self.model.save_model(self.model_path)
            
            return {
                "status": "success",
                "n_users": len(self.model.user_id_mapping),
                "n_events": len(self.model.event_id_mapping),
                "n_factors": n_factors,
                "message": "Model trained successfully"
            }
        except Exception as e:
            return {
                "status": "error",
                "message": str(e)
            }
    
    def get_recommendations(
        self,
        user_id: str,
        n_recommendations: int = 10,
        exclude_viewed: bool = True
    ) -> List[Dict[str, Any]]:
        """
        Get personalized recommendations for a user
        
        Args:
            user_id: User identifier
            n_recommendations: Number of recommendations to return
            exclude_viewed: Whether to exclude already viewed events
        
        Returns:
            List of recommendations with event_id, score, and reason
        """
        try:
            if self.model.svd_model is None:
                # Return empty list if model not trained
                return []
            
            recommendations = self.model.get_recommendations(
                user_id=user_id,
                n_recommendations=n_recommendations,
                exclude_viewed=exclude_viewed
            )
            
            return recommendations
        except Exception as e:
            print(f"Error getting recommendations: {e}")
            return []
    
    def get_similar_events(self, event_id: str, n_similar: int = 5) -> List[Dict[str, Any]]:
        """
        Get events similar to a given event
        
        Args:
            event_id: Event identifier
            n_similar: Number of similar events to return
        
        Returns:
            List of similar events with scores
        """
        try:
            if self.model.svd_model is None or self.model.event_features is None:
                return []
            
            if event_id not in self.model.event_id_mapping:
                return []
            
            event_idx = self.model.event_id_mapping[event_id]
            event_vector = self.model.event_features[event_idx]
            
            # Calculate similarity with all events
            from sklearn.metrics.pairwise import cosine_similarity
            similarities = cosine_similarity([event_vector], self.model.event_features)[0]
            
            # Get top N similar (excluding the event itself)
            similar_indices = np.argsort(similarities)[::-1][1:n_similar+1]
            
            similar_events = []
            for idx in similar_indices:
                similar_event_id = list(self.model.event_id_mapping.keys())[
                    list(self.model.event_id_mapping.values()).index(idx)
                ]
                similar_events.append({
                    'event_id': similar_event_id,
                    'score': float(similarities[idx]),
                    'reason': 'Similar content'
                })
            
            return similar_events
        except Exception as e:
            print(f"Error getting similar events: {e}")
            return []
    
    def record_interaction(self, user_id: str, event_id: str, interaction_type: str, 
                          rating: Optional[float] = None) -> Dict[str, Any]:
        """
        Record a user-event interaction for future model updates
        
        Args:
            user_id: User identifier
            event_id: Event identifier
            interaction_type: Type of interaction (view, click, booking, rating)
            rating: Optional explicit rating (1-5 scale)
        
        Returns:
            Status message
        """
        # Convert implicit interactions to ratings
        implicit_ratings = {
            'view': 1.0,
            'click': 2.0,
            'bookmark': 3.0,
            'booking': 4.0,
            'rating': rating if rating else 5.0
        }
        
        computed_rating = implicit_ratings.get(interaction_type, 1.0)
        
        # Store interaction (in production, save to database)
        interaction = {
            'user_id': user_id,
            'event_id': event_id,
            'interaction_type': interaction_type,
            'rating': computed_rating,
            'timestamp': datetime.now().isoformat()
        }
        
        return {
            'status': 'success',
            'message': 'Interaction recorded',
            'interaction': interaction
        }
    
    def get_model_stats(self) -> Dict[str, Any]:
        """Get current model statistics"""
        if self.model.svd_model is None:
            return {
                "status": "not_trained",
                "message": "Model has not been trained yet"
            }
        
        return {
            "status": "trained",
            "n_users": len(self.model.user_id_mapping),
            "n_events": len(self.model.event_id_mapping),
            "n_factors": self.model.svd_model.n_components,
            "explained_variance": float(self.model.svd_model.explained_variance_ratio_.sum()),
            "model_path": self.model_path
        }


# Global service instance
recommendation_service = RecommendationService()
