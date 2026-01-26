from datetime import datetime


class Booking:
    """
    Booking model for the database
    """
    # TODO: Define SQLAlchemy or MongoDB model
    
    id: str
    user_id: str
    event_id: str
    quantity: int
    total_price: float
    status: str = "pending"  # pending, confirmed, cancelled, completed
    payment_status: str = "pending"  # pending, paid, refunded
    created_at: datetime = None
    updated_at: datetime = None
    
    def __repr__(self):
        return f"<Booking {self.id}>"
