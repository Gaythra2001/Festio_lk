from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import uvicorn

from config.settings import settings
from routes import (
    auth, events, bookings, users, organizers, recommendations,
    research_behavior, research_features, research_models, research_evaluation
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🚀 Starting Festio LK Backend...")
    print(f"Environment: {settings.ENVIRONMENT}")
    # Initialize Firebase Admin SDK, Database connections, etc.
    yield
    # Shutdown
    print("👋 Shutting down Festio LK Backend...")


app = FastAPI(
    title="Festio LK API",
    description="Backend API for Festio LK Event Management Platform",
    version="1.0.0",
    lifespan=lifespan
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
app.include_router(research_evaluation.router)


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
