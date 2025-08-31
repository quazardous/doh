# DOH Data Manipulation API Guide for Command Authors

> **Central Reference**: This is the authoritative guide for DOH internal data manipulation. All commands must use these patterns and functions.

## Quick Lookup: "I need to..."

| **I need to...** | **Use this function** | **Library** | **Example** |
|------------------|----------------------|-------------|-------------|
| Find a task by number | `find_file_by_number("006")` | file-cache.sh | `task_file=$(find_file_by_number "006")` |
| Update task status | `update_frontmatter_field()` | frontmatter.sh | `update_frontmatter_field "$file" "status" "closed"` |
| Get next task number | `get_next_number()` | numbering.sh | `number=$(get_next_number "task" "$project_id")` |
| Calculate epic progress | `calculate_epic_progress()` | task.sh | `progress=$(calculate_epic_progress "epic-name")` |
| Create new task | `create_numbered_task()` | doh-numbering.sh | `create_numbered_task "$epic" "$title" "$description"` |
| Read frontmatter field | `get_frontmatter_field()` | frontmatter.sh | `status=$(get_frontmatter_field "$file" "status")` |
| List epic tasks | `list_epic_tasks()` | task.sh | `tasks=$(list_epic_tasks "epic-name")` |
| Get task status | `get_task_status()` | task.sh | `status=$(get_task_status "$task_file")` |

## Standard Command Patterns

### ✅ Pattern: Close a Task (CORRECT)
```bash
#!/bin/bash
source .claude/scripts/doh/lib/file-cache.sh
source .claude/scripts/doh/lib/frontmatter.sh
source .claude/scripts/doh/lib/task.sh

# Find task file
task_file=$(find_file_by_number "$ARGUMENTS")
if [[ -z "$task_file" ]]; then
    echo "❌ Task $ARGUMENTS not found"
    exit 1
fi

# Update status and timestamp
update_frontmatter_field "$task_file" "status" "closed"
update_frontmatter_field "$task_file" "updated" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Recalculate epic progress
epic_name=$(dirname "$task_file" | xargs basename)
epic_progress=$(calculate_epic_progress "$epic_name")

echo "✅ Closed task $ARGUMENTS (Epic: $epic_progress% complete)"
```

### ❌ Pattern: Close a Task (WRONG - Don't Do This)
```bash
#!/bin/bash
# DON'T DO ANY OF THIS:

# Manual file search - WRONG
find .doh/epics -name "$ARGUMENTS.md" -o -name "*$ARGUMENTS*.md"

# Manual frontmatter editing - WRONG  
sed -i "s/status: open/status: closed/" "$task_file"
sed -i "s/updated: .*/updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")/" "$task_file"

# Manual progress calculation - WRONG
total=$(find .doh/epics/epic-name -name "*.md" | wc -l)
closed=$(grep -l "status: closed" .doh/epics/epic-name/*.md | wc -l)
progress=$((closed * 100 / total))
```

## Library Function Reference

### 📁 File Discovery (file-cache.sh)
```bash
source .claude/scripts/doh/lib/file-cache.sh

# Find task/epic by number
find_file_by_number("006")         # Returns: /path/to/006.md or empty

# List all files in epic  
list_epic_files("epic-name")       # Returns: newline-separated paths

# Get cache statistics
get_file_cache_stats()             # Returns: JSON with cache info

# Rebuild cache (if needed)
rebuild_file_cache()               # Rebuilds entire file cache
```

### 📄 Frontmatter Operations (frontmatter.sh)
```bash
source .claude/scripts/doh/lib/frontmatter.sh

# Read frontmatter field
get_frontmatter_field("file.md", "status")    # Returns: field value

# Update frontmatter field  
update_frontmatter_field("file.md", "status", "closed")

# Extract all frontmatter
extract_frontmatter("file.md")     # Returns: YAML frontmatter block

# Validate frontmatter structure
validate_frontmatter("file.md")    # Returns: 0=valid, 1=invalid
```

### 🔢 Number Management (numbering.sh)
```bash
source .claude/scripts/doh/lib/numbering.sh

# Get next available number
get_next_number("task", "project-id")    # Returns: next task number

# Register new task/epic
register_task("006", "001", "/path/file.md", "metadata")
register_epic("001", "/path/epic.md", "metadata")  

# Find item by number
find_by_number("006")              # Returns: registry entry

# Validate number availability
validate_number("006", "task")     # Returns: 0=available, 1=taken
```

### 📊 Task & Epic Operations (task.sh)
```bash
source .claude/scripts/doh/lib/task.sh

# Get task status
get_task_status("task.md")         # Returns: open|closed|in-progress|blocked

# Check if completed
is_task_completed("task.md")       # Returns: 0=completed, 1=not completed

# Calculate epic progress
calculate_epic_progress("epic-name") # Returns: percentage (0-100)

# List all tasks in epic
list_epic_tasks("epic-name")       # Returns: array of task files

# Verify task completion
verify_task_completion("task.md")  # Returns: 0=verified, 1=incomplete
```

### 🏗️ High-Level Operations (doh-numbering.sh)
```bash
source .claude/scripts/doh/lib/doh-numbering.sh

# Create complete numbered task
create_numbered_task("epic-name", "Task Title", "Description")

# Create complete numbered epic  
create_numbered_epic("Epic Title", "Description", "prd-path")

# Batch create multiple tasks
batch_create_tasks("epic-name", "task-array")

# Update epic with task list
update_epic_with_tasks("epic-name", "task-numbers")
```

## Redundancy & Legacy Issues Found

### 🚨 DUPLICATE FUNCTIONS DETECTED

| **Function** | **Found In** | **Status** | **Action Required** |
|-------------|-------------|-----------|-------------------|
| `rebuild_file_cache()` | file-cache.sh + registers.sh | **DUPLICATE** | Use file-cache.sh version only |
| `rebuild_graph_cache()` | graph-cache.sh + registers.sh | **DUPLICATE** | Use graph-cache.sh version only |
| File discovery | 6+ commands do manual search | **REDUNDANT** | Replace with `find_file_by_number()` |
| Frontmatter search | 5+ commands search `github:.*issues` | **REDUNDANT** | Use file-cache.sh functions |
| Progress calculation | Manual counting in multiple commands | **REDUNDANT** | Use `calculate_epic_progress()` |

### 🏛️ LEGACY PATTERNS TO ELIMINATE

| **Legacy Pattern** | **Found In** | **Modern Replacement** |
|-------------------|-------------|----------------------|
| `sed` frontmatter editing | epic-sync, issue-* commands | `update_frontmatter_field()` |
| Manual file discovery | All issue-* commands | `find_file_by_number()` |
| `grep -l "status: closed"` | Multiple commands | `get_task_status()` |
| `find .doh -name "*.md"` | Multiple commands | `list_epic_files()` |
| Manual YAML construction | Various commands | `frontmatter.sh` functions |

## 🧹 CLEANUP RECOMMENDATIONS

### Immediate Actions Required:
1. **Remove duplicate cache functions** from registers.sh - use originals from file-cache.sh/graph-cache.sh
2. **Replace 15+ manual file search patterns** with `find_file_by_number()`
3. **Eliminate 8+ manual frontmatter manipulations** with `frontmatter.sh` functions
4. **Consolidate progress calculations** - remove 6+ duplicate implementations

### Files Requiring Updates:
- `.claude/commands/doh/issue-close.md` - Replace manual frontmatter editing
- `.claude/commands/doh/issue-reopen.md` - Replace manual frontmatter editing  
- `.claude/commands/doh/issue-start.md` - Replace manual file discovery
- `.claude/commands/doh/issue-edit.md` - Replace manual frontmatter search
- `.claude/commands/doh/issue-show.md` - Replace manual file discovery
- `.claude/commands/doh/epic-close.md` - Replace manual frontmatter editing
- `.claude/scripts/doh/lib/registers.sh` - Remove duplicate functions

## Command Template

### Standard Structure for All Commands:
```bash
#!/bin/bash
# Command: /doh:command-name

### 1. Load Required Libraries
source .claude/scripts/doh/lib/file-cache.sh
source .claude/scripts/doh/lib/frontmatter.sh  
source .claude/scripts/doh/lib/task.sh

### 2. Validate Input & Find Files
if [[ -z "$1" ]]; then
    echo "❌ Usage: /doh:command-name <task_number>"
    exit 1
fi

task_file=$(find_file_by_number "$1")
if [[ -z "$task_file" ]]; then
    echo "❌ Task $1 not found"
    exit 1
fi

### 3. Perform Operations Using Library Functions
current_status=$(get_frontmatter_field "$task_file" "status")
update_frontmatter_field "$task_file" "status" "new-status"
update_frontmatter_field "$task_file" "updated" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

### 4. Update Related Data
epic_name=$(dirname "$task_file" | xargs basename)
epic_progress=$(calculate_epic_progress "$epic_name")

### 5. Provide Clear Output
echo "✅ Task $1: $current_status → new-status"
echo "Epic progress: $epic_progress%"
```

## ⚠️ CRITICAL RULES

1. **NEVER manually edit frontmatter** with sed/awk
2. **NEVER manually search for files** with find/grep
3. **ALWAYS use library functions** for all data operations
4. **ALWAYS source required libraries** at the start of commands
5. **ALWAYS validate inputs** and check for file existence
6. **NEVER duplicate functionality** that exists in libraries

---

**Last Updated**: 2025-08-31T20:30:00Z  
**Violation Reports**: Submit to Task 010 for frontmatter violations  
**Function Requests**: Submit to Task 009 for missing helper commands