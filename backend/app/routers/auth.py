"""
WonderWorld Learning Adventure - Authentication Router
Handles parent registration, login, and consent verification
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timedelta
import uuid

from app.database import get_db
from app.models.models import Parent, RefreshToken
from app.schemas.schemas import (
    ParentRegister, ParentLogin, TokenResponse, 
    ParentResponse, RefreshTokenRequest, ConsentVerification
)
from app.services.auth_service import AuthService
from app.services.dependencies import get_current_parent

router = APIRouter()


@router.post("/register", response_model=ParentResponse, status_code=status.HTTP_201_CREATED)
async def register_parent(
    data: ParentRegister,
    db: AsyncSession = Depends(get_db)
):
    """
    Register a new parent account.
    
    COPPA compliance requires parental consent before any child data is collected.
    """
    auth_service = AuthService(db)
    
    # Check if email already exists
    existing = await db.execute(
        select(Parent).where(Parent.email == data.email)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create parent account
    parent = await auth_service.create_parent(data)
    return parent


@router.post("/login", response_model=TokenResponse)
async def login(
    data: ParentLogin,
    db: AsyncSession = Depends(get_db)
):
    """
    Authenticate parent and return JWT tokens.
    
    Returns:
    - access_token: Short-lived token (15 minutes)
    - refresh_token: Long-lived token (7 days)
    """
    auth_service = AuthService(db)
    
    # Authenticate
    parent = await auth_service.authenticate(data.email, data.password)
    if not parent:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Generate tokens
    tokens = await auth_service.create_tokens(parent)
    
    # Update last login
    parent.last_login_at = datetime.utcnow()
    await db.commit()
    
    return tokens


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    data: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Refresh access token using a valid refresh token.
    """
    auth_service = AuthService(db)
    
    tokens = await auth_service.refresh_tokens(data.refresh_token)
    if not tokens:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired refresh token"
        )
    
    return tokens


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    data: RefreshTokenRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Logout by revoking the refresh token.
    """
    auth_service = AuthService(db)
    await auth_service.revoke_token(data.refresh_token)


@router.get("/me", response_model=ParentResponse)
async def get_current_user(
    current_parent: Parent = Depends(get_current_parent)
):
    """
    Get current authenticated parent's profile.
    """
    return current_parent


@router.post("/verify-consent", response_model=ParentResponse)
async def verify_parental_consent(
    consent: ConsentVerification,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Verify parental consent (COPPA requirement).
    
    Methods:
    - email: Verification code sent to parent's email
    - credit_card: Minimal charge for identity verification
    """
    auth_service = AuthService(db)
    
    verified = await auth_service.verify_consent(current_parent, consent)
    if not verified:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Consent verification failed"
        )
    
    return current_parent
