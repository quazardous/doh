# /doh-sys:changelog - DOH System Documentation Updates

Executes DOH system documentation updates: TODO management, CHANGELOG updates, TODOARCHIVED maintenance, and version
tracking without committing changes. Uses the same intelligent analysis as `/doh-sys:commit` but stops before git
operations.

## Usage

```bash
/doh-sys:changelog [task-completion] [--version-bump] [--no-lint] [--dry-run]
```

## Parameters

- `task-completion`: (Optional) Task ID or description of completed work (e.g., "T035", "fix documentation")
  - **If omitted**: Auto-generates description based on git changes and asks for confirmation
- `--version-bump`: Update version tracking if changes warrant it
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

- **TODO Management**: Mark completed tasks, update timestamps, increment next ID
- **CHANGELOG Updates**: Add completed tasks, update status, ensure formatting
- **TODOARCHIVED Management**: Move old completed tasks from TODO.md to TODOARCHIVED.md (tasks completed yesterday or earlier)
- **Version Tracking**: Update VERSION.md metadata and completion timestamps

### 2. Quality Assurance

- **Calls `/doh-sys:lint`**: Applies intelligent auto-fix to all updated documentation
- **Preserves Analysis Documents**: Maintains semantic content of historical snapshots
- **Ensures Consistency**: Standardizes formatting across TODO.md and CHANGELOG.md

**Architecture**: This command provides the core pipeline that `/doh-sys:commit` builds upon.

## TODOARCHIVED Management Workflow

The changelog command automatically manages the TODOARCHIVED.md file to keep TODO.md focused on active tasks:

### Archive Policy
- **Today's completions**: Remain in TODO.md for immediate visibility
- **Yesterday & older completions**: Automatically moved to TODOARCHIVED.md
- **Preservation**: Full task content, completion dates, and metadata maintained

### Automated Process
1. **Scan TODO.md** for all COMPLETED tasks with completion timestamps
2. **Date comparison** against current date (tasks completed yesterday or earlier)
3. **Extract & format** tasks for TODOARCHIVED.md with full preservation:
   - Task ID, title, priority, dependencies
   - Original description and deliverables  
   - Completion date and notes
4. **Remove** archived tasks from TODO.md
5. **Update** TODOARCHIVED.md with properly formatted entries
6. **Maintain** chronological organization in archive

### Archive Format
Tasks moved to TODOARCHIVED.md maintain full context:
```markdown
### T037 - Clean up old project references ✅

**Status**: COMPLETED ✅  
**Priority**: High 🚩  
**Dependencies**: T034 (COMPLETED)  
**Version**: 1.4.0 **Completed**: 2025-08-27

Original task description and deliverables preserved...

**Completion Notes**: Successfully updated all documentation references...
```

## Example Usage

```bash
# Auto-generate documentation updates
/doh-sys:changelog

# Update with specific task description
/doh-sys:changelog "T039 - Lint command implementation"

# Update with version tracking
/doh-sys:changelog "T040 - Feature complete" --version-bump

# Check what would be updated
/doh-sys:changelog --dry-run

# Skip linting on documentation updates
/doh-sys:changelog "analysis document updates" --no-lint
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
├── ✅ TODO.md updated (T039 → COMPLETED)
├── ✅ CHANGELOG.md updated (T039 entry added)
├── ✅ TODOARCHIVED.md updated (2 old completed tasks moved)
├── ✅ VERSION.md tracking updated
├── 🔧 Auto-fixed 2 documentation formatting issues
└── ✅ Documentation updates complete

Ready for commit. Next: /doh-sys:commit (will use same description)
```

## Relationship to /doh-sys:commit

This command executes steps 1-3 of the commit pipeline:

| Step                  | /doh-sys:changelog | /doh-sys:commit |
| --------------------- | ------------------ | --------------- |
| TODO Management       | ✅                 | ✅              |
| CHANGELOG Updates     | ✅                 | ✅              |
| TODOARCHIVED Mgmt     | ✅                 | ✅              |
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
