"""
Repository Directory Manager for GitGit Integration.

This module is responsible for creating and managing the directory structure
required for storing intermediate parsed files and final output for specific repositories.
"""

import os
from pathlib import Path
from typing import Dict, List, Optional, Union
from loguru import logger


class RepositoryDirectoryManager:
    """
    Manages the directory structure for GitGit repository analysis.
    
    This class is responsible for creating and managing directories for:
    - Chunks: Stored chunked text
    - Parsed: Parsed markdown with section structure
    - Metadata: Extracted code metadata
    - Output: Final output files
    """
    
    def __init__(self, base_dir: str):
        """
        Initialize the directory manager.
        
        Args:
            base_dir: Base directory for all output
        """
        self.base_dir = Path(base_dir)
        self.dirs = {
            "chunks": self.base_dir / "chunks",
            "parsed": self.base_dir / "parsed",
            "metadata": self.base_dir / "metadata",
            "output": self.base_dir / "output"
        }
        
    def create_directory_structure(self) -> Dict[str, Path]:
        """
        Create the directory structure if it doesn't exist.
        
        Returns:
            Dictionary with directory paths
        """
        logger.info(f"Creating directory structure in {self.base_dir}")
        
        # Create base directory if it doesn't exist
        os.makedirs(self.base_dir, exist_ok=True)
        
        # Create subdirectories
        for name, path in self.dirs.items():
            os.makedirs(path, exist_ok=True)
            logger.debug(f"Created directory: {path}")
            
        return self.dirs
    
    def get_chunk_path(self, file_path: str, chunk_id: Optional[str] = None) -> Path:
        """
        Get the path for a chunked file.
        
        Args:
            file_path: Original file path
            chunk_id: Optional chunk identifier
            
        Returns:
            Path to the chunked file
        """
        file_name = Path(file_path).name
        base_name = Path(file_name).stem
        suffix = f"_{chunk_id}" if chunk_id else ""
        return self.dirs["chunks"] / f"{base_name}{suffix}.json"
    
    def get_parsed_path(self, file_path: str) -> Path:
        """
        Get the path for a parsed file.
        
        Args:
            file_path: Original file path
            
        Returns:
            Path to the parsed file
        """
        file_name = Path(file_path).name
        base_name = Path(file_name).stem
        return self.dirs["parsed"] / f"{base_name}_parsed.json"
    
    def get_metadata_path(self, file_path: str) -> Path:
        """
        Get the path for a metadata file.
        
        Args:
            file_path: Original file path
            
        Returns:
            Path to the metadata file
        """
        file_name = Path(file_path).name
        base_name = Path(file_name).stem
        return self.dirs["metadata"] / f"{base_name}_metadata.json"
    
    def get_output_path(self, name: str) -> Path:
        """
        Get the path for an output file.
        
        Args:
            name: Name of the output file
            
        Returns:
            Path to the output file
        """
        return self.dirs["output"] / name
    
    def cleanup(self, keep_output: bool = True) -> None:
        """
        Clean up the directory structure.
        
        Args:
            keep_output: Whether to keep the output directory
        """
        import shutil
        
        logger.info(f"Cleaning up directory structure in {self.base_dir}")
        
        # Remove intermediate directories
        for name, path in self.dirs.items():
            if name != "output" or not keep_output:
                if os.path.exists(path):
                    shutil.rmtree(path)
                    logger.debug(f"Removed directory: {path}")
        
        # Remove base directory if it's empty and we're not keeping output
        if not keep_output and os.path.exists(self.base_dir) and not os.listdir(self.base_dir):
            os.rmdir(self.base_dir)
            logger.debug(f"Removed empty base directory: {self.base_dir}")


def create_repo_directory_structure(repo_name: str, base_dir: Optional[str] = None) -> RepositoryDirectoryManager:
    """
    Create a directory structure for a repository.
    
    Args:
        repo_name: Name of the repository
        base_dir: Optional base directory (defaults to repos/<repo_name>)
        
    Returns:
        RepositoryDirectoryManager instance
    """
    if base_dir is None:
        base_dir = os.path.join("repos", f"{repo_name}")
    
    manager = RepositoryDirectoryManager(base_dir)
    manager.create_directory_structure()
    return manager


if __name__ == "__main__":
    """
    Script to demonstrate and test the directory manager.
    """
    import tempfile
    import json
    
    # Create a temporary directory for testing
    with tempfile.TemporaryDirectory() as temp_dir:
        # Create a directory manager
        manager = RepositoryDirectoryManager(temp_dir)
        dirs = manager.create_directory_structure()
        
        # Print the directory structure
        print(f"Directory structure created in {temp_dir}:")
        for name, path in dirs.items():
            print(f"  {name}: {path}")
        
        # Create some sample files
        chunk_path = manager.get_chunk_path("test.py", "chunk1")
        with open(chunk_path, "w") as f:
            json.dump({"content": "Test chunk"}, f)
        print(f"Created sample chunk file: {chunk_path}")
        
        parsed_path = manager.get_parsed_path("test.md")
        with open(parsed_path, "w") as f:
            json.dump({"sections": [{"title": "Test Section"}]}, f)
        print(f"Created sample parsed file: {parsed_path}")
        
        metadata_path = manager.get_metadata_path("test.py")
        with open(metadata_path, "w") as f:
            json.dump({"functions": [{"name": "test_func"}]}, f)
        print(f"Created sample metadata file: {metadata_path}")
        
        output_path = manager.get_output_path("SUMMARY.txt")
        with open(output_path, "w") as f:
            f.write("Test summary")
        print(f"Created sample output file: {output_path}")
        
        # Cleanup (keep the output)
        print("Cleaning up (keeping output)...")
        manager.cleanup(keep_output=True)
        
        # Check that output directory still exists
        assert os.path.exists(dirs["output"]), "Output directory should still exist"
        
        # Check that other directories were removed
        for name, path in dirs.items():
            if name != "output":
                assert not os.path.exists(path), f"{name} directory should have been removed"
                
        print("Directory manager test completed successfully")