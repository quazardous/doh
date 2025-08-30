# DOH Linting Exception Handling Guide

**DD089 Implementation** - Perfect Linting System with Exception Management

## Overview

The DOH linting system supports intelligent exception handling for intentional errors, documentation examples, and
context-aware linting exclusions.

## Exception Types Supported

### 1. Inline Tool Exceptions

#### Markdownlint Exceptions
```markdown
<!-- markdownlint-disable MD013 -->
This line can be very long without triggering MD013 rule violations
<!-- markdownlint-enable MD013 -->
```

#### Prettier Ignore
```markdown
<!-- prettier-ignore -->
This     has     intentional     bad     formatting
<!-- prettier-ignore-end -->
```

#### Codespell Ignore
```markdown
<!-- codespell-ignore -->
This text has seperate errors that should not be corrected automatically
<!-- codespell-ignore-end -->
```

### 2. Documentation Examples

#### Bad Example Sections (Teaching)
```markdown
<!-- lint-example:bad -->
```javascript
// ❌ BAD: Don't do this
function   badFormatting(  ){
    console.log("This is intentionally bad")
}
```
<!-- lint-example:end -->
```

#### Teaching Mode (Learning Materials)
```markdown
<!-- teaching-mode -->
### Exercise: Fix These Errors

The following has intentional errors:
- seperate (should be separate)
- occured (should be occurred)
<!-- teaching-mode:end -->
```

#### Historical Preservation
```markdown
<!-- preserve-original -->
This section maintains original formatting from legacy documentation
that we want to preserve exactly as-is.
<!-- preserve-original:end -->
```

## Commands

### Enhanced Linting with Exception Support

```bash
# Standard linting (respects all exceptions)
./scripts/linting/lint-files.sh README.md

# Show exception details during processing
./scripts/linting/lint-files.sh --show-exceptions README.md

# Validate exception markers are properly closed
./scripts/linting/lint-files.sh --validate-exceptions README.md

# Show what sections were skipped
./scripts/linting/lint-files.sh --show-skipped README.md
```

### Makefile Targets

```bash
# Standard linting with exception handling
make lint

# Show exception processing details  
make lint-with-exceptions

# Validate exception marker pairs
make lint-validate-exceptions

# Show skipped sections during linting
make lint-show-skipped
```

## How It Works

### Exception Processing Pipeline

1. **Detection**: System scans for exception markers in files
2. **Filtering**: Creates temporary versions with exception sections removed/modified
3. **Linting**: Standard tools process the filtered content
4. **Reporting**: Shows what was skipped and any remaining issues

### Exception Section Handling

- **Bad Examples**: Content between `lint-example:bad` and `lint-example:end` is removed during linting
- **Teaching Mode**: Content in `teaching-mode` sections is skipped entirely
- **Preserve Original**: Historical content is excluded from processing
- **Inline Exceptions**: Standard tool-specific ignore patterns are respected

### Validation System

The system validates that exception markers are properly paired:

- `markdownlint-disable` must have corresponding `markdownlint-enable`
- `teaching-mode` must have corresponding `teaching-mode:end`
- `lint-example:bad` must have corresponding `lint-example:end`

## Example File with Exceptions

See `dev-tools/examples/linting-exceptions.md` for a comprehensive example showing all exception types in action.

## Best Practices

### When to Use Exceptions

1. **Documentation examples** showing what NOT to do
2. **Teaching materials** with intentional errors for learning
3. **Historical preservation** of legacy formatting
4. **Temporary workarounds** while fixing complex issues

### Exception Hygiene

1. **Always close markers** - use validation to ensure pairs match
2. **Be specific** - use targeted exceptions rather than broad ignores
3. **Document reasons** - comment why exceptions are needed
4. **Regular review** - audit exceptions to see if still necessary

### Example: Proper Exception Usage

```markdown
<!-- lint-example:bad -->
# ❌ Common Markdown Mistake

This shows what happens when you don't close code blocks properly:

```bash
echo "This code block is not closed properly
<!-- lint-example:end -->

The above example intentionally contains errors for teaching purposes.
Regular content here will be linted normally.
```

## Integration with DOH Commands

### Pre-commit Hooks

The enhanced pre-commit hook (`scripts/git/hooks/pre-commit-new`) uses the same exception handling system:

```bash
# Install enhanced pre-commit hook with exception support
ln -sf ../../scripts/git/hooks/pre-commit-new .git/hooks/pre-commit
```

### Command Integration

All `/dd:*` commands that use linting will respect exceptions:

- `/dd:lint` - Direct linting with exception support
- `/dd:commit` - Pre-commit validation respects exceptions
- File modification workflows handle exceptions correctly

## Troubleshooting

### Common Issues

**"Mismatched markers" warnings:**
- Ensure every opening marker has a closing marker
- Check marker spelling and syntax exactly
- Use `--validate-exceptions` to identify problems

**"Sections not being skipped:**
- Verify marker syntax matches examples exactly
- Ensure no extra spaces in marker comments
- Check file encoding is UTF-8

**"Linting still catching exception content":**
- Verify section type (some exceptions remove content, others just mark it)
- Check if the specific linting rule is configured to respect markers
- Use `--show-exceptions` to see what was detected

### Debugging Exception Processing

```bash
# See detailed exception processing
./scripts/linting/lint-files.sh --show-exceptions --validate-exceptions \
  problem-file.md

# Check what the system actually processes
ls -la problem-file.md.lint-temp  # Temporary file shows filtered content
```

## Implementation Details

The exception handling system is implemented in:

- **Core Logic**: `dev-tools/lib/lint-core.sh` - Exception detection and filtering
- **Main Script**: `scripts/linting/lint-files.sh` - Command-line interface
- **Pre-commit**: `scripts/git/hooks/pre-commit-new` - Git integration
- **Makefile**: Enhanced targets for exception-aware linting

This provides a comprehensive, intelligent linting system that can handle complex documentation and code examples while maintaining strict quality standards for regular content.