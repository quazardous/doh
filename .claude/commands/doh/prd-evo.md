---
allowed-tools: Bash, Read, Write, LS, Task, Agent
---

# PRD Evolution Command

Create a comprehensive Product Requirements Document (PRD) using an advanced multi-agent committee workflow with user intervention points. This command leverages 4 specialized AI agents (DevOps Architect, Lead Developer, UX Designer, Product Owner) plus CTO arbitration to produce high-quality, consensus-driven PRDs through a structured collaborative process with mandatory user checkpoints after each round.

## Usage
```
/doh:prd-evo <natural language description>
```

## Examples
- `/doh:prd-evo gitlab support`
- `/doh:prd-evo add OAuth2 authentication to the API`
- `/doh:prd-evo version 2.0 database migration`
- `/doh:prd-evo user-notifications`

## Execution Mode
- **Sequential only**: Memory-optimized agent execution with context reduction

## Agents
- **Committee Orchestrator**: `.claude/agents/committee-orchestrator.md`
- **DevOps Architect**: `.claude/agents/devops-architect.md`
- **Lead Developer**: `.claude/agents/lead-developer.md`
- **UX Designer**: `.claude/agents/ux-designer.md`
- **Product Owner**: `.claude/agents/product-owner.md`

## Instructions

### 1. Parse Arguments and Execution Mode

From `$ARGUMENTS`, extract feature request and execution mode:

**Input Validation & Parsing:**
```bash
# Validate arguments exist
if [[ -z "$ARGUMENTS" ]] || [[ "$ARGUMENTS" =~ ^[[:space:]]*$ ]]; then
    echo "❌ Error: Feature request cannot be empty"
    echo "Usage: /doh:prd-evo <natural language description>"
    echo "Examples:"
    echo "  /doh:prd-evo gitlab support"  
    echo "  /doh:prd-evo user authentication system"
    exit 1
fi

# No flags supported - sequential only
if [[ "$ARGUMENTS" =~ -- ]]; then
    echo "❌ Error: Flags not supported"
    echo "Usage: /doh:prd-evo <description>"
    exit 1
fi

# Sequential execution only
EXECUTION_MODE="sequential"
FEATURE_REQUEST="$ARGUMENTS"

# Clean up feature request
FEATURE_REQUEST=$(echo "$FEATURE_REQUEST" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
```

### 2. Initial Context Gathering

From cleaned `$FEATURE_REQUEST`, gather project context:

**Pre-flight Checks (Critical):**
```bash
# Validate DOH project is initialized
if [[ ! -d ".doh" ]]; then
    echo "❌ Error: Not a DOH project (missing .doh directory)"
    echo "Initialize with: /doh:init"
    exit 1
fi

# Check committee infrastructure exists
if [[ ! -f ".claude/agents/committee-orchestrator.md" ]]; then
    echo "❌ Error: Committee infrastructure missing"
    echo "Required file: .claude/agents/committee-orchestrator.md"
    exit 1
fi

# Check version system exists  
CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "0.1.0")
if [[ ! -f "VERSION" ]]; then
    echo "⚠️ Warning: VERSION file missing, using default: 0.1.0"
fi
```

**Context Gathering (Silently check):**
1. Read VERSION file or use default
2. Check `.doh/versions/` for planned versions and roadmap  
3. List `.doh/prds/` to see existing PRDs
4. Check `.doh/epics/` for related work in progress
5. Validate committee seed template exists

**Note**: Seed file check will happen after feature concept clarification creates the feature name/slug.

### 3. Initial Feature Concept Clarification (MANDATORY)

**GOAL: Create feature name/slug from concept understanding**

Focus on core concept understanding to generate meaningful feature name before detailed discovery:

```
🏛️ Committee PRD Creation for: "$FEATURE_REQUEST"
=============================================

Before diving deep with our 4-agent committee, let me understand the main feature concept:

**Core Concept Questions:**
1. **What is the main thing this feature does?**
   - In one sentence, what would users say this feature is for?
   - What's the primary action or capability it provides?

2. **Who is this primarily for?**
   - What type of users would use this most?
   - Are they internal users, external customers, or administrators?

3. **How does this fit into the bigger picture?**
   - Is this a completely new feature area or enhancing something existing?
   - Does this replace something, add to something, or create something new?

4. **What's the rough scope?**
   - Is this more like: a new page/screen, a workflow improvement, system integration, or major platform addition?

This helps me propose a focused feature name and scope before our committee session.
(The committee will then dive deep into requirements, technical feasibility, and implementation details)
```

### 4. Synthesize Initial Feature Understanding

Based on concept clarification, create initial understanding:

**Determine Preliminary Feature Concept:**
- Focus on the **core value proposition** and **main user benefit**
- Don't commit to technical implementation yet
- Capture the **"what"** before the **"how"**
- Examples:
  - "tennis asso site web de gestion des adherents" → Member management platform concept
  - "gitlab support" → Development workflow integration concept  
  - "user notifications" → Communication system concept

**Generate Feature Name/Slug:**
Based on user answers, create kebab-case feature name:
```bash
# Algorithm for feature name generation:
# 1. Extract key nouns from main capability (user answers to question 1)
# 2. Add context from primary users (question 2) if relevant
# 3. Include scope indication (question 4) if it clarifies purpose
# 4. Convert to kebab-case, validate uniqueness

# Examples:
# "Tennis association member management" → "tennis-member-management"  
# "GitLab integration for deployments" → "gitlab-deployment-integration"
# "User notification system" → "user-notification-system"
# "OAuth2 authentication for API" → "oauth2-api-authentication"
```

**Feature Name Rules:**
- Must start with letter, contain only lowercase letters, numbers, hyphens
- Should be 2-4 words that capture the essence
- Must be unique (not exist in .doh/prds/)
- Should be self-documenting (readable without context)
- Avoid generic words like "feature", "improvement", "enhancement"

**Present Initial Understanding:**
```
🎯 Feature Concept Summary
==========================

Based on your input, I understand this as:

**Core Feature:** ${MAIN_CAPABILITY_DESCRIPTION}
**Primary Users:** ${USER_TYPE_IDENTIFIED}  
**Scope Category:** ${SCOPE_CLASSIFICATION}
**Integration Level:** ${NEW_VS_ENHANCEMENT}

**Preliminary Feature Focus Areas:**
${BULLET_LIST_OF_MAIN_AREAS}

Does this capture the main idea correctly?
1. ✅ Yes, let's proceed to detailed discovery
2. 🔄 Let me clarify the concept
3. ✏️ Adjust the focus/scope
```

### 5. Check for Existing Seed and PRD Files

**After feature name is determined, check if work already exists:**

**Feature Name Validation (Critical):**
```bash
# Validate feature name format
if [[ ! "$FEATURE_NAME" =~ ^[a-z][a-z0-9-]*[a-z0-9]$ ]] || [[ "$FEATURE_NAME" =~ -- ]]; then
    echo "❌ Error: Invalid feature name '${FEATURE_NAME}'"
    echo "Rules: Must start with letter, contain only lowercase letters/numbers/hyphens"
    echo "       Cannot have consecutive hyphens, must end with letter/number"
    echo "Examples: 'user-auth', 'gitlab-integration', 'member-management'"
    exit 1
fi

# Validate feature name length
if [[ ${#FEATURE_NAME} -lt 3 ]] || [[ ${#FEATURE_NAME} -gt 50 ]]; then
    echo "❌ Error: Feature name '${FEATURE_NAME}' must be 3-50 characters"
    exit 1
fi
```

**Critical Check - PRD exists = ABORT:**
```bash
# First check if PRD already exists (abort if true)
if [ -f ".doh/prds/${FEATURE_NAME}.md" ]; then
    echo "⚠️ PRD '${FEATURE_NAME}' already exists!"
    echo "   File: .doh/prds/${FEATURE_NAME}.md"
    echo ""
    echo "Options:"
    echo "1. ✏️ Edit existing PRD: /doh:prd-edit ${FEATURE_NAME}"
    echo "2. 🔄 Choose a different feature name"
    echo "3. ❌ Cancel PRD creation"
    exit 1
fi
```

**If PRD exists, present options and ABORT committee creation:**
```
⚠️ PRD Already Exists: ${FEATURE_NAME}
====================================

A PRD already exists for this feature at: .doh/prds/${FEATURE_NAME}.md

Committee PRD creation cannot proceed. Choose an option:
1. ✏️ Edit existing PRD: /doh:prd-edit ${FEATURE_NAME}
2. 🔄 Use a different feature name and restart
3. 👁️ View existing PRD content first
4. ❌ Cancel

Committee evolution is for NEW PRDs only.
```

**Secondary Check - Seed file exists (if PRD doesn't exist):**
```bash
# Only if PRD doesn't exist, check for seed file
./.claude/scripts/doh/helper.sh committee seed_exists "${FEATURE_NAME}"
```

**If seed file exists (but no PRD):**
```
📋 Found existing context for: ${FEATURE_NAME}
=====================================

A seed file exists from a previous discovery session, but no PRD was created yet.

Options:
1. ✅ Use existing context and proceed to committee
2. 🔄 Review and update the existing context
3. 🗑️ Start fresh (delete existing seed)
4. 👁️ View existing seed content
```

**Handle existing seed:**
- **Use existing**: Skip to Committee Session Execution, read seed file directly
- **Review/update**: Display seed content, allow modifications through discovery questions
- **Start fresh**: Delete seed, continue with normal discovery flow
- **View content**: Show seed, then ask for choice again

### 6. Comprehensive Discovery Phase (After Concept Confirmation)

**Act as Project Management Consultant - Audience-Aware Discovery:**

```
🏛️ Great! Now for detailed discovery with our committee approach.

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

### 7. Intelligent Parameter Synthesis

After gathering detailed context, synthesize the information into concrete parameters:

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

**Determine Version Alignment:**
- **DELEGATE to version system**: Let `/doh:version` handle version analysis and assignment
- Based on discovery answers, the version system will:
  - Analyze feature scope and impact (patch/minor/major)
  - Check existing versions for suitable placement
  - Create new version if needed
  - Update existing version if appropriate
- **Do not manually analyze version impact** - let the version command handle this expertise

**Version Delegation Process:**
```bash
# This will be handled automatically during validation if needed
# /doh:version will determine:
# - Whether feature fits in existing planned versions
# - If new version is needed based on scope
# - Appropriate version number based on impact analysis
```

### 8. Present Comprehensive Understanding (MANDATORY)

**Show full context before starting committee session:**

```
🏛️ Committee PRD Planning Summary for "$FEATURE_REQUEST"
========================================================

**Understanding of the Feature:**
${SUMMARIZE_PROBLEM_AND_SOLUTION}

**Proposed PRD Parameters:**
   Feature name: ${FEATURE_NAME}
   Description: ${DESCRIPTION}
   Target version: ${TARGET_VERSION} (to be validated/assigned by version system)

**Committee Configuration:**
   - Execution mode: Sequential (memory optimized)
   - User checkpoints: Enabled (mandatory confirmation after each round)
   - Complexity: ${HIGH/MEDIUM/LOW}
   - User impact: ${DESCRIPTION}
   - Breaking changes: ${YES/NO}
   - Dependencies: ${LIST_OR_NONE}
   - Estimated duration: ~15-20 minutes (including user interactions)

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
```

### 9. Handle User Response

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

### 10. Pre-Committee Validation

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
   
   If user agrees, **DELEGATE**: `/doh:version-new for ${FEATURE_NAME} - ${DESCRIPTION}`

### 11. Committee Session Execution

**After user confirmation, create seed file and launch committee:**

#### 11a. Create Seed File with Initial Context

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

# Generate seed file with discovered and provided context - SAFE substitution
# Use temporary file approach to handle special characters safely
temp_file=$(mktemp) || {
    echo "❌ Failed to create temporary file" >&2
    return 1
}

# Copy template and substitute variables safely
cp "$template_file" "$temp_file" || {
    echo "❌ Failed to copy template file" >&2
    rm -f "$temp_file"
    return 1
}

# Use printf to safely escape special characters in variables
printf -v ESCAPED_FEATURE_NAME '%q' "${FEATURE_NAME}"
printf -v ESCAPED_DESCRIPTION '%q' "${DESCRIPTION:-}"
printf -v ESCAPED_TARGET_VERSION '%q' "${TARGET_VERSION:-}" 
printf -v ESCAPED_EXECUTION_MODE '%q' "${EXECUTION_MODE}"
printf -v ESCAPED_TIMESTAMP '%q' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Perform safe substitutions using perl instead of sed for better special char handling
perl -pi -e "
    s/\{\{FEATURE_NAME\}\}/${FEATURE_NAME}/g;
    s/\{\{DESCRIPTION\}\}/${DESCRIPTION:-}/g;
    s/\{\{TARGET_VERSION\}\}/${TARGET_VERSION:-}/g;
    s/\{\{EXECUTION_MODE\}\}/${EXECUTION_MODE}/g;
    s/\{\{TIMESTAMP\}\}/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/g;
    s/\{\{PROBLEM_STATEMENT\}\}/${PROBLEM_SUMMARY:-Committee to refine based on feature description}/g;
    s/\{\{BUSINESS_CONTEXT\}\}/${BUSINESS_CONTEXT:-Committee to develop through analysis}/g;
    s/\{\{TECHNICAL_CONTEXT\}\}/${TECHNICAL_CONTEXT:-Auto-discovered from project}/g;
    s/\{\{CURRENT_STACK\}\}/${CURRENT_STACK:-Auto-discovered from project files}/g;
    s/\{\{REQUIREMENTS_SUMMARY\}\}/${REQUIREMENTS_LIST:-Committee to define during draft phase}/g;
    s/\{\{CONSTRAINTS\}\}/${CONSTRAINTS:-Committee to identify through technical debt analysis}/g;
    s/\{\{SUCCESS_CRITERIA\}\}/${SUCCESS_CRITERIA:-Committee to establish measurable outcomes}/g;
    s/\{\{COMPLEXITY\}\}/${COMPLEXITY_LEVEL:-Committee to assess}/g;
    s/\{\{USER_IMPACT\}\}/${USER_IMPACT:-Committee to evaluate}/g;
    s/\{\{BREAKING_CHANGES\}\}/${BREAKING_CHANGES:-Committee to determine}/g;
    s/\{\{DEPENDENCIES\}\}/${DEPENDENCIES:-Committee to discover through project analysis}/g;
    s/\{\{USER_SCALE\}\}/${USER_SCALE:-Committee to analyze}/g;
    s/\{\{SITE_COUNT\}\}/${SITE_COUNT:-Committee to determine}/g;
    s/\{\{CURRENT_VERSION\}\}/${CURRENT_VERSION}/g;
" "$temp_file" || {
    echo "❌ Failed to process template substitutions" >&2
    rm -f "$temp_file"
    return 1
}

# Move processed file to final location
mv "$temp_file" "$seed_file" || {
    echo "❌ Failed to create seed file" >&2
    rm -f "$temp_file"
    return 1
}

echo "✅ Committee seed created: $seed_file"
```

#### 11b. Launch Committee Session

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
3. Execute Round 1: Use Task tool to launch 4 sequential agents (devops-architect, lead-developer, ux-designer, product-owner)
4. **USER CHECKPOINT**: Present round 1 brief and ask for corrections/guidance
5. Use committee.sh functions to collect ratings and manage feedback
6. Execute Round 2: Use Task tool again for agent revisions based on user feedback and agent reviews
7. **USER CHECKPOINT**: Present round 2 brief and ask for corrections/guidance  
8. Continue rounds as needed (max 3) with user checkpoints after each
9. Perform convergence analysis and create final PRD
10. Use ./.claude/scripts/doh/helper.sh to save final PRD to .doh/prds/${FEATURE_NAME}.md

**Task invocation with error handling:**
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

**EXECUTION MODE: Sequential with User Checkpoints**
- Launch agents one by one with memory optimization and context reduction
- Present brief summary after each round
- Wait for mandatory user confirmation/corrections before continuing
- Apply user interventions (CTO decisions, client requirements, general corrections) to influence next round

**DISCOVERY EMPHASIS:**
- DevOps: Analyze existing infrastructure, discover deployment patterns and security context
- Lead Developer: Examine current codebase for technical debt, architecture patterns, integration points  
- UX Designer: Evaluate existing design systems, user flows, accessibility considerations
- Product Owner: Refine business requirements, develop success criteria, assess market positioning

**USER INTERVENTION APPROACH:**
- Express yourself naturally in any language
- AI automatically detects if you're speaking as CTO, client, or general stakeholder
- Technical feedback → Overrides agent technical decisions
- Business feedback → Updates requirements and priorities
- General feedback → Provides guidance and corrections
- Empty input → Continue with current direction

*AI-powered intent recognition, responds in user's language*

**ERROR HANDLING:**
If committee session fails:
1. Save session state to .doh/committees/${FEATURE_NAME}/session_failed.md
2. Provide recovery options to user
3. Offer manual PRD creation as fallback

Use existing DOH committee infrastructure:
- helper.sh committee commands for session management and seed access
- committee.sh library for workflow coordination  
- Task tool for agent coordination (devops-architect, lead-developer, ux-designer, product-owner)
- Save final PRD in standard DOH format to .doh/prds/${FEATURE_NAME}.md

IMPORTANT: Respect the execution mode specified in the seed file frontmatter.
```

**Handle committee orchestrator failure:**
```bash
# Check if Task tool execution succeeded
if [[ $? -ne 0 ]]; then
    echo "❌ Committee session failed"
    echo ""
    echo "Recovery options:"
    echo "1. 🔄 Retry committee session"
    echo "2. 📝 Create manual PRD: /doh:prd-new ${FEATURE_NAME} \"${DESCRIPTION}\""
    echo "3. 👁️ View session logs: .doh/committees/${FEATURE_NAME}/"
    echo "4. 🧹 Clean up and start fresh"
    echo ""
    echo "Committee session details saved for debugging."
    exit 1
fi
```

### 12. Post-Committee Processing

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

### 13. Final Summary

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