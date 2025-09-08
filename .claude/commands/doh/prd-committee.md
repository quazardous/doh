---
allowed-tools: Bash, Read, Write, LS, Task, Agent
---

# PRD Committee Command

Create a comprehensive **technical Product Requirements Document (PRD)** using a simplified 3-round committee workflow with a dedicated orchestrator. This command uses the specialized PRD Orchestrator agent to coordinate 4 expert agents through a fixed sequential process.

## PRD Document Purpose

**TARGET AUDIENCE**: Technical teams who understand databases, APIs, and software architecture  
**DOCUMENT GOAL**: Describe **WHAT the software does and HOW it's built**, not the discovery process

### Final PRD Content Focus:
✅ **INCLUDE:**
- **User Stories**: Clear functional requirements
- **Software Components**: Detailed breakdown of modules and their functions
- **API Specifications**: Endpoints list, data models, integration points
- **Technology Stack**: Recommended frameworks, libraries, and tools to investigate
- **User Journey Maps**: Specific workflows for web/mobile/webapp interfaces
- **Architecture Diagrams**: System design and data flow
- **Technical Constraints**: Performance, security, compliance requirements

❌ **EXCLUDE:**
- Marketing analysis and competitive positioning
- Business model details and revenue projections  
- Market research findings
- Committee discovery process narrative
- Detailed database schemas (mention isolation concepts, not CREATE TABLE statements)

### Technical Depth Examples:
- **API**: "Authentication API with 12 endpoints: POST /auth/login, GET /auth/profile, etc."
- **Framework Options**: "Frontend: React/Vue.js/Angular evaluation needed; Backend: FastAPI/Django/Express.js"
- **Data Architecture**: "Multi-tenant isolation via domain_id partitioning" (not full schema)
- **User Flows**: "Member booking: Login → Court selection → Time slot → Payment → Confirmation"

## Usage
```
/doh:prd-committee <natural language description>
/doh:prd-committee --continue <feature-name>
```

## Examples
- `/doh:prd-committee gitlab support` - Start new committee session
- `/doh:prd-committee add OAuth2 authentication to the API` - Start new session
- `/doh:prd-committee --continue gitlab-integration` - Resume existing session
- `/doh:prd-committee --continue tennis-club-management-platform` - Continue after round

## Process Overview

### Complete Workflow with Mandatory Validation Points
1. **Feature Clarification**: Mandatory questions about function, users, scope (STOP → Wait user input)
2. **Business Research**: WebSearch industry domain understanding
3. **Research Summary**: Present complete synthesis for validation (STOP → Wait user approval)
4. **Seed File Creation**: Only after user validation
5. **3-Round Committee**: Sequential workflow (Assessment → Refinement → Convergence)

### Development Team Assumption
The committee designs PRDs assuming:
- **Senior developers** (5+ years experience)
- **Experienced team** with modern best practices knowledge
- **Professional capabilities** in architecture, testing, CI/CD
- **Quality-first approach** - not constrained by temporary resources

Imposed resources (junior devs, interns, specific constraints) can be accommodated marginally but do NOT drive core architectural decisions.

### Orchestration
- **Orchestrator**: `.claude/agents/prd-orchestrator.md`
- **Session Management**: Simple YAML-based state tracking
- **Fixed Structure**: Always 3 rounds, always 4 agents

## Instructions

### 1. Parse Arguments and Validation

```bash
# Check for --continue flag
if [[ "$ARGUMENTS" =~ ^--continue[[:space:]]+ ]]; then
    # Extract feature name for resuming session
    FEATURE_NAME=$(echo "$ARGUMENTS" | sed 's/^--continue[[:space:]]*//;s/[[:space:]]*$//')
    CONTINUE_MODE=true
    
    # Validate feature name exists
    if [[ -z "$FEATURE_NAME" ]]; then
        echo "❌ Error: Feature name required for --continue"
        echo "Usage: /doh:prd-committee --continue <feature-name>"
        exit 1
    fi
    
    # Check if session exists
    if [[ ! -d ".doh/committees/${FEATURE_NAME}" ]]; then
        echo "❌ Error: No session found for '${FEATURE_NAME}'"
        echo "Available sessions:"
        ls -1 .doh/committees/ 2>/dev/null || echo "  None"
        exit 1
    fi
    
    # Check session state
    if [[ ! -f ".doh/committees/${FEATURE_NAME}/session.yaml" ]]; then
        echo "❌ Error: Invalid session - missing session.yaml"
        exit 1
    fi
    
    # Jump to section 1A for continue validation
else
    # Normal mode - new session
    CONTINUE_MODE=false
    
    # Validate arguments exist
    if [[ -z "$ARGUMENTS" ]] || [[ "$ARGUMENTS" =~ ^[[:space:]]*$ ]]; then
        echo "❌ Error: Feature request cannot be empty"
        echo "Usage: /doh:prd-committee <natural language description>"
        echo "       /doh:prd-committee --continue <feature-name>"
        exit 1
    fi
    
    # Clean up feature request
    FEATURE_REQUEST=$(echo "$ARGUMENTS" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
```

### 1A. Continue Session Validation (MANDATORY for --continue)

**CRITICAL**: When continuing a session, this step is mandatory and must be completed interactively. Do NOT proceed directly to orchestrator launch.

```bash
# Load current session state
COMMITTEE_DIR=".doh/committees/${FEATURE_NAME}"
SESSION_FILE="${COMMITTEE_DIR}/session.yaml"
SEED_FILE="${COMMITTEE_DIR}/seed.md"

# Determine current round from session.yaml
CURRENT_ROUND=$(grep "current_round:" "$SESSION_FILE" | cut -d: -f2 | tr -d ' ')
NEXT_ROUND=$((CURRENT_ROUND + 1))

# Read existing context from seed file
echo "📋 Loading existing session context..."
```

**Present Current Session Status:**
```
🏛️ PRD Committee - Session Continue: ${FEATURE_NAME}
===================================================

**Session trouvée:** Round ${CURRENT_ROUND} complété
**Prochain Round:** ${NEXT_ROUND} - [Round Name Based on Number]

📋 **Contexte Actuel (du seed file):**
[Display key points from seed.md - feature description, business domain, main insights]

🔍 **Insights du Round ${CURRENT_ROUND}:**
[Display brief summary from round${CURRENT_ROUND}/round-summary.md]

**⚠️ VALIDATION OBLIGATOIRE AVANT ROUND ${NEXT_ROUND}:**

Sur la base des insights du round précédent, souhaitez-vous ajuster quelque chose ?

1. ✅ Continuez avec le Round ${NEXT_ROUND} tel que prévu
2. 📝 Ajoutez des précisions/corrections pour orienter le prochain round
3. 🔍 Additional research on specific aspect  
4. 🎯 Réorientez le focus du Round ${NEXT_ROUND}
5. 📊 Affichez les détails complets du Round ${CURRENT_ROUND} avant de continuer
6. ❌ Annulez la continuation

**Votre choix (1-6):**
```

**Implementation Requirements:**
```bash
# After displaying options, WAIT for user input
# Process user choice:

case "$user_choice" in
    1)  # Continue as planned - Jump to section 8B
        echo "✅ Continuation vers Round ${NEXT_ROUND} confirmée"
        ;;
    2)  # Add clarifications - Jump to section 1B  
        echo "📝 Ajout de précisions pour le Round ${NEXT_ROUND}"
        ;;
    3)  # Additional research - Jump to section 1C
        echo "🔍 Additional research requested"
        ;;
    4)  # Refocus round - Jump to section 1D
        echo "🎯 Round focus redirection requested"
        ;;
    5)  # Show round details - Jump to section 1E
        echo "📊 Affichage des détails du Round ${CURRENT_ROUND}"
        ;;
    6)  # Cancel
        echo "❌ Continuation annulée"
        exit 0
        ;;
esac

# Do NOT proceed to orchestrator without user validation
echo "Attente de votre choix pour continuer..."
exit 0  # Exit and wait for user input
```

### 1B. Add Clarifications for Next Round

**When user selects option 2 (📝 Ajoutez des précisions):**

```
📝 Round ${NEXT_ROUND} Clarifications
====================================

**Basé sur les insights du Round ${CURRENT_ROUND}, précisez :**

1. **Corrections factuelles:**
   - Y a-t-il des erreurs dans l'analyse précédente ?
   - Des aspects mal compris qu'il faut corriger ?

2. **Éléments manquants:**
   - Quels aspects importants n'ont pas été couverts ?
   - Quelles contraintes spécifiques à ajouter ?

3. **Priorités pour le Round ${NEXT_ROUND}:**
   - Sur quoi le committee doit-il se concentrer ?
   - Quels sont les points critiques à résoudre ?

4. **Contexte supplémentaire:**
   - Nouvelles informations depuis le dernier round ?
   - Changements de priorité ou contraintes ?

**Vos précisions (ou 'skip' pour passer):**
```

**Create continuation seed file:**
```bash
# Create seed-round{NEXT_ROUND}.md with user clarifications
cat > "${COMMITTEE_DIR}/seed-round${NEXT_ROUND}.md" << EOF
---
# PRD Committee Round ${NEXT_ROUND} Adjustments  
feature_name: ${FEATURE_NAME}
base_round: ${CURRENT_ROUND}
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
---

# Additional Context for Round ${NEXT_ROUND}

## User Clarifications from Round ${CURRENT_ROUND} Review

### Factual Corrections
${USER_CORRECTIONS}

### Missing Elements  
${MISSING_ELEMENTS}

### Round ${NEXT_ROUND} Priorities
${ROUND_PRIORITIES}

### Additional Context
${ADDITIONAL_CONTEXT}

## Instructions for Committee
Apply these clarifications when executing Round ${NEXT_ROUND}:
- Reference both original seed.md and this continuation context
- Address user corrections before proceeding with new analysis
- Focus on specified priorities during this round
- Integrate additional context into agent perspectives

EOF
```

### 1C. Additional Research Phase  

**When user selects option 3 (🔍 Additional research):**

```
🔍 Additional Research
====================

**Spécifiez le domaine de recherche complémentaire:**

1. 🏢 Business model ou industrie spécifique
2. 👥 Utilisateurs ou personas particuliers  
3. 💻 Technologies ou intégrations spécifiques
4. 📊 Métriques ou benchmarks industrie
5. ⚖️ Réglementations ou compliance
6. 🎯 Autre (précisez)

**Votre choix et détails:**
```

**Execute additional WebSearch:**
```bash
# Based on user choice, execute targeted research
case "$research_choice" in
    1) # Business model research
       websearch_queries=("${DOMAIN} business model 2025" "${DOMAIN} revenue streams");;
    2) # User personas research  
       websearch_queries=("${DOMAIN} user personas" "${DOMAIN} stakeholder analysis");;
    3) # Technology research
       websearch_queries=("${USER_TECH_QUERY} integration" "${USER_TECH_QUERY} best practices 2025");;
    # ... etc
esac

# Execute searches and append to seed-round{NEXT_ROUND}.md
```

### 1D. Refocus Round Direction

**When user selects option 4 (🎯 Réorientez le focus):**

```
🎯 Round ${NEXT_ROUND} Focus Redirection
======================================

**Focus actuel prévu pour Round ${NEXT_ROUND}:**
[Display standard focus based on round number]

**Nouvelles orientations possibles:**

1. 💼 Focus business/revenue prioritaire
2. 🎨 Focus expérience utilisateur prioritaire  
3. 🔧 Focus technique/architecture prioritaire
4. 🛡️ Focus sécurité/compliance prioritaire
5. 📈 Focus scalabilité/performance prioritaire
6. 🎯 Focus personnalisé (décrivez)

**Agent leadership souhaité:**
- Product Owner lead
- UX Designer lead  
- Lead Developer lead
- DevOps Architect lead
- Équilibré (pas de leader dominant)

**Votre réorientation:**
```

**Update focus in continuation seed:**
```bash
# Add focus redirection to seed-round{NEXT_ROUND}.md
cat >> "${COMMITTEE_DIR}/seed-round${NEXT_ROUND}.md" << EOF

## Round ${NEXT_ROUND} Focus Redirection

### New Primary Focus
${NEW_FOCUS}

### Agent Leadership  
${AGENT_LEADERSHIP}

### Specific Areas of Emphasis
${EMPHASIS_AREAS}
EOF
```

### 1E. Show Round Details

**When user selects option 5 (📊 Détails du Round):**

```bash
# Display complete round details for user review
echo "📊 Complete Round ${CURRENT_ROUND} Details"
echo "============================================="

# Show round summary
if [[ -f "${COMMITTEE_DIR}/round${CURRENT_ROUND}/round-summary.md" ]]; then
    echo ""
    echo "## Résumé du Round ${CURRENT_ROUND}:"
    cat "${COMMITTEE_DIR}/round${CURRENT_ROUND}/round-summary.md"
fi

# Show CTO analysis
if [[ -f "${COMMITTEE_DIR}/round${CURRENT_ROUND}/cto-analysis.md" ]]; then
    echo ""
    echo "## Analyse CTO:"
    cat "${COMMITTEE_DIR}/round${CURRENT_ROUND}/cto-analysis.md"
fi

# Show agent draft summaries (first 200 words each)
echo ""
echo "## Résumés des Analyses par Agent:"
for agent in product-owner ux-designer lead-developer devops-architect; do
    if [[ -f "${COMMITTEE_DIR}/round${CURRENT_ROUND}/drafts/${agent}.md" ]]; then
        echo ""
        echo "### ${agent^}:"
        head -10 "${COMMITTEE_DIR}/round${CURRENT_ROUND}/drafts/${agent}.md"
        echo "..."
    fi
done

# Return to validation menu
echo ""
echo "Retour au menu de validation..."
# Re-display section 1A validation menu
```

### 2. Initial Context Gathering

**Pre-flight Checks:**
```bash
# Validate DOH project is initialized
if [[ ! -d ".doh" ]]; then
    echo "❌ Error: Not a DOH project (missing .doh directory)"
    echo "Initialize with: /doh:init"
    exit 1
fi

# Check PRD orchestrator exists
if [[ ! -f ".claude/agents/prd-orchestrator.md" ]]; then
    echo "❌ Error: PRD orchestrator missing"
    echo "Required file: .claude/agents/prd-orchestrator.md"
    exit 1
fi

# Check version system exists  
CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "0.1.0")
if [[ ! -f "VERSION" ]]; then
    echo "⚠️ Warning: VERSION file missing, using default: 0.1.0"
fi
```

### 3. Feature Concept Clarification (MANDATORY REFINEMENT)

**CRITICAL**: This step is mandatory and must be completed interactively before proceeding. Do NOT generate a feature name until the user provides clarifications.

```
🏛️ PRD Committee - Besoin Initial: "$FEATURE_REQUEST"
====================================================

ÉTAPE OBLIGATOIRE: Je dois d'abord affiner votre besoin pour générer un nom de feature précis.

**Questions de Clarification (Réponses Requises):**

1. **Fonction Principale:**
   - En une phrase, que fait exactement cette fonctionnalité ?
   - Quelle est l'action ou capacité principale qu'elle fournit ?

2. **Utilisateurs Cibles:**
   - Qui utilisera principalement cette fonctionnalité ?
   - S'agit-il d'utilisateurs internes, clients externes, ou administrateurs ?

3. **Portée et Contexte:**
   - Est-ce une nouvelle fonctionnalité ou une amélioration d'existant ?
   - Remplace-t-elle quelque chose, ajoute-t-elle à quelque chose, ou crée-t-elle quelque chose de nouveau ?

4. **Étendue Technique:**
   - S'agit-il plutôt de : une nouvelle page/écran, amélioration de workflow, intégration système, ou addition de plateforme majeure ?

5. **Contraintes Spécifiques:**
   - Y a-t-il des contraintes techniques, budgétaires, ou temporelles importantes ?
   - Des intégrations ou technologies spécifiques requises ?

**⚠️ ARRÊT OBLIGATOIRE:**
Veuillez répondre à ces questions avant que je continue. 
Cela garantit un nom de feature précis et un processus committee pertinent.
```

**Implementation Requirements:**
```bash
# After displaying questions, WAIT for user response
# Do NOT proceed to step 4 without user input
# Use user responses to inform feature naming algorithm
# Validate that all key questions are answered

echo "Attente de vos réponses pour continuer..."
echo "Le processus ne peut pas continuer sans ces clarifications."
exit 0  # Exit and wait for user input
```

### 4. Industry Research Phase (WebSearch)

**After concept confirmation, conduct industry research to inform committee:**

```
🔍 Industry Research for Committee Context
========================================

Before our expert committee analyzes your feature, let me gather industry context that will inform their analysis.

This research will be provided to the committee agents to enhance their domain expertise.
```

**Step 1: Business Domain Identification**

Based on the feature concept and user responses, identify the specific business domain/industry:

**Present Domain Identification:**
```
🏢 Business Domain Identified
============================

Based on your feature concept, I've identified the business domain as:
**Primary Domain:** ${PRIMARY_DOMAIN}
**Sub-Domain:** ${SUB_DOMAIN}
**Industry Context:** ${INDUSTRY_CONTEXT}

This will guide our industry research to find relevant standards, regulations, and best practices.

Is this domain identification correct?
1. ✅ Yes, proceed with research
2. 🔄 Let me clarify the business domain
3. ✏️ Adjust the domain focus
```

**Step 2: Client Business Understanding Research**

Focus: Le comité connaît le software, pas le métier du client.

```bash
echo "🔍 Researching client business domain to educate committee..."

# 1. What does this business actually DO day-to-day?
echo "  → Understanding daily operations..."
DAILY_OPERATIONS=$(WebSearch "${PRIMARY_DOMAIN} daily operations typical day workflow" 2>/dev/null || echo "Operations research unavailable")

# 2. Who are the key people and what are their roles?
echo "  → Identifying key stakeholders..."
KEY_STAKEHOLDERS=$(WebSearch "${SUB_DOMAIN} key roles responsibilities who does what" 2>/dev/null || echo "Stakeholder research unavailable")

# 3. How does this business actually make money?
echo "  → Understanding business model..."
BUSINESS_MODEL=$(WebSearch "${PRIMARY_DOMAIN} business model revenue how they make money" 2>/dev/null || echo "Business model research unavailable")

# 4. What are the main pain points in this industry?
echo "  → Identifying common challenges..."
BUSINESS_CHALLENGES=$(WebSearch "${SUB_DOMAIN} common problems challenges pain points" 2>/dev/null || echo "Challenges research unavailable")

# 5. What does success look like in this business?
echo "  → Understanding success metrics..."
SUCCESS_METRICS=$(WebSearch "${PRIMARY_DOMAIN} success metrics KPIs what good looks like" 2>/dev/null || echo "Success metrics research unavailable")

echo "✅ Business understanding research complete"
```

**Industry Research Data Collection:**
- Daily operations understanding
- Key stakeholders and roles  
- Business model and revenue patterns
- Common industry challenges
- Technology trends and standards
- Regulatory/compliance requirements
- Success metrics and KPIs
- Competitive landscape insights

**Step 3: WebSearch Implementation**

Execute targeted searches using WebSearch tool:

```bash
# Template for industry research searches
conduct_industry_research() {
    local domain="$1"
    local feature_context="$2"
    
    echo "🔍 Researching ${domain} industry for ${feature_context}..."
    
    # Search 1: Industry standards and best practices
    websearch_query_1="${domain} management software 2025 best practices standards"
    
    # Search 2: Pain points and challenges
    websearch_query_2="${domain} common challenges problems pain points operations"
    
    # Search 3: Technology trends  
    websearch_query_3="${domain} technology trends digital transformation 2025"
    
    # Search 4: Regulatory compliance
    websearch_query_4="${domain} regulations compliance requirements data privacy"
    
    # Search 5: Business models
    websearch_query_5="${domain} business model revenue streams pricing strategies"
    
    # Execute searches and capture insights for committee seed file
}
```

**Research Context Capture:**
```
✅ Client Business Understanding Research Complete
================================================

**Business Domain:** ${PRIMARY_DOMAIN} / ${SUB_DOMAIN}

**📋 What the Committee Now Understands About Client's Business:**

**Daily Operations:**
${DAILY_OPERATIONS}

**Key People & Roles:**
${KEY_STAKEHOLDERS}

**Business Model (How They Make Money):**
${BUSINESS_MODEL}

**Common Challenges in This Business:**
${BUSINESS_CHALLENGES}

**Success Metrics & Goals:**
${SUCCESS_METRICS}

**Context for Committee:**
This business understanding will be provided to the software committee so they can:
- Design solutions that fit the client's actual day-to-day operations
- Understand who will use the software and how
- Identify the real business value and ROI opportunities
- Anticipate operational challenges specific to this business type
- Create software that makes sense in the client's world, not just technically
```

**Version Alignment:**
- **DELEGATE to version system**: Let `/doh:version` handle version analysis and assignment
- Based on user clarifications and industry research, the version system will:
  - Analyze feature scope and impact (patch/minor/major)
  - Check existing versions for suitable placement
  - Create new version if needed
  - Update existing version if appropriate
- **Do not manually analyze version impact** - let the version command handle this expertise

This comprehensive research will be provided to the PRD Orchestrator for informed committee analysis.

### 5. Present Research Summary and Get User Validation

**MANDATORY VALIDATION**: Before creating the seed file and launching committee, present complete summary for user approval.

```
🏛️ PRD Committee - Complete Summary for Validation
==================================================

**Feature:** ${FEATURE_NAME}
**Description:** ${DESCRIPTION}

**🏢 Domaine Business Identifié:**
• **Domaine Principal:** ${PRIMARY_DOMAIN}
• **Sous-Domaine:** ${SUB_DOMAIN}
• **Contexte Industrie:** ${INDUSTRY_CONTEXT}

**📋 Client Business Research (WebSearch):**

**Opérations Quotidiennes:**
${DAILY_OPERATIONS}

**Rôles & Personnes Clés:**
${KEY_STAKEHOLDERS}

**Modèle Business & Revenus:**
${BUSINESS_MODEL}

**Défis Communs de ce Métier:**
${BUSINESS_CHALLENGES}

**Métriques de Succès:**
${SUCCESS_METRICS}

**🎯 Paramètres Committee:**
• **Version Cible:** ${TARGET_VERSION}
• **Rounds:** 3 rounds fixes (Assessment → Refinement → Convergence)
• **Agents:** Product Owner, UX Designer, Lead Developer, DevOps Architect
• **Estimated Duration:** 10-15 minutes

**⚠️ VALIDATION REQUIRED BEFORE LAUNCH:**

This summary will be integrated into the seed file to educate the committee about your business.

Do you agree with this analysis to launch the committee?

1. ✅ Perfect, launch the PRD committee with this information
2. 📝 I need to correct/clarify certain elements
3. 🔄 Redo business research with different terms
4. ✏️ Adjust feature name or description
5. ❌ Cancel PRD creation
```

**Implementation Requirements:**
```bash
# After displaying summary, WAIT for user validation
# Do NOT proceed to seed creation without explicit approval
# Handle user corrections and iterate if needed

echo "Attente de votre validation pour créer le seed file et lancer le committee..."
echo "Le committee ne peut pas démarrer sans votre approbation de cette synthèse."
exit 0  # Exit and wait for user input
```

### 6. Generate Feature Name Based on User Responses

**REQUIREMENT**: This step only executes AFTER user has provided clarifications in step 3.
**CRITICAL**: This step is MANDATORY and must wait for user selection - do NOT skip to seed file creation.

**Feature Name Generation Algorithm:**
```bash
# Algorithm for precise feature name generation based on user responses:
# 1. Extract primary capability from user's function description
# 2. Add user type context if it disambiguates (admin-*, user-*, client-*)  
# 3. Include scope/domain if it clarifies purpose
# 4. Use technical extent to add suffix (-platform, -integration, -system, -workflow)
# 5. Convert to kebab-case, validate uniqueness

# Intelligent Examples Based on Clarifications:
# Function: "Gérer les membres d'un club de tennis" + Users: "Admins" + Scope: "Platform" 
# → "tennis-club-member-management"
# 
# Function: "Intégrer GitLab pour déploiements" + Users: "Développeurs" + Scope: "Integration"
# → "gitlab-deployment-integration"
#
# Function: "Notification utilisateurs" + Users: "Tous" + Scope: "System feature"
# → "user-notification-system"

# Present 2-3 name options to user for selection
FEATURE_NAME_OPTIONS=(
    "${SUGGESTED_NAME_1}"
    "${SUGGESTED_NAME_2}" 
    "${SUGGESTED_NAME_3}"
)

echo "📝 Noms de feature proposés basés sur vos réponses:"
for i in "${!FEATURE_NAME_OPTIONS[@]}"; do
    echo "$((i+1)). ${FEATURE_NAME_OPTIONS[i]}"
done
echo "$((${#FEATURE_NAME_OPTIONS[@]}+1)). ✏️ Proposer un autre nom"

# Present options and wait for user response in natural language
echo "📝 Proposed feature names based on your responses:"
for i in "${!FEATURE_NAME_OPTIONS[@]}"; do
    echo "$((i+1)). ${FEATURE_NAME_OPTIONS[i]}"
done
echo "$((${#FEATURE_NAME_OPTIONS[@]}+1)). ✏️ Suggest another name"
echo ""
echo "Please respond with:"
echo "- The number of your choice (1, 2, 3, etc.)"
echo "- Or propose entirely new name: 'my-custom-feature-name'"

# STOP and wait for user response - do NOT proceed to seed creation
exit 0
```

**Feature Name Validation:**
```bash
# Validate feature name format
if [[ ! "$FEATURE_NAME" =~ ^[a-z][a-z0-9-]*[a-z0-9]$ ]] || [[ "$FEATURE_NAME" =~ -- ]]; then
    echo "❌ Error: Invalid feature name '${FEATURE_NAME}'"
    echo "Rules: Must start with letter, contain only lowercase letters/numbers/hyphens"
    exit 1
fi

# Check if PRD already exists
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

### 7. Create Seed File with Context (Only After User Validation)

**REQUIREMENT**: This step only executes AFTER user has validated the complete research summary in step 5.

**Create seed file from template:**

```bash
# Create committee workspace
doh_dir=$(doh_project_dir) || return 1
committee_dir="$doh_dir/committees/${FEATURE_NAME}"
seed_file="$committee_dir/seed.md"
mkdir -p "$committee_dir"

echo "📝 Creating seed file from template..."

# Create seed file with inline template
cat > "$seed_file" << 'EOF'
---
# PRD Committee Session Seed
feature_name: FEATURE_NAME_PLACEHOLDER
description: DESCRIPTION_PLACEHOLDER
target_version: TARGET_VERSION_PLACEHOLDER
current_version: CURRENT_VERSION_PLACEHOLDER
created: TIMESTAMP_PLACEHOLDER
status: initialized
---

# Committee Session: FEATURE_NAME_PLACEHOLDER

## Feature Overview
DESCRIPTION_PLACEHOLDER

## Business Domain Context
**Primary Domain:** PRIMARY_DOMAIN_PLACEHOLDER
**Sub-Domain:** SUB_DOMAIN_PLACEHOLDER
**Industry Context:** INDUSTRY_CONTEXT_PLACEHOLDER

## Client Business Understanding (WebSearch Research)

**📋 What the Committee Now Understands About Client's Business:**

### Daily Operations - What This Business Actually Does
DAILY_OPERATIONS_PLACEHOLDER

### Key People & Roles - Who Works in This Business
KEY_STAKEHOLDERS_PLACEHOLDER

### Business Model - How They Make Money
BUSINESS_MODEL_PLACEHOLDER

### Common Challenges - Main Pain Points in This Industry
BUSINESS_CHALLENGES_PLACEHOLDER

### Success Metrics - What Good Looks Like for This Business
SUCCESS_METRICS_PLACEHOLDER

## Committee Context & Guidance

**Why This Research Matters for the Committee:**
This business understanding enables the software committee to:
- Design solutions that fit the client's actual day-to-day operations
- Understand who will use the software and how
- Identify the real business value and ROI opportunities
- Anticipate operational challenges specific to this business type
- Create software that makes sense in the client's world, not just technically

## Project Context
- **Current Version:** CURRENT_VERSION_PLACEHOLDER
- **Target Version:** TARGET_VERSION_PLACEHOLDER
- **Technology Stack:** [Auto-discover from project]
- **Architecture:** [Analyze from codebase]

## Development Team Assumption
- Senior developers (5+ years experience)
- Experienced team with modern best practices
- Quality-first approach

## Committee Focus Areas
- **Round 1: Business Reality Discovery (PO lead)** - Validate research, find business contradictions
- **Round 2: Functional Design & User Workflows (UX lead)** - Design for actual user workflows
- **Round 3: Technical Architecture & Infrastructure (Dev+DevOps lead)** - Build for business reality
EOF

# Substitute variables in seed file
sed -i "
    s/FEATURE_NAME_PLACEHOLDER/${FEATURE_NAME}/g;
    s/DESCRIPTION_PLACEHOLDER/${DESCRIPTION}/g;
    s/TARGET_VERSION_PLACEHOLDER/${TARGET_VERSION}/g;
    s/CURRENT_VERSION_PLACEHOLDER/${CURRENT_VERSION}/g;
    s/TIMESTAMP_PLACEHOLDER/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/g;
    s/PRIMARY_DOMAIN_PLACEHOLDER/${PRIMARY_DOMAIN}/g;
    s/SUB_DOMAIN_PLACEHOLDER/${SUB_DOMAIN}/g;
    s/INDUSTRY_CONTEXT_PLACEHOLDER/${INDUSTRY_CONTEXT}/g;
    s/DAILY_OPERATIONS_PLACEHOLDER/${DAILY_OPERATIONS}/g;
    s/KEY_STAKEHOLDERS_PLACEHOLDER/${KEY_STAKEHOLDERS}/g;
    s/BUSINESS_MODEL_PLACEHOLDER/${BUSINESS_MODEL}/g;
    s/BUSINESS_CHALLENGES_PLACEHOLDER/${BUSINESS_CHALLENGES}/g;
    s/SUCCESS_METRICS_PLACEHOLDER/${SUCCESS_METRICS}/g;
" "$seed_file"

echo "✅ Committee seed created: $seed_file"
```

### 8. Launch PRD Orchestrator (Only After Seed File Created)

**For New Session (CONTINUE_MODE=false):**

```
subagent_type: prd-orchestrator  
prompt: Start new PRD committee session for "${FEATURE_NAME}".

**Seed File Location:** .doh/committees/${FEATURE_NAME}/seed.md
Read the seed file directly for complete feature context, business domain research, and project details.

**Mode:** NEW_SESSION
Start from Round 1 and execute workflow with mandatory pause after round completion.
```

### 8B. Launch PRD Orchestrator for Continuation (After User Validation)

**For Continuing Session (CONTINUE_MODE=true):**

```bash
# Determine if continuation seed exists
CONTINUATION_SEED="${COMMITTEE_DIR}/seed-round${NEXT_ROUND}.md"

if [[ -f "$CONTINUATION_SEED" ]]; then
    # User provided clarifications/adjustments
    CONTINUATION_CONTEXT="**Additional Context:** Read both original seed.md and seed-round${NEXT_ROUND}.md for user clarifications and focus adjustments."
else
    # Standard continuation without adjustments
    CONTINUATION_CONTEXT="**Standard Continuation:** Use original seed.md context."
fi
```

```
subagent_type: prd-orchestrator
prompt: Continue existing PRD committee session for "${FEATURE_NAME}".

**Session Location:** .doh/committees/${FEATURE_NAME}/
Load session.yaml to determine current state and continue from Round ${NEXT_ROUND}.

**Mode:** CONTINUE_SESSION
Resume from saved state and execute Round ${NEXT_ROUND} with mandatory pause after completion.

${CONTINUATION_CONTEXT}

**User Validation Completed:** User has reviewed Round ${CURRENT_ROUND} results and confirmed continuation with any necessary adjustments documented in continuation seed file.
```

**Common Execution Requirements:**
1. Execute round phases sequentially:
   - Phase 1: All agents create drafts in round{N}/drafts/
   - Phase 2: All agents provide feedback on others' drafts in round{N}/feedback/ using rating template
   - Phase 3: Generate CTO analysis in round{N}/cto-analysis.md
   - Phase 4: Present summary and PAUSE for user input
2. Track progress in session.yaml (current_round, phase, status)
3. After each round: MANDATORY PAUSE - save state and exit
4. After Round 3: Generate final report and save PRD to .doh/prds/${FEATURE_NAME}.md

**Feedback Template Example:**
Each agent provides structured feedback with ratings and specific critiques:
- Rating scale: 1 (Critical issues) to 5 (Excellent)
- Concrete quotes from drafts when raising concerns
- Constructive suggestions for improvements
- Identification of conflicts between agents
- Priority issues for next round

**Agent Sequence per Round:**
1. product-owner (business perspective)
2. ux-designer (user experience perspective)  
3. lead-developer (technical perspective)
4. devops-architect (infrastructure perspective)

**Round-Specific Focus (Based on Technical PRD Requirements):**

- **Round 1: Business Context & Technical Constraints Discovery (Product Owner Lead)**
  - **Product Owner (Primary)**: Extract functional requirements, business rules that become software constraints, compliance requirements, user roles and permissions. Research regulatory standards that impact technical implementation
  - **UX Designer (Co-Lead)**: Map user workflows to technical interfaces, identify UX patterns, accessibility requirements (WCAG 2.1 AA), multi-device usage patterns
  - Lead Developer: Observer - Capture business logic that becomes code, data requirements, integration points, logical contradictions to resolve
  - DevOps Architect: Observer - Note compliance, security, operational constraints that drive architecture decisions
  - **Goal**: Understand business requirements that drive software features, NOT market analysis

- **Round 2: User Stories & Interface Specification (UX Designer Lead)**
  - **UX Designer (Primary)**: Create detailed user journeys, interface wireframes, interaction patterns, responsive design requirements, component specifications
  - Product Owner: Validate user stories align with business requirements, define acceptance criteria, prioritize features
  - **Lead Developer (Co-Lead)**: Translate UX patterns into technical components, identify reusable modules, define API contracts
  - DevOps Architect: Review interface requirements for performance, security, deployment implications
  - **Goal**: Define precisely HOW users interact with the software and WHAT interfaces are needed

- **Round 3: Technical Architecture & Implementation Plan (Lead Dev + DevOps Co-Lead)**
  - **Lead Developer (Primary)**: Design software architecture, define components and their interactions, recommend technology stack, specify APIs and data models, create integration patterns
  - **DevOps Architect (Co-Primary)**: Design deployment architecture, security implementation, monitoring strategy, scaling approach, CI/CD pipeline requirements
  - Product Owner: Validate technical solution delivers required features, confirm compliance with business constraints
  - UX Designer: Ensure architecture supports optimal user workflows, performance requirements
  - **Goal**: Specify technical implementation details, component breakdown, and technology choices for development team

**User Feedback System:**
After each round:
1. Present brief summary of round insights
2. Collect user feedback/corrections/guidance
3. Apply feedback to influence next round's agent instructions
4. Continue until all 3 rounds complete

**Feedback Collection Format:**
```
🏛️ Round [X] Summary - Committee Insights
========================================

**Key Insights:**
• Product Owner: [key points]
• UX Designer: [key points] 
• Lead Developer: [key points]
• DevOps Architect: [key points]

**CTO Business Opportunity Assessment:**
• Market Potential: [SaaS opportunity vs client-specific solution]
• Strategic Value: [effort/reward analysis for market-ready architecture]
• Investment Decision: [custom vs SaaS-ready development recommendation]

**Emerging Concerns:** [cross-cutting issues]
**Areas of Agreement:** [consensus points]

**Your feedback/guidance for Round [X+1]:**
(Provide corrections, priorities, or guidance - or press Enter to continue)
```

Use simple sequential execution, no complex manifest system.
```

### 9. Handle Results and Present Summary

**After orchestrator completes:**

```bash
# Verify committee session completed
if [[ ! -f ".doh/prds/${FEATURE_NAME}.md" ]]; then
    echo "❌ Committee session failed - PRD not created"
    echo ""
    echo "Recovery options:"
    echo "1. 🔄 Retry committee session"
    echo "2. 📝 Create manual PRD: /doh:prd-new ${FEATURE_NAME}"
    echo "3. 👁️ View session logs: .doh/committees/${FEATURE_NAME}/"
    exit 1
fi
```

**Present final results:**

```
✅ Technical PRD Generated - Implementation Ready
================================================

**📄 Primary Deliverable:** .doh/prds/${FEATURE_NAME}.md
**📊 Committee Session:** .doh/committees/${FEATURE_NAME}/
**🔧 Technical Focus:** Software architecture and implementation specifications

**PRD Technical Content:**
• 📋 User Stories with acceptance criteria
• 🏗️ Software components and module breakdown  
• 🔌 API specifications and endpoint definitions
• 💻 Technology stack recommendations
• 🎨 User interface workflows (web/mobile/webapp)
• 🛡️ Security and compliance requirements
• ⚡ Performance and scalability constraints

**For Development Team:**
• Clear technical requirements without business fluff
• Actionable implementation guidance
• Architecture decisions with rationale
• Component integration patterns

**Next Actions:**
• 👥 Review technical PRD with development team
• 🔍 Deep-dive into recommended technology options
• 📋 Break down into development epics: /doh:prd-parse ${FEATURE_NAME}
• 📝 Refine if needed: /doh:prd-edit ${FEATURE_NAME}
```

## Key Differences from prd-evo

1. **Dedicated Orchestrator**: Uses `.claude/agents/prd-orchestrator.md` instead of generic committee-orchestrator
2. **Fixed 3-Round Process**: No variable rounds, always 3 rounds exactly
3. **Simple State Tracking**: YAML-based session.yaml instead of complex manifest
4. **Sequential Only**: No parallel execution options
5. **Specialized Workflow**: PRD-specific process, not generic committee system

## Error Handling

- Validate PRD orchestrator exists before starting
- Check for existing PRDs and abort if found
- Verify committee workspace creation
- Handle orchestrator failures with recovery options
- Provide session logs for debugging

## Integration

- Uses same parameter collection as `prd-evo` (feature name, description, version, business context)
- Maintains compatibility with existing DOH PRD workflow
- Outputs standard PRD format to `.doh/prds/`
- Integrates with version system and epic creation