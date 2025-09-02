#!/bin/bash

# DOH Workflow Library
# Pure library for task workflow operations (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_WORKFLOW_LOADED:-}" ]] && return 0
DOH_LIB_WORKFLOW_LOADED=1

# Constants
readonly WORKFLOW_LIB_VERSION="1.0.0"

# @description Get next available tasks (pending status, no blocking dependencies)
# @arg $1 string Optional epic name to filter by
# @stdout List of available task numbers/files
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error occurred
workflow_get_next() {
    local epic_filter="${1:-}"
    
    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "🔄 Next Available Tasks:"
    echo "======================="
    echo ""

    local search_path="$doh_root/.doh/epics"
    if [ -n "$epic_filter" ]; then
        search_path="$doh_root/.doh/epics/$epic_filter"
        if [ ! -d "$search_path" ]; then
            echo "Error: Epic not found: $epic_filter" >&2
            return 1
        fi
        echo "Epic: $epic_filter"
        echo ""
    fi

    local count=0
    find "$search_path" -name "[0-9]*.md" -type f 2>/dev/null | sort | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status depends_on task_number title epic_name
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            depends_on=$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null)
            task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
            title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
            
            # Get epic name from path if not filtering by epic
            if [ -z "$epic_filter" ]; then
                local rel_path
                rel_path=$(realpath --relative-to="$doh_root" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == .doh/epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n 's|^\.doh/epics/\([^/]*\)/.*|\1|p')
                fi
            fi

            # Check if task is available (pending status and no blocking dependencies)
            if [[ "$status" == "pending" || "$status" == "open" || -z "$status" ]]; then
                local is_blocked=false
                
                # Check for dependencies
                if [ -n "$depends_on" ] && [ "$depends_on" != "null" ] && [ "$depends_on" != "" ]; then
                    is_blocked=true
                fi
                
                if [ "$is_blocked" = false ]; then
                    local task_info="  • Task $task_number"
                    [ -n "$title" ] && task_info="$task_info: $title"
                    [ -n "$epic_name" ] && task_info="$task_info [$epic_name]"
                    
                    echo "$task_info"
                    ((count++))
                fi
            fi
        fi
    done
    
    echo ""
    local scope_text=""
    [ -n "$epic_filter" ] && scope_text=" in epic '$epic_filter'"
    echo "Found $count available tasks$scope_text"
}

# @description Get tasks currently in progress
# @arg $1 string Optional epic name to filter by
# @stdout List of in-progress task numbers/files
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error occurred
workflow_get_in_progress() {
    local epic_filter="${1:-}"
    
    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "🔄 Tasks In Progress:"
    echo "===================="
    echo ""

    local search_path="$doh_root/.doh/epics"
    if [ -n "$epic_filter" ]; then
        search_path="$doh_root/.doh/epics/$epic_filter"
        if [ ! -d "$search_path" ]; then
            echo "Error: Epic not found: $epic_filter" >&2
            return 1
        fi
        echo "Epic: $epic_filter"
        echo ""
    fi

    local count=0
    find "$search_path" -name "[0-9]*.md" -type f 2>/dev/null | sort | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status task_number title epic_name
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            
            if [ "$status" = "in_progress" ]; then
                task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
                title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
                
                # Get epic name from path if not filtering by epic
                if [ -z "$epic_filter" ]; then
                    local rel_path
                    rel_path=$(realpath --relative-to="$doh_root" "$task_file" 2>/dev/null)
                    if [[ "$rel_path" == .doh/epics/*/[0-9]*.md ]]; then
                        epic_name=$(echo "$rel_path" | sed -n 's|^\.doh/epics/\([^/]*\)/.*|\1|p')
                    fi
                fi

                local task_info="  • Task $task_number"
                [ -n "$title" ] && task_info="$task_info: $title"
                [ -n "$epic_name" ] && task_info="$task_info [$epic_name]"
                
                echo "$task_info"
                ((count++))
            fi
        fi
    done
    
    echo ""
    local scope_text=""
    [ -n "$epic_filter" ] && scope_text=" in epic '$epic_filter'"
    echo "Found $count tasks in progress$scope_text"
}

# @description Get blocked tasks (have dependencies or explicitly marked as blocked)
# @arg $1 string Optional epic name to filter by
# @stdout List of blocked task numbers/files
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error occurred
workflow_get_blocked() {
    local epic_filter="${1:-}"
    
    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "⏸️  Blocked Tasks:"
    echo "=================="
    echo ""

    local search_path="$doh_root/.doh/epics"
    if [ -n "$epic_filter" ]; then
        search_path="$doh_root/.doh/epics/$epic_filter"
        if [ ! -d "$search_path" ]; then
            echo "Error: Epic not found: $epic_filter" >&2
            return 1
        fi
        echo "Epic: $epic_filter"
        echo ""
    fi

    local count=0
    find "$search_path" -name "[0-9]*.md" -type f 2>/dev/null | sort | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status depends_on task_number title epic_name blocked_reason=""
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            depends_on=$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null)
            task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
            title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
            
            # Get epic name from path if not filtering by epic
            if [ -z "$epic_filter" ]; then
                local rel_path
                rel_path=$(realpath --relative-to="$doh_root" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == .doh/epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n 's|^\.doh/epics/\([^/]*\)/.*|\1|p')
                fi
            fi

            local is_blocked=false
            
            # Check if explicitly marked as blocked
            if [ "$status" = "blocked" ]; then
                is_blocked=true
                blocked_reason=" (status: blocked)"
            # Check if has unmet dependencies
            elif [ -n "$depends_on" ] && [ "$depends_on" != "null" ] && [ "$depends_on" != "" ]; then
                is_blocked=true
                blocked_reason=" (has dependencies)"
            fi
            
            if [ "$is_blocked" = true ]; then
                local task_info="  • Task $task_number"
                [ -n "$title" ] && task_info="$task_info: $title"
                [ -n "$epic_name" ] && task_info="$task_info [$epic_name]"
                task_info="$task_info$blocked_reason"
                
                echo "$task_info"
                ((count++))
            fi
        fi
    done
    
    echo ""
    local scope_text=""
    [ -n "$epic_filter" ] && scope_text=" in epic '$epic_filter'"
    echo "Found $count blocked tasks$scope_text"
}

# @description Transition a task to a new status
# @arg $1 string Task number or file path
# @arg $2 string New status (pending|in_progress|completed|blocked)
# @stdout Success message
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If task not found or status invalid
workflow_transition_status() {
    local task_identifier="$1"
    local new_status="$2"
    
    if [ -z "$task_identifier" ] || [ -z "$new_status" ]; then
        echo "Usage: workflow_transition_status <task_number|task_file> <new_status>" >&2
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
    
    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    # Find task file
    local task_file=""
    if [ -f "$task_identifier" ]; then
        task_file="$task_identifier"
    else
        # Search by task number
        task_file=$(find "$doh_root/.doh/epics" -name "${task_identifier}.md" -type f 2>/dev/null | head -1)
        if [ -z "$task_file" ]; then
            # Try with leading zeros
            task_file=$(find "$doh_root/.doh/epics" -name "0${task_identifier}.md" -o -name "00${task_identifier}.md" -type f 2>/dev/null | head -1)
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