#!/bin/bash
# DOH Core Library - Base functions and utilities
# Source this file to access all DOH internal functions

# Prevent double-sourcing
[[ "${DOH_CORE_LOADED:-}" == "1" ]] && return 0
readonly DOH_CORE_LOADED=1

# ==============================================================================
# CORE CONFIGURATION
# ==============================================================================

# Project paths
readonly DOH_PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
readonly DOH_INDEX_FILE="$DOH_PROJECT_ROOT/.doh/project-index.json"
readonly DOH_SESSION_FILE="$DOH_PROJECT_ROOT/.doh/memory/active-session.json"
readonly DOH_MEMORY_DIR="$DOH_PROJECT_ROOT/.doh/memory"

# Script configuration - Load from config.ini if available, fallback to env vars
_doh_load_script_config() {
    # Try to load config from config.ini first
    local config_file="$DOH_PROJECT_ROOT/.doh/config.ini"
    if [[ -f "$config_file" ]]; then
        # Source config library if not already loaded
        if [[ "${DOH_CONFIG_LOADED:-}" != "1" ]]; then
            local lib_dir="$(dirname "${BASH_SOURCE[0]}")"
            source "$lib_dir/doh-config.sh" 2>/dev/null || true
        fi
        
        # Load from config.ini with env var fallback
        if [[ "${DOH_CONFIG_LOADED:-}" == "1" ]]; then
            DOH_DEBUG=$(doh_config_bool "scripting" "debug_mode" "${DOH_DEBUG:-0}")
            DOH_QUIET=$(doh_config_bool "scripting" "quiet_mode" "${DOH_QUIET:-0}")
            DOH_PERFORMANCE_TRACKING=$(doh_config_bool "scripting" "performance_tracking" "${DOH_PERFORMANCE_TRACKING:-0}")
            DOH_BASH_OPTIMIZATION=$(doh_config_bool "scripting" "enable_bash_optimization" "1")
            DOH_FALLBACK_ENABLED=$(doh_config_bool "scripting" "fallback_to_claude" "1")
        else
            # Fallback to env vars if config loading failed
            DOH_DEBUG="${DOH_DEBUG:-0}"
            DOH_QUIET="${DOH_QUIET:-0}"
            DOH_PERFORMANCE_TRACKING="${DOH_PERFORMANCE_TRACKING:-0}"
            DOH_BASH_OPTIMIZATION="1"
            DOH_FALLBACK_ENABLED="1"
        fi
    else
        # No config file, use env vars
        DOH_DEBUG="${DOH_DEBUG:-0}"
        DOH_QUIET="${DOH_QUIET:-0}"
        DOH_PERFORMANCE_TRACKING="${DOH_PERFORMANCE_TRACKING:-0}"
        DOH_BASH_OPTIMIZATION="1"
        DOH_FALLBACK_ENABLED="1"
    fi
    
    # Convert to readonly after loading
    readonly DOH_DEBUG DOH_QUIET DOH_PERFORMANCE_TRACKING
    readonly DOH_BASH_OPTIMIZATION DOH_FALLBACK_ENABLED
}

# Load configuration on library source
_doh_load_script_config

# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# Logging functions
doh_log() {
    [[ "$DOH_QUIET" == "1" ]] && return 0
    echo "🔧 DOH: $*" >&2
}

doh_debug() {
    [[ "$DOH_DEBUG" == "1" ]] && echo "🐛 DEBUG: $*" >&2
}

doh_error() {
    echo "❌ ERROR: $*" >&2
}

doh_success() {
    [[ "$DOH_QUIET" == "1" ]] && return 0
    echo "✅ $*" >&2
}

# Performance tracking
doh_timer_start() {
    DOH_START_TIME=$(date +%s%N)
}

doh_timer_end() {
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - DOH_START_TIME) / 1000000 ))
    echo "$duration"
}

# ==============================================================================
# FILE VALIDATION FUNCTIONS
# ==============================================================================

# Check if DOH project is initialized
doh_check_initialized() {
    if [[ ! -f "$DOH_INDEX_FILE" ]]; then
        doh_error "DOH project not initialized. Missing: $DOH_INDEX_FILE"
        return 1
    fi
    return 0
}

# Validate JSON file integrity
doh_validate_json() {
    local file="$1"
    local description="${2:-JSON file}"
    
    if [[ ! -f "$file" ]]; then
        doh_error "$description not found: $file"
        return 1
    fi
    
    if ! jq empty "$file" 2>/dev/null; then
        doh_error "Invalid JSON in $description: $file"
        return 2
    fi
    
    return 0
}

# Validate index file structure
doh_validate_index_structure() {
    local index_file="${1:-$DOH_INDEX_FILE}"
    
    doh_validate_json "$index_file" "DOH index file" || return $?
    
    # Check required structure
    if ! jq -e '.metadata and .items and .counters' "$index_file" >/dev/null; then
        doh_error "Invalid DOH index structure"
        return 3
    fi
    
    return 0
}

# ==============================================================================
# JSON DATA ACCESS FUNCTIONS
# ==============================================================================

# Load DOH index data (cached for performance)
doh_load_index() {
    doh_validate_index_structure || return $?
    
    # Cache index data in memory if not already loaded
    if [[ -z "${DOH_INDEX_DATA:-}" ]]; then
        DOH_INDEX_DATA=$(cat "$DOH_INDEX_FILE")
        doh_debug "Index data loaded into memory"
    fi
    
    echo "$DOH_INDEX_DATA"
}

# Get item by ID (auto-detect type)
doh_get_item() {
    local item_id="$1"
    local index_data
    
    index_data=$(doh_load_index) || return $?
    
    # Search in all item types
    for item_type in tasks epics features prds; do
        local item
        item=$(echo "$index_data" | jq -r ".items.$item_type[\"$item_id\"] // empty")
        
        if [[ -n "$item" && "$item" != "null" ]]; then
            echo "$item" | jq -r ". + {\"item_type\": \"$item_type\", \"id\": \"$item_id\"}"
            return 0
        fi
    done
    
    doh_error "Item with ID '$item_id' not found"
    return 4
}

# Get item by type and ID
doh_get_item_by_type() {
    local item_id="$1"
    local item_type="$2"
    local index_data
    
    index_data=$(doh_load_index) || return $?
    
    # Normalize type name
    case "$item_type" in
        task) item_type="tasks" ;;
        epic) item_type="epics" ;;
        feature) item_type="features" ;;
        prd) item_type="prds" ;;
    esac
    
    local item
    item=$(echo "$index_data" | jq -r ".items.$item_type[\"$item_id\"] // empty")
    
    if [[ -n "$item" && "$item" != "null" ]]; then
        echo "$item" | jq -r ". + {\"item_type\": \"$item_type\", \"id\": \"$item_id\"}"
        return 0
    fi
    
    doh_error "$item_type with ID '$item_id' not found"
    return 4
}

# List all items of a specific type
doh_list_items_by_type() {
    local item_type="$1"
    local index_data
    
    index_data=$(doh_load_index) || return $?
    
    # Normalize type name
    case "$item_type" in
        task) item_type="tasks" ;;
        epic) item_type="epics" ;;
        feature) item_type="features" ;;
        prd) item_type="prds" ;;
    esac
    
    echo "$index_data" | jq -r ".items.$item_type | to_entries[] | .value + {\"item_type\": \"$item_type\", \"id\": .key}"
}

# Get item count by type
doh_count_items_by_type() {
    local item_type="$1"
    local index_data
    
    index_data=$(doh_load_index) || return $?
    
    case "$item_type" in
        task) item_type="tasks" ;;
        epic) item_type="epics" ;;
        feature) item_type="features" ;;
        prd) item_type="prds" ;;
    esac
    
    echo "$index_data" | jq ".items.$item_type | length"
}

# ==============================================================================
# PROJECT STATISTICS FUNCTIONS
# ==============================================================================

# Get comprehensive project statistics
doh_get_project_stats() {
    local output_format="${1:-object}"
    local index_data session_data=""
    
    index_data=$(doh_load_index) || return $?
    
    # Load session data if available
    if doh_validate_json "$DOH_SESSION_FILE" "session file" 2>/dev/null; then
        session_data=$(cat "$DOH_SESSION_FILE")
    else
        session_data='{}'
    fi
    
    # Extract statistics using jq
    local stats
    stats=$(echo "$index_data" | jq -r --argjson session "$session_data" '
    {
        project: {
            name: (.metadata.project_name // "Unknown"),
            last_updated: (.metadata.updated_at // "Unknown"),
            next_id: (.counters.next_id // 0)
        },
        items: {
            tasks: (.items.tasks | length),
            epics: (.items.epics | length),
            features: (.items.features | length),
            prds: (.items.prds | length)
        },
        task_status: (
            [.items.tasks[]] | 
            group_by(.status) | 
            map({key: .[0].status, value: length}) | 
            from_entries
        ),
        session: {
            current_epic: ($session.current_epic // "None"),
            current_task: ($session.current_task // "None")
        }
    }')
    
    if [[ "$output_format" == "json" ]]; then
        echo "$stats"
    else
        # Convert to human-readable format
        echo "$stats" | jq -r '
        "DOH Project Statistics",
        "=====================",
        "",
        ("Project: " + .project.name),
        ("Last Updated: " + .project.last_updated),
        ("Next ID: " + (.project.next_id | tostring)),
        "",
        "Items Summary:",
        ("  Tasks: " + (.items.tasks | tostring)),
        ("  Epics: " + (.items.epics | tostring)),
        ("  Features: " + (.items.features | tostring)),
        ("  PRDs: " + (.items.prds | tostring)),
        "",
        "Task Status:",
        ((.task_status | to_entries[] | "  " + .key + ": " + (.value | tostring)) // empty),
        "",
        "Current Session:",
        ("  Epic: " + .session.current_epic),
        ("  Task: " + .session.current_task)
        '
    fi
}

# ==============================================================================
# DEPENDENCY FUNCTIONS
# ==============================================================================

# Get dependencies for an item
doh_get_item_dependencies() {
    local item_id="$1"
    local index_data
    
    index_data=$(doh_load_index) || return $?
    
    # Check all dependency relationship types
    echo "$index_data" | jq -r --arg item_id "$item_id" '
    [
        (.dependency_graph.epics_to_tasks[$item_id] // []),
        (.dependency_graph.features_to_tasks[$item_id] // []),
        (.dependency_graph.prds_to_epics[$item_id] // []),
        (.dependency_graph.epics_to_features[$item_id] // [])
    ] | flatten | .[]?'
}

# Find items that depend on the given item
doh_find_dependents() {
    local target_id="$1"
    local index_data
    
    index_data=$(doh_load_index) || return $?
    
    echo "$index_data" | jq -r --arg target_id "$target_id" '
    .dependency_graph | to_entries[] | 
    select(.value | type == "array" and contains([$target_id])) | 
    .key'
}

# ==============================================================================
# VALIDATION FUNCTIONS
# ==============================================================================

# Check if item exists
doh_item_exists() {
    local item_id="$1"
    doh_get_item "$item_id" >/dev/null 2>&1
}

# Validate DOH project structure
doh_validate_project_structure() {
    doh_log "Validating DOH project structure..."
    
    # Check index file
    doh_validate_index_structure || return $?
    doh_success "Index file is valid"
    
    # Check directory structure
    local required_dirs=(
        "$DOH_MEMORY_DIR"
        "$DOH_MEMORY_DIR/project"
        "$DOH_MEMORY_DIR/epics"
        "$DOH_MEMORY_DIR/agent-sessions"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            doh_error "Missing directory: $dir"
            return 5
        fi
    done
    
    doh_success "Directory structure is valid"
    return 0
}

# ==============================================================================
# EXPORT FUNCTIONS
# ==============================================================================

# Export all functions for use in other scripts
export -f doh_log doh_debug doh_error doh_success
export -f doh_timer_start doh_timer_end
export -f doh_check_initialized doh_validate_json doh_validate_index_structure
export -f doh_load_index doh_get_item doh_get_item_by_type
export -f doh_list_items_by_type doh_count_items_by_type
export -f doh_get_project_stats
export -f doh_get_item_dependencies doh_find_dependents
export -f doh_item_exists doh_validate_project_structure

# Export constants
export DOH_PROJECT_ROOT DOH_INDEX_FILE DOH_SESSION_FILE DOH_MEMORY_DIR

doh_debug "DOH Core Library loaded successfully"