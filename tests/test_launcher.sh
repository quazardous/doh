#!/bin/bash
# DOH Test Launcher
# Enforces complete test framework stack execution for a single test file
# File version: 0.1.0 | Created: 2025-09-01 | Updated: 2025-09-01

set -euo pipefail

# Basic argument check
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <test_file>" >&2
    echo "       Runs a single test file through the complete DOH test framework stack" >&2
    exit 1
fi

TEST_FILE="$1"

# Verify test file exists and is readable
if [[ ! -f "$TEST_FILE" ]]; then
    echo "Error: Test file '$TEST_FILE' not found" >&2
    exit 1
fi

if [[ ! -r "$TEST_FILE" ]]; then
    echo "Error: Test file '$TEST_FILE' is not readable" >&2
    exit 1
fi

# Validate test file follows DOH conventions
if [[ ! "$TEST_FILE" =~ ^.*test_.*\.sh$ ]]; then
    echo "Warning: Test file '$TEST_FILE' does not follow naming convention (test_*.sh)" >&2
fi

# Set up test environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_FRAMEWORK="$SCRIPT_DIR/helpers/test_framework.sh"

# Verify test framework exists
if [[ ! -f "$TEST_FRAMEWORK" ]]; then
    echo "Error: Test framework not found at '$TEST_FRAMEWORK'" >&2
    echo "       The DOH test infrastructure may not be properly initialized" >&2
    exit 1
fi

# Set working directory to project root
cd "$PROJECT_ROOT"

# Set environment variable to indicate proper test execution through launcher
export _TF_LAUNCHER_EXECUTION="true"

# Source the test framework to ensure it's available
source "$TEST_FRAMEWORK"

# Validate the test file sources the framework properly
if ! grep -q "source.*test_framework\.sh" "$TEST_FILE"; then
    echo "Error: Test file '$TEST_FILE' does not source the test framework" >&2
    echo "       Expected: source \"\$(dirname \"\$0\")/../helpers/test_framework.sh\"" >&2
    exit 1
fi

# Execute test file through the framework
if ! _tf_run_test_file "$TEST_FILE"; then
    exit 1
fi