#!/bin/bash

# DOH Help Helper
# User-facing functions for DOH help and documentation

# Guard against multiple sourcing
[[ -n "${DOH_HELPER_HELP_LOADED:-}" ]] && return 0
DOH_HELPER_HELP_LOADED=1

# @description Display comprehensive DOH help and command reference
# @stdout Help information and command reference
# @stderr Error messages
# @exitcode 0 Always successful
help_helper_show() {
    echo "Helping..."
    echo ""
    echo ""

    echo "📚 DOH - Project Management System"
    echo "============================================="
    echo ""
    echo "🎯 Quick Start Workflow"
    echo "  1. /doh:prd-new <name>        - Create a new PRD"
    echo "  2. /doh:prd-parse <name>      - Convert PRD to epic"
    echo "  3. /doh:epic-decompose <name> - Break into tasks"
    echo "  4. /doh:epic-sync <name>      - Push to GitHub"
    echo "  5. /doh:epic-start <name>     - Start parallel execution"
    echo ""
    echo "📄 PRD Commands"
    echo "  /doh:prd-new <name>     - Launch brainstorming for new product requirement"
    echo "  /doh:prd-parse <name>   - Convert PRD to implementation epic"
    echo "  /doh:prd-list           - List all PRDs"
    echo "  /doh:prd-edit <name>    - Edit existing PRD"
    echo "  /doh:prd-status         - Show PRD implementation status"
    echo ""
    echo "📚 Epic Commands"
    echo "  /doh:epic-decompose <name> - Break epic into task files"
    echo "  /doh:epic-sync <name>      - Push epic and tasks to GitHub"
    echo "  /doh:epic-oneshot <name>   - Decompose and sync in one command"
    echo "  /doh:epic-list             - List all epics"
    echo "  /doh:epic-show <name>      - Display epic and its tasks"
    echo "  /doh:epic-status [name]    - Show epic progress"
    echo "  /doh:epic-close <name>     - Mark epic as complete"
    echo "  /doh:epic-edit <name>      - Edit epic details"
    echo "  /doh:epic-refresh <name>   - Update epic progress from tasks"
    echo "  /doh:epic-start <name>     - Launch parallel agent execution"
    echo ""
    echo "📝 Issue Commands"
    echo "  /doh:issue-show <num>      - Display issue and sub-issues"
    echo "  /doh:issue-status <num>    - Check issue status"
    echo "  /doh:issue-start <num>     - Begin work with specialized agent"
    echo "  /doh:issue-sync <num>      - Push updates to GitHub"
    echo "  /doh:issue-close <num>     - Mark issue as complete"
    echo "  /doh:issue-reopen <num>    - Reopen closed issue"
    echo "  /doh:issue-edit <num>      - Edit issue details"
    echo "  /doh:issue-analyze <num>   - Analyze for parallel work streams"
    echo ""
    echo "🔄 Workflow Commands"
    echo "  /doh:next               - Show next priority tasks"
    echo "  /doh:status             - Overall project dashboard"
    echo "  /doh:standup            - Daily standup report"
    echo "  /doh:blocked            - Show blocked tasks"
    echo "  /doh:in-progress        - List work in progress"
    echo ""
    echo "🔗 Sync Commands"
    echo "  /doh:sync               - Full bidirectional sync with GitHub"
    echo "  /doh:import <issue>     - Import existing GitHub issues"
    echo ""
    echo "🔧 Maintenance Commands"
    echo "  /doh:validate           - Check system integrity"
    echo "  /doh:clean              - Archive completed work"
    echo "  /doh:search <query>     - Search across all content"
    echo ""
    echo "⚙️  Setup Commands"
    echo "  /doh:init               - Install dependencies and configure GitHub"
    echo "  /doh:help               - Show this help message"
    echo ""
    echo "💡 Tips"
    echo "  • Use /doh:next to find available work"
    echo "  • Run /doh:status for quick overview"
    echo "  • Epic workflow: prd-new → prd-parse → epic-decompose → epic-sync"
    echo "  • View README.md for complete documentation"
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed
