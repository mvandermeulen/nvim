"""
Example and built-in hook handlers.
"""

from typing import Any
from .base import HookHandler, HookEvent, HookEventType
import json
from pathlib import Path
from datetime import datetime


class LoggingHandler(HookHandler):
    """
    Handler that logs all events to a file.
    """
    
    def __init__(self, log_path: str = "/tmp/hook_events.log", name: str = "LoggingHandler"):
        """
        Initialize the logging handler.
        
        Args:
            log_path: Path to the log file
            name: Handler name
        """
        super().__init__(name)
        self.log_path = Path(log_path)
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
    
    def can_handle(self, event: HookEvent) -> bool:
        """Can handle all events."""
        return True
    
    def handle(self, event: HookEvent) -> Any:
        """Log the event to file."""
        with open(self.log_path, 'a') as f:
            log_entry = {
                'timestamp': event.timestamp.isoformat(),
                'event_type': event.event_type.value,
                'source': event.source,
                'data': event.data,
                'metadata': event.metadata,
            }
            f.write(json.dumps(log_entry) + '\n')
        return True


class SkillDiscoveryHandler(HookHandler):
    """
    Handler for skill discovery events.
    """
    
    def __init__(self, name: str = "SkillDiscoveryHandler"):
        super().__init__(name)
        self.discovered_skills = []
    
    def can_handle(self, event: HookEvent) -> bool:
        """Handle skill discovery events."""
        return event.event_type == HookEventType.SKILL_DISCOVERED
    
    def handle(self, event: HookEvent) -> Any:
        """Process skill discovery."""
        skill_name = event.data.get('skill_name')
        skill_path = event.data.get('skill_path')
        
        if skill_name:
            self.discovered_skills.append({
                'name': skill_name,
                'path': skill_path,
                'source': event.source,
                'discovered_at': event.timestamp,
            })
        
        return {'processed': True, 'skill_name': skill_name}


class CommandExecutionHandler(HookHandler):
    """
    Handler for command execution events.
    """
    
    def __init__(self, name: str = "CommandExecutionHandler"):
        super().__init__(name)
        self.execution_history = []
    
    def can_handle(self, event: HookEvent) -> bool:
        """Handle command execution events."""
        return event.event_type in [
            HookEventType.COMMAND_EXECUTED,
            HookEventType.COMMAND_FAILED
        ]
    
    def handle(self, event: HookEvent) -> Any:
        """Process command execution."""
        command = event.data.get('command')
        status = 'success' if event.event_type == HookEventType.COMMAND_EXECUTED else 'failed'
        
        self.execution_history.append({
            'command': command,
            'status': status,
            'source': event.source,
            'timestamp': event.timestamp,
            'details': event.data,
        })
        
        return {'processed': True, 'command': command, 'status': status}


class AgentLifecycleHandler(HookHandler):
    """
    Handler for agent lifecycle events.
    """
    
    def __init__(self, name: str = "AgentLifecycleHandler"):
        super().__init__(name)
        self.active_agents = {}
    
    def can_handle(self, event: HookEvent) -> bool:
        """Handle agent lifecycle events."""
        return event.event_type in [
            HookEventType.AGENT_STARTED,
            HookEventType.AGENT_STOPPED,
            HookEventType.AGENT_ERROR
        ]
    
    def handle(self, event: HookEvent) -> Any:
        """Process agent lifecycle events."""
        agent_id = event.data.get('agent_id', event.source)
        
        if event.event_type == HookEventType.AGENT_STARTED:
            self.active_agents[agent_id] = {
                'started_at': event.timestamp,
                'source': event.source,
                'status': 'running',
            }
        elif event.event_type == HookEventType.AGENT_STOPPED:
            if agent_id in self.active_agents:
                self.active_agents[agent_id]['status'] = 'stopped'
                self.active_agents[agent_id]['stopped_at'] = event.timestamp
        elif event.event_type == HookEventType.AGENT_ERROR:
            if agent_id in self.active_agents:
                self.active_agents[agent_id]['status'] = 'error'
                self.active_agents[agent_id]['error'] = event.data.get('error')
        
        return {'processed': True, 'agent_id': agent_id, 'active_agents': len(self.active_agents)}
