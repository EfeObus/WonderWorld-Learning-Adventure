"""
WonderWorld Learning Adventure - SQLAlchemy Models
"""
from sqlalchemy import (
    Column, String, Integer, Boolean, DateTime, ForeignKey, 
    Numeric, Text, Enum as SQLEnum, JSON, ARRAY
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime
from typing import Optional, List
import enum
import uuid

from app.database import Base


# Enums
class AgeGroup(str, enum.Enum):
    AGE_2_3 = "2-3"
    AGE_4_5 = "4-5"
    AGE_6_7 = "6-7"
    AGE_8 = "8"


class LearningModule(str, enum.Enum):
    LITERACY = "literacy"
    NUMERACY = "numeracy"
    SEL = "sel"


class SkillLevel(str, enum.Enum):
    BEGINNER = "beginner"
    DEVELOPING = "developing"
    PROFICIENT = "proficient"
    ADVANCED = "advanced"


class ErrorType(str, enum.Enum):
    FACTUAL = "factual"
    PROCEDURAL = "procedural"
    CONCEPTUAL = "conceptual"
    VISUAL_SPATIAL = "visual_spatial"


class ConsentStatus(str, enum.Enum):
    PENDING = "pending"
    VERIFIED = "verified"
    REVOKED = "revoked"


class WordLevel(str, enum.Enum):
    TWO_LETTER = "2-letter"
    THREE_LETTER = "3-letter"
    FOUR_LETTER = "4-letter"
    FIVE_LETTER = "5-letter"


def generate_uuid():
    return str(uuid.uuid4())


# Parent/Guardian Model
class Parent(Base):
    __tablename__ = "parents"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    first_name = Column(String(100))
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # COPPA/GDPR-K Compliance
    consent_status = Column(SQLEnum(ConsentStatus), default=ConsentStatus.PENDING)
    consent_verified_at = Column(DateTime(timezone=True))
    consent_method = Column(String(50))
    data_processing_agreed = Column(Boolean, default=False)
    marketing_opted_in = Column(Boolean, default=False)
    
    # Account status
    is_active = Column(Boolean, default=True)
    last_login_at = Column(DateTime(timezone=True))
    
    # Relationships
    children = relationship("Child", back_populates="parent", cascade="all, delete-orphan")
    refresh_tokens = relationship("RefreshToken", back_populates="parent", cascade="all, delete-orphan")


# Child Profile Model
class Child(Base):
    __tablename__ = "children"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    parent_id = Column(String(36), ForeignKey("parents.id", ondelete="CASCADE"), nullable=False)
    
    # Minimal identifying info (COPPA compliant)
    display_name = Column(String(50), nullable=False)
    avatar_id = Column(Integer, default=1)
    birth_year = Column(Integer)
    age_group = Column(SQLEnum(AgeGroup), nullable=False)
    
    # Preferences
    preferred_language = Column(String(10), default="en")
    sound_enabled = Column(Boolean, default=True)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    is_active = Column(Boolean, default=True)
    
    # Relationships
    parent = relationship("Parent", back_populates="children")
    literacy_progress = relationship("LiteracyProgress", back_populates="child", uselist=False, cascade="all, delete-orphan")
    numeracy_progress = relationship("NumeracyProgress", back_populates="child", uselist=False, cascade="all, delete-orphan")
    sel_progress = relationship("SelProgress", back_populates="child", uselist=False, cascade="all, delete-orphan")
    game_state = relationship("GameState", back_populates="child", uselist=False, cascade="all, delete-orphan")
    ability_estimates = relationship("AbilityEstimate", back_populates="child", cascade="all, delete-orphan")
    task_responses = relationship("TaskResponse", back_populates="child", cascade="all, delete-orphan")
    tracing_sessions = relationship("TracingSession", back_populates="child", cascade="all, delete-orphan")
    word_progress = relationship("WordProgress", back_populates="child", cascade="all, delete-orphan")
    play_sessions = relationship("PlaySession", back_populates="child", cascade="all, delete-orphan")
    milestone_events = relationship("MilestoneEvent", back_populates="child", cascade="all, delete-orphan")


# Literacy Progress Model
class LiteracyProgress(Base):
    __tablename__ = "literacy_progress"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    # Current stage
    current_stage = Column(String(50), default="first_steps")
    
    # Letter mastery (JSON: {"A": {"traced": true, "sound_known": true, "mastery": 0.85}})
    letter_mastery = Column(JSON, default=dict)
    
    # Phonemic awareness
    phoneme_blending_score = Column(Numeric(5, 2), default=0)
    cvc_word_reading_score = Column(Numeric(5, 2), default=0)
    sight_words_mastered = Column(Integer, default=0)
    
    # Writing
    tracing_accuracy = Column(Numeric(5, 2), default=0)
    independent_writing_level = Column(SQLEnum(SkillLevel), default=SkillLevel.BEGINNER)
    
    # Comprehension
    reading_comprehension_score = Column(Numeric(5, 2), default=0)
    
    # Word levels progress
    two_letter_words_mastered = Column(Integer, default=0)
    three_letter_words_mastered = Column(Integer, default=0)
    four_letter_words_mastered = Column(Integer, default=0)
    five_letter_words_mastered = Column(Integer, default=0)
    
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    child = relationship("Child", back_populates="literacy_progress")


# Word Bank Model
class Word(Base):
    __tablename__ = "words"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    word = Column(String(20), unique=True, nullable=False, index=True)
    level = Column(SQLEnum(WordLevel), nullable=False, index=True)
    
    # Phonics info
    phonemes = Column(ARRAY(String), default=list)  # ['c', 'a', 't']
    syllables = Column(Integer, default=1)
    word_family = Column(String(20))  # e.g., "-at" family
    
    # Categories
    category = Column(String(50))  # short_a, short_e, cvcc, sight_word, etc.
    is_sight_word = Column(Boolean, default=False)
    
    # Teaching
    difficulty = Column(Numeric(8, 4), default=0)
    age_group_min = Column(SQLEnum(AgeGroup), nullable=False)
    age_group_max = Column(SQLEnum(AgeGroup), nullable=False)
    
    # Assets
    image_url = Column(String(500))
    audio_url = Column(String(500))
    sentence_example = Column(Text)
    
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


# Word Progress Model
class WordProgress(Base):
    __tablename__ = "word_progress"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    word_id = Column(String(36), ForeignKey("words.id", ondelete="CASCADE"), nullable=False)
    
    # Mastery tracking
    times_practiced = Column(Integer, default=0)
    times_correct = Column(Integer, default=0)
    mastery_score = Column(Numeric(5, 2), default=0)
    is_mastered = Column(Boolean, default=False)
    
    # Learning stages
    can_recognize = Column(Boolean, default=False)
    can_sound_out = Column(Boolean, default=False)
    can_read = Column(Boolean, default=False)
    can_spell = Column(Boolean, default=False)
    
    last_practiced_at = Column(DateTime(timezone=True))
    mastered_at = Column(DateTime(timezone=True))
    
    child = relationship("Child", back_populates="word_progress")


# Tracing Session Model
class TracingSession(Base):
    __tablename__ = "tracing_sessions"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    
    # What was traced
    letter = Column(String(1))
    word = Column(String(20))
    is_uppercase = Column(Boolean, default=True)
    
    # Stroke analysis
    stroke_accuracy = Column(Numeric(5, 2))
    stroke_smoothness = Column(Numeric(5, 2))
    time_taken_ms = Column(Integer)
    attempt_number = Column(Integer, default=1)
    
    # PathMetrics data
    path_deviation_data = Column(JSON)
    
    completed_at = Column(DateTime(timezone=True), server_default=func.now())
    
    child = relationship("Child", back_populates="tracing_sessions")


# Numeracy Progress Model
class NumeracyProgress(Base):
    __tablename__ = "numeracy_progress"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    # Core skills
    subitizing_mastery = Column(Numeric(5, 2), default=0)
    counting_range = Column(Integer, default=0)
    numeral_recognition = Column(JSON, default=dict)
    
    # Operations
    addition_mastery = Column(Numeric(5, 2), default=0)
    subtraction_mastery = Column(Numeric(5, 2), default=0)
    multiplication_intro = Column(Numeric(5, 2), default=0)
    
    # Place value
    place_value_mastery = Column(Numeric(5, 2), default=0)
    two_digit_operations = Column(Numeric(5, 2), default=0)
    
    # ST Math style
    st_puzzles_completed = Column(Integer, default=0)
    st_current_level = Column(Integer, default=1)
    
    # Digital manipulatives
    nooms_interactions = Column(Integer, default=0)
    
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    child = relationship("Child", back_populates="numeracy_progress")


# SEL Progress Model
class SelProgress(Base):
    __tablename__ = "sel_progress"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    emotions_identified = Column(JSON, default=list)
    feelings_wheel_uses = Column(Integer, default=0)
    kindness_bingo_completed = Column(Integer, default=0)
    sharing_scenarios_passed = Column(Integer, default=0)
    calm_down_techniques_learned = Column(JSON, default=list)
    
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    child = relationship("Child", back_populates="sel_progress")


# Ability Estimate Model (Rasch Model)
class AbilityEstimate(Base):
    __tablename__ = "ability_estimates"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    module = Column(SQLEnum(LearningModule), nullable=False)
    
    # Rasch model parameters
    ability_score = Column(Numeric(8, 4), default=0)
    ability_variance = Column(Numeric(8, 4), default=1)
    total_responses = Column(Integer, default=0)
    correct_responses = Column(Integer, default=0)
    
    last_updated = Column(DateTime(timezone=True), onupdate=func.now())


# Task Model
class Task(Base):
    __tablename__ = "tasks"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    module = Column(SQLEnum(LearningModule), nullable=False, index=True)
    
    # Task metadata
    task_type = Column(String(100), nullable=False)
    difficulty = Column(Numeric(8, 4), nullable=False, index=True)
    age_group_min = Column(SQLEnum(AgeGroup), nullable=False)
    age_group_max = Column(SQLEnum(AgeGroup), nullable=False)
    
    # Content
    content = Column(JSON, nullable=False)
    correct_answer = Column(JSON)
    hints = Column(JSON, default=list)
    visual_scaffold_url = Column(String(500))
    
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


# Task Response Model
class TaskResponse(Base):
    __tablename__ = "task_responses"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    task_id = Column(String(36), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False)
    
    # Response data
    is_correct = Column(Boolean, nullable=False)
    response_data = Column(JSON)
    response_time_ms = Column(Integer)
    
    # Error analysis
    error_type = Column(SQLEnum(ErrorType))
    scaffold_shown = Column(Boolean, default=False)
    hints_used = Column(Integer, default=0)
    interaction_count = Column(Integer, default=1)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    child = relationship("Child", back_populates="task_responses")


# Game State Model
class GameState(Base):
    __tablename__ = "game_states"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), unique=True, nullable=False)
    
    # Current position
    current_world = Column(String(100), default="starter_island")
    current_level = Column(Integer, default=1)
    checkpoint_data = Column(JSON, default=dict)
    
    # Mascot (WonderPal)
    mascot_position = Column(JSON)
    mascot_unlocks = Column(JSON, default=list)
    
    # Progress
    stars_earned = Column(Integer, default=0)
    achievements = Column(JSON, default=list)
    
    # Streaks
    current_streak_days = Column(Integer, default=0)
    longest_streak_days = Column(Integer, default=0)
    last_played_at = Column(DateTime(timezone=True))
    
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    child = relationship("Child", back_populates="game_state")


# Play Session Model
class PlaySession(Base):
    __tablename__ = "play_sessions"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    
    started_at = Column(DateTime(timezone=True), server_default=func.now())
    ended_at = Column(DateTime(timezone=True))
    duration_seconds = Column(Integer)
    
    # Device info (minimal)
    platform = Column(String(20))
    screen_size = Column(String(20))
    
    # Session summary
    tasks_attempted = Column(Integer, default=0)
    tasks_completed = Column(Integer, default=0)
    modules_visited = Column(JSON, default=list)
    
    child = relationship("Child", back_populates="play_sessions")


# Milestone Event Model
class MilestoneEvent(Base):
    __tablename__ = "milestone_events"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    child_id = Column(String(36), ForeignKey("children.id", ondelete="CASCADE"), nullable=False)
    
    milestone_type = Column(String(100), nullable=False)
    milestone_name = Column(String(255), nullable=False)
    description = Column(Text)
    conversation_starters = Column(JSON, default=list)
    
    achieved_at = Column(DateTime(timezone=True), server_default=func.now())
    parent_viewed = Column(Boolean, default=False)
    
    child = relationship("Child", back_populates="milestone_events")


# Refresh Token Model
class RefreshToken(Base):
    __tablename__ = "refresh_tokens"
    
    id = Column(String(36), primary_key=True, default=generate_uuid)
    parent_id = Column(String(36), ForeignKey("parents.id", ondelete="CASCADE"), nullable=False)
    token = Column(String(500), nullable=False, unique=True)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    is_revoked = Column(Boolean, default=False)
    
    parent = relationship("Parent", back_populates="refresh_tokens")


# Avatar Model
class Avatar(Base):
    __tablename__ = "avatars"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    image_path = Column(String(255), nullable=False)
    unlock_requirement = Column(JSON)


# Letter Group Model
class LetterGroup(Base):
    __tablename__ = "letter_groups"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    group_name = Column(String(100), nullable=False)
    letters = Column(ARRAY(String), nullable=False)
    stroke_type = Column(String(50), nullable=False)
    teaching_order = Column(Integer, nullable=False)
