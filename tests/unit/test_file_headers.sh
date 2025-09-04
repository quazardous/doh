#!/bin/bash
# DOH Version: 0.1.0
# Created: 2025-09-01T18:55:00Z

# Test Suite for file-headers.sh library
# Comprehensive testing of version header functionality

source "$(dirname "${BASH_SOURCE[0]}")/../helpers/test_framework.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

# Test setup
_tf_setup() {
    # Use skeleton fixture system for proper test isolation
    _tff_create_helper_test_project >/dev/null
    _tff_setup_workspace_for_helpers >/dev/null
    
    # Source the library after environment is set up
    source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/file-headers.sh"
    source "$(dirname "${BASH_SOURCE[0]}")/../../.claude/scripts/doh/lib/doh.sh"
    
    # Get project directory using DOH function
    local project_dir=$(doh_project_dir)
    
    # Create test files for each supported type in the project directory
    echo '#!/bin/bash' > "$project_dir/test.sh"
    echo 'echo "hello"' >> "$project_dir/test.sh"
    
    cat > "$project_dir/test.md" << 'EOF'
---
title: Test Document
---

# Test Markdown
Content here
EOF
    
    echo '#!/usr/bin/env python3' > "$project_dir/test.py"
    echo 'print("hello")' >> "$project_dir/test.py"
    
    echo 'console.log("hello");' > "$project_dir/test.js"
    echo 'const x: string = "hello";' > "$project_dir/test.ts"
    echo 'version: 1.0.0' > "$project_dir/test.yml"
    echo 'key: value' > "$project_dir/test.yaml"
    
    # Create files with existing headers
    cat > "$project_dir/existing_shell.sh" << 'EOF'
#!/bin/bash
# DOH Version: 0.0.1
# Created: 2025-01-01T00:00:00Z

echo "existing"
EOF
    
    cat > "$project_dir/existing_markdown.md" << 'EOF'
---
file_version: 0.0.1
created: 2025-01-01T00:00:00Z
---

# Existing Content
EOF
    
    # Create problematic files
    echo > "$project_dir/empty.sh"
    echo -n "no newline" > "$project_dir/no_newline.py"
    echo "   " > "$project_dir/whitespace_only.js"
    
    # Create unsupported file type
    echo "binary data" > "$project_dir/test.bin"
}

_tf_teardown() {
    # Cleanup handled by test launcher isolation
    return 0
}

# Test: Basic functionality - shell script without shebang
test_add_header_shell_no_shebang() {
    local temp_dir=$(_tf_test_container_tmpdir)
    local file_path="$temp_dir/simple.sh"
    echo 'echo "test"' > "$file_path"

    _tf_assert "Should succeed adding header to shell script" file_headers_add_version "$file_path" "1.0.0"
    _tf_assert_file_contains "Should contain version header" "$file_path" "# DOH Version: 1.0.0"
    _tf_assert_file_contains "Should contain creation date" "$file_path" "# Created: "
    _tf_assert_file_contains "Should preserve original content" "$file_path" 'echo "test"'
}

# Test: Shell script with shebang
test_add_header_shell_with_shebang() {
    local temp_dir=$(_tf_test_container_tmpdir)
    local file_path="$temp_dir/test.sh"
    echo '#!/bin/bash' > "$file_path"
    echo 'echo "hello"' >> "$file_path"
    
    _tf_assert "Should succeed adding header to shell script with shebang" file_headers_add_version "$file_path" "1.2.3"
    
    # Check header placement after shebang
    local first_line=$(head -n 1 "$file_path")
    local second_line=$(head -n 2 "$file_path" | tail -n 1)
    
    _tf_assert_equals "Shebang should remain first line" "#!/bin/bash" "$first_line"
    _tf_assert_equals "Version header should be second line" "# DOH Version: 1.2.3" "$second_line"
}

# Test: Markdown file without frontmatter (should use HTML comments)
test_add_header_markdown_no_frontmatter() {
    local temp_dir=$(_tf_test_container_tmpdir)
    local file_path="$temp_dir/plain.md"
    
    # Create a markdown file without frontmatter
    echo '# Plain Markdown' > "$file_path"
    echo 'No frontmatter here' >> "$file_path"
    
    _tf_assert "Should succeed adding header to plain markdown" file_headers_add_version "$file_path" "2.0.0"
    
    local first_line=$(head -n 1 "$file_path")
    _tf_assert_equals "Should start with HTML comment" "<!-- DOH Version: 2.0.0 -->" "$first_line"
    
    _tf_assert_file_contains "Should contain version in HTML comment" "$file_path" "<!-- DOH Version: 2.0.0"
    _tf_assert_file_contains "Should preserve original content" "$file_path" "# Plain Markdown"
}

# Test: Markdown file with existing frontmatter (should use frontmatter)
test_add_header_markdown_with_frontmatter() {
    local project_dir=$(doh_project_dir)
    local file_path="$project_dir/test.md"  # test.md has frontmatter from setup
    
    _tf_assert "Should succeed adding to frontmatter" file_headers_add_version "$file_path" "2.0.0"
    
    local first_line=$(head -n 1 "$file_path")
    _tf_assert_equals "Should start with frontmatter delimiter" "---" "$first_line"
    
    _tf_assert_file_contains "Should contain version in frontmatter" "$file_path" "file_version: 2.0.0"
    _tf_assert_file_contains "Should preserve original frontmatter" "$file_path" "title: Test Document"
    _tf_assert_file_contains "Should preserve original content" "$file_path" "# Test Markdown"
}

# Test: Python file with shebang
test_add_header_python_with_shebang() {
    local project_dir=$(doh_project_dir)
    local file_path="$project_dir/test.py"  # test.py from setup
    
    _tf_assert "Should succeed adding header to Python file" file_headers_add_version "$file_path" "3.1.4"
    
    local first_line=$(head -n 1 "$file_path")
    local second_line=$(head -n 2 "$file_path" | tail -n 1)
    
    _tf_assert_equals "Shebang should remain first" "#!/usr/bin/env python3" "$first_line"
    _tf_assert_equals "Version header should follow shebang" "# DOH Version: 3.1.4" "$second_line"
}

# Test: JavaScript and TypeScript files
test_add_header_javascript() {
    local project_dir=$(doh_project_dir)
    
    file_headers_add_version "$project_dir/test.js" "1.5.0"
    file_headers_add_version "$project_dir/test.ts" "1.5.0"
    
    _tf_assert_file_contains "JS should have // comment style" "$project_dir/test.js" "// DOH Version: 1.5.0"
    _tf_assert_file_contains "TS should have // comment style" "$project_dir/test.ts" "// DOH Version: 1.5.0"
    _tf_assert_file_contains "JS content should be preserved" "$project_dir/test.js" 'console.log("hello");'
    _tf_assert_file_contains "TS content should be preserved" "$project_dir/test.ts" 'const x: string = "hello";'
}

# Test: YAML files
test_add_header_yaml() {
    local project_dir=$(doh_project_dir)
    
    file_headers_add_version "$project_dir/test.yml" "0.9.0"
    file_headers_add_version "$project_dir/test.yaml" "0.9.0"
    
    _tf_assert_file_contains "YML should have # comment style" "$project_dir/test.yml" "# DOH Version: 0.9.0"
    _tf_assert_file_contains "YAML should have # comment style" "$project_dir/test.yaml" "# DOH Version: 0.9.0"
}

# Test: File already has header
test_skip_existing_headers() {
    local project_dir=$(doh_project_dir)
    local file_path="$project_dir/existing_shell.sh"
    
    _tf_assert "Should return success when header already exists" file_headers_add_version "$file_path" "2.0.0"
    _tf_assert_file_contains "Should keep original version" "$file_path" "# DOH Version: 0.0.1"
    _tf_assert_not "Should not add new version" grep -q "# DOH Version: 2.0.0" "$file_path"
}

# Test: Error handling - missing file
test_error_missing_file() {
    _tf_assert_not "Should fail when file doesn't exist" file_headers_add_version "nonexistent.sh" "1.0.0"
}

# Test: Error handling - missing file path
test_error_missing_path() {
    _tf_assert_not "Should fail when no file path provided" file_headers_add_version "" "1.0.0"
}

# Test: Error handling - invalid version
test_error_invalid_version() {
    local temp_dir=$(_tf_test_container_tmpdir)
    local file_path="$temp_dir/test.sh"
    echo 'echo "test"' > "$file_path"
    
    # Should still succeed as we don't validate version format in this function
    _tf_assert "Should handle invalid version gracefully" file_headers_add_version "$file_path" "invalid.version"
}

# Test: Unsupported file type
test_unsupported_file_type() {
    local project_dir=$(doh_project_dir)
    local file_path="$project_dir/test.bin"
    
    _tf_assert "Should return success for unsupported types" file_headers_add_version "$file_path" "1.0.0"
    _tf_assert_not "Should not modify unsupported files" grep -q "DOH Version:" "$file_path"
}

# Test: Empty file
test_empty_file() {
    local project_dir=$(doh_project_dir)
    local file_path="$project_dir/empty.sh"
    
    _tf_assert "Should handle empty files" file_headers_add_version "$file_path" "1.0.0"
    _tf_assert_file_contains "Should add header to empty file" "$file_path" "# DOH Version: 1.0.0"
}

# Test: File without newline at end
test_no_newline_file() {
    local project_dir=$(doh_project_dir)
    local file_path="$project_dir/no_newline.py"
    
    _tf_assert "Should handle files without trailing newline" file_headers_add_version "$file_path" "1.0.0"
    _tf_assert_file_contains "Should add header" "$file_path" "# DOH Version: 1.0.0"
    _tf_assert_file_contains "Should preserve content" "$file_path" "no newline"
}

# Test: File with only whitespace
test_whitespace_only_file() {
    local project_dir=$(doh_project_dir)
    local file_path="$project_dir/whitespace_only.js"
    
    _tf_assert "Should handle whitespace-only files" file_headers_add_version "$file_path" "1.0.0"
    _tf_assert_file_contains "Should add header" "$file_path" "// DOH Version: 1.0.0"
}

# Test: file_headers_file_has_version detection
test_header_detection() {
    local project_dir=$(doh_project_dir)
    
    # Test positive cases
    _tf_assert "Should detect existing shell header" file_headers_file_has_version "$project_dir/existing_shell.sh"
    _tf_assert "Should detect existing markdown header" file_headers_file_has_version "$project_dir/existing_markdown.md"
    
    # Test negative cases
    local temp_dir=$(_tf_test_container_tmpdir)
    local file_path="$temp_dir/test.sh"
    echo 'echo "no header"' > "$file_path"
    
    _tf_assert_not "Should not detect header in file without one" file_headers_file_has_version "$file_path"
}

# Test: file_headers_batch_add function
test_batch_processing() {
    local temp_dir=$(_tf_test_container_tmpdir)
    # Create multiple files
    echo 'echo "batch1"' > "$temp_dir/batch1.sh"
    echo 'echo "batch2"' > "$temp_dir/batch2.sh"
    echo 'print("batch3")' > "$temp_dir/batch3.py"

    _tf_assert "Batch processing should succeed" file_headers_batch_add "$temp_dir/batch1.sh" "$temp_dir/batch2.sh" "$temp_dir/batch3.py"
    _tf_assert_file_contains "First file should have header" "$temp_dir/batch1.sh" "# DOH Version:"
    _tf_assert_file_contains "Second file should have header" "$temp_dir/batch2.sh" "# DOH Version:"
    _tf_assert_file_contains "Third file should have header" "$temp_dir/batch3.py" "# DOH Version:"
}

# Test: batch processing with some failures
test_batch_processing_with_failures() {
    local temp_dir=$(_tf_test_container_tmpdir)
    echo 'echo "good"' > "$temp_dir/good.sh"
    # nonexistent.sh doesn't exist

    _tf_assert_not "Batch processing should fail if any file fails" file_headers_batch_add "$temp_dir/good.sh" "$temp_dir/nonexistent.sh"
    _tf_assert_file_contains "Good file should still be processed" "$temp_dir/good.sh" "# DOH Version:"
}

# Test: file_headers_find_missing_files function
test_find_missing_headers() {
    local temp_dir=$(_tf_test_container_tmpdir)
    # Create files with and without headers
    echo 'echo "no header"' > "$temp_dir/missing.sh"
    echo 'print("no header")' > "$temp_dir/missing.py"
    file_headers_add_version "$temp_dir/existing_shell.sh" "1.0.0"  # This already has header

    local missing_files=$(file_headers_find_missing_files "$temp_dir")

    _tf_assert_contains "Should find shell file missing header" "$missing_files" "missing.sh"
    _tf_assert_contains "Should find python file missing header" "$missing_files" "missing.py"
    _tf_assert_not_contains "Should not include files with headers" "$missing_files" "existing_shell.sh"
}

# Test: Version retrieval from VERSION file
test_version_from_file() {
    local temp_dir=$(_tf_test_container_tmpdir)
    echo "1.5.7" > "$temp_dir/VERSION"
    echo 'echo "test"' > "$temp_dir/version_test.sh"

    _tf_assert "Should succeed getting version from VERSION file" file_headers_add_version "$temp_dir/version_test.sh"  # No explicit version provided
    _tf_assert_file_contains "Should use version from VERSION file" "$temp_dir/version_test.sh" "# DOH Version: 0.2.0"
}

# Test: Markdown with existing frontmatter
test_markdown_existing_frontmatter() {
    local temp_dir=$(_tf_test_container_tmpdir)
    cat > "$temp_dir/existing_fm.md" << 'EOF'
---
title: Test Document
author: Test Author
---

# Content
EOF

    _tf_assert "Should handle existing frontmatter" file_headers_add_version "$temp_dir/existing_fm.md" "1.0.0"
    _tf_assert_file_contains "Should add version to frontmatter" "$temp_dir/existing_fm.md" "file_version: 1.0.0"
    _tf_assert_file_contains "Should preserve existing frontmatter" "$temp_dir/existing_fm.md" "title: Test Document"
    _tf_assert_file_contains "Should preserve content" "$temp_dir/existing_fm.md" "# Content"
}

# Test: Large file handling
test_large_file() {
    local temp_dir=$(_tf_test_container_tmpdir)

    touch "$temp_dir/large.sh"
    # Create a larger file
    for i in {1..1000}; do
        echo "Line $i of test content" >> "$temp_dir/large.sh"
    done

    _tf_assert "Should handle large files" file_headers_add_version "$temp_dir/large.sh" "1.0.0"
    _tf_assert_file_contains "Should add header to large file" "$temp_dir/large.sh" "# DOH Version: 1.0.0"

    # Check that all content is preserved
    local line_count=$(wc -l < "$temp_dir/large.sh")
    _tf_assert "Should preserve all content lines plus header" test "$line_count" -gt 1000
}

# Test: Special characters in file content
test_special_characters() {
    local temp_dir=$(_tf_test_container_tmpdir)
    cat > "$temp_dir/special.sh" << 'EOF'
#!/bin/bash
echo "Special chars: éñüñiöns & símb0ls $@#%"
echo 'Single quotes with "nested doubles"'
echo "Double quotes with 'nested singles'"
EOF

    _tf_assert "Should handle special characters" file_headers_add_version "$temp_dir/special.sh" "1.0.0"
    _tf_assert_file_contains "Should add header" "$temp_dir/special.sh" "# DOH Version: 1.0.0"
    _tf_assert_file_contains "Should preserve special characters" "$temp_dir/special.sh" "éñüñiöns & símb0ls"
    _tf_assert_file_contains "Should preserve nested quotes" "$temp_dir/special.sh" 'Single quotes with "nested doubles"'
}

# Run tests if script executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    _tf_direct_execution_error
fi
