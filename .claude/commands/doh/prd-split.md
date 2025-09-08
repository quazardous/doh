---
allowed-tools: Bash, Glob, Grep, LS, Read, WebFetch, TodoWrite, WebSearch, Search, Task, Agent
---

# PRD Split Command

Split a large PRD into multiple parallelizable PRDs to avoid tunnel effect and enable efficient epic execution. Uses a specialized 3-round committee process with development-focused orchestration.

## Usage
```
/doh:prd-split <master-prd-name> [split-criteria]
/doh:prd-split <master-prd-name> "focus on technical components and infrastructure readiness"
```

## Examples
- `/doh:prd-split tennis-club-management` - Default size-based splitting
- `/doh:prd-split e-commerce-platform "separate by user domains and technical layers"`
- `/doh:prd-split inventory-system "focus on database migration and API development phases"`

## Split Naming Convention

**Format:** `{master-basename}-S{NN}-{descriptive-suffix}`

**Examples:**
- Master PRD: `tennis-club-management`
- Split 0: `tennis-club-management-S00-development-foundation` (Domains: *.tennis-club.local)
- Split 1: `tennis-club-management-S01-user-authentication`
- Split 2: `tennis-club-management-S02-booking-engine`
- Split 3: `tennis-club-management-S03-payment-processing`

## Process Overview

### Specialized Committee Structure
- **Lead Developer (Primary)** - Technical decomposition and dependency analysis
- **DevOps Architect (Co-Lead)** - Infrastructure phasing and deployment readiness
- **Product Owner** - Business priority validation and feature boundaries
- **UX Designer** - User journey continuity across splits

### 3-Round Process

**Round 1: Development Foundation - Generate Split-S00**
- **Focus**: Create Split-S00-development-foundation PRD with pragmatic Docker-based dev environment
- **Deliverables**: Split-S00 PRD with:
  - INSTADEV.md for quick developer onboarding
  - Pragmatic Docker setup (docker-compose.yml)
  - Makefile with common commands
  - Install/bootstrap scripts (brew install, pip install, etc.)
  - Hello World implementation (HTTP endpoint + CLI command)
  - DevOps milestones roadmap
- **Philosophy**: Developer-friendly tooling - one command to start working
- **Docker Security**: UID/GID matching, Traefik routing (only ports 80/443 exposed), proper permissions

**Round 2: Split Boundaries & Dependencies**
- **Focus**: Define sub-PRDs in execution order with clear dependencies
- **Deliverables**: Ordered split list, dependency matrix, primary orientation (infra/dev/UX/etc.), justifications

**Round 3: PRD Split Generation**  
- **Focus**: Generate actual split PRDs with complete specifications
- **Deliverables**: Draft splits by all agents, final PRDs authored by Lead Developer

## Instructions

### 1. Validate Master PRD Exists

```bash
# Check master PRD exists
MASTER_PRD="$1"
if [[ ! -f ".doh/prds/${MASTER_PRD}.md" ]]; then
    echo "❌ Error: Master PRD '${MASTER_PRD}' not found"
    echo "Available PRDs:"
    ls -1 .doh/prds/ 2>/dev/null || echo "  None"
    exit 1
fi

# Parse split criteria
SPLIT_CRITERIA="${2:-focus on size and parallelization for efficient epic execution}"
```

### 2. Create Split Workspace

```bash
# Create split workspace
SPLIT_DIR=".doh/splits/${MASTER_PRD}"
mkdir -p "$SPLIT_DIR"

echo "📂 Created split workspace: $SPLIT_DIR"
```

### 3. Initialize Split Session

```bash
# Create split session context
cat > "${SPLIT_DIR}/split-session.md" << EOF
---
# PRD Split Session
master_prd: ${MASTER_PRD}
split_criteria: "${SPLIT_CRITERIA}"
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
status: initialized
---

# PRD Split Session: ${MASTER_PRD}

## Master PRD Context
**Source PRD:** .doh/prds/${MASTER_PRD}.md
**Split Criteria:** ${SPLIT_CRITERIA}

## Split Objectives
- Avoid tunnel effect in epic execution
- Enable parallel development streams
- Maintain clear dependency relationships
- Preserve master PRD context and coherence

## Committee Focus
- **Round 1**: Development readiness and phasing strategy
- **Round 2**: Split boundary definition and dependency analysis
- **Round 3**: Individual PRD generation and validation
EOF

echo "✅ Split session initialized: ${SPLIT_DIR}/split-session.md"
```

### 4. Launch Split Committee Orchestrator

```bash
# Launch specialized split orchestrator
subagent_type: prd-split-orchestrator
prompt: Execute PRD split process for master PRD "${MASTER_PRD}".

**Split Session Location:** ${SPLIT_DIR}/split-session.md
**Master PRD Location:** .doh/prds/${MASTER_PRD}.md
**Split Criteria:** "${SPLIT_CRITERIA}"

**Committee Mission:**
Split large PRD into parallelizable sub-PRDs to enable efficient epic execution without tunnel effect.

**Process Requirements:**
1. **Round 1: Development Foundation** (Lead Developer + DevOps lead)
   - Check existing dev environment FIRST - enhance, don't replace
   - Generate Split-S00-development-foundation PRD 
   - Make technology stack decisions if not already made
   - Create Hello World implementation specification (compatible with existing setup)
   - Define DevOps roadmap and milestones (plan, not implement)
   - Map remaining component stories with dependencies and critical path

2. **Round 2: Split Definition** (Lead Developer lead, all agents collaborate)  
   - Define sub-PRD boundaries in execution order
   - Document inter-PRD dependencies and interfaces
   - Assign primary orientation (infra/dev/UX/devops) per split
   - Justify split rationale and parallelization strategy

3. **Round 3: PRD Generation** (Lead Developer authors, all agents draft)
   - Each agent drafts each split PRD from their perspective
   - Lead Developer synthesizes drafts into final split PRDs
   - Ensure master PRD context and cross-references
   - Validate parallelization viability

**Output Structure:**
.doh/splits/${MASTER_PRD}/
├── split-session.md
├── round1/
├── round2/ 
└── round3/
    └── drafts/              # Agent drafts for synthesis

**Final PRDs Generated In:** .doh/prds/
├── {basename}-S01-{suffix}.md
├── {basename}-S02-{suffix}.md
└── ...

**Naming Convention:** {master-basename}-S{NN}-{descriptive-suffix}
**Master Reference:** Each split PRD must reference master PRD for context
**Parallelization:** Splits must be designed for parallel epic execution
```

### 5. Handle Split Results

```bash
# After orchestrator completes, validate splits were generated directly in .doh/prds/
SPLIT_PATTERN=".doh/prds/${MASTER_PRD}-S[0-9][0-9]-*.md"
SPLIT_FILES=($(ls ${SPLIT_PATTERN} 2>/dev/null))

if [[ ${#SPLIT_FILES[@]} -eq 0 ]]; then
    echo "❌ Split generation failed - no PRDs created"
    echo ""
    echo "Recovery options:"
    echo "1. 🔄 Retry split process"
    echo "2. 📝 Adjust split criteria and retry"
    echo "3. 👁️ Review session logs: ${SPLIT_DIR}/"
    exit 1
fi

# Count generated splits
SPLIT_COUNT=${#SPLIT_FILES[@]}
echo "📦 Generated ${SPLIT_COUNT} split PRDs directly in .doh/prds/"
```

### 6. Present Split Results

```bash
echo ""
echo "✅ PRD Split Complete - ${SPLIT_COUNT} Sub-PRDs Generated"
echo "=================================================="
echo ""
echo "**📄 Master PRD:** .doh/prds/${MASTER_PRD}.md"
echo "**📊 Split Session:** ${SPLIT_DIR}/"
echo "**🔧 Split Focus:** Parallelizable epic execution"
echo ""
echo "**Generated Split PRDs:**"
for split_file in "${SPLIT_FILES[@]}"; do
    split_name=$(basename "$split_file" .md)
    echo "• 📋 ${split_name}"
done
echo ""
echo "**Next Actions:**"
echo "• 👥 Review split PRDs for technical accuracy"
echo "• 🔍 Validate dependency relationships between splits"
echo "• 📋 Create epics from splits: /doh:prd-parse {split-name}"
echo "• 🚀 Execute splits in parallel for faster delivery"
echo ""
echo "**Parallel Execution Benefits:**"
echo "• No tunnel effect - multiple development streams"
echo "• Clear dependency management across teams"  
echo "• Independent testing and deployment cycles"
echo "• Reduced context switching and merge conflicts"
```

## Split PRD Requirements

### Master PRD Reference Section
Each split PRD must include:
```markdown
## Master PRD Context

**Master PRD:** {master-prd-name}
**Split Position:** {N} of {total-splits}
**Dependencies:** {list-of-required-splits}
**Enables:** {list-of-dependent-splits}

**Context from Master PRD:**
{relevant-context-extract}
```

### Parallelization Specifications
Each split PRD must specify:
- **Development Independence:** What can be built without other splits
- **Integration Points:** How this split connects to others
- **Testing Strategy:** How to test in isolation and integration
- **Deployment Dependencies:** What must be deployed first

## Multi-Project Domain Pattern

### Domain Naming Convention
**Pattern:** `{service}.{project}.local`

**Example for project "tennis":**
- `app.tennis.local` - Main application
- `api.tennis.local` - API endpoints
- `admin.tennis.local` - Admin panel
- `phpmyadmin.tennis.local` - Database management (PHP projects)
- `adminer.tennis.local` - Database management (any stack)
- `mailhog.tennis.local` - Email testing
- `redis.tennis.local` - Redis commander

### Docker Compose Example
```yaml
services:
  app:
    labels:
      - "traefik.http.routers.app.rule=Host(`app.${PROJECT_NAME}.local`)"
      
  phpmyadmin:  # Added for PHP/MySQL projects
    image: phpmyadmin/phpmyadmin
    labels:
      - "traefik.http.routers.pma.rule=Host(`phpmyadmin.${PROJECT_NAME}.local`)"
    environment:
      PMA_HOST: mysql
      
  mailhog:  # Added for email testing
    image: mailhog/mailhog
    labels:
      - "traefik.http.routers.mail.rule=Host(`mailhog.${PROJECT_NAME}.local`)"
```

### .env Configuration
```bash
PROJECT_NAME=tennis  # Used for all domain names
```

### Development Tools by Stack

**PHP Stack:**
- phpMyAdmin for MySQL
- Xdebug configured
- Composer in container

**Node.js Stack:**
- Adminer for any DB
- Node debugger configured
- NPM/Yarn in container

**Python Stack:**
- pgAdmin for PostgreSQL
- pdb debugger configured
- pip/poetry in container

## Committee Agent Roles

### Lead Developer (Primary)
- **Round 1**: Technical feasibility, development tooling, Hello World path
- **Round 2**: Component boundaries, API interfaces, technical dependencies
- **Round 3**: Final PRD authoring, technical specification synthesis

### DevOps Architect (Co-Lead)  
- **Round 1**: Infrastructure readiness, deployment pipeline, environment setup
- **Round 2**: Deployment dependencies, infrastructure boundaries, operational concerns
- **Round 3**: Infrastructure specifications, monitoring and deployment sections

### Product Owner
- **Round 1**: Business priority validation, feature completeness check
- **Round 2**: Business value boundaries, user story continuity, acceptance criteria
- **Round 3**: Business requirements validation, user story coherence

### UX Designer
- **Round 1**: User journey continuity, interface dependency mapping
- **Round 2**: User experience boundaries, interface coherence, workflow splits
- **Round 3**: User experience specifications, interface design continuity

## Success Criteria

- ✅ **Parallelizable**: Splits can be developed simultaneously by different teams
- ✅ **Complete**: All master PRD functionality covered across splits
- ✅ **Dependencies Clear**: Inter-split dependencies explicitly documented
- ✅ **Context Preserved**: Master PRD context maintained in each split
- ✅ **Epic Ready**: Each split PRD ready for immediate epic conversion