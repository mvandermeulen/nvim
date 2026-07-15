"""
Directory Manager for GitGit Integration.

This module is responsible for creating and managing the directory structure
required for storing intermediate parsed files and final output.
"""

import os
from pathlib import Path
from typing import Dict, List, Optional, Union
from loguru import logger


class DirectoryManager:
    """
    Manages the directory structure for GitGit repository analysis.
    
    This class is responsible for creating and managing directories for:
    - Chunks: Stored chunked text
    - Parsed: Parsed markdown with section structure
    - Output: Final output files
    """
    
    def __init__(self, base_dir: Optional[str] = None):
        """
        Initialize the directory manager.
        
        Args:
            base_dir: Base directory for all operations. If None, uses current directory.
        """
        self.base_dir = os.path.abspath(base_dir or os.getcwd())
        
        # Standard directory structure
        self.repos_dir = os.path.join(self.base_dir, "repos")
        self.tmp_dir = os.path.join(self.base_dir, "tmp")
        self.cache_dir = os.path.join(self.base_dir, "cache")
        self.logs_dir = os.path.join(self.base_dir, "logs")
        self.output_dir = os.path.join(self.base_dir, "output")
        
        # Ensure all standard directories exist
        self.create_directory(self.repos_dir)
        self.create_directory(self.tmp_dir)
        self.create_directory(self.cache_dir)
        self.create_directory(self.logs_dir)
        self.create_directory(self.output_dir)
        
        logger.debug(f"DirectoryManager initialized with base directory: {self.base_dir}")
    
    def create_directory(self, path: str, exist_ok: bool = True) -> str:
        """
        Create a directory if it doesn't exist.
        
        Args:
            path: Directory path to create
            exist_ok: Whether it's OK if the directory already exists
            
        Returns:
            The absolute path to the created directory
        """
        abs_path = os.path.abspath(path)
        os.makedirs(abs_path, exist_ok=exist_ok)
        logger.debug(f"Created directory: {abs_path}")
        return abs_path
    
    def get_repo_dir(self, repo_name: str) -> str:
        """
        Get the directory for a repository.
        
        Args:
            repo_name: Repository name
            
        Returns:
            The absolute path to the repository directory
        """
        repo_dir = os.path.join(self.repos_dir, repo_name)
        return self.create_directory(repo_dir)
    
    def get_repo_chunks_dir(self, repo_name: str) -> str:
        """
        Get the chunks directory for a repository.
        
        Args:
            repo_name: Repository name
            
        Returns:
            The absolute path to the repository chunks directory
        """
        chunks_dir = os.path.join(self.get_repo_dir(repo_name), "chunks")
        return self.create_directory(chunks_dir)
    
    def get_temp_dir(self, name: Optional[str] = None) -> str:
        """
        Get a temporary directory.
        
        Args:
            name: Optional name for the temporary directory
            
        Returns:
            The absolute path to the temporary directory
        """
        if name:
            temp_dir = os.path.join(self.tmp_dir, name)
            return self.create_directory(temp_dir)
        else:
            return self.tmp_dir
    
    def get_cache_dir(self, name: Optional[str] = None) -> str:
        """
        Get a cache directory.
        
        Args:
            name: Optional name for the cache directory
            
        Returns:
            The absolute path to the cache directory
        """
        if name:
            cache_dir = os.path.join(self.cache_dir, name)
            return self.create_directory(cache_dir)
        else:
            return self.cache_dir
    
    def get_log_dir(self, name: Optional[str] = None) -> str:
        """
        Get a log directory.
        
        Args:
            name: Optional name for the log directory
            
        Returns:
            The absolute path to the log directory
        """
        if name:
            log_dir = os.path.join(self.logs_dir, name)
            return self.create_directory(log_dir)
        else:
            return self.logs_dir
    
    def get_output_dir(self, name: Optional[str] = None) -> str:
        """
        Get an output directory.
        
        Args:
            name: Optional name for the output directory
            
        Returns:
            The absolute path to the output directory
        """
        if name:
            output_dir = os.path.join(self.output_dir, name)
            return self.create_directory(output_dir)
        else:
            return self.output_dir
    
    def get_repo_path(self, repo_name: str, path: Optional[str] = None) -> str:
        """
        Get a path within a repository.
        
        Args:
            repo_name: Repository name
            path: Optional path within the repository
            
        Returns:
            The absolute path to the repository path
        """
        repo_dir = self.get_repo_dir(repo_name)
        
        if path:
            # Make sure path separator is consistent
            clean_path = os.path.normpath(path)
            
            # Remove any leading / or ./ to avoid path traversal
            if clean_path.startswith("/") or clean_path.startswith("./"):
                clean_path = clean_path.lstrip("/.")
            
            return os.path.join(repo_dir, clean_path)
        else:
            return repo_dir
    
    def ensure_parent_directory(self, file_path: str) -> str:
        """
        Ensure that the parent directory of a file exists.
        
        Args:
            file_path: Path to the file
            
        Returns:
            The absolute path to the file
        """
        abs_path = os.path.abspath(file_path)
        parent_dir = os.path.dirname(abs_path)
        self.create_directory(parent_dir)
        return abs_path
    
    def clean_directory(self, path: str) -> None:
        """
        Remove all files in a directory.
        
        Args:
            path: Directory path to clean
        """
        for root, dirs, files in os.walk(path):
            for file in files:
                file_path = os.path.join(root, file)
                try:
                    os.remove(file_path)
                    logger.debug(f"Removed file: {file_path}")
                except Exception as e:
                    logger.warning(f"Failed to remove file {file_path}: {e}")
    
    def list_directories(self, base_path: Optional[str] = None) -> List[str]:
        """
        List all directories in a path.
        
        Args:
            base_path: Base path to list directories in, or None to use base_dir
            
        Returns:
            List of directory names
        """
        path = base_path or self.base_dir
        
        if not os.path.exists(path):
            logger.warning(f"Path does not exist: {path}")
            return []
        
        return [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]
    
    def list_repositories(self) -> List[str]:
        """
        List all repositories.
        
        Returns:
            List of repository names
        """
        return self.list_directories(self.repos_dir)


# Create a global instance for convenience
default_directory_manager = DirectoryManager()


def get_directory_manager(base_dir: Optional[str] = None) -> DirectoryManager:
    """
    Get a directory manager.
    
    Args:
        base_dir: Base directory for all operations
        
    Returns:
        A directory manager
    """
    if base_dir:
        return DirectoryManager(base_dir)
    else:
        return default_directory_manager