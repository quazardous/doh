---
name: workflow-conventions
description: Standardize task/epic workflow conventions with status values, lifecycle tracking, and external system mapping
status: backlog
created: 2025-09-02T06:15:08Z
updated: 2025-09-02T07:31:58Z
target_version: 0.6.0
file_version: 0.1.0
---

# PRD: workflow-conventions

## Executive Summary

Establish standardized workflow conventions across the DOH project to ensure consistent status management, lifecycle tracking, and seamless integration with external systems like GitHub and GitLab. This initiative will introduce unified status values, a new `started` timestamp field, priority tracking, and scriptable transition hooks to enable automation and external system synchronization.

## Problem Statement

The DOH project currently suffers from inconsistent workflow management across different entity types:

### Tasks and Epics (Implementation Units)
- **Status chaos**: Multiple overlapping status values (open/active, completed/closed, various pending states) with no clear standards
- **No lifecycle tracking**: Cannot determine when work actually began on tasks/epics
- **Missing automation points**: No hooks for status transitions to trigger workflows
- **External system disconnect**: No clear mapping to GitHub Issues or GitLab merge request states
- **Lack of prioritization**: No standard way to indicate task/epic priority

### PRDs (Strategic Intents)
- **Mixed conventions**: PRDs treated like tasks despite representing strategic documents
- **Unclear approval flow**: No clear distinction between draft, review, and approval stages
- **Implementation confusion**: No clear transition from approved PRD to active implementation
- **Document lifecycle**: No standard way to handle obsolete or superseded PRDs

These inconsistencies create confusion for developers, complicate AI agent operations, and prevent effective project tracking and automation.

## User Stories

### Primary User: DOH Developer
**As a** DOH developer  
**I want** consistent status values across all entities  
**So that** I can understand task state at a glance and write reliable scripts

**Acceptance Criteria:**
- Clear, documented status values for each entity type
- Validation prevents invalid status values
- Migration tools fix existing inconsistencies
- Status meanings are well-defined

### Primary User: AI Agent
**As an** AI agent processing DOH commands  
**I want** standardized fields and predictable transitions  
**So that** I can reliably update and query task states

**Acceptance Criteria:**
- Frontmatter operations validate status values
- Transition rules are programmatically enforceable
- Clear API for status and priority updates
- Consistent field formats (no mixed quoting)

### Primary User: Project Manager
**As a** project manager  
**I want** lifecycle tracking and priority indicators  
**So that** I can measure cycle time and manage task priorities

**Acceptance Criteria:**
- `started` field tracks when work begins
- Priority field allows task ranking
- Can calculate time in each status
- Reports show status distribution

### Primary User: DevOps Engineer
**As a** DevOps engineer  
**I want** transition hooks and external system mapping  
**So that** I can automate workflows and sync with GitHub/GitLab

**Acceptance Criteria:**
- Status transitions can trigger queue messages
- Clear mapping to GitHub Issue states
- GitLab MR status synchronization
- Webhooks for status changes

## Requirements

### Functional Requirements

#### Core Status Standardization
1. **Define canonical status values**:
   - Tasks: `pending`, `in_progress`, `blocked`, `completed`, `cancelled`
   - Epics: `backlog`/`draft`, `in-progress`/`active`, `on_hold`, `implemented`/`completed`, `maintenance`, `deprecated`
   - PRDs: `backlog`/`draft`, `in-progress`/`active`, `implemented`/`completed`/`done`, `deprecated`, `archived`

   **Note**: PRDs and Epics follow similar workflows but serve different purposes:
   - **PRDs** = Strategic intents with finite lifecycle (eventually archived when intent fulfilled)
   - **Epics** = Implementation units that continue beyond PRD lifecycle (support maintenance phase)

2. **Update task workflow rules**:
   - Modify `.claude/rules/task-workflow.md` to reflect new status conventions
   - Update status reopening procedures (e.g., `/doh:task-reopen` commands)
   - Document when to use each status value
   - Include examples of status transitions in workflows

3. **Create entity definition documentation**:
   - Create `.claude/rules/entity-definitions.md` OR update existing high-level doc
   - Define conceptual differences: PRD (strategic intent) vs Epic (implementation container) vs Task (work unit)
   - Explain lifecycle differences: PRDs → archived, Epics → maintenance, Tasks → completed
   - Document when to use each entity type
   - Include maintenance phase explanations for each entity
   - Cross-reference with status workflows

4. **Status transition rules**:
   - Valid transitions matrix (e.g., pending → in_progress → completed)
   - Prevent invalid transitions (e.g., completed → pending)
   - Allow reopening with explicit reason field

5. **Migration tooling**:
   - Script to identify non-standard status values
   - Automated migration with mapping rules:
     - **Tasks**: `open` → `in_progress`, `closed` → `completed`, `backlog` → `pending`
     - **Epics**: `backlog` → `planned`, `open` → `active`
     - **PRDs**: Already support multiple aliases (backlog/draft, in-progress/active, implemented/completed/done)
   - Backup before migration
   - Validation after migration
   - Update `.claude/rules/frontmatter-operations.md` with correct status values

#### Lifecycle Tracking
1. **Started field**:
   - Add `started` timestamp to frontmatter
   - Auto-populate when status changes to `in_progress`/`active`
   - Calculate duration metrics
   - Support manual override for historical data

2. **Status history** (optional enhancement):
   - Track status transitions with timestamps
   - Store in `.doh/history/` or embed in frontmatter
   - Query status duration and transition patterns

#### Priority System
1. **Priority field**:
   - Values: `critical`, `high`, `medium`, `low`, `none`
   - Default: `medium`
   - Sortable in status reports
   - Integration with task selection algorithms

2. **Priority inheritance**:
   - Tasks inherit epic priority by default
   - Can override with explicit priority
   - Critical items bubble up in reports

#### Maintenance Epic Management
1. **Maintenance status handling**:
   - `maintenance` status indicates stable epics accepting only bug fixes and improvements
   - No new major features, but ongoing support continues
   - Can transition back to `active` for feature development

2. **Maintenance brainstorming tasks**:
   - Regular tasks to identify improvement opportunities in maintenance epics
   - Examples: "Review [epic-name] for performance optimizations", "Identify technical debt in [epic-name]"
   - These tasks help maintain code quality without major feature additions
   - Should be tagged/categorized as maintenance work

#### Transition Hooks
1. **Hook system**:
   - Define hooks in `.doh/hooks/transitions/`
   - Trigger on specific transitions (e.g., `pending_to_in_progress.sh`)
   - Pass context (task file, old status, new status, user)
   - Support async execution via queue

2. **Queue integration**:
   - Transition events posted to `.doh/queues/transitions/`
   - Include transition metadata
   - Worker processes can consume messages
   - Enable workflow automation

#### External System Mapping
1. **GitHub mapping**:
   ```
   DOH Status    → GitHub Issue State
   pending       → open
   in_progress   → open + "in progress" label
   blocked       → open + "blocked" label
   completed     → closed as completed
   cancelled     → closed as not planned
   ```

2. **GitLab mapping**:
   ```
   DOH Status    → GitLab MR State
   pending       → draft
   in_progress   → open
   blocked       → open + "blocked" label
   completed     → merged
   cancelled     → closed
   ```

3. **Sync utilities**:
   - Export DOH status to GitHub/GitLab
   - Import status from external systems
   - Bidirectional sync with conflict resolution
   - Webhook handlers for real-time updates

### Non-Functional Requirements

#### Performance
- Status validation < 10ms
- Migration handles 1000+ files
- Queue operations non-blocking
- Transition hooks timeout after 30s

#### Security
- Validate all status inputs
- Sanitize hook parameters
- Queue messages signed/verified
- No arbitrary code execution

#### Scalability
- Support projects with 10,000+ tasks
- Queue handles 100+ transitions/second
- Parallel migration processing
- Efficient status queries

#### Compatibility
- Backward compatible read operations
- Grace period for deprecated statuses
- Progressive enhancement approach
- Version detection for migration

## Success Criteria

1. **Adoption metrics**:
   - 100% of new tasks use standard statuses
   - 95%+ existing tasks migrated successfully
   - Zero invalid status values after migration

2. **Quality metrics**:
   - 50% reduction in status-related bugs
   - AI agents handle status updates without errors
   - Clear documentation reduces support questions

3. **Performance metrics**:
   - Average transition hook execution < 100ms
   - Migration completes < 60s for 1000 files
   - No performance regression in status queries

4. **Integration metrics**:
   - GitHub sync accuracy > 99%
   - GitLab mapping covers all states
   - Webhook delivery success > 95%

## Constraints & Assumptions

### Constraints
- Must maintain compatibility with existing DOH commands
- Cannot break current AI agent workflows
- Must work with bash 4.0+ (no bleeding edge features)
- File-based storage (no external databases)

### Assumptions
- Users will accept one-time migration disruption
- Standard statuses cover 90%+ of use cases
- GitHub/GitLab APIs remain stable
- Queue/worker pattern acceptable for hooks

## Out of Scope

- Custom workflow engines (keep it simple)
- Graphical workflow designers
- Complex approval chains
- Time tracking beyond started timestamp
- Integration with other project management tools (Jira, Asana, etc.)
- Automatic status inference from git activity
- Role-based status transitions
- Multi-status states (parallel workflows)

## Dependencies

### Internal Dependencies
- Frontmatter library (needs status validation functions)
- Graph cache system (store transition history)
- Epic-task-numerotation epic (coordinate on core conventions)
- Test framework (comprehensive migration testing)
- Task workflow rules (`.claude/rules/task-workflow.md` - needs status updates)
- Documentation system (create new entity definition guide)

### External Dependencies
- GitHub API for issue state sync
- GitLab API for MR status mapping
- `jq` for JSON processing in hooks
- `flock` for queue file locking

## Implementation Phases

### Phase 1: Core Standardization
1. Define status enums and transitions
2. Update frontmatter library with validation
3. Create migration scripts
4. Document conventions
5. Update `.claude/rules/task-workflow.md` with new status conventions
6. **Create entity definition documentation** - Add conceptual guide explaining PRD vs Epic vs Task differences

### Phase 2: Lifecycle Enhancement
1. Add started field to frontmatter
2. Implement auto-population logic
3. Create duration calculation utilities
4. Update status commands

### Phase 3: Priority System
1. Add priority field definitions
2. Implement inheritance rules
3. Update reporting commands
4. Create priority-based queries

### Phase 4: Automation Foundation
1. Design hook system architecture
2. Implement transition detection
3. Create queue/worker pattern
4. Build example hooks

### Phase 5: External Integration
1. Define GitHub/GitLab mappings
2. Create sync utilities
3. Implement webhook handlers
4. Build conflict resolution

## Risk Mitigation

1. **Migration failures**: Comprehensive backup and rollback procedures
2. **Status confusion**: Clear documentation and training materials
3. **Hook performance**: Timeout and async execution options
4. **External API changes**: Versioned adapters and graceful degradation
5. **User resistance**: Phased rollout with feedback loops

## Appendix: Status Transition Matrix

### Task Transitions
```
pending → in_progress → completed
pending → cancelled
in_progress → blocked → in_progress
in_progress → cancelled
blocked → cancelled
completed → in_progress (reopen with reason)
```

### Epic Transitions
```
backlog/draft → in-progress/active → implemented/completed → maintenance
backlog/draft → deprecated
in-progress/active → on_hold → in-progress/active
in-progress/active → deprecated
implemented/completed → in-progress/active (reopen for new features)
maintenance → in-progress/active (reactivate for new features)
maintenance → deprecated (end of life)
on_hold → deprecated
```

### PRD Transitions
```
backlog/draft → in-progress/active → implemented/completed/done → archived
backlog/draft → deprecated (approach obsolete)  
in-progress/active → deprecated (superseded by new approach)
implemented/completed/done → deprecated (approach obsolete but implementation valid)
deprecated → archived (no longer referenced)
backlog/draft → archived (cancelled intent)
```

**Key Difference**: PRDs are **finite strategic intents** with multiple end states:
- **archived**: Intent fulfilled or cancelled
- **deprecated**: Strategic approach obsolete but technical implementation may remain valid

Epics are **ongoing implementation containers** that transition to maintenance for continued support.

**PRD Status Semantics (enhanced from existing prd-list.sh script)**:
- `backlog`/`draft`: Initial creation, content being developed
- `in-progress`/`active`: PRD being actively worked on, epic creation in progress
- `implemented`/`completed`/`done`: Epic created and implementation has begun
- `deprecated`: Strategic approach obsolete, but technical implementation may still be valid/deployable
- `archived`: PRD purpose fulfilled or permanently cancelled

**Epic Status Semantics** (aligned with PRD workflow):
- `backlog`/`draft`: Epic concept defined, waiting to start implementation
- `in-progress`/`active`: Epic actively being worked on with new tasks/features  
- `on_hold`: Epic temporarily paused but will resume
- `implemented`/`completed`: Epic initial goals achieved, PRD requirements fulfilled
- `maintenance`: Epic stable, ongoing support but no new major features
- `deprecated`: Epic obsolete, no longer maintained

**Epic Lifecycle vs PRD Lifecycle**:
- **PRD**: Intent fulfilled → `archived` (finite purpose completed)
- **Epic**: Goals achieved → `maintenance` (ongoing support continues)

**PRD Status Semantics (based on existing prd-list.sh script)**:
- `backlog`/`draft`: Initial creation, content being developed
- `in-progress`/`active`: PRD being actively worked on, epic creation in progress
- `implemented`/`completed`/`done`: Epic created and implementation has begun

**Current Implementation Notes**:
- The existing `prd-list.sh` script groups PRDs into three categories
- Multiple status values are accepted for flexibility: `backlog` OR `draft` for backlog group
- `in-progress` OR `active` for active PRDs
- `implemented` OR `completed` OR `done` for finished PRDs

**Future Enhancement**: Add `deprecated` and `archived` statuses for PRDs:

**Deprecated PRDs**: Strategic approach obsolete, but implementation still valid
- Example: PRD for "jQuery-based UI components" becomes deprecated when team adopts React
- But existing jQuery components may still be deployed and functional on legacy systems
- Epic transitions to `maintenance`, PRD becomes `deprecated`

**Archived PRDs**: Strategic intent completely fulfilled or permanently cancelled
- PRDs should transition to `archived` after epic reaches end-of-life or intent is fulfilled
- `archived` PRDs represent completed/cancelled strategic intents
- This distinguishes PRDs (finite intents) from epics (ongoing containers)

**Technical Debt Consideration**: `deprecated` PRDs can inform technical debt cleanup while acknowledging the implementation may still be operationally valid.