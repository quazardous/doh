#!/bin/bash

# Integration tests for DOH message queue system
# Usage: ./queue-integration-test.sh

set -e

# Source the libraries
LIB_DIR="$(dirname "$0")/../lib"
source "$LIB_DIR/message-queue.sh"
source "$LIB_DIR/queue-commands.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
print_test_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

print_test() {
    echo -n "  Testing: $1 ... "
    ((TESTS_RUN++))
}

pass_test() {
    echo -e "${GREEN}PASS${NC}"
    ((TESTS_PASSED++))
}

fail_test() {
    echo -e "${RED}FAIL${NC}"
    if [[ -n "$1" ]]; then
        echo -e "    ${RED}Error: $1${NC}"
    fi
    ((TESTS_FAILED++))
}

# Setup test environment
setup_test_env() {
    export DOH_TEST_PROJECT_ID="queue_test_$(date +%s)_$$"
    export DOH_TEST_DIR="$HOME/.doh/projects/$DOH_TEST_PROJECT_ID"
    export DOH_TEST_QUEUE="test_queue"
    
    # Override functions for testing
    get_current_project_id() {
        echo "$DOH_TEST_PROJECT_ID"
    }
    
    # Create test project structure
    mkdir -p "$DOH_TEST_DIR"
    
    echo "Test environment setup: $DOH_TEST_DIR"
}

# Cleanup test environment
cleanup_test_env() {
    if [[ -d "$DOH_TEST_DIR" ]]; then
        rm -rf "$DOH_TEST_DIR"
    fi
}

# Test basic queue operations
test_queue_basics() {
    print_test_header "Basic Queue Operations"
    
    print_test "Queue directory creation"
    local queue_dir
    queue_dir="$(ensure_queue_dir "$DOH_TEST_QUEUE")"
    
    if [[ -d "$queue_dir" ]]; then
        pass_test
    else
        fail_test "Queue directory not created: $queue_dir"
        return
    fi
    
    print_test "Message ID generation"
    local msg_id1 msg_id2
    msg_id1="$(generate_message_id)"
    sleep 0.1
    msg_id2="$(generate_message_id)"
    
    if [[ -n "$msg_id1" && -n "$msg_id2" && "$msg_id1" != "$msg_id2" ]]; then
        pass_test
    else
        fail_test "Message ID generation failed: '$msg_id1' vs '$msg_id2'"
    fi
    
    print_test "Renumber message creation"
    local test_message
    test_message=$(create_renumber_message "task" "test-task" "123" "124" "conflict" '{"user": "testuser"}')
    
    if [[ -n "$test_message" ]]; then
        # Validate message structure
        if echo "$test_message" | jq -e '.id and .timestamp and .operation and .source and .target and .reason' >/dev/null 2>&1; then
            pass_test
        else
            fail_test "Invalid message structure"
        fi
    else
        fail_test "Message creation failed"
    fi
}

# Test message queuing and status changes
test_message_lifecycle() {
    print_test_header "Message Lifecycle Tests"
    
    print_test "Message queuing"
    local test_message message_id
    test_message=$(create_renumber_message "epic" "test-epic" "001" "002" "gap_filling" '{"command": "test"}')
    message_id=$(queue_message "$DOH_TEST_QUEUE" "$test_message")
    
    if [[ -n "$message_id" ]]; then
        pass_test
    else
        fail_test "Message queuing failed"
        return
    fi
    
    print_test "Message retrieval"
    local retrieved_message
    retrieved_message=$(get_message "$DOH_TEST_QUEUE" "$message_id")
    
    if [[ -n "$retrieved_message" ]]; then
        local retrieved_id
        retrieved_id=$(echo "$retrieved_message" | jq -r '.id')
        
        if [[ "$retrieved_id" == "$message_id" ]]; then
            pass_test
        else
            fail_test "Message ID mismatch: expected '$message_id', got '$retrieved_id'"
        fi
    else
        fail_test "Message retrieval failed"
        return
    fi
    
    print_test "Message status change to OK"
    if set_message_status "$DOH_TEST_QUEUE" "$message_id" "$QUEUE_STATUS_OK"; then
        # Check if file was renamed correctly
        local queue_dir
        queue_dir="$(get_queue_dir "$DOH_TEST_QUEUE")"
        
        if [[ -f "$queue_dir/$message_id.json.ok" ]]; then
            pass_test
        else
            fail_test "Status file not found: $queue_dir/$message_id.json.ok"
        fi
    else
        fail_test "Status change failed"
    fi
    
    print_test "Message status change to ERROR"
    local error_message_id
    test_message=$(create_renumber_message "task" "error-task" "999" "1000" "conflict")
    error_message_id=$(queue_message "$DOH_TEST_QUEUE" "$test_message")
    
    if set_message_status "$DOH_TEST_QUEUE" "$error_message_id" "$QUEUE_STATUS_ERROR" "Test error message"; then
        # Check if error info was added
        local error_message
        error_message=$(get_message "$DOH_TEST_QUEUE" "$error_message_id")
        
        if echo "$error_message" | jq -e '.error' >/dev/null 2>&1; then
            pass_test
        else
            fail_test "Error information not added to message"
        fi
    else
        fail_test "Error status change failed"
    fi
}

# Test message listing and filtering
test_message_listing() {
    print_test_header "Message Listing Tests"
    
    # Create messages in different states for testing
    local pending_msg ok_msg error_msg
    
    # Pending message
    local test_message
    test_message=$(create_renumber_message "task" "pending-task" "100" "101" "conflict")
    pending_msg=$(queue_message "$DOH_TEST_QUEUE" "$test_message")
    
    # OK message
    test_message=$(create_renumber_message "task" "ok-task" "200" "201" "conflict")
    ok_msg=$(queue_message "$DOH_TEST_QUEUE" "$test_message")
    set_message_status "$DOH_TEST_QUEUE" "$ok_msg" "$QUEUE_STATUS_OK"
    
    # Error message
    test_message=$(create_renumber_message "task" "error-task" "300" "301" "conflict")
    error_msg=$(queue_message "$DOH_TEST_QUEUE" "$test_message")
    set_message_status "$DOH_TEST_QUEUE" "$error_msg" "$QUEUE_STATUS_ERROR" "Test error"
    
    print_test "List all messages"
    local all_messages
    all_messages=$(list_messages "$DOH_TEST_QUEUE")
    
    if [[ "$all_messages" == *"$pending_msg"* && "$all_messages" == *"$ok_msg"* && "$all_messages" == *"$error_msg"* ]]; then
        pass_test
    else
        fail_test "Not all messages found in listing"
    fi
    
    print_test "List pending messages only"
    local pending_messages
    pending_messages=$(list_messages "$DOH_TEST_QUEUE" "pending")
    
    if [[ "$pending_messages" == *"$pending_msg"* && "$pending_messages" != *"$ok_msg"* && "$pending_messages" != *"$error_msg"* ]]; then
        pass_test
    else
        fail_test "Pending filter failed: $pending_messages"
    fi
    
    print_test "List OK messages only"
    local ok_messages
    ok_messages=$(list_messages "$DOH_TEST_QUEUE" "ok")
    
    if [[ "$ok_messages" == *"$ok_msg"* && "$ok_messages" != *"$pending_msg"* && "$ok_messages" != *"$error_msg"* ]]; then
        pass_test
    else
        fail_test "OK filter failed: $ok_messages"
    fi
    
    print_test "List ERROR messages only"
    local error_messages
    error_messages=$(list_messages "$DOH_TEST_QUEUE" "error")
    
    if [[ "$error_messages" == *"$error_msg"* && "$error_messages" != *"$pending_msg"* && "$error_messages" != *"$ok_msg"* ]]; then
        pass_test
    else
        fail_test "Error filter failed: $error_messages"
    fi
    
    print_test "Message count validation"
    local pending_count ok_count error_count
    pending_count=$(count_messages "$DOH_TEST_QUEUE" "pending")
    ok_count=$(count_messages "$DOH_TEST_QUEUE" "ok")
    error_count=$(count_messages "$DOH_TEST_QUEUE" "error")
    
    if [[ $pending_count -ge 1 && $ok_count -ge 1 && $error_count -ge 1 ]]; then
        pass_test
    else
        fail_test "Message counts incorrect: pending=$pending_count, ok=$ok_count, error=$error_count"
    fi
}

# Test message validation
test_message_validation() {
    print_test_header "Message Validation Tests"
    
    print_test "Valid message validation"
    local valid_message
    valid_message=$(create_renumber_message "task" "valid-task" "123" "124" "conflict")
    
    if validate_message "$valid_message"; then
        pass_test
    else
        fail_test "Valid message rejected"
    fi
    
    print_test "Invalid JSON rejection"
    local invalid_json="{ invalid json"
    
    if ! validate_message "$invalid_json" 2>/dev/null; then
        pass_test
    else
        fail_test "Invalid JSON accepted"
    fi
    
    print_test "Missing required fields rejection"
    local incomplete_message='{"id": "test", "operation": "renumber"}'
    
    if ! validate_message "$incomplete_message" 2>/dev/null; then
        pass_test
    else
        fail_test "Incomplete message accepted"
    fi
    
    print_test "Invalid operation rejection"
    local invalid_op_message='{"id": "test", "timestamp": "2025-01-01T00:00:00Z", "operation": "invalid_op"}'
    
    if ! validate_message "$invalid_op_message" 2>/dev/null; then
        pass_test
    else
        fail_test "Invalid operation accepted"
    fi
}

# Test atomic operations and concurrency safety
test_atomic_operations() {
    print_test_header "Atomic Operations Tests"
    
    print_test "Duplicate message ID handling"
    local test_message message_id1 message_id2
    test_message=$(create_renumber_message "task" "duplicate-test" "123" "124" "conflict")
    
    # Manually set the same ID for both messages
    local fixed_id="test_duplicate_123"
    test_message=$(echo "$test_message" | jq --arg id "$fixed_id" '.id = $id')
    
    message_id1=$(queue_message "$DOH_TEST_QUEUE" "$test_message" 2>/dev/null)
    message_id2=$(queue_message "$DOH_TEST_QUEUE" "$test_message" 2>/dev/null)
    
    # Second attempt should warn about existing message
    if [[ -n "$message_id1" ]]; then
        pass_test
    else
        fail_test "First message queuing failed"
    fi
    
    print_test "Concurrent message processing simulation"
    # Create multiple messages quickly
    local msg_ids=()
    
    for i in {1..5}; do
        local msg
        msg=$(create_renumber_message "task" "concurrent-$i" "$((500 + i))" "$((600 + i))" "conflict")
        local msg_id
        msg_id=$(queue_message "$DOH_TEST_QUEUE" "$msg")
        msg_ids+=("$msg_id")
    done
    
    # Process them in parallel (simulate)
    local success_count=0
    for msg_id in "${msg_ids[@]}"; do
        if set_message_status "$DOH_TEST_QUEUE" "$msg_id" "$QUEUE_STATUS_OK"; then
            ((success_count++))
        fi
    done
    
    if [[ $success_count -eq 5 ]]; then
        pass_test
    else
        fail_test "Concurrent processing failed: $success_count/5 succeeded"
    fi
}

# Test queue commands
test_queue_commands() {
    print_test_header "Queue Commands Tests"
    
    print_test "Queue status command"
    local status_output
    status_output=$(cmd_queue_status "$DOH_TEST_QUEUE" 2>/dev/null)
    
    if [[ "$status_output" == *"Queue Statistics"* && "$status_output" == *"Pending:"* ]]; then
        pass_test
    else
        fail_test "Queue status command failed"
    fi
    
    print_test "Queue list command"
    local list_output
    list_output=$(cmd_queue_list "$DOH_TEST_QUEUE" "" 2>/dev/null)
    
    if [[ "$list_output" == *"Messages in queue"* ]]; then
        pass_test
    else
        fail_test "Queue list command failed"
    fi
    
    print_test "Create test message command"
    local create_output
    create_output=$(cmd_queue_create_test_message "$DOH_TEST_QUEUE" 2>/dev/null)
    
    if [[ "$create_output" == *"Test message created"* ]]; then
        pass_test
    else
        fail_test "Create test message command failed"
    fi
}

# Test error handling
test_error_handling() {
    print_test_header "Error Handling Tests"
    
    print_test "Nonexistent message handling"
    if ! get_message "$DOH_TEST_QUEUE" "nonexistent_message" >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Should fail for nonexistent message"
    fi
    
    print_test "Invalid queue name handling"
    if ! get_queue_dir "" >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Should fail for empty queue name"
    fi
    
    print_test "Invalid message format handling"
    local invalid_msg='not a json message'
    
    if ! queue_message "$DOH_TEST_QUEUE" "$invalid_msg" >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Should reject invalid message format"
    fi
    
    print_test "Missing parameter handling"
    if ! create_renumber_message "task" "" "123" "124" "conflict" >/dev/null 2>&1; then
        pass_test
    else
        fail_test "Should fail for missing parameters"
    fi
}

# Test performance (basic)
test_performance() {
    print_test_header "Basic Performance Tests"
    
    print_test "Message creation performance"
    local start_time end_time
    start_time=$(date +%s%N)
    
    for i in {1..50}; do
        create_renumber_message "task" "perf-test-$i" "$((1000 + i))" "$((2000 + i))" "conflict" >/dev/null
    done
    
    end_time=$(date +%s%N)
    local duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    # Should be fast (less than 5000ms for 50 messages)
    if [[ $duration_ms -lt 5000 ]]; then
        pass_test
    else
        fail_test "Message creation too slow: ${duration_ms}ms for 50 messages"
    fi
    
    print_test "Queue listing performance"
    start_time=$(date +%s%N)
    
    for i in {1..20}; do
        list_messages "$DOH_TEST_QUEUE" >/dev/null
    done
    
    end_time=$(date +%s%N)
    duration_ms=$(( (end_time - start_time) / 1000000 ))
    
    if [[ $duration_ms -lt 2000 ]]; then
        pass_test
    else
        fail_test "Queue listing too slow: ${duration_ms}ms for 20 operations"
    fi
}

# Main test execution
main() {
    echo "DOH Message Queue Integration Test Suite"
    echo "========================================"
    
    # Setup
    setup_test_env
    trap cleanup_test_env EXIT
    
    # Run all tests
    test_queue_basics
    test_message_lifecycle
    test_message_listing
    test_message_validation
    test_atomic_operations
    test_queue_commands
    test_error_handling
    test_performance
    
    # Print results
    echo -e "\n${YELLOW}Test Results:${NC}"
    echo "  Total: $TESTS_RUN"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        exit 1
    else
        echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
        echo -e "\n${GREEN}All tests passed!${NC}"
        
        # Show final statistics
        echo -e "\n${YELLOW}Final Queue Statistics:${NC}"
        get_queue_stats "$DOH_TEST_QUEUE"
        
        exit 0
    fi
}

# Run tests
main "$@"