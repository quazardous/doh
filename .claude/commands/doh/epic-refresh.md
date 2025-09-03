---
allowed-tools: Read, Write, LS
---

# Epic Refresh

Update epic progress based on task states.

## Usage
```
/doh:epic-refresh <epic_name>
```

## Instructions

### 1. Count Task Status

Scan all task files in `.doh/epics/$ARGUMENTS/`:
- Count total tasks
- Count tasks with `status: closed`
- Count tasks with `status: open`
- Count tasks with work in progress

### 2. Calculate Progress

```
progress = (closed_tasks / total_tasks) * 100
```

Round to nearest integer.

### 3. Update GitHub Task List

If epic has GitHub issue, sync task checkboxes:

```bash
# Get epic issue number from epic.md frontmatter
epic_issue={extract_from_github_field}

if [ ! -z "$epic_issue" ]; then
  # Get current epic body
  gh issue view $epic_issue --json body -q .body > /tmp/epic-body.md
  
  # For each task, check its status and update checkbox
  for task_file in .doh/epics/$ARGUMENTS/[0-9]*.md; do
    task_issue=$(./.claude/scripts/doh/api.sh frontmatter get_field "$task_file" "github" | grep -oE '[0-9]+$')
    task_status=$(./.claude/scripts/doh/api.sh frontmatter get_field "$task_file" "status")
    
    if [ "$task_status" = "closed" ]; then
      # Mark as checked
      sed -i "s/- \[ \] #$task_issue/- [x] #$task_issue/" /tmp/epic-body.md
    else
      # Ensure unchecked (in case manually checked)
      sed -i "s/- \[x\] #$task_issue/- [ ] #$task_issue/" /tmp/epic-body.md
    fi
  done
  
  # Update epic issue
  gh issue edit $epic_issue --body-file /tmp/epic-body.md
fi
```

### 4. Determine Epic Status

- If progress = 0% and no work started: `backlog`
- If progress > 0% and < 100%: `in-progress`
- If progress = 100%: `completed`

### 5. Update Epic

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Update epic.md frontmatter:
```yaml
status: {calculated_status}
progress: {calculated_progress}%
updated: {current_datetime}
```

### 6. Output

```
🔄 Epic refreshed: $ARGUMENTS

Tasks:
  Closed: {closed_count}
  Open: {open_count}
  Total: {total_count}
  
Progress: {old_progress}% → {new_progress}%
Status: {old_status} → {new_status}
GitHub: Task list updated ✓

{If complete}: Run /doh:epic-close $ARGUMENTS to close epic
{If in progress}: Run /doh:next to see priority tasks
```

## Important Notes

This is useful after manual task edits or GitHub sync.
Don't modify task files, only epic status.
Preserve all other frontmatter fields.