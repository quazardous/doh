#!/bin/bash
# T103 - Intelligent Linting Feedback System
# Pattern Analysis Script for Markdown-focused learning

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INTERVENTIONS_FILE="$SCRIPT_DIR/manual-interventions.jsonl"

# Ensure jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is required for pattern analysis"
    echo "Install: sudo apt-get install jq"
    exit 1
fi

analyze_patterns() {
    echo "📊 T103 - Analyzing Markdown Linting Intervention Patterns"
    echo "=================================================="
    
    if [[ ! -f "$INTERVENTIONS_FILE" ]]; then
        echo "⚠️  No intervention data found at: $INTERVENTIONS_FILE"
        echo "Manual interventions will be logged automatically during linting"
        return 0
    fi
    
    local total_interventions
    total_interventions=$(wc -l < "$INTERVENTIONS_FILE")
    echo "📈 Total manual interventions recorded: $total_interventions"
    echo ""
    
    # Top patterns requiring manual intervention
    echo "🔥 Most frequent manual fixes:"
    jq -r '[.rule, .pattern, .fix_type] | @csv' "$INTERVENTIONS_FILE" \
    | sort | uniq -c | sort -nr | head -10 \
    | while read -r count pattern; do
        echo "   $count occurrences: $pattern"
    done
    echo ""
    
    # High automation potential patterns
    echo "🎯 High automation potential patterns:"
    jq -r 'select(.automation_potential == "high") |
           [.pattern, .target_tool, .rule] | @csv' "$INTERVENTIONS_FILE" \
    | sort | uniq -c | sort -nr \
    | while read -r count pattern; do
        echo "   $count occurrences: $pattern"
    done
    echo ""
    
    # Tool effectiveness analysis
    echo "⚠️  Tool effectiveness analysis:"
    printf "%-15s %-10s %-s\n" "Tool" "Issues" "Common Patterns"
    printf "%-15s %-10s %-s\n" "----" "------" "---------------"
    
    for tool in "markdownlint" "prettier" "codespell"; do
        local count patterns
        count=$(jq -r "select(.target_tool == \"$tool\") | .pattern" "$INTERVENTIONS_FILE" | wc -l)
        patterns=$(jq -r "select(.target_tool == \"$tool\") | .pattern" "$INTERVENTIONS_FILE" | sort | uniq | head -3 | tr '\n' ', ' | sed 's/,$//')
        printf "%-15s %-10s %-s\n" "$tool" "$count" "$patterns"
    done
    echo ""
}

generate_recommendations() {
    echo "💡 T103 - Automation Development Recommendations"
    echo "==============================================="
    
    if [[ ! -f "$INTERVENTIONS_FILE" ]]; then
        echo "⚠️  No intervention data available for recommendations"
        return 0
    fi
    
    # Custom markdownlint rules candidates
    echo ""
    echo "🔧 Custom markdownlint rules to develop:"
    jq -r 'select(.target_tool == "markdownlint" and .automation_potential == "high") |
           "  - " + .pattern + " (" + .rule + "): " + .reason' "$INTERVENTIONS_FILE" \
    | sort | uniq
    echo ""
    
    # Prettier configuration improvements
    echo "🎨 Prettier configuration improvements:"
    jq -r 'select(.target_tool == "prettier") |
           "  - " + .fix_type + ": " + .reason' "$INTERVENTIONS_FILE" \
    | sort | uniq
    echo ""
    
    # Custom codespell dictionary entries
    echo "📚 Custom codespell dictionary candidates:"
    jq -r 'select(.target_tool == "codespell") |
           "  - " + (.original | split(" ")[0]) + " → " + (.fixed | split(" ")[0]) + ": " + .reason' "$INTERVENTIONS_FILE" \
    | sort | uniq
    echo ""
}

calculate_improvement_metrics() {
    echo "📈 T103 - Improvement Metrics"
    echo "============================="
    
    if [[ ! -f "$INTERVENTIONS_FILE" ]]; then
        echo "⚠️  No data available for metrics calculation"
        return 0
    fi
    
    local total_interventions high_potential medium_potential
    total_interventions=$(wc -l < "$INTERVENTIONS_FILE")
    high_potential=$(jq -r 'select(.automation_potential == "high")' "$INTERVENTIONS_FILE" | wc -l)
    medium_potential=$(jq -r 'select(.automation_potential == "medium")' "$INTERVENTIONS_FILE" | wc -l)
    
    echo "📊 Automation Potential Analysis:"
    echo "  Total interventions: $total_interventions"
    
    if (( total_interventions > 0 )); then
        echo "  High automation potential: $high_potential ($(( high_potential * 100 / total_interventions ))%)"
        echo "  Medium automation potential: $medium_potential ($(( medium_potential * 100 / total_interventions ))%)"
    else
        echo "  High automation potential: $high_potential"
        echo "  Medium automation potential: $medium_potential"
    fi
    
    if (( high_potential > 0 )); then
        echo ""
        echo "🎯 Target: Automate $high_potential high-potential patterns"
        echo "   Expected reduction: $(( high_potential * 100 / total_interventions ))% of manual interventions"
    fi
    echo ""
}

main() {
    case "${1:-analyze}" in
        "analyze"|"patterns")
            analyze_patterns
            ;;
        "recommend"|"recommendations")
            generate_recommendations
            ;;
        "metrics"|"stats")
            calculate_improvement_metrics
            ;;
        "all")
            analyze_patterns
            generate_recommendations
            calculate_improvement_metrics
            ;;
        *)
            echo "Usage: $0 [analyze|recommend|metrics|all]"
            echo ""
            echo "Commands:"
            echo "  analyze     - Analyze intervention patterns (default)"
            echo "  recommend   - Generate automation recommendations"
            echo "  metrics     - Calculate improvement metrics"
            echo "  all         - Run all analysis"
            exit 1
            ;;
    esac
}

main "$@"