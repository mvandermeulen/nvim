"""
Library manager for managing discovered libraries.
"""

from pathlib import Path
from typing import Any
import json
import yaml
from .discovery import LibraryDiscovery


class LibraryManager:
    """
    Manager for organizing and accessing discovered libraries.
    """
    
    def __init__(self, cache_path: Path | None = None):
        """
        Initialize the library manager.
        
        Args:
            cache_path: Optional path to cache discovered libraries
        """
        self.discovery = LibraryDiscovery()
        self.cache_path = cache_path
        self._cache: dict[str, list[dict[str, Any]]] = {
            'agents': [],
            'skills': [],
            'commands': [],
        }
    
    def add_search_path(self, path: Path):
        """
        Add a search path.
        
        Args:
            path: Path to add
        """
        self.discovery.add_search_path(path)
    
    def refresh(self):
        """Refresh the cache by re-scanning all paths."""
        self._cache = self.discovery.discover_all()
        
        if self.cache_path:
            self._save_cache()
    
    def _save_cache(self):
        """Save cache to disk."""
        if not self.cache_path:
            return
        
        self.cache_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(self.cache_path, 'w') as f:
            json.dump(self._cache, f, indent=2)
    
    def _load_cache(self):
        """Load cache from disk."""
        if not self.cache_path or not self.cache_path.exists():
            return
        
        with open(self.cache_path, 'r') as f:
            self._cache = json.load(f)
    
    def get_agents(self) -> list[dict[str, Any]]:
        """
        Get all discovered agents.
        
        Returns:
            List of agents
        """
        if not self._cache['agents']:
            self.refresh()
        return self._cache['agents']
    
    def get_skills(self) -> list[dict[str, Any]]:
        """
        Get all discovered skills.
        
        Returns:
            List of skills
        """
        if not self._cache['skills']:
            self.refresh()
        return self._cache['skills']
    
    def get_commands(self) -> list[dict[str, Any]]:
        """
        Get all discovered commands.
        
        Returns:
            List of commands
        """
        if not self._cache['commands']:
            self.refresh()
        return self._cache['commands']
    
    def find_by_name(self, name: str, item_type: str | None = None) -> list[dict[str, Any]]:
        """
        Find items by name.
        
        Args:
            name: Name to search for
            item_type: Optional type filter ('agent', 'skill', 'command')
            
        Returns:
            List of matching items
        """
        results = []
        
        if item_type is None or item_type == 'agent':
            results.extend([a for a in self.get_agents() if a['name'] == name])
        
        if item_type is None or item_type == 'skill':
            results.extend([s for s in self.get_skills() if s['name'] == name])
        
        if item_type is None or item_type == 'command':
            results.extend([c for c in self.get_commands() if c['name'] == name])
        
        return results
    
    def get_summary(self) -> dict[str, int]:
        """
        Get summary statistics.
        
        Returns:
            Dictionary with counts
        """
        agents = self.get_agents()
        skills = self.get_skills()
        commands = self.get_commands()
        
        return {
            'agents': len(agents),
            'skills': len(skills),
            'commands': len(commands),
            'total': len(agents) + len(skills) + len(commands),
        }
