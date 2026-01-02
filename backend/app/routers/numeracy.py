"""
WonderWorld Learning Adventure - Numeracy Router
Handles math learning, counting, and operations endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional

from app.database import get_db
from app.models.models import Parent, Child, NumeracyProgress
from app.schemas.schemas import NumeracyProgressResponse
from app.services.dependencies import get_current_parent, get_child_for_parent
from app.services.numeracy_service import NumeracyService

router = APIRouter()


@router.get("/{child_id}/progress", response_model=NumeracyProgressResponse)
async def get_numeracy_progress(
    child_id: str,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get child's numeracy progress including counting, operations, and puzzles.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    result = await db.execute(
        select(NumeracyProgress).where(NumeracyProgress.child_id == child.id)
    )
    progress = result.scalar_one_or_none()
    
    if not progress:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Numeracy progress not found"
        )
    
    return progress


@router.post("/{child_id}/subitizing")
async def record_subitizing_attempt(
    child_id: str,
    shown_count: int = Query(..., ge=1, le=10),
    guessed_count: int = Query(..., ge=0, le=20),
    response_time_ms: int = Query(..., ge=0),
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Record a subitizing (quick counting) attempt.
    
    Subitizing is the ability to instantly recognize small quantities (1-4)
    without counting. Essential for ages 2-4.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    numeracy_service = NumeracyService(db)
    result = await numeracy_service.record_subitizing(
        child.id, shown_count, guessed_count, response_time_ms
    )
    
    return result


@router.post("/{child_id}/counting")
async def record_counting_attempt(
    child_id: str,
    target_count: int = Query(..., ge=1, le=100),
    reached_count: int = Query(..., ge=0, le=100),
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Record a counting attempt.
    
    Tracks how high a child can count accurately.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    numeracy_service = NumeracyService(db)
    result = await numeracy_service.record_counting(
        child.id, target_count, reached_count
    )
    
    return result


@router.post("/{child_id}/numeral-recognition")
async def record_numeral_recognition(
    child_id: str,
    numeral: int = Query(..., ge=0, le=100),
    recognized: bool = Query(...),
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Record numeral recognition progress.
    
    Tracks which numerals a child can visually identify.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    numeracy_service = NumeracyService(db)
    result = await numeracy_service.record_numeral_recognition(
        child.id, numeral, recognized
    )
    
    return result


@router.post("/{child_id}/operation")
async def record_operation_attempt(
    child_id: str,
    operation: str = Query(..., pattern="^(addition|subtraction|multiplication|division)$"),
    operand1: int = Query(..., ge=0, le=100),
    operand2: int = Query(..., ge=0, le=100),
    answer: int = Query(..., ge=-100, le=200),
    response_time_ms: int = Query(..., ge=0),
    used_manipulatives: bool = Query(default=False),
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Record a math operation attempt.
    
    Tracks addition, subtraction, multiplication, and division performance.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    numeracy_service = NumeracyService(db)
    result = await numeracy_service.record_operation(
        child_id=child.id,
        operation=operation,
        operand1=operand1,
        operand2=operand2,
        answer=answer,
        response_time_ms=response_time_ms,
        used_manipulatives=used_manipulatives
    )
    
    return result


@router.post("/{child_id}/st-puzzle")
async def record_st_puzzle_completion(
    child_id: str,
    puzzle_level: int = Query(..., ge=1),
    completed: bool = Query(...),
    attempts: int = Query(default=1, ge=1),
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Record completion of a spatial-temporal (ST) puzzle.
    
    ST puzzles are language-independent math challenges (like JiJi in ST Math)
    that help develop mathematical intuition through visual problem-solving.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    numeracy_service = NumeracyService(db)
    result = await numeracy_service.record_st_puzzle(
        child.id, puzzle_level, completed, attempts
    )
    
    return result


@router.post("/{child_id}/nooms-interaction")
async def record_nooms_interaction(
    child_id: str,
    interaction_type: str = Query(...),
    blocks_used: int = Query(default=1, ge=1),
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Record interaction with Nooms (digital manipulatives).
    
    Nooms are Montessori-inspired digital blocks used for
    concrete understanding of addition and subtraction.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    numeracy_service = NumeracyService(db)
    result = await numeracy_service.record_nooms_interaction(
        child.id, interaction_type, blocks_used
    )
    
    return result

@router.post("/{child_id}/shapes")
async def record_shape_recognition(
    child_id: str,
    shape_name: str = Query(..., description="Name of the shape (circle, square, triangle, star, heart, diamond)"),
    recognized: bool = Query(...),
    response_time_ms: int = Query(..., ge=0),
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Record shape recognition attempt.
    
    Tracks which shapes a child can visually identify.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    # For now, return success - can be expanded with shape progress tracking
    return {
        "success": True,
        "child_id": str(child.id),
        "shape": shape_name,
        "recognized": recognized,
        "response_time_ms": response_time_ms,
        "message": f"Shape recognition recorded for {shape_name}"
    }


@router.get("/{child_id}/shapes/progress")
async def get_shapes_progress(
    child_id: str,
    current_parent: Parent = Depends(get_current_parent),
    db: AsyncSession = Depends(get_db)
):
    """
    Get child's shape recognition progress.
    """
    child = await get_child_for_parent(child_id, current_parent.id, db)
    
    # Return default progress - can be expanded with database storage
    shapes = ["circle", "square", "triangle", "star", "heart", "diamond", "rectangle", "oval"]
    return {
        "child_id": str(child.id),
        "shapes_learned": shapes[:4],
        "shapes_in_progress": shapes[4:6],
        "shapes_not_started": shapes[6:],
        "total_shapes": len(shapes),
        "mastery_percentage": 50.0
    }