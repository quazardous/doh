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

## Claude AI Execution Protocol

**Primary Workflow Steps**:
1. **Call `/dd:changelog`** with inherited parameters (`--no-lint`, `--lenient`, etc.)
2. **Monitor changelog response** for success/failure signals and user decision requirements
3. **IF changelog succeeds**: Continue to git operations with generated commit message
4. **IF changelog blocked**: Present user options, AWAIT input, apply user choice
5. **Execute git operations** using configured parameters (--no-verify based on linting results)
6. **Report completion** with commit hash and summary

## Usage

```bash
/dd:commit [task-completion] [--no-version-bump] [--no-lint] [--lenient] [--dry-run] [--amend] [--force] [--split] [--interactive] [--staged-focused]
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

- `--no-lint`: Skip linting and auto-fixes on documentation
  - **Default**: Strict linting enforcement - blocks commits with errors
  - **Use when**: Emergency commits or when linting is problematic
  - **⚠️ Warning**: Bypasses all quality checks

- `--lenient`: Allow commits with linting errors after showing warnings
  - **Behavior**: Shows linting errors but proceeds without user confirmation
  - **Use when**: Working with legacy files or minor formatting issues
  - **Quality**: Still shows all issues but doesn't block commit

### Advanced Git Operations  
- `--amend`: Amend the previous commit instead of creating a new one
  - **Use when**: Adding forgotten changes to recent commit
  - **⚠️ Warning**: Don't amend pushed commits (breaks collaboration)
  - **Combines with**: --no-version-bump (usually don't bump version for amendments)

- `--force`: Override safety checks and confirmations
  - **⚠️ DANGEROUS**: Can break collaboration if used incorrectly
  - **Use when**: Automated scripts or when you're absolutely certain
  - **Bypasses**: All interactive confirmations and safety validations

### Semantic Splitting System (NEW)
- `--split`: Intelligently split large staging area into multiple semantic commits
  - **Algorithm**: Epic/TODO updates → System changes → Documentation → Implementation → Misc
  - **Smart analysis**: Groups related files by semantic meaning
  - **Use when**: Staging area contains multiple logical units of work
  - **Example**: Mixed epic updates, DOH system changes, and code modifications

- `--interactive`: Review and confirm each commit in the split sequence
  - **Requires**: `--split` flag to be effective
  - **Process**: Shows each planned commit with files and message for approval
  - **Control**: Can edit commit messages, skip commits, or abort sequence
  - **Use when**: Want control over each commit in a split sequence

- `--staged-focused`: Process staged files + obvious semantic matches only
  - **Requires**: `--split` flag to be effective  
  - **Behavior**: Ignores unrelated unstaged/untracked files
  - **Smart matching**: Auto-stages files that are obviously part of staged work
  - **Use when**: Large workspace with many unrelated changes, want focused commits

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
| --no-lint | ✅ Pass through | ✅ Skip linting pipeline | Uses git --no-verify |
| --lenient | ✅ Pass through | ✅ Enable linting bypass | Uses git --no-verify |
| --dry-run | ✅ Pass through | ✅ Preview mode only | No git operations |
| --amend | ❌ Handle locally | ❌ Not applicable | git commit --amend |
| --force | ❌ Handle locally | ❌ Not applicable | git commit --force |
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

- **Works with existing flags**: Combines with `--no-lint`, `--no-version-bump`, etc.
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
/dd:commit --amend --no-lint
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

## Strict Linting Enforcement (NEW - Architectural Fix)

The command enforces professional documentation quality by default through the `/dd:changelog` pipeline, with explicit decision tree logic when linting errors are found.

## Claude AI Linting Decision Protocol

**When `/dd:changelog` encounters linting failures**:

```
IF linting_pipeline_fails THEN:
  1. DISPLAY error classification (critical vs minor issues)
  2. DISPLAY pattern analysis and optimization suggestions  
  3. PRESENT user decision options:
     - [1] Continue in lenient mode → SET git_no_verify=true
     - [2] Abort pipeline → HALT execution, display retry instructions
     - [3] Show fix suggestions → DISPLAY detailed help, AWAIT new choice
     - [4] Apply config optimizations → Run optimization, retry linting
  4. AWAIT user input
  5. EXECUTE chosen option:
     - IF option 1: CONTINUE with --no-verify flag for git operations
     - IF option 2: HALT command execution  
     - IF option 3: DISPLAY suggestions, RETURN to step 3
     - IF option 4: APPLY optimizations, RETRY linting pipeline
  6. PROCEED with configured git operation parameters
```

### Fixed Architecture: Linting in Changelog Pipeline

```bash
/dd:commit "T070 complete"

🔄 DOH Pipeline: T070 complete
├── 📝 Running linting pipeline in /dd:changelog (STRICT mode)...
│   ├── 🔧 Step 1: make lint-fix (fixed 8/12 issues)
│   ├── 🤖 Step 2: AI analyzing remaining 4 issues...
│   │   ├── ✅ Fixed MD047 (missing newlines)
│   │   ├── ✅ Fixed MD032 (list spacing)
│   │   ├── ⚠️  MD013 line 120 needs manual attention
│   │   └── ⚠️  MD025 multiple H1s (structural issue)
│   └── ❌ LINTING FAILED - 2 critical issues remain
│
├── 📊 Pattern tracking: Updated ./linting/feedback.md
├── 💡 Auto-suggestion: Consider line-length increase to 130
│
└── ⚠️  PIPELINE BLOCKED - USER DECISION REQUIRED:
    [1] Continue in lenient mode (uses --no-verify in git operations)
    [2] Abort and fix manually
    [3] Show detailed fix suggestions  
    [4] Apply suggested config optimizations

# User selects [1] - Continue in lenient mode
├── ⚡ CONTINUING IN LENIENT MODE
├── ✅ Documentation updates complete
├── 📝 Intelligent commit message generated
└── git commit --no-verify -m "T070 complete"  # Only uses --no-verify when bypassed
```

**Key Architectural Changes**:
- **Linting moved to `/dd:changelog`**: Quality checks happen BEFORE any git operations
- **Pipeline blocking**: Entire workflow halts when linting fails in strict mode
- **Smart `--no-verify` usage**: Only applied when user explicitly chooses lenient/skip mode
- **AI-powered fixes**: Multi-layer automated correction system
- **Pattern learning**: Feedback stored in `./linting/feedback.md` for optimization

### Bypass Control Integration

The bypass control is now handled in the `/dd:changelog` pipeline with intelligent options:

#### **Interactive Decision Flow** (When Linting Fails)

```bash
⚠️  PIPELINE BLOCKED - USER DECISION REQUIRED:

📄 Problematic Files:
├── todo/T070.md (3 issues remaining after AI fixes)
│   ├── Line 45: MD047 Missing final newline (CRITICAL)
│   ├── Line 120: MD013 Line too long [125/120] (minor)
│   └── Line 89: MD032 List spacing (minor)
└── docs/guide.md (1 issue)
    └── Line 12: MD025 Multiple H1 headings (CRITICAL)

🤖 AI Analysis: 2 critical issues require manual attention
💡 Suggestions: Run 'make lint-manual' for detailed guidance

DECISION OPTIONS:
[1] Continue in lenient mode → Pipeline continues with --no-verify
[2] Abort and fix manually → Halt pipeline, fix issues, retry
[3] Show detailed fix suggestions → Display specific resolution help
[4] Apply config optimizations → Update .markdownlint.json rules

Choice [1/2/3/4]: 
```

#### **Smart Flag Integration**

**Lenient Mode (`--lenient`)**:
- **Pipeline behavior**: Shows errors as warnings, continues automatically
- **Git operations**: Uses `git commit --no-verify` 
- **No prompts**: Automatic bypass without user interaction
- **Pattern tracking**: Still logs issues to `./linting/feedback.md`

```bash
/dd:commit "T070 complete" --lenient

🔄 DOH Pipeline: T070 complete (LENIENT mode)
├── 📝 Linting checks: 5 issues found - continuing with warnings
├── ✅ Documentation updates complete
├── 📊 Issues logged to ./linting/feedback.md
└── git commit --no-verify -m "T070 complete"
```

**Complete Skip (`--no-lint`)**:
- **Pipeline behavior**: Bypasses entire linting pipeline
- **Git operations**: Uses `git commit --no-verify`
- **Performance**: Fastest execution, no quality checks
- **Clear warnings**: Explicit messaging about skipped validation

```bash
/dd:commit "T070 complete" --no-lint

🔄 DOH Pipeline: T070 complete (NO-LINT mode)
├── ⚡ SKIPPING ALL LINTING - No quality checks performed
├── ✅ Documentation updates complete
└── git commit --no-verify -m "T070 complete"
```

### Error Classification & AI Success Tracking

The pipeline uses intelligent error categorization and tracks AI fix success rates:

**Critical Errors** (Pipeline blocking):
- **MD047**: Missing final newline → **AI Success: 100%**
- **MD025**: Multiple H1 headings → **AI Success: 23%** (needs manual fix)
- **MD002**: First heading not H1 → **AI Success: 45%**
- **MD031**: Code block spacing → **AI Success: 90%**

**Minor Errors** (Warning level in lenient mode):
- **MD013**: Line length → **AI Success: 95%** (smart line breaking)
- **MD032**: List spacing → **AI Success: 87%**
- **MD009**: Trailing spaces → **AI Success: 100%**
- **MD040**: Code block languages → **AI Success: 78%**

### Feedback-Driven Optimization

The system continuously learns and suggests improvements:

```bash
🔍 LINTING OPTIMIZATION AVAILABLE

📊 Pattern Analysis (last 25 commits):
├── MD013 (line length): 18 failures → 72% of all issues
├── MD047 (missing newline): 8 failures → 32% of all issues  
└── MD032 (list spacing): 5 failures → 20% of all issues

💡 Recommended .markdownlint.json optimizations:
{
  "MD013": { "line_length": 130, "code_blocks": false },
  "MD047": true,
  "MD032": { "style": "consistent" }
}

📈 Impact: Would eliminate ~85% of recurring linting failures

Apply these optimizations? [Y/n]
```

### Quality Assurance Benefits

- **Professional Standards**: Ensures consistent, high-quality documentation
- **Team Alignment**: Enforces shared quality standards across contributors
- **Error Prevention**: Catches structural issues before they enter git history
- **Developer Guidance**: Provides clear, actionable error explanations
- **Flexible Control**: Multiple bypass mechanisms for different scenarios

## Auto-Fix Capabilities

The pipeline includes intelligent auto-fixes for:

- **Line Length**: Smart text wrapping preserving meaning
- **Blank Lines**: Add missing blank lines around headings/lists
- **Code Blocks**: Add language specifications
- **Emphasis Headers**: Convert to proper heading syntax
- **Trailing Spaces**: Remove or normalize
- **File Endings**: Ensure single trailing newline

## Usage Examples & Smart Suggestions

### 💡 Quick Start - Most Common Patterns

```bash
# 🚀 Most common: Auto-extract from recent changes
/dd:commit
# Smart analysis → suggests commit message → single focused commit

# 📋 With specific task completion
/dd:commit "T039 - Lint command with auto-fix"
# Uses task description → updates changelog → creates commit

# 👁️ Preview before committing (always safe)
/dd:commit --dry-run
# Shows exactly what would happen → no changes made
```

### 🔧 Advanced Flag Combinations

```bash
# 🎯 Focus mode: Large workspace with unrelated changes
/dd:commit --split --staged-focused
# Only processes staged files + obvious semantic matches
# Ignores unrelated unstaged/untracked files

# 🔍 Interactive control: Review each commit
/dd:commit --split --interactive --staged-focused
# Split sequence → review each → edit messages → full control

# ⚡ Speed mode: Skip slow operations
/dd:commit "T041 cleanup" --no-lint --no-version-bump
# Fastest commit → skips linting & version analysis → immediate commit

# 🎯 Quality mode: Allow minor linting issues
/dd:commit "T041 cleanup" --lenient
# Shows linting warnings → proceeds without confirmation → maintains quality awareness

# 🛠️ Amendment with safety
/dd:commit --amend --lenient
# Add to previous commit → allow minor linting issues → safe for amendments

# 🧪 Testing mode: See everything without doing anything
/dd:commit --split --dry-run
# Shows split plan → no commits created → perfect for testing
```

### 📊 Smart Context-Based Suggestions

**When you have many files staged:**
```bash
/dd:commit --split
# 💡 Suggested by Claude when 5+ files staged
# Algorithm splits into semantic groups automatically
```

**When working directory is messy:**  
```bash
/dd:commit --split --staged-focused
# 💡 Suggested when many unrelated unstaged files present
# Focuses only on intentionally staged work
```

**When you want control over commits:**
```bash
/dd:commit --split --interactive
# 💡 Suggested for complex changes requiring review
# Full control over each commit in sequence
```

**When making quick fixes:**
```bash
/dd:commit "fix typo" --no-lint --no-version-bump
# 💡 Suggested for minor changes
# Skip time-consuming operations
```

**When unsure about changes:**
```bash
/dd:commit --dry-run
# 💡 Always safe - shows what would happen
# No actual changes made to git history
```

### 🔄 Common Workflow Patterns

**Epic Task Completion:**
```bash
# 1. Complete epic work with splitting
/dd:commit --split --interactive "T054 complete"
# → Epic updates first → System changes → Documentation → Implementation

# 2. Quick documentation fix
/dd:commit "fix documentation" --no-version-bump --no-lint
# → Skip version bump for docs-only changes
```

**Mixed Development Session:**
```bash
# 1. Stage intentional changes first
git add todo/T065.md .claude/commands/doh-sys/commit.md

# 2. Split with focus on staged files
/dd:commit --split --staged-focused
# → Process staged files + auto-detect related changes
# → Ignore unrelated workspace modifications
```

**Amendment and Cleanup:**
```bash
# 1. Realize you forgot something in previous commit
/dd:commit --amend --no-version-bump
# → Add changes to previous commit without version bump

# 2. Major changes require careful review
/dd:commit --split --interactive --dry-run
# → First: preview the split plan
/dd:commit --split --interactive  
# → Then: execute with full control
```

### ⚡ Flag Compatibility Matrix

| Primary Flag | Compatible With | Recommended Combinations |
|--------------|----------------|-------------------------|
| `--split` | `--interactive`, `--staged-focused`, `--dry-run` | `--split --interactive` |
| `--dry-run` | All flags | `--split --dry-run` (preview splits) |
| `--amend` | `--no-version-bump`, `--no-lint` | `--amend --no-version-bump` |
| `--interactive` | `--split` only | `--split --interactive --staged-focused` |
| `--staged-focused` | `--split` only | `--split --staged-focused` |

### 🚫 Flag Conflicts (Auto-Detected)

```bash
# ❌ These combinations are detected and prevented:
/dd:commit --amend --split
# Error: Cannot amend with splitting (creates multiple commits)

/dd:commit --interactive
# Error: --interactive requires --split flag

/dd:commit --staged-focused  
# Error: --staged-focused requires --split flag
```
# → Shows proposed commit sequence and file groupings
# → Perfect for validation before committing

# Split with other options
/dd:commit "T064 implementation" --split --no-lint
# → Split commits with specific task context, skip linting

# Staged-focused splitting (ignore unrelated unstaged files)
/dd:commit --split --staged-focused
# → Split staged files + obvious semantic matches
# → Don't prompt about unrelated unstaged files
# → Perfect for partial commits when working directory has unrelated changes
```

## Split Algorithm Implementation

### Semantic File Categorization

The split algorithm uses priority-based pattern matching to group files logically:

```javascript
// Priority 1: Epic & TODO Updates (Highest)
const epicFiles = stagedFiles.filter(file => 
  /^todo\/.*\.md$|^todo\/NEXT\.md$/.test(file)
);

// Priority 2: DOH System Infrastructure  
const dohSystemFiles = stagedFiles.filter(file =>
  /^\.claude\/(doh|commands)\//.test(file)
);

// Priority 3: Project Documentation
const docsFiles = stagedFiles.filter(file =>
  /^(README|WORKFLOW|DEVELOPMENT)\.md$|^docs\//.test(file)
);

// Priority 4: Core Implementation
const sourceFiles = stagedFiles.filter(file =>
  /^src\/|^lib\/|^app\/|\.(js|py|ts|php)$/.test(file)
);

// Priority 5: Configuration & Support
const configFiles = stagedFiles.filter(file =>
  /^(package\.json|.*\.config\.|.*rc\.|.*\.lock)$|^tests?\//.test(file)
);
```

### Content Analysis for Smart Messages

Each commit message is generated based on actual file content analysis:

```javascript
// Epic/TODO commit message generation
const generateEpicCommitMessage = (files) => {
  const completedTasks = extractCompletedTasks(files);
  const taskUpdates = extractTaskUpdates(files);
  
  if (completedTasks.length > 0) {
    return `feat: Complete ${completedTasks.join(', ')} and update project roadmap`;
  } else if (taskUpdates.length > 0) {
    return `docs: Update ${taskUpdates.join(', ')} task documentation`;
  }
  return 'docs: Update project task management';
};

// DOH System commit message generation
const generateSystemCommitMessage = (files) => {
  const newCommands = detectNewCommands(files);
  const enhancedComponents = detectEnhancements(files);
  
  if (newCommands.length > 0) {
    return `feat: Add ${newCommands.join(', ')} commands to DOH system`;
  } else if (enhancedComponents.length > 0) {
    return `feat: Enhance DOH ${enhancedComponents.join(', ')}`;
  }
  return 'feat: Update DOH system components';
};
```

### Interactive Split Flow

The interactive mode provides fine-grained control over each commit:

```javascript
const executeInteractiveSplit = async (commitPlan) => {
  for (let i = 0; i < commitPlan.length; i++) {
    const commit = commitPlan[i];
    
    console.log(`Commit ${i+1}/${commitPlan.length}: "${commit.message}"`);
    console.log(`Files: ${commit.files.join(', ')}`);
    
    const action = await prompt('Execute this commit? [Y/n/edit/skip]');
    
    switch (action.toLowerCase()) {
      case 'y':
      case '':
        await executeCommit(commit);
        console.log(`✅ Commit ${i+1} complete`);
        break;
        
      case 'edit':
        const newMessage = await prompt('Enter commit message:');
        commit.message = newMessage;
        await executeCommit(commit);
        console.log(`✅ Commit ${i+1} complete (edited)`);
        break;
        
      case 'skip':
        console.log(`⏭️  Commit ${i+1} skipped`);
        // Add files back to staging for potential later commits
        await stageFiles(commit.files);
        break;
        
      case 'n':
        console.log('Split sequence cancelled');
        return false;
    }
  }
  return true;
};
```

### Split Safety & Rollback

The split system includes comprehensive safety features:

```javascript
const executeSplitCommits = async (commitPlan) => {
  // Store original staging state for rollback
  const originalStaging = await getCurrentStagingState();
  const commitHashes = [];
  
  try {
    for (const commit of commitPlan) {
      // Reset staging and stage only files for this commit
      await resetStaging();
      await stageFiles(commit.files);
      
      // Execute commit with generated message
      const hash = await executeGitCommit(commit.message);
      commitHashes.push(hash);
      
      console.log(`✅ Commit created: ${hash.substring(0,7)} - ${commit.message}`);
    }
    
    console.log(`\n🎉 Split complete! Created ${commitHashes.length} focused commits.`);
    return true;
    
  } catch (error) {
    console.log(`❌ Split failed: ${error.message}`);
    
    // Rollback: reset to before split and restore original staging
    if (commitHashes.length > 0) {
      const rollbackTo = commitHashes.length > 0 
        ? `HEAD~${commitHashes.length}` 
        : 'HEAD';
      
      console.log(`🔄 Rolling back ${commitHashes.length} commits...`);
      await executeGitCommand(`git reset --soft ${rollbackTo}`);
    }
    
    // Restore original staging
    await restoreStagingState(originalStaging);
    console.log('✅ Original staging state restored');
    
    return false;
  }
};
```

## Error Handling

- **Split Failures**: Automatic rollback to original staging state if any commit fails
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

## Implementation

When this command is executed by Claude:

1. **Parameter Processing**: Parse task description and flags (`--no-version-bump`, `--no-lint`, `--lenient`, `--dry-run`, `--amend`, `--force`, `--split`, `--interactive`, `--staged-focused`)

2. **Split Mode Detection**: If `--split` flag detected:
   - **Semantic Analysis**: Analyze staged files and categorize by logical grouping
     - Epic/TODO files: `todo/*.md`, `NEXT.md` (highest priority)
     - DOH system files: `.claude/doh/*`, `.claude/commands/*`
     - Documentation files: `README.md`, `WORKFLOW.md`, `docs/*`
     - Implementation files: `src/*`, `lib/*`, application code
     - Configuration files: `package.json`, configs, tests
   - **Content Analysis**: Scan file changes for commit message context
     - Detect TODO completions and task IDs
     - Identify feature implementations and improvements
     - Analyze documentation focus areas
   - **Commit Sequence Planning**: Create logical commit order with generated messages
   - **Preview Mode**: If `--dry-run`, show planned sequence without execution
   - **Interactive Mode**: If `--interactive`, prompt for confirmation on each commit
   - **Execute Split**: Create multiple commits following priority order
   - **Skip remaining steps**: Split mode handles its own pipeline

3. **Amend Mode Detection**: If `--amend` flag detected (not compatible with `--split`):
   - Check for uncommitted changes in working directory
   - **CRITICAL SAFETY CHECK**: Abort with error if previous commit has been pushed to remote
     - **Override with `--force`**: Skip safety check (requires explicit confirmation)
   - Analyze both current changes and previous commit context

4. **Change Analysis**: Use git commands to analyze current status and detect modification patterns

5. **Documentation Pipeline with Strict Linting**: Execute `/dd:changelog` with enhanced quality enforcement
   - **AI-Powered Linting Pipeline**: Multi-layer fix system (make lint-fix → AI fixes → validation → user decision)
   - **Pipeline Blocking**: `/dd:changelog` halts execution when linting fails in strict mode
   - **Pattern Learning**: Track failures in `./linting/feedback.md` for optimization
   - **Flag Propagation**: Pass `--lenient`, `--no-lint` flags to control linting behavior
   - **Quality Gate**: Only proceeds if linting passes or user explicitly bypasses

6. **Version Bump Confirmation**: If version changes detected (unless `--no-version-bump`):
   - Analyze impact and determine appropriate version bump (major/minor/patch)
   - Present version change with rationale: "Version 1.4.0 → 1.4.1 (feature additions)? [Y/n]"
   - Wait for user confirmation before proceeding

7. **Commit Message Generation**: Create intelligent semantic commit message based on analysis
   - **Normal mode**: Generate new commit message
   - **Amend mode**: Update previous commit message while preserving structure

8. **Git Operations with Smart --no-verify Control**: Stage changes and execute git command
   - **Strict mode (default)**: `git commit` (no --no-verify flag, relies on clean pre-commit state)
   - **Lenient mode**: `git commit --no-verify` (when user chose bypass in changelog pipeline)
   - **Skip mode**: `git commit --no-verify` (when --no-lint flag used)
   - **Amend mode**: Apply same logic to `git commit --amend`

9. **Error Handling & Recovery**: Progressive retry with intelligent bypass options
   - **Linting failures**: Handled in `/dd:changelog` pipeline with user decision flow
   - **Git hook failures**: Rare due to pre-linting, but handled with retry logic
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
