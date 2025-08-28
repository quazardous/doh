# /doh-sys:changelog - DOH System Documentation Updates

Executes DOH system documentation updates: structured TODO management, CHANGELOG updates, archive maintenance, and
version tracking without committing changes. Works with the new structured todo/ folder system with individual files.

## Usage

```bash
/doh-sys:changelog [task-completion] [--no-version-bump] [--no-lint] [--dry-run]
```

## Parameters

- `task-completion`: (Optional) Task ID or description of completed work (e.g., "T035", "fix documentation")
  - **If omitted**: Auto-generates description based on git changes and asks for confirmation
- `--no-version-bump`: Skip automatic version tracking (version bump is default behavior with confirmation)
- `--no-lint`: Skip linting and auto-fixes on documentation files
- `--dry-run`: Show what would be done without making changes

## Auto-Description Generation

When called without a task description, uses the same intelligent analysis as `/doh-sys:commit`:

1. **Analyzes git changes** using `git diff --name-only` and `git status`
2. **Categorizes changes** by file patterns and detects TODO completions
3. **Generates task description** following DOH standards
4. **Prompts for confirmation** with suggested description and option to edit

### Auto-Description Examples

```bash
# Called without parameters
/doh-sys:changelog

# System analyzes changes and suggests:
# "T038 pipeline command implementation completed"
# Confirm for documentation updates? [Y/n/edit]:
```

## Pipeline Architecture

This command executes the core DOH documentation pipeline:

### 1. Documentation Updates

- **Structured TODO Management**: Update individual TODO files, mark completed tasks, update timestamps
- **Archive Management**: Move completed TODO files from todo/ to todo/archive/ (tasks completed yesterday or earlier)
- **CHANGELOG Updates**: Add completed tasks, update status, ensure formatting
- **ID Counter Management**: Update next available ID counter in todo/README.md
- **Version Tracking**: Update VERSION.md metadata and completion timestamps
  - **Automatic Analysis**: Detects if changes warrant version bump based on impact
  - **User Confirmation**: Prompts for approval before applying version changes
  - **Impact Assessment**: Shows version change rationale (major/minor/patch)

### 2. Quality Assurance

- **Calls `/doh-sys:lint`**: Applies intelligent auto-fix to all updated documentation
- **Preserves Analysis Documents**: Maintains semantic content of historical snapshots
- **Ensures Consistency**: Standardizes formatting across TODO.md and CHANGELOG.md

**Architecture**: This command provides the core pipeline that `/doh-sys:commit` builds upon.

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

```
todo/archive/
├── T013.md    # Complete original TODO file
├── T017.md    # Full metadata and content preserved
├── T037.md    # All completion information intact
└── ...
```

Each archived file retains its full structure including status, priority, dependencies, tasks, and completion details.

## Example Usage

```bash
# Auto-generate documentation updates
/doh-sys:changelog

# Update with specific task description
/doh-sys:changelog "T039 - Lint command implementation"

# Version tracking with confirmation (default behavior)
/doh-sys:changelog "T040 - Feature complete"
# → Analyzes impact, prompts: "Version 1.4.0 → 1.4.1 (feature completion)? [Y/n]"

# Check what would be updated
/doh-sys:changelog --dry-run

# Skip version bump for minor updates
/doh-sys:changelog "analysis document updates" --no-version-bump --no-lint
```

## Integration with Other Commands

Works seamlessly with other `/doh-sys:` commands:

```bash
# Typical workflow
/doh-sys:lint                    # Clean up code quality
/doh-sys:changelog "T039 done"   # Update documentation
/doh-sys:commit                  # Commit with auto-generated message

# Or use the full pipeline
/doh-sys:commit "T039 done"      # Does changelog + commit
```

## Output Format

Provides clear progress reporting:

```
📝 DOH Documentation Updates: T039 Lint Command
├── ✅ todo/T039.md updated (marked COMPLETED)
├── ✅ CHANGELOG.md updated (T039 entry added)
├── ✅ Archive management: 2 completed TODOs moved to todo/archive/
├── ✅ todo/README.md: Next ID counter updated
├── 🔄 VERSION.md analysis: 1.4.0 → 1.4.1 (feature additions detected)
├── ✅ Version bump confirmed and applied
├── 🔧 Auto-fixed 2 documentation formatting issues
└── ✅ Documentation updates complete

Ready for commit. Next: /doh-sys:commit (will use same description)
```

## Relationship to /doh-sys:commit

This command executes steps 1-3 of the commit pipeline:

| Step                  | /doh-sys:changelog | /doh-sys:commit |
| --------------------- | ------------------ | --------------- |
| Structured TODO Mgmt  | ✅                 | ✅              |
| CHANGELOG Updates     | ✅                 | ✅              |
| Archive Management    | ✅                 | ✅              |
| ID Counter Updates    | ✅                 | ✅              |
| Version Tracking      | ✅                 | ✅              |
| Documentation Linting | ✅                 | ✅              |
| Git Staging           | ❌                 | ✅              |
| Git Commit            | ❌                 | ✅              |

## Use Cases

Perfect for situations where you need to:

- **Update documentation** before reviewing changes
- **Separate documentation** from code commits
- **Batch multiple tasks** before committing
- **Review changes** before making them permanent
- **Work in draft mode** while iterating

## Error Handling

Uses the same progressive error handling as `/doh-sys:commit`:

- **File conflicts**: Detects and reports merge issues
- **Format errors**: Applies intelligent auto-fixes
- **Missing information**: Prompts for required details
- **Validation failures**: Reports issues with suggestions

This command provides all the documentation intelligence of the commit pipeline while giving you control over when to
actually commit the changes.
