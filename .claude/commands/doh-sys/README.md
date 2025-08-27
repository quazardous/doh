# DOH System Commands - Architecture and Shared Components

The `/doh-sys:` command family provides intelligent automation for DOH development workflows. These commands share
significant functionality and can be factorized for maintainability.

## Command Overview

| Command              | Purpose       | Architecture                                       | Default Behavior       |
| -------------------- | ------------- | -------------------------------------------------- | ---------------------- |
| `/doh-sys:lint`      | Code quality  | **Base layer** - Auto-fix linting                  | **Auto-fix enabled**   |
| `/doh-sys:changelog` | Documentation | **Calls** `/doh-sys:lint` + TODO/CHANGELOG/Version | Documentation pipeline |
| `/doh-sys:commit`    | Full pipeline | **Calls** `/doh-sys:changelog` + Git operations    | Full automation        |

## Shared Components (Factorization Opportunities)

### 1. Auto-Description Generation Engine

**Used by**: `changelog`, `commit` **Location**: Should be extracted to shared module

```typescript
interface DescriptionGenerator {
  analyzeGitChanges(): GitChangeAnalysis;
  categorizeChanges(analysis: GitChangeAnalysis): ChangeCategory[];
  detectTodoCompletions(changes: ChangeCategory[]): TodoCompletion[];
  generateDescription(categories: ChangeCategory[]): string;
  promptForConfirmation(suggested: string): string;
}
```

### 2. TODO Management Engine

**Used by**: `changelog`, `commit` **Location**: Should be extracted to shared module

```typescript
interface TodoManager {
  markTaskCompleted(taskId: string): void;
  updateTimestamp(): void;
  incrementNextId(): void;
  moveToArchived(taskIds: string[]): void;
  validateTodoStructure(): ValidationResult;
}
```

### 3. CHANGELOG Update Engine

**Used by**: `changelog`, `commit` **Location**: Should be extracted to shared module

```typescript
interface ChangelogManager {
  addCompletedTask(task: CompletedTask): void;
  updateSessionSection(tasks: CompletedTask[]): void;
  ensureProperFormatting(): void;
  linkAnalysisDocuments(task: CompletedTask): void;
}
```

### 4. Intelligent Linting Engine

**Used by**: `lint`, `changelog`, `commit` **Location**: Core shared module

```typescript
interface LintingEngine {
  applyPriorityFixes(files: string[]): FixResult[];
  smartLineWrapping(content: string): string;
  progressiveErrorHandling(errors: LintError[]): void;
  preserveAnalysisDocuments(files: string[]): void;
}
```

### 5. Version Management Engine

**Used by**: `changelog`, `commit` **Location**: Should be extracted to shared module

```typescript
interface VersionManager {
  checkVersionBumpWarrant(changes: ChangeAnalysis): boolean;
  updateVersionTracking(task: CompletedTask): void;
  bumpVersion(type: "major" | "minor" | "patch"): void;
  maintainVersionHistory(): void;
}
```

## Proposed Factorized Architecture

### Core Shared Module: `doh-sys-core.md`

```markdown
# Shared functionality for all /doh-sys: commands

- Auto-description generation
- TODO management operations
- CHANGELOG update operations
- Intelligent linting engine
- Version management
- Error handling patterns
- File analysis utilities
```

### Layered Architecture

Clean composition eliminates duplication:

```markdown
# /doh-sys:lint (Base Layer)

- Core: Auto-fix linting engine
- Standalone: File filtering, priority-based repairs

# /doh-sys:changelog (Documentation Layer)

- Calls: /doh-sys:lint for quality assurance
- Adds: TODO/CHANGELOG/Version management pipeline

# /doh-sys:commit (Git Layer)

- Calls: /doh-sys:changelog for documentation updates
- Adds: Git staging, commit message generation, pre-commit handling
```

**Benefits**: No code duplication, clear separation of concerns, composable functionality.

## Implementation Strategy

### Phase 1: Extract Common Patterns

1. **Create shared parameter handling**: `--dry-run`, `--verbose`, `--no-lint`
2. **Standardize output formatting**: Progress indicators, error messages
3. **Unify file detection logic**: Git change analysis, file categorization

### Phase 2: Create Shared Engines

1. **TODO/CHANGELOG engines**: Extract update logic from commit.md
2. **Description generator**: Extract from commit.md auto-label generation
3. **Linting engine**: Extract from lint.md intelligent auto-fix

### Phase 3: Refactor Commands

1. **Update each command** to use shared modules
2. **Maintain API compatibility** - no breaking changes to usage
3. **Add cross-references** between commands in documentation

## Benefits of Factorization

### Maintainability

- **Single source of truth** for common operations
- **Easier bug fixes** - fix once, applies to all commands
- **Consistent behavior** across all `/doh-sys:` commands

### Extensibility

- **New commands** can reuse existing engines
- **Feature additions** benefit all commands simultaneously
- **Testing** can focus on shared components

### User Experience

- **Consistent parameters** across commands
- **Predictable behavior** - same auto-fix logic everywhere
- **Interoperability** - commands work well together

## Cross-Command Workflows

The factorized architecture enables powerful workflows:

```bash
# Individual steps
/doh-sys:lint --files="docs/*.md"     # Auto-fix specific files
/doh-sys:changelog "T040 completed"   # Update documentation
/doh-sys:commit                       # Commit with auto-generated message

# Pipeline combinations
/doh-sys:changelog --dry-run          # Preview documentation updates
/doh-sys:lint --check-only            # Report-only (no auto-fixes)
/doh-sys:commit --no-lint             # Skip redundant linting

# Advanced workflows
/doh-sys:changelog T040 && /doh-sys:commit  # Chain operations
```

This architecture maintains the individual command simplicity while providing powerful shared functionality and clear
upgrade paths.
