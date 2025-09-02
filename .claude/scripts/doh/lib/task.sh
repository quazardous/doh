#!/bin/bash

# DOH Task Management Library
# Pure library for task status, completion verification, and epic/PRD logic (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_TASK_LOADED:-}" ]] && return 0
DOH_LIB_TASK_LOADED=1

# Constants
readonly TASK_LIB_VERSION="1.0.0"

# @description Check if a task is completed based on various criteria
# @public
# @arg $1 string Path to the task file
# @exitcode 0 If task is completed
# @exitcode 1 If task file not found or not completed
task_is_completed() {
    local task_file="$1"
    
    if [[ ! -f "$task_file" ]]; then
        return 1
    fi
    
    local status
    status="$(frontmatter_get_field "$task_file" "status")"
    
    # Check various completion statuses
    case "$status" in
        "closed"|"completed"|"done"|"finished")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# @description Get task status from frontmatter
# @public
# @arg $1 string Path to the task file
# @stdout Task status string ("not_found", "unknown", or actual status)
# @exitcode 0 If successful
# @exitcode 1 If task file not found
task_get_status() {
    local task_file="$1"
    
    if [[ ! -f "$task_file" ]]; then
        echo "not_found"
        return 1
    fi
    
    local status
    status="$(frontmatter_get_field "$task_file" "status")"
    
    if [[ -z "$status" ]]; then
        echo "unknown"
    else
        echo "$status"
    fi
}

# @description List all task files for an epic
# @public
# @arg $1 string Name of the epic
# @stdout List of task file paths (sorted)
# @stderr Error messages if epic not found
# @exitcode 0 If successful
# @exitcode 1 If epic directory not found
task_list_epic_tasks() {
    local epic_name="$1"
    local epic_dir=".doh/epics/$epic_name"
    
    if [[ ! -d "$epic_dir" ]]; then
        echo "Error: Epic not found: $epic_name" >&2
        return 1
    fi
    
    # Find all numbered task files (001.md, 002.md, etc.)
    find "$epic_dir" -name '[0-9][0-9][0-9].md' | sort
}

# @description Calculate completion percentage for an epic
# @public
# @arg $1 string Name of the epic
# @stdout Completion percentage (0-100)
# @exitcode 0 Always successful
task_calculate_epic_progress() {
    local epic_name="$1"
    local total_tasks=0
    local completed_tasks=0
    
    while IFS= read -r task_file; do
        [[ -z "$task_file" ]] && continue
        
        total_tasks=$((total_tasks + 1))
        
        if task_is_completed "$task_file"; then
            completed_tasks=$((completed_tasks + 1))
        fi
    done < <(task_list_epic_tasks "$epic_name")
    
    if [[ $total_tasks -eq 0 ]]; then
        echo "0"
        return 0
    fi
    
    # Calculate percentage
    echo $(( completed_tasks * 100 / total_tasks ))
}

# @description Verify that a task has actually been completed with real work
# @public
# @arg $1 string Path to the task file
# @stderr Error and warning messages about task completion status
# @exitcode 0 If verified complete
# @exitcode 1 If task file not found or not marked as completed
task_verify_completion() {
    local task_file="$1"
    
    if [[ ! -f "$task_file" ]]; then
        echo "Error: Task file not found: $task_file" >&2
        return 1
    fi
    
    # Basic status check
    if ! task_is_completed "$task_file"; then
        echo "Error: Task is not marked as completed" >&2
        return 1
    fi
    
    # Check for GitHub issue (indicates sync)
    local github_field
    github_field="$(frontmatter_get_field "$task_file" "github")"
    
    if [[ -z "$github_field" || "$github_field" == "[Will be updated when synced to GitHub]" ]]; then
        echo "Warning: Task not synced to GitHub - completion may be premature" >&2
    fi
    
    # Additional verification could be added here:
    # - Check for git commits related to this task
    # - Verify files mentioned in task exist
    # - Check for test results
    
    return 0
}

# @description Get task name from frontmatter
# @public
# @arg $1 string Path to the task file
# @stdout Task name string (fallback to "Unknown Task" if not found)
# @exitcode 0 If successful
# @exitcode 1 If task file not found
task_get_name() {
    local task_file="$1"
    
    if [[ ! -f "$task_file" ]]; then
        echo "Unknown Task"
        return 1
    fi
    
    local name
    name="$(frontmatter_get_field "$task_file" "name")"
    
    if [[ -z "$name" ]]; then
        # Fallback to extracting from first heading
        name="$(grep -m1 '^# ' "$task_file" | sed 's/^# *//')"
    fi
    
    echo "${name:-Unknown Task}"
}

# @description Check if task can run in parallel
# @public
# @arg $1 string Path to the task file
# @exitcode 0 If task can run in parallel
# @exitcode 1 If task cannot run in parallel
task_is_parallel() {
    local task_file="$1"
    
    local parallel_field
    parallel_field="$(frontmatter_get_field "$task_file" "parallel")"
    
    [[ "$parallel_field" == "true" ]]
}