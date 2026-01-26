from pydantic_settings import BaseSettings
from typing import List
import os


class Settings(BaseSettings):
    # Server
    PORT: int = 8000
    ENVIRONMENT: str = "development"
    
    # CORS
    ALLOWED_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5000"
    ]
    
    # Database
    DATABASE_URL: str = ""
    MONGODB_URL: str = ""
    
    # Firebase
    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_CLIENT_EMAIL: str = ""
    FIREBASE_PRIVATE_KEY: str = ""
    FIREBASE_CREDENTIALS_PATH: str = ""
    
    # JWT
    JWT_SECRET: str = "your-secret-key-change-this"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRES_IN_MINUTES: int = 10080  # 7 days
    
    # API Keys
    OPENAI_API_KEY: str = ""
    GOOGLE_PLACES_API_KEY: str = ""
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
