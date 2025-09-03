#!/bin/bash

# DOH API Helper Script
# Usage: api.sh <library> <function> [args...]
# Usage: api.sh --private <library> <function> [args...]
# Example: api.sh version get_current
# Example: api.sh frontmatter get_field "/path/to/file.md" "field_name"
# Example: api.sh --private version to_number "1.0.0"

set -eo pipefail

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DOH_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Parse flags
PRIVATE_CALL=false
LOAD_ENV=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --private)
            PRIVATE_CALL=true
            shift
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
    echo "Usage: $0 [--private] [--no-env] <library> <function> [args...]" >&2
    echo "Available libraries: doh, dohenv, frontmatter, version, numbering, workspace, task, etc." >&2
    echo "Flags:" >&2
    echo "  --private   Call private functions (prefixed with _library_)" >&2
    echo "  --no-env    Skip automatic DOH environment loading" >&2
    exit 1
fi

# Load DOH environment by default
if [[ "$LOAD_ENV" == "true" ]]; then
    if [[ -f "$SCRIPT_DIR/lib/dohenv.sh" ]]; then
        source "$SCRIPT_DIR/lib/dohenv.sh"
        dohenv_load 2>/dev/null || true  # Don't fail if environment loading fails
    fi
fi

LIBRARY="$1"
FUNCTION="$2"
shift 2

# Define library path
LIB_PATH="$SCRIPT_DIR/lib/${LIBRARY}.sh"

# Check if library exists
if [[ ! -f "$LIB_PATH" ]]; then
    echo "Error: Library not found: $LIB_PATH" >&2
    exit 1
fi

# Source the library
if ! source "$LIB_PATH"; then
    echo "Error: Failed to source library: $LIB_PATH" >&2
    exit 1
fi

# Normalize library name by replacing hyphens with underscores for function names
NORMALIZED_LIBRARY="${LIBRARY//-/_}"

# Determine function name based on private flag
if [[ "$PRIVATE_CALL" == "true" ]]; then
    FULL_FUNCTION_NAME="_${NORMALIZED_LIBRARY}_${FUNCTION}"
else
    FULL_FUNCTION_NAME="${NORMALIZED_LIBRARY}_${FUNCTION}"
fi

# Check if function exists
if ! declare -F "$FULL_FUNCTION_NAME" >/dev/null 2>&1; then
    if [[ "$PRIVATE_CALL" == "true" ]]; then
        echo "Error: Private function not found: $FULL_FUNCTION_NAME" >&2
    else
        echo "Error: Public function not found: $FULL_FUNCTION_NAME" >&2
    fi
    echo "Available functions:" >&2
    if [[ "$PRIVATE_CALL" == "true" ]]; then
        declare -F | grep -E "^declare -f _${NORMALIZED_LIBRARY}_" | sed 's/declare -f /  /' >&2
    else
        declare -F | grep -E "^declare -f ${NORMALIZED_LIBRARY}_" | sed 's/declare -f /  /' >&2
    fi
    exit 1
fi

# Call the function and preserve exit code
"$FULL_FUNCTION_NAME" "$@"
exit $?