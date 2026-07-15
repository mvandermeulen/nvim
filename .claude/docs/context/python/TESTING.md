# Testing

## Testing Requirements

<test_coverage_mandate>
- Tests MUST cover all implemented functionality
- Rationale: Comprehensive testing prevents regressions and ensures reliability
</test_coverage_mandate>

<test_output_standards>
- Never ignore system or test output - logs contain critical debugging information
- Test output must be pristine to pass
- If logs should contain errors, capture and test those error conditions
</test_output_standards>

<comprehensive_testing_policy>
- NO EXCEPTIONS: Every project requires unit tests, integration tests, AND end-to-end tests
- If you believe a test type doesn't apply, you need explicit authorization: "I AUTHORIZE YOU TO SKIP WRITING TESTS THIS TIME"
- Rationale: Different test types catch different categories of issues
</comprehensive_testing_policy>

<tdd_methodology>
Test-Driven Development is our standard approach:
- Write tests before implementation code
- Write only enough code to make failing tests pass
- Refactor continuously while maintaining green tests
</tdd_methodology>

<bdd>
Behavior-Driven Testing
No "unit tests" - this term is not helpful. Tests should verify expected behavior, treating implementation as a black box
Test through the public API exclusively - internals should be invisible to tests
No 1:1 mapping between test files and implementation files
Tests that examine internal implementation details are wasteful and should be avoided
Coverage targets: 100% coverage should be expected at all times, but these tests must ALWAYS be based on business behaviour, not implementation details
Tests must document expected business behaviour
</bdd>

<tdd_cycle>
1. Write a failing test that defines desired functionality
2. Run test to confirm expected failure
3. Write minimal code to make the test pass
4. Run test to confirm success
5. Refactor code while keeping tests green
6. Repeat cycle for each feature or bugfix
</tdd_cycle>

<test_data_pattern>

Use factory functions with optional overrides for test data:

```
const getMockPaymentPostPaymentRequest = (
  overrides?: Partial<PostPaymentsRequestV3>
): PostPaymentsRequestV3 => {
  return {
    CardAccountId: "1234567890123456",
    Amount: 100,
    Source: "Web",
    AccountStatus: "Normal",
    LastName: "Doe",
    DateOfBirth: "1980-01-01",
    PayingCardDetails: {
      Cvv: "123",
      Token: "token",
    },
    AddressDetails: getMockAddressDetails(),
    Brand: "Visa",
    ...overrides,
  };
};

const getMockAddressDetails = (
  overrides?: Partial<AddressDetails>
): AddressDetails => {
  return {
    HouseNumber: "123",
    HouseName: "Test House",
    AddressLine1: "Test Address Line 1",
    AddressLine2: "Test Address Line 2",
    City: "Test City",
    ...overrides,
  };
};
```
Key principles:

- Always return complete objects with sensible defaults
- Accept optional Partial<T> overrides
- Build incrementally - extract nested object factories as needed
- Compose factories for complex objects
- Consider using a test data builder pattern for very complex objects

</test_data_pattern>


## 🧪 Testing Strategy

### Test-Driven Development (TDD)

1. **Write the test first** - Define expected behavior before implementation
2. **Watch it fail** - Ensure the test actually tests something
3. **Write minimal code** - Just enough to make the test pass
4. **Refactor** - Improve code while keeping tests green
5. **Repeat** - One test at a time

### Testing Best Practices

```python
# Always use pytest fixtures for setup
import pytest
from datetime import datetime

@pytest.fixture
def sample_user():
    """Provide a sample user for testing."""
    return User(
        id=123,
        name="Test User",
        email="test@example.com",
        created_at=datetime.now()
    )

# Use descriptive test names
def test_user_can_update_email_when_valid(sample_user):
    """Test that users can update their email with valid input."""
    new_email = "newemail@example.com"
    sample_user.update_email(new_email)
    assert sample_user.email == new_email

# Test edge cases and error conditions
def test_user_update_email_fails_with_invalid_format(sample_user):
    """Test that invalid email formats are rejected."""
    with pytest.raises(ValidationError) as exc_info:
        sample_user.update_email("not-an-email")
    assert "Invalid email format" in str(exc_info.value)
```

### Test Organization

- Unit tests: Test individual functions/methods in isolation
- Integration tests: Test component interactions
- End-to-end tests: Test complete user workflows
- Keep test files next to the code they test
- Use `conftest.py` for shared fixtures
- Aim for 80%+ code coverage, but focus on critical paths



