#!/bin/bash

# DOH Queue Helper
# User-facing functions for DOH message queue management

# Source required dependencies
source "$(dirname "${BASH_SOURCE[0]}")/../lib/message-queue.sh"

# Guard against multiple sourcing
[[ -n "${DOH_HELPER_QUEUE_LOADED:-}" ]] && return 0
DOH_HELPER_QUEUE_LOADED=1

# @description Show queue status and recent messages
# @arg $1 string Optional queue name (default: DEFAULT_QUEUE_NAME)
# @stdout Queue status information and recent messages
# @exitcode 0 Always successful
helper_queue_status() {
    local queue_name="${1:-$DEFAULT_QUEUE_NAME}"
    
    echo "DOH Message Queue Status"
    echo "======================="
    echo ""
    
    get_queue_stats "$queue_name"
    
    echo ""
    echo "Recent Messages:"
    echo "---------------"
    
    # Show last 10 messages with their status
    list_messages "$queue_name" | tail -10 | while IFS=' ' read -r msg_id status; do
        if [[ -n "$msg_id" ]]; then
            local timestamp
            timestamp=$(get_message "$queue_name" "$msg_id" 2>/dev/null | jq -r '.timestamp // "unknown"')
            printf "  %-30s %-10s %s\n" "$msg_id" "$status" "$timestamp"
        fi
    done
    
    return 0
}

# @description List messages in queue with optional filtering
# @arg $1 string Optional queue name (default: DEFAULT_QUEUE_NAME)
# @arg $2 string Optional status filter (pending, ok, error)
# @arg $3 string Optional verbose flag (--verbose)
# @stdout Messages in queue with optional details
# @exitcode 0 Always successful
helper_queue_list() {
    local queue_name="${1:-$DEFAULT_QUEUE_NAME}"
    local status_filter="$2"  # optional: pending, ok, error
    local verbose="$3"        # optional: --verbose
    
    echo "Messages in queue: $queue_name"
    
    if [[ -n "$status_filter" ]]; then
        echo "Filter: $status_filter"
    fi
    
    echo "=============================="
    
    list_messages "$queue_name" "$status_filter" | while IFS=' ' read -r msg_id status; do
        if [[ -n "$msg_id" ]]; then
            if [[ "$verbose" == "--verbose" || "$verbose" == "-v" ]]; then
                # Show detailed message info
                local message
                message=$(get_message "$queue_name" "$msg_id" 2>/dev/null)
                
                if [[ -n "$message" ]]; then
                    local timestamp operation reason
                    timestamp=$(echo "$message" | jq -r '.timestamp // "unknown"')
                    operation=$(echo "$message" | jq -r '.operation // "unknown"')
                    reason=$(echo "$message" | jq -r '.reason // "unknown"')
                    
                    echo "Message: $msg_id [$status]"
                    echo "  Timestamp: $timestamp"
                    echo "  Operation: $operation"
                    echo "  Reason: $reason"
                    
                    # Show source/target for renumber operations
                    if [[ "$operation" == "renumber" ]]; then
                        local source_type source_number target_number
                        source_type=$(echo "$message" | jq -r '.source.type // "unknown"')
                        source_number=$(echo "$message" | jq -r '.source.number // "unknown"')
                        target_number=$(echo "$message" | jq -r '.target.number // "unknown"')
                        
                        echo "  Source: $source_type #$source_number"
                        echo "  Target: #$target_number"
                    fi
                    
                    # Show error info if present
                    if [[ "$status" == "error" ]]; then
                        local error_info
                        error_info=$(echo "$message" | jq -r '.error // "No error details"')
                        echo "  Error: $error_info"
                    fi
                    
                    echo ""
                fi
            else
                # Simple listing
                local timestamp
                timestamp=$(get_message "$queue_name" "$msg_id" 2>/dev/null | jq -r '.timestamp // "unknown"')
                printf "%-30s %-10s %s\n" "$msg_id" "$status" "$timestamp"
            fi
        fi
    done
    
    return 0
}

# @description Purge old processed messages from queue
# @arg $1 string Optional queue name (default: DEFAULT_QUEUE_NAME)
# @arg $2 string Optional max age in days (default: 7)
# @stdin User confirmation for purge operation
# @stdout Purge progress and confirmation prompts
# @exitcode 0 If successful or cancelled
# @exitcode 1 If queue directory access fails
helper_queue_purge() {
    local queue_name="${1:-$DEFAULT_QUEUE_NAME}"
    local max_age_days="${2:-7}"
    
    echo "Purging processed messages from queue: $queue_name"
    echo "Maximum age: $max_age_days days"
    echo ""
    
    # Show what will be purged first
    local queue_dir
    queue_dir="$(get_queue_dir "$queue_name")" || return 1
    
    if [[ -d "$queue_dir" ]]; then
        local files_to_purge
        files_to_purge=$(find "$queue_dir" -name "*.json.ok" -o -name "*.json.error" -type f -mtime "+$max_age_days" | wc -l)
        
        echo "Files to purge: $files_to_purge"
        
        if [[ $files_to_purge -gt 0 ]]; then
            read -p "Continue with purge? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                purge_processed_messages "$queue_name" "$max_age_days"
                echo "Purge completed"
            else
                echo "Purge cancelled"
            fi
        else
            echo "No files to purge"
        fi
    else
        echo "Queue directory does not exist: $queue_dir"
    fi
    
    return 0
}

# @description Retry a failed message in the queue
# @arg $1 string Optional queue name (default: DEFAULT_QUEUE_NAME)
# @arg $2 string Message ID to retry (required)
# @stdin User confirmation for processing message
# @stdout Retry progress and status messages
# @exitcode 0 If successful
# @exitcode 1 If invalid parameters or message not found
helper_queue_retry() {
    local queue_name="${1:-$DEFAULT_QUEUE_NAME}"
    local message_id="$2"
    
    if [[ -z "$message_id" ]]; then
        echo "Usage: queue retry <queue_name> <message_id>"
        echo "       queue retry <message_id>  (uses default queue)"
        return 1
    fi
    
    echo "Retrying message: $message_id in queue: $queue_name"
    
    # Check if message exists and is in error state
    local current_status
    if list_messages "$queue_name" | grep -q "^$message_id error$"; then
        current_status="error"
    elif list_messages "$queue_name" | grep -q "^$message_id ok$"; then
        echo "Error: Message $message_id already processed successfully"
        return 1
    elif list_messages "$queue_name" | grep -q "^$message_id pending$"; then
        echo "Error: Message $message_id is already pending"
        return 1
    else
        echo "Error: Message $message_id not found"
        return 1
    fi
    
    # Reset message to pending state
    if set_message_status "$queue_name" "$message_id" "$QUEUE_STATUS_PENDING"; then
        echo "Message $message_id reset to pending state"
        
        # Optionally process it immediately
        read -p "Process message now? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Processing message..."
            if process_message "$queue_name" "$message_id"; then
                echo "Message processed successfully"
            else
                echo "Message processing failed"
                return 1
            fi
        fi
    else
        echo "Error: Failed to reset message status"
        return 1
    fi
    
    return 0
}

# @description Process pending messages in queue
# @arg $1 string Optional queue name (default: DEFAULT_QUEUE_NAME)
# @arg $2 string Optional message ID (if not provided, processes all pending)
# @stdout Processing progress and summary statistics
# @exitcode 0 If successful
# @exitcode 1 If processing fails
helper_queue_process() {
    local queue_name="${1:-$DEFAULT_QUEUE_NAME}"
    local message_id="$2"  # optional: specific message, otherwise process all pending
    
    if [[ -n "$message_id" ]]; then
        # Process specific message
        echo "Processing message: $message_id in queue: $queue_name"
        
        if process_message "$queue_name" "$message_id"; then
            echo "Message processed successfully"
        else
            echo "Message processing failed"
            return 1
        fi
    else
        # Process all pending messages
        echo "Processing all pending messages in queue: $queue_name"
        
        local processed_count=0
        local failed_count=0
        
        list_messages "$queue_name" "pending" | while IFS=' ' read -r msg_id status; do
            if [[ -n "$msg_id" ]]; then
                echo "Processing: $msg_id"
                
                if process_message "$queue_name" "$msg_id"; then
                    echo "  ✓ Success"
                    ((processed_count++))
                else
                    echo "  ✗ Failed"
                    ((failed_count++))
                fi
            fi
        done
        
        echo ""
        echo "Processing summary:"
        echo "  Successful: $processed_count"
        echo "  Failed: $failed_count"
    fi
    
    return 0
}

# @description Show detailed information about a specific message
# @arg $1 string Optional queue name (default: DEFAULT_QUEUE_NAME)
# @arg $2 string Message ID to display (required)
# @stdout Pretty-printed JSON message details
# @exitcode 0 If successful
# @exitcode 1 If message not found or invalid parameters
helper_queue_show() {
    local queue_name="${1:-$DEFAULT_QUEUE_NAME}"
    local message_id="$2"
    
    if [[ -z "$message_id" ]]; then
        echo "Usage: queue show <queue_name> <message_id>"
        echo "       queue show <message_id>  (uses default queue)"
        return 1
    fi
    
    echo "Message Details: $message_id"
    echo "=========================="
    
    local message
    message=$(get_message "$queue_name" "$message_id" 2>/dev/null)
    
    if [[ -z "$message" ]]; then
        echo "Message not found: $message_id"
        return 1
    fi
    
    # Pretty print the JSON message
    echo "$message" | jq .
    
    return 0
}

# @description Create a test message for queue testing
# @arg $1 string Optional queue name (default: DEFAULT_QUEUE_NAME)
# @stdout Test message creation progress and ID
# @exitcode 0 If successful
# @exitcode 1 If message creation or queuing fails
helper_queue_create_test() {
    local queue_name="${1:-$DEFAULT_QUEUE_NAME}"
    
    echo "Creating test renumber message..."
    
    # Create a test renumber message
    local test_message
    test_message=$(create_renumber_message "task" "test-task" "123" "124" "conflict" '{"user": "test", "command": "test"}')
    
    if [[ -z "$test_message" ]]; then
        echo "Error: Failed to create test message"
        return 1
    fi
    
    local message_id
    message_id=$(queue_message "$queue_name" "$test_message")
    
    if [[ -n "$message_id" ]]; then
        echo "Test message created: $message_id"
        echo "Use 'queue show $message_id' to view details"
    else
        echo "Error: Failed to queue test message"
        return 1
    fi
    
    return 0
}

# @description Display queue command help
# @stdout Help information for queue commands
# @exitcode 0 Always successful
helper_queue_help() {
    echo "DOH Message Queue Management"
    echo "==========================="
    echo ""
    echo "Usage: helper.sh queue <command> [options]"
    echo ""
    echo "Commands:"
    echo "  status [queue_name]              Show queue statistics"
    echo "  list [queue_name] [status] [-v]  List messages (status: pending/ok/error)"
    echo "  show [queue_name] <message_id>   Show message details"
    echo "  process [queue_name] [msg_id]    Process pending messages"
    echo "  retry [queue_name] <message_id>  Retry failed message"
    echo "  purge [queue_name] [max_days]    Purge old processed messages"
    echo "  create-test [queue_name]         Create test message"
    echo "  help                             Show this help message"
    echo ""
    echo "Default queue name: $DEFAULT_QUEUE_NAME"
    echo ""
    echo "Examples:"
    echo "  helper.sh queue status"
    echo "  helper.sh queue list pending -v"
    echo "  helper.sh queue show msg123"
    echo "  helper.sh queue process"
    return 0
}

# Helpers should only be called through helper.sh bootstrap
# Direct execution is not allowed