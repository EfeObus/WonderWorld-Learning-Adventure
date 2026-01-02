"""
WonderWorld Learning Adventure - Configuration
"""
from pydantic_settings import BaseSettings
from functools import lru_cache
from typing import Optional
import os


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Application
    app_name: str = "WonderWorld Learning Adventure"
    debug: bool = False
    api_version: str = "v1"
    api_prefix: str = "/api"
    
    # Server
    host: str = "0.0.0.0"
    port: int = 5067
    
    # Database - MUST be set via environment variable or .env file
    database_url: str = "postgresql+asyncpg://user:password@localhost:5432/wonderworld_learning"
    database_echo: bool = False
    
    # Redis
    redis_url: str = "redis://localhost:6379"
    
    # JWT Authentication - MUST be set via environment variable for production
    jwt_secret: str = "CHANGE_THIS_SECRET_IN_PRODUCTION"
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 15
    jwt_refresh_token_expire_days: int = 7
    
    # Security
    bcrypt_rounds: int = 12
    rate_limit_requests: int = 100
    rate_limit_window_seconds: int = 900  # 15 minutes
    
    # COPPA Compliance
    parental_consent_required: bool = True
    min_parent_age: int = 18
    data_retention_days: int = 365
    
    # Adaptive Learning (Rasch Model)
    target_success_rate: float = 0.75  # Zone of Proximal Development
    ability_update_rate: float = 0.1
    initial_ability_score: float = 0.0
    initial_ability_variance: float = 1.0
    
    # CORS - Allow all origins for mobile app (can't use list type with Railway env vars)
    cors_origins: str = "*"
    
    @property
    def cors_origins_list(self) -> list:
        """Parse CORS origins from string to list."""
        if self.cors_origins == "*":
            return ["*"]
        return [origin.strip() for origin in self.cors_origins.split(",")]
    
    class Config:
        env_file = "../.env"
        env_file_encoding = "utf-8"
        case_sensitive = False
        extra = "ignore"  # Ignore extra env variables


@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()


settings = get_settings()
