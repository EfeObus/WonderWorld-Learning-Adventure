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
    
    # Database
    database_url: str = "postgresql+asyncpg://efeobukohwo:12345@localhost:5432/wonderworld_learning"
    database_echo: bool = False
    
    # Redis
    redis_url: str = "redis://localhost:6379"
    
    # JWT Authentication
    jwt_secret: str = "your-super-secret-jwt-key-change-in-production"
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
    
    # CORS
    cors_origins: list = ["http://localhost:5067", "http://localhost:8080"]
    
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
