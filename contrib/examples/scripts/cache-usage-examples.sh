#!/bin/bash
#
# DOH Cache Library - Usage Examples
# Demonstrates multi-purpose file hash caching for various use cases
#

# Source the cache library
source "$(dirname "$0")/../lib/cache-lib.sh"

# =============================================================================
# EXAMPLE 1: LINTING CACHE (Primary Use Case)
# =============================================================================

example_linting_cache() {
    echo "🔧 Example 1: Linting Cache"
    echo "================================"
    
    # Configure cache for linting
    export CACHE_DIR="./.cache/linting"
    export CONFIG_FILES=".markdownlint.json .prettierrc package.json"
    
    cache_init
    
    # Process markdown files with cache awareness
    for file in *.md; do
        [[ -f "$file" ]] || continue
        
        if cache_check_file "$file"; then
            echo "  ⚡ $file: cached (skipped)"
        else
            echo "  🔄 $file: processing..."
            # Simulate linting command
            if markdownlint "$file" &>/dev/null; then
                cache_mark_clean "$file"
                echo "  ✅ $file: linted and cached"
            else
                echo "  ❌ $file: linting failed"
            fi
        fi
    done
    
    cache_stats
    echo ""
}

# =============================================================================
# EXAMPLE 2: BUILD CACHE (Compilation/Transpilation)
# =============================================================================

example_build_cache() {
    echo "🏗️  Example 2: Build Cache"
    echo "============================"
    
    # Configure cache for build system
    export CACHE_DIR="./.cache/build"
    export CONFIG_FILES="package.json tsconfig.json webpack.config.js"
    
    cache_init
    
    # Process TypeScript files (if they exist)
    shopt -s nullglob
    for file in src/**/*.ts; do
        [[ -f "$file" ]] || continue
        
        local js_file="${file%.ts}.js"
        
        if cache_check_file "$file"; then
            echo "  ⚡ $file: build cached (skipped)"
        else
            echo "  🔄 $file: compiling..."
            # Simulate TypeScript compilation
            if touch "$js_file"; then  # Simulate successful build
                cache_mark_clean "$file"
                echo "  ✅ $file → $js_file: compiled and cached"
            else
                echo "  ❌ $file: compilation failed"
            fi
        fi
    done
    
    echo ""
}

# =============================================================================
# EXAMPLE 3: TESTING CACHE (Unit Tests)
# =============================================================================

example_testing_cache() {
    echo "🧪 Example 3: Testing Cache"
    echo "============================="
    
    # Configure cache for testing
    export CACHE_DIR="./.cache/testing"  
    export CONFIG_FILES="jest.config.js package.json tsconfig.json"
    
    cache_init
    
    # Process test files (if they exist)  
    shopt -s nullglob
    for file in **/*test.js **/*spec.js; do
        [[ -f "$file" ]] || continue
        
        if cache_check_file "$file"; then
            echo "  ⚡ $file: tests cached (skipped)"
        else
            echo "  🔄 $file: running tests..."
            # Simulate test execution
            if [[ $(( RANDOM % 10 )) -gt 2 ]]; then  # 80% success rate
                cache_mark_clean "$file"
                echo "  ✅ $file: tests passed and cached"
            else
                echo "  ❌ $file: tests failed"
            fi
        fi
    done
    
    echo ""
}

# =============================================================================
# EXAMPLE 4: DOCUMENTATION GENERATION CACHE
# =============================================================================

example_docs_cache() {
    echo "📚 Example 4: Documentation Cache"
    echo "===================================="
    
    # Configure cache for documentation
    export CACHE_DIR="./.cache/docs"
    export CONFIG_FILES="mkdocs.yml .readthedocs.yml package.json"
    
    cache_init
    
    # Process documentation source files
    shopt -s nullglob
    for file in docs/**/*.md README.md; do
        [[ -f "$file" ]] || continue
        
        if cache_check_file "$file"; then
            echo "  ⚡ $file: docs cached (skipped)"
        else
            echo "  🔄 $file: generating docs..."
            # Simulate documentation generation
            local html_file="docs/build/$(basename "${file%.md}").html"
            mkdir -p "docs/build"
            if echo "<html>Generated from $file</html>" > "$html_file"; then
                cache_mark_clean "$file"
                echo "  ✅ $file → $html_file: docs generated and cached"
            else
                echo "  ❌ $file: doc generation failed"
            fi
        fi
    done
    
    echo ""
}

# =============================================================================
# EXAMPLE 5: IMAGE OPTIMIZATION CACHE
# =============================================================================

example_image_cache() {
    echo "🖼️  Example 5: Image Optimization Cache"
    echo "========================================"
    
    # Configure cache for image optimization
    export CACHE_DIR="./.cache/images"
    export CONFIG_FILES="imagemin.config.js package.json"
    
    cache_init
    
    # Process image files
    shopt -s nullglob
    for file in **/*.jpg **/*.jpeg **/*.png **/*.gif; do
        [[ -f "$file" ]] || continue
        
        if cache_check_file "$file"; then
            echo "  ⚡ $file: optimization cached (skipped)"
        else
            echo "  🔄 $file: optimizing..."
            # Simulate image optimization
            local optimized_file="dist/${file}"
            mkdir -p "$(dirname "$optimized_file")"
            if cp "$file" "$optimized_file"; then  # Simulate optimization
                cache_mark_clean "$file"
                echo "  ✅ $file → $optimized_file: optimized and cached"
            else
                echo "  ❌ $file: optimization failed"
            fi
        fi
    done
    
    echo ""
}

# =============================================================================
# EXAMPLE 6: GENERIC FILE PROCESSOR WITH CACHE
# =============================================================================

# Generic function to process any files with caching
# Usage: process_files_with_cache cache_name "*.ext" "processing_command" "config1 config2"
process_files_with_cache() {
    local cache_name="$1"
    local file_pattern="$2"
    local process_command="$3"
    local config_files="$4"
    
    echo "⚙️  Generic Processing: $cache_name"
    echo "================================="
    
    # Configure cache
    export CACHE_DIR="./.cache/$cache_name"
    export CONFIG_FILES="$config_files"
    
    cache_init
    
    # Process matching files
    for file in $file_pattern; do
        [[ -f "$file" ]] || continue
        
        if cache_check_file "$file"; then
            echo "  ⚡ $file: cached (skipped)"
        else
            echo "  🔄 $file: processing with '$process_command'..."
            if eval "$process_command '$file'"; then
                cache_mark_clean "$file"
                echo "  ✅ $file: processed and cached"
            else
                echo "  ❌ $file: processing failed"
            fi
        fi
    done
    
    cache_stats
    echo ""
}

# =============================================================================
# ADVANCED EXAMPLES
# =============================================================================

example_advanced_usage() {
    echo "🚀 Advanced Usage Examples"
    echo "============================="
    
    # Custom cache directory with environment variable
    CACHE_DIR="/tmp/my-custom-cache" cache_init
    echo "✅ Custom cache directory: /tmp/my-custom-cache"
    
    # Batch file processing
    echo ""
    echo "📦 Batch Processing Example:"
    files_to_process=("README.md" "CHANGELOG.md" "DEVELOPMENT.md")
    for file in "${files_to_process[@]}"; do
        [[ -f "$file" ]] || continue
        current_hash=$(file_hash "$file")
        if cache_hit_check "$file" "$current_hash"; then
            echo "  ✅ $file: already processed (hash: $current_hash)"
        else
            echo "  🔄 $file: needs processing (hash: $current_hash)"
        fi
    done
    
    # Cache maintenance
    echo ""
    echo "🧹 Cache Maintenance:"
    cache_cleanup
    
    # Configuration monitoring
    echo ""
    echo "⚙️  Configuration Status:"
    if config_unchanged; then
        echo "  ✅ Configuration stable - cache valid"
    else
        echo "  ⚠️  Configuration changed - cache invalidated"
        cache_invalidate
    fi
    
    echo ""
}

# =============================================================================
# PERFORMANCE BENCHMARKING
# =============================================================================

benchmark_cache_performance() {
    echo "⏱️  Performance Benchmark"
    echo "=========================="
    
    export CACHE_DIR="./.cache/benchmark"
    cache_init
    
    # Create test files
    echo "Creating test files..."
    mkdir -p test_files
    for i in {1..100}; do
        echo "Test content for file $i - $(date)" > "test_files/test_$i.txt"
    done
    
    # Benchmark: First run (cache misses)
    echo ""
    echo "🔄 First run (cache misses):"
    start_time=$(date +%s.%3N)
    
    for file in test_files/*.txt; do
        current_hash=$(file_hash "$file")
        cache_update "$file" "$current_hash" "clean"
    done
    
    end_time=$(date +%s.%3N)
    first_run_time=$(awk "BEGIN {printf \"%.3f\", $end_time - $start_time}")
    echo "  Time: ${first_run_time}s (100 files)"
    
    # Benchmark: Second run (cache hits)
    echo ""
    echo "⚡ Second run (cache hits):"
    start_time=$(date +%s.%3N)
    
    hits=0
    for file in test_files/*.txt; do
        current_hash=$(file_hash "$file")
        if cache_hit_check "$file" "$current_hash"; then
            ((hits++))
        fi
    done
    
    end_time=$(date +%s.%3N)
    second_run_time=$(awk "BEGIN {printf \"%.3f\", $end_time - $start_time}")
    speedup=$(awk "BEGIN {printf \"%.1f\", $first_run_time / $second_run_time}")
    
    echo "  Time: ${second_run_time}s (100 files)"
    echo "  Cache hits: $hits/100"
    echo "  Speedup: ${speedup}x faster"
    
    # Cleanup
    rm -rf test_files
    
    cache_stats
    echo ""
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    echo "🎯 DOH Cache Library - Multi-Purpose Examples"
    echo "=============================================="
    echo ""
    
    case "${1:-all}" in
        linting)
            example_linting_cache
            ;;
        build)
            example_build_cache
            ;;
        testing)
            example_testing_cache
            ;;
        docs)
            example_docs_cache
            ;;
        images)
            example_image_cache
            ;;
        advanced)
            example_advanced_usage
            ;;
        benchmark)
            benchmark_cache_performance
            ;;
        generic)
            # Example of generic usage
            process_files_with_cache "sass" "*.scss" "sassc" "package.json _config.yml"
            process_files_with_cache "minify" "*.js" "terser --compress --mangle" "package.json webpack.config.js"
            ;;
        all)
            example_linting_cache
            example_build_cache
            example_testing_cache
            example_docs_cache
            example_advanced_usage
            ;;
        help|*)
            echo "Usage: $0 {linting|build|testing|docs|images|advanced|benchmark|generic|all|help}"
            echo ""
            echo "Examples:"
            echo "  linting    - Demonstrate linting cache usage"
            echo "  build      - Demonstrate build system cache"
            echo "  testing    - Demonstrate test execution cache"
            echo "  docs       - Demonstrate documentation cache"
            echo "  images     - Demonstrate image optimization cache"
            echo "  advanced   - Show advanced usage patterns"
            echo "  benchmark  - Performance benchmarking"
            echo "  generic    - Generic file processing examples"
            echo "  all        - Run all examples"
            echo ""
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi