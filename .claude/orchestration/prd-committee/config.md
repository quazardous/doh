# PRD Committee Configuration

```yaml
rounds:
  min: 2
  max: 3
  target: 3
  
# Round orientations and leadership
round_orientations:
  round_1:
    name: business_discovery
    lead_agent: product-owner
    support_agent: ux-designer
    focus: business_model_and_operational_reality
    objective: understand_the_actual_business_before_any_software_discussion
    approach: business_domain_analysis
    
  round_2:
    name: functional_design
    lead_agent: ux-designer
    support_agents: [product-owner, lead-developer]
    focus: user_workflows_and_software_functionality
    objective: translate_business_understanding_into_software_functional_requirements
    approach: user_centered_functional_design
    
  round_3:
    name: technical_architecture
    lead_agent: lead-developer
    support_agents: [devops-architect, ux-designer]
    focus: software_architecture_and_implementation_strategy
    objective: design_technical_solution_for_defined_functional_requirements
    approach: software_engineering_architecture

convergence:
  consensus_threshold: 7.5
  quality_threshold: 7.0
  early_exit: true

user_checkpoints:
  enabled: false                   # DISABLED temporarily to fix memory issues
  mandatory: false                 # Require user confirmation before continuing
  timeout_seconds: 60              # Reduced timeout
  brief_style: concise             # concise|detailed

timeouts:
  draft_minutes: 5                 # Reduced from 8 to avoid memory buildup
  feedback_minutes: 3              # Reduced from 4
  analysis_minutes: 2
  checkpoint_minutes: 2            # Reduced from 5
```