"""
WonderWorld Learning Adventure - Parent Dashboard Router
Provides parents with insights into their child's learning progress

NOTE: Authentication disabled - dashboard is accessible without login.
In production, consider adding optional password protection for the dashboard.
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime, timedelta
from typing import List

from app.database import get_db
from app.models.models import (
    Child, LiteracyProgress, NumeracyProgress, 
    GameState, MilestoneEvent, PlaySession
)
from app.schemas.schemas import (
    DashboardOverview, MilestoneResponse, 
    WeeklyProgressReport, PlaySessionResponse
)
from app.services.dependencies import get_child_by_id
from app.services.dashboard_service import DashboardService

router = APIRouter()


@router.get("/overview/{child_id}", response_model=DashboardOverview)
async def get_dashboard_overview(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Get a comprehensive dashboard overview for a child.
    
    Includes literacy stage, math level, engagement metrics,
    and recent achievements.
    """
    child = await get_child_by_id(child_id, db)
    
    dashboard_service = DashboardService(db)
    overview = await dashboard_service.get_overview(child)
    
    return overview


@router.get("/milestones/{child_id}", response_model=List[MilestoneResponse])
async def get_milestones(
    child_id: str,
    unread_only: bool = Query(False),
    limit: int = Query(20, ge=1, le=100),
    db: AsyncSession = Depends(get_db)
):
    """
    Get milestone achievements for a child.
    
    Milestones include things like "First letter traced!",
    "Counted to 10!", "Read first word!", etc.
    """
    child = await get_child_by_id(child_id, db)
    
    query = select(MilestoneEvent).where(MilestoneEvent.child_id == child.id)
    
    if unread_only:
        query = query.where(MilestoneEvent.parent_viewed == False)
    
    query = query.order_by(MilestoneEvent.achieved_at.desc()).limit(limit)
    
    result = await db.execute(query)
    milestones = result.scalars().all()
    
    return milestones


@router.post("/milestones/{milestone_id}/mark-read")
async def mark_milestone_read(
    milestone_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Mark a milestone as read/viewed by parent.
    """
    result = await db.execute(
        select(MilestoneEvent).where(MilestoneEvent.id == milestone_id)
    )
    milestone = result.scalar_one_or_none()
    
    if not milestone:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Milestone not found"
        )
    
    milestone.parent_viewed = True
    await db.commit()
    
    return {"status": "marked as read"}


@router.get("/weekly-report/{child_id}", response_model=WeeklyProgressReport)
async def get_weekly_report(
    child_id: str,
    week_offset: int = Query(0, ge=0, le=52),
    db: AsyncSession = Depends(get_db)
):
    """
    Get a weekly progress report.
    
    Includes:
    - New letters and words learned
    - Math progress
    - Total engagement time
    - Achievements earned
    - Conversation starters for parents
    - Suggested activities
    """
    child = await get_child_by_id(child_id, db)
    
    dashboard_service = DashboardService(db)
    report = await dashboard_service.generate_weekly_report(child.id, week_offset)
    
    return report


@router.get("/conversation-starters/{child_id}")
async def get_conversation_starters(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Get conversation starters based on recent learning.
    
    These prompts help parents extend learning into daily life:
    - "I see your child learned the word 'cat' today. 
       Ask them to point out cats in your neighborhood!"
    """
    child = await get_child_by_id(child_id, db)
    
    dashboard_service = DashboardService(db)
    starters = await dashboard_service.get_conversation_starters(child.id)
    
    return starters


@router.get("/activity-time/{child_id}")
async def get_activity_time(
    child_id: str,
    days: int = Query(7, ge=1, le=30),
    db: AsyncSession = Depends(get_db)
):
    """
    Get activity/play time statistics.
    """
    child = await get_child_by_id(child_id, db)
    
    start_date = datetime.utcnow() - timedelta(days=days)
    
    result = await db.execute(
        select(PlaySession)
        .where(
            PlaySession.child_id == child.id,
            PlaySession.started_at >= start_date
        )
    )
    sessions = result.scalars().all()
    
    total_minutes = sum(
        (s.duration_seconds or 0) / 60 for s in sessions
    )
    
    return {
        "period_days": days,
        "total_sessions": len(sessions),
        "total_minutes": round(total_minutes, 1),
        "average_session_minutes": round(total_minutes / len(sessions), 1) if sessions else 0
    }


@router.delete("/data/{child_id}")
async def request_data_deletion(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Request deletion of all child data (GDPR/COPPA compliance).
    
    This initiates a data deletion request that will be processed
    according to regulatory requirements.
    """
    child = await get_child_by_id(child_id, db)
    
    dashboard_service = DashboardService(db)
    await dashboard_service.request_data_deletion(child.id, None)
    
    return {
        "status": "deletion_requested",
        "message": "Data deletion request submitted."
    }


@router.get("/export/{child_id}")
async def export_child_data(
    child_id: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Export all child data (GDPR data portability right).
    """
    child = await get_child_by_id(child_id, db)
    
    dashboard_service = DashboardService(db)
    data = await dashboard_service.export_child_data(child.id)
    
    return data
