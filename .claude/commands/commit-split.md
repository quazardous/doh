# /commit-split - DEPRECATED: Use /dd:commit --split

**⚠️ DEPRECATION NOTICE**: This command has been consolidated into `/dd:commit --split` for architectural consistency and enhanced functionality. Please migrate to the new unified interface.

## Migration Guide

**Old Command** → **New Equivalent**
```bash
/commit-split                           → /dd:commit --split  (or /dd:commit -s)
/commit-split --interactive             → /dd:commit -si
/commit-split --staged-focused          → /dd:commit -sf  
/commit-split --dry-run                → /dd:commit -sd
/commit-split "T084" --interactive      → /dd:commit -si "T084"
```

## Enhanced Features in /dd:commit --split

The new unified command provides all /commit-split functionality plus:

- ✅ **Enhanced staging management**: Three distinct modes (default, --staged-focused, --staged-only)
- ✅ **Smart extension algorithm**: Related file detection in --staged-focused mode  
- ✅ **Complete pipeline integration**: Linting, version bumps, changelog updates
- ✅ **Convenience shortcuts**: `-si`, `-sf`, `-so`, `-sd` combinations
- ✅ **"Clean working directory" philosophy**: Predictable behavior by default
- ✅ **Auto-detection suggestions**: Smart recommendations for when to split

**Please update your workflows to use `/dd:commit --split` instead of this deprecated command.**

---

## Legacy Documentation (For Reference Only)

~~Quick access to intelligent commit splitting functionality - automatically analyzes staging area and creates multiple focused commits grouped by semantic meaning.~~

## ~~Usage~~ (DEPRECATED)

```bash
# DEPRECATED - Use these instead:
/dd:commit --split [task-completion] [flags...]
/dd:commit -si "task-completion"    # --split --interactive shortcut
/dd:commit -sf "task-completion"    # --split --staged-focused shortcut  
/dd:commit -sd "task-completion"    # --split --dry-run shortcut
```

## Description

This is a shortcut command for `/dd:commit --split` with enhanced usability for the most common semantic splitting scenarios. Perfect for when you have multiple logical units of work staged and want clean, focused commit history.

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
/dd:commit --split [same-parameters]
```

But provides:
- **Shorter syntax** for common splitting workflows
- **Focused documentation** on splitting-specific features
- **Quick access** to the most powerful commit organization feature

~~Perfect for developers who frequently work with complex staging areas and want clean, semantic commit history without the overhead of remembering the full `/dd:commit` syntax.~~

## ~~Success Criteria~~ (DEPRECATED)

~~- Produces the same semantic commit splitting as `/dd:commit --split`~~  
~~- Shorter, more memorable command for frequent use~~  
~~- Clear documentation focused specifically on splitting workflows~~  
~~- Maintains all safety and preview features of the parent command~~

---

## ⚠️ THIS COMMAND IS DEPRECATED

**Please use `/dd:commit --split` instead.** The new unified command provides all the functionality of /commit-split plus enhanced features:

- **Better staging management** with "Clean Working Directory" philosophy
- **Smart extension algorithm** for related file detection
- **Complete pipeline integration** with linting and version bumps
- **Convenient shortcuts** like `-si`, `-sf`, `-so`, `-sd`
- **Single, consistent interface** for all commit operations

**Quick migration**:
```bash
# Instead of this deprecated command:
/commit-split "T084 complete" --interactive

# Use this enhanced equivalent:
/dd:commit -si "T084 complete"
```

See `/dd:commit` documentation for complete details on the enhanced functionality.