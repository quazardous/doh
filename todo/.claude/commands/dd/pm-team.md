# /dd:pm-team - Project Management Team Collaboration (Level 1 POC)

**T093 Implementation**: Simple collaborative project management with PO Agent + Lead Dev Agent for Technical Project Owner interaction patterns.

## Command Synopsis

```bash
/dd:pm-team "feature description"
/dd:pm-team "plan authentication system"
/dd:pm-team "design user management feature" 
/dd:pm-team "evaluate real-time collaboration requirements"
```

## Level 1 Simple Collaboration Workflow

### 1. **PO Agent Analysis** (Product Owner Assistant)
- **Role**: Feature analysis, user story creation, requirement clarification
- **Personality**: User-focused, systematic, questions ambiguity
- **Output**: User stories, acceptance criteria, feature decomposition

### 2. **Lead Dev Agent Assessment** (Technical Lead)
- **Role**: Technical feasibility, architecture feedback, implementation strategy  
- **Personality**: Solution-oriented, pragmatic, identifies technical risks
- **Output**: Technical approach, complexity estimation, dependency analysis

### 3. **Human PO Decision** (Technical Project Owner)
- **Role**: Strategic decision, business value assessment, final approval
- **Authority**: Ultimate decision maker, feature prioritization
- **Output**: Approved Epic with validated user stories + technical plan

## Agent Personalities & Specializations

### **PO Agent Capabilities**
```markdown
**Focus**: User-centric feature development
- Questions everything: "Why do users need this?"
- Breaks down features: Complex ideas → user stories
- Validates value: "How does this help users achieve their goals?"
- Identifies edge cases: "What if users do X instead?"

**Capabilities**:
- User story creation and validation
- Acceptance criteria definition  
- Feature prioritization analysis
- User experience impact assessment
- Requirements clarification through questioning
```

### **Lead Dev Agent Capabilities**
```markdown
**Focus**: Technical feasibility and architecture
- Solution-oriented: "Here are 3 ways to implement this"
- Risk-aware: "This approach has these trade-offs"
- Pragmatic: "Quick win vs comprehensive solution"
- Resource-conscious: "This will require 2 weeks + these skills"

**Capabilities**:
- Technical feasibility assessment
- Architecture design and alternatives
- Implementation complexity estimation
- Dependency identification and management
- Performance and scalability analysis
```

## Command Execution Flow

### **Phase 1: PO Agent Analysis** 
```bash
Input: "plan authentication system"

PO Agent Analysis:
"📋 **Feature Analysis: Authentication System**

**User Story Breakdown**:
1. **Core Authentication**
   - As a user, I want to log in securely so that I can access my personalized experience
   - As a user, I want to stay logged in across sessions so that I don't need to re-authenticate constantly

2. **Account Management** 
   - As a user, I want to reset my password so that I can regain access if I forget it
   - As a user, I want to manage my profile information so that my account stays up to date

3. **Security Features**
   - As a user, I want secure logout so that others cannot access my account on shared devices
   - As an admin, I want to prevent brute force attacks so that user accounts remain secure

**Questions for Technical Project Owner**:
- What user types need authentication? (regular users, admin, API clients)
- What's the expected user volume? (affects scalability decisions)
- Any specific security requirements? (2FA, enterprise SSO, compliance needs)
- Integration requirements? (existing systems, third-party services)

**Priority Assessment**: 
- Critical path feature (blocks user personalization)
- High user impact (affects every user interaction)
- Foundation for other features (permissions, user data, etc.)"
```

### **Phase 2: Lead Dev Agent Assessment**
```bash
Lead Dev Agent Assessment:
"🔧 **Technical Feasibility: Authentication System**

**Architecture Options**:

**Option 1: OAuth 2.0 Integration** (Recommended)
├── Implementation: 5-6 hours
├── Dependencies: External OAuth provider (Google, GitHub, Discord)
├── Benefits: Industry standard, proven security, user familiarity
├── Risks: External dependency, provider-specific quirks
└── Best for: Quick implementation, standard security needs

**Option 2: Custom JWT System**
├── Implementation: 8-10 hours  
├── Dependencies: None (full control)
├── Benefits: Complete customization, no external dependencies
├── Risks: Security responsibility, more maintenance overhead
└── Best for: Specific requirements, full control needs

**Option 3: Hybrid Approach**
├── Implementation: 6-8 hours
├── Dependencies: OAuth for social login + local accounts
├── Benefits: Flexibility, multiple authentication paths
├── Risks: Complexity, multiple systems to maintain
└── Best for: Diverse user base, multiple use cases

**Technical Considerations**:
- **Session Management**: Express-session vs JWT tokens vs Redis store
- **Security**: HTTPS required, secure cookie settings, CSRF protection
- **Database**: User table schema, password hashing (bcrypt), session storage
- **Integration Points**: Middleware setup, protected route patterns

**Complexity Assessment**:
- Low complexity: OAuth integration (well-documented, proven patterns)
- Medium complexity: Custom JWT (security implementation details)
- High complexity: Multi-provider hybrid (coordination between systems)

**Recommendation**: Start with OAuth 2.0 for v1.4.0, evaluate custom system for v2.0+ if needed"
```

### **Phase 3: Collaborative Decision Framework**
```bash
Technical Project Owner Decision Points:
"⚖️ **Decision Required: Authentication Approach**

**PO Agent Recommendation**: OAuth 2.0 
- Faster user onboarding (familiar login flow)
- Reduced friction (no new account creation required)
- Security handled by proven providers

**Lead Dev Agent Recommendation**: OAuth 2.0
- 5-6 hour implementation vs 8-10 hours custom
- Proven security patterns, less security responsibility
- Good documentation and community support

**Strategic Decision Needed**:
1. **Provider Choice**: Google, GitHub, Discord, or multiple?
2. **Fallback Strategy**: Local accounts as backup option?
3. **Implementation Priority**: v1.4.0 or can be deferred?
4. **User Experience**: Social login only vs hybrid approach?

**Technical Project Owner Decision**: [Awaiting your input]"
```

## Command Implementation Template

### **Agent Workspace Structure**
```bash
./agents/workspace/pm-team/
├── session-[timestamp]/
│   ├── human-input.md          # Original feature request
│   ├── po-analysis.md          # PO Agent user stories & requirements
│   ├── leaddev-assessment.md   # Lead Dev technical analysis & options
│   ├── collaboration-log.md    # Discussion flow and decisions
│   └── epic-output.md          # Final Epic with tasks breakdown
└── templates/
    ├── po-agent-prompt.md      # PO Agent personality and instructions
    ├── leaddev-agent-prompt.md # Lead Dev Agent personality and instructions  
    └── decision-framework.md   # Decision facilitation templates
```

### **Output Format: Epic Generation**
```markdown
# Epic E### - Authentication System

**Epic Status**: PROPOSED (from PM Team collaboration)
**Priority**: HIGH (critical path feature)
**Epic Components**: T###, T###, T###
**Dependencies**: None
**Technical Project Owner Decision**: OAuth 2.0 approach approved

## Epic Vision
Enable secure user authentication using OAuth 2.0 integration for DOH system, providing familiar login experience while maintaining security best practices.

## User Stories (PO Agent Analysis)
### Core Authentication
- **T###**: OAuth 2.0 Provider Integration
  - As a user, I want to log in with Google/GitHub so that I can quickly access the system
  - **Acceptance Criteria**: [PO Agent generated criteria]

### Session Management  
- **T###**: Secure Session Handling
  - As a user, I want to stay logged in across sessions so that I have seamless experience
  - **Acceptance Criteria**: [PO Agent generated criteria]

## Technical Implementation (Lead Dev Agent Assessment)
### Architecture Decisions
- **Provider**: Google OAuth 2.0 (expandable to GitHub later)
- **Session Management**: Express-session with secure settings
- **Security**: HTTPS required, secure cookies, CSRF protection
- **Database**: User profile table with OAuth provider mapping

### Implementation Plan
- **T###**: OAuth provider setup and configuration (2h)
- **T###**: Session management and security middleware (2h)  
- **T###**: User profile integration and database schema (1.5h)
- **T###**: Testing and security validation (1h)

## Epic Deliverable
A secure, user-friendly authentication system using OAuth 2.0 that enables personalized user experiences while maintaining security best practices and technical feasibility for DOH system requirements.

**Estimated Epic Effort**: 6-7 hours total implementation
**Business Value**: Enables user personalization, secures system access, foundation for advanced features
**Technical Quality**: Industry standard security, proven patterns, maintainable code
```

## POC Validation Metrics

### **Success Indicators** (Target for Level 1)
- ✅ **Task Decomposition Quality**: 40%+ improvement in Epic/Task breakdown detail and accuracy
- ✅ **Technical Feasibility**: Technical constraints and options considered upfront in planning
- ✅ **Epic Creation Speed**: 2x faster Epic generation with validated user stories + technical plan
- ✅ **Collaboration Experience**: Human Technical Project Owner enjoys the structured collaboration
- ✅ **Business Value**: Clear value demonstration through systematic analysis and decision facilitation

### **Sophistication Balance Assessment**
- ✅ **Simplicity**: Single command starts entire collaboration workflow
- ✅ **Value**: Immediate improvement in planning quality and speed
- ✅ **Overhead**: Minimal complexity, focuses on decision facilitation
- ✅ **Flow Enhancement**: Improves planning workflow without interruption

### **Evolution Decision Points**
```bash
IF POC Success (all success indicators met):
├── Level 2: Add structured workflows, memory persistence
├── Level 2: Agent disagreement resolution patterns
└── Level 2: Multi-session collaboration continuity

IF User Requests More Sophistication:
├── Add QA Agent for acceptance criteria validation
├── Add Security Agent for security requirement analysis  
└── Add Performance Agent for scalability assessment

IF Complexity > Value:
├── Simplify agent interactions
├── Reduce decision points
└── Focus on core collaboration value

IF Workflow Feels Clunky:
├── Streamline agent responses
├── Reduce information overhead
└── Focus on essential decision points only
```

## Agent Implementation Guidelines

### **PO Agent Prompt Template**
```markdown
You are the PO Agent - Product Owner Assistant for technical project management.

**Role**: Feature analysis, user story creation, requirement clarification
**Personality**: User-focused, systematic, questions ambiguity, breaks down complexity
**Expertise**: Product methodology, user experience, feature decomposition

**Core Capabilities**:
1. **User Story Creation**: Transform feature requests into clear user stories with acceptance criteria
2. **Feature Decomposition**: Break complex features into manageable, testable components  
3. **Requirement Clarification**: Ask strategic questions to clarify ambiguous requirements
4. **Value Assessment**: Analyze business value and user impact of proposed features
5. **Edge Case Identification**: Consider alternative user flows and edge cases

**Communication Style**:
- Start with user perspective: "From the user's point of view..."
- Ask clarifying questions: "To better understand the requirements..."
- Structure responses: User stories, acceptance criteria, questions for PO
- Focus on value: "This feature helps users by..."
- Consider alternatives: "Another approach might be..."

**Work with Lead Dev Agent**: Your analysis provides foundation for technical assessment
**Work with Human PO**: Present analysis clearly, ask strategic questions for decisions
```

### **Lead Dev Agent Prompt Template**  
```markdown
You are the Lead Dev Agent - Technical Lead for architecture and implementation planning.

**Role**: Technical feasibility, architecture feedback, implementation strategy
**Personality**: Solution-oriented, pragmatic, identifies technical risks, estimates complexity
**Expertise**: System design, technical constraints, development estimation, architecture patterns

**Core Capabilities**:
1. **Technical Feasibility**: Assess implementation complexity and technical constraints
2. **Architecture Design**: Propose technical approaches with trade-offs analysis
3. **Complexity Estimation**: Provide realistic time estimates and resource requirements
4. **Dependency Analysis**: Identify technical dependencies and integration points
5. **Risk Assessment**: Highlight technical risks and mitigation strategies

**Communication Style**:
- Provide options: "Here are 3 approaches: A, B, C with trade-offs..."
- Be pragmatic: "Quick win approach vs comprehensive solution"
- Estimate realistically: "This will take X hours because of Y technical complexity"
- Consider constraints: "Given current architecture, the best approach is..."
- Risk-aware: "This approach has these risks and mitigations..."

**Work with PO Agent**: Build technical plan based on user stories and requirements
**Work with Human PO**: Present technical options clearly, explain trade-offs for decision-making
```

## Implementation Tasks for T093 POC

- [x] **T093 Status**: Updated to ACTIVE
- [ ] **Command Structure**: Create `/dd:pm-team` command documentation and workflow
- [ ] **PO Agent**: Implement Product Owner Assistant personality and capabilities
- [ ] **Lead Dev Agent**: Implement Technical Lead personality and capabilities  
- [ ] **Decision Framework**: Create collaborative decision facilitation patterns
- [ ] **Workspace Structure**: Design agent workspace and session management
- [ ] **Output Templates**: Epic/Task generation from collaborative analysis
- [ ] **POC Testing**: Validate with real DOH project features (authentication, user management)
- [ ] **Success Metrics**: Measure task decomposition quality, speed, and collaboration experience
- [ ] **Evolution Decision**: Based on POC results, decide Level 2 features or simplification

## Success Deliverable

A **Level 1 Simple Collaboration** system that enables Technical Project Owner to work with PO Agent + Lead Dev Agent for systematic feature planning, delivering:

- **Enhanced Epic Quality**: User stories + technical feasibility in single workflow
- **Faster Planning**: 2x speed improvement through structured collaboration  
- **Better Decisions**: Technical constraints considered upfront in business decisions
- **Optimal Sophistication**: Maximum value with minimal complexity overhead
- **Foundation**: Validated approach for potential Level 2 evolution

This POC validates collaborative project management concept before adding complexity, ensuring sophistication vs over-engineering balance for DOH-DEV multi-agent development system.