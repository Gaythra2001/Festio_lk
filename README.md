# Festio LK - Project Root

A comprehensive event management platform for Sri Lanka.

## Project Structure

```
festio_lk/
├── frontend/      # Flutter mobile/web application
├── backend/       # Backend API services
└── README.md      # This file
```

## Frontend

The frontend is built with Flutter and supports:
- Mobile (Android/iOS)
- Web
- Windows desktop

See [frontend/README.md](frontend/README.md) for more details.

## Backend

The backend provides REST API services for:
- User authentication
- Event management
- Booking system
- AI recommendations
- Organizer trust system
- Organizer AI chatbot
- Revenue optimization engine
- Analytics storage (PostgreSQL)

See [backend/README.md](backend/README.md) for more details.

## Getting Started

1. **Frontend Setup**:
   ```bash
   cd frontend
   flutter pub get
   flutter run
   ```

2. **Backend Setup**:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

3. **Configure PostgreSQL (Analytics Storage)**:
   - Update `backend/.env` with a valid PostgreSQL URL:
     ```
     DATABASE_URL=postgresql://user:password@localhost:5432/festio_lk
     ```
   - Ensure the `festio_lk` database exists.

4. **Run Backend (local)**:
   ```bash
   # From project root
   .\.venv312\Scripts\uvicorn.exe backend.src.main:app --host 127.0.0.1 --port 8000 --reload
   ```

5. **Run Frontend (web)**:
   ```bash
   cd frontend
   flutter run -d chrome
   ```

## Development Workflow

- Frontend development: Work in the `frontend/` directory
- Backend development: Work in the `backend/` directory
- Keep both services running during development for full functionality

## Key APIs

- Revenue Optimization: `POST /api/revenue-optimization/optimize`
- Analytics (store): `POST /api/analytics/events`
- Analytics (summary): `GET /api/analytics/summary`
- Organizer Chatbot: `POST /api/organizer-chatbot/send-message`

## Documentation

All project documentation is located in the `frontend/` directory:
- Firebase setup guides
- Architecture documentation
- Feature implementation guides
- Testing guides
