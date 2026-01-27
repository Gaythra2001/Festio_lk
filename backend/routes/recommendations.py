from fastapi import APIRouter, Query, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.recommendation_service import recommendation_service

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
    interaction_type: str  # view, click, bookmark, booking, rating
    rating: Optional[float] = None


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
    Record a user-event interaction for model improvement
    
    Interaction types:
    - **view**: User viewed event details
    - **click**: User clicked on event
    - **bookmark**: User bookmarked event
    - **booking**: User booked the event
    - **rating**: Explicit rating (requires rating field)
    """
    try:
        result = recommendation_service.record_interaction(
            user_id=interaction.user_id,
            event_id=interaction.event_id,
            interaction_type=interaction.interaction_type,
            rating=interaction.rating
        )
        return result
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
