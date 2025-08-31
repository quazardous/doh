---
name: epic-task-numerotation
description: Core numbering library with registry system for consistent task ID generation and sequence management
status: backlog
created: 2025-08-31T14:43:32Z
---

# PRD: epic-task-numerotation

## Executive Summary

A lightweight numbering library that provides consistent task ID generation and sequence management through a simple registry system. The library maintains project-scoped numbering state in `.doh/registers.json`, handles sequence allocation for epics and QUICK tasks, and addresses the question of GitHub issue numbering synchronization with clear trade-off analysis.

## Problem Statement

DOH currently lacks a systematic approach to task numbering, leading to manual sequence management and inconsistencies.

### Core Issues
1. **Manual Numbering**: Developers manually determine next task numbers (001, 002, 003...)
2. **No Central Registry**: No authoritative source for current sequence state per epic
3. **Branch Artifacts**: Git branching can create numbering conflicts and stale state
4. **GitHub Sync Uncertainty**: Unclear whether to align with GitHub issue numbers (pros/cons not evaluated)
5. **QUICK System Gap**: New `.doh/quick/` system needs integrated numbering approach

### Specific Pain Points
- Finding next available task number requires manual scanning
- Multiple developers risk creating duplicate task IDs
- No validation of numbering consistency
- Registry data mixed with versioned content creates branch conflicts

## User Stories

### Developer Creating New Task
**As a** developer creating a new task  
**I want to** get the next available task number automatically  
**So that** I don't have to manually scan existing files and risk conflicts  

**Acceptance Criteria:**
- Library provides next sequential number (001, 002, 003...)
- Works for both epic tasks and QUICK tasks
- Handles concurrent access safely
- Updates registry atomically

### Epic Owner Managing Sequence State  
**As an** epic owner  
**I want to** view and validate current numbering state  
**So that** I can ensure sequence integrity and identify gaps  

**Acceptance Criteria:**
- Can query current sequence state for any epic
- Shows gaps and inconsistencies in numbering
- Displays QUICK system numbering separately
- Provides sequence health validation

### Team Lead Evaluating GitHub Sync
**As a** team lead  
**I want to** understand pros/cons of GitHub issue numbering sync  
**So that** I can make informed decision about external integration  

**Acceptance Criteria:**
- Clear analysis of GitHub sync benefits and drawbacks
- Technical feasibility assessment  
- Impact on local numbering autonomy
- Recommendation with rationale

### System Administrator Managing Registry Location
**As a** system administrator  
**I want to** choose between project-scoped and global registry storage  
**So that** I can avoid git artifacts while maintaining appropriate scope  

**Acceptance Criteria:**
- Option for `.doh/registers.json` (project scope)
- Option for `~/.doh/projects/{id}/registers.json` (global scope)
- Clear guidance on when to use each approach
- Migration path between storage locations

### Developer Using DOH Commands
**As a** developer using DOH task creation commands  
**I want to** have task numbers automatically assigned through the library  
**So that** I never have to manually manage sequences and avoid conflicts  

**Acceptance Criteria:**
- All DOH task creation commands enforce library usage (absolute obligation)
- Fast task file discovery through cache lookup (< 10ms)
- Library handles duplicate cache entries gracefully
- Cache automatically updates when tasks created through library
- Recovery tools available if cache becomes stale

## Requirements

### Functional Requirements

#### Core Library Functions
- **`get_next_epic_number()`**: Returns next sequential number for new epic
- **`get_next_task_number(epic_name)`**: Returns next sequential number for given epic
- **`get_next_quick_number()`**: Returns next number for QUICK system
- **`validate_sequence(epic_name)`**: Checks for gaps and inconsistencies
- **`register_epic_number(epic_name, number)`**: Marks epic number as used
- **`register_task_number(epic_name, number)`**: Marks task number as used
- **`list_sequences()`**: Shows current state of all epic and task sequences
- **`find_file(number, [type])`**: Fast lookup of file path from cache (type: 'epic'|'task', defaults to 'task')

#### File Discovery Cache
- **Unified Cache**: Maps both epic and task numbers to file paths for fast discovery
- **Type Differentiation**: Distinguishes between epic files and task files
- **Duplicate Tolerance**: Multiple entries for same number acceptable
- **Speed Optimization**: Eliminates need to scan filesystem for files
- **Automatic Updates**: Cache updates when epics/tasks created via library

#### Graph Relationship Cache
- **Parent-Only Cache**: Maps each item to its parent and current epic (one-way only)
- **Speed Optimization**: Cache used for fast lookups, fallback to filesystem if wrong
- **Automatic Fallback**: If cache data doesn't match file, read .md file and fix cache
- **Source of Truth**: Epic/task .md files are always authoritative
- **Self-Healing**: Cache automatically corrects itself when inconsistencies found
- **Graceful Degradation**: System works normally even with completely broken cache

#### Registry Management  
- **JSON Format**: Simple, readable registry structure
- **Atomic Updates**: Safe concurrent access with file locking
- **Multi-Project Support**: Global `~/.doh/` directory isolates multiple projects on same computer
- **Registry Location**: `~/.doh/projects/{project-id}/registers.json` (avoids git artifacts)
- **Queue Location**: `~/.doh/projects/{project-id}/queues/{queue-name}/` (per-project queues)
- **Backup/Recovery**: Automatic backup before registry modifications

#### DOH Multi-Project Isolation 
- **Global DOH Directory**: `~/.doh/` enables running DOH commands across multiple projects on same computer
- **Per-Project State**: Each project gets isolated space in `~/.doh/projects/{project-id}/`
- **Project Detection**: Commands auto-detect current project from `.doh/` directory in working tree
- **Command Isolation**: Each `/doh` command operates only on current project's data
- **No Cross-Project Interference**: Multiple projects can coexist without conflicts
- **Worker Scope**: Future worker agents operate per-project, respecting isolation

#### Numbering Schema
- **Zero-Padded Sequential**: 001, 002, 003... format for both epics and tasks
- **Project-Wide Uniqueness**: Each number unique across entire project (epics and tasks share number space)
- **Hierarchical Structure**: Epic numbers and task numbers in same sequence (Epic 001, Task 002, Epic 003, Task 004...)
- **Epic Internal Numbers**: Epics get numbers just like tasks since they are essentially high-level tasks
- **QUICK Integration**: QUICK system gets reserved number 000, tasks use normal sequence
- **Gap Tolerance**: System handles missing numbers gracefully
- **Absolute Library Usage**: All epic/task creation must use library (enforced obligation)

#### Epic Frontmatter Integration
- **Epic Number Field**: Add `number: 001` field to epic.md frontmatter
- **Maintenance Epic Numbers**: Add `number: 007` field to maintenance.md frontmatter  
- **Parent Reference**: Use `parent: 001` to reference any parent (epic or task)
- **Epic Context**: Keep `epic: epic-name` field for organizational sanity
- **Automatic Population**: Library automatically sets number field during creation

#### GitHub Integration (Absolutely Optional)
- **URL Synchronization**: Optional `github: https://github.com/org/repo/issues/123` field
- **No Automatic Sync**: GitHub URLs manually added if desired, never required
- **Independent Numbering**: DOH numbers completely independent from GitHub issue numbers
- **User Choice**: Teams decide per-epic whether to add GitHub links

### Non-Functional Requirements

#### Performance
- **Fast Registry Access**: Number allocation in < 50ms
- **Graph Traversal**: Parent/child lookups in < 10ms via graph cache
- **Lightweight Storage**: Registry file under 20KB for 100+ epics with graph cache
- **Minimal Dependencies**: Uses only standard Unix tools and bash
- **Memory Efficient**: Library loads only when needed
- **Cache Rebuilding**: Graph cache rebuild in < 500ms for 500+ items

#### Reliability
- **File Locking**: Prevents concurrent registry corruption
- **Atomic Updates**: Registry changes succeed completely or fail cleanly
- **Cache Fallback**: Always fallback to .md files when cache data is suspect
- **Self-Healing Cache**: Automatically fixes cache inconsistencies when detected
- **Error Recovery**: Clear error messages with recovery guidance
- **Validation**: Built-in consistency checking with automatic repair

#### Usability
- **Simple API**: Library functions are intuitive and well-documented
- **Clear Output**: Registry format is human-readable JSON
- **Debug Support**: Verbose mode for troubleshooting
- **Migration Tools**: Easy transition from manual numbering

#### Integration
- **DOH Commands**: Works with existing /doh:* command structure
- **Shell Environment**: Compatible with current bash-based tooling
- **Git Friendly**: Registry location choice avoids branch conflicts
- **Cross-Platform**: Works on Unix, Linux, macOS

## Success Criteria

### Measurable Outcomes
1. **Numbering Consistency**: 100% of tasks follow systematic numbering rules
2. **Insertion Efficiency**: Task insertion time reduced by 80% (from 5 minutes to 1 minute average)
3. **Dependency Reliability**: Zero dependency breakage due to numbering changes
4. **User Adoption**: 90% of epic modifications use new numbering tools
5. **Error Reduction**: 75% fewer task reference errors in commits and documentation

### Key Metrics
- **Task Insertion Time**: Average time to add task mid-epic
- **Dependency Update Success Rate**: Percentage of automatic dependency updates that succeed
- **Renumbering Frequency**: How often teams need to reorganize task sequences
- **Cross-Epic Reference Usage**: Adoption of standardized task references
- **Support Requests**: Reduction in numbering-related help requests

## Constraints & Assumptions

### Constraints
- **File System Limitations**: Task files must remain as individual .md files
- **Git Compatibility**: Numbering changes must work well with git operations
- **Existing Epic Preservation**: Cannot break existing epic structures
- **Command Compatibility**: Must work with current DOH command set
- **Cross-Platform Support**: Work on Unix, Linux, and macOS environments

### Assumptions
- **Sequential Preference**: Most epics benefit from sequential numbering
- **Limited Reorganization**: Major task reordering is infrequent (monthly, not daily)
- **Developer Discipline**: Teams will follow numbering guidelines when provided
- **Tool Adoption**: Users prefer automated solutions over manual numbering management
- **Epic Stability**: Most epics have stable scope after initial planning

## GitHub Issue Numbering Sync Analysis

### Pros of GitHub Sync
- **Unified References**: Same numbers in DOH tasks and GitHub issues
- **External Visibility**: GitHub issues provide public task references
- **Project Management Integration**: GitHub project boards work seamlessly
- **Stakeholder Communication**: Non-technical stakeholders use familiar GitHub interface

### Cons of GitHub Sync
- **External Dependency**: Numbering system depends on GitHub API availability
- **API Rate Limits**: GitHub API limits may constrain task creation frequency
- **Complexity**: Sync logic adds significant implementation complexity
- **Local Autonomy Loss**: Can't work offline or without GitHub access
- **Sequential Breaks**: GitHub issue deletions create permanent gaps in sequence
- **Organization Coupling**: Numbering tied to specific GitHub org/repo structure

### Technical Challenges
- **API Authentication**: Requires GitHub token management
- **Network Reliability**: Internet connectivity required for task creation
- **Sync Conflicts**: Handling cases where GitHub and local state diverge
- **Migration Complexity**: Existing projects would need complex migration process

### Recommendation
**Avoid GitHub sync for core numbering system.** The complexity and external dependencies outweigh the benefits. Instead:
- Keep DOH task numbering autonomous and reliable
- Provide optional GitHub issue creation as separate feature
- Allow manual sync when needed, but don't require it
- Focus on local reliability and developer productivity

## Out of Scope

### Explicitly Excluded Features
- **Automatic GitHub Sync**: No automatic synchronization with GitHub issue numbers
- **Required GitHub Integration**: GitHub URLs are absolutely optional, never mandatory
- **GitHub Issue Creation**: Library doesn't create GitHub issues automatically
- **Custom Numbering Schemes**: Only supporting zero-padded sequential (001, 002, 003...)
- **Cross-Epic Dependencies**: Library focuses on numbering, not dependency management  
- **Task Insertion Logic**: Simple sequential allocation, no gap-filling or insertion
- **Historical Tracking**: No audit log of numbering changes over time

### GitHub Integration Policy
- **Manual Only**: GitHub URLs added manually to frontmatter if desired
- **No Dependencies**: DOH numbering system works completely without GitHub
- **Team Choice**: Each team/project decides GitHub integration level independently
- **No Validation**: Library doesn't validate or require GitHub URLs

### Migration Strategy
- **Deduplication Script**: Fix duplicate task numbers by creation date (older keeps number)
- **Renumbering Tool**: Assign new numbers to duplicates based on frontmatter `created` field
- **Dependency Tracking**: During renumbering, detect and update all references to changed numbers
- **Message Queue**: Post renumbering messages for processing (like Redis queue pattern)
- **Reference Updates**: Scan all files for `parent`, `depends_on`, and epic references to update
- **Cache Cleanup**: Migration script removes orphaned cache entries for deleted files
- **Manual Conflicts**: Handle cases where registry conflicts with existing manual files

### Performance Considerations
- **jq Limits**: JSON processing should handle registries up to ~1MB (thousands of tasks)
- **Cache Size**: No artificial limits, rely on jq performance characteristics
- **File Locking**: Use `flock` with reasonable timeout for concurrent access

### Queue Management Commands (Project-Scoped)
- **`/doh:queue-status [queue-name]`**: Show pending/success/error message counts (current project only)
- **`/doh:queue-purge [queue-name] [--days=7]`**: Remove .json.ok files older than specified days (current project)
- **`/doh:queue-retry [queue-name]`**: Retry .json.error messages (current project queues)
- **`/doh:queue-list [queue-name] [--status=pending]`**: List messages by queue and status (current project)

Examples:
```bash
/doh:queue-status                    # All queues in current project
/doh:queue-status number_conflict    # Only number_conflict queue in current project  
/doh:queue-purge number_conflict --days=30  # Purge current project's number_conflict messages
/doh:queue-list sync_requests --status=error  # List current project's failed sync messages
```

### Project ID Uniqueness (Resolved)
- **Solution Implemented**: `get_current_project_id()` now uses `basename_hash` format
- **Format**: `{project-name}_{8-char-hash}` where hash is from absolute path
- **Examples**: 
  - `/home/user/project-a` → `project-a_abc123ef` 
  - `/home/user/work/project-a` → `project-a_def456gh`
  - `/home/user/project-a-fork` → `project-a-fork_789abc12`
- **Benefits**: Same project can be cloned multiple times without conflicts

### Future Considerations  
- **Race Condition Analysis**: Dedicated task to identify and address race conditions beyond file locking
- **Migration Tool**: Handle existing projects that used old non-unique ID format
- **Worker Agents**: Dedicated agents/workers to poll queue directories for .json files
- **Worker Scope**: Workers operate per-project, respecting project isolation
- **Queue Types**: Extensible queue system (`number_conflict`, `sync_requests`, `maintenance_tasks`, etc.)
- **Message Persistence**: .json.ok files provide audit trail, .json.error files for debugging
- **Multiple Registry Support**: Team-specific or project-specific numbering schemes  
- **Optional GitHub Helpers**: Utilities to assist manual GitHub integration (if requested)

## Dependencies

### Internal Dependencies
- **DOH Core System**: Requires existing epic and task file structures
- **Frontmatter Library**: Depends on `.claude/scripts/doh/lib/frontmatter.sh`
- **Task Management**: Builds on existing task.sh library
- **Command Infrastructure**: Integrates with current DOH command pattern

### External Dependencies
- **Git Repository**: Numbering system assumes git-tracked project
- **File System Access**: Requires read/write permissions to .doh/ directory
- **Shell Environment**: Bash 4.0+ for associative arrays and advanced scripting
- **Unix Tools**: Standard tools (grep, sed, awk) for text processing

### Integration Points
- **QUICK System**: Must coordinate with new `.doh/quick/` directory structure
- **Maintenance Epics**: Integrate with maintenance.md file pattern
- **GitHub Sync**: Work with existing GitHub issue synchronization
- **Status Commands**: Update /doh:next and /doh:status to show numbering info

## Technical Implementation Notes

### Library Structure
```
.claude/scripts/doh/lib/
├── numbering.sh            # Core numbering library
├── registers.sh            # Registry management functions  
└── sequence-validation.sh  # Consistency checking utilities
```

### Registry File Structure
```
.doh/registers.json         # Project-scoped option
~/.doh/projects/{id}/registers.json  # Global option

{
  "global_sequence": {
    "current": 12,
    "used": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    "gaps": []
  },
  "file_cache": {
    "000": {
      "type": "epic",
      "path": ".doh/quick/manifest.md",
      "name": "QUICK"
    },
    "001": {
      "type": "epic",
      "path": ".doh/epics/user-auth/epic.md",
      "name": "user-auth"
    },
    "002": {
      "type": "task", 
      "path": ".doh/epics/user-auth/002.md",
      "epic": "user-auth"
    },
    "003": {
      "type": "task",
      "path": ".doh/epics/user-auth/003.md", 
      "epic": "user-auth"
    },
    "004": {
      "type": "epic",
      "path": ".doh/epics/payment-system/epic.md",
      "name": "payment-system" 
    },
    "005": {
      "type": "task",
      "path": ".doh/quick/005.md",
      "epic": "QUICK"
    }
  },
  "graph_cache": {
    "002": {
      "parent": "001",
      "epic": "user-auth"
    },
    "003": {
      "parent": "002", 
      "epic": "user-auth"
    },
    "007": {
      "parent": "001",
      "epic": "user-auth"
    },
    "008": {
      "parent": "004",
      "epic": "payment-system"
    },
    "last_sync": "2025-08-31T15:30:00Z"
  },
  "metadata": {
    "created": "2025-08-31T14:43:32Z",
    "last_updated": "2025-08-31T15:30:00Z",
    "version": "1.0"
  }
}
```

### Core Library Functions
```bash
# .claude/scripts/doh/lib/numbering.sh
get_next_number() {         # Returns next available number in global sequence
register_epic(name, number) {  # Marks epic number as used, updates cache + frontmatter
register_task(epic_name, number) {  # Marks task number as used, updates cache + frontmatter
create_epic_with_number(name) {     # Creates epic.md with auto-assigned number in frontmatter
create_maintenance_epic(parent_number) {  # Creates maintenance.md with parent reference
create_task_with_number(epic_name, title) {    # Creates task.md with number in frontmatter
validate_sequence() {       # Checks sequence consistency across project
list_sequences() {          # Shows current state of global sequence
find_file(number, [type]) { # Fast lookup: 001 -> file path (type: epic/task, defaults task)
update_cache(number, type, path, metadata) {  # Add/update cache entry
rebuild_cache() {           # Scan filesystem to rebuild cache (recovery tool)
get_epic_tasks(epic_name) { # Get all task numbers for specific epic
sync_frontmatter_numbers() { # Ensure all frontmatter number fields are correct
get_parent(number) {        # Cache lookup, fallback to .md file if cache wrong, auto-fix cache
get_epic_name(number) {     # Cache lookup, fallback to .md file if cache wrong, auto-fix cache  
get_children(parent_number) {  # Scan cache, verify against filesystem if needed
rebuild_graph_cache() {     # Rebuild entire graph cache from filesystem scanning
auto_fix_cache_entry(number) {  # Read .md file and fix cache entry for this number
migrate_existing_project() {    # Scan project, deduplicate by created date, renumber duplicates
fix_registry_conflicts() {      # Handle cases where registry conflicts with existing files
cleanup_orphaned_cache() {      # Remove cache entries for deleted files
track_renumber_dependencies(old_num, new_num, epic) {  # Find all files referencing old number
update_all_references(old_num, new_num) {  # Update parent/depends_on references across all files
post_renumber_message(old_num, new_num, epic, dependencies) {  # Create message file with unique ID
process_message_queue() {       # Process pending .json files (for future worker agents)
mark_message_success(msg_file) {  # Rename .json to .json.ok
mark_message_error(msg_file, error) {  # Rename .json to .json.error, append error info
purge_successful_messages(days_old) {  # Remove .json.ok files older than N days
```

### Epic Frontmatter Structure
```yaml
# Regular Epic (epic.md)
---
name: user-authentication
number: 001
status: active
created: 2025-08-31T14:43:32Z
progress: 20%
prd: .doh/prds/user-auth.md
github: https://github.com/org/repo/issues/45  # Optional
---

# Maintenance Epic (maintenance.md)  
---
name: user-authentication-maintenance
number: 007
parent: 001
epic: user-authentication
type: maintenance
status: active
created: 2025-08-31T15:30:00Z
scope: "Technical maintenance only - no new features"
github: https://github.com/org/repo/issues/67  # Optional
---
```

### Task Frontmatter Structure
```yaml
# Regular Task (003.md)
---
id: 003
number: 003  # Same as id, but explicit for consistency
title: Implement login validation
status: pending
created: 2025-08-31T14:45:00Z
priority: high
estimate: 4 hours
epic: user-authentication
parent: 002  # Can reference any task or epic number
depends_on: [002]
github: https://github.com/org/repo/issues/48  # Optional
---

# Task that references Epic directly
---
id: 008
number: 008
title: Setup deployment pipeline
status: pending
epic: deployment-system  
parent: 004  # References Epic 004 (deployment-system epic)
---
```

### Message Queue Structure
```
~/.doh/projects/{project-id}/queues/number_conflict/
├── msg_20250831_160000_001.json      # Pending message
├── msg_20250831_160001_002.json.ok   # Successfully processed
├── msg_20250831_160002_003.json.error # Failed processing
└── msg_20250831_160003_004.json      # Another pending message
```

Individual message file format:
```json
// ~/.doh/projects/{project-id}/queues/number_conflict/msg_20250831_160000_001.json
{
  "id": "msg_20250831_160000_001",
  "timestamp": "2025-08-31T16:00:00Z",
  "project_id": "my-project",
  "type": "renumber_request",
  "payload": {
    "old_number": "003",
    "new_number": "015", 
    "epic": "user-auth",
    "reason": "Duplicate found, older task (2025-08-20) kept original number",
    "dependencies_to_update": [
      {
        "file": ".doh/epics/user-auth/004.md",
        "field": "parent",
        "old_value": "003",
        "new_value": "015"
      },
      {
        "file": ".doh/epics/user-auth/005.md", 
        "field": "depends_on",
        "old_value": ["002", "003"],
        "new_value": ["002", "015"]
      }
    ]
  }
}
```

### Integration Points
- **Existing DOH Commands**: Library sourced by epic/task creation commands
- **Registry Location**: Configurable via DOH_REGISTRY_SCOPE env var
- **Concurrency**: File locking using `flock` for safe multi-user access
- **Frontmatter Updates**: Library automatically populates number fields
- **Message Processing**: Renumbering operations posted as messages for worker processing

## Migration Strategy

### Phase 1: Foundation (Week 1-2)
- Implement core numbering engine
- Create sequence tracking system
- Add basic insertion support

### Phase 2: Integration (Week 3-4)  
- Update existing DOH commands
- Add numbering validation
- Create migration tools for existing epics

### Phase 3: Enhancement (Week 5-6)
- Cross-epic dependency tracking
- Advanced insertion strategies  
- Performance optimization

### Phase 4: Adoption (Week 7-8)
- Documentation and training
- Migration support for existing projects
- Performance tuning based on real usage

## Risk Mitigation

### Technical Risks
- **Data Loss**: Comprehensive backup before any numbering operations
- **Performance Issues**: Incremental indexing and caching for large projects  
- **Complexity Creep**: Start with simple sequential numbering, add features gradually
- **Migration Failures**: Extensive testing with real project data

### User Adoption Risks
- **Learning Curve**: Provide clear migration guides and examples
- **Tool Resistance**: Make new system optional initially, prove value gradually
- **Workflow Disruption**: Ensure backward compatibility during transition
- **Documentation Debt**: Update all DOH documentation to reflect numbering system