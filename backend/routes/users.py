from fastapi import APIRouter, Depends, HTTPException, status, Header
from pydantic import BaseModel, EmailStr
from typing import Optional, List, Dict, Any
from services.firebase_auth_service import get_firebase_auth_service
from services.firestore_service import get_firestore_service
from models.firestore_models import UserProfile, UserProfileUpdate, OrganizerProfile
from routes.auth import get_current_user

router = APIRouter()

firebase_auth_service = get_firebase_auth_service()
firestore_service = get_firestore_service()


# ============ REQUEST/RESPONSE MODELS ============

class UserPreferences(BaseModel):
    """User preferences for recommendations"""
    favorite_categories: List[str] = []
    favorite_organizers: List[str] = []
    price_range: Dict[str, float] = {"min": 0, "max": 10000}
    notification_settings: Dict[str, bool] = {
        "email_notifications": True,
        "push_notifications": True,
        "sms_notifications": False
    }
    privacy_level: str = "public"  # public, friends, private


class ProfileResponse(BaseModel):
    """User profile response"""
    uid: str
    email: str
    display_name: str
    user_type: str
    phone_number: Optional[str] = None
    avatar_url: Optional[str] = None
    bio: Optional[str] = None
    is_active: bool = True


# ============ USER ENDPOINTS ============

@router.get("/profile", response_model=ProfileResponse)
async def get_user_profile(authorization: Optional[str] = Header(None)):
    """
    Get current user profile
    Requires valid Firebase ID token
    
    Headers:
        Authorization: Bearer <firebase_id_token>
    """
    current_user = await get_current_user(authorization)
    
    return ProfileResponse(
        uid=current_user['id'],
        email=current_user['email'],
        display_name=current_user.get('display_name', ''),
        user_type=current_user.get('user_type', 'attendee'),
        phone_number=current_user.get('phone_number'),
        avatar_url=current_user.get('avatar_url'),
        bio=current_user.get('bio'),
        is_active=current_user.get('is_active', True)
    )


@router.get("/{user_id}", response_model=ProfileResponse)
async def get_user_profile_by_id(user_id: str):
    """
    Get user profile by ID (public endpoint)
    """
    try:
        user = firestore_service.get_user(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        return ProfileResponse(
            uid=user['id'],
            email=user.get('email', ''),
            display_name=user.get('display_name', ''),
            user_type=user.get('user_type', 'attendee'),
            phone_number=user.get('phone_number'),
            avatar_url=user.get('avatar_url'),
            bio=user.get('bio')
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get user profile: {str(e)}"
        )


@router.put("/profile")
async def update_user_profile(
    update_data: UserProfileUpdate,
    authorization: Optional[str] = Header(None)
):
    """
    Update user profile
    Requires valid Firebase ID token
    """
    current_user = await get_current_user(authorization)
    try:
        update_dict = update_data.dict(exclude_unset=True)
        
        updated_user = firebase_auth_service.update_user(
            uid=current_user['id'],
            **update_dict
        )
        
        return ProfileResponse(
            uid=updated_user['id'],
            email=updated_user['email'],
            display_name=updated_user.get('display_name', ''),
            user_type=updated_user.get('user_type', 'attendee'),
            phone_number=updated_user.get('phone_number'),
            avatar_url=updated_user.get('avatar_url'),
            bio=updated_user.get('bio')
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile: {str(e)}"
        )


@router.get("/preferences", response_model=UserPreferences)
async def get_user_preferences(authorization: Optional[str] = Header(None)):
    """
    Get user preferences for recommendations
    """
    current_user = await get_current_user(authorization)
    try:
        prefs = current_user.get('preferences', {})
        return UserPreferences(**prefs)
    except Exception as e:
        # Return defaults if preferences not found
        return UserPreferences()


@router.post("/preferences")
async def set_user_preferences(
    preferences: UserPreferences,
    authorization: Optional[str] = Header(None)
):
    """
    Set user preferences for recommendations
    """
    current_user = await get_current_user(authorization)
    try:
        firestore_service.update_user(
            current_user['id'],
            preferences=preferences.dict()
        )
        
        return {
            "message": "Preferences updated successfully",
            "preferences": preferences.dict()
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update preferences: {str(e)}"
        )


@router.get("/")
async def list_users(
    limit: int = 50,
    user_type: Optional[str] = None,
    authorization: Optional[str] = Header(None)
):
    """
    List users (admin only - for FUTURE use)
    Requires valid Firebase ID token
    """
    current_user = await get_current_user(authorization)
    # This is a placeholder - implement admin check later
    # For now, return empty to prevent unauthorized access
    raise HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail="This endpoint is not yet available"
    )


@router.post("/{user_id}/follow")
async def follow_user(
    user_id: str,
    authorization: Optional[str] = Header(None)
):
    """
    Follow a user (for organizer profiles)
    """
    current_user = await get_current_user(authorization)
    if user_id == current_user['id']:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot follow yourself"
        )
    
    try:
        # Add to followers list in Firestore
        user = firestore_service.get_user(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        followers = user.get('followers', [])
        if current_user['id'] not in followers:
            followers.append(current_user['id'])
            firestore_service.update_user(user_id, followers=followers)
        
        return {"message": "Successfully followed user"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to follow user: {str(e)}"
        )


@router.post("/{user_id}/unfollow")
async def unfollow_user(
    user_id: str,
    authorization: Optional[str] = Header(None)
):
    """
    Unfollow a user
    """
    current_user = await get_current_user(authorization)
    try:
        user = firestore_service.get_user(user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        
        followers = user.get('followers', [])
        if current_user['id'] in followers:
            followers.remove(current_user['id'])
            firestore_service.update_user(user_id, followers=followers)
        
        return {"message": "Successfully unfollowed user"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to unfollow user: {str(e)}"
        )
