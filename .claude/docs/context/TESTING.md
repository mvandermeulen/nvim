
## Testing

- Tests MUST comprehensively cover ALL functionality.
- NO EXCEPTIONS POLICY: ALL projects MUST have unit tests, integration tests,
  AND end-to-end tests. The only way to skip any test type is if I EXPLICITLY
  states: "I AUTHORIZE YOU TO SKIP WRITING TESTS THIS TIME."
- FOR EVERY NEW FEATURE OR BUGFIX, YOU MUST follow TDD:
  1. Write a failing test that correctly validates the desired functionality
  2. Run the test to confirm it fails as expected
  3. Write ONLY enough code to make the failing test pass
  4. Run the test to confirm success
  5. Refactor if needed while keeping tests green
- YOU MUST NEVER implement mocks in end to end tests. We always use real data
  and real APIs.
- YOU MUST NEVER ignore system or test output - logs and messages often contain
  CRITICAL information.
- Test output MUST BE PRISTINE TO PASS. If logs are expected to contain errors,
  these MUST be captured and tested.
