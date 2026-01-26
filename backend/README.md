# Festio LK - Backend (Python/FastAPI)

Backend API service for the Festio LK event management platform built with **FastAPI**.

## 🚀 Quick Start

### 1. Create Virtual Environment

```bash
cd backend
python -m venv venv
```

### 2. Activate Virtual Environment

**Windows:**
```bash
venv\Scripts\activate
```

**Linux/Mac:**
```bash
source venv/bin/activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Setup Environment Variables

Copy `.env.example` to `.env` and fill in your values:
```bash
copy .env.example .env  # Windows
cp .env.example .env    # Linux/Mac
```

### 5. Run the Server

```bash
# From backend directory
python src/main.py

# Or using uvicorn directly
uvicorn src.main:app --reload --port 8000
```

The API will be available at `http://localhost:8000`

## 📚 API Documentation

Once the server is running, visit:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🏗️ Project Structure

```
backend/
├── src/
│   └── main.py              # FastAPI app entry point
├── config/
│   └── settings.py          # Configuration & environment variables
├── models/
│   ├── user.py             # User data model
│   ├── event.py            # Event data model
│   └── booking.py          # Booking data model
├── routes/
│   ├── auth.py             # Authentication endpoints
│   ├── users.py            # User management endpoints
│   ├── events.py           # Event endpoints
│   ├── bookings.py         # Booking endpoints
│   ├── organizers.py       # Organizer endpoints
│   └── recommendations.py  # AI recommendation endpoints
├── controllers/
│   └── auth_controller.py  # Authentication business logic
├── requirements.txt         # Python dependencies
├── .env.example            # Environment variables template
└── README.md               # This file
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user
- `GET /api/auth/me` - Get current user

### Events
- `GET /api/events` - Get all events
- `GET /api/events/{event_id}` - Get event by ID
- `POST /api/events` - Create event (organizer)
- `PUT /api/events/{event_id}` - Update event (organizer)
- `DELETE /api/events/{event_id}` - Delete event (organizer)

### Bookings
- `GET /api/bookings` - Get user bookings
- `POST /api/bookings` - Create booking
- `GET /api/bookings/{booking_id}` - Get booking details
- `DELETE /api/bookings/{booking_id}` - Cancel booking

### Users
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update user profile
- `POST /api/users/preferences` - Set user preferences

### Organizers
- `GET /api/organizers/{organizer_id}` - Get organizer profile
- `PUT /api/organizers/{organizer_id}` - Update organizer profile
- `GET /api/organizers/{organizer_id}/events` - Get organizer events
- `POST /api/organizers/{organizer_id}/rate` - Rate organizer

### AI Recommendations
- `GET /api/recommendations` - Get personalized event recommendations
- `POST /api/recommendations/feedback` - Provide recommendation feedback

## 🔧 Technologies

- **FastAPI**: Modern, fast web framework
- **Uvicorn**: ASGI server
- **Pydantic**: Data validation
- **Firebase Admin SDK**: Firebase integration
- **SQLAlchemy**: SQL database ORM
- **PyMongo**: MongoDB driver
- **python-jose**: JWT token handling
- **passlib**: Password hashing

## 🧪 Testing

```bash
pytest
```

## 📝 Development

- Code formatting: `black .`
- Linting: `flake8`
- Run with auto-reload: `uvicorn src.main:app --reload`
