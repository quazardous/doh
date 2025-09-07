---
# Session Data
feature_name: {{FEATURE_NAME}}
description: {{DESCRIPTION}}
target_version: {{TARGET_VERSION}}
execution_mode: {{EXECUTION_MODE}}
created: {{TIMESTAMP}}

# Orchestration Manifest Reference
orchestration:
  manifest: .claude/orchestration/prd-committee/manifest.md

# Shared Context for All Agents
context:
  problem_statement: {{PROBLEM_STATEMENT}}
  business_context: {{BUSINESS_CONTEXT}}
  technical_context: {{TECHNICAL_CONTEXT}}
  current_stack: {{CURRENT_STACK}}
  requirements: {{REQUIREMENTS_SUMMARY}}
  constraints: {{CONSTRAINTS}}
  success_criteria: {{SUCCESS_CRITERIA}}
  
  # Additional Context Variables
  complexity: {{COMPLEXITY}}
  user_impact: {{USER_IMPACT}}
  breaking_changes: {{BREAKING_CHANGES}}
  dependencies: {{DEPENDENCIES}}
  user_scale: {{USER_SCALE}}
  site_count: {{SITE_COUNT}}
  current_version: {{CURRENT_VERSION}}
---

# Committee Session Seed: {{FEATURE_NAME}}

## Feature Overview
{{DESCRIPTION}}

## Problem Statement
{{PROBLEM_STATEMENT}}

## Key Requirements
{{REQUIREMENTS_SUMMARY}}

## Success Criteria
{{SUCCESS_CRITERIA}}

## Technical Context
{{TECHNICAL_CONTEXT}}

## Business Context
{{BUSINESS_CONTEXT}}

## Constraints
{{CONSTRAINTS}}

---

**Note**: This seed contains context data for committee agents. 
Workflow execution is controlled by the committee orchestration manifest.