# Claude Code Configuration

## Project Overview

This is the DOH (DevOps Helper) system project - a task and project management framework designed to help Claude.ai
users manage their development workflows.

**Project Language**: This project is **full English** - all code, documentation, comments, and files must be in English
for universal compatibility and distribution.

**Dependencies Philosophy**:

- **DOH System Development**: Can use any tools/dependencies (Node.js, Python, etc.) for development, testing, and
  toolchain
- **DOH Runtime Distribution**: MUST be 100% bash + jq + awk only - no other dependencies for end users

DOH provides:

- Task tracking and epic management
- Project memory and context preservation
- Intelligent initialization and setup
- French/English bilingual support for end-users
- Integration with Claude Code workflows

## Development Guidelines

- This project develops the DOH system itself (scripts, templates, schemas)
- Uses TODO.md approach for tracking development tasks (not /doh commands)
- Follow existing shell script patterns in `.claude/doh/scripts/`
- Maintain backward compatibility when updating DOH components
- Test changes against sample projects before deployment
- Security best practices for file system operations
- No comments unless explicitly requested
- **By default, brainstorm and present plans - only start coding when explicitly asked** (except for simple direct
  orders)
- **Only work on complex tasks if there's a mature TODO entry** - complex work requires proper planning and
  documentation
- **Always create a TODO for complex tasks** - moving one file is simple, restructuring directories/systems is complex
  and requires a TODO
- **When uncertain about task complexity, ask if a TODO should be created** - better to check than assume

## DOH System Structure

- `.claude/doh/scripts/` - Runtime DOH command implementations
- `./skel/` - Project skeleton templates (development)
- `./templates/` - Project templates and schemas (development)
- `./docs/` - Documentation (development)
- `./TODO.md` - Development task tracking

## Task Management

This project uses traditional TODO.md (in project root) for development tasks rather than the /doh system it provides to
other projects.

📋 **Version Management Rules**: See `TODO.md` section "TODO Management" for complete version nomenclature (Proposed
Version / Target Version / Version)

## Pending Restructuring Plan

**Proposed**: Move non-runtime DOH components outside `.claude` directory

**Current Structure:**

```text
.claude/doh/
├── scripts/     # Runtime scripts (KEEP)
├── docs/        # Documentation (MOVE OUT)
├── analysis/    # Development analysis (MOVE OUT)
├── skel/        # Project skeleton (MOVE OUT)
├── templates/   # Templates (MOVE OUT)
└── tests/       # Test files (MOVE OUT)
```

**Proposed New Structure:**

```text
/quazardous/doh/
├── docs/        # Documentation
├── analysis/    # Development analysis
├── skel/        # Project skeleton
├── templates/   # Templates
├── tests/       # Test files
└── .claude/doh/
    └── scripts/ # Runtime scripts only
```

**Benefits:**

- Cleaner separation between runtime and development components
- Easier access to docs/analysis without navigating .claude
- More conventional project layout
- Runtime scripts remain in .claude for Claude Code integration

## Markdown Quality Control

Complete markdown linting workflow for maintaining documentation quality:

### Commands

- **`make lint`** - Run all linters (markdown + shell scripts)
- **`make lint-fix`** - Auto-correct markdown formatting issues
- **`make lint-manual`** - Show non-auto-fixable issues that need manual correction

### Workflow

1. **Write/Edit markdown** - Create or modify documentation
2. **Auto-fix** - Run `make lint-fix` to correct formatting automatically
3. **Manual fixes** - Run `make lint-manual` to see issues requiring manual attention:
   - 📏 **Line length (MD013)** - Break long lines at 80 characters
   - 🔢 **List numbering (MD029)** - Fix ordered list prefixes (1, 2, 3...)
   - 📑 **Duplicate headings (MD024)** - Make headings unique in document
   - 📝 **Emphasis as heading (MD036)** - Use proper heading syntax instead of bold text
4. **Verify** - Run `make lint` to confirm all issues resolved
5. **Commit** - Pre-commit hooks automatically block commits with linting errors

### Pre-commit Protection

The pre-commit hook automatically runs markdown linting on staged files:

- ✅ **Passes** - Commit proceeds normally
- ❌ **Fails** - Commit blocked, fix issues first

### Writing Bug-Free Markdown

#### Common Issues and Solutions

##### 📏 Line Length (MD013)

- Keep lines under 120 characters (modern standard)
- Break extremely long sentences into multiple lines
- Split very long URLs or code examples when needed

##### 🔢 List Numbering (MD029)

- Each ordered list should start with `1.`
- Use `1. 2. 3.` not `4. 5. 6.` in separate sections

##### 📑 Duplicate Headings (MD024)

- Make headings unique within the document
- Add context: `### Added (v1.2.0)` instead of just `### Added`

##### 📝 Emphasis as Heading (MD036)

- Use `## Heading` instead of `**Bold text**` for headings
- Bold text should emphasize words, not create structure

##### 🏷️ Code Block Language (MD040)

- Always specify language: `` `bash` not just ``
- Use `text` for non-code content: ``` `text`
- Common languages: `bash`, `json`, `javascript`, `text`

#### Best Practices

- **Preview before commit**: Run `make lint` locally
- **Auto-fix first**: Use `make lint-fix` to catch obvious issues
- **Manual review**: Use `make lint-manual` for remaining issues
- **Short lines**: Break at natural points (commas, conjunctions)
- **Consistent structure**: Follow existing document patterns

## Status

Awaiting approval before implementation
