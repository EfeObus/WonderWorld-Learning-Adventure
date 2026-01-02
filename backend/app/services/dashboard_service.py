"""
WonderWorld Learning Adventure - Dashboard Service
Provides parent dashboard data and reports
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import Dict, Any, List
from datetime import datetime, timedelta

from app.models.models import (
    Child, LiteracyProgress, NumeracyProgress, GameState,
    MilestoneEvent, PlaySession, TracingSession, WordProgress
)
from app.schemas.schemas import DashboardOverview, WeeklyProgressReport


class DashboardService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_overview(self, child: Child) -> DashboardOverview:
        """Get comprehensive dashboard overview for a child."""
        # Get literacy progress
        literacy_result = await self.db.execute(
            select(LiteracyProgress).where(LiteracyProgress.child_id == child.id)
        )
        literacy = literacy_result.scalar_one_or_none()
        
        # Get numeracy progress
        numeracy_result = await self.db.execute(
            select(NumeracyProgress).where(NumeracyProgress.child_id == child.id)
        )
        numeracy = numeracy_result.scalar_one_or_none()
        
        # Get game state
        game_result = await self.db.execute(
            select(GameState).where(GameState.child_id == child.id)
        )
        game_state = game_result.scalar_one_or_none()
        
        # Calculate words mastered
        words_mastered = 0
        letters_mastered = 0
        if literacy:
            words_mastered = (
                (literacy.two_letter_words_mastered or 0) +
                (literacy.three_letter_words_mastered or 0) +
                (literacy.four_letter_words_mastered or 0) +
                (literacy.five_letter_words_mastered or 0)
            )
            letter_mastery = literacy.letter_mastery or {}
            letters_mastered = sum(
                1 for v in letter_mastery.values() 
                if v.get("mastery", 0) >= 0.8
            )
        
        # Calculate play time this week
        week_ago = datetime.utcnow() - timedelta(days=7)
        sessions_result = await self.db.execute(
            select(PlaySession).where(
                PlaySession.child_id == child.id,
                PlaySession.started_at >= week_ago
            )
        )
        sessions = sessions_result.scalars().all()
        total_time = sum((s.duration_seconds or 0) for s in sessions)
        
        # Get recent milestones
        milestones_result = await self.db.execute(
            select(MilestoneEvent)
            .where(MilestoneEvent.child_id == child.id)
            .order_by(MilestoneEvent.achieved_at.desc())
            .limit(5)
        )
        milestones = milestones_result.scalars().all()
        
        return DashboardOverview(
            child_id=child.id,
            child_name=child.display_name,
            age_group=child.age_group,
            literacy_stage=literacy.current_stage if literacy else "first_steps",
            words_mastered=words_mastered,
            letters_mastered=letters_mastered,
            math_level=numeracy.st_current_level if numeracy else 1,
            stars_earned=game_state.stars_earned if game_state else 0,
            current_streak=game_state.current_streak_days if game_state else 0,
            total_play_time_minutes=total_time // 60,
            sessions_this_week=len(sessions),
            recent_milestones=[
                {
                    "type": m.milestone_type,
                    "name": m.milestone_name,
                    "date": m.achieved_at.isoformat()
                }
                for m in milestones
            ]
        )
    
    async def generate_weekly_report(
        self, 
        child_id: str, 
        week_offset: int = 0
    ) -> WeeklyProgressReport:
        """Generate a weekly progress report."""
        # Calculate week boundaries
        now = datetime.utcnow()
        week_end = now - timedelta(days=7 * week_offset)
        week_start = week_end - timedelta(days=7)
        
        # Get tracing sessions this week
        tracing_result = await self.db.execute(
            select(TracingSession).where(
                TracingSession.child_id == child_id,
                TracingSession.completed_at >= week_start,
                TracingSession.completed_at <= week_end
            )
        )
        tracing_sessions = tracing_result.scalars().all()
        
        # Calculate unique letters traced
        unique_letters = set(s.letter for s in tracing_sessions if s.letter)
        avg_accuracy = 0
        if tracing_sessions:
            avg_accuracy = sum(
                float(s.stroke_accuracy or 0) for s in tracing_sessions
            ) / len(tracing_sessions)
        
        # Get play sessions
        sessions_result = await self.db.execute(
            select(PlaySession).where(
                PlaySession.child_id == child_id,
                PlaySession.started_at >= week_start,
                PlaySession.started_at <= week_end
            )
        )
        play_sessions = sessions_result.scalars().all()
        total_time = sum((s.duration_seconds or 0) for s in play_sessions)
        
        # Get milestones this week
        milestones_result = await self.db.execute(
            select(MilestoneEvent).where(
                MilestoneEvent.child_id == child_id,
                MilestoneEvent.achieved_at >= week_start,
                MilestoneEvent.achieved_at <= week_end
            )
        )
        milestones = milestones_result.scalars().all()
        
        # Get game state for streak check
        game_result = await self.db.execute(
            select(GameState).where(GameState.child_id == child_id)
        )
        game_state = game_result.scalar_one_or_none()
        
        return WeeklyProgressReport(
            child_id=child_id,
            week_start=week_start,
            week_end=week_end,
            new_letters_learned=len(unique_letters),
            new_words_learned=0,  # Would need to track this separately
            tracing_sessions=len(tracing_sessions),
            avg_tracing_accuracy=avg_accuracy,
            math_puzzles_completed=0,  # Would need to track
            math_level_progress=0,
            total_sessions=len(play_sessions),
            total_time_minutes=total_time // 60,
            streak_maintained=game_state.current_streak_days >= 7 if game_state else False,
            achievements_earned=[m.milestone_name for m in milestones],
            areas_of_strength=self._identify_strengths(tracing_sessions),
            areas_to_focus=self._identify_focus_areas(tracing_sessions),
            conversation_starters=self._generate_conversation_starters(unique_letters),
            activity_suggestions=self._generate_activity_suggestions(unique_letters)
        )
    
    def _identify_strengths(self, tracing_sessions) -> List[str]:
        """Identify areas of strength based on performance."""
        strengths = []
        if tracing_sessions:
            avg = sum(float(s.stroke_accuracy or 0) for s in tracing_sessions) / len(tracing_sessions)
            if avg >= 80:
                strengths.append("Excellent letter tracing!")
            if len(set(s.letter for s in tracing_sessions)) >= 5:
                strengths.append("Great variety in letter practice!")
        return strengths or ["Keep practicing!"]
    
    def _identify_focus_areas(self, tracing_sessions) -> List[str]:
        """Identify areas that need more practice."""
        focus = []
        if not tracing_sessions:
            focus.append("Try some letter tracing activities!")
        return focus or ["You're doing great!"]
    
    def _generate_conversation_starters(self, letters: set) -> List[str]:
        """Generate conversation starters for parents."""
        starters = []
        for letter in list(letters)[:3]:
            starters.append(
                f"Your child practiced the letter '{letter}' this week. "
                f"Can you find things around the house that start with '{letter}'?"
            )
        return starters or ["Ask your child what they learned this week!"]
    
    def _generate_activity_suggestions(self, letters: set) -> List[str]:
        """Generate activity suggestions for parents."""
        suggestions = [
            "Read a picture book together and point out letters",
            "Count objects during snack time",
            "Practice writing letters in sand or shaving cream"
        ]
        return suggestions
    
    async def get_conversation_starters(self, child_id: str) -> List[str]:
        """Get personalized conversation starters."""
        # Get recent milestones
        result = await self.db.execute(
            select(MilestoneEvent)
            .where(MilestoneEvent.child_id == child_id)
            .order_by(MilestoneEvent.achieved_at.desc())
            .limit(5)
        )
        milestones = result.scalars().all()
        
        starters = []
        for m in milestones:
            if m.conversation_starters:
                starters.extend(m.conversation_starters)
        
        return starters or [
            "Ask your child about their favorite game today!",
            "What new letters did you learn?",
            "Can you count your toys together?"
        ]
    
    async def request_data_deletion(self, child_id: str, parent_id: str) -> None:
        """Request deletion of child data (GDPR/COPPA)."""
        # In production, this would create a deletion request record
        # and initiate the deletion workflow
        pass
    
    async def export_child_data(self, child_id: str) -> Dict[str, Any]:
        """Export all child data (GDPR portability)."""
        # Get all data for the child
        child_result = await self.db.execute(
            select(Child).where(Child.id == child_id)
        )
        child = child_result.scalar_one_or_none()
        
        if not child:
            return {}
        
        # Gather all related data
        literacy_result = await self.db.execute(
            select(LiteracyProgress).where(LiteracyProgress.child_id == child_id)
        )
        numeracy_result = await self.db.execute(
            select(NumeracyProgress).where(NumeracyProgress.child_id == child_id)
        )
        game_result = await self.db.execute(
            select(GameState).where(GameState.child_id == child_id)
        )
        
        return {
            "child": {
                "display_name": child.display_name,
                "age_group": child.age_group.value if child.age_group else None,
                "created_at": child.created_at.isoformat() if child.created_at else None
            },
            "literacy_progress": {},  # Would serialize progress
            "numeracy_progress": {},  # Would serialize progress
            "game_state": {},  # Would serialize state
            "exported_at": datetime.utcnow().isoformat()
        }
