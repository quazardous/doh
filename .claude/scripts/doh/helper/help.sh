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
    cat <<'EOF'
Helping...

📚 DOH - Project Management System
=============================================

🎯 Quick Start Workflow
  1. /doh:prd-new <name>        - Create a new PRD
  2. /doh:prd-parse <name>      - Convert PRD to epic
  3. /doh:epic-decompose <name> - Break into tasks
  4. /doh:epic-sync <name>      - Push to GitHub
  5. /doh:epic-start <name>     - Start parallel execution

📄 PRD Commands
  /doh:prd-new <name>     - Launch brainstorming for new product requirement
  /doh:prd-parse <name>   - Convert PRD to implementation epic
  /doh:prd-list           - List all PRDs
  /doh:prd-edit <name>    - Edit existing PRD
  /doh:prd-status         - Show PRD implementation status

📚 Epic Commands
  /doh:epic-decompose <name> - Break epic into task files
  /doh:epic-sync <name>      - Push epic and tasks to GitHub
  /doh:epic-oneshot <name>   - Decompose and sync in one command
  /doh:epic-list             - List all epics
  /doh:epic-show <name>      - Display epic and its tasks
  /doh:epic-status [name]    - Show epic progress
  /doh:epic-close <name>     - Mark epic as complete
  /doh:epic-edit <name>      - Edit epic details
  /doh:epic-refresh <name>   - Update epic progress from tasks
  /doh:epic-start <name>     - Launch parallel agent execution

📝 Issue Commands
  /doh:issue-show <num>      - Display issue and sub-issues
  /doh:issue-status <num>    - Check issue status
  /doh:issue-start <num>     - Begin work with specialized agent
  /doh:issue-sync <num>      - Push updates to GitHub
  /doh:issue-close <num>     - Mark issue as complete
  /doh:issue-reopen <num>    - Reopen closed issue
  /doh:issue-edit <num>      - Edit issue details
  /doh:issue-analyze <num>   - Analyze for parallel work streams

🔄 Workflow Commands
  /doh:next               - Show next priority tasks
  /doh:status             - Overall project dashboard
  /doh:standup            - Daily standup report
  /doh:blocked            - Show blocked tasks
  /doh:in-progress        - List work in progress

🔗 Sync Commands
  /doh:sync               - Full bidirectional sync with GitHub
  /doh:import <issue>     - Import existing GitHub issues

🔧 Maintenance Commands
  /doh:validate           - Check system integrity
  /doh:clean              - Archive completed work
  /doh:search <query>     - Search across all content

⚙️  Setup Commands
  /doh:init               - Install dependencies and configure GitHub
  /doh:help               - Show this help message

💡 Tips
  • Use /doh:next to find available work
  • Run /doh:status for quick overview
  • Epic workflow: prd-new → prd-parse → epic-decompose → epic-sync
  • View README.md for complete documentation
EOF
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed
