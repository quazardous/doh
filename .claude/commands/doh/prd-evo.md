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

**Act as Project Management Consultant - Audience-Aware Discovery:**

```
🏛️ Let's create a collaborative PRD for: "$FEATURE_REQUEST"

As your Project Management Consultant, I'll tailor our discovery session to your expertise level.
The Committee Evolution process uses 4 specialized agents as expert consultants.

**First, help me understand your background:**
What's your role/expertise? (e.g., Lead Developer, Product Manager, Sales, CEO, Designer, etc.)

This helps me ask the right questions and leverage your knowledge effectively.
```

**Based on user's role, adapt the discovery questions:**

### For Technical Roles (Lead Dev, DevOps, Architect, etc.):
```
**Technical & Functional Discovery:**

🎯 **Business Context:**
   - What specific problem does "$FEATURE_REQUEST" solve?
   - What's the user impact and business value?

🔧 **Technical Deep Dive:**
   - Any architectural constraints or preferences?
   - Performance/scalability requirements you foresee?
   - Integration challenges with current stack?
   - Security/compliance considerations?
   - Technical debt or refactoring opportunities?
   - Database schema or API changes needed?
   - Testing strategy concerns?

🚀 **Implementation Context:**
   - Timeline constraints or delivery pressures?
   - Resource availability (team, budget)?
   - Dependencies on other systems/teams?
```

### For Business Roles (Product Manager, CEO, etc.):
```
**Business & Functional Discovery:**

🎯 **Business Context:**
   - What specific problem does "$FEATURE_REQUEST" solve for users?
   - Who are the main users affected by this issue?
   - What happens if we don't build this feature?
   - What does success look like from a user perspective?

💼 **Strategic Context:**
   - How does this align with business objectives?
   - What's the expected ROI or business impact?
   - Any competitive pressures or market drivers?
   - User research or data supporting this need?

📋 **Functional Requirements:**
   - What key functionality would make users happy?
   - Any critical requirements or deal-breakers?
   - Integration with existing workflows?
   - Compliance or regulatory considerations?
```

### For Non-Technical Roles (Sales, Marketing, etc.):
```
**Functional Discovery:**

🎯 **User Problem:**
   - What specific problem does "$FEATURE_REQUEST" solve for users?
   - Who benefits and how do they currently handle this?
   - What would successful implementation look like to users?

💡 **Functional Vision:**
   - What key functionality is essential?
   - How should users interact with this feature?
   - Any examples from competitors or other tools?
   - What would make this feature a "must-have"?

📈 **Business Impact:**
   - How does this help achieve business goals?
   - What's the urgency or priority level?
   - Any constraints you're aware of (budget, timeline, etc.)?
```

**What I'll Auto-Discover Based on Your Technical Level:**
✅ Technology stack and architecture (from your codebase)
✅ Current version and roadmap alignment (from .doh files)  
✅ Technical constraints and debt (through code analysis)
✅ Integration points and dependencies (from project structure)
✅ Security and infrastructure concerns (expert analysis)
✅ Design patterns and UX consistency (existing system review)

**Committee Consultant Expertise:**
• 🏗️ DevOps Architect → Infrastructure, security, scalability analysis
• 💻 Lead Developer → Technical feasibility, architecture decisions  
• 🎨 UX Designer → User experience flow, accessibility review
• 💼 Product Owner → Business case refinement, market positioning

I'll match my questions to your expertise level and let the expert committee handle the gaps.

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

**After confirmation, validate gate check requirements:**

1. **PM Consultant Gate Check (Client-Friendly Approach):**
   Minimize requirements while maximizing auto-discovery:
   ```bash
   # Validate or generate feature name
   if [[ -z "${FEATURE_NAME}" ]] || ! echo "${FEATURE_NAME}" | grep -qE '^[a-z][a-z0-9-]*[a-z0-9]$'; then
       # Try to generate from description if needed
       FEATURE_NAME=$(echo "${DESCRIPTION}" | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
   fi
   
   # Auto-discover technical context (PM consultant does the heavy lifting)
   CURRENT_STACK=$(discover_tech_stack_from_project_files)  # Smart discovery from package.json, etc.
   CURRENT_VERSION=$(cat VERSION 2>/dev/null || git describe --tags 2>/dev/null || echo "0.1.0")
   TECHNICAL_CONTEXT=$(analyze_existing_architecture)  # Analyzes .doh, README, codebase
   TARGET_VERSION=${TARGET_VERSION:-$(increment_version "$CURRENT_VERSION" "minor")}
   EXECUTION_MODE=${EXECUTION_MODE:-"sequential"}
   
   # Only require basic business direction (understanding client limitations)
   [ -n "${DESCRIPTION}" ] && ([ -n "${PROBLEM_SUMMARY}" ] || can_infer_business_context_from_description)
   ```
   
   **Client-friendly messaging when business direction is insufficient:**
   ```
   💼 PM Consultant Check: Quick Business Context Needed
   ====================================================
   
   I can handle all the technical discovery from your project, but need minimal business context:
   
   Missing:
   ❓ What user problem does this solve?
   ❓ What would successful implementation look like?
   
   ✅ I'll auto-discover: tech stack, architecture, constraints, dependencies, versions
   ✅ Committee will refine: detailed requirements, technical solutions, implementation plan
   
   Just help me understand the "why" - I'll figure out the "how."
   ```
   
   **Auto-discovery successful (emphasize value delivered):**
   ```
   ✅ PM Consultant Ready - Full Project Analysis Complete
   =====================================================
   
   Auto-discovered technical context:
   • Current stack: ${DISCOVERED_STACK}
   • Version roadmap: ${CURRENT_VERSION} → ${TARGET_VERSION}
   • Architecture patterns: ${DISCOVERED_ARCHITECTURE}
   • Existing constraints: ${DISCOVERED_CONSTRAINTS}
   
   Committee consultants will now provide:
   • Cross-functional technical analysis
   • Implementation feasibility assessment  
   • User experience optimization
   • Business requirements refinement
   
   You've provided the business direction - we'll handle the technical complexity.
   ```

2. **Check PRD doesn't exist:**
   ```bash
   [ -f ".doh/prds/${FEATURE_NAME}.md" ]
   ```
   If exists: "⚠️ PRD '${FEATURE_NAME}' already exists. Options:
   - Edit existing: /doh:prd-edit ${FEATURE_NAME}
   - Use different name
   - Overwrite (loses content)"

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
# Create seed directory structure
doh_dir=$(doh_project_dir) || return 1
seed_dir="$doh_dir/committees/${FEATURE_NAME}"
seed_file="$seed_dir/seed.md"

mkdir -p "$seed_dir" || {
    echo "❌ Failed to create committee directory: $seed_dir" >&2
    return 1
}

echo "📝 Creating seed file from template..."

# Process template directly
template_file=".claude/orchestration/prd-committee/templates/seed.md"
if [[ ! -f "$template_file" ]]; then
    echo "❌ Error: Template not found: $template_file" >&2
    return 1
fi

# Generate seed file with discovered and provided context
# Use discovered values with fallbacks, allowing committee to refine during analysis
sed \
    -e "s/{{FEATURE_NAME}}/${FEATURE_NAME}/g" \
    -e "s/{{DESCRIPTION}}/${DESCRIPTION}/g" \
    -e "s/{{TARGET_VERSION}}/${TARGET_VERSION}/g" \
    -e "s/{{EXECUTION_MODE}}/${EXECUTION_MODE}/g" \
    -e "s/{{TIMESTAMP}}/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/g" \
    -e "s/{{PROBLEM_STATEMENT}}/${PROBLEM_SUMMARY:-Committee to refine based on feature description}/g" \
    -e "s/{{BUSINESS_CONTEXT}}/${BUSINESS_CONTEXT:-Committee to develop through analysis}/g" \
    -e "s/{{TECHNICAL_CONTEXT}}/${TECHNICAL_CONTEXT:-Auto-discovered from project}/g" \
    -e "s/{{CURRENT_STACK}}/${CURRENT_STACK:-Auto-discovered from project files}/g" \
    -e "s/{{REQUIREMENTS_SUMMARY}}/${REQUIREMENTS_LIST:-Committee to define during draft phase}/g" \
    -e "s/{{CONSTRAINTS}}/${CONSTRAINTS:-Committee to identify through technical debt analysis}/g" \
    -e "s/{{SUCCESS_CRITERIA}}/${SUCCESS_CRITERIA:-Committee to establish measurable outcomes}/g" \
    -e "s/{{COMPLEXITY}}/${COMPLEXITY_LEVEL:-Committee to assess}/g" \
    -e "s/{{USER_IMPACT}}/${USER_IMPACT:-Committee to evaluate}/g" \
    -e "s/{{BREAKING_CHANGES}}/${BREAKING_CHANGES:-Committee to determine}/g" \
    -e "s/{{DEPENDENCIES}}/${DEPENDENCIES:-Committee to discover through project analysis}/g" \
    -e "s/{{USER_SCALE}}/${USER_SCALE:-Committee to analyze}/g" \
    -e "s/{{SITE_COUNT}}/${SITE_COUNT:-Committee to determine}/g" \
    -e "s/{{CURRENT_VERSION}}/${CURRENT_VERSION}/g" \
    "$template_file" > "$seed_file" || {
    echo "❌ Failed to generate seed file" >&2
    return 1
}

echo "✅ Committee seed created: $seed_file"
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
prompt: Execute complete committee PRD workflow for "${FEATURE_NAME}" using Project Management Consultant approach.

The seed file has been created at .doh/committees/${FEATURE_NAME}/seed.md with discovered and provided context.
Read the seed file directly at .doh/committees/${FEATURE_NAME}/seed.md for the full context.

**PROJECT MANAGEMENT CONSULTANT MODE:**
The committee acts as consultants who can discover context during analysis:
- Auto-discovered technical context is available in seed (current_stack, technical_context)
- Some fields marked "Committee to [action]" should be developed by agents during draft phase
- Agents should analyze existing project to discover technical debt, constraints, dependencies
- Business context should be refined through cross-functional analysis

**EXECUTION MODE: ${EXECUTION_MODE}**
- If "sequential": Launch agents one by one (memory efficient)
- If "parallel": Launch agents simultaneously (faster but memory intensive)

**DISCOVERY EMPHASIS:**
- DevOps: Analyze existing infrastructure, discover deployment patterns and security context
- Lead Developer: Examine current codebase for technical debt, architecture patterns, integration points  
- UX Designer: Evaluate existing design systems, user flows, accessibility considerations
- Product Owner: Refine business requirements, develop success criteria, assess market positioning

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