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
                Optional feature columns supported for feature engineering:
                - interaction_type (view, click, bookmark, booking, rating, promotion_click, notification_click)
                - timestamp (ISO 8601 string)
                - channel (e.g., 'events_tab', 'calendar', 'promotion', 'notification')
                - is_promotion_click (bool)
                - calendar_selected (bool)
                - organizer_trust_score (0-100)
                - rating_value (explicit rating 1-5 if available)
                - notification_action (sent/open/click)
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
            
            # Feature engineering to enrich rating signal
            df = self._apply_feature_engineering(df)

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

    def _apply_feature_engineering(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Apply feature engineering to implicit interactions to enrich the rating signal.
        Features considered:
        - Recency/frequency per channel
        - Promotion response rate
        - Calendar-date preference
        - Organizer trust score
        - Rating bias/propensity
        - Notification engagement rate
        """
        engineered = df.copy()

        # Recency decay (30-day half-life-ish)
        if 'timestamp' in engineered.columns:
            ts = pd.to_datetime(engineered['timestamp'], errors='coerce')
        else:
            ts = pd.Series([datetime.utcnow()] * len(engineered))

        now = datetime.utcnow()
        recency_days = (now - ts).dt.total_seconds() / 86400.0
        recency_weight = np.exp(-recency_days.clip(lower=0) / 30.0)

        # Frequency per user/channel (0.9 - 1.1)
        channel_series = engineered.get('channel', pd.Series(['generic'] * len(engineered)))
        freq_counts = channel_series.groupby([engineered['user_id'], channel_series]).transform('count')
        freq_weight = 0.9 + 0.2 * (freq_counts / freq_counts.max().replace(0, 1))

        # Promotion response (clicks) boost
        promo_flag = engineered.get('is_promotion_click', pd.Series([False] * len(engineered))).fillna(False)
        promo_weight = np.where(promo_flag, 1.15, 1.0)

        # Calendar preference boost
        calendar_flag = engineered.get('calendar_selected', pd.Series([False] * len(engineered))).fillna(False)
        calendar_weight = np.where(calendar_flag, 1.10, 1.0)

        # Organizer trust score (0-100 -> 0.9-1.2)
        trust_series = engineered.get('organizer_trust_score', pd.Series([70] * len(engineered))).fillna(70)
        trust_weight = 0.9 + (trust_series.clip(0, 100) / 100.0) * 0.3

        # Rating bias/propensity: deviation from user's mean rating
        rating_values = engineered.get('rating_value', engineered['rating']).fillna(engineered['rating'])
        user_mean = rating_values.groupby(engineered['user_id']).transform('mean')
        rating_bias = (rating_values - user_mean).abs()
        rating_bias_weight = 1.0 + rating_bias.clip(0, 2) * 0.05  # up to +10%

        # Notification engagement weight
        notification_action = engineered.get('notification_action', pd.Series(['none'] * len(engineered))).fillna('none')
        notif_weight = notification_action.apply(
            lambda x: 1.2 if str(x).lower() in ['open', 'click'] else 1.0
        )

        # Combine weights and stabilize
        combined_weight = (
            recency_weight * freq_weight * promo_weight * calendar_weight * trust_weight * rating_bias_weight * notif_weight
        )
        combined_weight = np.clip(combined_weight, 0.5, 2.0)

        # Apply to ratings and clip to 0.5-5.0
        engineered['rating'] = (engineered['rating'].astype(float) * combined_weight).clip(0.5, 5.0)

        # Keep only required training columns
        return engineered[['user_id', 'event_id', 'rating']]
    
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
