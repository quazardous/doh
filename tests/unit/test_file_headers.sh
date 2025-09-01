#!/bin/bash
# DOH Version: 0.1.0
# Created: 2025-09-01T18:55:00Z

# Test Suite for file-headers.sh library
# Comprehensive testing of version header functionality

source "$(dirname "$0")/../../.claude/scripts/doh/lib/file-headers.sh"
source "$(dirname "$0")/../lib/test_framework.sh"

# Test setup
_tf_setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    
    # Create a mock DOH project structure
    mkdir -p .doh/versions
    echo "0.1.0" > VERSION
    
    # Create test files for each supported type
    echo '#!/bin/bash' > test.sh
    echo 'echo "hello"' >> test.sh
    
    echo '# Test Markdown' > test.md
    echo 'Content here' >> test.md
    
    echo '#!/usr/bin/env python3' > test.py
    echo 'print("hello")' >> test.py
    
    echo 'console.log("hello");' > test.js
    echo 'const x: string = "hello";' > test.ts
    echo 'version: 1.0.0' > test.yml
    echo 'key: value' > test.yaml
    
    # Create files with existing headers
    cat > existing_shell.sh << 'EOF'
#!/bin/bash
# DOH Version: 0.0.1
# Created: 2025-01-01T00:00:00Z

echo "existing"
EOF
    
    cat > existing_markdown.md << 'EOF'
---
file_version: 0.0.1
created: 2025-01-01T00:00:00Z
---

# Existing Content
EOF
    
    # Create problematic files
    echo > empty.sh
    echo -n "no newline" > no_newline.py
    echo "   " > whitespace_only.js
    
    # Create unsupported file type
    echo "binary data" > test.bin
}

_tf_teardown() {
    cd /
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

# Test: Basic functionality - shell script without shebang
test_add_header_shell_no_shebang() {
    echo 'echo "test"' > simple.sh
    
    add_version_header "simple.sh" "1.0.0"
    local result=$?
    
    assert_equals 0 $result "Should succeed adding header to shell script"
    assert_file_contains "simple.sh" "# DOH Version: 1.0.0" "Should contain version header"
    assert_file_contains "simple.sh" "# Created: " "Should contain creation date"
    assert_file_contains "simple.sh" 'echo "test"' "Should preserve original content"
}

# Test: Shell script with shebang
test_add_header_shell_with_shebang() {
    add_version_header "test.sh" "1.2.3"
    local result=$?
    
    assert_equals 0 $result "Should succeed adding header to shell script with shebang"
    
    # Check header placement after shebang
    local first_line=$(head -n 1 "test.sh")
    local second_line=$(head -n 2 "test.sh" | tail -n 1)
    
    assert_equals "#!/bin/bash" "$first_line" "Shebang should remain first line"
    assert_equals "# DOH Version: 1.2.3" "$second_line" "Version header should be second line"
}

# Test: Markdown file without frontmatter
test_add_header_markdown_no_frontmatter() {
    add_version_header "test.md" "2.0.0"
    local result=$?
    
    assert_equals 0 $result "Should succeed adding frontmatter to markdown"
    
    local first_line=$(head -n 1 "test.md")
    assert_equals "---" "$first_line" "Should start with frontmatter delimiter"
    
    assert_file_contains "test.md" "file_version: 2.0.0" "Should contain version in frontmatter"
    assert_file_contains "test.md" "created:" "Should contain creation date"
    assert_file_contains "test.md" "# Test Markdown" "Should preserve original content"
}

# Test: Python file with shebang
test_add_header_python_with_shebang() {
    add_version_header "test.py" "3.1.4"
    local result=$?
    
    assert_equals 0 $result "Should succeed adding header to Python file"
    
    local first_line=$(head -n 1 "test.py")
    local second_line=$(head -n 2 "test.py" | tail -n 1)
    
    assert_equals "#!/usr/bin/env python3" "$first_line" "Shebang should remain first"
    assert_equals "# DOH Version: 3.1.4" "$second_line" "Version header should follow shebang"
}

# Test: JavaScript and TypeScript files
test_add_header_javascript() {
    add_version_header "test.js" "1.5.0"
    add_version_header "test.ts" "1.5.0"
    
    assert_file_contains "test.js" "// DOH Version: 1.5.0" "JS should have // comment style"
    assert_file_contains "test.ts" "// DOH Version: 1.5.0" "TS should have // comment style"
    assert_file_contains "test.js" 'console.log("hello");' "JS content should be preserved"
    assert_file_contains "test.ts" 'const x: string = "hello";' "TS content should be preserved"
}

# Test: YAML files
test_add_header_yaml() {
    add_version_header "test.yml" "0.9.0"
    add_version_header "test.yaml" "0.9.0"
    
    assert_file_contains "test.yml" "# DOH Version: 0.9.0" "YML should have # comment style"
    assert_file_contains "test.yaml" "# DOH Version: 0.9.0" "YAML should have # comment style"
}

# Test: File already has header
test_skip_existing_headers() {
    add_version_header "existing_shell.sh" "2.0.0"
    local result=$?
    
    assert_equals 0 $result "Should return success when header already exists"
    assert_file_contains "existing_shell.sh" "# DOH Version: 0.0.1" "Should keep original version"
    assert_not_file_contains "existing_shell.sh" "# DOH Version: 2.0.0" "Should not add new version"
}

# Test: Error handling - missing file
test_error_missing_file() {
    add_version_header "nonexistent.sh" "1.0.0" 2>/dev/null
    local result=$?
    
    assert_equals 1 $result "Should fail when file doesn't exist"
}

# Test: Error handling - missing file path
test_error_missing_path() {
    add_version_header "" "1.0.0" 2>/dev/null
    local result=$?
    
    assert_equals 1 $result "Should fail when no file path provided"
}

# Test: Error handling - invalid version
test_error_invalid_version() {
    add_version_header "test.sh" "invalid.version" 2>/dev/null
    local result=$?
    
    # Should still succeed as we don't validate version format in this function
    assert_equals 0 $result "Should handle invalid version gracefully"
}

# Test: Unsupported file type
test_unsupported_file_type() {
    add_version_header "test.bin" "1.0.0" 2>/dev/null
    local result=$?
    
    assert_equals 0 $result "Should return success for unsupported types"
    assert_not_file_contains "test.bin" "DOH Version:" "Should not modify unsupported files"
}

# Test: Empty file
test_empty_file() {
    add_version_header "empty.sh" "1.0.0"
    local result=$?
    
    assert_equals 0 $result "Should handle empty files"
    assert_file_contains "empty.sh" "# DOH Version: 1.0.0" "Should add header to empty file"
}

# Test: File without newline at end
test_no_newline_file() {
    add_version_header "no_newline.py" "1.0.0"
    local result=$?
    
    assert_equals 0 $result "Should handle files without trailing newline"
    assert_file_contains "no_newline.py" "# DOH Version: 1.0.0" "Should add header"
    assert_file_contains "no_newline.py" "no newline" "Should preserve content"
}

# Test: File with only whitespace
test_whitespace_only_file() {
    add_version_header "whitespace_only.js" "1.0.0"
    local result=$?
    
    assert_equals 0 $result "Should handle whitespace-only files"
    assert_file_contains "whitespace_only.js" "// DOH Version: 1.0.0" "Should add header"
}

# Test: file_has_version_header detection
test_header_detection() {
    # Test positive cases
    file_has_version_header "existing_shell.sh"
    assert_equals 0 $? "Should detect existing shell header"
    
    file_has_version_header "existing_markdown.md"
    assert_equals 0 $? "Should detect existing markdown header"
    
    # Test negative cases
    file_has_version_header "test.sh"
    assert_equals 1 $? "Should not detect header in file without one"
}

# Test: batch_add_headers function
test_batch_processing() {
    # Create multiple files
    echo 'echo "batch1"' > batch1.sh
    echo 'echo "batch2"' > batch2.sh
    echo 'print("batch3")' > batch3.py
    
    batch_add_headers batch1.sh batch2.sh batch3.py 2>/dev/null
    local result=$?
    
    assert_equals 0 $result "Batch processing should succeed"
    assert_file_contains "batch1.sh" "# DOH Version:" "First file should have header"
    assert_file_contains "batch2.sh" "# DOH Version:" "Second file should have header"
    assert_file_contains "batch3.py" "# DOH Version:" "Third file should have header"
}

# Test: batch processing with some failures
test_batch_processing_with_failures() {
    echo 'echo "good"' > good.sh
    # nonexistent.sh doesn't exist
    
    batch_add_headers good.sh nonexistent.sh 2>/dev/null
    local result=$?
    
    assert_equals 1 $result "Batch processing should fail if any file fails"
    assert_file_contains "good.sh" "# DOH Version:" "Good file should still be processed"
}

# Test: find_files_missing_headers function
test_find_missing_headers() {
    # Create files with and without headers
    echo 'echo "no header"' > missing.sh
    echo 'print("no header")' > missing.py
    add_version_header "existing_shell.sh" "1.0.0" 2>/dev/null  # This already has header
    
    local missing_files=$(find_files_missing_headers .)
    
    assert_contains "$missing_files" "missing.sh" "Should find shell file missing header"
    assert_contains "$missing_files" "missing.py" "Should find python file missing header"
    assert_not_contains "$missing_files" "existing_shell.sh" "Should not include files with headers"
}

# Test: Version retrieval from VERSION file
test_version_from_file() {
    echo "1.5.7" > VERSION
    
    add_version_header "version_test.sh"  # No explicit version provided
    local result=$?
    
    assert_equals 0 $result "Should succeed getting version from VERSION file"
    assert_file_contains "version_test.sh" "# DOH Version: 1.5.7" "Should use version from VERSION file"
}

# Test: Markdown with existing frontmatter
test_markdown_existing_frontmatter() {
    cat > existing_fm.md << 'EOF'
---
title: Test Document
author: Test Author
---

# Content
EOF
    
    add_version_header "existing_fm.md" "1.0.0"
    local result=$?
    
    assert_equals 0 $result "Should handle existing frontmatter"
    assert_file_contains "existing_fm.md" "file_version: 1.0.0" "Should add version to frontmatter"
    assert_file_contains "existing_fm.md" "title: Test Document" "Should preserve existing frontmatter"
    assert_file_contains "existing_fm.md" "# Content" "Should preserve content"
}

# Test: Large file handling
test_large_file() {
    # Create a larger file
    for i in {1..1000}; do
        echo "Line $i of test content" >> large.sh
    done
    
    add_version_header "large.sh" "1.0.0"
    local result=$?
    
    assert_equals 0 $result "Should handle large files"
    assert_file_contains "large.sh" "# DOH Version: 1.0.0" "Should add header to large file"
    
    # Check that all content is preserved
    local line_count=$(wc -l < large.sh)
    assert_greater_than $line_count 1000 "Should preserve all content lines plus header"
}

# Test: Special characters in file content
test_special_characters() {
    cat > special.sh << 'EOF'
#!/bin/bash
echo "Special chars: éñüñiöns & símb0ls $@#%"
echo 'Single quotes with "nested doubles"'
echo "Double quotes with 'nested singles'"
EOF
    
    add_version_header "special.sh" "1.0.0"
    local result=$?
    
    assert_equals 0 $result "Should handle special characters"
    assert_file_contains "special.sh" "# DOH Version: 1.0.0" "Should add header"
    assert_file_contains "special.sh" "éñüñiöns & símb0ls" "Should preserve special characters"
    assert_file_contains "special.sh" 'Single quotes with "nested doubles"' "Should preserve nested quotes"
}

# Helper functions for tests
assert_file_contains() {
    local file="$1"
    local expected="$2"
    local message="$3"
    
    if grep -q "$expected" "$file" 2>/dev/null; then
        _tf_pass "$message"
    else
        _tf_fail "$message - Expected '$expected' in $file"
        echo "File contents:" >&2
        cat "$file" >&2
    fi
}

assert_not_file_contains() {
    local file="$1"
    local unexpected="$2"
    local message="$3"
    
    if ! grep -q "$unexpected" "$file" 2>/dev/null; then
        _tf_pass "$message"
    else
        _tf_fail "$message - Found unexpected '$unexpected' in $file"
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="$3"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        _tf_pass "$message"
    else
        _tf_fail "$message - '$needle' not found in '$haystack'"
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="$3"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        _tf_pass "$message"
    else
        _tf_fail "$message - Found unexpected '$needle' in '$haystack'"
    fi
}

assert_greater_than() {
    local actual="$1"
    local expected="$2"
    local message="$3"
    
    if [[ $actual -gt $expected ]]; then
        _tf_pass "$message"
    else
        _tf_fail "$message - Expected $actual > $expected"
    fi
}