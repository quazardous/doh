#!/bin/bash
# DOH Get Item Script - High frequency bash optimization
# Usage: get-item.sh <item_id> [output_format]
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
    echo "Usage: $0 <item_id> [output_format]"
    echo ""
    echo "Arguments:"
    echo "  item_id       ID of the item to retrieve (required)"
    echo "  output_format json|text|summary (default: json)"
    echo ""
    echo "Examples:"
    echo "  $0 2              # Get item #2 as JSON"
    echo "  $0 2 text         # Get item #2 as human-readable text" 
    echo "  $0 2 summary      # Get item #2 summary"
    echo ""
    echo "Exit codes:"
    echo "  0 - Success"
    echo "  1 - Item not found"  
    echo "  2 - JSON parsing error"
    echo "  3 - Invalid arguments"
    echo "  4 - DOH project not initialized"
}

format_item_text() {
    local item_json="$1"
    
    echo "$item_json" | jq -r '
    "ID: " + .id,
    "Type: " + .item_type,
    "Title: " + .title,
    "Status: " + .status,
    "Path: " + .path,
    (if .parent_epic then "Parent Epic: " + .parent_epic else empty end),
    (if .created_at then "Created: " + .created_at else empty end),
    (if .updated_at then "Updated: " + .updated_at else empty end)
    '
}

format_item_summary() {
    local item_json="$1"
    
    echo "$item_json" | jq -r '
    .item_type + " #" + .id + ": " + .title + " [" + .status + "]"
    '
}

get_item_bash() {
    local item_id="$1"
    local output_format="${2:-json}"
    
    # Performance tracking
    if [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]]; then
        doh_timer_start
    fi
    
    # Validate DOH project
    if ! doh_check_initialized; then
        doh_error "DOH project not initialized"
        return 4
    fi
    
    # Get item using DOH library function
    local item_json
    if ! item_json=$(doh_get_item "$item_id" 2>/dev/null); then
        doh_error "Item with ID '$item_id' not found"
        return 1
    fi
    
    # Validate JSON
    if ! echo "$item_json" | jq empty 2>/dev/null; then
        doh_error "Invalid JSON returned for item '$item_id'"
        return 2
    fi
    
    # Format output
    case "$output_format" in
        json)
            echo "$item_json" | jq '.'
            ;;
        text)
            format_item_text "$item_json"
            ;;
        summary)
            format_item_summary "$item_json"
            ;;
        *)
            doh_error "Invalid output format: $output_format"
            return 3
            ;;
    esac
    
    # Performance reporting
    if [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]]; then
        local duration=$(doh_timer_end)
        doh_debug "get-item.sh completed in ${duration}ms (bash)"
    fi
    
    return 0
}

claude_fallback() {
    local item_id="$1"
    local output_format="${2:-json}"
    
    doh_debug "Falling back to Claude for get-item operation"
    
    # This would call the original Claude command
    # For now, return error to indicate fallback needed
    doh_error "Claude fallback not implemented yet - item '$item_id'"
    return 5
}

# ==============================================================================
# MAIN SCRIPT LOGIC
# ==============================================================================

main() {
    local item_id="${1:-}"
    local output_format="${2:-json}"
    
    # Validate arguments
    if [[ -z "$item_id" ]]; then
        doh_error "Missing required argument: item_id"
        show_usage
        return 3
    fi
    
    # Validate item ID format (should be numeric)
    if [[ ! "$item_id" =~ ^[0-9]+$ ]]; then
        doh_error "Invalid item ID format: '$item_id' (should be numeric)"
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
        if get_item_bash "$item_id" "$output_format"; then
            return 0
        elif [[ "$DOH_FALLBACK_ENABLED" == "1" ]]; then
            claude_fallback "$item_id" "$output_format"
            return $?
        else
            return $?
        fi
    else
        # Direct Claude fallback if bash optimization disabled
        claude_fallback "$item_id" "$output_format"
        return $?
    fi
}

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi