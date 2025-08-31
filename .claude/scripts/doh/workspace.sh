#!/bin/bash
source .claude/scripts/doh/lib/dohenv.sh

# Check for reset flag
if [[ "$1" == "--reset" ]]; then
    source .claude/scripts/doh/lib/workspace.sh
    reset_workspace
    exit $?
fi

# Load required libraries
source .claude/scripts/doh/lib/workspace.sh
source .claude/scripts/doh/lib/task.sh

echo "🔧 DOH Workspace Diagnostic"
echo "=========================="
echo ""

# Project Information
project_id="$(get_current_project_id)"
echo "Project: $project_id"
echo "DOH Global Dir: $DOH_GLOBAL_DIR"
echo ""

# Workspace Mode Detection
current_mode="$(detect_workspace_mode)"
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
if [[ -d ".doh/epics" ]]; then
    epic_count=0
    task_count=0
    
    for epic_dir in .doh/epics/*/; do
        [[ ! -d "$epic_dir" ]] && continue
        epic_name="$(basename "$epic_dir")"
        epic_count=$((epic_count + 1))
        
        while IFS= read -r task_file; do
            [[ -z "$task_file" ]] && continue
            task_count=$((task_count + 1))
        done < <(list_epic_tasks "$epic_name")
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