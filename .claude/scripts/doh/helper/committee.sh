#!/bin/bash

# DOH Committee Helper
# Provides user-friendly interface for committee operations
# Wraps committee.sh library functions with proper argument handling

set -euo pipefail

# Source dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/doh.sh"
source "$SCRIPT_DIR/../lib/committee.sh"

# =============================================================================
# HELP AND USAGE
# =============================================================================

helper_committee_help() {
    cat << 'EOF'
DOH Committee Management

USAGE:
    helper.sh committee <command> [arguments...]

COMMANDS:
    # Seed management
    seed-create <feature> <content>   Create seed file with initial context
    seed-read <feature>               Read seed content for feature
    seed-exists <feature>             Check if seed file exists
    seed-update <feature> <content>   Update existing seed file
    seed-delete <feature>             Delete seed file
    seed-list                         List all features with seeds
    
    # Session management
    create <feature> [context]     Create new committee session
    status <feature>               Show session status and progress
    list                          List all committee sessions
    clean <feature>               Clean up session workspace
    validate <feature>            Validate session structure
    
    # Workflow execution
    round1 <feature>              Execute Round 1 (exploration)
    round2 <feature>              Execute Round 2 (convergence)  
    score <feature>               Collect and analyze scoring
    converge <feature>            Check convergence and create final PRD

EXAMPLES:
    helper.sh committee create oauth2-auth '{"description":"Add OAuth2 support","version":"2.1.0"}'
    helper.sh committee status oauth2-auth
    helper.sh committee list
    helper.sh committee round1 oauth2-auth
    helper.sh committee converge oauth2-auth
    helper.sh committee clean oauth2-auth

For detailed information about committee workflows, see:
.doh/prds/prd-committee.md
EOF
}

# =============================================================================
# ARGUMENT VALIDATION
# =============================================================================

_committee_validate_feature_name() {
    local feature="$1"
    local command="${2:-}"
    
    # Check if feature name is provided
    if [[ -z "$feature" ]]; then
        if [[ -n "$command" ]]; then
            echo "❌ Error: Feature name required for $command command" >&2
        else
            echo "❌ Error: Feature name required" >&2
        fi
        echo "Usage: committee <command> <feature> [args...]" >&2
        return 1
    fi
    
    # Validate feature name format (kebab-case)
    if [[ ! "$feature" =~ ^[a-z][a-z0-9-]*[a-z0-9]$|^[a-z]$ ]]; then
        echo "❌ Error: Feature name must be kebab-case (lowercase, hyphens only)" >&2
        echo "Examples: oauth2-auth, user-management, api-v2" >&2
        return 1
    fi
    
    return 0
}

# =============================================================================
# COMMITTEE OPERATIONS
# =============================================================================

helper_committee_create() {
    local feature="${1:-}"
    local context="${2:-{}}"
    
    _committee_validate_feature_name "$feature" "create" || return 1
    
    echo "🏛️ Creating committee session for: $feature"
    
    # Create session with context
    if committee_create_session "$feature" "$context"; then
        local doh_dir
        doh_dir=$(doh_project_dir)
        echo "✅ Committee session created: $doh_dir/committees/$feature/"
        echo ""
        echo "Next steps:"
        echo "  committee round1 $feature    # Start Round 1 (exploration)"
        echo "  committee status $feature    # Check session status"
    else
        echo "❌ Failed to create committee session" >&2
        return 1
    fi
}

helper_committee_status() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "status" || return 1
    
    echo "📊 Committee Session Status: $feature"
    echo "=================================="
    
    # Get session status
    if committee_get_session_status "$feature"; then
        echo ""
        echo "Available commands:"
        echo "  committee round1 $feature    # Execute Round 1"
        echo "  committee round2 $feature    # Execute Round 2"  
        echo "  committee score $feature     # Analyze scoring"
        echo "  committee converge $feature  # Check convergence"
    else
        echo "❌ Session not found or invalid" >&2
        return 1
    fi
}

helper_committee_list() {
    echo "📋 Committee Sessions"
    echo "===================="
    
    local doh_dir
    doh_dir=$(doh_project_dir)
    local committees_dir="$doh_dir/committees"
    
    if [[ ! -d "$committees_dir" ]]; then
        echo "No committee sessions found."
        echo ""
        echo "Create a session with:"
        echo "  committee create <feature-name> [context]"
        return 0
    fi
    
    local found=false
    for session_dir in "$committees_dir"/*; do
        if [[ -d "$session_dir" ]]; then
            local feature
            feature=$(basename "$session_dir")
            echo ""
            echo "🏛️ $feature"
            
            # Show basic status
            if [[ -f "$session_dir/session.md" ]]; then
                echo "   Status: Active session"
                if [[ -d "$session_dir/round1" ]]; then
                    echo "   Round 1: ✅ Completed"
                else
                    echo "   Round 1: ⏳ Pending"
                fi
                if [[ -d "$session_dir/round2" ]]; then
                    echo "   Round 2: ✅ Completed"
                else
                    echo "   Round 2: ⏳ Pending"
                fi
            else
                echo "   Status: ⚠️  Incomplete setup"
            fi
            
            found=true
        fi
    done
    
    if [[ "$found" == "false" ]]; then
        echo "No active committee sessions found."
    fi
    
    echo ""
    echo "Commands:"
    echo "  committee status <feature>   # Detailed session info"
    echo "  committee create <feature>   # New session"
}

helper_committee_clean() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "clean" || return 1
    
    local doh_dir
    doh_dir=$(doh_project_dir)
    local session_dir="$doh_dir/committees/$feature"
    
    if [[ ! -d "$session_dir" ]]; then
        echo "❌ No session found for: $feature" >&2
        return 1
    fi
    
    echo "🧹 Cleaning committee session: $feature"
    echo "⚠️  This will delete all session data including:"
    echo "   - Round 1 & 2 PRD versions"
    echo "   - Agent scores and feedback"
    echo "   - Session minutes"
    echo ""
    read -p "Are you sure? [y/N]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if rm -rf "$session_dir"; then
            echo "✅ Session cleaned: $feature"
        else
            echo "❌ Failed to clean session" >&2
            return 1
        fi
    else
        echo "Cancelled."
        return 1
    fi
}

helper_committee_validate() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "validate" || return 1
    
    echo "🔍 Validating committee session: $feature"
    
    if committee_validate_session_structure "$feature"; then
        echo "✅ Session structure valid"
    else
        echo "❌ Session validation failed" >&2
        return 1
    fi
}

# =============================================================================
# WORKFLOW OPERATIONS
# =============================================================================

helper_committee_round1() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "round1" || return 1
    
    echo "🚀 Executing Round 1 (Exploration): $feature"
    echo "============================================="
    echo ""
    echo "This will:"
    echo "• Launch 4 specialized agents in parallel"
    echo "• Each agent creates their PRD version"
    echo "• Collect cross-rating scores and arguments"
    echo "• Generate CTO feedback"
    echo ""
    read -p "Continue? [Y/n]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Cancelled."
        return 1
    fi
    
    if committee_execute_round_1 "$feature"; then
        echo ""
        echo "✅ Round 1 completed!"
        echo ""
        echo "Next steps:"
        echo "  committee status $feature    # Review results"
        echo "  committee round2 $feature    # Start Round 2"
    else
        echo "❌ Round 1 failed" >&2
        return 1
    fi
}

helper_committee_round2() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "round2" || return 1
    
    echo "🔄 Executing Round 2 (Convergence): $feature"
    echo "============================================="
    echo ""
    echo "This will:"
    echo "• Agents revise PRDs based on Round 1 feedback"
    echo "• Collect final cross-rating scores"
    echo "• Prepare data for convergence analysis"
    echo ""
    read -p "Continue? [Y/n]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "Cancelled."
        return 1
    fi
    
    if committee_execute_round_2 "$feature"; then
        echo ""
        echo "✅ Round 2 completed!"
        echo ""
        echo "Next steps:"
        echo "  committee converge $feature  # Check for consensus"
        echo "  committee status $feature    # Review final results"
    else
        echo "❌ Round 2 failed" >&2
        return 1
    fi
}

helper_committee_score() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "score" || return 1
    
    echo "📊 Analyzing Committee Scores: $feature"
    echo "======================================"
    
    if committee_analyze_scoring "$feature"; then
        echo ""
        echo "Score analysis complete. Check session minutes for details."
    else
        echo "❌ Score analysis failed" >&2
        return 1
    fi
}

helper_committee_converge() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "converge" || return 1
    
    echo "⚖️  Checking Convergence: $feature"
    echo "================================"
    
    if committee_check_convergence_and_finalize "$feature"; then
        local doh_dir
        doh_dir=$(doh_project_dir)
        echo ""
        echo "✅ Committee process completed!"
        echo ""
        echo "Results:"
        echo "  Final PRD: $doh_dir/prds/$feature.md"
        echo "  Session: $doh_dir/committees/$feature/"
        echo ""
        echo "Next steps:"
        echo "  /doh:prd-edit $feature      # Edit PRD if needed"
        echo "  /doh:prd-parse $feature     # Create epic"
    else
        echo "❌ Convergence check failed" >&2
        echo ""
        echo "This might mean:"
        echo "• Agents haven't reached consensus"
        echo "• Manual decision required"
        echo "• Session incomplete"
        echo ""
        echo "Check: committee status $feature"
        return 1
    fi
}

# =============================================================================
# SEED OPERATIONS
# =============================================================================

helper_committee_seed_create() {
    local feature="${1:-}"
    local content="${2:-}"
    
    _committee_validate_feature_name "$feature" "seed-create" || return 1
    
    if [[ -z "$content" ]]; then
        echo "❌ Error: Seed content required" >&2
        echo "Usage: committee seed-create <feature> <content>" >&2
        return 1
    fi
    
    echo "📝 Creating seed file for: $feature"
    
    if committee_create_seed "$feature" "$content"; then
        local seed_file
        seed_file=$(committee_get_seed "$feature")
        echo "✅ Seed file created: $seed_file"
        echo ""
        echo "Next steps:"
        echo "  committee create $feature     # Create session (will preserve seed)"
        echo "  committee seed-read $feature  # View seed content"
    else
        echo "❌ Failed to create seed file" >&2
        return 1
    fi
}

helper_committee_seed_read() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "seed-read" || return 1
    
    echo "📖 Reading seed content for: $feature"
    echo "=================================="
    
    if committee_read_seed "$feature"; then
        echo ""
        echo "Commands:"
        echo "  committee seed-update $feature \"<new content>\"  # Update content"
        echo "  committee create $feature                        # Create session"
    else
        echo "❌ No seed file found for: $feature" >&2
        return 1
    fi
}

helper_committee_seed_exists() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "seed-exists" || return 1
    
    if committee_has_seed "$feature"; then
        echo "✅ Seed exists for: $feature"
        local seed_file
        seed_file=$(committee_get_seed "$feature")
        echo "   Location: $seed_file"
        return 0
    else
        echo "❌ No seed found for: $feature"
        return 1
    fi
}

helper_committee_seed_update() {
    local feature="${1:-}"
    local content="${2:-}"
    
    _committee_validate_feature_name "$feature" "seed-update" || return 1
    
    if [[ -z "$content" ]]; then
        echo "❌ Error: New content required" >&2
        echo "Usage: committee seed-update <feature> <content>" >&2
        return 1
    fi
    
    echo "✏️  Updating seed file for: $feature"
    
    if committee_update_seed "$feature" "$content"; then
        echo "✅ Seed file updated successfully"
        echo ""
        echo "Commands:"
        echo "  committee seed-read $feature  # View updated content"
    else
        echo "❌ Failed to update seed file" >&2
        echo "Use 'committee seed-create $feature \"<content>\"' to create a new seed" >&2
        return 1
    fi
}

helper_committee_seed_delete() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "seed-delete" || return 1
    
    echo "🗑️  Deleting seed file for: $feature"
    echo "⚠️  This will permanently remove the seed content"
    echo ""
    read -p "Are you sure? [y/N]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if committee_delete_seed "$feature"; then
            echo "✅ Seed file deleted: $feature"
        else
            echo "❌ Failed to delete seed file" >&2
            return 1
        fi
    else
        echo "Cancelled."
        return 1
    fi
}

helper_committee_seed_list() {
    echo "📋 Committee Seeds"
    echo "=================="
    
    local seeds
    seeds=$(committee_list_seeds)
    
    if [[ -z "$seeds" ]]; then
        echo "No seed files found."
        echo ""
        echo "Create a seed with:"
        echo "  committee seed-create <feature-name> \"<content>\""
        return 0
    fi
    
    echo ""
    while IFS= read -r feature; do
        echo "🌱 $feature"
        
        # Show seed file info
        local seed_file
        if seed_file=$(committee_get_seed "$feature" 2>/dev/null); then
            local size
            size=$(wc -c < "$seed_file" 2>/dev/null || echo "0")
            echo "   Size: ${size} bytes"
            
            # Show first line as preview
            local preview
            preview=$(head -1 "$seed_file" 2>/dev/null || echo "")
            if [[ -n "$preview" ]]; then
                echo "   Preview: ${preview:0:50}..."
            fi
        fi
        echo ""
    done <<< "$seeds"
    
    echo "Commands:"
    echo "  committee seed-read <feature>     # View full content"
    echo "  committee create <feature>        # Create session from seed"
}

