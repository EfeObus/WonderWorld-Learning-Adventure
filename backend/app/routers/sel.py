"""
WonderWorld Learning Adventure - SEL Router
Handles Social-Emotional Learning activities

NOTE: Authentication disabled - kids play directly without login.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.database import get_db
from app.models.models import Child, SelProgress
from app.schemas.schemas import SelProgressResponse, EmotionLogEntry
from app.services.dependencies import get_child_by_id
from app.services.sel_service import SelService

router = APIRouter()


@router.get("/{child_id}/progress", response_model=SelProgressResponse)
async def get_sel_progress(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Get child's social-emotional learning progress.
    
    Tracks:
    - Emotions identified
    - Feelings wheel usage
    - Kindness bingo completions
    - Sharing scenarios passed
    - Calm-down techniques learned
    """
    child = await get_child_by_id(child_id, db)
    
    result = await db.execute(
        select(SelProgress).where(SelProgress.child_id == child.id)
    )
    progress = result.scalar_one_or_none()
    
    if not progress:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="SEL progress not found"
        )
    
    return progress


@router.post("/{child_id}/feelings-wheel")
async def record_feelings_wheel_use(
    child_id: str,
    emotion: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Record a feelings wheel interaction.
    
    The feelings wheel helps children identify and express emotions.
    """
    child = await get_child_by_id(child_id, db)
    
    sel_service = SelService(db)
    result = await sel_service.record_feelings_wheel(child.id, emotion)
    
    return result


@router.post("/{child_id}/emotion-log")
async def log_emotion(
    child_id: str,
    entry: EmotionLogEntry,
    db: AsyncSession = Depends(get_db)
):
    """
    Log an emotion identification event.
    """
    child = await get_child_by_id(child_id, db)
    
    sel_service = SelService(db)
    result = await sel_service.log_emotion(child.id, entry)
    
    return result


@router.post("/{child_id}/kindness-bingo")
async def complete_kindness_bingo(
    child_id: str,
    task_completed: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Record completion of a kindness bingo task.
    
    Kindness bingo encourages prosocial behaviors like:
    - Sharing a toy
    - Saying thank you
    - Helping with chores
    - Giving a compliment
    """
    child = await get_child_by_id(child_id, db)
    
    sel_service = SelService(db)
    result = await sel_service.complete_kindness_task(child.id, task_completed)
    
    return result


@router.post("/{child_id}/sharing-scenario")
async def complete_sharing_scenario(
    child_id: str,
    scenario_id: str,
    response_chosen: str,
    was_prosocial: bool,
    db: AsyncSession = Depends(get_db)
):
    """
    Record response to a sharing scenario.
    
    Scenarios present social situations and track
    whether children choose prosocial responses.
    """
    child = await get_child_by_id(child_id, db)
    
    sel_service = SelService(db)
    result = await sel_service.record_sharing_scenario(
        child.id, scenario_id, response_chosen, was_prosocial
    )
    
    return result


@router.post("/{child_id}/calm-down")
async def learn_calm_down_technique(
    child_id: str,
    technique: str,
    practiced: bool = True,
    db: AsyncSession = Depends(get_db)
):
    """
    Record learning/practice of a calm-down technique.
    
    Techniques include:
    - Deep breathing
    - Counting to 10
    - Squeeze and release
    - Find a quiet spot
    - Talk about feelings
    """
    child = await get_child_by_id(child_id, db)
    
    sel_service = SelService(db)
    result = await sel_service.learn_calm_down_technique(child.id, technique)
    
    return result


@router.get("/{child_id}/emotions-summary")
async def get_emotions_summary(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Get a summary of emotions identified over time.
    
    Helps parents understand their child's emotional patterns.
    """
    child = await get_child_by_id(child_id, db)
    
    sel_service = SelService(db)
    summary = await sel_service.get_emotions_summary(child.id)
    
    return summary

@router.get("/friendship-stories")
async def get_friendship_stories(
    db: AsyncSession = Depends(get_db)
):
    """
    Get available friendship stories.
    
    Returns stories that teach social-emotional concepts.
    """
    stories = [
        {
            "id": "sharing_is_caring",
            "title": "Sharing is Caring",
            "description": "Tommy learns to share his crayons",
            "lesson": "Sharing makes friendships stronger!",
            "pages": 5,
            "themes": ["sharing", "friendship"]
        },
        {
            "id": "new_friend",
            "title": "The New Friend",
            "description": "Lily helps a new kid feel welcome",
            "lesson": "Being kind to new friends is wonderful!",
            "pages": 5,
            "themes": ["kindness", "inclusion"]
        },
        {
            "id": "sorry_makes_better",
            "title": "Sorry Makes it Better",
            "description": "Ben apologizes after an accident",
            "lesson": "Saying sorry helps heal hurt feelings!",
            "pages": 5,
            "themes": ["apology", "empathy"]
        },
        {
            "id": "different_is_special",
            "title": "Different is Special",
            "description": "Mia and Jake become friends despite being different",
            "lesson": "Friends don't have to be the same!",
            "pages": 5,
            "themes": ["diversity", "acceptance"]
        }
    ]
    
    return {"stories": stories, "total": len(stories)}


@router.post("/{child_id}/friendship-story/{story_id}/complete")
async def record_friendship_story_completion(
    child_id: str,
    story_id: str,
    pages_read: int,
    understood_lesson: bool = True,
    db: AsyncSession = Depends(get_db)
):
    """
    Record completion of a friendship story.
    """
    child = await get_child_by_id(child_id, db)
    
    return {
        "success": True,
        "child_id": str(child.id),
        "story_id": story_id,
        "pages_read": pages_read,
        "understood_lesson": understood_lesson,
        "message": "Friendship story completion recorded"
    }


@router.post("/{child_id}/breathing-exercise")
async def record_breathing_exercise(
    child_id: str,
    exercise_type: str = Query(..., description="Type of breathing exercise (bubble, counting, etc.)"),
    duration_seconds: int = Query(..., ge=0),
    completed: bool = Query(default=True),
    db: AsyncSession = Depends(get_db)
):
    """
    Record a breathing/calming exercise session.
    """
    child = await get_child_by_id(child_id, db)
    
    return {
        "success": True,
        "child_id": str(child.id),
        "exercise_type": exercise_type,
        "duration_seconds": duration_seconds,
        "completed": completed,
        "message": f"Breathing exercise '{exercise_type}' recorded"
    }