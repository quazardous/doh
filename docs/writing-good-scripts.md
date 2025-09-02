# Writing Good Scripts

This document outlines best practices for writing maintainable and robust shell scripts in the DOH project.

## Script Structure

### File Headers

Every script should start with a clear header:

```bash
#!/bin/bash
# Script Description: Brief description of what this script does
# File version: 1.0.0 | Created: 2025-09-01
# Dependencies: lib1.sh, lib2.sh
```

### Modern DOH Architecture: Primary Entry Points

The DOH project provides two primary entry points that should be used instead of direct library sourcing:

## PRIMARY ENTRY POINTS

### 1. Helper Bootstrap (`.claude/scripts/doh/helper.sh`) - **FOR CLI OPERATIONS**

The helper bootstrap is the **primary entry point** for all CLI operations and consolidated functionality:

```bash
# Source the helper bootstrap - primary CLI entry point
source ".claude/scripts/doh/helper.sh"

# CLI operations through helper system
helper_epic_list "active"                    # List active epics
helper_prd_status "003"                      # Show PRD status  
helper_workflow_next                         # Show next tasks
helper_core_init                             # Initialize DOH project
```

**Key Benefits:**
- **Dynamic Discovery**: Automatically discovers available helpers
- **Consolidated Operations**: Groups related functionality
- **Consistent Interface**: All CLI operations through `helper_domain_action()` pattern
- **Bootstrap Protection**: Helpers cannot be called directly

### 2. API Helper (`.claude/scripts/doh/api.sh`) - **FOR EXTERNAL SCRIPTS**

The API helper is the **primary entry point** for external scripts and clean function calls:

```bash
# API calls - primary external entry point
current_version="$(./.claude/scripts/doh/api.sh version get_current)"
task_status="$(./.claude/scripts/doh/api.sh task get_status "task.md")"

# Private function access
version_number="$(./.claude/scripts/doh/api.sh --private version to_number "1.0.0")"
```

**Key Benefits:**
- **Clean API**: No function prefixes needed
- **Automatic Loading**: Handles library dependencies
- **Error Handling**: Clear messages and proper exit codes
- **Public/Private**: Access to both public and private functions

## COMMAND FILES: USE API.SH OR HELPER.SH

**CRITICAL RULE**: Command markdown files should use `api.sh` or `helper.sh` instead of directly sourcing libraries.

### ❌ DON'T DO THIS in Command Files:

```bash
# DON'T: Direct library sourcing in .claude/commands/doh/*.md
source ".claude/scripts/doh/lib/workspace.sh"
source ".claude/scripts/doh/lib/numbering.sh"
next_epic="$(numbering_get_next "epic")"
```

### ✅ USE THESE PATTERNS INSTEAD:

**For command files - use API helper:**
```bash
# ✅ In .claude/commands/doh/some-command.md implementation
next_epic="$(./.claude/scripts/doh/api.sh numbering get_next "epic")"
task_status="$(./.claude/scripts/doh/api.sh task get_status "task.md")"
```

**For CLI operations - use helper bootstrap:**
```bash
# ✅ In .claude/commands/doh/some-command.md implementation
source ".claude/scripts/doh/helper.sh"
helper_epic_create "new-feature"
```

### ✅ THESE ARE ALLOWED:

**Libraries can source other libraries:**
```bash
# ✅ Inside .claude/scripts/doh/lib/some-library.sh
source ".claude/scripts/doh/lib/workspace.sh"
source ".claude/scripts/doh/lib/frontmatter.sh"
```

**Helpers can source libraries:**
```bash
# ✅ Inside .claude/scripts/doh/helper/epic.sh
source ".claude/scripts/doh/lib/numbering.sh"
source ".claude/scripts/doh/lib/frontmatter.sh"
```

## Function Documentation

Use **shdoc** format for documenting functions. This provides comprehensive API documentation that can be automatically generated.

### Basic Function Documentation

```bash
# @description Gets the next available number for tasks or epics
# @arg $1 string The type of number to generate ("epic" or "task")
# @stdout Zero-padded 3-digit number (e.g., "001")
# @exitcode 0 If successful
# @exitcode 1 If invalid type provided
numbering_get_next() {
    local type="$1"
    
    if [[ "$type" != "epic" && "$type" != "task" ]]; then
        echo "Error: Invalid type '$type'. Must be 'epic' or 'task'" >&2
        return 1
    fi
    
    # Implementation...
}
```

### Complex Function Documentation

```bash
# @description Registers a new task in the central registry
# @arg $1 string The task number (3-digit format)
# @arg $2 string Parent epic or task number
# @arg $3 string Relative path to task file
# @arg $4 string Human-readable task name
# @arg $5 string Optional epic name for grouping
# @arg $6 string Optional JSON metadata object
# @stdout Task registration confirmation message
# @exitcode 0 If registration successful
# @exitcode 1 If invalid parameters provided
# @exitcode 2 If task number already exists
numbering_register_task() {
    local number="$1"
    local parent_number="$2"
    local path="$3"
    local name="$4"
    local epic_name="${5:-}"
    local metadata="${6:-}"
    
    # Implementation...
}
```

### shdoc Documentation Tags Reference

| Tag | Description | Usage | Example |
|-----|-------------|-------|---------|
| `@description` | Function description | Main function purpose | `@description Processes user input` |
| `@arg $N type` | Function argument | Document parameters | `@arg $1 string Username to process` |
| `@option` | Command-line option | Document CLI options | `@option -v\|--verbose Enable verbose output` |
| `@stdout` | Standard output | What function outputs | `@stdout Formatted user data` |
| `@stderr` | Standard error | Error output description | `@stderr Error messages for invalid input` |
| `@stdin` | Standard input | Expected input | `@stdin User credentials from terminal` |
| `@exitcode` | Return/exit codes | Function return codes | `@exitcode 0 If successful` |
| `@see` | Cross-reference | Link to related functions | `@see process_input()` |
| `@internal` | Internal function | Mark private functions | `@internal` |

### Advanced Documentation Features

#### With Options and Examples
```bash
# @description Processes files with various options
# @arg $1 string Input file path
# @option -v|--verbose Enable verbose processing
# @option -o|--output=<file> Specify output file
# @stdin File content to process
# @stdout Processed file content
# @stderr Processing errors and warnings
# @exitcode 0 If processing successful
# @exitcode 1 If file not found
# @exitcode 2 If processing fails
# @see validate_file()
process_file() {
    local file="$1"
    # Implementation...
}
```

#### Internal/Private Functions
```bash
# @description Internal helper for number validation
# @internal
# @arg $1 string Number to validate
# @exitcode 0 If valid number
# @exitcode 1 If invalid number
_validate_number_format() {
    local number="$1"
    # Implementation...
}
```

## Error Handling

### Input Validation

Always validate input parameters:

```bash
validate_inputs() {
    local number="$1"
    local type="$2"
    
    if [[ -z "$number" || -z "$type" ]]; then
        echo "Error: Missing required parameters" >&2
        return 1
    fi
    
    if [[ ! "$number" =~ ^[0-9]{3}$ ]]; then
        echo "Error: Invalid number format: $number" >&2
        return 1
    fi
}
```

### Error Messages

- Always send errors to stderr using `>&2`
- Include context in error messages
- Use consistent error format: `"Error: descriptive message"`

```bash
if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file not found: $config_file" >&2
    return 1
fi
```

### Return Codes

**General Pattern:**
- `0` - Success (OK)
- `1+` - Various error conditions (KO)

**Standard Return Code Guidelines:**
- `0` - Success
- `1` - General error or invalid input
- `2` - File/resource not found
- `3` - Permission denied
- `4` - Network/external service error

**Important:** Each library, helper, and script should document its specific return code mappings in its header comments or README. The above codes are suggested defaults, but domain-specific mappings should be clearly documented.

**Example Library Header:**
```bash
#!/bin/bash
# Script Description: Message queue operations
# Return Codes:
#   0 - Success
#   1 - Invalid parameters
#   2 - Queue directory not found
#   3 - Message validation failed
#   4 - File system error
```

## DOH Architecture: Libraries, Helpers, and API

The DOH project follows a modern three-tier architecture:

### Directory Layout

```
doh/
├── .claude/scripts/doh/
│   ├── lib/                      # TIER 1: Core Libraries
│   │   ├── workspace.sh          # Project structure and paths
│   │   ├── numbering.sh          # Number generation and registry
│   │   ├── file-cache.sh         # File metadata caching
│   │   ├── graph-cache.sh        # Relationship caching
│   │   ├── frontmatter.sh        # YAML frontmatter parsing
│   │   ├── version.sh            # Version management
│   │   └── dohenv.sh             # Environment initialization
│   ├── helper/                   # TIER 2: Helper Bootstrap System
│   │   ├── core.sh               # System operations (init, help, validate)
│   │   ├── epic.sh               # Epic management operations
│   │   ├── prd.sh                # PRD management operations
│   │   ├── workflow.sh           # Workflow operations (standup, next)
│   │   └── queue.sh              # Queue management operations
│   ├── helper.sh                 # Helper bootstrap script
│   ├── api.sh                    # TIER 3: Clean API Interface
│   └── *.sh                      # Legacy command scripts
├── migration/                    # Specialized scripts
└── tests/                        # Test framework
```

### Architecture Tiers

**TIER 1: Libraries** - Pure business logic functions
- Function naming: `library_function_name()` (e.g., `numbering_get_next()`)
- Private functions: `_library_function_name()` (e.g., `_numbering_ensure_registry()`)
- No user interaction, pure input/output
- Testable and reusable

**TIER 2: Helpers** - CLI interface consolidation
- Function naming: `helper_domain_action()` (e.g., `helper_epic_list()`)
- Bootstrap discovery via `helper.sh`
- Consolidate related CLI operations
- Handle argument parsing and formatting

**TIER 3: API** - Clean external interface
- No prefixes needed: `./.claude/scripts/doh/api.sh version get_current`
- Automatic library loading and dependency resolution
- Recommended for external usage and scripts

### Purpose of Each Directory

#### **TIER 1: Libraries** (`lib/`) - Core Business Logic
- **Naming**: `library_function()` public, `_library_function()` private
- **Usage**: Direct sourcing for internal scripts
- **Examples**: `numbering_get_next()`, `version_compare()`, `frontmatter_get_field()`
- **Characteristics**:
  - Pure functions with clear inputs/outputs
  - No user interaction or output formatting
  - Well-documented with shdoc format
  - Testable and mockable
  - Dependency management through explicit sourcing

#### **TIER 2: Helpers** (`helper/`) - CLI Consolidation
- **Naming**: `helper_domain_action()` (e.g., `helper_epic_list()`)
- **Usage**: Via helper bootstrap system (`source helper.sh`)
- **Discovery**: Dynamic discovery from helper directory
- **Characteristics**:
  - Consolidate related CLI operations
  - Handle argument parsing and user interaction
  - Format output for human consumption
  - Cannot be called directly - must use bootstrap
  - Example: `helper_prd_status()`, `helper_workflow_standup()`

#### **TIER 3: API** (`api.sh`) - Clean External Interface
- **Usage**: `./.claude/scripts/doh/api.sh library function [args]`
- **Examples**: 
  - `api.sh version get_current`
  - `api.sh task is_completed "task.md"`
  - `api.sh --private version to_number "1.0.0"`
- **Characteristics**:
  - No function prefixes needed
  - Automatic library loading and dependency resolution
  - Clean API for external usage
  - Supports both public and private function calls
  - Recommended approach for external scripts

#### **Legacy Commands** (`.claude/scripts/doh/*.sh`)
- **Status**: Being migrated to helper system
- **Usage**: Direct execution through DOH system (`/doh:command`)
- **Future**: Will be replaced by helper bootstrap calls

#### **Migration Scripts** (`migration/`)
- **Purpose**: Specialized, one-time, or unusual operations
- **Usage**: Manual execution for specific scenarios
- **Characteristics**: Not part of regular DOH workflow

## Usage Patterns by Tier

### TIER 1: Direct Library Usage (Internal Scripts)

```bash
# Source dependencies explicitly
source ".claude/scripts/doh/lib/dohenv.sh"
source ".claude/scripts/doh/lib/workspace.sh"
source ".claude/scripts/doh/lib/numbering.sh"

# Use prefixed library functions
local project_root
project_root="$(doh_find_root)" || {
    echo "Error: Not in DOH project" >&2
    return 1
}

local next_epic
next_epic="$(numbering_get_next "epic")" || {
    echo "Error: Could not generate epic number" >&2
    return 1
}
```

### TIER 2: Helper Bootstrap Usage (CLI Scripts)

```bash
# Source helper bootstrap
source ".claude/scripts/doh/helper.sh"

# Use helper functions with automatic discovery
helper_epic_list "active"                    # Lists active epics
helper_prd_status "003"                      # Shows PRD status
helper_workflow_next                         # Shows next tasks
```

### RECOMMENDED: API Helper (External Scripts)

```bash
# Use API helper - the primary external entry point
current_version="$(./.claude/scripts/doh/api.sh version get_current)"
task_status="$(./.claude/scripts/doh/api.sh task get_status "task.md")"

# Private function access
version_number="$(./.claude/scripts/doh/api.sh --private version to_number "1.0.0")"
```

### Architecture Principles

1. **Primary Entry Points**: Use `helper.sh` for CLI, `api.sh` for external scripts
2. **Avoid Direct Sourcing**: Never source libraries directly - use entry points
3. **Helper Bootstrap**: Consolidates and discovers CLI operations automatically  
4. **API Simplicity**: Clean interface without function prefixes
5. **Tier Separation**: Libraries → Helpers → API (no reverse dependencies)

## Variable Management

### Naming Conventions

**Functions:**
- Libraries: `library_function()` (public), `_library_function()` (private)
- Helpers: `helper_domain_action()`
- Examples: `numbering_get_next()`, `helper_epic_list()`, `_version_to_number()`

**Variables:**
- `UPPERCASE` - Global constants and environment variables
- `lowercase` - Local variables and function parameters

**Files:**
- Libraries: `library-name.sh` (e.g., `frontmatter.sh`)
- Helpers: `domain.sh` (e.g., `epic.sh`, `workflow.sh`)

### Local Variables

Always declare variables as local within functions:

```bash
process_file() {
    local file_path="$1"
    local temp_file
    local result
    
    temp_file=$(mktemp)
    result=$(process_content < "$file_path")
    
    echo "$result" > "$temp_file"
    mv "$temp_file" "$file_path"
}
```

### Environment Variables

Use prefixes to avoid conflicts:

```bash
# DOH-specific variables
export DOH_PROJECT_ROOT="/path/to/project"
export DOH_DEBUG="false"

# Test-specific variables  
export TEST_PROJECT_NAME="test_project"
export DOH_TEST_MODE="true"
```

## File Operations

### Atomic Operations

Use TMPDIR-aware temporary files for atomic updates:

```bash
update_config() {
    local config_file="$1"
    local temp_file
    
    # mktemp automatically respects TMPDIR
    temp_file=$(mktemp) || {
        echo "Error: Could not create temporary file" >&2
        return 1
    }
    
    # Process and write to temp file
    process_config > "$temp_file" || {
        rm -f "$temp_file"
        return 1
    }
    
    # Atomic move
    mv "$temp_file" "$config_file"
}
```

**Note**: Always use `mktemp` which respects the `TMPDIR` environment variable. Never hard-code `/tmp/` paths.

### File Locks

Use file locks for concurrent access:

```bash
acquire_lock() {
    local lock_file="$1"
    local timeout="${2:-10}"
    
    exec 200>"$lock_file.lock"
    flock -x -w "$timeout" 200 || {
        echo "Error: Could not acquire lock within ${timeout}s" >&2
        return 1
    }
}

release_lock() {
    exec 200>&-
}
```

## Testing Integration

### Test-Friendly Functions

Write functions that are easy to test:

```bash
# Good: Pure function with clear inputs/outputs
format_number() {
    local number="$1"
    printf "%03d" "$number"
}

# Good: Testable with dependency injection
get_config_value() {
    local key="$1"
    local config_file="${2:-$DEFAULT_CONFIG}"
    
    grep "^$key=" "$config_file" | cut -d'=' -f2
}
```

### Mock-Friendly Design

Allow function mocking in tests:

```bash
# In production code
get_current_user() {
    whoami
}

# In test code
_tf_setup() {
    # Override function for testing
    get_current_user() {
        echo "test_user"
    }
}
```

## Performance Considerations

### Minimize Subprocess Calls

```bash
# Bad: Multiple subprocess calls
count=$(echo "$data" | wc -l)
first_line=$(echo "$data" | head -1)

# Good: Single call with process substitution
{
    IFS= read -r first_line
    count=1
    while IFS= read -r line; do
        ((count++))
    done
} <<< "$data"
```

### Efficient String Operations

```bash
# Bad: External command
if echo "$string" | grep -q "pattern"; then

# Good: Built-in pattern matching  
if [[ "$string" == *pattern* ]]; then
```

## Security Best Practices

### Input Sanitization

```bash
sanitize_filename() {
    local filename="$1"
    
    # Remove dangerous characters
    filename="${filename//[^a-zA-Z0-9._-]/}"
    
    # Prevent directory traversal
    filename="${filename//\.\./}"
    
    echo "$filename"
}
```

### Temporary File Security

**CRITICAL**: Always be TMPDIR aware when creating temporary files or directories.

```bash
# ✅ GOOD: TMPDIR-aware temporary file creation
create_secure_temp() {
    local temp_file
    
    # mktemp respects TMPDIR environment variable
    temp_file=$(mktemp) || return 1
    chmod 600 "$temp_file"
    
    echo "$temp_file"
}

# ✅ GOOD: TMPDIR-aware temporary directory
create_temp_dir() {
    local temp_dir
    
    # mktemp -d respects TMPDIR environment variable
    temp_dir=$(mktemp -d) || return 1
    chmod 700 "$temp_dir"
    
    echo "$temp_dir"
}

# ✅ GOOD: Explicit TMPDIR with fallback
create_temp_in_location() {
    local temp_file
    local tmpdir="${TMPDIR:-/tmp}"
    
    temp_file=$(mktemp -p "$tmpdir") || return 1
    chmod 600 "$temp_file"
    
    echo "$temp_file"
}
```

**❌ DON'T DO THIS:**
```bash
# DON'T: Hard-coded /tmp paths (ignores TMPDIR)
temp_file="/tmp/myapp-$$-$(date +%s)"
touch "$temp_file"

# DON'T: Hard-coded temporary locations
temp_dir="/tmp/myapp-work"
mkdir -p "$temp_dir"
```

**TMPDIR Best Practices:**
- Use `mktemp` and `mktemp -d` which automatically respect `TMPDIR`
- Always set restrictive permissions: `600` for files, `700` for directories
- Clean up temporary files/directories on script exit
- Use `${TMPDIR:-/tmp}` pattern when you need explicit TMPDIR access

## Documentation

### README Requirements

Every library should have:
- Purpose and scope
- Function API documentation
- Usage examples
- Dependencies
- Version compatibility

### Inline Comments

Use comments for complex logic:

```bash
# Calculate next sequence number with gap detection
local current_seq next_seq
current_seq=$(get_current_sequence)

# Skip reserved numbers (000-099 reserved for system)
while [[ $next_seq -lt 100 ]] || is_number_reserved "$next_seq"; do
    ((next_seq++))
done
```

This document serves as the foundation for writing maintainable, testable, and robust shell scripts in the DOH project.