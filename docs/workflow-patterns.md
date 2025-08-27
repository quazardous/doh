# DOH Workflow Patterns

Complete guide to DOH workflow patterns for different project types and development scenarios.

## Overview

DOH supports multiple workflow patterns depending on project complexity, team size, and development approach. This guide
covers when and how to use each pattern effectively.

## Pattern Categories

### 1. Quick Development Pattern

**Use case**: Bug fixes, small features, exploratory work  
**Duration**: Hours to 1-2 days  
**Team size**: Individual developers

```bash
/doh:quick "fix header alignment issue"
/doh:quick "research new authentication library"
/doh:quick "add loading spinner to dashboard"
```

**Benefits**:

- Zero planning overhead
- Immediate task creation
- Perfect for maintenance work
- Automatic graduation suggestions when patterns emerge

**When to use**:

- Bug fixes and hotfixes
- Small UI improvements
- Research spikes
- Prototype development
- Learning new technologies

### 2. Epic-Driven Development

**Use case**: Medium features with clear scope  
**Duration**: 3-10 days  
**Team size**: 1-3 developers

```bash
/doh:epic "user authentication system"
/doh:epic-tasks !2  # Direct task breakdown
```

**Benefits**:

- Balanced planning and execution
- Skip feature layer when unnecessary
- Clear deliverable focus
- Good traceability

**When to use**:

- Single cohesive features
- API development
- Database migrations
- Performance optimizations
- Security implementations

### 3. Feature-First Development

**Use case**: User-facing features with multiple components  
**Duration**: 1-3 weeks  
**Team size**: 2-5 developers

```bash
/doh:epic "e-commerce checkout process"
/doh:epic-features !3
/doh:feature-tasks !5  # Break each feature into tasks
```

**Benefits**:

- User-centric organization
- Clear feature boundaries
- Good for UI/UX-driven development
- Parallel feature development

**When to use**:

- Complex user interfaces
- Multi-step user workflows
- Feature sets with distinct components
- Mobile app screens/flows

### 4. Product Requirements Driven (PRD)

**Use case**: Major product initiatives  
**Duration**: Weeks to months  
**Team size**: Multiple teams

```bash
/doh:prd "mobile app launch"
/doh:prd-epics !1
/doh:epic-features !4
/doh:feature-tasks !7
```

**Benefits**:

- Complete requirements traceability
- Business alignment
- Cross-team coordination
- Strategic planning integration

**When to use**:

- New product launches
- Major platform migrations
- Multi-team initiatives
- Quarterly/annual planning

## Workflow Pattern Selection

### Decision Matrix

| Project Scope      | Time Estimate | Team Size | Recommended Pattern |
| ------------------ | ------------- | --------- | ------------------- |
| Bug fix            | < 4 hours     | 1         | Quick Development   |
| Small feature      | 1-2 days      | 1         | Quick Development   |
| Medium feature     | 3-10 days     | 1-3       | Epic-Driven         |
| Complex feature    | 1-3 weeks     | 2-5       | Feature-First       |
| Product initiative | 1+ months     | 5+        | PRD-Driven          |

### Pattern Progression

Projects often evolve through patterns:

```text
Quick → Epic → Feature-First → PRD
  ↓      ↓         ↓           ↓
 Task   Tasks   Features    Epics
```

**Graduation triggers**:

- 6+ related quick tasks → Epic
- Epic with multiple user-facing components → Feature-First
- Multiple related epics → PRD

## Advanced Workflow Patterns

### 1. Parallel Epic Development

```bash
# Epic A: Frontend development
/doh:epic "user interface redesign"
/doh:agent !5  # Autonomous frontend work

# Epic B: Backend API
/doh:epic "API optimization"
/doh:agent !6  # Autonomous backend work
```

**Benefits**:

- Parallel development streams
- Reduced dependencies
- Faster delivery
- Team specialization

### 2. Cross-Epic Dependencies

```bash
/doh:task "integrate payment gateway with user profiles"
# Dependencies: Epic !2 (payments) + Epic !3 (users)
```

**Management strategies**:

- Document dependencies in task descriptions
- Use epic cross-references
- Coordinate epic completion timing
- Consider architecture refactoring

### 3. Epic Graduation Pattern

```bash
# Start with quick tasks
/doh:quick "improve user login"
/doh:quick "add password reset"
/doh:quick "enhance user profile"

# System suggests: "Consider creating 'User Management' epic"
/doh:epic "user management improvements"
# Migrate related tasks to new epic
```

### 4. Feature Decomposition Strategies

#### A. Component-Based Decomposition

```bash
/doh:epic "shopping cart system"
/doh:epic-features !8
```

Results in:

- Feature: "Cart item management"
- Feature: "Price calculation engine"
- Feature: "Checkout integration"

#### B. User Journey Decomposition

```bash
/doh:epic "user onboarding flow"
/doh:epic-features !9
```

Results in:

- Feature: "Registration and verification"
- Feature: "Profile setup wizard"
- Feature: "Initial app tour"

#### C. Technical Layer Decomposition

```bash
/doh:epic "data analytics platform"
/doh:epic-features !10
```

Results in:

- Feature: "Data collection layer"
- Feature: "Processing and analysis"
- Feature: "Visualization dashboard"

## Team Collaboration Patterns

### 1. Individual Developer Workflow

```bash
# Personal task management
/doh:quick "refactor utility functions"
/doh:epic "implement new search feature"
/doh:agent !12  # Autonomous implementation
```

### 2. Small Team Workflow (2-4 developers)

```bash
# Shared epic, distributed features
/doh:epic "messaging system"
/doh:epic-features !15

# Developer A takes Feature !16
# Developer B takes Feature !17
# Parallel development with shared epic context
```

### 3. Large Team Workflow (5+ developers)

```bash
# PRD-driven with epic ownership
/doh:prd "platform modernization"
/doh:prd-epics !20

# Team A owns Epic !21 (frontend)
# Team B owns Epic !22 (backend)
# Team C owns Epic !23 (infrastructure)
```

## Specialized Workflow Scenarios

### 1. Research and Development

```bash
/doh:epic "AI integration research"
/doh:epic-tasks !25
```

Tasks focus on:

- Technology evaluation
- Proof of concept development
- Performance benchmarking
- Integration feasibility

### 2. Legacy System Migration

```bash
/doh:prd "legacy system modernization"
/doh:prd-epics !30
```

Epic structure:

- Analysis and documentation
- Data migration strategy
- Incremental feature porting
- Testing and validation

### 3. Performance Optimization

```bash
/doh:epic "application performance optimization"
/doh:epic-features !35
```

Feature breakdown:

- Database query optimization
- Frontend bundle optimization
- Caching layer implementation
- Monitoring and alerting

### 4. Security Implementation

```bash
/doh:epic "security audit and improvements"
/doh:epic-tasks !40  # Security often requires task-level precision
```

Direct task approach for:

- Vulnerability assessments
- Specific security controls
- Compliance requirements
- Security testing

## Integration Patterns

### 1. Git Integration Workflow

```bash
# Create epic with worktree
/doh:epic "payment processing"
/doh:agent !45  # Creates isolated worktree

# Development happens in: worktrees/epic-payment-processing/
# Commits reference: [DOH !45] implement stripe integration
```

### 2. CI/CD Integration

```bash
# Epic completion triggers
/doh:epic-complete !50
# Automatically runs epic-specific test suites
# Deploys to staging environment
# Updates project documentation
```

### 3. Project Management Tool Integration

```bash
# DOH IDs sync with external tools
Epic !55 ↔ JIRA Epic PROJ-123
Feature !58 ↔ Linear Feature LIN-456
Task !62 ↔ GitHub Issue #789
```

## Workflow Anti-Patterns

### 1. Over-Planning Anti-Pattern

**Problem**: Creating PRDs for simple features **Solution**: Start with epic, graduate if needed

### 2. Under-Planning Anti-Pattern

**Problem**: Using quick tasks for complex features **Solution**: Recognize complexity early, create proper structure

### 3. Stale Epic Anti-Pattern

**Problem**: Epics that never get implemented **Solution**: Regular epic review and prioritization

### 4. Dependency Hell Anti-Pattern

**Problem**: Too many cross-epic dependencies **Solution**: Refactor epic boundaries, consider architecture changes

## Best Practices

### 1. Pattern Recognition

- Monitor quick task patterns
- Identify recurring themes
- Graduate to appropriate structure
- Don't force complex patterns on simple work

### 2. Context Preservation

- Use DOH memory system effectively
- Document architectural decisions
- Preserve epic-specific context
- Maintain traceability chains

### 3. Regular Reviews

- Weekly Epic #0 review
- Monthly epic completion analysis
- Quarterly workflow pattern assessment
- Annual process optimization

### 4. Tool Integration

- Leverage autonomous agents for implementation
- Use worktrees for parallel development
- Integrate with existing development tools
- Maintain consistency across tools

## Workflow Metrics

### 1. Efficiency Metrics

- Time from epic creation to completion
- Task completion rate
- Epic graduation success rate
- Quick task → epic conversion rate

### 2. Quality Metrics

- Traceability completeness
- Cross-epic dependency count
- Technical debt accumulation
- Documentation completeness

### 3. Team Metrics

- Epic ownership distribution
- Cross-team collaboration frequency
- Knowledge sharing effectiveness
- Parallel development success

## Conclusion

DOH workflow patterns provide flexibility while maintaining structure. The key is:

1. **Start simple** - use quick tasks for exploration
2. **Scale appropriately** - graduate to epics when patterns emerge
3. **Plan strategically** - use PRDs for major initiatives
4. **Adapt continuously** - workflows should evolve with project needs

For implementation details, see [commands.md](./commands.md).  
For technical architecture, see [architecture.md](./architecture.md).
