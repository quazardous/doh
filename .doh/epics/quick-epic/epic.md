---
name: quick-epic
status: backlog
created: 2025-08-31T12:36:25Z
progress: 0%
prd: .doh/prds/quick-epic.md
github: [Will be updated when synced to GitHub]
---

# Epic: quick-epic

## Overview

Implement a streamlined quick task system that intelligently matches urgent tasks to existing epics or falls back to the reserved QUICK system. The system provides iterative layered matching (PRD → Epic → Task) with maintenance epic support for completed features. Creates and manages the hardcoded QUICK directory (`.doh/quick/`) which serves as a never-completing container for unmatched quick tasks.

## Architecture Decisions

- **Matching Engine**: Keyword-based similarity scoring with configurable thresholds
- **Layered Exploration**: User-controlled iterative analysis from PRD to task level
- **State-Aware Handling**: Different workflows for open vs completed epics
- **File-Based Storage**: Leverage existing DOH file structure for consistency
- **Maintenance Separation**: Technical-only maintenance epics for completed features
- **Reserved QUICK System**: Hardcoded `.doh/quick/` directory that cannot be created by users  
- **Never-Completing Design**: QUICK system remains permanently open for continuous task addition

## Technical Approach

### Frontend Components
- Command-line interface via `/doh:quick` command
- Interactive user prompts for match selection
- Progress indicators during analysis phases

### Backend Services
- **Matching Service**: PRD description analysis and scoring
- **Dependency Analyzer**: Task dependency chain analysis for open epics
- **Epic State Manager**: Handle open vs completed epic workflows
- **File Operations**: Task creation and frontmatter updates

### Infrastructure
- Leverage existing `.claude/scripts/doh/lib/` libraries
- Extend frontmatter.sh for maintenance epic support
- Integrate with existing GitHub sync workflow

## Implementation Strategy

### Development Phases
1. **Core Matching**: Basic PRD scanning and percentage scoring
2. **Interactive Flow**: User selection and deep analysis workflow
3. **Epic Integration**: Open epic dependency insertion logic
4. **Maintenance Support**: Auto-create maintenance.md for completed epics
5. **QUICK System Protection**: Auto-creation during `/doh:init` with reserved directory validation

### Risk Mitigation
- Leverage existing file operations to minimize new failure points
- Preserve epic immutability rules (never modify completed epic.md)
- Use existing frontmatter library for consistency

### Testing Approach
- Test with various PRD content for matching accuracy
- Validate dependency chain updates don't break existing tasks
- Ensure maintenance epic creation doesn't corrupt original epics

## Task Breakdown Preview

- [ ] **Task 1**: Create matching algorithm with keyword extraction and scoring
- [ ] **Task 2**: Implement interactive selection workflow with user controls
- [ ] **Task 3**: Build dependency analysis for inserting tasks into open epics
- [ ] **Task 4**: Add maintenance epic auto-creation for completed epics
- [ ] **Task 5**: Integrate QUICK system auto-creation into `/doh:init` with reserved directory protection
- [ ] **Task 6**: Add `--direct` flag support for bypass workflow
- [ ] **Task 7**: Update existing commands to handle quick tasks properly

## Dependencies

### Internal Dependencies
- DOH core system and existing libraries
- Frontmatter parsing library
- Existing epic/task file structures
- Current GitHub sync workflow

### External Dependencies
- Bash 4.0+ for associative arrays and advanced string operations
- Standard Unix tools (grep, sed, awk) for text processing

## Success Criteria (Technical)

1. **Matching Accuracy**: 70% of suggestions accepted by users
2. **Performance**: < 2 seconds for PRD scanning, < 5 seconds for deep analysis
3. **Integration**: Quick tasks appear correctly in `/doh:next` and status reports
4. **Safety**: No corruption of existing epic files or dependency chains
5. **Usability**: 45-second average from command to task creation

## Estimated Effort

- **Overall timeline**: 2-3 days for core implementation
- **Critical path**: Matching algorithm and dependency analysis
- **Total tasks**: 7 focused tasks
- **Complexity**: Medium (leverages existing infrastructure)