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

### Source Dependencies

Always source required libraries at the top after the header:

```bash
# Source required dependencies
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../lib"
source "$LIB_DIR/workspace.sh"
source "$LIB_DIR/numbering.sh"
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
get_next_number() {
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
register_task() {
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

## Project Structure

The DOH project follows a clear organizational pattern that separates different types of scripts and libraries:

### Directory Layout

```
doh/
├── .claude/scripts/doh/          # DOH system scripts
│   ├── lib/                      # Core reusable libraries  
│   │   ├── workspace.sh          # Project structure and paths
│   │   ├── numbering.sh          # Number generation and registry
│   │   ├── file-cache.sh         # File metadata caching
│   │   ├── graph-cache.sh        # Relationship caching
│   │   ├── frontmatter.sh        # YAML frontmatter parsing
│   │   ├── message-queue.sh      # Message queue operations
│   │   └── version.sh            # Version management
│   ├── helper/                   # CLI wrapper scripts
│   │   ├── queue-commands.sh     # CLI for queue operations
│   │   └── doh-numbering.sh      # CLI for numbering (deprecated)
│   ├── init.sh                   # Regular DOH commands
│   ├── status.sh                 # (available via /doh:command)
│   ├── epic-list.sh             
│   └── ...
├── migration/                    # Specialized/unusual scripts
│   ├── migrate.sh               # Database migration tools
│   ├── deduplicate.sh           # Data cleanup utilities
│   ├── detect_duplicates.sh     # Analysis scripts
│   └── rollback.sh              # Recovery operations
└── tests/                       # Test framework
    ├── unit/                    # Unit tests
    ├── integration/             # Integration tests
    └── helpers/                 # Test framework
```

### Purpose of Each Directory

#### **`.claude/scripts/doh/lib/`** - Core Libraries
- **Purpose**: Reusable business logic functions
- **Usage**: Sourced by other scripts and libraries
- **Characteristics**:
  - Pure functions with clear inputs/outputs
  - No direct user interaction
  - Well-documented with @param/@return
  - Testable and mockable
  - Example: `get_next_number()`, `queue_message()`

#### **`.claude/scripts/doh/helper/`** - CLI Helpers/Wrappers  
- **Purpose**: Command-line interface wrappers around core libraries
- **Usage**: Called from DOH command system
- **Characteristics**:
  - Functions prefixed with `cmd_`
  - Handle argument parsing and user interaction
  - Format output for human consumption
  - Example: `cmd_queue_status()`, `cmd_queue_list()`

#### **`.claude/scripts/doh/`** - Regular DOH Commands
- **Purpose**: Standard DOH functionality available via `/doh:command`
- **Usage**: Direct execution through DOH system
- **Characteristics**:
  - Executable scripts
  - User-facing functionality
  - Integration with DOH workflow
  - Example: `init.sh`, `status.sh`, `epic-list.sh`

#### **`./migration/`** - Specialized Scripts
- **Purpose**: Unusual, specialized, or one-time operations
- **Usage**: Manual execution for specific scenarios
- **Characteristics**:
  - Not part of regular DOH workflow
  - Complex operations (migrations, analysis, cleanup)
  - May require special permissions or setup
  - Example: `migrate.sh`, `deduplicate.sh`

## Library Usage

### Factorization Principles

1. **Single Responsibility**: Each library handles one domain
2. **No Duplication**: Common functionality lives in shared libraries
3. **Clear Dependencies**: Explicit library sourcing and dependency chains
4. **Proper Separation**: Core logic separate from CLI interfaces

### Using Libraries

```bash
# Source dependencies in order
source "$LIB_DIR/workspace.sh"
source "$LIB_DIR/numbering.sh"  # Depends on workspace.sh

# Use library functions
local project_root
project_root="$(_find_doh_root)" || {
    echo "Error: Not in DOH project" >&2
    return 1
}

local next_epic
next_epic="$(get_next_number "epic")" || {
    echo "Error: Could not generate epic number" >&2
    return 1
}
```

## Variable Management

### Naming Conventions

- `UPPERCASE` - Global constants and environment variables
- `lowercase` - Local variables and function parameters
- `_private` - Internal/private functions (prefix with underscore)

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

Use temporary files for atomic updates:

```bash
update_config() {
    local config_file="$1"
    local temp_file
    
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

```bash
create_secure_temp() {
    local temp_file
    
    # Create with restrictive permissions
    temp_file=$(mktemp) || return 1
    chmod 600 "$temp_file"
    
    echo "$temp_file"
}
```

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