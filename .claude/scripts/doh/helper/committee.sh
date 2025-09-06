#!/bin/bash

# DOH Committee Helper
# Provides user-friendly interface for committee operations
# Only includes functions actually used by the workflow

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
    # Seed management (used by /doh:prd-evo)
    seed-create <feature> <content>   Create seed file with initial context
    seed-exists <feature>             Check if seed file exists
    seed-update <feature> <content>   Update existing seed file
    seed-delete <feature>             Delete seed file
    
    # PRD template (used by orchestrator)
    create-final-prd <feature>        Create empty PRD template with frontmatter

EXAMPLES:
    helper.sh committee seed-create oauth2-auth "$(cat seed_content.md)"
    helper.sh committee seed-exists oauth2-auth
    helper.sh committee create-final-prd oauth2-auth > /tmp/template.md

NOTE: 
    Committee workflow execution is handled by the committee-orchestrator agent.
    These helpers only provide seed management and PRD template generation.
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
# SEED MANAGEMENT (USED BY PRD-EVO)
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
        local doh_dir
        doh_dir=$(doh_project_dir)
        echo "✅ Seed file created: $doh_dir/committees/$feature/seed.md"
        echo ""
        echo "Next steps:"
        echo "  Read seed: .doh/committees/$feature/seed.md"
        echo "  Launch orchestrator with this feature name"
    else
        echo "❌ Failed to create seed file" >&2
        return 1
    fi
}

helper_committee_seed_exists() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "seed-exists" || return 1
    
    if committee_has_seed "$feature"; then
        echo "✅ Seed exists for: $feature"
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
        echo "❌ Error: Updated content required" >&2
        echo "Usage: committee seed-update <feature> <content>" >&2
        return 1
    fi
    
    echo "📝 Updating seed file for: $feature"
    
    if committee_update_seed "$feature" "$content"; then
        echo "✅ Seed file updated"
    else
        echo "❌ Failed to update seed file" >&2
        return 1
    fi
}

helper_committee_seed_delete() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "seed-delete" || return 1
    
    echo "🗑️ Deleting seed file for: $feature"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local seed_file="$doh_dir/committees/$feature/seed.md"
    
    if [[ ! -f "$seed_file" ]]; then
        echo "❌ No seed file found for: $feature"
        return 1
    fi
    
    echo "This will permanently delete the seed file."
    read -p "Are you sure? [y/N]: " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if committee_delete_seed "$feature"; then
            echo "✅ Seed file deleted"
        else
            echo "❌ Failed to delete seed file" >&2
            return 1
        fi
    else
        echo "Cancelled."
    fi
}

# =============================================================================
# PRD TEMPLATE (USED BY ORCHESTRATOR) 
# =============================================================================

helper_committee_create_final_prd() {
    local feature="${1:-}"
    
    _committee_validate_feature_name "$feature" "create-final-prd" || return 1
    
    # Delegate to lib function
    committee_create_final_prd "$feature"
}

# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

# Handle commands based on helper.sh pattern (skip in test mode)
if [[ -z "${DOH_HELPER_COMMITTEE_TEST_MODE:-}" ]]; then
    COMMAND="${1:-help}"
    shift || true

    case "$COMMAND" in
    help|--help|-h)
        helper_committee_help
        ;;
    seed-create|seed_create)
        helper_committee_seed_create "$@"
        ;;
    seed-exists|seed_exists) 
        helper_committee_seed_exists "$@"
        ;;
    seed-update|seed_update)
        helper_committee_seed_update "$@"
        ;;
    seed-delete|seed_delete)
        helper_committee_seed_delete "$@"
        ;;
    create-final-prd|create_final_prd)
        helper_committee_create_final_prd "$@"
        ;;
    *)
        echo "❌ Error: Unknown command '$COMMAND'" >&2
        echo "Use 'helper.sh committee help' for available commands" >&2
        exit 1
        ;;
    esac
fi