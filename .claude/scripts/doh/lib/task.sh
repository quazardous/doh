#!/bin/bash

# DOH Task Library
# Pure library for task operations (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_TASK_LOADED:-}" ]] && return 0
DOH_LIB_TASK_LOADED=1

# Constants
readonly TASK_LIB_VERSION="1.0.0"


# @description Transition a task to a new status
# @arg $1 string Task number or file path
# @arg $2 string New status (pending|in_progress|completed|blocked)
# @stdout Success message
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If task not found or status invalid
task_transition_status() {
    local task_identifier="$1"
    local new_status="$2"
    
    if [ -z "$task_identifier" ] || [ -z "$new_status" ]; then
        echo "Usage: task_transition_status <task_number|task_file> <new_status>" >&2
        echo "Valid statuses: pending, in_progress, completed, blocked" >&2
        return 1
    fi
    
    # Validate status
    case "$new_status" in
        pending|in_progress|completed|blocked) ;;
        *)
            echo "Error: Invalid status '$new_status'" >&2
            echo "Valid statuses: pending, in_progress, completed, blocked" >&2
            return 1
            ;;
    esac
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    # Find task file
    local task_file=""
    if [ -f "$task_identifier" ]; then
        task_file="$task_identifier"
    else
        # Search by task number
        task_file=$(find "$doh_dir/epics" -name "${task_identifier}.md" -type f 2>/dev/null | head -1)
        if [ -z "$task_file" ]; then
            # Try with leading zeros
            task_file=$(find "$doh_dir/epics" -name "0${task_identifier}.md" -o -name "00${task_identifier}.md" -type f 2>/dev/null | head -1)
        fi
    fi
    
    if [ -z "$task_file" ] || [ ! -f "$task_file" ]; then
        echo "Error: Task not found: $task_identifier" >&2
        return 1
    fi
    
    # Update status using frontmatter library (if available)
    if command -v frontmatter_update_field >/dev/null 2>&1; then
        if frontmatter_update_field "$task_file" "status" "$new_status"; then
            echo "✅ Updated task $(basename "$task_file" .md) status to '$new_status'"
            return 0
        else
            echo "Error: Failed to update task status" >&2
            return 1
        fi
    else
        # Fallback to sed-based update
        if sed -i "s/^status: .*/status: $new_status/" "$task_file"; then
            echo "✅ Updated task $(basename "$task_file" .md) status to '$new_status'"
            return 0
        else
            echo "Error: Failed to update task status" >&2
            return 1
        fi
    fi
}

# @description Create task content with proper formatting
# @arg $1 string Task name
# @arg $2 string Task description (optional)
# @stdout Task markdown content
# @exitcode 0 Always succeeds
task_create_content() {
    local task_name="$1"
    local description="${2:-}"
    
    local description_section=""
    if [[ -n "$description" ]]; then
        description_section="## Description
$description

"
    fi
    
    # Escape special characters for sed
    local escaped_name="${task_name//\//\\/}"
    local escaped_desc="${description_section//\//\\/}"
    escaped_desc="${escaped_desc//$'\n'/\\n}"
    
    cat <<'TASK_TEMPLATE' | sed "s/TASK_NAME_PLACEHOLDER/$escaped_name/g" | sed "s/DESCRIPTION_SECTION_PLACEHOLDER/$escaped_desc/g"

# Task: TASK_NAME_PLACEHOLDER

DESCRIPTION_SECTION_PLACEHOLDER## Acceptance Criteria
<!-- Define what "done" means for this task -->

## Implementation Details
<!-- Technical approach and considerations -->

## Testing Requirements
<!-- How to verify the task is complete -->

## Notes
<!-- Additional context or considerations -->
TASK_TEMPLATE
}

# @description Create new task with frontmatter
# @arg $1 string Task path
# @arg $2 string Task name
# @arg $3 string Epic name
# @arg $... string Additional field:value pairs (optional)
# @stdout Creation status messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If creation failed
task_create() {
    local task_path="$1"
    local task_name="$2"
    local epic_name="$3"
    shift 3

    if [[ -z "$task_path" || -z "$task_name" || -z "$epic_name" ]]; then
        echo "Error: Missing required parameters" >&2
        echo "Usage: task_create <path> <name> <epic> [field:value ...]" >&2
        return 1
    fi
    
    # Build base frontmatter fields
    local -a frontmatter_fields=(
        "name:$task_name"
        "epic:$epic_name"
        "status:pending"
        "parallel:false"
    )
    
    # Process additional field:value pairs
    local description=""
    for field_value in "$@"; do
        if [[ "$field_value" =~ ^([^:]+):(.*)$ ]]; then
            local field="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            if [[ "$field" == "description" ]]; then
                description="$value"
            else
                frontmatter_fields+=("$field_value")
            fi
        fi
    done
    
    # Generate content using the content creation function
    local task_content
    task_content=$(task_create_content "$task_name" "$description")
    
    # Create task file with frontmatter
    frontmatter_create_markdown --auto-number=task "$task_path" "$task_content" "${frontmatter_fields[@]}"

    return $?
}

# @description Update task fields using frontmatter
# @arg $1 string Task file path
# @arg $... string Field:value pairs to update
# @stdout Update status messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If update failed
task_update() {
    local task_path="$1"
    shift
    
    if [[ -z "$task_path" ]]; then
        echo "Error: Missing task file path" >&2
        echo "Usage: task_update <path> field:value [field:value ...]" >&2
        return 1
    fi
    
    if [[ ! -f "$task_path" ]]; then
        echo "Error: Task file not found: $task_path" >&2
        return 1
    fi
    
    # Update task fields using frontmatter_update_many
    frontmatter_update_many "$task_path" "$@"
    
    return $?
}