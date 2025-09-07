---
# Session Data
feature_name: {{FEATURE_NAME}}
description: {{DESCRIPTION}}
target_version: {{TARGET_VERSION}}
execution_mode: sequential
created: {{TIMESTAMP}}

# Orchestration Manifest Reference
orchestration:
  manifest: .claude/orchestration/prd-committee/manifest.md

# Minimal Context (Role-specific context added per agent)
core_context:
  feature_name: {{FEATURE_NAME}}
  description: {{DESCRIPTION}}
  target_version: {{TARGET_VERSION}}
  problem_statement: {{PROBLEM_STATEMENT}}
  
# Full context available but not embedded (agents discover as needed)
extended_context_reference:
  file: .doh/committees/{{FEATURE_NAME}}/context.md
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