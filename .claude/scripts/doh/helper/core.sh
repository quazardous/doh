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
    local doh_dir="$(doh_project_dir)"
    cat <<EOF
DOH - Development Operations Helper
==================================

DOH is a task and epic management system for development workflows.

Quick Start:
  /doh:init          Initialize DOH in current project
  /doh:prd-new       Create new Product Requirements Document
  /doh:epic-new      Create new epic from PRD
  /doh:task-new      Create new task within epic

Core Commands:
  /doh:validate      Validate DOH system integrity
  /doh:help          Show this help message
  /doh:status        Show overall project status

Management Commands:
  /doh:epic-list     List all epics by status
  /doh:epic-status   Show epic progress and task breakdown
  /doh:prd-list      List all PRDs by status
  /doh:prd-status    Show PRD distribution and recent activity
  /doh:task-list     List tasks with filtering options

Workflow Commands:
  /doh:next          Show next actionable tasks
  /doh:in-progress   Show currently active tasks
  /doh:blocked       Show blocked tasks needing attention
  /doh:standup       Generate standup report

Version Management:
  /doh:version-status    Show version information
  /doh:version-bump      Increment project version
  /doh:version-validate  Validate version consistency

Workspace Commands:
  /doh:workspace         Manage workspace and environment
  /doh:search            Search across DOH documents

System Information:
  - Configuration: $doh_dir/env
  - PRDs: $doh_dir/prds/
  - Epics: $doh_dir/epics/
  - Versions: $doh_dir/versions/

For detailed command help, run the specific command or check .claude/commands/doh/

Quick Examples:
  /doh:prd-new "user-authentication"  # Create auth PRD
  /doh:epic-new "user-auth"           # Convert PRD to epic
  /doh:task-new "login-form"          # Add task to epic
  /doh:status                         # Check overall progress
EOF
    
    return 0
}

# @description Initialize DOH system in current project
# @stdout DOH initialization progress and instructions
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If initialization fails
helper_core_init() {
    local doh_dir="$(doh_project_dir)"
    local project_root="$(doh_project_root)"

    echo "🚀 Initializing DOH System"
    echo "========================="
    echo ""
    
    # Check if we're in a git repository
    if [ ! -d "$project_root/.git" ]; then
        echo "❌ Error: Not in a git repository" >&2
        echo "   Initialize git first with: git init" >&2
        return 1
    fi
    
    # Check if DOH is already initialized
    if [ -d "$doh_dir" ]; then
        echo "⚠️  DOH already initialized in this project"
        echo "   Use /doh:validate to check system health"
        return 0
    fi
    
    echo "📁 Creating DOH directory structure..."
    
    # Create core directories
    mkdir -p "$doh_dir"/{epics,prds,versions} || {
        echo "❌ Error: Failed to create DOH directories" >&2
        return 1
    }
    
    # Create environment file
    if [ ! -f "$doh_dir/env" ]; then
        echo "📝 Creating environment configuration..."
        cat > "$doh_dir/env" << 'EOF'
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
    if [ ! -f "$doh_dir/prds/getting-started.md" ]; then
        echo "📄 Creating sample PRD..."
        cat > "$doh_dir/prds/getting-started.md" << 'EOF'
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
    
    local version_file=$(doh_version_file)
    # Create version file
    if [ ! -f "$version_file" ]; then
        echo "🏷️  Creating version file..."
        echo "0.1.0" > "$version_file"
    fi
    
    # Create initial version document
    if [ ! -f "$doh_dir/versions/0.1.0.md" ]; then
        echo "📋 Creating initial version document..."
        cat > "$doh_dir/versions/0.1.0.md" << EOF
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
1. Review and customize `.$doh_dir/env` settings
2. Explore the sample PRD: `/doh:prd-list`
3. Create your first epic: `/doh:epic-new getting-started`
4. Check system health: `/doh:validate`
EOF
    fi
    
    # Initialize git ignore entries
    if [ -f ".gitignore" ] && ! grep -q "$doh_dir/cache" .gitignore; then
        echo "🚫 Updating .gitignore..."
        cat >> .gitignore << EOF

# DOH cache and temporary files
$doh_dir/cache/
$doh_dir/.tmp/
EOF
    fi
    
    cat <<EOF

✅ DOH initialization complete!

📊 System Status:
   • Environment: $doh_dir/env
   • Sample PRD: $doh_dir/prds/getting-started.md
   • Version: 0.1.0

🎯 Next Actions:
   1. Customize settings: edit $doh_dir/env
   2. Validate system: /doh:validate
   3. List PRDs: /doh:prd-list
   4. Create epic: /doh:epic-new getting-started
   5. Check status: /doh:status

💡 Tip: Run /doh:help for complete command reference
EOF
    
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