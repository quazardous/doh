# /dd:next - AI-Powered TODO Analysis & Task Recommendation Engine

Intelligent task prioritization system that analyzes TODO dependencies, developer context, and project priorities to
suggest the optimal next tasks with natural language interaction support.

## Claude AI Execution Protocol

**Primary Workflow Steps**:

1. **Parse parameters and context** - Extract query, flags, and project context (--internal, --context, --format)
2. **Select appropriate cache** - Choose todo/NEXT.md (runtime) or todo/NEXT-dd.md (internal) based on --internal flag
3. **Check cache freshness** - Read Unix timestamp from cache file first line, compare with 3600 second threshold
4. **Execute mode decision**:
   - **IF cache fresh (<1hr) AND no --refresh**: Use cache-only mode for sub-100ms response
   - **IF cache stale (>1hr) OR --refresh specified**: Perform fresh analysis and update cache
   - **IF --no-cache specified**: Skip cache entirely, pure analysis mode
5. **Process recommendations** - Parse cache content or perform live analysis of todo/ files
6. **Apply filters and formatting** - Process --context, --limit, --format parameters for output
7. **Return results** - Provide task recommendations with explanations and context

## Usage

```bash
/dd:next [query] [--context=focus] [--project=type] [--internal] [--format=output] [--limit=N] [--refresh] [--cache-only] [--no-cache]
```

## Parameters

### Primary Input

- `query`: (Optional) Natural language query about what to work on
  - **Examples**: `"what can I do that's high impact"`, `"show me documentation tasks"`, `"what's ready to start"`
  - **Smart matching**: Understands intent and maps to appropriate filters
  - **If omitted**: Shows top priority tasks based on current project state

### Context Filtering

- `--context=focus`: Filter recommendations by development area
  - `docs` - Documentation and writing tasks (README, WORKFLOW, TODO updates)
  - `build` - Build system and architecture tasks
  - `testing` - Testing, QA, and quality assurance tasks
  - `features` - Core functionality development and implementation
  - `quick` - Tasks that can be completed in under 2 hours
  - `blocked` - Show what's currently blocking other tasks (dependencies)
  - **Smart detection**: Analyzes task tags and descriptions for automatic categorization

### Project Filtering

- `--project=type`: Filter tasks by project context for isolation
  - `doh-dev` - Internal development support and tooling (dd-x.x.x versioning)
  - `doh-runtime` - Public distribution and end-user features (doh-x.x.x versioning)
  - `all` - Show both projects with clear separation (default behavior)
  - **Dependency isolation**: Respects project boundaries, warns on cross-project dependencies

- `--internal`: Convenient shorthand for `--project=doh-dev`
  - **Focus**: DOH-DEV internal development tasks (dd-x.x.x versioning)
  - **Default behavior**: Without this flag, focuses on DOH runtime user features (doh-x.x.x)
  - **Equivalent to**: `--project=doh-dev` for streamlined workflow
  - **Task indicators**: Version files `dd-*.md`, internal tooling, command enhancements

### Output Control

- `--format=output`: Control the level of detail in responses
  - `brief` - Concise task list with key information (default)
  - `detailed` - Full analysis with reasoning, dependencies, and impact
  - `plan` - Step-by-step implementation plan for recommended tasks
  - **Adaptive**: Format adjusts based on query complexity

- `--limit=N`: Maximum number of tasks to suggest
  - **Default**: 3-5 tasks (optimal for decision making)
  - **Range**: 1-20 (automatically caps at available tasks)
  - **Smart limiting**: Prioritizes most relevant tasks

### Performance Modes

**Default Behavior - Hybrid Mode** (New):

- **Automatic optimization**: Checks cache age and decides best approach
- **Fresh cache (<1 hour)**: Uses cache-only mode for sub-100ms response
- **Stale cache (>1 hour)**: Performs fresh analysis and updates cache
- **Smart balance**: Speed when possible, accuracy when needed
- **No flags required**: Optimal performance by default

#### Explicit Performance Flags

- `--cache-only`: Force ultra-fast mode using smart memory
  - **Speed**: Sub-100ms response time guaranteed
  - **Source**: Reads from todo/NEXT.md (default) or todo/NEXT-dd.md (with --internal)
  - **Use when**: Speed critical, scripting, or rapid iterations
  - **Note**: May use outdated data regardless of cache age

- `--refresh`: Force complete re-analysis
  - **Ignores**: Existing cache files (NEXT.md or NEXT-dd.md based on context)
  - **Rebuilds**: Complete task analysis from current todo/ folder state
  - **Use when**: Major task changes, ensure absolute accuracy
  - **Slower**: Takes 3-5 seconds but guarantees current accuracy

- `--no-cache`: Pure analysis without memory
  - **Clean slate**: Ignores memory files entirely
  - **No updates**: Doesn't update cache files with results
  - **Use when**: Testing, debugging, or when memory files are problematic

## Smart Memory System

The command uses dual cache files for project isolation and performance optimization.

### Dual Cache Architecture

- **todo/NEXT.md**: DOH Runtime cache (default) - VDOH-1.4.0 tasks, user features, distribution
- **todo/NEXT-dd.md**: DOH-DEV Internal cache - VDD-0.1.0 tasks, /dd:\* commands, developer tools

Cache selection is automatic based on context:

- Default behavior uses `todo/NEXT.md` for runtime tasks
- `--internal` flag uses `todo/NEXT-dd.md` for internal development tasks

Cache file format:

- **Line 1**: Unix timestamp (seconds since epoch) for cache generation time
- **Rest of file**: Task recommendations and analysis in markdown format

### Version Goal Awareness

The command reads `todo/doh-*.md` and `todo/dd-*.md` version files to understand:

- Current version philosophy and goals (Must Have/Should Have/Should NOT Have)
- Version constraints that affect task selection
- Key strategic decisions that guide recommendations
- Progress context (~XX% completion estimates)

Version awareness ensures task recommendations align with strategic goals and respects version constraints like "Should
NOT Have: External API dependencies" for v1.4.0.

### Memory Architecture

- **Context isolation**: Separate caches prevent project cross-contamination
- **Version awareness**: Each cache tracks its respective version (VDOH-1.4.0 vs VDD-0.1.0)
- **Project classification**: Pre-computed DOH-DEV vs DOH Runtime task categorization
- **Pre-computed queries**: Common searches like "version 1.4", "quick wins", "high impact", "internal tasks"
  pre-calculated
- **Smart context matching**: Natural language queries instantly mapped to stored results including `--internal` context
- **Hybrid freshness check**: Auto-uses cache if <3600 seconds old, else refreshes (default behavior)
- **Auto-update**: Memory refreshed when stale or with `--refresh` flag
- **Extreme speed**: Sub-100ms responses when cache is fresh (<1 hour old)

## AI Analysis Engine

The command performs comprehensive intelligent analysis with memory optimization:

### 1. Dependency Mapping

- **Parses todo/ files** for individual task files and status (excludes todo/archive/ only)
- **Includes COMPLETED tasks**: Maintains dependency context from finished work in active epics
- **Identifies blockers**: Tasks marked as dependencies for others
- **Maps ready tasks**: Tasks with all dependencies completed
- **Calculates impact**: How many other tasks depend on this one
- **Stores results**: Saves analysis in todo/NEXT.md for Claude's memory
- **Archive Exclusion**: Ignores todo/archive/ directory for performance, keeps completed tasks in todo/ root

### 2. Context-Aware Filtering

- **Tag analysis**: Processes #doc, #build, #testing, #features tags
- **Project classification**: Identifies DOH-DEV Internal vs DOH Runtime tasks
  - **DOH-DEV Internal**: Version files `dd-*.md`, command enhancements, internal tooling
  - **DOH Runtime**: Version files `doh-*.md`, user-facing features, public distribution
- **Status tracking**: Differentiates IN PROGRESS, COMPLETED, and pending tasks
- **Priority parsing**: Extracts High/Medium/Low priority indicators
- **Complexity estimation**: Analyzes task descriptions for effort indicators
- **Cross-project dependency detection**: Warns when tasks cross project boundaries
- **Internal flag processing**: Automatically filters for DOH-DEV tasks when `--internal` used

### 3. Natural Language Processing

- **Intent recognition**: Understands queries like "what should I work on next?"
- **Context matching**: Maps natural language to technical categories
- **Smart filtering**: Interprets phrases like "high impact", "quick wins", "documentation work"
- **Project classification**: Recognizes "internal development", "runtime features", "command enhancements"
- **Auto-flag mapping**: Automatically applies `--internal` for DOH-DEV context queries
- **Conversational responses**: Provides explanations in natural language

### 4. Intelligent Prioritization Algorithm

**Priority Score Calculation**:

```
Priority Score = Base Priority × Dependency Weight × Context Relevance × Impact Factor
```

**Factors**:

- **Base Priority**: Explicit High (3.0), Medium (2.0), Low (1.0) or inferred from 🚩 flags
- **Dependency Weight**: 2.0 if no blockers, 0.5 if dependencies remain, 0.1 if blocked
- **Context Relevance**: 2.0 if matches user context/query, 1.0 baseline, 0.5 if mismatched
- **Impact Factor**: 1.5 if blocks other tasks, 1.0 baseline, 2.0 if critical path item

## Usage Examples & Smart Auto-completion

### 💡 Quick Start - Most Common Patterns

```bash
# 🚀 Most common: Get top recommendations (NEW HYBRID MODE)
/dd:next
# Auto-optimized: Uses cache if <1hr old, else refreshes → Best speed/accuracy

# 🎯 Context-specific filtering
/dd:next --context=docs
# Shows documentation tasks → README, WORKFLOW, TODO updates (hybrid mode)

# 🔧 Internal development focus
/dd:next --internal
# Shows DOH-DEV internal tasks → uses NEXT-dd.md cache (hybrid mode)

# ⚡ Force ultra-fast mode
/dd:next --cache-only
# Sub-100ms guaranteed → ignores cache age, always uses memory

# 🔄 Force fresh analysis
/dd:next --refresh
# 3-5 seconds → always performs full analysis regardless of cache age
```

### 🗣️ Natural Language Query Examples

### Development Focus Queries

```bash
/dd:next "what can I work on while the build system is being designed?"
# AI Response: Analyzes DOH032 (build) as blocked, suggests parallel work on DOH027 (linting), DOH037 (cleanup)

/dd:next "show me some quick wins I can complete today"
# AI Response: Filters for tasks with simple deliverables and clear scope

/dd:next "what documentation needs attention?"
# AI Response: Filters #doc tagged tasks, analyzes completion gaps in README/WORKFLOW/DEVELOPMENT docs

/dd:next "internal tooling improvements"
# AI Response: Auto-maps to --internal flag, shows DOH-DEV command enhancements and dev workflow tasks

/dd:next "what runtime features are ready?"
# AI Response: Focuses on VDOH-1.4.0 tasks, user-facing features, public distribution work
```

### Priority and Impact Queries

```bash
/dd:next "what's the most important thing to work on right now?"
# AI Response: Calculates highest priority×impact score, explains reasoning

/dd:next "what's blocking the most other work?"
# AI Response: Identifies bottleneck tasks that are dependencies for multiple others

/dd:next "what can I do that will unblock the most tasks?"
# AI Response: Prioritizes tasks that are blocking dependencies for others
```

### Contextual Development Queries

```bash
/dd:next "I want to work on testing"
# AI Response: Shows DOH024, DOH019, DOH027 with testing focus, explains relationships

/dd:next "what build system work is ready?"
# AI Response: Analyzes DOH032, DOH003, DOH005 build-related tasks and their readiness

/dd:next "I have 2 hours, what should I tackle?"
# AI Response: Suggests appropriately-scoped tasks based on complexity analysis
```

### Smart Memory Queries

```bash
# Version-specific tasks (pre-computed in memory)
/dd:next "version 1.4"
# Returns: Epic EDOH001 tasks with phase breakdown instantly

# Pre-computed quick wins
/dd:next "quick wins"
# Returns: DOH037 (1h), DOH056 (1.5h), DOH008 (2h) from memory

# High-impact tasks (instant from memory)
/dd:next "high impact"
# Returns: DOH032, DOH054 with unlock explanations

# Extreme speed with memory-only mode
/dd:next --cache-only                    # Uses todo/NEXT.md for Runtime tasks
/dd:next --cache-only --context=build    # Uses todo/NEXT.md for Runtime build tasks
/dd:next --internal --cache-only         # Uses todo/NEXT-dd.md for DOH-DEV tasks
/dd:next --cache-only "what next after t054"  # Runtime context from NEXT.md
# All return sub-100ms responses from appropriate cache

# Fresh analysis without memory (testing/debugging)
/dd:next --no-cache
/dd:next --no-cache "high impact tasks"
/dd:next --no-cache --context=testing --format=detailed
# Pure analysis from current TODO files, ignores memory entirely
```

### 🔧 Smart Flag Combinations & Context Suggestions

```bash
# 📋 Context + Format combinations
/dd:next --context=quick --format=plan
# Quick tasks → with implementation plans → ready to execute

/dd:next --context=docs --limit=2
# Documentation focus → only top 2 → avoid choice paralysis

/dd:next --context=blocked --format=detailed
# Show blockers → with full analysis → understand dependencies

# 🔧 Internal development combinations
/dd:next --internal --context=testing --format=detailed
# DOH-DEV internal testing tools → detailed analysis → development focus

/dd:next --internal --cache-only
# Fast internal task recommendations → from memory → dev workflow

/dd:next --internal "quick wins"
# DOH-DEV quick tasks → command enhancements, workflow improvements

# ⚡ Performance optimization patterns
/dd:next --cache-only --context=features
# Fast feature recommendations → from memory → rapid workflow

/dd:next --refresh --format=detailed
# Force fresh analysis → detailed reasoning → major project changes

/dd:next --no-cache --context=testing --limit=1
# Pure analysis → testing focus → single recommendation → debugging mode
```

### 📊 Context-Aware Smart Suggestions

**When Claude detects large TODO backlog:**

```bash
/dd:next --context=quick --limit=3
# 💡 Auto-suggested: Focus on quick wins to build momentum
# Shows 3 tasks under 2 hours each
```

**When many documentation tasks pending:**

```bash
/dd:next --context=docs --format=plan
# 💡 Auto-suggested: Documentation sprint with implementation plans
# Perfect for focused documentation sessions
```

**When project has complex dependencies:**

```bash
/dd:next --context=blocked --format=detailed
# 💡 Auto-suggested: Understand what's blocking progress
# Full dependency analysis and resolution strategies
```

**When memory might be stale:**

```bash
/dd:next --refresh
# 💡 Auto-suggested: After major task completions or status changes
# Ensures recommendations reflect current reality
```

### 🔄 Common Workflow Integration Patterns

**Morning Planning Session:**

```bash
# 1. Quick overview from memory
/dd:next --cache-only --limit=5

# 2. Deep dive on top recommendation
/dd:next --format=plan --limit=1
# → Get implementation plan for chosen task
```

**Context Switching:**

```bash
# 1. Finished documentation work, want technical task
/dd:next "I just finished docs work, show me technical tasks"

# 2. Blocked on current work, need alternatives
/dd:next --context=quick "what can I do while waiting?"
```

**Epic Completion Check:**

```bash
# 1. Check version-specific progress
/dd:next "version 1.4" --cache-only

# 2. See what's blocking epic completion
/dd:next --context=blocked --format=detailed
```

### ⚡ Performance Mode Selection Guide

| Scenario             | Recommended Mode | Reason                                                 |
| -------------------- | ---------------- | ------------------------------------------------------ |
| Normal workflow      | (default hybrid) | Auto-optimizes: fast if cache fresh, accurate if stale |
| Rapid iterations     | `--cache-only`   | Force sub-100ms response regardless of cache age       |
| After major changes  | `--refresh`      | Force fresh analysis to capture all updates            |
| Debugging/testing    | `--no-cache`     | Clean slate analysis without cache interference        |
| Scripting/automation | `--cache-only`   | Predictable fast response for scripts                  |

### 🎯 Smart Query Interpretation Examples

Claude Code will intelligently map natural language to technical filters:

```bash
# Intent: "I want to be productive quickly"
/dd:next "quick wins"
# → Maps to: --context=quick --limit=3

# Intent: "What's holding up the project?"
/dd:next "what's blocking progress"
# → Maps to: --context=blocked --format=detailed

# Intent: "I want to work on core features"
/dd:next "show me feature development"
# → Maps to: --context=features --format=brief

# Intent: "I want to work on internal tooling"
/dd:next "internal development"
# → Maps to: --internal --format=brief

# Intent: "Show me DOH system improvements"
/dd:next "command enhancements"
# → Maps to: --internal --context=features

# Intent: "What runtime work is ready?"
/dd:next "runtime features"
# → Maps to: --project=doh-runtime --format=brief

# Intent: "Need a detailed plan for next task"
/dd:next --format=plan --limit=1
# → Provides step-by-step implementation guide
```

## Smart Response Formats

### Brief Format (Default)

```
🎯 Next Recommended Tasks (3 of 47 total)

1. **DOH037** - Clean up old project references (#doc, High Priority)
   ├── 🟢 Ready to start (no blockers)
   ├── ⏱️  Estimated: 1-2 hours
   └── 🎯 Impact: Unblocks DOH034 Phase 3, improves documentation quality

2. **DOH027** - Implement Markdown Linting System (#testing, Medium Priority)
   ├── 🟢 Ready to start (discussed, well-scoped)
   ├── ⏱️  Estimated: 2-4 hours
   └── 🎯 Impact: Enables automated quality control for all docs

3. **DOH041** - Remove attribution comments (COMPLETED)
   ├── ✅ Task completed successfully
   ├── ⏱️  Time taken: 45 minutes
   └── 🎯 Impact: Clean commit history, professional codebase presentation
```

### Internal Development Format (`--internal`)

```
🔧 DOH-DEV Internal Tasks (3 of 12 total)

1. **DD073** - Add --internal flag to /dd:next command (Medium Priority)
   ├── 🟢 Ready to start (epic-less, standalone)
   ├── ⏱️  Estimated: 1-2 hours
   └── 🎯 Impact: DOH-DEV vs Runtime filtering in task recommendations

2. **DD072** - Rename /doh-dev Commands to /dd (COMPLETED)
   ├── ✅ DOH-DEV system enhancement completed
   ├── ⏱️  Time taken: 3 hours
   └── 🎯 Impact: Streamlined command interface for developers

3. **VDD-0.1.0** - DOH-DEV Internal System Enhancement
   ├── 🟡 30% complete (6 of 20 features implemented)
   ├── ⏱️  Next milestone: Testing framework integration
   └── 🎯 Impact: Enhanced development workflow and tooling
```

### Detailed Format

```
🧠 AI Analysis: TODO Prioritization Report

## Dependency Analysis
✅ **Ready to Start**: 12 tasks with no blockers
🟡 **Waiting**: 8 tasks with pending dependencies
🔴 **Blocked**: 3 tasks with incomplete dependencies

## Top Recommendation: DOH037 (Score: 8.5/10)

**Task**: Clean up old project references (example projects)
**Category**: Documentation (#doc)
**Priority**: High 🚩

**Why This Task:**
- ✅ **No blockers**: All dependencies completed
- 🎯 **High impact**: Mentioned in 4 other task descriptions
- ⚡ **Quick completion**: Well-defined scope, 1-2 hour estimate
- 🔗 **Enables**: DOH034 Phase 3, general documentation quality improvements
- 🏃 **Momentum**: Builds on completed DOH034, DOH030, DOH035 documentation work

**Implementation Approach:**
1. Scan all .md files for outdated project references
2. Replace with current project context ("DOH", "quazardous/doh")
3. Update examples and paths to reflect current structure
4. Validate no broken links introduced
```

### Plan Format

```
📋 Implementation Plan: DOH037

## Step-by-Step Execution
1. **Discovery Phase** (15min)
   - Search codebase for outdated project references
   - Catalog all occurrences with context

2. **Replacement Phase** (45min)
   - Update project references to "quazardous/doh"
   - Fix file paths to current structure
   - Update examples to use DOH context

3. **Validation Phase** (30min)
   - Test all updated links and paths
   - Verify documentation still makes sense
   - Run /doh-sys:lint to ensure quality

## Risk Assessment: Low
- Well-defined scope prevents scope creep
- Search/replace operations are reversible
- Documentation-only changes reduce system risk

## Success Criteria
- [ ] All outdated project references updated
- [ ] No broken links introduced
- [ ] Documentation maintains coherence
- [ ] Linting passes cleanly
```

## Context-Aware Intelligence

### Project Phase Detection

The AI analyzes the overall project state to provide phase-appropriate suggestions:

- **Foundation Phase**: Prioritizes DOH003, DOH004, DOH005 (architecture/distribution)
- **Quality Phase**: Emphasizes DOH024, DOH027, DOH019 (testing/linting)
- **Feature Phase**: Focuses on DOH020, DOH021, DOH017 (core functionality)
- **Polish Phase**: Suggests DOH037, DOH008, documentation tasks

### Workload Balancing

- **Heavy Development**: Suggests alternating with documentation tasks
- **Documentation Focus**: Recommends technical implementation tasks for balance
- **Testing Phase**: Identifies gaps in test coverage and quality systems

### Skill Context Adaptation

Adapts suggestions based on inferred developer preferences:

- **Documentation-heavy recent commits**: Suggests more technical tasks
- **Feature implementation patterns**: Recommends complementary testing/docs
- **System architecture focus**: Prioritizes foundational tasks

## Error Handling & Edge Cases

### Invalid TODO.md Structure

- **Graceful degradation**: Falls back to basic task listing if dependency parsing fails
- **Self-healing**: Reports TODO.md issues and suggests fixes
- **Partial analysis**: Provides best-effort recommendations even with incomplete data

### Circular Dependencies

- **Detection**: Identifies and reports circular dependency chains
- **Resolution**: Suggests dependency restructuring or task splitting
- **Bypass**: Recommends tasks outside the circular chain

### Context Mismatches

- **Clarification**: Asks follow-up questions for ambiguous queries
- **Alternative suggestions**: Offers closest matches when exact query impossible
- **Learning**: Adapts to user's working patterns over time

## Integration Points

### With Other doh-dev Commands

- **Post-completion hook**: Automatically suggests next task after `/dd:commit`
- **Memory refresh**: `/dd:commit` and `/dd:changelog` auto-update todo/NEXT.md
- **Dependency updates**: Integrates with `/dd:changelog` to update dependencies
- **Quality gates**: Considers `/dd:lint` results in task readiness assessment
- **Smart updates**: Other commands can append memory updates instead of full re-computation

### With DOH System

- **Task linking**: Suggests creating /doh tasks for complex TODOs
- **Epic correlation**: Maps TODO items to Epic/Feature structure when applicable
- **Progress tracking**: Uses DOH task completion to update TODO analysis

## Example Conversation Flows

### Getting Started

```
User: /dd:next
AI: 🎯 Based on current project state, I recommend DOH037 (cleanup old references).
    It's ready to start, high impact, and builds on your recent documentation work.
    Would you like details or alternatives?

User: show me alternatives
AI: 📋 Alternative options:
    • DOH027 (markdown linting) - technical implementation, good variety
    • DOH041 (attribution cleanup) - continue current work in progress
    • DOH032 (build design) - foundational but more complex
    Which interests you?
```

### Context-Driven Selection

```
User: /dd:next "I want something technical after all this documentation work"
AI: 🔧 Perfect! Based on your recent doc focus, I recommend DOH027 (Markdown Linting System).
    Technical implementation with clear scope, builds testing infrastructure,
    and complements your documentation work. Ready to start with no blockers.

User: /dd:next --format=plan
AI: [Provides detailed DOH027 implementation plan]
```

### Workflow Integration

```
User: [After completing a task]
/doh-sys:commit "Completed DOH037 cleanup"

AI: [Auto-suggestion] 🎯 DOH037 complete! Next recommendation: DOH027 (linting system)
    Your cleanup work removed inconsistencies - perfect time to add automated quality control.
    Continue the quality improvement momentum?
```

## Implementation Architecture

This command is executed entirely by Claude's AI logic with smart memory:

### Execution Modes

#### Hybrid Mode (Default - NEW)

1. **Cache Selection**: Choose NEXT.md (default) or NEXT-dd.md (--internal flag)
2. **Cache Age Check**: Read Unix timestamp from first line of cache file
3. **Decision Point**:
   - **Fresh cache (<1 hour from timestamp)**: Jump to step 7 (cache-only behavior)
   - **Stale cache (>1 hour old)**: Continue to step 4 (full analysis)
4. **Analyze Current State**: Scan todo/ folder for complete analysis
5. **Project Filtering**: Apply DOH Runtime or DOH-DEV Internal context
6. **Update Memory**: Refresh appropriate cache with current analysis (Unix timestamp on line 1)
7. **Extract Recommendations**: Read from cache (fresh or just updated)
8. **Return Results**: Provide recommendations with optimal speed/accuracy balance

#### Memory-Only Mode (`--cache-only`)

1. **Cache Selection**: Choose NEXT.md (default) or NEXT-dd.md (--internal flag)
2. **Direct Read**: Load appropriate cache file immediately
3. **Extract Recommendations**: Parse top recommendations from stored memory
4. **Format Output**: Apply requested format (brief/detailed/plan)
5. **Instant Return**: Provide memory-based recommendations with zero re-computation
6. **Skip Analysis**: No file scanning, no memory refresh, no analysis overhead

#### No-Cache Mode (`--no-cache`)

1. **Skip Memory**: Completely ignore both cache files (don't read or update)
2. **Fresh Analysis**: Scan todo/ folder and analyze all tasks from scratch
3. **Project Filtering**: Apply DOH Runtime or DOH-DEV Internal context
4. **Pure Computation**: Generate recommendations using only current file state
5. **No Memory Updates**: Don't update any cache files with results
6. **Clean State**: Useful for testing, debugging, or when memory is corrupted

### Full Analysis (Memory Miss)

- **todo/ folder parsing**: Claude analyzes individual T*.md and E*.md files
- **Dependency resolution**: Claude builds dependency graphs and identifies ready tasks
- **Natural language processing**: Claude interprets user queries and provides conversational responses
- **Priority calculation**: Claude applies weighting algorithms and contextual scoring
- **Memory generation**: Claude creates todo/NEXT.md with comprehensive analysis for future reference
- **Response generation**: Claude formats recommendations in requested style

### Memory Benefits

- **Contextual continuity**: Maintains task analysis history and patterns
- **Faster computation**: Previous analysis provides baseline for incremental updates
- **Progress tracking**: Historical view of task completion and emerging priorities
- **Manual override**: `--refresh` flag forces complete re-analysis if needed
- **Extreme speed**: `--cache-only` provides sub-100ms responses using stored memory

### Performance Characteristics

| Mode                 | Response Time  | Accuracy    | Use Case                                        |
| -------------------- | -------------- | ----------- | ----------------------------------------------- |
| **Hybrid (Default)** | <100ms or 1-3s | Optimal     | Auto-decides based on cache age (1hr threshold) |
| Cache-Only           | <100ms         | Last update | Force speed, scripting, rapid iterations        |
| Refresh              | 3-5 seconds    | Perfect     | Force fresh analysis, major changes             |
| No-Cache             | 2-4 seconds    | Perfect     | Testing, debugging, clean analysis              |

### Archive Management & Analysis Scope

**Analysis Scope Policy**:

- **Analyzes**: All files in `todo/` root directory (includes COMPLETED tasks)
- **Excludes**: `todo/archive/` directory entirely for performance
- **Rationale**: COMPLETED tasks provide context for recommendations and dependencies

**Smart Archive Management**:

- **Keep in todo/**: COMPLETED tasks from active epics (remain accessible for analysis)
- **Archive to todo/archive/**: Only tasks from fully COMPLETED epics
- **Never Archive**: Tasks belonging to active/in-progress epics
- **Epic Status Check**: Before archiving, verify parent epic is COMPLETED

**Archive Rules**:

```bash
# Keep in todo/ (analyzed by /dd:next)
DOH064.md (COMPLETED) - Epic EDOH001 still active → Stay in todo/
DD070.md (COMPLETED) - Epic EDOH001 still active → Stay in todo/

# Archive to todo/archive/ (excluded from analysis)
DOH027.md (COMPLETED) - Epic E003 COMPLETED → Move to archive/
DOH018.md (COMPLETED) - Epic E002 COMPLETED → Move to archive/
```

**Benefits**:

- **Context Preservation**: Completed tasks from active epics remain visible for dependency analysis
- **Performance**: Archive exclusion reduces scan time without losing relevant context
- **Epic Continuity**: All tasks related to active epics stay accessible

## AI-Driven Features

- **Learning**: Remembers user preferences and working patterns within conversation
- **Adaptation**: Adjusts recommendations based on project evolution and completed work
- **Explanation**: Provides clear reasoning for all suggestions to build user confidence
- **Flexibility**: Handles edge cases and ambiguous input gracefully with clarifying questions

## AI-Driven Optimization Detection

This command continuously learns and improves through pattern analysis:

### Auto-Detection Capabilities

**Query Pattern Analysis**:

- **Repetitive misses**: When user queries consistently miss relevant tasks
- **Context gaps**: When natural language queries don't match available filters
- **Preference learning**: When user repeatedly selects different options than recommended

**Example Detection Scenarios**:

```bash
# After 3 queries for "documentation work" miss DOH037, DOH008
🔍 Optimization Detected: Documentation task detection incomplete
   Pattern: Queries for "doc work" missing tasks without #doc tag
   Missing: DOH037 (references cleanup), DOH008 (CLAUDE.md integration)

   Proposed: Enhanced semantic analysis beyond explicit tags
   - Scan descriptions for: "documentation", "README", "markdown", "cleanup"
   - Add inference: reference cleanup = documentation work

   Update /dd:next with this optimization? [Y/n]
```

**Dependency Resolution Learning**:

- **Blocked task patterns**: When dependency analysis misses implicit blockers
- **Priority miscalculation**: When impact scores don't match actual user selections
- **Context preference**: When user consistently picks tasks from specific categories

**Unlimited Discovery Scope**:

- **Emergent patterns**: Any new inefficiency, miss, or improvement opportunity I observe
- **Novel optimizations**: Creative solutions to problems I identify during execution
- **Cross-command learning**: Insights from other `/doh-dev` commands that could enhance task recommendations
- **User behavior adaptation**: Previously unknown preference patterns or work style insights

### Optimization Discovery

The AI continuously learns from usage patterns and can discover:

- **Novel optimizations**: Creative solutions to problems identified during execution
- **Cross-command learning**: Insights from other `/dd:*` commands that enhance recommendations
- **User behavior adaptation**: Preference patterns and work style insights

When significant improvements are identified, they're applied directly to enhance future executions.

This command transforms TODO management from static lists into an intelligent, conversational task recommendation system
that continuously adapts to developer context and project needs through active learning.
