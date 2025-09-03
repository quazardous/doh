#!/bin/bash
# Script to fix assertion parameter order issues in test files
# Converts old patterns to message-first patterns

echo "Fixing assertion parameter order in test files..."

find tests -name "*.sh" -type f | while read -r file; do
    echo "Processing: $file"
    
    # Fix _tf_assert_equals patterns
    sed -i 's/_tf_assert_equals "\([^"]*\)" "\([^"]*\)" "\([^"]*\)"/_tf_assert_equals "\3" "\1" "\2"/g' "$file"
    sed -i 's/_tf_assert_equals \([^"]\+\) \([^"]\+\) "\([^"]*\)"/_tf_assert_equals "\3" \1 \2/g' "$file"
    
    # Fix _tf_assert_not_equals patterns  
    sed -i 's/_tf_assert_not_equals "\([^"]*\)" "\([^"]*\)" "\([^"]*\)"/_tf_assert_not_equals "\3" "\1" "\2"/g' "$file"
    
    # Fix _tf_assert_contains patterns
    sed -i 's/_tf_assert_contains "\([^"]*\)" "\([^"]*\)" "\([^"]*\)"/_tf_assert_contains "\3" "\1" "\2"/g' "$file"
    
    # Fix _tf_assert_file_exists patterns
    sed -i 's/_tf_assert_file_exists "\([^"]*\)" "\([^"]*\)"/_tf_assert_file_exists "\2" "\1"/g' "$file"
    
    # Fix _tf_assert_file_contains patterns
    sed -i 's/_tf_assert_file_contains "\([^"]*\)" "\([^"]*\)" "\([^"]*\)"/_tf_assert_file_contains "\3" "\1" "\2"/g' "$file"
    
    # Fix _tf_assert_true patterns
    sed -i 's/_tf_assert_true "\([^"]*\)" "\([^"]*\)"/_tf_assert_true "\2" "\1"/g' "$file"
    
    # Fix _tf_assert_false patterns
    sed -i 's/_tf_assert_false "\([^"]*\)" "\([^"]*\)"/_tf_assert_false "\2" "\1"/g' "$file"
    
    # Replace _tf_assert_command_succeeds with _tf_assert
    sed -i 's/_tf_assert_command_succeeds "\([^"]*\)" "\([^"]*\)"/_tf_assert "\2" \1/g' "$file"
    
    # Replace _tf_assert_command_fails with _tf_assert_not  
    sed -i 's/_tf_assert_command_fails "\([^"]*\)" "\([^"]*\)"/_tf_assert_not "\2" \1/g' "$file"
done

echo "Assertion parameter order fixes completed."