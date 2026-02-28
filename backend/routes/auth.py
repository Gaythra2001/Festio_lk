from fastapi import APIRouter, Depends, HTTPException, status, Header
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from services.firebase_auth_service import get_firebase_auth_service
from controllers.auth_controller import extract_token_from_header

router = APIRouter()

firebase_auth_service = get_firebase_auth_service()


# ============ REQUEST/RESPONSE MODELS ============

class UserRegister(BaseModel):
    email: EmailStr
    password: str
    display_name: str
    phone_number: Optional[str] = None
    user_type: str = Field(default="attendee", pattern="^(attendee|organizer)$")


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    phone_number: Optional[str] = None
    bio: Optional[str] = None
    avatar_url: Optional[str] = None
    location: Optional[dict] = None


class UserResponse(BaseModel):
    uid: str
    email: str
    display_name: str
    user_type: str
    email_verified: bool = False
    is_active: bool = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse


# ============ HELPER FUNCTIONS ============

async def get_current_user(authorization: Optional[str] = Header(None)) -> dict:
    """
    Get current authenticated user from Firebase token
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization header"
        )
    
    token = extract_token_from_header(authorization)
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header format. Use: Bearer <token>"
        )
    
    try:
        # Verify Firebase ID token
        decoded_token = firebase_auth_service.verify_id_token(token)
        uid = decoded_token.get('uid')
        
        # Get user profile from Firestore
        user = firebase_auth_service.get_user_by_uid(uid)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )
        
        return user
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired token: {str(e)}"
        )


# ============ AUTHENTICATION ENDPOINTS ============

@router.post("/register", response_model=TokenResponse)
async def register(user_data: UserRegister):
    """
    Register a new user with Firebase Authentication
    
    Note: This endpoint returns the user data but not an access token.
    The client should use the email and password to login via Firebase SDK to get the token.
    Or use POST /login after registration.
    """
    try:
        # Create user in Firebase and Firestore
        user = firebase_auth_service.create_user(
            email=user_data.email,
            password=user_data.password,
            display_name=user_data.display_name,
            phone_number=user_data.phone_number or "",
            user_type=user_data.user_type
        )
        
        # For now, return user data (client logs in separately via Firebase SDK)
        return {
            "access_token": "",
            "token_type": "bearer",
            "user": {
                "uid": user['uid'],
                "email": user['email'],
                "display_name": user['display_name'],
                "user_type": user['user_type'],
                "email_verified": False,
                "is_active": True
            }
        }
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Registration failed: {str(e)}"
        )


@router.post("/login", response_model=TokenResponse)
async def login(authorization: Optional[str] = Header(None)):
    """
    Verify Firebase authentication token
    Returns current user information if token is valid
    
    The access token should come from Firebase SDK authentication (web/mobile).
    This endpoint validates the token and returns the user profile.
    
    Headers:
        Authorization: Bearer <firebase_id_token>
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization header"
        )
    
    try:
        token = extract_token_from_header(authorization)
        if not token:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authorization header format. Use: Bearer <token>"
            )
        
        # Verify token
        decoded_token = firebase_auth_service.verify_id_token(token)
        uid = decoded_token.get('uid')
        
        # Get user profile
        user = firebase_auth_service.get_user_by_uid(uid)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )
        
        return {
            "access_token": token,
            "token_type": "bearer",
            "user": {
                "uid": user['id'],
                "email": user['email'],
                "display_name": user['display_name'],
                "user_type": user['user_type'],
                "email_verified": user.get('email_verified', False),
                "is_active": user.get('is_active', True)
            }
        }
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Login failed: {str(e)}"
        )



@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(current_user: dict = Depends(get_current_user)):
    """
    Get current authenticated user profile
    Requires valid Firebase ID token
    """
    return UserResponse(
        uid=current_user['id'],
        email=current_user['email'],
        display_name=current_user.get('display_name', ''),
        user_type=current_user.get('user_type', 'attendee'),
        email_verified=current_user.get('email_verified', False),
        is_active=current_user.get('is_active', True)
    )


@router.put("/profile", response_model=UserResponse)
async def update_user_profile(
    update_data: UserUpdate,
    current_user: dict = Depends(get_current_user)
):
    """
    Update current user profile
    Requires valid Firebase ID token
    """
    update_dict = update_data.dict(exclude_unset=True)
    
    updated_user = firebase_auth_service.update_user(
        uid=current_user['id'],
        **update_dict
    )
    
    return UserResponse(
        uid=updated_user['id'],
        email=updated_user['email'],
        display_name=updated_user.get('display_name', ''),
        user_type=updated_user.get('user_type', 'attendee'),
        email_verified=updated_user.get('email_verified', False),
        is_active=updated_user.get('is_active', True)
    )


@router.get("/verify-token")
async def verify_token(authorization: Optional[str] = Header(None)):
    """
    Verify if a Firebase ID token is valid
    Returns the decoded token claims
    
    Headers:
        Authorization: Bearer <firebase_id_token>
    """
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authorization header"
        )
    
    token = extract_token_from_header(authorization)
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header format. Use: Bearer <token>"
        )
    
    try:
        decoded_token = firebase_auth_service.verify_id_token(token)
        return {
            "valid": True,
            "uid": decoded_token.get('uid'),
            "email": decoded_token.get('email'),
            "iat": decoded_token.get('iat'),
            "exp": decoded_token.get('exp')
        }
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token verification failed: {str(e)}"
        )


@router.post("/logout")
async def logout(current_user: dict = Depends(get_current_user)):
    """
    Logout user
    Note: Firebase uses client-side token deletion. This endpoint is mainly for logging purposes.
    """
    return {
        "message": "Successfully logged out",
        "uid": current_user['id']
    }
