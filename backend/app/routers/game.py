"""
WonderWorld Learning Adventure - Game Router
Handles game state, achievements, streaks, and progress
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime
from typing import List

from app.database import get_db
from app.models.models import Parent, Child, GameState, PlaySession
from app.schemas.schemas import (
    GameStateResponse, GameStateUpdate, AchievementUnlock, PlaySessionResponse
)
from app.services.dependencies import get_current_parent, get_child_for_parent
from app.services.game_service import GameService

router = APIRouter()


@router.get("/{child_id}/state", response_model=GameStateResponse)
async def get_game_state(
    child_id: str,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get current game state for a child.
    
    Includes world position, stars, achievements, and streak info.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    result = await db.execute(
        select(GameState).where(GameState.child_id == child.id)
    )
    game_state = result.scalar_one_or_none()
    
    if not game_state:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Game state not found"
        )
    
    return game_state


@router.patch("/{child_id}/state", response_model=GameStateResponse)
async def update_game_state(
    child_id: str,
    data: GameStateUpdate,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Update game state (checkpoint, level, world position).
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    result = await db.execute(
        select(GameState).where(GameState.child_id == child.id)
    )
    game_state = result.scalar_one_or_none()
    
    if not game_state:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Game state not found"
        )
    
    # Update fields
    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(game_state, field, value)
    
    game_state.last_played_at = datetime.utcnow()
    
    await db.commit()
    await db.refresh(game_state)
    
    return game_state


@router.post("/{child_id}/stars")
async def add_stars(
    child_id: str,
    stars: int,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Add stars to a child's total.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    game_service = GameService(db)
    result = await game_service.add_stars(child.id, stars)
    
    return result


@router.post("/{child_id}/achievement", response_model=AchievementUnlock)
async def unlock_achievement(
    child_id: str,
    achievement_id: str,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Unlock an achievement for a child.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    game_service = GameService(db)
    achievement = await game_service.unlock_achievement(child.id, achievement_id)
    
    return achievement


@router.post("/{child_id}/session/start", response_model=PlaySessionResponse)
async def start_play_session(
    child_id: str,
    platform: str = "web",
    screen_size: str = "tablet",
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Start a new play session.
    
    Track engagement and update streak.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    game_service = GameService(db)
    session = await game_service.start_session(child.id, platform, screen_size)
    
    return session


@router.post("/{child_id}/session/{session_id}/end", response_model=PlaySessionResponse)
async def end_play_session(
    child_id: str,
    session_id: str,
    tasks_attempted: int = 0,
    tasks_completed: int = 0,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    End a play session.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    game_service = GameService(db)
    session = await game_service.end_session(
        session_id, tasks_attempted, tasks_completed
    )
    
    return session


@router.get("/{child_id}/sessions", response_model=List[PlaySessionResponse])
async def get_play_sessions(
    child_id: str,
    limit: int = 20,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get play session history.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    result = await db.execute(
        select(PlaySession)
        .where(PlaySession.child_id == child.id)
        .order_by(PlaySession.started_at.desc())
        .limit(limit)
    )
    sessions = result.scalars().all()
    
    return sessions


@router.get("/{child_id}/streak")
async def get_streak_info(
    child_id: str,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get streak information.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    result = await db.execute(
        select(GameState).where(GameState.child_id == child.id)
    )
    game_state = result.scalar_one_or_none()
    
    return {
        "current_streak_days": game_state.current_streak_days if game_state else 0,
        "longest_streak_days": game_state.longest_streak_days if game_state else 0,
        "last_played_at": game_state.last_played_at if game_state else None
    }
