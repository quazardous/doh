---
name: versioning
number: 003
status: backlog
created: 2025-08-31T20:38:27Z
progress: 0%
prd: .doh/prds/versioning.md
github: [Will be updated when synced to GitHub]
target_version: 1.0.0
file_version: 0.1.0
---

# Epic: Versioning System Implementation

## Overview

Implement a comprehensive semantic versioning system for DOH that provides version tracking for PRDs, epics, and tasks, along with release management workflows. The system will enable better change management, release coordination, and backward compatibility across the DOH ecosystem.

## Architecture Decisions

- **File-based version storage**: Use `.doh/versions/{version}.md` for decentralized, readable version management
- **Hierarchical version inheritance**: PRD → Epic → Task version context flow
- **Non-retroactive file versioning**: Only new/updated files get version tracking to maintain clean history
- **Semantic versioning compliance**: Strict MAJOR.MINOR.PATCH format with validation
- **Library-based implementation**: Extend existing DOH library structure (frontmatter.sh, etc.)

## Technical Approach

### Version Storage System
- **Version files**: Store in `.doh/versions/1.2.3.md` format with release notes, breaking changes, migration guides
- **Version registry**: Track all versions in project state directory for quick lookups
- **Atomic operations**: Ensure version data integrity during creation/updates
- **Validation layer**: Semantic versioning format compliance across all components

### Frontmatter Schema Extensions
- **New version fields**: `target_version`, `release_version`, `file_version` added to PRD/epic/task schemas
- **Inheritance logic**: Child components inherit parent version context with override capability  
- **Version validation**: Ensure consistency across hierarchy during creation/updates
- **Migration safety**: Non-breaking additions to existing frontmatter structure

### Command Integration
- **Version management commands**: `/doh:version-new`, `/doh:version-list`, `/doh:version-publish`, etc.
- **Enhanced creation workflows**: PRD/epic/task creation includes version planning assistance
- **File-level versioning**: Automatic version headers for new files based on file type detection
- **Version-aware behaviors**: Commands consider version context for compatibility and feature availability

### DOH Self-Hosting Support
- **Development versioning**: Special handling for DOH developing itself (current v0.1.0)
- **File version tracking**: All new DOH files include creation version in appropriate format
- **Multi-file type support**: Version headers for .md, .sh, .js, .py with proper comment syntax
- **Documentation chain**: CLAUDE.md → DEVELOPMENT.md → docs/versioning.md cross-referencing

## Implementation Strategy

### Phase 1: Core Version System (Week 1-2)
- Implement version file schema and storage structure
- Create version management commands with validation
- Build semantic versioning utilities and templates

### Phase 2: Frontmatter Integration (Week 3)  
- Extend PRD/epic/task schemas with version fields
- Implement version inheritance logic and validation
- Update creation commands with version planning assistance

### Phase 3: Command Enhancement (Week 4-5)
- Integrate version context into all affected workflows
- Implement file-level version tracking with type detection
- Create version-aware command behaviors

### Phase 4: Documentation & Testing (Week 6)
- Complete documentation updates and user guides
- Comprehensive testing and validation
- Migration tools for existing projects

## Task Breakdown Preview

High-level task categories that will be created:
- [ ] **Version Storage & Management**: Core version file system and commands
- [ ] **Frontmatter Schema Updates**: PRD/epic/task version field integration  
- [ ] **Command Integration**: Update creation workflows for version inheritance
- [ ] **File Version Tracking**: Automatic version headers for new files
- [ ] **Documentation System**: Comprehensive versioning guides and cross-references
- [ ] **Testing & Validation**: Version system integrity and workflow testing
- [ ] **DOH Self-Hosting**: Special handling for DOH development versioning
- [ ] **Migration Tools**: Support for existing project version adoption

## Dependencies

- **Existing DOH libraries**: frontmatter.sh, workspace.sh, numbering.sh for foundation
- **Completed epic-task-numerotation**: Core numbering system (Tasks 001-005 completed, 006-010 in progress)
- **File manipulation infrastructure**: Read/Write operations and directory management
- **Git integration**: Version history tracking and change management

## Success Criteria (Technical)

- **Version consistency**: All version operations maintain semantic versioning compliance
- **Performance**: <100ms overhead for version operations in existing commands  
- **Data integrity**: Atomic version operations with rollback capability
- **Backward compatibility**: Existing projects continue functioning without modification
- **Documentation coverage**: Complete API reference and user guides for all version features

## Estimated Effort

- **Overall timeline**: 6 weeks for complete implementation
- **Resource requirements**: 1 senior developer, part-time product manager for validation
- **Critical path**: Core version system → Frontmatter integration → Command updates → Documentation

**Total effort**: ~120-150 hours across 25+ implementation tasks in 5 epic categories

## Tasks Created
- [ ] 005.md - Create frontmatter integration (parallel: true)
- [ ] 006.md - Version bump workflow implementation (parallel: false)
- [ ] 007.md - Version milestone conditions and auto-bump (parallel: false)
- [ ] 008.md - Version dependencies in task graph (parallel: true)
- [ ] 009.md - Version management commands (parallel: true)
- [ ] 010.md - Version validation utilities (parallel: true)
- [ ] 011.md - Version file headers system (parallel: true)
- [ ] 012.md - Version documentation and guides (parallel: false)
- [ ] 013.md - Version system testing suite (parallel: false)
- [ ] 014.md - Version migration tools (parallel: false)

Total tasks: 10
Parallel tasks: 6
Sequential tasks: 4
Estimated total effort: 70-86 hours