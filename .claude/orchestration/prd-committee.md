# PRD Committee Orchestration Workflow

## Workflow Definition
```yaml
workflow_id: prd-committee
workflow_version: 1.0
workflow_type: collaborative_document_creation
deliverable_type: product_requirements_document
estimated_duration_minutes: 20
max_duration_minutes: 30
```

## Orchestration Phases

### Phase 1: Drafting by rounds
```yaml
phase_id: drafting_rounds
execution_mode: ${EXECUTION_MODE:sequential}
timeout_minutes: 16  # 8 minutes per round
parallel_max_agents: 4
success_criteria:
  min_agents_success: 3
  min_output_length: 500
  required_sections_present: true
  rounds_completed: 2
```

**Phase Actions:**
This phase executes two complete subphases/rounds of drafting and cross-rating.

**Round Structure:**
Each round consists of (sequentialy):
1. **Agent Drafting**: Each agent creates/revises their PRD sections
2. **Cross-Feedback**: Each agent provides detailed critique of all other agents' work
3. **Feedback Analysis**: CTO analyzes feedback for consensus

**Agent Specifications:**
- **devops-architect**: Focus on security, scalability, infrastructure, operational monitoring
- **lead-developer**: Technical architecture, API design, database patterns, development timeline  
- **ux-designer**: Mobile-first design, user journey optimization, accessibility compliance
- **product-owner**: Market analysis, go-to-market strategy, ROI projections, business value

**Round Execution:**
```
FOR round IN [1, 2]:
  # Initialize round directory
  mkdir -p "${COMMITTEE_DIR}/round${round}"
  
  # Agent drafting phase
  FOR EACH agent IN [devops-architect, lead-developer, ux-designer, product-owner]:
    INVOKE Task tool:
      - subagent_type: {agent}
      - context: Feature requirements + (round 2+: incorporate previous round results and CTO guidance)
      - task: Create/revise PRD section from agent's perspective
      - output: ${COMMITTEE_DIR}/round${round}/${agent}.md
  
  # Cross-feedback phase
  FOR EACH reviewer IN [devops-architect, lead-developer, ux-designer, product-owner]:
    INVOKE Task tool:
      - subagent_type: {reviewer}
      - context: Read {reviewer}'s own draft AND all other agents' drafts
      - task: Provide detailed, assertive critique and ratings of all other agents' work with concrete examples, including technical confidence level and professional assessment of work quality
      - output: ${COMMITTEE_DIR}/round${round}/${reviewer}_feedback.md
  
  # CTO analysis after each round
  INVOKE Task tool:
    - subagent_type: cto-agent
    - context: Read all ${COMMITTEE_DIR}/round${round}/ files (drafts + ratings)
    - task: Analyze convergence progress and provide guidance for next round
    - output: ${COMMITTEE_DIR}/round${round}/cto_analysis.md
```

### Phase 2: Final CTO Decision
```yaml
phase_id: cto_final_decision
execution_mode: sequential
timeout_minutes: 4
convergence_threshold: 7.5
cto_arbitration: true
```

**Phase Actions:**
1. **Final CTO Analysis**
   ```bash
   INVOKE Task tool:
     - subagent_type: cto-agent
     - context: Read all rounds\' results and evolution between rounds
     - task: Explain final choices, rationale, and arbitration decisions
     - output: ${COMMITTEE_DIR}/final_analysis.md
   ```

2. **Convergence Validation**
   ```bash
   # Extract convergence decision from CTO analysis
   convergence_achieved=$(grep -q "CONVERGENCE ACHIEVED" "${COMMITTEE_DIR}/final_analysis.md" && echo "true" || echo "false")
   
   if [[ "$convergence_achieved" != "true" ]]; then
     phase_fail "CTO determined convergence not achieved"
   fi
   ```

### Phase 3: Final PRD Synthesis
```yaml
phase_id: prd_synthesis
execution_mode: sequential
timeout_minutes: 2
output_location: .doh/prds/
template: committee-generated-prd
```

**Phase Actions:**
1. **Prepare PRD Template**
   ```bash
   # Create empty PRD template with frontmatter
   helper.sh committee create_final_prd "${FEATURE_NAME}" > "/tmp/prd_template_${FEATURE_NAME}.md"
   ```

2. **Generate Final PRD**
   ```bash
   INVOKE Task tool:
     - subagent_type: cto-agent  
     - context: Committee results, final_analysis.md, and PRD template
     - task: Create comprehensive PRD reflecting committee consensus with concrete technical guidance
     - requirements: |
       The PRD must include actionable technical specifications:
       - Specific technology stack recommendations (not just "modern technologies")
       - Development environment setup (Docker configurations, tooling)
       - Infrastructure requirements with concrete sizing/scaling guidance
       - Security implementation specifics (authentication methods, encryption standards)
       - Documentation deliverables (API specs, deployment guides, user manuals)
       - Testing strategy with specific frameworks and coverage targets
       - Monitoring and observability implementation details
       - Performance benchmarks and SLA definitions
       This is NOT a wishlist - provide implementable, specific guidance
     - output: ${DOH_DIR}/prds/${FEATURE_NAME}.md
   ```

3. **Final Validation**
   ```bash
   # Validate PRD completeness and specificity
   prd_file="${DOH_DIR}/prds/${FEATURE_NAME}.md"
   
   # Check required sections exist
   required_sections=("Executive Summary" "Technical Architecture" "User Experience" "Business Requirements" "Implementation Plan" "Development Environment" "Documentation Deliverables")
   for section in "${required_sections[@]}"; do
     grep -q "$section" "$prd_file" || phase_fail "Missing required section: $section"
   done
   
   # Check minimum length and technical specificity
   word_count=$(wc -w < "$prd_file")
   [[ $word_count -ge 1500 ]] || phase_fail "PRD too short: $word_count words"
   
   # Verify technical specificity (not just generic recommendations)
   grep -q "Docker\|Kubernetes\|specific" "$prd_file" || phase_fail "PRD lacks technical specificity"
   ```

## Agent Role Specifications

### devops-architect
```yaml
primary_focus: [infrastructure, security, scalability, compliance]
agent_invocation:
  - Task tool with devops-architect subagent
  - Context provided via prompt with feature requirements and task specifics
required_outputs:
  - Security architecture and threat assessment
  - Scalability strategy and infrastructure requirements  
  - Monitoring and observability approach
  - Deployment and operational procedures
  - Compliance and regulatory considerations
success_metrics:
  - Security threats identified and mitigated
  - Scalability bottlenecks addressed
  - Operational procedures defined
  - Compliance requirements satisfied
```

### lead-developer  
```yaml
primary_focus: [technical_architecture, implementation, code_quality]
agent_invocation:
  - Task tool with lead-developer subagent
  - Context provided via prompt with feature requirements and task specifics
required_outputs:
  - Technology stack selection and justification
  - System architecture and design patterns
  - API design and integration strategy
  - Database design and data modeling
  - Development timeline and resource estimates
success_metrics:
  - Architecture decisions justified
  - Implementation approach feasible
  - Integration strategy clear
  - Development timeline realistic
```

### ux-designer
```yaml
primary_focus: [user_experience, accessibility, design_systems]
agent_invocation:
  - Task tool with ux-designer subagent
  - Context provided via prompt with feature requirements and task specifics  
required_outputs:
  - User journey mapping and workflow optimization
  - Design system and component specifications
  - Accessibility compliance strategy (WCAG 2.1 AA)
  - Mobile-first responsive design approach
  - Usability testing and validation plan
success_metrics:
  - User workflows optimized for efficiency
  - Accessibility requirements comprehensive
  - Design consistency maintained
  - Mobile experience prioritized
```

### product-owner
```yaml
primary_focus: [business_strategy, market_analysis, success_metrics]
agent_invocation:
  - Task tool with product-owner subagent
  - Context provided via prompt with feature requirements and task specifics
required_outputs:
  - Business case and value proposition
  - Market analysis and competitive positioning
  - Success metrics and KPIs definition
  - Go-to-market strategy and timeline
  - Revenue model and ROI projections
success_metrics:
  - Business value clearly quantified
  - Market opportunity validated
  - Success criteria measurable
  - Go-to-market strategy executable
```

## File Structure Per Phase

### Round Files Structure (applies to both Round 1 and Round 2)
```
${COMMITTEE_DIR}/round{1|2}/
├── devops-architect.md        # DevOps PRD (draft/revision)
├── lead-developer.md          # Technical PRD (draft/revision)
├── ux-designer.md            # UX PRD (draft/revision)
├── product-owner.md          # Business PRD (draft/revision)
├── devops-architect_feedback.md   # DevOps critiques all others
├── lead-developer_feedback.md    # Lead Dev critiques all others
├── ux-designer_feedback.md       # UX critiques all others
├── product-owner_feedback.md     # PO critiques all others
└── cto_analysis.md               # CTO analysis after each round
```

**Process**: The workflow executes this structure twice - Round 1 for initial drafts and feedback, Round 2 for revisions and final feedback.

## Feedback File Format Example

Each agent produces a single feedback file containing their detailed critique of all other agents.  
This structure applies to both Round 1 and Round 2 feedback.

### Individual Feedback File Structure (example: devops-architect_feedback.md)
```markdown
# DevOps Architect Cross-Team Feedback - Round 1

**Reviewer:** devops-architect  
**Round:** 1  
**Feature:** ${FEATURE_NAME}
**Review Date:** $(date -u +"%Y-%m-%dT%H:%M:%SZ")

---

## Feedback: Lead Developer

**Overall Score: 6.5/10**

### Technical Mood & Confidence Level
**Current Vibe: Solid foundation, major gaps to address 🔧⚠️**

Good technical instincts on API design and containerization - this feels like working with competent engineers. However, the security and scalability blind spots are concerning for production readiness. The technical approach is sound but incomplete. Need to see infrastructure planning to match the code quality before feeling confident about launch.

### Detailed Assessment
- **Technical Architecture (8/10)**: Well-defined API structure, appropriate tech stack choices
- **Security Considerations (3/10)**: Critical security gaps that could compromise production
- **Infrastructure Compatibility (7/10)**: Good containerization approach, missing scalability
- **Implementation Feasibility (6/10)**: Realistic in scope but timeline concerns due to missing components

### What's Working Well
- **API Design**: The REST API structure is solid with proper resource modeling and HTTP verb usage
- **Database Schema**: PostgreSQL choice is appropriate for ACID compliance requirements
- **Containerization**: Docker setup shows good understanding of deployment patterns

### Critical Issues That Must Be Addressed

**🔴 CRITICAL - Security Architecture Missing (Score: 3/10)**
Your PRD completely ignores security at the infrastructure level. This is unacceptable for a production system:
- No mention of TLS termination strategy 
- Zero discussion of secret management (how are DB credentials handled?)
- Missing network segmentation between web tier and database
- No consideration of DDoS protection or rate limiting

**🔴 CRITICAL - Scalability Not Planned (Score: 4/10)**  
The architecture assumes a single-instance deployment which will fail under load:
- No horizontal scaling strategy for the API layer
- Database connection pooling not addressed
- No caching layer (Redis/Memcached) for session management
- Missing load balancer configuration

**🟡 MEDIUM - Operations Blindness (Score: 5/10)**
- No monitoring strategy defined (how do we know when things break?)
- Missing deployment rollback procedures
- No health check endpoints specified
- Backup strategy not mentioned

### Specific Technical Issues
1. **Line 47**: "Simple database connection" - This will create connection exhaustion under concurrent load
2. **Section 3.2**: Claims "cloud-ready" but provides no cloud provider specifics or multi-AZ considerations
3. **Authentication section**: JWT tokens mentioned but no key rotation strategy

### Required Actions for Next Round
- Add complete infrastructure security section with threat model
- Define horizontal scaling architecture with specific performance metrics
- Include comprehensive monitoring and alerting strategy
- Specify CI/CD pipeline with automated rollback capabilities

---

## Feedback: UX Designer  

**Overall Score: 7.8/10**

### Technical Mood & Confidence Level  
**Current Vibe: Strong design thinking, performance reality check needed 🎨⚡**

Excellent accessibility focus and user-centered approach - this is how you design for real users. The technical integration awareness is better than most design work I review. However, performance assumptions need adjustment for infrastructure constraints. Good design foundation that needs technical grounding.

### Detailed Assessment
- **User Experience Design (9/10)**: Excellent accessibility focus and user journey mapping
- **Technical Integration (6/10)**: Performance assumptions don't align with infrastructure reality
- **Security Awareness (7/10)**: Good privacy considerations, missing 2FA flow integration
- **Operational Impact (8/10)**: Strong consideration of user analytics and monitoring needs

### What's Working Well
- **Accessibility Focus**: WCAG 2.1 AA compliance is properly prioritized
- **Mobile-First Approach**: Progressive enhancement strategy is sound
- **User Journey Mapping**: Flow diagrams clearly show user pain points
- **Offline Functionality**: Excellent understanding of user needs for offline capability

### Infrastructure Reality Check

**🟡 MEDIUM - Performance Assumptions Unrealistic (Score: 6/10)**
Your designs assume instant load times that our infrastructure can't deliver:
- 16 different fonts will kill page load performance (each font = additional HTTP request)
- High-res images without CDN consideration will cause 3-5 second load delays
- Client-side rendering of complex data tables should be server-side for performance

**🟡 MEDIUM - Security UX Integration Gaps (Score: 7/10)**
- No consideration of how 2FA affects user flows (adds 30-45 seconds to login)
- Password requirements UX doesn't match our security policy complexity
- Session timeout handling not addressed in user flows (will confuse users)

### Required Actions for Next Round
- Include performance budgets for each page (target load times)
- Design 2FA integration flows that don't disrupt user experience
- Consider infrastructure constraints in high-frequency user actions

---

## Feedback: Product Owner

**Overall Score: 5.5/10**

### Technical Mood & Confidence Level
**Current Vibe: Strong business case, technical planning disconnect 📈⚠️**

Solid market research and business fundamentals - good product-market fit validation. However, technical timeline and resource assumptions are disconnected from infrastructure reality. Business strategy is sound but needs technical feasibility alignment to be executable.

### Detailed Assessment
- **Business Requirements (8/10)**: Clear value proposition and solid market research
- **Technical Feasibility (2/10)**: Timelines and technical assumptions disconnected from reality
- **Security & Compliance (3/10)**: Dangerous ignorance of compliance requirements
- **Operational Readiness (6/10)**: Good go-to-market strategy, poor resource planning

### What's Working Well
- **Market Research**: Customer interviews show solid validation
- **Revenue Projections**: Financial model is realistic and well-researched
- **Go-to-Market Strategy**: Clear understanding of customer acquisition channels

### Critical Technical Reality Gaps

**🔴 CRITICAL - Technical Feasibility Unrealistic (Score: 2/10)**
Your timelines and technical assumptions are disconnected from engineering reality:
- "Simple integration with 15 third-party APIs" - Each API integration is 2-3 weeks minimum
- "Real-time analytics dashboard" - This requires streaming infrastructure you haven't budgeted
- "99.99% uptime" - You've allocated zero budget for redundant infrastructure

**🔴 CRITICAL - Compliance Requirements Ignored (Score: 3/10)**  
You're planning to handle PII data but show zero understanding of compliance requirements:
- GDPR right-to-deletion requires significant architecture changes
- PCI DSS for payment processing needs separate network segments  
- HIPAA compliance (if medical data) requires encrypted storage at rest

**🟡 MEDIUM - Resource Planning Unrealistic (Score: 4/10)**
- Assuming 1 developer can handle frontend, backend, and DevOps
- No budget allocated for security audits or penetration testing
- Infrastructure costs underestimated by approximately 300%

### Required Actions for Next Round
- Consult with technical advisors on realistic development timelines
- Include compliance requirements and associated development costs
- Revise resource allocation to include security and infrastructure specialists
- Align business metrics with actual technical capabilities

---

## Overall Committee Assessment

**Highest Risk**: Product Owner's unrealistic technical assumptions could derail the project timeline and budget.

**Best Cross-Functional Awareness**: UX Designer demonstrates good understanding of technical constraints in design decisions.

**Universal Gap**: All team members need to address disaster recovery, data backup, and incident response procedures.

**Common Misconception**: Everyone assumes "cloud deployment" provides automatic scalability without considering implementation complexity and costs.

---

**Summary:** Each agent produces one markdown file containing their detailed, assertive critique and ratings of all other agents. These files combine numerical ratings with specific, actionable feedback, concrete examples of what's working and what needs improvement, AND technical confidence assessments about work quality and project viability. The CTO agent reads these for convergence analysis and understanding technical team confidence.

### Final Analysis Files
```
${COMMITTEE_DIR}/
└── final_analysis.md         # CTO final convergence decision and rationale
```

## Error Handling Strategies

### Agent Failure Recovery
```yaml
max_retries_per_agent: 1
fallback_strategies:
  - continue_with_available_agents (minimum 3 required)
  - use_previous_round_output (for Round 2 failures)  
  - request_manual_intervention (for critical failures)
```

### Timeout Handling
```yaml
grace_period_seconds: 30
timeout_strategies:
  - partial_results_acceptable (if 75%+ complete)
  - extend_timeout_once (additional 50% time)
  - escalate_to_manual (for critical timeouts)
```

### Quality Gate Failures
```yaml
validation_failures:
  - retry_phase_once (with enhanced context)
  - lower_success_thresholds (minimum viable criteria)
  - escalate_to_cto (for unresolvable conflicts)
```

## Integration with DOH Helpers

### Committee Helper Integration
```bash
# All workflow phases handled directly by committee-orchestrator via Task tool
# Only seed management and PRD template creation use helpers:
helper.sh committee seed_create FEATURE
helper.sh committee seed_exists FEATURE  
helper.sh committee seed_update FEATURE
helper.sh committee seed_delete FEATURE
helper.sh committee create_final_prd FEATURE
```

### Orchestration Helper Functions
```bash
# Read orchestration file
orchestration_get_phase ORCHESTRATION_FILE PHASE_ID

# Execute phase according to orchestration (uses Task tool for agents)
orchestration_execute_phase FEATURE PHASE_ID

# Validate phase completion
orchestration_validate_phase FEATURE PHASE_ID

# Rating file management (handled by Task tool agents)
```