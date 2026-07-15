"""
Repository Exception Hierarchy

Custom exceptions for repository operations with actionable error messages.

Exception Hierarchy:
    RepositoryError (base)
    ├── NotFoundError (resource not found)
    ├── ValidationError (invalid data)
    ├── ConnectionError (database connection failed)
    └── IntegrityError (constraint violation)
"""


class RepositoryError(Exception):
    """Base exception for all repository errors"""

    def __init__(self, message: str, details: dict = None):
        """
        Initialize repository error

        Args:
            message: Human-readable error message
            details: Additional error context (dict)
        """
        super().__init__(message)
        self.message = message
        self.details = details or {}

    def __str__(self) -> str:
        if self.details:
            return f"{self.message} | Details: {self.details}"
        return self.message


class NotFoundError(RepositoryError):
    """Raised when requested resource not found"""

    def __init__(self, resource_type: str, resource_id: str, details: dict = None):
        """
        Initialize not found error

        Args:
            resource_type: Type of resource (e.g., "session", "task")
            resource_id: ID of resource that wasn't found
            details: Additional context
        """
        message = f"{resource_type.capitalize()} not found: {resource_id}"
        super().__init__(message, details)
        self.resource_type = resource_type
        self.resource_id = resource_id


class ValidationError(RepositoryError):
    """Raised when data validation fails"""

    def __init__(self, field: str, value: any, reason: str, details: dict = None):
        """
        Initialize validation error

        Args:
            field: Field name that failed validation
            value: Invalid value
            reason: Why validation failed
            details: Additional context
        """
        message = f"Validation failed for '{field}': {reason} (value: {value})"
        super().__init__(message, details)
        self.field = field
        self.value = value
        self.reason = reason


class ConnectionError(RepositoryError):
    """Raised when database connection fails"""

    def __init__(self, db_path: str, reason: str, details: dict = None):
        """
        Initialize connection error

        Args:
            db_path: Database file path
            reason: Why connection failed
            details: Additional context
        """
        message = f"Database connection failed: {db_path} | Reason: {reason}"
        super().__init__(message, details)
        self.db_path = db_path
        self.reason = reason


class IntegrityError(RepositoryError):
    """Raised when database integrity constraint violated"""

    def __init__(self, constraint: str, reason: str, details: dict = None):
        """
        Initialize integrity error

        Args:
            constraint: Constraint that was violated (e.g., "FOREIGN KEY", "UNIQUE")
            reason: Description of violation
            details: Additional context
        """
        message = f"Integrity constraint violated: {constraint} | {reason}"
        super().__init__(message, details)
        self.constraint = constraint
        self.reason = reason
