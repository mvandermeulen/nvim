# Security

## Best Practices

### Security Guidelines

- Never commit secrets - use environment variables
- Validate all user input with Pydantic
- Use parameterized queries for database operations
- Implement rate limiting for APIs
- Keep dependencies updated with `uv`
- Use HTTPS for all external communications
- Implement proper authentication and authorization

### Example Security Implementation

```python
from passlib.context import CryptContext
import secrets

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """Hash password using bcrypt."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)

def generate_secure_token(length: int = 32) -> str:
    """Generate a cryptographically secure random token."""
    return secrets.token_urlsafe(length)
```


