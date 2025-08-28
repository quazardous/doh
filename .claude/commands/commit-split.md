# /commit-split - Smart Semantic Commit Splitting

Quick access to intelligent commit splitting functionality - automatically analyzes staging area and creates multiple focused commits grouped by semantic meaning.

## Usage

```bash
/commit-split [task-completion] [--interactive] [--staged-focused] [--dry-run]
```

## Description

This is a shortcut command for `/doh-sys:commit --split` with enhanced usability for the most common semantic splitting scenarios. Perfect for when you have multiple logical units of work staged and want clean, focused commit history.

## Parameters

- `task-completion`: (Optional) Overall description of the work being committed
  - **Example**: `"T065 command beautification complete"`
  - **Smart usage**: Applied to first commit in sequence, others auto-generated
- `--interactive`: Review and confirm each commit in the split sequence
  - **Process**: Shows each planned commit with files and message for approval
  - **Control**: Edit messages, skip commits, or abort entire sequence
- `--staged-focused`: Process staged files + obvious semantic matches only
  - **Behavior**: Ignores unrelated unstaged/untracked files
  - **Smart matching**: Auto-stages files obviously related to staged work
- `--dry-run`: Preview the split plan without creating any commits

## Smart Splitting Algorithm

Prioritizes commits in this semantic order:

1. **Epic/TODO Updates** - `todo/*.md`, `NEXT.md`, epic documentation
2. **DOH System Changes** - `.claude/doh/` modifications, templates, scripts  
3. **Documentation Updates** - `README.md`, `WORKFLOW.md`, `DEVELOPMENT.md`
4. **Core Implementation** - Source code, main functionality changes
5. **Configuration** - Config files, package.json, build scripts
6. **Remaining Changes** - Everything else grouped logically

## Example Usage

```bash
# Basic semantic splitting
/commit-split
# Analyzes staging → creates focused commit sequence → clean history

# Interactive control over commits
/commit-split --interactive
# Review each → edit messages → skip unwanted → full control

# Focus on intentionally staged work
/commit-split --staged-focused  
# Staged files + obvious matches → ignore workspace clutter

# Preview without committing
/commit-split --dry-run
# Shows planned commits → perfect for validation

# Combined workflow
/commit-split "T065 complete" --interactive --staged-focused
# Epic completion → review each commit → focused approach
```

## Common Scenarios

**Epic Task Completion:**
```bash
/commit-split "T054 DOH memory system complete" --interactive
# → Commit 1: Epic/TODO updates
# → Commit 2: DOH system enhancements  
# → Commit 3: Documentation updates
# → Commit 4: Implementation details
```

**Mixed Development Session:**
```bash
/commit-split --staged-focused
# Clean commits for staged work → ignore unrelated changes
```

**Validation Before Committing:**
```bash
/commit-split --dry-run
# See the split plan → make adjustments → then execute
```

## Integration

This command is equivalent to:
```bash
/doh-sys:commit --split [same-parameters]
```

But provides:
- **Shorter syntax** for common splitting workflows
- **Focused documentation** on splitting-specific features
- **Quick access** to the most powerful commit organization feature

Perfect for developers who frequently work with complex staging areas and want clean, semantic commit history without the overhead of remembering the full `/doh-sys:commit` syntax.

## Success Criteria

- Produces the same semantic commit splitting as `/doh-sys:commit --split`
- Shorter, more memorable command for frequent use
- Clear documentation focused specifically on splitting workflows
- Maintains all safety and preview features of the parent command