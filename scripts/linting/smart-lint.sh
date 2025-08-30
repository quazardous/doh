#!/bin/bash
# T103 - Intelligent Linting Feedback System
# Main integration script that learns from interventions and proposes automation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTERVENTIONS_FILE="$SCRIPT_DIR/manual-interventions.jsonl"
PROPOSALS_FILE="$SCRIPT_DIR/proposed-plugins.json"
REJECTED_FILE="$SCRIPT_DIR/rejected-plugins.json"

# Configuration
PROPOSAL_THRESHOLD=5           # Minimum occurrences to trigger proposal
CHECK_PROPOSALS_EVERY=10       # Check for proposals every N interventions
INTERVENTION_COUNTER_FILE="$SCRIPT_DIR/.intervention-counter"

log_intervention() {
    local file="$1" rule="$2" original="$3" fixed="$4" fix_type="$5" pattern="$6" automation_potential="$7" target_tool="$8" reason="$9"
    
    local timestamp
    timestamp=$(date -Iseconds)
    
    # Create intervention record
    local intervention_json
    intervention_json=$(jq -n \
        --arg timestamp "$timestamp" \
        --arg file "$file" \
        --arg rule "$rule" \
        --arg original "$original" \
        --arg fixed "$fixed" \
        --arg fix_type "$fix_type" \
        --arg pattern "$pattern" \
        --arg automation_potential "$automation_potential" \
        --arg target_tool "$target_tool" \
        --arg reason "$reason" \
        '{
            timestamp: $timestamp,
            file: $file,
            rule: $rule,
            original: $original,
            fixed: $fixed,
            fix_type: $fix_type,
            pattern: $pattern,
            automation_potential: $automation_potential,
            target_tool: $target_tool,
            reason: $reason
        }')
    
    # Append to JSONL file
    echo "$intervention_json" >> "$INTERVENTIONS_FILE"
    
    # Update intervention counter
    local counter=1
    if [[ -f "$INTERVENTION_COUNTER_FILE" ]]; then
        counter=$(cat "$INTERVENTION_COUNTER_FILE")
        counter=$((counter + 1))
    fi
    echo "$counter" > "$INTERVENTION_COUNTER_FILE"
    
    echo "🔍 T103 - Intervention logged (#$counter): $pattern"
    
    # Check if we should evaluate proposals
    if (( counter % CHECK_PROPOSALS_EVERY == 0 )); then
        echo "🎯 Checking for plugin proposal opportunities..."
        check_proposal_opportunities
    fi
}

check_proposal_opportunities() {
    echo ""
    echo "🤖 T103 - Evaluating Plugin Proposal Opportunities"
    echo "================================================"
    
    # Run proposal script in check mode
    "$SCRIPT_DIR/plugin-proposals.sh" check
}

interactive_fix_with_learning() {
    local file="$1" tool="$2" rule="$3" issue_description="$4"
    
    echo ""
    echo "🛠️  T103 - Interactive Fix with Learning"
    echo "========================================"
    echo "File: $file"
    echo "Tool: $tool"
    echo "Rule: $rule"
    echo "Issue: $issue_description"
    echo ""
    
    # Check if this pattern was previously rejected
    if is_pattern_rejected "$rule" "$tool"; then
        echo "⚠️  This pattern was previously rejected for automation."
        echo "   Proceeding with manual correction (as requested)."
        echo ""
    fi
    
    echo "Please provide:"
    echo "1. Original problematic text"
    echo "2. Fixed version"
    echo "3. Fix classification (brief description)"
    echo ""
    
    # Interactive input
    echo -n "Original text: "
    read -r original_text
    echo -n "Fixed text: "
    read -r fixed_text
    echo -n "Fix type: "
    read -r fix_type
    
    # Pattern classification
    echo ""
    echo "Pattern classification:"
    echo "1. high    - Highly automatable, clear rules"
    echo "2. medium  - Partially automatable, requires context"
    echo "3. low     - Manual review needed, complex decisions"
    echo -n "Automation potential [high/medium/low]: "
    read -r automation_potential
    
    echo -n "Reason for fix: "
    read -r reason
    
    # Generate pattern name from rule and fix type
    local pattern
    pattern=$(generate_pattern_name "$rule" "$fix_type" "$tool")
    
    # Log the intervention
    log_intervention "$file" "$rule" "$original_text" "$fixed_text" "$fix_type" "$pattern" "$automation_potential" "$tool" "$reason"
    
    echo "✅ Intervention logged and learned!"
}

generate_pattern_name() {
    local rule="$1" fix_type="$2" tool="$3"
    
    # Generate meaningful pattern names
    case "$tool" in
        "markdownlint")
            case "$rule" in
                "MD013") echo "long_line_${fix_type}";;
                "MD029") echo "list_numbering_${fix_type}";;
                "MD024") echo "duplicate_heading_${fix_type}";;
                *) echo "${rule,,}_${fix_type}";;
            esac
            ;;
        "prettier")
            echo "formatting_${fix_type}"
            ;;
        "codespell")
            echo "spelling_${fix_type}"
            ;;
        *)
            echo "${tool}_${fix_type}"
            ;;
    esac
}

is_pattern_rejected() {
    local rule="$1" tool="$2"
    
    if [[ ! -f "$REJECTED_FILE" ]]; then
        return 1  # No rejections file, pattern not rejected
    fi
    
    # Check if this rule/tool combination was rejected
    if jq -e --arg rule "$rule" --arg tool "$tool" '
        .rejected[]? | select(.rule == $rule and .tool == $tool)
    ' "$REJECTED_FILE" > /dev/null 2>&1; then
        return 0  # Pattern was rejected
    else
        return 1  # Pattern not rejected
    fi
}

approve_plugin() {
    local pattern="$1"
    echo "✅ T103 - Plugin Approved: $pattern"
    
    # Delegate to plugin-proposals script
    "$SCRIPT_DIR/plugin-proposals.sh" approve "$pattern"
    
    echo "🔄 Next: Plugin will be implemented in development cycle"
    echo "   Status can be checked with: .cache/linting/data/plugin-proposals.sh status"
}

reject_plugin() {
    local pattern="$1" reason="${2:-User declined automation}"
    
    echo "❌ T103 - Plugin Rejected: $pattern"
    echo "   Reason: $reason"
    
    # Delegate to plugin-proposals script
    "$SCRIPT_DIR/plugin-proposals.sh" reject "$pattern" "$reason"
    
    echo "📝 Rejection logged. AI will continue manual corrections for this pattern."
    echo "   Pattern will not be proposed again."
}

show_learning_stats() {
    echo "📊 T103 - Learning Statistics"
    echo "============================"
    
    if [[ ! -f "$INTERVENTIONS_FILE" ]]; then
        echo "⚠️  No learning data available yet."
        echo "   Interventions will be logged automatically during manual fixes."
        return 0
    fi
    
    local total_interventions
    total_interventions=$(wc -l < "$INTERVENTIONS_FILE")
    echo "📈 Total interventions logged: $total_interventions"
    
    # Show progress toward proposal thresholds
    echo ""
    echo "🎯 Progress toward plugin proposals:"
    "$SCRIPT_DIR/analyze-patterns.sh" analyze
    
    echo ""
    echo "💡 Current automation recommendations:"
    "$SCRIPT_DIR/analyze-patterns.sh" recommend
}

main() {
    case "${1:-help}" in
        "log")
            if [[ $# -lt 9 ]]; then
                echo "Usage: $0 log FILE TOOL RULE ORIGINAL FIXED FIX_TYPE PATTERN AUTOMATION_POTENTIAL REASON"
                exit 1
            fi
            log_intervention "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}"
            ;;
        "fix")
            if [[ $# -lt 4 ]]; then
                echo "Usage: $0 fix FILE TOOL RULE [DESCRIPTION]"
                exit 1
            fi
            interactive_fix_with_learning "$2" "$3" "$4" "${5:-Manual intervention needed}"
            ;;
        "check")
            check_proposal_opportunities
            ;;
        "approve")
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 approve PATTERN"
                exit 1
            fi
            approve_plugin "$2"
            ;;
        "reject")
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 reject PATTERN [REASON]"
                exit 1
            fi
            reject_plugin "$2" "${3:-}"
            ;;
        "stats"|"statistics")
            show_learning_stats
            ;;
        "reset")
            echo "🗑️  Resetting T103 learning data..."
            rm -f "$INTERVENTIONS_FILE" "$INTERVENTION_COUNTER_FILE"
            echo "✅ Learning data cleared. Fresh start enabled."
            ;;
        *)
            cat << 'EOF'
T103 - Intelligent Linting Feedback System
========================================

USAGE: smart-lint.sh COMMAND [args]

Learning Commands:
  fix FILE TOOL RULE [DESC]  - Interactive fix with learning
  log FILE TOOL RULE ORIG... - Direct intervention logging
  stats                      - Show learning statistics

Proposal Management:
  check                      - Check for plugin proposals
  approve PATTERN            - Approve a plugin proposal  
  reject PATTERN [REASON]    - Reject a plugin proposal

Maintenance:
  reset                      - Clear learning data (fresh start)

Examples:
  # Interactive fix with learning
  smart-lint.sh fix docs/README.md markdownlint MD013

  # Check for automation opportunities  
  smart-lint.sh check

  # Approve a proposed plugin
  smart-lint.sh approve long_line_with_conjunction

  # Reject a proposal with reason
  smart-lint.sh reject long_line_with_conjunction "Too complex for automation"

Integration:
  This script integrates with the existing linting system to learn from
  manual interventions and propose intelligent automation plugins.
EOF
            ;;
    esac
}

main "$@"