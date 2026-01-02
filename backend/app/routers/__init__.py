"""
WonderWorld Learning Adventure - API Routers
NOTE: Auth router disabled - kids play directly without login
"""
from app.routers import children, literacy, numeracy, tasks, game, parent_dashboard, sel

__all__ = [
    "children", 
    "literacy",
    "numeracy",
    "tasks",
    "game",
    "parent_dashboard",
    "sel"
]
