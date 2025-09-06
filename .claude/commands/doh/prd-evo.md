---
allowed-tools: Bash, Read, Write, LS, Task, Agent
---

# PRD Evolution Command

Create a comprehensive Product Requirements Document (PRD) using an advanced multi-agent committee workflow. This command leverages 4 specialized AI agents (DevOps Architect, Lead Developer, UX Designer, Product Owner) plus CTO arbitration to produce high-quality, consensus-driven PRDs through a structured 2-round collaborative process.

## Usage
```
/doh:prd-evo <natural language description> [--parallel]
```

## Examples
- `/doh:prd-evo gitlab support`
- `/doh:prd-evo add OAuth2 authentication to the API`
- `/doh:prd-evo version 2.0 database migration --parallel`  # Force parallel execution
- `/doh:prd-evo user-notifications`

## Execution Mode
- **Default**: Sequential agent execution (memory efficient)
- **--parallel**: Parallel agent execution (faster but uses more memory)

## Agents
- **Committee Orchestrator**: `.claude/agents/committee-orchestrator.md`
- **DevOps Architect**: `.claude/agents/devops-architect.md`
- **Lead Developer**: `.claude/agents/lead-developer.md`
- **UX Designer**: `.claude/agents/ux-designer.md`
- **Product Owner**: `.claude/agents/product-owner.md`

## Instructions

### 1. Parse Arguments and Execution Mode

From `$ARGUMENTS`, extract feature request and execution mode:

**Parse execution mode:**
```bash
# Check for --parallel flag
if [[ "$ARGUMENTS" == *"--parallel"* ]]; then
    EXECUTION_MODE="parallel"
    FEATURE_REQUEST="${ARGUMENTS/--parallel/}"  # Remove flag from description
else
    EXECUTION_MODE="sequential"  # Default
    FEATURE_REQUEST="$ARGUMENTS"
fi
```

### 2. Initial Context Gathering

From cleaned `$FEATURE_REQUEST`, begin understanding the feature request, but first gather project context:

**Silently check (don't announce these checks):**
1. Read `VERSION` file to understand current version
2. Check `.doh/versions/` for planned versions and roadmap
3. List `.doh/prds/` to see existing PRDs and avoid duplication
4. Check `.doh/epics/` for related work in progress
5. **Check for existing seed file**: `./.claude/scripts/doh/helper.sh committee seed_exists "${FEATURE_NAME}"`

**If seed file exists:**
```
📋 Found existing context for: ${FEATURE_NAME}
=====================================

A seed file already exists for this feature from a previous discovery session.

Options:
1. ✅ Use existing context and proceed to committee
2. 🔄 Review and update the existing context
3. 🗑️ Start fresh (delete existing seed)
4. 👁️ View existing seed content
```

If user chooses to use existing context:
- Skip to step 7 (Committee Session Execution)
- Read seed file directly: `.doh/committees/${FEATURE_NAME}/seed.md`
- Proceed directly to launching committee orchestrator

If user chooses to review/update:
- Display seed content: Read `.doh/committees/${FEATURE_NAME}/seed.md`
- Allow modifications through discovery questions
- Update seed: `./.claude/scripts/doh/helper.sh committee seed_update "${FEATURE_NAME}" "$new_content"`

If user chooses to start fresh:
- Delete seed: `./.claude/scripts/doh/helper.sh committee seed_delete "${FEATURE_NAME}"`
- Continue with normal discovery flow

### 3. Comprehensive Discovery Phase (MANDATORY)

**ALWAYS conduct a thorough discovery session before suggesting parameters:**

```
🏛️ Let's create a collaborative PRD for: "$FEATURE_REQUEST"

The Committee Evolution process uses 4 specialized agents to create comprehensive PRDs:
• 🏗️ DevOps Architect (security, scalability, infrastructure)
• 💻 Lead Developer (technical architecture, implementation)
• 🎨 UX Designer (user experience, accessibility, design)
• 💼 Product Owner (business requirements, market fit)

Before we start the committee session, I need to understand the full context:

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

### 4. Intelligent Parameter Synthesis

After gathering context, synthesize the information using the same logic as `/doh:prd-new`:

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

### 5. Present Comprehensive Understanding (MANDATORY)

**Show full context before starting committee session:**

```
🏛️ Committee PRD Planning Summary for "$FEATURE_REQUEST"
========================================================

**Understanding of the Feature:**
${SUMMARIZE_PROBLEM_AND_SOLUTION}

**Proposed PRD Parameters:**
   Feature name: ${FEATURE_NAME}
   Description: ${DESCRIPTION}
   Target version: ${TARGET_VERSION} (${VERSION_REASONING})

**Committee Configuration:**
   - Execution mode: ${EXECUTION_MODE} (memory ${EXECUTION_MODE == "sequential" ? "efficient" : "intensive"})
   - Complexity: ${HIGH/MEDIUM/LOW}
   - User impact: ${DESCRIPTION}
   - Breaking changes: ${YES/NO}
   - Dependencies: ${LIST_OR_NONE}
   - Estimated duration: ~${EXECUTION_MODE == "sequential" ? "12-15" : "8-12"} minutes

**Agent Focus Areas:**
   - 🏗️ DevOps: Infrastructure, security, scalability concerns
   - 💻 Lead Dev: Technical architecture, implementation feasibility
   - 🎨 UX: User experience, accessibility, design consistency
   - 💼 PO: Business requirements, market fit, success metrics

**Roadmap Alignment:**
   - Current version: ${CURRENT_VERSION}
   - Fits in version: ${TARGET_VERSION}
   - Related PRDs: ${LIST_OR_NONE}
   - Related epics: ${LIST_OR_NONE}

**Key Requirements Identified:**
   ${BULLET_LIST_OF_KEY_REQUIREMENTS}

Is this understanding correct? Should I proceed with committee session?
1. ✅ Yes, start committee PRD creation
2. 📝 Let me provide more context
3. ✏️ Adjust the parameters
4. 📋 Create a new version first
5. ⚡ Use solo mode instead (faster, simpler)
```

### 6. Handle User Response

Based on user choice:

**Option 1 (Proceed with Committee):**
- Continue to validation and committee session

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

**Option 5 (Solo mode fallback):**
- **DELEGATE to prd-new command**: Execute `/doh:prd-new ${ARGUMENTS}`
- Present option with reasoning: "Committee mode provides more comprehensive analysis but takes longer. Solo mode is faster for simple features."

### 7. Pre-Committee Validation

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

### 8. Committee Session Execution

**After user confirmation, create seed file and launch committee:**

#### 8a. Create Seed File with Initial Context

**First, save the gathered context to a seed file:**

```bash
# Source template library
source "$SCRIPT_DIR/../lib/template.sh"

# Build template variables from discovery context
declare -a template_vars=(
    "FEATURE_NAME=${FEATURE_NAME}"
    "DESCRIPTION=${DESCRIPTION}"
    "TARGET_VERSION=${TARGET_VERSION}"
    "EXECUTION_MODE=${EXECUTION_MODE}"
    "COMPLEXITY=${COMPLEXITY_LEVEL}"
    "USER_IMPACT=${USER_IMPACT}"
    "BREAKING_CHANGES=${BREAKING_CHANGES}"
    "DEPENDENCIES=${DEPENDENCIES}"
    "DEVOPS_REQUIREMENTS=${DEVOPS_SPECIFIC_REQS}"
    "LEADDEV_REQUIREMENTS=${LEADDEV_SPECIFIC_REQS}"
    "UX_REQUIREMENTS=${UX_SPECIFIC_REQS}"
    "PO_REQUIREMENTS=${PO_SPECIFIC_REQS}"
    "PROBLEM_SUMMARY=${PROBLEM_SUMMARY}"
    "BUSINESS_CONTEXT=${BUSINESS_CONTEXT}"
    "TECHNICAL_CONTEXT=${TECHNICAL_CONTEXT}"
    "REQUIREMENTS_LIST=${REQUIREMENTS_LIST}"
    "DISCOVERY_INSIGHTS=${DISCOVERY_INSIGHTS}"
    "SUCCESS_CRITERIA=${SUCCESS_CRITERIA}"
)

# Generate seed from template
echo "📝 Generating committee seed from template..."
if template_process_committee_prd "${FEATURE_NAME}" "${DESCRIPTION}" "${TARGET_VERSION}" "${EXECUTION_MODE}" "${template_vars[@]}" | \
   ./.claude/scripts/doh/helper.sh committee seed_create "${FEATURE_NAME}"; then
    echo "✅ Committee seed generated from template"
else
    echo "❌ Failed to generate seed from template" >&2
    return 1
fi
```

#### 8b. Launch Committee Session

```
🏛️ Starting Committee PRD Session...
=====================================

Feature: ${FEATURE_NAME}
Description: ${DESCRIPTION}
Target Version: ${TARGET_VERSION}

✅ Context saved to seed file
Launching committee orchestrator...
```

**Use Task tool to launch committee-orchestrator agent:**

The committee-orchestrator agent will:
1. Read seed file directly: .doh/committees/${FEATURE_NAME}/seed.md
2. Session structure will be initialized automatically by seed_create
3. Execute Round 1: Use Task tool to launch 4 parallel agents (devops-architect, lead-developer, ux-designer, product-owner) 
4. Use committee.sh functions to collect ratings and manage feedback
5. Execute Round 2: Use Task tool again for agent revisions based on feedback
6. Perform convergence analysis and create final PRD
7. Use ./.claude/scripts/doh/helper.sh to save final PRD to .doh/prds/${FEATURE_NAME}.md

**Task invocation:**
```
subagent_type: committee-orchestrator
prompt: Execute complete committee PRD workflow for "${FEATURE_NAME}".

The seed file has been created at .doh/committees/${FEATURE_NAME}/seed.md with all context.
Read the seed file directly at .doh/committees/${FEATURE_NAME}/seed.md for the full context.

**EXECUTION MODE: ${EXECUTION_MODE}**
- If "sequential": Launch agents one by one (memory efficient)
- If "parallel": Launch agents simultaneously (faster but memory intensive)

Use existing DOH committee infrastructure:
- helper.sh committee commands for session management and seed access
- committee.sh library for workflow coordination  
- Task tool for agent coordination (devops-architect, lead-developer, ux-designer, product-owner)
- Save final PRD in standard DOH format to .doh/prds/${FEATURE_NAME}.md

IMPORTANT: Respect the execution mode specified in the seed file frontmatter.
```

### 9. Post-Committee Processing

After committee session completes, validate and enhance results:

**Check committee output:**
```bash
# Verify committee session completed
[ -d "committees/${FEATURE_NAME}" ]
[ -f ".doh/prds/${FEATURE_NAME}.md" ]
```

**Present results:**
```
✅ Committee PRD Session Complete
=================================

**Created:** .doh/prds/${FEATURE_NAME}.md
**Session Details:** committees/${FEATURE_NAME}/
**Duration:** ${ACTUAL_DURATION} minutes
**Agents Participated:** 4 specialized agents + CTO arbitration

**Committee Insights:**
• 🏗️ DevOps concerns: ${DEVOPS_KEY_POINTS}
• 💻 Lead Dev insights: ${LEADDEV_KEY_POINTS}  
• 🎨 UX considerations: ${UX_KEY_POINTS}
• 💼 PO requirements: ${PO_KEY_POINTS}

**Consensus Level:** ${CONVERGENCE_SCORE}
**Key Decisions:** ${COMMITTEE_DECISIONS}

The PRD incorporates multi-perspective analysis and cross-functional alignment.
```

### 10. Final Summary

```
✅ Committee PRD Creation Complete
=================================

**Created:** .doh/prds/${FEATURE_NAME}.md
**Description:** ${DESCRIPTION}
**Target Version:** ${TARGET_VERSION}
**Committee Session:** committees/${FEATURE_NAME}/

**Multi-Agent Analysis Captured:**
${BULLET_LIST_OF_COMMITTEE_INSIGHTS}

**Cross-Functional Alignment:**
• Technical feasibility validated by Lead Developer
• Security/infrastructure concerns addressed by DevOps
• User experience optimized by UX Designer  
• Business requirements refined by Product Owner

**Next Steps:**
• Review committee minutes: committees/${FEATURE_NAME}/session.md
• Edit if needed: /doh:prd-edit ${FEATURE_NAME}
• Create epic: /doh:prd-parse ${FEATURE_NAME}
• View all PRDs: ./.claude/scripts/doh/helper.sh prd list
• Check version plan: /doh:version-show ${TARGET_VERSION}
```

## Important Rules

1. **UNDERSTAND FIRST** - Never start committee without comprehensive context
2. **ROADMAP AWARENESS** - Always check versions and existing work  
3. **USER CONFIRMATION** - Explicit approval required before committee session
4. **COMMITTEE ORCHESTRATOR** - Always use `.claude/agents/committee-orchestrator.md` for session management
5. **CONTEXT PRESERVATION** - Pass complete discovery context to committee
6. **EXACT PARAMETERS** - Maintain same parameter standards as /doh:prd-new
7. **VALIDATE EVERYTHING** - Check names, versions, duplicates before committee
8. **VERSION DELEGATION** - NEVER manually create version files; always use `/doh:version-new`

## Error Handling

- If committee session fails, offer fallback to solo mode
- Present committee session minutes for debugging
- Enable session recovery for interrupted committees  
- Suggest `./.claude/scripts/doh/helper.sh committee help` for committee issues
- If version doesn't exist, **DELEGATE to /doh:version** 
- If PRD exists, never overwrite without explicit confirmation

## Committee vs Solo Mode

**Use Committee Mode When:**
- Complex cross-functional features
- Security-sensitive implementations
- User-facing functionality changes
- Multi-system integrations
- Unclear technical requirements

**Consider Solo Mode For:**
- Simple bug fixes or minor improvements
- Well-defined technical tasks
- Urgent timeline requirements
- Prototype or experimental work

The committee mode provides comprehensive multi-perspective analysis at the cost of additional time (~15 minutes vs ~3 minutes solo).