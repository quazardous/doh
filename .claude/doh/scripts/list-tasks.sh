#!/bin/bash
# DOH List Tasks Script - High frequency bash optimization
# Usage: list-tasks.sh [status] [output_format]
# CWD Independent: Works from any directory

set -euo pipefail

# Get script directory for lib loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load unified DOH library
source "$SCRIPT_DIR/lib/doh.sh"

# ==============================================================================
# SCRIPT FUNCTIONS
# ==============================================================================

show_usage() {
    echo "Usage: $0 [status] [output_format]"
    echo ""
    echo "Arguments:"
    echo "  status         Filter by status (pending|active|completed|all) - default: all"
    echo "  output_format  json|text|summary (default: text)"
    echo ""
    echo "Examples:"
    echo "  $0                    # List all tasks"
    echo "  $0 pending            # List only pending tasks"
    echo "  $0 pending json       # List pending tasks as JSON"
    echo "  $0 all summary        # Summary view of all tasks"
    echo ""
    echo "Exit codes:"
    echo "  0 - Success"
    echo "  1 - DOH project not initialized"
    echo "  2 - No tasks found"
    echo "  3 - Invalid arguments"
}

format_task_text() {
    local task_json="$1"
    
    echo "$task_json" | jq -r '
    "  #" + .id + ": " + .title,
    "    Status: " + .status,
    "    Epic: " + (if .parent_epic then .parent_epic else "None"),
    "    Path: " + .path,
    ""
    '
}

format_task_summary() {
    local task_json="$1"
    
    echo "$task_json" | jq -r '
    "#" + .id + ": " + .title + " [" + .status + "]"
    '
}

list_tasks_bash() {
    local status_filter="${1:-all}"
    local output_format="${2:-text}"
    
    # Performance tracking
    if [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]]; then
        doh_timer_start
    fi
    
    # Validate DOH project
    if ! doh_check_initialized; then
        doh_error "DOH project not initialized"
        return 1
    fi
    
    # Get tasks using DOH library function
    local tasks_json
    if ! tasks_json=$(doh_list_items_by_type "tasks" 2>/dev/null); then
        doh_error "Failed to retrieve tasks"
        return 2
    fi
    
    # Filter by status if specified
    if [[ "$status_filter" != "all" ]]; then
        tasks_json=$(echo "$tasks_json" | jq -c "select(.status == \"$status_filter\")")
        if [[ -z "$tasks_json" ]]; then
            doh_log "No tasks found with status: $status_filter"
            return 2
        fi
    fi
    
    # Convert to array for consistent processing
    local tasks_array
    tasks_array=$(echo "$tasks_json" | jq -s '.')
    
    # Check if we have tasks
    local task_count
    task_count=$(echo "$tasks_array" | jq 'length')
    if [[ "$task_count" -eq 0 ]]; then
        doh_log "No tasks found"
        return 2
    fi
    
    # Format output
    case "$output_format" in
        json)
            echo "$tasks_array" | jq '.'
            ;;
        text)
            echo "DOH Tasks (Status: $status_filter)"
            echo "=================================="
            echo ""
            echo "$tasks_array" | jq -c '.[]' | while IFS= read -r task; do
                format_task_text "$task"
            done
            echo "Total: $task_count task(s)"
            ;;
        summary)
            echo "DOH Tasks Summary (Status: $status_filter):"
            echo "$tasks_array" | jq -c '.[]' | while IFS= read -r task; do
                echo "  $(format_task_summary "$task")"
            done
            echo "Total: $task_count task(s)"
            ;;
        *)
            doh_error "Invalid output format: $output_format"
            return 3
            ;;
    esac
    
    # Performance reporting
    if [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]]; then
        local duration=$(doh_timer_end)
        doh_debug "list-tasks.sh completed in ${duration}ms (bash)"
    fi
    
    return 0
}

claude_fallback() {
    local status_filter="${1:-all}"
    local output_format="${2:-text}"
    
    doh_debug "Falling back to Claude for list-tasks operation"
    
    # This would call the original Claude command
    # For now, return error to indicate fallback needed
    doh_error "Claude fallback not implemented yet"
    return 5
}

# ==============================================================================
# MAIN SCRIPT LOGIC
# ==============================================================================

main() {
    local status_filter="${1:-all}"
    local output_format="${2:-text}"
    
    # Validate status filter
    if [[ ! "$status_filter" =~ ^(pending|active|completed|all)$ ]]; then
        doh_error "Invalid status filter: '$status_filter'"
        show_usage
        return 3
    fi
    
    # Validate output format
    if [[ ! "$output_format" =~ ^(json|text|summary)$ ]]; then
        doh_error "Invalid output format: '$output_format'"
        show_usage
        return 3
    fi
    
    # Try bash implementation first (if bash optimization enabled)
    if [[ "$DOH_BASH_OPTIMIZATION" == "1" ]]; then
        if list_tasks_bash "$status_filter" "$output_format"; then
            return 0
        elif [[ "$DOH_FALLBACK_ENABLED" == "1" ]]; then
            claude_fallback "$status_filter" "$output_format"
            return $?
        else
            return $?
        fi
    else
        # Direct Claude fallback if bash optimization disabled
        claude_fallback "$status_filter" "$output_format"
        return $?
    fi
}

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi