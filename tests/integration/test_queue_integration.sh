#!/bin/bash
# Integration tests for DOH message queue system - Fixed API
# Updated to use actual queue.sh API
# File version: 0.1.0 | Created: 2025-09-01

# Source the framework
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

# Source the libraries being tested - FOCUS ON CORE LIBRARY ONLY
LIB_DIR="$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib"
source "$LIB_DIR/queue.sh"

# Test environment setup
_tf_setup() {
    export DOH_TEST_PROJECT_ID="queue_test_$(date +%s)_$$"
    export DOH_TEST_QUEUE_NAME="test_queue"
    
    # Override functions for testing
    workspace_get_current_project_id() {
        echo "$DOH_TEST_PROJECT_ID"
    }
}

_tf_teardown() {
    # Cleanup test environment
    local project_dir="$HOME/.doh/projects/$DOH_TEST_PROJECT_ID"
    if [[ -n "$DOH_TEST_PROJECT_ID" && -d "$project_dir" ]]; then
        rm -rf "$project_dir"
    fi
}

# Queue Initialization Tests
test_queue_initialization() {
    local queue_dir
    queue_dir="$(queue_ensure_dir "$DOH_TEST_QUEUE_NAME")"
    
    _tf_assert_command_succeeds "test -d '$queue_dir'" "Queue directory should be created"
}

test_message_creation() {
    # Test creating a renumber message
    local message
    message="$(queue_create_renumber_message "task" "test_task" "001" "002" "conflict")"
    
    _tf_assert_command_succeeds "test -n '$message'" "Should create renumber message"
    
    # Validate message format
    _tf_assert_command_succeeds "queue_validate_message '$message'" "Message should be valid"
}

test_queue_add_message() {
    queue_ensure_dir "$DOH_TEST_QUEUE_NAME"
    
    # Create and queue a message
    local message
    message="$(queue_create_renumber_message "task" "test_task" "001" "002" "conflict")"
    
    local message_id
    message_id="$(queue_add_message "$DOH_TEST_QUEUE_NAME" "$message")"
    
    _tf_assert_command_succeeds "test -n '$message_id'" "Message ID should be generated"
    
    # Check message was queued
    local queue_dir
    queue_dir="$(queue_get_dir "$DOH_TEST_QUEUE_NAME")"
    
    _tf_assert_file_exists "$queue_dir/$message_id.json" "Message file should be created"
}

test_queue_get_message() {
    queue_ensure_dir "$DOH_TEST_QUEUE_NAME"
    
    # Create and queue a message
    local message
    message="$(queue_create_renumber_message "epic" "test_epic" "003" "004" "gap_filling")"
    
    local message_id
    message_id="$(queue_add_message "$DOH_TEST_QUEUE_NAME" "$message")"
    
    # Retrieve the message
    local retrieved_message
    retrieved_message="$(queue_get_message "$DOH_TEST_QUEUE_NAME" "$message_id")"
    
    _tf_assert_command_succeeds "test -n '$retrieved_message'" "Should retrieve queued message"
    _tf_assert_contains "$retrieved_message" "test_epic" "Message should contain epic identifier"
}

test_queue_list_messages() {
    queue_ensure_dir "$DOH_TEST_QUEUE_NAME"
    
    # Queue multiple messages
    local msg1 msg2
    msg1="$(queue_create_renumber_message "task" "task1" "001" "002" "conflict")"
    msg2="$(queue_create_renumber_message "task" "task2" "003" "004" "conflict")"
    
    local id1 id2
    id1="$(queue_add_message "$DOH_TEST_QUEUE_NAME" "$msg1")"
    id2="$(queue_add_message "$DOH_TEST_QUEUE_NAME" "$msg2")"
    
    # List pending messages
    local messages
    messages="$(queue_list_messages "$DOH_TEST_QUEUE_NAME" "pending")"
    
    _tf_assert_contains "$messages" "$id1" "Should list first message"
    _tf_assert_contains "$messages" "$id2" "Should list second message"
}

test_message_status_change() {
    queue_ensure_dir "$DOH_TEST_QUEUE_NAME"
    
    # Create and queue a message
    local message
    message="$(queue_create_renumber_message "task" "status_test" "001" "002" "conflict")"
    
    local message_id
    message_id="$(queue_add_message "$DOH_TEST_QUEUE_NAME" "$message")"
    
    # Change status to OK
    _tf_assert_command_succeeds "queue_set_message_status '$DOH_TEST_QUEUE_NAME' '$message_id' '.ok'" "Should set message status to OK"
    
    # Check message appears in OK list
    local ok_messages
    ok_messages="$(queue_list_messages "$DOH_TEST_QUEUE_NAME" "ok")"
    
    _tf_assert_contains "$ok_messages" "$message_id" "Message should appear in OK list"
}

test_queue_process_message() {
    queue_ensure_dir "$DOH_TEST_QUEUE_NAME"
    
    # Create and queue a message
    local message
    message="$(queue_create_renumber_message "task" "process_test" "001" "002" "conflict")"
    
    local message_id
    message_id="$(queue_add_message "$DOH_TEST_QUEUE_NAME" "$message")"
    
    # Process the message
    _tf_assert_command_succeeds "queue_process_message '$DOH_TEST_QUEUE_NAME' '$message_id'" "Should process message"
    
    # Check message is marked as processed
    local ok_messages
    ok_messages="$(queue_list_messages "$DOH_TEST_QUEUE_NAME" "ok")"
    
    _tf_assert_contains "$ok_messages" "$message_id" "Processed message should be marked as OK"
}

test_queue_statistics() {
    queue_ensure_dir "$DOH_TEST_QUEUE_NAME"
    
    # Queue a few messages
    local msg1 msg2
    msg1="$(queue_create_renumber_message "task" "stats1" "001" "002" "conflict")"
    msg2="$(queue_create_renumber_message "epic" "stats2" "003" "004" "gap_filling")"
    
    queue_add_message "$DOH_TEST_QUEUE_NAME" "$msg1"
    queue_add_message "$DOH_TEST_QUEUE_NAME" "$msg2"
    
    # Get statistics
    local stats
    stats="$(queue_get_stats "$DOH_TEST_QUEUE_NAME")"
    
    _tf_assert_contains "$stats" "Queue Statistics" "Stats should include header"
    _tf_assert_contains "$stats" "Pending:" "Stats should include pending count"
    _tf_assert_contains "$stats" "Total:" "Stats should include total count"
}

test_queue_purge_processed() {
    queue_ensure_dir "$DOH_TEST_QUEUE_NAME"
    
    # Create and process a message
    local message
    message="$(queue_create_renumber_message "task" "purge_test" "001" "002" "conflict")"
    
    local message_id
    message_id="$(queue_add_message "$DOH_TEST_QUEUE_NAME" "$message")"
    
    # Mark as processed
    queue_set_message_status "$DOH_TEST_QUEUE_NAME" "$message_id" ".ok"
    
    # Test purge function (should not purge recent messages)
    _tf_assert_command_succeeds "queue_purge_processed '$DOH_TEST_QUEUE_NAME' 0" "Should run purge function"
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi