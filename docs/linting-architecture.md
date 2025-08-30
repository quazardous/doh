# DOH Linting System Architecture

**Version**: 1.0 (Post DD113 Migration)  
**Last Updated**: 2025-08-30  
**Architecture**: 3-layer consolidated system

## Overview

The DOH linting system provides comprehensive code quality control through a 3-layer architecture that emerged from
DD113 migration consolidation. The system integrates AI-powered pattern recognition, multi-linter plugin management, and
performance optimization into a unified framework.

### Key Features

- **AI-Powered Analysis**: Automatic pattern detection and fix proposals
- **Multi-Linter Integration**: Codespell, MarkdownLint, Prettier, and extensible plugin system
- **Performance Optimization**: Intelligent caching and incremental scanning
- **Developer Integration**: Command-line tools and make targets
- **Learning System**: Continuous improvement through manual intervention tracking

## Architecture Layers

### Layer 1: Execution Engine (`scripts/linting/`)

**Purpose**: Complete linting functionality consolidated in single location

#### Core Execution Scripts

| Script               | Purpose                        | Entry Point        |
| -------------------- | ------------------------------ | ------------------ |
| `lint-files.sh`      | Main project linting engine    | Primary execution  |
| `smart-lint.sh`      | AI-powered intelligent linting | User interface     |
| `dd-lint-wrapper.sh` | Command integration wrapper    | `/dd:lint` backend |

#### AI Intelligence System

| Script                | Purpose                             | Function      |
| --------------------- | ----------------------------------- | ------------- |
| `analyze-patterns.sh` | Pattern recognition and learning    | AI analysis   |
| `plugin-proposals.sh` | Automated fix proposals (40+ ready) | AI automation |

#### Plugin Management

| Script                           | Purpose                    | Linter       |
| -------------------------------- | -------------------------- | ------------ |
| `manager_codespell_plugin.sh`    | Spell checking management  | Codespell    |
| `manager_markdownlint_plugin.sh` | Markdown quality control   | MarkdownLint |
| `manager_prettier_plugin.sh`     | Code formatting management | Prettier     |

#### Performance & Caching

| Script                 | Purpose                         | Function     |
| ---------------------- | ------------------------------- | ------------ |
| `lint-scan.sh`         | Incremental file scanning       | Performance  |
| `lint-progress.sh`     | Progress tracking and reporting | Monitoring   |
| `lint-update-cache.sh` | Cache management and updates    | Optimization |

#### Integration

| Script                | Purpose              | Function   |
| --------------------- | -------------------- | ---------- |
| `integration-hook.sh` | Git hook integration | Automation |

### Layer 2: Configuration (`linting/plugins.d/`)

**Purpose**: Plugin configurations and project-specific rules

#### Structure

```
linting/plugins.d/
├── codespell/
│   └── project-dictionary/     # Custom spell check dictionary
├── markdownlint/
│   └── md040-yaml-blocks/      # YAML code block rules
└── README.md                   # Plugin documentation
```

#### Configuration Types

- **Plugin Rules**: Linter-specific configuration files
- **Project Dictionaries**: Custom vocabularies and exceptions
- **Rule Overrides**: Project-specific rule modifications
- **Documentation**: Plugin usage and customization guides

### Layer 3: Shared Utilities (`scripts/lib/`)

**Purpose**: Reusable script functions and libraries

| Library        | Purpose                    | Used By             |
| -------------- | -------------------------- | ------------------- |
| `lint-core.sh` | Core linting functions     | Layer 1 scripts     |
| `cache-lib.sh` | Cache management utilities | Performance scripts |

## Data Flow

```
Developer Input
     ↓
[make lint] → lint-files.sh → Plugin Managers → Linters
     ↓                              ↓
Cache System ←                 Results Collection
     ↓                              ↓
Performance Data         AI Pattern Analysis
     ↓                              ↓
Progress Reports ← analyze-patterns.sh → Fix Proposals
```

## Integration Points

### Make Integration

```bash
# Primary entry point
make lint                    # Full project linting
make lint-scan              # Incremental scan
make lint-progress          # Progress reporting
```

### Command Integration

```bash
# DOH-DEV command integration
/dd:lint                    # Via dd-lint-wrapper.sh
/dd:lint --smart           # AI-powered analysis
/dd:lint --proposals       # Generate fix proposals
```

### Git Integration

```bash
# Automated hooks
.git/hooks/pre-commit      # Via integration-hook.sh
```

### Cache System

```bash
# Performance optimization
.cache/linting/            # All cache data
├── file-hashes/          # Incremental scan data
├── plugin-results/       # Linter output cache
└── pattern-learning/     # AI learning data
```

## Developer Workflows

### Adding New Linting Rules

1. **Configure Plugin**: Add rules to `linting/plugins.d/[linter]/`
2. **Test Locally**: Run `make lint` to verify behavior
3. **Update Documentation**: Document new rules in plugin README
4. **Commit Changes**: Include both config and documentation

### Modifying Existing Behavior

1. **Identify Layer**:
   - Configuration changes → `linting/plugins.d/`
   - Script behavior → `scripts/linting/`
   - Shared functions → `scripts/lib/`
2. **Make Changes**: Edit appropriate files
3. **Test Integration**: Verify with `make lint`
4. **Update Cache**: Run `scripts/linting/lint-update-cache.sh` if needed

### Debugging Linting Issues

1. **Check Logs**: Review output from `make lint`
2. **Test Individual Plugins**: Run manager scripts directly
3. **Verify Cache**: Clear `.cache/linting/` if stale
4. **Use Smart Analysis**: Run `scripts/linting/smart-lint.sh --debug`

### Extending the Plugin System

1. **Create Manager Script**: Follow pattern of existing `manager_*.sh`
2. **Add Configuration**: Create `linting/plugins.d/[new-linter]/`
3. **Integration**: Update `lint-files.sh` to call new manager
4. **Documentation**: Add to plugin README and this architecture doc

## Performance Characteristics

### Incremental Scanning

- **File Hash Tracking**: Only process changed files
- **Plugin Result Caching**: Reuse previous linter outputs
- **Smart Dependencies**: Rebuild cache on config changes

### AI Learning System

- **Pattern Recognition**: Automatic detection of recurring issues
- **Fix Proposals**: 40+ ready-to-implement automated fixes
- **Manual Intervention Tracking**: Learn from developer corrections

### Cache Efficiency

- **Layered Caching**: File, plugin, and analysis result levels
- **Intelligent Invalidation**: Smart cache clearing on relevant changes
- **Performance Monitoring**: Progress tracking and timing analysis

## Architecture Benefits

### Consolidation Success (DD113)

- **Single Location**: All linting functionality in `scripts/linting/`
- **Eliminated Duplication**: Removed scattered implementations
- **Maintained Compatibility**: Preserved existing workflows
- **Clean Separation**: Clear boundaries between layers

### Developer Experience

- **Simple Structure**: Easy to understand and navigate
- **Comprehensive Documentation**: Clear guidance for modifications
- **Flexible Integration**: Multiple entry points for different use cases
- **Performance Optimization**: Fast execution with intelligent caching

### Extensibility

- **Plugin Architecture**: Easy to add new linters
- **AI Integration**: Continuous learning and improvement
- **Configuration Flexibility**: Project-specific customization
- **Hook Integration**: Automated quality control

## Migration History

### Pre-DD113 Issues

- **Scattered Files**: Linting logic spread across multiple directories
- **Duplication**: Similar functionality in different locations
- **Complex Dependencies**: Unclear integration points
- **Maintenance Burden**: Multiple places to update for changes

### DD113 Migration Benefits

- **Centralized Logic**: All scripts in `scripts/linting/`
- **Clear Boundaries**: Configuration vs execution separation
- **Simplified Maintenance**: Single location for updates
- **Preserved Functionality**: No feature loss during consolidation

## Future Evolution

### Extension Points

- **New Plugin Addition**: Follow manager script pattern
- **AI Enhancement**: Extend pattern recognition capabilities
- **Integration Expansion**: Add more development tool hooks
- **Performance Optimization**: Enhanced caching strategies

### Architectural Stability

- **Layer Boundaries**: Well-defined responsibilities prevent coupling
- **Plugin Interface**: Standardized manager script pattern
- **Configuration System**: Flexible rule and override system
- **Documentation**: Comprehensive guidance for safe evolution

---

**This architecture provides a solid foundation for maintainable, extensible, and performant code quality control in the
DOH project.**
