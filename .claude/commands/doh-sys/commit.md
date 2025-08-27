# /doh-sys:commit - DOH System Commit Pipeline

Executes the complete DOH system commit pipeline by calling `/doh-sys:changelog` for documentation updates, then
performing git operations with intelligent commit message generation.

## Usage

```bash
/doh-sys:commit [task-completion] [--version-bump] [--no-lint] [--dry-run]
```

## Parameters

- `task-completion`: (Optional) Task ID or description of completed work (e.g., "T035", "fix documentation")
  - **If omitted**: Auto-generates commit label based on git changes and asks for confirmation
- `--version-bump`: Automatically bump version if changes warrant it
- `--no-lint`: Skip linting and auto-fixes
- `--dry-run`: Show what would be done without executing

## Auto-Label Generation

When called without a task description, the command:

1. **Analyzes git changes** using `git diff --name-only` and `git status`
2. **Categorizes changes** by file patterns:
   - `docs/`, `README.md`, `*.md` → "docs: Update documentation"
   - `TODO.md` changes → "docs: Update TODO with task progress"
   - `.claude/commands/` → "feat: Add/update Claude commands"
   - `src/`, `lib/` → "feat: Update core functionality"
   - `tests/` → "test: Update test suite"
   - `package.json`, `*.config.*` → "chore: Update project configuration"
3. **Detects TODO completions** by scanning for "COMPLETED" status changes
4. **Identifies task patterns**:
   - New TODO entries → "docs: Add T### task to TODO"
   - CHANGELOG updates → "docs: Update CHANGELOG with T### completion"
   - Command additions → "feat: Add /doh-sys:### command"
   - Documentation fixes → "fix: Correct documentation issues"
5. **Generates semantic commit message** following DOH standards
6. **Prompts for confirmation** with suggested message and option to edit

### Smart Commit Examples

```bash
# Called without parameters - extracts from changelog pipeline
/doh-sys:commit

# Example extraction and suggestion:
# Detected: T040 completed, version bump to 1.4.1, 3 files modified
# Suggested: "feat: Complete T040 /doh-sys:changelog command implementation (v1.4.1)"
# Confirm commit? [Y/n/edit]:

# Called after specific changelog update
/doh-sys:changelog "T039 - Lint command with auto-fix"
/doh-sys:commit

# Extracts: "Complete T039 lint command with auto-fix capabilities"
```

**Confirmation Options**:

- `Y` or `Enter`: Accept suggested message
- `n`: Cancel operation
- `edit`: Modify the suggested message
- Custom text: Replace with your own message

## Pipeline Architecture

This command provides the complete automation by composing existing commands:

### 1. Documentation Pipeline

- **Calls `/doh-sys:changelog`**: Executes the full documentation update pipeline
  - TODO management and CHANGELOG updates
  - Version tracking and metadata
  - Quality assurance via `/doh-sys:lint` auto-fix
- **Inherits all parameters**: `--version-bump`, `--no-lint`, `--dry-run` passed through

### 2. Intelligent Git Operations

- **Extract Commit Context**: Analyzes `/doh-sys:changelog` output to extract:
  - Completed TODO IDs (e.g., "T040", "T039")
  - Version bump information (if `--version-bump` was used)
  - CHANGELOG entries added
  - Files modified during the pipeline
- **Generate Smart Commit Message**:
  - Automatically references completed TODOs: "Complete T040 pipeline command implementation"
  - Includes version bump info: "bump to v1.4.1" when applicable
  - Uses semantic commit format based on change analysis
  - Adds DOH traceability and Claude Code attribution
- **Stage & Commit**:
  - Stages all pipeline-modified files
  - Commits with intelligent message
  - Handles pre-commit hooks with retry logic

## Advanced Extraction Capabilities

The commit command intelligently extracts information from the documentation pipeline:

### TODO Completion Detection

- **Scans TODO.md changes**: Identifies tasks marked as "COMPLETED"
- **Extracts task descriptions**: Gets full task titles for commit messages
- **Detects multiple completions**: Handles batch TODO updates gracefully
- **Links to CHANGELOG entries**: Cross-references TODO and CHANGELOG updates

### Version Bump Intelligence

- **Detects version changes**: Monitors VERSION.md modifications
- **Semantic versioning context**: Understands major/minor/patch implications
- **Commit message integration**: Includes version info in commit messages
- **Compatibility tracking**: Records version compatibility information

### Change Analysis

- **File modification tracking**: Monitors all files changed by the pipeline
- **Change categorization**: Classifies changes as docs, feat, fix, etc.
- **Impact assessment**: Determines scope and importance of changes
- **Traceability preservation**: Maintains full audit trail

**Architecture**: `/doh-sys:commit` = `/doh-sys:changelog` + Intelligent Git Operations

## Auto-Fix Capabilities

The pipeline includes intelligent auto-fixes for:

- **Line Length**: Smart text wrapping preserving meaning
- **Blank Lines**: Add missing blank lines around headings/lists
- **Code Blocks**: Add language specifications
- **Emphasis Headers**: Convert to proper heading syntax
- **Trailing Spaces**: Remove or normalize
- **File Endings**: Ensure single trailing newline

## Example Usage

```bash
# Intelligent extraction and commit (most common usage)
/doh-sys:commit
# → Calls /doh-sys:changelog (if needed)
# → Extracts: "T040 - /doh-sys:changelog command completed"
# → Commits with intelligent message

# Explicit task description
/doh-sys:commit "T039 - Lint command with auto-fix"
# → Runs changelog pipeline with specific description
# → Commits with provided context

# Version bump with extraction
/doh-sys:commit --version-bump
# → Detects version changes in pipeline
# → Includes version info in commit: "feat: Complete T040 (bump to v1.4.1)"

# Dry run shows full extraction
/doh-sys:commit --dry-run
# → Shows what changelog would do + commit message preview

# Skip redundant linting
/doh-sys:commit --no-lint
# → Passes --no-lint to changelog pipeline
```

## Error Handling

- **Linting Failures**: Apply progressive auto-fixes, retry up to 2 times
- **Git Hook Failures**: Attempt additional fixes, use `--no-verify` as last resort
- **Version Conflicts**: Detect and resolve version inconsistencies
- **File Lock Issues**: Retry operations with brief delays

## Integration Points

- Uses existing DOH version management from VERSION.md
- Follows CHANGELOG.md format standards
- Integrates with existing pre-commit hooks
- Maintains TODOARCHIVED.md organization
- Respects analysis document preservation policy

## Output Format

Provides clear progress reporting:

```
🔄 DOH Pipeline: T035 Documentation Navigation
├── ✅ TODO.md updated (T035 → COMPLETED)
├── ✅ CHANGELOG.md updated (T035 entry added)
├── 🔧 Auto-fixed 3 markdown issues
├── ✅ All files linted successfully
└── ✅ Committed: docs: Complete T035 documentation navigation
```

## Priority System

Auto-fixes applied in this priority order:

1. **Critical**: Syntax errors blocking commits
2. **High**: Structure issues (headings, code blocks)
3. **Medium**: Formatting consistency (line length, spacing)
4. **Low**: Style preferences (emphasis, trailing spaces)

This command streamlines DOH development workflow while maintaining quality and consistency standards.
