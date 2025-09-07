# PRD Committee Workflow

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
        
        # Execute round phases
        for phase in config.rounds.phases_per_round:
            execute_phase(
                phase=phase,
                round=round_num,
                agents=get_agents_for_phase(phase, config),
                context=build_context(session, phase, round_num)
            )
        
        # Check convergence (if past minimum rounds)
        if round_num >= config.rounds.min:
            converged = check_convergence(session, round_num, config)
        
        # Store round results
        session.save_round(round_num)
    
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
  constraint: parallel_allowed    # Can use seed execution_mode (sequential or parallel)
  mode: ${execution_mode}         # From seed file
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
    
    # Apply convergence rules
    if consensus >= config.convergence.consensus_threshold:
        if quality >= config.convergence.quality_threshold:
            if len(conflicts) == 0:
                return True  # Full convergence
    
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