---
allowed-tools: Bash, Read, Write, LS
---

# PRD New

Launch brainstorming for new product requirement document.

## Usage
```
/doh:prd-new <feature_name>
```

## Required Rules

**IMPORTANT:** Before executing this command, read and follow:
- `.claude/rules/datetime.md` - For getting real current date/time

## Preflight Checklist

Before proceeding, complete these validation steps.
Do not bother the user with preflight checks progress ("I'm not going to ..."). Just do them and move on.

### Input Validation
1. **Validate feature name format:**
   - Must contain only lowercase letters, numbers, and hyphens
   - Must start with a letter
   - No spaces or special characters allowed
   - If invalid, tell user: "❌ Feature name must be kebab-case (lowercase letters, numbers, hyphens only). Examples: user-auth, payment-v2, notification-system"

2. **Check for existing PRD:**
   - Check if `.doh/prds/$ARGUMENTS.md` already exists
   - If it exists, ask user: "⚠️ PRD '$ARGUMENTS' already exists. Do you want to overwrite it? (yes/no)"
   - Only proceed with explicit 'yes' confirmation
   - If user says no, suggest: "Use a different name or run: /doh:prd-parse $ARGUMENTS to create an epic from the existing PRD"

3. **Verify directory structure:**
   - Check if `.doh/prds/` directory exists
   - If not, create it first
   - If unable to create, tell user: "❌ Cannot create PRD directory. Please manually create: .doh/prds/"

## Instructions

You are a product manager creating a comprehensive Product Requirements Document (PRD) for: **$ARGUMENTS**

Follow this structured approach:

### 1. Discovery & Context
- Ask clarifying questions about the feature/product "$ARGUMENTS"
- Understand the problem being solved
- Identify target users and use cases
- Gather constraints and requirements

### 1.5. AI-Powered Version Planning
After understanding the scope, perform intelligent version analysis:

1. **Read current project version** from `VERSION` file
2. **Analyze existing versions** in `.doh/versions/` directory  
3. **Determine version impact**:
   - **Patch (x.y.Z+1)**: Bug fixes, minor improvements, documentation
   - **Minor (x.Y+1.0)**: New features, backwards compatible changes
   - **Major (X+1.0.0)**: Breaking changes, major architecture updates
4. **Suggest target_version** based on scope analysis with reasoning
5. **Check version compatibility** with existing version goals
6. **Offer version creation** if no suitable version exists

**Version Suggestion Process:**
```
🎯 AI Version Analysis for "$ARGUMENTS"
=====================================

Current project version: [from VERSION file]
Existing planned versions: [list from .doh/versions/]

📊 Scope Analysis:
- Feature complexity: [High/Medium/Low]
- Breaking changes: [Yes/No]
- API impact: [Major/Minor/None]
- Architecture changes: [Yes/No]

💡 Suggested target_version: [X.Y.Z]
Reasoning: [Explain why this version level is appropriate]

Available options:
1. ✅ Accept suggested version: [X.Y.Z]
2. 🔄 Suggest different version
3. 📋 Create new version [X.Y.Z] interactively
4. 🔍 View existing version details

[Wait for user choice before proceeding]
```

**If user chooses option 3 (Create new version):**
- Launch `/doh:version-new` workflow with PRD context
- Create strategic version file with goals derived from PRD scope  
- Use natural language processing to categorize features into must/should/must-not have
- Link the new version back to the PRD automatically
- Continue with PRD creation using the newly created target_version

### 2. PRD Structure
Create a comprehensive PRD with these sections:

#### Executive Summary
- Brief overview and value proposition

#### Problem Statement
- What problem are we solving?
- Why is this important now?

#### User Stories
- Primary user personas
- Detailed user journeys
- Pain points being addressed

#### Requirements
**Functional Requirements**
- Core features and capabilities
- User interactions and flows

**Non-Functional Requirements**
- Performance expectations
- Security considerations
- Scalability needs

#### Success Criteria
- Measurable outcomes
- Key metrics and KPIs

#### Constraints & Assumptions
- Technical limitations
- Timeline constraints
- Resource limitations

#### Out of Scope
- What we're explicitly NOT building

#### Dependencies
- External dependencies
- Internal team dependencies

### 3. File Format with Frontmatter
Save the completed PRD to: `.doh/prds/$ARGUMENTS.md` with this exact structure:

```markdown
---
name: $ARGUMENTS
description: [Brief one-line description of the PRD]
status: backlog
created: [Current ISO date/time]
target_version: [AI-suggested based on scope analysis]
file_version: 0.1.0
---

# PRD: $ARGUMENTS

## Executive Summary
[Content...]

## Problem Statement
[Content...]

[Continue with all sections...]
```

### 4. Frontmatter Guidelines
- **name**: Use the exact feature name (same as $ARGUMENTS)
- **description**: Write a concise one-line summary of what this PRD covers
- **status**: Always start with "backlog" for new PRDs
- **created**: Get REAL current datetime by running: `date -u +"%Y-%m-%dT%H:%M:%SZ"`
  - Never use placeholder text
  - Must be actual system time in ISO 8601 format
- **target_version**: Use the AI-suggested version from the version planning step
  - Must be valid semantic version (e.g., "1.2.0", "0.3.0")
  - Should align with existing version strategy
  - If new version created, reference that version file

### 5. Quality Checks

Before saving the PRD, verify:
- [ ] All sections are complete (no placeholder text)
- [ ] User stories include acceptance criteria
- [ ] Success criteria are measurable
- [ ] Dependencies are clearly identified
- [ ] Out of scope items are explicitly listed

### 6. Post-Creation

After successfully creating the PRD:
1. Confirm: "✅ PRD created: .doh/prds/$ARGUMENTS.md"
2. Show brief summary of what was captured
3. **Display version information**: "🎯 Target version: [X.Y.Z]"
4. **Link to version file** (if applicable): "📋 Version goals: .doh/versions/[X.Y.Z].md"
5. Suggest next step: "Ready to create implementation epic? Run: /doh:prd-parse $ARGUMENTS"
6. **Additional version actions**: "📊 View version progress: /doh:version-show [X.Y.Z]"

## Error Recovery

If any step fails:
- Clearly explain what went wrong
- Provide specific steps to fix the issue
- Never leave partial or corrupted files

Conduct a thorough brainstorming session before writing the PRD. Ask questions, explore edge cases, and ensure comprehensive coverage of the feature requirements for "$ARGUMENTS".
