# T087 Simplified Linting Architecture

**Created**: 2025-08-28  
**Status**: Implementation Design  
**Context**: Replace overly complex dual-linting system with clean, predictable enforcement

## 🚨 STRICT NEVER TO CROSS RULE

**NO COMMIT IF LINTING FAILS - NEVER EVER** (unless `--force` is explicitly passed by human developer)

## Current Problems (Before T087)

### **Root Cause**: Dual Linting Systems

1. **Pipeline Linting**: Claims to happen in `/dd:changelog` with complex decision trees
2. **Git Hook Linting**: Actually blocks commits at git level
3. **No Coordination**: These systems don't communicate, causing confusion

### **Symptoms**

- Users get linting errors at both pipeline AND git commit stages
- Documentation promises intelligent automation but requires manual `--no-verify` workarounds
- Split workflows become unusable due to repeated linting prompts
- Complex 4-option decision trees that confuse rather than help
- Auto-fixes work inconsistently, especially for TODO files

## New Architecture (Option 1)

### **Single Point of Enforcement**

```
/dd:commit → /dd:changelog (NO linting) → git commit (WITH pre-commit hooks)
                                               ↓
                                        [LINTING ENFORCEMENT POINT]
                                               ↓
                                      Pass → Commit succeeds
                                      Fail → Commit blocked (period)
```

### **Enforcement Logic**

```bash
# Default behavior
if linting_passes; then
    git commit -m "message"
    # → SUCCESS
else
    echo "❌ LINTING FAILED - COMMIT BLOCKED"
    echo "Fix issues or use --force to override"
    exit 1
fi

# Force override (explicit developer choice)
if --force_flag_passed; then
    git commit --no-verify -m "message"
    echo "⚠️  LINTING BYPASSED with --force"
    # → SUCCESS (but with clear warning)
fi
```

## Implementation Requirements

### **Remove from `/dd:changelog`**

- ❌ Delete all linting pipeline code
- ❌ Remove AI-powered fix attempts
- ❌ Remove pattern learning and feedback systems
- ❌ Remove complex decision trees
- ❌ Remove lenient mode logic
- ✅ Focus purely on documentation updates

### **Simplify `/dd:commit` Flags**

- **Remove**: `--lenient`, `--no-lint` (confusing, contradictory)
- **Keep**: `--force` (explicit override for `git commit --no-verify`)
- **Keep**: `--dry-run`, `--split`, `--interactive` (workflow features)
- **Keep**: `--amend`, `--no-version-bump` (git operation features)

### **Flag Behavior Matrix**

| Flag        | Git Command              | Linting     | Description                 |
| ----------- | ------------------------ | ----------- | --------------------------- |
| _(none)_    | `git commit`             | ✅ Enforced | Default strict behavior     |
| `--force`   | `git commit --no-verify` | ❌ Bypassed | Explicit developer override |
| `--dry-run` | _(no git)_               | ❌ Skipped  | Preview only                |

### **Split Mode Integration**

Each commit in split sequence follows the same simple rule:

1. **Pass 1 Commit**: `git commit` → linting enforced → success or block
2. **Pass 2 Commit**: `git commit` → linting enforced → success or block
3. **If any commit fails**: User must fix issues or use `--force`

**No special handling**, no prompts, no complexity.

## User Experience

### **Clean Success Path**

```bash
/dd:commit "T087 implementation"
# → Documentation updates
# → git commit -m "..."
# → ✅ Success (linting passed)
```

### **Clean Failure Path**

```bash
/dd:commit "T087 implementation"
# → Documentation updates
# → git commit -m "..."
# → ❌ LINTING FAILED - COMMIT BLOCKED
# → Fix issues or use --force to override

# Developer fixes issues
make lint-fix
/dd:commit "T087 implementation"
# → ✅ Success

# OR developer forces override
/dd:commit "T087 implementation" --force
# → ⚠️ LINTING BYPASSED with --force
# → ✅ Success (but with warning)
```

### **Split Mode Experience**

```bash
/dd:commit --split "T087 implementation"
# → Pass 1: git commit → linting fails → BLOCKED
# → "❌ LINTING FAILED on commit 1/2 - Fix issues or use --force"

# Fix and retry
make lint-fix
/dd:commit --split "T087 implementation"
# → Pass 1: git commit → ✅ success
# → Pass 2: git commit → ✅ success
```

## Documentation Cleanup

### **Remove from `/dd:commit` docs**

- Complex "Claude AI Linting Decision Protocol" (lines 475-495)
- "Fixed Architecture: Linting in Changelog Pipeline" (lines 497-533)
- "Interactive Decision Flow" examples (lines 539-562)
- "Smart Flag Integration" for lenient modes (lines 564-595)
- "Error Classification & AI Success Tracking" (lines 597-612)
- "Feedback-Driven Optimization" (lines 613-641)

### **Replace with**

````markdown
## Linting Enforcement

The command enforces documentation quality through git pre-commit hooks with strict enforcement:

### **STRICT RULE: NO COMMIT IF LINTING FAILS**

- **Default behavior**: `git commit` respects pre-commit hooks
- **Linting failure**: Commit blocked, must fix issues or use `--force`
- **Force override**: `--force` flag uses `git commit --no-verify`

### Usage Examples

```bash
# Standard commit (linting enforced)
/dd:commit "T087 implementation"

# Force override (bypasses linting)
/dd:commit "T087 implementation" --force

# Split mode (each commit enforced)
/dd:commit --split "T087 implementation"
```
````

**No complex decision trees, no prompts, no bypass modes.**

```

## Benefits of Simplified Architecture

### **Predictability**
- ✅ Linting fails → commit blocked (always)
- ✅ Developer knows exactly what to expect
- ✅ No hidden bypasses or automatic lenient modes

### **Performance**
- ✅ No AI-powered pipeline processing
- ✅ No pattern analysis or feedback systems
- ✅ Faster execution, single decision point

### **Maintainability**
- ✅ Single linting enforcement point (git hooks)
- ✅ No coordination between multiple systems
- ✅ Simple logic, fewer edge cases

### **User Experience**
- ✅ Clear failure messages with actionable solutions
- ✅ Explicit `--force` for intentional bypasses
- ✅ Works predictably with split mode

## Migration Checklist

- [ ] Remove linting code from `/dd:changelog` command
- [ ] Update `/dd:commit` documentation (remove complex sections)
- [ ] Remove `--lenient` and `--no-lint` flags
- [ ] Test split mode with new behavior
- [ ] Update command help text
- [ ] Verify pre-commit hook configuration
- [ ] Test force override functionality

**Result**: Clean, predictable, maintainable linting enforcement that developers can trust and understand.
```
