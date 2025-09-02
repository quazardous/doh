#!/bin/bash

# DOH Project Library  
# Pure library for project-wide status and operations (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_PROJECT_LOADED:-}" ]] && return 0
DOH_LIB_PROJECT_LOADED=1

# Constants
readonly PROJECT_LIB_VERSION="1.0.0"

# @description Get overall project status with PRDs, epics, and tasks summary
# @stdout Formatted project status report
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project or errors
project_get_status() {
    echo "Getting status..."
    echo ""
    echo ""

    echo "📊 Project Status"
    echo "================"
    echo ""

    # Get DOH root directory
    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in a DOH project" >&2
        return 1
    }

    # PRD Statistics
    echo "📄 PRDs:"
    local prd_dir="$doh_root/.doh/prds"
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
    local epic_dir="$doh_root/.doh/epics"
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

# @description Get project summary with key metrics
# @stdout Brief project summary
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If not in DOH project
project_get_summary() {
    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    # Count totals
    local prd_count epic_count task_count completed_count
    prd_count=$(find "$doh_root/.doh/prds" -name "*.md" -type f 2>/dev/null | wc -l)
    epic_count=$(find "$doh_root/.doh/epics" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    task_count=$(find "$doh_root/.doh/epics" -name "[0-9]*.md" -type f 2>/dev/null | wc -l)
    
    # Count completed tasks
    completed_count=0
    while IFS= read -r task_file; do
        if [[ -n "$task_file" && -f "$task_file" ]]; then
            local status
            status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            if [[ "$status" == "completed" || "$status" == "closed" ]]; then
                ((completed_count++))
            fi
        fi
    done < <(find "$doh_root/.doh/epics" -name "[0-9]*.md" -type f 2>/dev/null)

    # Calculate completion percentage
    local completion_percent=0
    if [ $task_count -gt 0 ]; then
        completion_percent=$((completed_count * 100 / task_count))
    fi

    echo "📊 Project Summary: $prd_count PRDs, $epic_count epics, $task_count tasks ($completion_percent% complete)"
}

# @description Get recent activity across the project
# @arg $1 number Optional number of days to look back (default: 7)
# @stdout Recent activity report
# @stderr Error messages
# @exitcode 0 If successful
project_get_recent_activity() {
    local days="${1:-7}"
    
    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "📅 Recent Activity (last $days days):"
    echo "======================================"

    # Find recently modified files
    find "$doh_root/.doh" -name "*.md" -type f -mtime -"$days" -printf '%T@ %p\n' 2>/dev/null | \
    sort -nr | head -10 | while read -r timestamp filepath; do
        local filename relative_path
        filename=$(basename "$filepath")
        relative_path=$(realpath --relative-to="$doh_root" "$filepath" 2>/dev/null || echo "$filepath")
        
        # Get file type and status if available
        local file_info=""
        if frontmatter_has "$filepath" 2>/dev/null; then
            local status
            status=$(frontmatter_get_field "$filepath" "status" 2>/dev/null)
            [ -n "$status" ] && file_info=" [$status]"
        fi
        
        echo "  • $relative_path$file_info"
    done
}

# @description Get project health metrics
# @stdout Health metrics report
# @stderr Error messages
# @exitcode 0 If successful
project_get_health() {
    local doh_root
    doh_root=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "🏥 Project Health Check:"
    echo "========================"

    # Check for common issues
    local issues=0

    # Check for tasks without frontmatter
    local invalid_tasks
    invalid_tasks=$(find "$doh_root/.doh/epics" -name "[0-9]*.md" -type f 2>/dev/null | while read -r task_file; do
        if ! frontmatter_has "$task_file" 2>/dev/null; then
            echo "$task_file"
            ((issues++))
        fi
    done)
    
    if [ -n "$invalid_tasks" ]; then
        echo "⚠️  Tasks missing frontmatter:"
        echo "$invalid_tasks" | while read -r task; do
            echo "    • $task"
        done
        ((issues++))
    fi

    # Check for epics without epic.md
    find "$doh_root/.doh/epics" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r epic_dir; do
        if [ ! -f "$epic_dir/epic.md" ]; then
            echo "⚠️  Epic missing epic.md: $(basename "$epic_dir")"
            ((issues++))
        fi
    done

    if [ $issues -eq 0 ]; then
        echo "✅ No issues found - project looks healthy!"
    else
        echo ""
        echo "Found $issues potential issues. Consider running validation."
    fi
}