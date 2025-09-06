---
name: prd-committee
description: Multi-agent collaborative committee for superior quality PRD creation with specialized roles
status: backlog
created: 2025-08-30T23:19:05Z
---

# PRD: Multi-Agent Committee for Collaborative PRD Creation

## Executive Summary

Transform PRD creation from a solo process to a **multidisciplinary committee of 4 specialized agents** (DevOps, Lead Dev, UX, PO) with CTO validation. **2 iterative rounds** with cross-rating, contradictory debates, and convergence toward superior quality PRDs integrating all business perspectives.

## Problem Statement

### Current Problems
- **Mono-perspective PRDs**: Single agent creates PRD, lacks holistic vision
- **Late-discovered tensions**: DevOps vs Dev vs UX vs Business conflicts emerge during implementation
- **Inconsistent quality**: PRDs without specific domain expertise (security, UX, market)
- **Sub-optimal decisions**: No upstream idea confrontation

### Why Now?
The DOH framework with specialized agents finally enables **simulating a complete product team** to create robust PRDs with all business expertise from conception.

## User Stories

### As a Product Manager
- I want my PRD to **automatically integrate** DevOps, technical, UX and business expertise
- I want to see the **debates and arbitrations** between different perspectives
- I want **technical tensions** identified before implementation
- I want to **make final decisions** when agents can't converge

### As a Developer
- I want PRDs to include **real technical constraints** from conception
- I want **architecture choices** debated upfront
- I want to avoid **UX surprises** or **DevOps constraints** discovered during development

### As a Tech Lead
- I want my **technical choices** confronted with other concerns
- I want to negotiate **trade-offs** between velocity and robustness
- I want **technical feasibility** properly evaluated

### As a DevOps Engineer
- I want **security and deployment concerns** integrated from spec stage
- I want **pipelines and monitoring** considered in architecture
- I want to defend **robustness** against speed demands

## Requirements

### Functional Requirements

#### FR1: Multi-Agent Committee
**4 specialized agents** with defined roles:
- 🏗️ **DevOps Architect**: Robustness, security, infrastructure, deployments
- 💻 **Lead Developer**: Technology choices, patterns, state-of-the-art
- 🎨 **UX Designer**: User experience, journeys, mobile-first, accessibility
- 💼 **Product Owner**: Market, ROI, business opportunities, SaaS vs standalone
- **CTO Agent**: Validation, arbitration, technical and business challenge

#### FR2: 2-Round Process

**Round 1 - Exploration:**
1. **Separate drafting**: Each agent produces their PRD version
2. **Cross-rating**: Agents rate others (1-5 ⭐) with arguments
3. **CTO feedback**: Challenge and tension identification

**Round 2 - Convergence:**
4. **Revision**: Agents revise based on CTO feedback and constraints
5. **Final rating**: New rating on revised versions
6. **Delivery**: Consolidated PRD or human escalation if divergence

#### FR3: Rating and Consensus System
- **1-5 scores** with mandatory justification
- **Convergence calculation**: If gap < threshold → auto validation
- **Divergence handling**: CTO presents options → human decides

#### FR4: Complete Historization
- **Session minutes** for each round
- **Successive versions** of PRDs by agent
- **Detailed arguments and scores**
- **Identified tensions** and resolutions
- **CTO decisions** and rationale

#### FR5: DOH Integration

**Dual Command Approach:**
- **Legacy**: `/doh:prd-new feature` - Solo PRD creation (kept as-is)
- **Evolution**: `/doh:prd-evo feature` - Committee workflow (new)
- **User choice**: Two distinct commands for different approaches
- **Testing**: Validate `/doh:prd-evo` thoroughly before broader adoption

**Committee Command Features:**
- **Full workflow**: Context gathering → Orchestrator → 4 agents + CTO → Final PRD
- **Historization**: Complete session records in `${doh_project_dir}/committees/{feature}/`
- **Compatibility**: Same PRD output format as `/doh:prd-new`
- **Workflow**: PRD → `/doh:prd-parse` → Standard epic

### Non-Functional Requirements

#### NFR1: Performance
- **Complete process < 15 minutes** (vs 3-5 min solo PRD)
- **Parallel sessions** when possible
- **Timeouts** on infinite debates

#### NFR2: Quality
- **Traceable arguments** for each decision
- **Consistency** between final PRD sections
- **Completeness**: All business perspectives covered

#### NFR3: Usability
- **Transparency**: User sees the process
- **Minimal intervention**: Human escalation only when necessary
- **Understanding**: Accessible minutes and rationale

## Success Criteria

### Launch Criteria
- [ ] 4 specialized agents operational with distinct personalities
- [ ] Functional 2-round process with rating
- [ ] CTO agent capable of arbitration
- [ ] Complete session historization
- [ ] Default `/doh:prd-new` integration

### Long-term Success
- **Adoption**: 90% PRDs use committee (< 10% solo)
- **Quality**: 60% reduction in post-PRD changes during implementation
- **Satisfaction**: 85% developer preference for committee vs solo PRDs
- **Discovery**: 80% technical tensions identified before development
- **Time**: Process stabilized to < 10 minutes with experience

## Technical Approach

### Agent Architecture

#### DevOps Architect Agent
```yaml
personality: Rigorous, security-focused, long-term
concerns:
  - "Proper migration even if longer"
  - "Separate BO from frontend with clean APIs"
  - "Secure pipelines mandatory"
tensions:
  - vs Lead Dev: "Secure deliveries vs velocity"
  - vs PO: "Robustness vs time-to-market"
```

#### Lead Developer Agent
```yaml
personality: Pragmatic, technical, solution-oriented
concerns:
  - "Vue.js + Symfony for this spec"
  - "State-of-the-art and best practices"
  - "Realistic technical feasibility"
tensions:
  - vs DevOps: "These pipelines are painful"
  - vs UX: "Complexity of your demands"
```

#### UX Designer Agent
```yaml
personality: User-centric, creative, experience quality
concerns:
  - "Mobile-first but not only"
  - "Smooth Progressive Web App"
  - "Accessibility and ergonomics"
tensions:
  - vs Lead Dev: "Feasibility vs UX vision"
  - vs PO: "Experience vs features"
```

#### Product Owner Agent
```yaml
personality: Business-oriented, market-focused, ROI-driven
concerns:
  - "Multi-tenant SaaS = huge market"
  - "Critical time-to-market"
  - "Economic opportunities"
tensions:
  - vs DevOps: "Velocity vs architecture"
  - vs UX: "Features vs pretty"
```

#### CTO Agent
```yaml
personality: Arbitrator, strategic, balanced
responsibilities:
  - Technical AND business challenge
  - Tension identification
  - Compromise proposals
  - Escalation when necessary
```

### Rating System

```python
# Scores by agent
scores = {
    'devops': [4, 5, 3],    # Ratings given to others
    'lead': [5, 2, 4],
    'ux': [3, 3, 5],
    'po': [4, 4, 3]
}

# Convergence calculation
convergence_threshold = 1.0
if max_score_difference < convergence_threshold:
    consensus = True
else:
    escalate_to_cto()
```

### File Structure

```
{doh_project_root}/
└── .doh/                         # doh_project_dir()
    ├── prds/
    │   └── {feature}.md          # Final PRD
    ├── committees/
    │   └── {feature}/
    │       ├── session.md        # Session minutes
    │       ├── seed.md           # Initial context (optional)
    │       ├── round1/
    │       │   ├── devops.md     # DevOps version round 1
    │       │   ├── lead.md       # Lead version round 1
    │       │   ├── ux.md         # UX version round 1
    │       │   ├── po.md         # PO version round 1
    │       │   ├── scores.json   # Cross-rating scores
    │       │   └── cto-feedback.md # CTO feedback round 1
    │       ├── round2/
    │       │   ├── devops.md     # DevOps revised version
    │       │   ├── lead.md       # Lead revised version
    │       │   ├── ux.md         # UX revised version
    │       │   ├── po.md         # PO revised version
    │       │   ├── scores.json   # Final cross-rating scores
    │       │   └── cto-feedback.md # CTO feedback round 2
    │       └── final-decision.md # Final decision
    ├── epics/
    └── versions/
```

## `/doh:prd-evo` Workflow Specification

### Main Stream (Claude Principal) - Context Phase

**Step 1: Initial Context Gathering**
- Read project context (VERSION, .doh/versions/, .doh/prds/, .doh/epics/)
- Conduct comprehensive discovery with user (same as `/doh:prd-new` steps 1-4)
- Synthesize parameters: feature name, description, target version

**Step 2: Present Committee Approach**
```
🏛️ PRD Evolution - Multi-Agent Committee
=========================================

Feature: ${FEATURE_NAME}
Description: ${DESCRIPTION}  
Target: ${TARGET_VERSION}

This PRD will be created through collaborative committee process:
• 🏗️ DevOps Architect • 💻 Lead Developer • 🎨 UX Designer • 💼 Product Owner
• 👨‍💼 CTO Arbitrator

Process: 2 rounds → Cross-rating → Convergence → Final PRD
Duration: ~15 minutes vs 5 min solo

Ready to launch committee? [Y/n]
```

**Step 3: Orchestrator Handoff**
- Package complete context for orchestrator agent
- Launch orchestrator with: `{feature_name, description, target_version, user_context, project_context}`
- Monitor orchestrator progress (optional status updates)

### Orchestrator Agent - Committee Management

**Step 4: Committee Session Setup**
- Create session workspace: `${doh_project_dir}/committees/{feature}/`
- Initialize 4 specialized agents + CTO agent
- Set up scoring and convergence system

**Step 5: Round 1 - Exploration**
- Launch 4 agents in parallel with shared context
- Each agent creates their PRD version from their perspective
- Cross-rating: Each agent scores others (1-5 ⭐) with arguments
- CTO analysis: Identify tensions and feedback

**Step 6: Round 2 - Convergence** 
- Agents revise PRDs based on CTO feedback and peer ratings
- Final cross-rating on revised versions
- Convergence check: If scores converge → Final PRD
- If divergence → CTO presents options

**Step 7: Session Historization**
- Save all PRD versions, scores, arguments, CTO decisions
- Generate session minutes
- Create final consolidated PRD

### Main Stream - Final Phase

**Step 8: Receive Committee Output**
- Orchestrator returns: Final PRD OR multiple options if no convergence
- If multiple options → User chooses final version
- Save PRD to `.doh/prds/{feature}.md`

**Step 9: Post-Creation**
- Same as current `/doh:prd-new` (populate sections, next steps)
- Plus: Show committee session summary and link to full minutes

## Implementation Strategy

### Phase 1: Core Components (Week 1)
- Create `/doh:prd-evo.md` command specification
- Develop orchestrator agent framework  
- Build 4 specialized agents with distinct personalities
- Test agent interactions and realistic tensions

### Phase 2: Committee Process (Week 2)
- Implement 2-round workflow with scoring
- Build CTO agent with arbitration capabilities
- Complete session historization system
- Test convergence and divergence scenarios

### Phase 3: DOH Integration (Week 3)
- Full `/doh:prd-evo` command implementation
- Context handoff between main stream and orchestrator
- File structure and workspace management
- Complex PRD testing and validation

### Phase 4: Optimization (Week 4)
- Performance tuning and timeout handling
- User experience refinement
- Convergence threshold calibration
- Documentation and user guidance

## Example Sessions

### Example 1: SaaS vs Standalone Tension

**Round 1:**
- **PO**: "Multi-tenant SaaS = 10x bigger market"
- **DevOps**: "Complex migration, necessary splitting"
- **Lead**: "OK but requires Symfony multi-tenant + Vue.js"
- **UX**: "Admin + user interface, mobile mandatory"

**CTO Feedback**: "PO is right about market, but DevOps don't underestimate complexity. Lead, why not Laravel? UX, mobile-first but not full PWA in v1."

**Round 2**: Revisions and compromises → Balanced PRD

### Example 2: Quick Consensus

**Round 1**: Convergent scores (gap < 1)
**Result**: Automatic validation without round 2

## Dependencies

### Technical Dependencies
- Existing DOH agent framework
- Task system for parallel agents
- Storage for session historization

### Process Dependencies
- Agent personality definitions
- Convergence threshold calibration
- User training on escalation

## Constraints & Assumptions

### Constraints
- **Compatibility**: Same output as current PRDs
- **Performance**: Max 15 min vs 5 min solo PRD
- **Maintenance**: Stable agent personalities

### Assumptions
- Users accept extra time for quality
- Simulated tensions are representative
- 4 agents sufficient (no need for Legal, Finance, etc.)

## Out of Scope

### V1 Exclusions
- **Human agents** in committee (100% AI)
- **Slack/Teams integration** for notifications
- **ML/Learning** of user preferences
- **Cross-validation** with real product team
- **Quantitative metrics** of PRD quality

### Future Considerations
- **Security Agent** for sensitive features
- **Legal Agent** for GDPR compliance
- **GitHub integration** for PRD reviews
- **PRD templates** by business domain

## Timeline

| Milestone | Duration | Deliverables |
|-----------|----------|--------------|
| Agent Prototypes | 3 days | 4 agents + CTO functional |
| 2-Round Process | 4 days | Complete workflow with rating |
| DOH Integration | 3 days | Modified `/doh:prd-new`, historization |
| Tests & Polish | 3 days | Validation on real PRDs |
| **Total** | **13 days** | **Operational Committee** |

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Infinite debates | High | Timeouts + automatic CTO escalation |
| Too similar agents | Medium | Strong personalities, calibrated tensions |
| Performance overhead | Medium | Optimizations, parallel sessions |
| User resistance | Low | Opt-out available, demonstrated benefits |
| Inconsistent quality | Medium | CTO validation, strict templates |

## Approval Checklist

- [ ] **Product vision**: Multi-agent committee validated
- [ ] **Architecture**: 4 agents + CTO + 2-round process
- [ ] **Integration**: Compatible with existing DOH workflow
- [ ] **Performance**: < 15 min acceptable vs quality
- [ ] **Adoption**: Default with solo opt-out

---

✅ **PRD ready for validation and implementation**

*Next: `/doh:prd-parse prd-committee` to create technical epic*