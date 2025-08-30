# Linting Exception Examples

This document demonstrates various exception patterns for the DOH linting system.

## Standard Content (Will Be Linted)

This section follows all linting rules and will be processed normally.

- Proper formatting
- Correct spelling
- Appropriate line lengths

## Intentional Errors in Documentation

### Example 1: Bad Code Examples

<!-- lint-example:bad -->
```bash
# ❌ BAD: Don't do this
function   badFormatting(  ){
    echo "This line is intentionally very very very very very very very very very very very very very long to exceed character limits"
    # separate is misspelled on purpose
}
```
<!-- lint-example:end -->

```bash
# ✅ GOOD: Do this instead
function good_formatting() {
    echo "This is properly formatted"
    # separate is spelled correctly
}
```

### Example 2: Teaching Mode

<!-- teaching-mode -->
### Exercise: Find the Errors

The following text has intentional mistakes for learning purposes:
- seperate (should be separate)
- occured (should be occurred)
- receive (should be receive)

This line is intentionally way way way way way way way way way way way way way way way way way too long for demonstration purposes.
<!-- teaching-mode:end -->

### Example 3: Historical Preservation

<!-- preserve-original -->
This section maintains original formatting from legacy documentation that we want to preserve exactly as-is, including weird    spacing   and potential speling errors.
<!-- preserve-original:end -->

## Inline Exceptions

### Markdownlint Exceptions

<!-- markdownlint-disable MD013 -->
This line is extremely long and would normally violate the MD013 rule but is disabled for this specific section because we need to demonstrate exception handling.
<!-- markdownlint-enable MD013 -->

### Prettier Ignore

<!-- prettier-ignore -->
This     has     intentional     bad     formatting     that     prettier     should     not     fix.
<!-- prettier-ignore-end -->

### Codespell Ignore

<!-- codespell-ignore -->
This text has a seperate error that is intentionally left uncorrected for demonstration purposes.
<!-- codespell-ignore-end -->

## Normal Content Continues

After the exceptions, linting should resume normally and catch any real errors.