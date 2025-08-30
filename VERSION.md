# DOH System Version Registry

## Current Active Versions

### DOH Runtime (Public Distribution)

- **Current**: `VDOH-1.4.0` (Planning)
- **Previous**: `doh-1.3.0` (Stable)
- **Focus**: End-user task and project management system
- **Audience**: Claude users, project developers using /doh commands

### DOH-DEV Internal (Development System)

- **Current**: `VDD-0.2.0` (Planning - Linting Focus)
- **Future**: `VDD-0.3.0` (Planning - Multi-Agent Systems)
- **Previous**: `VDD-0.1.0` ✅ (Completed 2025-08-29)
- **Focus**: Internal development tooling and intelligent automation
- **Audience**: DOH system developers using /dd commands

## Dual Version Architecture

### DOH Runtime Versions (`doh-x.y.z`)

- **Purpose**: Stable end-user features and task management system
- **Tracking**: Version files in `todo/doh-*.md`
- **Commands**: `/doh:*` command suite
- **Release Cycle**: Major releases when feature sets complete
- **Documentation**: User-facing features in README.md

### DOH-DEV Internal Versions (`dd-x.y.z`)

- **Purpose**: Internal development tooling and AI collaboration systems
- **Tracking**: Version files in `todo/dd-*.md`
- **Commands**: `/dd:*` command suite for developers
- **Release Cycle**: Rapid iteration based on development needs
- **Documentation**: Internal tooling and workflows

### Version Isolation

- **Complete Separation**: DOH Runtime and DOH-DEV maintain independent versioning
- **No Cross-Contamination**: Runtime features never affect internal tooling versions
- **Clear Boundaries**: `/doh` vs `/dd` command namespaces enforce separation

## Version Status Overview

### DOH Runtime Status

| Version       | Status      | Release Date | Key Features                                   |
| ------------- | ----------- | ------------ | ---------------------------------------------- |
| **VDOH-1.4.0** | 🟡 Planning | TBD          | Analysis & Distribution system                 |
| **doh-1.3.0** | ✅ Stable   | 2025-08-27   | Infrastructure completion, worktree automation |
| **doh-1.2.0** | ✅ Archived | Previous     | Agent context protocol, memory system          |

### DOH-DEV Internal Status

| Version      | Status      | Release Date | Key Features                                              |
| ------------ | ----------- | ------------ | --------------------------------------------------------- |
| **VDD-0.3.0** | 🔮 Future   | TBD          | Multi-agent collaboration systems, benchmarked validation |
| **VDD-0.2.0** | 🟡 Planning | 2025-09-10   | Perfect linting with intelligent feedback learning        |
| **VDD-0.1.0** | ✅ Complete | 2025-08-29   | Project isolation, /dd commands, smart cache              |

## Version Planning & References

### Active Version Files

#### DOH Runtime Versions

- **Current Planning**: `todo/VDOH-1.4.0.md` - Analysis & Distribution features
- **Archived Versions**: Previous doh-\* files contain historical goals and achievements

#### DOH-DEV Internal Versions

- **Current Planning**: `todo/VDD-0.2.0.md` - Perfect linting with intelligent feedback learning
- **Future Planning**: `todo/VDD-0.3.0.md` - Multi-agent collaboration systems
- **Completed**: `todo/VDD-0.1.0.md` - Project isolation and enhanced /dd commands

### Version References

This VERSION.md file serves as a **registry only** - detailed goals, constraints, and progress tracking are maintained
in individual version files:

- **For planning**: See respective `todo/doh-*.md` or `todo/dd-*.md` files
- **For implementation**: Follow Epic structures linked in version files
- **For history**: Completed version files contain achievement records

### Cross-Version Independence

- **DOH Runtime**: User-facing features, completely independent development cycle
- **DOH-DEV Internal**: Developer tooling, can evolve rapidly without affecting runtime
- **No Dependencies**: Each system can release independently based on its own readiness

---

**Usage**: This file tracks **which versions are active** - see individual version files in `todo/` for detailed
planning, goals, and progress.
