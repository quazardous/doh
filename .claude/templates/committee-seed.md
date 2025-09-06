---
# Committee Session Configuration
feature_name: {{FEATURE_NAME}}
description: {{DESCRIPTION}}
target_version: {{TARGET_VERSION}}
execution_mode: {{EXECUTION_MODE}}
created: {{TIMESTAMP}}

# Orchestration Reference
orchestration_file: .claude/orchestration/prd-committee.md
orchestration_type: prd-committee
orchestration_version: 1.0

# Context Variables for Orchestration
context:
  complexity: {{COMPLEXITY}}
  user_impact: {{USER_IMPACT}}
  breaking_changes: {{BREAKING_CHANGES}}
  dependencies: {{DEPENDENCIES}}
  user_scale: {{USER_SCALE}}
  site_count: {{SITE_COUNT}}
  current_version: {{CURRENT_VERSION}}

# Discovery Context
discovery:
  problem_statement: {{PROBLEM_STATEMENT}}
  business_context: {{BUSINESS_CONTEXT}}
  technical_context: {{TECHNICAL_CONTEXT}}
  requirements_summary: {{REQUIREMENTS_SUMMARY}}
  success_criteria: {{SUCCESS_CRITERIA}}
  key_insights: {{KEY_INSIGHTS}}
---

# Committee Session Seed: {{FEATURE_NAME}}

## Session Configuration
- **Orchestration**: `.claude/orchestration/prd-committee.md`
- **Workflow**: 5-phase collaborative PRD creation
- **Agents**: devops-architect, lead-developer, ux-designer, product-owner
- **Execution Mode**: {{EXECUTION_MODE}}
- **Estimated Duration**: 20 minutes

## Feature Context
{{DESCRIPTION}}

## Discovery Summary
{{PROBLEM_STATEMENT}}

### Key Requirements
{{REQUIREMENTS_SUMMARY}}

### Success Criteria  
{{SUCCESS_CRITERIA}}

## Orchestration Notes
This seed references the complete orchestration workflow at `.claude/orchestration/prd-committee.md`. The orchestrator will read that file to understand:

1. **Phase Execution**: Detailed steps for each of the 5 phases
2. **Agent Instructions**: Specific commands and outputs for each agent
3. **File Management**: Required directory structure and file naming
4. **Quality Gates**: Success criteria and validation requirements
5. **Error Handling**: Failure recovery and retry strategies

The orchestrator operates in full automation mode following the orchestration plan exactly.