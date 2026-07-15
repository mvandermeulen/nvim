"""
Library discovery utilities.
"""

from pathlib import Path
from typing import Any
from .scanner import AgentScanner, SkillScanner, CommandScanner


class LibraryDiscovery:
    """
    Unified interface for discovering agents, skills, and commands.
    """
    
    def __init__(self):
        """Initialize the discovery system."""
        self.agent_scanner = AgentScanner()
        self.skill_scanner = SkillScanner()
        self.command_scanner = CommandScanner()
    
    def add_search_path(self, path: Path):
        """
        Add a search path to all scanners.
        
        Args:
            path: Path to add
        """
        self.agent_scanner.add_search_path(path)
        self.skill_scanner.add_search_path(path)
        self.command_scanner.add_search_path(path)
    
    def discover_all(self) -> dict[str, list[dict[str, Any]]]:
        """
        Discover all agents, skills, and commands.
        
        Returns:
            Dictionary with 'agents', 'skills', and 'commands' keys
        """
        return {
            'agents': self.agent_scanner.scan(),
            'skills': self.skill_scanner.scan(),
            'commands': self.command_scanner.scan(),
        }
    
    def discover_agents(self) -> list[dict[str, Any]]:
        """
        Discover agents.
        
        Returns:
            List of discovered agents
        """
        return self.agent_scanner.scan()
    
    def discover_skills(self) -> list[dict[str, Any]]:
        """
        Discover skills.
        
        Returns:
            List of discovered skills
        """
        return self.skill_scanner.scan()
    
    def discover_commands(self) -> list[dict[str, Any]]:
        """
        Discover commands.
        
        Returns:
            List of discovered commands
        """
        return self.command_scanner.scan()
    
    def get_summary(self) -> dict[str, int]:
        """
        Get a summary of discovered items.
        
        Returns:
            Dictionary with counts
        """
        results = self.discover_all()
        return {
            'agents': len(results['agents']),
            'skills': len(results['skills']),
            'commands': len(results['commands']),
            'total': len(results['agents']) + len(results['skills']) + len(results['commands']),
        }
