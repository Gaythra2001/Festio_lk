import numpy as np  # type: ignore
import pandas as pd  # type: ignore
from sklearn.preprocessing import MinMaxScaler  # type: ignore
from sklearn.decomposition import TruncatedSVD  # type: ignore
from sklearn.metrics.pairwise import cosine_similarity  # type: ignore
import joblib  # type: ignore
from typing import List, Dict, Optional, Any


class EventRecommendationModel:
    """
    Collaborative Filtering based recommendation model for events
    Uses SVD (Singular Value Decomposition) for matrix factorization
    """
    
    def __init__(self) -> None:
        self.user_item_matrix: Optional[pd.DataFrame] = None
        self.svd_model: Optional[TruncatedSVD] = None
        self.user_features: Optional[np.ndarray] = None
        self.event_features: Optional[np.ndarray] = None
        self.scaler: MinMaxScaler = MinMaxScaler()
        self.user_id_mapping: Dict[str, int] = {}
        self.event_id_mapping: Dict[str, int] = {}
        
    def build_user_item_matrix(self, interactions_df: pd.DataFrame) -> pd.DataFrame:
        """
        Build user-event interaction matrix from interactions dataframe
        
        Args:
            interactions_df: DataFrame with columns [user_id, event_id, rating]
        
        Returns:
            User-item matrix (users x events)
        """
        self.user_item_matrix = interactions_df.pivot_table(
            index='user_id',
            columns='event_id', 
            values='rating',
            fill_value=0
        )
        
        # Store mappings for new users/events
        self.user_id_mapping = {uid: idx for idx, uid in enumerate(self.user_item_matrix.index)}
        self.event_id_mapping = {eid: idx for idx, eid in enumerate(self.user_item_matrix.columns)}
        
        print(f"Built user-item matrix: {self.user_item_matrix.shape[0]} users, {self.user_item_matrix.shape[1]} events")
        return self.user_item_matrix
    
    def train_collaborative_filtering(self, n_factors: int = 50) -> TruncatedSVD:
        """
        Train collaborative filtering using SVD (Singular Value Decomposition)
        
        Args:
            n_factors: Number of latent factors
        
        Returns:
            Trained SVD model
        """
        if self.user_item_matrix is None:
            raise ValueError("Must call build_user_item_matrix first")
        
        self.svd_model = TruncatedSVD(n_components=n_factors, random_state=42)
        self.user_features = self.svd_model.fit_transform(self.user_item_matrix)
        self.event_features = self.svd_model.components_.T
        
        explained_variance = self.svd_model.explained_variance_ratio_.sum()
        print(f"SVD trained with {n_factors} factors")
        print(f"Explained variance: {explained_variance:.2%}")
        
        return self.svd_model
    
    def get_recommendations(self, user_id: str, n_recommendations: int = 10, 
                           exclude_viewed: bool = True) -> List[Dict[str, Any]]:
        """
        Get top N event recommendations for a user
        
        Args:
            user_id: User identifier
            n_recommendations: Number of recommendations to return
            exclude_viewed: Whether to exclude already viewed events
        
        Returns:
            List of recommendations with event_id and score
        """
        if self.svd_model is None:
            raise ValueError("Model not trained. Call train_collaborative_filtering first")
        
        if user_id not in self.user_item_matrix.index:
            return self._get_popular_events(n_recommendations)
        
        user_idx = self.user_item_matrix.index.get_loc(user_id)
        user_vector = self.user_features[user_idx]
        
        # Calculate cosine similarity between user and all events
        similarities = cosine_similarity([user_vector], self.event_features)[0]
        
        recommendations = []
        viewed_events = set()
        
        if exclude_viewed:
            # Get viewed events for this user
            user_row = self.user_item_matrix.iloc[user_idx]
            viewed_events = set(user_row[user_row > 0].index.tolist())
        
        for event_idx, similarity in enumerate(similarities):
            if event_idx not in viewed_events:
                event_id = self.user_item_matrix.columns[event_idx]
                recommendations.append({
                    'event_id': str(event_id),
                    'score': float(similarity),
                    'reason': 'Collaborative filtering recommendation'
                })
        
        # Sort by score and return top N
        recommendations.sort(key=lambda x: x['score'], reverse=True)
        return recommendations[:n_recommendations]
    
    def _get_popular_events(self, n: int = 10) -> List[Dict[str, Any]]:
        """
        Get popular events for cold-start users (no history)
        """
        if self.user_item_matrix is None:
            return []
        
        # Events with highest average ratings
        avg_ratings = self.user_item_matrix.mean(axis=0)
        popular_events = avg_ratings.nlargest(n)
        
        recommendations = []
        for event_id, score in popular_events.items():
            recommendations.append({
                'event_id': str(event_id),
                'score': float(score),
                'reason': 'Popular events'
            })
        
        return recommendations
    
    def evaluate(self, test_df: pd.DataFrame, k: int = 10) -> Dict[str, Any]:
        """
        Evaluate model performance
        
        Args:
            test_df: Test dataframe with columns [user_id, event_id, rating]
            k: Number of recommendations to evaluate
        
        Returns:
            Evaluation metrics
        """
        from sklearn.metrics import mean_squared_error, mean_absolute_error
        
        total_rmse = 0
        total_mae = 0
        evaluated_count = 0
        
        for user_id in test_df['user_id'].unique():
            user_test = test_df[test_df['user_id'] == user_id]
            recommendations = self.get_recommendations(user_id, n_recommendations=k)
            
            if recommendations:
                rec_event_ids = {r['event_id'] for r in recommendations}
                actual_ratings = user_test[user_test['event_id'].isin(rec_event_ids)]
                
                if len(actual_ratings) > 0:
                    actual_scores = actual_ratings['rating'].values
                    pred_scores = [r['score'] for r in recommendations 
                                 if r['event_id'] in rec_event_ids][:len(actual_scores)]
                    
                    rmse = np.sqrt(mean_squared_error(actual_scores, pred_scores))
                    mae = mean_absolute_error(actual_scores, pred_scores)
                    
                    total_rmse += rmse
                    total_mae += mae
                    evaluated_count += 1
        
        avg_rmse = total_rmse / max(evaluated_count, 1)
        avg_mae = total_mae / max(evaluated_count, 1)
        
        metrics = {
            'rmse': avg_rmse,
            'mae': avg_mae,
            'evaluated_users': evaluated_count
        }
        
        print(f"Evaluation Results:")
        print(f"  RMSE: {avg_rmse:.4f}")
        print(f"  MAE: {avg_mae:.4f}")
        print(f"  Evaluated users: {evaluated_count}")
        
        return metrics
    
    def save_model(self, path: str = 'models/recommendation_model.pkl') -> None:
        """Save trained model to disk"""
        model_data = {
            'svd_model': self.svd_model,
            'user_features': self.user_features,
            'event_features': self.event_features,
            'user_item_matrix': self.user_item_matrix,
            'user_id_mapping': self.user_id_mapping,
            'event_id_mapping': self.event_id_mapping
        }
        joblib.dump(model_data, path)
        print(f"✅ Model saved to {path}")
    
    def load_model(self, path: str = 'models/recommendation_model.pkl') -> None:
        """Load trained model from disk"""
        model_data: Dict[str, Any] = joblib.load(path)
        self.svd_model = model_data['svd_model']
        self.user_features = model_data['user_features']
        self.event_features = model_data['event_features']
        self.user_item_matrix = model_data['user_item_matrix']
        self.user_id_mapping = model_data['user_id_mapping']
        self.event_id_mapping = model_data['event_id_mapping']
        print(f"✅ Model loaded from {path}")
