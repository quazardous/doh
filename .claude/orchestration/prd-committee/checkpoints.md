# User Checkpoint Configuration

## Overview
Configuration for user intervention points during PRD committee workflow.

**Core Principle**: Committee analyzes for professional development teams by default. Resource limitations should not drive architectural decisions unless explicitly requested by client intervention.

## Checkpoint Settings

```yaml
user_checkpoints:
  enabled: true                    # Enable user checkpoints after each round
  
  # Brief format settings
  brief_format:
    show_consensus_score: true     # Display consensus level
    show_key_decisions: true       # Show main decisions made
    show_conflicts: true           # Highlight any conflicts
    show_next_focus: true          # Show what next round will focus on
    
  # Intervention parsing
  # AI-based intent recognition - no pattern matching needed
  intervention_processing:
    intent_detection: ai_natural_language
    supported_roles:
      - cto: technical_executive
      - client: business_stakeholder
      - general: stakeholder
      
  # Authority levels
  authority_mapping:
    cto: technical_executive       # Can override technical decisions
    client: business_stakeholder   # Can change business requirements
    general: stakeholder          # General feedback and suggestions
```

## Brief Template

The system presents this format after each round:

```
🏛️ Round {N} Brief
====================

**Key Decisions:**
{key_decisions_summary}

**Technical Direction:**
{technical_approach_summary}

**Business Approach:**
{business_requirements_summary}

**UX Strategy:**
{user_experience_approach}

**Infrastructure Plan:**
{devops_strategy_summary}

**Critical Questions Addressed:** {critical_questions_checklist}
**Industry Research Completed:** {domain_research_summary}
**Potential Blind Spots:** {identified_gaps_or_assumptions}

**Consensus Level:** {score}/10

💭 Want to correct something? Express yourself naturally:
- Speak as CTO for technical decisions
- Speak as client for business requirements  
- Give general feedback as stakeholder
- Or just press Enter to continue

(AI detects your intent and responds in your language)

> 
```

## Intervention Processing

### CTO Perspective
When user input contains CTO or technical keywords, their input is treated as:
- **Authority Level**: Technical Executive
- **Influence**: Can override agent technical decisions
- **Next Round Impact**: Agents receive CTO directive in context
- **Examples**: 
  - "as CTO, I think Laravel is too complex, let's use vanilla PHP"
  - "en tant que CTO, je pense que Laravel est trop complexe"
  - "from technical perspective, we should use simpler stack"

### Client Perspective  
When user input contains client or business keywords, their input is treated as:
- **Authority Level**: Business Stakeholder
- **Influence**: Can change business requirements and priorities
- **Next Round Impact**: Agents receive updated client requirements
- **Examples**: 
  - "as client, I prefer a simple system even if less performant"
  - "en tant que client, je prefere un systeme simple"
  - "business requirement: we need mobile-first approach"

### General Corrections
When user provides feedback without specific role keywords:
- **Authority Level**: Stakeholder
- **Influence**: General guidance and suggestions
- **Next Round Impact**: Agents receive stakeholder feedback
- **Examples**: 
  - "actually we also need to manage tournaments, not just members"
  - "finalement il faut aussi gerer les tournois"
  - "correction: the scope should include reporting features"

## Context Enhancement

User interventions are added to agent context for the next round:

```yaml
# Enhanced context structure with user guidance
context:
  shared: {seed_context}
  round: {current_round}
  phase: {current_phase}
  
  # User intervention data (if any)
  user_guidance:
    perspective: cto|client|general
    authority: technical_executive|business_stakeholder|stakeholder
    content: "{user_input_text}"
    round_source: {previous_round}
    
  # Formatted for agents based on perspective
  cto_directive: "CTO Decision: {content}"           # If perspective == cto
  client_requirements: "Client Update: {content}"    # If perspective == client
  stakeholder_feedback: "Stakeholder Input: {content}" # If perspective == general
```

## Implementation Notes

1. **No Menu System**: Simple open text input, no numbered choices
2. **Language Agnostic**: Users express corrections in their natural language
3. **Keyword Detection**: System parses perspective from role/context indicators
4. **Context Injection**: Corrections automatically influence next round
5. **Authority Respect**: Agents understand different authority levels
6. **Persistence**: All interventions saved in session for audit trail
7. **Response Language**: System responds in user's detected language
8. **Critical Questions Tracking**: Round 1 briefs show whether mandatory exploration questions were addressed
9. **Research Validation**: Show what industry research was completed and key findings
10. **Blind Spot Detection**: Highlight potential gaps in business discovery for user review

## Error Handling

- **Empty Input**: Continue without intervention
- **Unrecognized Pattern**: Treat as general stakeholder feedback
- **Conflicting Authority**: CTO > Client > General for technical decisions
- **Round Limit**: User interventions don't extend max round limit

## Compatibility

- **Existing Seeds**: Work unchanged, checkpoints controlled by config
- **Helper Scripts**: No changes required
- **Agent Interface**: Backward compatible, interventions optional in context