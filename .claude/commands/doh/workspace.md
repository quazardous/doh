---
allowed-tools: Bash, Read
---

# Workspace Diagnostic and Management

Show current workspace state and diagnostic information, or reset corrupted workspace.

## Usage
```
/doh:workspace           # Show diagnostic
/doh:workspace --reset   # Reset workspace state
```

## Instructions

### 1. Check for Reset Flag

```bash
if [[ "$ARGUMENTS" == "--reset" ]]; then
  # Execute reset operation
  bash .claude/scripts/doh/helper.sh workflow workspace --reset
  exit $?
fi
```

### 2. Load Workspace Libraries

```bash
# Use helper system instead of direct library sourcing
bash .claude/scripts/doh/helper.sh workflow workspace
```

### 3. Display Workspace Diagnostic

```bash
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
# Get workspace state fields using DOH API
for field in mode current_epic current_branch current_worktree agent_count; do
  value=$(./.claude/scripts/doh/api.sh workspace get_field "$field")
  echo "  $field: $value"
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
```

### 4. Show Next Actions

```bash
echo ""
echo "🚀 Available Actions:"
echo "  /doh:workspace --reset  - Reset workspace state"
echo "  /doh:next              - Show next available tasks"
echo "  /doh:epic-list         - List all epics"
echo "  /doh:status            - Show overall status"
```

## Output Format

### Normal Diagnostic Output
```
🔧 DOH Workspace Diagnostic
==========================

Project: my-project
DOH Global Dir: /home/user/.doh

Current Mode: worktree

📋 Workspace State:
  mode: worktree
  current_epic: feature-auth
  current_branch: null
  current_worktree: ../epic-feature-auth
  agent_count: 2

📚 Git Status:
  Branch: main
  Worktrees:
    /home/user/project/.git  abcd123 [main]
    /home/user/epic-feature-auth  efgh456 [epic/feature-auth]

🔍 Integrity Check:
  Status: ✅ All checks passed

📊 Active Tasks:
  Epics: 2
  Total Tasks: 8

🚀 Available Actions:
  /doh:workspace --reset  - Reset workspace state
  /doh:next              - Show next available tasks
  /doh:epic-list         - List all epics
  /doh:status            - Show overall status
```

### Reset Output
```
⚠️  About to: Reset workspace state for project: my-project
   This operation may affect your workspace state.
   Continue? (y/N): y
✅ Workspace state reset for project: my-project
```

## Error Handling

```bash
# If not in DOH project
echo "❌ Error: Not in a DOH project (no .doh/ directory at git repo root)"
echo "Initialize DOH project with: /doh:init"
exit 1

# If workspace corruption detected
echo "⚠️ Workspace corruption detected:"
echo "  - Orphaned worktree: ../epic-old-feature"
echo "  - Uncommitted changes in: ../epic-feature-auth"
echo ""
echo "Run '/doh:workspace --reset' to fix these issues"
```

## Important Notes

- This command is safe to run frequently for monitoring
- Reset operation requires confirmation unless DOH_FORCE=1
- Diagnostic information helps debug workspace issues
- Shows both current state and git reality for comparison