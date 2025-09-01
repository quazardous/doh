# Claude Code Project Notes

## Rules for Working with .claude/rules/

**IMPORTANT**: Never update files in `.claude/rules/` without explicit user approval.

The user must specifically tell you to modify rule files. Do not make changes to:
- `.claude/rules/task-workflow.md`
- `.claude/rules/standard-patterns.md`
- Any other files in `.claude/rules/` directory

These files contain critical workflow patterns that should only be modified when the user explicitly requests changes.

## Project Context

This is the DOH (Development Operations Helper) project for task and epic management.

See [DEVELOPMENT.md](DEVELOPMENT.md) for DOH-specific development context and versioning information.

## Commands Available

Run commands using the format `/doh:command-name`

## Testing

The DOH project uses a custom lightweight test framework with comprehensive test coverage.

### Running Tests
```bash
# Run all tests (recommended)
./tests/run.sh

# Run specific test file
./tests/test_launcher.sh tests/unit/test_example.sh

# Debug test issues
VERBOSE=true ./tests/test_launcher.sh tests/unit/test_example.sh
```

### Writing Tests
- Place unit tests in `tests/unit/`
- Place integration tests in `tests/integration/`
- Use the test framework functions (prefixed with `_tf_`)
- Follow existing test patterns in the codebase

### Test Framework Guidelines
- Always use `./tests/test_launcher.sh` to run individual tests
- Use `_tf_setup()` and `_tf_teardown()` for test lifecycle
- All assertion functions return proper exit codes
- Tests should be isolated and not depend on external state

**Comprehensive Testing Guide**: See [DOH TDD Guide](docs/doh-tdd.md) for detailed patterns and examples.