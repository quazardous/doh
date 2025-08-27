# DOH Workflow Examples

Real-world examples showing how to apply DOH workflows to different types of software projects.

## Web Application Development

### Scenario: E-commerce Platform

#### Initial Planning

```bash
/doh:prd "e-commerce platform v2.0"
/doh:prd-epics !1
```

**Generated epics**:

- Epic !2: "User authentication and profiles"
- Epic !3: "Product catalog and search"
- Epic !4: "Shopping cart and checkout"
- Epic !5: "Order management system"
- Epic !6: "Admin dashboard and analytics"

#### Feature Development: Shopping Cart

```bash
/doh:epic-features !4  # Shopping cart epic
```

**Generated features**:

- Feature !7: "Cart item management"
- Feature !8: "Price calculation engine"
- Feature !9: "Checkout flow and payment"
- Feature !10: "Cart persistence and recovery"

#### Task Implementation: Price Calculator

```bash
/doh:feature-tasks !8  # Price calculation feature
```

**Generated tasks**:

- Task !11: "Implement base price calculation"
- Task !12: "Add tax calculation logic"
- Task !13: "Apply discount and coupon codes"
- Task !14: "Handle shipping cost calculation"
- Task !15: "Create price calculation tests"

#### Autonomous Development

```bash
/doh:agent !12  # Tax calculation task
```

**Result**: Isolated worktree development with full traceability.

## Mobile App Development

### Scenario: Social Media App

#### Epic-Driven Approach

```bash
/doh:epic "user feed and timeline"
/doh:epic-features !20
```

**Generated features**:

- Feature !21: "Post creation and editing"
- Feature !22: "Feed algorithm and display"
- Feature !23: "Real-time updates and notifications"
- Feature !24: "Media handling and optimization"

#### Parallel Development

```bash
# Team A: UI Components
/doh:agent !21  # Post creation

# Team B: Backend Integration  
/doh:agent !22  # Feed algorithm

# Team C: Performance
/doh:agent !24  # Media optimization
```

**Benefits**: Parallel worktrees, independent development, shared epic context.

## API Development

### Scenario: REST API for Financial Services

#### Direct Epic → Task Pattern

```bash
/doh:epic "transaction processing API"
/doh:epic-tasks !30
```

**Generated tasks**:

- Task !31: "Design transaction data models"
- Task !32: "Implement transaction creation endpoint"
- Task !33: "Add transaction validation logic"
- Task !34: "Create transaction history endpoint"
- Task !35: "Implement transaction search and filtering"
- Task !36: "Add comprehensive API tests"

#### Security-First Development

```bash
/doh:epic "API security and authentication"
/doh:epic-tasks !40
```

**Security-focused tasks**:

- Task !41: "Implement JWT authentication"
- Task !42: "Add rate limiting middleware"
- Task !43: "Create audit logging system"
- Task !44: "Implement input validation"
- Task !45: "Add API key management"

## Data Pipeline Development

### Scenario: Analytics Data Pipeline

#### Component-Based Epic Structure

```bash
/doh:epic "real-time analytics pipeline"
/doh:epic-features !50
```

**Generated features**:

- Feature !51: "Data ingestion layer"
- Feature !52: "Stream processing engine"
- Feature !53: "Data transformation pipeline"
- Feature !54: "Analytics dashboard API"

#### Infrastructure as Code

```bash
/doh:feature-tasks !51  # Data ingestion
```

**Infrastructure tasks**:

- Task !55: "Set up Kafka message brokers"
- Task !56: "Configure data validation schemas"
- Task !57: "Implement error handling and retry logic"
- Task !58: "Create monitoring and alerting"

## Legacy System Modernization

### Scenario: Mainframe to Cloud Migration

#### PRD-Driven Strategic Approach

```bash
/doh:prd "legacy banking system modernization"
/doh:prd-epics !60
```

**Generated epics**:

- Epic !61: "Data migration and validation"
- Epic !62: "Core business logic porting"
- Epic !63: "Modern API development"
- Epic !64: "Integration testing and validation"
- Epic !65: "Deployment and rollout strategy"

#### Risk-Managed Feature Development

```bash
/doh:epic-features !62  # Core business logic
```

**Risk-focused features**:

- Feature !66: "Account management core logic"
- Feature !67: "Transaction processing engine"
- Feature !68: "Compliance and regulatory reporting"
- Feature !69: "Security and encryption layer"

## Open Source Project Development

### Scenario: Developer Tool Library

#### Community-Driven Development

```bash
/doh:epic "plugin architecture system"
/doh:epic-features !70
```

**Community features**:

- Feature !71: "Plugin discovery and installation"
- Feature !72: "Plugin development SDK"
- Feature !73: "Plugin security and sandboxing"
- Feature !74: "Community plugin marketplace"

#### Contributor Workflow

```bash
# Individual contributors
/doh:quick "fix documentation typo"
/doh:quick "add TypeScript definitions"

# Feature contributors
/doh:feature-tasks !72  # SDK development
/doh:agent !75  # "Create plugin template generator"
```

## DevOps and Infrastructure

### Scenario: CI/CD Pipeline Enhancement

#### Operations-Focused Epic

```bash
/doh:epic "containerized deployment pipeline"
/doh:epic-tasks !80
```

**Operational tasks**:

- Task !81: "Create Docker multi-stage builds"
- Task !82: "Set up Kubernetes deployment configs"
- Task !83: "Implement blue-green deployment"
- Task !84: "Add pipeline monitoring and alerts"
- Task !85: "Create rollback automation"

#### Infrastructure Automation

```bash
/doh:epic "infrastructure as code"
/doh:epic-features !90
```

**Infrastructure features**:

- Feature !91: "Cloud resource provisioning"
- Feature !92: "Configuration management"
- Feature !93: "Backup and disaster recovery"
- Feature !94: "Cost optimization and monitoring"

## Machine Learning Projects

### Scenario: Recommendation System

#### Research-Driven Development

```bash
/doh:prd "AI-powered recommendation engine"
/doh:prd-epics !100
```

**ML-focused epics**:

- Epic !101: "Data collection and preprocessing"
- Epic !102: "Model development and training"
- Epic !103: "Real-time inference system"
- Epic !104: "A/B testing and optimization"

#### Experimental Workflow

```bash
/doh:epic-features !102  # Model development
```

**Experimental features**:

- Feature !105: "Collaborative filtering model"
- Feature !106: "Content-based recommendation"
- Feature !107: "Deep learning hybrid model"
- Feature !108: "Model evaluation and metrics"

## Startup MVP Development

### Scenario: SaaS Product Launch

#### MVP-Focused Approach

```bash
/doh:prd "SaaS platform MVP"
/doh:prd-epics !110
```

**MVP epics**:

- Epic !111: "Core product functionality"
- Epic !112: "User onboarding and authentication"
- Epic !113: "Payment and subscription system"
- Epic !114: "Basic analytics and reporting"

#### Rapid Development Pattern

```bash
# Quick validation
/doh:quick "create landing page prototype"
/doh:quick "test payment integration"

# Core features
/doh:epic-tasks !111  # Direct epic → task for speed
```

## Multi-Team Enterprise Development

### Scenario: Enterprise Platform Integration

#### Cross-Team Coordination

```bash
/doh:prd "enterprise platform integration"
/doh:prd-epics !120
```

**Team-specific epics**:

- Epic !121: "Frontend team - user interface"
- Epic !122: "Backend team - API services"
- Epic !123: "DevOps team - infrastructure"
- Epic !124: "QA team - testing automation"

#### Epic Ownership Pattern

```bash
# Team A owns Epic !121
/doh:epic-features !121
/doh:agent !125  # Autonomous feature development

# Team B owns Epic !122  
/doh:epic-tasks !122    # Direct task breakdown
```

## Common Workflow Transitions

### 1. Quick Task → Epic Graduation

```bash
# Initial exploration
/doh:quick "research user notification options"
/doh:quick "prototype email notifications"
/doh:quick "test push notification service"

# System suggests graduation
/doh:epic "comprehensive notification system"
# Migrate related quick tasks
```

### 2. Epic Splitting

```bash
# Original epic becomes too large
/doh:epic "user management system"  # Epic !130

# Split into focused epics
/doh:epic "user authentication and security"     # Epic !131
/doh:epic "user profiles and preferences"        # Epic !132
/doh:epic "user activity and analytics"          # Epic !133
```

### 3. Feature Consolidation

```bash
# Related features across epics
# Feature !140: "Email notifications" (Epic !131)
# Feature !141: "Push notifications" (Epic !132)
# Feature !142: "SMS notifications" (Epic !133)

# Consolidate into notification epic
/doh:epic "unified notification system"          # Epic !134
# Migrate features to new epic
```

## Workflow Pattern Selection Examples

### By Project Size

#### Small Project (1-3 developers, 1-3 months)

```bash
/doh:epic "personal finance tracker"
/doh:epic-features !150
# 3-5 features, direct implementation
```

#### Medium Project (4-8 developers, 3-6 months)

```bash
/doh:prd "team collaboration platform"
/doh:prd-epics !160
# 4-6 epics, feature-driven development
```

#### Large Project (10+ developers, 6+ months)

```bash
/doh:prd "enterprise resource planning system"
/doh:prd-epics !170
# 8-12 epics, multiple teams, complex coordination
```

### By Development Style

#### Agile/Iterative

```bash
# Sprint-focused epics
/doh:epic "sprint 1 - core user features"
/doh:epic-tasks !180  # 2-week completion target
```

#### Waterfall/Planned

```bash
# Phase-based PRD structure
/doh:prd "system development lifecycle"
/doh:prd-epics !190
# Requirements → Design → Implementation → Testing
```

#### Continuous Delivery

```bash
# Feature flag driven
/doh:quick "add feature flag for new search"
/doh:epic "incremental search improvements"
/doh:agent !200  # Autonomous deployment-ready development
```

## Integration Examples

### GitHub Integration

```bash
/doh:epic "issue tracking integration"
/doh:epic-tasks !210
# Task !211 ↔ GitHub Issue #456
# Commit messages: "[DOH !211] implement GitHub API sync"
```

### Jira Integration  

```bash
/doh:prd "quarterly platform updates"
/doh:prd-epics !220
# Epic !221 ↔ Jira Epic PROJ-123
# Feature-level sync with Jira stories
```

### Slack Integration

```bash
/doh:agent !230  # Autonomous development
# Slack notifications: "Epic !230 implementation completed"
# Team updates: "Feature !235 ready for review"
```

For detailed workflow patterns, see [workflow-patterns.md](./workflow-patterns.md).  
For command reference, see [commands.md](./commands.md).
