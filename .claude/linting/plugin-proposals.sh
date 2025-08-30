#!/bin/bash
# T103 - Intelligent Plugin Proposal System
# Generates automation proposals when patterns reach threshold

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTERVENTIONS_FILE="$SCRIPT_DIR/manual-interventions.jsonl"
PROPOSALS_FILE="$SCRIPT_DIR/proposed-plugins.json"
APPROVED_FILE="$SCRIPT_DIR/approved-plugins.json"
REJECTED_FILE="$SCRIPT_DIR/rejected-plugins.json"

# Configuration thresholds
MIN_OCCURRENCES=5          # Minimum pattern occurrences to trigger proposal
HIGH_POTENTIAL_ONLY=true   # Only propose high automation potential patterns
PROPOSAL_COOLDOWN=7        # Days between proposals for same pattern

check_proposal_thresholds() {
    echo "🔍 T103 - Checking Pattern Thresholds for Plugin Proposals"
    echo "========================================================"
    
    if [[ ! -f "$INTERVENTIONS_FILE" ]]; then
        echo "⚠️  No intervention data found. Continue using system to collect patterns."
        return 0
    fi
    
    echo "📊 Current thresholds:"
    echo "  Minimum occurrences: $MIN_OCCURRENCES"
    echo "  High potential only: $HIGH_POTENTIAL_ONLY"
    echo "  Proposal cooldown: $PROPOSAL_COOLDOWN days"
    echo ""
    
    # Find patterns that meet threshold criteria
    local eligible_patterns
    eligible_patterns=$(mktemp)
    
    if [[ "$HIGH_POTENTIAL_ONLY" == "true" ]]; then
        jq -r 'select(.automation_potential == "high") | [.pattern, .rule, .target_tool] | @csv' "$INTERVENTIONS_FILE"
    else
        jq -r '[.pattern, .rule, .target_tool] | @csv' "$INTERVENTIONS_FILE"
    fi | sort | uniq -c | sort -nr | while read -r count pattern; do
        if (( count >= MIN_OCCURRENCES )); then
            echo "$count,$pattern" >> "$eligible_patterns"
        fi
    done
    
    if [[ ! -s "$eligible_patterns" ]]; then
        echo "📈 No patterns have reached the $MIN_OCCURRENCES occurrence threshold yet."
        echo "   Continue using the linting system to collect more pattern data."
        echo ""
        
        # Show progress toward threshold
        echo "🎯 Progress toward plugin proposal threshold:"
        jq -r 'select(.automation_potential == "high") | [.pattern, .rule] | @csv' "$INTERVENTIONS_FILE" \
        | sort | uniq -c | sort -nr | head -5 | while read -r count pattern; do
            local percentage=$((count * 100 / MIN_OCCURRENCES))
            if (( percentage > 100 )); then percentage=100; fi
            echo "   $pattern: $count/$MIN_OCCURRENCES (${percentage}%)"
        done
    else
        echo "🚀 Patterns ready for plugin proposal:"
        while IFS= read -r line; do
            local count pattern_info
            count=$(echo "$line" | cut -d, -f1)
            pattern_info=$(echo "$line" | cut -d, -f2-)
            echo "   ✅ $pattern_info: $count occurrences (>= $MIN_OCCURRENCES threshold)"
        done < "$eligible_patterns"
        echo ""
        
        generate_plugin_proposals "$eligible_patterns"
    fi
    
    rm -f "$eligible_patterns"
}

generate_plugin_proposals() {
    local eligible_patterns="$1"
    
    echo "💡 T103 - Generating Plugin Proposals"
    echo "===================================="
    
    while IFS= read -r line; do
        local count pattern rule tool
        count=$(echo "$line" | cut -d, -f1)
        pattern=$(echo "$line" | cut -d, -f2 | tr -d '"')
        rule=$(echo "$line" | cut -d, -f3 | tr -d '"')
        tool=$(echo "$line" | cut -d, -f4 | tr -d '"')
        
        # Check if this pattern was already proposed recently
        if check_recent_proposal "$pattern"; then
            echo "⏸️  Skipping $pattern (proposed within $PROPOSAL_COOLDOWN days)"
            continue
        fi
        
        echo ""
        echo "🔧 PLUGIN PROPOSAL: $pattern"
        echo "   Target tool: $tool"
        echo "   Rule: $rule" 
        echo "   Occurrences: $count"
        echo ""
        
        # Get sample interventions for this pattern
        echo "📝 Sample interventions:"
        jq -r --arg pattern "$pattern" '
            select(.pattern == $pattern) | 
            "   Original: " + (.original | .[0:60]) + (if (.original | length) > 60 then "..." else "" end) + "\n" +
            "   Fixed:    " + (.fixed | .[0:60]) + (if (.fixed | length) > 60 then "..." else "" end) + "\n" +
            "   Reason:   " + .reason
        ' "$INTERVENTIONS_FILE" | head -9
        echo ""
        
        # Generate specific plugin recommendation
        generate_specific_proposal "$pattern" "$rule" "$tool" "$count"
        
    done < "$eligible_patterns"
}

generate_specific_proposal() {
    local pattern="$1" rule="$2" tool="$3" count="$4"
    
    case "$tool" in
        "markdownlint")
            generate_markdownlint_proposal "$pattern" "$rule" "$count"
            ;;
        "prettier")
            generate_prettier_proposal "$pattern" "$rule" "$count"
            ;;
        "codespell")
            generate_codespell_proposal "$pattern" "$rule" "$count"
            ;;
        *)
            echo "⚠️  Unknown tool: $tool"
            ;;
    esac
}

generate_markdownlint_proposal() {
    local pattern="$1" rule="$2" count="$3"
    
    echo "🛠️  MARKDOWNLINT CUSTOM RULE PROPOSAL:"
    echo ""
    echo "   Rule ID: MD-DOH-$(echo "$pattern" | tr '[:lower:]' '[:upper:]' | tr '_' '-')"
    echo "   Pattern: $pattern"
    echo "   Target: $rule violations"
    echo "   Evidence: $count manual interventions"
    echo ""
    
    case "$pattern" in
        "long_line_with_conjunction")
            cat << 'EOF'
   Proposed rule logic:
   - Detect lines > 120 chars containing conjunctions (and, or, but)
   - Auto-break at conjunction with proper continuation
   - Preserve semantic meaning and readability
   
   Implementation approach:
   - Custom markdownlint rule in JavaScript
   - Pattern: /(.{60,})\s+(and|or|but)\s+(.{10,})/
   - Fix: $1\n$2 $3
EOF
            ;;
        *)
            echo "   Generic custom rule for pattern: $pattern"
            echo "   Requires pattern-specific implementation analysis"
            ;;
    esac
    
    echo ""
    echo "❓ APPROVAL REQUIRED:"
    echo "   Would you like to create this custom markdownlint rule?"
    echo "   This would automate $count recurring manual interventions."
    echo ""
    echo "   Commands to approve:"
    echo "     $0 approve $pattern"
    echo "     $0 reject $pattern \"reason for rejection\""
    echo ""
}

generate_prettier_proposal() {
    local pattern="$1" rule="$2" count="$3"
    
    echo "🛠️  PRETTIER CONFIGURATION PROPOSAL:"
    echo ""
    echo "   Pattern: $pattern"
    echo "   Evidence: $count manual interventions"
    echo ""
    echo "   Proposed prettier config adjustment based on common fixes"
    echo ""
    echo "❓ APPROVAL REQUIRED:"
    echo "   Commands: $0 approve $pattern | $0 reject $pattern \"reason\""
    echo ""
}

generate_codespell_proposal() {
    local pattern="$1" rule="$2" count="$3"
    
    echo "🛠️  CODESPELL DICTIONARY PROPOSAL:"
    echo ""
    echo "   Pattern: $pattern"
    echo "   Evidence: $count manual interventions"
    echo ""
    echo "   Proposed additions to project dictionary:"
    
    # Extract common corrections for this pattern
    jq -r --arg pattern "$pattern" '
        select(.pattern == $pattern) | 
        [.original, .fixed] | @csv
    ' "$INTERVENTIONS_FILE" | sort | uniq | while IFS=, read -r original fixed; do
        echo "     $original → $fixed"
    done
    
    echo ""
    echo "❓ APPROVAL REQUIRED:"
    echo "   Commands: $0 approve $pattern | $0 reject $pattern \"reason\""
    echo ""
}

check_recent_proposal() {
    local pattern="$1"
    
    # First check if pattern was rejected - if so, never propose again
    if [[ -f "$REJECTED_FILE" ]]; then
        if jq -e --arg pattern "$pattern" '
            .rejected[] | select(.pattern == $pattern)
        ' "$REJECTED_FILE" > /dev/null 2>&1; then
            return 0  # Pattern was rejected, treat as "recent"
        fi
    fi
    
    if [[ ! -f "$PROPOSALS_FILE" ]]; then
        return 1  # No recent proposals
    fi
    
    # Check if pattern was proposed within cooldown period
    local cutoff_date
    cutoff_date=$(date -d "$PROPOSAL_COOLDOWN days ago" -Iseconds)
    
    if jq -e --arg pattern "$pattern" --arg cutoff "$cutoff_date" '
        .proposals[] | select(.pattern == $pattern and .timestamp > $cutoff)
    ' "$PROPOSALS_FILE" > /dev/null 2>&1; then
        return 0  # Recent proposal exists
    else
        return 1  # No recent proposal
    fi
}

approve_proposal() {
    local pattern="$1"
    echo "✅ Approving plugin proposal for pattern: $pattern"
    echo "   Implementation will be scheduled for development"
    
    # Log approval
    local timestamp
    timestamp=$(date -Iseconds)
    
    # Add to approved plugins
    if [[ ! -f "$APPROVED_FILE" ]]; then
        echo '{"approved": []}' > "$APPROVED_FILE"
    fi
    
    jq --arg pattern "$pattern" --arg timestamp "$timestamp" '
        .approved += [{
            "pattern": $pattern,
            "approved_at": $timestamp,
            "status": "pending_implementation"
        }]
    ' "$APPROVED_FILE" > "${APPROVED_FILE}.tmp" && mv "${APPROVED_FILE}.tmp" "$APPROVED_FILE"
    
    echo "   ✅ Approval logged. Plugin will be implemented in next development cycle."
}

reject_proposal() {
    local pattern="$1" reason="$2"
    echo "❌ Rejecting plugin proposal for pattern: $pattern"
    echo "   Reason: $reason"
    
    # Extract rule and tool from the pattern for better tracking
    local rule tool
    rule=$(extract_rule_from_pattern "$pattern")
    tool=$(extract_tool_from_pattern "$pattern")
    
    # Log rejection to dedicated rejected file
    local timestamp
    timestamp=$(date -Iseconds)
    
    if [[ ! -f "$REJECTED_FILE" ]]; then
        echo '{"rejected": []}' > "$REJECTED_FILE"
    fi
    
    jq --arg pattern "$pattern" --arg rule "$rule" --arg tool "$tool" --arg timestamp "$timestamp" --arg reason "$reason" '
        .rejected += [{
            "pattern": $pattern,
            "rule": $rule,
            "tool": $tool,
            "rejected_at": $timestamp,
            "reason": $reason,
            "continue_manual": true
        }]
    ' "$REJECTED_FILE" > "${REJECTED_FILE}.tmp" && mv "${REJECTED_FILE}.tmp" "$REJECTED_FILE"
    
    echo "   ✅ Rejection logged in dedicated tracking system."
    echo "   🤖 AI will continue manual corrections for this pattern."
    echo "   🚫 Pattern will not be proposed again."
}

extract_rule_from_pattern() {
    local pattern="$1"
    
    # Extract rule information from the pattern based on common patterns
    case "$pattern" in
        "long_line_"*) echo "MD013";;
        "list_numbering_"*) echo "MD029";;
        "duplicate_heading_"*) echo "MD024";;
        "formatting_"*) echo "formatting";;
        "spelling_"*) echo "spelling";;
        *) echo "unknown";;
    esac
}

extract_tool_from_pattern() {
    local pattern="$1"
    
    # Get the tool from the interventions file
    if [[ -f "$INTERVENTIONS_FILE" ]]; then
        jq -r --arg pattern "$pattern" 'select(.pattern == $pattern) | .target_tool' "$INTERVENTIONS_FILE" | head -1
    else
        echo "unknown"
    fi
}

main() {
    case "${1:-check}" in
        "check"|"threshold"|"thresholds")
            check_proposal_thresholds
            ;;
        "propose"|"proposals")
            # Force proposal generation (ignore thresholds)
            MIN_OCCURRENCES=1
            check_proposal_thresholds
            ;;
        "approve")
            if [[ -z "${2:-}" ]]; then
                echo "Error: Pattern name required"
                echo "Usage: $0 approve PATTERN_NAME"
                exit 1
            fi
            approve_proposal "$2"
            ;;
        "reject")
            if [[ -z "${2:-}" || -z "${3:-}" ]]; then
                echo "Error: Pattern name and reason required"
                echo "Usage: $0 reject PATTERN_NAME \"rejection reason\""
                exit 1
            fi
            reject_proposal "$2" "$3"
            ;;
        "status")
            echo "📊 T103 Plugin Proposal Status"
            echo "=============================="
            if [[ -f "$APPROVED_FILE" ]]; then
                echo "✅ Approved plugins:"
                jq -r '.approved[] | "   " + .pattern + " (" + .status + ")"' "$APPROVED_FILE"
            else
                echo "✅ Approved plugins: none"
            fi
            echo ""
            if [[ -f "$REJECTED_FILE" ]]; then
                echo "❌ Rejected patterns (AI continues manual corrections):"
                jq -r '.rejected[] | "   " + .pattern + " (" + .tool + "/" + .rule + "): " + .reason' "$REJECTED_FILE"
            else
                echo "❌ Rejected patterns: none"
            fi
            ;;
        *)
            echo "T103 - Intelligent Plugin Proposal System"
            echo "========================================"
            echo ""
            echo "Usage: $0 COMMAND [args]"
            echo ""
            echo "Commands:"
            echo "  check        - Check patterns against thresholds (default)"
            echo "  propose      - Force proposal generation (ignore thresholds)"
            echo "  approve PATTERN - Approve a plugin proposal"
            echo "  reject PATTERN REASON - Reject a plugin proposal"
            echo "  status       - Show approved/rejected plugin status"
            echo ""
            echo "Thresholds:"
            echo "  Minimum occurrences: $MIN_OCCURRENCES"
            echo "  High potential only: $HIGH_POTENTIAL_ONLY"
            echo "  Proposal cooldown: $PROPOSAL_COOLDOWN days"
            exit 1
            ;;
    esac
}

main "$@"