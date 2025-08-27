#!/bin/bash
# DOH Library - Complete DOH functionality in one file
# Source this file to access all DOH functions

# Prevent double-sourcing
[[ "${DOH_LOADED:-}" == "1" ]] && return 0
readonly DOH_LOADED=1

# ==============================================================================
# FUNCTION NAMING CONVENTION
# ==============================================================================
# 
# All public functions MUST be prefixed with 'doh_'
# - doh_config_get()    - Get configuration value  
# - doh_find_root()     - Find project root
# - doh_validate_path() - Validate project path
# 
# Private/internal functions use '_doh_' prefix:
# - _doh_debug()        - Internal debug function
# - _doh_load_config()  - Internal config loading
#
# This ensures:
# 1. Clear public API surface
# 2. No conflicts with other bash libraries 
# 3. Easy identification of DOH functions

# ==============================================================================
# CORE CONFIGURATION
# ==============================================================================

# T018: Comprehensive Project Path Resolution Strategy  
# Handles symlinks, encrypted filesystems, bind mounts with UUID validation
# This is the main PUBLIC function for finding project root
doh_find_project_root() {
    local debug_mode="${DOH_PATH_DEBUG:-0}"
    
    [[ "$debug_mode" == "1" ]] && echo "🐛 DOH Path Resolution Debug Mode" >&2
    
    # 1. PRIORITY: AI Assistant Working Directory (preserve user's choice)
    local claude_cwd="$PWD"  
    if doh_validate_project_path "$claude_cwd"; then
        [[ "$debug_mode" == "1" ]] && echo "🐛 Found via AI CWD: $claude_cwd" >&2
        echo "$(cd "$claude_cwd" && pwd -P)"
        return 0
    fi
    
    # 2. PRIORITY: Explicit PROJECT_ROOT environment variable
    if [[ -n "${PROJECT_ROOT:-}" ]]; then
        if doh_validate_project_path "$PROJECT_ROOT"; then
            [[ "$debug_mode" == "1" ]] && echo "🐛 Found via PROJECT_ROOT: $PROJECT_ROOT" >&2
            echo "$(cd "$PROJECT_ROOT" && pwd -P)"
            return 0
        fi
    fi
    
    # 3. PRIORITY: Configuration preferred path (if accessible)
    local config_preferred_path
    if config_preferred_path=$(_doh_get_preferred_path_from_any_config 2>/dev/null); then
        if [[ -n "$config_preferred_path" ]] && doh_validate_project_path "$config_preferred_path"; then
            [[ "$debug_mode" == "1" ]] && echo "🐛 Found via config preferred_path: $config_preferred_path" >&2
            echo "$(cd "$config_preferred_path" && pwd -P)"
            return 0
        fi
    fi
    
    # 4. PRIORITY: Standard .doh detection with parent traversal
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if doh_validate_project_path "$dir"; then
            [[ "$debug_mode" == "1" ]] && echo "🐛 Found via .doh detection: $dir" >&2
            echo "$(cd "$dir" && pwd -P)"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    
    # 5. PRIORITY: Path equivalency detection (symlinks, .private, mounts)
    local equivalent_path
    if equivalent_path=$(_doh_find_path_equivalents "$claude_cwd"); then
        if doh_validate_project_path "$equivalent_path"; then
            [[ "$debug_mode" == "1" ]] && echo "🐛 Found via path equivalency: $equivalent_path" >&2
            echo "$(cd "$equivalent_path" && pwd -P)"
            return 0
        fi
    fi
    
    # 6. PRIORITY: Discovered paths cache lookup
    local discovered_path
    if discovered_path=$(_doh_check_discovered_paths_cache "$claude_cwd"); then
        if doh_validate_project_path "$discovered_path"; then
            [[ "$debug_mode" == "1" ]] && echo "🐛 Found via discovered paths cache: $discovered_path" >&2
            echo "$(cd "$discovered_path" && pwd -P)"
            return 0
        fi
    fi
    
    # 7. FALLBACK: Return current directory (may not be a DOH project)
    [[ "$debug_mode" == "1" ]] && echo "🐛 Using fallback: $claude_cwd (no .doh found)" >&2
    echo "$(cd "$claude_cwd" && pwd -P)"
}

# PUBLIC: Validate that a path contains a valid DOH project with UUID checking  
doh_validate_project_path() {
    local path="$1"
    local require_uuid="${2:-true}"
    
    # Check basic requirements
    [[ -d "$path/.doh" ]] || return 1
    [[ -f "$path/.doh/project-index.json" ]] || return 1
    
    # UUID validation (optional, for compatibility with legacy projects)
    if [[ "$require_uuid" == "true" && -f "$path/.doh/uuid" ]]; then
        local uuid
        uuid=$(cat "$path/.doh/uuid" 2>/dev/null)
        # Basic UUID format validation (8-4-4-4-12 or similar)
        [[ "$uuid" =~ ^[0-9a-fA-F-]{32,}$ ]] || return 2
    fi
    
    return 0
}

# PUBLIC: Get project UUID for identity validation
doh_get_project_uuid() {
    local path="${1:-$DOH_PROJECT_ROOT}"
    
    if [[ -f "$path/.doh/uuid" ]]; then
        cat "$path/.doh/uuid"
        return 0
    fi
    
    return 1
}

# Get preferred path from any accessible config file (search multiple locations)
_doh_get_preferred_path_from_any_config() {
    local possible_configs=(
        "$PWD/.doh/config.ini"
        "${PROJECT_ROOT:-}/.doh/config.ini"
    )
    
    # Try to find any accessible config file
    local config_file
    for config_file in "${possible_configs[@]}"; do
        if [[ -f "$config_file" ]]; then
            # Temporarily set DOH_CONFIG_FILE for doh_config_path
            local old_config="${DOH_CONFIG_FILE:-}"
            DOH_CONFIG_FILE="$config_file"
            local preferred_path
            preferred_path=$(doh_config_path "project" "preferred_path" "")
            DOH_CONFIG_FILE="$old_config"
            
            if [[ -n "$preferred_path" ]]; then
                echo "$preferred_path"
                return 0
            fi
        fi
    done
    
    return 1
}

# Find path equivalents using common patterns
_doh_find_path_equivalents() {
    local original_path="$1"
    
    # Common equivalency patterns
    local equivalent_paths=()
    
    # Pattern 1: /home/user/path <-> /home/user/Private/path (.private encryption)
    if [[ "$original_path" == /home/*/Private/* ]]; then
        equivalent_paths+=("${original_path/\/Private\//\/}")
    elif [[ "$original_path" == /home/*/* ]] && [[ "$original_path" != /home/*/Private/* ]]; then
        local user_part="${original_path#/home/}"
        local user="${user_part%%/*}"
        local rest="${user_part#*/}"
        equivalent_paths+=("/home/$user/Private/$rest")
    fi
    
    # Pattern 2: Symlink resolution
    if [[ -L "$original_path" ]]; then
        equivalent_paths+=("$(readlink -f "$original_path")")
    fi
    
    # Pattern 3: Common dev paths
    equivalent_paths+=(
        "${original_path/\/dev\/projects\//\/Private\/dev\/projects\/}"
        "${original_path/\/Private\/dev\/projects\//\/dev\/projects\/}"
    )
    
    # Test each equivalent path
    local equiv_path
    for equiv_path in "${equivalent_paths[@]}"; do
        if [[ -d "$equiv_path/.doh" ]]; then
            echo "$equiv_path"
            return 0
        fi
    done
    
    return 1
}

# Check discovered paths cache for known equivalents
_doh_check_discovered_paths_cache() {
    local search_path="$1"
    
    # Search through common config locations for discovered_paths
    local possible_configs=(
        "$search_path/.doh/config.ini"
        "${PROJECT_ROOT:-}/.doh/config.ini"
        "$PWD/.doh/config.ini"
    )
    
    local config_file
    for config_file in "${possible_configs[@]}"; do
        if [[ -f "$config_file" ]]; then
            # Temporarily set DOH_CONFIG_FILE and check discovered_paths
            local old_config="${DOH_CONFIG_FILE:-}"
            DOH_CONFIG_FILE="$config_file"
            
            # Get discovered paths as array
            local discovered_paths=()
            while IFS= read -r path; do
                discovered_paths+=("$path")
            done < <(doh_config_list "project" "discovered_paths")
            
            DOH_CONFIG_FILE="$old_config"
            
            # Check each discovered path
            local disc_path
            for disc_path in "${discovered_paths[@]}"; do
                if [[ -d "$disc_path/.doh" ]]; then
                    # Validate UUID matches if both have UUIDs
                    if doh_validate_uuid_match "$search_path" "$disc_path"; then
                        echo "$disc_path"
                        return 0
                    fi
                fi
            done
        fi
    done
    
    return 1
}

# PUBLIC: Auto-discovery mechanism - learns new equivalent paths
doh_discover_equivalent_path() {
    local current_path="$1"
    local equivalent_path="$2"
    
    # Validate both paths
    doh_validate_project_path "$current_path" false || return 1
    doh_validate_project_path "$equivalent_path" false || return 2
    
    # Ensure they have matching UUIDs (same project)
    doh_validate_uuid_match "$current_path" "$equivalent_path" || return 3
    
    # Add to discovered_paths in current_path's config
    if [[ -f "$current_path/.doh/config.ini" ]]; then
        local old_config="${DOH_CONFIG_FILE:-}"
        DOH_CONFIG_FILE="$current_path/.doh/config.ini"
        
        # Add equivalent path to discovered_paths
        doh_config_add_to_list "project" "discovered_paths" "$equivalent_path"
        
        # Update last_discovered timestamp
        doh_config_set "project" "last_discovered" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        
        DOH_CONFIG_FILE="$old_config"
    fi
    
    return 0
}

# Validate that two paths have matching UUIDs (same project identity)
doh_validate_uuid_match() {
    local path1="$1"
    local path2="$2"
    
    # If either doesn't have UUID, consider it a match (legacy compatibility)
    local uuid1 uuid2
    uuid1=$(doh_get_project_uuid "$path1" 2>/dev/null) || return 0
    uuid2=$(doh_get_project_uuid "$path2" 2>/dev/null) || return 0
    
    # Both have UUIDs - they must match
    [[ "$uuid1" == "$uuid2" ]]
}

# Project paths - Use the public API
readonly DOH_PROJECT_ROOT="$(doh_find_project_root)"
readonly DOH_INDEX_FILE="$DOH_PROJECT_ROOT/.doh/project-index.json"
readonly DOH_SESSION_FILE="$DOH_PROJECT_ROOT/.doh/memory/active-session.json"
readonly DOH_MEMORY_DIR="$DOH_PROJECT_ROOT/.doh/memory"
readonly DOH_CONFIG_FILE="$DOH_PROJECT_ROOT/.doh/config.ini"

# ==============================================================================
# CONFIGURATION PARSING (INI FORMAT)
# ==============================================================================

# Simple debug function
_doh_debug() {
    [[ "${DOH_DEBUG:-0}" == "1" ]] && echo "🐛 DOH: $*" >&2
}

# Parse INI value with awk
doh_config_get() {
    local section="$1"
    local key="$2"
    local default_value="${3:-}"
    local config_file="${DOH_CONFIG_FILE}"
    
    # Check if config file exists
    if [[ ! -f "$config_file" ]]; then
        _doh_debug "Config file not found: $config_file"
        echo "$default_value"
        return 1
    fi
    
    # Parse INI with awk (fast and reliable)
    local value
    value=$(awk -F= -v section="[$section]" -v key="$key" '
    BEGIN { in_section = 0 }
    
    # Skip comments and empty lines
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    
    # Section headers
    /^\[.*\]$/ {
        if ($0 == section) {
            in_section = 1
        } else {
            in_section = 0
        }
        next
    }
    
    # Key-value pairs in the right section
    in_section && /=/ {
        # Clean up key (remove spaces)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
        if ($1 == key) {
            # Clean up value (remove leading/trailing spaces)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
            print $2
            exit
        }
    }' "$config_file")
    
    # Return value or default
    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default_value"
        return 2
    fi
}

# Get boolean config with conversion
doh_config_bool() {
    local section="$1"
    local key="$2"
    local default="${3:-false}"
    
    local raw_value
    raw_value=$(doh_config_get "$section" "$key" "$default")
    
    case "${raw_value,,}" in  # Convert to lowercase
        true|yes|1|on) echo "true" ;;
        false|no|0|off|"") echo "false" ;;
        *) echo "$default" ;;
    esac
}

# Get list config (comma-separated values) as array
doh_config_list() {
    local section="$1"
    local key="$2"
    local default_list="${3:-}"
    
    local raw_value
    raw_value=$(doh_config_get "$section" "$key" "$default_list")
    
    # Return empty if no value
    [[ -z "$raw_value" ]] && return
    
    # Split by comma and clean up whitespace
    local IFS=','
    local item
    for item in $raw_value; do
        # Remove leading/trailing whitespace
        item=$(echo "$item" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [[ -n "$item" ]] && echo "$item"
    done
}

# Get integer config with validation
doh_config_int() {
    local section="$1"
    local key="$2"
    local default="${3:-0}"
    local min="${4:-}"
    local max="${5:-}"
    
    local raw_value
    raw_value=$(doh_config_get "$section" "$key" "$default")
    
    # Check if it's a valid integer
    if ! [[ "$raw_value" =~ ^-?[0-9]+$ ]]; then
        echo "$default"
        return 1
    fi
    
    # Check bounds if specified
    if [[ -n "$min" && "$raw_value" -lt "$min" ]]; then
        echo "$min"
        return 2
    fi
    
    if [[ -n "$max" && "$raw_value" -gt "$max" ]]; then
        echo "$max"
        return 2
    fi
    
    echo "$raw_value"
}

# Get path config with validation and expansion
doh_config_path() {
    local section="$1"
    local key="$2"
    local default="${3:-}"
    local must_exist="${4:-false}"
    
    local raw_value
    raw_value=$(doh_config_get "$section" "$key" "$default")
    
    # Return empty/default if no value
    [[ -z "$raw_value" ]] && { echo "$default"; return; }
    
    # Expand ~ and environment variables
    eval "raw_value=\"$raw_value\""
    
    # Convert to absolute path if relative
    if [[ "$raw_value" != /* ]]; then
        raw_value="$DOH_PROJECT_ROOT/$raw_value"
    fi
    
    # Canonicalize path
    if [[ -e "$raw_value" ]]; then
        raw_value="$(cd "$raw_value" && pwd -P)"
    fi
    
    # Check existence if required
    if [[ "$must_exist" == "true" && ! -e "$raw_value" ]]; then
        echo "$default"
        return 1
    fi
    
    echo "$raw_value"
}

# Set config value in INI file
doh_config_set() {
    local section="$1"
    local key="$2"
    local value="$3"
    local config_file="${DOH_CONFIG_FILE}"
    
    # Create config file if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        _doh_debug "Config file not found, cannot set value: $config_file"
        return 1
    fi
    
    # Use awk to update the INI file in place
    awk -F= -v section="[$section]" -v key="$key" -v value="$value" '
    BEGIN { 
        in_section = 0
        found_key = 0
        section_found = 0
    }
    
    # Skip comments and empty lines, but preserve them
    /^[[:space:]]*#/ || /^[[:space:]]*$/ {
        print $0
        next
    }
    
    # Section headers
    /^\[.*\]$/ {
        # If we were in the target section and didnt find the key, add it
        if (in_section && !found_key) {
            print key " = " value
            found_key = 1
        }
        
        if ($0 == section) {
            in_section = 1
            section_found = 1
        } else {
            in_section = 0
        }
        print $0
        next
    }
    
    # Key-value pairs
    /=/ {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
        
        # Update the key if in right section
        if (in_section && $1 == key) {
            print key " = " value
            found_key = 1
        } else {
            print $0
        }
        next
    }
    
    # Other lines
    { print $0 }
    
    END {
        # Add section and key if not found
        if (!section_found) {
            print ""
            print section
            print key " = " value
        } else if (!found_key) {
            print key " = " value
        }
    }' "$config_file" > "$config_file.tmp" && mv "$config_file.tmp" "$config_file"
}

# Set list value in config (comma-separated)
doh_config_set_list() {
    local section="$1"
    local key="$2"
    shift 2
    local items=("$@")
    
    # Join array with commas
    local value
    local IFS=','
    value="${items[*]}"
    
    doh_config_set "$section" "$key" "$value"
}

# Add item to list config (if not already present)
doh_config_add_to_list() {
    local section="$1"
    local key="$2"
    local new_item="$3"
    
    # Get current list
    local current_items=()
    while IFS= read -r item; do
        current_items+=("$item")
    done < <(doh_config_list "$section" "$key")
    
    # Check if item already exists
    local item
    for item in "${current_items[@]}"; do
        [[ "$item" == "$new_item" ]] && return 0
    done
    
    # Add new item
    current_items+=("$new_item")
    doh_config_set_list "$section" "$key" "${current_items[@]}"
}

# Load script configuration from config.ini with env var fallback
_doh_load_script_config() {
    local config_file="$DOH_PROJECT_ROOT/.doh/config.ini"
    
    if [[ -f "$config_file" ]]; then
        # Load from config.ini with env var fallback
        DOH_DEBUG=$(doh_config_bool "scripting" "debug_mode" "${DOH_DEBUG:-0}")
        DOH_QUIET=$(doh_config_bool "scripting" "quiet_mode" "${DOH_QUIET:-0}")
        DOH_PERFORMANCE_TRACKING=$(doh_config_bool "scripting" "performance_tracking" "${DOH_PERFORMANCE_TRACKING:-0}")
        DOH_BASH_OPTIMIZATION=$(doh_config_bool "scripting" "enable_bash_optimization" "1")
        DOH_FALLBACK_ENABLED=$(doh_config_bool "scripting" "fallback_to_claude" "1")
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
# LOGGING FUNCTIONS
# ==============================================================================

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

# ==============================================================================
# PERFORMANCE TRACKING
# ==============================================================================

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
# CONFIGURATION HELPERS
# ==============================================================================

# Common configuration shortcuts
doh_config_is_debug() {
    doh_config_bool "scripting" "debug_mode" "false"
}

doh_config_is_quiet() {
    doh_config_bool "scripting" "quiet_mode" "false"
}

doh_config_bash_optimization() {
    doh_config_bool "scripting" "enable_bash_optimization" "true"
}

doh_config_fallback_enabled() {
    doh_config_bool "scripting" "fallback_to_claude" "true"
}

doh_config_performance_tracking() {
    doh_config_bool "scripting" "performance_tracking" "false"
}

# ==============================================================================
# EXPORT FUNCTIONS
# ==============================================================================

# Export all DOH functions
export -f doh_log doh_debug doh_error doh_success
export -f doh_timer_start doh_timer_end
export -f doh_check_initialized doh_validate_json doh_validate_index_structure
export -f doh_load_index doh_get_item doh_get_item_by_type
export -f doh_list_items_by_type doh_count_items_by_type
export -f doh_get_project_stats
export -f doh_get_item_dependencies doh_find_dependents
export -f doh_item_exists doh_validate_project_structure
export -f doh_config_get doh_config_bool
export -f doh_config_is_debug doh_config_is_quiet
export -f doh_config_bash_optimization doh_config_fallback_enabled
export -f doh_config_performance_tracking

# Export constants
export DOH_PROJECT_ROOT DOH_INDEX_FILE DOH_SESSION_FILE DOH_MEMORY_DIR DOH_CONFIG_FILE
export DOH_DEBUG DOH_QUIET DOH_PERFORMANCE_TRACKING DOH_BASH_OPTIMIZATION DOH_FALLBACK_ENABLED

doh_debug "DOH Library loaded successfully"