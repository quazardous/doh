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

## CRITICAL USAGE RULES

### RULE 1: HELPERS AND APIS - NEVER USE HELPER.SH OR API.SH

**CRITICAL RULE**: Helper scripts (`helper/*.sh`) and API scripts (`api.sh`) are **external interfaces** and should **NEVER** call each other internally.

#### ❌ FORBIDDEN in Helper Scripts (`.claude/scripts/doh/helper/*.sh`):
```bash
# ❌ DON'T: Using api.sh from inside helper scripts
epic_number="$(./.claude/scripts/doh/api.sh numbering get_next "epic")"
status="$(./.claude/scripts/doh/api.sh frontmatter get_field "$file" "status")"

# ❌ DON'T: Using helper.sh from inside API scripts
result="$(./.claude/scripts/doh/helper.sh epic list)"
```

#### ✅ USE THIS INSTEAD in Helper Scripts:
```bash
# ✅ CORRECT: Direct library sourcing and function calls
source "$(dirname "${BASH_SOURCE[0]}")/../lib/numbering.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/frontmatter.sh"

epic_number="$(numbering_get_next "epic")"
status="$(frontmatter_get_field "$file" "status")"
```

**Why this rule exists:**
- `helper.sh` and `api.sh` are **external interfaces** for user consumption
- Internal usage creates circular dependencies and performance overhead
- Helper scripts should source DOH libraries directly for optimal performance
- This maintains clean architecture separation between interface and implementation

### RULE 2: COMMAND FILES - USE API.SH OR HELPER.SH

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
- **Usage**: Via helper bootstrap system (`helper.sh domain action`)
- **Discovery**: Dynamic discovery from helper directory structure
- **Architecture**: Each `helper/domain.sh` file contains normalized helper functions
- **Characteristics**:
  - Consolidate related CLI operations
  - Handle argument parsing and user interaction
  - Format output for human consumption
  - Functions are called through bootstrap, not directly
  - Example: `helper_epic_list()`, `helper_prd_status()`

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
project_root="$(doh_project_dir)" || {
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
# Use helper bootstrap with domain/action pattern
./.claude/scripts/doh/helper.sh epic list "active"        # Lists active epics
./.claude/scripts/doh/helper.sh prd status "003"          # Shows PRD status  
./.claude/scripts/doh/helper.sh workflow next             # Shows next tasks
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

## Writing Helper Functions

### Helper Architecture Pattern

Le système de helpers DOH utilise un pattern de **classes de helpers** où chaque fichier `.claude/scripts/doh/helper/domain.sh` contient des fonctions normalisées pour un domaine spécifique.

#### Structure des Helpers

```
.claude/scripts/doh/helper/
├── epic.sh          # Classe de helpers pour les epics
├── prd.sh           # Classe de helpers pour les PRDs  
├── task.sh          # Classe de helpers pour les tasks
├── version.sh       # Classe de helpers pour les versions
└── frontmatter.sh   # Classe de helpers pour la logique métier frontmatter
```

### Convention de Nommage des Fonctions Helper

**Pattern**: `helper_{domain}_{action}()`

Exemples:
- `helper_epic_create()` - Créer un epic
- `helper_epic_list()` - Lister les epics
- `helper_prd_new()` - Créer un nouveau PRD
- `helper_task_decompose()` - Décomposer un epic en tasks
- `helper_frontmatter_create_epic()` - Créer le frontmatter d'un epic

### Exemple d'Implémentation: `.claude/scripts/doh/helper/epic.sh`

```bash
#!/bin/bash
# Epic Helper Functions
# Une "classe" de helpers pour la gestion des epics

set -euo pipefail

# Source des dépendances
source "$(dirname "${BASH_SOURCE[0]}")/../lib/dohenv.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/numbering.sh" 
source "$(dirname "${BASH_SOURCE[0]}")/../lib/frontmatter.sh"

# @description Créer un nouvel epic
# @arg $1 string Nom de l'epic
# @arg $2 string Description (optionnel)
# @stdout Chemin vers l'epic créé
# @exitcode 0 Si création réussie
# @exitcode 1 Si erreur de paramètres
helper_epic_create() {
    local epic_name="$1"
    local description="${2:-}"
    
    # Validation
    if [[ -z "$epic_name" ]]; then
        echo "Error: Epic name required" >&2
        return 1
    fi
    
    # Utiliser l'API numbering pour obtenir le prochain numéro
    local epic_number
    epic_number="$(./.claude/scripts/doh/api.sh numbering get_next "epic")" || {
        echo "Error: Could not generate epic number" >&2
        return 1
    }
    
    # Utiliser le helper frontmatter pour créer le fichier
    local epic_path
    epic_path="$(./.claude/scripts/doh/helper.sh frontmatter create-epic "$epic_name" "$epic_number" "$description")" || {
        echo "Error: Could not create epic file" >&2
        return 1
    }
    
    echo "Epic created: $epic_path"
    return 0
}

# @description Lister les epics selon un statut
# @arg $1 string Statut à filtrer (optional, default: all)
# @stdout Liste des epics
# @exitcode 0 Toujours
helper_epic_list() {
    local status_filter="${1:-all}"
    
    # Logique de listing des epics
    # Utilise les APIs DOH pour récupérer les données
    echo "Listing epics with status: $status_filter"
    # Implementation...
}

# @description Parser un PRD vers un epic
# @arg $1 string Nom du PRD source
# @stdout Chemin vers l'epic créé
# @exitcode 0 Si parsing réussi
# @exitcode 1 Si PRD non trouvé ou erreur
helper_epic_parse() {
    local prd_name="$1"
    
    if [[ -z "$prd_name" ]]; then
        echo "Error: PRD name required" >&2
        return 1
    fi
    
    # Vérifier que le PRD existe
    local prd_path=".doh/prds/${prd_name}.md"
    if [[ ! -f "$prd_path" ]]; then
        echo "Error: PRD not found: $prd_path" >&2
        return 1
    fi
    
    # Parser le PRD et créer l'epic
    # Implementation de la logique de parsing...
    echo "Epic created from PRD: $prd_name"
}
```

### Exemple d'Implémentation: `.claude/scripts/doh/helper/frontmatter.sh`

```bash
#!/bin/bash
# Frontmatter Business Logic Helpers
# Logique métier pour la création de frontmatter spécialisé

set -euo pipefail

# Source des dépendances
source "$(dirname "${BASH_SOURCE[0]}")/../lib/frontmatter.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/numbering.sh"

# @description Créer un fichier epic avec frontmatter complet
# @arg $1 string Nom de l'epic
# @arg $2 string Numéro de l'epic 
# @arg $3 string Description (optionnel)
# @stdout Chemin vers le fichier créé
# @exitcode 0 Si création réussie
helper_frontmatter_create_epic() {
    local epic_name="$1"
    local epic_number="$2" 
    local description="${3:-}"
    local created_date
    
    created_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    
    # Créer le répertoire si nécessaire
    local epic_dir=".doh/epics/${epic_name}"
    mkdir -p "$epic_dir"
    
    # Créer le frontmatter avec l'API
    local epic_path="${epic_dir}/epic.md"
    
    # Utiliser l'API frontmatter pour créer le fichier
    ./.claude/scripts/doh/api.sh frontmatter create_markdown "$epic_path" \
        "name" "$epic_name" \
        "number" "$epic_number" \
        "status" "backlog" \
        "created" "$created_date" \
        "progress" "0%" \
        "file_version" "0.1.0"
    
    # Ajouter le contenu de base de l'epic
    {
        echo ""
        echo "# Epic: $epic_name"
        echo ""
        if [[ -n "$description" ]]; then
            echo "## Description"
            echo "$description"
            echo ""
        fi
        echo "## Overview"
        echo "<!-- Epic overview goes here -->"
        echo ""
        echo "## Implementation Strategy"
        echo "<!-- Implementation details go here -->"
    } >> "$epic_path"
    
    # Registrer l'epic dans le système de numérotation
    ./.claude/scripts/doh/api.sh numbering register_epic "$epic_number" "$epic_path" "$epic_name"
    
    echo "$epic_path"
}

# @description Créer un fichier task avec frontmatter complet  
# @arg $1 string Nom de la task
# @arg $2 string Numéro de la task
# @arg $3 string Epic parent
# @stdout Chemin vers le fichier créé
helper_frontmatter_create_task() {
    local task_name="$1"
    local task_number="$2"
    local epic_name="$3"
    local created_date
    
    created_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    
    # Créer le fichier task avec frontmatter
    local task_path=".doh/epics/${epic_name}/${task_number}.md"
    
    ./.claude/scripts/doh/api.sh frontmatter create_markdown "$task_path" \
        "name" "$task_name" \
        "number" "$task_number" \
        "status" "open" \
        "created" "$created_date" \
        "updated" "$created_date" \
        "epic" "$epic_name" \
        "parallel" "true" \
        "file_version" "0.1.0"
    
    # Ajouter le contenu de base de la task
    {
        echo ""
        echo "# Task: $task_name"
        echo ""
        echo "## Description"
        echo "<!-- Task description goes here -->"
        echo ""
        echo "## Acceptance Criteria"
        echo "- [ ] Criterion 1"
        echo "- [ ] Criterion 2"
        echo ""
        echo "## Technical Details"
        echo "<!-- Implementation details go here -->"
    } >> "$task_path"
    
    echo "$task_path"
}
```

### Utilisation des Helpers

#### Via le Bootstrap Helper

```bash
# Créer un epic
./.claude/scripts/doh/helper.sh epic create "my-new-feature" "Epic description"

# Lister les epics actifs  
./.claude/scripts/doh/helper.sh epic list "active"

# Parser un PRD vers un epic
./.claude/scripts/doh/helper.sh epic parse "my-prd-name"

# Créer un frontmatter d'epic via helper frontmatter
./.claude/scripts/doh/helper.sh frontmatter create-epic "feature-name" "001" "Description"
```

#### Dans les Commands DOH

```bash
# Dans un fichier .claude/commands/doh/epic-new.md
./.claude/scripts/doh/helper.sh epic create "$ARGUMENTS" "Auto-created epic"
```

#### Depuis un Script Bash

```bash
#!/bin/bash
# Script exemple utilisant des helpers

# ✅ PERMIS: Sourcer directement dans un script bash
source ".claude/scripts/doh/helper/epic.sh"
epic_path="$(helper_epic_create "my-feature" "Description")"
status="$(helper_epic_list "active")"

# ✅ AUSSI PERMIS: Utiliser helper.sh (plus verbeux mais marche aussi)
epic_path="$(./.claude/scripts/doh/helper.sh epic create "my-feature" "Description")"
status="$(./.claude/scripts/doh/helper.sh epic list "active")"
```

### Règles d'Usage des Helpers

#### Commands Markdown (.claude/commands/doh/*.md)
- **OBLIGATOIRE**: Utiliser `helper.sh domain action`
- **INTERDIT**: Sourcer directement les fichiers helper
- **Raison**: Les commands sont exécutées dans un contexte spécial

```bash
# ✅ Dans .claude/commands/doh/epic-new.md
./.claude/scripts/doh/helper.sh epic create "$ARGUMENTS"

# ❌ INTERDIT dans commands
source ".claude/scripts/doh/helper/epic.sh"
```

#### Scripts Bash Normaux (*.sh)
- **PERMIS**: Sourcer directement `source "helper/domain.sh"`
- **PERMIS**: Utiliser `helper.sh domain action` (plus verbeux)
- **RECOMMANDÉ**: Sourcer directement pour de meilleures performances

```bash
# ✅ RECOMMANDÉ dans scripts bash
source ".claude/scripts/doh/helper/epic.sh"
result="$(helper_epic_create "name")"

# ✅ AUSSI PERMIS mais plus lent
result="$(./.claude/scripts/doh/helper.sh epic create "name")"
```

### Principes des Helpers

1. **Un Helper = Une Fonction**: Chaque helper est une fonction normalisée dans un fichier de classe
2. **Classe = Domaine**: Chaque fichier `helper/domain.sh` regroupe les fonctions d'un domaine
3. **Fonctions Normalisées**: Pattern `helper_domain_action()` strict
4. **Business Logic**: Les helpers encapsulent la logique métier complexe
5. **API Calls**: Les helpers utilisent l'API DOH pour les opérations de base
6. **Contexte d'Usage**: Commands MD → `helper.sh`, Scripts → sourcing direct OK

### Avantages du Pattern

- **Découvrabilité**: `helper.sh domain help` liste les actions disponibles
- **Testabilité**: Chaque fonction helper est testable individuellement  
- **Réutilisabilité**: Les helpers peuvent être utilisés par multiple commands
- **Séparation**: Logique métier séparée des APIs de base
- **Cohérence**: Interface uniforme pour toutes les opérations

This document serves as the foundation for writing maintainable, testable, and robust shell scripts in the DOH project.