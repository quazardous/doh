#!/bin/bash

# DOH Workflow Helper
# User-facing functions for workflow and project operations

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../lib/workflow.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/project.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/reporting.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/workspace.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/doh.sh"

# Guard against multiple sourcing
[[ -n "${DOH_HELPER_WORKFLOW_LOADED:-}" ]] && return 0
DOH_HELPER_WORKFLOW_LOADED=1

# @description Show next actionable tasks
# @stdout List of tasks ready to work on
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_next() {
    # Call the library function
    workflow_get_next "$@"
}

# @description Show currently active tasks
# @stdout List of in-progress tasks
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_in_progress() {
    # Call the library function
    workflow_get_in_progress "$@"
}

# @description Show blocked tasks needing attention
# @stdout List of blocked tasks with blockers
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_blocked() {
    # Call the library function
    workflow_get_blocked "$@"
}

# @description Generate standup report
# @stdout Standup format report with yesterday/today/blockers
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_standup() {
    # Call the library function
    reporting_generate_standup "$@"
}

# @description Show comprehensive project status
# @stdout Overall project status with all components
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_status() {
    # Call the library function
    project_get_status "$@"
}

# @description Manage workspace and environment
# @arg $1 string Optional --reset flag to reset workspace state
# @stdout Workspace diagnostic and management information
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_workspace() {
    # Call the library function
    workspace_diagnostic "$@"
}

# @description Search across DOH documents
# @arg $1 string Search query (required)
# @stdout Search results across PRDs, epics, and tasks
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If no query provided
helper_workflow_search() {
    local query="$1"
    
    if [ -z "$query" ]; then
        echo "❌ Please provide a search query" >&2
        echo "Usage: helper.sh workflow search <query>" >&2
        return 1
    fi
    
    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    echo "Searching for '$query'..."
    echo ""
    echo ""
    
    echo "🔍 Search results for: '$query'"
    echo "================================"
    echo ""
    
    # Search in PRDs
    if [ -d "$doh_root/.doh/prds" ]; then
        echo "📄 PRDs:"
        local results
        results=$(find "$doh_root/.doh/prds" -name "*.md" -exec grep -l -i "$query" {} \; 2>/dev/null)
        if [ -n "$results" ]; then
            while IFS= read -r file; do
                local name matches
                name=$(basename "$file" .md)
                matches=$(grep -c -i "$query" "$file")
                echo "  • $name ($matches matches)"
            done <<< "$results"
        else
            echo "  No matches"
        fi
        echo ""
    fi
    
    # Search in Epics
    if [ -d "$doh_root/.doh/epics" ]; then
        echo "📚 Epics:"
        local results
        results=$(find "$doh_root/.doh/epics" -name "epic.md" -exec grep -l -i "$query" {} \; 2>/dev/null)
        if [ -n "$results" ]; then
            while IFS= read -r file; do
                local epic_name matches
                epic_name=$(basename "$(dirname "$file")")
                matches=$(grep -c -i "$query" "$file")
                echo "  • $epic_name ($matches matches)"
            done <<< "$results"
        else
            echo "  No matches"
        fi
        echo ""
    fi
    
    # Search in Tasks
    if [ -d "$doh_root/.doh/epics" ]; then
        echo "📝 Tasks:"
        local results
        results=$(find "$doh_root/.doh/epics" -name "[0-9]*.md" -exec grep -l -i "$query" {} \; 2>/dev/null | head -10)
        if [ -n "$results" ]; then
            while IFS= read -r file; do
                local epic_name task_num
                epic_name=$(basename "$(dirname "$file")")
                task_num=$(basename "$file" .md)
                echo "  • Task #$task_num in $epic_name"
            done <<< "$results"
        else
            echo "  No matches"
        fi
    fi
    
    # Summary
    local total
    total=$(find "$doh_root/.doh" -name "*.md" -exec grep -l -i "$query" {} \; 2>/dev/null | wc -l)
    echo ""
    echo "📊 Total files with matches: $total"
    
    return 0
}

# @description Display workflow command help
# @stdout Help information for workflow commands
# @exitcode 0 Always successful
helper_workflow_help() {
    echo "DOH Workflow Management"
    echo "======================"
    echo ""
    echo "Usage: helper.sh workflow <command> [options]"
    echo ""
    echo "Task Flow Commands:"
    echo "  next                    Show next actionable tasks"
    echo "  in-progress            Show currently active tasks"
    echo "  blocked                Show blocked tasks needing attention"
    echo "  standup                Generate standup report"
    echo ""
    echo "Project Commands:"
    echo "  status                 Show comprehensive project status"
    echo "  workspace              Manage workspace and environment"
    echo "  search <query>         Search across DOH documents"
    echo ""
    echo "Help:"
    echo "  help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  helper.sh workflow next               # Show next tasks to work on"
    echo "  helper.sh workflow standup           # Generate daily standup"
    echo "  helper.sh workflow status            # Overall project overview"
    echo "  helper.sh workflow search \"auth\"     # Find auth-related items"
    echo "  helper.sh workflow workspace         # Check workspace health"
    
    return 0
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed