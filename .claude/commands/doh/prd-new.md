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

3. **Verify DOH project structure:**
   - Ensure we're in a DOH project (`.doh/` directory exists)
   - The helper will automatically create `.doh/prds/` directory if needed
   - No manual directory creation required

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

### 3. PRD Creation using Helper Backend
After completing the brainstorming and determining the target_version, create the PRD using the helper backend:

**Step 1: Create PRD with helper**
```bash
./.claude/scripts/doh/helper.sh prd new "$ARGUMENTS" "$DESCRIPTION" "$TARGET_VERSION"
```

Where:
- `$ARGUMENTS` = feature name from command arguments
- `$DESCRIPTION` = brief one-line description gathered during brainstorming
- `$TARGET_VERSION` = version determined from AI analysis

**Step 2: Enhance the generated PRD**
The helper creates a basic PRD template. Now enhance it by:

1. **Read the created file**: `.doh/prds/$ARGUMENTS.md`
2. **Replace template sections** with detailed content from brainstorming:
   - Executive Summary (expand from description)
   - Problem Statement (from discovery phase)
   - User Stories (from requirements gathering)
   - Functional/Non-functional Requirements
   - Success Criteria (measurable outcomes)
   - Constraints & Assumptions
   - Dependencies
   - Out of Scope items

3. **Preserve the frontmatter** (automatically generated by helper):
   - ✅ `name`, `status`, `created`, `updated`, `file_version` auto-generated
   - ✅ `target_version` set from your analysis
   - ✅ `description` set from brainstorming summary

### 4. Quality Enhancement Guidelines

Since the helper automatically handles frontmatter creation with proper timestamps and versioning, focus on content quality:

**Content Requirements:**
- Replace all template placeholders with specific, actionable content
- Ensure user stories include clear acceptance criteria
- Make success criteria measurable with specific metrics
- List concrete dependencies (not vague references)
- Explicitly state what's out of scope to prevent feature creep

**Validation Checklist:**
- [ ] All sections contain real content (no "<!-- comments -->")
- [ ] User stories follow "As a [user], I want [goal] so that [benefit]" format
- [ ] Requirements are testable and verifiable
- [ ] Dependencies include specific teams, systems, or external factors
- [ ] Success criteria include quantifiable metrics

### 5. Post-Creation Confirmation

After successfully enhancing the PRD:

1. **Verify creation**: Check that `.doh/prds/$ARGUMENTS.md` exists and contains enhanced content
2. **Confirm completion**: "✅ PRD brainstorming complete: .doh/prds/$ARGUMENTS.md"
3. **Show summary**: Brief overview of sections completed during brainstorming
4. **Display version**: "🎯 Target version: [determined target_version]"
5. **Version context** (if applicable): "📋 Version goals: .doh/versions/[X.Y.Z].md"
6. **Next steps**: "Ready to create implementation epic? Run: /doh:prd-parse $ARGUMENTS"
7. **Helper commands**: "Manage PRD with: helper.sh prd status, helper.sh prd list"

## Error Recovery

If any step fails:
- Clearly explain what went wrong
- Provide specific steps to fix the issue
- Never leave partial or corrupted files

Conduct a thorough brainstorming session before writing the PRD. Ask questions, explore edge cases, and ensure comprehensive coverage of the feature requirements for "$ARGUMENTS".
