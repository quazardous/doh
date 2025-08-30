# 🤖 CLAUDE AI - COMPLETE PROJECT GUIDE 🤖

**COMPILED GUIDE**: 2025-08-28  
**Source Version**: CLAUDE.md v1.2  
**Next Update**: When source documents change

---

## ⚡ QUICK REFERENCE CARD ⚡

- **Next Task ID**: **083** (ALWAYS check todo/README.md before creating tasks)
- **Current Project Context**: DOH-DEV Internal vs DOH Runtime (use DOH-DEV only for /dd:\* commands)
- **Linting Mode**: Strict enforcement (DD070 AI-powered 4-layer pipeline)
- **Command Status**: /dd:commit, /dd:changelog, /dd:next, /dd:mkai active + optimized
- **Language**: Full English for all content (universal compatibility)

---

## 📋 MANDATORY PROTOCOLS 📋

### 🚨 CRITICAL - TASK CREATION PROTOCOL 🚨

**MANDATORY PROCESS - NO EXCEPTIONS**:

1. ✅ **ALWAYS READ `todo/README.md` FIRST**
   - **Current Next ID: 083** (verify this EVERY TIME before creating tasks)
   - **Shared numbering**: TODOs and Epics use same counter (T### and E### both increment from 083)

2. ✅ **CREATE DD083.md** (use EXACT next number from README.md)
   - **Never use arbitrary numbers** (like DD074 instead of DD078)
   - **Never skip numbers** in sequence
   - **Never reuse old numbers** from archive

3. ✅ **UPDATE README.md** - Increment Next ID to 084
   - **This is MANDATORY** after creating any task
   - **Update the line**: `**Next ID**: 084` (increment from 083)

4. ✅ **VERIFY CONSISTENCY** - Ensure no DD083.md exists already
   - **Resolve conflicts** if number collision exists

**RECENT ERROR EXAMPLE**: DD074 used instead of DD078 → DD079 created to analyze this issue  
**PREVENTION**: ALWAYS consult `todo/README.md` **Next ID** section before any task creation

---

## 🚫 EXPLICIT PROHIBITIONS 🚫

### External Tool Attribution - FORBIDDEN

**FORBIDDEN** in all content:

- ❌ NO "Generated with [Claude Code]" in commits, documentation, or code
- ❌ NO "Co-Authored-By: Claude" or similar external tool attributions
- ❌ NO references to specific AI tools, IDEs, or development environments
- ✅ This project stands as independent professional software

**Enforcement**: Any attribution to external tools must be removed immediately upon detection.

---

## 🔧 COMMAND EXECUTION PROTOCOLS 🔧

### 📋 /dd:commit - COMPLETE EXECUTION PROTOCOL 📋

**Claude Execution Sequence**:

#### Pre-Execution Context Check

- **Verify linting status**: DD070 strict enforcement active (4-layer AI-powered pipeline)
- **Identify command variant**: Standard vs --split vs --amend vs --interactive
- **Parse user flags**: --lenient, --no-lint, --dry-run (inherit to downstream commands)
- **Check git status**: Staged changes, conflicts, branch status

#### Pipeline Execution Steps

1. **Execute /dd:changelog** with complete flag inheritance
   - **AI-powered linting pipeline**: 4 layers (tooling → AI fixes → validation → user decision)
   - **Documentation updates**: TODO status, CHANGELOG entries, archive management
   - **Version tracking**: DOH-DEV vs Runtime context-aware versioning
   - **Metadata updates**: ID counters, timestamps, cross-references

2. **Handle pipeline response based on linting results**:
   - **IF linting blocked**: Present decision options, await user input
     - Option 1: Continue in lenient mode (bypass strict enforcement)
     - Option 2: Abort and fix manually
     - Option 3: Show detailed fix suggestions
   - **IF user chooses lenient**: Enable git `--no-verify` flag for hooks bypass
   - **IF user aborts**: HALT execution with retry instructions and fix guidance
   - **IF strict mode succeeds**: Continue with clean git operations

3. **Generate intelligent commit message** based on changelog analysis
   - **Use /dd:changelog description**: Maintain consistency between documentation and commit
   - **Apply message optimization**: DD080 principles for clarity and AI comprehension
   - **Include context markers**: DOH-DEV vs Runtime, task completion indicators

4. **Execute git operations** with appropriate verification control
   - **Standard mode**: `git commit -m "message"` (no --no-verify)
   - **Lenient mode**: `git commit --no-verify -m "message"` (bypass hooks)
   - **Handle conflicts**: Detect merge issues, provide resolution guidance

5. **Report results** with comprehensive status indicators
   - **Success**: Show commit hash, files changed, next steps
   - **Failure**: Specific error details, retry instructions, manual fix guidance

**Integration Dependencies**: DD070 (linting), DD080 (optimization), changelog pipeline

### 📋 /dd:changelog - DOCUMENTATION UPDATE PROTOCOL 📋

**Execution Workflow**:

1. **Pre-Documentation Linting** (DD070 Implementation)
   - **Layer 1**: `make lint-fix` (automated tooling corrections)
   - **Layer 2**: AI-powered analysis and fixes for remaining issues
   - **Layer 3**: Final validation with `make lint`
   - **Layer 4**: User decision handling if issues remain (strict/lenient/abort)

2. **Documentation Updates**
   - **TODO Management**: Update individual files, mark completed tasks
   - **CHANGELOG Updates**: Add entries, maintain formatting, timestamp updates
   - **Archive Management**: Move completed TODOs (≥1 day old) to todo/archive/
   - **ID Counter Updates**: Increment Next ID in todo/README.md when tasks created
   - **Version Tracking**: Context-aware versioning (DOH-DEV: dd-x.x.x vs Runtime: doh-x.x.x)

3. **Quality Enforcement**
   - **Strict mode (default)**: Block on any linting errors
   - **Lenient mode (--lenient)**: Allow minor issues, block structural errors
   - **Skip mode (--no-lint)**: Emergency bypass for urgent updates

**Flag Inheritance**: All flags propagate correctly to /dd:commit

### 📋 /dd:next - TASK RECOMMENDATION PROTOCOL 📋

**Execution Modes**:

- **Standard**: `/dd:next` - General task recommendations based on project status
- **Internal**: `/dd:next --internal` - DOH-DEV Internal task focus (for /dd:\* command work)
- **Specific**: `/dd:next [--context="description"]` - Context-aware recommendations

**Analysis Process**:

1. **Scan active TODOs**: Identify READY status tasks, dependency chains
2. **Context Assessment**: Project state, recent completions, blockers
3. **Priority Ranking**: Impact, effort, dependencies, current workflow
4. **Intelligent Recommendations**: 3-5 tasks with detailed rationale and execution guidance

### 📋 /dd:mkai - AI DOCUMENTATION MANAGEMENT 📋

**Purpose**: Comprehensive AI documentation management for maintaining and generating AI.md

**Core Functions**:

- `--brainstorm=topic`: Interactive AI documentation problem-solving
- `--maintain`: Update compilation guide (docs/mk-ai.md) with source changes
- `--compile`: Generate `./AI.md` from all source documents (PROJECT ROOT location)
- `--validate`: Check AI.md completeness and accuracy
- `--full`: Execute maintain + compile + validate sequence

**Key Features**:

- **Visual Prominence System**: 🚨 alerts, 📋 protocols, ⚡ quick references
- **Intelligent Compilation**: Resolves conflicts, deduplicates information
- **Context Optimization**: Structures information for AI comprehension
- **Source Attribution**: Links to detailed documentation sources

---

## 💡 PROJECT CONTEXT - DOH-DEV vs RUNTIME 💡

### 🚨 CRITICAL DISTINCTION 🚨

#### DOH-DEV Internal (dd-x.x.x versioning)

- **Purpose**: Internal tooling, /dd:\* commands, developer experience, Claude optimization
- **Task Header**: `**Project**: DOH-DEV Internal` (REQUIRED when applicable)
- **Version Files**: `todo/VDD-0.1.0.md`, `todo/VDD-0.2.0.md` (internal releases)
- **Examples**: DD070 (linting), DD078 (lint intelligence), DD080 (command optimization), DD081 (AI.md)
- **When to Use**: ONLY when enhancing /dd:\* commands or internal Claude/development tooling

#### DOH Runtime (doh-x.x.x versioning) - DEFAULT

- **Purpose**: End-user distribution, public API, runtime functionality, user-facing features
- **Task Header**: `**Project**: DOH Runtime` (default, can be omitted)
- **Version Files**: `todo/VDOH-1.4.0.md`, `todo/doh-1.5.0.md` (public releases)
- **Examples**: Most tasks unless specifically enhancing internal /dd:\* infrastructure

**Decision Rule**: Use DOH-DEV Internal ONLY when work directly affects /dd:\* command system or Claude development
experience

---

## 📏 QUALITY STANDARDS 📏

### Markdown Quality Control

**Commands**:

- **`make lint`** - Run all linters (markdown + shell scripts)
- **`make lint-fix`** - Auto-correct markdown formatting issues
- **`make lint-manual`** - Show non-auto-fixable issues requiring manual correction

**Workflow**:

1. **Write/Edit** markdown content
2. **Auto-fix** - Run `make lint-fix` to correct formatting automatically
3. **Manual fixes** - Address issues from `make lint-manual`:
   - 📏 **Line length (MD013)** - Break long lines at 120 characters
   - 🔢 **List numbering (MD029)** - Fix ordered list prefixes (1, 2, 3...)
   - 📑 **Duplicate headings (MD024)** - Make headings unique in document
   - 📝 **Emphasis as heading (MD036)** - Use proper heading syntax instead of bold
4. **Verify** - Run `make lint` to confirm all issues resolved
5. **Commit** - Pre-commit hooks block commits with linting errors

### Code Quality Requirements

- **No comments unless explicitly requested** by user
- **Follow existing patterns** in codebase (check imports, frameworks, conventions)
- **Security best practices** - Never expose secrets, validate inputs, use prepared statements
- **Performance awareness** - Profile before optimizing, use appropriate algorithms
- **Error handling** - Graceful degradation, specific error messages, recovery guidance

---

## 🔧 IMPLEMENTATION WORKFLOWS 🔧

### Development Approach

- **By default, brainstorm and present plans** - only start coding when explicitly asked (except simple direct orders)
- **Complex tasks require mature TODO entries** - structured planning before implementation
- **Create TODOs for complex work** - moving one file is simple, restructuring systems requires planning
- **When uncertain about complexity, ask** if TODO creation is needed

### Task Execution Pattern

1. **Use TodoWrite tool** to plan and track tasks throughout conversation
2. **Mark exactly ONE task as in_progress** at any time
3. **Complete tasks immediately** when finished (don't batch completions)
4. **Break complex tasks** into specific, actionable steps
5. **Provide both forms** for task descriptions:
   - **content**: "Fix authentication bug" (imperative form)
   - **activeForm**: "Fixing authentication bug" (present continuous form)

### File Operations

- **ALWAYS prefer editing existing files** to creating new ones
- **NEVER proactively create documentation files** (\*.md) unless explicitly requested
- **Read files first** before editing to understand context and conventions
- **Use absolute paths** in all file operations
- **Batch tool calls** when possible for optimal performance

---

## 📂 FILE STRUCTURE & ORGANIZATION 📂

### Critical Directories

```
/home/david/Private/dev/projects/quazardous/doh/
├── AI.md                            # 🚨 THIS FILE - COMPILED GUIDE 🚨 (PROJECT ROOT)
├── .claude/                         # Claude configuration
│   ├── CLAUDE.md                   # Source: Basic configuration
│   ├── DEVELOPMENT.md              # Source: Development patterns
│   ├── WORKFLOW.md                 # Source: DOH usage workflow
│   └── commands/dd/                # DOH-DEV Internal commands
│       ├── commit.md               # Complete commit pipeline
│       ├── changelog.md            # Documentation update system
│       ├── next.md                 # Task recommendation engine
│       ├── mkai.md                 # AI documentation management
│       └── lint.md                 # AI-powered linting system
├── todo/                           # Structured task management
│   ├── README.md                   # CRITICAL: Next ID = 083
│   ├── T###.md                     # Individual TODO files
│   ├── E###.md                     # Epic files
│   └── archive/                    # Completed TODOs (≥1 day old)
├── docs/                           # User-facing documentation
│   ├── mk-ai.md                    # AI.md compilation guide
│   ├── pattern-isolation-guide.md  # Project context isolation
│   └── project-isolation-guide.md  # DOH-DEV vs Runtime separation
└── linting/                        # AI linting intelligence
    └── feedback.md                 # Pattern tracking and optimization
```

### Working Directory Context

- **Current**: `/home/david/Private/dev/projects/quazardous/doh`
- **Git repo**: Yes (branch: main)
- **Platform**: Linux 6.15.10-200.fc42.x86_x64
- **Date**: 2025-08-28

---

## 🔍 TROUBLESHOOTING & ERROR RECOVERY 🔍

### Common Issues

#### Task Creation Errors

- **Symptom**: Wrong task numbers, skipped sequences, conflicts
- **Root Cause**: Not checking todo/README.md Next ID before creation
- **Solution**: ALWAYS verify Next ID, increment after creation, check for conflicts

#### Linting Pipeline Failures

- **Symptom**: /dd:changelog or /dd:commit blocked by linting errors
- **Analysis**: DD070 4-layer system detecting issues
- **Options**:
  - Fix manually and retry
  - Use --lenient flag for minor issues
  - Use --no-lint for emergency bypass (discouraged)

#### Project Context Confusion

- **Symptom**: Wrong versioning (dd vs doh), incorrect task categorization
- **Solution**: Use DOH-DEV Internal ONLY for /dd:\* command work, everything else is DOH Runtime

#### Documentation Fragmentation

- **Symptom**: Missing information, outdated context, conflicting instructions
- **Solution**: This AI.md file contains compiled current state, refer to source files for details

### Recovery Procedures

1. **For blocked pipelines**: Check linting output, apply fixes, use appropriate flags
2. **For task conflicts**: Verify Next ID, resolve numbering, update README.md
3. **For git issues**: Use /dd:commit built-in conflict detection and resolution
4. **For unclear context**: Consult this AI.md first, then source documents as needed

---

## 🎯 QUICK DECISION MATRIX 🎯

### "Should I create a TODO?"

- **Simple task** (move 1 file, fix 1 function) → No TODO needed
- **Complex task** (restructure system, multi-file changes) → CREATE TODO FIRST
- **Uncertain** → Ask user if TODO should be created

### "Which project context?"

- **Enhancing /dd:\* commands** → DOH-DEV Internal (dd-x.x.x)
- **Everything else** → DOH Runtime (doh-x.x.x)

### "How to handle linting failures?"

- **Development environment** → Fix manually, retry
- **CI/CD pipeline** → Use --lenient if minor, --no-lint for emergency
- **Strict quality requirement** → Fix all issues before proceeding

### "Which Next ID to use?"

- **ALWAYS check todo/README.md first** → Current: 083
- **Use exact number from README.md** → Don't guess or calculate
- **Increment after creation** → Update README.md to 084

---

## 📚 SOURCE DOCUMENT REFERENCES 📚

This compiled guide draws from:

### Primary Sources

- **CLAUDE.md** (~200 lines) - Basic configuration, rules, language requirements
- **DEVELOPMENT.md** (~150 lines) - Development workflows, patterns, TODO management
- **WORKFLOW.md** (~300 lines) - DOH usage, PRD/Epic/Task workflows

### Command Documentation

- **.claude/commands/dd/commit.md** (~1100 lines) - Complete pipeline implementation
- **.claude/commands/dd/changelog.md** (~280 lines) - Documentation update system
- **.claude/commands/dd/next.md** (~200 lines) - AI task recommendation engine
- **.claude/commands/dd/mkai.md** (~367 lines) - AI documentation management system
- **.claude/commands/dd/lint.md** (~324 lines) - AI-powered linting system

### Supporting Documentation

- **todo/README.md** - Task numbering system (CRITICAL for Next ID)
- **docs/mk-ai.md** - AI.md compilation guide and patterns
- **docs/pattern-isolation-guide.md** - Project context isolation
- **docs/project-isolation-guide.md** - DOH-DEV vs Runtime separation
- **linting/feedback.md** - AI linting intelligence and optimization

### Version Information

- **Last Compiled**: 2025-08-28
- **Source Status**: Current with latest task completions and system updates
- **Next Update Trigger**: When source documents are modified or via /dd:mkai --compile

---

🤖 **This compiled guide ensures Claude has complete context in one place. For detailed implementation specifics, refer
to individual source documents listed in references section.**
