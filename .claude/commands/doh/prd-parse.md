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

**IMPORTANT:** This command uses the DOH helper system:
- Epic creation is handled by `helper.sh epic create` which manages all frontmatter, numbering, and file operations
- Helper automatically handles datetime, numbering, and PRD reference linking
- Focus on PRD analysis and technical content enhancement rather than file structure

## Preflight Checklist

Simple validation since the helper handles most checks:

### Validation Steps
1. **Verify <feature_name> was provided:**
   - If not, tell user: "❌ <feature_name> was not provided. Please run: /doh:prd-parse <feature_name>"

2. **Verify PRD exists:**
   - Check if `.doh/prds/$ARGUMENTS.md` exists
   - If not found, tell user: "❌ PRD not found: $ARGUMENTS. First create it with: /doh:prd-new $ARGUMENTS"

**Note:** The helper will handle epic conflict checking, directory creation, numbering, and frontmatter validation automatically.

## Instructions

You are a technical lead converting a Product Requirements Document into a detailed implementation epic for: **$ARGUMENTS**

### 1. Read and Analyze PRD
- Load the PRD from `.doh/prds/$ARGUMENTS.md`
- Analyze all requirements and constraints
- Understand the user stories and success criteria
- Extract the PRD description and key value proposition
- Identify technical complexity and scope

### 2. Create Epic Using Helper
Use the helper system to create the epic with analyzed context:

```bash
bash .claude/scripts/doh/helper.sh epic create "$ARGUMENTS" "SYNTHESIZED_DESCRIPTION_FROM_PRD"
```

**Note:** The helper will automatically extract `target_version` from the PRD frontmatter if it exists. You can also explicitly provide a target version as a third argument if needed.

Where `SYNTHESIZED_DESCRIPTION_FROM_PRD` should be a concise technical summary combining:
- Core value proposition from PRD
- Primary user benefits
- Key technical challenges
- Implementation scope (e.g., "Implement secure user authentication with OAuth2 integration, including login/logout flows, session management, and role-based access control")

**Target Version Handling:**
- 🔍 **Auto-extraction**: Helper automatically reads `target_version` from PRD frontmatter
- 📋 **Explicit override**: Can provide version as 3rd argument: `epic create "name" "desc" "1.2.0"`
- 🎯 **Smart defaults**: Uses PRD version or falls back to current project version

### 3. Epic Enhancement
After the helper creates the basic epic structure, enhance the epic file with detailed technical analysis by adding these sections to the generated content:

**Architecture Decisions:**
- Key technical decisions and rationale based on PRD analysis
- Technology choices that best fit the requirements
- Design patterns to use

**Technical Approach:**
- Frontend components needed (if applicable)
- Backend services required
- API endpoints and data models
- Integration points with existing systems

**Implementation Strategy:**
- Development phases based on PRD priorities
- Risk mitigation for identified challenges
- Testing approach for quality assurance

**Task Breakdown Preview:**
- High-level task categories derived from PRD requirements
- Logical groupings for parallel development
- Dependencies between task categories

**Dependencies:**
- External service dependencies identified in PRD
- Internal team dependencies
- Prerequisite work that must be completed

**Success Criteria (Technical):**
- Performance benchmarks from PRD
- Quality gates and acceptance criteria
- Technical validation requirements

**Estimated Effort:**
- Overall timeline estimate based on complexity analysis
- Resource requirements
- Critical path identification

### 4. Post-Creation Summary

After enhancing the epic, provide:
1. ✅ Confirmation: "Epic created: .doh/epics/$ARGUMENTS/epic.md"
2. Summary of key technical decisions
3. Number of task categories identified
4. Estimated effort and timeline
5. Next step suggestion: "Ready to break down into tasks? Run: /doh:epic-decompose $ARGUMENTS"

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
