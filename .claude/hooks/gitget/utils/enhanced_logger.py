"""
Enhanced logging module for GitGit integration.

This module provides enhanced logging capabilities for tracking complex
workflows in the GitGit system, with support for structured logging,
performance tracking, and rich console output.
"""

import os
import sys
import time
import json
import atexit
import tempfile
from enum import Enum
from typing import Dict, Any, Optional, List, Set, Union, Callable
from pathlib import Path
from contextlib import contextmanager
from loguru import logger
from rich.console import Console


class LogLevel(str, Enum):
    """
    Enumeration of log levels.
    """
    DEBUG = "DEBUG"
    INFO = "INFO"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"


class ComponentType(str, Enum):
    """
    Enumeration of component types.
    """
    REPOSITORY = "REPOSITORY"  # Repository operations
    CHUNKING = "CHUNKING"      # Text chunking
    PARSER = "PARSER"          # Code parsing
    MARKDOWN = "MARKDOWN"      # Markdown processing
    LLM = "LLM"                # LLM interactions
    CLI = "CLI"                # CLI interactions
    WORKFLOW = "WORKFLOW"      # Workflow management
    INTEGRATION = "INTEGRATION" # Integration components
    IO = "IO"                  # I/O operations
    UNKNOWN = "UNKNOWN"        # Unknown component type


class EnhancedLogger:
    """
    Enhanced logger with structured logging and performance tracking.
    """
    
    def __init__(
        self,
        name: str,
        log_file: Optional[str] = None,
        console_level: LogLevel = LogLevel.INFO,
        file_level: LogLevel = LogLevel.DEBUG,
        json_format: bool = True,
        add_timestamp: bool = True,
        enable_rich_output: bool = True
    ):
        """
        Initialize the enhanced logger.
        
        Args:
            name: Logger name
            log_file: Log file path, or None to use a default location
            console_level: Console log level
            file_level: File log level
            json_format: Whether to use JSON format for log files
            add_timestamp: Whether to add a timestamp to the log file name
            enable_rich_output: Whether to enable rich console output
        """
        self.name = name
        self.start_time = time.time()
        self.markers = {}
        
        # Set up log file path
        if log_file is None:
            log_dir = Path(tempfile.gettempdir()) / "gitgit_logs"
            os.makedirs(log_dir, exist_ok=True)
            
            if add_timestamp:
                timestamp = time.strftime("%Y%m%d-%H%M%S")
                log_file = log_dir / f"{name}_{timestamp}.log"
            else:
                log_file = log_dir / f"{name}.log"
        
        self.log_file = str(log_file)
        
        # Configure loguru
        logger.remove()  # Remove default handler
        
        # Add console handler
        logger.add(
            sys.stderr,
            level=console_level.value,
            format="<green>{time:HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{message}</cyan>"
        )
        
        # Add file handler
        if json_format:
            # JSON formatter function
            def json_formatter(record):
                log_record = {
                    "timestamp": record["time"].strftime("%Y-%m-%d %H:%M:%S.%f"),
                    "level": record["level"].name,
                    "message": record["message"],
                    "name": self.name
                }
                
                # Add extra fields
                for key, value in record["extra"].items():
                    if key not in log_record:
                        log_record[key] = value
                
                # Add exception info if present
                if record["exception"]:
                    log_record["exception"] = {
                        "type": record["exception"].type.__name__,
                        "value": str(record["exception"].value),
                        "traceback": record["exception"].traceback
                    }
                
                return json.dumps(log_record)
            
            logger.add(
                self.log_file,
                level=file_level.value,
                format=json_formatter,
                serialize=True
            )
        else:
            logger.add(
                self.log_file,
                level=file_level.value,
                format="{time:YYYY-MM-DD HH:mm:ss.SSS} | {level: <8} | {message} | {extra}"
            )
        
        # Set up rich console
        self.enable_rich_output = enable_rich_output
        if enable_rich_output:
            self.console = Console()
        else:
            self.console = None
        
        # Log initialization
        self.info(f"Enhanced logger '{name}' initialized", log_file=self.log_file)
        
        # Register cleanup handler
        atexit.register(self._cleanup)
    
    def _cleanup(self):
        """Clean up resources and log completion."""
        elapsed = time.time() - self.start_time
        self.info(f"Logger '{self.name}' completed after {elapsed:.3f}s")
    
    def _log(
        self,
        level: LogLevel,
        message: str,
        component: ComponentType = ComponentType.UNKNOWN,
        **kwargs
    ):
        """
        Log a message with extra context.
        
        Args:
            level: Log level
            message: Log message
            component: Component type
            **kwargs: Additional context
        """
        # Add component type to extra
        extra = {"component": component.value}
        
        # Add other kwargs to extra
        extra.update(kwargs)
        
        # Get the loguru log function
        log_fn = getattr(logger, level.value.lower())
        
        # Log with extra context
        log_fn(message, **extra)
    
    def debug(self, message: str, component: ComponentType = ComponentType.UNKNOWN, **kwargs):
        """Log a debug message."""
        self._log(LogLevel.DEBUG, message, component, **kwargs)
    
    def info(self, message: str, component: ComponentType = ComponentType.UNKNOWN, **kwargs):
        """Log an info message."""
        self._log(LogLevel.INFO, message, component, **kwargs)
    
    def warning(self, message: str, component: ComponentType = ComponentType.UNKNOWN, **kwargs):
        """Log a warning message."""
        self._log(LogLevel.WARNING, message, component, **kwargs)
    
    def error(self, message: str, component: ComponentType = ComponentType.UNKNOWN, **kwargs):
        """Log an error message."""
        self._log(LogLevel.ERROR, message, component, **kwargs)
    
    def critical(self, message: str, component: ComponentType = ComponentType.UNKNOWN, **kwargs):
        """Log a critical message."""
        self._log(LogLevel.CRITICAL, message, component, **kwargs)
    
    def mark(self, name: str, description: Optional[str] = None):
        """
        Mark a point in time for performance tracking.
        
        Args:
            name: Marker name
            description: Marker description
        """
        marker = {
            "time": time.time(),
            "description": description
        }
        
        self.markers[name] = marker
        self.debug(f"Marker '{name}' set", marker=name, description=description)
    
    def elapsed(self, from_marker: str, to_marker: Optional[str] = None) -> float:
        """
        Get elapsed time between markers.
        
        Args:
            from_marker: Starting marker name
            to_marker: Ending marker name, or None to use current time
            
        Returns:
            Elapsed time in seconds
        """
        if from_marker not in self.markers:
            self.warning(f"Marker '{from_marker}' not found")
            return 0.0
        
        start_time = self.markers[from_marker]["time"]
        
        if to_marker:
            if to_marker not in self.markers:
                self.warning(f"Marker '{to_marker}' not found")
                return 0.0
            
            end_time = self.markers[to_marker]["time"]
        else:
            end_time = time.time()
        
        return end_time - start_time
    
    def log_elapsed(self, from_marker: str, to_marker: Optional[str] = None, level: LogLevel = LogLevel.INFO):
        """
        Log elapsed time between markers.
        
        Args:
            from_marker: Starting marker name
            to_marker: Ending marker name, or None to use current time
            level: Log level
        """
        elapsed = self.elapsed(from_marker, to_marker)
        
        if to_marker:
            message = f"Elapsed time from '{from_marker}' to '{to_marker}': {elapsed:.3f}s"
        else:
            message = f"Elapsed time since '{from_marker}': {elapsed:.3f}s"
        
        log_fn = getattr(self, level.value.lower())
        log_fn(message, component=ComponentType.WORKFLOW, elapsed=elapsed)
    
    @contextmanager
    def timer(self, operation_name: str, level: LogLevel = LogLevel.INFO, **kwargs):
        """
        Context manager for timing operations.
        
        Args:
            operation_name: Name of the operation
            level: Log level for the timing log
            **kwargs: Additional context
        """
        start_time = time.time()
        
        try:
            yield
        finally:
            elapsed = time.time() - start_time
            
            message = f"Operation '{operation_name}' completed in {elapsed:.3f}s"
            log_fn = getattr(self, level.value.lower())
            
            context = {"elapsed": elapsed}
            context.update(kwargs)
            
            log_fn(message, component=ComponentType.WORKFLOW, **context)
    
    def log_dict(self, data: Dict[str, Any], title: str, level: LogLevel = LogLevel.DEBUG):
        """
        Log a dictionary with pretty formatting.
        
        Args:
            data: Dictionary to log
            title: Log title
            level: Log level
        """
        log_fn = getattr(self, level.value.lower())
        
        if self.enable_rich_output and self.console:
            # Format as JSON string first
            json_str = json.dumps(data, indent=2)
            
            # Log the title with normal logging
            log_fn(title, component=ComponentType.UNKNOWN)
            
            # Print the JSON with rich syntax highlighting
            self.console.print(json_str)
        else:
            # Just log as JSON string
            log_fn(f"{title}: {json.dumps(data, indent=2)}", component=ComponentType.UNKNOWN)


def get_logger(
    name: str,
    log_file: Optional[str] = None,
    console_level: LogLevel = LogLevel.INFO,
    file_level: LogLevel = LogLevel.DEBUG,
    json_format: bool = True,
    add_timestamp: bool = True,
    enable_rich_output: bool = True
) -> EnhancedLogger:
    """
    Get an enhanced logger.
    
    Args:
        name: Logger name
        log_file: Log file path, or None to use a default location
        console_level: Console log level
        file_level: File log level
        json_format: Whether to use JSON format for log files
        add_timestamp: Whether to add a timestamp to the log file name
        enable_rich_output: Whether to enable rich console output
        
    Returns:
        An enhanced logger
    """
    return EnhancedLogger(
        name=name,
        log_file=log_file,
        console_level=console_level,
        file_level=file_level,
        json_format=json_format,
        add_timestamp=add_timestamp,
        enable_rich_output=enable_rich_output
    )


def safely_execute(
    func: Callable,
    logger: Optional[EnhancedLogger] = None,
    name: Optional[str] = None,
    component: ComponentType = ComponentType.UNKNOWN,
    level: LogLevel = LogLevel.ERROR,
    **kwargs
):
    """
    Safely execute a function with logging.
    
    Args:
        func: Function to execute
        logger: Logger to use, or None to create a new one
        name: Operation name, or None to use the function name
        component: Component type
        level: Log level for errors
        **kwargs: Additional context
        
    Returns:
        Function result, or None if an exception occurred
    """
    # Get or create logger
    log = logger or get_logger("safe_execute")
    
    # Get operation name
    op_name = name or func.__name__
    
    try:
        # Log the operation start
        log.debug(f"Executing {op_name}", component=component, **kwargs)
        
        # Execute the function
        with log.timer(op_name, level=LogLevel.DEBUG, component=component, **kwargs):
            result = func()
        
        # Log success
        log.debug(f"Successfully executed {op_name}", component=component, **kwargs)
        
        return result
    except Exception as e:
        # Log the error
        log_fn = getattr(log, level.value.lower())
        log_fn(
            f"Error executing {op_name}: {e}",
            component=component,
            error=str(e),
            error_type=type(e).__name__,
            **kwargs
        )
        
        # Re-raise the exception
        raise