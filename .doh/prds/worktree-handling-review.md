---
name: worktree-handling-review
description: Standardize git worktree operations across all /doh commands and agents for consistent parallel development
status: backlog
created: 2025-08-31T06:32:44Z
---

# PRD: Worktree Handling Review

## Executive Summary

The /doh development orchestration system needs clear workspace awareness for every component to understand whether it's operating in the main branch or a worktree. This PRD defines a dual-mode system where quick, monitored tasks run in the main branch while long-running parallel work happens in isolated worktrees, with comprehensive logging and monitoring capabilities from the main Claude stream.

## Problem Statement

The /doh system lacks clear workspace awareness and proper mode selection:

**Core Issues:**
1. Components don't know if they're in main branch or worktree workspace
2. No distinction between quick tasks (main branch) vs long tasks (worktree)
3. Agents can be launched in "worktree mode" without proper worktree setup
4. No centralized monitoring of worktree activities from main Claude stream
5. Unclear commit points and progress tracking across worktrees

**Specific Problems:**
- Agents fail with "directory not found" when worktree isn't created first
- Quick debugging tasks unnecessarily create worktrees
- Main Claude conversation loses visibility into worktree agent progress
- No clear logs or status updates from parallel worktree operations
- Branch workspace gets lost between command invocations

**Why this matters now:**
- Need to monitor quick tasks directly in main branch
- Long-running epics need isolation but with visibility
- Parallel agents require guaranteed worktree existence
- Developers need real-time progress updates from all workspaces

## User Stories

### Primary Persona: Claude User (Main Stream)
**As a** Claude user orchestrating development  
**I want** to monitor all work from my main conversation  
**So that** I can track progress without workspace switching  

**Acceptance Criteria:**
- Real-time log streaming from worktree agents to main stream
- Clear commit checkpoints showing worktree progress
- Ability to switch between monitoring different worktrees
- Quick tasks run directly in main branch with immediate feedback
- Flag-based control over branch vs worktree execution

### Secondary Persona: Automated Agent
**As an** automated agent executing work  
**I want** guaranteed worktree existence before execution  
**So that** I never fail due to missing directories  

**Acceptance Criteria:**
- Pre-flight check ensures worktree exists before agent launch
- Explicit error if launching in worktree mode without setup
- Workspace object includes: branch, worktree path, mode, and logging config
- Agents auto-detect their execution workspace
- Clear failure messages with remediation steps

### Tertiary Persona: Developer Doing Quick Fix
**As a** developer fixing a bug  
**I want** to work directly in main branch  
**So that** I can see immediate results without worktree overhead  

**Acceptance Criteria:**
- `--branch` flag keeps work in current branch
- `--worktree` flag forces worktree creation
- Default behavior based on task complexity (auto-detect)
- Visual indicator shows current mode
- Ability to monitor branch changes in real-time

## Requirements

### Functional Requirements

#### Workspace Awareness System
- **Universal Workspace Object**: Every /doh component receives workspace with:
  ```yaml
  workspace:
    mode: branch|worktree
    current_branch: main|feature|epic/x
    worktree_path: null|../epic-x/
    is_worktree: true|false
    parent_repo: /path/to/main
    log_stream: .doh/logs/current.log
  ```
- **Workspace Persistence**: Save workspace state between command invocations
- **Workspace Detection**: Auto-detect current git workspace on startup
- **Workspace Validation**: Verify workspace matches expected state

#### Mandatory Workspace Display
- **Pre-Execution Banner**: Every command and agent MUST display workspace before execution:
  ```bash
  # For branch mode:
  echo "════════════════════════════════════════════════════"
  echo "🏠 WORKSPACE: Main Repository"
  echo "📍 Branch: main"
  echo "🎯 Mode: BRANCH (direct changes)"
  echo "⚠️  Changes will affect current branch immediately"
  echo "════════════════════════════════════════════════════"
  
  # For worktree mode:
  echo "════════════════════════════════════════════════════"
  echo "🔧 WORKSPACE: Worktree"
  echo "📍 Branch: epic/feature-x"
  echo "📂 Location: ../epic-feature-x/"
  echo "🎯 Mode: WORKTREE (isolated changes)"
  echo "✅ Commits will go to: epic/feature-x"
  echo "════════════════════════════════════════════════════"
  ```

- **Agent Launch Workspace**: Agents must announce their working workspace:
  ```markdown
  ## Agent Starting: Database Schema Update
  
  🔧 **Working Workspace:**
  - Mode: WORKTREE
  - Directory: ../epic-payment-system/
  - Branch: epic/payment-system
  - Will commit to: epic/payment-system
  - Parent repo stays on: main
  
  Starting work...
  ```

- **Workspace Switch Warnings**: Alert when workspace changes:
  ```bash
  echo "⚠️  WORKSPACE SWITCH DETECTED"
  echo "   From: main branch"
  echo "   To: worktree ../epic-feature-x/"
  echo "   Confirm switch? (yes/no)"
  ```

#### Dual-Mode Execution
- **Branch Mode** (Quick Tasks):
  - Work directly in current branch
  - Immediate visibility in main Claude stream
  - No directory switching required
  - For tasks < 30 minutes
  
- **Worktree Mode** (Long Tasks):
  - Isolated worktree at `../epic-{name}/`
  - Parallel agent execution
  - Log streaming to main workspace
  - For epics and complex features

#### Flag-Based Control
- **Command Flags**:
  ```bash
  /doh:issue-start 123 --branch    # Force branch mode
  /doh:issue-start 123 --worktree  # Force worktree mode
  /doh:issue-start 123              # Auto-detect based on task size
  ```
- **Global Settings**:
  ```yaml
  .doh/config.yml:
    default_mode: auto|branch|worktree
    quick_task_threshold: 30min
    force_worktree_for_epics: true
  ```

#### Worktree Safety Guards
- **Pre-flight Validation**:
  ```bash
  # Before launching agent in worktree mode:
  if [[ "$MODE" == "worktree" ]]; then
    if ! git worktree list | grep -q "$WORKTREE_PATH"; then
      echo "ERROR: Worktree not found at $WORKTREE_PATH"
      echo "Run: /doh:epic-start $EPIC_NAME first"
      exit 1
    fi
  fi
  ```
- **Agent Launch Protection**: Refuse to start agents without valid worktree
- **Directory Verification**: Check paths exist before any file operations
- **Rollback on Failure**: Clean up partial worktree creations

#### Monitoring & Logging System
- **Centralized Log Aggregation**:
  ```
  .doh/logs/
    main.log           # Main branch operations
    epic-x/
      agent-1.log      # Individual agent logs
      agent-2.log
      summary.log      # Consolidated progress
      commits.log      # Commit history
  ```
  
- **Real-time Streaming**:
  ```bash
  # Stream logs to main Claude conversation
  tail -f .doh/logs/epic-x/summary.log &
  MONITOR_PID=$!
  ```

- **Commit Checkpoints**:
  ```markdown
  ## Worktree Progress: epic-feature-x
  
  ✓ Commit 1a2b3c: Database schema created (Agent-1)
  ✓ Commit 4d5e6f: API endpoints added (Agent-2)
  ⏳ In Progress: UI components (Agent-3)
  ⏸ Queued: Integration tests (Agent-4)
  
  Last update: 2 minutes ago
  ```

- **Progress Commands**:
  ```bash
  /doh:monitor epic-x        # Show live progress
  /doh:monitor --all         # Show all worktrees
  /doh:switch-monitor epic-y # Change monitoring focus
  ```

#### Intelligent Mode Selection
- **Auto-Detection Logic**:
  ```python
  def select_mode(task):
    if task.is_epic:
      return "worktree"
    if task.estimated_time > 30:
      return "worktree"
    if task.parallel_streams > 1:
      return "worktree"
    if task.type in ["debug", "hotfix", "config"]:
      return "branch"
    return "branch"  # Default to branch for simplicity
  ```

#### Workspace Switching Helpers
- **Easy Navigation**:
  ```bash
  /doh:goto main          # Return to main repo
  /doh:goto epic-x        # Switch to worktree
  /doh:where              # Show current workspace
  /doh:list-workspaces      # Show all active workspaces
  ```

### Non-Functional Requirements

#### Performance
- Worktree creation must complete within 5 seconds
- Switching between worktrees must be near-instantaneous
- No performance degradation with up to 10 active worktrees

#### Security
- Worktrees must respect repository permissions
- No cross-contamination between worktree branches
- Secure cleanup of worktree data after deletion

#### Scalability
- Support minimum 10 concurrent worktrees
- Handle epics with 50+ parallel tasks
- Efficient git operations even with large repositories

#### Usability
- Clear error messages for worktree conflicts
- Intuitive commands for worktree navigation
- Visual indicators in prompts showing worktree workspace

## Success Criteria

### Quantitative Metrics
- **100%** workspace display - Every command/agent shows workspace banner
- **100%** workspace awareness - Every command knows its execution mode
- **Zero** agent launches in non-existent worktrees
- **< 2 seconds** log streaming latency from worktree to main
- **100%** success rate for worktree pre-flight checks
- **< 5%** incorrect mode selection (branch vs worktree)

### Qualitative Metrics
- Users always know where changes will be committed
- Clear visual distinction between branch and worktree modes
- Main Claude stream maintains full visibility into worktree progress
- No confusion about current working workspace
- Seamless monitoring without workspace switching

### Monitoring Metrics
- Every worktree commit appears in main stream within 2 seconds
- Progress updates every 30 seconds during active work
- Clear indication when agents complete or fail
- Ability to see all active worktrees at a glance

## Constraints & Assumptions

### Technical Constraints
- Git version 2.5+ required for worktree support
- Filesystem must support symbolic links
- Available disk space for multiple working copies

### Resource Constraints
- Implementation must be completed within current sprint
- No additional infrastructure requirements
- Must work with existing GitHub integration

### Assumptions
- Developers familiar with git worktree concept
- Epics typically have 5-20 parallel tasks
- Most development happens on Unix-like systems
- Agents have filesystem access to parent directory

## Out of Scope

- **Not changing** core git workflow (still using feature branches)
- **Not implementing** custom version control system
- **Not supporting** worktrees on network drives
- **Not handling** submodule worktree management
- **Not providing** GUI for worktree visualization
- **Not supporting** nested worktrees (worktrees within worktrees)

## Dependencies

### External Dependencies
- Git 2.5+ installation on all development machines
- GitHub API for issue synchronization
- Filesystem permissions for parent directory access

### Internal Dependencies
- All /doh command implementations must be updated
- Agent framework must support worktree workspace passing
- Documentation must be updated with new workflow
- Existing epic tracking system must be compatible

### Migration Dependencies
- Current in-progress epics must be completed or migrated
- Existing automation scripts may need updates
- CI/CD pipelines might need worktree awareness

## Risk Assessment

### High Risk
- **Data Loss**: Accidental deletion of worktree with uncommitted changes
  - *Mitigation*: Implement confirmation prompts and status checks

### Medium Risk
- **Adoption Resistance**: Developers confused by worktree concept
  - *Mitigation*: Comprehensive documentation and training
- **Performance Issues**: Too many worktrees degrading system performance
  - *Mitigation*: Implement worktree limits and cleanup policies

### Low Risk
- **Git Version Incompatibility**: Older git versions on some machines
  - *Mitigation*: Version detection and helpful error messages

## Implementation Phases

### Phase 1: Workspace Awareness (Week 1)
- Implement universal workspace object
- Add workspace detection to all commands
- Create workspace persistence layer
- Add pre-flight worktree validation

### Phase 2: Dual-Mode System (Week 2)
- Implement --branch and --worktree flags
- Add auto-detection logic for mode selection
- Update commands to respect mode flags
- Create mode-specific execution paths

### Phase 3: Monitoring Infrastructure (Week 3)
- Build centralized logging system
- Implement log streaming to main workspace
- Create progress tracking commands
- Add commit checkpoint notifications

### Phase 4: Safety & Polish (Week 4)
- Add comprehensive error handling
- Implement rollback mechanisms
- Create workspace switching commands
- Update all documentation

## Appendix

### Example Workflows

#### Quick Fix in Branch Mode
```bash
# Fixing a typo - stays in main branch
/doh:issue-start 123 --branch

# Output:
════════════════════════════════════════════════════
🏠 WORKSPACE: Main Repository
📍 Branch: main
🎯 Mode: BRANCH (direct changes)
⚠️  Changes will affect current branch immediately
════════════════════════════════════════════════════
Starting issue #123 in branch mode...

# Work happens directly, visible immediately
git add -p
git commit -m "Fix: Typo in documentation"
# No worktree overhead for 2-minute fix
```

#### Epic with Workspace Display
```bash
# Long-running epic - uses worktree
/doh:epic-start feature-x

# Output:
════════════════════════════════════════════════════
🔧 WORKSPACE: Worktree Creation
📍 Target Branch: epic/feature-x
📂 Location: ../epic-feature-x/
🎯 Mode: WORKTREE (isolated changes)
✅ All commits will go to: epic/feature-x
════════════════════════════════════════════════════
Creating worktree...
✓ Worktree created at ../epic-feature-x/

Launching agents...

## Agent-1 Starting: Database Schema
🔧 Working Workspace:
- Mode: WORKTREE
- Directory: ../epic-feature-x/
- Branch: epic/feature-x
- Will commit to: epic/feature-x

## Agent-2 Starting: API Endpoints  
🔧 Working Workspace:
- Mode: WORKTREE
- Directory: ../epic-feature-x/
- Branch: epic/feature-x
- Will commit to: epic/feature-x
```

#### Workspace Switch Warning
```bash
# User tries to switch workspace
cd ../epic-payment/
/doh:issue-start 789

# Output:
⚠️  WORKSPACE SWITCH DETECTED
   From: main branch (main repo)
   To: worktree ../epic-payment/
   
   Current: /home/user/project (branch: main)
   Target: ../epic-payment/ (branch: epic/payment)
   
   This will change your working workspace.
   Continue? (yes/no): 
```

#### Agent with Clear Workspace
```bash
# When agent launches
/doh:issue-start 456 --worktree

# Output:
════════════════════════════════════════════════════
🔧 WORKSPACE: Worktree
📍 Branch: epic/feature-y
📂 Location: ../epic-feature-y/
🎯 Mode: WORKTREE (isolated changes)
✅ Commits will go to: epic/feature-y
════════════════════════════════════════════════════

🚀 Launching parallel-worker agent...

Agent output:
"I'm working in worktree ../epic-feature-y/
 All my commits will go to branch: epic/feature-y
 The main repo remains on: main
 
 Starting implementation..."
```

### Technical Details

#### Worktree Structure
```
/main-repo/              # Always on main or stable branch
  .doh/
    epics/
      feature-x/
        epic.md
        001.md
        002.md

/epic-feature-x/         # Worktree on epic/feature-x branch
  src/
  tests/
  # All implementation work happens here
```

#### Enhanced Workspace Structure
```json
{
  "mode": "worktree",
  "working_directory": "../epic-feature-x",
  "branch": "epic/feature-x",
  "is_worktree": true,
  "parent_repo": "/home/user/project",
  "commit_prefix": "Issue #1234:",
  "logging": {
    "stream_to_main": true,
    "log_file": ".doh/logs/epic-feature-x/agent-1.log",
    "checkpoint_interval": 30,
    "verbosity": "info"
  },
  "monitoring": {
    "enabled": true,
    "report_commits": true,
    "report_errors": true,
    "heartbeat_seconds": 60
  },
  "validation": {
    "worktree_exists": true,
    "branch_exists": true,
    "last_validated": "2025-01-15T10:30:00Z"
  }
}
```

#### Monitoring Dashboard Format
```markdown
## Active Development Workspaces

### Main Branch (Current)
- Mode: branch
- Branch: main
- Active: ✓
- Last commit: 2 minutes ago

### Worktree: epic-feature-x
- Mode: worktree
- Branch: epic/feature-x
- Agents: 3 active, 1 queued
- Progress: 65%
- Last update: 30 seconds ago

### Worktree: epic-bugfix-y
- Mode: worktree
- Branch: epic/bugfix-y
- Agents: 1 active
- Progress: 90%
- Last update: 5 minutes ago

---
Use /doh:monitor [name] to focus on specific workspace
```

#### Pre-flight Check Sequence
```bash
#!/bin/bash
# Pre-flight validation before agent launch

function validate_worktree_mode() {
  local epic_name=$1
  local worktree_path="../epic-${epic_name}"
  
  echo "🔍 Pre-flight checks for worktree mode..."
  
  # Check 1: Worktree exists
  if ! git worktree list | grep -q "$worktree_path"; then
    echo "❌ FAIL: Worktree not found at $worktree_path"
    echo "   Fix: Run /doh:epic-start $epic_name"
    return 1
  fi
  
  # Check 2: Worktree is clean
  cd "$worktree_path"
  if [[ -n $(git status --porcelain) ]]; then
    echo "⚠️  WARN: Worktree has uncommitted changes"
    echo "   Consider committing before launching agents"
  fi
  
  # Check 3: Branch exists and is correct
  local current_branch=$(git branch --show-current)
  if [[ "$current_branch" != "epic/$epic_name" ]]; then
    echo "❌ FAIL: Wrong branch in worktree"
    echo "   Expected: epic/$epic_name"
    echo "   Found: $current_branch"
    return 1
  fi
  
  # Check 4: Can write logs
  local log_dir="../$parent_repo/.doh/logs/epic-$epic_name"
  if ! mkdir -p "$log_dir" 2>/dev/null; then
    echo "❌ FAIL: Cannot create log directory"
    return 1
  fi
  
  echo "✅ All pre-flight checks passed"
  echo "   Worktree: $worktree_path"
  echo "   Branch: $current_branch"
  echo "   Logs: $log_dir"
  return 0
}
```