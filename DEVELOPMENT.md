# DOH Development Project

This project uses the DOH system to develop DOH itself - a self-hosting approach where we eat our own dog food.

## File Versioning

All new and updated files include `file_version` to track when features were introduced. Existing files are not retroactively versioned.

## Version Management

The current DOH version is maintained in the `VERSION` file at the project root. This file is the single source of truth for the project version and is used by all DOH commands and scripts.

To check the current version:
```bash
cat VERSION
# or
source .claude/scripts/doh/lib/version.sh && get_current_version
```

## Test-Driven Development

DOH uses a lightweight custom test framework for comprehensive testing. The framework provides simple assertions, parallel test execution, and TAP-compatible output.

### Testing Workflow
```bash
# Run all tests
./tests/run.sh

# Run specific test
./tests/test_launcher.sh tests/unit/test_example.sh

# Run with verbose output
VERBOSE=true ./tests/run.sh
```

### Test Directory Structure
```
tests/
├── run.sh                    # Main test runner
├── test_launcher.sh          # Single test executor
├── helpers/                  # Test framework and utilities
│   └── test_framework.sh     # Core test framework
├── unit/                     # Unit tests
├── integration/             # Integration tests
└── fixtures/                # Test data and mocks
```

**Detailed TDD Guide**: See [DOH TDD Guide](docs/doh-tdd.md) for comprehensive testing patterns and examples.

## Documentation
- [Local Versioning Guide](docs/versioning.md) - Detailed versioning specifics for DOH development
- [Writing Good Scripts](docs/writing-good-scripts.md) - Best practices for shell scripting in DOH project
- [DOH Data API Guide](docs/doh-data-api.md) - Authoritative API reference for DOH internal data manipulation
- [DOH TDD Guide](docs/doh-tdd.md) - Comprehensive test-driven development patterns and framework usage

---

**Last Updated**: 2025-08-31T19:13:44Z