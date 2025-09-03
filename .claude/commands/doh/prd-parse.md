---
allowed-tools: Bash, Read, Write, LS
---

# PRD Parse

Convert PRD to technical implementation epic.

## Usage
```
/doh:prd-parse <feature_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time
- Use DOH API for numbering operations: `./.claude/scripts/doh/api.sh numbering get_next "epic"`

## Preflight Checklist

Before proceeding, complete these validation steps.
Do not bother the user with preflight checks progress ("I'm not going to ..."). Just do them and move on.

### Validation Steps
1. **Verify <feature_name> was provided as a parameter:**
   - If not, tell user: "❌ <feature_name> was not provided as parameter. Please run: /doh:prd-parse <feature_name>"
   - Stop execution if <feature_name> was not provided

2. **Verify PRD exists:**
   - Check if `.doh/prds/$ARGUMENTS.md` exists
   - If not found, tell user: "❌ PRD not found: $ARGUMENTS. First create it with: /doh:prd-new $ARGUMENTS"
   - Stop execution if PRD doesn't exist

3. **Validate PRD frontmatter:**
   - Verify PRD has valid frontmatter with: name, description, status, created
   - If frontmatter is invalid or missing, tell user: "❌ Invalid PRD frontmatter. Please check: .doh/prds/$ARGUMENTS.md"
   - Show what's missing or invalid

4. **Check for existing epic:**
   - Check if `.doh/epics/$ARGUMENTS/epic.md` already exists
   - If it exists, ask user: "⚠️ Epic '$ARGUMENTS' already exists. Overwrite? (yes/no)"
   - Only proceed with explicit 'yes' confirmation
   - If user says no, suggest: "View existing epic with: /doh:epic-show $ARGUMENTS"

5. **Verify directory permissions:**
   - Ensure `.doh/epics/` directory exists or can be created
   - If cannot create, tell user: "❌ Cannot create epic directory. Please check permissions."

## Instructions

You are a technical lead converting a Product Requirements Document into a detailed implementation epic for: **$ARGUMENTS**

### 1. Read the PRD
- Load the PRD from `.doh/prds/$ARGUMENTS.md`
- Analyze all requirements and constraints
- Understand the user stories and success criteria
- Extract the PRD description from frontmatter

### 2. Technical Analysis
- Identify architectural decisions needed
- Determine technology stack and approaches
- Map functional requirements to technical components
- Identify integration points and dependencies

### 3. File Format with Frontmatter
Create the epic file at: `.doh/epics/$ARGUMENTS/epic.md` with this exact structure:

```markdown
---
name: $ARGUMENTS
number: $(./.claude/scripts/doh/api.sh numbering get_next "epic")
status: backlog
created: [Current ISO date/time]
progress: 0%
prd: .doh/prds/$ARGUMENTS.md
github: [Will be updated when synced to GitHub]
target_version: 1.0.0
file_version: 0.1.0
---

# Epic: $ARGUMENTS

## Overview
Brief technical summary of the implementation approach

## Architecture Decisions
- Key technical decisions and rationale
- Technology choices
- Design patterns to use

## Technical Approach
### Frontend Components
- UI components needed
- State management approach
- User interaction patterns

### Backend Services
- API endpoints required
- Data models and schema
- Business logic components

### Infrastructure
- Deployment considerations
- Scaling requirements
- Monitoring and observability

## Implementation Strategy
- Development phases
- Risk mitigation
- Testing approach

## Task Breakdown Preview
High-level task categories that will be created:
- [ ] Category 1: Description
- [ ] Category 2: Description
- [ ] etc.

## Dependencies
- External service dependencies
- Internal team dependencies
- Prerequisite work

## Success Criteria (Technical)
- Performance benchmarks
- Quality gates
- Acceptance criteria

## Estimated Effort
- Overall timeline estimate
- Resource requirements
- Critical path items
```

### 4. Frontmatter Guidelines
- **name**: Use the exact feature name (same as $ARGUMENTS)
- **status**: Always start with "backlog" for new epics
- **created**: Get REAL current datetime by running: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
- **progress**: Always start with "0%" for new epics
- **prd**: Reference the source PRD file path
- **github**: Leave placeholder text - will be updated during sync

### 5. Output Location
Create the directory structure if it doesn't exist:
- `.doh/epics/$ARGUMENTS/` (directory)
- `.doh/epics/$ARGUMENTS/epic.md` (epic file)

### 6. Quality Validation

Before saving the epic, verify:
- [ ] All PRD requirements are addressed in the technical approach
- [ ] Task breakdown categories cover all implementation areas
- [ ] Dependencies are technically accurate
- [ ] Effort estimates are realistic
- [ ] Architecture decisions are justified

### 7. Post-Creation

After successfully creating the epic:
1. Register the epic in the numbering system: `./.claude/scripts/doh/api.sh numbering register_epic "$(./.claude/scripts/doh/api.sh frontmatter get_field ".doh/epics/$ARGUMENTS/epic.md" "number")" ".doh/epics/$ARGUMENTS/epic.md" "$ARGUMENTS"`
2. Confirm: "✅ Epic created: .doh/epics/$ARGUMENTS/epic.md"
3. Show summary of:
   - Number of task categories identified
   - Key architecture decisions
   - Estimated effort
4. Suggest next step: "Ready to break down into tasks? Run: /doh:epic-decompose $ARGUMENTS"

## Error Recovery

If any step fails:
- Clearly explain what went wrong
- If PRD is incomplete, list specific missing sections
- If technical approach is unclear, identify what needs clarification
- Never create an epic with incomplete information

Focus on creating a technically sound implementation plan that addresses all PRD requirements while being practical and achievable for "$ARGUMENTS".

## IMPORTANT:
- Aim for as few tasks as possible and limit the total number of tasks to 10 or less.
- When creating the epic, identify ways to simplify and improve it. Look for ways to leverage existing functionality instead of creating more code when possible.
