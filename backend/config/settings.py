from pydantic_settings import BaseSettings
from typing import List
import os


class Settings(BaseSettings):
    # Server
    PORT: int = 8000
    ENVIRONMENT: str = "development"
    
    @property
    def backend_dir(self) -> str:
        return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    @property
    def uploads_dir(self) -> str:
        return os.path.join(self.backend_dir, "uploads")
    
    # CORS
    # Allow all origins in development to support Flutter web's random port.
    ALLOWED_ORIGINS: List[str] = ["*"]
    
    # Database
    DATABASE_URL: str = "postgresql://user:password@localhost:5432/festio_lk"
    MONGODB_URL: str = ""
    
    # Firebase
    FIREBASE_PROJECT_ID: str = ""
    FIREBASE_CLIENT_EMAIL: str = ""
    FIREBASE_PRIVATE_KEY: str = ""
    FIREBASE_CREDENTIALS_PATH: str = ""
    FIREBASE_STORAGE_BUCKET: str = "festio-lk.firebasestorage.app"
    
    # JWT
    JWT_SECRET: str = "your-secret-key-change-this"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRES_IN_MINUTES: int = 10080  # 7 days
    
    # API Keys
    OPENAI_API_KEY: str = ""
    GOOGLE_PLACES_API_KEY: str = ""
    CLOUDINARY_URL: str = ""
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
