#!/bin/bash

# DOH Core Helper
# User-facing functions for core system operations (validate, help, init)

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../lib/validation.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/migration.sh"

# Guard against multiple sourcing
[[ -n "${DOH_HELPER_CORE_LOADED:-}" ]] && return 0
DOH_HELPER_CORE_LOADED=1

# @description Validate DOH system integrity
# @stdout Comprehensive validation report with health status
# @stderr Error messages
# @exitcode 0 If successful
helper_core_validate() {
    echo "Validating DOH System..."
    echo ""
    echo ""
    
    # Call the library function
    validation_validate_system "$@"
    return $?
}

# @description Show comprehensive DOH help information
# @stdout DOH system help with available commands and usage
# @exitcode 0 Always successful
helper_core_help() {
    echo "DOH - Development Operations Helper"
    echo "=================================="
    echo ""
    echo "DOH is a task and epic management system for development workflows."
    echo ""
    echo "Quick Start:"
    echo "  /doh:init          Initialize DOH in current project"
    echo "  /doh:prd-new       Create new Product Requirements Document"
    echo "  /doh:epic-new      Create new epic from PRD"
    echo "  /doh:task-new      Create new task within epic"
    echo ""
    echo "Core Commands:"
    echo "  /doh:validate      Validate DOH system integrity"
    echo "  /doh:help          Show this help message"
    echo "  /doh:status        Show overall project status"
    echo ""
    echo "Management Commands:"
    echo "  /doh:epic-list     List all epics by status"
    echo "  /doh:epic-status   Show epic progress and task breakdown"
    echo "  /doh:prd-list      List all PRDs by status"
    echo "  /doh:prd-status    Show PRD distribution and recent activity"
    echo "  /doh:task-list     List tasks with filtering options"
    echo ""
    echo "Workflow Commands:"
    echo "  /doh:next          Show next actionable tasks"
    echo "  /doh:in-progress   Show currently active tasks"
    echo "  /doh:blocked       Show blocked tasks needing attention"
    echo "  /doh:standup       Generate standup report"
    echo ""
    echo "Version Management:"
    echo "  /doh:version-status    Show version information"
    echo "  /doh:version-bump      Increment project version"
    echo "  /doh:version-validate  Validate version consistency"
    echo ""
    echo "Workspace Commands:"
    echo "  /doh:workspace         Manage workspace and environment"
    echo "  /doh:search            Search across DOH documents"
    echo ""
    echo "System Information:"
    echo "  - Configuration: .doh/env"
    echo "  - PRDs: .doh/prds/"
    echo "  - Epics: .doh/epics/"
    echo "  - Versions: .doh/versions/"
    echo ""
    echo "For detailed command help, run the specific command or check .claude/commands/doh/"
    echo ""
    echo "Quick Examples:"
    echo "  /doh:prd-new \"user-authentication\"  # Create auth PRD"
    echo "  /doh:epic-new \"user-auth\"           # Convert PRD to epic"  
    echo "  /doh:task-new \"login-form\"          # Add task to epic"
    echo "  /doh:status                          # Check overall progress"
    
    return 0
}

# @description Initialize DOH system in current project
# @stdout DOH initialization progress and instructions
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If initialization fails
helper_core_init() {
    echo "🚀 Initializing DOH System"
    echo "========================="
    echo ""
    
    # Check if we're in a git repository
    if [ ! -d ".git" ]; then
        echo "❌ Error: Not in a git repository" >&2
        echo "   Initialize git first with: git init" >&2
        return 1
    fi
    
    # Check if DOH is already initialized
    if [ -d ".doh" ]; then
        echo "⚠️  DOH already initialized in this project"
        echo "   Use /doh:validate to check system health"
        return 0
    fi
    
    echo "📁 Creating DOH directory structure..."
    
    # Create core directories
    mkdir -p .doh/{epics,prds,versions} || {
        echo "❌ Error: Failed to create DOH directories" >&2
        return 1
    }
    
    # Create environment file
    if [ ! -f ".doh/env" ]; then
        echo "📝 Creating environment configuration..."
        cat > .doh/env << 'EOF'
# DOH Project Environment
# Customize these settings for your project

# Project metadata
PROJECT_NAME="$(basename "$(pwd)")"
PROJECT_VERSION="0.1.0"

# Workflow settings
DEFAULT_EPIC_STATUS="active"
DEFAULT_TASK_STATUS="pending" 
AUTO_VERSION_BUMP="true"

# Display settings
SHOW_FILE_VERSIONS="true"
COMPACT_LIST_VIEW="false"
COLORIZED_OUTPUT="true"

# Integration settings
ENABLE_GIT_HOOKS="false"
TRACK_TIME="false"

# Advanced settings
CACHE_ENABLED="true"
DEBUG_MODE="false"
EOF
    fi
    
    # Create sample PRD
    if [ ! -f ".doh/prds/getting-started.md" ]; then
        echo "📄 Creating sample PRD..."
        cat > .doh/prds/getting-started.md << 'EOF'
---
name: getting-started
description: Learn DOH task management basics
status: backlog
created: $(date -Iseconds)
target_version: 0.1.0
---

# Getting Started with DOH

## Overview
This sample PRD demonstrates DOH's task and epic management capabilities.

## Goals
- Learn to create and manage PRDs
- Understand epic decomposition
- Practice task workflow
- Explore DOH commands

## Success Criteria
- [ ] Create your first epic
- [ ] Add tasks to epic  
- [ ] Complete a task workflow
- [ ] Generate status reports

## Implementation Notes
Use `/doh:epic-new getting-started` to convert this PRD into an epic, then add specific tasks for your learning objectives.

## Resources
- DOH Documentation: `docs/`
- Command Reference: `.claude/commands/doh/`
EOF
    fi
    
    # Create version file
    if [ ! -f "VERSION" ]; then
        echo "🏷️  Creating version file..."
        echo "0.1.0" > VERSION
    fi
    
    # Create initial version document
    if [ ! -f ".doh/versions/0.1.0.md" ]; then
        echo "📋 Creating initial version document..."
        cat > .doh/versions/0.1.0.md << 'EOF'
---
version: 0.1.0
status: active
created: $(date -Iseconds)
---

# Version 0.1.0 - Project Initialization

## Overview
Initial DOH system setup and configuration.

## Features
- DOH directory structure
- Sample PRD for learning
- Basic environment configuration
- Version tracking system

## Next Steps
1. Review and customize `.doh/env` settings
2. Explore the sample PRD: `/doh:prd-list`
3. Create your first epic: `/doh:epic-new getting-started`
4. Check system health: `/doh:validate`
EOF
    fi
    
    # Initialize git ignore entries
    if [ -f ".gitignore" ] && ! grep -q ".doh/cache" .gitignore; then
        echo "🚫 Updating .gitignore..."
        cat >> .gitignore << 'EOF'

# DOH cache and temporary files
.doh/cache/
.doh/.tmp/
EOF
    fi
    
    echo ""
    echo "✅ DOH initialization complete!"
    echo ""
    echo "📊 System Status:"
    echo "   • Environment: .doh/env"  
    echo "   • Sample PRD: .doh/prds/getting-started.md"
    echo "   • Version: 0.1.0"
    echo ""
    echo "🎯 Next Actions:"
    echo "   1. Customize settings: edit .doh/env"
    echo "   2. Validate system: /doh:validate"
    echo "   3. List PRDs: /doh:prd-list"
    echo "   4. Create epic: /doh:epic-new getting-started"
    echo "   5. Check status: /doh:status"
    echo ""
    echo "💡 Tip: Run /doh:help for complete command reference"
    
    return 0
}

# @description Migrate DOH project to versioning system
# @arg $* string Migration options (analyze, dry-run, from-git, interactive, rollback, force, deduplicate)
# @stdout Migration progress and results
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If migration fails
helper_core_version_migrate() {
    local options=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --analyze) options="${options:+$options,}analyze"; shift ;;
            --dry-run) options="${options:+$options,}dry-run"; shift ;;
            --from-git) options="${options:+$options,}from-git"; shift ;;
            --interactive) options="${options:+$options,}interactive"; shift ;;
            --rollback) options="${options:+$options,}rollback"; shift ;;
            --force) options="${options:+$options,}force"; shift ;;
            --deduplicate) options="${options:+$options,}deduplicate"; shift ;;
            --backup-dir) shift 2 ;; # Skip backup dir for now
            --initial-version) shift 2 ;; # Skip initial version for now  
            -h|--help) 
                cat << 'EOF'
DOH Version Migration Tool

USAGE:
    helper.sh core version-migrate [OPTIONS]

OPTIONS:
    --analyze              Analyze project without making changes
    --dry-run             Show what changes would be made
    --from-git            Import version history from git tags  
    --interactive         Step-by-step guided migration
    --rollback            Rollback previous migration
    --force               Skip safety checks and confirmations
    --deduplicate         Include duplicate number cleanup
    --backup-dir DIR      Custom backup directory location
    --initial-version VER Set initial version (default: 0.1.0)
    -h, --help            Show this help message

EXAMPLES:
    helper.sh core version-migrate --analyze
    helper.sh core version-migrate --dry-run --from-git
    helper.sh core version-migrate --interactive
    helper.sh core version-migrate --rollback
EOF
                return 0
                ;;
            *) shift ;; # Ignore unknown options for now
        esac
    done
    
    # Call the library function
    migration_migrate_version "$options"
    return $?
}

# @description Display core system help
# @stdout Help information for core commands
# @exitcode 0 Always successful
helper_core_usage() {
    echo "DOH Core System Commands"
    echo "======================="
    echo ""
    echo "Usage: helper.sh core <command> [options]"
    echo ""
    echo "Commands:"
    echo "  validate              Validate DOH system integrity"
    echo "  help                  Show comprehensive DOH help"
    echo "  init                  Initialize DOH in current project"
    echo "  version-migrate       Migrate project to versioning system"
    echo "  usage                 Show this usage message"
    echo ""
    echo "Examples:"
    echo "  helper.sh core validate               # Check system health"
    echo "  helper.sh core help                  # Show full DOH help"
    echo "  helper.sh core init                  # Initialize new project"
    echo "  helper.sh core version-migrate --analyze  # Analyze for migration"
    
    return 0
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed