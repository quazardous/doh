# /doh-sys:next - AI-Powered TODO Analysis & Task Recommendation Engine

Intelligent task prioritization system that analyzes TODO dependencies, developer context, and project priorities to
suggest the optimal next tasks with natural language interaction support.

## Usage

```bash
/doh-sys:next [query] [--context=focus] [--format=output] [--limit=N]
```

## Parameters

- `query`: (Optional) Natural language query about what to work on (e.g., "what can I do that's high impact", "show me
  documentation tasks", "what's ready to start")
- `--context=focus`: Filter by development context
  - `docs` - Documentation and writing tasks
  - `build` - Build system and architecture
  - `testing` - Testing and QA tasks
  - `features` - Core functionality development
  - `quick` - Tasks that can be completed in <2 hours
  - `blocked` - Show what's currently blocking other tasks
- `--format=output`: Output format
  - `brief` - Concise task list (default)
  - `detailed` - Full analysis with reasoning
  - `plan` - Step-by-step implementation plan
- `--limit=N`: Maximum number of tasks to suggest (default: 3-5)

## AI Analysis Engine

The command performs comprehensive intelligent analysis:

### 1. Dependency Mapping

- **Parses TODO.md** for task dependencies and status
- **Identifies blockers**: Tasks marked as dependencies for others
- **Maps ready tasks**: Tasks with all dependencies completed
- **Calculates impact**: How many other tasks depend on this one

### 2. Context-Aware Filtering

- **Tag analysis**: Processes #doc, #build, #testing, #features tags
- **Status tracking**: Differentiates IN PROGRESS, COMPLETED, and pending tasks
- **Priority parsing**: Extracts High/Medium/Low priority indicators
- **Complexity estimation**: Analyzes task descriptions for effort indicators

### 3. Natural Language Processing

- **Intent recognition**: Understands queries like "what should I work on next?"
- **Context matching**: Maps natural language to technical categories
- **Smart filtering**: Interprets phrases like "high impact", "quick wins", "documentation work"
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

## Natural Language Query Examples

### Development Focus Queries

```bash
/doh-sys:next "what can I work on while the build system is being designed?"
# AI Response: Analyzes T032 (build) as blocked, suggests parallel work on T027 (linting), T037 (cleanup)

/doh-sys:next "show me some quick wins I can complete today"
# AI Response: Filters for tasks with simple deliverables and clear scope

/doh-sys:next "what documentation needs attention?"
# AI Response: Filters #doc tagged tasks, analyzes completion gaps in README/WORKFLOW/DEVELOPMENT docs
```

### Priority and Impact Queries

```bash
/doh-sys:next "what's the most important thing to work on right now?"
# AI Response: Calculates highest priority×impact score, explains reasoning

/doh-sys:next "what's blocking the most other work?"
# AI Response: Identifies bottleneck tasks that are dependencies for multiple others

/doh-sys:next "what can I do that will unblock the most tasks?"
# AI Response: Prioritizes tasks that are blocking dependencies for others
```

### Contextual Development Queries

```bash
/doh-sys:next "I want to work on testing"
# AI Response: Shows T024, T019, T027 with testing focus, explains relationships

/doh-sys:next "what build system work is ready?"
# AI Response: Analyzes T032, T003, T005 build-related tasks and their readiness

/doh-sys:next "I have 2 hours, what should I tackle?"
# AI Response: Suggests appropriately-scoped tasks based on complexity analysis
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

3. **T041** - Remove Claude Code attribution comments (COMPLETED)
   ├── ✅ Task completed successfully
   ├── ⏱️  Time taken: 45 minutes
   └── 🎯 Impact: Clean commit history, professional codebase presentation
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

### With Other doh-sys Commands

- **Post-completion hook**: Automatically suggests next task after `/doh-sys:commit`
- **Dependency updates**: Integrates with `/doh-sys:changelog` to update dependencies
- **Quality gates**: Considers `/doh-sys:lint` results in task readiness assessment

### With DOH System

- **Task linking**: Suggests creating /doh tasks for complex TODOs
- **Epic correlation**: Maps TODO items to Epic/Feature structure when applicable
- **Progress tracking**: Uses DOH task completion to update TODO analysis

## Example Conversation Flows

### Getting Started

```
User: /doh-sys:next
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
User: /doh-sys:next "I want something technical after all this documentation work"
AI: 🔧 Perfect! Based on your recent doc focus, I recommend T027 (Markdown Linting System).
    Technical implementation with clear scope, builds testing infrastructure,
    and complements your documentation work. Ready to start with no blockers.

User: /doh-sys:next --format=plan
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

This command is executed entirely by Claude's AI logic:

- **TODO.md parsing**: Claude analyzes markdown structure and extracts task metadata
- **Dependency resolution**: Claude builds dependency graphs and identifies ready tasks
- **Natural language processing**: Claude interprets user queries and provides conversational responses
- **Priority calculation**: Claude applies weighting algorithms and contextual scoring
- **Response generation**: Claude formats recommendations in requested style

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

   Update /doh-sys:next with this optimization? [Y/n]
```

**Dependency Resolution Learning**:

- **Blocked task patterns**: When dependency analysis misses implicit blockers
- **Priority miscalculation**: When impact scores don't match actual user selections
- **Context preference**: When user consistently picks tasks from specific categories

**Unlimited Discovery Scope**:

- **Emergent patterns**: Any new inefficiency, miss, or improvement opportunity I observe
- **Novel optimizations**: Creative solutions to problems I identify during execution
- **Cross-command learning**: Insights from other `/doh-sys` commands that could enhance task recommendations
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

   Update /doh-sys:next command with this optimization? [Y/n]

   [If confirmed, logs to DOHSYSOPTIM.md with pattern details and impact metrics]
```

This command transforms TODO management from static lists into an intelligent, conversational task recommendation system
that continuously adapts to developer context and project needs through active learning.
