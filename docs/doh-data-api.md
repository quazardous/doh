# DOH Data API Reference

> **Quick reference for DOH internal data manipulation functions**

## File Cache (file-cache.sh)

| Function | Description | Signature |
|----------|-------------|-----------|
| `find_file_by_number` | Find task/epic by number | `find_file_by_number "006"` |
| `add_to_file_cache` | Add entry to cache | `add_to_file_cache "006" "task" "path" "name" "epic"` |
| `remove_from_file_cache` | Remove cache entry | `remove_from_file_cache "006" "path"` |
| `list_epic_files` | List all files in epic | `list_epic_files "epic-name"` |
| `get_file_cache_stats` | Get cache statistics | `get_file_cache_stats` |
| `rebuild_file_cache` | Rebuild entire cache | `rebuild_file_cache` |
| `detect_duplicates` | Find duplicate numbers | `detect_duplicates` |

## Graph Cache (graph-cache.sh)

| Function | Description | Signature |
|----------|-------------|-----------|
| `add_relationship` | Add parent-child relationship | `add_relationship "002" "001" "epic-name"` |
| `get_parent` | Get parent of item | `get_parent "002"` |
| `get_children` | Get children of item | `get_children "001"` |
| `get_epic` | Get epic name for item | `get_epic "002"` |
| `remove_relationship` | Remove relationship | `remove_relationship "002"` |
| `rebuild_graph_cache` | Rebuild graph cache | `rebuild_graph_cache` |
| `print_relationship_tree` | Display tree structure | `print_relationship_tree "001"` |

## Frontmatter (frontmatter.sh)

| Function | Description | Signature |
|----------|-------------|-----------|
| `get_frontmatter_field` | Read field value | `get_frontmatter_field "file.md" "status"` |
| `update_frontmatter_field` | Update field value | `update_frontmatter_field "file.md" "status" "closed"` |
| `extract_frontmatter` | Get all frontmatter | `extract_frontmatter "file.md"` |
| `validate_frontmatter` | Validate structure | `validate_frontmatter "file.md"` |
| `has_frontmatter` | Check if file has frontmatter | `has_frontmatter "file.md"` |

## Numbering (numbering.sh)

| Function | Description | Signature |
|----------|-------------|-----------|
| `get_next_number` | Get next available number | `get_next_number "task"` |
| `register_task` | Register new task | `register_task "006" "001" "path" "name" "epic" "metadata"` |
| `register_epic` | Register new epic | `register_epic "001" "path" "metadata"` |
| `find_by_number` | Find registry entry | `find_by_number "006"` |
| `validate_number` | Check number availability | `validate_number "006" "task"` |
| `get_registry_stats` | Get registry statistics | `get_registry_stats` |

## Task Operations (task.sh)

| Function | Description | Signature |
|----------|-------------|-----------|
| `get_task_status` | Get task status | `get_task_status "task.md"` |
| `is_task_completed` | Check if completed | `is_task_completed "task.md"` |
| `calculate_epic_progress` | Calculate progress % | `calculate_epic_progress "epic-name"` |
| `list_epic_tasks` | List tasks in epic | `list_epic_tasks "epic-name"` |
| `verify_task_completion` | Verify completion | `verify_task_completion "task.md"` |
| `get_task_name` | Get task name | `get_task_name "task.md"` |
| `is_task_parallel` | Check if parallel task | `is_task_parallel "task.md"` |

## Version Management (version.sh)

| Function | Description | Signature |
|----------|-------------|-----------|
| `get_current_version` | Get project version | `get_current_version` |
| `get_file_version` | Get file version | `get_file_version "file.md"` |
| `set_file_version` | Set file version | `set_file_version "file.md" "1.0.0"` |
| `bump_project_version` | Bump project version | `bump_project_version "patch"` |
| `validate_version` | Validate version format | `validate_version "1.0.0"` |

## Message Queue (message-queue.sh)

| Function | Description | Signature |
|----------|-------------|-----------|
| `queue_message` | Queue a message | `queue_message "queue" "message"` |
| `get_message` | Get message content | `get_message "queue" "id"` |
| `list_messages` | List messages by status | `list_messages "queue" "pending"` |
| `process_message` | Process pending message | `process_message "queue" "id"` |
| `get_queue_stats` | Get queue statistics | `get_queue_stats "queue"` |

## Workspace (workspace.sh)

| Function | Description | Signature |
|----------|-------------|-----------|
| `get_current_project_id` | Get current project ID | `get_current_project_id` |
| `detect_workspace_mode` | Detect workspace type | `detect_workspace_mode` |
| `ensure_project_state_dir` | Ensure state directory | `ensure_project_state_dir` |
| `load_workspace_state` | Load workspace state | `load_workspace_state` |
| `save_workspace_state` | Save workspace state | `save_workspace_state "key" "value"` |

## Standard Usage Pattern

```bash
#!/bin/bash
# Load required libraries
source .claude/scripts/doh/lib/file-cache.sh
source .claude/scripts/doh/lib/frontmatter.sh
source .claude/scripts/doh/lib/task.sh

# Find and update task
task_file=$(find_file_by_number "$1")
[[ -n "$task_file" ]] || { echo "Task not found"; exit 1; }

update_frontmatter_field "$task_file" "status" "closed"
echo "Task $1 closed"
```

---
*Generated from current library state - all functions verified to exist*