# /doh:changelog - Project Documentation Pipeline

Executes project documentation updates: DOH task management, CHANGELOG updates, and version tracking for any DOH-managed project. Adapts the sophisticated /doh-dev pipeline for runtime use with .doh project structure.

## Usage

```bash
/doh:changelog [task-completion] [--no-version-bump] [--no-lint] [--dry-run]
```

## Parameters

- `task-completion`: (Optional) DOH task ID or description of completed work (e.g., "DOH-123", "implement user auth")
  - **If omitted**: Auto-generates description based on git changes and asks for confirmation
- `--no-version-bump`: Skip automatic version tracking (version bump is default behavior with confirmation)
- `--no-lint`: Skip linting and auto-fixes on documentation files (default: lint only if project has DOH linting enabled)
- `--dry-run`: Show what would be done without making changes

## Auto-Description Generation

When called without a task description, uses intelligent analysis similar to /dd:commit:

1. **Analyzes git changes** using `git diff --name-only` and `git status`
2. **Categorizes changes** by file patterns and detects DOH task completions
3. **Generates task description** following project standards
4. **Prompts for confirmation** with suggested description and option to edit

### Auto-Description Examples

```bash
# Called without parameters
/doh:changelog

# System analyzes changes and suggests:
# "DOH-123 user authentication implementation completed"
# Confirm for documentation updates? [Y/n/edit]:
```

## Pipeline Architecture

This command executes the core DOH documentation pipeline for .doh projects:

### 1. Documentation Updates

- **DOH Task Management**: Update .doh/tasks/ files, mark completed tasks, update timestamps
- **CHANGELOG Updates**: Add completed tasks to project CHANGELOG.md, update status, ensure formatting
- **Version Tracking**: Update project version metadata and completion timestamps
  - **Automatic Analysis**: Detects if changes warrant version bump based on impact
  - **User Confirmation**: Prompts for approval before applying version changes
  - **Impact Assessment**: Shows version change rationale (major/minor/patch)

### 2. Project Structure Adaptation

**Development** (/doh-dev):

- Source: todo/*.md files → TODO management
- Target: TODO.md, CHANGELOG.md in project root
- Context: DOH system development

**Runtime** (/doh):

- Source: .doh/tasks/*.json → DOH task management  
- Target: Project's CHANGELOG.md
- Context: User's project using DOH

### 3. Quality Assurance (Optional)

- **Calls `/doh:lint`** (if enabled): Applies intelligent auto-fix to updated documentation
  - **Auto-detection**: Only runs if .doh/config.ini has `lint_enabled = true`
  - **Respects project setup**: Uses project's own linting rules when available
  - **Graceful fallback**: Skips linting if not configured, continues pipeline
- **Preserves Project Files**: Maintains semantic content of project documentation
- **Optional consistency**: Standardizes formatting only when linting is enabled

## DOH Task Structure Integration

The command works with standard DOH task structure:

### Task File Format (.doh/tasks/DOH-123.json)

```json
{
  "id": "DOH-123",
  "title": "Implement user authentication",
  "status": "completed",
  "priority": "P1",
  "completed_date": "2025-08-28",
  "epic_id": "EPIC-001",
  "description": "Add JWT-based authentication system",
  "acceptance_criteria": [...],
  "implementation_notes": "Used bcrypt for password hashing"
}
```

### Changelog Integration

Completed tasks automatically generate changelog entries:

```markdown
## [1.2.1] - 2025-08-28

### Added
- **DOH-123**: User authentication system with JWT tokens
- **DOH-124**: Password reset functionality

### Changed
- **DOH-125**: Updated API response format for consistency
```

## Configuration Integration

Works with project-specific configuration in .doh/config.ini:

```ini
[pipeline]
changelog_format = keep-a-changelog  ; or custom
lint_enabled = true                  ; enable DOH linting (optional)
lint_rules = strict                  ; strict, standard, relaxed (if enabled)
commit_prefix = DOH                  ; DOH, TASK, or custom
auto_version_bump = true            ; enable version management

[project]
version_file = package.json         ; location of version info
changelog_file = CHANGELOG.md       ; changelog location
```

## Example Usage

```bash
# Auto-generate documentation updates
/doh:changelog

# Update with specific task description
/doh:changelog "DOH-123 - User authentication complete"

# Version tracking with confirmation (default behavior)
/doh:changelog "DOH-124 - Feature complete"
# → Analyzes impact, prompts: "Version 1.2.0 → 1.2.1 (feature completion)? [Y/n]"

# Check what would be updated
/doh:changelog --dry-run

# Skip version bump for minor updates
/doh:changelog "documentation updates" --no-version-bump --no-lint
```

## Integration with Other Commands

Works seamlessly with other `/doh:` commands:

```bash
# Typical workflow
/doh:lint                          # Clean up code quality
/doh:changelog "DOH-123 done"      # Update documentation
/doh:commit                        # Commit with auto-generated message

# Or use the full pipeline
/doh:commit "DOH-123 done"         # Does changelog + commit
```

## Output Format

Provides clear progress reporting:

```
📝 Project Documentation Updates: DOH-123 User Authentication
├── ✅ .doh/tasks/DOH-123.json updated (marked completed)
├── ✅ CHANGELOG.md updated (DOH-123 entry added)
├── ✅ .doh/metadata.json: task counters updated
├── 🔄 Version analysis: 1.2.0 → 1.2.1 (feature additions detected)
├── ✅ Version bump confirmed and applied to package.json
├── 🔧 Auto-fixed 2 documentation formatting issues
└── ✅ Documentation updates complete

Ready for commit. Next: /doh:commit (will use same description)
```

## Relationship to /doh:commit

This command executes steps 1-3 of the commit pipeline:

| Step                  | /doh:changelog | /doh:commit |
| --------------------- | -------------- | ----------- |
| DOH Task Management   | ✅             | ✅          |
| CHANGELOG Updates     | ✅             | ✅          |
| Version Tracking      | ✅             | ✅          |
| Documentation Linting | ✅             | ✅          |
| Git Staging           | ❌             | ✅          |
| Git Commit            | ❌             | ✅          |

## Use Cases

Perfect for situations where you need to:

- **Update documentation** before reviewing changes
- **Separate documentation** from code commits
- **Batch multiple tasks** before committing
- **Review changes** before making them permanent
- **Work in draft mode** while iterating

## Error Handling

Uses progressive error handling:

- **File conflicts**: Detects and reports merge issues in .doh/ structure
- **Format errors**: Applies intelligent auto-fixes to project documentation
- **Missing information**: Prompts for required details
- **Validation failures**: Reports issues with suggestions for DOH task format

## Migration from /doh-dev

Key differences for runtime use:

- **Task Source**: .doh/tasks/*.json instead of todo/*.md
- **Changelog Target**: Project CHANGELOG.md instead of DOH system CHANGELOG.md  
- **Version Source**: Project package.json/version files instead of VERSION.md
- **Configuration**: .doh/config.ini instead of hardcoded DOH system settings
- **ID Format**: DOH-### or custom prefix instead of T###

This command brings enterprise-grade documentation pipeline capabilities to every DOH-managed project while maintaining the intelligent automation and AI-driven optimizations of the /doh-dev equivalent.
