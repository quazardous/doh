---
name: worktree-handling-review
status: backlog
created: 2025-08-31T06:48:23Z
progress: 0%
prd: .doh/prds/worktree-handling-review.md
github: [Will be updated when synced to GitHub]
---

# Epic: Worktree Handling Review

## Overview

Implement a comprehensive context awareness system that ensures every /doh component knows whether it's operating in branch or worktree mode, with mandatory context displays, pre-flight validation, and real-time monitoring from the main Claude stream.

## Architecture Decisions

### Core Design Choices
- **Dual-mode architecture**: Explicit separation between branch mode (quick tasks) and worktree mode (long tasks)
- **Context-first approach**: Every operation starts with context detection and display
- **Fail-safe validation**: Pre-flight checks prevent agent launches in non-existent worktrees
- **Centralized monitoring**: All worktree activity streams back to main conversation

### Technology Stack
- **Bash scripting**: For context detection and validation logic
- **YAML configuration**: For context persistence and settings
- **Git worktrees**: Native git feature for isolated development
- **File-based logging**: Simple log aggregation in .doh/logs/

### Design Patterns
- **Command decorator pattern**: Wrap all commands with context display
- **Pre-flight validation**: Check preconditions before execution
- **Observer pattern**: Stream logs from worktrees to main context
- **Strategy pattern**: Mode selection based on task characteristics

## Technical Approach

### Context Management Layer
- Create `.doh/lib/context.sh` with shared context functions
- Implement context detection that checks `git worktree list` and current directory
- Build context persistence in `.doh/context.yml` for state between commands
- Add context display wrapper for all command entry points

### Command Enhancement
- Update all /doh commands to source context library
- Add `--branch` and `--worktree` flag parsing
- Implement auto-detection logic based on task metadata
- Ensure context banner displays before any operation

### Monitoring Infrastructure
- Create log directory structure under `.doh/logs/`
- Implement log streaming with `tail -f` for real-time updates
- Build progress aggregation from agent commits
- Add `/doh:monitor` command for viewing worktree status

### Safety Systems
- Implement pre-flight validation function for worktree operations
- Add directory existence checks before agent launches
- Create rollback mechanisms for failed worktree creation
- Build error recovery with clear remediation steps

## Implementation Strategy

### Development Approach
1. Start with context library as foundation
2. Update high-impact commands first (epic-start, issue-start)
3. Add monitoring in parallel with command updates
4. Layer in safety checks after core functionality works

### Risk Mitigation
- Keep existing behavior as fallback during transition
- Test with small epics before full rollout
- Maintain backward compatibility with flags
- Document migration path for existing workflows

### Testing Strategy
- Unit tests for context detection logic
- Integration tests for command workflows
- Simulation of agent failures and recovery
- Performance testing with multiple worktrees

## Task Breakdown Preview

Streamlined implementation in focused phases:

- [ ] **Task 1**: Core context system - Detection, persistence, and display
- [ ] **Task 2**: Command updates - Add flags and context awareness to all commands
- [ ] **Task 3**: Pre-flight validation - Safety checks and error handling
- [ ] **Task 4**: Monitoring system - Log streaming and progress tracking
- [ ] **Task 5**: Agent integration - Update agents with context awareness
- [ ] **Task 6**: Helper commands - Navigation and status tools
- [ ] **Task 7**: Documentation and migration - Update docs and migration guide

## Dependencies

### External Dependencies
- Git 2.5+ for worktree support
- Bash 4.0+ for associative arrays
- Standard Unix tools (tail, grep, sed)

### Internal Dependencies
- Existing /doh command structure must be preserved
- Agent framework needs context injection points
- Current epic/issue tracking remains compatible

### No Additional Dependencies
- No new languages or frameworks required
- Leverages existing bash infrastructure
- Uses native git features only

## Success Criteria (Technical)

### Performance Benchmarks
- Context detection < 100ms
- Log streaming latency < 2 seconds
- Worktree creation < 5 seconds
- No performance degradation in main repo

### Quality Gates
- 100% of commands show context banner
- Zero agent launches without validation
- All error states have recovery paths
- Context persists across command invocations

### Acceptance Criteria
- Developers never confused about working context
- Main stream maintains visibility into all work
- Quick tasks stay in branch without overhead
- Long tasks isolated in worktrees automatically

## Estimated Effort

### Timeline
- **Total Duration**: 2 weeks
- **Phase 1** (Core): 3 days
- **Phase 2** (Commands): 3 days
- **Phase 3** (Monitoring): 2 days
- **Phase 4** (Polish): 2 days

### Resource Requirements
- 1 developer for implementation
- Existing infrastructure only
- No additional tools needed

### Critical Path
1. Context library (enables everything else)
2. Command updates (user-facing changes)
3. Monitoring (visibility requirement)
4. Documentation (adoption enabler)

## Tasks Created
- [ ] 001.md - Core Workspace Awareness System (parallel: false)
- [ ] 002.md - Command Flag Updates (parallel: false)
- [ ] 003.md - Pre-flight Validation System (parallel: true)
- [ ] 004.md - Monitoring and Logging Infrastructure (parallel: true)
- [ ] 005.md - Agent Workspace Integration (parallel: false)
- [ ] 006.md - Workspace Navigation Commands (parallel: true)
- [ ] 007.md - Documentation and Migration Guide (parallel: true)

Total tasks: 7
Parallel tasks: 4
Sequential tasks: 3
Estimated total effort: 68 hours