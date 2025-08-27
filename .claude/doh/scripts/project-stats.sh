#!/bin/bash
# DOH Utility - Project Statistics
# Usage: project-stats.sh [--json|--dashboard]
# CWD Independent: Works from any directory

set -euo pipefail

# ==============================================================================
# ROBUST PATH RESOLUTION
# ==============================================================================

# Get absolute script directory (CWD independent)
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LIB_DIR="$SCRIPT_DIR/lib"

# Detect project root robustly (same function as get-item.sh for consistency)
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
    
    # Fallback: assume current working directory
    echo "$PWD"
    return 1
}

# Set project root robustly
export PROJECT_ROOT
PROJECT_ROOT="$(detect_project_root)"

# Load DOH libraries with absolute paths
source "$LIB_DIR/doh-core.sh"
source "$LIB_DIR/doh-wrappers.sh"

# ==============================================================================
# INPUT VALIDATION
# ==============================================================================

readonly OUTPUT_FORMAT="${1:-human}"

case "$OUTPUT_FORMAT" in
    --json|json)
        OUTPUT_MODE="json"
        ;;
    --dashboard|dashboard)
        OUTPUT_MODE="dashboard"
        ;;
    --human|human|"")
        OUTPUT_MODE="human"
        ;;
    --help|-h)
        cat <<EOF
DOH Project Statistics

Usage: $0 [format]

Formats:
  --human      Human-readable output (default)
  --json       JSON format output
  --dashboard  Enhanced dashboard view

Examples:
  $0                    # Human-readable stats
  $0 --json            # JSON output
  $0 --dashboard       # Full dashboard

This script works from any directory within a DOH project.
EOF
        exit 0
        ;;
    *)
        echo "Error: Unknown format '$OUTPUT_FORMAT'" >&2
        echo "Use --help for usage information" >&2
        exit 1
        ;;
esac

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================

main() {
    local start_time
    [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]] && start_time=$(date +%s%N)
    
    # Validate project initialization
    if ! doh_check_initialized; then
        doh_error "DOH not initialized in: $PROJECT_ROOT"
        doh_log "Run 'doh:init' to initialize DOH in this project"
        exit 2
    fi
    
    # Generate output based on format
    local result
    case "$OUTPUT_MODE" in
        json)
            result=$(doh_safe_get_stats "json")
            ;;
        dashboard)
            result=$(doh_get_dashboard_data "human")
            ;;
        human)
            result=$(doh_safe_get_stats "human")
            ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        echo "$result"
        
        # Performance reporting
        if [[ "$DOH_PERFORMANCE_TRACKING" == "1" ]]; then
            local end_time duration
            end_time=$(date +%s%N)
            duration=$(( (end_time - start_time) / 1000000 ))
            doh_success "Statistics generated in ${duration}ms"
        fi
        
        exit 0
    else
        # Error handling
        local exit_code=$?
        case $exit_code in
            2|3)
                doh_error "Project data corruption detected"
                doh_log "Try running: validate-project.sh"
                ;;
            10)
                doh_log "Bash processing failed, Claude fallback recommended"
                ;;
            *)
                doh_error "Failed to generate statistics (code: $exit_code)"
                ;;
        esac
        exit $exit_code
    fi
}

# Execute with proper error handling
main "$@"