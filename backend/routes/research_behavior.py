"""
Research API Routes - User Behavior Mining & Cold-Start Study
"""

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
import sys
import os

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from research.user_behavior_mining import UserBehaviorMiner, generate_sample_behavior_data

router = APIRouter(prefix="/api/research/behavior", tags=["Research - Behavior"])

# Global instance
behavior_miner = UserBehaviorMiner()


# Request/Response Models
class ClickLog(BaseModel):
    user_id: int
    event_id: int
    timestamp: str
    action: str


class BookingLog(BaseModel):
    user_id: int
    event_id: int
    amount: float
    status: str


class UserFeature(BaseModel):
    user_id: int
    total_clicks: int = 0
    total_bookings: int = 0
    avg_session_duration: float = 0
    days_since_registration: int = 0


class ColdStartPreferences(BaseModel):
    preferred_categories: Optional[List[str]] = []
    preferred_location: Optional[str] = None
    price_range: Optional[List[float]] = [0, 1000]


class EventData(BaseModel):
    event_id: int
    view_count: int = 0
    booking_count: int = 0
    rating: float = 0
    category: Optional[str] = None
    location: Optional[str] = None
    price: float = 0


class EventFeature(BaseModel):
    event_id: int
    category: str
    location: str
    price: float


@router.post("/analyze-clicks")
async def analyze_clicks(click_data: List[ClickLog]):
    """
    Analyze user click patterns from logs.
    
    Returns click-through rates, engagement metrics, and temporal patterns.
    """
    try:
        click_dicts = [log.dict() for log in click_data]
        analysis = behavior_miner.analyze_click_logs(click_dicts)
        return {"status": "success", "analysis": analysis}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/analyze-bookings")
async def analyze_bookings(booking_data: List[BookingLog]):
    """
    Analyze booking conversion patterns.
    
    Returns conversion rates, revenue metrics, and top performing events.
    """
    try:
        booking_dicts = [log.dict() for log in booking_data]
        analysis = behavior_miner.analyze_booking_logs(booking_dicts)
        return {"status": "success", "analysis": analysis}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/cluster-users")
async def cluster_users(user_features: List[UserFeature]):
    """
    Cluster users by behavioral patterns to understand different user intents.
    
    Uses K-means clustering on user engagement metrics.
    """
    try:
        feature_dicts = [feat.dict() for feat in user_features]
        clustering = behavior_miner.cluster_user_intents(feature_dicts)
        return {"status": "success", "clustering": clustering}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/cold-start/popularity")
async def cold_start_popularity(event_data: List[EventData], top_n: int = 10):
    """
    Generate recommendations for cold-start users using popularity priors.
    
    Returns top N most popular events.
    """
    try:
        event_dicts = [event.dict() for event in event_data]
        recommendations = behavior_miner.cold_start_popularity_prior(event_dicts, top_n)
        return {
            "status": "success",
            "strategy": "popularity_prior",
            "recommendations": recommendations,
            "count": len(recommendations)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/cold-start/content-similarity")
async def cold_start_content(
    user_prefs: ColdStartPreferences,
    event_features: List[EventFeature],
    top_n: int = 10
):
    """
    Generate recommendations for cold-start users using content-based similarity.
    
    Matches user preferences with event features.
    """
    try:
        prefs_dict = user_prefs.dict()
        event_dicts = [event.dict() for event in event_features]
        recommendations = behavior_miner.cold_start_content_similarity(prefs_dict, event_dicts, top_n)
        return {
            "status": "success",
            "strategy": "content_similarity",
            "recommendations": recommendations,
            "count": len(recommendations)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/cold-start/evaluate")
async def evaluate_cold_start(
    strategy_name: str,
    recommendations: List[int],
    actual_interactions: List[int]
):
    """
    Evaluate the effectiveness of a cold-start strategy.
    
    Returns precision, recall, and F1 score.
    """
    try:
        evaluation = behavior_miner.evaluate_cold_start_strategy(
            strategy_name, recommendations, actual_interactions
        )
        return {"status": "success", "evaluation": evaluation}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/sample-data")
async def get_sample_data():
    """
    Generate sample behavior data for testing.
    
    Returns sample click logs, booking logs, and user features.
    """
    try:
        sample_data = generate_sample_behavior_data()
        return {
            "status": "success",
            "data": {
                "click_logs_count": len(sample_data['click_logs']),
                "booking_logs_count": len(sample_data['booking_logs']),
                "user_features_count": len(sample_data['user_features']),
                "sample_click_logs": sample_data['click_logs'][:5],
                "sample_booking_logs": sample_data['booking_logs'][:5],
                "sample_user_features": sample_data['user_features'][:5]
            }
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
