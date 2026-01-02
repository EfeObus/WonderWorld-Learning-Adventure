"""
WonderWorld Learning Adventure - Numeracy Service
Handles math learning, counting, and operations logic
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import Dict, Any
from datetime import datetime

from app.models.models import NumeracyProgress


class NumeracyService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def _get_progress(self, child_id: str) -> NumeracyProgress:
        """Get or create numeracy progress."""
        result = await self.db.execute(
            select(NumeracyProgress).where(NumeracyProgress.child_id == child_id)
        )
        return result.scalar_one_or_none()
    
    async def record_subitizing(
        self, 
        child_id: str, 
        shown_count: int, 
        guessed_count: int,
        response_time_ms: int
    ) -> Dict[str, Any]:
        """
        Record a subitizing attempt.
        
        Subitizing is the ability to instantly recognize small quantities.
        - 1-3: Should be instant (< 1 second)
        - 4-6: May require counting
        """
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        is_correct = shown_count == guessed_count
        is_fast = response_time_ms < 2000  # Under 2 seconds
        
        # Update subitizing mastery
        # Weight by correctness and speed
        if is_correct and is_fast and shown_count <= 4:
            # Perfect subitizing
            progress.subitizing_mastery = min(100, progress.subitizing_mastery + 2)
        elif is_correct:
            progress.subitizing_mastery = min(100, progress.subitizing_mastery + 1)
        else:
            progress.subitizing_mastery = max(0, progress.subitizing_mastery - 0.5)
        
        await self.db.commit()
        
        return {
            "is_correct": is_correct,
            "is_fast": is_fast,
            "subitizing_mastery": float(progress.subitizing_mastery)
        }
    
    async def record_counting(
        self, 
        child_id: str, 
        target_count: int, 
        reached_count: int
    ) -> Dict[str, Any]:
        """
        Record a counting attempt.
        
        Update the counting range (how high they can count).
        """
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        # Update counting range if they reached higher
        if reached_count >= target_count and target_count > progress.counting_range:
            progress.counting_range = target_count
        
        await self.db.commit()
        
        return {
            "target": target_count,
            "reached": reached_count,
            "counting_range": progress.counting_range
        }
    
    async def record_numeral_recognition(
        self, 
        child_id: str, 
        numeral: int, 
        recognized: bool
    ) -> Dict[str, Any]:
        """
        Record numeral recognition progress.
        """
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        numeral_recognition = progress.numeral_recognition or {}
        numeral_recognition[str(numeral)] = recognized
        progress.numeral_recognition = numeral_recognition
        
        await self.db.commit()
        
        recognized_count = sum(1 for v in numeral_recognition.values() if v)
        
        return {
            "numeral": numeral,
            "recognized": recognized,
            "total_recognized": recognized_count
        }
    
    async def record_operation(
        self, 
        child_id: str, 
        operation: str,
        operand1: int,
        operand2: int,
        answer: int,
        response_time_ms: int,
        used_manipulatives: bool
    ) -> Dict[str, Any]:
        """
        Record a math operation attempt.
        """
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        # Calculate correct answer
        if operation == "addition":
            correct = operand1 + operand2
            mastery_attr = "addition_mastery"
        elif operation == "subtraction":
            correct = operand1 - operand2
            mastery_attr = "subtraction_mastery"
        else:  # multiplication
            correct = operand1 * operand2
            mastery_attr = "multiplication_intro"
        
        is_correct = answer == correct
        
        # Update mastery
        current_mastery = getattr(progress, mastery_attr)
        if is_correct:
            # Bigger bonus if not using manipulatives
            bonus = 1.5 if not used_manipulatives else 1.0
            new_mastery = min(100, current_mastery + bonus)
        else:
            new_mastery = max(0, current_mastery - 0.5)
        
        setattr(progress, mastery_attr, new_mastery)
        await self.db.commit()
        
        return {
            "operation": operation,
            "problem": f"{operand1} {'+' if operation == 'addition' else '-' if operation == 'subtraction' else '×'} {operand2}",
            "answer_given": answer,
            "correct_answer": correct,
            "is_correct": is_correct,
            "mastery": float(new_mastery)
        }
    
    async def record_st_puzzle(
        self, 
        child_id: str, 
        puzzle_level: int, 
        completed: bool,
        attempts: int
    ) -> Dict[str, Any]:
        """
        Record ST (spatial-temporal) puzzle completion.
        
        ST puzzles are language-independent visual math challenges.
        """
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        if completed:
            progress.st_puzzles_completed += 1
            
            # Level up if completed current level
            if puzzle_level >= progress.st_current_level:
                progress.st_current_level = puzzle_level + 1
        
        await self.db.commit()
        
        return {
            "puzzle_level": puzzle_level,
            "completed": completed,
            "attempts": attempts,
            "total_completed": progress.st_puzzles_completed,
            "current_level": progress.st_current_level
        }
    
    async def record_nooms_interaction(
        self, 
        child_id: str, 
        interaction_type: str,
        blocks_used: int
    ) -> Dict[str, Any]:
        """
        Record interaction with Nooms (digital manipulatives).
        
        Nooms are Montessori-inspired digital blocks.
        """
        progress = await self._get_progress(child_id)
        if not progress:
            return {"error": "Progress not found"}
        
        progress.nooms_interactions += 1
        await self.db.commit()
        
        return {
            "interaction_type": interaction_type,
            "blocks_used": blocks_used,
            "total_interactions": progress.nooms_interactions
        }
