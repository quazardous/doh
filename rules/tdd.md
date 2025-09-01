# Test-Driven Development (TDD) Rules
<!-- File version: 0.1.0 | Created: 2025-09-01 (Task 015) -->

## Core Principle

**Write tests BEFORE implementation.** Every feature starts with a failing test that defines expected behavior.

## The TDD Cycle

### 1. RED: Write a Failing Test
- Write the smallest possible test that captures one requirement
- Run the test and verify it fails for the expected reason
- The failure confirms the test is actually testing something

### 2. GREEN: Make the Test Pass
- Write the minimal code necessary to make the test pass
- Don't worry about elegance or optimization yet
- Focus only on making the test green

### 3. REFACTOR: Improve the Code
- Clean up the implementation while keeping tests green
- Remove duplication, improve naming, simplify logic
- Run tests after each change to ensure nothing breaks

## Test Organization

### Directory Structure
```
./tests/
├── unit/           # Isolated function/component tests
├── integration/    # Multi-component interaction tests
├── fixtures/       # Test data and mock files
├── helpers/        # Shared test utilities
└── run.sh         # Main test runner
```

### File Naming Conventions
- Test files: `test_*.sh` or `*_test.sh`
- Test functions: `test_<description>()` 
- Setup/teardown: `setup()`, `teardown()`
- Helpers: `assert_*()`, `mock_*()`, `stub_*()`

## Test Structure

### Arrange-Act-Assert Pattern
```bash
test_user_creation() {
    # Arrange: Set up test data and environment
    local test_user="testuser"
    local test_email="test@example.com"
    
    # Act: Execute the function being tested
    local result=$(create_user "$test_user" "$test_email")
    
    # Assert: Verify the outcome
    assert_equals "0" "$?" "User creation should succeed"
    assert_contains "$result" "User created" "Should return success message"
}
```

### Test Independence
- Each test must be completely independent
- Tests can run in any order without affecting each other
- Use setup/teardown for shared initialization/cleanup
- Never rely on test execution order

## Writing Good Tests

### Characteristics of Good Tests
1. **Fast**: Execute in milliseconds, not seconds
2. **Independent**: No dependencies on other tests
3. **Repeatable**: Same result every time
4. **Self-Validating**: Clear pass/fail result
5. **Timely**: Written just before the code

### Test Naming
Tests should clearly describe what they test:
- `test_<component>_<action>_<expected_result>()`
- Examples:
  - `test_auth_valid_credentials_returns_token()`
  - `test_parser_empty_input_throws_error()`
  - `test_database_connection_timeout_retries()`

### One Assertion Per Test (Preferred)
```bash
# Good: Single focused test
test_user_email_validation() {
    assert_false $(validate_email "invalid")
}

test_user_email_accepts_valid() {
    assert_true $(validate_email "user@example.com")
}

# Avoid: Multiple assertions testing different things
test_user_validation() {
    assert_false $(validate_email "invalid")
    assert_true $(validate_email "user@example.com")
    assert_false $(validate_username "")
    assert_true $(validate_username "validuser")
}
```

## Test Coverage

### What to Test
- **Business Logic**: Core functionality and algorithms
- **Edge Cases**: Boundary conditions, empty inputs, nulls
- **Error Paths**: Exception handling and error conditions
- **Integration Points**: API calls, database operations
- **Public Interfaces**: All public functions/methods

### What NOT to Test
- **Language Features**: Don't test the programming language itself
- **External Libraries**: Trust that dependencies work
- **Private Implementation Details**: Test behavior, not implementation
- **Generated Code**: Focus on the generator, not output
- **Trivial Code**: Simple getters/setters without logic

## Mocking and Stubbing

### When to Mock
- External services (APIs, databases)
- File system operations
- Time-dependent functionality
- Random number generation
- Expensive or slow operations

### Mock Naming Convention
```bash
# Mock function follows original name with mock_ prefix
mock_database_query() {
    echo "mocked_result"
}

# Stub returns predetermined values
stub_current_time() {
    echo "2025-01-01T00:00:00Z"
}
```

## Test Data Management

### Fixtures
- Place test data in `./tests/fixtures/`
- Use descriptive names: `valid_user.json`, `malformed_request.txt`
- Keep fixtures minimal and focused
- Version control test data with the code

### Test Data Builders
```bash
# Builder functions for complex test data
build_test_user() {
    local name="${1:-TestUser}"
    local email="${2:-test@example.com}"
    echo "{\"name\": \"$name\", \"email\": \"$email\"}"
}
```

## Continuous Testing

### Test Execution Triggers
1. **Pre-commit**: Run relevant unit tests
2. **Pre-push**: Run full test suite
3. **Pull Request**: Run all tests + integration tests
4. **Post-merge**: Run full regression suite

### Test Performance Goals
- Unit tests: < 100ms each
- Integration tests: < 1 second each
- Full suite: < 30 seconds total
- Feedback loop: < 2 minutes from code change to test result

## Common Anti-Patterns to Avoid

### ❌ Testing Implementation Instead of Behavior
```bash
# Bad: Tests internal implementation
test_function_calls_helper() {
    # Checking if specific internal function was called
}

# Good: Tests observable behavior
test_function_produces_expected_output() {
    # Checking the actual result
}
```

### ❌ Conditional Logic in Tests
```bash
# Bad: Test with conditions
test_maybe_valid() {
    if [[ $ENVIRONMENT == "prod" ]]; then
        assert_true $(some_function)
    else
        assert_false $(some_function)
    fi
}

# Good: Separate explicit tests
test_in_production_environment() {
    ENVIRONMENT="prod" assert_true $(some_function)
}
```

### ❌ Test Interdependencies
```bash
# Bad: Tests depend on execution order
test_step_1() {
    echo "data" > /tmp/testfile
}

test_step_2() {
    # Assumes test_step_1 ran first
    local data=$(cat /tmp/testfile)
}

# Good: Each test is self-contained
test_with_file() {
    echo "data" > /tmp/testfile
    # ... test logic ...
    rm /tmp/testfile
}
```

## Test Documentation

### Test Comments
Only add comments when the test intent isn't obvious:
```bash
# Good: Self-documenting test name
test_password_requires_minimum_eight_characters() {
    assert_false $(validate_password "short")
}

# When comment is needed:
test_rate_limit_blocks_after_threshold() {
    # Simulate 10 rapid requests to trigger rate limiting
    for i in {1..10}; do
        make_request
    done
    assert_equals "429" "$(get_last_status_code)"
}
```

## Debugging Failed Tests

### Test Failure Investigation
1. **Read the assertion message** - It should clearly indicate what failed
2. **Check test independence** - Run the single test in isolation
3. **Verify test data** - Ensure fixtures and mocks are correct
4. **Add debug output** - Temporarily add echo statements
5. **Simplify the test** - Reduce to minimal failing case

### Flaky Test Resolution
If a test fails intermittently:
- Remove time dependencies
- Eliminate race conditions
- Mock external dependencies
- Use deterministic test data
- Add proper wait/retry logic

## Summary

Remember: **Test behavior, not implementation.** Write tests that describe what the system should do, not how it does it. Keep tests simple, focused, and fast. A good test suite gives confidence to refactor and extend code without fear of breaking existing functionality.