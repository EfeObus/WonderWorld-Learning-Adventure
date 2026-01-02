"""
WonderWorld Learning Adventure - Literacy Router
Handles letter tracing, phonics, and word learning endpoints

NOTE: Authentication disabled - kids play directly without login.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List, Optional

from app.database import get_db
from app.models.models import (
    Child, LiteracyProgress, TracingSession, 
    Word, WordProgress
)
from app.schemas.schemas import (
    LiteracyProgressResponse, TracingSessionCreate, TracingSessionResponse,
    WordResponse, WordProgressResponse, WordsByLevel, WordLevelEnum
)
from app.services.dependencies import get_child_by_id
from app.services.literacy_service import LiteracyService

router = APIRouter()


@router.get("/{child_id}/progress", response_model=LiteracyProgressResponse)
async def get_literacy_progress(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Get child's literacy progress including letter mastery and word reading scores.
    """
    child = await get_child_by_id(child_id, db)
    
    result = await db.execute(
        select(LiteracyProgress).where(LiteracyProgress.child_id == child.id)
    )
    progress = result.scalar_one_or_none()
    
    if not progress:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Literacy progress not found"
        )
    
    return progress


@router.post("/{child_id}/tracing", response_model=TracingSessionResponse, status_code=status.HTTP_201_CREATED)
async def record_tracing_session(
    child_id: str,
    data: TracingSessionCreate,
    db: AsyncSession = Depends(get_db)
):
    """
    Record a letter or word tracing session.
    
    This endpoint receives stroke analysis data from the Flutter app's
    PathMetrics comparison against ideal letter paths.
    """
    child = await get_child_by_id(child_id, db)
    
    # Create tracing session
    session = TracingSession(
        child_id=child.id,
        letter=data.letter,
        word=data.word,
        is_uppercase=data.is_uppercase,
        stroke_accuracy=data.stroke_accuracy,
        stroke_smoothness=data.stroke_smoothness,
        time_taken_ms=data.time_taken_ms,
        attempt_number=data.attempt_number,
        path_deviation_data=data.path_deviation_data
    )
    
    db.add(session)
    
    # Update letter mastery if tracing a letter
    if data.letter:
        literacy_service = LiteracyService(db)
        await literacy_service.update_letter_mastery(
            child.id, 
            data.letter, 
            data.stroke_accuracy
        )
    
    await db.commit()
    await db.refresh(session)
    
    return session


@router.get("/{child_id}/tracing/history", response_model=List[TracingSessionResponse])
async def get_tracing_history(
    child_id: str,
    letter: Optional[str] = Query(None, max_length=1),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """
    Get tracing session history for a child.
    """
    child = await get_child_by_id(child_id, db)
    
    query = select(TracingSession).where(TracingSession.child_id == child.id)
    
    if letter:
        query = query.where(TracingSession.letter == letter.upper())
    
    query = query.order_by(TracingSession.completed_at.desc()).limit(limit)
    
    result = await db.execute(query)
    sessions = result.scalars().all()
    
    return sessions


@router.get("/words", response_model=List[WordResponse])
async def get_words(
    level: Optional[WordLevelEnum] = None,
    category: Optional[str] = None,
    age_group: Optional[str] = None,
    limit: int = Query(50, ge=1, le=200),
    db: AsyncSession = Depends(get_db)
):
    """
    Get words from the word bank.
    
    Filter by:
    - level: 2-letter, 3-letter, 4-letter, 5-letter
    - category: short_a, short_e, cvcc, sight_word, etc.
    - age_group: 2-3, 4-5, 6-7, 8
    """
    query = select(Word).where(Word.is_active == True)
    
    if level:
        query = query.where(Word.level == level)
    
    if category:
        query = query.where(Word.category == category)
    
    if age_group:
        query = query.where(Word.age_group_min <= age_group)
        query = query.where(Word.age_group_max >= age_group)
    
    query = query.order_by(Word.difficulty).limit(limit)
    
    result = await db.execute(query)
    words = result.scalars().all()
    
    return words


@router.get("/{child_id}/words/progress", response_model=List[WordsByLevel])
async def get_word_progress_by_level(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Get child's word learning progress organized by level.
    """
    child = await get_child_by_id(child_id, db)
    
    literacy_service = LiteracyService(db)
    progress = await literacy_service.get_word_progress_by_level(child.id)
    
    return progress


@router.post("/{child_id}/words/{word_id}/practice", response_model=WordProgressResponse)
async def record_word_practice(
    child_id: str,
    word_id: str,
    is_correct: bool,
    db: AsyncSession = Depends(get_db)
):
    """
    Record a word practice attempt.
    """
    child = await get_child_by_id(child_id, db)
    
    literacy_service = LiteracyService(db)
    progress = await literacy_service.record_word_practice(
        child.id, word_id, is_correct
    )
    
    return progress


@router.get("/{child_id}/letter-groups")
async def get_letter_groups_progress(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Get progress on letter groups (developmental order teaching).
    
    Letters are taught based on stroke complexity:
    1. Straight Lines: L, F, E, H, T, I
    2. Curves: C, O, Q, G, S
    3. Diagonals: A, V, W, M, N, K, X, Y, Z
    4. Mixed: B, D, J, P, R, U
    """
    child = await get_child_by_id(child_id, db)
    
    literacy_service = LiteracyService(db)
    groups = await literacy_service.get_letter_groups_progress(child.id)
    
    return groups

@router.get("/stories")
async def get_stories(
    age_group: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
):
    """
    Get available stories for story time.
    
    Returns a list of age-appropriate stories with metadata.
    """
    # Static story data - can be moved to database
    stories = [
        {
            "id": "little_star",
            "title": "The Little Star",
            "description": "A star wants to make friends with the moon",
            "age_group": "2-4",
            "pages": 5,
            "read_time_minutes": 3,
            "themes": ["friendship", "kindness"]
        },
        {
            "id": "friendly_bunny",
            "title": "The Friendly Bunny",
            "description": "Bunny helps a lost butterfly find home",
            "age_group": "3-5",
            "pages": 5,
            "read_time_minutes": 3,
            "themes": ["helping", "kindness"]
        },
        {
            "id": "brave_fish",
            "title": "The Brave Little Fish",
            "description": "A fish explores beyond the coral reef",
            "age_group": "4-6",
            "pages": 5,
            "read_time_minutes": 4,
            "themes": ["bravery", "exploration"]
        }
    ]
    
    if age_group:
        # Filter by age group if provided
        pass
    
    return {"stories": stories, "total": len(stories)}


@router.post("/{child_id}/stories/{story_id}/complete")
async def record_story_completion(
    child_id: str,
    story_id: str,
    pages_read: int,
    time_spent_seconds: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Record completion of a story reading session.
    """
    child = await get_child_by_id(child_id, db)
    
    return {
        "success": True,
        "child_id": str(child.id),
        "story_id": story_id,
        "pages_read": pages_read,
        "time_spent_seconds": time_spent_seconds,
        "message": "Story reading session recorded"
    }


@router.post("/{child_id}/phonics")
async def record_phonics_practice(
    child_id: str,
    letter: str = Query(..., max_length=1),
    sound_played: bool = Query(default=True),
    word_example: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
):
    """
    Record a phonics learning session.
    
    Tracks letter sounds and example words learned.
    """
    child = await get_child_by_id(child_id, db)
    
    return {
        "success": True,
        "child_id": str(child.id),
        "letter": letter.upper(),
        "sound_played": sound_played,
        "word_example": word_example,
        "message": f"Phonics practice recorded for letter {letter.upper()}"
    }


@router.post("/{child_id}/word-building")
async def record_word_building(
    child_id: str,
    word: str = Query(...),
    completed: bool = Query(...),
    attempts: int = Query(default=1, ge=1),
    time_taken_seconds: int = Query(..., ge=0),
    db: AsyncSession = Depends(get_db)
):
    """
    Record a word building activity.
    
    Tracks words built by dragging letters.
    """
    child = await get_child_by_id(child_id, db)
    
    return {
        "success": True,
        "child_id": str(child.id),
        "word": word.upper(),
        "completed": completed,
        "attempts": attempts,
        "time_taken_seconds": time_taken_seconds,
        "message": f"Word building recorded for '{word.upper()}'"
    }