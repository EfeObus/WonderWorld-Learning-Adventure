"""
WonderWorld Learning Adventure - Literacy Service
Handles letter tracing, phonics, and word learning logic
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from typing import List, Dict, Any, Optional
from datetime import datetime

from app.models.models import (
    LiteracyProgress, TracingSession, Word, WordProgress, LetterGroup
)
from app.schemas.schemas import WordsByLevel, WordLevelEnum


class LiteracyService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    # Letter groups based on developmental order
    LETTER_GROUPS = {
        "straight_lines": ["L", "F", "E", "H", "T", "I"],
        "curves": ["C", "O", "Q", "G", "S"],
        "diagonals": ["A", "V", "W", "M", "N", "K", "X", "Y", "Z"],
        "mixed": ["B", "D", "J", "P", "R", "U"]
    }
    
    async def update_letter_mastery(
        self, 
        child_id: str, 
        letter: str, 
        accuracy: float
    ) -> Dict[str, Any]:
        """
        Update mastery level for a specific letter.
        
        Uses weighted average with more recent attempts having higher weight.
        """
        letter = letter.upper()
        
        # Get literacy progress
        result = await self.db.execute(
            select(LiteracyProgress).where(LiteracyProgress.child_id == child_id)
        )
        progress = result.scalar_one_or_none()
        
        if not progress:
            return {"error": "Progress not found"}
        
        # Update letter mastery
        letter_mastery = progress.letter_mastery or {}
        
        if letter not in letter_mastery:
            letter_mastery[letter] = {
                "traced": True,
                "sound_known": False,
                "mastery": accuracy / 100,
                "attempts": 1
            }
        else:
            # Weighted average: 70% new score, 30% previous
            current = letter_mastery[letter]
            new_mastery = (accuracy / 100 * 0.7) + (current.get("mastery", 0) * 0.3)
            letter_mastery[letter] = {
                "traced": True,
                "sound_known": current.get("sound_known", False),
                "mastery": min(1.0, new_mastery),
                "attempts": current.get("attempts", 0) + 1
            }
        
        progress.letter_mastery = letter_mastery
        
        # Update average tracing accuracy
        all_mastery = [v.get("mastery", 0) for v in letter_mastery.values()]
        progress.tracing_accuracy = sum(all_mastery) / len(all_mastery) * 100
        
        await self.db.commit()
        
        return {
            "letter": letter,
            "mastery": letter_mastery[letter]["mastery"],
            "overall_accuracy": progress.tracing_accuracy
        }
    
    async def get_word_progress_by_level(self, child_id: str) -> List[WordsByLevel]:
        """
        Get word learning progress organized by level.
        """
        results = []
        
        for level in WordLevelEnum:
            # Get all words at this level
            word_result = await self.db.execute(
                select(Word).where(
                    Word.level == level,
                    Word.is_active == True
                ).order_by(Word.difficulty)
            )
            words = word_result.scalars().all()
            
            # Get mastered count
            mastered_result = await self.db.execute(
                select(func.count(WordProgress.id)).where(
                    WordProgress.child_id == child_id,
                    WordProgress.is_mastered == True
                ).join(Word).where(Word.level == level)
            )
            mastered_count = mastered_result.scalar() or 0
            
            results.append(WordsByLevel(
                level=level,
                total_count=len(words),
                mastered_count=mastered_count,
                words=words
            ))
        
        return results
    
    async def record_word_practice(
        self, 
        child_id: str, 
        word_id: str, 
        is_correct: bool
    ) -> WordProgress:
        """
        Record a word practice attempt and update mastery.
        """
        # Get or create word progress
        result = await self.db.execute(
            select(WordProgress).where(
                WordProgress.child_id == child_id,
                WordProgress.word_id == word_id
            )
        )
        progress = result.scalar_one_or_none()
        
        if not progress:
            progress = WordProgress(
                child_id=child_id,
                word_id=word_id
            )
            self.db.add(progress)
        
        # Update stats
        progress.times_practiced += 1
        if is_correct:
            progress.times_correct += 1
        
        progress.last_practiced_at = datetime.utcnow()
        
        # Calculate mastery score
        if progress.times_practiced >= 3:
            mastery = progress.times_correct / progress.times_practiced
            progress.mastery_score = mastery * 100
            
            # Consider mastered if 80%+ accuracy over 5+ attempts
            if progress.times_practiced >= 5 and mastery >= 0.8:
                if not progress.is_mastered:
                    progress.is_mastered = True
                    progress.mastered_at = datetime.utcnow()
                    
                    # Update literacy progress count
                    await self._update_words_mastered_count(child_id)
        
        await self.db.commit()
        await self.db.refresh(progress)
        
        return progress
    
    async def _update_words_mastered_count(self, child_id: str):
        """Update the word mastery counts in literacy progress."""
        # Get literacy progress
        result = await self.db.execute(
            select(LiteracyProgress).where(LiteracyProgress.child_id == child_id)
        )
        progress = result.scalar_one_or_none()
        
        if not progress:
            return
        
        # Count mastered words by level
        for level, attr in [
            (WordLevelEnum.TWO_LETTER, "two_letter_words_mastered"),
            (WordLevelEnum.THREE_LETTER, "three_letter_words_mastered"),
            (WordLevelEnum.FOUR_LETTER, "four_letter_words_mastered"),
            (WordLevelEnum.FIVE_LETTER, "five_letter_words_mastered"),
        ]:
            count_result = await self.db.execute(
                select(func.count(WordProgress.id)).where(
                    WordProgress.child_id == child_id,
                    WordProgress.is_mastered == True
                ).join(Word).where(Word.level == level)
            )
            count = count_result.scalar() or 0
            setattr(progress, attr, count)
    
    async def get_letter_groups_progress(self, child_id: str) -> Dict[str, Any]:
        """
        Get progress on letter groups (developmental teaching order).
        """
        # Get literacy progress
        result = await self.db.execute(
            select(LiteracyProgress).where(LiteracyProgress.child_id == child_id)
        )
        progress = result.scalar_one_or_none()
        
        letter_mastery = progress.letter_mastery if progress else {}
        
        groups = {}
        for group_name, letters in self.LETTER_GROUPS.items():
            mastered = []
            in_progress = []
            not_started = []
            
            for letter in letters:
                if letter in letter_mastery:
                    if letter_mastery[letter].get("mastery", 0) >= 0.8:
                        mastered.append(letter)
                    else:
                        in_progress.append(letter)
                else:
                    not_started.append(letter)
            
            groups[group_name] = {
                "letters": letters,
                "mastered": mastered,
                "in_progress": in_progress,
                "not_started": not_started,
                "completion_percentage": len(mastered) / len(letters) * 100
            }
        
        # Determine recommended next group
        recommended = None
        for group_name in ["straight_lines", "curves", "diagonals", "mixed"]:
            if groups[group_name]["completion_percentage"] < 100:
                recommended = group_name
                break
        
        return {
            "groups": groups,
            "recommended_group": recommended
        }
