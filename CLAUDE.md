# Claude Code Project Notes

**IMPORTANT**: For comprehensive Claude Code guidelines, see [.claude/CLAUDE.md](.claude/CLAUDE.md)

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

## DOH API Helper Script

**RECOMMENDED**: Use the DOH API helper script instead of manually sourcing libraries.

### Quick Usage
```bash
# Call public DOH library functions (function names without library prefix)
./.claude/scripts/doh/api.sh <library> <function> [args...]

# Call private DOH library functions (with --private flag)
./.claude/scripts/doh/api.sh --private <library> <function> [args...]
```

### Public Function Examples
```bash
# Version operations - call functions without version_ prefix
./.claude/scripts/doh/api.sh version get_current
./.claude/scripts/doh/api.sh version get_file ".doh/epics/versioning/005.md"
./.claude/scripts/doh/api.sh version validate "1.2.3"
./.claude/scripts/doh/api.sh version compare "1.0.0" "2.0.0"
./.claude/scripts/doh/api.sh version increment "1.0.0" "patch"

# Frontmatter operations - call functions without frontmatter_ prefix
./.claude/scripts/doh/api.sh frontmatter get_field "file.md" "field_name"
./.claude/scripts/doh/api.sh frontmatter update_field "file.md" "status" "completed"
./.claude/scripts/doh/api.sh frontmatter has "file.md"
./.claude/scripts/doh/api.sh frontmatter validate "file.md"

# Task operations - call functions without task_ prefix
./.claude/scripts/doh/api.sh task get_status ".doh/epics/data-api-sanity/032.md"
./.claude/scripts/doh/api.sh task is_completed ".doh/epics/data-api-sanity/032.md"
./.claude/scripts/doh/api.sh task get_name ".doh/epics/data-api-sanity/032.md"

# DOH core operations
./.claude/scripts/doh/api.sh doh find_root
```

### Private Function Examples
```bash
# Call private functions with --private flag (function names without _library_ prefix)
./.claude/scripts/doh/api.sh --private version to_number "1.0.0"
./.claude/scripts/doh/api.sh --private version prerelease_to_adjustment "1.0.0-alpha"
```

### Benefits
- **Clean API**: Call functions without library prefixes
- **Private function access**: Use `--private` flag to call internal functions
- **Automatic dependency resolution**: Libraries source their dependencies automatically
- **Error handling**: Shows available functions when function not found
- **Return value handling**: Preserves exact exit codes from underlying functions

### API Convention
- **Public functions**: Call with function name only (library prefix handled internally)
  - `api.sh version get_current` → calls `version_get_current()`
  - `api.sh task is_completed "file.md"` → calls `task_is_completed()`
- **Private functions**: Use `--private` flag with function name only
  - `api.sh --private version to_number "1.0.0"` → calls `_version_to_number()`

### Usage Examples
```bash
# Public function calls - function name without library prefix
./.claude/scripts/doh/api.sh version get_current
./.claude/scripts/doh/api.sh frontmatter get_field "file.md" "status"
./.claude/scripts/doh/api.sh task is_completed "task.md"

# Private function calls - requires --private flag
./.claude/scripts/doh/api.sh --private version to_number "1.0.0"
```

## DOH Library Reference

### Available Libraries and Functions

| Library | Public Functions (call without prefix) | Private Functions (use --private) |
|---------|----------------------------------------|-----------------------------------|
| `doh` | `find_root`, `project_id` | |
| `dohenv` | `load`, `is_loaded` | |
| `frontmatter` | `get_field`, `update_field`, `has`, `validate`, `extract`, `add_field`, `remove_field`, `get_fields`, `pretty_print`, `merge`, `create_markdown`, `query`, `bulk_update` | |
| `version` | `get_current`, `get_file`, `set_file`, `increment`, `set_current`, `bump_current`, `bump_file`, `compare`, `validate`, `find_files_without_file_version`, `find_inconsistencies`, `list` | `to_number`, `prerelease_to_adjustment` |
| `task` | `is_completed`, `get_status`, `list_epic_tasks`, `calculate_epic_progress`, `verify_completion`, `get_name`, `is_parallel` | |
| `numbering` | `get_next` | |
| `workspace` | | |

### Error Handling

The helper script provides clear error messages and proper exit codes:
- **Library not found**: Shows expected library path and exits with code 1
- **Public function not found**: Lists all available public functions for the library and exits with code 1
- **Private function not found**: Lists all available private functions for the library and exits with code 1
- **Invalid arguments**: Shows proper usage syntax with examples and exits with code 1
- **Function execution**: Preserves exact exit code from the called function

### Return Values

The API helper preserves all return values from the underlying DOH functions:
```bash
# Success cases return 0
./.claude/scripts/doh/api.sh version validate "1.0.0"  # Exit code: 0
./.claude/scripts/doh/api.sh task is_completed "completed_task.md"  # Exit code: 0

# Failure cases return 1 (or other appropriate codes)
./.claude/scripts/doh/api.sh version validate "invalid"  # Exit code: 1
./.claude/scripts/doh/api.sh task is_completed "pending_task.md"  # Exit code: 1
```

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