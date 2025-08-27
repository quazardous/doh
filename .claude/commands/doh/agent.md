# /doh:agent Command

## Description

Assign a task or epic to an autonomous agent for independent execution.

## Usage

```bash
/doh:agent [task/epic description or #id]
```

## Parameters

- `task/epic description or #id`: Description of the task/epic or ID of existing task/epic to assign to agent

## Examples

- `/doh:agent fait la tâche #34` - Assign task #34 to autonomous agent
- `/doh:agent implémente le système de notification` - Assign notification system implementation to agent
- `/doh:agent #67` - Assign existing epic #67 to autonomous agent

## Implementation

When this command is executed:

1. **Parse Parameters**: Extract task/epic description or ID
2. **Load Context**: If ID provided, load existing task/epic from `.doh/index.json`
3. **Build Context Bundle**: Generate JSON context bundle with:

   ```bash
   # Generate agent session ID
   AGENT_ID="agent-$(date +%Y%m%d-%H%M%S)-${TASK_ID}"
   TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
   
   # Build context bundle JSON
   cat > /tmp/agent-context-${AGENT_ID}.json << EOF
   {
     "agent_session": {
       "id": "${AGENT_ID}",
       "created_at": "${TIMESTAMP}",
       "worktree_path": "../${PROJECT_NAME}-worktree-${TYPE}-${NAME}",
       "branch": "${TYPE}/${NAME}",
       "target": {
         "type": "${TYPE}",
         "id": "${TASK_ID}",
         "title": "${TITLE}",
         "description": "${DESCRIPTION}",
         "status": "assigned_to_agent"
       }
     },
     "hierarchy": $(load_hierarchy_context),
     "memory": $(load_memory_context),
     "codebase_context": $(load_codebase_context)
   }
   EOF
   ```

4. **Create Worktree & Setup Environment**: Use integrated setup function:

   ```bash
   # Parse task details for worktree naming
   TASK_NAME=$(echo "${DESCRIPTION}" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
   
   # Setup complete agent worktree with validation
   WORKTREE_PATH=$(setup_agent_worktree "${TASK_ID}" "${TYPE}" "${TASK_NAME}" "${AGENT_ID}")
   
   # Validate setup was successful
   if ! validate_worktree_setup "${WORKTREE_PATH}" "${AGENT_ID}"; then
     echo "❌ Worktree setup failed, aborting agent launch"
     exit 1
   fi
   ```

5. **Agent Launch**: Launch autonomous agent with complete context:

   ```bash
   # Save context bundle to worktree
   cp "/tmp/agent-context-${AGENT_ID}.json" "${WORKTREE_PATH}/.doh-agent-context.json"
   
   # Switch to agent worktree
   cd "${WORKTREE_PATH}"
   
   # Load agent environment
   source .doh-agent-env.sh
   
   # Set agent-specific environment
   export DOH_AGENT_CONTEXT="${WORKTREE_PATH}/.doh-agent-context.json"
   export DOH_AGENT_ID="${AGENT_ID}"
   export DOH_TASK_ID="${TASK_ID}"
   export DOH_TASK_TYPE="${TYPE}"
   
   # Update agent status to active
   update_agent_progress "active" "autonomous_execution" "[]"
   
   # Launch autonomous agent with context
   echo "🚀 Launching autonomous agent ${AGENT_ID}..."
   echo "📂 Worktree: ${WORKTREE_PATH}"
   echo "🌳 Branch: ${TYPE}/${TASK_NAME}"
   echo "📋 Context: ${WORKTREE_PATH}/.doh-agent-context.json"
   
   # Start agent in background with logging
   {
     echo "=== Agent ${AGENT_ID} Started at $(date -u +"%Y-%m-%dT%H:%M:%SZ") ==="
     echo "Target: ${TYPE} #${TASK_ID} - ${DESCRIPTION}"
     echo "Worktree: ${WORKTREE_PATH}"
     echo "Context loaded from: ${DOH_AGENT_CONTEXT}"
     echo ""
     
     # Launch Claude in agent mode
     claude --agent-mode --context-file="${DOH_AGENT_CONTEXT}" --project-context="${WORKTREE_PATH}"
     
   } >> ".doh/memory/agent-sessions/${AGENT_ID}.log" 2>&1 &
   
   AGENT_PID=$!
   echo "${AGENT_PID}" > ".doh/memory/agent-sessions/${AGENT_ID}.pid"
   
   echo "✅ Agent ${AGENT_ID} launched successfully (PID: ${AGENT_PID})"
   echo "📜 Logs: .doh/memory/agent-sessions/${AGENT_ID}.log"
   echo "🔍 Monitor: tail -f .doh/memory/agent-sessions/${AGENT_ID}.log"
   ```

## Context Loading Functions

### Hierarchy Context

```bash
load_hierarchy_context() {
  if [[ -f ".doh/index.json" ]]; then
    # Load from index.json if exists
    jq -r --arg task_id "$TASK_ID" '
      .items[$task_id] as $task |
      if $task.epic_id then
        .items[$task.epic_id] as $epic |
        {
          "project": {
            "name": .metadata.project_name // "Unknown",
            "language": .metadata.language // "en",
            "working_directory": env.PWD
          },
          "epic": {
            "id": $epic.id,
            "title": $epic.title,
            "path": $epic.path
          },
          "parent_feature": $task.feature_id // null,
          "dependencies": $task.dependencies // []
        }
      else
        {
          "project": {
            "name": .metadata.project_name // "Unknown",
            "language": .metadata.language // "en", 
            "working_directory": env.PWD
          },
          "epic": null,
          "parent_feature": null,
          "dependencies": []
        }
      end
    ' .doh/index.json
  else
    # Default hierarchy for new projects
    echo '{
      "project": {
        "name": "'$(basename $(pwd))'",
        "language": "en",
        "working_directory": "'$(pwd)'"
      },
      "epic": null,
      "parent_feature": null,
      "dependencies": []
    }'
  fi
}
```

### Memory Context

```bash
load_memory_context() {
  local memory_context='{"project_conventions": {}, "epic_decisions": {}, "patterns": {}}'
  
  # Load project conventions if exist
  if [[ -f ".doh/memory/project/conventions.md" ]]; then
    memory_context=$(echo "$memory_context" | jq --rawfile content .doh/memory/project/conventions.md '
      .project_conventions = {
        "path": ".doh/memory/project/conventions.md",
        "key_points": ($content | split("\n") | map(select(startswith("- "))) | map(.[2:]))
      }
    ')
  fi
  
  # Load epic decisions if task belongs to epic
  if [[ -n "$EPIC_ID" && -f ".doh/memory/epics/${EPIC_NAME}/decisions.md" ]]; then
    memory_context=$(echo "$memory_context" | jq --rawfile content .doh/memory/epics/${EPIC_NAME}/decisions.md '
      .epic_decisions = {
        "path": ".doh/memory/epics/'${EPIC_NAME}'/decisions.md",
        "key_decisions": ($content | split("\n") | map(select(startswith("- "))) | map(.[2:]))
      }
    ')
  fi
  
  echo "$memory_context"
}
```

### Codebase Context

```bash
load_codebase_context() {
  local tech_stack='[]'
  local build_system='null'
  local test_commands='[]'
  
  # Detect tech stack from files
  [[ -f "package.json" ]] && tech_stack=$(echo "$tech_stack" | jq '. + ["JavaScript/Node.js"]')
  [[ -f "composer.json" ]] && tech_stack=$(echo "$tech_stack" | jq '. + ["PHP"]')
  [[ -f "webpack.config.js" ]] && build_system='"Webpack"'
  [[ -f "vite.config.js" ]] && build_system='"Vite"'
  
  # Load test commands from package.json
  if [[ -f "package.json" ]]; then
    test_commands=$(jq -r '.scripts | to_entries | map(select(.key | startswith("test"))) | map(.value)' package.json 2>/dev/null || echo '[]')
  fi
  
  echo '{
    "tech_stack": '"$tech_stack"',
    "build_system": '"$build_system"',
    "test_commands": '"$test_commands"',
    "relevant_files": []
  }'
}
```

## Memory Updates Protocol

### Agent Memory Enrichment Interface

```bash
# Function for agents to update project memory during execution
update_project_memory() {
  local memory_type="$1"     # conventions|architecture|patterns|tech-stack
  local content="$2"         # Content to add
  local agent_id="$3"        # Agent ID for traceability
  
  mkdir -p .doh/memory/project
  
  case "$memory_type" in
    "conventions")
      echo "- $content" >> .doh/memory/project/conventions.md
      echo "  <!-- Added by agent $agent_id on $(date -u +"%Y-%m-%dT%H:%M:%SZ") -->" >> .doh/memory/project/conventions.md
      ;;
    "patterns")
      echo "- **Pattern**: $content" >> .doh/memory/project/patterns.md
      echo "  <!-- Discovered by agent $agent_id on $(date -u +"%Y-%m-%dT%H:%M:%SZ") -->" >> .doh/memory/project/patterns.md
      ;;
    "architecture")
      echo "- $content" >> .doh/memory/project/architecture.md
      echo "  <!-- Decision by agent $agent_id on $(date -u +"%Y-%m-%dT%H:%M:%SZ") -->" >> .doh/memory/project/architecture.md
      ;;
  esac
  
  # Update agent session with memory contribution
  update_agent_session_memory "$agent_id" "$memory_type" "$content"
}

# Function for agents to update epic-specific memory
update_epic_memory() {
  local epic_name="$1"       # Epic name/ID
  local memory_type="$2"     # decisions|context|learnings|code-map
  local content="$3"         # Content to add
  local agent_id="$4"        # Agent ID for traceability
  
  mkdir -p ".doh/memory/epics/$epic_name"
  
  case "$memory_type" in
    "decisions")
      echo "- $content" >> ".doh/memory/epics/$epic_name/decisions.md"
      echo "  <!-- Decision by agent $agent_id on $(date -u +"%Y-%m-%dT%H:%M:%SZ") -->" >> ".doh/memory/epics/$epic_name/decisions.md"
      ;;
    "learnings")
      echo "- **Learning**: $content" >> ".doh/memory/epics/$epic_name/learnings.md"
      echo "  <!-- Learned by agent $agent_id on $(date -u +"%Y-%m-%dT%H:%M:%SZ") -->" >> ".doh/memory/epics/$epic_name/learnings.md"
      ;;
    "context")
      echo "- $content" >> ".doh/memory/epics/$epic_name/context.md"
      echo "  <!-- Context by agent $agent_id on $(date -u +"%Y-%m-%dT%H:%M:%SZ") -->" >> ".doh/memory/epics/$epic_name/context.md"
      ;;
  esac
  
  # Update agent session with memory contribution
  update_agent_session_memory "$agent_id" "epic:$memory_type" "$content"
}

# Update agent session with memory contributions
update_agent_session_memory() {
  local agent_id="$1"
  local memory_type="$2"
  local content="$3"
  local session_file=".doh/memory/agent-sessions/${agent_id}.json"
  
  if [[ -f "$session_file" ]]; then
    # Add memory update to agent session
    jq --arg type "$memory_type" --arg content "$content" --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '
      .memory_updates += [{
        "type": $type,
        "content": $content,
        "timestamp": $timestamp
      }] |
      .last_updated = $timestamp
    ' "$session_file" > "${session_file}.tmp" && mv "${session_file}.tmp" "$session_file"
  fi
}

# Function for agents to record patterns discovered
record_pattern_discovery() {
  local pattern_name="$1"
  local description="$2"
  local files="$3"           # JSON array of files
  local agent_id="$4"
  local epic_name="$5"       # Optional epic context
  
  local pattern_data=$(cat <<EOF
{
  "name": "$pattern_name",
  "description": "$description", 
  "files": $files,
  "discovered_by": "$agent_id",
  "discovered_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "epic_context": "$epic_name"
}
EOF
)
  
  # Add to epic code-map if epic context
  if [[ -n "$epic_name" ]]; then
    mkdir -p ".doh/memory/epics/$epic_name"
    echo "$pattern_data" | jq '.' >> ".doh/memory/epics/$epic_name/code-map.json"
  fi
  
  # Add to project patterns
  update_project_memory "patterns" "$pattern_name: $description" "$agent_id"
}
```

### Agent Environment Variables

Agents have access to these memory update functions through environment:

```bash
export -f update_project_memory
export -f update_epic_memory  
export -f record_pattern_discovery
export DOH_AGENT_ID="${AGENT_ID}"
export DOH_EPIC_NAME="${EPIC_NAME}"
```

## Worktree Context Setup Script

### Complete Worktree Initialization

```bash
setup_agent_worktree() {
  local task_id="$1"
  local task_type="$2"      # task/epic/feature
  local task_name="$3"      # kebab-case name
  local agent_id="$4"
  
  local project_name=$(basename $(pwd))
  local worktree_name="${project_name}-worktree-${task_type}-${task_name}"
  local worktree_path="../${worktree_name}"
  local branch_name="${task_type}/${task_name}"
  
  echo "Setting up agent worktree: ${worktree_path}"
  
  # 1. Create Git worktree with proper branch
  if ! git show-ref --verify --quiet "refs/heads/${branch_name}"; then
    # Create new branch from current HEAD
    git checkout -b "${branch_name}"
    git checkout -  # Switch back to original branch
  fi
  
  # Create worktree
  git worktree add "${worktree_path}" "${branch_name}"
  
  # 2. Setup AI context (symlink strategy)
  if [[ -d ".claude" ]]; then
    echo "Creating .claude symlink in worktree..."
    ln -sf "$(pwd)/.claude" "${worktree_path}/.claude"
  else
    echo "Warning: .claude directory not found in main project"
  fi
  
  # 3. Verify .doh is available (should be via Git)
  if [[ -d ".doh" ]]; then
    echo "✓ .doh directory will be available in worktree via Git (versioned)"
  else
    echo "Creating initial .doh structure..."
    mkdir -p .doh/memory/{project,epics,agent-sessions}
    
    # Initialize minimal index.json if not exists
    if [[ ! -f ".doh/index.json" ]]; then
      cat > .doh/index.json << EOF
{
  "metadata": {
    "version": "1.4.0",
    "project_name": "${project_name}",
    "language": "en",
    "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "last_updated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  },
  "items": {},
  "dependency_graph": {}
}
EOF
    fi
    
    # Commit .doh structure
    git add .doh/
    git commit -m "[DOH INIT] Initialize /doh structure for agent ${agent_id}"
  fi
  
  # 4. Initialize agent session tracking
  mkdir -p .doh/memory/agent-sessions
  cat > ".doh/memory/agent-sessions/${agent_id}.json" << EOF
{
  "agent_id": "${agent_id}",
  "status": "initializing",
  "started_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "target": {
    "type": "${task_type}",
    "id": "${task_id}",
    "name": "${task_name}"
  },
  "worktree": "${worktree_path}",
  "branch": "${branch_name}",
  "progress": {
    "phase": "setup",
    "completed_subtasks": ["worktree_created"],
    "current_focus": "environment_setup",
    "files_modified": []
  },
  "memory_updates": [],
  "context_loaded_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
  
  # 5. Create worktree-specific environment script
  cat > "${worktree_path}/.doh-agent-env.sh" << 'EOF'
#!/bin/bash
# DOH Agent Environment Setup
# This script sets up the agent environment in the worktree

# Agent-specific environment variables
export DOH_AGENT_MODE=true
export DOH_WORKTREE_MODE=true
export DOH_MAIN_PROJECT="$(readlink -f ..)"

# Load memory update functions
source "${DOH_MAIN_PROJECT}/.claude/commands/doh/agent.md"

# Set up agent session tracking
update_agent_progress() {
  local phase="$1"
  local focus="$2"
  local files="${3:-[]}"
  
  jq --arg phase "$phase" --arg focus "$focus" --argjson files "$files" --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" '
    .progress.phase = $phase |
    .progress.current_focus = $focus |
    .progress.files_modified = $files |
    .last_updated = $timestamp |
    .status = "active"
  ' ".doh/memory/agent-sessions/${DOH_AGENT_ID}.json" > ".doh/memory/agent-sessions/${DOH_AGENT_ID}.json.tmp"
  
  mv ".doh/memory/agent-sessions/${DOH_AGENT_ID}.json.tmp" ".doh/memory/agent-sessions/${DOH_AGENT_ID}.json"
}

echo "DOH Agent environment loaded in worktree"
echo "Agent ID: ${DOH_AGENT_ID}"
echo "Main project: ${DOH_MAIN_PROJECT}"
EOF
  
  chmod +x "${worktree_path}/.doh-agent-env.sh"
  
  # 6. Update main project session tracking
  git add ".doh/memory/agent-sessions/${agent_id}.json"
  git commit -m "[DOH] Initialize agent session ${agent_id}"
  
  echo "✓ Agent worktree setup complete: ${worktree_path}"
  echo "✓ Branch: ${branch_name}"
  echo "✓ Agent session: ${agent_id}"
  echo "✓ Claude context: symlinked"
  echo "✓ DOH memory: available"
  
  # Return worktree path for agent launch
  echo "${worktree_path}"
}
```

### Worktree Validation

```bash
validate_worktree_setup() {
  local worktree_path="$1"
  local agent_id="$2"
  
  echo "Validating worktree setup..."
  
  # Check worktree exists and is valid
  if [[ ! -d "$worktree_path" ]]; then
    echo "❌ Worktree directory not found: $worktree_path"
    return 1
  fi
  
  # Check .claude symlink
  if [[ ! -L "$worktree_path/.claude" ]]; then
    echo "❌ .claude symlink not found in worktree"
    return 1
  fi
  
  # Check .doh availability
  if [[ ! -d "$worktree_path/.doh" ]]; then
    echo "❌ .doh directory not available in worktree"
    return 1
  fi
  
  # Check agent session file
  if [[ ! -f ".doh/memory/agent-sessions/${agent_id}.json" ]]; then
    echo "❌ Agent session file not found"
    return 1
  fi
  
  # Check agent environment script
  if [[ ! -x "$worktree_path/.doh-agent-env.sh" ]]; then
    echo "❌ Agent environment script not found or not executable"
    return 1
  fi
  
  echo "✅ Worktree setup validation passed"
  return 0
}
```

## Agent Session Integration Tests

### Test Scenarios: /doh:quick → /doh:agent Workflow

#### Test 1: Simple Task → Agent Assignment

```bash
# Scenario: User creates simple task via /doh:quick, then assigns to agent
test_simple_task_to_agent() {
  echo "=== Test 1: Simple Task → Agent Assignment ==="
  
  # 1. Create task via /doh:quick
  echo "Creating task via /doh:quick..."
  /doh:quick "fix typo in contact page title"
  # Expected: Task created in Epic #0 with auto-category 🐛 Bug
  
  # 2. Assign to agent
  echo "Assigning latest task to agent..."
  LATEST_TASK_ID=$(jq -r '.items | to_entries | map(select(.value.type == "task")) | sort_by(.value.created_at) | reverse | .[0].key' .doh/index.json)
  
  /doh:agent "#${LATEST_TASK_ID}"
  
  # 3. Verify agent setup
  echo "Verifying agent setup..."
  ls -la ../$(basename $(pwd))-worktree-task-*
  cat .doh/memory/agent-sessions/agent-*.json | head -20
  
  echo "✅ Test 1 completed"
}
```

#### Test 2: Complex Task → Questions → Agent Assignment

```bash
# Scenario: Complex task triggers questions, then gets assigned to agent
test_complex_task_workflow() {
  echo "=== Test 2: Complex Task → Questions → Agent Assignment ==="
  
  # 1. Create complex task that should trigger questions
  echo "Creating complex task via /doh:quick..."
  /doh:quick "implement real-time notification system"
  # Expected: Agent asks clarifying questions about scope
  
  # 2. After clarifications, assign to agent
  echo "Following up with agent assignment..."
  LATEST_TASK_ID=$(jq -r '.items | to_entries | map(select(.value.type == "task")) | sort_by(.value.created_at) | reverse | .[0].key' .doh/index.json)
  
  /doh:agent "#${LATEST_TASK_ID}"
  
  # 3. Verify agent has full context including clarifications
  AGENT_ID=$(ls .doh/memory/agent-sessions/ | grep "agent-" | head -1 | sed 's/.json//')
  echo "Agent context:"
  jq '.memory' ".doh/memory/agent-sessions/${AGENT_ID%.*}.json"
  
  echo "✅ Test 2 completed"
}
```

#### Test 3: Epic #0 Graduation → Feature Agent

```bash
# Scenario: Multiple related tasks in Epic #0 → graduation suggestion → feature agent
test_epic_graduation_workflow() {
  echo "=== Test 3: Epic #0 Graduation → Feature Agent ==="
  
  # 1. Create multiple related tasks in Epic #0
  echo "Creating multiple auth-related tasks..."
  /doh:quick "fix login validation"
  /doh:quick "update password requirements"  
  /doh:quick "improve session handling"
  /doh:quick "add two-factor authentication UI"
  /doh:quick "optimize auth database queries"
  /doh:quick "refactor authentication service"
  
  # 2. Check if Epic #0 graduation is suggested
  echo "Checking Epic #0 status..."
  AUTH_TASKS=$(jq -r '.items | to_entries | map(select(.value.epic_id == "0" and (.value.description | test("auth|login|password|session")))) | length' .doh/index.json)
  echo "Found ${AUTH_TASKS} auth-related tasks in Epic #0"
  
  # 3. Create dedicated epic and assign agent to it
  if [[ $AUTH_TASKS -ge 6 ]]; then
    echo "Creating dedicated Authentication epic..."
    /doh:epic-create "Authentication System Improvements"
    
    LATEST_EPIC_ID=$(jq -r '.items | to_entries | map(select(.value.type == "epic")) | sort_by(.value.created_at) | reverse | .[0].key' .doh/index.json)
    
    /doh:agent "#${LATEST_EPIC_ID}"
    echo "✅ Epic agent assigned"
  else
    echo "ℹ️  Not enough tasks for graduation yet"
  fi
  
  echo "✅ Test 3 completed"
}
```

### Integration Test Runner

```bash
run_integration_tests() {
  echo "🧪 Running /doh:quick → /doh:agent Integration Tests"
  echo "=============================================="
  
  # Setup test environment
  echo "Setting up test environment..."
  mkdir -p .doh-test-backup
  [[ -d .doh ]] && cp -r .doh .doh-test-backup/
  
  # Initialize fresh /doh structure for testing
  /doh:init --test-mode
  
  # Run tests
  test_simple_task_to_agent
  echo ""
  test_complex_task_workflow  
  echo ""
  test_epic_graduation_workflow
  
  # Generate test report
  echo ""
  echo "📊 Integration Test Report"
  echo "========================="
  echo "Total tasks created: $(jq '.items | to_entries | map(select(.value.type == "task")) | length' .doh/index.json)"
  echo "Total epics created: $(jq '.items | to_entries | map(select(.value.type == "epic")) | length' .doh/index.json)"
  echo "Active agent sessions: $(ls .doh/memory/agent-sessions/*.json 2>/dev/null | wc -l)"
  echo "Worktrees created: $(git worktree list | grep -c worktree || echo 0)"
  
  echo ""
  echo "🔗 Agent Session Summary:"
  for session_file in .doh/memory/agent-sessions/*.json; do
    if [[ -f "$session_file" ]]; then
      echo "- $(jq -r '"\(.agent_id): \(.target.type) #\(.target.id) (\(.status))"' "$session_file")"
    fi
  done
  
  # Restore original state if desired
  echo ""
  echo "Test completed. Original state backed up in .doh-test-backup/"
  echo "To restore: mv .doh-test-backup/.doh .doh"
}

# Export test functions for manual execution
export -f test_simple_task_to_agent
export -f test_complex_task_workflow
export -f test_epic_graduation_workflow
export -f run_integration_tests
```

## Agent Workflow

```text
Create autonomous agent environment for task/epic: {description_or_id}

1. Create worktree with branch epic/{epic_name}
2. Set up isolated development environment
3. Begin autonomous execution of assigned task/epic
4. Work independently following /doh standards and project conventions
```

## Output Location

- Autonomous agent works in separate worktree: `epic/{epic_name}` branch
- Agent maintains /doh traceability standards
- Independent commit history in agent branch

## Integration

- Links to original task/epic for traceability
- Maintains /doh standards for code comments and commits
- Agent works independently without human intervention
- Results can be merged back when complete

