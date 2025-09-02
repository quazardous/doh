#!/bin/bash

# DOH Epic Helper
# User-facing functions for epic management operations

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../lib/epic.sh"

# Guard against multiple sourcing
[[ -n "${DOH_HELPER_EPIC_LOADED:-}" ]] && return 0
DOH_HELPER_EPIC_LOADED=1

# @description List all epics categorized by status
# @stdout Formatted list of epics with status categorization and summary
# @stderr Error messages
# @exitcode 0 If successful
helper_epic_list() {
    echo "Getting epics..."
    echo ""
    echo ""

    local doh_root
    doh_root=$(doh_find_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    if [ ! -d "$doh_root/.doh/epics" ]; then
        echo "📁 No epics directory found. Create your first epic with: /doh:prd-parse <feature-name>"
        return 0
    fi
    
    if [ -z "$(ls -d "$doh_root"/.doh/epics/*/ 2>/dev/null)" ]; then
        echo "📁 No epics found. Create your first epic with: /doh:prd-parse <feature-name>"
        return 0
    fi

    echo "📚 Project Epics"
    echo "================"
    echo ""

    # Initialize arrays to store epics by status
    local planning_epics="" in_progress_epics="" completed_epics=""

    # Process all epics
    for dir in "$doh_root"/.doh/epics/*/; do
        [ -d "$dir" ] || continue
        [ -f "$dir/epic.md" ] || continue

        # Extract metadata using frontmatter if available, fallback to grep
        local name status progress github
        if command -v frontmatter_get_field >/dev/null 2>&1; then
            name=$(frontmatter_get_field "$dir/epic.md" "name" 2>/dev/null)
            status=$(frontmatter_get_field "$dir/epic.md" "status" 2>/dev/null)
            progress=$(frontmatter_get_field "$dir/epic.md" "progress" 2>/dev/null)
            github=$(frontmatter_get_field "$dir/epic.md" "github" 2>/dev/null)
        else
            # Fallback to grep
            name=$(grep "^name:" "$dir/epic.md" | head -1 | sed 's/^name: *//')
            status=$(grep "^status:" "$dir/epic.md" | head -1 | sed 's/^status: *//' | tr '[:upper:]' '[:lower:]')
            progress=$(grep "^progress:" "$dir/epic.md" | head -1 | sed 's/^progress: *//')
            github=$(grep "^github:" "$dir/epic.md" | head -1 | sed 's/^github: *//')
        fi

        # Defaults
        [ -z "$name" ] && name=$(basename "$dir")
        [ -z "$progress" ] && progress="0%"
        [ -z "$status" ] && status=""

        # Count tasks
        local task_count
        task_count=$(ls "$dir"[0-9]*.md 2>/dev/null | wc -l)

        # Format output with GitHub issue number if available
        local entry
        if [ -n "$github" ]; then
            local issue_num
            issue_num=$(echo "$github" | grep -o '/[0-9]*$' | tr -d '/')
            entry="   📋 ${dir}epic.md (#$issue_num) - $progress complete ($task_count tasks)"
        else
            entry="   📋 ${dir}epic.md - $progress complete ($task_count tasks)"
        fi

        # Categorize by status (handle various status values)
        case "$status" in
            planning|draft|"")
                planning_epics="${planning_epics}${entry}\n"
                ;;
            in-progress|in_progress|active|started)
                in_progress_epics="${in_progress_epics}${entry}\n"
                ;;
            completed|complete|done|closed|finished)
                completed_epics="${completed_epics}${entry}\n"
                ;;
            *)
                # Default to planning for unknown statuses
                planning_epics="${planning_epics}${entry}\n"
                ;;
        esac
    done

    # Display categorized epics
    echo "📝 Planning:"
    if [ -n "$planning_epics" ]; then
        echo -e "$planning_epics" | sed '/^$/d'
    else
        echo "   (none)"
    fi

    echo ""
    echo "🚀 In Progress:"
    if [ -n "$in_progress_epics" ]; then
        echo -e "$in_progress_epics" | sed '/^$/d'
    else
        echo "   (none)"
    fi

    echo ""
    echo "✅ Completed:"
    if [ -n "$completed_epics" ]; then
        echo -e "$completed_epics" | sed '/^$/d'
    else
        echo "   (none)"
    fi

    # Summary
    echo ""
    echo "📊 Summary"
    local total tasks
    total=$(ls -d "$doh_root"/.doh/epics/*/ 2>/dev/null | wc -l)
    tasks=$(find "$doh_root"/.doh/epics -name "[0-9]*.md" 2>/dev/null | wc -l)
    echo "   Total epics: $total"
    echo "   Total tasks: $tasks"

    return 0
}

# @description Show detailed epic information
# @arg $1 string Epic name (required)
# @stdout Detailed epic information and task breakdown
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic not found or no name provided
helper_epic_show() {
    if [ -z "$1" ]; then
        echo "Usage: epic show <epic-name>" >&2
        return 1
    fi

    # Call the library function which already provides user-friendly output
    epic_show "$@"
}

# @description Get epic status with progress and task breakdown
# @arg $1 string Epic name (required)
# @stdout Epic status report with progress bar and task counts
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic not found or no name provided
helper_epic_status() {
    if [ -z "$1" ]; then
        echo "Usage: epic status <epic-name>" >&2
        echo ""
        echo "Available epics:"
        helper_epic_list | grep "📋" | head -10
        return 1
    fi

    # Call the library function which already provides user-friendly output
    epic_get_status "$@"
}

# @description Get tasks from an epic by status
# @arg $1 string Epic name (required)
# @arg $2 string Optional status filter (pending|in_progress|completed|blocked)
# @stdout List of task numbers/files with status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic not found or no name provided
helper_epic_tasks() {
    if [ -z "$1" ]; then
        echo "Usage: epic tasks <epic-name> [status]" >&2
        echo "Status options: pending, in_progress, completed, blocked" >&2
        return 1
    fi

    local epic_name="$1"
    local status_filter="${2:-}"

    echo "📋 Tasks in epic: $epic_name"
    if [ -n "$status_filter" ]; then
        echo "Filter: $status_filter"
    fi
    echo "=========================="
    echo ""

    # Get tasks using library function
    local tasks
    tasks=$(epic_get_tasks "$epic_name" "$status_filter" 2>/dev/null)
    
    if [ -z "$tasks" ]; then
        echo "No tasks found"
        if [ -n "$status_filter" ]; then
            echo "Try without status filter: epic tasks $epic_name"
        fi
        return 0
    fi

    # Display tasks with more user-friendly format
    local count=0
    while IFS= read -r task_num; do
        if [ -n "$task_num" ]; then
            echo "  • Task $task_num"
            ((count++))
        fi
    done <<< "$tasks"

    echo ""
    echo "Total: $count tasks"
    
    if [ -n "$status_filter" ]; then
        echo "Status: $status_filter"
    fi

    return 0
}

# @description Display epic command help
# @stdout Help information for epic commands
# @exitcode 0 Always successful
helper_epic_help() {
    echo "DOH Epic Management"
    echo "=================="
    echo ""
    echo "Usage: helper.sh epic <command> [options]"
    echo ""
    echo "Commands:"
    echo "  list                    List all epics categorized by status"
    echo "  show <epic-name>        Show detailed epic information"
    echo "  status <epic-name>      Get epic status with progress and tasks"
    echo "  tasks <epic-name> [status]  List tasks in epic (optional status filter)"
    echo "  help                    Show this help message"
    echo ""
    echo "Status filters for tasks command:"
    echo "  pending     - Tasks not yet started"
    echo "  in_progress - Tasks currently being worked on"
    echo "  completed   - Finished tasks"
    echo "  blocked     - Tasks that are blocked"
    echo ""
    echo "Examples:"
    echo "  helper.sh epic list"
    echo "  helper.sh epic show data-api-sanity"
    echo "  helper.sh epic status versioning"
    echo "  helper.sh epic tasks data-api-sanity pending"
    return 0
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed