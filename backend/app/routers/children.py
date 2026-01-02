"""
WonderWorld Learning Adventure - Children Router
Manages child profiles (COPPA compliant - minimal data)
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.database import get_db
from app.models.models import Parent, Child, LiteracyProgress, NumeracyProgress, SelProgress, GameState
from app.schemas.schemas import ChildCreate, ChildUpdate, ChildResponse, ChildWithProgress
from app.services.dependencies import get_current_parent

router = APIRouter()


@router.get("/", response_model=List[ChildWithProgress])
async def get_children(
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get all children for the authenticated parent.
    """
    result = await db.execute(
        select(Child).where(
            Child.parent_id == current_parent.id,
            Child.is_active == True
        )
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
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Create a new child profile.
    
    Requires verified parental consent (COPPA).
    Only minimal data is stored - no full names, photos, or precise DOB.
    """
    # Check consent status
    if current_parent.consent_status != "verified":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Parental consent required before creating child profiles"
        )
    
    # Create child
    child = Child(
        parent_id=current_parent.id,
        display_name=data.display_name,
        avatar_id=data.avatar_id,
        birth_year=data.birth_year,
        age_group=data.age_group,
        preferred_language=data.preferred_language,
        sound_enabled=data.sound_enabled
    )
    
    db.add(child)
    await db.flush()
    
    # Initialize progress records
    literacy = LiteracyProgress(child_id=child.id)
    numeracy = NumeracyProgress(child_id=child.id)
    sel = SelProgress(child_id=child.id)
    game_state = GameState(child_id=child.id)
    
    db.add_all([literacy, numeracy, sel, game_state])
    await db.commit()
    await db.refresh(child)
    
    return child


@router.get("/{child_id}", response_model=ChildWithProgress)
async def get_child(
    child_id: str,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get a specific child's profile.
    """
    result = await db.execute(
        select(Child).where(
            Child.id == child_id,
            Child.parent_id == current_parent.id,
            Child.is_active == True
        )
    )
    child = result.scalar_one_or_none()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
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
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Update a child's profile.
    """
    result = await db.execute(
        select(Child).where(
            Child.id == child_id,
            Child.parent_id == current_parent.id
        )
    )
    child = result.scalar_one_or_none()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
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
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Soft delete a child profile.
    
    Data is retained for the legally required period (GDPR) but marked inactive.
    For full deletion, use the data deletion request endpoint.
    """
    result = await db.execute(
        select(Child).where(
            Child.id == child_id,
            Child.parent_id == current_parent.id
        )
    )
    child = result.scalar_one_or_none()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
    child.is_active = False
    await db.commit()
