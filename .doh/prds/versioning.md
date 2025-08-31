---
name: versioning
description: Comprehensive versioning system for DOH with semantic versioning, PRD version tracking, and release management
status: backlog
created: 2025-08-31T19:13:44Z
target_version: 1.0.0
release_version: null
file_version: 0.1.0
---

# PRD: Versioning System for DOH

## Executive Summary

Implement a comprehensive versioning system for the DOH (Development Operations Helper) project management tool. This system will introduce semantic versioning for DOH releases, version tracking for PRDs and epics, and integrated release management workflows. The versioning system will enable better change management, release coordination, and backward compatibility handling across the DOH ecosystem.

## Problem Statement

### Current State Issues:
- **No version tracking** for PRDs, epics, or the DOH system itself
- **No release coordination** mechanism for managing feature rollouts
- **No change history** for important documents and specifications
- **No backward compatibility** guarantees for DOH tool evolution
- **Difficult coordination** between DOH development and projects using DOH

### Why Now:
- DOH is maturing and needs stable release cycles
- Multiple projects depend on DOH requiring stability guarantees
- Team growth requires better change management processes
- Need to support both bleeding-edge development and stable production usage

## User Stories

### Primary Personas:

#### 1. DOH Developer
- **As a DOH developer**, I want to version my changes so that I can track feature evolution
- **As a DOH developer**, I want semantic versioning so that breaking changes are clearly communicated
- **As a DOH developer**, I want release branches so that I can stabilize features before release

#### 2. Product Manager
- **As a product manager**, I want to version my PRDs so that I can track requirement evolution
- **As a product manager**, I want target versions so that I can plan feature releases
- **As a product manager**, I want version history so that I can understand what changed when

#### 3. Project User (Using DOH)
- **As a project user**, I want stable DOH versions so that my workflows don't break unexpectedly
- **As a project user**, I want clear upgrade paths so that I can adopt new features safely
- **As a project user**, I want LTS versions so that I can maintain stability

## Requirements

### Functional Requirements

#### Version Storage System
- **R1**: Store version files as `.doh/versions/{version}.md` (e.g., `1.2.3.md`)
- **R2**: Support semantic versioning format: `MAJOR.MINOR.PATCH`
- **R3**: Version files contain release notes, breaking changes, and migration guides
- **R4**: Maintain version history and changelog generation

#### PRD, Epic, and Task Version Integration
- **R5**: Add `target_version` field to PRD frontmatter (planned release version)
- **R6**: Add `release_version` field to PRD frontmatter (actual release version)
- **R7**: Add `target_version` field to epic frontmatter (inherited from PRD or specified)
- **R8**: Add `release_version` field to epic frontmatter (actual release version)
- **R9**: Add `target_version` field to task frontmatter (inherited from epic or specified)
- **R10**: Add `release_version` field to task frontmatter (actual release version)
- **R11**: PRD creation workflow includes version planning assistance
- **R12**: Epic and task creation inherits version context from parent
- **R13**: Version validation ensures semantic versioning compliance across all levels

#### Release Management
- **R9**: Commands to create, update, and publish version files
- **R10**: Integration with epic and task workflows for version tracking
- **R11**: Release preparation automation (changelog, migration notes)
- **R12**: Version-aware command behavior and compatibility checks

#### DOH Development Project Support  
- **R13**: Special handling for DOH system development in `DEVELOPMENT.md`
- **R14**: Separate versioning for DOH tool vs projects using DOH
- **R15**: Development version tracking and pre-release management
- **R16**: File-level version tracking for all created/updated files (non-retroactive)
- **R17**: Current DOH development version: 0.1.0

### Non-Functional Requirements

#### Performance
- **NR1**: Version operations should add <100ms overhead to existing commands
- **NR2**: Version history queries should complete within 1 second

#### Compatibility
- **NR3**: Backward compatibility for at least 2 major versions
- **NR4**: Clear migration paths for breaking changes
- **NR5**: Non-breaking addition to existing DOH workflows

#### Reliability
- **NR6**: Version data integrity through atomic operations
- **NR7**: Recovery mechanisms for corrupted version data
- **NR8**: Validation of version consistency across system

## Success Criteria

### Measurable Outcomes:
1. **Version Adoption**: 100% of new PRDs include target_version within 1 month
2. **Release Velocity**: Ability to ship DOH releases every 2 weeks
3. **Change Tracking**: Complete change history for all PRDs and major releases
4. **User Satisfaction**: <5 breaking change issues per major release
5. **Documentation**: Complete version documentation and migration guides

### Key Metrics:
- Number of versions tracked and managed
- PRD version coverage percentage  
- Release deployment success rate
- User upgrade completion rate
- Breaking change issue resolution time

## Technical Implementation

### Version File Structure
```markdown
---
version: 1.2.3
type: major|minor|patch
released: 2025-08-31T19:13:44Z
status: draft|released|deprecated
breaking_changes: true|false
---

# Release Notes: DOH v1.2.3

## New Features
- Feature A with detailed description
- Feature B with usage examples

## Breaking Changes
- Change X with migration instructions
- Change Y with compatibility notes

## Bug Fixes
- Fix A with issue reference
- Fix B with affected versions

## Migration Guide
[Detailed upgrade instructions]
```

### Updated Frontmatter Schemas

#### PRD Frontmatter
```yaml
---
name: feature-name
description: Feature description
status: backlog|in-progress|completed
created: 2025-08-31T19:13:44Z
target_version: 1.0.0    # NEW: Planned release version
file_version: 0.1.0      # NEW: Version when this file was created
release_version: null    # NEW: Actual release version (null until released)
---
```

#### Epic Frontmatter
```yaml
---
name: Epic Name
status: open|in-progress|completed
created: 2025-08-31T19:13:44Z
updated: 2025-08-31T19:13:44Z
github: [GitHub URL]
progress: 45%
prd: path/to/prd.md
target_version: 1.0.0    # NEW: Inherited from PRD or specified
file_version: 0.1.0      # NEW: Version when this file was created
release_version: null    # NEW: Actual release version
---
```

#### Task Frontmatter  
```yaml
---
name: Task Name
status: open|in-progress|completed|blocked
created: 2025-08-31T19:13:44Z
updated: 2025-08-31T19:13:44Z
github: [GitHub URL]
depends_on: [001, 002]
parallel: false
conflicts_with: []
target_version: 1.0.0    # NEW: Inherited from epic or specified
release_version: null    # NEW: Actual release version
file_version: 0.1.0      # NEW: Version when file was created/last updated
---
```

#### File-Level Version Tracking
**All new and updated DOH files will include version information:**

**Markdown files (.md):**
```yaml
file_version: 0.1.0      # Version when file was created or last significantly updated
```

**Shell scripts (.sh):**
```bash
#!/bin/bash
# DOH Version: 0.1.0
# Created: 2025-08-31T19:13:44Z
```

**Other file types:**
- Use appropriate comment syntax for the language
- Include version and creation date in header
- Examples: `# DOH Version: 0.1.0`, `// DOH Version: 0.1.0`, etc.

**Rules for file_version:**
- Set when file is first created
- Updated only when file receives significant changes
- NOT retroactively added to existing files
- Format depends on file type and comment syntax
- Helps track when features/documentation were introduced

### Commands to Implement

#### Version Management Commands:
- `/doh:version-new 1.2.3` - Create new version file
- `/doh:version-list` - List all versions
- `/doh:version-current` - Show current/latest version
- `/doh:version-publish 1.2.3` - Publish version (draft→released)
- `/doh:version-deprecate 1.1.0` - Mark version as deprecated

#### Integration Updates:
- Update `/doh:prd-new` - Add version planning assistance and file_version
- Update `/doh:prd-parse` - Consider target_version for epic planning
- Update `/doh:epic-new` - Inherit version from PRD, allow override, add file_version
- Update `/doh:epic-decompose` - Inherit version context for tasks, add file_version
- Update `/doh:task-new` (or equivalent) - Inherit version from epic, add file_version
- Update all file creation commands - Automatically add current file_version (format varies by file type)
- Update all status commands to display version information
- Update progress tracking to consider version context

## Constraints & Assumptions

### Technical Constraints:
- Must integrate with existing DOH architecture without major refactoring
- Version files must be readable by both humans and scripts
- Semantic versioning compliance is mandatory
- Git integration for version history tracking

### Resource Constraints:
- Implementation should not require external dependencies
- Must work with existing DOH library structure
- Documentation updates for all affected commands required

### Timeline Constraints:
- Core versioning system: 2 weeks
- PRD integration: 1 week  
- Command updates: 2 weeks
- Documentation and testing: 1 week

## Out of Scope

### Explicitly NOT Building:
- Automated version bumping based on commit messages (future enhancement)
- Integration with external version management tools (GitHub releases, etc.)
- Rollback capabilities for deployed versions (future enhancement) 
- Multi-repository versioning coordination (future enhancement)
- Version-based access control or permissions

## Dependencies

### External Dependencies:
- Git for version history tracking
- Existing DOH library functions (frontmatter.sh, etc.)
- Semantic versioning specification compliance

### Internal Dependencies:
- Task 010: Frontmatter manipulation standardization (required for PRD updates)
- Task 011: DOH data API guide (required for consistent version data handling)
- Completion of core numbering system tasks (001-005)

## Implementation Tasks

### Epic Breakdown:

#### Epic 1: Core Version System (Target: v2.0.0)
1. **Task 1.1**: Create version file schema and storage structure
2. **Task 1.2**: Implement version management commands (new, list, current, publish, deprecate)
3. **Task 1.3**: Add semantic versioning validation and utilities
4. **Task 1.4**: Create version file templates and documentation

#### Epic 2: PRD, Epic, and Task Version Integration (Target: v1.0.0)  
1. **Task 2.1**: Update PRD frontmatter schema with version fields
2. **Task 2.2**: Update epic frontmatter schema with version fields
3. **Task 2.3**: Update task frontmatter schema with version fields
4. **Task 2.4**: Create file type detection and version format mapping
5. **Task 2.5**: Enhance `/doh:prd-new` with version planning assistance
6. **Task 2.6**: Update `/doh:prd-parse` for version-aware epic creation
7. **Task 2.7**: Update epic creation to inherit version context
8. **Task 2.8**: Update task creation to inherit version context
9. **Task 2.9**: Implement file_version automatic addition to all new files (with format detection)
10. **Task 2.10**: Create version tracking and reporting across all levels

#### Epic 3: Command & Workflow Updates (Target: v1.0.0)
1. **Task 3.1**: Update all epic/task commands to handle version context
2. **Task 3.2**: Update task workflow rules for version integration
3. **Task 3.3**: Update frontmatter manipulation to support version fields
4. **Task 3.4**: Update all file creation commands to add file_version automatically (detect file type)
5. **Task 3.5**: Create version header templates for different file types (.sh, .js, .py, etc.)
6. **Task 3.6**: Integration testing for version-aware workflows

#### Epic 4: DOH Development Project Support (Target: v1.0.0)
1. **Task 4.1**: Create `DEVELOPMENT.md` for DOH project versioning
2. **Task 4.2**: Implement development version tracking
3. **Task 4.3**: Create pre-release and development build support
4. **Task 4.4**: Document DOH development workflow with versioning

#### Epic 5: Documentation & Migration (Target: v1.0.0)
1. **Task 5.1**: Update all command documentation for version features
2. **Task 5.2**: Create comprehensive versioning guide
3. **Task 5.3**: Create `docs/versioning.md` for local DOH development versioning specifics
4. **Task 5.4**: Update `DEVELOPMENT.md` to index versioning documentation
5. **Task 5.5**: Update `CLAUDE.md` to reference `DEVELOPMENT.md`
6. **Task 5.6**: Create migration tools for existing PRDs
7. **Task 5.7**: Version system testing and validation

## Version Inheritance Flow

### Hierarchical Version Context:
1. **PRD Level**: Product manager sets target_version during PRD creation
2. **Epic Level**: Epics inherit target_version from PRD (can be overridden for cross-version epics)
3. **Task Level**: Tasks inherit target_version from epic (can be overridden for backport/hotfix tasks)
4. **Release Process**: When version is released, release_version is set at all levels that contributed

### Version Context Examples:
```
PRD: user-authentication (target_version: 1.0.0)
├── Epic: auth-backend (target_version: 1.0.0) [inherited]
│   ├── Task 001: JWT implementation (target_version: 1.0.0) [inherited]
│   └── Task 002: Password hashing (target_version: 1.0.0) [inherited]
├── Epic: auth-frontend (target_version: 1.1.0) [override - delayed]
│   └── Task 001: Login UI (target_version: 1.1.0) [inherited]
└── Epic: auth-docs (target_version: 1.0.0) [inherited]
    └── Task 001: API documentation (target_version: 0.9.0) [backport]
```

## Version Planning Assistant Logic

When creating new PRDs, the system should help users determine appropriate target_version:

### Version Suggestion Algorithm:
1. **Analyze PRD scope**: Breaking changes → major, new features → minor, fixes → patch
2. **Check current version**: Get latest version from `.doh/versions/`  
3. **Suggest next version**: Based on scope and semantic versioning rules
4. **Allow override**: User can specify different version with justification
5. **Validate choice**: Ensure version doesn't conflict with existing targets

### Example Interaction:
```
Creating PRD for 'user-authentication'...

Analyzing scope: New major feature with API changes
Current DOH version: 0.1.0
Current latest target: 1.0.0 (versioning system)
Suggested target_version: 1.0.0 (major - new feature for v1.0)

Accept suggestion? (y/n/specify): y
✓ PRD will target version 1.0.0
✓ File version set to 0.1.0 (current DOH version)
```

## Migration Strategy

### Phase 1: Core System (Week 1-2)
- Implement version storage and basic commands
- Create version file templates and validation

### Phase 2: PRD Integration (Week 3)
- Update PRD schema and creation workflow
- Migrate existing PRDs to include version fields

### Phase 3: Command Updates (Week 4-5)
- Update all affected commands and workflows
- Integration testing and bug fixes

### Phase 4: Documentation (Week 6)
- Complete documentation updates
- Create user guides and migration instructions

## Risk Mitigation

### Risk: Breaking Existing Workflows
- **Mitigation**: Implement version features as non-breaking additions
- **Fallback**: Maintain backward compatibility for 6 months

### Risk: Version Conflicts
- **Mitigation**: Implement validation and conflict detection
- **Fallback**: Manual resolution process with clear guidelines

### Risk: Adoption Resistance  
- **Mitigation**: Make version features optional initially
- **Fallback**: Gradual rollout with training and support

## Future Enhancements

### Post-v2.0.0 Considerations:
- Automated version bumping based on conventional commits
- Integration with GitHub releases and tags
- Version-based rollback and deployment controls
- Multi-project version coordination
- Advanced version analytics and reporting

---

**Next Steps**: Ready to implement this versioning system? Run `/doh:prd-parse versioning` to create the implementation epic structure.