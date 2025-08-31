---
name: epic-task-numerotation
status: backlog
created: 2025-08-31T16:04:52Z
progress: 0%
prd: .doh/prds/epic-task-numerotation.md
github: [Will be updated when synced to GitHub]
---

# Epic: epic-task-numerotation

## Overview

Implement a core numbering library that provides centralized, conflict-free task and epic number generation through a global registry system. The library maintains project-isolated state in `~/.doh/projects/{project-id}/`, includes a self-healing cache for fast lookups, and supports message queuing for conflict resolution.

## Architecture Decisions

### Key Technical Decisions
- **Global Registry Storage**: Use `~/.doh/projects/{project-id}/registers.json` to avoid git artifacts
- **Unified Number Space**: Epics and tasks share same sequential numbering (000-999)
- **Self-Healing Cache**: Cache with automatic fallback to .md files as source of truth
- **Message Queue Pattern**: Individual message files for async conflict resolution
- **Project Isolation**: Each project gets unique ID based on path hash
- **No GitHub Sync**: Maintain local autonomy, GitHub URLs optional in frontmatter

### Technology Choices
- **Bash 4.0+**: Leverage associative arrays for registry management
- **JSON with jq**: Simple, readable registry format that handles ~1MB registries
- **File Locking**: Use `flock` for concurrent access safety
- **SHA256 Hashing**: Generate unique project IDs from absolute paths

## Technical Approach

### Core Library Components
- **numbering.sh**: Main library with number allocation functions
- **registers.sh**: Registry management and JSON operations
- **sequence-validation.sh**: Consistency checking and repair tools

### Registry Structure
```json
{
  "global_sequence": {
    "current": 12,
    "used": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    "gaps": []
  },
  "file_cache": {
    "000": {"type": "epic", "path": ".doh/quick/manifest.md", "name": "QUICK"},
    "001": {"type": "epic", "path": ".doh/epics/user-auth/epic.md", "name": "user-auth"},
    "002": {"type": "task", "path": ".doh/epics/user-auth/002.md", "epic": "user-auth"}
  },
  "graph_cache": {
    "002": {"parent": "001", "epic": "user-auth"},
    "003": {"parent": "002", "epic": "user-auth"}
  }
}
```

### Message Queue System
- **Location**: `~/.doh/projects/{project-id}/queues/number_conflict/`
- **File Pattern**: `msg_20250831_160000_001.json` (pending), `.json.ok` (success), `.json.error` (failed)
- **Queue Commands**: `/doh:queue-status`, `/doh:queue-purge`, `/doh:queue-retry`

## Implementation Strategy

### Development Phases
1. **Core Library** (2 days): Basic number allocation and registry management
2. **Cache System** (1 day): File discovery cache with self-healing
3. **Migration Tools** (2 days): Deduplication and conflict resolution
4. **Queue Integration** (1 day): Message queue for async processing
5. **Command Updates** (2 days): Integrate with existing DOH commands

### Risk Mitigation
- **Atomic Operations**: All registry updates use file locking
- **Fallback Strategy**: Always fallback to .md files if cache inconsistent
- **Migration Safety**: Track all renumbering with detailed messages
- **Backward Compatibility**: Support existing manual numbering during transition

### Testing Approach
- **Concurrent Access**: Test with multiple simultaneous operations
- **Cache Recovery**: Verify self-healing when cache corrupted
- **Migration Scenarios**: Test deduplication with various conflict patterns
- **Performance**: Validate < 50ms number allocation, < 10ms cache lookups

## Task Breakdown Preview

Simplified into essential tasks (max 10):
- [ ] **Task 1**: Core numbering library with registry management
- [ ] **Task 2**: File discovery and graph cache implementation
- [ ] **Task 3**: Migration tools for deduplication and conflict resolution
- [ ] **Task 4**: Message queue system for number conflicts
- [ ] **Task 5**: Queue management commands (status, purge, retry)
- [ ] **Task 6**: Integration with existing DOH commands
- [ ] **Task 7**: Frontmatter number field updates
- [ ] **Task 8**: Documentation and testing suite

## Dependencies

### Internal Dependencies
- **DOH Core System**: Existing epic/task file structures
- **Frontmatter Library**: `.claude/scripts/doh/lib/frontmatter.sh`
- **Workspace Library**: Updated `get_current_project_id()` for unique IDs
- **Existing Commands**: /doh:task-new, /doh:epic-new integration

### External Dependencies
- **Bash 4.0+**: Required for associative arrays
- **jq**: JSON processing for registry operations
- **Standard Unix Tools**: sha256sum, flock, realpath
- **File System**: Read/write access to ~/.doh/

## Success Criteria (Technical)

### Performance Benchmarks
- **Number Allocation**: < 50ms for next number retrieval
- **Cache Lookups**: < 10ms for file discovery
- **Registry Size**: Handle 1000+ tasks without degradation
- **Queue Processing**: < 100ms per message

### Quality Gates
- **Zero Conflicts**: No duplicate numbers in same project
- **100% Recovery**: Cache rebuilds correctly from filesystem
- **Atomic Updates**: No partial state corruption
- **Migration Success**: All dependencies updated during renumbering

### Acceptance Criteria
- **Enforced Usage**: All DOH commands use library (no manual numbering)
- **Project Isolation**: Multiple clones work without interference
- **Self-Healing**: System recovers from cache corruption automatically
- **Audit Trail**: Complete message history for all renumbering operations

## Estimated Effort

### Overall Timeline
- **Total Duration**: 8-10 days for complete implementation
- **Critical Path**: Core library → Cache → Migration tools
- **Parallelizable**: Queue system and command integration

### Resource Requirements
- **Development**: 1 developer full-time
- **Testing**: Concurrent access scenarios require multiple test environments
- **Documentation**: 1 day for comprehensive usage guides

### Complexity Assessment
- **Low Complexity**: Core numbering, basic cache operations
- **Medium Complexity**: Migration tools, dependency tracking
- **High Complexity**: Concurrent access handling, self-healing cache

## Tasks Created
- [x] 001.md - Core numbering library with registry management (parallel: false) ✅ COMPLETED
- [x] 002.md - File discovery and graph cache implementation (parallel: false) ✅ COMPLETED
- [x] 003.md - Migration tools for deduplication and conflict resolution (parallel: true) ✅ COMPLETED
- [x] 004.md - Message queue system for number conflicts (parallel: true) ✅ COMPLETED
- [x] 005.md - Queue management commands (parallel: false) ✅ COMPLETED (integrated in 004)
- [ ] 006.md - Integration with existing DOH commands (parallel: false) 🔄 NEXT
- [ ] 007.md - Frontmatter number field updates (parallel: false)
- [ ] 008.md - Documentation and testing suite (parallel: true)

Total tasks: 8
Completed: 5
Remaining: 3
Progress: 62.5%
Estimated remaining effort: 30-35 hours