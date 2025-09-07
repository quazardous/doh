# PRD Committee Workflow

## Context Quality Guidelines

**Professional Team Assumption**: Committee analyzes assuming experienced development team by default.

**Resource Constraint Handling**:
- Intern/junior developer mentions → Capture as "some [technology] knowledge available"
- Never let resource limitations drive architectural decisions
- Technical choices prioritize scalability, maintainability, best practices
- Resource constraints become implementation considerations, not design constraints

**If client explicitly wants resource accommodation**: They can intervene during checkpoints.

## Generic Workflow Algorithm

This workflow is designed to work with any number of rounds without modification.

### Core Algorithm
```python
def execute_committee_workflow(seed, manifest):
    """
    Execute N-round committee workflow based on manifest configuration.
    Fully reusable for any committee type.
    """
    # Initialize from manifest
    config = load_manifest(manifest)
    session = initialize_session(seed)
    
    # Round iteration
    round_num = 0
    converged = False
    
    while round_num < config.rounds.max and not converged:
        round_num += 1
        
        # Get round orientation and adjust agent priorities
        round_orientation = config.get_round_orientation(round_num)
        
        # Execute round phases with orientation-specific agent ordering
        for phase in config.rounds.phases_per_round:
            agents = get_agents_for_phase_with_orientation(
                phase=phase, 
                orientation=round_orientation,
                config=config
            )
            execute_phase(
                phase=phase,
                round=round_num,
                agents=agents,
                context=build_context_with_orientation(session, phase, round_num, round_orientation)
            )
        
        # Store round results
        session.save_round(round_num)
        
        # USER CHECKPOINT - Present brief and ask for corrections
        if config.user_checkpoints.enabled:
            user_intervention = present_round_brief_and_ask_corrections(
                session=session,
                round_num=round_num
            )
            
            # Apply user intervention if provided
            if user_intervention:
                apply_user_intervention(session, round_num, user_intervention)
        
        # Check convergence (if past minimum rounds)
        if round_num >= config.rounds.min:
            converged = check_convergence(session, round_num, config)
    
    # Final synthesis
    return create_final_deliverable(session, config)
```

## Phase Execution Patterns

### Draft Phase
Any agent creating or revising content:

```yaml
context_building:
  if round == 1:
    include:
      - shared_context (from seed)
      - requirements
      - constraints
  else:
    include:
      - shared_context (from seed)
      - previous_draft (round N-1)
      - feedback_received (round N-1)
      - cto_guidance (round N-1)

execution:
  constraint: sequential_only     # Memory-optimized sequential execution
  mode: sequential                # Always sequential
  timeout: 8 minutes
  
output:
  path: round${N}/${agent_name}.md
  format: markdown
```

### Feedback Phase
Any agent reviewing other agents' work:

```yaml
context_building:
  include:
    - all_current_drafts (round N)
    - rating_criteria
    - review_guidelines

execution:
  constraint: sequential_only     # Must be sequential (agents need to read each other's drafts)
  mode: sequential               # Overrides seed execution_mode
  timeout: 4 minutes
  
output:
  path: round${N}/${agent_name}_feedback.md
  format: structured_feedback
```

### Analysis Phase
Arbitrator analyzing convergence:

```yaml
context_building:
  include:
    - all_drafts (round N)
    - all_feedback (round N)
    - previous_analyses (rounds 1 to N-1)
    - convergence_criteria

execution:
  constraint: single_agent        # Only arbitrator agent runs
  agent: ${manifest.agents.arbitrator}
  timeout: 2 minutes
  
output:
  path: round${N}/cto_analysis.md
  decisions:
    - convergence_score
    - continue_or_stop
    - guidance_for_next
```

## Context Builder

```python
def build_context(session, phase, round_num):
    """
    Build context for any phase and round.
    Adapts automatically based on available data.
    """
    context = {
        'shared': session.seed.context,
        'round': round_num,
        'phase': phase.name
    }
    
    if phase.name == 'draft':
        if round_num > 1:
            # Add previous round data if it exists
            context['previous_draft'] = session.get_draft(round_num - 1)
            context['feedback'] = session.get_feedback(round_num - 1)
            context['guidance'] = session.get_analysis(round_num - 1)
    
    elif phase.name == 'feedback':
        # Add current round drafts for review
        context['review_targets'] = session.get_all_drafts(round_num)
        context['criteria'] = load_rating_criteria()
    
    elif phase.name == 'analysis':
        # Add all round data for convergence check
        context['current_round'] = session.get_round_data(round_num)
        context['history'] = session.get_all_rounds()
    
    return context
```

## User Checkpoint System

### Round Brief and Correction Request
```python
def present_round_brief_and_ask_corrections(session, round_num):
    """
    Present concise round summary and ask for corrections.
    No menu - just open-ended correction opportunity.
    """
    # Generate brief summary
    brief = generate_round_brief(session, round_num)
    
    print(f"""
🏛️ Round {round_num} Brief
{'=' * 20}

**Key Decisions:**
{brief.key_decisions}

**Technical Direction:**
{brief.technical_direction}

**Business Approach:**
{brief.business_approach}

**UX Strategy:**
{brief.ux_strategy}

**Infrastructure Plan:**
{brief.infrastructure_plan}

**Consensus Level:** {brief.consensus_score}/10
    """)
    
    # Ask for corrections in natural language
    correction = input("""
💭 Want to correct something? Express yourself naturally:
- Speak as CTO for technical decisions
- Speak as client for business requirements  
- Give general feedback as stakeholder
- Or just press Enter to continue

(AI detects your intent and responds in your language)

> """)
    
    if correction.strip():
        return parse_user_intervention(correction)
    return None

def parse_user_intervention(correction_text):
    """
    Parse user correction to determine perspective and content.
    Uses AI natural language understanding to detect intent.
    """
    # Use AI to analyze the user's intent and perspective
    # This is more flexible than keyword matching and works in any language
    
    analysis_prompt = f"""
    Analyze this user feedback to determine their perspective:
    "{correction_text}"
    
    Determine if the user is speaking:
    - As a CTO/technical leader (technical decisions, architecture, etc.)
    - As a client/business stakeholder (business requirements, preferences, etc.) 
    - As a general stakeholder (general feedback, corrections, etc.)
    
    Return only: 'cto', 'client', or 'general'
    """
    
    # In actual implementation, this would call an AI service
    # For now, use simple heuristics as fallback
    text = correction_text.lower()
    
    if 'cto' in text or 'technical' in text or 'architecture' in text:
        perspective = 'cto'
        authority = 'technical_executive'
    elif 'client' in text or 'business' in text or 'prefer' in text:
        perspective = 'client'
        authority = 'business_stakeholder'
    else:
        perspective = 'general'
        authority = 'stakeholder'
    
    return {
        'perspective': perspective,
        'content': correction_text,
        'authority': authority
    }

def apply_user_intervention(session, round_num, intervention):
    """
    Apply user intervention to influence next round.
    """
    guidance = {
        'type': 'user_intervention',
        'round_source': round_num,
        'perspective': intervention['perspective'],
        'authority': intervention['authority'],
        'content': intervention['content'],
        'timestamp': datetime.now(),
        'for_next_round': round_num + 1
    }
    
    # Store guidance for next round
    session.add_guidance(guidance)
    
    # Show confirmation based on perspective
    if intervention['perspective'] == 'cto':
        print(f"🎯 CTO guidance stored for Round {round_num + 1}")
    elif intervention['perspective'] == 'client':
        print(f"💼 Client requirements updated for Round {round_num + 1}")
    else:
        print(f"📝 Corrections stored for Round {round_num + 1}")
```

#### Agent Ordering by Round Orientation
```python
def get_agents_for_phase_with_orientation(phase, orientation, config):
    """
    Order agents based on round orientation and leadership.
    """
    base_agents = config.get_agents_for_phase(phase)
    
    if phase.name == 'draft':
        if orientation.name == 'functional_exploration':
            # Round 1: PO leads, UX supports, others observe
            return order_agents_by_priority([
                ('product-owner', 'lead'),
                ('ux-designer', 'support'),
                ('lead-developer', 'observer'),
                ('devops-architect', 'observer')
            ])
        elif orientation.name == 'technical_architecture':
            # Round 2: Lead Dev leads, others support
            return order_agents_by_priority([
                ('lead-developer', 'lead'),
                ('ux-designer', 'support'),
                ('product-owner', 'support'),
                ('devops-architect', 'observer')
            ])
        elif orientation.name == 'infrastructure_operations':
            # Round 3: DevOps leads, Lead Dev supports
            return order_agents_by_priority([
                ('devops-architect', 'lead'),
                ('lead-developer', 'support'),
                ('product-owner', 'observer'),
                ('ux-designer', 'observer')
            ])
    
    # Default ordering for other phases
    return base_agents

def build_context_with_orientation(session, phase, round_num, orientation):
    """
    Enhanced context builder that includes round orientation guidance.
    """
    context = build_context(session, phase, round_num)
    
    # Add orientation-specific guidance
    context['round_orientation'] = {
        'name': orientation.name,
        'focus': orientation.focus,
        'objective': orientation.objective,
        'approach': orientation.approach
    }
    
    # Add role-specific instructions based on orientation
    if orientation.name == 'functional_exploration':
        context['exploration_guidelines'] = {
            'lead_responsibility': 'Drive comprehensive functional exploration without technical constraints',
            'support_responsibility': 'Focus on user experience implications of business scenarios',
            'observer_responsibility': 'Listen and take notes for later technical analysis'
        }
        
        # CRITICAL: Add mandatory exploration checklist
        context['mandatory_exploration_checklist'] = [
            'How do separated entities coordinate shared resources?',
            'What information visibility exists between entities?', 
            'How are real-time conflicts detected and resolved?',
            'What happens when Entity A needs Entity B information?',
            'How do users know resource status across entity boundaries?',
            'What are the permission and access patterns between entities?',
            'How do shared workflows actually work in practice?'
        ]
        
        # Business discovery requirements (research done in prd-evo preparation)
        context['business_analysis_focus'] = [
            'Analyze provided industry context and standards',
            'Consider organizational models relevant to the domain',
            'Apply regulatory requirements and compliance frameworks from research', 
            'Reference case studies and best practices from preparation phase',
            'Validate business model assumptions against provided industry context',
            'Address challenges and solutions identified during prd-evo discovery'
        ]
    elif orientation.name == 'technical_architecture':
        context['architecture_guidelines'] = {
            'lead_responsibility': 'Transform functional requirements into concrete software architecture',
            'support_responsibility': 'Ensure architecture serves user and business needs',
            'observer_responsibility': 'Prepare infrastructure requirements for next round'
        }
    elif orientation.name == 'infrastructure_operations':
        context['infrastructure_guidelines'] = {
            'lead_responsibility': 'Design infrastructure for proposed software architecture',
            'support_responsibility': 'Provide software architecture context and requirements',
            'observer_responsibility': 'Review infrastructure impact on user and business requirements'
        }
    
    return context
```

## Context Enhancement for Next Round
```python
def build_context(session, phase, round_num):
    """
    Enhanced context builder that includes user interventions.
    """
    context = {
        'shared': session.seed.context,
        'round': round_num,
        'phase': phase.name
    }
    
    # Include user interventions from previous round
    user_guidance = session.get_guidance_for_round(round_num)
    if user_guidance:
        context['user_guidance'] = user_guidance
        
        # Format guidance based on perspective for agents
        if user_guidance['perspective'] == 'cto':
            context['cto_directive'] = f"CTO Decision: {user_guidance['content']}"
        elif user_guidance['perspective'] == 'client': 
            context['client_requirements'] = f"Client Update: {user_guidance['content']}"
        else:
            context['stakeholder_feedback'] = f"Stakeholder Input: {user_guidance['content']}"
    
    # Rest of existing context building logic...
    if phase.name == 'draft':
        if round_num > 1:
            context['previous_draft'] = session.get_draft(round_num - 1)
            context['feedback'] = session.get_feedback(round_num - 1)
            context['guidance'] = session.get_analysis(round_num - 1)
    
    return context
```

## Convergence Checker

```python
def check_convergence(session, round_num, config):
    """
    Generic convergence checking logic.
    Works for any committee type.
    """
    analysis = session.get_analysis(round_num)
    
    # Extract metrics from CTO analysis
    consensus = analysis.get('consensus_score', 0)
    quality = analysis.get('quality_score', 0)
    conflicts = analysis.get('unresolved_conflicts', [])
    logical_conflicts = analysis.get('logical_contradictions', [])
    
    # Apply convergence rules
    if consensus >= config.convergence.consensus_threshold:
        if quality >= config.convergence.quality_threshold:
            if len(conflicts) == 0 and len(logical_conflicts) == 0:
                return True  # Full convergence
            elif len(logical_conflicts) > 0:
                return False  # Force another round for logical conflict resolution
    
    # Force convergence at max rounds
    if round_num >= config.rounds.max:
        return True  # Forced convergence
    
    return False  # Continue iterating
```

## Agent Invocation

```python
def invoke_agent(agent_config, context):
    """
    Generic agent invocation.
    Works with any agent type.
    """
    # Build prompt from orchestration
    orchestration = load_orchestration(agent_config.orchestration)
    prompt = build_prompt(orchestration, context)
    
    # Invoke via Task tool
    result = Task(
        subagent_type=agent_config.agent,
        prompt=prompt,
        description=f"{context['phase']} - Round {context['round']}"
    )
    
    return result
```

## Output Generation

### Round Outputs
```python
def save_round_output(session, round_num, phase, agent, content):
    """
    Save any agent output in consistent structure.
    """
    if phase == 'draft':
        filename = f"{agent}.md"
    elif phase == 'feedback':
        filename = f"{agent}_feedback.md"
    elif phase == 'analysis':
        filename = "cto_analysis.md"
    
    path = f"{session.dir}/round{round_num}/{filename}"
    write_file(path, content)
```

### Final Deliverable
```python
def create_final_deliverable(session, config):
    """
    Generate final PRD from committee results using template synthesis.
    """
    # Load PRD template from orchestration templates
    prd_template = read_file(".claude/orchestration/prd-committee/templates/prd.md")
    
    # Build comprehensive context for CTO synthesis
    synthesis_context = {
        'prd_template': prd_template,
        'committee_results': session.get_all_rounds(),
        'agent_drafts': session.get_final_drafts(),
        'convergence_analysis': session.get_final_analysis(),
        'seed_context': session.seed.context,
        'deliverable_requirements': config.deliverable.required_sections
    }
    
    # Use CTO agent to synthesize final PRD by filling template variables
    final_prd = Task(
        subagent_type=config.agents.arbitrator.agent,
        prompt=f"""
        Create final PRD by synthesizing committee results into the provided template.
        
        TEMPLATE TO FILL: {synthesis_context['prd_template']}
        
        Replace all template variables like {{{{VARIABLE_NAME}}}} with concrete content from:
        - Committee agent drafts: {synthesis_context['agent_drafts']}
        - Convergence analysis: {synthesis_context['convergence_analysis']}
        - Original seed context: {synthesis_context['seed_context']}
        
        Fill each template variable with specific decisions and content from the committee process:
        - {{{{FEATURE_TITLE}}}}: Proper title from feature name
        - {{{{EXECUTIVE_SUMMARY}}}}: Business overview synthesized from Product Owner
        - {{{{TECHNICAL_ARCHITECTURE}}}}: Architecture decisions from Lead Developer
        - {{{{INFRASTRUCTURE_SECURITY}}}}: Security strategy from DevOps Architect
        - {{{{USER_EXPERIENCE}}}}: UX strategy from UX Designer
        - All other variables with appropriate content from committee results
        
        Output the complete PRD with all variables filled and no template placeholders remaining.
        """
    )
    
    # Save to standard DOH PRD location
    save_path = f".doh/prds/{session.feature}.md"
    write_file(save_path, final_prd)
    return final_prd
```

## Error Handling

### Graceful Degradation
```python
def handle_agent_failure(agent, phase, round_num):
    """
    Handle failures without breaking workflow.
    """
    if phase == 'draft':
        if round_num == 1:
            # Critical - retry once
            return retry_agent(agent, extended_timeout=True)
        else:
            # Use previous round draft
            return get_previous_draft(agent, round_num - 1)
    
    elif phase == 'feedback':
        # Non-critical - continue without
        return None
    
    elif phase == 'analysis':
        # Critical - must have analysis
        return force_basic_analysis(round_num)
```

## Directory Management

The workflow creates this structure dynamically:

```
.doh/committees/{feature}/
├── seed.md                  # Created by helper (unchanged)
├── round1/                  # Created on first round
├── round2/                  # Created on second round
├── roundN/                  # Created as needed
└── final_analysis.md        # Created at end
```

No hardcoded round numbers - directories created as needed.

## Compatibility Notes

### Helper Scripts
No changes required to helper scripts. They continue to work with:
- `committee_create_seed()` - Creates seed.md
- `committee_read_seed()` - Reads seed.md
- `committee_create_final_prd()` - Creates PRD template

### Seed Format
Seed files only need to reference the new manifest:
```yaml
orchestration:
  type: prd-committee
  manifest: .claude/orchestration/prd-committee/manifest.md
```

### Agent Interface
Agents receive generic context and adapt based on what's present.
No agent-specific changes needed for N-round support.