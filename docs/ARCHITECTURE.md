# DOH Development Project Architecture

**Version**: 2.0 (Post-EDD116 Refactoring)  
**Last Updated**: 2025-08-30  
**Architecture**: Separation-by-Function

Complete architectural guide for the DOH Development project structure established by EDD116.

## Architecture Principles

### **1. Separation by Function**

Every directory has a single, clear purpose:

- **Executables** → `scripts/[category]/`
- **Configurations** → `linting/` or `config/`
- **Documentation** → `docs/`
- **References** → `contrib/`

### **2. Hot vs Cold Storage**

- **Hot** (daily use): `scripts/`, `docs/`, `linting/`
- **Cold** (reference): `contrib/`

### **3. Claude Independence**

- Project works without Claude dependencies
- `.claude/` contains only interface commands
- Standard directory structure

## Directory Structure

```text
doh-dev/                          # DOH Development Project Root
├── .claude/                      # ✅ MINIMAL - Essential Claude commands
│   └── commands/dd/              # /dd: command specifications
├── scripts/                      # ✅ ALL executables by function
│   ├── linting/                  # Linting execution + intelligence (12 scripts)
│   │   ├── lint-files.sh         # Main linting engine
│   │   ├── smart-lint.sh         # AI-powered interface
│   │   ├── analyze-patterns.sh   # Pattern recognition
│   │   ├── manager_*.sh          # Plugin managers (3 scripts)
│   │   └── lint-*.sh             # Cache management (3 scripts)
│   ├── git/                      # Git tools and hooks
│   │   ├── install-hooks.sh      # Hook installation tool
│   │   └── hooks/                # Actual git hooks
│   │       ├── pre-commit
│   │       └── pre-commit-new
│   ├── development/              # Development workflow scripts
│   │   └── setup-dev-env.sh     # Environment setup
│   ├── analysis/                 # Analysis and reporting (future)
│   ├── agents/                   # Agent orchestration (future)
│   ├── common/                   # Cross-functional utilities (future)
│   └── lib/                      # Shared libraries and modules
│       ├── lint-core.sh          # Linting core functionality
│       └── cache-lib.sh          # Cache management library
├── agents/                       # ✅ Agent ecosystem (unchanged)
│   ├── workspace/                # Agent session workspaces
│   └── templates/                # Agent prompt templates
├── analysis/                     # ✅ Task outputs and reports
├── docs/                         # ✅ ALL documentation
│   ├── ARCHITECTURE.md           # This file
│   ├── exception-handling.md     # Linting exception handling
│   └── *.md                      # All project documentation
├── todo/                         # ✅ Task management
├── linting/                      # ✅ PURE configurations only
│   ├── plugins.d/                # Plugin configurations (NO scripts)
│   │   ├── markdownlint/         # Markdownlint plugin configs
│   │   ├── codespell/            # Codespell plugin configs
│   │   └── prettier/             # Prettier plugin configs
│   └── config/                   # Base linter configurations
│       └── .markdownlint.json    # Base markdownlint config
├── .cache/                       # ✅ ALL cache and temporary data
│   ├── linting/                  # Linting performance cache
│   │   ├── error-files.txt       # Error cache
│   │   └── data/                 # Learning data
│   └── */                        # Other cache types
└── contrib/                      # 🆕 "Cold storage" - useful references
    ├── examples/scripts/         # Script examples and demos
    │   ├── cache-usage-examples.sh
    │   └── linting-exceptions.md
    ├── docs/archived/            # Archived documentation (future)
    └── tools/                    # Experimental/reference tools (future)
```

## Component Responsibilities

### **scripts/ - Executable Organization**

#### **scripts/linting/ - Linting Ecosystem**

All linting-related executables in one location:

**Core Engine**:

- `lint-files.sh` - Main linting engine (moved from dev-tools)
- `dd-lint-wrapper.sh` - /dd:lint command wrapper

**Intelligence Layer**:

- `smart-lint.sh` - AI-powered linting interface
- `analyze-patterns.sh` - Pattern recognition engine
- `integration-hook.sh` - Git integration hooks

**Plugin Management**:

- `manager_markdownlint_plugin.sh` - Markdownlint plugin manager
- `manager_prettier_plugin.sh` - Prettier plugin manager
- `manager_codespell_plugin.sh` - Codespell plugin manager

**Performance Layer**:

- `lint-scan.sh` - Error cache population
- `lint-progress.sh` - Progress reporting
- `lint-update-cache.sh` - Cache maintenance

#### **scripts/git/ - Git Integration**

Git-related scripts and hooks:

- `install-hooks.sh` - Hook installation and management tool
- `hooks/pre-commit` - Legacy pre-commit hook
- `hooks/pre-commit-new` - Enhanced pre-commit hook

#### **scripts/lib/ - Shared Libraries**

Reusable script components:

- `lint-core.sh` - Core linting functionality
- `cache-lib.sh` - Cache management library

#### **scripts/development/ - Development Tools**

Development workflow automation:

- `setup-dev-env.sh` - Environment setup script

### **linting/ - Pure Configurations**

**Strict Rule**: NO executable files, only configuration data.

#### **linting/plugins.d/ - Plugin Configurations**

Plugin-specific configurations and rules:

- `markdownlint/` - Markdownlint plugin configurations
- `codespell/` - Codespell plugin configurations
- `prettier/` - Prettier plugin configurations
- `README.md` - Plugin system documentation

#### **linting/config/ - Base Configurations**

Base linter configurations:

- `.markdownlint.json` - Base markdownlint rules

### **contrib/ - Cold Storage**

Non-critical but useful reference materials:

#### **contrib/examples/scripts/ - Script Examples**

Reference scripts and usage examples:

- `cache-usage-examples.sh` - Cache system usage examples
- `linting-exceptions.md` - Exception handling examples

## Migration History

### **EDD116 - DOH Development Architecture Refactoring**

**Phase 1** ✅ (DD113, DD114):

- Established `scripts/linting/` with core functionality
- Moved plugin managers from `linting/plugins.d/`
- Created architectural foundation

**Phase 2** ✅ (DD115, DD117):

- Complete `dev-tools/` evacuation and elimination
- Established `contrib/` cold storage
- Organized git tools in `scripts/git/`
- Comprehensive validation and path updates

**Phase 3** ✅ (Current):

- Architecture documentation creation
- System polish and optimization
- Developer experience improvements

### **Key Migrations**

```text
BEFORE EDD116                    →  AFTER EDD116
dev-tools/scripts/lint-files.sh → scripts/linting/lint-files.sh
dev-tools/hooks/install-hooks.sh → scripts/git/install-hooks.sh
dev-tools/hooks/pre-commit*      → scripts/git/hooks/pre-commit*
dev-tools/examples/*             → contrib/examples/scripts/*
dev-tools/linters/*              → linting/config/*
linting/plugins.d/manager_*.sh   → scripts/linting/manager_*.sh
dev-tools/lib/*.sh               → scripts/lib/*.sh
dev-tools/docs/*                 → docs/*
```

## Development Workflows

### **Common Operations**

#### **Linting Workflow**

```bash
# Main linting (new path)
scripts/linting/lint-files.sh README.md

# AI-enhanced linting
scripts/linting/smart-lint.sh fix README.md

# Plugin management
scripts/linting/manager_markdownlint_plugin.sh --list

# Cache management
scripts/linting/lint-scan.sh
```

#### **Git Integration**

```bash
# Install hooks (new path)
scripts/git/install-hooks.sh

# Direct hook usage
scripts/git/hooks/pre-commit-new
```

#### **Development Setup**

```bash
# Environment setup
scripts/development/setup-dev-env.sh

# Using Makefile (updated targets)
make lint          # Uses scripts/linting/lint-files.sh
make hooks-install # Uses scripts/git/install-hooks.sh
```

### **Plugin Development**

#### **Adding New Linting Scripts**

1. Place executable in appropriate `scripts/[category]/`
2. Place configurations in `linting/plugins.d/[linter]/`
3. Update documentation

#### **Creating Utility Scripts**

1. **Cross-functional**: `scripts/common/`
2. **Analysis**: `scripts/analysis/`
3. **Agent-related**: `scripts/agents/`
4. **Shared libraries**: `scripts/lib/`

### **Finding Components**

#### **By Function**

- **Need a linting script?** → `scripts/linting/`
- **Need git integration?** → `scripts/git/`
- **Need configuration?** → `linting/`
- **Need documentation?** → `docs/`
- **Need examples?** → `contrib/examples/scripts/`

#### **By Type**

- **Executable files** → `scripts/[category]/`
- **Configuration files** → `linting/` or `config/`
- **Documentation files** → `docs/`
- **Reference materials** → `contrib/`

## Benefits Achieved

### **Developer Experience**

- **Predictable structure**: Always know where to find/add components
- **Reduced cognitive load**: Clear separation of concerns
- **Faster onboarding**: Logical, intuitive organization
- **Better maintainability**: Easy to modify and extend

### **System Quality**

- **Architectural consistency**: Professional, well-organized codebase
- **Reduced complexity**: Clean separation eliminates confusion
- **Improved reliability**: Systematic organization reduces errors
- **Future-ready**: Structure supports project growth

### **Operational Benefits**

- **Claude independence**: Project works without external dependencies
- **Standard compliance**: Follows industry-standard directory patterns
- **Hot/cold separation**: Optimizes daily workflow efficiency
- **Integration friendly**: Easy to integrate with other tools

## Integration Points

### **Makefile Integration**

All Makefile targets updated to use new script locations:

```makefile
lint: scripts/linting/lint-files.sh --check
hooks-install: scripts/git/install-hooks.sh
```

### **Command Integration**

Claude commands in `.claude/commands/dd/` reference correct script paths:

- `/dd:lint` → `scripts/linting/lint-files.sh`
- `/dd:commit` → `scripts/git/hooks/pre-commit-new`

### **Cache Integration**

Cache system maintains performance with new structure:

- Scripts reference `.cache/linting/` correctly
- Performance characteristics preserved
- Cache invalidation works with new paths

## Future Extensions

### **Planned Directories**

- **scripts/analysis/** - Analysis and reporting scripts
- **scripts/agents/** - Agent orchestration scripts
- **scripts/common/** - Cross-functional utilities
- **contrib/docs/archived/** - Archived documentation
- **contrib/tools/** - Experimental tools

### **Extension Guidelines**

1. **Follow function-based organization**
2. **Maintain hot/cold separation**
3. **Keep .claude/ minimal**
4. **Document new components**
5. **Update integration points**

This architecture provides a solid foundation for continued DOH development project growth while maintaining clarity,
efficiency, and professional organization standards.
