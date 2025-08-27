#!/bin/bash
# DOH Hybrid Wrapper - Bash-first with Claude fallback
# Usage: hybrid-wrapper.sh <operation> <args...>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Operation dispatch with fallback mechanism
doh_hybrid_get_item() {
    local item_id="$1"
    local start_time=$(date +%s%N)
    
    echo "🔧 Trying bash script first..." >&2
    
    # Try bash script first
    if result=$("$SCRIPT_DIR/get-item.sh" "$item_id" 2>/dev/null); then
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))
        
        echo "✅ Bash script succeeded (${duration}ms)" >&2
        echo "Token savings: ~300-500 tokens" >&2
        echo "$result"
        return 0
    else
        echo "⚠️  Bash script failed, falling back to Claude..." >&2
        echo "🤖 [FALLBACK] Would call Claude here with full context for item: $item_id" >&2
        echo "📊 Performance: Bash attempt failed, full Claude tokens required" >&2
        return 1
    fi
}

doh_hybrid_project_stats() {
    local format="${1:-human}"
    local start_time=$(date +%s%N)
    
    echo "🔧 Trying bash script first..." >&2
    
    # Try bash script first  
    if result=$("$SCRIPT_DIR/project-stats.sh" "$format" 2>/dev/null); then
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))
        
        echo "✅ Bash script succeeded (${duration}ms)" >&2
        echo "Token savings: ~400-800 tokens" >&2
        echo "$result"
        return 0
    else
        echo "⚠️  Bash script failed, falling back to Claude..." >&2
        echo "🤖 [FALLBACK] Would call Claude here with full project analysis" >&2
        echo "📊 Performance: Bash attempt failed, full Claude tokens required" >&2
        return 1
    fi
}

# Test non-existent item (should trigger fallback)
doh_hybrid_get_nonexistent() {
    local item_id="$1"
    
    echo "🔧 Testing fallback mechanism with non-existent item..." >&2
    
    if result=$("$SCRIPT_DIR/get-item.sh" "$item_id" 2>/dev/null); then
        echo "✅ Bash found item: $result" >&2
    else
        echo "⚠️  Bash script failed (expected for non-existent item)" >&2
        echo "🤖 [FALLBACK] Claude would handle this gracefully with:" >&2
        echo "   - Intelligent error handling" >&2
        echo "   - Suggestions for similar items" >&2
        echo "   - Context-aware help" >&2
        return 1
    fi
}

# Main dispatcher
case "${1:-help}" in
    get-item)
        doh_hybrid_get_item "$2"
        ;;
    stats)
        doh_hybrid_project_stats "${2:-human}"
        ;;
    test-fallback)
        doh_hybrid_get_nonexistent "${2:-999}"
        ;;
    *)
        echo "DOH Hybrid Wrapper - POC Demo"
        echo "Usage: $0 <operation> <args>"
        echo ""
        echo "Operations:"
        echo "  get-item <id>       - Get item details (bash-first)"
        echo "  stats [--json]      - Project statistics (bash-first)"  
        echo "  test-fallback <id>  - Test fallback mechanism"
        echo ""
        echo "This POC demonstrates bash-first with Claude fallback strategy"
        ;;
esac