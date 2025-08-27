#!/bin/bash
# DOH Wrapper Library - High-level wrapper functions with fallback
# Source this file after doh-core.sh to access wrapper functions

# Prevent double-sourcing
[[ "${DOH_WRAPPERS_LOADED:-}" == "1" ]] && return 0
readonly DOH_WRAPPERS_LOADED=1

# Load core library if not already loaded
if [[ "${DOH_CORE_LOADED:-}" != "1" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/doh-core.sh"
fi

# ==============================================================================
# WRAPPER CONFIGURATION
# ==============================================================================

readonly DOH_FALLBACK_ENABLED="${DOH_FALLBACK_ENABLED:-1}"
readonly DOH_PERFORMANCE_TRACKING="${DOH_PERFORMANCE_TRACKING:-0}"

# ==============================================================================
# FALLBACK FUNCTIONS
# ==============================================================================

# Claude fallback for complex operations
doh_fallback_to_claude() {
    local operation="$1"
    shift
    local args=("$@")
    
    doh_error "Bash script operation '$operation' failed"
    doh_log "Would fallback to Claude with operation: $operation ${args[*]}"
    doh_log "Claude would provide:"
    doh_log "  - Intelligent error handling"
    doh_log "  - Context-aware suggestions"
    doh_log "  - Fallback data processing"
    
    return 10  # Special code for Claude fallback needed
}

# Execute with fallback wrapper
doh_execute_with_fallback() {
    local operation="$1"
    local bash_function="$2"
    shift 2
    local args=("$@")
    
    # Performance tracking
    [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]] && doh_timer_start
    
    # Try bash function first
    if "$bash_function" "${args[@]}" 2>/dev/null; then
        if [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]]; then
            local duration
            duration=$(doh_timer_end)
            doh_success "Bash script succeeded (${duration}ms)"
            doh_log "Token savings: ~300-800 tokens"
        fi
        return 0
    else
        # Fallback to Claude if enabled
        if [[ "$DOH_FALLBACK_ENABLED" == "1" ]]; then
            doh_fallback_to_claude "$operation" "${args[@]}"
            return $?
        else
            doh_error "Operation '$operation' failed and fallback disabled"
            return 1
        fi
    fi
}

# ==============================================================================
# HIGH-LEVEL WRAPPER FUNCTIONS
# ==============================================================================

# Get item with fallback
doh_safe_get_item() {
    local item_id="$1"
    local item_type="${2:-auto}"
    
    if [[ "$item_type" == "auto" ]]; then
        doh_execute_with_fallback "get-item" "doh_get_item" "$item_id"
    else
        doh_execute_with_fallback "get-item-by-type" "doh_get_item_by_type" "$item_id" "$item_type"
    fi
}

# Get project statistics with fallback
doh_safe_get_stats() {
    local format="${1:-human}"
    doh_execute_with_fallback "project-stats" "doh_get_project_stats" "$format"
}

# List items with fallback
doh_safe_list_items() {
    local item_type="$1"
    doh_execute_with_fallback "list-items" "doh_list_items_by_type" "$item_type"
}

# Validate project with fallback
doh_safe_validate_project() {
    doh_execute_with_fallback "validate-project" "doh_validate_project_structure"
}

# ==============================================================================
# BATCH OPERATIONS
# ==============================================================================

# Get multiple items efficiently
doh_get_items_batch() {
    local item_ids=("$@")
    local results=()
    local failed_ids=()
    
    doh_log "Processing ${#item_ids[@]} items in batch..."
    
    for item_id in "${item_ids[@]}"; do
        if result=$(doh_get_item "$item_id" 2>/dev/null); then
            results+=("$result")
        else
            failed_ids+=("$item_id")
        fi
    done
    
    # Output successful results
    for result in "${results[@]}"; do
        echo "$result"
    done
    
    # Report failures
    if [[ ${#failed_ids[@]} -gt 0 ]]; then
        doh_error "Failed to retrieve items: ${failed_ids[*]}"
        return 1
    fi
    
    return 0
}

# Get comprehensive dashboard data
doh_get_dashboard_data() {
    local output_format="${1:-json}"
    
    doh_log "Generating dashboard data..."
    
    # Combine multiple data sources
    local stats project_health session_info
    
    stats=$(doh_get_project_stats "json" 2>/dev/null) || {
        doh_error "Failed to get project stats"
        return 1
    }
    
    # Project health check
    if doh_validate_project_structure >/dev/null 2>&1; then
        project_health='"healthy"'
    else
        project_health='"unhealthy"'
    fi
    
    # Combine all data
    local dashboard_data
    dashboard_data=$(echo "$stats" | jq --argjson health "$project_health" '
    . + {
        "health": $health,
        "generated_at": (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
        "version": "1.0"
    }')
    
    if [[ "$output_format" == "json" ]]; then
        echo "$dashboard_data"
    else
        # Convert to human-readable dashboard
        echo "$dashboard_data" | jq -r '
        "=== DOH PROJECT DASHBOARD ===",
        "",
        "📊 OVERVIEW",
        ("Project: " + .project.name),
        ("Health: " + .health),
        ("Generated: " + .generated_at),
        "",
        "📈 STATISTICS",
        ("Tasks: " + (.items.tasks | tostring) + " | Epics: " + (.items.epics | tostring)),
        ("Features: " + (.items.features | tostring) + " | PRDs: " + (.items.prds | tostring)),
        "",
        "⚡ CURRENT SESSION",
        ("Epic: " + .session.current_epic),
        ("Task: " + .session.current_task),
        "",
        "📋 TASK STATUS",
        ((.task_status | to_entries[] | "  " + .key + ": " + (.value | tostring)) // "  No tasks"),
        ""
        '
    fi
}

# ==============================================================================
# SEARCH AND FILTER FUNCTIONS
# ==============================================================================

# Search items by title pattern
doh_search_items() {
    local search_pattern="$1"
    local item_type="${2:-all}"
    
    doh_log "Searching for pattern: '$search_pattern'"
    
    local index_data
    index_data=$(doh_load_index) || return $?
    
    if [[ "$item_type" == "all" ]]; then
        # Search across all item types
        echo "$index_data" | jq -r --arg pattern "$search_pattern" '
        (.items.tasks, .items.epics, .items.features, .items.prds) | 
        to_entries[] | 
        select(.value.title | test($pattern; "i")) |
        .value + {"id": .key}
        '
    else
        # Search in specific item type
        echo "$index_data" | jq -r --arg pattern "$search_pattern" --arg type "$item_type" '
        .items[$type] | to_entries[] | 
        select(.value.title | test($pattern; "i")) |
        .value + {"id": .key, "item_type": $type}
        '
    fi
}

# Filter items by status
doh_filter_items_by_status() {
    local status="$1"
    local item_type="${2:-tasks}"
    
    echo "$(doh_load_index)" | jq -r --arg status "$status" --arg type "$item_type" '
    .items[$type] | to_entries[] |
    select(.value.status == $status) |
    .value + {"id": .key, "item_type": $type}
    '
}

# ==============================================================================
# EXPORT FUNCTIONS
# ==============================================================================

# Export wrapper functions
export -f doh_fallback_to_claude doh_execute_with_fallback
export -f doh_safe_get_item doh_safe_get_stats doh_safe_list_items doh_safe_validate_project
export -f doh_get_items_batch doh_get_dashboard_data
export -f doh_search_items doh_filter_items_by_status

doh_debug "DOH Wrappers Library loaded successfully"