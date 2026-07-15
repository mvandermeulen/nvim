## Project Overview

This repository contains a loose collection of python scripts which are used to 
perform various automation tasks. We would like to improve the quality of the codebase
and make use of modern python features.

## Dependencies

The project uses the following Python dependencies:
- psutil (for system metrics)
- Standard library: asyncio, dataclasses, uuid, datetime
- Pydantic (for data validation and settings management)
- aiosqlite (for async SQLite operations)

## Code Conventions

- Uses Python 3.13+ syntax (generic types with `[T]` syntax)
- Follows Protocol-based design patterns for service interfaces
- Uses dataclasses with frozen=True for immutable data structures
- Async/await patterns for service operations
- Type hints throughout the codebase
- Service results wrapped in ServiceResult[T] dataclass with success/error handling
- Review: `.claude/docs/context/python/PROJECT_CONVENTIONS_AND_STANDARDS.md`
- Review: `.claude/docs/context/python/PYTHON_CODING_CONVENTIONS.md`

## Testing

No test framework is currently configured in the main repository. Check individual submodules for their testing approaches.


## Project Conventions

- Use uv for dependency management
- Add tests for all new functionality
- Maintain >80% test coverage (current min: 81%)
- Follow pre-commit hooks guidelines
- Document public APIs with docstrings

## Project Structure

```
# Use: eza -T -L 3 --all --group-directories-first --ignore-glob=.git

```


- **Package Management**: Always use uv with pyproject.toml, never pip
- **Mirror Structure**: examples/, tests/ mirror the project structure in src/
- **Documentation**: Keep comprehensive docs in `.docs/` directory

## Module Requirements

- **Size**: Maximum 800 lines of code per file
- **Documentation Header**: Every file must include:
  - Description of purpose
- **Validation Function**: Every file needs a main block (`if __name__ == "__main__":`) that tests with real data


## Code Style Guidelines

- Python 3.13+ compatible code
- Type hints required for all functions and methods
- Classes: PascalCase with descriptive names
- Functions/Variables: snake_case
- Constants: UPPERCASE_WITH_UNDERSCORES
- Imports organization with isort:
  1. Standard library imports
  2. Third-party imports
  3. Local application imports
- Error handling: Use specific exception types
- Logging: Use the logging module with appropriate levels
- Use dataclasses for structured data when applicable
- Review: `.claude/docs/guides/python.md`
- Review: `.claude/docs/guides/using-uv.md`



