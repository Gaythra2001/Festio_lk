from fastapi import FastAPI, Request
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import uvicorn
import sys
import os
from pathlib import Path

# Add backend directory to Python path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

from config.settings import settings
# from db.database import init_db
from services.firestore_service import get_firestore_service
from services.storage_service import get_storage_service
from routes import (
    auth, events, bookings, users, organizers, recommendations,
    research_behavior, research_features, research_models,
    trust_and_budget, revenue_optimization
    # research_evaluation  # Temporarily disabled due to file corruption
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("[START] Starting Festio LK Backend...")
    print(f"Environment: {settings.ENVIRONMENT}")
    
    # Check if using Firebase Emulator
    use_emulator = os.getenv("USE_FIREBASE_EMULATOR", "").lower() == "true"
    if use_emulator:
        print("[DEV] Using Firebase Emulators (local development mode)")
        os.environ["FIRESTORE_EMULATOR_HOST"] = "127.0.0.1:8080"
        os.environ["FIREBASE_AUTH_EMULATOR_HOST"] = "127.0.0.1:9099"
        os.environ["FIREBASE_STORAGE_EMULATOR_HOST"] = "127.0.0.1:9199"
    
    # Initialize database (PostgreSQL/SQLite fallback) - DISABLED for Firebase-only migration
    # print("Initializing database...")
    # init_db()
    
    # Initialize Firebase Admin SDK
    print("Initializing Firebase services...")
    firestore_service = get_firestore_service()
    storage_service = get_storage_service()
    
    firebase_initialized = firestore_service.initialize()
    storage_initialized = storage_service.initialize()
    
    if firebase_initialized:
        app.state.firestore = firestore_service
        print("[OK] Firestore initialized successfully")
    else:
        print("[WARN] Firestore not available - running in compatibility mode")
    
    if storage_initialized:
        app.state.storage = storage_service
        print("[OK] Firebase Storage initialized successfully")
    else:
        print("[WARN] Firebase Storage not available - file uploads disabled")
    
    print("[OK] All services initialized")
    yield
    # Shutdown
    print("[STOP] Shutting down Festio LK Backend...")


app = FastAPI(
    title="Festio LK API",
    description="Backend API for Festio LK Event Management Platform",
    version="1.0.0",
    lifespan=lifespan
)

@app.middleware("http")
async def add_cors_headers(request: Request, call_next):
    print(f"Incoming {request.method} request to {request.url}")
    try:
        response = await call_next(request)
        # Ensure consistent CORS headers for all responses
        response.headers["Access-Control-Allow-Origin"] = "*"
        response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS, PATCH"
        response.headers["Access-Control-Allow-Headers"] = "*"
        response.headers["Access-Control-Expose-Headers"] = "Content-Length, Content-Range"
        return response
    except Exception as e:
        print(f"❗ Request processing error: {str(e)}")
        # Even on error, try to provide a response with CORS headers if possible
        # but here we just re-raise and let FastAPI handle the 500
        raise e

# CORS Configuration - Keep this as a secondary layer
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static Files
uploads_path = Path(settings.uploads_dir)
uploads_path.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(uploads_path)), name="uploads")

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(users.router, prefix="/api/users", tags=["Users"])
app.include_router(events.router, prefix="/api/events", tags=["Events"])
app.include_router(bookings.router, prefix="/api/bookings", tags=["Bookings"])
app.include_router(organizers.router, prefix="/api/organizers", tags=["Organizers"])
app.include_router(recommendations.router, prefix="/api/recommendations", tags=["AI Recommendations"])

# Research routers
app.include_router(research_behavior.router)
app.include_router(research_features.router)
app.include_router(research_models.router)
# app.include_router(research_evaluation.router)  # Temporarily disabled

# Multilingual Promotion routers
# app.include_router(promotion_ma_epom.router)

# Trust Assessment & Budget Planning routers
app.include_router(trust_and_budget.router)

# Organizer ML routers
# app.include_router(organizer_ml_routes.router)

# Organizer Chatbot routers
# app.include_router(organizer_chatbot_routes.router)

# Revenue Optimization (Using Firestore) - keep the AI revenue optimization routes active
app.include_router(revenue_optimization.router)

# New AI Revenue Optimization (As requested)
# from revenue_optimizer_api import router as revenue_api
# app.include_router(revenue_api)

# Analytics routers
# app.include_router(analytics.router)


@app.get("/")
async def root():
    return {
        "message": "Festio LK API",
        "version": "1.0.0",
        "status": "running"
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=settings.PORT,
        reload=settings.ENVIRONMENT == "development"
    )
