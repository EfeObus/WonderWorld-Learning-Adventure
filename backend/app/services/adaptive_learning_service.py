"""
WonderWorld Learning Adventure - Adaptive Learning Service
Implements the Rasch Model for personalized task selection
"""
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from typing import Optional, List, Dict, Any
import math
import numpy as np

from app.models.models import (
    Task, TaskResponse as TaskResponseModel, 
    AbilityEstimate, Child
)
from app.schemas.schemas import (
    TaskSubmission, TaskResultResponse, 
    LearningModuleEnum, ErrorTypeEnum
)
from app.config import settings


class AdaptiveLearningService:
    """
    Implements adaptive learning using the Rasch Model.
    
    The Rasch model is an Item Response Theory (IRT) model where the
    probability of a correct response depends on the difference between
    a person's ability and the item's difficulty.
    
    P(correct) = e^(B-D) / (1 + e^(B-D))
    
    Where:
    - B = Person's ability (logit scale)
    - D = Item difficulty (logit scale)
    """
    
    def __init__(self, db: AsyncSession):
        self.db = db
    
    def calculate_probability(self, ability: float, difficulty: float) -> float:
        """
        Calculate probability of correct response using Rasch model.
        
        P = e^(B-D) / (1 + e^(B-D))
        """
        logit = ability - difficulty
        # Prevent overflow
        logit = max(-10, min(10, logit))
        return math.exp(logit) / (1 + math.exp(logit))
    
    async def get_ability_estimate(
        self, 
        child_id: str, 
        module: LearningModuleEnum
    ) -> AbilityEstimate:
        """Get or create ability estimate for a child and module."""
        result = await self.db.execute(
            select(AbilityEstimate).where(
                AbilityEstimate.child_id == child_id,
                AbilityEstimate.module == module
            )
        )
        estimate = result.scalar_one_or_none()
        
        if not estimate:
            estimate = AbilityEstimate(
                child_id=child_id,
                module=module,
                ability_score=settings.initial_ability_score,
                ability_variance=settings.initial_ability_variance
            )
            self.db.add(estimate)
            await self.db.commit()
            await self.db.refresh(estimate)
        
        return estimate
    
    async def select_next_task(
        self, 
        child_id: str,
        module: LearningModuleEnum,
        task_type: Optional[str] = None
    ) -> Optional[Task]:
        """
        Select the next task using the Rasch model.
        
        Aims for tasks where P(correct) is approximately the target
        success rate (default 75% - Zone of Proximal Development).
        """
        # Get child's ability
        estimate = await self.get_ability_estimate(child_id, module)
        ability = float(estimate.ability_score)
        
        # Get child for age group
        child_result = await self.db.execute(
            select(Child).where(Child.id == child_id)
        )
        child = child_result.scalar_one_or_none()
        
        if not child:
            return None
        
        # Calculate target difficulty for desired success rate
        # From P = e^(B-D)/(1+e^(B-D)), solving for D when P = target
        # D = B - ln(P/(1-P))
        target_p = settings.target_success_rate
        target_difficulty = ability - math.log(target_p / (1 - target_p))
        
        # Get tasks within appropriate range
        query = select(Task).where(
            Task.module == module,
            Task.is_active == True,
            Task.age_group_min <= child.age_group,
            Task.age_group_max >= child.age_group
        )
        
        if task_type:
            query = query.where(Task.task_type == task_type)
        
        # Order by proximity to target difficulty
        result = await self.db.execute(query)
        tasks = result.scalars().all()
        
        if not tasks:
            return None
        
        # Find task closest to target difficulty
        best_task = min(
            tasks, 
            key=lambda t: abs(float(t.difficulty) - target_difficulty)
        )
        
        return best_task
    
    async def evaluate_response(
        self, 
        task: Task, 
        submission: TaskSubmission
    ) -> TaskResultResponse:
        """
        Evaluate a task response and update ability estimate.
        """
        # Extract child_id from response_data or task context
        child_id = submission.response_data.get("child_id")
        
        if not child_id:
            # Try to get from previous responses
            return TaskResultResponse(
                is_correct=False,
                error_type=ErrorTypeEnum.CONCEPTUAL,
                hint="Unable to process response",
                stars_earned=0,
                ability_change=0.0,
                next_task_available=True
            )
        
        # Check correctness
        is_correct = self._check_answer(task, submission.response_data)
        
        # Analyze error type if incorrect
        error_type = None
        hint = None
        if not is_correct:
            error_type, hint = self._analyze_error(task, submission.response_data)
        
        # Update ability estimate
        estimate = await self.get_ability_estimate(child_id, task.module)
        ability_change = await self._update_ability(estimate, task, is_correct)
        
        # Record response
        response = TaskResponseModel(
            child_id=child_id,
            task_id=task.id,
            is_correct=is_correct,
            response_data=submission.response_data,
            response_time_ms=submission.response_time_ms,
            error_type=error_type,
            interaction_count=submission.interaction_count
        )
        self.db.add(response)
        await self.db.commit()
        
        # Calculate stars
        stars = self._calculate_stars(is_correct, submission.response_time_ms)
        
        return TaskResultResponse(
            is_correct=is_correct,
            correct_answer=task.correct_answer,
            error_type=error_type,
            hint=hint,
            stars_earned=stars,
            ability_change=ability_change,
            next_task_available=True
        )
    
    def _check_answer(self, task: Task, response_data: Dict[str, Any]) -> bool:
        """Check if the answer is correct."""
        if not task.correct_answer:
            return True  # No correct answer defined
        
        user_answer = response_data.get("answer")
        
        # Handle different answer types
        if isinstance(task.correct_answer, dict):
            correct = task.correct_answer.get("value")
        else:
            correct = task.correct_answer
        
        return str(user_answer).lower().strip() == str(correct).lower().strip()
    
    def _analyze_error(
        self, 
        task: Task, 
        response_data: Dict[str, Any]
    ) -> tuple[Optional[ErrorTypeEnum], Optional[str]]:
        """
        Analyze the type of error made.
        
        Error types:
        - Factual: Wrong fact (e.g., 2+2=5)
        - Procedural: Wrong method (e.g., subtracted instead of added)
        - Conceptual: Misunderstanding of concept
        - Visual-Spatial: Confusion with similar-looking items
        """
        user_answer = response_data.get("answer")
        task_type = task.task_type
        hints = task.hints or []
        
        # Simple heuristics for error classification
        if task_type in ["letter_trace", "letter_recognition"]:
            # Visual-spatial errors common in letter tasks
            return ErrorTypeEnum.VISUAL_SPATIAL, hints[0] if hints else "Look carefully at the shape!"
        
        elif task_type in ["addition", "subtraction"]:
            # Check for procedural vs factual
            return ErrorTypeEnum.PROCEDURAL, hints[0] if hints else "Let's try counting on our fingers!"
        
        elif task_type in ["word_read", "phoneme_blend"]:
            return ErrorTypeEnum.CONCEPTUAL, hints[0] if hints else "Listen to each sound carefully!"
        
        return ErrorTypeEnum.FACTUAL, hints[0] if hints else "Let's try again!"
    
    async def _update_ability(
        self, 
        estimate: AbilityEstimate, 
        task: Task,
        is_correct: bool
    ) -> float:
        """
        Update ability estimate using simplified Bayesian update.
        
        Uses a learning rate to gradually adjust ability based on
        performance relative to expected probability.
        """
        ability = float(estimate.ability_score)
        difficulty = float(task.difficulty)
        
        # Calculate expected probability
        expected_p = self.calculate_probability(ability, difficulty)
        
        # Outcome (1 for correct, 0 for incorrect)
        outcome = 1 if is_correct else 0
        
        # Update ability: B_new = B_old + k * (outcome - expected_p)
        # where k is learning rate
        k = settings.ability_update_rate
        ability_change = k * (outcome - expected_p)
        
        new_ability = ability + ability_change
        
        # Update estimate
        estimate.ability_score = new_ability
        estimate.total_responses += 1
        if is_correct:
            estimate.correct_responses += 1
        
        await self.db.commit()
        
        return ability_change
    
    def _calculate_stars(self, is_correct: bool, response_time_ms: int) -> int:
        """Calculate stars earned for a response."""
        if not is_correct:
            return 0
        
        # Base star for correct answer
        stars = 1
        
        # Bonus for fast response (under 5 seconds)
        if response_time_ms < 5000:
            stars += 1
        
        # Extra bonus for very fast (under 2 seconds)
        if response_time_ms < 2000:
            stars += 1
        
        return stars
    
    async def get_ability_estimates(self, child_id: str) -> List[Dict[str, Any]]:
        """Get all ability estimates for a child."""
        result = await self.db.execute(
            select(AbilityEstimate).where(AbilityEstimate.child_id == child_id)
        )
        estimates = result.scalars().all()
        
        return [
            {
                "module": e.module.value,
                "ability_score": float(e.ability_score),
                "total_responses": e.total_responses,
                "correct_responses": e.correct_responses,
                "accuracy": e.correct_responses / e.total_responses if e.total_responses > 0 else 0
            }
            for e in estimates
        ]
