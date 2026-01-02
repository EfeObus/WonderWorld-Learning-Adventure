"""
WonderWorld Learning Adventure - Children Router
Manages child profiles (COPPA compliant - minimal data)

NOTE: Authentication disabled - kids play directly without login.
Uses device-based identification for anonymous child profiles.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Header
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional

from app.database import get_db
from app.models.models import Child, LiteracyProgress, NumeracyProgress, SelProgress, GameState
from app.schemas.schemas import ChildCreate, ChildUpdate, ChildResponse, ChildWithProgress
from app.services.dependencies import get_or_create_anonymous_child, get_child_by_id

router = APIRouter()


@router.get("/me", response_model=ChildWithProgress)
async def get_or_create_current_child(
    child: Child = Depends(get_or_create_anonymous_child),
    db: AsyncSession = Depends(get_db)
):
    """
    Get or create an anonymous child profile for the current device.
    Uses X-Device-ID header to identify the device.
    """
    child_data = ChildWithProgress.model_validate(child)
    
    # Get game state for stars and streak
    game_result = await db.execute(
        select(GameState).where(GameState.child_id == child.id)
    )
    game_state = game_result.scalar_one_or_none()
    
    if game_state:
        child_data.stars_earned = game_state.stars_earned or 0
        child_data.current_streak_days = game_state.current_streak_days or 0
        child_data.last_played_at = game_state.last_played_at
    
    # Get literacy stage
    literacy_result = await db.execute(
        select(LiteracyProgress).where(LiteracyProgress.child_id == child.id)
    )
    literacy = literacy_result.scalar_one_or_none()
    
    if literacy:
        child_data.literacy_stage = literacy.current_stage
    
    return child_data


@router.get("/", response_model=List[ChildWithProgress])
async def get_all_children(
    db: AsyncSession = Depends(get_db)
):
    """
    Get all active children (for dashboard/admin purposes).
    """
    result = await db.execute(
        select(Child).where(Child.is_active == True)
    )
    children = result.scalars().all()
    
    # Enrich with progress data
    enriched = []
    for child in children:
        child_data = ChildWithProgress.model_validate(child)
        
        # Get game state for stars and streak
        game_result = await db.execute(
            select(GameState).where(GameState.child_id == child.id)
        )
        game_state = game_result.scalar_one_or_none()
        
        if game_state:
            child_data.stars_earned = game_state.stars_earned or 0
            child_data.current_streak_days = game_state.current_streak_days or 0
            child_data.last_played_at = game_state.last_played_at
        
        # Get literacy stage
        literacy_result = await db.execute(
            select(LiteracyProgress).where(LiteracyProgress.child_id == child.id)
        )
        literacy = literacy_result.scalar_one_or_none()
        
        if literacy:
            child_data.literacy_stage = literacy.current_stage
        
        enriched.append(child_data)
    
    return enriched


@router.post("/", response_model=ChildResponse, status_code=status.HTTP_201_CREATED)
async def create_child(
    data: ChildCreate,
    device_id: Optional[str] = Header(None, alias="X-Device-ID"),
    db: AsyncSession = Depends(get_db)
):
    """
    Create a new child profile.
    
    No authentication required - creates anonymous child profile.
    """
    # Create child
    child = Child(
        display_name=data.display_name,
        avatar_id=data.avatar_id if hasattr(data, 'avatar_id') else "avatar_star",
        birth_year=data.birth_year if hasattr(data, 'birth_year') else None,
        age_group=data.age_group if hasattr(data, 'age_group') else "3-5",
        preferred_language=data.preferred_language if hasattr(data, 'preferred_language') else "en",
        sound_enabled=data.sound_enabled if hasattr(data, 'sound_enabled') else True,
        device_id=device_id,
        is_anonymous=True
    )
    
    db.add(child)
    await db.flush()
    
    # Initialize progress records
    literacy = LiteracyProgress(child_id=child.id)
    numeracy = NumeracyProgress(child_id=child.id)
    sel = SelProgress(child_id=child.id)
    game_state = GameState(child_id=child.id, stars_earned=0)
    
    db.add_all([literacy, numeracy, sel, game_state])
    await db.commit()
    await db.refresh(child)
    
    return child


@router.get("/{child_id}", response_model=ChildWithProgress)
async def get_child(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Get a specific child's profile.
    """
    child = await get_child_by_id(child_id, db)
    
    child_data = ChildWithProgress.model_validate(child)
    
    # Get game state
    game_result = await db.execute(
        select(GameState).where(GameState.child_id == child.id)
    )
    game_state = game_result.scalar_one_or_none()
    
    if game_state:
        child_data.stars_earned = game_state.stars_earned or 0
        child_data.current_streak_days = game_state.current_streak_days or 0
        child_data.last_played_at = game_state.last_played_at
    
    return child_data


@router.patch("/{child_id}", response_model=ChildResponse)
async def update_child(
    child_id: str,
    data: ChildUpdate,
    db: AsyncSession = Depends(get_db)
):
    """
    Update a child's profile.
    """
    child = await get_child_by_id(child_id, db)
    
    # Update fields
    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(child, field, value)
    
    await db.commit()
    await db.refresh(child)
    
    return child


@router.delete("/{child_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_child(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Soft delete a child profile.
    """
    child = await get_child_by_id(child_id, db)
    
    child.is_active = False
    await db.commit()
