# PRD Committee Orchestration Manifest

## Orchestration Metadata
```yaml
orchestration_id: prd-committee
version: 2.0
type: multi-agent-collaborative
purpose: product-requirements-document
```

## Agent Configuration

### Participating Agents
Define which agents participate in this committee workflow:

```yaml
agents:
  # Core committee members (participate in all rounds)
  participants:
    - agent: devops-architect
      orchestration: .claude/orchestration/prd-committee/agents/devops-architect.md
      role: infrastructure-security-specialist
      
    - agent: lead-developer
      orchestration: .claude/orchestration/prd-committee/agents/lead-developer.md
      role: technical-architecture-specialist
      
    - agent: ux-designer
      orchestration: .claude/orchestration/prd-committee/agents/ux-designer.md
      role: user-experience-specialist
      
    - agent: product-owner
      orchestration: .claude/orchestration/prd-committee/agents/product-owner.md
      role: business-requirements-specialist
  
  # Arbitration and synthesis
  arbitrator:
    agent: cto-agent
    orchestration: .claude/orchestration/prd-committee/agents/cto-agent.md
    role: convergence-analyzer
    invoked_at: [round_analysis, final_synthesis]
```

## Configuration Reference
```yaml
configuration: ./config.md      # Human-editable settings
```

### Workflow Structure
```yaml
phases_per_round:
  - phase: draft
    description: Agents create/revise PRD sections
    duration_source: config.timeouts.draft_minutes
    execution_constraint: parallel_allowed  # Can use seed execution_mode
    
  - phase: feedback
    description: Agents review each other's work
    duration_source: config.timeouts.feedback_minutes
    execution_constraint: sequential_only   # Must be sequential (agents read each other's outputs)
    
  - phase: analysis
    description: CTO analyzes convergence
    duration_source: config.timeouts.analysis_minutes
    execution_constraint: single_agent      # Only arbitrator agent runs
```

## Output Configuration

### Directory Structure
```yaml
session_structure:
  root: .doh/committees/{feature_name}/
  files:
    - seed.md               # Initial context (created by helper)
    - session.yaml          # Session metadata
    - round{N}/             # Dynamic round directories
      - {agent}.md          # Agent drafts
      - {agent}_feedback.md # Agent feedback
      - cto_analysis.md     # Round analysis
    - final_analysis.md     # Final convergence decision
    - session.log          # Audit trail
```

### PRD Output
```yaml
deliverable:
  path: .doh/prds/{feature_name}.md
  format: markdown-with-frontmatter
  required_sections:
    - Executive Summary
    - Technical Architecture
    - Infrastructure & Security
    - User Experience
    - Business Requirements
    - Implementation Plan
    - Development Environment
    - Testing Strategy
    - Success Metrics
  strategic_technical_requirements:
    - Clear architectural decisions (SPA vs traditional, SQL vs NoSQL, microservices vs monolith)
    - Strategic technology choices (CMS vs custom, cloud vs on-premise, framework philosophy)
    - Approach definitions that guide epic creation (authentication strategy, deployment philosophy)
    - High-level patterns that affect team structure and long-term maintenance
    - **Technical debt assessment**: Current stack evaluation and migration justification if changes proposed
    - **Conservative bias**: Default to extending existing systems unless compelling reasons for change
    - Leave specific versions, tools, and implementation details to epic/development phase
```

## Seed Configuration

### Seed Structure Expected
The manifest expects seed files with this structure:

```yaml
# Required Fields
feature_name: string        # Kebab-case identifier
description: string         # Feature summary
target_version: string      # Semantic version
execution_mode: string      # sequential|parallel

# Context Fields (used by agents)
context:
  problem_statement: string
  business_context: string
  technical_context: string
  current_stack: string
  requirements: string
  constraints: string
  success_criteria: string
```

### Templates
```yaml
seed_template: ./templates/seed.md           # Template for seed creation
prd_template: ./templates/prd.md             # Template for final PRD creation
seed_location: .doh/committees/{feature_name}/seed.md
prd_location: .doh/prds/{feature_name}.md
```

### Seed Validation (Optional)
```yaml
seed_validation:
  enabled: true
  validation_spec: ./check.md
  enforcement_level: strict        # strict|warning|disabled
  quality_threshold: 7.0          # Minimum context quality score
  fail_fast: true                 # Stop execution on validation failure
```

### How This Manifest Uses Seeds
1. **Validates seed** (if enabled) using check.md criteria
2. **Reads seed** for session configuration and context  
3. **Extracts** feature_name, execution_mode, and context
4. **Passes context** to agents during rounds
5. **Ignores** orchestration references in seed (manifest is authoritative)

## Integration Points

### Helper Script Compatibility
The orchestration maintains full compatibility with existing helper scripts:

```bash
# Seed management (unchanged)
helper.sh committee seed-create FEATURE CONTENT
helper.sh committee seed-read FEATURE
helper.sh committee seed-exists FEATURE

# PRD template generation (unchanged)
helper.sh committee create-final-prd FEATURE
```

### Orchestrator Instructions
When the committee-orchestrator receives a feature name:

1. **Load this manifest** to understand the workflow structure
2. **Load configuration**: Read `./config.md` for round limits, timeouts, convergence criteria
3. **Read seed** from `.doh/committees/{feature}/seed.md` for context data
4. **Validate seed** (if manifest.seed_validation.enabled) using `./check.md`
5. **Read workflow file**: Load `./workflow.md` for execution algorithms and patterns
6. **Execute workflow** using config settings with workflow.md algorithms

### For Individual Agents
Agents receive:
- Their orchestration from `./agents/{agent}.md`
- Shared context from seed
- Round number and phase
- Previous round results (if applicable)

### Backward Compatibility
Seeds may contain legacy orchestration references - these are ignored.
The manifest is the single source of truth for workflow execution.

## Execution Modes

```yaml
execution_modes:
  sequential:
    description: Memory-efficient, agents run one at a time
    default: true
    
  parallel:
    description: Faster execution, agents run simultaneously
    requires_flag: --parallel
```

## Quality Assurance

### Validation Rules
- All participating agents must complete each round
- Minimum output length per agent: 500 words
- All required sections must be present
- Consensus score must meet threshold

### Error Handling
- Single agent failure: Retry once, then continue
- Multiple failures: Escalate to manual review
- Timeout: Use partial results if >75% complete
- Convergence failure: Force synthesis after max rounds