# /doh:commit - Project Commit Pipeline

Executes the complete DOH project commit pipeline by calling `/doh:changelog` for documentation updates, then performing git operations with intelligent commit message generation. Adapts the sophisticated /doh-sys pipeline for any DOH-managed project.

## Usage

```bash
/doh:commit [task-completion] [--no-version-bump] [--no-lint] [--dry-run] [--amend]
```

## Parameters

- `task-completion`: (Optional) DOH task ID or description of completed work (e.g., "DOH-123", "implement user auth")
  - **If omitted**: Auto-generates commit label based on git changes and asks for confirmation
- `--no-version-bump`: Skip automatic version bumping (version bump is default behavior)
- `--no-lint`: Skip linting and auto-fixes (overrides project linting configuration)
- `--dry-run`: Show what would be done without executing
- `--amend`: Amend the previous commit instead of creating a new one

## Auto-Label Generation

When called without a task description, the command:

1. **Analyzes git changes** using `git diff --name-only` and `git status`
2. **Categorizes changes** by file patterns:
   - `.doh/`, `CHANGELOG.md` → "docs: Update DOH documentation"
   - `docs/`, `README.md`, `*.md` → "docs: Update project documentation"
   - `src/`, `lib/`, main code → "feat: Update core functionality"
   - `tests/` → "test: Update test suite"
   - `package.json`, config files → "chore: Update project configuration"
3. **Detects DOH completions** by scanning for "completed" status changes in .doh/tasks/
4. **Identifies task patterns**:
   - New DOH entries → "feat: Add DOH-### task implementation"
   - CHANGELOG updates → "docs: Update CHANGELOG with DOH-### completion"
   - Feature additions → "feat: Add ### functionality (DOH-###)"
   - Bug fixes → "fix: Resolve ### issue (DOH-###)"
5. **Generates semantic commit message** following project conventions
6. **Prompts for confirmation** with suggested message and option to edit

### Smart Commit Examples

```bash
# Called without parameters - extracts from changelog pipeline
/doh:commit

# Example extraction and suggestion:
# Detected: DOH-123 completed, version bump to 1.2.1, 5 files modified
# Suggested: "feat: Complete DOH-123 user authentication system (v1.2.1)"
# Confirm commit? [Y/n/edit]:

# Called after specific changelog update
/doh:changelog "DOH-123 - User authentication complete"
/doh:commit

# Extracts: "Complete DOH-123 user authentication implementation"
```

**Confirmation Options**:

- `Y` or `Enter`: Accept suggested message
- `n`: Cancel operation
- `edit`: Modify the suggested message
- Custom text: Replace with your own message

## Pipeline Architecture

This command provides complete automation by composing project-adapted commands:

### 1. Documentation Pipeline

- **Calls `/doh:changelog`**: Executes the full project documentation pipeline
  - DOH task management and CHANGELOG updates
  - Version tracking and project metadata
  - Optional quality assurance via `/doh:lint` (if enabled)
- **Inherits all parameters**: `--no-version-bump`, `--no-lint`, `--dry-run` passed through

### 2. Intelligent Git Operations

- **Extract Commit Context**: Analyzes `/doh:changelog` output to extract:
  - Completed DOH task IDs (e.g., "DOH-123", "DOH-124")
  - Version bump information (if version management is enabled)
  - CHANGELOG entries added
  - Files modified during the pipeline
- **Generate Smart Commit Message**:
  - Follows semantic commit conventions
  - Includes DOH task references for traceability
  - Adapts to project-specific commit format from .doh/config.ini
  - Uses project's commit prefix configuration

### 3. Project Configuration Integration

Respects project-specific settings from .doh/config.ini:

```ini
[pipeline]
commit_prefix = DOH                  ; DOH, TASK, FEAT, or custom
commit_format = semantic            ; semantic, conventional, simple
lint_enabled = true                 ; include linting in pipeline
auto_version_bump = true           ; enable version management

[git]
commit_template = "{prefix}-{id}: {description}"
include_version_in_commit = true    ; add version info to commit message
```

### 4. Advanced Git Operations

- **Smart Staging**: Stages documentation updates, respects .gitignore
- **Commit Generation**: Creates semantic commit messages with DOH traceability
- **Amend Support**: Updates previous commit when using --amend flag
- **Safety Checks**: Prevents commits that would break project workflow

## Example Usage

```bash
# Auto-generate commit with full pipeline
/doh:commit
# Runs /doh:changelog, then commits with extracted description

# Commit with specific task description
/doh:commit "DOH-123 - User authentication complete"

# Version tracking with confirmation (default behavior)
/doh:commit "DOH-124 - Feature complete"
# → Analyzes impact, includes version info in commit

# Check what would be committed
/doh:commit --dry-run

# Skip version bump for minor updates
/doh:commit "documentation updates" --no-version-bump

# Skip linting even if enabled in project
/doh:commit "quick fix" --no-lint

# Amend previous commit with new changes
/doh:commit --amend
```

## Integration with Project Workflow

Works seamlessly with existing project development workflow:

```bash
# Standard DOH workflow
git add .                          # Stage your code changes
/doh:commit "DOH-123 complete"     # Handles docs + commit

# With existing project linting
npm run test                       # Run project tests
/doh:commit "DOH-124 done"         # Includes DOH linting if enabled

# Complex workflow
git add src/                       # Stage only code
/doh:changelog "DOH-125"           # Update docs separately  
git add .                          # Stage doc updates
/doh:commit                        # Commit with auto-generated message
```

## Output Format

Provides comprehensive progress reporting:

```
🚀 DOH Project Commit Pipeline: DOH-123 User Authentication

📝 Documentation Phase:
├── ✅ .doh/tasks/DOH-123.json updated (marked completed)
├── ✅ CHANGELOG.md updated (DOH-123 entry added)
├── 🔄 Version analysis: 1.2.0 → 1.2.1 (feature additions)
├── ✅ Version bump applied to package.json
├── 🔧 DOH linting: 2 documentation fixes applied
└── ✅ Documentation pipeline complete

🔧 Git Operations:
├── ✅ Staged files: 6 modified, 0 new, 0 deleted
├── 💭 Generated commit message:
│   "feat: Complete DOH-123 user authentication system (v1.2.1)"
├── ✅ Commit created: a1b2c3d
└── 🎯 Ready for push to origin/main

Pipeline completed successfully!
```

## Project Adaptation Features

### Compared to /doh-sys:commit

| Feature | /doh-sys | /doh (Runtime) |
|---------|----------|----------------|
| Task Source | todo/*.md | .doh/tasks/*.json |
| Changelog | DOH CHANGELOG.md | Project CHANGELOG.md |
| Version Management | VERSION.md | package.json/project files |
| Linting | Always enabled | Optional, respects project setup |
| Commit Format | DOH system format | Project-configurable format |
| ID References | T### format | DOH-### or custom prefix |

### Smart Project Detection

- **Node.js projects**: Updates package.json version, uses npm conventions
- **Python projects**: Updates setup.py, **version**.py as appropriate
- **Generic projects**: Uses .doh/version.txt or skips version management
- **Existing linting**: Integrates with ESLint, Prettier, existing tools
- **Git hooks**: Works with pre-commit hooks and project git workflow

## Error Handling & Recovery

### Progressive Error Handling

- **Documentation errors**: Attempts fixes, continues pipeline if non-critical
- **Git conflicts**: Provides resolution suggestions, pauses for user action
- **Version conflicts**: Offers version resolution options
- **Linting failures**: Continues pipeline, reports issues for later resolution

### Recovery Options

```bash
# If commit fails partway through
/doh:commit --dry-run              # See current state
git status                         # Check staged changes
/doh:commit --amend                # Fix and amend if needed

# If documentation pipeline had issues  
/doh:changelog --dry-run           # Check what would be updated
/doh:changelog "fix"               # Update docs only
git add .                          # Stage fixes
git commit -m "fix: Documentation updates"
```

## Use Cases

### Daily Development Workflow

- **Feature completion**: Complete work, run /doh:commit, automatic docs + version + commit
- **Bug fixes**: Fix issue, /doh:commit with bug reference, proper tracking
- **Maintenance**: Update dependencies, docs automatically stay current

### Team Collaboration  

- **Consistent commits**: Team gets uniform commit messages with DOH references
- **Traceability**: Every commit links back to DOH tasks and project planning
- **Version coordination**: Automatic version bumps keep team synchronized

### Release Management

- **Feature rollup**: Multiple DOH tasks completed, version bumps track progress
- **Changelog automation**: Release notes generated from completed DOH tasks
- **Quality gates**: Optional linting ensures release-ready documentation

This command brings enterprise-grade commit automation to any DOH-managed project while respecting existing project workflows, tools, and team conventions.
