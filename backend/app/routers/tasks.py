"""
WonderWorld Learning Adventure - Tasks Router
Handles adaptive learning task selection and responses
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List

from app.database import get_db
from app.models.models import Parent, Child, Task, TaskResponse as TaskResponseModel
from app.schemas.schemas import (
    TaskResponse, TaskSubmission, TaskResultResponse, 
    AdaptiveTaskRequest, LearningModuleEnum
)
from app.services.dependencies import get_current_parent, get_child_for_parent
from app.services.adaptive_learning_service import AdaptiveLearningService

router = APIRouter()


@router.post("/next", response_model=TaskResponse)
async def get_next_task(
    request: AdaptiveTaskRequest,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get the next adaptive task for a child.
    
    Uses the Rasch Model to select a task where the probability
    of success is approximately 75% (Zone of Proximal Development).
    
    P = e^(B-D) / (1 + e^(B-D))
    
    Where:
    - B = Child's ability level
    - D = Task difficulty
    """
    child = await get_child_for_parent(request.child_id, current_parent.id, db)
    
    adaptive_service = AdaptiveLearningService(db)
    task = await adaptive_service.select_next_task(
        child_id=child.id,
        module=request.module,
        task_type=request.task_type
    )
    
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No suitable tasks available"
        )
    
    return task


@router.post("/submit", response_model=TaskResultResponse)
async def submit_task_response(
    submission: TaskSubmission,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Submit a response to a task.
    
    The system will:
    1. Evaluate correctness
    2. Categorize any errors (factual, procedural, conceptual, visual-spatial)
    3. Update the child's ability estimate using Bayesian estimation
    4. Provide appropriate scaffolding if needed
    """
    # Get the task
    result = await db.execute(
        select(Task).where(Task.id == submission.task_id)
    )
    task = result.scalar_one_or_none()
    
    if not task:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Task not found"
        )
    
    adaptive_service = AdaptiveLearningService(db)
    result = await adaptive_service.evaluate_response(task, submission)
    
    return result


@router.get("/{child_id}/history")
async def get_task_history(
    child_id: str,
    module: LearningModuleEnum = None,
    limit: int = 50,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get a child's task response history.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    query = select(TaskResponseModel).where(TaskResponseModel.child_id == child.id)
    
    if module:
        query = query.join(Task).where(Task.module == module)
    
    query = query.order_by(TaskResponseModel.created_at.desc()).limit(limit)
    
    result = await db.execute(query)
    responses = result.scalars().all()
    
    return responses


@router.get("/{child_id}/ability")
async def get_ability_estimates(
    child_id: str,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get a child's ability estimates across all modules.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    adaptive_service = AdaptiveLearningService(db)
    abilities = await adaptive_service.get_ability_estimates(child.id)
    
    return abilities
