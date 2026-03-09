from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Path, Header, Query
from starlette.concurrency import run_in_threadpool
from typing import List, Optional
from datetime import datetime
import uuid
from services.firestore_service import get_firestore_service
from services.storage_service import get_storage_service
from models.firestore_models import (
    Event, EventCreate, EventUpdate, EventStatus, EventCategory, EventLocation
)
from routes.auth import get_current_user

router = APIRouter()

firestore_service = get_firestore_service()
storage_service = get_storage_service()


# ============ HELPER FUNCTIONS ============

def is_organizer(current_user: dict) -> bool:
    """Verify user is an organizer"""
    return current_user.get('user_type') == 'organizer'


# ============ EVENT ENDPOINTS ============

@router.get("/", response_model=List[Event])
async def get_events(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, ge=1, le=100),
    category: Optional[str] = None,
    search: Optional[str] = None,
    status: Optional[str] = None
):
    """
    Get all published events with pagination and filters
    """
    try:
        filters = {'status': 'published'}
        
        if category:
            filters['category'] = category
        
        events = firestore_service.list_events(limit=limit, filters=filters)
        
        # Apply search filter if provided
        if search:
            search_lower = search.lower()
            events = [
                e for e in events 
                if search_lower in e.get('title', '').lower() or 
                   search_lower in e.get('description', '').lower()
            ]
        
        # Apply pagination
        return events[skip:skip + limit]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch events: {str(e)}"
        )


@router.get("/{event_id}", response_model=Event)
async def get_event(event_id: str = Path(...)):
    """
    Get a specific event by ID
    """
    try:
        event = firestore_service.get_event(event_id)
        if not event:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found"
            )
        return event
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch event: {str(e)}"
        )


@router.post("/", response_model=Event, status_code=201)
async def create_event(
    event_data: EventCreate,
    authorization: Optional[str] = Header(None)
):
    """
    Create a new event (organizer only)
    Requires valid Firebase ID token with organizer role
    """
    current_user = await get_current_user(authorization)
    if not is_organizer(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can create events"
        )
    
    try:
        event_id = str(uuid.uuid4())
        
        event_doc = {
            'organizer_id': current_user['id'],
            'title': event_data.title,
            'description': event_data.description,
            'category': event_data.category,
            'status': EventStatus.draft,
            'start_date': event_data.start_date,
            'end_date': event_data.end_date,
            'timezone': event_data.timezone,
            'location': event_data.location.dict(),
            'is_online': event_data.is_online,
            'online_url': event_data.online_url,
            'tickets': [t.dict() for t in event_data.tickets],
            'total_capacity': event_data.total_capacity,
            'bookings_count': 0,
            'image_url': event_data.image_url,
            'tags': event_data.tags or [],
            'average_rating': 0.0,
            'total_reviews': 0
        }
        
        return firestore_service.create_event(event_id, event_doc)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create event: {str(e)}"
        )


@router.put("/{event_id}", response_model=Event)
async def update_event(
    event_id: str = Path(...),
    event_data: EventUpdate = None,
    authorization: Optional[str] = Header(None)
):
    """
    Update an event (organizer only, must be event creator)
    """
    current_user = await get_current_user(authorization)
    if not is_organizer(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can update events"
        )
    
    try:
        # Verify ownership
        event = firestore_service.get_event(event_id)
        if not event:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found"
            )
        
        if event['organizer_id'] != current_user['id']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only update your own events"
            )
        
        # Prepare update data
        update_dict = event_data.dict(exclude_unset=True)
        
        # Convert nested objects
        if 'location' in update_dict and update_dict['location']:
            update_dict['location'] = update_dict['location'].dict()
        if 'tickets' in update_dict and update_dict['tickets']:
            update_dict['tickets'] = [t.dict() for t in update_dict['tickets']]
        
        return firestore_service.update_event(event_id, update_dict)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update event: {str(e)}"
        )


@router.delete("/{event_id}")
async def delete_event(
    event_id: str = Path(...),
    authorization: Optional[str] = Header(None)
):
    """
    Delete an event (organizer only, must be event creator)
    """
    current_user = await get_current_user(authorization)
    if not is_organizer(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can delete events"
        )
    
    try:
        # Verify ownership
        event = firestore_service.get_event(event_id)
        if not event:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found"
            )
        
        if event['organizer_id'] != current_user['id']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only delete your own events"
            )
        
        firestore_service.delete_event(event_id)
        return {"message": "Event deleted successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete event: {str(e)}"
        )


@router.post("/{event_id}/publish")
async def publish_event(
    event_id: str = Path(...),
    authorization: Optional[str] = Header(None)
):
    """
    Publish an event to make it visible to users
    """
    current_user = await get_current_user(authorization)
    if not is_organizer(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can publish events"
        )
    
    try:
        event = firestore_service.get_event(event_id)
        if not event:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found"
            )
        
        if event['organizer_id'] != current_user['id']:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only publish your own events"
            )
        
        firestore_service.update_event(
            event_id,
            {'status': EventStatus.published, 'published_at': datetime.now()}
        )
        
        return {"message": "Event published successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to publish event: {str(e)}"
        )


@router.get("/organizer/{organizer_id}/events", response_model=List[Event])
async def get_organizer_events(
    organizer_id: str = Path(...),
    limit: int = Query(50, ge=1, le=100)
):
    """
    Get all events created by a specific organizer
    """
    try:
        events = firestore_service.list_user_events(organizer_id, limit=limit)
        return events
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch organizer events: {str(e)}"
        )


@router.post("/{event_id}/upload-image")
async def upload_event_image(
    event_id: str = Path(...),
    file: UploadFile = File(...),
    authorization: Optional[str] = Header(None)
):
    """
    Upload an image for an event
    """
    current_user = await get_current_user(authorization)
    if not is_organizer(current_user):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only organizers can upload event images"
        )
    
    print(f"📸 Image upload request for event: {event_id}")
    try:
        # Verify ownership if event exists
        event = await run_in_threadpool(firestore_service.get_event, event_id)
        if event and event.get('organizer_id') != current_user['id']:
            print(f"❌ Ownership mismatch for event {event_id}")
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only upload images for your own events"
            )
        
        print(f"💾 Saving file locally for {event_id}...")
        # Upload to Local Storage (prioritized)
        unique_filename = storage_service.generate_unique_filename(file.filename)
        storage_path = f"event_images/{event_id}/{unique_filename}"
        image_url = await storage_service.save_local_file(file, storage_path)
        
        # Update event with image URL if it exists
        if event:
            event_images = event.get('images', [])
            event_images.append(image_url)
            await run_in_threadpool(
                firestore_service.update_event,
                event_id,
                {
                    'images': event_images,
                    'image_url': image_url
                }
            )
        
        return {"image_url": image_url}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to upload image: {str(e)}"
        )
