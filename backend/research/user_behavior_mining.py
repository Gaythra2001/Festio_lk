"""
User Behavior Mining & Cold-Start Study Module
Analyzes user click/booking logs, clusters user intents, and tests cold-start strategies.
"""

from typing import Dict, Any, List, Optional
import numpy as np  # type: ignore
import pandas as pd  # type: ignore
from sklearn.cluster import KMeans  # type: ignore
from sklearn.preprocessing import StandardScaler  # type: ignore
from datetime import datetime, timedelta
import json


class UserBehaviorMiner:
    """Analyzes user behavior patterns and handles cold-start problems."""
    
    def __init__(self):
        self.scaler = StandardScaler()
        self.kmeans_model = None
        self.n_clusters = 5
        
    def analyze_click_logs(self, click_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Analyze user click patterns from logs.
        
        Args:
            click_data: List of click events with user_id, event_id, timestamp, action
            
        Returns:
            Analysis results including click-through rates, engagement metrics
        """
        df = pd.DataFrame(click_data)
        
        if df.empty:
            return {"error": "No click data available"}
        
        analysis = {
            "total_clicks": len(df),
            "unique_users": df['user_id'].nunique(),
            "unique_events": df['event_id'].nunique(),
            "avg_clicks_per_user": len(df) / df['user_id'].nunique(),
            "avg_clicks_per_event": len(df) / df['event_id'].nunique(),
            "time_range": {
                "start": df['timestamp'].min(),
                "end": df['timestamp'].max()
            }
        }
        
        # Click distribution by hour
        df['hour'] = pd.to_datetime(df['timestamp']).dt.hour
        hourly_dist = df.groupby('hour').size().to_dict()
        analysis['hourly_distribution'] = hourly_dist
        
        return analysis
    
    def analyze_booking_logs(self, booking_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Analyze booking conversion patterns.
        
        Args:
            booking_data: List of booking events with user_id, event_id, amount, status
            
        Returns:
            Booking analytics including conversion rates, revenue metrics
        """
        df = pd.DataFrame(booking_data)
        
        if df.empty:
            return {"error": "No booking data available"}
        
        analysis = {
            "total_bookings": len(df),
            "unique_users": df['user_id'].nunique(),
            "unique_events": df['event_id'].nunique(),
            "successful_bookings": len(df[df['status'] == 'confirmed']),
            "total_revenue": df[df['status'] == 'confirmed']['amount'].sum(),
            "avg_booking_value": df[df['status'] == 'confirmed']['amount'].mean(),
            "conversion_rate": len(df[df['status'] == 'confirmed']) / len(df) if len(df) > 0 else 0
        }
        
        # Top events by bookings
        top_events = df.groupby('event_id').size().sort_values(ascending=False).head(10)
        analysis['top_events'] = top_events.to_dict()
        
        return analysis
    
    def cluster_user_intents(self, user_features: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Cluster users by behavioral patterns to understand different user intents.
        
        Args:
            user_features: List of user feature vectors (clicks, bookings, preferences)
            
        Returns:
            Cluster assignments and characteristics
        """
        df = pd.DataFrame(user_features)
        
        if df.empty or len(df) < self.n_clusters:
            return {"error": "Insufficient data for clustering"}
        
        # Select numeric features for clustering
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        X = df[numeric_cols].fillna(0)
        
        # Standardize features
        X_scaled = self.scaler.fit_transform(X)
        
        # Perform K-means clustering
        self.kmeans_model = KMeans(n_clusters=self.n_clusters, random_state=42)
        clusters = self.kmeans_model.fit_predict(X_scaled)
        
        df['cluster'] = clusters
        
        # Analyze cluster characteristics
        cluster_stats = {}
        for cluster_id in range(self.n_clusters):
            cluster_data = df[df['cluster'] == cluster_id]
            cluster_stats[f"cluster_{cluster_id}"] = {
                "size": len(cluster_data),
                "percentage": len(cluster_data) / len(df) * 100,
                "avg_clicks": cluster_data['total_clicks'].mean() if 'total_clicks' in cluster_data else 0,
                "avg_bookings": cluster_data['total_bookings'].mean() if 'total_bookings' in cluster_data else 0
            }
        
        return {
            "n_clusters": self.n_clusters,
            "cluster_assignments": clusters.tolist(),
            "cluster_statistics": cluster_stats
        }
    
    def cold_start_popularity_prior(self, event_data: List[Dict[str, Any]], top_n: int = 10) -> List[int]:
        """
        Generate recommendations for cold-start users using popularity priors.
        
        Args:
            event_data: List of events with popularity metrics
            top_n: Number of recommendations to return
            
        Returns:
            List of event IDs sorted by popularity
        """
        df = pd.DataFrame(event_data)
        
        if df.empty:
            return []
        
        # Calculate popularity score
        df['popularity_score'] = (
            df.get('view_count', 0) * 0.3 +
            df.get('booking_count', 0) * 0.5 +
            df.get('rating', 0) * 0.2
        )
        
        # Sort by popularity and return top N
        top_events = df.nlargest(top_n, 'popularity_score')
        return top_events['event_id'].tolist()
    
    def cold_start_content_similarity(
        self, 
        new_user_prefs: Dict[str, Any], 
        event_features: List[Dict[str, Any]],
        top_n: int = 10
    ) -> List[int]:
        """
        Generate recommendations for cold-start users using content-based similarity.
        
        Args:
            new_user_prefs: User preferences (categories, location, price_range)
            event_features: List of events with feature vectors
            top_n: Number of recommendations to return
            
        Returns:
            List of event IDs matching user preferences
        """
        df = pd.DataFrame(event_features)
        
        if df.empty:
            return []
        
        # Calculate similarity score based on user preferences
        similarity_scores = []
        
        for _, event in df.iterrows():
            score = 0
            
            # Category match
            if 'preferred_categories' in new_user_prefs and 'category' in event:
                if event['category'] in new_user_prefs['preferred_categories']:
                    score += 0.4
            
            # Location proximity (simplified)
            if 'preferred_location' in new_user_prefs and 'location' in event:
                if event['location'] == new_user_prefs['preferred_location']:
                    score += 0.3
            
            # Price range match
            if 'price_range' in new_user_prefs and 'price' in event:
                min_price, max_price = new_user_prefs['price_range']
                if min_price <= event['price'] <= max_price:
                    score += 0.3
            
            similarity_scores.append(score)
        
        df['similarity_score'] = similarity_scores
        
        # Sort by similarity and return top N
        top_events = df.nlargest(top_n, 'similarity_score')
        return top_events['event_id'].tolist()
    
    def evaluate_cold_start_strategy(
        self,
        strategy_name: str,
        recommendations: List[int],
        actual_interactions: List[int]
    ) -> Dict[str, float]:
        """
        Evaluate the effectiveness of a cold-start strategy.
        
        Args:
            strategy_name: Name of the strategy being evaluated
            recommendations: List of recommended event IDs
            actual_interactions: List of event IDs the user actually interacted with
            
        Returns:
            Evaluation metrics (precision, recall, f1)
        """
        recommended_set = set(recommendations)
        actual_set = set(actual_interactions)
        
        true_positives = len(recommended_set & actual_set)
        
        precision = true_positives / len(recommended_set) if recommended_set else 0
        recall = true_positives / len(actual_set) if actual_set else 0
        f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
        
        return {
            "strategy": strategy_name,
            "precision": precision,
            "recall": recall,
            "f1_score": f1,
            "true_positives": true_positives,
            "recommendations_count": len(recommendations),
            "actual_interactions": len(actual_interactions)
        }


# Example usage and testing functions
def generate_sample_behavior_data() -> Dict[str, Any]:
    """Generate sample data for testing behavior mining."""
    np.random.seed(42)
    
    # Sample click logs
    click_logs = []
    for i in range(1000):
        click_logs.append({
            "user_id": np.random.randint(1, 100),
            "event_id": np.random.randint(1, 50),
            "timestamp": (datetime.now() - timedelta(days=np.random.randint(0, 30))).isoformat(),
            "action": np.random.choice(["view", "click", "share"])
        })
    
    # Sample booking logs
    booking_logs = []
    for i in range(300):
        booking_logs.append({
            "user_id": np.random.randint(1, 100),
            "event_id": np.random.randint(1, 50),
            "amount": np.random.uniform(10, 200),
            "status": np.random.choice(["confirmed", "pending", "cancelled"], p=[0.7, 0.2, 0.1])
        })
    
    # Sample user features for clustering
    user_features = []
    for user_id in range(1, 100):
        user_features.append({
            "user_id": user_id,
            "total_clicks": np.random.randint(5, 100),
            "total_bookings": np.random.randint(0, 20),
            "avg_session_duration": np.random.uniform(60, 600),
            "days_since_registration": np.random.randint(1, 365)
        })
    
    return {
        "click_logs": click_logs,
        "booking_logs": booking_logs,
        "user_features": user_features
    }
