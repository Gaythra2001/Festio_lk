"""
Feature Engineering Experiments Module
Systematically compares temporal, price-sensitivity, and location-distance features.
Runs ablation studies to determine which features most improve recommendation quality.
"""

from typing import Dict, Any, List, Optional, Tuple
import numpy as np  # type: ignore
import pandas as pd  # type: ignore
from datetime import datetime, timedelta
from sklearn.model_selection import train_test_split  # type: ignore
from sklearn.metrics import mean_squared_error, mean_absolute_error  # type: ignore
import json


class FeatureEngineer:
    """Handles feature engineering and ablation experiments."""
    
    def __init__(self):
        self.feature_importance = {}
        self.ablation_results = {}
        
    def extract_temporal_features(self, interaction_data: List[Dict[str, Any]]) -> pd.DataFrame:
        """
        Extract temporal features from user-event interactions.
        
        Features:
        - Hour of day
        - Day of week
        - Is weekend
        - Time since event creation
        - Days until event
        - Season
        """
        df = pd.DataFrame(interaction_data)
        
        if 'timestamp' not in df.columns:
            return df
        
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        
        # Hour of day (0-23)
        df['hour_of_day'] = df['timestamp'].dt.hour
        
        # Day of week (0=Monday, 6=Sunday)
        df['day_of_week'] = df['timestamp'].dt.dayofweek
        
        # Is weekend
        df['is_weekend'] = (df['day_of_week'] >= 5).astype(int)
        
        # Time-based cyclical features
        df['hour_sin'] = np.sin(2 * np.pi * df['hour_of_day'] / 24)
        df['hour_cos'] = np.cos(2 * np.pi * df['hour_of_day'] / 24)
        df['day_sin'] = np.sin(2 * np.pi * df['day_of_week'] / 7)
        df['day_cos'] = np.cos(2 * np.pi * df['day_of_week'] / 7)
        
        # Season (0=Winter, 1=Spring, 2=Summer, 3=Fall)
        df['month'] = df['timestamp'].dt.month
        df['season'] = ((df['month'] % 12 + 3) // 3).map({1: 0, 2: 1, 3: 2, 4: 3})
        
        # Time since event created (if available)
        if 'event_created_at' in df.columns:
            df['event_created_at'] = pd.to_datetime(df['event_created_at'])
            df['days_since_created'] = (df['timestamp'] - df['event_created_at']).dt.days
        
        # Days until event (if event date available)
        if 'event_date' in df.columns:
            df['event_date'] = pd.to_datetime(df['event_date'])
            df['days_until_event'] = (df['event_date'] - df['timestamp']).dt.days
            df['is_last_minute'] = (df['days_until_event'] <= 7).astype(int)
        
        return df
    
    def extract_price_sensitivity_features(self, user_event_data: List[Dict[str, Any]]) -> pd.DataFrame:
        """
        Extract price-related features to capture user price sensitivity.
        
        Features:
        - Absolute price
        - Price relative to user's average booking
        - Price percentile in category
        - Discount percentage
        - Price tier
        """
        df = pd.DataFrame(user_event_data)
        
        if 'price' not in df.columns:
            return df
        
        # Absolute price
        df['event_price'] = df['price']
        
        # User's average booking price
        if 'user_id' in df.columns:
            user_avg_price = df.groupby('user_id')['price'].transform('mean')
            df['price_vs_user_avg'] = df['price'] / (user_avg_price + 1e-6)
            df['price_diff_user_avg'] = df['price'] - user_avg_price
        
        # Price percentile within category
        if 'category' in df.columns:
            df['price_percentile_in_category'] = df.groupby('category')['price'].rank(pct=True)
        
        # Discount features
        if 'original_price' in df.columns:
            df['discount_amount'] = df['original_price'] - df['price']
            df['discount_percentage'] = (df['discount_amount'] / df['original_price']) * 100
            df['has_discount'] = (df['discount_amount'] > 0).astype(int)
        
        # Price tiers (binning)
        df['price_tier'] = pd.qcut(df['price'], q=5, labels=['very_low', 'low', 'medium', 'high', 'very_high'], duplicates='drop')
        df['price_tier_encoded'] = pd.qcut(df['price'], q=5, labels=False, duplicates='drop')
        
        # Log price for handling skewed distributions
        df['log_price'] = np.log1p(df['price'])
        
        return df
    
    def extract_location_distance_features(self, user_event_data: List[Dict[str, Any]]) -> pd.DataFrame:
        """
        Extract location-based features including distance calculations.
        
        Features:
        - Euclidean distance from user to event
        - Distance tier (near, medium, far)
        - Same city/region
        - Travel time estimate
        """
        df = pd.DataFrame(user_event_data)
        
        # Check if location data is available
        has_user_loc = 'user_lat' in df.columns and 'user_lon' in df.columns
        has_event_loc = 'event_lat' in df.columns and 'event_lon' in df.columns
        
        if has_user_loc and has_event_loc:
            # Calculate Haversine distance (km)
            df['distance_km'] = self._haversine_distance(
                df['user_lat'], df['user_lon'],
                df['event_lat'], df['event_lon']
            )
            
            # Distance tiers
            df['distance_tier'] = pd.cut(
                df['distance_km'],
                bins=[0, 5, 25, 100, float('inf')],
                labels=['very_near', 'near', 'medium', 'far']
            )
            df['distance_tier_encoded'] = pd.cut(
                df['distance_km'],
                bins=[0, 5, 25, 100, float('inf')],
                labels=False
            )
            
            # Is local (within 25km)
            df['is_local'] = (df['distance_km'] <= 25).astype(int)
            
            # Estimated travel time (rough: distance/40 for km, assuming 40km/h avg)
            df['estimated_travel_minutes'] = df['distance_km'] / 40 * 60
        
        # Same city/region
        if 'user_city' in df.columns and 'event_city' in df.columns:
            df['same_city'] = (df['user_city'] == df['event_city']).astype(int)
        
        if 'user_region' in df.columns and 'event_region' in df.columns:
            df['same_region'] = (df['user_region'] == df['event_region']).astype(int)
        
        return df
    
    def _haversine_distance(self, lat1: pd.Series, lon1: pd.Series, lat2: pd.Series, lon2: pd.Series) -> pd.Series:
        """Calculate Haversine distance between two points on Earth."""
        R = 6371  # Earth's radius in kilometers
        
        lat1_rad = np.radians(lat1)
        lat2_rad = np.radians(lat2)
        delta_lat = np.radians(lat2 - lat1)
        delta_lon = np.radians(lon2 - lon1)
        
        a = np.sin(delta_lat/2)**2 + np.cos(lat1_rad) * np.cos(lat2_rad) * np.sin(delta_lon/2)**2
        c = 2 * np.arcsin(np.sqrt(a))
        
        return R * c
    
    def run_ablation_study(
        self,
        X_full: pd.DataFrame,
        y: pd.Series,
        model_class: Any,
        feature_groups: Dict[str, List[str]]
    ) -> Dict[str, Any]:
        """
        Run ablation study to determine feature importance.
        
        Systematically removes feature groups to see impact on performance.
        
        Args:
            X_full: Full feature matrix
            y: Target variable
            model_class: Model class to use (should have fit/predict methods)
            feature_groups: Dictionary mapping group names to feature column lists
            
        Returns:
            Ablation study results showing performance with/without each group
        """
        results = {}
        
        # Baseline: all features
        X_train, X_test, y_train, y_test = train_test_split(X_full, y, test_size=0.2, random_state=42)
        
        model = model_class()
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        
        baseline_mse = mean_squared_error(y_test, y_pred)
        baseline_mae = mean_absolute_error(y_test, y_pred)
        
        results['baseline_all_features'] = {
            "mse": baseline_mse,
            "mae": baseline_mae,
            "rmse": np.sqrt(baseline_mse),
            "n_features": X_full.shape[1]
        }
        
        # Ablation: remove each feature group
        for group_name, feature_cols in feature_groups.items():
            # Remove this feature group
            remaining_cols = [col for col in X_full.columns if col not in feature_cols]
            X_ablated = X_full[remaining_cols]
            
            X_train_ab, X_test_ab, y_train_ab, y_test_ab = train_test_split(
                X_ablated, y, test_size=0.2, random_state=42
            )
            
            model_ab = model_class()
            model_ab.fit(X_train_ab, y_train_ab)
            y_pred_ab = model_ab.predict(X_test_ab)
            
            ablated_mse = mean_squared_error(y_test_ab, y_pred_ab)
            ablated_mae = mean_absolute_error(y_test_ab, y_pred_ab)
            
            # Calculate performance drop
            performance_drop = ablated_mse - baseline_mse
            
            results[f'without_{group_name}'] = {
                "mse": ablated_mse,
                "mae": ablated_mae,
                "rmse": np.sqrt(ablated_mse),
                "n_features": X_ablated.shape[1],
                "performance_drop_mse": performance_drop,
                "importance_score": performance_drop / baseline_mse if baseline_mse > 0 else 0
            }
        
        # Rank feature groups by importance
        importance_ranking = sorted(
            [(k, v['importance_score']) for k, v in results.items() if 'without_' in k],
            key=lambda x: x[1],
            reverse=True
        )
        
        results['feature_importance_ranking'] = [
            {"group": k.replace('without_', ''), "importance": v} 
            for k, v in importance_ranking
        ]
        
        self.ablation_results = results
        return results
    
    def compare_feature_sets(
        self,
        feature_sets: Dict[str, pd.DataFrame],
        y: pd.Series,
        model_class: Any
    ) -> Dict[str, Any]:
        """
        Compare different feature engineering approaches.
        
        Args:
            feature_sets: Dictionary of {approach_name: feature_dataframe}
            y: Target variable
            model_class: Model class to use
            
        Returns:
            Comparison results across different feature sets
        """
        comparison = {}
        
        for set_name, X in feature_sets.items():
            X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
            
            model = model_class()
            model.fit(X_train, y_train)
            y_pred = model.predict(X_test)
            
            mse = mean_squared_error(y_test, y_pred)
            mae = mean_absolute_error(y_test, y_pred)
            
            comparison[set_name] = {
                "mse": mse,
                "mae": mae,
                "rmse": np.sqrt(mse),
                "n_features": X.shape[1]
            }
        
        # Find best performing set
        best_set = min(comparison.items(), key=lambda x: x[1]['mse'])
        comparison['best_feature_set'] = {
            "name": best_set[0],
            "metrics": best_set[1]
        }
        
        return comparison


# Example usage
def generate_sample_feature_data() -> Dict[str, Any]:
    """Generate sample data for feature engineering experiments."""
    np.random.seed(42)
    
    n_samples = 1000
    
    interaction_data = []
    for i in range(n_samples):
        interaction_data.append({
            "user_id": np.random.randint(1, 100),
            "event_id": np.random.randint(1, 50),
            "timestamp": (datetime.now() - timedelta(days=np.random.randint(0, 90))).isoformat(),
            "event_date": (datetime.now() + timedelta(days=np.random.randint(1, 180))).isoformat(),
            "event_created_at": (datetime.now() - timedelta(days=np.random.randint(30, 365))).isoformat(),
            "price": np.random.uniform(10, 200),
            "original_price": np.random.uniform(10, 250),
            "category": np.random.choice(['Music', 'Sports', 'Art', 'Food', 'Tech']),
            "user_lat": np.random.uniform(6.0, 10.0),
            "user_lon": np.random.uniform(79.0, 82.0),
            "event_lat": np.random.uniform(6.0, 10.0),
            "event_lon": np.random.uniform(79.0, 82.0),
            "user_city": np.random.choice(['Colombo', 'Kandy', 'Galle']),
            "event_city": np.random.choice(['Colombo', 'Kandy', 'Galle']),
            "rating": np.random.uniform(1, 5)
        })
    
    return {"interaction_data": interaction_data}
