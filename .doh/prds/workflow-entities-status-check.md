---
name: workflow-entities-status-check
description: Comprehensive analysis and validation system for DOH entity status interactions and lifecycle gaps
status: backlog
created: 2025-09-02T07:41:16Z
target_version: 0.5.2
file_version: 0.1.0
---

# PRD: workflow-entities-status-check

## Executive Summary

This PRD addresses critical gaps in DOH's entity status management system by creating a comprehensive analysis framework that documents how commands interact with entity statuses across all DOH entities (versions, PRDs, epics, tasks). The system will identify workflow gaps, enforce proper status progression, and provide validation mechanisms to prevent inconsistent state transitions.

## Problem Statement

The DOH system currently lacks comprehensive oversight of status interactions between commands and entities, leading to:

1. **Version File Creation Gap**: When PRDs target specific versions (e.g., 0.5.1), the version file isn't automatically created
2. **Status Progression Inconsistencies**: Commands don't enforce valid status transitions across all entity types
3. **Incomplete Status Chains**: Missing intermediate states in entity lifecycle progressions
4. **Orphaned Entity References**: Entities referencing non-existent or invalid status values
5. **Workflow Fragmentation**: No centralized documentation of command-to-entity-status relationships
6. **Undocumented Status Values**: Status values used in practice but missing from conventions
7. **Missing Validation**: Frontmatter operations lack comprehensive status validation rules
8. **Entity Lifecycle Confusion**: Unclear interactions between PRD, Epic, and Task status progressions
9. **Command Coverage Gaps**: Commands that should manipulate status but lack implementation

Current state analysis reveals commands operate independently without system-wide status awareness, creating potential for workflow corruption and inconsistent project state.

## User Stories

### Primary Personas

**DOH System Administrator**
- Needs comprehensive visibility into all entity status interactions
- Requires validation mechanisms to prevent invalid status transitions
- Must identify and resolve workflow gaps systematically

**Development Team Member**
- Expects consistent status behavior across all DOH commands
- Needs clear understanding of entity lifecycle progression
- Requires automatic creation of dependent entities (version files)

### User Journeys

1. **Status Audit Journey**
   - User runs comprehensive status analysis command
   - System scans all entities and identifies inconsistencies
   - Generates actionable report with fix recommendations
   - User applies fixes through guided remediation

2. **Command Validation Journey**
   - User attempts status transition via DOH command
   - System validates transition against entity lifecycle rules
   - Invalid transitions are blocked with clear explanations
   - Valid transitions proceed with dependent entity creation

3. **Common Pattern Gap Detection Journey**
   - User creates PRD targeting new version
   - System detects missing version file dependency
   - System identifies common workflow pattern gaps (e.g., PRD not updating when epic created)
   - System maps which commands handle transitions vs. which are missing
   - System provides comprehensive "what works vs. what's missing" analysis
   - Automatically offers to resolve detected common pattern gaps
   - Proposes implementation approaches for missing transition handlers

## Requirements

### Functional Requirements

**FR1: Entity Status Analysis Engine**
- Scan all DOH entities (versions, PRDs, epics, tasks) for current status
- Map command-to-status interactions across entire codebase
- Generate comprehensive status interaction matrix
- Identify orphaned entities and broken references

**FR2: Status Validation Framework**
- Define valid status transitions for each entity type
- Implement validation rules in frontmatter operations
- Block invalid status changes with descriptive error messages
- Provide suggested valid transitions for blocked operations

**FR3: Automatic Dependency Resolution**
- Detect when entity creation requires dependent entities
- Automatically offer to create missing version files
- Link related entities through frontmatter references
- Maintain referential integrity across entity relationships

**FR4: Common Pattern Gap Detection System**
- Focus on standard project workflow patterns and common use cases
- Document all commands that manipulate entity status with transition mapping
- Detect missing version file creation when PRDs/epics target specific versions
- Identify missing automatic status transitions (e.g., PRD → active when epic created)
- Map what workflow transitions work vs. what's missing
- Detect commands missing status manipulation capabilities for common patterns
- Identify which commands handle which transitions and gaps in coverage
- Generate actionable proposals for handling missing status transitions
- Provide comprehensive workflow description showing OK vs. missing patterns

**FR5: Status Progression Enforcement**
- Implement status lifecycle rules for each entity type
- Prevent backwards status transitions unless explicitly allowed
- Log all status changes with timestamps and justifications
- Provide rollback mechanisms for invalid progressions

**FR6: Maintainer Experience Enhancement**
- Add helpful tips and suggestions at the end of DOH commands
- Provide context-aware next-step recommendations
- Include workflow guidance for complex operations
- Display relevant entity relationship information during operations

### Non-Functional Requirements

**Performance**
- Status analysis completes within 10 seconds for typical DOH project
- Validation checks add <100ms overhead to command execution
- Gap analysis runs incrementally to avoid full project scans

**Reliability**
- Status validation prevents 100% of invalid transitions
- Dependency resolution succeeds for all standard entity creation patterns
- System maintains referential integrity across all operations

**Usability**
- Clear error messages for blocked status transitions
- Automated fixes for 90% of detected workflow gaps
- Visual status progression diagrams for entity lifecycle understanding
- Contextual tips and next-step suggestions to improve maintainer productivity

## Success Criteria

### Measurable Outcomes

1. **Common Pattern Gap Coverage**: All standard project workflow gaps identified and resolved
2. **Status Transition Automation**: PRD status automatically updates to 'active' when epic is created
3. **Workflow Documentation Completeness**: Comprehensive mapping of what works vs. what's missing
4. **Command Transition Coverage**: Document which commands handle transitions and identify missing handlers
5. **Automated Gap Resolution**: 90% of common workflow gaps resolved automatically
6. **Standard Status Chain Validation**: All typical status progressions properly defined and validated
7. **Missing Transition Proposals**: Actionable recommendations for handling missing status transitions

### Key Metrics

- Number of common project pattern gaps identified and resolved
- Percentage of standard workflow transitions properly automated
- Count of commands with documented status manipulation capabilities
- Number of missing transition handlers identified with implementation proposals
- Percentage of typical project workflows fully supported
- Coverage of PRD→Epic→Task status coordination patterns
- Quality of workflow documentation (what works vs. what's missing analysis)

## Constraints & Assumptions

### Technical Limitations
- Must work with existing DOH architecture without breaking changes
- Validation overhead must be minimal for performance
- Rules must be maintainable as new entity types are added

### Timeline Constraints
- Analysis framework completed within current version cycle (0.5.1)
- Validation implementation can extend to future versions
- Documentation updates must precede enforcement implementation

### Resource Limitations
- Implementation uses existing DOH library infrastructure
- No external dependencies beyond current toolchain
- Must be maintainable by existing development team

## Out of Scope

**Explicitly NOT Building:**
- Complete workflow redesign (enhancement only)
- New entity types beyond current version/PRD/epic/task structure
- Historical status migration for existing inconsistent entities
- Advanced workflow automation beyond validation and gap detection
- Integration with external project management tools

## Dependencies

### External Dependencies
- Existing DOH library functions (frontmatter operations, version management)
- YAML processing capabilities for frontmatter validation
- Git integration for change tracking and rollback

### Internal Team Dependencies
- Coordination with ongoing workflow standardization efforts
- Integration with version management system improvements
- Alignment with command rules enforcement initiative

### Prerequisite Work
- Completion of workflow-conventions PRD implementation
- Establishment of standardized entity status values
- Documentation of current DOH library API patterns

## Technical Approach Preview

### Analysis Engine Architecture
- Recursive entity scanner using existing DOH file patterns
- Status interaction matrix generator with command mapping
- Gap detection algorithms based on dependency graph analysis

### Validation Framework Design
- Rule-based validation system integrated with frontmatter operations
- Configurable status transition rules per entity type
- Extensible validation plugin architecture for future enhancements

### Implementation Strategy
- Phase 1: Analysis and documentation (immediate deliverable)
- Phase 2: Validation framework integration
- Phase 3: Automated gap resolution and enforcement
- Phase 4: Maintainer experience enhancements (tips, suggestions, workflow guidance)

## Estimated Effort

### Overall Timeline
- Analysis documentation: 1-2 days
- Validation framework: 3-4 days
- Gap resolution automation: 2-3 days
- Maintainer experience features: 2-3 days
- Testing and integration: 2-3 days

### Resource Requirements
- Primary developer for implementation
- DOH system knowledge for validation rule design
- Testing across diverse DOH project configurations

### Critical Path Items
1. Complete entity status interaction analysis
2. Define comprehensive validation rule set
3. Implement dependency resolution algorithms
4. Integrate validation with existing command infrastructure