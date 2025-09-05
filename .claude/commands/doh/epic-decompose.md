---
allowed-tools: Bash, Read, Write, LS, Task
---

# Epic Decompose

Break epic into concrete, actionable tasks.

## Usage
```
/doh:epic-decompose <feature_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time
- Use DOH helper for task creation: `./.claude/scripts/doh/helper.sh task new <epic-name> <task-title> [target_version]`

## Preflight Checklist

Before proceeding, complete these validation steps.
Do not bother the user with preflight checks progress ("I'm not going to ..."). Just do them and move on.

1. **Verify epic exists:**
   - Check if `.doh/epics/$ARGUMENTS/epic.md` exists
   - If not found, tell user: "❌ Epic not found: $ARGUMENTS. First create it with: /doh:prd-parse $ARGUMENTS"
   - Stop execution if epic doesn't exist

2. **Check for existing tasks:**
   - Check if any numbered task files (001.md, 002.md, etc.) already exist in `.doh/epics/$ARGUMENTS/`
   - If tasks exist, list them and ask: "⚠️ Found {count} existing tasks. Delete and recreate all tasks? (yes/no)"
   - Only proceed with explicit 'yes' confirmation
   - If user says no, suggest: "View existing tasks with: /doh:epic-show $ARGUMENTS"

3. **Validate epic frontmatter:**
   - Verify epic has valid frontmatter with: name, status, created, prd
   - If invalid, tell user: "❌ Invalid epic frontmatter. Please check: .doh/epics/$ARGUMENTS/epic.md"

4. **Check epic status:**
   - If epic status is already "completed", warn user: "⚠️ Epic is marked as completed. Are you sure you want to decompose it again?"

## Instructions

You are decomposing an epic into specific, actionable tasks for: **$ARGUMENTS**

### 1. Read the Epic
- Load the epic from `.doh/epics/$ARGUMENTS/epic.md`
- Understand the technical approach and requirements
- Review the task breakdown preview

### 2. Analyze for Parallel Creation

Determine if tasks can be created in parallel:
- If tasks are mostly independent: Create in parallel using Task agents
- If tasks have complex dependencies: Create sequentially
- For best results: Group independent tasks for parallel creation

### 3. Parallel Task Creation (When Possible)

If tasks can be created in parallel, spawn sub-agents:

```yaml
Task:
  description: "Create task files batch {X}"
  subagent_type: "general-purpose"
  prompt: |
    Create task files for epic: $ARGUMENTS

    Tasks to create:
    - {list of 3-4 tasks for this batch}

    For each task:
    1. Create task: ./.claude/scripts/doh/helper.sh task new "$ARGUMENTS" "[Task Title]" "[target_version]"
       The command outputs the generated TASK_NUM (e.g., "Number: 003")
    2. Extract TASK_NUM from helper output for subsequent operations
    3. Update task fields if needed: ./.claude/scripts/doh/helper.sh task update TASK_NUM parallel:true depends_on:"[001,002]"
    4. Follow task breakdown from epic
    5. Use helper functions for all operations

    The helper.sh task new command will:
    - Auto-generate task number and display it in output
    - Create file with proper frontmatter  
    - Inherit target_version from epic if not specified
    - Handle all numbering registration automatically
    - Output: "Number: XXX" line contains the generated TASK_NUM

    Return: List of files created
```

### 4. Task Creation with Helper

Use the DOH helper for task creation:

```bash
# Create new task - outputs "Number: XXX" line with generated TASK_NUM
./.claude/scripts/doh/helper.sh task new "$ARGUMENTS" "Task Title" "target_version"

# Extract TASK_NUM from the helper output (look for "Number: XXX" line)
# Then update task fields if needed using the extracted TASK_NUM
./.claude/scripts/doh/helper.sh task update TASK_NUM parallel:true depends_on:"[001,002]" conflicts_with:"[003,004]"
```

The helper automatically creates tasks with this structure:
- Auto-generated task number (displayed in "Number: XXX" output line)
- Proper frontmatter with all required fields
- Inherits target_version from epic if not specified
- Standard task content template
- Proper DOH numbering registration

**Important**: The `helper.sh task new` command outputs the generated task number. Look for the "Number: XXX" line to get TASK_NUM for subsequent operations.

### 3. Task Creation Process

1. **Create tasks using helper:**
   ```bash
   ./.claude/scripts/doh/helper.sh task new "$ARGUMENTS" "Task Title" "target_version"
   ```

2. **Task files are automatically saved as:** `.doh/epics/$ARGUMENTS/{task_number}.md`
   - Task numbers are auto-generated and globally sequential
   - Helper handles all file creation and numbering
   - Keep task titles short but descriptive

### 4. Task Field Updates

The helper creates tasks with default values. Update specific fields as needed:

```bash
# Update task fields after creation
./.claude/scripts/doh/helper.sh task update TASK_NUM \
  depends_on:"[001,002]" \
  parallel:true \
  conflicts_with:"[003,004]"
```

- **depends_on**: List task numbers that must complete first (e.g., [001, 002])
- **parallel**: Set to true if this can run alongside other tasks without conflicts
- **conflicts_with**: List task numbers that modify the same files (helps coordination)
- All other fields (name, number, status, created, epic) are set automatically by helper

### 5. Task Types to Consider
- **Setup tasks**: Environment, dependencies, scaffolding
- **Data tasks**: Models, schemas, migrations
- **API tasks**: Endpoints, services, integration
- **UI tasks**: Components, pages, styling
- **Testing tasks**: Unit tests, integration tests
- **Documentation tasks**: README, API docs
- **Deployment tasks**: CI/CD, infrastructure

### 6. Parallelization
Mark tasks with `parallel: true` if they can be worked on simultaneously without conflicts.

### 7. Execution Strategy

Choose based on task count and complexity:

**Small Epic (< 5 tasks)**: Create sequentially for simplicity

**Medium Epic (5-10 tasks)**:
- Batch into 2-3 groups
- Spawn agents for each batch
- Consolidate results

**Large Epic (> 10 tasks)**:
- Analyze dependencies first
- Group independent tasks
- Launch parallel agents (max 5 concurrent)
- Create dependent tasks after prerequisites

Example for parallel execution:
```markdown
Spawning 3 agents for parallel task creation:
- Agent 1: Creating tasks 001-003 (Database layer)
- Agent 2: Creating tasks 004-006 (API layer)
- Agent 3: Creating tasks 007-009 (UI layer)
```

### 8. Task Dependency Validation

When creating tasks with dependencies:
- Ensure referenced dependencies exist (e.g., if Task 003 depends on Task 002, verify 002 was created)
- Check for circular dependencies (Task A → Task B → Task A)
- If dependency issues found, warn but continue: "⚠️ Task dependency warning: {details}"

### 9. Update Epic with Task Summary
After creating all tasks, update the epic file by adding this section:
```markdown
## Tasks Created
- [ ] {TASK_NUM}.md - {Task Title} (parallel: true/false)
- [ ] {TASK_NUM}.md - {Task Title} (parallel: true/false)
- etc.

Total tasks: {count}
Parallel tasks: {parallel_count}
Sequential tasks: {sequential_count}
Estimated total effort: {sum of hours}
```

Also update the epic's frontmatter progress if needed (still 0% until tasks actually start).

### 9. Quality Validation

Before finalizing tasks, verify:
- [ ] All tasks have clear acceptance criteria
- [ ] Task sizes are reasonable (1-3 days each)
- [ ] Dependencies are logical and achievable
- [ ] Parallel tasks don't conflict with each other
- [ ] Combined tasks cover all epic requirements

### 10. Post-Decomposition

After successfully creating tasks:
1. Confirm: "✅ Created {count} tasks for epic: $ARGUMENTS"
2. Show summary:
   - Total tasks created
   - Parallel vs sequential breakdown
   - Total estimated effort
3. Suggest next step: "Ready to sync to GitHub? Run: /doh:epic-sync $ARGUMENTS"

## Error Recovery

If any step fails:
- If task creation partially completes, list which tasks were created
- Provide option to clean up partial tasks
- Never leave the epic in an inconsistent state

Aim for tasks that can be completed in 1-3 days each. Break down larger tasks into smaller, manageable pieces for the "$ARGUMENTS" epic.
