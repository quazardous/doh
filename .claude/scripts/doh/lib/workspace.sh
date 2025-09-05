#!/bin/bash

# DOH Workspace Management Library
# Pure library for workspace detection, safety, persistence, and multi-agent coordination

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_WORKSPACE_LOADED:-}" ]] && return 0
DOH_LIB_WORKSPACE_LOADED=1


# @description Ensure project state directory exists
# @arg $1 string Optional project ID (default: current project)
# @stdout Path to the project state directory
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If unable to determine project ID or create directory
ensure_project_state_dir() {
    local project_id="${1:-$(doh_project_id)}"
    
    if [[ -z "$project_id" ]]; then
        echo "Error: Could not determine project ID" >&2
        return 1
    fi
    
    local state_dir="$(doh_global_dir)/projects/$project_id"
    
    mkdir -p "$state_dir"
    mkdir -p "$state_dir/logs"
    mkdir -p "$state_dir/locks"
    
    echo "$state_dir"
}

# @description Register project in global mapping
# @arg $1 string Optional project ID (default: current project)
# @arg $2 string Optional project path (default: current DOH root)
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If project ID or path missing
register_project_mapping() {
    local project_id="${1:-$(doh_project_id)}"
    local project_path="${2:-$(_find_doh_root)}"
    
    if [[ -z "$project_id" || -z "$project_path" ]]; then
        echo "Error: Project ID and path required" >&2
        return 1
    fi
    
    local projects_file="$(doh_global_dir)/projects/PROJECTS.txt"
    local project_entry="$project_id:$project_path"
    
    # Create file if it doesn't exist
    mkdir -p "$(dirname "$projects_file")"
    touch "$projects_file"
    
    # Check if project already registered
    if grep -q "^$project_id:" "$projects_file" 2>/dev/null; then
        # Update existing entry
        sed -i "s|^$project_id:.*|$project_entry|" "$projects_file"
    else
        # Add new entry
        echo "$project_entry" >> "$projects_file"
    fi
}

# @description Detect current workspace mode (branch or worktree)
# @stdout "branch" or "worktree"
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If not in a git repository
detect_workspace_mode() {
    local current_dir="$PWD"
    local git_root
    
    # Find git root
    git_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    
    # Check if we're in a worktree
    if git worktree list 2>/dev/null | grep -q "$(realpath "$current_dir")"; then
        echo "worktree"
    else
        echo "branch"
    fi
}

# @description Get workspace state file path
# @arg $1 string Optional project ID (default: current project)
# @stdout Path to the workspace state file
# @exitcode 0 If successful
# @exitcode 1 If unable to ensure project state directory
get_workspace_state_file() {
    local project_id="${1:-$(doh_project_id)}"
    local state_dir
    
    state_dir="$(ensure_project_state_dir "$project_id")" || return 1
    echo "$state_dir/workspace-state.yml"
}

# @description Load workspace state from file
# @arg $1 string Optional project ID (default: current project)
# @stdout YAML workspace state content
# @exitcode 0 If successful
# @exitcode 1 If unable to get state file path
load_workspace_state() {
    local project_id="${1:-$(doh_project_id)}"
    local state_file
    
    state_file="$(get_workspace_state_file "$project_id")" || return 1
    
    if [[ -f "$state_file" ]]; then
        cat "$state_file"
    else
        # Return default state
        cat <<EOF
---
mode: auto
last_updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
current_epic: null
current_branch: null
current_worktree: null
agent_count: 0
---
EOF
    fi
}

# @description Save workspace state to file
# @arg $1 string YAML content to save
# @arg $2 string Optional project ID (default: current project)
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If unable to acquire lock or write file
save_workspace_state() {
    local yaml_content="$1"
    local project_id="${2:-$(doh_project_id)}"
    local state_file
    
    state_file="$(get_workspace_state_file "$project_id")" || return 1
    
    # Acquire lock before writing
    local lock_file="$state_file.lock"
    local lock_acquired=false
    
    for i in {1..10}; do
        if (set -C; echo $$ > "$lock_file") 2>/dev/null; then
            lock_acquired=true
            break
        fi
        sleep 0.1
    done
    
    if [[ "$lock_acquired" != true ]]; then
        echo "Error: Could not acquire lock for workspace state" >&2
        return 1
    fi
    
    # Write state with error handling
    if echo "$yaml_content" > "$state_file"; then
        rm -f "$lock_file"
        return 0
    else
        rm -f "$lock_file"
        echo "Error: Failed to write workspace state" >&2
        return 1
    fi
}

# @description Choose workspace mode based on task characteristics
# @arg $1 string Name of the epic being worked on
# @arg $2 string Optional forced mode ("branch" or "worktree")
# @stdout Recommended workspace mode
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If another epic is active or unable to load state
choose_workspace_mode() {
    local epic_name="$1"
    local force_mode="$2"
    
    # If mode is forced, use it
    if [[ -n "$force_mode" ]]; then
        echo "$force_mode"
        return 0
    fi
    
    # Load current state
    local current_state
    current_state="$(load_workspace_state)" || return 1
    
    # Check if we have an active epic already
    local current_epic
    current_epic="$(echo "$current_state" | grep "^current_epic:" | sed 's/current_epic: *//')"
    
    if [[ -n "$current_epic" && "$current_epic" != "null" && "$current_epic" != "$epic_name" ]]; then
        echo "Error: Another epic is active: $current_epic" >&2
        echo "Error: Use /doh:workspace --reset to clear state" >&2
        return 1
    fi
    
    # Default logic: use worktree for epics, branch for single tasks
    if [[ -n "$epic_name" ]]; then
        echo "worktree"
    else
        echo "branch"
    fi
}

# @description Check workspace integrity
# @arg $1 string Optional project ID (default: current project)
# @stdout Success message if no issues
# @stderr Issue descriptions and warnings
# @exitcode 0 If no issues found
# @exitcode 1 If integrity issues found
check_workspace_integrity() {
    local project_id="${1:-$(doh_project_id)}"
    local issues=()
    
    # Load workspace state
    local state
    state="$(load_workspace_state "$project_id")" || return 1
    
    local current_worktree
    current_worktree="$(echo "$state" | grep "^current_worktree:" | sed 's/current_worktree: *//')"
    
    # Check if worktree directory exists
    if [[ -n "$current_worktree" && "$current_worktree" != "null" ]]; then
        if [[ ! -d "$current_worktree" ]]; then
            issues+=("Worktree directory missing: $current_worktree")
        fi
    fi
    
    # Check for orphaned worktrees
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local worktree_path
        worktree_path="$(echo "$line" | awk '{print $1}')"
        if [[ ! -d "$worktree_path" ]]; then
            issues+=("Orphaned worktree in git: $worktree_path")
        fi
    done < <(git worktree list 2>/dev/null | tail -n +2)
    
    # Check for uncommitted work
    if [[ -n "$current_worktree" && -d "$current_worktree" ]]; then
        cd "$current_worktree" || return 1
        if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
            issues+=("Uncommitted changes in worktree: $current_worktree")
        fi
        cd - > /dev/null || return 1
    fi
    
    # Report issues
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "⚠️ Workspace integrity issues found:" >&2
        printf "  - %s\n" "${issues[@]}" >&2
        return 1
    fi
    
    echo "✅ Workspace integrity check passed"
    return 0
}

# @description Safety prompt before potentially destructive operations
# @arg $1 string Description of the operation being performed
# @stderr Warning messages and user prompt
# @exitcode 0 If user confirms or DOH_FORCE=1
# @exitcode 1 If user cancels operation
safety_prompt() {
    local operation="$1"
    
    echo "⚠️  About to: $operation" >&2
    echo "   This operation may affect your workspace state." >&2
    
    if [[ "${DOH_FORCE:-}" == "1" ]]; then
        echo "   Proceeding (DOH_FORCE=1)" >&2
        return 0
    fi
    
    echo -n "   Continue? (y/N): " >&2
    read -r response
    
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            echo "   Operation cancelled" >&2
            return 1
            ;;
    esac
}

# @description Reset workspace to clean state
# @arg $1 string Optional project ID (default: current project)
# @stdout Success message
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If user cancels or unable to save state
reset_workspace() {
    local project_id="${1:-$(doh_project_id)}"
    
    safety_prompt "Reset workspace state for project: $project_id" || return 1
    
    # Clean workspace state
    local clean_state
    clean_state="---
mode: auto
last_updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
current_epic: null
current_branch: null
current_worktree: null
agent_count: 0
---"
    
    save_workspace_state "$clean_state" "$project_id" || return 1
    
    # Clean locks
    local state_dir
    state_dir="$(ensure_project_state_dir "$project_id")" || return 1
    rm -f "$state_dir/locks/"*.lock 2>/dev/null || true
    
    echo "✅ Workspace state reset for project: $project_id"
}

# @description Generate comprehensive workspace diagnostic report
# @arg $1 string Optional --reset flag to reset workspace
# @stdout Workspace diagnostic report
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If errors encountered
workspace_diagnostic() {
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
    project_id="$(doh_project_id)"
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