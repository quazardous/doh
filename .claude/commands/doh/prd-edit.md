---
allowed-tools: Read, Write, LS, Bash
---

# PRD Edit

Edit an existing Product Requirements Document.

## Usage
```
/doh:prd-edit <feature_name>
```

## Instructions

### 1. Read Current PRD

Read `.doh/prds/$ARGUMENTS.md`:
- Parse frontmatter (including current `target_version`)
- Read all sections
- Note the original scope and requirements

### 2. Pre-Edit Version Analysis

Display current version context:
```
📋 Current PRD: $ARGUMENTS
🎯 Target Version: [current target_version from frontmatter]
📄 Version Goals: .doh/versions/[target_version].md (if exists)

Current Scope Summary:
[AI-generated brief summary of current PRD scope]
```

### 3. Interactive Edit

Ask user what sections to edit:
- Executive Summary
- Problem Statement  
- User Stories
- Requirements (Functional/Non-Functional)
- Success Criteria
- Constraints & Assumptions
- Out of Scope
- Dependencies

For each edit, track scope changes for version impact analysis.

### 4. AI Version Impact Analysis

After edits are complete, analyze scope changes:

```
🎯 AI Version Analysis for PRD Edit
====================================

Current target_version: [X.Y.Z]
Original scope: [Brief summary]

📊 Detected Changes:
- Added features: [List new requirements]
- Removed features: [List removed items]
- Modified scope: [Describe changes]

💡 Version Impact Assessment:
```

**Scenario 1: Current version still appropriate ✅**
```
- Changes are minor clarifications or details
- No impact on version scope
- Recommendation: Keep target_version: [X.Y.Z]
```

**Scenario 2: Version bump suggested 🔄**
```
- Significant new features added
- Exceeds current patch/minor scope
- Recommendation: Update to target_version: [X.Y+1.Z]
- Reasoning: [Explain why bump is needed]
```

**Scenario 3: Different version needed 🎯**
```
- Scope has fundamentally changed
- Better aligned with existing version: [A.B.C]
- Recommendation: Change target_version to: [A.B.C]
- Reasoning: [Explain alignment with different version]
```

**Scenario 4: New version required 📋**
```
- Scope exceeds all existing versions
- Recommendation: Create new version [X.Y.Z]
- Would you like to create this version now? (yes/no)
```

Ask user: "Accept version recommendation? (yes/no/modify)"

If user chooses "modify":
- Ask for preferred target_version
- Validate against existing versions
- Explain any concerns with manual choice

If user chooses "yes" and new version needed:
- Launch `/doh:version-new` workflow with PRD context
- Create strategic version file with updated scope
- Link back to PRD automatically

### 5. Update PRD

Get current datetime: `date -u +"%Y-%m-%dT%H:%M:%SZ"`

Update PRD file:
- Preserve frontmatter except `updated` and `target_version` fields
- Apply user's edits to selected sections
- Update `updated` field with current datetime
- Update `target_version` based on AI analysis and user confirmation
- Add version change comment if target_version changed:
  ```markdown
  <!-- Version History
  - Changed from [old_version] to [new_version] on [date]
  - Reason: [AI reasoning or user override reason]
  -->
  ```

### 6. Check Epic Impact

If PRD has associated epic:
- Notify user: "This PRD has epic: {epic_name}"
- Ask: "Epic may need updating based on PRD changes. Review epic? (yes/no)"
- If yes, show: "Review with: /doh:epic-edit {epic_name}"

### 7. Output

```
✅ Updated PRD: $ARGUMENTS
  Sections edited: {list_of_sections}
  
📊 Version Impact:
  Previous version: {old_target_version}
  Current version: {new_target_version}
  {If changed}: Reason: {version_change_reason}
  
{If has epic}: ⚠️ Epic may need review: {epic_name}

Next steps:
- {If version changed}: Review version goals: /doh:version-show {new_target_version}
- {If has epic}: Update epic: /doh:epic-edit {epic_name}
- Parse to epic: /doh:prd-parse $ARGUMENTS
```

## Important Notes

Preserve original creation date.
Keep version history in frontmatter if needed.
Follow `/rules/frontmatter-operations.md`.

## AI Version Analysis Details

### Scope Change Detection
The AI should analyze semantic meaning of changes:
- **Feature additions**: New user stories, requirements, or capabilities
- **Feature removals**: Deleted or descoped items  
- **Scope shifts**: Changes in focus or primary objectives
- **Complexity changes**: Simple → Complex or vice versa

### Version Impact Mapping
```
Change Type → Version Impact
- Typos/clarifications → No change
- Minor feature tweaks → No change
- Bug fixes added → Patch version
- New features → Minor version
- Breaking changes → Major version
- Complete pivot → Different version
```

### Natural Language Understanding
AI should comprehend various edit descriptions:
- "Add enterprise SSO support" → Feature addition
- "Remove payment processing for now" → Scope reduction
- "Focus on MVP features only" → Scope simplification
- "Include multi-tenancy" → Major feature addition
- "Fix security requirements" → Requirement clarification

### Version Compatibility Check
When suggesting versions, AI should:
1. Load all `.doh/versions/*.md` files
2. Compare PRD scope with each version's goals
3. Find best match or suggest new version
4. Explain reasoning clearly to user

### Examples of Version Analysis

**Example 1 - No Change Needed:**
```
Original: "User authentication with email/password"
Edit: "User authentication with email/password and remember me"
Impact: Minor addition, current version appropriate
```

**Example 2 - Version Bump:**
```
Original: "Basic reporting"
Edit: "Advanced analytics with ML predictions"
Impact: Major feature expansion, suggest minor version bump
```

**Example 3 - Different Version:**
```
Original: "E-commerce checkout" (target: 1.0.0)
Edit: "User profile management" 
Impact: Complete scope change, suggest version 0.4.0 focused on user features
```

**Example 4 - New Version Needed:**
```
Original: "Bug fixes" (target: 0.1.1)
Edit: "Complete API v2 with GraphQL"
Impact: Major new scope, create version 2.0.0
```