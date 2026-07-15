"""
Library scanners for discovering agents, skills, and commands.
"""

from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any
import json
import yaml


class LibraryScanner(ABC):
    """
    Abstract base class for library scanners.
    """
    
    def __init__(self, search_paths: list[Path] | None = None):
        """
        Initialize the scanner.
        
        Args:
            search_paths: Paths to search for libraries
        """
        self.search_paths = search_paths or []
        self.discovered_items: list[dict[str, Any]] = []
    
    @abstractmethod
    def scan(self) -> list[dict[str, Any]]:
        """
        Scan for items in the configured paths.
        
        Returns:
            List of discovered items
        """
        pass
    
    def add_search_path(self, path: Path):
        """Add a path to search."""
        if path not in self.search_paths:
            self.search_paths.append(path)
    
    def _load_metadata(self, metadata_file: Path) -> dict[str, Any]:
        """
        Load metadata from a JSON or YAML file.
        
        Args:
            metadata_file: Path to metadata file
            
        Returns:
            Metadata dictionary
        """
        if not metadata_file.exists():
            return {}
        
        with open(metadata_file, 'r') as f:
            if metadata_file.suffix in ['.yaml', '.yml']:
                return yaml.safe_load(f) or {}
            elif metadata_file.suffix == '.json':
                return json.load(f)
        
        return {}


class AgentScanner(LibraryScanner):
    """
    Scanner for discovering agent libraries.
    """
    
    def scan(self) -> list[dict[str, Any]]:
        """
        Scan for agent libraries.
        
        Looks for:
        - Directories with 'agent.yaml' or 'agent.json'
        - Python files with agent definitions
        
        Returns:
            List of discovered agents
        """
        self.discovered_items.clear()
        
        for search_path in self.search_paths:
            if not search_path.exists():
                continue
            
            # Look for agent metadata files
            for agent_file in search_path.rglob('agent.yaml'):
                metadata = self._load_metadata(agent_file)
                self.discovered_items.append({
                    'type': 'agent',
                    'name': metadata.get('name', agent_file.parent.name),
                    'path': str(agent_file.parent),
                    'metadata': metadata,
                })
            
            for agent_file in search_path.rglob('agent.json'):
                metadata = self._load_metadata(agent_file)
                self.discovered_items.append({
                    'type': 'agent',
                    'name': metadata.get('name', agent_file.parent.name),
                    'path': str(agent_file.parent),
                    'metadata': metadata,
                })
        
        return self.discovered_items


class SkillScanner(LibraryScanner):
    """
    Scanner for discovering skill libraries.
    """
    
    def scan(self) -> list[dict[str, Any]]:
        """
        Scan for skill libraries.
        
        Looks for:
        - Directories with 'skill.yaml' or 'skill.json'
        - Python files with skill definitions
        
        Returns:
            List of discovered skills
        """
        self.discovered_items.clear()
        
        for search_path in self.search_paths:
            if not search_path.exists():
                continue
            
            # Look for skill metadata files
            for skill_file in search_path.rglob('skill.yaml'):
                metadata = self._load_metadata(skill_file)
                self.discovered_items.append({
                    'type': 'skill',
                    'name': metadata.get('name', skill_file.parent.name),
                    'path': str(skill_file.parent),
                    'metadata': metadata,
                })
            
            for skill_file in search_path.rglob('skill.json'):
                metadata = self._load_metadata(skill_file)
                self.discovered_items.append({
                    'type': 'skill',
                    'name': metadata.get('name', skill_file.parent.name),
                    'path': str(skill_file.parent),
                    'metadata': metadata,
                })
        
        return self.discovered_items


class CommandScanner(LibraryScanner):
    """
    Scanner for discovering command libraries.
    """
    
    def scan(self) -> list[dict[str, Any]]:
        """
        Scan for command libraries.
        
        Looks for:
        - Directories with 'commands.yaml' or 'commands.json'
        - Shell scripts and executables
        
        Returns:
            List of discovered commands
        """
        self.discovered_items.clear()
        
        for search_path in self.search_paths:
            if not search_path.exists():
                continue
            
            # Look for command metadata files
            for cmd_file in search_path.rglob('commands.yaml'):
                metadata = self._load_metadata(cmd_file)
                commands = metadata.get('commands', [])
                for cmd in commands:
                    self.discovered_items.append({
                        'type': 'command',
                        'name': cmd.get('name', ''),
                        'path': str(cmd_file.parent),
                        'metadata': cmd,
                    })
            
            for cmd_file in search_path.rglob('commands.json'):
                metadata = self._load_metadata(cmd_file)
                commands = metadata.get('commands', [])
                for cmd in commands:
                    self.discovered_items.append({
                        'type': 'command',
                        'name': cmd.get('name', ''),
                        'path': str(cmd_file.parent),
                        'metadata': cmd,
                    })
        
        return self.discovered_items
