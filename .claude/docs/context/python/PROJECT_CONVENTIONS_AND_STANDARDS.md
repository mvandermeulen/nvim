# Project Conventions and Standards

## Style & Conventions

### Python Style Guide

- **Follow PEP8** with these specific choices:
  - Line length: 100 characters (set by Ruff in pyproject.toml)
  - Use double quotes for strings
  - Use trailing commas in multi-line structures
- **Always use type hints** for function signatures and class attributes
- **Format with `ruff format`** (faster alternative to Black)
- **Use `pydantic` v2** for data validation and settings management

### Docstring Standards

Use Google-style docstrings for all public functions, classes, and modules:

```python
def calculate_discount(
    price: Decimal,
    discount_percent: float,
    min_amount: Decimal = Decimal("0.01")
) -> Decimal:
    """
    Calculate the discounted price for a product.

    Args:
        price: Original price of the product
        discount_percent: Discount percentage (0-100)
        min_amount: Minimum allowed final price

    Returns:
        Final price after applying discount

    Raises:
        ValueError: If discount_percent is not between 0 and 100
        ValueError: If final price would be below min_amount

    Example:
        >>> calculate_discount(Decimal("100"), 20)
        Decimal('80.00')
    """
```

### Naming Conventions

- **Variables and functions**: `snake_case`
- **Classes**: `PascalCase`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private attributes/methods**: `_leading_underscore`
- **Type aliases**: `PascalCase`
- **Enum values**: `UPPER_SNAKE_CASE`

## Code Structure & Modularity

### File and Function Limits

- **Never create a file longer than 800 lines of code**. If approaching this limit, refactor by splitting into modules.
- **Functions should be under 50 lines** with a single, clear responsibility.
- **Classes should be under 300 lines** and represent a single concept or entity.
- **Organize code into clearly separated modules**, grouped by feature or responsibility.
- **Line length should be max 100 characters** ruff rule in pyproject.toml
- **Use venv_linux** (the virtual environment) whenever executing Python commands, including for unit tests.

### Project Architecture

Follow strict vertical slice architecture with tests living next to the code they test:

```
src/project/
    __init__.py
    main.py
    tests/
        test_main.py
    conftest.py

    # Core modules
    database/
        __init__.py
        connection.py
        models.py
        tests/
            test_connection.py
            test_models.py

    auth/
        __init__.py
        authentication.py
        authorization.py
        tests/
            test_authentication.py
            test_authorization.py

    # Feature slices
    features/
        user_management/
            __init__.py
            handlers.py
            validators.py
            tests/
                test_handlers.py
                test_validators.py

        payment_processing/
            __init__.py
            processor.py
            gateway.py
            tests/
                test_processor.py
                test_gateway.py
```

## Data Models and Validation

### Example Pydantic Models strict with pydantic v2

```python
from pydantic import BaseModel, Field, validator, EmailStr
from datetime import datetime
from decimal import Decimal

class ProductBase(BaseModel):
    """Base product model with common fields."""
    name: str = Field(..., min_length=1, max_length=255)
    description: str | None = None
    price: Decimal = Field(..., gt=0, decimal_places=2)
    category: str
    tags: list[str] = []

    @validator('price')
    def validate_price(cls, v):
        if v > Decimal('1000000'):
            raise ValueError('Price cannot exceed 1,000,000')
        return v

    class Config:
        json_encoders = {
            Decimal: str,
            datetime: lambda v: v.isoformat()
        }

class ProductCreate(ProductBase):
    """Model for creating new products."""
    pass

class ProductUpdate(BaseModel):
    """Model for updating products - all fields optional."""
    name: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = None
    price: Decimal | None = Field(None, gt=0, decimal_places=2)
    category: str | None = None
    tags: list[str] | None = None

class Product(ProductBase):
    """Complete product model with database fields."""
    id: int
    created_at: datetime
    updated_at: datetime
    is_active: bool = True

    class Config:
        from_attributes = True  # Enable ORM mode
```

## Field Naming Conventions

```sql
-- Primary keys: {entity}_id
session_id, lead_id, message_id

-- Foreign keys: {referenced_entity}_id
session_id REFERENCES sessions(session_id)
agency_id REFERENCES agencies(agency_id)

-- Timestamps: {action}_at
created_at, updated_at, started_at, expires_at

-- Booleans: is_{state}
is_connected, is_active, is_qualified

-- Counts: {entity}_count
message_count, lead_count, notification_count

-- Durations: {property}_{unit}
duration_seconds, timeout_minutes
```

## Repository Pattern Auto-Derivation

The enhanced BaseRepository automatically derives table names and primary keys:

```python
# ✅ STANDARDIZED: Convention-based repositories
class LeadRepository(BaseRepository[Lead]):
    def __init__(self):
        super().__init__()  # Auto-derives "leads" and "lead_id"

class SessionRepository(BaseRepository[AvatarSession]):
    def __init__(self):
        super().__init__()  # Auto-derives "sessions" and "session_id"
```

**Benefits**:

- ✅ Self-documenting schema
- ✅ Clear foreign key relationships
- ✅ Eliminates repository method overrides
- ✅ Consistent with entity naming patterns

### Model-Database Alignment

Models mirror database fields exactly to eliminate field mapping complexity:

```python
# ✅ STANDARDIZED: Models mirror database exactly
class Lead(BaseModel):
    lead_id: UUID = Field(default_factory=uuid4)  # Matches database field
    session_id: UUID                               # Matches database field
    agency_id: str                                 # Matches database field
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))

    model_config = ConfigDict(
        use_enum_values=True,
        populate_by_name=True,
        alias_generator=None  # Use exact field names
    )
```

## API Route Standards

```python
# ✅ STANDARDIZED: RESTful with consistent parameter naming
router = APIRouter(prefix="/api/v1/leads", tags=["leads"])

@router.get("/{lead_id}")           # GET /api/v1/leads/{lead_id}
@router.put("/{lead_id}")           # PUT /api/v1/leads/{lead_id}
@router.delete("/{lead_id}")        # DELETE /api/v1/leads/{lead_id}

# Sub-resources
@router.get("/{lead_id}/messages")  # GET /api/v1/leads/{lead_id}/messages
@router.get("/agency/{agency_id}")  # GET /api/v1/leads/agency/{agency_id}
```


## Performance Considerations

### Optimization Guidelines

- Profile before optimizing - use `cProfile` or `py-spy`
- Use `lru_cache` for expensive computations
- Prefer generators for large datasets
- Use `asyncio` for I/O-bound operations
- Consider `multiprocessing` for CPU-bound tasks
- Cache database queries appropriately

### Example Optimization

```python
from functools import lru_cache
import asyncio
from typing import AsyncIterator

@lru_cache(maxsize=1000)
def expensive_calculation(n: int) -> int:
    """Cache results of expensive calculations."""
    # Complex computation here
    return result

async def process_large_dataset() -> AsyncIterator[dict]:
    """Process large dataset without loading all into memory."""
    async with aiofiles.open('large_file.json', mode='r') as f:
        async for line in f:
            data = json.loads(line)
            # Process and yield each item
            yield process_item(data)
```

## Monitoring and Observability

### Structured Logging

```python
import structlog

logger = structlog.get_logger()

# Log with context
logger.info(
    "payment_processed",
    user_id=user.id,
    amount=amount,
    currency="USD",
    processing_time=processing_time
)
```

## Error Handling

### Exception Best Practices

```python
# Create custom exceptions for your domain
class PaymentError(Exception):
    """Base exception for payment-related errors."""
    pass

class InsufficientFundsError(PaymentError):
    """Raised when account has insufficient funds."""
    def __init__(self, required: Decimal, available: Decimal):
        self.required = required
        self.available = available
        super().__init__(
            f"Insufficient funds: required {required}, available {available}"
        )

# Use specific exception handling
try:
    process_payment(amount)
except InsufficientFundsError as e:
    logger.warning(f"Payment failed: {e}")
    return PaymentResult(success=False, reason="insufficient_funds")
except PaymentError as e:
    logger.error(f"Payment error: {e}")
    return PaymentResult(success=False, reason="payment_error")

# Use context managers for resource management
from contextlib import contextmanager

@contextmanager
def database_transaction():
    """Provide a transactional scope for database operations."""
    conn = get_connection()
    trans = conn.begin_transaction()
    try:
        yield conn
        trans.commit()
    except Exception:
        trans.rollback()
        raise
    finally:
        conn.close()
```

### Logging Strategy

```python
import logging
from functools import wraps

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Log function entry/exit for debugging
def log_execution(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        logger.debug(f"Entering {func.__name__}")
        try:
            result = func(*args, **kwargs)
            logger.debug(f"Exiting {func.__name__} successfully")
            return result
        except Exception as e:
            logger.exception(f"Error in {func.__name__}: {e}")
            raise
    return wrapper
```

## Documentation Standards

### Code Documentation

- Every module should have a docstring explaining its purpose
- Never end a docstring with a period (.) to avoid confusion with sentences
- Public functions must have complete docstrings
- Complex logic should have inline comments with `# Reason:` prefix
- Keep README.md updated with setup instructions and examples
- Maintain CHANGELOG.md for version history

### API Documentation

```python
from fastapi import APIRouter, HTTPException, status
from typing import List

router = APIRouter(prefix="/products", tags=["products"])

@router.get(
    "/",
    response_model=list[Product],
    summary="List all products",
    description="Retrieve a paginated list of all active products"
)
async def list_products(
    skip: int = 0,
    limit: int = 100,
    category: str | None = None
) -> list[Product]:
    """
    Retrieve products with optional filtering.

    - **skip**: Number of products to skip (for pagination)
    - **limit**: Maximum number of products to return
    - **category**: Filter by product category
    """
    # Implementation here
```

## Configuration Management

### Environment Variables and Settings

```python
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    """Application settings with validation."""
    app_name: str = "MyApp"
    debug: bool = False
    database_url: str
    redis_url: str = "redis://localhost:6379"
    api_key: str
    max_connections: int = 100

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False

@lru_cache()
def get_settings() -> Settings:
    """Get cached settings instance."""
    return Settings()

# Usage
settings = get_settings()
```








