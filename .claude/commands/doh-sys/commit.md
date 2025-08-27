# /doh-sys:commit - DOH System Commit Pipeline

## 🚫 EXPLICIT PROHIBITION: External Tool Attribution

**FORBIDDEN**: This command must NEVER add external tool attributions to commits:
- ❌ NO "Generated with [Tool Name]" attributions
- ❌ NO "Co-Authored-By: AI Assistant" or similar
- ✅ All commits must appear as clean, professional development work

Executes the complete DOH system commit pipeline by calling `/doh-sys:changelog` for documentation updates, then
performing git operations with intelligent commit message generation.

## Description

Fully automated DOH development workflow command that handles documentation updates, quality assurance, and git
operations in a single pipeline. Implements intelligent commit message generation based on change analysis and TODO
completion detection.

## Usage

```bash
/doh-sys:commit [task-completion] [--no-version-bump] [--no-lint] [--dry-run] [--amend] [--force]
```

## Parameters

- `task-completion`: (Optional) Task ID or description of completed work (e.g., "T035", "fix documentation")
  - **If omitted**: Auto-generates commit label based on git changes and asks for confirmation
- `--no-version-bump`: Skip automatic version bumping (version bump is default behavior)
- `--no-lint`: Skip linting and auto-fixes
- `--dry-run`: Show what would be done without executing
- `--amend`: Amend the previous commit instead of creating a new one
- `--force`: Override safety checks (⚠️ DANGEROUS - can break collaboration)

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
- **Inherits all parameters**: `--no-version-bump`, `--no-lint`, `--dry-run` passed through

### 2. Intelligent Git Operations

- **Extract Commit Context**: Analyzes `/doh-sys:changelog` output to extract:
  - Completed TODO IDs (e.g., "T040", "T039")
  - Version bump information (if `--version-bump` was used)
  - CHANGELOG entries added
  - Files modified during the pipeline
- **Generate Smart Commit Message**:
  - Automatically references completed TODOs: "Complete T040 pipeline command implementation"
  - **Version Bump Confirmation**: Prompts user before applying version changes
  - Uses semantic commit format based on change analysis
  - Adds DOH traceability for development workflow
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

- **Detects version changes**: Monitors VERSION.md modifications and analyzes change impact
- **Semantic versioning context**: Understands major/minor/patch implications
- **User Confirmation**: Prompts before applying version bumps with impact analysis
- **Commit message integration**: Includes version info in commit messages after confirmation
- **Compatibility tracking**: Records version compatibility information

### Change Analysis

- **File modification tracking**: Monitors all files changed by the pipeline
- **Change categorization**: Classifies changes as docs, feat, fix, etc.
- **Impact assessment**: Determines scope and importance of changes
- **Traceability preservation**: Maintains full audit trail

**Architecture**: `/doh-sys:commit` = `/doh-sys:changelog` + Intelligent Git Operations

## Amend Functionality

The `--amend` flag modifies the behavior to update the previous commit instead of creating a new one:

### Amend Workflow

1. **Change Detection**: Analyzes current working directory changes
2. **Documentation Pipeline**: Runs `/doh-sys:changelog` to update documentation for new changes
3. **Message Generation**: Creates new commit message based on combined changes (previous + current)
4. **Git Amend**: Uses `git commit --amend` to update the previous commit
5. **Timestamp Preservation**: Maintains original commit timestamp unless `--reset-author` is needed

### Amend Use Cases

**Perfect for**:
- **Fixing typos** in documentation after committing
- **Adding forgotten files** to the previous commit
- **Updating commit messages** with better descriptions
- **Including additional changes** that logically belong to the previous commit
- **Pre-push cleanup** to create clean commit history

**Example Scenarios**:

```bash
# Initial commit
/doh-sys:commit "T042 security analysis task"

# Realized you missed updating a file
echo "additional content" >> missed-file.md
/doh-sys:commit --amend
# → Updates previous commit to include missed-file.md

# Fix typo in previous commit's documentation
vim TODO.md  # fix typo
/doh-sys:commit --amend --no-lint
# → Amends previous commit with typo fix
```

### Amend Safety Features

- **Uncommitted Changes Check**: Ensures there are changes to amend
- **🚨 CRITICAL PUSH DETECTION**: Automatically aborts if previous commit has been pushed to remote
- **Message Preservation**: Preserves original commit structure while updating content
- **Documentation Sync**: Ensures TODO.md and CHANGELOG.md stay synchronized

### Amend Safety Enforcement

**AUTOMATIC ABORT CONDITIONS**:
- **Pushed commit detected**: `git branch -r --contains HEAD~1` shows remote tracking
- **Remote branch ahead**: Previous commit exists on `origin/main` or other remotes  
- **Collaboration risk**: Multiple contributors detected in recent commit history

**Safety Check Output**:
```bash
❌ AMEND BLOCKED: Previous commit already pushed to origin/main
   Commit: 95981a9 "feat: Add TODOARCHIVED management..."
   Risk: Amending pushed commits breaks collaboration and git history
   
   Solutions:
   1. Use regular commit: /doh-sys:commit (recommended)
   2. Create fixup commit: git commit --fixup=HEAD~1
   3. Force push WARNING: /doh-sys:commit --amend --force (dangerous!)
```

### Amend Limitations

- **🚫 NEVER amend pushed commits**: Automatically blocked to prevent collaboration issues
- **Local-only operation**: Only works with unpushed commits
- **History rewriting**: Changes commit hash, affecting git history
- **Single-user workflow**: Best for solo development or feature branches

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

# Version bump with confirmation (default behavior)
/doh-sys:commit "T042 security analysis complete"
# → Analyzes changes, detects version impact
# → Prompts: "Version bump detected: 1.4.0 → 1.4.1 (minor features added). Confirm? [Y/n]"
# → User confirms before applying version changes

# Skip version bump when not needed
/doh-sys:commit --no-version-bump
# → Skips automatic version detection and bumping
# → Focuses only on documentation and commit operations

# Dry run shows full extraction
/doh-sys:commit --dry-run
# → Shows what changelog would do + commit message preview

# Skip redundant linting
/doh-sys:commit --no-lint
# → Passes --no-lint to changelog pipeline

# Amend previous commit with new changes
/doh-sys:commit --amend
# → Runs changelog pipeline for new changes
# → Amends previous commit instead of creating new one
# → Preserves commit timestamp but updates message and content

# Combine flags for complex workflows
/doh-sys:commit "T041 cleanup" --amend --no-lint
# → Amend with specific task description, skip linting
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

## AI-Driven Optimization Detection

This command continuously learns and improves through execution pattern analysis:

### Auto-Detection Capabilities

**Commit Message Pattern Analysis**:

- **Manual edit frequency**: When auto-generated messages require frequent manual correction
- **Context extraction misses**: When TODO/CHANGELOG parsing fails to extract proper context
- **Version detection gaps**: When version bumps aren't properly detected and included

**Example Detection Scenarios**:

```bash
# After 4/5 auto-generated messages required manual editing
🔍 Optimization Detected: Commit message generation accuracy low
   Pattern: 80% of auto-messages manually edited (last 5 executions)
   Common issues: Missing T### references, version bump detection failed

   Proposed optimization: Enhanced change analysis
   - Improve TODO completion detection in CHANGELOG parsing
   - Add VERSION.md change pattern recognition
   - Better semantic commit type classification

   Update /doh-sys:commit with this optimization? [Y/n]
```

**Pipeline Execution Learning**:

- **Lint failure patterns**: When specific markdown issues consistently cause failures
- **Git hook conflicts**: When pre-commit hooks repeatedly fail on similar issues
- **File staging misses**: When important changed files aren't automatically staged

### Optimization Confirmation Workflow

1. **Execution Monitoring**: Track success rates and failure patterns across multiple runs
2. **Pattern Analysis**: Identify recurring issues that could be prevented
3. **Solution Design**: Develop specific improvements to address detected patterns
4. **User Confirmation**: Request permission with clear improvement explanation
5. **Logic Enhancement**: Update pipeline intelligence
6. **Optimization Logging**: Records optimization in `.claude/optimization/DOHSYSOPTIM.md`
7. **Immediate Application**: Apply improved logic to current execution

**Confirmation Format**:

```
🔍 Optimization Detected: [Pipeline component] needs improvement
   Pattern: [Statistical observation from recent executions]
   Impact: [What currently fails or requires manual intervention]

   Proposed optimization: [Specific enhancement]
   - [Technical improvement 1]
   - [Technical improvement 2]

   Update /doh-sys:commit pipeline with this optimization? [Y/n]

   [If confirmed, logs to DOHSYSOPTIM.md with execution statistics and improvement metrics]
```

This command streamlines DOH development workflow while maintaining quality and consistency standards, continuously
improving through intelligent pattern recognition and optimization.

## Implementation

When this command is executed by Claude:

1. **Parameter Processing**: Parse task description and flags (`--no-version-bump`, `--no-lint`, `--dry-run`, `--amend`, `--force`)
2. **Amend Mode Detection**: If `--amend` flag detected:
   - Check for uncommitted changes in working directory
   - **CRITICAL SAFETY CHECK**: Abort with error if previous commit has been pushed to remote
     - **Override with `--force`**: Skip safety check (requires explicit confirmation)
   - Analyze both current changes and previous commit context
3. **Change Analysis**: Use git commands to analyze current status and detect modification patterns
4. **Documentation Pipeline**: Execute `/doh-sys:changelog` AI logic with extracted or provided task information
5. **Version Bump Confirmation**: If version changes detected (unless `--no-version-bump`):
   - Analyze impact and determine appropriate version bump (major/minor/patch)
   - Present version change with rationale: "Version 1.4.0 → 1.4.1 (feature additions)? [Y/n]"
   - Wait for user confirmation before proceeding
6. **Quality Assurance**: Run `/doh-sys:lint` AI logic with prettier-first auto-fix (unless `--no-lint`)
7. **Commit Message Generation**: Create intelligent semantic commit message based on analysis
   - **Normal mode**: Generate new commit message
   - **Amend mode**: Update previous commit message while preserving structure
8. **Git Operations**: Stage changes and execute git command
   - **Normal mode**: `git commit` with generated message
   - **Amend mode**: `git commit --amend` with updated message
9. **Error Handling**: Progressive retry with Claude-driven auto-fixes, fallback to `--no-verify` if needed

## AI-Driven Execution

This command is executed entirely by Claude's AI logic:

- **Smart Analysis**: Claude analyzes git changes and TODO completions
- **Intelligent Fixes**: Claude applies prettier and linting fixes progressively
- **Adaptive Messaging**: Claude generates semantic commit messages based on change context
- **Error Recovery**: Claude handles pre-commit hook failures with intelligent retries

## Integration with Other Commands

- **Calls `/doh-sys:changelog`**: AI-driven documentation updates
- **Calls `/doh-sys:lint`**: AI-driven quality assurance with prettier-first approach
- **No bash scripts required**: Pure AI workflow execution
