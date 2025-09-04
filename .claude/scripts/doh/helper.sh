#!/bin/bash

# DOH Helper Bootstrap
# Bootstrap script for calling user-facing helper functions
# Usage: ./helper.sh <helper_name> <function_name> [arguments...]
# Example: ./helper.sh epic show data-api-sanity
#
# IMPORTANT: This is an EXTERNAL INTERFACE for user consumption.
# NEVER use helper.sh from inside helper scripts or api.sh - those should
# source DOH libraries directly for performance and to avoid circular dependencies.
# See docs/writing-good-scripts.md for complete usage rules.

set -euo pipefail

# Help function
show_usage() {
    cat << 'EOF'
DOH Helper Bootstrap

USAGE:
    helper.sh [--no-env] <helper_name> <function_name> [arguments...]

FLAGS:
    --no-env    Skip automatic DOH environment loading

EXAMPLES:
    helper.sh epic show data-api-sanity
    helper.sh reporting generate_standup
    helper.sh validation validate_system
    helper.sh workspace diagnostic --reset
    helper.sh migration migrate_version analyze

AVAILABLE HELPERS:
EOF
    
    # Dynamically list available helpers
    local helper_dir="$(dirname "${BASH_SOURCE[0]}")/helper"
    if [[ -d "$helper_dir" ]]; then
        find "$helper_dir" -name "*.sh" -type f | while read -r file; do
            local helper_name
            helper_name=$(basename "$file" .sh | sed 's/_/-/g')
            # Skip api.sh as it's not a user helper
            [[ "$helper_name" == "api" ]] && continue
            [[ "$helper_name" == "queue-commands" ]] && continue  # Skip queue-commands too
            echo "    $helper_name"
        done | sort
    else
        echo "    (no helpers found)"
    fi
    
    cat << 'EOF'

For more details on available functions, use:
    helper.sh <helper_name> help
EOF
}

# Parse flags
LOAD_ENV=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_usage
            exit 0
            ;;
        --no-env)
            LOAD_ENV=false
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Validate arguments
if [[ $# -lt 2 ]]; then
    echo "Error: Missing required arguments" >&2
    echo "Usage: helper.sh [--no-env] <helper_name> <function_name> [arguments...]" >&2
    echo "Run 'helper.sh --help' for more information" >&2
    exit 1
fi

# Load DOH environment by default
if [[ "$LOAD_ENV" == "true" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -f "$script_dir/lib/dohenv.sh" ]]; then
        source "$script_dir/lib/dohenv.sh"
        dohenv_load 2>/dev/null || true  # Don't fail if environment loading fails
    fi
fi

# Extract parameters
HELPER_NAME="$1"
FUNCTION_NAME="$2"
shift 2  # Remove helper_name and function_name from arguments

# Validate helper name (only allow alphanumeric and hyphens)
if [[ ! "$HELPER_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
    echo "Error: Invalid helper name '$HELPER_NAME'" >&2
    echo "Helper names must start with a letter and contain only letters, numbers, underscores, and hyphens" >&2
    exit 1
fi

# Validate function name (only allow alphanumeric and underscores)
if [[ ! "$FUNCTION_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
    echo "Error: Invalid function name '$FUNCTION_NAME'" >&2
    echo "Function names must start with a letter and contain only letters, numbers, and underscores" >&2
    exit 1
fi

# Convert hyphens to underscores for file system compatibility
NORMALIZED_HELPER="${HELPER_NAME//-/_}"

# Construct helper file path
HELPER_DIR="$(dirname "${BASH_SOURCE[0]}")/helper"
HELPER_FILE="$HELPER_DIR/$NORMALIZED_HELPER.sh"

# Check if helper file exists
if [[ ! -f "$HELPER_FILE" ]]; then
    echo "Error: Helper not found: $HELPER_NAME" >&2
    echo "Expected helper file: $HELPER_FILE" >&2
    echo "" >&2
    echo "Available helpers:" >&2
    if [[ -d "$HELPER_DIR" ]]; then
        find "$HELPER_DIR" -name "*.sh" -type f | while read -r file; do
            basename "$file" .sh | sed 's/_/-/g' | sed 's/^/  /'
        done
    else
        echo "  (no helpers directory found)" >&2
    fi
    exit 1
fi

# Source the helper file
if ! source "$HELPER_FILE"; then
    echo "Error: Failed to source helper file: $HELPER_FILE" >&2
    exit 1
fi

# Construct full function name
FULL_FUNCTION_NAME="helper_${NORMALIZED_HELPER}_${FUNCTION_NAME}"

# Check if function exists
if ! declare -f "$FULL_FUNCTION_NAME" >/dev/null 2>&1; then
    echo "Error: Function '$FUNCTION_NAME' not found in helper '$HELPER_NAME'" >&2
    echo "Expected function: $FULL_FUNCTION_NAME" >&2
    echo "" >&2
    echo "Available functions in $HELPER_NAME helper:" >&2
    # List functions that match the helper pattern
    declare -F | grep -E "^declare -f helper_${NORMALIZED_HELPER}_" | sed "s/declare -f helper_${NORMALIZED_HELPER}_/  /" || echo "  (no functions found)"
    exit 1
fi

# Execute the function with remaining arguments
"$FULL_FUNCTION_NAME" "$@"
exit $?