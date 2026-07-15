"""
Base classes for the hook system.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import Any
from datetime import datetime
from enum import Enum


class HookEventType(Enum):
    """Types of hook events that can be processed."""
    
    # Agent events
    AGENT_STARTED = "agent.started"
    AGENT_STOPPED = "agent.stopped"
    AGENT_ERROR = "agent.error"
    
    # Skill/Command events
    SKILL_DISCOVERED = "skill.discovered"
    SKILL_EXECUTED = "skill.executed"
    SKILL_FAILED = "skill.failed"
    
    # Command events
    COMMAND_DISCOVERED = "command.discovered"
    COMMAND_EXECUTED = "command.executed"
    COMMAND_FAILED = "command.failed"
    
    # Library events
    LIBRARY_SCANNED = "library.scanned"
    LIBRARY_UPDATED = "library.updated"
    
    # Configuration events
    CONFIG_LOADED = "config.loaded"
    CONFIG_UPDATED = "config.updated"
    
    # Custom events
    CUSTOM = "custom"


@dataclass
class HookEvent:
    """
    Represents a hook event with metadata.
    
    Attributes:
        event_type: The type of event
        source: The source tool that triggered the event (e.g., 'claude', 'codex')
        data: Event-specific data payload
        timestamp: When the event occurred
        metadata: Additional metadata
    """
    
    event_type: HookEventType
    source: str
    data: dict[str, Any] = field(default_factory=dict)
    timestamp: datetime = field(default_factory=datetime.utcnow)
    metadata: dict[str, Any] = field(default_factory=dict)
    
    def to_dict(self) -> dict[str, Any]:
        """Convert event to dictionary representation."""
        return {
            "event_type": self.event_type.value,
            "source": self.source,
            "data": self.data,
            "timestamp": self.timestamp.isoformat(),
            "metadata": self.metadata,
        }


class HookHandler(ABC):
    """
    Abstract base class for hook handlers.
    
    Handlers implement the actual logic for processing hook events.
    Each handler can be registered to handle specific event types.
    """
    
    def __init__(self, name: str | None = None):
        """
        Initialize the handler.
        
        Args:
            name: Optional name for the handler
        """
        self.name = name or self.__class__.__name__
        self.enabled = True
    
    @abstractmethod
    def can_handle(self, event: HookEvent) -> bool:
        """
        Determine if this handler can process the given event.
        
        Args:
            event: The event to check
            
        Returns:
            True if the handler can process this event
        """
        pass
    
    @abstractmethod
    def handle(self, event: HookEvent) -> Any:
        """
        Process the hook event.
        
        Args:
            event: The event to process
            
        Returns:
            Result of processing (implementation-specific)
        """
        pass
    
    def enable(self):
        """Enable this handler."""
        self.enabled = True
    
    def disable(self):
        """Disable this handler."""
        self.enabled = False


class HookReceiver:
    """
    Main entry point for receiving and routing hook events.
    
    The receiver accepts events from various sources and routes them
    to registered handlers.
    """
    
    def __init__(self):
        """Initialize the hook receiver."""
        self.handlers: list[HookHandler] = []
        self._event_log: list[HookEvent] = []
        self.max_log_size = 1000
    
    def register_handler(self, handler: HookHandler):
        """
        Register a handler to process events.
        
        Args:
            handler: The handler to register
        """
        if handler not in self.handlers:
            self.handlers.append(handler)
    
    def unregister_handler(self, handler: HookHandler):
        """
        Unregister a handler.
        
        Args:
            handler: The handler to unregister
        """
        if handler in self.handlers:
            self.handlers.remove(handler)
    
    def receive(self, event: HookEvent) -> list[Any]:
        """
        Receive and process a hook event.
        
        The event is passed to all registered handlers that can handle it.
        
        Args:
            event: The event to process
            
        Returns:
            List of results from handlers
        """
        # Log the event
        self._log_event(event)
        
        # Process with handlers
        results = []
        for handler in self.handlers:
            if handler.enabled and handler.can_handle(event):
                try:
                    result = handler.handle(event)
                    results.append(result)
                except Exception as e:
                    # Log handler error but continue processing
                    error_event = HookEvent(
                        event_type=HookEventType.AGENT_ERROR,
                        source="hook_receiver",
                        data={
                            "handler": handler.name,
                            "error": str(e),
                            "original_event": event.to_dict(),
                        }
                    )
                    self._log_event(error_event)
        
        return results
    
    def _log_event(self, event: HookEvent):
        """
        Log an event to the internal event log.
        
        Args:
            event: The event to log
        """
        self._event_log.append(event)
        
        # Trim log if it exceeds max size
        if len(self._event_log) > self.max_log_size:
            self._event_log = self._event_log[-self.max_log_size:]
    
    def get_event_log(self, limit: int | None = None) -> list[HookEvent]:
        """
        Get the event log.
        
        Args:
            limit: Maximum number of events to return (most recent)
            
        Returns:
            List of events
        """
        if limit is None:
            return self._event_log.copy()
        return self._event_log[-limit:]
    
    def clear_log(self):
        """Clear the event log."""
        self._event_log.clear()
