"""
Error handling module for GitGit integration.

This module provides comprehensive error handling for the GitGit system,
with specialized handlers for different components and appropriate fallbacks.
"""

import os
import sys
import traceback
from enum import Enum
from typing import Dict, Any, Optional, Callable, List, Tuple, Type, Union
from loguru import logger
from pydantic import BaseModel, Field


class ErrorSeverity(str, Enum):
    """
    Enumeration of error severity levels.
    """
    CRITICAL = "critical"  # Fatal error that should abort processing
    ERROR = "error"        # Serious error, but processing might continue
    WARNING = "warning"    # Non-fatal issue that might affect results
    INFO = "info"          # Informational message about recoverable issues


class ErrorSource(str, Enum):
    """
    Enumeration of error sources.
    """
    REPOSITORY = "repository"    # Repository access or operations
    CHUNKING = "chunking"        # Text chunking operations
    PARSER = "parser"            # Tree-sitter or code parsing
    MARKDOWN = "markdown"        # Markdown parsing
    INTEGRATION = "integration"  # Integration components
    CLI = "cli"                  # CLI processing
    FILE_SYSTEM = "file_system"  # File system operations
    DIRECTORY = "directory"      # Directory management
    LLM = "llm"                  # LLM interactions
    SUMMARIZATION = "summarization"  # Text summarization
    OUTPUT = "output"            # Output generation
    NETWORK = "network"          # Network operations
    VALIDATION = "validation"    # Data validation
    UNKNOWN = "unknown"          # Unknown error source


class GitGitError(BaseModel):
    """
    Model for GitGit errors.
    """
    message: str
    source: ErrorSource = ErrorSource.UNKNOWN
    severity: ErrorSeverity = ErrorSeverity.ERROR
    exception: Optional[Exception] = None
    file_path: Optional[str] = None
    context: Dict[str, Any] = Field(default_factory=dict)
    traceback: Optional[str] = None
    recoverable: bool = True
    timestamp: str = Field(default_factory=lambda: import datetime; datetime.datetime.now().isoformat())


class ErrorHandler:
    """
    Handler for GitGit errors.
    """
    
    def __init__(self):
        """Initialize the error handler."""
        self.errors: List[GitGitError] = []
        self.handlers: Dict[Tuple[ErrorSource, ErrorSeverity], Callable[[GitGitError], bool]] = {}
        
        # Register default handlers
        self.register_handler(ErrorSource.FILE_SYSTEM, ErrorSeverity.ERROR, self._handle_file_system_error)
        self.register_handler(ErrorSource.DIRECTORY, ErrorSeverity.ERROR, self._handle_directory_error)
        self.register_handler(ErrorSource.REPOSITORY, ErrorSeverity.ERROR, self._handle_repository_error)
        self.register_handler(ErrorSource.LLM, ErrorSeverity.ERROR, self._handle_llm_error)
    
    def create_error(
        self,
        message: str,
        source: ErrorSource = ErrorSource.UNKNOWN,
        severity: ErrorSeverity = ErrorSeverity.ERROR,
        exception: Optional[Exception] = None,
        file_path: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        recoverable: bool = True
    ) -> GitGitError:
        """
        Create a GitGit error.
        
        Args:
            message: Error message
            source: Error source
            severity: Error severity
            exception: Original exception, if any
            file_path: Path to the file that caused the error, if applicable
            context: Additional context about the error
            recoverable: Whether the error is recoverable
            
        Returns:
            A GitGitError object
        """
        error_context = context or {}
        error_traceback = None
        
        if exception:
            error_traceback = traceback.format_exception(
                type(exception), exception, exception.__traceback__
            )
        
        return GitGitError(
            message=message,
            source=source,
            severity=severity,
            exception=exception,
            file_path=file_path,
            context=error_context,
            traceback=error_traceback,
            recoverable=recoverable
        )
    
    def handle_error(self, error: GitGitError) -> bool:
        """
        Handle an error.
        
        Args:
            error: The error to handle
            
        Returns:
            True if the error was handled, False otherwise
        """
        # Log the error
        self._log_error(error)
        
        # Add the error to the list
        self.errors.append(error)
        
        # Check if we have a handler for this error source and severity
        handler_key = (error.source, error.severity)
        if handler_key in self.handlers:
            # Call the handler
            return self.handlers[handler_key](error)
        
        # Check if we have a handler for this source with any severity
        handler_key = (error.source, None)
        if handler_key in self.handlers:
            # Call the handler
            return self.handlers[handler_key](error)
        
        # Check if we have a handler for any source with this severity
        handler_key = (None, error.severity)
        if handler_key in self.handlers:
            # Call the handler
            return self.handlers[handler_key](error)
        
        # No handler found, return False
        return False
    
    def handle_exception(
        self,
        exception: Exception,
        source: ErrorSource = ErrorSource.UNKNOWN,
        severity: ErrorSeverity = ErrorSeverity.ERROR,
        file_path: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        recoverable: bool = True
    ) -> bool:
        """
        Handle an exception.
        
        Args:
            exception: The exception to handle
            source: Error source
            severity: Error severity
            file_path: Path to the file that caused the error, if applicable
            context: Additional context about the error
            recoverable: Whether the error is recoverable
            
        Returns:
            True if the error was handled, False otherwise
        """
        # Create an error from the exception
        error = self.create_error(
            message=str(exception),
            source=source,
            severity=severity,
            exception=exception,
            file_path=file_path,
            context=context,
            recoverable=recoverable
        )
        
        # Handle the error
        return self.handle_error(error)
    
    def register_handler(
        self,
        source: Optional[ErrorSource] = None,
        severity: Optional[ErrorSeverity] = None,
        handler: Callable[[GitGitError], bool] = None
    ) -> None:
        """
        Register a handler for errors of a specific source and severity.
        
        Args:
            source: Error source, or None for any source
            severity: Error severity, or None for any severity
            handler: Error handler function
        """
        if handler is None:
            raise ValueError("Handler function cannot be None")
        
        self.handlers[(source, severity)] = handler
    
    def get_errors(
        self,
        source: Optional[ErrorSource] = None,
        severity: Optional[ErrorSeverity] = None
    ) -> List[GitGitError]:
        """
        Get errors, optionally filtered by source and severity.
        
        Args:
            source: Error source to filter by, or None for all sources
            severity: Error severity to filter by, or None for all severities
            
        Returns:
            List of errors matching the filter criteria
        """
        if source is None and severity is None:
            return self.errors.copy()
        
        filtered_errors = []
        
        for error in self.errors:
            if source is not None and error.source != source:
                continue
            
            if severity is not None and error.severity != severity:
                continue
            
            filtered_errors.append(error)
        
        return filtered_errors
    
    def has_critical_errors(self) -> bool:
        """
        Check if there are any critical errors.
        
        Returns:
            True if there are critical errors, False otherwise
        """
        return any(error.severity == ErrorSeverity.CRITICAL for error in self.errors)
    
    def clear_errors(self) -> None:
        """Clear all errors."""
        self.errors = []
    
    def _log_error(self, error: GitGitError) -> None:
        """
        Log an error.
        
        Args:
            error: The error to log
        """
        # Determine log level based on severity
        log_levels = {
            ErrorSeverity.CRITICAL: logger.critical,
            ErrorSeverity.ERROR: logger.error,
            ErrorSeverity.WARNING: logger.warning,
            ErrorSeverity.INFO: logger.info
        }
        
        log_fn = log_levels.get(error.severity, logger.error)
        
        # Build error context string
        context_str = ""
        if error.context:
            context_str = " - Context: " + ", ".join(f"{k}={v}" for k, v in error.context.items())
        
        # Log the error
        log_fn(f"[{error.source.value.upper()}] {error.message}{context_str}")
        
        # Log traceback for exceptions
        if error.traceback and error.severity in (ErrorSeverity.ERROR, ErrorSeverity.CRITICAL):
            logger.debug("".join(error.traceback))
    
    def _handle_file_system_error(self, error: GitGitError) -> bool:
        """
        Handle a file system error.
        
        Args:
            error: The error to handle
            
        Returns:
            True if the error was handled, False otherwise
        """
        # If the error is a FileNotFoundError, we can sometimes recover
        if error.exception and isinstance(error.exception, FileNotFoundError):
            # If the file was supposed to be read, we can't recover
            if error.context.get("operation") == "read":
                error.recoverable = False
                return False
            
            # If the file was supposed to be written, we might be able to create it
            if error.context.get("operation") == "write":
                # Try to create the parent directory
                file_path = error.file_path
                if file_path:
                    try:
                        os.makedirs(os.path.dirname(file_path), exist_ok=True)
                        logger.info(f"Created directory for file: {file_path}")
                        error.recoverable = True
                        return True
                    except Exception as e:
                        logger.error(f"Failed to create directory: {e}")
                        error.recoverable = False
                        return False
        
        # By default, file system errors are not recoverable
        error.recoverable = False
        return False
    
    def _handle_directory_error(self, error: GitGitError) -> bool:
        """
        Handle a directory error.
        
        Args:
            error: The error to handle
            
        Returns:
            True if the error was handled, False otherwise
        """
        # If the error is about a missing directory, we might be able to create it
        if "not found" in error.message.lower() or "does not exist" in error.message.lower():
            directory = error.context.get("directory")
            if directory:
                try:
                    os.makedirs(directory, exist_ok=True)
                    logger.info(f"Created directory: {directory}")
                    error.recoverable = True
                    return True
                except Exception as e:
                    logger.error(f"Failed to create directory: {e}")
        
        # By default, directory errors are not recoverable
        error.recoverable = False
        return False
    
    def _handle_repository_error(self, error: GitGitError) -> bool:
        """
        Handle a repository error.
        
        Args:
            error: The error to handle
            
        Returns:
            True if the error was handled, False otherwise
        """
        # Repository errors are often not recoverable
        error.recoverable = False
        return False
    
    def _handle_llm_error(self, error: GitGitError) -> bool:
        """
        Handle an LLM error.
        
        Args:
            error: The error to handle
            
        Returns:
            True if the error was handled, False otherwise
        """
        # Most LLM errors are recoverable in some way
        error.recoverable = True
        
        # Check for specific error types
        if error.exception:
            exception_str = str(error.exception).lower()
            
            # Token limit errors
            if "token" in exception_str and ("limit" in exception_str or "exceed" in exception_str):
                logger.warning("LLM token limit exceeded, retrying with shorter input")
                error.context["reduce_input"] = True
                return True
            
            # Rate limit errors
            if "rate" in exception_str and "limit" in exception_str:
                logger.warning("LLM rate limit exceeded, retrying with exponential backoff")
                error.context["retry_with_backoff"] = True
                return True
        
        # Generic LLM errors
        logger.warning("LLM error, trying to continue without this result")
        return True


def safe_execute(
    func: Callable,
    error_handler: ErrorHandler,
    source: ErrorSource,
    severity: ErrorSeverity = ErrorSeverity.ERROR,
    file_path: Optional[str] = None,
    context: Optional[Dict[str, Any]] = None,
    default_return: Any = None,
    recoverable: bool = True
) -> Any:
    """
    Safely execute a function with error handling.
    
    Args:
        func: Function to execute
        error_handler: Error handler
        source: Error source
        severity: Error severity
        file_path: Path to the file being processed, if applicable
        context: Additional context about the operation
        default_return: Default return value if the function fails
        recoverable: Whether errors are recoverable
        
    Returns:
        Function result, or default_return if the function fails
        
    Raises:
        Exception: Re-raises the exception if severity is CRITICAL and not recoverable
    """
    try:
        return func()
    except Exception as e:
        # Handle the exception
        handled = error_handler.handle_exception(
            exception=e,
            source=source,
            severity=severity,
            file_path=file_path,
            context=context,
            recoverable=recoverable
        )
        
        # If the error is critical and not recoverable, re-raise the exception
        if severity == ErrorSeverity.CRITICAL and not recoverable:
            raise
        
        # Otherwise, return the default value
        return default_return


# Global error handler instance
global_error_handler = ErrorHandler()