"""
Robust Hook Receiver and Management System

This module provides an extensible hook system for receiving and processing
events from various agentic tools (claude, codex, opencode, copilot-cli, gemini-cli).
"""

from .directories import Directories, DIRECTORIES
from .base import HookReceiver, HookHandler, HookEvent, HookEventType
from .manager import HookManager
from .registry import HookRegistry



__all__ = [
    "DIRECTORIES",
    "HookReceiver",
    "HookHandler", 
    "HookEvent",
    "HookEventType",
    "HookManager",
    "HookRegistry",
]
