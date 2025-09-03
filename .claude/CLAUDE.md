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

