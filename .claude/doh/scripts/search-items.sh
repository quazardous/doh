#!/bin/bash
# DOH Search Items - Fast bash-based search across DOH items
# Usage: search-items.sh "search_term" [item_type] [field] [output_format]

set -e

# Get script directory and load DOH library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/doh.sh"

# Usage function
usage() {
    cat << EOF
DOH Search Items - Fast search across DOH project items

Usage: $0 "search_term" [item_type] [field] [output_format]

Arguments:
  search_term    Text to search for (supports regex)
  item_type      Type to search: tasks|epics|features|prds|all (default: all)
  field          Field to search: title|description|all (default: all)
  output_format  Output format: json|text|summary|ids (default: text)

Examples:
  $0 "authentication"                    # Search all items for "authentication"
  $0 "bug" tasks title                   # Search task titles for "bug"
  $0 "user.*login" all all json          # Regex search, JSON output
  $0 "API" features description ids      # Search feature descriptions, return IDs

Performance: ~10-50x faster than Claude-based search
EOF
}

# Search items using bash/jq
doh_search_items_bash() {
    local search_term="$1"
    local item_type="${2:-all}"
    local field="${3:-all}"
    local output_format="${4:-text}"
    
    # Validate inputs
    if [[ -z "$search_term" ]]; then
        doh_error "Search term is required"
        return 1
    fi
    
    if [[ ! "$item_type" =~ ^(tasks|epics|features|prds|all)$ ]]; then
        doh_error "Invalid item type: $item_type"
        return 1
    fi
    
    if [[ ! "$field" =~ ^(title|description|all)$ ]]; then
        doh_error "Invalid field: $field"
        return 1
    fi
    
    if [[ ! "$output_format" =~ ^(json|text|summary|ids)$ ]]; then
        doh_error "Invalid output format: $output_format"
        return 1
    fi
    
    # Start timer
    doh_timer_start "search"
    
    # Load index
    local index_data
    if ! index_data=$(doh_load_index); then
        doh_error "Failed to load project index"
        return 1
    fi
    
    # Build jq filter based on parameters
    local types_filter
    if [[ "$item_type" == "all" ]]; then
        types_filter="tasks, epics, features, prds"
    else
        types_filter="$item_type"
    fi
    
    local field_filter
    case "$field" in
        title)
            field_filter='.title // "" | test($term; "i")'
            ;;
        description)
            field_filter='.description // "" | test($term; "i")'
            ;;
        all)
            field_filter='(.title // "" | test($term; "i")) or (.description // "" | test($term; "i")) or (.status // "" | test($term; "i"))'
            ;;
    esac
    
    # Execute search using jq
    local results
    results=$(echo "$index_data" | jq -r --arg term "$search_term" --arg types "$types_filter" "
        [
            (.items | to_entries[] | select(.key as \$type | (\$types | split(\", \") | index(\$type))) | 
                .value | to_entries[] | 
                select(.value | $field_filter) |
                .value + {\"item_type\": (.key), \"id\": (.key)}
            )
        ]
    ")
    
    # Count results
    local result_count
    result_count=$(echo "$results" | jq 'length')
    
    if [[ "$result_count" -eq 0 ]]; then
        echo "No items found matching '$search_term'"
        return 0
    fi
    
    # Format output
    case "$output_format" in
        json)
            echo "$results" | jq '.'
            ;;
        text)
            echo "Found $result_count items matching '$search_term':"
            echo ""
            echo "$results" | jq -r '.[] | "[\(.item_type | ascii_upcase)] !\(.id) - \(.title) (\(.status))"'
            ;;
        summary)
            echo "Search Results: $result_count items"
            echo "$results" | jq -r '.[] | "!\(.id): \(.title)"'
            ;;
        ids)
            echo "$results" | jq -r '.[] | "!\(.id)"'
            ;;
    esac
    
    # End timer
    local duration
    duration=$(doh_timer_end "search")
    
    if doh_config_performance_tracking; then
        doh_debug "search-items.sh completed in ${duration}ms (bash)"
    fi
}

# Main execution
main() {
    # Check initialization
    if ! doh_check_initialized; then
        doh_error "DOH not initialized. Run doh-init.sh first."
        exit 1
    fi
    
    # Parse arguments
    if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        usage
        exit 0
    fi
    
    local search_term="$1"
    local item_type="${2:-all}"
    local field="${3:-all}"
    local output_format="${4:-text}"
    
    # Execute search with fallback
    if doh_config_bash_optimization; then
        if doh_search_items_bash "$search_term" "$item_type" "$field" "$output_format"; then
            exit 0
        else
            doh_debug "Bash search failed, checking fallback..."
        fi
    fi
    
    # Fallback to Claude if enabled (placeholder)
    if doh_config_fallback_enabled; then
        doh_debug "Falling back to Claude for search operation"
        doh_fallback_to_claude "search" "$@"
    else
        doh_error "Search failed and fallback is disabled"
        exit 1
    fi
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi