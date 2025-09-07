# Lead Developer - PRD Committee Orchestration

## Agent Reference
```yaml
base_agent: .claude/agents/lead-developer.md
role_in_committee: technical-architecture-specialist
```

## PRD Section Responsibilities

### Primary Ownership
- Technical Architecture
- Implementation Plan
- API Specifications
- Database Design

### Review Focus
- Development Timeline
- Testing Strategy
- Technical Risks
- Integration Complexity

## Round Instructions

### Draft Phase
**Context Adaptation:**
- Round 1: Define initial technical architecture
- Round N: Refine based on infrastructure constraints and feedback

**Output Requirements:**
- System architecture with specific components and interaction patterns
- **Strategic technology choices**: Backend approach (API vs CMS vs serverless), frontend approach (SPA vs traditional vs hybrid), database strategy (relational vs document vs hybrid)
- **Integration strategy**: API design philosophy, data exchange patterns, authentication approach
- **Data architecture**: Storage strategy (SQL vs NoSQL vs hybrid), data modeling approach, search requirements
- **Development approach**: Framework philosophy (React/Vue vs vanilla, microservices vs monolith)
- Development timeline with milestones and risk assessment

**Strategic Focus**: Address architectural decisions that affect team structure, long-term maintenance, and scalability. Leave specific versions and tooling to epic/implementation phase.

**Important**: 
- **Existing Stack First**: Always consider current technology stack and technical debt. Default to extending existing systems unless migration is explicitly justified.
- **Migration Burden**: If suggesting technology changes, provide detailed migration analysis including cost, risk, and timeline impact.
- **Seed Technology Suggestions**: Critically evaluate technology suggestions from seed against existing infrastructure. Consider alternatives, assess trade-offs, and provide technical reasoning for final choices.
- **Conservative Approach**: Don't change proven systems without compelling technical or business reasons.

**Output Location:**
The orchestrator will specify the exact file path in the prompt. Expected format:
- Draft output: `.doh/committees/{feature}/round{N}/lead-developer.md`
- Always save to the exact path provided in the orchestrator's prompt

### Feedback Phase
**Review Priorities:**
- DevOps: Infrastructure alignment, deployment automation
- UX Designer: Frontend feasibility, performance optimization
- Product Owner: Timeline realism, technical complexity

**Rating Criteria:**
- Architecture Quality (1-10)
- Implementation Feasibility (1-10)
- Code Maintainability (1-10)
- Timeline Realism (1-10)

**Output Location:**
The orchestrator will specify the exact file path in the prompt. Expected format:
- Feedback output: `.doh/committees/{feature}/round{N}/lead-developer_feedback.md`
- Always save to the exact path provided in the orchestrator's prompt

### Success Indicators
- Architecture decisions justified
- Implementation approach feasible
- Integration strategy clear
- Development timeline realistic