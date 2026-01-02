"""
WonderWorld Learning Adventure - Game Service
Handles stars, achievements, streaks, and sessions
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Dict, Any, Optional
from datetime import datetime, timedelta

from app.models.models import GameState, PlaySession, MilestoneEvent
from app.schemas.schemas import AchievementUnlock, PlaySessionResponse


# Achievement definitions
ACHIEVEMENTS = {
    "first_letter": {
        "name": "First Letter!",
        "description": "Traced your first letter",
        "stars": 5
    },
    "alphabet_starter": {
        "name": "Alphabet Starter",
        "description": "Traced 5 different letters",
        "stars": 10
    },
    "alphabet_master": {
        "name": "Alphabet Master",
        "description": "Mastered all 26 letters",
        "stars": 50
    },
    "first_word": {
        "name": "First Word!",
        "description": "Read your first word",
        "stars": 10
    },
    "word_explorer": {
        "name": "Word Explorer",
        "description": "Learned 10 words",
        "stars": 20
    },
    "counting_star": {
        "name": "Counting Star",
        "description": "Counted to 10",
        "stars": 10
    },
    "math_whiz": {
        "name": "Math Whiz",
        "description": "Completed 10 math puzzles",
        "stars": 15
    },
    "streak_3": {
        "name": "3-Day Streak!",
        "description": "Played for 3 days in a row",
        "stars": 15
    },
    "streak_7": {
        "name": "Week Warrior!",
        "description": "Played for 7 days in a row",
        "stars": 30
    },
    "feelings_friend": {
        "name": "Feelings Friend",
        "description": "Identified 5 different emotions",
        "stars": 10
    },
    "kindness_champion": {
        "name": "Kindness Champion",
        "description": "Completed a kindness bingo",
        "stars": 20
    }
}


class GameService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def _get_game_state(self, child_id: str) -> GameState:
        """Get game state for a child."""
        result = await self.db.execute(
            select(GameState).where(GameState.child_id == child_id)
        )
        return result.scalar_one_or_none()
    
    async def add_stars(self, child_id: str, stars: int) -> Dict[str, Any]:
        """Add stars to a child's total."""
        game_state = await self._get_game_state(child_id)
        if not game_state:
            return {"error": "Game state not found"}
        
        game_state.stars_earned += stars
        await self.db.commit()
        
        return {
            "stars_added": stars,
            "total_stars": game_state.stars_earned
        }
    
    async def unlock_achievement(
        self, 
        child_id: str, 
        achievement_id: str
    ) -> AchievementUnlock:
        """Unlock an achievement and award stars."""
        if achievement_id not in ACHIEVEMENTS:
            raise ValueError(f"Unknown achievement: {achievement_id}")
        
        achievement = ACHIEVEMENTS[achievement_id]
        game_state = await self._get_game_state(child_id)
        
        if not game_state:
            raise ValueError("Game state not found")
        
        # Check if already unlocked
        current_achievements = game_state.achievements or []
        if achievement_id in current_achievements:
            return AchievementUnlock(
                achievement_id=achievement_id,
                achievement_name=achievement["name"],
                description=achievement["description"],
                stars_reward=0  # Already unlocked
            )
        
        # Unlock achievement
        current_achievements.append(achievement_id)
        game_state.achievements = current_achievements
        game_state.stars_earned += achievement["stars"]
        
        # Create milestone event
        milestone = MilestoneEvent(
            child_id=child_id,
            milestone_type="achievement",
            milestone_name=achievement["name"],
            description=achievement["description"],
            conversation_starters=[
                f"Congratulations! Ask your child about their '{achievement['name']}' achievement!"
            ]
        )
        self.db.add(milestone)
        
        await self.db.commit()
        
        return AchievementUnlock(
            achievement_id=achievement_id,
            achievement_name=achievement["name"],
            description=achievement["description"],
            stars_reward=achievement["stars"]
        )
    
    async def start_session(
        self, 
        child_id: str, 
        platform: str,
        screen_size: str
    ) -> PlaySession:
        """Start a new play session."""
        game_state = await self._get_game_state(child_id)
        
        # Update streak
        if game_state:
            await self._update_streak(game_state)
        
        # Create session
        session = PlaySession(
            child_id=child_id,
            platform=platform,
            screen_size=screen_size
        )
        self.db.add(session)
        await self.db.commit()
        await self.db.refresh(session)
        
        return session
    
    async def end_session(
        self, 
        session_id: str,
        tasks_attempted: int,
        tasks_completed: int
    ) -> PlaySession:
        """End a play session."""
        result = await self.db.execute(
            select(PlaySession).where(PlaySession.id == session_id)
        )
        session = result.scalar_one_or_none()
        
        if not session:
            raise ValueError("Session not found")
        
        session.ended_at = datetime.utcnow()
        session.duration_seconds = int(
            (session.ended_at - session.started_at).total_seconds()
        )
        session.tasks_attempted = tasks_attempted
        session.tasks_completed = tasks_completed
        
        await self.db.commit()
        await self.db.refresh(session)
        
        return session
    
    async def _update_streak(self, game_state: GameState) -> None:
        """Update play streak based on last play date."""
        now = datetime.utcnow()
        last_played = game_state.last_played_at
        
        if last_played:
            days_since = (now.date() - last_played.date()).days
            
            if days_since == 0:
                # Same day, no change
                pass
            elif days_since == 1:
                # Consecutive day, increment streak
                game_state.current_streak_days += 1
                if game_state.current_streak_days > game_state.longest_streak_days:
                    game_state.longest_streak_days = game_state.current_streak_days
            else:
                # Streak broken
                game_state.current_streak_days = 1
        else:
            # First time playing
            game_state.current_streak_days = 1
        
        game_state.last_played_at = now
