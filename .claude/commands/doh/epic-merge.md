---
allowed-tools: Bash, Read, Write
---

# Epic Merge

Merge completed epic from worktree back to main branch.

## Usage
```
/doh:epic-merge <epic_name>
```

## Quick Check

1. **Verify worktree exists:**
   ```bash
   git worktree list | grep "epic-$ARGUMENTS" || echo "❌ No worktree for epic: $ARGUMENTS"
   ```

2. **Check for active agents:**
   Read `.doh/epics/$ARGUMENTS/execution-status.md`
   If active agents exist: "⚠️ Active agents detected. Stop them first with: /doh:epic-stop $ARGUMENTS"

## Instructions

### 1. Pre-Merge Validation

Navigate to worktree and check status:
```bash
cd ../epic-$ARGUMENTS

# Check for uncommitted changes
if [[ $(git status --porcelain) ]]; then
  echo "⚠️ Uncommitted changes in worktree:"
  git status --short
  echo "Commit or stash changes before merging"
  exit 1
fi

# Check branch status
git fetch origin
git status -sb
```

### 2. Run Tests (Optional but Recommended)

```bash
# Look for test commands
if [ -f package.json ]; then
  npm test || echo "⚠️ Tests failed. Continue anyway? (yes/no)"
elif [ -f Makefile ]; then
  make test || echo "⚠️ Tests failed. Continue anyway? (yes/no)"
fi
```

### 3. Update Epic Documentation

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Update `.doh/epics/$ARGUMENTS/epic.md`:
- Set status to "completed"
- Update completion date
- Add final summary

### 4. Attempt Merge

```bash
# Return to main repository
cd {main-repo-path}

# Ensure main is up to date
git checkout main
git pull origin main

# Attempt merge
echo "Merging epic/$ARGUMENTS to main..."
git merge epic/$ARGUMENTS --no-ff -m "Merge epic: $ARGUMENTS

Completed features:
$(./.claude/scripts/doh/api.sh task list_epic_tasks "$ARGUMENTS" | while read f; do
  echo "- $(./.claude/scripts/doh/api.sh frontmatter get_field "$f" "name")"
done)

Closes epic #$(./.claude/scripts/doh/api.sh frontmatter get_field ".doh/epics/$ARGUMENTS/epic.md" "github" | sed 's/[^0-9]//g')"
```

### 5. Handle Merge Conflicts

If merge fails with conflicts:
```bash
# Check conflict status
git status

echo "
❌ Merge conflicts detected!

Conflicts in:
$(git diff --name-only --diff-filter=U)

Options:
1. Resolve manually:
   - Edit conflicted files
   - git add {files}
   - git commit
   
2. Abort merge:
   git merge --abort
   
3. Get help:
   /doh:epic-resolve $ARGUMENTS

Worktree preserved at: ../epic-$ARGUMENTS
"
exit 1
```

### 6. Post-Merge Cleanup

If merge succeeds:
```bash
# Push to remote
git push origin main

# Clean up worktree
git worktree remove ../epic-$ARGUMENTS
echo "✅ Worktree removed: ../epic-$ARGUMENTS"

# Delete branch
git branch -d epic/$ARGUMENTS
git push origin --delete epic/$ARGUMENTS 2>/dev/null || true

# Archive epic locally
mkdir -p .doh/epics/archived/
mv .doh/epics/$ARGUMENTS .doh/epics/archived/
echo "✅ Epic archived: .doh/epics/archived/$ARGUMENTS"
```

### 7. Update GitHub Issues

Close related issues:
```bash
# Get issue numbers from epic
epic_issue=$(./.claude/scripts/doh/api.sh frontmatter get_field ".doh/epics/archived/$ARGUMENTS/epic.md" "github" | sed 's/[^0-9]//g')

# Close epic issue
gh issue close $epic_issue -c "Epic completed and merged to main"

# Close task issues
for task_file in .doh/epics/archived/$ARGUMENTS/[0-9]*.md; do
  issue_num=$(./.claude/scripts/doh/api.sh frontmatter get_field "$task_file" "github" | grep -oE '[0-9]+')
  if [ ! -z "$issue_num" ]; then
    gh issue close $issue_num -c "Completed in epic merge"
  fi
done
```

### 8. Final Output

```
✅ Epic Merged Successfully: $ARGUMENTS

Summary:
  Branch: epic/$ARGUMENTS → main
  Commits merged: {count}
  Files changed: {count}
  Issues closed: {count}
  
Cleanup completed:
  ✓ Worktree removed
  ✓ Branch deleted
  ✓ Epic archived
  ✓ GitHub issues closed
  
Next steps:
  - Deploy changes if needed
  - Start new epic: /doh:prd-new {feature}
  - View completed work: git log --oneline -20
```

## Conflict Resolution Help

If conflicts need resolution:
```
The epic branch has conflicts with main.

This typically happens when:
- Main has changed since epic started
- Multiple epics modified same files
- Dependencies were updated

To resolve:
1. Open conflicted files
2. Look for <<<<<<< markers
3. Choose correct version or combine
4. Remove conflict markers
5. git add {resolved files}
6. git commit
7. git push

Or abort and try later:
  git merge --abort
```

## Important Notes

- Always check for uncommitted changes first
- Run tests before merging when possible
- Use --no-ff to preserve epic history
- Archive epic data instead of deleting
- Close GitHub issues to maintain sync