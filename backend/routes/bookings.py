from fastapi import APIRouter, Depends, HTTPException, status, Path, Query, Header
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid
from services.firestore_service import get_firestore_service
from models.firestore_models import (
    Booking, BookingCreate, BookingUpdate, BookingStatus
)
from routes.auth import get_current_user

router = APIRouter()

firestore_service = get_firestore_service()


# ============ REQUEST/RESPONSE MODELS ============

class BookingResponse(BaseModel):
    id: str
    user_id: str
    event_id: str
    quantity: int
    total_price: float
    status: str
    created_at: datetime


# ============ BOOKING ENDPOINTS ============

@router.get("/", response_model=List[BookingResponse])
async def get_user_bookings(
    authorization: Optional[str] = Header(None),
    limit: int = Query(50, ge=1, le=100)
):
    """
    Get all bookings for the current user
    Requires valid Firebase ID token
    """
    current_user = await get_current_user(authorization)
    try:
        bookings = firestore_service.list_user_bookings(current_user['id'], limit=limit)
        return [
            BookingResponse(
                id=b['id'],
                user_id=b['user_id'],
                event_id=b['event_id'],
                quantity=b['quantity'],
                total_price=b['total_price'],
                status=b['status'],
                created_at=b['created_at']
            )
            for b in bookings
        ]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch bookings: {str(e)}"
        )


@router.post("/", response_model=BookingResponse, status_code=201)
async def create_booking(
    booking_data: BookingCreate,
    authorization: Optional[str] = Header(None)
):
    """
    Create a new booking
    Requires valid Firebase ID token
    """
    current_user = await get_current_user(authorization)
    try:
        # Get event details
        event = firestore_service.get_event(booking_data.event_id)
        if not event:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found"
            )
        
        # Find the ticket type
        tickets = event.get('tickets', [])
        ticket = next((t for t in tickets if t['name'] == booking_data.ticket_type), None)
        
        if not ticket:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Ticket type '{booking_data.ticket_type}' not found"
            )
        
        # Check availability
        if ticket['available'] < booking_data.quantity:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Not enough tickets available"
            )
        
        # Create booking
        booking_id = str(uuid.uuid4())
        booking_doc = {
            'user_id': current_user['id'],
            'event_id': booking_data.event_id,
            'organizer_id': event['organizer_id'],
            'ticket_type': booking_data.ticket_type,
            'quantity': booking_data.quantity,
            'unit_price': ticket['price'],
            'total_price': ticket['price'] * booking_data.quantity,
            'status': BookingStatus.pending,
            'payment_method': None,
            'transaction_id': None,
            'paid_at': None,
            'cancelled_at': None,
            'cancellation_reason': None,
            'refund_amount': None
        }
        
        booking = firestore_service.create_booking(booking_id, booking_doc)
        
        # Update event booking count
        event_bookings = event.get('bookings_count', 0)
        event_bookings += booking_data.quantity
        firestore_service.update_event(
            booking_data.event_id,
            {'bookings_count': event_bookings}
        )
        
        # Reduce available tickets
        for t in tickets:
            if t['name'] == booking_data.ticket_type:
                t['available'] -= booking_data.quantity
        firestore_service.update_event(booking_data.event_id, {'tickets': tickets})
        
        return BookingResponse(
            id=booking['id'],
            user_id=booking['user_id'],
            event_id=booking['event_id'],
            quantity=booking['quantity'],
            total_price=booking['total_price'],
            status=booking['status'],
            created_at=booking['created_at']
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create booking: {str(e)}"
        )


@router.get("/{booking_id}", response_model=BookingResponse)
async def get_booking(
    booking_id: str = Path(...),
    authorization: Optional[str] = Header(None)
):
    """
    Get a specific booking
    """
    current_user = await get_current_user(authorization)
    try:
        booking = firestore_service.get_booking(booking_id)
        if not booking:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found"
            )
        
        # Verify ownership or organizer access
        if booking['user_id'] != current_user['id'] and booking['organizer_id'] != current_user['id']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You don't have permission to view this booking"
            )
        
        return BookingResponse(
            id=booking['id'],
            user_id=booking['user_id'],
            event_id=booking['event_id'],
            quantity=booking['quantity'],
            total_price=booking['total_price'],
            status=booking['status'],
            created_at=booking['created_at']
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch booking: {str(e)}"
        )


@router.post("/{booking_id}/confirm")
async def confirm_booking(
    booking_id: str = Path(...),
    authorization: Optional[str] = Header(None)
):
    """
    Confirm a booking (mark as paid)
    """
    current_user = await get_current_user(authorization)
    try:
        booking = firestore_service.get_booking(booking_id)
        if not booking:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found"
            )
        
        # Verify ownership
        if booking['user_id'] != current_user['id']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only confirm your own bookings"
            )
        
        firestore_service.update_booking(
            booking_id,
            {
                'status': BookingStatus.confirmed,
                'paid_at': datetime.now()
            }
        )
        
        return {"message": "Booking confirmed successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to confirm booking: {str(e)}"
        )


@router.delete("/{booking_id}")
async def cancel_booking(
    booking_id: str = Path(...),
    cancellation_reason: Optional[str] = Query(None),
    authorization: Optional[str] = Header(None)
):
    """
    Cancel a booking
    """
    current_user = await get_current_user(authorization)
    try:
        booking = firestore_service.get_booking(booking_id)
        if not booking:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Booking not found"
            )
        
        # Verify ownership
        if booking['user_id'] != current_user['id']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only cancel your own bookings"
            )
        
        # Update booking status
        firestore_service.update_booking(
            booking_id,
            {
                'status': BookingStatus.cancelled,
                'cancelled_at': datetime.now(),
                'cancellation_reason': cancellation_reason,
                'refund_amount': booking['total_price']  # Full refund
            }
        )
        
        # Restore ticket availability
        event = firestore_service.get_event(booking['event_id'])
        tickets = event.get('tickets', [])
        for t in tickets:
            if t['name'] == booking['ticket_type']:
                t['available'] += booking['quantity']
        
        firestore_service.update_event(
            booking['event_id'],
            {
                'tickets': tickets,
                'bookings_count': max(0, event.get('bookings_count', 0) - booking['quantity'])
            }
        )
        
        return {"message": "Booking cancelled successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to cancel booking: {str(e)}"
        )


@router.get("/event/{event_id}/bookings", response_model=List[BookingResponse])
async def get_event_bookings(
    event_id: str = Path(...),
    authorization: Optional[str] = Header(None),
    limit: int = Query(100, ge=1, le=500)
):
    """
    Get all bookings for an event (organizer only)
    """
    current_user = await get_current_user(authorization)
    try:
        # Verify organizer access
        event = firestore_service.get_event(event_id)
        if not event:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found"
            )
        
        if event['organizer_id'] != current_user['id']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Only the organizer can view event bookings"
            )
        
        bookings = firestore_service.list_event_bookings(event_id, limit=limit)
        return [
            BookingResponse(
                id=b['id'],
                user_id=b['user_id'],
                event_id=b['event_id'],
                quantity=b['quantity'],
                total_price=b['total_price'],
                status=b['status'],
                created_at=b['created_at']
            )
            for b in bookings
        ]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch event bookings: {str(e)}"
        )
