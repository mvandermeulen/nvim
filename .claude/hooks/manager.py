"""
Hook manager for coordinating the hook system.
"""

import os
import yaml
from pathlib import Path
from typing import Any
from .base import HookReceiver, HookEvent, HookEventType
from .registry import HookRegistry, get_global_registry


class HookManager:
    """
    High-level manager for the hook system.
    
    Coordinates the receiver, handlers, and configuration.
    """
    
    def __init__(
        self,
        config_path: Path | None = None,
        registry: HookRegistry | None = None
    ):
        """
        Initialize the hook manager.
        
        Args:
            config_path: Optional path to configuration file
            registry: Optional hook registry (uses global if not provided)
        """
        self.receiver = HookReceiver()
        self.registry = registry or get_global_registry()
        self.config: dict[str, Any] = {}
        
        if config_path:
            self.load_config(config_path)
    
    def load_config(self, config_path: Path):
        """
        Load configuration from a YAML file.
        
        Args:
            config_path: Path to the configuration file
        """
        if not config_path.exists():
            raise FileNotFoundError(f"Configuration file not found: {config_path}")
        
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f) or {}
        
        # Auto-configure handlers from config
        self._configure_handlers()
    
    def _configure_handlers(self):
        """Configure handlers based on loaded configuration."""
        handlers_config = self.config.get('handlers', [])
        
        for handler_config in handlers_config:
            handler_name = handler_config.get('name')
            enabled = handler_config.get('enabled', True)
            params = handler_config.get('params', {})
            
            if handler_name and enabled:
                handler = self.registry.instantiate_handler(handler_name, **params)
                if handler:
                    self.receiver.register_handler(handler)
    
    def send_event(
        self,
        event_type: HookEventType,
        source: str,
        data: dict[str, Any] | None = None,
        metadata: dict[str, Any] | None = None
    ) -> list[Any]:
        """
        Send an event to the hook system.
        
        Args:
            event_type: Type of event
            source: Source of the event
            data: Event data
            metadata: Event metadata
            
        Returns:
            List of results from handlers
        """
        event = HookEvent(
            event_type=event_type,
            source=source,
            data=data or {},
            metadata=metadata or {}
        )
        return self.receiver.receive(event)
    
    def register_handler(self, handler):
        """
        Register a handler instance.
        
        Args:
            handler: Handler instance to register
        """
        self.receiver.register_handler(handler)
    
    def get_event_log(self, limit: int | None = None) -> list[HookEvent]:
        """
        Get the event log.
        
        Args:
            limit: Maximum number of events to return
            
        Returns:
            List of events
        """
        return self.receiver.get_event_log(limit)
    
    def save_config(self, config_path: Path):
        """
        Save current configuration to a YAML file.
        
        Args:
            config_path: Path where to save the configuration
        """
        with open(config_path, 'w') as f:
            yaml.dump(self.config, f, default_flow_style=False)
