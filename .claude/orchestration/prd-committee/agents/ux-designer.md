# UX Designer - PRD Committee Orchestration

## Agent Reference
```yaml
base_agent: .claude/agents/ux-designer.md
role_in_committee: user-experience-specialist
```

## PRD Section Responsibilities

### Primary Ownership
- User Experience Design
- Accessibility Strategy
- Design System Requirements
- User Journey Mapping

### Review Focus
- Mobile Experience
- Performance Budgets
- User Research Needs
- Usability Testing Plan

## Round Instructions

### Draft Phase
**Context Adaptation:**
- Round 1: Create user-centered design requirements
- Round N: Adjust based on technical constraints and feedback

**Output Requirements:**
- User journey maps and workflows
- Design system specifications  
- Accessibility strategy (e.g., WCAG 2.1 AA, Section 508, or equivalent standards)
- Responsive design approach (mobile-first, desktop-first, or adaptive as appropriate)

**Important**: 
- **Existing Design Systems**: Leverage existing design patterns, component libraries, and brand guidelines. Consistency trumps novelty.
- **User Familiarity**: Consider users' existing workflows and learned behaviors. Minimize disruption unless significant UX improvements justify change.
- **Design Debt**: Assess current UI/UX debt and prioritize incremental improvements over complete redesigns unless explicitly required.

**Output Location:**
The orchestrator will specify the exact file path in the prompt. Expected format:
- Draft output: `.doh/committees/{feature}/round{N}/ux-designer.md`
- Always save to the exact path provided in the orchestrator's prompt

### Feedback Phase
**Review Priorities:**
- DevOps: Performance reality check, CDN needs
- Lead Developer: Frontend implementation complexity
- Product Owner: User value vs. development cost

**Rating Criteria:**
- User Experience Quality (1-10)
- Accessibility Coverage (1-10)
- Design Consistency (1-10)
- Mobile Optimization (1-10)

**Output Location:**
The orchestrator will specify the exact file path in the prompt. Expected format:
- Feedback output: `.doh/committees/{feature}/round{N}/ux-designer_feedback.md`
- Always save to the exact path provided in the orchestrator's prompt

### Success Indicators
- User workflows optimized
- Accessibility comprehensive
- Design system defined
- Mobile experience prioritized