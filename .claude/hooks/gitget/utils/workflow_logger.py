"""
Workflow logging module for GitGit integration.

This module provides detailed logging for complex GitGit workflows, integrating
the enhanced logger with the error handling system.
"""

import os
import time
import uuid
import functools
from typing import Dict, Any, Optional, List, Set, Union, Callable, TypeVar, cast
from contextlib import contextmanager

# Import the enhanced logger and error handler
from complexity.gitgit.utils.enhanced_logger import (
    EnhancedLogger, ComponentType, LogLevel, get_logger, safely_execute
)
from complexity.gitgit.utils.error_handler import (
    ErrorHandler, ErrorSource, ErrorSeverity, GitGitError, global_error_handler
)

# Type variable for decorators
F = TypeVar('F', bound=Callable[..., Any])


class WorkflowLogger:
    """
    Logger for complex GitGit workflows.
    
    This class provides structured logging for multi-step workflows,
    with proper error handling, timing, and context management.
    """
    
    def __init__(
        self,
        workflow_name: str,
        logger: Optional[EnhancedLogger] = None,
        error_handler: Optional[ErrorHandler] = None,
        context: Optional[Dict[str, Any]] = None
    ):
        """
        Initialize a workflow logger.
        
        Args:
            workflow_name: Name of the workflow
            logger: Logger to use, or None to create a new one
            error_handler: Error handler to use, or None to use the global handler
            context: Initial context for the workflow
        """
        self.workflow_name = workflow_name
        self.logger = logger or get_logger(workflow_name)
        self.error_handler = error_handler or global_error_handler
        self.context = context or {}
        self.workflow_id = str(uuid.uuid4())
        self.step_count = 0
        self.errors = []
        self.start_time = time.time()
        self.last_step_time = self.start_time
        
        # Log workflow start
        self.logger.info(
            f"Workflow '{workflow_name}' started",
            workflow_id=self.workflow_id,
            context=self.context
        )
    
    def log_step(
        self,
        step_name: str,
        step_description: Optional[str] = None,
        level: LogLevel = LogLevel.INFO,
        context: Optional[Dict[str, Any]] = None,
        component: ComponentType = ComponentType.WORKFLOW
    ) -> None:
        """
        Log a workflow step.
        
        Args:
            step_name: Name of the step
            step_description: Description of the step
            level: Log level
            context: Additional context for the step
            component: Component type
        """
        self.step_count += 1
        step_context = {
            "workflow_id": self.workflow_id,
            "workflow_name": self.workflow_name,
            "step": self.step_count,
            "step_name": step_name
        }
        
        if context:
            step_context.update(context)
        
        # Calculate elapsed time since workflow start and last step
        current_time = time.time()
        elapsed_total = current_time - self.start_time
        elapsed_step = current_time - self.last_step_time
        self.last_step_time = current_time
        
        # Add timing information
        step_context["elapsed_total"] = f"{elapsed_total:.3f}s"
        step_context["elapsed_step"] = f"{elapsed_step:.3f}s"
        
        # Log the step
        message = f"Step {self.step_count}: {step_name}"
        if step_description:
            message += f" - {step_description}"
        
        log_fn = getattr(self.logger, level.value.lower())
        log_fn(message, **step_context, component=component)
    
    def log_error(
        self,
        error: Union[Exception, GitGitError],
        step_name: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        source: ErrorSource = ErrorSource.UNKNOWN,
        severity: ErrorSeverity = ErrorSeverity.ERROR,
        recoverable: bool = True
    ) -> bool:
        """
        Log an error during the workflow.
        
        Args:
            error: The error to log
            step_name: Name of the step where the error occurred
            context: Additional context for the error
            source: Error source
            severity: Error severity
            recoverable: Whether the error is recoverable
            
        Returns:
            True if the error was handled, False otherwise
        """
        self.step_count += 1
        step_context = {
            "workflow_id": self.workflow_id,
            "workflow_name": self.workflow_name,
            "step": self.step_count,
            "step_name": step_name or "error",
            "elapsed_total": f"{time.time() - self.start_time:.3f}s"
        }
        
        # Merge the passed context with step context
        error_context = step_context.copy()
        if context:
            error_context.update(context)
        
        # Handle the error
        if isinstance(error, GitGitError):
            # If it's already a GitGitError, just handle it
            self.errors.append(error)
            return self.error_handler.handle_error(error)
        else:
            # If it's an exception, create a GitGitError and handle it
            git_error = self.error_handler.create_error(
                message=str(error),
                source=source,
                severity=severity,
                exception=error,
                context=error_context,
                recoverable=recoverable
            )
            self.errors.append(git_error)
            return self.error_handler.handle_error(git_error)
    
    def log_result(
        self,
        result: Any,
        step_name: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        level: LogLevel = LogLevel.INFO
    ) -> None:
        """
        Log a workflow result.
        
        Args:
            result: The result to log
            step_name: Name of the step that produced the result
            context: Additional context for the result
            level: Log level
        """
        self.step_count += 1
        result_context = {
            "workflow_id": self.workflow_id,
            "workflow_name": self.workflow_name,
            "step": self.step_count,
            "step_name": step_name or "result",
            "elapsed_total": f"{time.time() - self.start_time:.3f}s"
        }
        
        if context:
            result_context.update(context)
        
        # Log the result
        log_fn = getattr(self.logger, level.value.lower())
        log_fn(
            f"Result: {result}",
            **result_context,
            component=ComponentType.WORKFLOW
        )
    
    def log_completion(
        self,
        success: bool = True,
        result: Any = None,
        context: Optional[Dict[str, Any]] = None
    ) -> None:
        """
        Log workflow completion.
        
        Args:
            success: Whether the workflow completed successfully
            result: The final result of the workflow
            context: Additional context for the completion
        """
        completion_context = {
            "workflow_id": self.workflow_id,
            "workflow_name": self.workflow_name,
            "step_count": self.step_count,
            "elapsed_total": f"{time.time() - self.start_time:.3f}s",
            "error_count": len(self.errors)
        }
        
        if context:
            completion_context.update(context)
        
        # Log the result if provided
        if result is not None:
            completion_context["result"] = result
        
        # Log completion
        if success:
            self.logger.info(
                f"Workflow '{self.workflow_name}' completed successfully",
                **completion_context,
                component=ComponentType.WORKFLOW
            )
        else:
            self.logger.error(
                f"Workflow '{self.workflow_name}' failed",
                **completion_context,
                component=ComponentType.WORKFLOW
            )
    
    @contextmanager
    def step_context(
        self,
        step_name: str,
        step_description: Optional[str] = None,
        context: Optional[Dict[str, Any]] = None,
        error_source: ErrorSource = ErrorSource.UNKNOWN,
        error_severity: ErrorSeverity = ErrorSeverity.ERROR,
        recoverable: bool = True
    ):
        """
        Context manager for a workflow step.
        
        Args:
            step_name: Name of the step
            step_description: Description of the step
            context: Additional context for the step
            error_source: Source for any errors that occur
            error_severity: Severity for any errors that occur
            recoverable: Whether errors are recoverable
            
        Yields:
            The workflow logger
        """
        self.log_step(step_name, step_description, context=context)
        
        try:
            yield self
        except Exception as e:
            self.log_error(
                e,
                step_name=step_name,
                context=context,
                source=error_source,
                severity=error_severity,
                recoverable=recoverable
            )
            raise
        finally:
            pass  # Any cleanup code would go here
    
    def step_decorator(
        self,
        step_name: Optional[str] = None,
        error_source: ErrorSource = ErrorSource.UNKNOWN,
        error_severity: ErrorSeverity = ErrorSeverity.ERROR,
        recoverable: bool = True
    ) -> Callable[[F], F]:
        """
        Decorator for workflow steps.
        
        Args:
            step_name: Name of the step
            error_source: Source for any errors that occur
            error_severity: Severity for any errors that occur
            recoverable: Whether errors are recoverable
            
        Returns:
            Decorator function
        """
        def decorator(func: F) -> F:
            @functools.wraps(func)
            def wrapper(*args, **kwargs):
                func_name = step_name or func.__name__
                self.log_step(func_name, f"Function {func.__name__} called")
                
                try:
                    result = func(*args, **kwargs)
                    self.log_result(result, step_name=func_name)
                    return result
                except Exception as e:
                    self.log_error(
                        e,
                        step_name=func_name,
                        source=error_source,
                        severity=error_severity,
                        recoverable=recoverable
                    )
                    raise
            
            return cast(F, wrapper)
        
        return decorator


def get_workflow_logger(
    workflow_name: str,
    logger: Optional[EnhancedLogger] = None,
    error_handler: Optional[ErrorHandler] = None,
    context: Optional[Dict[str, Any]] = None
) -> WorkflowLogger:
    """
    Get a workflow logger.
    
    Args:
        workflow_name: Name of the workflow
        logger: Logger to use, or None to create a new one
        error_handler: Error handler to use, or None to use the global handler
        context: Initial context for the workflow
        
    Returns:
        A workflow logger
    """
    return WorkflowLogger(workflow_name, logger, error_handler, context)


# Helper decorators and context managers

def workflow_step(
    step_name: str,
    workflow_logger: Optional[WorkflowLogger] = None,
    error_source: ErrorSource = ErrorSource.UNKNOWN,
    error_severity: ErrorSeverity = ErrorSeverity.ERROR,
    recoverable: bool = True
) -> Callable[[F], F]:
    """
    Decorator for workflow steps.
    
    Args:
        step_name: Name of the step
        workflow_logger: Workflow logger to use, or None to create a new one
        error_source: Source for any errors that occur
        error_severity: Severity for any errors that occur
        recoverable: Whether errors are recoverable
        
    Returns:
        Decorator function
    """
    def decorator(func: F) -> F:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # Get or create workflow logger
            logger = workflow_logger
            if logger is None:
                logger = get_workflow_logger(f"{func.__module__}.{func.__name__}")
            
            # Use the logger's step decorator
            decorated = logger.step_decorator(
                step_name=step_name,
                error_source=error_source,
                error_severity=error_severity,
                recoverable=recoverable
            )(func)
            
            return decorated(*args, **kwargs)
        
        return cast(F, wrapper)
    
    return decorator


@contextmanager
def workflow_context(
    workflow_name: str,
    logger: Optional[EnhancedLogger] = None,
    error_handler: Optional[ErrorHandler] = None,
    context: Optional[Dict[str, Any]] = None
):
    """
    Context manager for a workflow.
    
    Args:
        workflow_name: Name of the workflow
        logger: Logger to use, or None to create a new one
        error_handler: Error handler to use, or None to use the global handler
        context: Initial context for the workflow
        
    Yields:
        A workflow logger
    """
    workflow_logger = WorkflowLogger(workflow_name, logger, error_handler, context)
    
    try:
        yield workflow_logger
    except Exception as e:
        workflow_logger.log_error(e)
        workflow_logger.log_completion(success=False)
        raise
    else:
        workflow_logger.log_completion(success=True)