"""
WonderWorld Learning Adventure - Pydantic Schemas
"""
from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional, List, Dict, Any
from datetime import datetime
from enum import Enum


# Enums for API
class AgeGroupEnum(str, Enum):
    AGE_2_3 = "2-3"
    AGE_4_5 = "4-5"
    AGE_6_7 = "6-7"
    AGE_8 = "8"


class LearningModuleEnum(str, Enum):
    LITERACY = "literacy"
    NUMERACY = "numeracy"
    SEL = "sel"


class SkillLevelEnum(str, Enum):
    BEGINNER = "beginner"
    DEVELOPING = "developing"
    PROFICIENT = "proficient"
    ADVANCED = "advanced"


class WordLevelEnum(str, Enum):
    TWO_LETTER = "2-letter"
    THREE_LETTER = "3-letter"
    FOUR_LETTER = "4-letter"
    FIVE_LETTER = "5-letter"


class ErrorTypeEnum(str, Enum):
    FACTUAL = "factual"
    PROCEDURAL = "procedural"
    CONCEPTUAL = "conceptual"
    VISUAL_SPATIAL = "visual_spatial"


# ============== Authentication Schemas ==============

class ParentRegister(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8, max_length=128)
    first_name: Optional[str] = Field(None, max_length=100)
    data_processing_agreed: bool = True
    
    @validator('password')
    def password_strength(cls, v):
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not any(c.islower() for c in v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain at least one digit')
        return v


class ParentLogin(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class ParentResponse(BaseModel):
    id: str
    email: str
    first_name: Optional[str]
    consent_status: str
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


class ConsentVerification(BaseModel):
    method: str = Field(..., pattern="^(email|credit_card)$")
    verification_code: Optional[str] = None


# ============== Child Schemas ==============

class ChildCreate(BaseModel):
    display_name: str = Field(default="Little Star", min_length=1, max_length=50)
    avatar_id: str = Field(default="avatar_star", max_length=50)
    birth_year: Optional[int] = Field(None, ge=2016, le=2026)
    age_group: str = Field(default="3-5", max_length=10)
    preferred_language: str = Field(default="en", max_length=10)
    sound_enabled: bool = True


class ChildUpdate(BaseModel):
    display_name: Optional[str] = Field(None, max_length=50)
    avatar_id: Optional[str] = Field(None, max_length=50)
    age_group: Optional[str] = Field(None, max_length=10)
    preferred_language: Optional[str] = None
    sound_enabled: Optional[bool] = None


class ChildResponse(BaseModel):
    id: str
    display_name: str
    avatar_id: str
    age_group: str
    preferred_language: str
    sound_enabled: bool
    is_anonymous: bool = True
    created_at: datetime
    
    class Config:
        from_attributes = True


class ChildWithProgress(ChildResponse):
    literacy_stage: Optional[str] = None
    stars_earned: int = 0
    current_streak_days: int = 0
    last_played_at: Optional[datetime] = None


# ============== Word Schemas ==============

class WordBase(BaseModel):
    word: str
    level: WordLevelEnum
    phonemes: List[str]
    syllables: int = 1
    word_family: Optional[str] = None
    category: Optional[str] = None
    is_sight_word: bool = False


class WordCreate(WordBase):
    difficulty: float = 0.0
    age_group_min: AgeGroupEnum
    age_group_max: AgeGroupEnum
    image_url: Optional[str] = None
    audio_url: Optional[str] = None
    sentence_example: Optional[str] = None


class WordResponse(WordBase):
    id: str
    difficulty: float
    age_group_min: AgeGroupEnum
    age_group_max: AgeGroupEnum
    image_url: Optional[str]
    audio_url: Optional[str]
    sentence_example: Optional[str]
    
    class Config:
        from_attributes = True


class WordProgressResponse(BaseModel):
    word_id: str
    word: str
    times_practiced: int
    times_correct: int
    mastery_score: float
    is_mastered: bool
    can_recognize: bool
    can_sound_out: bool
    can_read: bool
    can_spell: bool
    
    class Config:
        from_attributes = True


class WordsByLevel(BaseModel):
    level: WordLevelEnum
    total_count: int
    mastered_count: int
    words: List[WordResponse]


# ============== Literacy Schemas ==============

class LiteracyProgressResponse(BaseModel):
    current_stage: str
    letter_mastery: Dict[str, Any]
    phoneme_blending_score: float
    cvc_word_reading_score: float
    sight_words_mastered: int
    tracing_accuracy: float
    independent_writing_level: SkillLevelEnum
    reading_comprehension_score: float
    two_letter_words_mastered: int
    three_letter_words_mastered: int
    four_letter_words_mastered: int
    five_letter_words_mastered: int
    
    class Config:
        from_attributes = True


class TracingSessionCreate(BaseModel):
    letter: Optional[str] = Field(None, max_length=1)
    word: Optional[str] = Field(None, max_length=20)
    is_uppercase: bool = True
    stroke_accuracy: float = Field(..., ge=0, le=100)
    stroke_smoothness: float = Field(..., ge=0, le=100)
    time_taken_ms: int = Field(..., ge=0)
    attempt_number: int = Field(default=1, ge=1)
    path_deviation_data: Optional[Dict[str, Any]] = None


class TracingSessionResponse(BaseModel):
    id: str
    letter: Optional[str]
    word: Optional[str]
    stroke_accuracy: float
    stroke_smoothness: float
    time_taken_ms: int
    attempt_number: int
    completed_at: datetime
    
    class Config:
        from_attributes = True


# ============== Numeracy Schemas ==============

class NumeracyProgressResponse(BaseModel):
    subitizing_mastery: float
    counting_range: int
    numeral_recognition: Dict[str, bool]
    addition_mastery: float
    subtraction_mastery: float
    multiplication_intro: float
    place_value_mastery: float
    two_digit_operations: float
    st_puzzles_completed: int
    st_current_level: int
    nooms_interactions: int
    
    class Config:
        from_attributes = True


# ============== Task & Adaptive Learning Schemas ==============

class TaskContent(BaseModel):
    type: str  # "letter_trace", "word_read", "phoneme_blend", "math_puzzle"
    prompt: str
    options: Optional[List[Any]] = None
    media_url: Optional[str] = None
    hints: List[str] = []


class TaskResponse(BaseModel):
    id: str
    module: LearningModuleEnum
    task_type: str
    difficulty: float
    content: TaskContent
    
    class Config:
        from_attributes = True


class TaskSubmission(BaseModel):
    task_id: str
    response_data: Dict[str, Any]
    response_time_ms: int = Field(..., ge=0)
    interaction_count: int = Field(default=1, ge=1)


class TaskResultResponse(BaseModel):
    is_correct: bool
    correct_answer: Optional[Any] = None
    error_type: Optional[ErrorTypeEnum] = None
    hint: Optional[str] = None
    stars_earned: int = 0
    ability_change: float = 0.0
    next_task_available: bool = True


class AdaptiveTaskRequest(BaseModel):
    child_id: str
    module: LearningModuleEnum
    task_type: Optional[str] = None


# ============== Game State Schemas ==============

class GameStateResponse(BaseModel):
    current_world: str
    current_level: int
    stars_earned: int
    achievements: List[str]
    current_streak_days: int
    longest_streak_days: int
    mascot_unlocks: List[str]
    last_played_at: Optional[datetime]
    
    class Config:
        from_attributes = True


class GameStateUpdate(BaseModel):
    current_world: Optional[str] = None
    current_level: Optional[int] = None
    checkpoint_data: Optional[Dict[str, Any]] = None
    mascot_position: Optional[Dict[str, Any]] = None


class AchievementUnlock(BaseModel):
    achievement_id: str
    achievement_name: str
    description: str
    stars_reward: int


# ============== Parent Dashboard Schemas ==============

class DashboardOverview(BaseModel):
    child_id: str
    child_name: str
    age_group: AgeGroupEnum
    
    # Progress summary
    literacy_stage: str
    words_mastered: int
    letters_mastered: int
    math_level: int
    
    # Engagement
    stars_earned: int
    current_streak: int
    total_play_time_minutes: int
    sessions_this_week: int
    
    # Recent achievements
    recent_milestones: List[Dict[str, Any]]


class MilestoneResponse(BaseModel):
    id: str
    milestone_type: str
    milestone_name: str
    description: Optional[str]
    conversation_starters: List[str]
    achieved_at: datetime
    parent_viewed: bool
    
    class Config:
        from_attributes = True


class PlaySessionResponse(BaseModel):
    id: str
    started_at: datetime
    ended_at: Optional[datetime]
    duration_seconds: Optional[int]
    platform: Optional[str]
    tasks_attempted: int
    tasks_completed: int
    modules_visited: List[str]
    
    class Config:
        from_attributes = True


# ============== SEL Schemas ==============

class SelProgressResponse(BaseModel):
    emotions_identified: List[str]
    feelings_wheel_uses: int
    kindness_bingo_completed: int
    sharing_scenarios_passed: int
    calm_down_techniques_learned: List[str]
    
    class Config:
        from_attributes = True


class EmotionLogEntry(BaseModel):
    emotion: str
    intensity: int = Field(..., ge=1, le=5)
    context: Optional[str] = None


# ============== Progress Report Schemas ==============

class WeeklyProgressReport(BaseModel):
    child_id: str
    week_start: datetime
    week_end: datetime
    
    # Literacy
    new_letters_learned: int
    new_words_learned: int
    tracing_sessions: int
    avg_tracing_accuracy: float
    
    # Numeracy
    math_puzzles_completed: int
    math_level_progress: int
    
    # Engagement
    total_sessions: int
    total_time_minutes: int
    streak_maintained: bool
    
    # Highlights
    achievements_earned: List[str]
    areas_of_strength: List[str]
    areas_to_focus: List[str]
    
    # Parent tips
    conversation_starters: List[str]
    activity_suggestions: List[str]
