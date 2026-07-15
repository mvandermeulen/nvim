"""
Workflow tracking module for GitGit complex workflows.

This module provides standardized workflow tracking for common GitGit operations
such as repository cloning, chunking, parsing, and summarization.
"""

import os
import time
import uuid
from typing import Dict, Any, Optional, List, Set, Union, Callable, TypeVar, cast
from pathlib import Path

# Import workflow logger
from complexity.gitgit.utils.workflow_logger import (
    WorkflowLogger, track_workflow, track_step, ComponentType, LogLevel
)

# Import error handling and logging utilities
from complexity.gitgit.utils.error_handler import ErrorSource, ErrorSeverity
from complexity.gitgit.utils.log_utils import truncate_large_value


class RepositoryWorkflow:
    """
    Repository workflow tracking for GitGit operations.
    
    This class provides specialized workflow tracking for repository operations
    like cloning, parsing, chunking, and summarization.
    """
    
    def __init__(self, repo_url: str, clone_dir: str):
        """
        Initialize the repository workflow tracker.
        
        Args:
            repo_url: Repository URL
            clone_dir: Clone directory
        """
        self.repo_url = repo_url
        self.clone_dir = clone_dir
        self.repo_name = self._extract_repo_name(repo_url)
        
        # Create workflow logger for the repository
        workflow_name = f"Repository: {self.repo_name}"
        log_dir = os.path.join(clone_dir, "logs")
        self.workflow_logger = WorkflowLogger(workflow_name, log_dir)
    
    def _extract_repo_name(self, repo_url: str) -> str:
        """Extract repository name from URL."""
        return repo_url.rstrip('/').split('/')[-1]
    
    def start_cloning_workflow(self, extensions: List[str], files: Optional[List[str]] = None, dirs: Optional[List[str]] = None):
        """
        Start the repository cloning workflow.
        
        Args:
            extensions: File extensions to include
            files: Specific files to include
            dirs: Specific directories to include
        """
        # Set the total steps for the cloning workflow
        total_steps = 5  # init, add remote, configure sparse checkout, create patterns, pull
        self.workflow_logger.set_total_steps(total_steps)
        
        # Log workflow start with context
        self.workflow_logger.log_data(
            {
                "repo_url": self.repo_url, 
                "clone_dir": self.clone_dir,
                "extensions": extensions,
                "files": files,
                "dirs": dirs
            },
            level=LogLevel.INFO,
            source=ComponentType.REPOSITORY,
            description="Starting repository cloning workflow"
        )
    
    def start_chunking_workflow(self, file_count: int, enhanced_markdown: bool = True):
        """
        Start the repository chunking workflow.
        
        Args:
            file_count: Number of files to process
            enhanced_markdown: Whether to use enhanced markdown extraction
        """
        # Set the total steps for chunking workflow (2 per file + 1 for final step)
        total_steps = file_count * 2 + 1
        self.workflow_logger.set_total_steps(total_steps)
        
        # Log workflow start with context
        self.workflow_logger.log_data(
            {
                "repo_name": self.repo_name,
                "file_count": file_count,
                "enhanced_markdown": enhanced_markdown
            },
            level=LogLevel.INFO,
            source=ComponentType.CHUNKING,
            description="Starting repository chunking workflow"
        )
    
    def start_summarization_workflow(self, model: str, include_code_metadata: bool = False):
        """
        Start the repository summarization workflow.
        
        Args:
            model: LLM model to use
            include_code_metadata: Whether to include code metadata in summary
        """
        # Set the total steps for summarization (digest creation, LLM processing, formatting)
        total_steps = 3
        self.workflow_logger.set_total_steps(total_steps)
        
        # Log workflow start with context
        self.workflow_logger.log_data(
            {
                "repo_name": self.repo_name,
                "model": model,
                "include_code_metadata": include_code_metadata
            },
            level=LogLevel.INFO,
            source=ComponentType.SUMMARIZATION,
            description="Starting repository summarization workflow"
        )
    
    def log_file_processing(self, file_path: str, size_bytes: int, chunk_count: Optional[int] = None):
        """
        Log file processing during chunking.
        
        Args:
            file_path: File path
            size_bytes: File size in bytes
            chunk_count: Number of chunks created
        """
        # Get file extension
        ext = os.path.splitext(file_path)[1].lstrip('.')
        
        # Log file processing with context
        self.workflow_logger.log_data(
            {
                "file_path": file_path,
                "extension": ext,
                "size_bytes": size_bytes,
                "chunk_count": chunk_count
            },
            level=LogLevel.INFO,
            source=ComponentType.FILE_SYSTEM,
            description=f"Processing file: {os.path.basename(file_path)}"
        )
    
    def log_llm_request(self, model: str, token_count: int, prompt_size: int):
        """
        Log LLM request during summarization.
        
        Args:
            model: LLM model used
            token_count: Token count of the request
            prompt_size: Size of the prompt in bytes
        """
        # Log LLM request with context
        self.workflow_logger.log_data(
            {
                "model": model,
                "token_count": token_count,
                "prompt_size": prompt_size
            },
            level=LogLevel.INFO,
            source=ComponentType.LLM,
            description="Sending request to LLM"
        )
    
    def log_performance_metrics(self, file_count: int, total_bytes: int, chunk_count: int, duration: float):
        """
        Log performance metrics for the workflow.
        
        Args:
            file_count: Number of files processed
            total_bytes: Total bytes processed
            chunk_count: Number of chunks created
            duration: Processing duration in seconds
        """
        # Calculate processing rates
        bytes_per_second = total_bytes / duration if duration > 0 else 0
        files_per_second = file_count / duration if duration > 0 else 0
        
        # Log performance metrics
        self.workflow_logger.log_data(
            {
                "file_count": file_count,
                "total_bytes": total_bytes,
                "chunk_count": chunk_count,
                "duration": duration,
                "bytes_per_second": bytes_per_second,
                "files_per_second": files_per_second
            },
            level=LogLevel.INFO,
            source=ComponentType.INTEGRATION,
            description="Workflow performance metrics"
        )
    
    def finish_cloning(self, status: str = "completed", file_count: Optional[int] = None):
        """
        Finish the cloning workflow.
        
        Args:
            status: Workflow status
            file_count: Number of files cloned
        """
        # Log repo tree summary if successful
        if status == "completed" and file_count is not None:
            self.workflow_logger.log_data(
                {"file_count": file_count},
                level=LogLevel.SUCCESS,
                source=ComponentType.REPOSITORY,
                description="Repository cloned successfully"
            )
        
        # Finish the workflow
        self.workflow_logger.finish_workflow(status)
    
    def finish_chunking(self, status: str = "completed", chunk_count: Optional[int] = None, total_bytes: Optional[int] = None):
        """
        Finish the chunking workflow.
        
        Args:
            status: Workflow status
            chunk_count: Number of chunks created
            total_bytes: Total bytes processed
        """
        # Log chunking summary if successful
        if status == "completed" and chunk_count is not None:
            self.workflow_logger.log_data(
                {
                    "chunk_count": chunk_count,
                    "total_bytes": total_bytes
                },
                level=LogLevel.SUCCESS,
                source=ComponentType.CHUNKING,
                description="Repository chunking completed"
            )
        
        # Finish the workflow
        self.workflow_logger.finish_workflow(status)
    
    def finish_summarization(self, status: str = "completed", summary_path: Optional[str] = None):
        """
        Finish the summarization workflow.
        
        Args:
            status: Workflow status
            summary_path: Path to the summary file
        """
        # Log summary if successful
        if status == "completed" and summary_path is not None:
            self.workflow_logger.log_data(
                {"summary_path": summary_path},
                level=LogLevel.SUCCESS,
                source=ComponentType.SUMMARIZATION,
                description="Repository summarization completed"
            )
        
        # Finish the workflow
        self.workflow_logger.finish_workflow(status)


# Decorator for tracking repository cloning
def track_repo_cloning(func):
    """Decorator to track repository cloning workflow."""
    def wrapper(repo_url, extensions, clone_dir, files=None, dirs=None, **kwargs):
        # Create repository workflow
        repo_workflow = RepositoryWorkflow(repo_url, clone_dir)
        
        # Start cloning workflow
        repo_workflow.start_cloning_workflow(extensions, files, dirs)
        
        try:
            # Run the function
            result = func(repo_url, extensions, clone_dir, files, dirs, repo_workflow=repo_workflow, **kwargs)
            
            # Finish workflow
            file_count = len(result) if isinstance(result, list) else None
            repo_workflow.finish_cloning("completed", file_count)
            
            return result
        except Exception as e:
            # Finish workflow with failure
            repo_workflow.finish_cloning("failed")
            raise
    
    return wrapper


# Decorator for tracking repository chunking
def track_repo_chunking(func):
    """Decorator to track repository chunking workflow."""
    def wrapper(root_dir, extensions, files=None, dirs=None, code_metadata=False, max_chunk_tokens=500, chunk_overlap=100, enhanced_markdown=True, **kwargs):
        # Extract repo name from root_dir
        repo_name = os.path.basename(root_dir)
        
        # Create repository workflow
        repo_workflow = RepositoryWorkflow("", root_dir)  # Empty URL since we're working with cloned repo
        
        # Detect file count for progress tracking
        file_count = 0
        if files:
            file_count = len(files)
        elif dirs:
            # Count files in specified directories
            for dir_path in dirs:
                full_path = os.path.join(root_dir, dir_path)
                if os.path.exists(full_path):
                    for _, _, files_list in os.walk(full_path):
                        file_count += len(files_list)
        else:
            # Count files with specified extensions
            for ext in extensions:
                for _, _, files_list in os.walk(root_dir):
                    for file in files_list:
                        if file.lower().endswith(f'.{ext.lower()}'):
                            file_count += 1
        
        # Start chunking workflow
        repo_workflow.start_chunking_workflow(file_count, enhanced_markdown)
        
        try:
            # Run the function
            start_time = time.time()
            result = func(
                root_dir, extensions, files, dirs, code_metadata, 
                max_chunk_tokens, chunk_overlap, enhanced_markdown,
                repo_workflow=repo_workflow, **kwargs
            )
            duration = time.time() - start_time
            
            # Extract metrics from result
            if isinstance(result, tuple) and len(result) >= 3:
                summary, tree, digest = result
                
                # Parse summary to extract metrics
                file_count = 0
                total_bytes = 0
                chunk_count = 0
                
                if isinstance(summary, str):
                    lines = summary.split('\n')
                    for line in lines:
                        if line.startswith("Files analyzed:"):
                            file_count = int(line.split(':')[1].strip())
                        elif line.startswith("Total bytes:"):
                            total_bytes = int(line.split(':')[1].strip())
                        elif line.startswith("Chunks created:"):
                            chunk_count = int(line.split(':')[1].strip())
                
                # Log performance metrics
                repo_workflow.log_performance_metrics(file_count, total_bytes, chunk_count, duration)
                
                # Finish workflow
                repo_workflow.finish_chunking("completed", chunk_count, total_bytes)
            else:
                # Finish workflow without metrics
                repo_workflow.finish_chunking("completed")
            
            return result
        except Exception as e:
            # Finish workflow with failure
            repo_workflow.finish_chunking("failed")
            raise
    
    return wrapper


# Decorator for tracking repository summarization
def track_repo_summarization(func):
    """Decorator to track repository summarization workflow."""
    def wrapper(digest_path, summary_path, model="gemini-2.5-pro-preview-03-25", **kwargs):
        # Extract repo name from digest_path
        repo_dir = os.path.dirname(digest_path)
        
        # Create repository workflow
        repo_workflow = RepositoryWorkflow("", repo_dir)  # Empty URL since we're working with cloned repo
        
        # Start summarization workflow
        repo_workflow.start_summarization_workflow(model)
        
        try:
            # Run the function
            result = func(digest_path, summary_path, model=model, repo_workflow=repo_workflow, **kwargs)
            
            # Finish workflow
            repo_workflow.finish_summarization("completed", summary_path)
            
            return result
        except Exception as e:
            # Finish workflow with failure
            repo_workflow.finish_summarization("failed")
            raise
    
    return wrapper


# Example of integration with GitGit functions
if __name__ == "__main__":
    import time
    import random
    
    # Mock GitGit functions for demonstration
    @track_repo_cloning
    def sparse_clone_demo(repo_url, extensions, clone_dir, files=None, dirs=None, repo_workflow=None):
        """Demo sparse clone function."""
        print(f"Cloning {repo_url} to {clone_dir}...")
        
        # Simulate file creation
        os.makedirs(clone_dir, exist_ok=True)
        
        # Simulate steps
        time.sleep(0.5)  # init
        if repo_workflow:
            repo_workflow.workflow_logger.complete_step("Initialize repository")
        
        time.sleep(0.5)  # add remote
        if repo_workflow:
            repo_workflow.workflow_logger.complete_step("Add remote")
        
        time.sleep(0.5)  # config sparse checkout
        if repo_workflow:
            repo_workflow.workflow_logger.complete_step("Configure sparse checkout")
        
        # Simulate file patterns
        patterns = []
        if files or dirs:
            if files:
                patterns.extend(files)
            if dirs:
                patterns.extend(dirs)
        else:
            for ext in extensions:
                patterns.append(f"*.{ext}")
        
        if repo_workflow:
            repo_workflow.workflow_logger.complete_step("Create sparse checkout patterns")
        
        # Simulate pull
        time.sleep(1.0)
        if repo_workflow:
            repo_workflow.workflow_logger.complete_step("Pull repository")
        
        # Create some demo files
        created_files = []
        for i, pattern in enumerate(patterns):
            if pattern.startswith("*"):
                # Create a few files with this extension
                ext = pattern[1:]
                for j in range(3):
                    filename = f"file{j}{ext}"
                    with open(os.path.join(clone_dir, filename), "w") as f:
                        f.write(f"Content of {filename}")
                    created_files.append(filename)
            else:
                # Create this specific file
                with open(os.path.join(clone_dir, pattern), "w") as f:
                    f.write(f"Content of {pattern}")
                created_files.append(pattern)
        
        return created_files
    
    @track_repo_chunking
    def concat_and_summarize_demo(root_dir, extensions, files=None, dirs=None, code_metadata=False,
                                 max_chunk_tokens=500, chunk_overlap=100, enhanced_markdown=True, repo_workflow=None):
        """Demo concatenation and summarization function."""
        print(f"Processing {root_dir} with chunking={enhanced_markdown}...")
        
        # Simulate file processing
        total_bytes = 0
        chunk_count = 0
        file_count = 0
        
        # Process existing files
        for root, _, filenames in os.walk(root_dir):
            for filename in filenames:
                # Check if we should process this file
                should_process = False
                if files and filename in files:
                    should_process = True
                elif dirs:
                    rel_dir = os.path.relpath(root, root_dir)
                    if rel_dir in dirs:
                        should_process = True
                else:
                    ext = os.path.splitext(filename)[1].lstrip('.')
                    if ext in extensions:
                        should_process = True
                
                if should_process:
                    file_count += 1
                    file_path = os.path.join(root, filename)
                    
                    # Get file size
                    size = os.path.getsize(file_path)
                    total_bytes += size
                    
                    # Simulate processing
                    if repo_workflow:
                        repo_workflow.log_file_processing(
                            file_path=file_path,
                            size_bytes=size
                        )
                        repo_workflow.workflow_logger.complete_step(f"Process file: {filename}")
                    
                    # Simulate chunking
                    time.sleep(0.2)
                    file_chunks = random.randint(1, 5)
                    chunk_count += file_chunks
                    
                    if repo_workflow:
                        repo_workflow.workflow_logger.complete_step(f"Chunk file: {filename}")
        
        # Simulate saving digest
        time.sleep(0.5)
        digest_path = os.path.join(root_dir, "DIGEST.txt")
        with open(digest_path, "w") as f:
            f.write(f"Sample digest of {file_count} files")
        
        # Simulate saving summary
        summary_path = os.path.join(root_dir, "SUMMARY.txt")
        with open(summary_path, "w") as f:
            f.write(f"Directory: {root_dir}\n")
            f.write(f"Files analyzed: {file_count}\n")
            f.write(f"Total bytes: {total_bytes}\n")
            f.write(f"Estimated tokens: {total_bytes // 4}\n")
            f.write(f"Chunks created: {chunk_count}\n")
        
        if repo_workflow:
            repo_workflow.workflow_logger.complete_step("Save output files")
        
        # Return demo summary data
        return summary_path, os.path.join(root_dir, "TREE.txt"), digest_path
    
    @track_repo_summarization
    def llm_summarize_demo(digest_path, summary_path, model="gemini-2.5-pro-preview-03-25", repo_workflow=None):
        """Demo LLM summarization function."""
        print(f"Summarizing {digest_path} using {model}...")
        
        # Simulate reading digest
        with open(digest_path, "r") as f:
            digest_content = f.read()
        
        if repo_workflow:
            repo_workflow.workflow_logger.complete_step("Read repository digest")
        
        # Simulate LLM processing
        time.sleep(1.0)
        token_count = len(digest_content) // 4
        
        if repo_workflow:
            repo_workflow.log_llm_request(model, token_count, len(digest_content))
            repo_workflow.workflow_logger.complete_step("Process content with LLM")
        
        # Simulate saving summary
        with open(summary_path, "w") as f:
            f.write("# Repository Summary\n\n")
            f.write("This is a sample LLM generated summary.\n\n")
            f.write("## Key Files\n\n")
            f.write("- file1.py: Important Python file\n")
            f.write("- docs/readme.md: Documentation file\n")
        
        if repo_workflow:
            repo_workflow.workflow_logger.complete_step("Save LLM summary")
        
        return True
    
    # Run the demo
    repo_url = "https://github.com/example/repo"
    extensions = ["py", "md"]
    clone_dir = "demo_repo"
    
    try:
        # Clean up existing demo
        if os.path.exists(clone_dir):
            import shutil
            shutil.rmtree(clone_dir)
        
        # Step 1: Clone the repository
        print("\n=== Step 1: Cloning Repository ===")
        files = sparse_clone_demo(repo_url, extensions, clone_dir)
        
        # Step 2: Process and chunk the repository
        print("\n=== Step 2: Processing Repository ===")
        summary_path, tree_path, digest_path = concat_and_summarize_demo(
            clone_dir, extensions, max_chunk_tokens=500, chunk_overlap=100, enhanced_markdown=True
        )
        
        # Step 3: Generate LLM summary
        print("\n=== Step 3: Generating LLM Summary ===")
        llm_summary_path = os.path.join(clone_dir, "LLM_SUMMARY.txt")
        llm_summarize_demo(digest_path, llm_summary_path, model="gpt-4")
        
        print("\n=== Demo Completed Successfully ===")
    except Exception as e:
        print(f"\n=== Demo Failed: {e} ===")
    finally:
        # Optional cleanup
        pass  # Uncomment to clean up: shutil.rmtree(clone_dir)