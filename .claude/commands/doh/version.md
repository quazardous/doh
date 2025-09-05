---
name: version
description: "Unified version management with intelligent create/edit routing"
version: 2.0.0
category: versioning
priority: 1
requires_doh: true
author: Claude
created: 2025-09-01
updated: 2025-09-05
file_version: 0.3.0
allowed-tools: Bash, Read, Write, LS
---

# Version

Unified version management that intelligently creates new versions or edits existing ones based on context and natural language input.

## Usage
```
/doh:version <natural language description>
```

## Examples
- `/doh:version 2.0.0`
- `/doh:version for gitlab integration`
- `/doh:version 1.5.0 add user management features`
- `/doh:version 2.0.0 change status to active`
- `/doh:version major release with breaking changes`
- `/doh:version patch for authentication fixes`

## Instructions

### 1. Parse Input and Route Intelligently

From `$ARGUMENTS`, extract:
- **Explicit version**: "2.0.0", "1.5.0", "3.0.0"
- **Version hints**: "major", "minor", "patch", "next"
- **Action context**: "for", "add", "change status", "update"
- **Feature context**: Feature names, descriptions, scope indicators

### 2. Determine Operation Mode

**Check version existence if explicit version provided:**
```bash
[ -f ".doh/versions/${VERSION}.md" ]
```

**Route decision:**
- **Version exists + context** → **EDIT MODE**
- **Version missing** → **CREATE MODE** 
- **No version specified** → **DISCOVERY MODE** (infer version)

### 3. CREATE MODE - New Version

**When version doesn't exist or needs to be inferred:**

#### **3a. Context Gathering (Silently)**
1. Read `VERSION` file for current version
2. Check `.doh/versions/` for existing versions
3. Check `.doh/prds/` for features that might target this version
4. Look at `.doh/epics/` for work in progress

#### **3b. Discovery Phase (if needed)**
**If version number unclear or context missing:**
```
📋 Version Planning: "$ARGUMENTS"

To create the right version, I need to understand:

1. **What's driving this version?**
   - Major new features or capabilities?
   - Bug fixes and stability improvements?
   - Breaking changes or architecture updates?

2. **Version preference:**
   - Specific version number in mind?
   - Or should I suggest based on changes?

3. **Scope and timeline:**
   - Which features will be included?
   - Any breaking changes expected?

Current version: ${CURRENT_VERSION}
Available versions: ${EXISTING_VERSIONS}

Please provide context.
```

#### **3c. Version Number Determination**
**Smart inference:**
- **"major"** or breaking changes → X+1.0.0
- **"minor"** or new features → X.Y+1.0  
- **"patch"** or bug fixes → X.Y.Z+1
- **Context analysis**: "gitlab integration" → likely major, "auth fixes" → patch

#### **3d. Present Plan and Create**
```
📊 Version Planning Summary
===========================

**Proposed Version:** ${VERSION}
**Type:** ${MAJOR/MINOR/PATCH} (${REASONING})
**Theme:** ${RELEASE_THEME}

**Version Progression:** ${CURRENT_VERSION} → ${VERSION}
**Scope Understanding:** ${DESCRIPTION_FROM_INPUT}

Should I create version ${VERSION}?
1. ✅ Yes, create version ${VERSION}
2. ✏️ Adjust the version details
3. 📝 Let me provide more context
4. ❌ Cancel
```

**If confirmed, use helper:**
```bash
./.claude/scripts/doh/helper.sh version new "${VERSION}" "${DESCRIPTION}"
```

**Post-creation enhancement:**
- Read the created version file
- Update with context from discovery conversation
- Preserve all frontmatter from helper

### 4. EDIT MODE - Existing Version

**When version file exists:**

#### **4a. Load Current State**
```
📋 Current Version: ${VERSION}
========================

**Status:** ${CURRENT_STATUS}
**Description:** ${CURRENT_DESCRIPTION}

**Current Content:**
- Goals: ${GOALS_SUMMARY}
- Features: ${FEATURES_SUMMARY}  
- Breaking Changes: ${BREAKING_CHANGES}

**Related Work:**
- PRDs targeting this version: ${COUNT}
- Active epics: ${COUNT}
```

#### **4b. Parse Edit Intent**
**From natural language, determine:**
- **Status changes**: "active", "completed", "released", "deprecated"
- **Content updates**: "add features", "update notes", "change description"
- **Scope changes**: "include", "add to scope", "remove from scope"

#### **4c. Present Changes**
```
📊 Proposed Changes to Version ${VERSION}
=========================================

**Changes Based On:** "${USER_INPUT}"
**What will be updated:** ${CHANGES_DESCRIPTION}

Apply these changes?
1. ✅ Yes, apply changes
2. ✏️ Edit some changes  
3. 👀 Preview result
4. ❌ Cancel
```

#### **4d. Apply Updates Using Helper**
**Use helper_version_update to touch existing versions:**

**Simple touch (updates timestamp only):**
```bash
# Just touch the version file - automatically updates 'updated' field
./.claude/scripts/doh/helper.sh version update "${VERSION}"
```

**With specific field updates (optional):**
```bash
# Update specific fields only if needed
./.claude/scripts/doh/helper.sh version update "${VERSION}" status:"${NEW_STATUS}"
# Or multiple fields
./.claude/scripts/doh/helper.sh version update "${VERSION}" status:"active" description:"Updated description"
```

**Helper automatically:**
- Updates `updated` field with current timestamp
- Validates version existence
- Preserves all existing structure and content
- Handles atomic file operations

**For content sections beyond frontmatter:**
- Read version file after helper touch
- Enhance content sections based on user input
- All frontmatter is already handled by helper

### 5. DISCOVERY MODE - No Version Specified

**When input like "for gitlab integration" without version:**

#### **5a. Context Analysis**
- Analyze feature scope from description
- Check current version and existing plans
- Determine appropriate version increment

#### **5b. Version Suggestion**
```
📊 Version Analysis for "${ARGUMENTS}"
====================================

**Feature Analysis:**
- Scope: ${FEATURE_SCOPE_ANALYSIS}
- Impact: ${BREAKING_CHANGES_ASSESSMENT}
- Suggested increment: ${VERSION_TYPE}

**Recommended Version:** ${SUGGESTED_VERSION}
**Reasoning:** ${VERSION_REASONING}

Should I create version ${SUGGESTED_VERSION}?
1. ✅ Yes, create ${SUGGESTED_VERSION}
2. 🔄 Suggest different version
3. ✏️ Let me specify version manually
```

**If confirmed, proceed to CREATE MODE with inferred version**

### 6. Post-Operation Summary

```
✅ Version Operation Complete
=============================

**Version:** ${VERSION}
**Operation:** ${CREATED/UPDATED}
**Changes:** ${SUMMARY_OF_CHANGES}

**Files Affected:**
- .doh/versions/${VERSION}.md

**Next Steps:**
• View version: /doh:version-show ${VERSION}
• Plan features: /doh:prd-new <feature> for version ${VERSION}
• Check all versions: /doh:version-status
```

## Important Rules

1. **SMART ROUTING** - Auto-detect create vs edit based on version existence
2. **HELPER DELEGATION** - Always use helpers: `version new` for creation, `version update` for edits
3. **CONTEXT AWARENESS** - Use information from PRD creation and discovery  
4. **NATURAL LANGUAGE** - Parse human descriptions intelligently
5. **NO MANUAL TEMPLATES** - Let helpers handle all version file operations
6. **DISCOVERY WHEN UNCLEAR** - Conduct discovery when context missing
7. **ATOMIC OPERATIONS** - Helpers ensure proper file handling and validation

## Error Handling

- Invalid version format: Show semantic versioning examples
- Version conflicts: Offer edit existing or choose different number
- Ambiguous input: Conduct discovery session
- Helper errors: Show exact error and suggest fixes