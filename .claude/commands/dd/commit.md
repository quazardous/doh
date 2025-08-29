# /dd:commit - DOH System Commit Pipeline

## 🚫 EXPLICIT PROHIBITION: External Tool Attribution

**FORBIDDEN**: This command must NEVER add external tool attributions to commits:
- ❌ NO "Generated with [Tool Name]" attributions
- ❌ NO "Co-Authored-By: AI Assistant" or similar
- ✅ All commits must appear as clean, professional development work

Executes the complete DOH system commit pipeline by calling `/dd:changelog` for documentation updates, then
performing git operations with intelligent commit message generation.

## Description

Complete DOH development workflow command that orchestrates documentation updates, quality assurance, and git
operations in a sequential pipeline. Uses intelligent commit message generation based on change analysis and TODO
completion detection.

## Claude AI Execution Protocol (Enhanced T085 2-Pass Algorithm)

**Primary Workflow Steps**:
1. **Parse parameters and detect mode** - Analyze flags (--split, --staged, --staged-only, shortcuts)
2. **Analyze staging area state** - Determine staged vs unstaged files (preserve developer intent)
3. **IF --split mode detected**: Execute 2-pass iterative splitting workflow:
   - **Pass 1 - Staged Files Processing**: 
     * `while(stagedFiles.length > 0) { group → commit → repeat }`
     * Smart extensions: Add related unstaged files to complete logical groups
     * Respect original staging intention throughout
   - **Pass 2 - Unstaged Files Processing** (unless --staged or --staged-only):
     * `while(unstagedFiles.length > 0) { group → commit → repeat }`
     * Semantic grouping: Epic/TODO → System → Docs → Implementation → Config
     * Clean remaining modifications iteratively
   - **Mode handling**:
     * **DEFAULT**: Both Pass 1 + Pass 2 (complete processing)
     * **--staged**: Pass 1 only (respect staging intent, leave unstaged)
     * **--staged-only**: Pass 1 without extensions (conservative)
   - **Interactive controls**: 
     * **IF --interactive**: Present each commit for approval per pass
     * **IF --dry-run**: Display 2-pass plan without executing
4. **IF single commit mode**: Call `/dd:changelog` with inherited parameters
6. **Execute git operations**: Create commits using configured parameters
7. **Validate clean state**: Ensure working directory is clean (except for --staged-only mode)
8. **Report completion**: Provide commit hashes, staging decisions, and working directory status

## Usage

```bash
/dd:commit [task-completion] [--no-version-bump] [--dry-run] [--amend] [--force] [--split] [--interactive] [--staged] [--staged-only]
```

## Parameters

### Primary Parameters
- `task-completion`: (Optional) Task ID or description of completed work
  - **Examples**: `"T035"`, `"fix documentation"`, `"implement user auth"`
  - **If omitted**: Auto-generates commit label based on git changes and asks for confirmation
  - **Smart detection**: Analyzes file changes to suggest appropriate descriptions

### Control Flags
- `--dry-run`: Preview what would be done without executing any changes
  - **Use when**: Want to verify changes before committing
  - **Safe**: No modifications to git history or files
  - **Output**: Shows planned commits, version changes, and documentation updates

- `--no-version-bump`: Skip automatic version bumping 
  - **Default**: Version bump enabled with user confirmation
  - **Use when**: Minor changes that don't warrant version increment
  - **Note**: Version analysis still runs, just skips the actual bump


### Advanced Git Operations  
- `--amend`: Amend the previous commit instead of creating a new one
  - **Use when**: Adding forgotten changes to recent commit
  - **⚠️ Warning**: Don't amend pushed commits (breaks collaboration)
  - **Combines with**: --no-version-bump (usually don't bump version for amendments)

- `--force`: Override safety checks and confirmations
  - **⚠️ DANGEROUS**: Can break collaboration if used incorrectly
  - **Use when**: Automated scripts or when you're absolutely certain
  - **Bypasses**: All interactive confirmations and safety validations

### Semantic Splitting System (Enhanced with T085 2-Pass Algorithm)
- `--split` or `-s`: Intelligently split changes using 2-pass iterative algorithm
  - **Algorithm**: Respects developer staging intent with iterative processing
  - **Pass 1**: Process staged files with smart extensions (developer intent first)
  - **Pass 2**: Process remaining unstaged files iteratively  
  - **Use when**: Multiple logical units of work need separate commits

#### 2-Pass Staging Algorithm (T085 Implementation)

- **Default Mode**: "Complete 2-Pass Processing" (Recommended)
  ```bash
  /dd:commit --split "T085 implementation"
  # Pass 1: while(stagedFiles) { group → commit → repeat }
  # Pass 2: while(unstagedFiles) { group → commit → repeat }  
  # Result: Clean directory + respected developer intent
  ```

- `--staged`: "Pass 1 Only" (Respects Staging Intent)
  ```bash
  /dd:commit --split --staged "staged work only"
  # Pass 1: Process staged files with smart extensions
  # No Pass 2: Stop after staged files processed
  # Result: Staged intent honored, unstaged files remain
  ```

- `--staged-only`: "Pass 1 Without Extensions" (Conservative)
  ```bash
  /dd:commit --split --staged-only "strict staged only"
  # Pass 1: Process ONLY staged files, no smart extensions  
  # No Pass 2: Ignore unstaged files completely
  # Result: Most conservative staged-only processing
  ```

#### Interactive and Preview Controls

- `--interactive` or `-i`: Review and confirm each commit in the split sequence
  - **Compatible with**: All staging modes (default, --staged-focused, --staged-only)
  - **Process**: Shows each planned commit with files and message for approval
  - **Control**: Edit messages, skip commits, abort sequence, or modify file groups
  - **Enhanced**: Shows staging decisions and file relationship explanations

- `--dry-run`: Preview the complete split plan without creating commits
  - **Shows**: Staging decisions, semantic grouping, commit messages, file relationships
  - **Safe**: No modifications to git history, staging area, or files
  - **Enhanced**: Displays staging mode effects and smart extension decisions

#### Convenience Shortcuts (T085 2-Pass Integration)

- `-si`: Shortcut for `--split --interactive` (most common pattern)
- `-ss`: Shortcut for `--split --staged` (Pass 1 only, respects staging intent)  
- `-so`: Shortcut for `--split --staged-only` (conservative staged-only)
- `-sd`: Shortcut for `--split --dry-run` (safe preview)

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
/dd:commit

# Example extraction and suggestion:
# Detected: T040 completed, version bump to 1.4.1, 3 files modified
# Suggested: "feat: Complete T040 /dd:changelog command implementation (v1.4.1)"
# Confirm commit? [Y/n/edit]:

# Called after specific changelog update
/dd:changelog "T039 - Lint command with auto-fix"
/dd:commit

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

- **Calls `/dd:changelog`**: Executes the full documentation update pipeline with strict linting enforcement
  - AI-powered linting pipeline (multi-layer fix system)
  - TODO management and CHANGELOG updates
  - Version tracking and metadata
  - Pattern learning and configuration optimization
- **Parameter Inheritance Matrix**:

| Input Flag | Action | Pass to /dd:changelog | Git Operation Effect |
|-----------|--------|----------------------|---------------------|
| --no-version-bump | ✅ Pass through | ✅ Skip version analysis | No version changes |
| --force | ❌ Handle locally | ❌ Not applicable | git commit --no-verify |
| --dry-run | ✅ Pass through | ✅ Preview mode only | No git operations |
| --amend | ❌ Handle locally | ❌ Not applicable | git commit --amend |
| --split | ❌ Handle locally | ❌ Not applicable | Multiple git commits |
- **Quality Gate**: Pipeline blocked in `/dd:changelog` if linting fails (strict mode)

### 2. Intelligent Git Operations

- **Extract Commit Context**: Analyzes `/dd:changelog` output to extract:
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

**Architecture**: `/dd:commit` = `/dd:changelog` + Intelligent Git Operations

## Semantic Commit Splitting (--split)

The `--split` flag enables intelligent analysis of large staging areas and automatically creates multiple focused commits following a priority-based strategy.

### Split Strategy: Epic/TODO Updates First

The splitting algorithm follows a semantic priority order designed to separate planning work from implementation:

#### **Phase 1: Epic & TODO Updates** (Highest Priority)
- Files: `todo/*.md`, `todo/NEXT.md`, epic documentation
- Purpose: Isolate project management and planning changes
- Example: `"feat: Complete T059 AI Task Engine and update project roadmap"`

#### **Phase 2: DOH System Infrastructure**
- Files: `.claude/doh/*`, `.claude/commands/*`, system templates
- Purpose: Separate framework/tooling changes from project work
- Example: `"feat: Enhance DOH runtime with AI task intelligence system"`

#### **Phase 3: Project Documentation**  
- Files: `README.md`, `WORKFLOW.md`, `DEVELOPMENT.md`, `docs/*`
- Purpose: Group user-facing documentation updates
- Example: `"docs: Update DOH runtime documentation with task intelligence"`

#### **Phase 4: Core Implementation**
- Files: `src/*`, `lib/*`, main application code
- Purpose: Focus implementation changes separately from planning
- Example: `"feat: Implement user authentication with JWT tokens"`

#### **Phase 5: Configuration & Support**
- Files: `package.json`, config files, build scripts, tests
- Purpose: Group supporting infrastructure changes
- Example: `"chore: Update project configuration and test setup"`

### Split Analysis Engine

The command performs intelligent semantic analysis of staged changes:

#### **File Pattern Recognition**
```bash
# Epic/TODO priority detection
epic_files=$(git diff --cached --name-only | grep -E "todo/.*\.md|NEXT\.md")
doh_system_files=$(git diff --cached --name-only | grep -E "\.claude/doh/|\.claude/commands/")
docs_files=$(git diff --cached --name-only | grep -E "README\.md|WORKFLOW\.md|DEVELOPMENT\.md|docs/")
```

#### **Content Analysis**
- **Task Completion Detection**: Scans for TODO status changes to `COMPLETED`
- **Feature Implementation**: Identifies new functionality additions
- **Documentation Focus**: Analyzes doc changes for commit context
- **Dependency Updates**: Detects related file modifications

#### **Smart Message Generation**
Each split commit gets contextually generated messages:
- **Epic commits**: `"feat: Complete T### {task_title} and update project roadmap"`
- **System commits**: `"feat: Enhance DOH {component} with {improvement}"`
- **Documentation**: `"docs: Update {doc_type} with {focus_area}"`
- **Implementation**: `"feat: Implement {feature_name} for {purpose}"`

### Split Usage Examples

#### **Automatic Splitting**
```bash
# Analyze staging and create semantic commit sequence
/dd:commit --split

# Example output:
🔍 Analysis: 12 files staged across 4 semantic categories

📋 Proposed Commit Sequence:
Commit 1: "feat: Complete T059 AI Task Engine and update project roadmap"
  Files: todo/T059.md, todo/NEXT.md (3 files)
  
Commit 2: "feat: Enhance DOH runtime with task intelligence system" 
  Files: .claude/commands/doh/next.md, .claude/doh/templates/ (4 files)
  
Commit 3: "docs: Update DOH runtime documentation"
  Files: .claude/doh/inclaude.md (1 file)

Execute this 3-commit sequence? [Y/n/preview]
```

#### **Interactive Review**
```bash
# Review and confirm each individual commit
/dd:commit --split --interactive

# Example flow:
Commit 1/3: "feat: Complete T059 AI Task Engine and update project roadmap"
Files: todo/T059.md, todo/NEXT.md, todo/T061.md
Execute this commit? [Y/n/edit/skip]
> Y
✅ Commit 1 complete

Commit 2/3: "feat: Enhance DOH runtime with task intelligence"
Files: .claude/commands/doh/next.md, templates/memory_structure.md
Execute this commit? [Y/n/edit/skip]
> edit
Enter commit message: feat: Add /doh:next AI-powered task recommendations
✅ Commit 2 complete (edited)

Commit 3/3: "docs: Update runtime documentation"
Files: .claude/doh/inclaude.md  
Execute this commit? [Y/n/edit/skip]
> Y
✅ Commit 3 complete

Split sequence complete! Created 3 focused commits.
```

#### **Preview Mode**
```bash
# Show split plan without executing
/dd:commit --split --dry-run

# Shows complete analysis, file groupings, and proposed messages
# No commits created - perfect for validation
```

### Split Benefits

- **Cleaner History**: Each commit focuses on single logical unit of work
- **Epic Separation**: Planning/management work isolated from implementation
- **Better Traceability**: Easier to understand project evolution
- **Code Review**: Reviewers can focus on specific aspects in each commit
- **Rollback Granularity**: Can revert specific changes without affecting others

### Split Safety Features

- **Non-Destructive**: Original staging preserved if split is cancelled
- **Preview Available**: `--dry-run` shows plan without execution
- **Interactive Override**: `--interactive` allows message editing and commit skipping
- **Rollback Capability**: Can undo split commits if something goes wrong
- **Dependency Aware**: Ensures related changes stay together when logically connected

### Split Integration

- **Works with existing flags**: Combines with `--no-version-bump`, `--force`, etc.
- **Changelog integration**: Each commit can trigger documentation updates
- **Quality assurance**: Linting applied to each commit individually
- **Version management**: Smart version bumping across commit sequence

## Amend Functionality

The `--amend` flag modifies the behavior to update the previous commit instead of creating a new one:

### Amend Workflow

1. **Change Detection**: Analyzes current working directory changes
2. **Documentation Pipeline**: Runs `/dd:changelog` to update documentation for new changes
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
/dd:commit "T042 security analysis task"

# Realized you missed updating a file
echo "additional content" >> missed-file.md
/dd:commit --amend
# → Updates previous commit to include missed-file.md

# Fix typo in previous commit's documentation
vim TODO.md  # fix typo
/dd:commit --amend --force
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
   1. Use regular commit: /dd:commit (recommended)
   2. Create fixup commit: git commit --fixup=HEAD~1
   3. Force push WARNING: /dd:commit --amend --force (dangerous!)
```

### Amend Limitations

- **🚫 NEVER amend pushed commits**: Automatically blocked to prevent collaboration issues
- **Local-only operation**: Only works with unpushed commits
- **History rewriting**: Changes commit hash, affecting git history
- **Single-user workflow**: Best for solo development or feature branches

## Linting Enforcement (T087 Simplified Architecture)

The command enforces documentation quality through git pre-commit hooks with strict enforcement.

### 🚨 STRICT RULE: NO COMMIT IF LINTING FAILS

**NEVER COMMIT IF LINTING FAILS** - unless `--force` is explicitly passed by the developer.

### **Simple Architecture**

```
/dd:commit → /dd:changelog (NO linting) → git commit (WITH pre-commit hooks)
                                               ↓
                                        [SINGLE ENFORCEMENT POINT]  
                                               ↓
                                      Pass → Commit succeeds
                                      Fail → Commit blocked (period)
```

### **Only 2 Modes**

1. **Default**: `git commit` (respects pre-commit hooks, blocks on failure)
2. **Force**: `git commit --no-verify` (when `--force` flag passed explicitly)

### **Enforcement Logic**

```bash
# Default behavior - STRICT ENFORCEMENT
if linting_passes; then
    git commit -m "message"
    # → SUCCESS
else
    echo "❌ LINTING FAILED - COMMIT BLOCKED"
    echo "Fix issues or use --force to override"
    exit 1
fi

# Force override - EXPLICIT DEVELOPER CHOICE
if --force_flag_passed; then
    git commit --no-verify -m "message"  
    echo "⚠️  LINTING BYPASSED with --force"
    # → SUCCESS (but with clear warning)
fi
```

### **Usage Examples**

```bash
# Standard commit (linting enforced)
/dd:commit "T087 implementation"
# → Documentation updates → git commit → SUCCESS or BLOCKED

# Force override (bypasses linting)
/dd:commit "T087 implementation" --force
# → Documentation updates → git commit --no-verify → SUCCESS

# Split mode (each commit enforced)
/dd:commit --split "T087 implementation"
# → Pass 1: git commit → linting enforced → success or block
# → Pass 2: git commit → linting enforced → success or block
```

### **Clean User Experience**

**✅ Success Path**:
```bash
/dd:commit "T087 fix"
# → ✅ Documentation updated
# → ✅ Commit successful (linting passed)
```

**❌ Failure Path**:
```bash
/dd:commit "T087 fix" 
# → ✅ Documentation updated
# → ❌ LINTING FAILED - COMMIT BLOCKED
# → Fix issues or use --force to override

# Developer fixes issues
make lint-fix
/dd:commit "T087 fix"
# → ✅ Success

# OR developer forces override  
/dd:commit "T087 fix" --force
# → ⚠️  LINTING BYPASSED with --force
# → ✅ Success (with warning)
```

### **Flag Behavior**

| Flag | Git Command | Linting | Description |
|------|-------------|---------|-------------|
| *(none)* | `git commit` | ✅ Enforced | Default strict behavior |
| `--force` | `git commit --no-verify` | ❌ Bypassed | Explicit override |  
| `--dry-run` | *(no git)* | ❌ Skipped | Preview only |

### **Removed Complexity**

**❌ No More**:
- Complex decision trees with 4 options
- AI-powered linting pipeline in `/dd:changelog`
- Pattern learning and feedback systems  
- Interactive prompts about linting failures
- Complex decision trees and bypass modes
- Dual linting systems causing coordination issues

**✅ Benefits**:
- **Predictable**: Linting fails → commit blocked (always)
- **Simple**: Two modes only (strict or force)
- **Fast**: No AI processing or complex decision trees
- **Clear**: Obvious failure messages and solutions

## Error Handling

- **Split Failures**: Automatic rollback to original staging state if any commit fails
- **Linting Failures**: Commit blocked, user must fix issues or use `--force` 
- **Git Hook Failures**: Clear error messages with actionable solutions
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

**Standard Single Commit:**
```
🔄 DOH Pipeline: T035 Documentation Navigation
├── ✅ TODO.md updated (T035 → COMPLETED)
├── ✅ CHANGELOG.md updated (T035 entry added)
├── 🔧 Auto-fixed 3 markdown issues
├── ✅ All files linted successfully
└── ✅ Committed: docs: Complete T035 documentation navigation
```

**Split Mode Output:**
```
🔍 Semantic Commit Split Analysis
├── 📊 15 files staged across 4 categories
├── 🎯 Epic/TODO priority: 3 files (todo/T064.md, todo/NEXT.md)
├── 🔧 DOH system files: 2 files (.claude/commands/doh-sys/commit.md)
├── 📖 Documentation files: 1 file (.claude/doh/inclaude.md)
└── ⚙️  Configuration files: 1 file (package.json)

🚀 Executing Split Sequence:
├── ✅ Commit 1/3: feat: Complete T064 commit splitting and update roadmap
│   └── Files: todo/T064.md, todo/NEXT.md (3 files)
├── ✅ Commit 2/3: feat: Enhance DOH commit pipeline with semantic splitting  
│   └── Files: .claude/commands/doh-sys/commit.md (2 files)
└── ✅ Commit 3/3: docs: Update DOH documentation with split functionality
    └── Files: .claude/doh/inclaude.md (1 file)

🎉 Split complete! Created 3 focused commits in 2.4s
```

**Interactive Split Output:**
```
🔍 Proposed Split: 3 commits from 7 staged files

Commit 1/3: "feat: Complete T064 commit splitting enhancement"
Files: todo/T064.md, todo/NEXT.md
Execute this commit? [Y/n/edit/skip] > Y
✅ Commit 1 complete: a1b2c3d

Commit 2/3: "feat: Enhance /dd:commit with --split functionality" 
Files: .claude/commands/doh-sys/commit.md
Execute this commit? [Y/n/edit/skip] > edit
Enter commit message: feat: Add intelligent semantic commit splitting to pipeline
✅ Commit 2 complete (edited): d4e5f6g

Commit 3/3: "docs: Update command documentation"
Files: .claude/doh/inclaude.md
Execute this commit? [Y/n/edit/skip] > Y  
✅ Commit 3 complete: h7i8j9k

🎉 Interactive split complete! 3 commits created successfully.
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

   Update /dd:commit with this optimization? [Y/n]
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

   Update /dd:commit pipeline with this optimization? [Y/n]

   [If confirmed, logs to DOHSYSOPTIM.md with execution statistics and improvement metrics]
```

This command streamlines DOH development workflow while maintaining quality and consistency standards, continuously
improving through intelligent pattern recognition and optimization.

## Enhanced Staging Management (T083/T084 Integration)

### Staging Modes: "Clean Working Directory" Philosophy

The command now follows a "Clean Working Directory" principle by default - leaving users with completely clean working directories after commits. Three distinct modes provide flexibility:

#### **Default Mode: "Clean Working Directory"**
```bash
/dd:commit "T084 fix"
/dd:commit --split "T084 complete"

# Behavior:
# 1. Auto-stage ALL modified/deleted files (git add -A)
# 2. Process everything in appropriate commits
# 3. Result: Completely clean working directory
# 4. Only untracked files remain (by design)
```

**Auto-Staging Strategy**:
- **Comprehensive staging**: Automatically stages all modified and deleted files
- **Semantic processing**: All changes processed through split algorithm
- **Clean result**: Working directory becomes completely clean
- **Predictable behavior**: Users know everything will be committed

#### **--staged-focused Mode: "Priority + Smart Extension"**
```bash
/dd:commit --split --staged-focused "T084 complete"

# Behavior:
# 1. Primary focus: Process staged files as main semantic groups
# 2. Smart extension: Auto-detect obviously related unstaged files
# 3. Secondary commits: Group remaining modifications semantically
# 4. Complete processing: Still commits everything, maintains clean directory
```

**Smart Extension Algorithm**:
- **Related file detection**: Identifies unstaged files related to staged work
- **Semantic relationships**: Test files, documentation, configuration dependencies
- **Priority treatment**: Staged files get primary commit positions
- **Complete cleanup**: All modifications still get committed

**Extension Examples**:
```bash
# Smart extension scenarios:

# Scenario 1: Test files
# Staged: src/commit.js
# Unstaged: tests/commit.test.js
# → Extension: Include test file in same commit

# Scenario 2: Documentation
# Staged: .claude/commands/dd/commit.md
# Unstaged: README.md (mentions commit command)
# → Extension: Include related documentation

# Scenario 3: Configuration
# Staged: package.json (new dependency)
# Unstaged: src/config.js (uses new dependency)
# → Extension: Include configuration that uses dependency
```

#### **--staged-only Mode: "Explicit Partial Commits"** (New)
```bash
/dd:commit --split --staged-only "T084 partial"

# Behavior:
# 1. ONLY process currently staged files
# 2. Ignore all unstaged modifications
# 3. Partial result: Working directory may remain "dirty"
# 4. Advanced use case: For users who explicitly want partial commits
```

**Explicit Partial Processing**:
- **Limited scope**: Only processes currently staged files
- **No auto-staging**: Completely ignores unstaged modifications
- **Advanced control**: For power users needing partial commits
- **Clear intent**: Explicitly leaves working directory in current state

### Convenience Shortcuts (T083 Consolidation)

Enhanced shortcuts combine common flag combinations for streamlined workflow:

#### **Split Shortcuts**
```bash
# Quick interactive splitting (most common pattern)
/dd:commit -si "T083 complete"    # --split --interactive

# Staged-focused splitting (common for messy workspaces)
/dd:commit -sf "T083 complete"    # --split --staged-focused

# Staged-only splitting (explicit partial commits)
/dd:commit -so "T083 partial"    # --split --staged-only

# Preview splitting (safe exploration)
/dd:commit -sd "T083 preview"    # --split --dry-run
```

#### **Combined Shortcuts**
```bash
# Interactive staged-focused (full control + priority)
/dd:commit -sif "T083 complete"  # --split --interactive --staged-focused

# Staged-only with preview (partial commit validation)
/dd:commit -sod "T083 partial"   # --split --staged-only --dry-run
```

### Mode Comparison Matrix (T085 2-Pass Algorithm)

| Mode | Pass 1 (Staged Files) | Pass 2 (Unstaged Files) | Smart Extensions | Result |
|------|----------------------|-------------------------|------------------|---------|
| **Default** | ✅ Process with extensions | ✅ Process remaining iteratively | ✅ Related files added to groups | Clean directory |
| **--staged** | ✅ Process with extensions | ❌ Skip Pass 2 | ✅ Related files added to staged groups | Unstaged remain |
| **--staged-only** | ✅ Process without extensions | ❌ Skip Pass 2 | ❌ No extensions | Unstaged remain |

### User Experience Improvements

#### **Before T085 (Sub-Optimal)**
```bash
# Old T084 approach was flawed:
/dd:commit --split "T084"
# 1. git add -A  # ❌ Destroys developer staging intent
# 2. Complex staging/unstaging juggling to create groups
# 3. Sub-optimal performance with mass operations

# Lost developer intent:
git add important-feature.js tests/important-feature.test.js  # Developer's choice
/dd:commit --split --staged-focused "feature work"
# → git add -A first, then try to "undo" and regroup
# → Original staging intention lost
```

#### **After T085 (Intelligent 2-Pass)**
```bash
# Respects developer intent with 2-pass algorithm:
git add important-feature.js tests/important-feature.test.js  # Developer's choice
/dd:commit --split "feature work"

# Pass 1: Honor staged files first
# → Processes important-feature.js + tests/important-feature.test.js
# → May add related unstaged files (smart extensions)
# → Commit focused groups iteratively

# Pass 2: Clean remaining unstaged files  
# → Processes remaining docs, config, etc.
# → Groups semantically and commits iteratively
# → Result: Clean directory + respected intent
```

### Smart Auto-Detection and Suggestions

#### **Auto-Split Detection**
```bash
# When /dd:commit detects split-worthy staging:
/dd:commit "mixed changes"

🔍 Smart Detection: Staging area contains 4+ semantic groups
📋 Epic/TODO files: 3 files
🔧 System files: 2 files
📖 Documentation: 1 file
⚙️  Configuration: 2 files

💡 Suggestion: Use --split for cleaner commit history
   - Create focused commits per semantic group
   - Better code review and history tracking
   - Easier rollback granularity

   Quick options:
   /dd:commit -si    # Interactive splitting with review
   /dd:commit -sf    # Staged-focused priority splitting
   /dd:commit -sd    # Preview split plan first

Apply splitting? [Y/n/preview]:
```

#### **Staging Mode Recommendations**
```bash
# When working directory has many unrelated changes:
/dd:commit --split

🔍 Workspace Analysis: 12 total modifications detected
   📌 Staged: 4 files (intentionally selected)
   📝 Unstaged: 8 files (mixed purposes)

💡 Staging Mode Recommendation: --staged-focused
   - Process your staged files with priority
   - Smart extension for obviously related files
   - Group remaining modifications appropriately
   - Maintain clean working directory

   Execute: /dd:commit --split --staged-focused
   Quick:   /dd:commit -sf

Use recommended staging mode? [Y/n/default]:
```

## Implementation (T085 2-Pass Algorithm)

When this command is executed by Claude:

1. **Parameter Processing**: Parse task description and flags (`--no-version-bump`, `--dry-run`, `--amend`, `--force`, `--split`, `--interactive`, `--staged`, `--staged-only`) and convenience shortcuts (`-si`, `-ss`, `-so`, `-sd`)

2. **Split Mode Detection**: If `--split` flag detected:
   - **2-Pass Algorithm Execution**: Apply T085 intelligent staging approach
   - **Pass 1 - Staged Files Processing**:
     * Analyze currently staged files (preserve developer intent)
     * `while(stagedFiles.length > 0)`:
       - Find next logical group from staged files
       - Smart extension: Add related unstaged files to complete group (unless --staged-only)
       - Reset staging, stage group files, create commit
       - Remove processed files from remaining staged list
   - **Pass 2 - Unstaged Files Processing** (unless --staged or --staged-only):
     * `while(unstagedFiles.length > 0)`:
       - Find next logical group from remaining unstaged files  
       - Reset staging, stage group files, create commit
       - Remove processed files from remaining unstaged list
   - **Smart Extension Detection** (Pass 1, unless --staged-only):
     - **Test file relationships**: `tests/*.test.js` related to `src/*.js`
     - **Documentation relationships**: `README.md` changes related to feature files
     - **Configuration relationships**: `package.json` changes related to implementation files
     - **Same directory relationships**: Files in same directory as staged files
   - **Semantic Analysis**: Applied in both passes for logical grouping
     - Epic/TODO files: `todo/*.md`, `NEXT.md` (highest priority)
     - DOH system files: `.claude/doh/*`, `.claude/commands/*`
     - Documentation files: `README.md`, `WORKFLOW.md`, `docs/*`
     - Implementation files: `src/*`, `lib/*`, application code
     - Configuration files: `package.json`, configs, tests
   - **Content Analysis**: Scan file changes for commit message context (both passes)
   - **Iterative Commit Creation**: Process groups progressively without mass staging operations
   - **Preview Mode**: If `--dry-run`, show planned sequence with staging decisions
   - **Interactive Mode**: If `--interactive`, prompt for confirmation on each commit with staging context
   - **Execute Split**: Create multiple commits following priority order and staging mode
   - **Skip remaining steps**: Split mode handles its own pipeline

3. **Amend Mode Detection**: If `--amend` flag detected (not compatible with `--split`):
   - Check for uncommitted changes in working directory
   - **CRITICAL SAFETY CHECK**: Abort with error if previous commit has been pushed to remote
     - **Override with `--force`**: Skip safety check (requires explicit confirmation)
   - Analyze both current changes and previous commit context

4. **Change Analysis**: Use git commands to analyze current status and detect modification patterns

5. **Documentation Pipeline**: Execute `/dd:changelog` without linting (T087)
   - **No linting in pipeline**: /dd:changelog focuses purely on documentation updates
   - **Single enforcement point**: Linting handled only by git pre-commit hooks
   - **Clean separation**: Documentation updates separate from quality enforcement

6. **Version Bump Confirmation**: If version changes detected (unless `--no-version-bump`):
   - Analyze impact and determine appropriate version bump (major/minor/patch)
   - Present version change with rationale: "Version 1.4.0 → 1.4.1 (feature additions)? [Y/n]"
   - Wait for user confirmation before proceeding

7. **Commit Message Generation**: Create intelligent semantic commit message based on analysis
   - **Normal mode**: Generate new commit message
   - **Amend mode**: Update previous commit message while preserving structure

8. **Git Operations with T087 STRICT Enforcement**: Stage changes and execute git command
   - **Default mode**: `git commit` (respects pre-commit hooks, blocks on linting failure)
   - **Force override**: `git commit --no-verify` (ONLY when --force flag explicitly passed by user)
   - **Amend mode**: Apply same logic to `git commit --amend` or `git commit --amend --no-verify`

9. **Error Handling & Recovery**: T087 STRICT enforcement
   - **Linting failures**: COMMIT BLOCKED - display error message and stop execution
   - **User must fix issues OR use --force explicitly**
   - **No automatic bypass or retry logic**
   - **Version conflicts**: Detect and resolve inconsistencies
   - **Rollback capability**: Restore original state if pipeline fails

## AI-Driven Execution

This command is executed entirely by Claude's AI logic:

- **Smart Analysis**: Claude analyzes git changes and TODO completions
- **Intelligent Fixes**: Claude applies prettier and linting fixes progressively
- **Adaptive Messaging**: Claude generates semantic commit messages based on change context
- **Error Recovery**: Claude handles pre-commit hook failures with intelligent retries

## Integration with Other Commands

- **Calls `/dd:changelog`**: AI-driven documentation updates
- **Calls `/doh-sys:lint`**: AI-driven quality assurance with prettier-first approach
- **No bash scripts required**: Pure AI workflow execution

## T085 Integration: Intelligent 2-Pass Algorithm

**✅ ALGORITHM ENHANCED**: The splitting system now uses T085's intelligent 2-pass approach for optimal staging management and developer intent preservation.

### Key Improvements in T085

| Aspect | Before T085 | After T085 |
|--------|-------------|-----------|
| **Staging Approach** | `git add -A` (destroys intent) | 2-pass iterative (respects intent) |
| **Performance** | Mass staging/unstaging juggling | Efficient iterative processing |
| **Developer Intent** | Lost during mass operations | Preserved throughout process |
| **Flags** | Complex --staged-focused | Simple --staged (Pass 1 only) |

### Migration from T084 Approach

| Old T084 Behavior | New T085 Behavior |
|-------------------|-------------------|
| `git add -A` then split | Pass 1 (staged) → Pass 2 (unstaged) |
| `--staged-focused` | `--staged` (cleaner, Pass 1 only) |
| Mass staging operations | Iterative group → commit → repeat |

### Benefits of T085 Algorithm

- **Developer Intent Preservation**: Staged files processed first with priority
- **Optimal Performance**: No staging/unstaging juggling overhead  
- **Cleaner Logic**: Straightforward 2-pass approach vs complex undo operations
- **Better User Experience**: Predictable, logical commit sequence
- **Professional Workflow**: Maintains staging best practices

### Enhanced Features vs /commit-split

**New capabilities in consolidated /dd:commit --split**:
- ✅ **Enhanced staging management**: Three distinct staging modes
- ✅ **Smart extension algorithm**: Related file detection in --staged-focused mode
- ✅ **Convenience shortcuts**: `-si`, `-sf`, `-so`, `-sd` combinations
- ✅ **Complete pipeline integration**: Linting, version bumps, changelog updates
- ✅ **Auto-detection suggestions**: Smart recommendations for when to split
- ✅ **Clean working directory**: Predictable "clean everything" behavior by default

**Removed limitations from /commit-split**:
- ❌ **No pipeline integration**: Now has full /dd:changelog integration
- ❌ **Limited flag support**: Now supports all /dd:commit flags
- ❌ **Incomplete staging**: Now provides complete staging management
- ❌ **Separate maintenance**: Now single, unified implementation
