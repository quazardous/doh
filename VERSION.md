# /doh System Version Management

## Current Versions

### Production (Runtime)

- **Version**: `1.3.0`
- **Codename**: Infrastructure Completion
- **Status**: Stable
- **Release Date**: 2025-08-27
- **Compatible with**: AI Assistants, Git Worktrees, Skeleton System

### Development

- **Version**: `1.4.0-dev`
- **Status**: Planning
- **Target Release**: Runtime 1.4.0
- **Focus**: Analysis & Distribution

## Version Strategy

### Runtime Versions (inclaude.md)

- **Purpose**: Stable features ready for end-user consumption
- **Audience**: Claude, project developers using /doh
- **Update frequency**: When features are stable and tested
- **Semantic versioning**: MAJOR.MINOR.PATCH

### Development Versions (./TODO.md)

- **Purpose**: Development roadmap and work in progress
- **Audience**: /doh system developers
- **Update frequency**: Continuous during development
- **Format**: `X.Y.Z-dev` where X.Y.Z is target runtime version

## Feature Stability Matrix

| Feature                     | Runtime 1.3.0 | Dev 1.4.0 | Status           |
| --------------------------- | ------------- | --------- | ---------------- |
| Agent Context Protocol      | ✅ Stable     | ✅ Stable | Production Ready |
| Worktree Automation         | ✅ Stable     | ✅ Stable | Production Ready |
| Memory Updates Protocol     | ✅ Stable     | ✅ Stable | Production Ready |
| DOH Skeleton Implementation | ✅ Stable     | ✅ Stable | Production Ready |
| File System Validation      | ✅ Stable     | ✅ Stable | Production Ready |
| Memory Structure            | ✅ Stable     | ✅ Stable | Production Ready |
| Centralized Dependencies    | ✅ Stable     | ✅ Stable | Production Ready |

## Release Process

### Runtime Release Criteria

- [ ] All features tested and stable
- [ ] Documentation updated (inclaude.md)
- [ ] Integration tests passing
- [ ] No breaking changes without migration path

### Development Updates

- [ ] Feature implementation tracked in ./TODO.md
- [ ] Version bumped when major milestones reached
- [ ] Clear mapping from dev features to runtime releases

## Version History

### Runtime 1.2.0 (2025-08-27)

- Agent Context Protocol with complete JSON bundles
- Automated worktree creation and management
- Memory enrichment system for agents
- Integration testing framework
- Runtime documentation (inclaude.md)

### Runtime 1.1.0 (Previous)

- Dual ID System (!123 → #456)
- Index.json unified structure
- GitHub/GitLab sync specifications
- MD headers with URLs

### Runtime 1.0.0 (Previous)

- 2-Agent architecture consolidation
- Basic DOH command structure
- Epic #0 system foundation

## Upgrade Path

### From 1.1.0 → 1.2.0

- Agents gain full context awareness
- Worktree automation available
- Memory system operational
- No breaking changes to existing workflows

### From 1.2.0 → 1.3.0 (Planned)

- Enhanced file system validation
- Complete memory structure
- Centralized dependency management
- Backwards compatible
