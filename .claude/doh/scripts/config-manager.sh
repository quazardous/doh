#!/bin/bash
# DOH Configuration Manager - INI Edition
# Usage: config-manager.sh <action> <section> <key> [value]
# CWD Independent: Works from any directory

set -euo pipefail

# ==============================================================================
# ROBUST PATH RESOLUTION  
# ==============================================================================

# Get absolute script directory (CWD independent)
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LIB_DIR="$SCRIPT_DIR/lib"

# Detect project root robustly
detect_project_root() {
    local current_dir="$PWD"
    
    # Try current directory and parents
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/.doh/project-index.json" ]]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done
    
    # If not found, check if PROJECT_ROOT env var is set
    if [[ -n "${PROJECT_ROOT:-}" && -f "$PROJECT_ROOT/.doh/project-index.json" ]]; then
        echo "$PROJECT_ROOT"
        return 0
    fi
    
    echo "$PWD"
    return 1
}

# Set project root robustly
export PROJECT_ROOT
PROJECT_ROOT="$(detect_project_root)"

# Load DOH libraries with absolute paths
source "$LIB_DIR/doh-core.sh"
source "$LIB_DIR/doh-config.sh"

# ==============================================================================
# CONFIGURATION MANAGEMENT FUNCTIONS
# ==============================================================================

# Show help
show_help() {
    cat <<EOF
DOH Configuration Manager (INI Edition)

USAGE:
  $0 get <section> <key>           Get configuration value
  $0 set <section> <key> <value>   Set configuration value  
  $0 list [section]                List configuration values
  $0 validate                      Validate configuration file
  $0 help                          Show this help

EXAMPLES:
  $0 get scripting debug_mode
  $0 set scripting debug_mode true
  $0 set project language fr
  $0 list scripting
  $0 list
  $0 validate

AVAILABLE SECTIONS:
  project       Project metadata and settings
  behavior      DOH system behavior preferences
  scripting     Script execution preferences
  templates     Template and generation preferences
  sync          External sync settings (GitHub/GitLab)
  development   Development and debugging settings
  paths         Custom directory paths within .doh/
  integrations  External tool integrations

VALUE TYPES:
  Boolean: true/false, yes/no, 1/0, on/off
  Integer: 0, 1, 42, etc.
  String:  any text (no quotes needed)
  Empty:   leave blank (will use defaults)

CONFIGURATION FILE:
  Location: .doh/config.ini
  Format:   Standard INI format with comments support
  
This script works from any directory within a DOH project.
EOF
}

# Get configuration value with nice formatting
config_get() {
    local section="$1"
    local key="$2"
    
    if ! doh_check_initialized; then
        doh_error "DOH not initialized in: $PROJECT_ROOT"
        exit 2
    fi
    
    local value
    value=$(doh_config_get "$section" "$key")
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]]; then
        echo "$value"
    elif [[ $exit_code -eq 1 ]]; then
        doh_error "Config file not found: $DOH_CONFIG_FILE"
        exit 3
    elif [[ $exit_code -eq 2 ]]; then
        doh_error "Configuration key not found: [$section] $key"
        exit 4
    fi
}

# Set configuration value
config_set() {
    local section="$1"
    local key="$2"
    local value="$3"
    
    if ! doh_check_initialized; then
        doh_error "DOH not initialized in: $PROJECT_ROOT"
        exit 2
    fi
    
    # Validate input
    if [[ -z "$section" || -z "$key" ]]; then
        doh_error "Section and key cannot be empty"
        exit 1
    fi
    
    # Set the value
    if doh_config_set "$section" "$key" "$value"; then
        doh_log "Configuration saved to: $DOH_CONFIG_FILE"
    else
        doh_error "Failed to set configuration"
        exit 5
    fi
}

# List configuration values
config_list() {
    local section="${1:-}"
    
    if ! doh_check_initialized; then
        doh_error "DOH not initialized in: $PROJECT_ROOT"
        exit 2
    fi
    
    if ! doh_config_validate; then
        exit 3
    fi
    
    if [[ -n "$section" ]]; then
        # List specific section
        echo "Configuration for [$section]:"
        echo "=========================="
        doh_config_list_section "$section" | while IFS= read -r line; do
            echo "  $line"
        done
    else
        # List all sections
        echo "DOH Configuration Summary:"
        echo "========================="
        echo ""
        
        # List all sections found in config file
        local sections
        sections=$(awk '/^\[.*\]$/ { gsub(/\[|\]/, ""); print }' "$DOH_CONFIG_FILE" 2>/dev/null | sort -u)
        
        for section_name in $sections; do
            echo "[$section_name]"
            doh_config_list_section "$section_name" | while IFS= read -r line; do
                echo "  $line"
            done
            echo ""
        done
    fi
}

# Validate configuration
config_validate() {
    if ! doh_check_initialized; then
        doh_error "DOH not initialized in: $PROJECT_ROOT"
        exit 2
    fi
    
    doh_log "Validating configuration..."
    
    if doh_config_validate; then
        doh_success "Configuration file is valid"
        
        # Show config file info
        if [[ -f "$DOH_CONFIG_FILE" ]]; then
            local line_count section_count key_count
            line_count=$(wc -l < "$DOH_CONFIG_FILE")
            section_count=$(grep -c '^\[.*\]$' "$DOH_CONFIG_FILE" 2>/dev/null || echo "0")
            key_count=$(grep -c '^[^#\[].*=' "$DOH_CONFIG_FILE" 2>/dev/null || echo "0")
            
            doh_log "Config file: $DOH_CONFIG_FILE"
            doh_log "Lines: $line_count | Sections: $section_count | Keys: $key_count"
        fi
    else
        doh_error "Configuration validation failed"
        exit 3
    fi
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

main() {
    local action="${1:-help}"
    
    case "$action" in
        get)
            if [[ $# -lt 3 ]]; then
                doh_error "Usage: $0 get <section> <key>"
                exit 1
            fi
            config_get "$2" "$3"
            ;;
        set)
            if [[ $# -lt 4 ]]; then
                doh_error "Usage: $0 set <section> <key> <value>"
                exit 1
            fi
            config_set "$2" "$3" "$4"
            ;;
        list)
            config_list "${2:-}"
            ;;
        validate)
            config_validate
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            doh_error "Unknown action: $action"
            show_help
            exit 1
            ;;
    esac
}

# Execute with proper error handling
main "$@"