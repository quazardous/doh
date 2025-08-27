#!/bin/bash
# DOH Update Status Script - High frequency bash optimization
# Usage: update-status.sh <item_id> <new_status> [item_type]
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
    echo "Usage: $0 <item_id> <new_status> [item_type]"
    echo ""
    echo "Arguments:"
    echo "  item_id     ID of the item to update (required)"
    echo "  new_status  New status value (pending|active|completed|blocked)"
    echo "  item_type   Specific type (task|epic|feature|prd) - auto-detect if omitted"
    echo ""
    echo "Examples:"
    echo "  $0 2 completed        # Mark task #2 as completed"
    echo "  $0 1 active epic      # Mark epic #1 as active" 
    echo "  $0 3 blocked task     # Mark task #3 as blocked"
    echo ""
    echo "Exit codes:"
    echo "  0 - Success"
    echo "  1 - DOH project not initialized"
    echo "  2 - Item not found" 
    echo "  3 - Invalid arguments"
    echo "  4 - Update failed"
}

update_status_bash() {
    local item_id="$1"
    local new_status="$2"
    local item_type="${3:-auto}"
    
    # Performance tracking
    if [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]]; then
        doh_timer_start
    fi
    
    # Validate DOH project
    if ! doh_check_initialized; then
        doh_error "DOH project not initialized"
        return 1
    fi
    
    # Find item and determine type if auto-detect
    local item_json item_found_type
    if [[ "$item_type" == "auto" ]]; then
        # Auto-detect item type by searching all types
        for check_type in tasks epics features prds; do
            if item_json=$(echo "$(doh_load_index)" | jq -r ".items.$check_type[\"$item_id\"] // empty" 2>/dev/null); then
                if [[ -n "$item_json" && "$item_json" != "null" && "$item_json" != "empty" ]]; then
                    item_found_type="$check_type"
                    break
                fi
            fi
        done
        
        if [[ -z "${item_found_type:-}" ]]; then
            doh_error "Item with ID '$item_id' not found in any category"
            return 2
        fi
    else
        # Use specified type
        case "$item_type" in
            task) item_found_type="tasks" ;;
            epic) item_found_type="epics" ;;
            feature) item_found_type="features" ;;
            prd) item_found_type="prds" ;;
            *) 
                doh_error "Invalid item type: '$item_type'"
                return 3
                ;;
        esac
        
        # Verify item exists in specified type
        item_json=$(echo "$(doh_load_index)" | jq -r ".items.$item_found_type[\"$item_id\"] // empty" 2>/dev/null)
        if [[ -z "$item_json" || "$item_json" == "null" || "$item_json" == "empty" ]]; then
            doh_error "Item '$item_id' not found in category '$item_found_type'"
            return 2
        fi
    fi
    
    doh_debug "Found item $item_id in category $item_found_type"
    
    # Create backup if configured
    if [[ "$(doh_config_bool 'scripting' 'backup_before_changes' 'false')" == "true" ]]; then
        local backup_file="$DOH_INDEX_FILE.backup.$(date +%s)"
        if ! cp "$DOH_INDEX_FILE" "$backup_file"; then
            doh_error "Failed to create backup"
            return 4
        fi
        doh_debug "Backup created: $backup_file"
    fi
    
    # Update status using jq
    local temp_file
    temp_file=$(mktemp)
    
    if ! jq ".items.$item_found_type[\"$item_id\"].status = \"$new_status\" | .metadata.updated_at = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" "$DOH_INDEX_FILE" > "$temp_file"; then
        doh_error "Failed to update item status with jq"
        rm -f "$temp_file"
        return 4
    fi
    
    # Validate updated JSON
    if ! jq empty "$temp_file" 2>/dev/null; then
        doh_error "Generated invalid JSON during update"
        rm -f "$temp_file"
        return 4
    fi
    
    # Replace original file
    if ! mv "$temp_file" "$DOH_INDEX_FILE"; then
        doh_error "Failed to update index file"
        rm -f "$temp_file"
        return 4
    fi
    
    # Success reporting
    doh_success "Updated ${item_found_type%s} #$item_id status: $new_status"
    
    # Performance reporting
    if [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]]; then
        local duration=$(doh_timer_end)
        doh_debug "update-status.sh completed in ${duration}ms (bash)"
    fi
    
    return 0
}

claude_fallback() {
    local item_id="$1"
    local new_status="$2" 
    local item_type="${3:-auto}"
    
    doh_debug "Falling back to Claude for update-status operation"
    
    # This would call the original Claude command
    # For now, return error to indicate fallback needed
    doh_error "Claude fallback not implemented yet - item '$item_id' status '$new_status'"
    return 5
}

# ==============================================================================
# MAIN SCRIPT LOGIC
# ==============================================================================

main() {
    local item_id="${1:-}"
    local new_status="${2:-}"
    local item_type="${3:-auto}"
    
    # Validate required arguments
    if [[ -z "$item_id" ]]; then
        doh_error "Missing required argument: item_id"
        show_usage
        return 3
    fi
    
    if [[ -z "$new_status" ]]; then
        doh_error "Missing required argument: new_status"
        show_usage
        return 3
    fi
    
    # Validate item ID format (should be numeric)
    if [[ ! "$item_id" =~ ^[0-9]+$ ]]; then
        doh_error "Invalid item ID format: '$item_id' (should be numeric)"
        return 3
    fi
    
    # Validate status value
    if [[ ! "$new_status" =~ ^(pending|active|completed|blocked)$ ]]; then
        doh_error "Invalid status: '$new_status' (must be: pending|active|completed|blocked)"
        return 3
    fi
    
    # Validate item type if specified
    if [[ "$item_type" != "auto" && ! "$item_type" =~ ^(task|epic|feature|prd)$ ]]; then
        doh_error "Invalid item type: '$item_type'"
        show_usage
        return 3
    fi
    
    # Try bash implementation first (if bash optimization enabled)
    if [[ "$DOH_BASH_OPTIMIZATION" == "1" ]]; then
        if update_status_bash "$item_id" "$new_status" "$item_type"; then
            return 0
        elif [[ "$DOH_FALLBACK_ENABLED" == "1" ]]; then
            claude_fallback "$item_id" "$new_status" "$item_type"
            return $?
        else
            return $?
        fi
    else
        # Direct Claude fallback if bash optimization disabled
        claude_fallback "$item_id" "$new_status" "$item_type"
        return $?
    fi
}

# Execute main function if script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi