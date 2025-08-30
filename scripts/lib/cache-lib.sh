#!/bin/bash
# 
# DOH Linting Cache Library
# Ultra-fast key-value cache for file linting optimization
# 
# Version: 1.0
# Format: path:hash:timestamp:status
# Performance: ~1-5ms lookups with standard Unix tools
#

# =============================================================================
# CONFIGURATION
# =============================================================================

CACHE_DIR="${CACHE_DIR:-./.cache/linting}"
CACHE_FILE="${CACHE_DIR}/file-hashes.txt"
METADATA_FILE="${CACHE_DIR}/metadata.txt"
CONFIG_HASH_FILE="${CACHE_DIR}/config-hash.txt"

# Files to monitor for config changes (space-separated)
CONFIG_FILES=".markdownlint.json .prettierrc .prettierrc.json package.json pyproject.toml .codespell.conf scripts/linting/lint-files.sh"

# =============================================================================
# CORE CACHE FUNCTIONS
# =============================================================================

# Initialize cache directory structure
# Usage: cache_init
cache_init() {
    local cache_dir="$CACHE_DIR"
    
    # Create cache directory
    mkdir -p "$cache_dir"
    
    # Initialize cache files if they don't exist
    [[ -f "$CACHE_FILE" ]] || touch "$CACHE_FILE"
    
    # Initialize metadata
    if [[ ! -f "$METADATA_FILE" ]]; then
        cat > "$METADATA_FILE" << EOF
version:1.0
created:$(date +%s)
total_files:0
cache_hits:0
cache_misses:0
last_cleanup:$(date +%s)
EOF
    fi
    
    # Initialize config hash
    [[ -f "$CONFIG_HASH_FILE" ]] || cache_update_config_hash
    
    # Create .gitignore to exclude cache
    echo "# DOH linting cache - exclude from git" > "$cache_dir/.gitignore"
    echo "*" >> "$cache_dir/.gitignore"
}

# Ultra-fast cache lookup
# Usage: cached_hash=$(cache_lookup "path/to/file.md")
# Returns: hash if found, empty if not found
cache_lookup() {
    local filepath="$1"
    [[ -f "$CACHE_FILE" ]] || return 1
    grep "^${filepath}:" "$CACHE_FILE" 2>/dev/null | cut -d: -f2
}

# Check if file has cache hit (hash matches)
# Usage: if cache_hit_check "file.md" "$current_hash"; then echo "hit"; fi
cache_hit_check() {
    local filepath="$1"
    local current_hash="$2"
    local cached_hash
    
    cached_hash=$(cache_lookup "$filepath")
    [[ -n "$cached_hash" && "$cached_hash" == "$current_hash" ]]
}

# Update cache entry for a file
# Usage: cache_update "file.md" "abc123hash" "clean"
cache_update() {
    local filepath="$1"
    local hash="$2"
    local status="${3:-clean}"
    local timestamp=$(date +%s)
    local temp_file="${CACHE_FILE}.tmp"
    
    # Ensure cache is initialized
    cache_init
    
    # Remove old entry (if exists) and add new entry atomically
    grep -v "^${filepath}:" "$CACHE_FILE" > "$temp_file" 2>/dev/null || touch "$temp_file"
    echo "${filepath}:${hash}:${timestamp}:${status}" >> "$temp_file"
    mv "$temp_file" "$CACHE_FILE"
    
    # Update statistics
    cache_increment_counter "cache_misses"
}

# Remove cache entry for a file
# Usage: cache_remove "file.md"
cache_remove() {
    local filepath="$1"
    local temp_file="${CACHE_FILE}.tmp"
    
    [[ -f "$CACHE_FILE" ]] || return 0
    
    grep -v "^${filepath}:" "$CACHE_FILE" > "$temp_file" 2>/dev/null || touch "$temp_file"
    mv "$temp_file" "$CACHE_FILE"
}

# =============================================================================
# HASH UTILITIES
# =============================================================================

# Calculate SHA-256 hash of file (first 24 chars for compactness)
# Usage: hash=$(file_hash "path/to/file")
file_hash() {
    local filepath="$1"
    [[ -f "$filepath" ]] || return 1
    sha256sum "$filepath" 2>/dev/null | cut -d' ' -f1 | cut -c1-24
}

# Calculate hash of all config files
# Usage: config_hash=$(config_files_hash)
config_files_hash() {
    local temp_file="/tmp/doh-config-$$.tmp"
    local config_file
    
    # Collect existing config files
    for config_file in $CONFIG_FILES; do
        [[ -f "$config_file" ]] && cat "$config_file" >> "$temp_file" 2>/dev/null
    done
    
    # Calculate hash of combined config
    if [[ -f "$temp_file" ]]; then
        sha256sum "$temp_file" 2>/dev/null | cut -d' ' -f1 | cut -c1-16
        rm -f "$temp_file"
    else
        echo "no-config"
    fi
}

# Update stored config hash
# Usage: cache_update_config_hash
cache_update_config_hash() {
    config_files_hash > "$CONFIG_HASH_FILE"
}

# Check if config has changed since cache creation
# Usage: if config_unchanged; then echo "config stable"; fi
config_unchanged() {
    [[ -f "$CONFIG_HASH_FILE" ]] || return 1
    
    local current_hash stored_hash
    current_hash=$(config_files_hash)
    stored_hash=$(cat "$CONFIG_HASH_FILE" 2>/dev/null)
    
    [[ "$current_hash" == "$stored_hash" ]]
}

# =============================================================================
# CACHE MAINTENANCE
# =============================================================================

# Remove entries for files that no longer exist
# Usage: cache_cleanup
cache_cleanup() {
    [[ -f "$CACHE_FILE" ]] || return 0
    
    local temp_file="${CACHE_FILE}.tmp"
    local filepath hash timestamp status
    local cleaned=0
    
    # Keep only entries for existing files
    while IFS=: read -r filepath hash timestamp status; do
        if [[ -f "$filepath" ]]; then
            echo "${filepath}:${hash}:${timestamp}:${status}"
        else
            ((cleaned++))
        fi
    done < "$CACHE_FILE" > "$temp_file"
    
    mv "$temp_file" "$CACHE_FILE"
    
    # Update cleanup timestamp
    cache_set_metadata "last_cleanup" "$(date +%s)"
    
    echo "🧹 Cleaned $cleaned stale cache entries"
}

# Invalidate entire cache (config changes, force refresh)
# Usage: cache_invalidate
cache_invalidate() {
    [[ -f "$CACHE_FILE" ]] && rm -f "$CACHE_FILE"
    touch "$CACHE_FILE"
    cache_update_config_hash
    cache_set_metadata "total_files" "0"
    cache_set_metadata "cache_hits" "0" 
    cache_set_metadata "cache_misses" "0"
    echo "🔄 Cache invalidated"
}

# =============================================================================
# STATISTICS & METADATA
# =============================================================================

# Get metadata value
# Usage: value=$(cache_get_metadata "cache_hits")
cache_get_metadata() {
    local key="$1"
    [[ -f "$METADATA_FILE" ]] || return 1
    grep "^${key}:" "$METADATA_FILE" 2>/dev/null | cut -d: -f2
}

# Set metadata value  
# Usage: cache_set_metadata "cache_hits" "42"
cache_set_metadata() {
    local key="$1"
    local value="$2"
    local temp_file="${METADATA_FILE}.tmp"
    
    [[ -f "$METADATA_FILE" ]] || cache_init
    
    grep -v "^${key}:" "$METADATA_FILE" > "$temp_file" 2>/dev/null || touch "$temp_file"
    echo "${key}:${value}" >> "$temp_file"
    mv "$temp_file" "$METADATA_FILE"
}

# Increment metadata counter
# Usage: cache_increment_counter "cache_hits"
cache_increment_counter() {
    local key="$1"
    local current_value
    
    current_value=$(cache_get_metadata "$key")
    current_value=${current_value:-0}
    cache_set_metadata "$key" $((current_value + 1))
}

# Display comprehensive cache statistics
# Usage: cache_stats
cache_stats() {
    local total_files cache_hits cache_misses hit_rate cache_size
    local created last_cleanup
    
    [[ -f "$CACHE_FILE" ]] || { echo "❌ No cache found"; return 1; }
    
    # Gather statistics
    total_files=$(wc -l < "$CACHE_FILE" 2>/dev/null || echo "0")
    cache_hits=$(cache_get_metadata "cache_hits" || echo "0")
    cache_misses=$(cache_get_metadata "cache_misses" || echo "0") 
    created=$(cache_get_metadata "created" || echo "unknown")
    last_cleanup=$(cache_get_metadata "last_cleanup" || echo "unknown")
    
    # Calculate hit rate
    if [[ $((cache_hits + cache_misses)) -gt 0 ]]; then
        hit_rate=$(awk "BEGIN {printf \"%.1f\", ($cache_hits / ($cache_hits + $cache_misses)) * 100}")
    else
        hit_rate="0.0"
    fi
    
    # Get cache directory size
    cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1 || echo "unknown")
    
    # Format creation and cleanup times
    if [[ "$created" != "unknown" ]]; then
        created="${created} ($(date -d "@$created" '+%Y-%m-%d %H:%M' 2>/dev/null || echo 'unknown'))"
    fi
    if [[ "$last_cleanup" != "unknown" ]]; then
        last_cleanup="${last_cleanup} ($(date -d "@$last_cleanup" '+%Y-%m-%d %H:%M' 2>/dev/null || echo 'unknown'))"
    fi
    
    # Display formatted statistics
    echo "📊 DOH Linting Cache Statistics"
    echo "├── 💾 Cache entries: $total_files files"
    echo "├── 🎯 Cache hits: $cache_hits ($hit_rate%)"
    echo "├── ❌ Cache misses: $cache_misses"
    echo "├── 📁 Cache size: $cache_size"
    echo "├── 📅 Created: $created"
    echo "├── 🧹 Last cleanup: $last_cleanup"
    echo "└── ⚙️  Config status: $(config_unchanged && echo "✅ stable" || echo "⚠️ changed")"
}

# =============================================================================
# HIGH-LEVEL CACHE WORKFLOW
# =============================================================================

# Smart cache check for a file with automatic statistics
# Usage: if cache_check_file "file.md"; then echo "cache hit"; else echo "cache miss"; fi  
cache_check_file() {
    local filepath="$1"
    local current_hash
    
    # Calculate current hash
    current_hash=$(file_hash "$filepath")
    [[ -n "$current_hash" ]] || return 1
    
    # Check config stability
    if ! config_unchanged; then
        echo "🔄 Config changed, invalidating cache..."
        cache_invalidate
        return 1
    fi
    
    # Check cache hit
    if cache_hit_check "$filepath" "$current_hash"; then
        cache_increment_counter "cache_hits"
        echo "✅ Cache hit: $filepath (skipped)"
        return 0
    else
        cache_increment_counter "cache_misses"
        return 1
    fi
}

# Mark file as successfully linted (update cache)
# Usage: cache_mark_clean "file.md"
cache_mark_clean() {
    local filepath="$1"
    local current_hash
    
    current_hash=$(file_hash "$filepath")
    [[ -n "$current_hash" ]] || return 1
    
    cache_update "$filepath" "$current_hash" "clean"
    echo "💾 Cached: $filepath"
}

# Process file with cache awareness
# Usage: cache_process_file "file.md" "linting_command"
cache_process_file() {
    local filepath="$1"
    local lint_command="$2"
    
    # Check cache first
    if cache_check_file "$filepath"; then
        return 0  # Cache hit, skip processing
    fi
    
    # Process file (cache miss)
    echo "🔄 Processing: $filepath"
    if eval "$lint_command"; then
        cache_mark_clean "$filepath"
        return 0
    else
        echo "❌ Linting failed: $filepath"
        return 1
    fi
}

# =============================================================================
# UTILITY FUNCTIONS  
# =============================================================================

# Test if cache library is working
# Usage: cache_test
cache_test() {
    echo "🧪 Testing DOH cache library..."
    
    # Test initialization
    cache_init
    echo "✅ Cache initialized"
    
    # Test file operations
    local test_file="README.md"
    if [[ -f "$test_file" ]]; then
        local hash
        hash=$(file_hash "$test_file")
        cache_update "$test_file" "$hash" "clean"
        echo "✅ Cache update works"
        
        if cache_hit_check "$test_file" "$hash"; then
            echo "✅ Cache lookup works"
        else
            echo "❌ Cache lookup failed"
        fi
    fi
    
    # Test statistics
    cache_stats
    echo "✅ Cache test completed"
}

# Print library version and info
# Usage: cache_version
cache_version() {
    echo "DOH Linting Cache Library v1.0"
    echo "Ultra-fast key-value cache for file linting optimization"
    echo "Performance: ~1-5ms lookups with standard Unix tools"
}

# =============================================================================
# EXPORT FUNCTIONS (if sourced)
# =============================================================================

# If script is sourced, export functions for use in other scripts
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Mark as sourced
    DOH_CACHE_LIB_LOADED=1
    
    # Export main functions
    export -f cache_init cache_lookup cache_hit_check cache_update cache_remove
    export -f file_hash config_files_hash config_unchanged  
    export -f cache_cleanup cache_invalidate cache_stats
    export -f cache_check_file cache_mark_clean cache_process_file
    export -f cache_test cache_version
fi

# =============================================================================
# COMMAND LINE INTERFACE (if run directly)
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-help}" in
        init)
            cache_init
            ;;
        stats)
            cache_stats
            ;;
        cleanup)
            cache_cleanup
            ;;
        invalidate)
            cache_invalidate
            ;;
        test)
            cache_test
            ;;
        version)
            cache_version
            ;;
        help|*)
            echo "DOH Linting Cache Library"
            echo ""
            echo "Usage: $0 {init|stats|cleanup|invalidate|test|version|help}"
            echo ""
            echo "Commands:"
            echo "  init        Initialize cache directory and files"
            echo "  stats       Display cache statistics"  
            echo "  cleanup     Remove stale cache entries"
            echo "  invalidate  Clear entire cache"
            echo "  test        Run library tests"
            echo "  version     Show version information"
            echo "  help        Show this help message"
            echo ""
            echo "Library functions (when sourced):"
            echo "  cache_check_file file.md    # Check if file needs linting"
            echo "  cache_mark_clean file.md    # Mark file as successfully linted"
            echo "  cache_process_file file.md 'lint_cmd'  # Process with cache"
            ;;
    esac
fi