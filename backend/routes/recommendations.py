from fastapi import APIRouter, Query, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.recommendation_service import recommendation_service
from services.interaction_logger import interaction_logger
from services.evaluation_metrics import evaluation_metrics

router = APIRouter()


class Recommendation(BaseModel):
    event_id: str
    score: float
    reason: str


class TrainingData(BaseModel):
    interactions: List[Dict[str, Any]]
    n_factors: int = 50


class InteractionRecord(BaseModel):
    user_id: str
    event_id: str
    interaction_type: str  # view, click, bookmark, booking, rating, promotion_click, notification_click
    rating: Optional[float] = None
    channel: Optional[str] = None  # events_tab, calendar, promotion, notification, search
    is_promotion_click: bool = False
    calendar_selected: bool = False
    organizer_trust_score: Optional[float] = None
    rating_value: Optional[float] = None
    notification_action: Optional[str] = None  # sent, open, click
    metadata: Optional[Dict[str, Any]] = None


class RecommendationSession(BaseModel):
    user_id: str
    recommended_events: List[str]
    clicked_events: Optional[List[str]] = None
    booked_events: Optional[List[str]] = None
    context: Optional[Dict[str, Any]] = None


@router.get("/", response_model=List[Recommendation])
async def get_recommendations(
    user_id: str = Query(..., description="User ID for personalized recommendations"),
    limit: int = Query(10, ge=1, le=50),
    exclude_viewed: bool = Query(True, description="Exclude already viewed events")
):
    """
    Get AI-powered event recommendations for a user using ML collaborative filtering
    
    - **user_id**: User identifier
    - **limit**: Number of recommendations to return (1-50)
    - **exclude_viewed**: Whether to exclude events already viewed by user
    """
    try:
        recommendations = recommendation_service.get_recommendations(
            user_id=user_id,
            n_recommendations=limit,
            exclude_viewed=exclude_viewed
        )
        
        return [Recommendation(**rec) for rec in recommendations]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/similar/{event_id}")
async def get_similar_events(
    event_id: str,
    limit: int = Query(5, ge=1, le=20)
):
    """
    Get events similar to a given event based on collaborative filtering
    
    - **event_id**: Event identifier
    - **limit**: Number of similar events to return
    """
    try:
        similar = recommendation_service.get_similar_events(
            event_id=event_id,
            n_similar=limit
        )
        return similar
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/train")
async def train_model(data: TrainingData):
    """
    Train the recommendation model with user-event interaction data
    
    Requires interaction data with format:
    ```json
    {
        "interactions": [
            {"user_id": "user1", "event_id": "event1", "rating": 5.0},
            {"user_id": "user2", "event_id": "event2", "rating": 4.0}
        ],
        "n_factors": 50
    }
    ```
    """
    try:
        result = recommendation_service.train_model(
            interactions=data.interactions,
            n_factors=data.n_factors
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/interaction")
async def record_interaction(interaction: InteractionRecord):
    """
    Record a user-event interaction for model improvement.
    
    Supports rich interaction data:
    - interaction_type: view, click, bookmark, booking, rating, promotion_click, notification_click
    - channel: events_tab, calendar, promotion, notification, search
    - promotion/calendar/notification tracking
    - organizer trust scores and explicit ratings
    """
    try:
        # Log to interaction logger with all features
        logged = interaction_logger.log_interaction(
            user_id=interaction.user_id,
            event_id=interaction.event_id,
            interaction_type=interaction.interaction_type,
            rating=interaction.rating,
            channel=interaction.channel,
            is_promotion_click=interaction.is_promotion_click,
            calendar_selected=interaction.calendar_selected,
            organizer_trust_score=interaction.organizer_trust_score,
            rating_value=interaction.rating_value,
            notification_action=interaction.notification_action,
            metadata=interaction.metadata
        )
        
        return {"status": "logged", "interaction": logged}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/feedback")
async def provide_feedback(event_id: str, user_id: str, liked: bool):
    """
    Provide feedback on a recommendation to improve future suggestions
    
    - **event_id**: Event that was recommended
    - **user_id**: User providing feedback
    - **liked**: Whether user liked the recommendation
    """
    try:
        # Convert like/dislike to rating
        rating = 5.0 if liked else 1.0
        
        result = recommendation_service.record_interaction(
            user_id=user_id,
            event_id=event_id,
            interaction_type='rating',
            rating=rating
        )
        
        return {"message": "Feedback recorded", "details": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/model/stats")
async def get_model_stats():
    """
    Get current recommendation model statistics
    
    Returns information about:
    - Number of users in the model
    - Number of events in the model
    - Model training status
    - Explained variance
    """
    try:
        stats = recommendation_service.get_model_stats()
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/impression")
async def log_impression(
    user_id: str,
    event_id: str,
    channel: str,
    position: int,
    organizer_id: Optional[str] = None,
    is_promoted: bool = False
):
    """
    Log when user sees a recommendation (for CTR/conversion tracking)
    
    - **user_id**: User ID
    - **event_id**: Event ID that was shown
    - **channel**: Where recommendation appeared (feed, notification, search, etc.)
    - **position**: Position in list (0-indexed)
    - **is_promoted**: Whether this was a promoted event
    """
    try:
        impression = interaction_logger.log_impression(
            user_id=user_id,
            event_id=event_id,
            channel=channel,
            position=position,
            organizer_id=organizer_id,
            is_promoted=is_promoted
        )
        return {"status": "logged", "impression": impression}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/session")
async def log_recommendation_session(session: RecommendationSession):
    """
    Log a complete recommendation session for evaluation
    
    Records what was recommended, what user clicked, and what they booked.
    Used to calculate NDCG, Recall@K, CTR, and booking conversion rates.
    """
    try:
        logged_session = evaluation_metrics.log_recommendation_session(
            user_id=session.user_id,
            recommended_events=session.recommended_events,
            user_actions={
                'clicked_events': session.clicked_events or [],
                'booked_events': session.booked_events or []
            },
            context=session.context
        )
        return {"status": "logged", "session": logged_session}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/metrics")
async def get_metrics(days_back: int = Query(7, ge=1, le=90)):
    """
    Get recommendation quality metrics over time period
    
    Returns:
    - NDCG@10: Ranking quality (0-1)
    - Recall@10: Coverage of user interests (0-1)
    - Precision@10: Fraction of relevant recommendations (0-1)
    - MRR: Mean reciprocal rank (0-1)
    - CTR: Click-through rate (%)
    - Booking rate: Bookings from clicks (%)
    - Total clicks and bookings
    """
    try:
        metrics = evaluation_metrics.calculate_aggregate_metrics(days_back=days_back)
        return metrics
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/promotion-lift")
async def get_promotion_lift():
    """
    Get promotional recommendation lift metrics
    
    Compares promoted vs organic recommendations performance
    """
    try:
        # Load recent sessions
        from services.evaluation_metrics import evaluation_metrics
        
        # This would need session data partitioned by promotion status
        # For now, return structure placeholder
        return {
            "message": "Implement session filtering by promotion status",
            "promoted_conversion_rate": 0.0,
            "control_conversion_rate": 0.0,
            "lift_percentage": 0.0
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/user/{user_id}/analytics")
async def get_user_interaction_analytics(user_id: str, days_back: int = Query(30, ge=1, le=180)):
    """
    Get per-user interaction analytics
    
    Returns:
    - Interaction types and frequencies
    - Channel preferences
    - Average engagement rating
    - Calendar selections
    - Booking count
    """
    try:
        analytics = interaction_logger.get_user_interaction_summary(user_id, days_back)
        channel_freq = interaction_logger.get_user_channel_frequency(user_id, days_back)
        analytics['channel_frequency'] = channel_freq
        return analytics
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/organizer/{organizer_id}/promotion-analytics")
async def get_organizer_promotion_analytics(
    organizer_id: str,
    days_back: int = Query(30, ge=1, le=180)
):
    """
    Get promotion analytics for an organizer
    
    Returns:
    - Promotional CTR
    - Conversion rate
    - Number of clicks and conversions
    """
    try:
        # This would need to filter impressions/interactions by organizer
        promo_stats = interaction_logger.get_promotion_response_rate(
            organizer_id=organizer_id,
            days_back=days_back
        )
        return promo_stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/notifications/engagement")
async def get_notification_engagement(days_back: int = Query(30, ge=1, le=180)):
    """
    Get notification engagement metrics
    
    Returns:
    - Open rate (%)
    - Click-through rate (%)
    - Number of sends, opens, clicks
    """
    try:
        engagement = interaction_logger.get_notification_engagement_stats(days_back)
        return engagement
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/retrain")
async def retrain_model():
    """
    Retrain recommendation model with latest interactions
    
    Pulls all logged interactions from the last 90 days and retrains
    the collaborative filtering model with feature engineering.
    """
    try:
        # Get recent interactions
        interactions = interaction_logger.get_interactions_for_training(
            days_back=90,
            min_rating=0.5
        )
        
        if not interactions:
            return {
                "status": "warning",
                "message": "No recent interactions found for retraining"
            }
        
        # Retrain model
        result = recommendation_service.train_model(
            interactions=interactions,
            n_factors=50
        )
        
        return {
            "status": result.get("status", "error"),
            "message": result.get("message"),
            "interactions_used": len(interactions),
            **result
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/scheduler/status")
async def get_scheduler_status():
    """
    Get model retraining scheduler status
    
    Returns:
    - is_running: Whether scheduler is active
    - check_interval_hours: How often to check for retraining
    - last_retrain: Timestamp of last retraining
    - retrain_count: Total number of retraining events
    - recent_retrains: Last 5 retraining events with status
    """
    try:
        from services.model_retraining_scheduler import get_scheduler
        scheduler = get_scheduler()
        status = scheduler.get_status()
        return status
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/scheduler/start")
async def start_scheduler():
    """
    Start the model retraining scheduler
    
    Scheduler will automatically retrain model on configured interval
    with recent interaction data.
    """
    try:
        from services.model_retraining_scheduler import get_scheduler
        scheduler = get_scheduler()
        scheduler.start()
        return {
            "status": "success",
            "message": "Scheduler started",
            "check_interval_hours": scheduler.check_interval_hours
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/scheduler/stop")
async def stop_scheduler():
    """Stop the model retraining scheduler"""
    try:
        from services.model_retraining_scheduler import get_scheduler
        scheduler = get_scheduler()
        scheduler.stop()
        return {"status": "success", "message": "Scheduler stopped"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/scheduler/history")
async def get_retrain_history(limit: int = Query(20, ge=1, le=100)):
    """
    Get recent model retraining history
    
    - **limit**: Number of recent retraining events to return
    """
    try:
        from services.model_retraining_scheduler import get_scheduler
        scheduler = get_scheduler()
        history = scheduler.get_retrain_history(limit=limit)
        return {"count": len(history), "history": history}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

