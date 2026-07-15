# GitGit Integration Error Handling System

This document describes the comprehensive error handling system for the GitGit integration components.

## Overview

The error handling system provides a centralized way to manage errors across all GitGit components with specialized handlers for different error types and appropriate fallbacks. It is designed to:

- Categorize errors by source and severity
- Provide structured error information
- Handle errors appropriately based on their type
- Support fallback mechanisms for recoverable errors
- Log errors with appropriate detail
- Allow for safe execution of functions with proper error handling

## Key Components

### Error Sources

Errors are categorized by their source, which helps in determining the appropriate handling strategy. The available error sources include:

| Source | Description |
|--------|-------------|
| `REPOSITORY` | Errors related to repository access or operations |
| `CHUNKING` | Errors in text chunking operations |
| `PARSER` | Errors in tree-sitter or code parsing |
| `MARKDOWN` | Errors in markdown parsing |
| `INTEGRATION` | Errors in integration components |
| `CLI` | Errors in CLI processing |
| `FILE_SYSTEM` | Errors in file system operations |
| `DIRECTORY` | Errors in directory management |
| `LLM` | Errors in LLM interactions |
| `SUMMARIZATION` | Errors in text summarization |
| `OUTPUT` | Errors in output generation |
| `NETWORK` | Errors in network operations |
| `VALIDATION` | Errors in data validation |
| `UNKNOWN` | Unknown error source |

### Error Severity

Errors are also categorized by severity to determine the appropriate response:

| Severity | Description |
|----------|-------------|
| `CRITICAL` | Fatal error, processing cannot continue |
| `ERROR` | Serious error, but processing might continue |
| `WARNING` | Non-fatal issue that might affect results |
| `INFO` | Informational message about recoverable issues |

### Error Structure

Each error is represented as a `GitGitError` structure with the following fields:

- `message`: Error message
- `source`: Source of the error
- `severity`: Severity of the error
- `exception`: Original exception (if applicable)
- `file_path`: Path to the file that caused the error (if applicable)
- `context`: Additional context about the error
- `traceback`: Exception traceback (if applicable)
- `recoverable`: Whether the error is recoverable
- `timestamp`: When the error occurred

## Using the Error Handler

### Initialization

The error handler is available as a global instance that can be imported:

```python
from error_handler import global_error_handler
```

You can also create a new instance if needed:

```python
from error_handler import ErrorHandler
handler = ErrorHandler()
```

### Handling Errors

There are several ways to handle errors:

1. **Creating and handling an error manually**:

```python
error = handler.create_error(
    message="Failed to process file",
    source=ErrorSource.FILE_SYSTEM,
    severity=ErrorSeverity.ERROR,
    file_path="/path/to/file.txt"
)
handler.handle_error(error)
```

2. **Handling an exception**:

```python
try:
    process_file("/path/to/file.txt")
except Exception as e:
    handler.handle_exception(
        exception=e,
        source=ErrorSource.FILE_SYSTEM,
        file_path="/path/to/file.txt"
    )
```

3. **Safe execution with error handling**:

```python
result = safe_execute(
    lambda: process_file("/path/to/file.txt"),
    handler,
    ErrorSource.FILE_SYSTEM,
    file_path="/path/to/file.txt",
    default_return=None
)
```

### Custom Error Handlers

You can register custom error handlers for specific error sources and severities:

```python
def custom_file_handler(error):
    # Custom handling logic
    print(f"Custom handler for {error.file_path}")
    return True  # Return True if handled, False otherwise

handler.register_handler(ErrorSource.FILE_SYSTEM, ErrorSeverity.ERROR, custom_file_handler)
```

### Error Reporting

You can get all errors or filter by source:

```python
# Get all errors
all_errors = handler.get_errors()

# Get errors by source
fs_errors = handler.get_errors(source=ErrorSource.FILE_SYSTEM)
```

### Critical Error Checking

You can check if there are any critical errors that would prevent processing from continuing:

```python
if handler.has_critical_errors():
    print("Processing cannot continue due to critical errors")
```

## Best Practices

### 1. Use Appropriate Error Sources

Always use the most specific error source for an error, which helps in determining the appropriate handling strategy.

### 2. Set Severity Correctly

Use appropriate severity levels:
- `CRITICAL`: Fatal errors that prevent the process from continuing
- `ERROR`: Serious errors that might allow some processing to continue
- `WARNING`: Issues that shouldn't stop processing but might affect results
- `INFO`: Informational messages about recoverable issues

### 3. Provide Context

Include relevant context in errors to help with debugging and logging:

```python
error = handler.create_error(
    message="Failed to process repository",
    source=ErrorSource.REPOSITORY,
    context={
        "repo_url": "https://github.com/example/repo",
        "branch": "main",
        "commit": "abc123"
    }
)
```

### 4. Use Safe Execution

The `safe_execute` function is a convenient way to run a function with proper error handling:

```python
result = safe_execute(
    func=lambda: process_file(file_path),
    error_handler=handler,
    source=ErrorSource.FILE_SYSTEM,
    file_path=file_path,
    default_return=None,
    recoverable=True
)
```

### 5. Handle Fallbacks

When implementing error handlers, try to provide fallback mechanisms for recoverable errors:

```python
def handle_chunking_error(error):
    # Fall back to simple text processing
    logger.warning(f"Chunking failed, falling back to simple processing")
    error.context["fallback"] = "simple_processing"
    error.recoverable = True
    return True
```

### 6. Check Recoverability

Always check if an error is recoverable before continuing processing:

```python
if not handler.handle_error(error) or not error.recoverable:
    print("Error is not recoverable, aborting process")
    return
```

## Example Workflow

Here's an example of using the error handling system in a workflow:

```python
def process_repository(repo_url, output_dir):
    handler = global_error_handler
    
    # Step 1: Clone repository
    repo_path = safe_execute(
        lambda: clone_repository(repo_url),
        handler,
        ErrorSource.REPOSITORY,
        context={"repo_url": repo_url},
        default_return=None
    )
    
    if not repo_path:
        return False
    
    # Step 2: Process files
    files = safe_execute(
        lambda: find_files(repo_path),
        handler,
        ErrorSource.FILE_SYSTEM,
        file_path=repo_path,
        default_return=[]
    )
    
    # Process each file with proper error handling
    results = []
    for file_path in files:
        result = safe_execute(
            lambda: process_file(file_path),
            handler,
            ErrorSource.FILE_SYSTEM,
            file_path=file_path,
            default_return=None
        )
        if result:
            results.append(result)
    
    # Step 3: Generate output
    success = safe_execute(
        lambda: generate_output(results, output_dir),
        handler,
        ErrorSource.OUTPUT,
        file_path=output_dir,
        default_return=False
    )
    
    return success
```

## Error Handling in Different Components

### Repository Operations

For repository operations, critical errors (like failing to clone) are usually not recoverable, while less critical issues might allow processing to continue:

```python
try:
    repo = clone_repository(repo_url)
except Exception as e:
    handler.handle_exception(
        exception=e,
        source=ErrorSource.REPOSITORY,
        context={"repo_url": repo_url}
    )
    return None
```

### File System Operations

For file operations, consider different types of errors:
- File not found: May be recoverable by skipping the file
- Permission denied: Usually not recoverable
- Disk space: Critical error that prevents processing

```python
try:
    with open(file_path, 'r') as f:
        content = f.read()
except FileNotFoundError as e:
    # This may be recoverable by skipping the file
    handler.handle_exception(
        exception=e,
        source=ErrorSource.FILE_SYSTEM,
        file_path=file_path,
        recoverable=True
    )
    return None
except PermissionError as e:
    # This is usually not recoverable
    handler.handle_exception(
        exception=e,
        source=ErrorSource.FILE_SYSTEM,
        file_path=file_path,
        recoverable=False
    )
    return None
```

### LLM Operations

For LLM operations, consider different failure modes:
- API connection issues: May be retryable
- Token limit exceeded: May be recoverable by reducing input
- General LLM errors: May be able to continue without summaries

```python
try:
    summary = generate_summary_with_llm(content)
except Exception as e:
    # Check if this is a token limit issue
    if "token limit" in str(e).lower():
        # Recoverable by reducing input
        handler.handle_exception(
            exception=e,
            source=ErrorSource.LLM,
            context={"reduce_input": True},
            recoverable=True
        )
        # Try with shorter input
        summary = generate_summary_with_llm(content[:len(content)//2])
    else:
        # General LLM error
        handler.handle_exception(
            exception=e,
            source=ErrorSource.LLM,
            recoverable=True
        )
        # Skip summarization
        summary = "Summary not available"
```

## Advanced Topics

### Retry Mechanisms

For transient errors like network issues, you can implement retry mechanisms:

```python
def retry_with_backoff(func, max_retries=3, initial_backoff=1):
    """Retry a function with exponential backoff."""
    import time
    
    retries = 0
    while retries < max_retries:
        try:
            return func()
        except Exception as e:
            retries += 1
            if retries == max_retries:
                raise
            
            backoff = initial_backoff * (2 ** (retries - 1))
            print(f"Retry {retries}/{max_retries} after {backoff}s: {e}")
            time.sleep(backoff)
```

### Integration with Workflow Systems

The error handling system can be integrated with workflow management systems to track and report errors:

```python
def run_workflow(steps):
    """Run a workflow with proper error handling."""
    results = []
    
    for step in steps:
        result = safe_execute(
            func=step["function"],
            error_handler=global_error_handler,
            source=step["source"],
            context=step["context"],
            default_return=None
        )
        
        results.append({
            "step": step["name"],
            "result": result,
            "success": result is not None
        })
        
        if result is None and not step.get("optional", False):
            print(f"Workflow aborted at step: {step['name']}")
            break
    
    return results
```

## Conclusion

The GitGit error handling system provides a comprehensive approach to managing errors across all components. By using appropriate error sources, severities, and handling strategies, you can build more robust and resilient applications that gracefully handle failure scenarios.

For more details, refer to the example implementations in `error_handling_examples.py`.