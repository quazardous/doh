#!/bin/bash

# Message queue system for DOH number conflicts and renumbering operations
# File-based queue with atomic operations and status tracking

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/workspace.sh"
source "$(dirname "${BASH_SOURCE[0]}")/numbering.sh"

# Constants
readonly QUEUE_VERSION="1.0"
readonly DEFAULT_QUEUE_NAME="number_conflict"

# Queue status constants
readonly QUEUE_STATUS_PENDING=""
readonly QUEUE_STATUS_OK=".ok"
readonly QUEUE_STATUS_ERROR=".error"

# @description Generate unique message ID
# @stdout Unique message ID string
# @exitcode 0 If successful
generate_message_id() {
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    
    # Create a simple UUID-like identifier using timestamp + random + PID
    local random_part
    random_part=$(od -An -tx4 -N4 /dev/urandom | tr -d ' ')
    
    echo "msg_${timestamp}_${random_part}_$$"
}

# @description Get queue directory path
# @arg $1 string Optional queue name (default: number_conflict)
# @stdout Path to queue directory
# @exitcode 0 If successful
# @exitcode 1 If project ID cannot be retrieved
get_queue_dir() {
    local queue_name="${1:-$DEFAULT_QUEUE_NAME}"
    
    local project_id
    project_id="$(get_current_project_id)" || return 1
    
    echo "$HOME/.doh/projects/$project_id/queues/$queue_name"
}

# @description Ensure queue directory exists
# @arg $1 string Optional queue name (default: number_conflict)
# @stdout Path to ensured queue directory
# @exitcode 0 If successful
# @exitcode 1 If directory cannot be created
ensure_queue_dir() {
    local queue_name="${1:-$DEFAULT_QUEUE_NAME}"
    
    local queue_dir
    queue_dir="$(get_queue_dir "$queue_name")" || return 1
    
    mkdir -p "$queue_dir" || {
        echo "Error: Could not create queue directory: $queue_dir" >&2
        return 1
    }
    
    echo "$queue_dir"
}

# @description Create renumber message
# @arg $1 string Type of source ("task" or "epic")
# @arg $2 string Original identifier
# @arg $3 string Current number
# @arg $4 string New number
# @arg $5 string Reason for renumber ("conflict" or "gap_filling")
# @arg $6 string Optional JSON metadata
# @stdout JSON message string
# @stderr Error messages for invalid parameters
# @exitcode 0 If successful
# @exitcode 1 If invalid parameters provided
create_renumber_message() {
    local source_type="$1"      # "task" or "epic"
    local source_id="$2"        # original identifier
    local source_number="$3"    # current number
    local target_number="$4"    # new number
    local reason="$5"           # "conflict" or "gap_filling"
    local metadata="${6:-}"     # optional JSON metadata
    
    if [[ -z "$source_type" || -z "$source_id" || -z "$source_number" || -z "$target_number" || -z "$reason" ]]; then
        echo "Error: Missing required parameters for renumber message" >&2
        return 1
    fi
    
    if [[ "$source_type" != "task" && "$source_type" != "epic" ]]; then
        echo "Error: Invalid source type. Must be 'task' or 'epic'" >&2
        return 1
    fi
    
    local message_id timestamp
    message_id="$(generate_message_id)"
    timestamp="$(date -Iseconds)"
    
    # Build message JSON
    local message='{}'
    message=$(echo "$message" | jq --arg id "$message_id" '. + {id: $id}')
    message=$(echo "$message" | jq --arg ts "$timestamp" '. + {timestamp: $ts}')
    message=$(echo "$message" | jq '. + {operation: "renumber"}')
    
    # Add source information
    local source_obj='{}'
    source_obj=$(echo "$source_obj" | jq --arg type "$source_type" '. + {type: $type}')
    source_obj=$(echo "$source_obj" | jq --arg id "$source_id" '. + {id: $id}')
    source_obj=$(echo "$source_obj" | jq --arg num "$source_number" '. + {number: ($num | tonumber)}')
    message=$(echo "$message" | jq --argjson src "$source_obj" '. + {source: $src}')
    
    # Add target information
    local target_obj='{}'
    target_obj=$(echo "$target_obj" | jq --arg num "$target_number" '. + {number: ($num | tonumber)}')
    message=$(echo "$message" | jq --argjson tgt "$target_obj" '. + {target: $tgt}')
    
    # Add reason
    message=$(echo "$message" | jq --arg reason "$reason" '. + {reason: $reason}')
    
    # Add metadata if provided
    if [[ -n "$metadata" ]]; then
        message=$(echo "$message" | jq --argjson meta "$metadata" '. + {metadata: $meta}')
    else
        # Default metadata
        local default_meta='{}'
        default_meta=$(echo "$default_meta" | jq --arg user "${USER:-unknown}" '. + {user: $user}')
        default_meta=$(echo "$default_meta" | jq '. + {command: "system"}')
        message=$(echo "$message" | jq --argjson meta "$default_meta" '. + {metadata: $meta}')
    fi
    
    echo "$message"
}

# @description Queue a message (atomic operation)
# @arg $1 string Name of the queue
# @arg $2 string JSON message to queue
# @stdout Message ID if successful
# @stderr Error messages and confirmation
# @exitcode 0 If successful
# @exitcode 1 If invalid parameters or operation fails
queue_message() {
    local queue_name="$1"
    local message="$2"
    
    if [[ -z "$queue_name" || -z "$message" ]]; then
        echo "Error: Queue name and message required" >&2
        return 1
    fi
    
    local queue_dir
    queue_dir="$(ensure_queue_dir "$queue_name")" || return 1
    
    # Extract message ID for filename
    local message_id
    message_id=$(echo "$message" | jq -r '.id')
    
    if [[ -z "$message_id" || "$message_id" == "null" ]]; then
        echo "Error: Message must have an 'id' field" >&2
        return 1
    fi
    
    local message_file="$queue_dir/$message_id.json"
    local temp_file="$message_file.tmp"
    
    # Check if message already exists
    if [[ -f "$message_file" ]]; then
        echo "Warning: Message $message_id already exists in queue" >&2
        return 0
    fi
    
    # Validate JSON format
    if ! echo "$message" | jq empty 2>/dev/null; then
        echo "Error: Invalid JSON message format" >&2
        return 1
    fi
    
    # Write to temp file first (atomic operation)
    echo "$message" | jq . > "$temp_file" || {
        echo "Error: Failed to write message to temp file" >&2
        return 1
    }
    
    # Atomically move temp file to final location
    mv "$temp_file" "$message_file" || {
        echo "Error: Failed to move message to queue" >&2
        rm -f "$temp_file"
        return 1
    }
    
    echo "Message queued: $message_id" >&2
    echo "$message_id"
}

# @description Change message status
# @arg $1 string Name of the queue
# @arg $2 string Message ID to update
# @arg $3 string New status ("", ".ok", or ".error")
# @arg $4 string Optional error information
# @stderr Status change confirmation
# @exitcode 0 On success
# @exitcode 1 On error
set_message_status() {
    local queue_name="$1"
    local message_id="$2"
    local status="$3"  # "", ".ok", or ".error"
    local error_info="${4:-}"  # optional error information
    
    if [[ -z "$queue_name" || -z "$message_id" ]]; then
        echo "Error: Queue name and message ID required" >&2
        return 1
    fi
    
    local queue_dir
    queue_dir="$(get_queue_dir "$queue_name")" || return 1
    
    local current_file new_file
    
    # Find current message file
    if [[ -f "$queue_dir/$message_id.json" ]]; then
        current_file="$queue_dir/$message_id.json"
    elif [[ -f "$queue_dir/$message_id.json.ok" ]]; then
        current_file="$queue_dir/$message_id.json.ok"
    elif [[ -f "$queue_dir/$message_id.json.error" ]]; then
        current_file="$queue_dir/$message_id.json.error"
    else
        echo "Error: Message $message_id not found in queue" >&2
        return 1
    fi
    
    new_file="$queue_dir/$message_id.json$status"
    
    # If adding error status, update message with error info
    if [[ "$status" == "$QUEUE_STATUS_ERROR" && -n "$error_info" ]]; then
        local temp_file="$new_file.tmp"
        
        # Add error information to message
        jq --arg error "$error_info" --arg ts "$(date -Iseconds)" '
            . + {
                error: $error,
                error_timestamp: $ts
            }
        ' "$current_file" > "$temp_file" || {
            echo "Error: Failed to update message with error info" >&2
            return 1
        }
        
        # Atomically replace
        mv "$temp_file" "$new_file" && rm -f "$current_file"
    else
        # Simple rename for status change
        mv "$current_file" "$new_file"
    fi
    
    echo "Message $message_id status changed to: $status" >&2
    return 0
}

# @description Get message content
# @arg $1 string Name of the queue
# @arg $2 string Message ID to retrieve
# @stdout JSON message content
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If message not found
get_message() {
    local queue_name="$1"
    local message_id="$2"
    
    if [[ -z "$queue_name" || -z "$message_id" ]]; then
        echo "Error: Queue name and message ID required" >&2
        return 1
    fi
    
    local queue_dir
    queue_dir="$(get_queue_dir "$queue_name")" || return 1
    
    # Find message file regardless of status
    local message_file
    if [[ -f "$queue_dir/$message_id.json" ]]; then
        message_file="$queue_dir/$message_id.json"
    elif [[ -f "$queue_dir/$message_id.json.ok" ]]; then
        message_file="$queue_dir/$message_id.json.ok"
    elif [[ -f "$queue_dir/$message_id.json.error" ]]; then
        message_file="$queue_dir/$message_id.json.error"
    else
        return 1
    fi
    
    cat "$message_file"
}

# @description List messages by status
# @arg $1 string Name of the queue
# @arg $2 string Optional status filter ("pending", "ok", "error")
# @stdout List of message IDs and statuses
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If invalid parameters
list_messages() {
    local queue_name="$1"
    local status_filter="$2"  # optional: "pending", "ok", "error", or empty for all
    
    if [[ -z "$queue_name" ]]; then
        echo "Error: Queue name required" >&2
        return 1
    fi
    
    local queue_dir
    queue_dir="$(get_queue_dir "$queue_name")" || return 1
    
    if [[ ! -d "$queue_dir" ]]; then
        return 0  # Empty queue
    fi
    
    local pattern
    case "$status_filter" in
        "pending")
            pattern="*.json"
            ;;
        "ok")
            pattern="*.json.ok"
            ;;
        "error")
            pattern="*.json.error"
            ;;
        "")
            pattern="*.json*"
            ;;
        *)
            echo "Error: Invalid status filter. Use: pending, ok, error, or empty" >&2
            return 1
            ;;
    esac
    
    # List files and extract message IDs
    find "$queue_dir" -name "$pattern" -type f 2>/dev/null | while read -r file; do
        local basename
        basename=$(basename "$file")
        
        # Extract message ID (remove .json and status suffixes)
        local message_id
        message_id=$(echo "$basename" | sed 's/\.json.*$//')
        
        # Determine actual status
        local actual_status="pending"
        if [[ "$basename" == *.json.ok ]]; then
            actual_status="ok"
        elif [[ "$basename" == *.json.error ]]; then
            actual_status="error"
        fi
        
        echo "$message_id $actual_status"
    done | sort
}

# @description Count messages by status
# @arg $1 string Name of the queue
# @arg $2 string Optional status filter
# @stdout Number of messages
# @exitcode 0 If successful
count_messages() {
    local queue_name="$1"
    local status_filter="$2"
    
    list_messages "$queue_name" "$status_filter" | wc -l
}

# @description Purge processed messages (ok and error)
# @arg $1 string Name of the queue
# @arg $2 string Optional max age in days (default: 7)
# @stderr Purge operation summary
# @exitcode 0 On success
# @exitcode 1 If invalid parameters
purge_processed_messages() {
    local queue_name="$1"
    local max_age_days="${2:-7}"  # Default: keep for 7 days
    
    if [[ -z "$queue_name" ]]; then
        echo "Error: Queue name required" >&2
        return 1
    fi
    
    local queue_dir
    queue_dir="$(get_queue_dir "$queue_name")" || return 1
    
    if [[ ! -d "$queue_dir" ]]; then
        echo "Queue directory does not exist: $queue_dir" >&2
        return 0
    fi
    
    local purged_count=0
    
    # Find and remove old processed messages
    find "$queue_dir" -name "*.json.ok" -o -name "*.json.error" -type f -mtime "+$max_age_days" | while read -r file; do
        rm -f "$file" && ((purged_count++))
    done
    
    echo "Purged $purged_count processed messages older than $max_age_days days" >&2
    return 0
}

# @description Get queue statistics
# @arg $1 string Name of the queue
# @stdout Formatted statistics string
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If invalid parameters
get_queue_stats() {
    local queue_name="$1"
    
    if [[ -z "$queue_name" ]]; then
        echo "Error: Queue name required" >&2
        return 1
    fi
    
    local queue_dir
    queue_dir="$(get_queue_dir "$queue_name")" || return 1
    
    local pending_count ok_count error_count total_count
    pending_count="$(count_messages "$queue_name" "pending")"
    ok_count="$(count_messages "$queue_name" "ok")"
    error_count="$(count_messages "$queue_name" "error")"
    total_count=$((pending_count + ok_count + error_count))
    
    cat << EOF
Queue Statistics ($queue_name):
  Pending: $pending_count
  Processed OK: $ok_count
  Errors: $error_count
  Total: $total_count
  Queue Directory: $queue_dir
EOF
}

# @description Process a pending message (example implementation)
# @arg $1 string Name of the queue
# @arg $2 string Message ID to process
# @stderr Processing status messages
# @exitcode 0 On success
# @exitcode 1 On error
process_message() {
    local queue_name="$1"
    local message_id="$2"
    
    if [[ -z "$queue_name" || -z "$message_id" ]]; then
        echo "Error: Queue name and message ID required" >&2
        return 1
    fi
    
    # Get message content
    local message
    message="$(get_message "$queue_name" "$message_id")" || {
        echo "Error: Could not retrieve message $message_id" >&2
        return 1
    }
    
    # Extract operation type
    local operation
    operation=$(echo "$message" | jq -r '.operation')
    
    case "$operation" in
        "renumber")
            # This is a placeholder - actual implementation would call renumbering functions
            echo "Processing renumber operation for message $message_id" >&2
            
            # Simulate processing
            sleep 0.1
            
            # Mark as successful
            set_message_status "$queue_name" "$message_id" "$QUEUE_STATUS_OK"
            ;;
        *)
            # Unknown operation
            set_message_status "$queue_name" "$message_id" "$QUEUE_STATUS_ERROR" "Unknown operation: $operation"
            return 1
            ;;
    esac
    
    return 0
}

# @description Validate message format
# @arg $1 string JSON message to validate
# @stderr Error messages for invalid format
# @exitcode 0 If valid
# @exitcode 1 If invalid
validate_message() {
    local message="$1"
    
    if [[ -z "$message" ]]; then
        echo "Error: Empty message" >&2
        return 1
    fi
    
    # Check if valid JSON
    if ! echo "$message" | jq empty 2>/dev/null; then
        echo "Error: Invalid JSON format" >&2
        return 1
    fi
    
    # Check required fields
    local required_fields=("id" "timestamp" "operation")
    
    for field in "${required_fields[@]}"; do
        if ! echo "$message" | jq -e ".$field" >/dev/null 2>&1; then
            echo "Error: Missing required field: $field" >&2
            return 1
        fi
    done
    
    # Validate operation-specific fields
    local operation
    operation=$(echo "$message" | jq -r '.operation')
    
    case "$operation" in
        "renumber")
            local renumber_fields=("source" "target" "reason")
            for field in "${renumber_fields[@]}"; do
                if ! echo "$message" | jq -e ".$field" >/dev/null 2>&1; then
                    echo "Error: Missing required field for renumber operation: $field" >&2
                    return 1
                fi
            done
            ;;
        *)
            echo "Error: Unknown operation: $operation" >&2
            return 1
            ;;
    esac
    
    return 0
}