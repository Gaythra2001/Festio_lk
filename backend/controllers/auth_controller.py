from passlib.context import CryptContext  # type: ignore
from jose import JWTError, jwt  # type: ignore
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from config.settings import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against a hash"""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Hash a password"""
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: timedelta = None) -> str:
    """Create a JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.JWT_EXPIRES_IN_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt


def verify_token(token: str) -> Optional[Dict[str, Any]]:
    """Verify and decode a JWT token"""
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        return payload
    except JWTError:
        return None


def extract_token_from_header(authorization_header: str) -> Optional[str]:
    """
    Extract Bearer token from Authorization header
    
    Args:
        authorization_header: Authorization header value (Bearer <token>)
    
    Returns:
        Token string or None if invalid format
    """
    if not authorization_header:
        return None
    
    try:
        scheme, credentials = authorization_header.split()
        if scheme.lower() == "bearer":
            return credentials
    except ValueError:
        pass
    
    return None
