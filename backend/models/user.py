from sqlalchemy import Column, String, DateTime, Boolean, JSON
from sqlalchemy.sql import func
from datetime import datetime


class User:
    """
    User model for the database
    """
    # TODO: Define SQLAlchemy or MongoDB model
    
    id: str
    email: str
    password_hash: str
    full_name: str
    phone: str = None
    role: str = "user"  # user, organizer, admin
    verified: bool = False
    preferences: dict = {}
    created_at: datetime = None
    updated_at: datetime = None
    
    def __repr__(self):
        return f"<User {self.email}>"
