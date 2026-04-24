from fastapi import FastAPI, Request
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
    auth, events, bookings, users, organizers, recommendations, trust,
    research_behavior, research_features, research_models,
    revenue_optimization
    # Temporarily disabled missing routes:
    # promotion_ma_epom, trust_and_budget, organizer_ml_routes, organizer_chatbot_routes, analytics
    # research_evaluation  # Temporarily disabled due to file corruption
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🚀 Starting Festio LK Backend...")
    print(f"Environment: {settings.ENVIRONMENT}")
    
    # Check if using Firebase Emulator
    use_emulator = os.getenv("USE_FIREBASE_EMULATOR", "").lower() == "true"
    if use_emulator:
        print("🔥 Using Firebase Emulators (local development mode)")
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
        print("✅ Firestore initialized successfully")
    else:
        print("⚠️  Firestore not available - running in compatibility mode")
    
    if storage_initialized:
        app.state.storage = storage_service
        print("✅ Firebase Storage initialized successfully")
    else:
        print("⚠️  Firebase Storage not available - file uploads disabled")
    
    print("✅ All services initialized")
    yield
    # Shutdown
    print("👋 Shutting down Festio LK Backend...")


app = FastAPI(
    title="Festio LK API",
    description="Backend API for Festio LK Event Management Platform",
    version="1.0.0",
    lifespan=lifespan
)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    print(f"Incoming request: {request.method} {request.url}")
    try:
        response = await call_next(request)
        print(f"Response status: {response.status_code}")
        return response
    except Exception as e:
        print(f"Request failed with error: {str(e)}")
        raise e

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(users.router, prefix="/api/users", tags=["Users"])
app.include_router(events.router, prefix="/api/events", tags=["Events"])
app.include_router(bookings.router, prefix="/api/bookings", tags=["Bookings"])
app.include_router(organizers.router, prefix="/api/organizers", tags=["Organizers"])
app.include_router(recommendations.router, prefix="/api/recommendations", tags=["AI Recommendations"])
app.include_router(trust.router, tags=["Trust Assessment"])

# Research routers
app.include_router(research_behavior.router)
app.include_router(research_features.router)
app.include_router(research_models.router)
# app.include_router(research_evaluation.router)  # Temporarily disabled

# Temporarily disabled missing routers:
# app.include_router(promotion_ma_epom.router)
# app.include_router(trust_and_budget.router)
# app.include_router(organizer_ml_routes.router)
# app.include_router(organizer_chatbot_routes.router)

# Revenue Optimization (Using Firestore) - DISABLED in favor of new AI Revenue Optimization
# app.include_router(revenue_optimization.router)

# Temporarily disabled missing router:
# from revenue_optimizer_api import router as revenue_api
# app.include_router(revenue_api)

# Temporarily disabled missing router:
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
