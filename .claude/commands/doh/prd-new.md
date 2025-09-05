---
allowed-tools: Bash, Read, Write, LS
---

# PRD New

Create a new Product Requirements Document (PRD) with comprehensive understanding of the feature context.

## Usage
```
/doh:prd-new <natural language description>
```

## Examples
- `/doh:prd-new gitlab support`
- `/doh:prd-new add OAuth2 authentication to the API`
- `/doh:prd-new version 2.0 database migration`
- `/doh:prd-new user-notifications`

## Instructions

### 1. Initial Context Gathering

From `$ARGUMENTS`, begin understanding the feature request, but first gather project context:

**Silently check (don't announce these checks):**
1. Read `VERSION` file to understand current version
2. Check `.doh/versions/` for planned versions and roadmap
3. List `.doh/prds/` to see existing PRDs and avoid duplication
4. Check `.doh/epics/` for related work in progress

### 2. Comprehensive Discovery Phase (MANDATORY)

**ALWAYS conduct a thorough discovery session before suggesting parameters:**

```
📋 Let's plan the PRD for: "$ARGUMENTS"

Before we create the PRD, I need to understand the full context:

1. **What problem does this solve?**
   - Who are the primary users affected?
   - What pain points does it address?
   - Why is this important now?

2. **What's the scope and goal?**
   - Core functionality needed?
   - Expected outcomes?
   - Success metrics?

3. **Where does this fit in the roadmap?**
   - Is this a bug fix, new feature, or breaking change?
   - Should this target an existing version or need a new one?
   - Dependencies on other features?

4. **Any constraints or considerations?**
   - Technical limitations?
   - Timeline requirements?
   - Security/performance needs?

Please provide context on these points (answer what you can, skip what's not relevant).
```

### 3. Intelligent Parameter Synthesis

After gathering context, synthesize the information:

**Determine Feature Name:**
- **MUST capture the main idea/purpose** (not just literal conversion)
- Convert to meaningful kebab-case that conveys intent
- Examples of good naming:
  - "gitlab support" → `gitlab-integration` (not just "gitlab-support")
  - "fix login bugs" → `auth-stability` (captures the goal)
  - "make it faster" → `performance-optimization` (descriptive of purpose)
  - "add users page" → `user-management` (broader feature context)
- Ensure it's unique and check against existing PRDs
- Should be self-documenting (someone should understand the feature from the name)

**Craft Description:**
- Concise summary (max 100 chars) that expands on the name
- Captures the business value and outcome
- Complements the feature name with additional context

**Analyze Version Impact:**
Based on discovery answers, determine:
- **Patch (x.y.Z+1)**: Bug fixes, minor improvements
- **Minor (x.Y+1.0)**: New features, backwards compatible
- **Major (X+1.0.0)**: Breaking changes, major features

**Check existing versions:**
```bash
# Check if suitable version exists
ls -la .doh/versions/
```

If no suitable version exists, suggest creating one first.

### 4. Present Comprehensive Understanding (MANDATORY)

**Show full context before creating PRD:**

```
📊 PRD Planning Summary for "$ARGUMENTS"
=====================================

**Understanding of the Feature:**
${SUMMARIZE_PROBLEM_AND_SOLUTION}

**Proposed PRD Parameters:**
   Feature name: ${FEATURE_NAME}
   Description: ${DESCRIPTION}
   Target version: ${TARGET_VERSION} (${VERSION_REASONING})

**Scope Assessment:**
   - Complexity: ${HIGH/MEDIUM/LOW}
   - User impact: ${DESCRIPTION}
   - Breaking changes: ${YES/NO}
   - Dependencies: ${LIST_OR_NONE}

**Roadmap Alignment:**
   - Current version: ${CURRENT_VERSION}
   - Fits in version: ${TARGET_VERSION}
   - Related PRDs: ${LIST_OR_NONE}
   - Related epics: ${LIST_OR_NONE}

**Key Requirements Identified:**
   ${BULLET_LIST_OF_KEY_REQUIREMENTS}

Is this understanding correct? Should I proceed with these parameters?
1. ✅ Yes, create the PRD
2. 📝 Let me provide more context
3. ✏️ Adjust the parameters
4. 📋 Create a new version first
```

### 5. Handle User Response

Based on user choice:

**Option 1 (Proceed):**
- Continue to validation and creation

**Option 2 (More context):**
- Ask specific follow-up questions
- Refine understanding
- Present updated summary

**Option 3 (Adjust):**
```
Which parameters need adjustment?
- Feature name (current: ${FEATURE_NAME})
- Description (current: ${DESCRIPTION})  
- Target version (current: ${TARGET_VERSION})
- Other aspects of scope/requirements

Please provide the corrections.
```

**Option 4 (New version):**
- **DELEGATE to version command**: Execute `/doh:version-new for ${FEATURE_NAME} - ${DESCRIPTION}`
- **Let version-new handle:** Version number inference, discovery, and creation
- After version creation completes, return to PRD creation with the created version
- DO NOT manually create version files or specify version numbers

### 6. Pre-Creation Validation

**After confirmation, silently validate:**

1. **Check PRD doesn't exist:**
   ```bash
   [ -f ".doh/prds/${FEATURE_NAME}.md" ]
   ```
   If exists: "⚠️ PRD '${FEATURE_NAME}' already exists. Options:
   - Edit existing: /doh:prd-edit ${FEATURE_NAME}
   - Use different name
   - Overwrite (loses content)"

2. **Validate feature name:**
   - Must be kebab-case
   - Must start with letter
   - No special characters

3. **Verify target version exists (if specified):**
   ```bash
   [ -f ".doh/versions/${TARGET_VERSION}.md" ]
   ```
   If not: 
   ```
   Version ${TARGET_VERSION} doesn't exist yet.
   
   Should I create it for you?
   1. ✅ Yes, create version ${TARGET_VERSION}
   2. 🔄 Choose a different version
   3. ❌ Cancel PRD creation
   ```
   
   If user agrees, **DELEGATE**: `/doh:version for ${FEATURE_NAME} - ${DESCRIPTION}`
   
   **Let /doh:version handle:**
   - Version number inference from feature scope
   - Discovery of appropriate version increment
   - Context-aware version creation

### 7. Create PRD Using Helper (ONLY After Full Understanding)

**MANDATORY: Use helper script with EXACT parameter order:**

```bash
./.claude/scripts/doh/helper.sh prd new "${FEATURE_NAME}" "${DESCRIPTION}" "${TARGET_VERSION}"
```

**Parameter Order (NEVER CHANGE):**
1. `prd` - command group
2. `new` - subcommand  
3. `"${FEATURE_NAME}"` - required, kebab-case
4. `"${DESCRIPTION}"` - optional, brief description or ""
5. `"${TARGET_VERSION}"` - optional, version or ""

### 8. Post-Creation Enhancement

After successful creation:

```
✅ PRD created: .doh/prds/${FEATURE_NAME}.md

Based on our discovery discussion, would you like me to:
1. 📝 Populate the PRD with the requirements we discussed
2. ✏️ Keep as template for you to fill
3. 🚀 Start creating the epic immediately
```

If option 1 chosen:
- Read the created PRD
- Fill in sections based on discovery conversation:
  - Problem statement from user's answers
  - User stories from identified users
  - Requirements from discussed scope
  - Success criteria from goals
  - Dependencies identified
  - Constraints mentioned
- Preserve all frontmatter

### 9. Final Summary

```
✅ PRD Creation Complete
========================

**Created:** .doh/prds/${FEATURE_NAME}.md
**Description:** ${DESCRIPTION}
**Target Version:** ${TARGET_VERSION}

**Key Points Captured:**
${BULLET_LIST_OF_MAIN_REQUIREMENTS}

**Next Steps:**
• Review and refine: /doh:prd-edit ${FEATURE_NAME}
• Create epic: /doh:prd-parse ${FEATURE_NAME}
• View all PRDs: ./.claude/scripts/doh/helper.sh prd list
• Check version plan: /doh:version-show ${TARGET_VERSION}
```

## Important Rules

1. **UNDERSTAND FIRST** - Never create without comprehensive context
2. **ROADMAP AWARENESS** - Always check versions and existing work
3. **USER CONFIRMATION** - Explicit approval required at each step
4. **HELPER ONLY** - Always use helper script, never manual creation
5. **EXACT PARAMETERS** - Helper requires: name, description, target_version (in that order)
6. **VALIDATE EVERYTHING** - Check names, versions, duplicates before creation
7. **VERSION DELEGATION** - NEVER manually create version files; always use `/doh:version-new` or `/doh:version-edit`

## Error Handling

- Show exact helper errors
- Never attempt manual recovery
- Suggest `./.claude/scripts/doh/helper.sh prd help` for issues
- If version doesn't exist, **DELEGATE to /doh:version** with feature context (let it infer version)
- If version needs editing, **DELEGATE to /doh:version** with update context
- If PRD exists, never overwrite without explicit confirmation