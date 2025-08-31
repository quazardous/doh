---
name: quick-epic
description: Quick task management system with intelligent PRD/epic matching and fallback container
status: backlog
created: 2025-08-31T10:55:22Z
updated: 2025-08-31T12:35:44Z
---

# PRD: quick-epic

## Executive Summary

The quick-epic system provides a streamlined workflow for handling quick tasks and hotfixes that need immediate attention. It features an intelligent matching system that attempts to place quick tasks within existing PRD/epic structures, falling back to a dedicated "quick-epic" container when no suitable match exists. This ensures quick tasks maintain traceability while avoiding the overhead of full PRD/epic creation.

## Problem Statement

Currently, when developers encounter urgent bugs, small improvements, or quick fixes, they face a dilemma:
- Creating a full PRD/epic is overkill for a 30-minute fix
- Working without proper task tracking breaks the "no vibe coding" principle
- Forcing quick fixes into unrelated epics creates confusion
- Lack of structure for quick tasks leads to lost context and poor traceability

This friction often leads to either:
1. Developers avoiding the DOH system for quick fixes (breaking process)
2. Spending more time on process than the actual fix
3. Polluting existing epics with unrelated quick tasks

## User Stories

### Developer Fixing a Bug
**As a** developer encountering a production bug
**I want to** quickly create a tracked task without extensive planning
**So that** I can fix the issue immediately while maintaining traceability

**Acceptance Criteria:**
- Can create a task in under 30 seconds
- System suggests relevant epic if one exists
- Falls back to QUICK epic if no match
- Maintains full audit trail

### Team Lead Reviewing Quick Fixes
**As a** team lead
**I want to** see all quick tasks in one place
**So that** I can review what ad-hoc work has been done

**Acceptance Criteria:**
- Quick tasks are visible in status reports
- Can identify which were attached to epics vs QUICK epic
- Can track time spent on unplanned work

### Developer Doing Small Improvements
**As a** developer seeing a small improvement opportunity
**I want to** capture and execute it quickly
**So that** technical debt doesn't accumulate

**Acceptance Criteria:**
- No requirement for extensive documentation
- Can complete entire workflow in minutes
- Task is properly linked if related to existing work

## Requirements

### Functional Requirements

#### Core Command: `/doh:quick`
- Accept task description as argument
- Perform intelligent PRD matching with percentage scores
- Present matches in order of relevance
- Allow user to select specific PRD by name or number
- Provide skip-all option for immediate QUICK epic creation
- Support `--direct` flag to bypass matching and go straight to QUICK system

#### Matching Algorithm
1. **PRD Layer**: Scan all PRD descriptions for keyword matches
2. **Epic Layer**: If PRD selected, analyze its epics for relevance
3. **Task Layer**: Within epic, identify specific tasks that relate
4. **Synthesis**: Present single recommendation with rationale

#### User Interaction Flow
- Show top matches with percentages
- User can: select match, skip to next, type PRD name, or skip all
- System performs deep analysis only when requested
- Present synthesized recommendation, not raw data
- Always confirm before creating/attaching task

#### QUICK System Management
- Auto-create QUICK directory during `/doh:init` (reserved location: `.doh/quick/`)
- Permanent container for unmatched quick tasks
- Never-completing system (hardcoded behavior)
- No automatic archival (manual review encouraged)
- Simplified structure separate from regular epics

#### Task Creation
- Minimal required fields: title and description
- Skip decomposition phase for quick tasks
- Auto-set priority as "high" (can be overridden)
- No dependency requirements
- Optional time estimate (default: 2 hours)

#### Epic State Handling

**When matching to open/active epics:**
- Add new task with next sequential number
- Analyze existing task dependencies to determine insertion point
- Update dependency chains as needed (tasks that should depend on new task)
- May require updating multiple existing tasks' `depends_on` fields
- Prompt user to confirm dependency modifications before proceeding

**When matching to completed epics:**
- Auto-create `maintenance.md` as full epic structure for technical maintenance
- Continue normal task numbering sequence (004, 005, 006...)
- Never modify original `epic.md` (strictly forbidden once completed)
- Maintenance scope: bugs, performance, security, refactoring (NO new features)
- Maintenance epic remains open for ongoing technical work

### Non-Functional Requirements

#### Performance
- Matching algorithm completes in < 2 seconds
- Support up to 100 PRDs without degradation
- Analysis phase completes in < 5 seconds

#### Usability
- Single command execution
- Clear percentage indicators for matches
- Intuitive navigation between options
- Minimal typing required

#### Compatibility
- Works with existing DOH workflow
- Quick tasks appear in `/doh:next`
- Compatible with GitHub issue sync
- Maintains standard file formats

## Success Criteria

1. **Adoption**: 80% of hotfixes use `/doh:quick` within first month
2. **Speed**: Average time from command to task creation < 45 seconds
3. **Accuracy**: 70% of quick tasks successfully matched to relevant epics
4. **Traceability**: 100% of quick work tracked in system
5. **Satisfaction**: Developers report reduced friction for quick fixes

## Constraints & Assumptions

### Constraints
- Must maintain backward compatibility with existing DOH commands
- Cannot modify existing PRD/epic structures
- Must work within current file-based storage system
- GitHub API rate limits apply

### Assumptions
- Quick tasks are typically completed in one session
- Most quick tasks relate to existing work (60-70%)
- Developers will provide meaningful task descriptions
- QUICK system won't grow beyond manageable size (< 50 active tasks)

## Out of Scope

- Automatic task prioritization based on urgency
- Time tracking for quick tasks
- Automatic archival of old quick tasks
- Task size estimation or validation
- Integration with external ticketing systems
- Defining what constitutes a "quick" task (left to developer judgment)
- Special handling for different task types (bugs vs improvements)

## Dependencies

### Internal Dependencies
- DOH core system must be initialized
- `.doh/epics/` directory structure exists
- PRD files available for matching
- Git repository initialized

### External Dependencies
- GitHub CLI for issue creation (optional)
- Bash 4.0+ for matching algorithm
- Standard Unix tools (grep, sed, awk)

## Technical Implementation Notes

### Matching Algorithm Approach
- Use keyword extraction from task description
- Calculate similarity score using:
  - Keyword overlap (60% weight)
  - Domain proximity (30% weight)
  - Recency (10% weight)
- Configurable threshold (default: 30% minimum match)

### File Structure
```
.doh/
├── prds/
│   └── quick-epic.md          # Auto-created at init
├── quick/
│   ├── manifest.md            # QUICK system metadata
│   └── [task-id].md           # Quick task files
├── epics/
│   └── existing-epic/
│       ├── epic.md            # Original epic (NEVER modified after completion)
│       ├── 001.md             # Original tasks (one file per task)
│       ├── 002.md
│       ├── 003.md
│       ├── maintenance.md     # Auto-created maintenance epic
│       ├── 004.md             # Maintenance tasks (continue numbering)
│       ├── 005.md
│       └── 006.md
```

### Command Flags
- `/doh:quick "description"` - Standard flow with matching
- `/doh:quick --direct "description"` - Skip matching, add directly to QUICK system
- `/doh:quick --threshold 60 "description"` - Custom match threshold (future enhancement)

## Documentation Updates Required

### Rule Files to Update
1. **`.claude/rules/standard-patterns.md`**
   - Add quick task workflow pattern
   - Document when to use `/doh:quick` vs full PRD process

2. **`.claude/rules/frontmatter-operations.md`**
   - Add `maintenance.md` frontmatter structure with `parent_epic` field
   - Document `type: maintenance` field usage

3. **New rule file: `.claude/rules/quick-tasks.md`**
   - Epic immutability rule: Never modify `epic.md` after completion
   - Maintenance scope definition: Technical only, no features  
   - Task numbering continuation: Always continue sequence
   - Quick task workflow: When to match vs fallback to QUICK system

## Migration Path

1. **Phase 1**: Add `/doh:quick` command
2. **Phase 2**: Auto-create QUICK system in `/doh:init`
3. **Phase 3**: Update `/doh:next` to show quick tasks
4. **Phase 4**: Add quick task metrics to `/doh:status`
5. **Phase 5**: Update rule documentation as specified above

## Future Enhancements

- Machine learning for improved matching
- Quick task cleanup and organization strategies
- **GitHub labeling system**: Configurable labels for quick/maintenance tasks (via `.doh/env` or `.doh/config`)
- **Priority weighting**: How maintenance vs feature tasks appear in `/doh:next` (out of scope for now)  
- Quick task templates for common fixes
- Integration with monitoring/alerting systems
- Bulk quick task creation from error logs
- Automatic maintenance epic lifecycle management