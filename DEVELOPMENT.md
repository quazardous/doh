# DOH-DEV Development Patterns Guide

**Purpose**: Development methodology and patterns for building the DOH system itself  
**Target**: Claude & developers working on DOH-DEV internals  
**Scope**: HOW we develop, not WHAT we've built

## 🎯 Development Approach Philosophy

### **Core Principle: We Develop the System, We Don't Use It**

- **DOH-DEV**: Building the DOH project management system
- **DOH Runtime**: Using the completed DOH system (not applicable to this project yet)
- **Pattern**: Bootstrap development using structured TODO system until DOH system is complete

### **Architecture Pattern: Separation-by-Function**

**Principle**: Every directory has a single, clear purpose

- **Executables** → `scripts/[category]/` (organized by function)
- **Configurations** → `linting/`, `config/` (pure configuration data)
- **Documentation** → `docs/` (centralized knowledge)
- **References** → `contrib/` (cold storage for examples)

**Why**: Predictable structure, reduced cognitive load, easy maintenance

**DOH-DEV Project Structure**:

```text
doh-dev/                          # DOH Development Project Root
├── .claude/                      # Claude interface commands (minimal)
│   └── commands/dd/              # /dd:* commands for development
├── scripts/                      # All executables by function
│   ├── linting/                  # Linting execution + intelligence
│   ├── git/                      # Git tools and hooks
│   ├── development/              # Development workflow scripts
│   └── lib/                      # Shared libraries and modules
├── todo/                         # Structured task management
│   ├── README.md                 # Next ID counter + basic workflow
│   ├── DD###.md, DOH###.md       # Individual task files
│   ├── EDD###.md, EDOH###.md     # Epic files
│   └── archive/                  # Completed tasks
├── docs/                         # Centralized documentation
│   ├── ARCHITECTURE.md           # Complete architectural guide
│   ├── QUICK-REFERENCE.md        # Daily development shortcuts
│   └── *.md                      # Specialized documentation
├── linting/                      # Pure configurations only
│   ├── plugins.d/                # Plugin configurations (NO scripts)
│   └── config/                   # Base linter configurations
├── contrib/                      # Cold storage - reference materials
│   └── examples/scripts/         # Script examples and demos
├── .cache/                       # All cache and temporary data
└── AI.md                         # Compiled guide for Claude (project root)
```

**Note**: `./README.md` and `./WORKFLOW.md` exist at project root but are **not part of DOH-DEV development workflow**:

- **./README.md**: Public-facing project introduction (for DOH runtime users)
- **./WORKFLOW.md**: DOH runtime system usage guide (for end users, not developers)
- **DOH-DEV development**: Uses this file (DEVELOPMENT.md) and todo/README.md for workflow guidance

## 📋 Task Management Patterns

### **Naming Convention System**

**Task Types by Project Context**:

- **DD###**: DOH-DEV Internal (system development, /dd:\* commands, Claude tooling)
- **DOH###**: DOH Runtime features (end-user functionality)
- **EDD###**: Development Epics, **EDOH###**: Runtime Epics
- **VDD###**: Dev versions, **VDOH###**: Runtime versions

**Decision Pattern**: Use DD/EDD/VDD only for /dd:\* command system or Claude development experience

### **Task Creation Protocol**

**Mandatory Process Pattern**:

1. **Always check** `todo/README.md` for current Next ID
2. **Use exact ID** from README.md (never arbitrary numbers)
3. **Create file** with appropriate prefix (DD### vs DOH###)
4. **Update Next ID** in README.md immediately

**Why**: Prevents numbering conflicts, maintains sequence integrity

### **File Organization Pattern**

**Individual File Approach**:

- Each task/epic gets dedicated file: `DD117.md`, `EDD116.md`
- Shared numbering sequence across all types
- Archive completed work to `todo/archive/`
- Single source of truth per task

**Benefits**: Parallel work, reduced merge conflicts, clear history

## 🔧 Development Context & Requirements

### **Project Scope Pattern**

**Development Philosophy**:

- Follow existing shell script patterns in `scripts/` directories
- Maintain backward compatibility when updating DOH components
- Test changes against sample projects before deployment
- Apply security best practices for file system operations

### **Dependencies Strategy**

**Two-Tier Approach**:

- **Development**: Use any tools needed (Node.js, Python, etc.) for building
- **Runtime Distribution**: Maintain 100% bash + jq + awk only for end users

**Why**: Developer experience vs. deployment simplicity

## 📝 Quality Control Patterns

### **Documentation Quality Pattern**

**Systematic Approach**:

- **Auto-fix first**: `make lint-fix` for automated corrections
- **Manual review**: `make lint-manual` for issues requiring human attention
- **Verification**: `make lint` to confirm resolution
- **Pre-commit protection**: Automated blocking of problematic commits

**🚨 Git Impact**: Pre-commit hooks **BLOCK commits** with markdown linting errors

- **Workflow**: Fix linting issues BEFORE attempting to commit
- **Quick fix**: `make lint-fix && make lint` before `git commit`
- **Emergency**: Use `git commit --no-verify` only if absolutely necessary

**Key Issues to Address**:

- Line length (120 characters max)
- List numbering consistency
- Heading uniqueness
- Proper code block languages

**Details**: See `docs/markdown-quality-control.md` for complete commands and troubleshooting

### **Markdown Development Pattern**

**Best Practices Approach**:

- Preview before commit
- Break lines at natural points (commas, conjunctions)
- Follow existing document structure patterns
- Maintain consistency across all documentation

## 🏗️ Architecture Development Patterns

### **Component Organization Pattern**

**Function-Based Structure**:

```text
scripts/[category]/     # All executables by function
├── linting/           # Linting execution + intelligence
├── git/              # Git tools and hooks
├── development/      # Development workflow scripts
└── lib/              # Shared libraries and modules
```

**Configuration Separation**:

```text
linting/              # Pure configurations only
├── plugins.d/        # Plugin configurations (NO scripts)
└── config/           # Base linter configurations
```

### **Development Workflow Pattern**

**Common DOH-DEV Development Cycle**:

1. **Discover work**: Use `/dd:next` to get AI-recommended next tasks based on project analysis
2. **Plan**: Create TODO with clear deliverable (if complex work)
3. **Implement**: Follow existing patterns and conventions
4. **Commit**: Use `/dd:commit` for integrated documentation + git workflow
5. **Archive**: Completed TODOs automatically moved to archive

**Key Commands**:

- **`/dd:next`**: Get intelligent task recommendations (analyzes project state, dependencies, priorities)
- **`/dd:commit`**: Complete commit workflow (runs /dd:changelog → documentation updates → git commit)
- **`/dd:changelog`**: Update documentation and task status (integrated into /dd:commit)

**Typical Development Session**:

```bash
/dd:next                    # "What should I work on next?"
# Work on recommended task
/dd:commit "Task description"   # Auto-handles docs + git commit
```

### **Documentation Boundary Pattern**

**Clear Separation**:

- **Internal Development** (this file): Can reference TODO/task numbers, internal workflows
- **User-Facing** (README.md, etc.): No internal task references, focus on usage
- **Mixed-Purpose**: Careful separation required

## 🔍 Development Decision Patterns

### **Complexity Assessment Pattern**

**When to Create TODO**:

- **Simple tasks**: Move one file, fix one function → No TODO needed unless we are in a task context
- **Complex tasks**: Restructure system, multi-file changes → CREATE TODO FIRST
- **Uncertain**: Ask user if TODO should be created

### **Project Context Decision Pattern**

**DOH-DEV vs Runtime Context**:

- **Use DD/EDD/VDD**: Only for /dd:\* commands or Claude development experience
- **Use DOH/EDOH/VDOH**: Everything else (default)
- **When uncertain**: Default to Runtime context unless clearly internal tooling

### **Documentation Update Pattern**

**Systematic Approach**:

- Update task files when status changes
- Maintain CHANGELOG.md with task mappings
- Keep version files current
- Archive completed tasks (≥1 day old)

## 🛠️ Implementation Patterns

### **Code Development Pattern**

**Guidelines**:

- **Follow existing patterns**: Check imports, frameworks, conventions before starting
- **No comments unless requested**: Self-documenting code preferred
- **Security first**: Never expose secrets, validate inputs, use prepared statements
- **Performance awareness**: Profile before optimizing

### **Integration Pattern**

**Testing Requirements**:

- All integration tests must pass before commit
- Features must be stable before runtime release
- Task must be fully implemented before marking complete
- CHANGELOG must be updated with all changes

### **Error Handling Pattern**

**Recovery Approach**:

- Graceful degradation when possible
- Specific error messages with recovery guidance
- Built-in conflict detection and resolution
- Clear documentation of failure scenarios

## 📊 Quality Metrics Patterns

### **Development Metrics**

**Success Indicators**:

- Task completion rate per session
- CHANGELOG coverage (1:1 mapping with completed tasks)
- Integration test pass rate
- Documentation coverage for user-facing features

### **Validation Patterns**

**Quality Gates**:

- All markdown linting passes cleanly
- Integration points tested thoroughly
- Documentation updated appropriately
- No broken references or dependencies

## 🔄 Maintenance Patterns

### **Regular Maintenance**

**Periodic Tasks**:

- Update compilation guides when core processes change
- Verify documentation accuracy after significant changes
- Monitor development patterns for optimization opportunities
- Maintain architectural consistency

### **Continuous Improvement**

**Evolution Pattern**:

- Track common issues and create prevention patterns
- Refine development workflows based on experience
- Update tooling and processes as project grows
- Maintain clear separation between development and runtime

---

**This guide focuses on development patterns and methodology. For specific implementation details, commands, and
configurations, see respective documentation in `docs/`, `scripts/`, and `linting/` directories.**
