"""
WonderWorld Learning Adventure - FastAPI Application
Main entry point for the educational platform API
Kids game - no login required!
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging

from app.config import settings
from app.database import init_db, close_db
from app.routers import children, literacy, numeracy, tasks, game, parent_dashboard, sel

# Configure logging
logging.basicConfig(
    level=logging.DEBUG if settings.debug else logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage application lifecycle."""
    # Startup
    logger.info("Starting WonderWorld Learning Adventure API...")
    await init_db()
    logger.info("Database initialized successfully")
    yield
    # Shutdown
    logger.info("Shutting down...")
    await close_db()
    logger.info("Database connections closed")


# Create FastAPI application
app = FastAPI(
    title=settings.app_name,
    description="""
    **WonderWorld Learning Adventure API**
    
    A comprehensive educational platform for children ages 2-8, featuring:
    
    - 📚 **Literacy Engine**: Letter tracing, phonics, word learning
    - 🔢 **Numeracy Engine**: Counting, operations, visual math
    - 💝 **SEL**: Social-emotional learning activities
    - 🎮 **Gamification**: Stars, achievements, streaks
    - 👨‍👩‍👧 **Parent Dashboard**: Real-time progress tracking
    
    Built with adaptive learning (Rasch Model) for personalized education.
    
    COPPA & GDPR-K Compliant.
    """,
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# CORS middleware - allow all origins for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Include routers - No auth needed, kids play directly!
app.include_router(
    children.router,
    prefix=f"{settings.api_prefix}/children",
    tags=["Children"]
)

app.include_router(
    literacy.router,
    prefix=f"{settings.api_prefix}/literacy",
    tags=["Literacy"]
)

app.include_router(
    numeracy.router,
    prefix=f"{settings.api_prefix}/numeracy",
    tags=["Numeracy"]
)

app.include_router(
    tasks.router,
    prefix=f"{settings.api_prefix}/tasks",
    tags=["Adaptive Tasks"]
)

app.include_router(
    game.router,
    prefix=f"{settings.api_prefix}/game",
    tags=["Game & Progress"]
)

app.include_router(
    parent_dashboard.router,
    prefix=f"{settings.api_prefix}/dashboard",
    tags=["Parent Dashboard"]
)

app.include_router(
    sel.router,
    prefix=f"{settings.api_prefix}/sel",
    tags=["Social-Emotional Learning"]
)


# Root endpoint
@app.get("/", tags=["Root"])
async def root():
    """Welcome endpoint."""
    return {
        "message": "Welcome to WonderWorld Learning Adventure API!",
        "version": "1.0.0",
        "docs": "/docs",
        "status": "running"
    }


# Health check
@app.get("/health", tags=["Health"])
async def health_check():
    """Health check endpoint."""
    return {
        "status": "healthy",
        "service": settings.app_name,
        "version": "1.0.0"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug
    )
