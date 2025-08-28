# /dd:next - AI-Powered TODO Analysis & Task Recommendation Engine

Intelligent task prioritization system that analyzes TODO dependencies, developer context, and project priorities to
suggest the optimal next tasks with natural language interaction support.

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
- `--cache-only`: Ultra-fast mode using smart memory
  - **Speed**: Sub-100ms response time
  - **Source**: Reads directly from todo/NEXT.md memory file
  - **Use when**: Quick checks, rapid workflow, scripting integration
  - **Note**: Results may be slightly outdated if tasks recently changed

- `--refresh`: Force complete re-analysis
  - **Ignores**: Existing todo/NEXT.md cache
  - **Rebuilds**: Complete task analysis from current todo/ folder state
  - **Use when**: Major task changes, memory corruption, or fresh perspective needed
  - **Slower**: Takes 3-5 seconds but guarantees current accuracy

- `--no-cache`: Pure analysis without memory
  - **Clean slate**: Ignores memory file entirely
  - **No updates**: Doesn't update todo/NEXT.md with results
  - **Use when**: Testing, debugging, or when memory file is problematic

## Smart Memory System

The command uses `todo/NEXT.md` as intelligent memory with version awareness and pre-computed queries.

### Version Goal Awareness

The command reads `todo/doh-*.md` and `todo/dd-*.md` version files to understand:
- Current version philosophy and goals (Must Have/Should Have/Should NOT Have)
- Version constraints that affect task selection  
- Key strategic decisions that guide recommendations
- Progress context (~XX% completion estimates)

Version awareness ensures task recommendations align with strategic goals and respects version constraints like "Should NOT Have: External API dependencies" for v1.4.0.

### Memory Architecture

- **todo/NEXT.md**: Claude's memory file with pre-analyzed task data and smart query results
- **Version awareness**: Tracks current version (1.4.0-dev) and version-specific tasks
- **Project classification**: Pre-computed DOH-DEV vs DOH Runtime task categorization
- **Pre-computed queries**: Common searches like "version 1.4", "quick wins", "high impact", "internal tasks" pre-calculated
- **Smart context matching**: Natural language queries instantly mapped to stored results including `--internal` context
- **Auto-update**: Memory refreshed on every standard call to maintain current state
- **Extreme speed**: `--cache-only` reads memory directly with zero re-computation overhead

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
# 🚀 Most common: Get top recommendations
/dd:next
# Analyzes current project state → shows 3-5 best tasks

# 🎯 Context-specific filtering  
/dd:next --context=docs
# Shows documentation tasks → README, WORKFLOW, TODO updates

# 🔧 Internal development focus
/dd:next --internal
# Shows DOH-DEV internal tasks → command enhancements, dev workflow

# ⚡ Ultra-fast mode from memory
/dd:next --cache-only
# Sub-100ms response → uses smart memory cache
```

### 🗣️ Natural Language Query Examples

### Development Focus Queries

```bash
/dd:next "what can I work on while the build system is being designed?"
# AI Response: Analyzes T032 (build) as blocked, suggests parallel work on T027 (linting), T037 (cleanup)

/dd:next "show me some quick wins I can complete today"
# AI Response: Filters for tasks with simple deliverables and clear scope

/dd:next "what documentation needs attention?"
# AI Response: Filters #doc tagged tasks, analyzes completion gaps in README/WORKFLOW/DEVELOPMENT docs

/dd:next "internal tooling improvements"
# AI Response: Auto-maps to --internal flag, shows DOH-DEV command enhancements and dev workflow tasks

/dd:next "what runtime features are ready?"
# AI Response: Focuses on doh-1.4.0 tasks, user-facing features, public distribution work
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
# AI Response: Shows T024, T019, T027 with testing focus, explains relationships

/dd:next "what build system work is ready?"
# AI Response: Analyzes T032, T003, T005 build-related tasks and their readiness

/dd:next "I have 2 hours, what should I tackle?"
# AI Response: Suggests appropriately-scoped tasks based on complexity analysis
```

### Smart Memory Queries

```bash
# Version-specific tasks (pre-computed in memory)
/dd:next "version 1.4"
# Returns: Epic E001 tasks with phase breakdown instantly

# Pre-computed quick wins
/dd:next "quick wins"  
# Returns: T037 (1h), T056 (1.5h), T008 (2h) from memory

# High-impact tasks (instant from memory)
/dd:next "high impact"
# Returns: T032, T054 with unlock explanations

# Extreme speed with memory-only mode
/dd:next --cache-only
/dd:next --cache-only --context=build
/dd:next --cache-only "what next after t054"
# All return sub-100ms responses from smart memory

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

| Scenario | Recommended Mode | Reason |
|----------|------------------|--------|
| Quick daily check | `--cache-only` | Sub-100ms response |
| After completing tasks | `--refresh` | Ensure current accuracy |  
| Debugging recommendations | `--no-cache` | Clean slate analysis |
| Normal workflow | (default) | Balanced speed + accuracy |

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

1. **T037** - Clean up old project references (#doc, High Priority)
   ├── 🟢 Ready to start (no blockers)
   ├── ⏱️  Estimated: 1-2 hours
   └── 🎯 Impact: Unblocks T034 Phase 3, improves documentation quality

2. **T027** - Implement Markdown Linting System (#testing, Medium Priority)
   ├── 🟢 Ready to start (discussed, well-scoped)
   ├── ⏱️  Estimated: 2-4 hours
   └── 🎯 Impact: Enables automated quality control for all docs

3. **T041** - Remove attribution comments (COMPLETED)
   ├── ✅ Task completed successfully
   ├── ⏱️  Time taken: 45 minutes
   └── 🎯 Impact: Clean commit history, professional codebase presentation
```

### Internal Development Format (`--internal`)

```
🔧 DOH-DEV Internal Tasks (3 of 12 total)

1. **T073** - Add --internal flag to /dd:next command (Medium Priority)
   ├── 🟢 Ready to start (epic-less, standalone)
   ├── ⏱️  Estimated: 1-2 hours
   └── 🎯 Impact: DOH-DEV vs Runtime filtering in task recommendations

2. **T072** - Rename /doh-dev Commands to /dd (COMPLETED)
   ├── ✅ DOH-DEV system enhancement completed
   ├── ⏱️  Time taken: 3 hours  
   └── 🎯 Impact: Streamlined command interface for developers

3. **dd-0.1.0** - DOH-DEV Internal System Enhancement
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

## Top Recommendation: T037 (Score: 8.5/10)

**Task**: Clean up old project references (example projects)
**Category**: Documentation (#doc)
**Priority**: High 🚩

**Why This Task:**
- ✅ **No blockers**: All dependencies completed
- 🎯 **High impact**: Mentioned in 4 other task descriptions
- ⚡ **Quick completion**: Well-defined scope, 1-2 hour estimate
- 🔗 **Enables**: T034 Phase 3, general documentation quality improvements
- 🏃 **Momentum**: Builds on completed T034, T030, T035 documentation work

**Implementation Approach:**
1. Scan all .md files for outdated project references  
2. Replace with current project context ("DOH", "quazardous/doh")
3. Update examples and paths to reflect current structure
4. Validate no broken links introduced
```

### Plan Format

```
📋 Implementation Plan: T037

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

- **Foundation Phase**: Prioritizes T003, T004, T005 (architecture/distribution)
- **Quality Phase**: Emphasizes T024, T027, T019 (testing/linting)
- **Feature Phase**: Focuses on T020, T021, T017 (core functionality)
- **Polish Phase**: Suggests T037, T008, documentation tasks

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
AI: 🎯 Based on current project state, I recommend T037 (cleanup old references).
    It's ready to start, high impact, and builds on your recent documentation work.
    Would you like details or alternatives?

User: show me alternatives
AI: 📋 Alternative options:
    • T027 (markdown linting) - technical implementation, good variety
    • T041 (attribution cleanup) - continue current work in progress
    • T032 (build design) - foundational but more complex
    Which interests you?
```

### Context-Driven Selection

```
User: /dd:next "I want something technical after all this documentation work"
AI: 🔧 Perfect! Based on your recent doc focus, I recommend T027 (Markdown Linting System).
    Technical implementation with clear scope, builds testing infrastructure,
    and complements your documentation work. Ready to start with no blockers.

User: /dd:next --format=plan
AI: [Provides detailed T027 implementation plan]
```

### Workflow Integration

```
User: [After completing a task]
/doh-sys:commit "Completed T037 cleanup"

AI: [Auto-suggestion] 🎯 T037 complete! Next recommendation: T027 (linting system)
    Your cleanup work removed inconsistencies - perfect time to add automated quality control.
    Continue the quality improvement momentum?
```

## Implementation Architecture

This command is executed entirely by Claude's AI logic with smart memory:

### Execution Modes

#### Standard Mode (Default)

1. **Read Previous Memory**: Load existing todo/NEXT.md if available for context
2. **Analyze Current State**: Scan todo/ folder for any changes since last run
3. **Incremental Update**: Update analysis based on changes detected
4. **Generate Recommendations**: Create prioritized task suggestions
5. **Update Memory**: Refresh todo/NEXT.md with current analysis and recommendations
6. **Return Results**: Provide recommendations to user with fresh insights

#### Memory-Only Mode (`--cache-only`)

1. **Direct Read**: Load todo/NEXT.md memory file immediately
2. **Extract Recommendations**: Parse top recommendations from stored memory
3. **Format Output**: Apply requested format (brief/detailed/plan)
4. **Instant Return**: Provide memory-based recommendations with zero re-computation
5. **Skip Analysis**: No file scanning, no memory refresh, no analysis overhead

#### No-Cache Mode (`--no-cache`)

1. **Skip Memory**: Completely ignore todo/NEXT.md file (don't read or update)
2. **Fresh Analysis**: Scan todo/ folder and analyze all tasks from scratch
3. **Pure Computation**: Generate recommendations using only current file state
4. **No Memory Updates**: Don't update todo/NEXT.md with results
5. **Clean State**: Useful for testing, debugging, or when memory is corrupted

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

| Mode | Response Time | Accuracy | Use Case |
|------|---------------|----------|-----------|
| Standard | 1-3 seconds | Current | Normal workflow, up-to-date recommendations |
| Memory-Only | <100ms | Last update | Quick checks, rapid workflow, scripting |
| Refresh | 3-5 seconds | Perfect | Major changes, memory reset, fresh start |
| No-Cache | 2-4 seconds | Perfect | Testing, debugging, corrupted memory, clean analysis |

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
T064.md (COMPLETED) - Epic E001 still active → Stay in todo/
T070.md (COMPLETED) - Epic E001 still active → Stay in todo/

# Archive to todo/archive/ (excluded from analysis)
T027.md (COMPLETED) - Epic E003 COMPLETED → Move to archive/
T018.md (COMPLETED) - Epic E002 COMPLETED → Move to archive/
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
# After 3 queries for "documentation work" miss T037, T008
🔍 Optimization Detected: Documentation task detection incomplete
   Pattern: Queries for "doc work" missing tasks without #doc tag
   Missing: T037 (references cleanup), T008 (CLAUDE.md integration)

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

### Optimization Confirmation Workflow

1. **Pattern Recognition**: AI detects improvement opportunities during execution
2. **Impact Analysis**: Evaluates what would be enhanced
3. **User Confirmation**: Clear explanation + permission request
4. **Logic Enhancement**: Updates command intelligence
5. **Optimization Logging**: Records optimization in `.claude/optimization/DOHSYSOPTIM.md`
6. **Immediate Application**: Uses new logic for current execution

**Confirmation Format**:

```
🔍 Optimization Detected: [Brief description]
   Pattern: [What was observed]
   Issue: [Current limitation]

   Proposed optimization: [Specific improvement]
   - [Implementation detail 1]
   - [Implementation detail 2]

   Update /dd:next command with this optimization? [Y/n]

   [If confirmed, logs to DOHSYSOPTIM.md with pattern details and impact metrics]
```

This command transforms TODO management from static lists into an intelligent, conversational task recommendation system
that continuously adapts to developer context and project needs through active learning.
