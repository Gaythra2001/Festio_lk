from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr
from typing import Optional

router = APIRouter()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


class UserRegister(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    phone: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str
    user: dict


@router.post("/register", response_model=Token)
async def register(user_data: UserRegister):
    """
    Register a new user
    """
    # TODO: Implement user registration logic
    # 1. Validate email doesn't exist
    # 2. Hash password
    # 3. Create user in Firebase/Database
    # 4. Generate JWT token
    
    return {
        "access_token": "sample_token",
        "token_type": "bearer",
        "user": {
            "id": "123",
            "email": user_data.email,
            "full_name": user_data.full_name
        }
    }


@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    """
    Login user and return JWT token
    """
    # TODO: Implement login logic
    # 1. Verify credentials
    # 2. Generate JWT token
    
    return {
        "access_token": "sample_token",
        "token_type": "bearer",
        "user": {
            "id": "123",
            "email": form_data.username
        }
    }


@router.post("/logout")
async def logout(token: str = Depends(oauth2_scheme)):
    """
    Logout user (invalidate token if using token blacklist)
    """
    return {"message": "Successfully logged out"}


@router.get("/me")
async def get_current_user(token: str = Depends(oauth2_scheme)):
    """
    Get current authenticated user
    """
    # TODO: Decode token and get user info
    return {
        "id": "123",
        "email": "user@example.com",
        "full_name": "John Doe"
    }
