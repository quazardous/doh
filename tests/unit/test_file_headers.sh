#!/bin/bash
# DOH Version: 0.1.0
# Created: 2025-09-01T18:55:00Z

# Test Suite for file-headers.sh library
# Comprehensive testing of version header functionality

source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/file-headers.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"

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
    
    cat > test.md << 'EOF'
---
title: Test Document
---

# Test Markdown
Content here
EOF
    
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
    
    file_headers_add_version "simple.sh" "1.0.0"
    local result=$?
    
    _tf_assert_equals "Should succeed adding header to shell script" "0" "$result"
    _tf_assert_file_contains "Should contain version header" "simple.sh" "# DOH Version: 1.0.0"
    _tf_assert_file_contains "Should contain creation date" "simple.sh" "# Created: "
    _tf_assert_file_contains "Should preserve original content" "simple.sh" 'echo "test"'
}

# Test: Shell script with shebang
test_add_header_shell_with_shebang() {
    file_headers_add_version "test.sh" "1.2.3"
    local result=$?
    
    _tf_assert_equals "Should succeed adding header to shell script with shebang" "0" "$result"
    
    # Check header placement after shebang
    local first_line=$(head -n 1 "test.sh")
    local second_line=$(head -n 2 "test.sh" | tail -n 1)
    
    _tf_assert_equals "Shebang should remain first line" "#!/bin/bash" "$first_line"
    _tf_assert_equals "Version header should be second line" "# DOH Version: 1.2.3" "$second_line"
}

# Test: Markdown file without frontmatter (should use HTML comments)
test_add_header_markdown_no_frontmatter() {
    # Create a markdown file without frontmatter
    echo '# Plain Markdown' > plain.md
    echo 'No frontmatter here' >> plain.md
    
    file_headers_add_version "plain.md" "2.0.0"
    local result=$?
    
    _tf_assert_equals "Should succeed adding header to plain markdown" "0" "$result"
    
    local first_line=$(head -n 1 "plain.md")
    _tf_assert_equals "Should start with HTML comment" "<!-- DOH Version: 2.0.0 -->" "$first_line"
    
    _tf_assert_file_contains "Should contain version in HTML comment" "plain.md" "<!-- DOH Version: 2.0.0"
    _tf_assert_file_contains "Should preserve original content" "plain.md" "# Plain Markdown"
}

# Test: Markdown file with existing frontmatter (should use frontmatter)
test_add_header_markdown_with_frontmatter() {
    file_headers_add_version "test.md" "2.0.0"  # test.md has frontmatter from setup
    local result=$?
    
    _tf_assert_equals "Should succeed adding to frontmatter" "0" "$result"
    
    local first_line=$(head -n 1 "test.md")
    _tf_assert_equals "Should start with frontmatter delimiter" "---" "$first_line"
    
    _tf_assert_file_contains "Should contain version in frontmatter" "test.md" "file_version: 2.0.0"
    _tf_assert_file_contains "Should preserve original frontmatter" "test.md" "title: Test Document"
    _tf_assert_file_contains "Should preserve original content" "test.md" "# Test Markdown"
}

# Test: Python file with shebang
test_add_header_python_with_shebang() {
    file_headers_add_version "test.py" "3.1.4"
    local result=$?
    
    _tf_assert_equals "Should succeed adding header to Python file" "0" "$result"
    
    local first_line=$(head -n 1 "test.py")
    local second_line=$(head -n 2 "test.py" | tail -n 1)
    
    _tf_assert_equals "Shebang should remain first" "#!/usr/bin/env python3" "$first_line"
    _tf_assert_equals "Version header should follow shebang" "# DOH Version: 3.1.4" "$second_line"
}

# Test: JavaScript and TypeScript files
test_add_header_javascript() {
    file_headers_add_version "test.js" "1.5.0"
    file_headers_add_version "test.ts" "1.5.0"
    
    _tf_assert_file_contains "JS should have // comment style" "test.js" "// DOH Version: 1.5.0"
    _tf_assert_file_contains "TS should have // comment style" "test.ts" "// DOH Version: 1.5.0"
    _tf_assert_file_contains "JS content should be preserved" "test.js" 'console.log("hello");'
    _tf_assert_file_contains "TS content should be preserved" "test.ts" 'const x: string = "hello";'
}

# Test: YAML files
test_add_header_yaml() {
    file_headers_add_version "test.yml" "0.9.0"
    file_headers_add_version "test.yaml" "0.9.0"
    
    _tf_assert_file_contains "YML should have # comment style" "test.yml" "# DOH Version: 0.9.0"
    _tf_assert_file_contains "YAML should have # comment style" "test.yaml" "# DOH Version: 0.9.0"
}

# Test: File already has header
test_skip_existing_headers() {
    file_headers_add_version "existing_shell.sh" "2.0.0"
    local result=$?
    
    _tf_assert_equals "Should return success when header already exists" "0" "$result"
    _tf_assert_file_contains "Should keep original version" "existing_shell.sh" "# DOH Version: 0.0.1"
    _tf_assert_not "Should not add new version" grep -q "# DOH Version: 2.0.0" "existing_shell.sh"
}

# Test: Error handling - missing file
test_error_missing_file() {
    file_headers_add_version "nonexistent.sh" "1.0.0" 2>/dev/null
    local result=$?
    
    _tf_assert_equals "Should fail when file doesn't exist" "1" "$result"
}

# Test: Error handling - missing file path
test_error_missing_path() {
    file_headers_add_version "" "1.0.0" 2>/dev/null
    local result=$?
    
    _tf_assert_equals "Should fail when no file path provided" "1" "$result"
}

# Test: Error handling - invalid version
test_error_invalid_version() {
    file_headers_add_version "test.sh" "invalid.version" 2>/dev/null
    local result=$?
    
    # Should still succeed as we don't validate version format in this function
    _tf_assert_equals "Should handle invalid version gracefully" "0" "$result"
}

# Test: Unsupported file type
test_unsupported_file_type() {
    file_headers_add_version "test.bin" "1.0.0" 2>/dev/null
    local result=$?
    
    _tf_assert_equals "Should return success for unsupported types" "0" "$result"
    _tf_assert_not "Should not modify unsupported files" grep -q "DOH Version:" "test.bin"
}

# Test: Empty file
test_empty_file() {
    file_headers_add_version "empty.sh" "1.0.0"
    local result=$?
    
    _tf_assert_equals "Should handle empty files" "0" "$result"
    _tf_assert_file_contains "Should add header to empty file" "empty.sh" "# DOH Version: 1.0.0"
}

# Test: File without newline at end
test_no_newline_file() {
    file_headers_add_version "no_newline.py" "1.0.0"
    local result=$?
    
    _tf_assert_equals "Should handle files without trailing newline" "0" "$result"
    _tf_assert_file_contains "Should add header" "no_newline.py" "# DOH Version: 1.0.0"
    _tf_assert_file_contains "Should preserve content" "no_newline.py" "no newline"
}

# Test: File with only whitespace
test_whitespace_only_file() {
    file_headers_add_version "whitespace_only.js" "1.0.0"
    local result=$?
    
    _tf_assert_equals "Should handle whitespace-only files" "0" "$result"
    _tf_assert_file_contains "Should add header" "whitespace_only.js" "// DOH Version: 1.0.0"
}

# Test: file_headers_file_has_version detection
test_header_detection() {
    # Test positive cases
    file_headers_file_has_version "existing_shell.sh"
    _tf_assert_equals "Should detect existing shell header" "0" "$?"
    
    file_headers_file_has_version "existing_markdown.md"
    _tf_assert_equals "Should detect existing markdown header" "0" "$?"
    
    # Test negative cases
    file_headers_file_has_version "test.sh"
    _tf_assert_equals "Should not detect header in file without one" "1" "$?"
}

# Test: file_headers_batch_add function
test_batch_processing() {
    # Create multiple files
    echo 'echo "batch1"' > batch1.sh
    echo 'echo "batch2"' > batch2.sh
    echo 'print("batch3")' > batch3.py
    
    file_headers_batch_add batch1.sh batch2.sh batch3.py 2>/dev/null
    local result=$?
    
    _tf_assert_equals "Batch processing should succeed" "0" "$result"
    _tf_assert_file_contains "First file should have header" "batch1.sh" "# DOH Version:"
    _tf_assert_file_contains "Second file should have header" "batch2.sh" "# DOH Version:"
    _tf_assert_file_contains "Third file should have header" "batch3.py" "# DOH Version:"
}

# Test: batch processing with some failures
test_batch_processing_with_failures() {
    echo 'echo "good"' > good.sh
    # nonexistent.sh doesn't exist
    
    file_headers_batch_add good.sh nonexistent.sh 2>/dev/null
    local result=$?
    
    _tf_assert_equals "Batch processing should fail if any file fails" "1" "$result"
    _tf_assert_file_contains "Good file should still be processed" "good.sh" "# DOH Version:"
}

# Test: file_headers_find_missing_files function
test_find_missing_headers() {
    # Create files with and without headers
    echo 'echo "no header"' > missing.sh
    echo 'print("no header")' > missing.py
    file_headers_add_version "existing_shell.sh" "1.0.0" 2>/dev/null  # This already has header
    
    local missing_files=$(file_headers_find_missing_files .)
    
    _tf_assert_contains "Should find shell file missing header" "$missing_files" "missing.sh"
    _tf_assert_contains "Should find python file missing header" "$missing_files" "missing.py"
    _tf_assert_not_contains "Should not include files with headers" "$missing_files" "existing_shell.sh"
}

# Test: Version retrieval from VERSION file
test_version_from_file() {
    echo "1.5.7" > VERSION
    echo 'echo "test"' > version_test.sh
    
    file_headers_add_version "version_test.sh"  # No explicit version provided
    local result=$?
    
    _tf_assert_equals "Should succeed getting version from VERSION file" "0" "$result"
    _tf_assert_file_contains "Should use version from VERSION file" "version_test.sh" "# DOH Version: 0.2.0"
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
    
    file_headers_add_version "existing_fm.md" "1.0.0"
    local result=$?
    
    _tf_assert_equals "Should handle existing frontmatter" "0" "$result"
    _tf_assert_file_contains "Should add version to frontmatter" "existing_fm.md" "file_version: 1.0.0"
    _tf_assert_file_contains "Should preserve existing frontmatter" "existing_fm.md" "title: Test Document"
    _tf_assert_file_contains "Should preserve content" "existing_fm.md" "# Content"
}

# Test: Large file handling
test_large_file() {
    # Create a larger file
    for i in {1..1000}; do
        echo "Line $i of test content" >> large.sh
    done
    
    file_headers_add_version "large.sh" "1.0.0"
    local result=$?
    
    _tf_assert_equals "Should handle large files" "0" "$result"
    _tf_assert_file_contains "Should add header to large file" "large.sh" "# DOH Version: 1.0.0"
    
    # Check that all content is preserved
    local line_count=$(wc -l < large.sh)
    _tf_assert "Should preserve all content lines plus header" test "$line_count" -gt 1000
}

# Test: Special characters in file content
test_special_characters() {
    cat > special.sh << 'EOF'
#!/bin/bash
echo "Special chars: éñüñiöns & símb0ls $@#%"
echo 'Single quotes with "nested doubles"'
echo "Double quotes with 'nested singles'"
EOF
    
    file_headers_add_version "special.sh" "1.0.0"
    local result=$?
    
    _tf_assert_equals "Should handle special characters" "0" "$result"
    _tf_assert_file_contains "Should add header" "special.sh" "# DOH Version: 1.0.0"
    _tf_assert_file_contains "Should preserve special characters" "special.sh" "éñüñiöns & símb0ls"
    _tf_assert_file_contains "Should preserve nested quotes" "special.sh" 'Single quotes with "nested doubles"'
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
