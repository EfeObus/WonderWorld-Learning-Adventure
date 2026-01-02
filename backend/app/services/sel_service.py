"""
WonderWorld Learning Adventure - SEL Service
Handles Social-Emotional Learning activities
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Dict, Any, List
from datetime import datetime

from app.models.models import SelProgress, MilestoneEvent
from app.schemas.schemas import EmotionLogEntry


# Available emotions for the feelings wheel
EMOTIONS = [
    "happy", "sad", "angry", "scared", "surprised", "disgusted",
    "excited", "calm", "worried", "proud", "embarrassed", "confused",
    "frustrated", "hopeful", "grateful", "jealous", "lonely", "loved"
]

# Calm-down techniques
CALM_DOWN_TECHNIQUES = [
    "deep_breathing",
    "count_to_ten",
    "squeeze_and_release",
    "quiet_spot",
    "talk_about_feelings",
    "draw_feelings",
    "listen_to_music",
    "take_a_walk"
]


class SelService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def _get_progress(self, child_id: str) -> SelProgress:
        """Get SEL progress for a child."""
        result = await self.db.execute(
            select(SelProgress).where(SelProgress.child_id == child_id)
        )
        return result.scalar_one_or_none()
    
    async def record_feelings_wheel(
        self, 
        child_id: str, 
        emotion: str
    ) -> Dict[str, Any]:
        """Record a feelings wheel interaction."""
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        # Increment usage count
        progress.feelings_wheel_uses += 1
        
        # Track unique emotions identified
        emotions = progress.emotions_identified or []
        if emotion.lower() not in emotions:
            emotions.append(emotion.lower())
            progress.emotions_identified = emotions
            
            # Check for milestone
            if len(emotions) == 5:
                await self._create_milestone(
                    child_id,
                    "sel",
                    "Feelings Expert",
                    "Identified 5 different emotions!",
                    ["Ask your child to show you the feelings wheel!"]
                )
        
        await self.db.commit()
        
        return {
            "emotion": emotion,
            "total_emotions_identified": len(emotions),
            "feelings_wheel_uses": progress.feelings_wheel_uses
        }
    
    async def log_emotion(
        self, 
        child_id: str, 
        entry: EmotionLogEntry
    ) -> Dict[str, Any]:
        """Log an emotion identification."""
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        emotions = progress.emotions_identified or []
        if entry.emotion.lower() not in emotions:
            emotions.append(entry.emotion.lower())
            progress.emotions_identified = emotions
        
        await self.db.commit()
        
        return {
            "emotion": entry.emotion,
            "intensity": entry.intensity,
            "logged": True
        }
    
    async def complete_kindness_task(
        self, 
        child_id: str, 
        task: str
    ) -> Dict[str, Any]:
        """Record completion of a kindness bingo task."""
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        progress.kindness_bingo_completed += 1
        
        # Check for milestone (completing a full bingo = 5 tasks)
        if progress.kindness_bingo_completed % 5 == 0:
            await self._create_milestone(
                child_id,
                "sel",
                "Kindness Champion",
                f"Completed {progress.kindness_bingo_completed} kind acts!",
                [
                    "Celebrate your child's kindness!",
                    "Ask them about the kind thing they did."
                ]
            )
        
        await self.db.commit()
        
        return {
            "task": task,
            "total_completed": progress.kindness_bingo_completed
        }
    
    async def record_sharing_scenario(
        self, 
        child_id: str,
        scenario_id: str,
        response_chosen: str,
        was_prosocial: bool
    ) -> Dict[str, Any]:
        """Record response to a sharing scenario."""
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        if was_prosocial:
            progress.sharing_scenarios_passed += 1
        
        await self.db.commit()
        
        return {
            "scenario_id": scenario_id,
            "was_prosocial": was_prosocial,
            "total_passed": progress.sharing_scenarios_passed
        }
    
    async def learn_calm_down_technique(
        self, 
        child_id: str, 
        technique: str
    ) -> Dict[str, Any]:
        """Record learning of a calm-down technique."""
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        techniques = progress.calm_down_techniques_learned or []
        
        if technique not in techniques:
            techniques.append(technique)
            progress.calm_down_techniques_learned = techniques
            
            # Milestone for learning first technique
            if len(techniques) == 1:
                await self._create_milestone(
                    child_id,
                    "sel",
                    "Calm Down Pro",
                    "Learned first calm-down technique!",
                    [
                        "Practice the technique together when your child is calm.",
                        "Model using the technique yourself!"
                    ]
                )
        
        await self.db.commit()
        
        return {
            "technique": technique,
            "total_techniques": len(techniques),
            "all_techniques": techniques
        }
    
    async def get_emotions_summary(self, child_id: str) -> Dict[str, Any]:
        """Get a summary of emotions identified over time."""
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        emotions = progress.emotions_identified or []
        
        # Categorize emotions
        positive = ["happy", "excited", "calm", "proud", "hopeful", "grateful", "loved"]
        negative = ["sad", "angry", "scared", "worried", "frustrated", "jealous", "lonely"]
        neutral = ["surprised", "confused", "embarrassed", "disgusted"]
        
        categorized = {
            "positive": [e for e in emotions if e in positive],
            "negative": [e for e in emotions if e in negative],
            "neutral": [e for e in emotions if e in neutral]
        }
        
        return {
            "total_emotions_identified": len(emotions),
            "emotions": emotions,
            "categorized": categorized,
            "feelings_wheel_uses": progress.feelings_wheel_uses,
            "kindness_tasks_completed": progress.kindness_bingo_completed,
            "calm_down_techniques": progress.calm_down_techniques_learned or []
        }
    
    async def _create_milestone(
        self, 
        child_id: str, 
        milestone_type: str,
        name: str,
        description: str,
        conversation_starters: List[str]
    ) -> None:
        """Create a milestone event."""
        milestone = MilestoneEvent(
            child_id=child_id,
            milestone_type=milestone_type,
            milestone_name=name,
            description=description,
            conversation_starters=conversation_starters
        )
        self.db.add(milestone)
