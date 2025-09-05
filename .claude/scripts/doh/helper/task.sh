#!/bin/bash

# DOH Task Helper
# User-facing functions for task management operations

set -euo pipefail

# Source required dependencies
DOH_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
source "${DOH_ROOT}/.claude/scripts/doh/lib/dohenv.sh"
source "${DOH_ROOT}/.claude/scripts/doh/lib/doh.sh"
source "${DOH_ROOT}/.claude/scripts/doh/lib/numbering.sh" 
source "${DOH_ROOT}/.claude/scripts/doh/lib/frontmatter.sh"
source "${DOH_ROOT}/.claude/scripts/doh/lib/task.sh"

# Load DOH environment
dohenv_load

# Guard against multiple sourcing
[[ -n "${DOH_HELPER_TASK_LOADED:-}" ]] && return 0
DOH_HELPER_TASK_LOADED=1

# @description Créer une nouvelle tâche pour un epic
# @arg $1 string Nom de l'epic
# @arg $2 string Titre de la tâche
# @arg $3 string Target version (optionnel, hérite de l'epic par défaut)
# @stdout Messages de création
# @stderr Messages d'erreur  
# @exitcode 0 Si création réussie
# @exitcode 1 Si erreur
helper_task_new() {
    local epic_name="${1:-}"
    local task_title="${2:-}"
    local target_version="${3:-}"
    
    # Validation
    if [[ -z "$epic_name" ]]; then
        echo "Error: Epic name required" >&2
        echo "Usage: helper.sh task new <epic-name> <task-title> [target_version]" >&2
        return 1
    fi
    
    if [[ -z "$task_title" ]]; then
        echo "Error: Task title required" >&2
        echo "Usage: helper.sh task new <epic-name> <task-title> [target_version]" >&2
        return 1
    fi

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    # Check if epic exists
    local epic_path="$doh_dir/epics/${epic_name}/epic.md"
    if [[ ! -f "$epic_path" ]]; then
        echo "Error: Epic not found: $epic_path" >&2
        echo "Available epics:" >&2
        if [[ -d "$doh_dir/epics" ]]; then
            find "$doh_dir/epics" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r dir; do
                [ -d "$dir" ] && echo "  • $(basename "$dir")" >&2
            done
        fi
        return 1
    fi
    
    # Extract target_version from epic if not provided
    if [[ -z "$target_version" ]]; then
        target_version="$(frontmatter_get_field "$epic_path" "target_version" 2>/dev/null || echo "")"
        if [[ -n "$target_version" ]]; then
            echo "📋 Inherited target_version from epic: $target_version"
        fi
    fi
    
    echo "Creating task: $task_title"
    echo "For epic: $epic_name"
    
    # Create task file path with next available number
    local task_dir="$doh_dir/epics/${epic_name}"
    local task_number
    task_number="$(numbering_get_next "task")" || {
        echo "Error: Could not generate task number" >&2
        return 1
    }
    
    local task_path="$task_dir/${task_number}.md"
    
    # Build additional fields for task creation
    local -a additional_fields=()
    if [[ -n "$target_version" ]]; then
        additional_fields+=("target_version:$target_version")
        echo "🎯 Set target_version: $target_version"
    fi
    
    # Create task using library function with auto-numbering
    task_create "$task_path" "$task_title" "$epic_name" "${additional_fields[@]}"
    
    # Get the generated number for display
    local actual_task_number
    actual_task_number=$(frontmatter_get_field "$task_path" "number")
    
    echo "✅ Task created: $task_path"
    echo "   Number: $actual_task_number"
    echo "   Title: $task_title"
    echo "   Epic: $epic_name"
    echo "   Status: pending"
    if [[ -n "$target_version" ]]; then
        echo "   Target version: $target_version"
    fi
    
    return 0
}


# @description Obtenir le statut d'une tâche
# @arg $1 string Numéro de la tâche
# @stdout Statut et informations de la tâche
# @exitcode 0 Si tâche trouvée
# @exitcode 1 Si tâche non trouvée ou erreur
helper_task_status() {
    local task_number="${1:-}"
    
    if [[ -z "$task_number" ]]; then
        echo "Error: Task number required" >&2
        echo "Usage: helper.sh task status <task-number>" >&2
        return 1
    fi

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    # Find task file by number (search in all epics)
    local task_file
    task_file=$(find "$doh_dir/epics" -name "${task_number}.md" -type f 2>/dev/null | head -1)

    if [[ -z "$task_file" ]]; then
        echo "Error: Task #$task_number not found" >&2
        echo "Available tasks:" >&2
        find "$doh_dir/epics" -name "[0-9][0-9][0-9].md" -type f 2>/dev/null | sort | head -10 | while read -r f; do
            local num=$(basename "$f" .md)
            echo "  - Task #$num"
        done
        return 1
    fi
    
    echo "Task Status Report"
    echo "=================="
    
    # Extract task metadata
    local task_name status created updated epic parallel depends_on
    task_name="$(frontmatter_get_field "$task_file" "name" 2>/dev/null || echo "")"
    status="$(frontmatter_get_field "$task_file" "status" 2>/dev/null || echo "")"
    created="$(frontmatter_get_field "$task_file" "created" 2>/dev/null || echo "")"
    updated="$(frontmatter_get_field "$task_file" "updated" 2>/dev/null || echo "")"
    epic="$(frontmatter_get_field "$task_file" "epic" 2>/dev/null || echo "")"
    parallel="$(frontmatter_get_field "$task_file" "parallel" 2>/dev/null || echo "")"
    depends_on="$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null || echo "")"
    
    # Display task information
    echo "📋 Task #$task_number: $task_name"
    echo "   Status: ${status:-unknown}"
    echo "   Epic: ${epic:-unknown}"
    echo "   File: $task_file"
    echo ""
    echo "📅 Timeline:"
    echo "   Created: ${created:-unknown}"
    echo "   Updated: ${updated:-unknown}"
    echo ""
    echo "🔄 Execution:"
    echo "   Parallel: ${parallel:-unknown}"
    if [[ -n "$depends_on" && "$depends_on" != "[]" ]]; then
        echo "   Dependencies: $depends_on"
    else
        echo "   Dependencies: none"
    fi
    
    # Status-specific information
    case "$status" in
        "open"|"pending")
            echo ""
            echo "✅ Ready to start"
            echo "💡 Suggestion: Update status when you begin work"
            ;;
        "in_progress"|"in-progress")
            echo ""
            echo "🚀 In progress"
            echo "💡 Suggestion: Update status when complete"
            ;;
        "completed"|"done")
            echo ""
            echo "✅ Completed"
            ;;
        "blocked")
            echo ""
            echo "🚫 Blocked"
            echo "💡 Check dependencies and resolve blockers"
            ;;
        *)
            echo ""
            echo "⚠️ Unknown status: $status"
            ;;
    esac
    
    return 0
}

# @description Mettre à jour le statut d'une tâche
# @arg $1 string Numéro de la tâche
# @arg $2 string Nouveau statut
# @stdout Confirmation de la mise à jour
# @exitcode 0 Si mise à jour réussie
# @exitcode 1 Si erreur
helper_task_update_status() {
    local task_number="$1"
    local new_status="$2"
    
    if [[ -z "$task_number" || -z "$new_status" ]]; then
        echo "Error: Task number and status required" >&2
        echo "Usage: helper.sh task update <task-number> <status>" >&2
        echo "Valid statuses: open, in_progress, completed, blocked" >&2
        return 1
    fi
    
    # Validate status
    case "$new_status" in
        "open"|"pending"|"in_progress"|"in-progress"|"completed"|"done"|"blocked")
            # Valid status
            ;;
        *)
            echo "Error: Invalid status '$new_status'" >&2
            echo "Valid statuses: open, in_progress, completed, blocked" >&2
            return 1
            ;;
    esac

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    # Find task file
    local task_file
    task_file=$(find "$doh_dir/epics" -name "${task_number}.md" -type f 2>/dev/null | head -1)

    if [[ -z "$task_file" ]]; then
        echo "Error: Task #$task_number not found" >&2
        return 1
    fi
    
    # Get current status
    local current_status
    current_status="$(frontmatter_get_field "$task_file" "status" 2>/dev/null || echo "")"
    
    echo "Updating task #$task_number status"
    echo "  From: ${current_status:-unknown}"
    echo "  To: $new_status"
    
    # Update status and updated timestamp
    local updated_date
    updated_date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    
    frontmatter_update_field "$task_file" "status" "$new_status"
    frontmatter_update_field "$task_file" "updated" "$updated_date"
    
    echo "✅ Task #$task_number status updated to: $new_status"
    
    return 0
}

# @description Update task fields
# @arg $1 string Task number
# @arg $... string Field:value pairs to update
# @stdout Update status messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If update failed
helper_task_update() {
    local task_number="${1:-}"
    shift
    
    # Check if this is the old status-only update syntax
    if [[ $# -eq 1 && ! "$1" =~ : ]]; then
        # Legacy syntax: task update <number> <status>
        helper_task_update_status "$task_number" "$1"
        return $?
    fi
    
    # Validation
    if [[ -z "$task_number" ]]; then
        echo "Error: Task number required" >&2
        echo "Usage: task update <task-number> field:value [field:value ...]" >&2
        echo "   Or: task update <task-number> <status> (legacy)" >&2
        return 1
    fi
    
    # Get DOH directory
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    # Find task file
    local task_file
    task_file=$(find "$doh_dir/epics" -name "${task_number}.md" -type f 2>/dev/null | head -1)
    
    if [[ -z "$task_file" ]]; then
        echo "Error: Task #$task_number not found" >&2
        return 1
    fi
    
    # Update task fields using library function
    echo "📝 Updating task: #$task_number"
    task_update "$task_file" "$@"
    local result=$?
    
    if [[ $result -eq 0 ]]; then
        echo "✅ Task updated successfully"
        
        # Show updated fields
        for field_value in "$@"; do
            if [[ "$field_value" =~ ^([^:]+):(.*)$ ]]; then
                local field="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"
                echo "   • $field: $value"
            fi
        done
    else
        echo "❌ Failed to update task" >&2
    fi
    
    return $result
}

# @description Afficher l'aide des commandes task
# @stdout Informations d'aide
# @exitcode 0 Toujours
helper_task_help() {
    echo "DOH Task Management"
    echo "=================="
    echo ""
    echo "Usage: helper.sh task <command> [options]"
    echo ""
    echo "Commands:"
    echo "  new <epic-name> <task-title> [target_version]  Create new task for epic"
    echo "  status <task-number>                           Show detailed task status"
    echo "  update <task-number> <status>                  Update task status"
    echo "  update <task-number> field:value [...]         Update task fields"
    echo "  help                                           Show this help message"
    echo ""
    echo "Valid status values:"
    echo "  open          - Task is ready to be worked on"
    echo "  in_progress   - Task is currently being worked on"
    echo "  completed     - Task has been finished"
    echo "  blocked       - Task is blocked and cannot proceed"
    echo ""
    echo "Examples:"
    echo "  helper.sh task new command-with-helper 'Add error handling' 2.1.0"
    echo "  helper.sh task status 003"
    echo "  helper.sh task update 003 in_progress"
    echo "  helper.sh task update 003 status:completed parallel:true"
    return 0
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed