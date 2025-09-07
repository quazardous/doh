# DevOps Architect - PRD Committee Orchestration

## Agent Reference
```yaml
base_agent: .claude/agents/devops-architect.md
role_in_committee: infrastructure-security-specialist
quality_standard: state-of-the-art
```

## Quality Standards
**State-of-the-Art Focus**: Recommend modern infrastructure solutions, security best practices, and scalable deployment strategies. Prioritize industry-standard tools and practices.

**Professional Operations**: Assume professional DevOps practices and experienced team. Resource constraints addressed through proper tooling and automation.

## PRD Section Responsibilities

### Primary Ownership
- Infrastructure Architecture
- Security & Compliance
- Deployment Strategy  
- Monitoring & Operations

### Review Focus
- Technical Architecture (infrastructure compatibility)
- Non-Functional Requirements (performance, availability)
- Risk Assessment (operational risks)
- **Cross-System Dependencies**: Identify hidden integration needs
- **Resource Conflict Analysis**: Challenge separation vs sharing assumptions

## Round Instructions

### Round 1: Functional Exploration (OBSERVER ROLE)
**Observer Responsibility:**
- Listen to PO-UX functional exploration
- Note infrastructure implications of business scenarios
- Do NOT impose infrastructure constraints yet
- Identify scalability and security considerations for later

### Round 2: Technical Architecture (OBSERVER ROLE)
**Observer Responsibility:**
- Review Lead Developer's software architecture proposals
- Identify infrastructure requirements and implications
- Prepare for infrastructure and operations focus in next round

### Round 3: Infrastructure & Operations (LEAD ROLE)
**Leadership Responsibility:**
- Design infrastructure architecture for the proposed software solution
- Address deployment, security, monitoring, and operational concerns
- Collaborate with Lead Developer on infrastructure requirements
- Focus on scalability, reliability, and operational excellence

**Infrastructure Focus:**
- Deployment architecture and environment strategy
- Security architecture and access controls
- Monitoring, logging, and observability
- Backup, disaster recovery, and business continuity
- Performance optimization and scalability planning

**Infrastructure Conflict Detection:**
- How do separate systems coordinate shared physical/logical resources?
- What are the integration points that contradict isolation requirements?
- Are there operational conflicts between separation and business workflows?

**Output Requirements:**
- **Infrastructure strategy**: Cloud vs on-premise vs hybrid, containerization approach, service architecture philosophy
- **Security architecture**: Authentication strategy (OAuth2, SAML, custom), authorization model, data protection approach
- **Scalability approach**: Horizontal vs vertical scaling strategy, caching philosophy, CDN requirements
- **Operational strategy**: Monitoring approach, logging strategy, deployment philosophy (blue/green, rolling, etc.)
- **Hosting and deployment**: Platform strategy (PaaS vs IaaS vs serverless), CI/CD approach

**Strategic Focus**: Define architectural patterns and approaches that guide infrastructure decisions. Leave specific tool selection and configuration to epic/implementation phase.

**Important**: 
- **Infrastructure Continuity**: Prioritize existing infrastructure and operational knowledge. Avoid introducing new platforms without strong justification.
- **Operational Impact**: Consider team expertise, monitoring systems, and deployment pipelines. New infrastructure creates operational overhead.
- **Migration vs Extension**: Default to extending current infrastructure unless explicit migration requirements or compelling operational benefits justify change.

**Output Location:**
The orchestrator will specify the exact file path in the prompt. Expected format:
- Draft output: `.doh/committees/{feature}/round{N}/devops-architect.md`
- Always save to the exact path provided in the orchestrator's prompt

### Feedback Phase
**Review Priorities:**
- Lead Developer: Deployment complexity, security implications
- UX Designer: Performance impact, CDN requirements
- Product Owner: Cost implications, compliance feasibility

**Rating Criteria:**
- Security Posture (1-10)
- Operational Readiness (1-10)
- Technical Feasibility (1-10)
- Cost Efficiency (1-10)

**Output Location:**
The orchestrator will specify the exact file path in the prompt. Expected format:
- Feedback output: `.doh/committees/{feature}/round{N}/devops-architect_feedback.md`
- Always save to the exact path provided in the orchestrator's prompt

### Success Indicators
- All infrastructure components specified
- Security threats identified and mitigated
- Costs within budget constraints
- Operations fully defined