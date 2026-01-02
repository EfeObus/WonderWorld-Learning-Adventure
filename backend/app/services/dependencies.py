"""
WonderWorld Learning Adventure - Dependencies
Common dependencies for route handlers

NOTE: Authentication is disabled for this kids app.
All endpoints are public. Progress is tracked by child_id (device-based).
"""
from fastapi import Depends, HTTPException, status, Header
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Optional

from app.database import get_db
from app.models.models import Parent, Child

# Security scheme (optional - kept for parent dashboard if needed later)
security = HTTPBearer(auto_error=False)


async def get_current_parent_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> Optional[Parent]:
    """
    Optionally validate JWT token and return current parent.
    Returns None if no token provided (anonymous access for kids).
    """
    if credentials is None:
        return None
    
    # For now, return None - auth is disabled
    return None


async def get_child_by_id(
    child_id: str,
    db: AsyncSession
) -> Child:
    """
    Get a child by ID (no parent verification - anonymous access).
    Creates a new child record if not found.
    """
    result = await db.execute(
        select(Child).where(
            Child.id == child_id,
            Child.is_active == True
        )
    )
    child = result.scalar_one_or_none()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child profile not found"
        )
    
    return child


async def get_or_create_anonymous_child(
    device_id: str = Header(None, alias="X-Device-ID"),
    db: AsyncSession = Depends(get_db)
) -> Child:
    """
    Get or create an anonymous child profile based on device ID.
    Used for device-based progress tracking without login.
    """
    if not device_id:
        device_id = "default-device"
    
    # Check if child exists for this device
    result = await db.execute(
        select(Child).where(
            Child.device_id == device_id,
            Child.is_active == True
        )
    )
    child = result.scalar_one_or_none()
    
    if child:
        return child
    
    # Create new anonymous child profile
    from app.models.models import LiteracyProgress, NumeracyProgress, SelProgress, GameState
    
    child = Child(
        display_name="Little Learner",
        avatar_id="avatar_star",
        age_group="3-5",
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


# Legacy function for compatibility - now just gets child by ID without parent check
async def get_child_for_parent(
    child_id: str,
    parent_id: str,
    db: AsyncSession
) -> Child:
    """
    Legacy compatibility function.
    Now just gets child by ID (auth disabled).
    """
    return await get_child_by_id(child_id, db)
