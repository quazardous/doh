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