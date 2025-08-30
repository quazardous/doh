# /dd:changelog - DOH System Documentation Updates

Executes DOH system documentation updates: structured TODO management, CHANGELOG updates, archive maintenance, and
version tracking without committing changes. Works with the new structured todo/ folder system with individual files.

## 🚨 CRITICAL: NO GIT OPERATIONS

**This command performs ZERO git operations**:

- ❌ **NO `git add`** - Does not stage any files
- ❌ **NO `git commit`** - Does not create commits
- ❌ **NO `git status`** - Does not check git state
- ✅ **Documentation ONLY** - Modifies files without touching git

**For git operations**: Use `/dd:commit` after running this command

## Claude AI Execution Protocol

**Sequential Pipeline Steps**:

1. **ENFORCE: No git operations allowed** - Verify no git commands in pipeline
2. **Parse task-completion parameter** - Extract TODO ID and description
3. **Update TODO files** - Modify T###.md status and metadata
4. **Update CHANGELOG.md** - Add session entry with version in title if bump occurs, project context, and task list
5. **Version Management Pipeline**:
   - Analyze version impact and determine appropriate bump
   - Update VERSION.md with new version information
   - Update relevant version goal files (todo/VDOH-*.md or todo/VDD-*.md)
   - Synchronize version information across all files
6. **Manage archives** - Move old completed TODOs to todo/archive/
7. **Return pipeline status** - Success for calling command

## Usage

```bash
/dd:changelog [task-completion] [--no-version-bump] [--dry-run]
```

## Parameters

### Primary Input

- `task-completion`: (Optional) Task ID or description of completed work
  - **Examples**: `"DOH035"`, `"fix documentation"`, `"implement changelog pipeline"`
  - **If omitted**: Auto-generates description based on git changes and asks for confirmation
  - **Smart detection**: Analyzes staging area and recent commits to suggest descriptions

### Control Flags

- `--dry-run`: Preview all changes without making any modifications
  - **Safe**: Shows TODO updates, CHANGELOG entries, version changes, archive operations
  - **Use when**: Want to verify changes before executing
  - **Perfect for**: Testing and understanding what the command will do

- `--no-version-bump`: Skip automatic version tracking
  - **Default**: Version analysis with user confirmation before changes
  - **Use when**: Minor documentation updates that don't warrant version increment
  - **Note**: Version analysis still runs to show impact, just skips the actual bump

## Auto-Description Generation

When called without a task description, uses the same intelligent analysis as `/dd:commit`:

1. **Analyzes git changes** using `git diff --name-only` and `git status`
2. **Categorizes changes** by file patterns and detects TODO completions
3. **Generates task description** following DOH standards
4. **Prompts for confirmation** with suggested description and option to edit

### Auto-Description Examples

```bash
# Called without parameters
/dd:changelog

# System analyzes changes and suggests:
# "DOH038 pipeline command implementation completed"
# Confirm for documentation updates? [Y/n/edit]:
```

## Pipeline Architecture

This command executes the core DOH documentation pipeline:

### 1. Documentation Updates

- **Structured TODO Management**: Update individual TODO files, mark completed tasks, update timestamps
- **Archive Management**: Move completed TODO files from todo/ to todo/archive/ (tasks completed yesterday or earlier)
- **CHANGELOG Updates**: Add synthetic epic-level summaries with clear project context (DOH Runtime vs DOH-DEV), maintain concise format (max 2 lines per entry)
- **ID Counter Management**: Update next available ID counter in todo/README.md
- **Version Tracking**: Comprehensive version management across all related files
  - **Project-Aware Versioning**:
    - DOH-DEV Internal tasks → `dd-x.x.x` version files (`todo/VDD-0.1.0.md`)
    - DOH Runtime tasks → `doh-x.x.x` version files (`todo/VDOH-1.4.0.md`)
    - Default: DOH Runtime versioning unless task explicitly marked DOH-DEV Internal
  - **VERSION.md Integration**: Updates main version registry during version bumps
    - Updates current version numbers for active projects
    - Maintains version history and status tracking
    - Synchronizes with version goal files
  - **Version Goal File Management**:
    - Updates progress percentages in active version goal files
    - Marks version goal files as COMPLETED when milestones achieved  
    - Creates new version goal files for next version milestones
    - Handles version transitions (e.g., VDD-0.2.0 → VDD-0.2.1)
  - **Cross-File Synchronization**: Ensures VERSION.md, version goal files, and CHANGELOG.md consistency
  - **History Immutability**: NEVER modifies CHANGELOG.md or completed tasks during refactoring
  - **Automatic Analysis**: Detects version impact based on project context and task scope
  - **User Confirmation**: Prompts for approval with project-specific version increment
  - **Impact Assessment**: Shows version change rationale with project isolation respected

### 2. Version Management

- **VERSION.md Integration**: Updates main version registry when versions are bumped
- **Version Goal File Management**: Updates `todo/VDOH-*.md` and `todo/VDD-*.md` files during version transitions
- **Version Impact Analysis**: Automatic detection of version-affecting changes
- **Cross-File Synchronization**: Ensures VERSION.md, version goal files, and CHANGELOG.md stay synchronized
- **Archive Management**: Systematic organization of completed tasks

### 3. CHANGELOG Format Requirements

**Simple Chronological Log Format**:

- **Session-based entries**: Use date as section header (e.g., `## 2025-08-30`)
- **Version in title when bump occurs**: Use new version in section title (e.g., `## VDD-0.2.1 (2025-08-30)`)
- **Maximum 2 lines per entry**: Project context + task list only
- **Project Context Required**: Clear indication of "DOH Runtime" vs "DOH-DEV"
- **Epic-Level Summaries**: Focus on major achievements, not individual task details
- **Task Lists Only**: Simple enumeration without verbose descriptions

**Example Formats**:

With version bump:
```
## VDD-0.2.1 (2025-08-30)

- **DOH-DEV**: Architecture refactoring and intelligent linting system completion
  - **Tasks**: EDD116, DD103, DD104, DD112, DD118
```

Without version bump:
```
## 2025-08-30

- **DOH Runtime**: Memory system enhancements and bug fixes
  - **Tasks**: DOH054, DOH055, DOH056
```

**NOT This** (verbose commit-style entries):
```
- **DD103** - Intelligent Linting Feedback System (DOH-DEV Internal)
  - **STATUS**: ✅ COMPLETED 2025-08-30
  - **Components**: Self-improving linting system...
  - [multiple lines of technical detail]
```

**Architecture**: This command provides the core documentation pipeline that `/dd:commit` builds upon.

## Archive Management Workflow

The changelog command automatically manages the todo/archive/ folder to keep active TODOs organized:

### Archive Policy

- **Today's completions**: Remain in todo/ folder for immediate visibility
- **Yesterday & older completions**: Automatically moved to todo/archive/
- **File Preservation**: Individual TODO files moved intact with full history

### Automated Process

1. **Scan todo/ folder** for all TODO files (T###.md) with COMPLETED status
2. **Date comparison** against current date (tasks completed yesterday or earlier)
3. **Move files** from todo/ to todo/archive/ preserving:
   - Complete file content and metadata
   - Original filename (T###.md)
   - All completion information and notes
4. **Update todo/README.md** if next ID counter needs adjustment
5. **Maintain** chronological organization in archive folder

### Archive Structure

Files moved to todo/archive/ maintain their complete original format:

```text
todo/archive/
├── DOH013.md    # Complete original TODO file
├── DOH017.md    # Full metadata and content preserved
├── DOH037.md    # All completion information intact
└── ...
```

Each archived file retains its full structure including status, priority, dependencies, tasks, and completion details.

## Example Usage

```bash
# Auto-generate documentation updates
/dd:changelog

# Update with specific task description
/dd:changelog "DOH039 - Lint command implementation"

# Version tracking with confirmation (default behavior)
/dd:changelog "DOH040 - Feature complete"
# → Analyzes impact, prompts: "Version 1.4.0 → 1.4.1 (feature completion)? [Y/n]"

# Check what would be updated
/dd:changelog --dry-run

# Skip version bump for minor updates
/dd:changelog "analysis document updates" --no-version-bump
```

## Integration with Other Commands

Works seamlessly with other `/doh-sys:` commands:

```bash
# Typical workflow (NO GIT OPERATIONS in changelog)
/doh-sys:lint                    # Clean up code quality
/dd:changelog "DOH039 done"        # Update documentation ONLY (no git)
/doh-sys:commit                  # NOW do git staging + commit

# Or use the full pipeline
/doh-sys:commit "DOH039 done"      # Does changelog + commit

# ⚠️ INCORRECT usage (changelog does NOT do git):
/dd:changelog && git add .       # WRONG - changelog doesn't need staging
git add . && /dd:changelog       # WRONG - changelog works on working tree
```

## Output Format

Provides clear progress reporting:

```text
📝 DOH Documentation Updates: DOH039 Lint Command
├── ✅ todo/DOH039.md updated (marked COMPLETED)
├── ✅ CHANGELOG.md updated (session entry: VDOH-1.4.1 (2025-08-30))
├── ✅ Archive management: 2 completed TODOs moved to todo/archive/
├── ✅ todo/README.md: Next ID counter updated
├── 🔄 Version analysis: VDOH-1.4.0 → VDOH-1.4.1 (feature additions detected)
├── ✅ VERSION.md updated: DOH Runtime VDOH-1.4.0 → VDOH-1.4.1
├── ✅ todo/VDOH-1.4.0.md updated with completion status
├── ✅ Version synchronization: All version files consistent
└── ✅ Documentation updates complete

Ready for commit. Next: /dd:commit (will use same description)
```

## Relationship to /doh-sys:commit

This command executes steps 1-3 of the commit pipeline:

| Step                  | /dd:changelog | /dd:commit    |
| --------------------- | ------------- | ------------- |
| Structured TODO Mgmt  | ✅            | ✅            |
| CHANGELOG Updates     | ✅            | ✅            |
| Archive Management    | ✅            | ✅            |
| ID Counter Updates    | ✅            | ✅            |
| Version Tracking      | ✅            | ✅            |
| VERSION.md Updates    | ✅            | ✅            |
| Version Goal Files    | ✅            | ✅            |
| Documentation Updates | ✅            | ✅            |
| Git Staging           | ❌ **NEVER**  | ✅            |
| Git Commit            | ❌ **NEVER**  | ✅            |
| Git Operations        | ❌ **ZERO**   | ✅ Full       |

## Use Cases

Perfect for situations where you need to:

- **Update documentation** before reviewing changes
- **Separate documentation** from code commits
- **Batch multiple tasks** before committing
- **Review changes** before making them permanent
- **Work in draft mode** while iterating

## Error Handling

Simple error handling:

- **File conflicts**: Detects and reports merge issues
- **Missing information**: Prompts for required details
- **Validation failures**: Reports issues with suggestions

This command provides all the documentation intelligence of the commit pipeline while giving you control over when to
actually commit the changes.
