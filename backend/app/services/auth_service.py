"""
WonderWorld Learning Adventure - Authentication Service
Handles registration, login, JWT tokens, and consent verification
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from passlib.context import CryptContext
from jose import jwt
from datetime import datetime, timedelta
from typing import Optional
import uuid

from app.config import settings
from app.models.models import Parent, RefreshToken
from app.schemas.schemas import (
    ParentRegister, TokenResponse, ConsentVerification
)

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class AuthService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    def hash_password(self, password: str) -> str:
        """Hash a password using bcrypt."""
        return pwd_context.hash(password, rounds=settings.bcrypt_rounds)
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """Verify a password against its hash."""
        return pwd_context.verify(plain_password, hashed_password)
    
    async def create_parent(self, data: ParentRegister) -> Parent:
        """Create a new parent account."""
        parent = Parent(
            email=data.email,
            password_hash=self.hash_password(data.password),
            first_name=data.first_name,
            data_processing_agreed=data.data_processing_agreed
        )
        
        self.db.add(parent)
        await self.db.commit()
        await self.db.refresh(parent)
        
        return parent
    
    async def authenticate(self, email: str, password: str) -> Optional[Parent]:
        """Authenticate a parent by email and password."""
        result = await self.db.execute(
            select(Parent).where(Parent.email == email)
        )
        parent = result.scalar_one_or_none()
        
        if not parent:
            return None
        
        if not self.verify_password(password, parent.password_hash):
            return None
        
        if not parent.is_active:
            return None
        
        return parent
    
    def create_access_token(self, parent_id: str) -> str:
        """Create a short-lived access token."""
        expire = datetime.utcnow() + timedelta(
            minutes=settings.jwt_access_token_expire_minutes
        )
        
        payload = {
            "sub": parent_id,
            "type": "access",
            "exp": expire,
            "iat": datetime.utcnow()
        }
        
        return jwt.encode(
            payload, 
            settings.jwt_secret, 
            algorithm=settings.jwt_algorithm
        )
    
    async def create_refresh_token(self, parent_id: str) -> str:
        """Create a long-lived refresh token and store it."""
        expire = datetime.utcnow() + timedelta(
            days=settings.jwt_refresh_token_expire_days
        )
        
        payload = {
            "sub": parent_id,
            "type": "refresh",
            "exp": expire,
            "iat": datetime.utcnow(),
            "jti": str(uuid.uuid4())
        }
        
        token = jwt.encode(
            payload, 
            settings.jwt_secret, 
            algorithm=settings.jwt_algorithm
        )
        
        # Store refresh token in database
        refresh_token = RefreshToken(
            parent_id=parent_id,
            token=token,
            expires_at=expire
        )
        
        self.db.add(refresh_token)
        await self.db.commit()
        
        return token
    
    async def create_tokens(self, parent: Parent) -> TokenResponse:
        """Create both access and refresh tokens."""
        access_token = self.create_access_token(parent.id)
        refresh_token = await self.create_refresh_token(parent.id)
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.jwt_access_token_expire_minutes * 60
        )
    
    async def refresh_tokens(self, refresh_token: str) -> Optional[TokenResponse]:
        """Validate refresh token and issue new tokens."""
        try:
            payload = jwt.decode(
                refresh_token, 
                settings.jwt_secret, 
                algorithms=[settings.jwt_algorithm]
            )
            
            if payload.get("type") != "refresh":
                return None
            
            parent_id = payload.get("sub")
            
        except Exception:
            return None
        
        # Check if token exists and is not revoked
        result = await self.db.execute(
            select(RefreshToken).where(
                RefreshToken.token == refresh_token,
                RefreshToken.is_revoked == False
            )
        )
        stored_token = result.scalar_one_or_none()
        
        if not stored_token or stored_token.expires_at < datetime.utcnow():
            return None
        
        # Revoke old token
        stored_token.is_revoked = True
        
        # Get parent
        result = await self.db.execute(
            select(Parent).where(Parent.id == parent_id)
        )
        parent = result.scalar_one_or_none()
        
        if not parent or not parent.is_active:
            return None
        
        # Create new tokens
        tokens = await self.create_tokens(parent)
        
        await self.db.commit()
        
        return tokens
    
    async def revoke_token(self, refresh_token: str) -> bool:
        """Revoke a refresh token (logout)."""
        result = await self.db.execute(
            select(RefreshToken).where(RefreshToken.token == refresh_token)
        )
        stored_token = result.scalar_one_or_none()
        
        if stored_token:
            stored_token.is_revoked = True
            await self.db.commit()
            return True
        
        return False
    
    async def verify_consent(
        self, 
        parent: Parent, 
        consent: ConsentVerification
    ) -> bool:
        """
        Verify parental consent (COPPA requirement).
        
        In production, this would:
        - For email: Send verification email and validate code
        - For credit_card: Process minimal charge via payment processor
        """
        # Simplified verification for demo
        # In production, implement proper verification
        
        if consent.method == "email":
            # Would send email verification
            # For demo, accept any verification code
            if consent.verification_code:
                parent.consent_status = "verified"
                parent.consent_verified_at = datetime.utcnow()
                parent.consent_method = "email"
                await self.db.commit()
                return True
        
        elif consent.method == "credit_card":
            # Would process payment verification
            parent.consent_status = "verified"
            parent.consent_verified_at = datetime.utcnow()
            parent.consent_method = "credit_card"
            await self.db.commit()
            return True
        
        return False
