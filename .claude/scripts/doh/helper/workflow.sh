#!/bin/bash

# DOH Workflow Helper
# User-facing functions for workflow and project operations

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../lib/task.sh"
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
    local epic_filter="${1:-}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "🔄 Next Available Tasks:"
    echo "======================"
    echo ""

    local search_path="$doh_dir/epics"
    if [ -n "$epic_filter" ]; then
        search_path="$doh_dir/epics/$epic_filter"
        if [ ! -d "$search_path" ]; then
            echo "Error: Epic not found: $epic_filter" >&2
            return 1
        fi
        echo "Epic: $epic_filter"
        echo ""
    fi

    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local count=0
    find "$search_path" -name "[0-9]*.md" -type f 2>/dev/null | sort | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status depends_on task_number title epic_name
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            depends_on=$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null)
            task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
            title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
            
            # Get epic name from path if not filtering by epic
            if [ -z "$epic_filter" ]; then
                local rel_path
                rel_path=$(realpath --relative-to="$doh_dir" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == $doh_dir/epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n "s|^$doh_dir/epics/\([^/]*\)/.*|\1|p")
                fi
            fi

            # Check if task is available (pending status and no blocking dependencies)
            if [[ "$status" == "pending" || "$status" == "open" || -z "$status" ]]; then
                local is_blocked=false
                
                # Check for dependencies
                if [ -n "$depends_on" ] && [ "$depends_on" != "null" ] && [ "$depends_on" != "" ]; then
                    is_blocked=true
                fi
                
                if [ "$is_blocked" = false ]; then
                    local task_info="  • Task $task_number"
                    [ -n "$title" ] && task_info="$task_info: $title"
                    [ -n "$epic_name" ] && task_info="$task_info [$epic_name]"
                    
                    echo "$task_info"
                    ((count++))
                fi
            fi
        fi
    done
    
    echo ""
    local scope_text=""
    [ -n "$epic_filter" ] && scope_text=" in epic '$epic_filter'"
    echo "Found $count available tasks$scope_text"
}

# @description Show currently active tasks
# @stdout List of in-progress tasks
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_in_progress() {
    local epic_filter="${1:-}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "🔄 Tasks In Progress:"
    echo "===================="
    echo ""

    local search_path="$doh_dir/epics"
    if [ -n "$epic_filter" ]; then
        search_path="$doh_dir/epics/$epic_filter"
        if [ ! -d "$search_path" ]; then
            echo "Error: Epic not found: $epic_filter" >&2
            return 1
        fi
        echo "Epic: $epic_filter"
        echo ""
    fi

    local count=0
    find "$search_path" -name "[0-9]*.md" -type f 2>/dev/null | sort | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status task_number title epic_name
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            
            if [ "$status" = "in_progress" ]; then
                task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
                title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
                
                # Get epic name from path if not filtering by epic
                if [ -z "$epic_filter" ]; then
                    local rel_path
                    rel_path=$(realpath --relative-to="$doh_dir" "$task_file" 2>/dev/null)
                    if [[ "$rel_path" == $doh_dir/epics/*/[0-9]*.md ]]; then
                        epic_name=$(echo "$rel_path" | sed -n "s|^$doh_dir/epics/\([^/]*\)/.*|\1|p")
                    fi
                fi

                local task_info="  • Task $task_number"
                [ -n "$title" ] && task_info="$task_info: $title"
                [ -n "$epic_name" ] && task_info="$task_info [$epic_name]"
                
                echo "$task_info"
                ((count++))
            fi
        fi
    done
    
    echo ""
    local scope_text=""
    [ -n "$epic_filter" ] && scope_text=" in epic '$epic_filter'"
    echo "Found $count tasks in progress$scope_text"
}

# @description Show blocked tasks needing attention
# @stdout List of blocked tasks with blockers
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_blocked() {
    local epic_filter="${1:-}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "⏸️  Blocked Tasks:"
    echo "================="
    echo ""

    local search_path="$doh_dir/epics"
    if [ -n "$epic_filter" ]; then
        search_path="$doh_dir/epics/$epic_filter"
        if [ ! -d "$search_path" ]; then
            echo "Error: Epic not found: $epic_filter" >&2
            return 1
        fi
        echo "Epic: $epic_filter"
        echo ""
    fi

    local count=0
    find "$search_path" -name "[0-9]*.md" -type f 2>/dev/null | sort | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status depends_on task_number title epic_name blocked_reason=""
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            depends_on=$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null)
            task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
            title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
            
            # Get epic name from path if not filtering by epic
            if [ -z "$epic_filter" ]; then
                local rel_path
                rel_path=$(realpath --relative-to="$doh_dir" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == $doh_dir/epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n "s|^$doh_dir/epics/\([^/]*\)/.*|\1|p")
                fi
            fi

            local is_blocked=false
            
            # Check if explicitly marked as blocked
            if [ "$status" = "blocked" ]; then
                is_blocked=true
                blocked_reason=" (status: blocked)"
            # Check if has unmet dependencies
            elif [ -n "$depends_on" ] && [ "$depends_on" != "null" ] && [ "$depends_on" != "" ]; then
                is_blocked=true
                blocked_reason=" (has dependencies)"
            fi
            
            if [ "$is_blocked" = true ]; then
                local task_info="  • Task $task_number"
                [ -n "$title" ] && task_info="$task_info: $title"
                [ -n "$epic_name" ] && task_info="$task_info [$epic_name]"
                task_info="$task_info$blocked_reason"
                
                echo "$task_info"
                ((count++))
            fi
        fi
    done
    
    echo ""
    local scope_text=""
    [ -n "$epic_filter" ] && scope_text=" in epic '$epic_filter'"
    echo "Found $count blocked tasks$scope_text"
}

# @description Generate standup report
# @stdout Standup format report with yesterday/today/blockers
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_standup() {
    local target_date="${1:-$(date +%Y-%m-%d)}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "📅 Daily Standup Report - $target_date"
    echo "======================================"
    echo ""

    # Get recently completed tasks (last 2 days)
    echo "✅ Recently Completed:"
    echo "---------------------"
    local completed_count=0
    
    find "$doh_dir/epics" -name "[0-9]*.md" -type f -mtime -2 2>/dev/null | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status task_number title epic_name
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            
            if [ "$status" = "completed" ] || [ "$status" = "closed" ]; then
                task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
                title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
                
                # Get epic name from path
                local rel_path
                rel_path=$(realpath --relative-to="$doh_dir" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == $doh_dir/epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n "s|^$doh_dir/epics/\([^/]*\)/.*|\1|p")
                fi
                
                echo "  • Task $task_number: $title [$epic_name]"
                ((completed_count++))
            fi
        fi
    done
    
    [ $completed_count -eq 0 ] && echo "  No tasks completed recently"
    
    echo ""
    
    # Get currently in-progress tasks
    echo "🔄 Currently In Progress:"
    echo "------------------------"
    local in_progress_count=0
    
    find "$doh_dir/epics" -name "[0-9]*.md" -type f 2>/dev/null | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status task_number title epic_name
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            
            if [ "$status" = "in_progress" ]; then
                task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
                title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
                
                # Get epic name from path
                local rel_path
                rel_path=$(realpath --relative-to="$doh_dir" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == $doh_dir/epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n "s|^$doh_dir/epics/\([^/]*\)/.*|\1|p")
                fi
                
                echo "  • Task $task_number: $title [$epic_name]"
                ((in_progress_count++))
            fi
        fi
    done
    
    [ $in_progress_count -eq 0 ] && echo "  No tasks currently in progress"
    
    echo ""
    
    # Get next priorities (pending tasks with no dependencies)
    echo "📋 Next Priorities:"
    echo "------------------"
    local next_count=0
    
    find "$doh_dir/epics" -name "[0-9]*.md" -type f 2>/dev/null | sort | head -5 | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status depends_on task_number title epic_name
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            depends_on=$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null)
            
            # Check if task is available (pending and no dependencies)
            if [[ "$status" == "pending" || "$status" == "open" || -z "$status" ]]; then
                if [ -z "$depends_on" ] || [ "$depends_on" = "null" ]; then
                    task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
                    title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
                    
                    # Get epic name from path
                    local rel_path
                    rel_path=$(realpath --relative-to="$doh_dir" "$task_file" 2>/dev/null)
                    if [[ "$rel_path" == $doh_dir/epics/*/[0-9]*.md ]]; then
                        epic_name=$(echo "$rel_path" | sed -n "s|^$doh_dir/epics/\([^/]*\)/.*|\1|p")
                    fi
                    
                    echo "  • Task $task_number: $title [$epic_name]"
                    ((next_count++))
                fi
            fi
        fi
    done
    
    [ $next_count -eq 0 ] && echo "  No immediate priorities available"
    
    echo ""
    
    # Get blocked tasks
    echo "⏸️  Blocked Items:"
    echo "----------------"
    local blocked_count=0
    
    find "$doh_dir/epics" -name "[0-9]*.md" -type f 2>/dev/null | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local status depends_on task_number title epic_name
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            depends_on=$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null)
            
            local is_blocked=false
            if [ "$status" = "blocked" ]; then
                is_blocked=true
            elif [ -n "$depends_on" ] && [ "$depends_on" != "null" ]; then
                is_blocked=true
            fi
            
            if [ "$is_blocked" = true ]; then
                task_number=$(frontmatter_get_field "$task_file" "number" 2>/dev/null)
                title=$(frontmatter_get_field "$task_file" "title" 2>/dev/null)
                
                # Get epic name from path
                local rel_path
                rel_path=$(realpath --relative-to="$doh_dir" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == $doh_dir/epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n "s|^$doh_dir/epics/\([^/]*\)/.*|\1|p")
                fi
                
                echo "  • Task $task_number: $title [$epic_name]"
                ((blocked_count++))
            fi
        fi
    done
    
    [ $blocked_count -eq 0 ] && echo "  No blocked tasks"
    
    echo ""
    echo "📊 Summary: $completed_count completed, $in_progress_count in progress, $next_count ready, $blocked_count blocked"
}

# @description Show comprehensive project status
# @stdout Overall project status with all components
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_status() {
    echo "Getting status..."
    echo ""
    echo ""

    echo "📊 Project Status"
    echo "================"
    echo ""

    # Get DOH root directory
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }

    # PRD Statistics
    echo "📄 PRDs:"
    local prd_dir="$doh_dir/prds"
    if [ -d "$prd_dir" ]; then
        local total
        total=$(find "$prd_dir" -name "*.md" -type f 2>/dev/null | wc -l)
        echo "  Total: $total"
    else
        echo "  No PRDs found"
    fi

    echo ""
    
    # Epic Statistics
    echo "📚 Epics:"
    local epic_dir="$doh_dir/epics"
    if [ -d "$epic_dir" ]; then
        local total
        total=$(find "$epic_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
        echo "  Total: $total"
    else
        echo "  No epics found"
    fi

    echo ""
    
    # Task Statistics
    echo "📝 Tasks:"
    if [ -d "$epic_dir" ]; then
        # Count all numbered task files
        local total
        total=$(find "$epic_dir" -name "[0-9]*.md" -type f 2>/dev/null | wc -l)
        
        # Count tasks by status using frontmatter API
        local pending=0 completed=0 in_progress=0 blocked=0
        
        while IFS= read -r task_file; do
            if [[ -n "$task_file" && -f "$task_file" ]]; then
                local status
                status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
                case "$status" in
                    "pending"|"open") ((pending++)) ;;
                    "completed"|"closed") ((completed++)) ;;
                    "in_progress") ((in_progress++)) ;;
                    "blocked") ((blocked++)) ;;
                esac
            fi
        done < <(find "$epic_dir" -name "[0-9]*.md" -type f 2>/dev/null)
        
        echo "  Pending: $pending"
        echo "  In Progress: $in_progress" 
        echo "  Completed: $completed"
        echo "  Blocked: $blocked"
        echo "  Total: $total"
    else
        echo "  No tasks found"
    fi

    return 0
}

# @description Manage workspace and environment
# @arg $1 string Optional --reset flag to reset workspace state
# @stdout Workspace diagnostic and management information
# @stderr Error messages
# @exitcode 0 If successful
helper_workflow_workspace() {
    local reset_flag="${1:-}"
    
    # Check for reset flag
    if [[ "$reset_flag" == "--reset" ]]; then
        reset_workspace
        return $?
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "🔧 DOH Workspace Diagnostic"
    echo "=========================="
    echo ""

    # Project Information
    local project_id
    project_id="$(workspace_get_current_project_id)"
    echo "Project: $project_id"
    echo "DOH Global Dir: $(doh_global_dir)"
    echo ""

    # Workspace Mode Detection
    local current_mode
    current_mode="$(detect_workspace_mode 2>/dev/null || echo "unknown")"
    echo "Current Mode: $current_mode"
    echo ""

    # Workspace State
    echo "📋 Workspace State:"
    load_workspace_state | grep -E "^(mode|current_epic|current_branch|current_worktree|agent_count):" | while IFS=': ' read -r key value; do
        echo "  $key: $value"
    done
    echo ""

    # Git Information
    echo "📚 Git Status:"
    echo "  Branch: $(git branch --show-current 2>/dev/null || echo "unknown")"
    echo "  Worktrees:"
    git worktree list 2>/dev/null | while read -r line; do
        echo "    $line"
    done
    echo ""

    # Workspace Integrity Check
    echo "🔍 Integrity Check:"
    if check_workspace_integrity; then
        echo "  Status: ✅ All checks passed"
    else
        echo "  Status: ⚠️ Issues detected"
        echo ""
        echo "💡 To fix issues, run: /doh:workspace --reset"
    fi
    echo ""

    # Active Tasks Summary
    echo "📊 Active Tasks:"
    if [[ -d "$doh_dir/epics" ]]; then
        local epic_count=0
        local task_count=0
        
        for epic_dir in "$doh_dir/epics"/*/; do
            [[ ! -d "$epic_dir" ]] && continue
            local epic_name
            epic_name="$(basename "$epic_dir")"
            epic_count=$((epic_count + 1))
            
            # Count tasks in this epic
            while IFS= read -r -d '' task_file; do
                [[ -f "$task_file" ]] && task_count=$((task_count + 1))
            done < <(find "$epic_dir" -name "[0-9]*.md" -type f -print0)
        done
        
        echo "  Epics: $epic_count"
        echo "  Total Tasks: $task_count"
    else
        echo "  No epics found"
    fi

    echo ""
    echo "🚀 Available Actions:"
    echo "  /doh:workspace --reset  - Reset workspace state"
    echo "  /doh:next              - Show next available tasks"
    echo "  /doh:epic-list         - List all epics"
    echo "  /doh:status            - Show overall status"
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
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
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
    if [ -d "$doh_dir/prds" ]; then
        echo "📄 PRDs:"
        local results
        results=$(find "$doh_dir/prds" -name "*.md" -exec grep -l -i "$query" {} \; 2>/dev/null)
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
    if [ -d "$doh_dir/epics" ]; then
        echo "📚 Epics:"
        local results
        results=$(find "$doh_dir/epics" -name "epic.md" -exec grep -l -i "$query" {} \; 2>/dev/null)
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
    if [ -d "$doh_dir/epics" ]; then
        echo "📝 Tasks:"
        local results
        results=$(find "$doh_dir/epics" -name "[0-9]*.md" -exec grep -l -i "$query" {} \; 2>/dev/null | head -10)
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
    total=$(find "$doh_dir/.doh" -name "*.md" -exec grep -l -i "$query" {} \; 2>/dev/null | wc -l)
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