#!/bin/bash

# DOH Reporting Helper
# Helper for report generation operations

# Source core library dependencies
source "${DOH_ROOT}/.claude/scripts/doh/lib/doh.sh"
source "${DOH_ROOT}/.claude/scripts/doh/lib/frontmatter.sh"

# @description Generate daily standup report
# @arg $1 string Optional date (YYYY-MM-DD format, default: today)
# @stdout Formatted standup report
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If error occurred
helper_reporting_generate_standup() {
    local target_date="${1:-$(date +%Y-%m-%d)}"
    
    local project_root
    project_root=$(doh_project_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
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
                rel_path=$(realpath --relative-to="$project_root" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == *epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n 's|.*epics/\([^/]*\)/.*|\1|p')
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
                rel_path=$(realpath --relative-to="$project_root" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == *epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n 's|.*epics/\([^/]*\)/.*|\1|p')
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
                    rel_path=$(realpath --relative-to="$project_root" "$task_file" 2>/dev/null)
                    if [[ "$rel_path" == *epics/*/[0-9]*.md ]]; then
                        epic_name=$(echo "$rel_path" | sed -n 's|.*epics/\([^/]*\)/.*|\1|p')
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
                rel_path=$(realpath --relative-to="$project_root" "$task_file" 2>/dev/null)
                if [[ "$rel_path" == *epics/*/[0-9]*.md ]]; then
                    epic_name=$(echo "$rel_path" | sed -n 's|.*epics/\([^/]*\)/.*|\1|p')
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

# @description Generate detailed epic summary report
# @arg $1 string Epic name
# @stdout Formatted epic summary report
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If epic not found
helper_reporting_generate_epic_summary() {
    local epic_name="$1"
    
    if [ -z "$epic_name" ]; then
        echo "Usage: helper_reporting_generate_epic_summary <epic-name>" >&2
        return 1
    fi

    local project_root
    project_root=$(doh_project_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local epic_file="$doh_dir/epics/$epic_name/epic.md"
    
    if [ ! -f "$epic_file" ]; then
        echo "Error: Epic not found: $epic_name" >&2
        return 1
    fi

    echo "📚 Epic Summary Report: $epic_name"
    echo "================================="
    echo ""

    # Epic metadata
    local status progress target_version created prd
    status=$(frontmatter_get_field "$epic_file" "status" 2>/dev/null)
    progress=$(frontmatter_get_field "$epic_file" "progress" 2>/dev/null)
    target_version=$(frontmatter_get_field "$epic_file" "target_version" 2>/dev/null)
    created=$(frontmatter_get_field "$epic_file" "created" 2>/dev/null)
    prd=$(frontmatter_get_field "$epic_file" "prd" 2>/dev/null)

    echo "📋 Epic Details:"
    [ -n "$status" ] && echo "  Status: $status"
    [ -n "$progress" ] && echo "  Progress: $progress"
    [ -n "$target_version" ] && echo "  Target Version: $target_version"
    [ -n "$created" ] && echo "  Created: $created"
    [ -n "$prd" ] && echo "  PRD: $prd"
    
    echo ""

    # Task breakdown by status
    echo "📊 Task Breakdown:"
    local total=0 pending=0 in_progress=0 completed=0 blocked=0
    
    find "$doh_dir/epics/$epic_name" -name "[0-9]*.md" -type f 2>/dev/null | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local task_status
            task_status=$(frontmatter_get_field "$task_file" "status" 2>/dev/null)
            
            ((total++))
            case "$task_status" in
                "pending"|"open"|"") ((pending++)) ;;
                "in_progress") ((in_progress++)) ;;
                "completed"|"closed") ((completed++)) ;;
                "blocked") ((blocked++)) ;;
            esac
        fi
    done
    
    echo "  Total Tasks: $total"
    echo "  Pending: $pending"
    echo "  In Progress: $in_progress"
    echo "  Completed: $completed"
    echo "  Blocked: $blocked"
    
    # Progress calculation
    if [ $total -gt 0 ]; then
        local completion_percent=$((completed * 100 / total))
        echo "  Completion: $completion_percent%"
        
        # Progress bar
        local filled=$((completion_percent * 20 / 100))
        local empty=$((20 - filled))
        echo -n "  Progress: ["
        [ $filled -gt 0 ] && printf '%0.s█' $(seq 1 $filled)
        [ $empty -gt 0 ] && printf '%0.s░' $(seq 1 $empty)
        echo "] $completion_percent%"
    fi
    
    echo ""
    
    # Recent activity in this epic
    echo "📅 Recent Activity (last 7 days):"
    find "$doh_dir/epics/$epic_name" -name "*.md" -type f -mtime -7 -printf '%T@ %p\n' 2>/dev/null | \
    sort -nr | head -5 | while read -r timestamp filepath; do
        local filename
        filename=$(basename "$filepath")
        echo "  • $filename"
    done
    
    echo ""
    echo "💡 Use 'epic-status.sh $epic_name' for detailed task status"
}

# @description Format progress bar
# @arg $1 number Completed count
# @arg $2 number Total count
# @stdout Formatted progress bar
# @exitcode 0 Always successful
_helper_reporting_format_progress() {
    local completed="${1:-0}"
    local total="${2:-1}"
    
    if [ "$total" -eq 0 ]; then
        echo "[████████████████████] N/A"
        return 0
    fi
    
    local percent=$((completed * 100 / total))
    local filled=$((percent * 20 / 100))
    local empty=$((20 - filled))
    
    echo -n "["
    [ $filled -gt 0 ] && printf '%0.s█' $(seq 1 $filled)
    [ $empty -gt 0 ] && printf '%0.s░' $(seq 1 $empty)
    echo "] $percent% ($completed/$total)"
}

# @description Get recent activity across project
# @arg $1 number Optional number of days (default: 7)
# @stdout Recent activity list
# @stderr Error messages
# @exitcode 0 If successful
helper_reporting_get_recent_activity() {
    local days="${1:-7}"
    
    local project_root
    project_root=$(doh_project_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "📅 Recent Activity (last $days days):"
    echo "===================================="
    echo ""

    # Find recently modified files
    find "$doh_dir" -name "*.md" -type f -mtime -"$days" -printf '%T@ %p\n' 2>/dev/null | \
    sort -nr | head -15 | while read -r timestamp filepath; do
        local filename relative_path file_type=""
        filename=$(basename "$filepath")
        relative_path=$(realpath --relative-to="$project_root" "$filepath" 2>/dev/null || echo "$filepath")
        
        # Determine file type
        case "$relative_path" in
            *epics/*/epic.md) file_type="[epic]" ;;
            *epics/*/[0-9]*.md) file_type="[task]" ;;
            *prds/*.md) file_type="[prd]" ;;
            *) file_type="[doc]" ;;
        esac
        
        echo "  • $relative_path $file_type"
    done
}