#!/bin/bash
# DOH Configuration Library - INI file parsing and management
# Source this file to access configuration functions

# Prevent double-sourcing
[[ "${DOH_CONFIG_LOADED:-}" == "1" ]] && return 0
readonly DOH_CONFIG_LOADED=1

# Note: We don't load doh-core.sh here to avoid circular dependency
# doh-core.sh will source this file when needed

# ==============================================================================
# CONFIGURATION CONSTANTS
# ==============================================================================

# Set PROJECT_ROOT if not already set
readonly DOH_PROJECT_ROOT="${PROJECT_ROOT:-$(pwd)}"
readonly DOH_CONFIG_FILE="$DOH_PROJECT_ROOT/.doh/config.ini"

# Simple debug function (standalone to avoid circular dependencies)
_doh_config_debug() {
    [[ "${DOH_DEBUG:-0}" == "1" ]] && echo "🐛 CONFIG: $*" >&2
}

# ==============================================================================
# INI PARSING FUNCTIONS
# ==============================================================================

# Parse INI value with natural bash approach
# Usage: doh_config_get "section" "key" [default_value]
doh_config_get() {
    local section="$1"
    local key="$2"
    local default_value="${3:-}"
    local config_file="${DOH_CONFIG_FILE}"
    
    # Check if config file exists
    if [[ ! -f "$config_file" ]]; then
        _doh_config_debug "Config file not found: $config_file"
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

# Set INI value (create/update)
# Usage: doh_config_set "section" "key" "value"
doh_config_set() {
    local section="$1"
    local key="$2" 
    local value="$3"
    local config_file="${DOH_CONFIG_FILE}"
    
    # Create config file if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        echo "🔧 CONFIG: Creating new config file: $config_file" >&2
        touch "$config_file"
    fi
    
    # Create backup if enabled
    local backup_enabled
    backup_enabled=$(doh_config_get "behavior" "backup_before_changes" "true")
    
    if [[ "$backup_enabled" == "true" ]]; then
        local backup_file="$config_file.backup.$(date +%s)"
        cp "$config_file" "$backup_file" 2>/dev/null || true
        doh_debug "Config backup created: $backup_file"
    fi
    
    # Use awk to update the INI file
    local temp_file
    temp_file=$(mktemp)
    
    awk -F= -v section="[$section]" -v key="$key" -v value="$value" '
    BEGIN { 
        in_section = 0
        key_found = 0
        section_found = 0
    }
    
    # Skip empty lines but preserve them
    /^[[:space:]]*$/ { print; next }
    
    # Preserve comments
    /^[[:space:]]*#/ { print; next }
    
    # Section headers
    /^\[.*\]$/ {
        # If we were in the target section and didnt find the key, add it
        if (in_section && !key_found) {
            print key " = " value
            key_found = 1
        }
        
        if ($0 == section) {
            in_section = 1
            section_found = 1
        } else {
            in_section = 0
        }
        print
        next
    }
    
    # Key-value pairs
    in_section && /=/ {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
        if ($1 == key) {
            print key " = " value
            key_found = 1
        } else {
            print
        }
        next
    }
    
    # Other lines
    { print }
    
    END {
        # If section was found but key wasnt, it was added above
        # If section wasnt found, add both section and key
        if (!section_found) {
            print ""
            print section
            print key " = " value
        } else if (!key_found && in_section) {
            # Key not found but we were in section at end of file
            print key " = " value
        }
    }' "$config_file" > "$temp_file"
    
    # Replace original file
    if mv "$temp_file" "$config_file"; then
        doh_success "Configuration updated: [$section] $key = $value"
        return 0
    else
        doh_error "Failed to update configuration"
        rm -f "$temp_file"
        return 1
    fi
}

# Get configuration value with type conversion
# Usage: doh_config_get_typed "section" "key" "type" [default]
doh_config_get_typed() {
    local section="$1"
    local key="$2"
    local type="$3"
    local default_value="${4:-}"
    
    local raw_value
    raw_value=$(doh_config_get "$section" "$key" "$default_value")
    
    case "$type" in
        bool|boolean)
            case "${raw_value,,}" in  # Convert to lowercase
                true|yes|1|on) echo "true" ;;
                false|no|0|off|"") echo "false" ;;
                *) echo "$default_value" ;;
            esac
            ;;
        int|integer)
            if [[ "$raw_value" =~ ^[0-9]+$ ]]; then
                echo "$raw_value"
            else
                echo "$default_value"
            fi
            ;;
        string|*)
            echo "$raw_value"
            ;;
    esac
}

# List all configuration in a section
# Usage: doh_config_list_section "section"
doh_config_list_section() {
    local section="$1"
    local config_file="${DOH_CONFIG_FILE}"
    
    if [[ ! -f "$config_file" ]]; then
        doh_error "Config file not found: $config_file"
        return 1
    fi
    
    awk -F= -v section="[$section]" '
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
    
    # Key-value pairs in target section
    in_section && /=/ {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
        print $1 " = " $2
    }' "$config_file"
}

# ==============================================================================
# CONFIGURATION HELPERS
# ==============================================================================

# Get boolean config with sensible defaults
doh_config_bool() {
    local section="$1"
    local key="$2"
    local default="${3:-false}"
    
    doh_config_get_typed "$section" "$key" "bool" "$default"
}

# Get integer config with sensible defaults
doh_config_int() {
    local section="$1" 
    local key="$2"
    local default="${3:-0}"
    
    doh_config_get_typed "$section" "$key" "int" "$default"
}

# Get string config with sensible defaults
doh_config_string() {
    local section="$1"
    local key="$2" 
    local default="${3:-}"
    
    doh_config_get_typed "$section" "$key" "string" "$default"
}

# Check if config file exists and is valid
doh_config_validate() {
    local config_file="${DOH_CONFIG_FILE}"
    
    if [[ ! -f "$config_file" ]]; then
        doh_log "Config file missing, using defaults: $config_file"
        return 1
    fi
    
    # Basic syntax check
    if ! awk '
    /^[[:space:]]*#/ { next }  # Skip comments
    /^[[:space:]]*$/ { next }  # Skip empty lines
    /^\[.*\]$/ { next }        # Skip section headers
    /^[^=]+=[^=]*$/ { next }   # Valid key=value
    { print "Invalid line: " NR ": " $0; exit 1 }
    ' "$config_file"; then
        doh_error "Configuration file has syntax errors"
        return 2
    fi
    
    doh_debug "Configuration file is valid"
    return 0
}

# ==============================================================================
# COMMON CONFIGURATION GETTERS
# ==============================================================================

# Commonly used configuration shortcuts
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

doh_config_epic_threshold() {
    doh_config_int "behavior" "epic_graduation_threshold" "6"
}

# ==============================================================================
# EXPORT FUNCTIONS
# ==============================================================================

# Export all configuration functions
export -f doh_config_get doh_config_set doh_config_get_typed
export -f doh_config_list_section doh_config_validate
export -f doh_config_bool doh_config_int doh_config_string
export -f doh_config_is_debug doh_config_is_quiet
export -f doh_config_bash_optimization doh_config_fallback_enabled
export -f doh_config_performance_tracking doh_config_epic_threshold

# Export constants
export DOH_CONFIG_FILE

doh_debug "DOH Configuration Library loaded successfully"