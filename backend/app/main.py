from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from .database import engine, Base
from .routers import auth_router, offres_router, candidatures_router, admin_router, profile_router
from .routers.candidatures_grades import router as candidatures_grades_router

# Create database tables
Base.metadata.create_all(bind=engine)

# Initialize FastAPI app
app = FastAPI(
    title="Université - Portail Étudiant API",
    description="API pour l'inscription universitaire avec vérification de documents par OCR",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create uploads directory
os.makedirs("uploads", exist_ok=True)
os.makedirs("uploads/profiles", exist_ok=True)

# Mount static files for uploaded documents
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Include routers
app.include_router(auth_router)
app.include_router(profile_router)
app.include_router(offres_router)
app.include_router(candidatures_router)
app.include_router(candidatures_grades_router)
app.include_router(admin_router)


@app.get("/")
async def root():
    """API root endpoint"""
    return {
        "message": "Université - Portail Étudiant API",
        "version": "2.0.0",
        "docs": "/docs",
        "endpoints": {
            "auth": "/auth",
            "profile": "/profile",
            "offres": "/offres",
            "candidatures": "/candidatures",
            "admin": "/admin"
        }
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy"}
