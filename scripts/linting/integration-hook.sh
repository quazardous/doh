#!/bin/bash
# T103 - Integration Hook for Existing Linting Workflow
# Called from scripts/linting/lint-files.sh when manual interventions occur

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SMART_LINT="$SCRIPT_DIR/smart-lint.sh"

# Integration function to log intervention from existing linting tools
log_linting_intervention() {
    local file="$1"
    local tool="$2" 
    local rule="${3:-unknown}"
    local intervention_type="${4:-manual_fix}"
    
    # If this is a known pattern that requires learning
    case "$tool" in
        "markdownlint"|"prettier"|"codespell")
            echo "🧠 T103 - Learning opportunity detected for $tool/$rule"
            echo "   File: $file"
            echo "   Use: .cache/linting/data/smart-lint.sh fix \"$file\" \"$tool\" \"$rule\""
            echo "   This will enable intelligent automation learning."
            ;;
        *)
            # Unknown tool, still log for potential future learning
            echo "📝 T103 - Unknown tool intervention: $tool in $file"
            ;;
    esac
}

# Quick intervention logging for automated detection
quick_log_intervention() {
    local file="$1" tool="$2" rule="$3" pattern="$4" potential="${5:-medium}"
    local timestamp reason
    
    timestamp=$(date -Iseconds)
    reason="Automated detection from $tool"
    
    # Generate a basic intervention record
    "$SMART_LINT" log "$file" "$tool" "$rule" "detected_issue" "auto_corrected" \
        "automated_detection" "$pattern" "$potential" "$reason" 2>/dev/null || {
        echo "⚠️  T103 learning system not available"
    }
}

# Integration with existing lint workflow
integration_main() {
    local command="$1"
    shift
    
    case "$command" in
        "notify")
            # Called when manual intervention is needed
            log_linting_intervention "$@"
            ;;
        "log")
            # Quick logging for automated patterns
            quick_log_intervention "$@"
            ;;
        "check")
            # Check for learning opportunities
            "$SMART_LINT" stats
            ;;
        "proposals")
            # Check for plugin proposals
            "$SMART_LINT" check
            ;;
        *)
            cat << 'EOF'
T103 Integration Hook
===================

Usage: integration-hook.sh COMMAND [args]

Commands:
  notify FILE TOOL RULE TYPE     - Notify about manual intervention opportunity
  log FILE TOOL RULE PATTERN     - Quick log automated intervention
  check                          - Show learning statistics
  proposals                      - Check for plugin proposals

Integration Examples:

# From lint-files.sh when manual fix needed:
integration-hook.sh notify "docs/README.md" "markdownlint" "MD013" "line_length"

# From automated correction detection:  
integration-hook.sh log "docs/README.md" "markdownlint" "MD013" "long_line_detected"

# Regular learning checks:
integration-hook.sh check
integration-hook.sh proposals
EOF
            ;;
    esac
}

# Only run if called directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    integration_main "$@"
fi