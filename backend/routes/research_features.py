"""
Research API Routes - Feature Engineering Experiments
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import sys
import os
import pandas as pd  # type: ignore

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from research.feature_engineering_experiments import FeatureEngineer, generate_sample_feature_data

router = APIRouter(prefix="/api/research/features", tags=["Research - Features"])

# Global instance
feature_engineer = FeatureEngineer()


# Request Models
class InteractionData(BaseModel):
    user_id: int
    event_id: int
    timestamp: str
    event_date: Optional[str] = None
    event_created_at: Optional[str] = None
    price: float = 0
    original_price: Optional[float] = None
    category: Optional[str] = None
    user_lat: Optional[float] = None
    user_lon: Optional[float] = None
    event_lat: Optional[float] = None
    event_lon: Optional[float] = None
    user_city: Optional[str] = None
    event_city: Optional[str] = None
    rating: float = 0


class AblationRequest(BaseModel):
    interaction_data: List[InteractionData]
    target_column: str = "rating"
    feature_groups: Dict[str, List[str]]


@router.post("/extract/temporal")
async def extract_temporal_features(interaction_data: List[InteractionData]):
    """
    Extract temporal features from user-event interactions.
    
    Features include:
    - Hour of day, day of week, is weekend
    - Cyclical time features (sin/cos)
    - Season, time since event creation
    - Days until event, is last minute
    """
    try:
        data_dicts = [d.dict() for d in interaction_data]
        df = feature_engineer.extract_temporal_features(data_dicts)
        
        # Convert to dict for JSON serialization
        result = df.to_dict(orient='records')
        
        return {
            "status": "success",
            "feature_count": len(df.columns),
            "sample_count": len(df),
            "features": list(df.columns),
            "sample_data": result[:5]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/extract/price-sensitivity")
async def extract_price_features(interaction_data: List[InteractionData]):
    """
    Extract price-sensitivity features.
    
    Features include:
    - Absolute price, price vs user average
    - Price percentile in category
    - Discount features
    - Price tiers, log price
    """
    try:
        data_dicts = [d.dict() for d in interaction_data]
        df = feature_engineer.extract_price_sensitivity_features(data_dicts)
        
        # Convert price_tier to string for JSON
        if 'price_tier' in df.columns:
            df['price_tier'] = df['price_tier'].astype(str)
        
        result = df.to_dict(orient='records')
        
        return {
            "status": "success",
            "feature_count": len(df.columns),
            "sample_count": len(df),
            "features": list(df.columns),
            "sample_data": result[:5]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/extract/location-distance")
async def extract_location_features(interaction_data: List[InteractionData]):
    """
    Extract location-based features including distance calculations.
    
    Features include:
    - Euclidean distance from user to event
    - Distance tier (near, medium, far)
    - Same city/region
    - Estimated travel time
    """
    try:
        data_dicts = [d.dict() for d in interaction_data]
        df = feature_engineer.extract_location_distance_features(data_dicts)
        
        # Convert categorical columns to string
        if 'distance_tier' in df.columns:
            df['distance_tier'] = df['distance_tier'].astype(str)
        
        result = df.to_dict(orient='records')
        
        return {
            "status": "success",
            "feature_count": len(df.columns),
            "sample_count": len(df),
            "features": list(df.columns),
            "sample_data": result[:5]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/extract/all")
async def extract_all_features(interaction_data: List[InteractionData]):
    """
    Extract all feature types (temporal, price, location) at once.
    
    Returns comprehensive feature matrix.
    """
    try:
        data_dicts = [d.dict() for d in interaction_data]
        
        # Extract all features
        df = pd.DataFrame(data_dicts)
        df = feature_engineer.extract_temporal_features(df.to_dict(orient='records'))
        df = feature_engineer.extract_price_sensitivity_features(df.to_dict(orient='records'))
        df = feature_engineer.extract_location_distance_features(df.to_dict(orient='records'))
        
        # Convert categorical to string
        for col in df.select_dtypes(include=['category']).columns:
            df[col] = df[col].astype(str)
        
        result = df.to_dict(orient='records')
        
        # Feature groups
        temporal_features = [c for c in df.columns if any(x in c for x in ['hour', 'day', 'weekend', 'season', 'month', 'sin', 'cos', 'time', 'until', 'since', 'minute'])]
        price_features = [c for c in df.columns if any(x in c for x in ['price', 'discount', 'tier'])]
        location_features = [c for c in df.columns if any(x in c for x in ['distance', 'lat', 'lon', 'city', 'region', 'local', 'travel'])]
        
        return {
            "status": "success",
            "total_features": len(df.columns),
            "sample_count": len(df),
            "feature_groups": {
                "temporal": temporal_features,
                "price": price_features,
                "location": location_features
            },
            "all_features": list(df.columns),
            "sample_data": result[:5]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/ablation-study")
async def run_ablation_study(request: AblationRequest):
    """
    Run ablation study to determine feature importance.
    
    Systematically removes feature groups to measure impact on performance.
    Requires a model class - currently returns template response.
    """
    try:
        # Note: This endpoint needs a proper model integration
        # For now, returning structure
        return {
            "status": "info",
            "message": "Ablation study requires model integration. Use /compare-feature-sets for basic comparison.",
            "expected_output": {
                "baseline_all_features": {"mse": 0.0, "mae": 0.0, "rmse": 0.0, "n_features": 0},
                "without_temporal": {"mse": 0.0, "importance_score": 0.0},
                "without_price": {"mse": 0.0, "importance_score": 0.0},
                "without_location": {"mse": 0.0, "importance_score": 0.0},
                "feature_importance_ranking": []
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/sample-data")
async def get_sample_feature_data():
    """
    Generate sample interaction data for feature engineering testing.
    """
    try:
        sample_data = generate_sample_feature_data()
        return {
            "status": "success",
            "data": {
                "interaction_count": len(sample_data['interaction_data']),
                "sample_interactions": sample_data['interaction_data'][:5]
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/feature-documentation")
async def get_feature_documentation():
    """
    Get documentation of all available features.
    """
    return {
        "status": "success",
        "feature_categories": {
            "temporal_features": {
                "description": "Time-based features for capturing temporal patterns",
                "features": [
                    "hour_of_day", "day_of_week", "is_weekend",
                    "hour_sin", "hour_cos", "day_sin", "day_cos",
                    "season", "month", "days_since_created",
                    "days_until_event", "is_last_minute"
                ]
            },
            "price_features": {
                "description": "Price-related features for capturing price sensitivity",
                "features": [
                    "event_price", "price_vs_user_avg", "price_diff_user_avg",
                    "price_percentile_in_category", "discount_amount",
                    "discount_percentage", "has_discount", "price_tier",
                    "price_tier_encoded", "log_price"
                ]
            },
            "location_features": {
                "description": "Location-based features for capturing spatial preferences",
                "features": [
                    "distance_km", "distance_tier", "distance_tier_encoded",
                    "is_local", "estimated_travel_minutes", "same_city", "same_region"
                ]
            }
        }
    }
