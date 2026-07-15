"""
Intelligence Layer - Smart session resume and pattern recognition

Modules:
- smart_resume: Load session context optimized for tokens
- decision_learning: Learn from past architectural decisions
- pattern_recognition: Find similar sessions and estimate effort
- context_optimizer: Prioritize essential context for token efficiency
"""

from .smart_resume import load_session_context

__all__ = ['load_session_context']
