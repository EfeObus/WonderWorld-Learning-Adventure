"""
WonderWorld Learning Adventure - Dependencies
Common dependencies for route handlers
"""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from jose import jwt, JWTError
from datetime import datetime

from app.database import get_db
from app.config import settings
from app.models.models import Parent, Child

# Security scheme
security = HTTPBearer()


async def get_current_parent(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> Parent:
    """
    Validate JWT token and return current parent.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        token = credentials.credentials
        payload = jwt.decode(
            token, 
            settings.jwt_secret, 
            algorithms=[settings.jwt_algorithm]
        )
        
        parent_id: str = payload.get("sub")
        token_type: str = payload.get("type")
        
        if parent_id is None or token_type != "access":
            raise credentials_exception
            
    except JWTError:
        raise credentials_exception
    
    # Get parent from database
    result = await db.execute(
        select(Parent).where(Parent.id == parent_id)
    )
    parent = result.scalar_one_or_none()
    
    if parent is None:
        raise credentials_exception
    
    if not parent.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is deactivated"
        )
    
    return parent


async def get_child_for_parent(
    child_id: str,
    parent_id: str,
    db: AsyncSession
) -> Child:
    """
    Get a child that belongs to a specific parent.
    """
    result = await db.execute(
        select(Child).where(
            Child.id == child_id,
            Child.parent_id == parent_id,
            Child.is_active == True
        )
    )
    child = result.scalar_one_or_none()
    
    if not child:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Child not found"
        )
    
    return child
