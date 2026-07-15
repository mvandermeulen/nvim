"""
Hook registry for managing and discovering handlers.
"""

from typing import Type
from .base import HookHandler, HookEventType


class HookRegistry:
    """
    Registry for managing available hook handlers.
    
    Provides a central place to register and discover handlers
    by event type or name.
    """
    
    def __init__(self):
        """Initialize the registry."""
        self._handlers: dict[str, Type[HookHandler]] = {}
        self._handlers_by_event: dict[HookEventType, list[Type[HookHandler]]] = {}
    
    def register(
        self,
        handler_class: Type[HookHandler],
        name: str | None = None,
        event_types: list[HookEventType] | None = None
    ):
        """
        Register a handler class.
        
        Args:
            handler_class: The handler class to register
            name: Optional name for the handler (defaults to class name)
            event_types: Optional list of event types this handler processes
        """
        handler_name = name or handler_class.__name__
        self._handlers[handler_name] = handler_class
        
        # Register by event types if provided
        if event_types:
            for event_type in event_types:
                if event_type not in self._handlers_by_event:
                    self._handlers_by_event[event_type] = []
                if handler_class not in self._handlers_by_event[event_type]:
                    self._handlers_by_event[event_type].append(handler_class)
    
    def unregister(self, name: str):
        """
        Unregister a handler by name.
        
        Args:
            name: Name of the handler to unregister
        """
        if name in self._handlers:
            handler_class = self._handlers[name]
            del self._handlers[name]
            
            # Remove from event type mappings
            for event_handlers in self._handlers_by_event.values():
                if handler_class in event_handlers:
                    event_handlers.remove(handler_class)
    
    def get_handler(self, name: str) -> Type[HookHandler] | None:
        """
        Get a handler class by name.
        
        Args:
            name: Name of the handler
            
        Returns:
            Handler class or None if not found
        """
        return self._handlers.get(name)
    
    def get_handlers_for_event(
        self, event_type: HookEventType
    ) -> list[Type[HookHandler]]:
        """
        Get all handler classes registered for an event type.
        
        Args:
            event_type: The event type
            
        Returns:
            List of handler classes
        """
        return self._handlers_by_event.get(event_type, []).copy()
    
    def list_handlers(self) -> list[str]:
        """
        List all registered handler names.
        
        Returns:
            List of handler names
        """
        return list(self._handlers.keys())
    
    def instantiate_handler(
        self, name: str, **kwargs
    ) -> HookHandler | None:
        """
        Instantiate a handler by name.
        
        Args:
            name: Name of the handler
            **kwargs: Arguments to pass to the handler constructor
            
        Returns:
            Handler instance or None if not found
        """
        handler_class = self.get_handler(name)
        if handler_class:
            return handler_class(**kwargs)
        return None


# Global registry instance
_global_registry = HookRegistry()


def get_global_registry() -> HookRegistry:
    """Get the global hook registry instance."""
    return _global_registry
