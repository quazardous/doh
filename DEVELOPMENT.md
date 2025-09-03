# DOH Development Project

This project uses the DOH system to develop DOH itself - a self-hosting approach where we eat our own dog food.

## File Versioning

All new and updated files include `file_version` to track when features were introduced. Existing files are not retroactively versioned.

## DOH Directory Structure

DOH uses two distinct directories to organize project data:

### DOH_PROJECT_DIR (Default: `.doh/`)
**Purpose**: Versioned project data that should be committed to the repository.

**Contains**:
- PRDs (Product Requirements Documents)
- Epics and tasks
- Project configuration files
- Any data that needs to be shared across the team and versioned

**Location**: Inside the project repository (typically `.doh/` folder)

**Environment Variable**: `DOH_PROJECT_DIR` - can override the default location

### DOH_GLOBAL_DIR (Default: `~/.doh/`)
**Purpose**: Persistent global data that should NOT be versioned.

**Contains**:
- Local workspace configurations
- Temporary files and caches
- User-specific settings
- Build artifacts and logs

**Location**: Outside the project repository (typically `~/.doh/` folder)

**Organization**: Data is organized in per-project folders using path hashing to ensure complete isolation between different projects:
```
~/.doh/
├── abc123def/     # Hash of /path/to/project1
│   ├── cache/
│   ├── logs/
│   └── workspace.conf
├── xyz789uvw/     # Hash of /path/to/project2
│   ├── cache/
│   ├── logs/
│   └── workspace.conf
```

This ensures that multiple DOH projects can coexist without data conflicts, even if they have similar names or structures.

**Environment Variable**: `DOH_GLOBAL_DIR` - can override the default location

### Usage Examples
```bash
# These directories are automatically configured by DOH
echo "Project data: $(doh_project_dir)"     # Returns DOH_PROJECT_DIR path
echo "Global data: $(doh_global_dir)"       # Returns DOH_GLOBAL_DIR path

# Override defaults with environment variables
export DOH_PROJECT_DIR="/custom/project/doh"
export DOH_GLOBAL_DIR="/custom/global/doh"
```

## Version Management

The current DOH version is maintained in the `VERSION` file at the project root. This file is the single source of truth for the project version and is used by all DOH commands and scripts.

To check the current version:
```bash
cat VERSION
# or
./.claude/scripts/doh/api.sh version get_current
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

### Test Coverage Requirements

**MANDATORY**: Create permanent tests for all architectural changes, core functionality, and library modifications that provide meaningful coverage and prevent regressions.

**When to Write Tests**:
- ✅ **Core library changes** (e.g., dependency management, API refactoring)  
- ✅ **Breaking changes** (e.g., function renames, behavior modifications)
- ✅ **Critical functionality** (e.g., version management, file operations)
- ✅ **Integration points** (e.g., library sourcing, command workflows)
- ✅ **Bug fixes** that could regress

**When Tests Are Optional**:
- ⚪ Simple configuration changes
- ⚪ Documentation updates  
- ⚪ Trivial one-line fixes
- ⚪ Cosmetic improvements

**Test Quality Standards**:
- Tests must be **verbose and descriptive** to aid debugging
- Tests must **reflect real usage patterns**, not just exercise code
- Tests must be **designed to catch actual problems**, not just achieve coverage
- Tests should **fail meaningfully** when functionality breaks

**Example**: Task 025 (library no-op pattern) required a comprehensive test suite covering:
- All 18 libraries source without side effects
- Proper dependency chains are maintained  
- Source guards prevent duplicate loading
- Core functions remain operational after refactoring

This prevented regressions and validated the architectural changes were working correctly.

## Refactoring Policy

### No Wrapper Functions

**CRITICAL RULE**: When refactoring, NEVER create wrapper functions or aliases to bridge API changes.

**❌ Wrong Approach**:
```bash
# DON'T create wrapper functions like this:
increment_version() { version_increment "$@"; }
validate_version() { version_validate "$@"; }
```

**✅ Correct Approach**: Update all calling code to use the proper API names directly:
```bash
# Update test files to use correct function names:
result=$(version_increment "1.0.0" "patch")   # Not increment_version
version_validate "1.0.0"                      # Not validate_version
```

**Why This Rule Exists**:
- Prevents code duplication and maintenance overhead
- Forces proper API consistency across the codebase
- Eliminates confusion about which function to use
- Maintains clean, direct function calls
- Follows the principle: "Either use or delete from codebase completely"

**When Refactoring**:
1. Identify all places using the old API
2. Update them to use the correct API directly
3. Never create bridge/wrapper functions
4. Test thoroughly to ensure all references are updated

## Documentation
- [Local Versioning Guide](docs/versioning.md) - Detailed versioning specifics for DOH development
- [Writing Good Scripts](docs/writing-good-scripts.md) - Best practices for shell scripting in DOH project
- [DOH Data API Guide](docs/doh-data-api.md) - Authoritative API reference for DOH internal data manipulation
- [DOH TDD Guide](docs/doh-tdd.md) - Comprehensive test-driven development patterns and framework usage

---

**Last Updated**: 2025-08-31T19:13:44Z