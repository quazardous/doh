# CLAUDE.md

> Think carefully and implement the most concise solution that changes as little code as possible.

## USE SUB-AGENTS FOR CONTEXT OPTIMIZATION

### 1. Always use the file-analyzer sub-agent when asked to read files.
The file-analyzer agent is an expert in extracting and summarizing critical information from files, particularly log files and verbose outputs. It provides concise, actionable summaries that preserve essential information while dramatically reducing context usage.

### 2. Always use the code-analyzer sub-agent when asked to search code, analyze code, research bugs, or trace logic flow.

The code-analyzer agent is an expert in code analysis, logic tracing, and vulnerability detection. It provides concise, actionable summaries that preserve essential information while dramatically reducing context usage.

### 3. Always use the test-runner sub-agent to run tests and analyze the test results.

Using the test-runner agent ensures:

- Full test output is captured for debugging
- Main conversation stays clean and focused
- Context usage is optimized
- All issues are properly surfaced
- No approval dialogs interrupt the workflow

## DOH API ENFORCEMENT

### MANDATORY: Use DOH API for Markdown Commands and Interactive Usage

**For DOH library functions in markdown commands and interactive contexts:**
```bash
# ✅ CORRECT: Use DOH API
./.claude/scripts/doh/api.sh <library> <function> [args...]

# ❌ WRONG: Direct library sourcing in markdown commands
source .claude/scripts/doh/lib/library.sh && library_function
```

**For DOH commands and workflows in markdown commands:**
```bash
# ✅ CORRECT: Use DOH helper
./.claude/scripts/doh/helper.sh <helper> <command> [args...]

# ❌ WRONG: Direct script execution in markdown commands
./.claude/scripts/doh/some-script.sh
```

**Rules:**
- **For markdown commands and interactive usage**: Always use `api.sh` and `helper.sh` 
- **For internal scripts and test files**: Direct library sourcing and script execution is allowed and recommended for performance
- Scripts in `.claude/scripts/doh/` can source libraries directly using `source` statements
- Test files in `tests/` can source DOH libraries directly for efficiency
- The API enforcement applies primarily to user-facing commands and agent operations

**Examples:**
```bash
# Numbering operations
./.claude/scripts/doh/api.sh numbering get_next "epic"
./.claude/scripts/doh/api.sh numbering register_epic "205" "path" "name"

# PRD operations  
./.claude/scripts/doh/helper.sh prd list
./.claude/scripts/doh/helper.sh prd status

# Workspace operations
./.claude/scripts/doh/api.sh workspace get_current_project_id
```

## Philosophy

### Error Handling

- **Fail fast** for critical configuration (missing text model)
- **Log and continue** for optional features (extraction model)
- **Graceful degradation** when external services unavailable
- **User-friendly messages** through resilience layer

### Testing

- Always use the test-runner agent to execute tests.
- Do not use mock services for anything ever.
- Do not move on to the next test until the current test is complete.
- If the test fails, consider checking if the test is structured correctly before deciding we need to refactor the codebase.
- Tests to be verbose so we can use them for debugging.


## Tone and Behavior

- Criticism is welcome. Please tell me when I am wrong or mistaken, or even when you think I might be wrong or mistaken.
- Please tell me if there is a better approach than the one I am taking.
- Please tell me if there is a relevant standard or convention that I appear to be unaware of.
- Be skeptical.
- Be concise.
- Short summaries are OK, but don't give an extended breakdown unless we are working through the details of a plan.
- Do not flatter, and do not give compliments unless I am specifically asking for your judgement.
- Occasional pleasantries are fine.
- Feel free to ask many questions. If you are in doubt of my intent, don't guess. Ask.

## ABSOLUTE RULES:

- NO PARTIAL IMPLEMENTATION
- NO SIMPLIFICATION : no "//This is simplified stuff for now, complete implementation would blablabla"
- NO CODE DUPLICATION : check existing codebase to reuse functions and constants Read files before writing new functions. Use common sense function name to find them easily.
- NO DEAD CODE : either use or delete from codebase completely
- IMPLEMENT TEST FOR EVERY FUNCTIONS : Every significant function must have a dedicated test that covers its real usage.
- NO CHEATER TESTS : test must be accurate, reflect real usage and be designed to reveal flaws. No useless tests! Design tests to be verbose so we can use them for debuging.
- NO INCONSISTENT NAMING - read existing codebase naming patterns.
- NO OVER-ENGINEERING - Don't add unnecessary abstractions, factory patterns, or middleware when simple functions would work. Don't think "enterprise" when you need "working"
- NO ALIAS OR WRAPPER FUNCTIONS. Don't create wrapper functions to adapt APIs. Refactor the calling code to use the correct API directly.
- NO MIXED CONCERNS - Don't put validation logic inside API handlers, database queries inside UI components, etc. instead of proper separation
- NO RESOURCE LEAKS - Don't forget to close database connections, clear timeouts, remove event listeners, or clean up file handles
- ALWAYS VERIFY CURRENT CODE - Always inspect the codebase before analyzing or suggesting fixes. Do not rely on outdated tasks, backlog items, or prior context.
- NO PREMATURE SCRIPTING IN REFACTOR - Do not extract logic into separate scripts or automation tools unless the same operation will be repeated across multiple files or contexts. 

## DOH NATURAL LANGUAGE COMMAND DETECTION

When users make requests in natural language that correspond to DOH commands, automatically execute the appropriate `/doh:` command instead of implementing the functionality manually.

### PRD Domain Commands

| Natural Language Pattern | DOH Command | Notes |
|---------------------------|-------------|--------|
| "Create a new PRD/feature/epic for..." | `/doh:prd-new` | Initial feature planning |
| "Turn this PRD into an epic" | `/doh:prd-parse` | PRD → Epic conversion |
| "Show me all PRDs" | `/doh:prd-list` | PRD overview |
| "What's the status of PRDs?" | `/doh:prd-status` | PRD progress |
| "Edit PRD X" | `/doh:prd-edit X` | PRD modification |

### Epic Domain Commands

| Natural Language Pattern | DOH Command | Notes |
|---------------------------|-------------|--------|
| "Break down this epic into tasks" | `/doh:epic-decompose` | Task creation |
| "Sync epic to GitHub" | `/doh:epic-sync` | GitHub integration |
| "Start working on epic X" | `/doh:epic-start X` | Begin development |
| "Show me all epics" | `/doh:epic-list` | Epic overview |
| "What's the status of epic X?" | `/doh:epic-status X` | Progress check |
| "Show me details of epic X" | `/doh:epic-show X` | Detailed view |
| "Update epic progress" | `/doh:epic-refresh` | Sync progress |
| "Edit epic X" | `/doh:epic-edit X` | Modify epic |
| "Close/complete epic X" | `/doh:epic-close X` | Mark done |
| "Merge epic X back to main" | `/doh:epic-merge X` | Deployment |
| "Do everything for epic X" | `/doh:epic-oneshot X` | Full workflow |

### Task/Issue Domain Commands

| Natural Language Pattern | DOH Command | Notes |
|---------------------------|-------------|--------|
| "Start working on issue #123" | `/doh:issue-start 123` | Begin task work |
| "Show me issue #123" | `/doh:issue-show 123` | Task details |
| "What's the status of issue #123?" | `/doh:issue-status 123` | Status check |
| "Update issue #123 on GitHub" | `/doh:issue-sync 123` | Sync progress |
| "Analyze issue #123" | `/doh:issue-analyze 123` | Work planning |
| "Edit issue #123" | `/doh:issue-edit 123` | Modify task |
| "Close issue #123" | `/doh:issue-close 123` | Mark complete |
| "Reopen issue #123" | `/doh:issue-reopen 123` | Undo completion |
| "Close task 001" / "Mark task 001 as done" | Execute: `./.claude/scripts/doh/helper.sh task update 001 status:completed` | Task completion |
| "How does task 123 affect versions?" | `/doh:task-versions 123` | Version impact analysis |

### Version Domain Commands

| Natural Language Pattern | DOH Command | Notes |
|---------------------------|-------------|--------|
| "Create a new version" | `/doh:version-new` | Version planning |
| "Show me version X.Y.Z" | `/doh:version-show X.Y.Z` | Version details |
| "Edit version X.Y.Z" | `/doh:version-edit X.Y.Z` | Modify version |
| "What's the version status?" | `/doh:version-status` | Version overview |
| "Check if version is ready" | `/doh:version-validate` | Release readiness |
| "Delete version X.Y.Z" | `/doh:version-delete X.Y.Z` | Remove version |
| "Bump the version" | `/doh:version-bump` | Increment version |
| "Initialize versioning" | `/doh:version-init` | Setup versioning |
| "Migrate to versioning" | `/doh:version-migrate` | Convert project |

### Project Status & Planning Commands

| Natural Language Pattern | DOH Command | Notes |
|---------------------------|-------------|--------|
| "What should I work on next?" | `/doh:next` | Task prioritization |
| "What's the overall project status?" | `/doh:status` | High-level view |
| "What am I currently working on?" | `/doh:in-progress` | Active work |
| "What's blocked?" | `/doh:blocked` | Dependency issues |
| "Generate standup report" | `/doh:standup` | Daily meetings |
| "Search for..." | `/doh:search` | Content search |

### System & Maintenance Commands

| Natural Language Pattern | DOH Command | Notes |
|---------------------------|-------------|--------|
| "Clean up old work" | `/doh:clean` | Housekeeping |
| "Sync everything with GitHub" | `/doh:sync` | Full sync |
| "Check system health" | `/doh:validate` | System check |
| "Import GitHub issues" | `/doh:import` | External import |
| "Check workspace" | `/doh:workspace` | Workspace status |
| "Show me help" | `/doh:help` | Documentation |
| "Initialize new project" | `/doh:init` | Project setup |
| "Add version headers" | `/doh:add-file-headers` | File management |

### Command Detection Rules

1. **Exact Pattern Matching**: When user input matches patterns above, execute the corresponding command immediately
2. **Argument Inference**: If the command requires specific arguments, try to infer them from:
   - User input context (epic names, issue numbers, versions mentioned)
   - Current working directory or active epic context
   - Recent conversation history
   - File names or paths visible in the workspace
3. **Parameter Extraction**: Extract and validate arguments before command execution:
   - Epic names (e.g., "command-with-helper", "data-api-sanity")
   - Issue numbers (e.g., "#123", "issue 456", "task 001") 
   - Version numbers (e.g., "1.2.3", "v2.0.0")
   - File paths and entity identifiers
4. **Context Awareness**: Consider current working context (epic, task, etc.) when resolving ambiguous requests
5. **Smart Defaults**: Use reasonable defaults when arguments can be inferred:
   - Current epic if working within an epic directory
   - Latest version for version operations
   - Current task if in task context
6. **Argument Validation**: Verify arguments exist before executing commands:
   - Check if epic exists before running epic commands
   - Validate issue numbers are valid
   - Confirm version numbers follow semantic versioning
7. **Fallback**: If arguments cannot be inferred or validated, ask for clarification with specific examples

### Implementation Examples

```bash
# User says: "Show me the status of epic command-with-helper"
# Infer: epic name = "command-with-helper"
# Execute: /doh:epic-status command-with-helper

# User says: "Close task 001"  
# Infer: task number = "001"
# Execute: ./.claude/scripts/doh/helper.sh task update 001 status:completed

# User says: "What should I work on next?"
# No arguments needed
# Execute: /doh:next

# User says: "Edit the current epic"
# Infer: epic name from current directory (.doh/epics/command-with-helper/)
# Execute: /doh:epic-edit command-with-helper

# User says: "Show issue 123"
# Infer: issue number = "123"
# Execute: /doh:issue-show 123

# User says: "Start working on the data API epic" 
# Infer: epic name = "data-api-sanity" (closest match)
# Execute: /doh:epic-start data-api-sanity

# User says: "Bump version to 2.1.0"
# Infer: target version = "2.1.0"
# Execute: /doh:version-bump 2.1.0

# User says: "Sync everything to GitHub" 
# No arguments needed
# Execute: /doh:sync
```

**Priority**: Always use DOH commands over manual implementation when natural language matches available command functionality.

