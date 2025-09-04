# DOH Data API Reference

> **Comprehensive reference for DOH internal data manipulation functions**
> File version: 1.0.0 | Updated: 2025-09-03

## Quick Start

Use the DOH API helper script for all function calls:

```bash
# Public functions (call without library prefix)
./.claude/scripts/doh/api.sh version get_current
./.claude/scripts/doh/api.sh frontmatter get_field "file.md" "status"

# Private functions (use --private flag)
./.claude/scripts/doh/api.sh --private version to_number "1.0.0"
```

## Library Dependencies

The DOH libraries have complex interdependencies. Here's the actual dependency hierarchy:

### Core Foundation
```
doh.sh (foundation - zero dependencies)
├── dohenv.sh (sources doh.sh)
├── frontmatter.sh (zero dependencies)
└── version.sh (sources doh.sh, frontmatter.sh)
```

### Data Management Layer  
```
workspace.sh (sources doh.sh, dohenv.sh)
├── numbering.sh (sources doh.sh, workspace.sh)
├── file-cache.sh (sources doh.sh, workspace.sh)
├── graph-cache.sh (sources doh.sh, workspace.sh, numbering.sh, frontmatter.sh)
├── registers.sh (sources doh.sh, numbering.sh)
└── queue.sh (sources workspace.sh, numbering.sh)
```

### Application Layer
```
task.sh (sources doh.sh, frontmatter.sh)
├── validation.sh (sources doh.sh, frontmatter.sh)
├── project.sh (sources doh.sh, frontmatter.sh)
├── prd.sh (sources doh.sh, frontmatter.sh)
├── epic.sh (sources doh.sh, frontmatter.sh)
├── file-headers.sh (sources frontmatter.sh, version.sh)
├── reporting.sh (sources doh.sh, frontmatter.sh)
└── migration.sh (sources doh.sh, version.sh, frontmatter.sh)
```

### Safe Loading Order

```bash
# Minimal setup for basic operations
source .claude/scripts/doh/lib/doh.sh          # Always first!
source .claude/scripts/doh/lib/frontmatter.sh   # For file operations

# Full setup for all operations  
source .claude/scripts/doh/lib/doh.sh          # Foundation
source .claude/scripts/doh/lib/dohenv.sh       # Environment variables
source .claude/scripts/doh/lib/workspace.sh     # Workspace functions
source .claude/scripts/doh/lib/numbering.sh     # Numbering system
source .claude/scripts/doh/lib/frontmatter.sh   # Frontmatter operations
source .claude/scripts/doh/lib/version.sh       # Version management
# ... add other libraries as needed
```

## Core Libraries

### doh.sh - Foundation Functions
**Purpose**: Core DOH project detection and directory management

| Function | Description | Returns |
|----------|-------------|---------|
| `doh_global_dir` | Get DOH global directory with fallback | Path to global dir |
| `doh_project_dir` | Get DOH project .doh directory path | Path to .doh dir |
| `doh_project_root` | Get DOH project root directory | Path to project root |
| `doh_validate_project` | Check if in valid DOH project | 0=valid, 1=invalid |
| `doh_require_project` | Get DOH project root or exit | Path or exit |

**Usage Examples**:
```bash
# Get directories
project_root=$(doh_project_root)
doh_dir=$(doh_project_dir)
global_dir=$(doh_global_dir)

# Validate project
if doh_validate_project; then
    echo "Valid DOH project"
fi
```

### dohenv.sh - Environment Management
**Purpose**: DOH environment variable loading and management

| Function | Description | Returns |
|----------|-------------|---------|
| `dohenv_load` | Load environment variables from DOH project env file | 0=success, 1=error |
| `dohenv_is_loaded` | Check if DOH environment loaded | 0=loaded, 1=not loaded |
| `dohenv_get` | Get DOH environment variable with fallback | Variable value |

**Usage Examples**:
```bash
# Load environment
dohenv_load

# Check if loaded
if dohenv_is_loaded; then
    echo "Environment is loaded"
fi

# Get variable with fallback
api_key=$(dohenv_get "API_KEY" "default_value")
```

## Data Management Libraries

### frontmatter.sh - YAML Frontmatter Operations
**Purpose**: Extract, modify, and validate YAML frontmatter in markdown files

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `frontmatter_extract` | Extract frontmatter from file | `<file>` | YAML content |
| `frontmatter_get_field` | Get specific field value | `<file> <field>` | Field value |
| `frontmatter_update_field` | Update specific field | `<file> <field> <value>` | 0=success |
| `frontmatter_validate` | Validate frontmatter syntax | `<file>` | 0=valid, 1=invalid |
| `frontmatter_has` | Check if file has frontmatter | `<file>` | 0=has, 1=no |
| `frontmatter_add_field` | Add new field | `<file> <field> <value>` | 0=success |
| `frontmatter_remove_field` | Remove field | `<file> <field>` | 0=success |
| `frontmatter_get_fields` | Get all field names | `<file>` | Field list |
| `frontmatter_pretty_print` | Pretty print frontmatter | `<file>` | Formatted YAML |
| `frontmatter_merge` | Merge frontmatter between files | `<source> <target>` | 0=success |
| `frontmatter_create_markdown` | Create markdown with frontmatter | `<file> <content> <field:value>...` | 0=success |
| `frontmatter_query` | Query with yq expressions | `<file> <query>` | Query result |
| `frontmatter_bulk_update` | Update multiple fields | `<file> <field=value>...` | 0=success |

**Usage Examples**:
```bash
# Get field value
status=$(frontmatter_get_field ".doh/task.md" "status")

# Update field
frontmatter_update_field ".doh/task.md" "status" "completed"

# Check if file has frontmatter
if frontmatter_has ".doh/task.md"; then
    echo "File has frontmatter"
fi
```

### version.sh - Version Management
**Purpose**: Project and file version tracking and manipulation

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `version_get_current` | Get current project version | None | Version string |
| `version_get_file` | Get version from file frontmatter | `<file>` | Version string |
| `version_set_file` | Set version in file frontmatter | `<file> <version>` | 0=success |
| `version_increment` | Increment version string | `<version> <type>` | New version |
| `version_set_current` | Set current project version | `<version>` | 0=success |
| `version_bump_current` | Bump current project version by type | `<type>` | New version |
| `version_bump_file` | Bump file version by type | `<file> <type>` | New version |
| `version_compare` | Compare two version strings | `<v1> <v2>` | -1/0/1 |
| `version_validate` | Validate version format | `<version>` | 0=valid, 1=invalid |
| `version_find_files_without_file_version` | Find files without file_version | None | File list |
| `version_find_inconsistencies` | Find version inconsistencies | None | Issue list |
| `version_list` | List all versions in project | None | Version list |

**Usage Examples**:
```bash
# Get current project version
current=$(version_get_current)

# Increment version
new_version=$(version_increment "1.0.0" "patch")  # Returns "1.0.1"

# Compare versions
if version_compare "1.0.0" "2.0.0"; then
    echo "First version is newer"
fi
```

### numbering.sh - Sequential Number Management
**Purpose**: Manage sequential numbering for epics and tasks

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `numbering_get_current` | Get current sequence number | `<type>` | Current number |
| `numbering_get_next` | Get next available number | `<type>` | Next number |
| `numbering_register_epic` | Register epic in registry | `<number> <path> <name>` | 0=success |
| `numbering_register_task` | Register task in registry | `<number> <epic> <path> <name>` | 0=success |
| `numbering_validate` | Validate number availability | `<type> <number>` | 0=available |
| `numbering_find_by_number` | Find entry by number | `<number>` | Entry info |
| `numbering_get_stats` | Get registry statistics | None | Stats summary |

**Usage Examples**:
```bash
# Get next epic number
next_epic=$(numbering_get_next "epic")

# Register new epic
numbering_register_epic "005" ".doh/epics/auth" "Authentication System"
```

### workspace.sh - Workspace Management
**Purpose**: Project workspace identification and management

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `workspace_get_current_project_id` | Get current project ID | None | Project ID |

## Task and Epic Management

### task.sh - Task Status Management
**Purpose**: Task lifecycle and status transitions

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `task_transition_status` | Transition task to new status | `<file> <new_status>` | 0=success |

### epic.sh - Epic Management Operations
**Purpose**: Epic status tracking and task aggregation

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `epic_get_status` | Get epic status with progress | `<epic_path>` | Status report |
| `epic_list` | List all epics with status | None | Epic list |
| `epic_show` | Show detailed epic information | `<epic_path>` | Detailed info |
| `epic_get_tasks` | Get tasks in epic by status | `<epic_path> [status]` | Task list |

### prd.sh - PRD Management
**Purpose**: Product Requirements Document management

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `prd_get_count` | Get PRD count by status | `[status]` | Count |
| `prd_list_by_status` | List PRDs by status | `<status>` | PRD list |
| `prd_list` | List all PRDs with metadata | None | PRD list |

## File Management Libraries

### file-cache.sh - File Registry Cache
**Purpose**: Fast file lookup and duplicate detection

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `file_cache_find_file_by_number` | Find file by number | `<number>` | File path |
| `file_cache_add_file` | Add entry to cache | `<number> <path> <type>` | 0=success |
| `file_cache_remove_file` | Remove entry from cache | `<number>` | 0=success |
| `file_cache_rebuild` | Rebuild cache from filesystem | None | 0=success |
| `file_cache_detect_duplicates` | Detect and report duplicates | None | Duplicate list |
| `file_cache_get_stats` | Get cache statistics | None | Stats summary |
| `file_cache_list_epic_files` | List files for epic | `<epic_number>` | File list |

### graph-cache.sh - Relationship Cache
**Purpose**: Track relationships between epics, tasks, and versions

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `graph_cache_add_relationship` | Add relationship to cache | `<parent> <child> <type>` | 0=success |
| `graph_cache_remove_relationship` | Remove relationship | `<parent> <child>` | 0=success |
| `graph_cache_get_parent` | Get parent of number | `<number>` | Parent number |
| `graph_cache_get_epic` | Get epic of number | `<number>` | Epic number |
| `graph_cache_get_children` | Get children of number | `<number>` | Child list |
| `graph_cache_get_epic_items` | Get all items in epic | `<epic_number>` | Item list |
| `graph_cache_rebuild` | Rebuild cache | None | 0=success |
| `graph_cache_validate` | Validate cache consistency | None | 0=valid |
| `graph_cache_heal` | Self-healing cache | None | 0=success |
| `graph_cache_get_stats` | Get cache statistics | None | Stats summary |
| `graph_cache_print_tree` | Print relationship tree | `<root_number>` | Tree display |
| `graph_cache_update_version` | Update version data | `<number> <version>` | 0=success |
| `graph_cache_get_version` | Get version data | `<number>` | Version info |
| `graph_cache_get_version_blocking_tasks` | Get blocking tasks | `<version>` | Task list |
| `graph_cache_get_task_versions` | Get versions for task | `<task_number>` | Version list |
| `graph_cache_sync_version_cache` | Sync version data | None | 0=success |
| `graph_cache_check_version_readiness` | Check version readiness | `<version>` | 0=ready |

## Queue System

### queue.sh - Message Queue System
**Purpose**: Asynchronous task processing and workflow management

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `queue_generate_message_id` | Generate unique message ID | None | Message ID |
| `queue_get_dir` | Get queue directory path | None | Directory path |
| `queue_ensure_dir` | Ensure queue directory exists | None | 0=success |
| `queue_create_renumber_message` | Create renumber message | `<type> <reason>` | Message ID |
| `queue_add_message` | Queue a message | `<type> <data>` | Message ID |
| `queue_set_message_status` | Change message status | `<id> <status>` | 0=success |
| `queue_get_message` | Get message content | `<id>` | Message data |
| `queue_list_messages` | List messages by status | `[status]` | Message list |
| `queue_count_messages` | Count messages by status | `[status]` | Count |
| `queue_purge_processed` | Purge processed messages | None | Count purged |
| `queue_get_stats` | Get queue statistics | None | Stats summary |
| `queue_process_message` | Process pending message | `<id>` | 0=success |
| `queue_validate_message` | Validate message format | `<id>` | 0=valid |

## System Management

### validation.sh - System Validation
**Purpose**: Comprehensive DOH project validation

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `validation_validate_system` | Comprehensive system validation | None | 0=valid |
| `validation_check_directories` | Directory structure validation | None | 0=valid |
| `validation_check_frontmatter` | Frontmatter validation | None | Issue list |
| `validation_check_references` | Reference validation | None | Issue list |

### project.sh - Project-wide Operations
**Purpose**: High-level project status and metrics

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `project_get_summary` | Get project summary with metrics | None | Summary report |
| `project_get_recent_activity` | Get recent activity | `[days]` | Activity list |
| `project_get_health` | Get project health metrics | None | Health report |

## Utility Libraries

### file-headers.sh - Version Header Management
**Purpose**: Manage version headers in files

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `file_headers_add_version` | Add version header to file | `<file> <version>` | 0=success |
| `file_headers_file_has_version` | Check if file has version header | `<file>` | 0=has |
| `file_headers_batch_add` | Process multiple files | `<pattern> <version>` | 0=success |
| `file_headers_find_missing_files` | Find files missing headers | None | File list |

### reporting.sh - Report Generation
**Purpose**: Generate various project reports

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `reporting_generate_standup` | Generate daily standup report | None | Report text |
| `reporting_generate_epic_summary` | Generate epic summary | `<epic_path>` | Summary text |
| `reporting_format_progress` | Format progress bar | `<current> <total>` | Progress bar |
| `reporting_get_recent_activity` | Get recent activity | `[days]` | Activity text |

### migration.sh - DOH Migration
**Purpose**: DOH version migration operations

| Function | Description | Arguments | Returns |
|----------|-------------|-----------|---------|
| `migration_migrate_version` | Perform DOH version migration | `<from_version> <to_version>` | 0=success |

## Usage Patterns

### Using the DOH API Helper

**Recommended approach** - Use the API helper script:

```bash
# Version operations
current_version=$(./.claude/scripts/doh/api.sh version get_current)
new_version=$(./.claude/scripts/doh/api.sh version increment "$current_version" "patch")

# Frontmatter operations
status=$(./.claude/scripts/doh/api.sh frontmatter get_field ".doh/task.md" "status")
./.claude/scripts/doh/api.sh frontmatter update_field ".doh/task.md" "status" "completed"

# Private function access
numeric_version=$(./.claude/scripts/doh/api.sh --private version to_number "1.0.0")
```

### Direct Library Loading

**For performance-critical scripts** - Load libraries directly:

```bash
# Load required libraries
source .claude/scripts/doh/lib/doh.sh
source .claude/scripts/doh/lib/frontmatter.sh
source .claude/scripts/doh/lib/version.sh

# Use functions directly
current_version=$(version_get_current)
status=$(frontmatter_get_field ".doh/task.md" "status")
```

### Error Handling

All DOH functions follow consistent error handling patterns:

```bash
# Check return codes
if version_validate "$user_version"; then
    echo "Valid version: $user_version"
else
    echo "Invalid version format" >&2
    exit 1
fi

# Capture both output and return code
if output=$(frontmatter_get_field "$file" "$field" 2>/dev/null); then
    echo "Field value: $output"
else
    echo "Field not found or file error" >&2
fi
```

## Function Categories Summary

| Category | Libraries | Functions | Purpose |
|----------|-----------|-----------|---------|
| **Core** | doh, dohenv | 8 | Foundation, environment |
| **Data Management** | frontmatter, version, numbering, workspace | 37 | File and version operations |
| **Task/Epic** | task, epic, prd | 9 | Project management |
| **File Management** | file-cache, graph-cache | 25 | Caching and relationships |
| **System** | validation, project, queue | 21 | System operations |
| **Utilities** | file-headers, reporting, migration | 9 | Helper operations |
| **Total** | 18 libraries | **109 functions** | Complete DOH ecosystem |

## Best Practices

Use the DOH API helper script for all function calls to ensure consistency and forward compatibility:

```bash
# Recommended approach
current_version=$(./.claude/scripts/doh/api.sh version get_current)
./.claude/scripts/doh/api.sh frontmatter update_field ".doh/task.md" "status" "completed"

# For performance-critical code, direct library loading is acceptable
source .claude/scripts/doh/lib/version.sh
current_version=$(version_get_current)
```