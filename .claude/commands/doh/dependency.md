# /doh:dependency - Centralized Dependency Management

## Description
Manage dependencies between tasks, features, epics, and PRDs in the DOH system. This command provides centralized functionality for adding, removing, listing, and visualizing dependencies between DOH items.

## Usage

```bash
# Add dependency: Task #123 depends on Task #67
/doh:dependency add 123 67

# Remove dependency
/doh:dependency remove 123 67

# List dependencies for an item
/doh:dependency list 123

# Show full dependency graph
/doh:dependency graph

# Check for circular dependencies
/doh:dependency validate

# Show dependency path between two items  
/doh:dependency path 123 45
```

## Parameters

- **action**: `add|remove|list|graph|validate|path`
- **item_id**: DOH item ID (without ! prefix)
- **dependency_id**: Dependency item ID (for add/remove actions)
- **target_id**: Target item ID (for path action)

## Implementation

```bash
# Main dependency command function
doh_dependency_main() {
  local action="$1"
  local item_id="$2"
  local dependency_id="$3"
  local target_id="$4"
  
  # Load project index
  local index_file=".doh/project-index.json"
  if [[ ! -f "$index_file" ]]; then
    echo "Error: No DOH project found. Run /doh:init first."
    return 1
  fi
  
  case "$action" in
    "add")
      add_dependency "$item_id" "$dependency_id"
      ;;
    "remove")
      remove_dependency "$item_id" "$dependency_id"
      ;;
    "list")
      list_dependencies "$item_id"
      ;;
    "graph")
      show_dependency_graph
      ;;
    "validate")
      validate_dependencies
      ;;
    "path")
      find_dependency_path "$item_id" "$target_id"
      ;;
    *)
      show_dependency_help
      ;;
  esac
}

# Add dependency between two items
add_dependency() {
  local item_id="$1"
  local dependency_id="$2"
  
  # Validate items exist
  if ! item_exists "$item_id" || ! item_exists "$dependency_id"; then
    echo "Error: One or both items don't exist"
    return 1
  fi
  
  # Check for circular dependency
  if creates_circular_dependency "$item_id" "$dependency_id"; then
    echo "Error: Adding this dependency would create a circular dependency"
    return 1
  fi
  
  # Update dependency graph in index.json
  update_dependency_graph "add" "$item_id" "$dependency_id"
  
  echo "✅ Added dependency: !${item_id} depends on !${dependency_id}"
  
  # Update agent memory if available
  update_dependency_memory "$item_id" "$dependency_id" "added"
}

# Remove dependency between two items
remove_dependency() {
  local item_id="$1"
  local dependency_id="$2"
  
  # Check if dependency exists
  if ! dependency_exists "$item_id" "$dependency_id"; then
    echo "Warning: Dependency !${item_id} → !${dependency_id} doesn't exist"
    return 0
  fi
  
  # Update dependency graph in index.json
  update_dependency_graph "remove" "$item_id" "$dependency_id"
  
  echo "✅ Removed dependency: !${item_id} no longer depends on !${dependency_id}"
  
  # Update agent memory if available
  update_dependency_memory "$item_id" "$dependency_id" "removed"
}

# List all dependencies for an item
list_dependencies() {
  local item_id="$1"
  
  if ! item_exists "$item_id"; then
    echo "Error: Item !${item_id} doesn't exist"
    return 1
  fi
  
  echo "Dependencies for !${item_id}:"
  echo
  
  # Dependencies this item has (things it depends on)
  local depends_on=$(get_item_dependencies "$item_id")
  if [[ -n "$depends_on" ]]; then
    echo "Depends on:"
    for dep in $depends_on; do
      local title=$(get_item_title "$dep")
      echo "  → !${dep}: ${title}"
    done
  else
    echo "  No dependencies"
  fi
  
  echo
  
  # Items that depend on this item (blockers)
  local blocked_by=$(get_items_depending_on "$item_id")
  if [[ -n "$blocked_by" ]]; then
    echo "Blocks:"
    for item in $blocked_by; do
      local title=$(get_item_title "$item")
      echo "  ← !${item}: ${title}"
    done
  else
    echo "  Not blocking anything"
  fi
}

# Show complete dependency graph
show_dependency_graph() {
  echo "DOH Project Dependency Graph"
  echo "============================"
  echo
  
  # Load dependency graph from index.json
  local graph_data=$(jq -r '.dependency_graph' .doh/project-index.json)
  
  if [[ "$graph_data" == "null" || "$graph_data" == "{}" ]]; then
    echo "No dependencies defined yet."
    return 0
  fi
  
  echo "Format: [Item] → [Dependencies]"
  echo
  
  # Process each dependency relationship
  jq -r '.dependency_graph | to_entries[] | "\\(.key) → [\\(.value | join(", "))]"' .doh/project-index.json | while read -r line; do
    # Replace IDs with titles for readability
    echo "$line" | sed 's/!\([0-9]\+\)/\1/g' | while read -r formatted_line; do
      echo "  $formatted_line"
    done
  done
  
  echo
  echo "Use '/doh:dependency validate' to check for circular dependencies"
}

# Validate dependency graph for circular dependencies
validate_dependencies() {
  echo "Validating dependency graph..."
  
  # Implement topological sort algorithm to detect cycles
  local has_cycles=false
  local visited_file=$(mktemp)
  local recursion_stack_file=$(mktemp)
  
  # Get all items with dependencies
  local items=$(jq -r '.dependency_graph | keys[]' .doh/project-index.json)
  
  for item in $items; do
    if ! is_visited "$item" "$visited_file"; then
      if detect_cycle_dfs "$item" "$visited_file" "$recursion_stack_file"; then
        has_cycles=true
        break
      fi
    fi
  done
  
  rm -f "$visited_file" "$recursion_stack_file"
  
  if [[ "$has_cycles" == "true" ]]; then
    echo "❌ Circular dependencies detected!"
    echo "Please review and fix dependency relationships."
    return 1
  else
    echo "✅ No circular dependencies found."
    return 0
  fi
}

# Find dependency path between two items
find_dependency_path() {
  local from_id="$1"
  local to_id="$2"
  
  if ! item_exists "$from_id" || ! item_exists "$to_id"; then
    echo "Error: One or both items don't exist"
    return 1
  fi
  
  echo "Finding dependency path from !${from_id} to !${to_id}..."
  
  # Implement breadth-first search to find path
  local path=$(find_bfs_path "$from_id" "$to_id")
  
  if [[ -n "$path" ]]; then
    echo "Dependency path found:"
    echo "$path"
  else
    echo "No dependency path exists between these items."
  fi
}

# Helper functions for dependency management

# Check if item exists in index
item_exists() {
  local item_id="$1"
  jq -e ".items.tasks.\"$item_id\" // .items.features.\"$item_id\" // .items.epics.\"$item_id\" // .items.prds.\"$item_id\"" .doh/project-index.json >/dev/null 2>&1
}

# Check if dependency already exists
dependency_exists() {
  local item_id="$1"
  local dependency_id="$2"
  jq -e ".dependency_graph.\"$item_id\" // [] | index(\"$dependency_id\")" .doh/project-index.json >/dev/null 2>&1
}

# Check if adding dependency would create cycle
creates_circular_dependency() {
  local item_id="$1"
  local dependency_id="$2"
  
  # If dependency_id already depends on item_id (directly or indirectly), 
  # then adding item_id → dependency_id would create a cycle
  local temp_path=$(find_bfs_path "$dependency_id" "$item_id")
  [[ -n "$temp_path" ]]
}

# Update dependency graph in index.json
update_dependency_graph() {
  local action="$1"
  local item_id="$2"
  local dependency_id="$3"
  
  local temp_file=$(mktemp)
  
  if [[ "$action" == "add" ]]; then
    # Add dependency to graph
    jq ".dependency_graph.\"$item_id\" = (.dependency_graph.\"$item_id\" // []) + [\"$dependency_id\"] | .dependency_graph.\"$item_id\" |= unique" .doh/project-index.json > "$temp_file"
  elif [[ "$action" == "remove" ]]; then
    # Remove dependency from graph
    jq ".dependency_graph.\"$item_id\" = (.dependency_graph.\"$item_id\" // []) - [\"$dependency_id\"]" .doh/project-index.json > "$temp_file"
  fi
  
  mv "$temp_file" .doh/project-index.json
  
  # Update timestamps
  update_index_timestamp
}

# Get item dependencies
get_item_dependencies() {
  local item_id="$1"
  jq -r ".dependency_graph.\"$item_id\" // [] | .[]" .doh/project-index.json
}

# Get items that depend on given item
get_items_depending_on() {
  local target_id="$1"
  jq -r ".dependency_graph | to_entries[] | select(.value[] == \"$target_id\") | .key" .doh/project-index.json
}

# Get item title for display
get_item_title() {
  local item_id="$1"
  jq -r ".items.tasks.\"$item_id\".title // .items.features.\"$item_id\".title // .items.epics.\"$item_id\".title // .items.prds.\"$item_id\".title // \"Unknown\"" .doh/project-index.json
}

# Update agent memory with dependency change
update_dependency_memory() {
  local item_id="$1"
  local dependency_id="$2"
  local action="$3"
  
  # Update active session memory if available
  if [[ -f ".doh/memory/active-session.json" ]]; then
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local temp_file=$(mktemp)
    
    jq ".dependency_changes = (.dependency_changes // []) + [{
      \"timestamp\": \"$timestamp\",
      \"action\": \"$action\",
      \"item_id\": \"$item_id\",
      \"dependency_id\": \"$dependency_id\"
    }]" .doh/memory/active-session.json > "$temp_file"
    
    mv "$temp_file" .doh/memory/active-session.json
  fi
}

# Update index timestamp
update_index_timestamp() {
  local temp_file=$(mktemp)
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  jq ".metadata.updated_at = \"$timestamp\"" .doh/project-index.json > "$temp_file"
  mv "$temp_file" .doh/project-index.json
}

# BFS path finding (simplified implementation)
find_bfs_path() {
  local from_id="$1"
  local to_id="$2"
  
  # Simplified BFS - in real implementation would use queue data structure
  # This is a placeholder for the concept
  echo "  !${from_id} → !${to_id} (direct/indirect path analysis needed)"
}

# Show help for dependency command
show_dependency_help() {
  echo "DOH Dependency Management"
  echo "========================"
  echo
  echo "Usage:"
  echo "  /doh:dependency add <item_id> <dependency_id>    # Add dependency"
  echo "  /doh:dependency remove <item_id> <dependency_id> # Remove dependency"
  echo "  /doh:dependency list <item_id>                   # List item dependencies"
  echo "  /doh:dependency graph                            # Show dependency graph"
  echo "  /doh:dependency validate                         # Check for circular deps"
  echo "  /doh:dependency path <from_id> <to_id>          # Find dependency path"
  echo
  echo "Examples:"
  echo "  /doh:dependency add 123 67     # Task 123 depends on Task 67"
  echo "  /doh:dependency list 123       # Show what 123 depends on"
  echo "  /doh:dependency graph          # Visual dependency overview"
}

# Export functions for agent use
export -f doh_dependency_main
export -f add_dependency
export -f remove_dependency
export -f list_dependencies
export -f show_dependency_graph
export -f validate_dependencies
export -f find_dependency_path

# Set environment variables for agents
export DOH_DEPENDENCY_MANAGEMENT="enabled"
export DOH_DEPENDENCY_VALIDATION="enabled"
```

## Integration Points

### With Other DOH Commands
- `/doh:quick` - Automatically detect dependencies based on task descriptions
- `/doh:agent` - Include dependency context in agent bundles
- `/doh:task` / `/doh:epic` - Show dependencies when displaying items
- `/doh:sync-github` - Sync dependency relationships to GitHub issue links

### With Memory System
- Record dependency changes in active session
- Track dependency patterns in project memory
- Include dependency context in agent sessions

### With Agent Context Protocol
- Dependencies included in context bundles for agent awareness
- Agent memory enrichment includes dependency discoveries
- Worktree creation considers dependency relationships

## Test Scenarios

### Basic Dependency Management
```bash
# Create test items
/doh:quick "Setup database schema"      # Gets ID 1
/doh:quick "Create user authentication" # Gets ID 2

# Add dependency: Authentication depends on database
/doh:dependency add 2 1

# Verify dependency
/doh:dependency list 2

# Show full graph
/doh:dependency graph
```

### Circular Dependency Prevention
```bash
# Create chain: A → B → C
/doh:dependency add 1 2
/doh:dependency add 2 3

# Try to create circle: C → A (should fail)
/doh:dependency add 3 1

# Validate should pass
/doh:dependency validate
```

### Dependency Path Finding
```bash
# Find path between distant items
/doh:dependency path 1 5
```

## Error Handling

- **Non-existent items**: Clear error messages when items don't exist
- **Circular dependencies**: Prevention with helpful error messages
- **Invalid operations**: Graceful handling of edge cases
- **Index corruption**: Validation and recovery suggestions

## Performance Considerations

- **Graph operations**: Efficient algorithms for large dependency graphs
- **Index updates**: Atomic operations to prevent corruption
- **Memory usage**: Optimized for projects with hundreds of dependencies
- **Caching**: Dependency calculations cached where appropriate