#!/bin/bash

# Generic test runner with output redirection to specified log file
# Usage: ./claude/scripts/test-and-log.sh <log_file_path> <test_command> [args...]

if [ $# -lt 2 ]; then
    echo "Usage: $0 <log_file_path> <test_command> [args...]"
    echo "Examples:"
    echo "  $0 tests/logs/version_test_20250903_123045.log ./tests/test_launcher.sh tests/unit/test_version.sh"
    echo "  $0 /tmp/debug_run.log ./tests/run.sh"
    echo "  $0 tests/logs/integration_test.log python tests/my_test.py"
    exit 1
fi

LOG_FILE="$1"
shift  # Remove log file from arguments, rest are the command

# Check that log directory exists
LOG_DIR=$(dirname "$LOG_FILE")
if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Log directory '$LOG_DIR' does not exist"
    echo "Please create the directory first: mkdir -p '$LOG_DIR'"
    exit 1
fi

# Run the command with output redirection
echo "Running: $*"
echo "Logging to: $LOG_FILE"

# Execute the command and capture all output
"$@" > "$LOG_FILE" 2>&1

# Check exit code
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Test completed successfully. Log saved to $LOG_FILE"
else
    echo "❌ Test failed with exit code $EXIT_CODE. Check $LOG_FILE for details"
fi

exit $EXIT_CODE
