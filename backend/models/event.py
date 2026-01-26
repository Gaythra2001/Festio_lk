from datetime import datetime
from typing import List


class Event:
    """
    Event model for the database
    """
    # TODO: Define SQLAlchemy or MongoDB model
    
    id: str
    title: str
    description: str
    category: str
    location: str
    start_date: datetime
    end_date: datetime
    organizer_id: str
    price: float
    capacity: int
    images: List[str] = []
    status: str = "active"  # active, cancelled, completed
    created_at: datetime = None
    updated_at: datetime = None
    
    def __repr__(self):
        return f"<Event {self.title}>"
