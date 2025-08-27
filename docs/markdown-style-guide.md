# DOH Markdown Style Guide

**Purpose**: Consistent, professional documentation quality across the DOH system

## Configuration

DOH uses **markdownlint-cli** with custom configuration at `dev-tools/linters/.markdownlint.json`.

### Current Rules

```json
{
  "default": true,
  "MD007": { "indent": 4 },
  "MD013": { "line_length": 120 },
  "MD024": { "allow_different_nesting": true },
  "MD033": { "allowed_elements": ["br", "details", "summary"] },
  "MD041": false
}
```

## Style Standards

### Headers

- **Consistent spacing**: Always use `# Header` (space after #)
- **Hierarchy**: Follow logical h1 → h2 → h3 progression
- **Unique headings**: Avoid duplicate headings in same document
- **Exception**: Duplicate headings allowed at different nesting levels (MD024 override)

### Line Length

- **Maximum**: 120 characters per line
- **Rationale**: Balance readability with modern screen widths
- **Breaking**: Break at natural points (commas, conjunctions, sentence boundaries)
- **Code blocks**: Long code lines acceptable when necessary

### Lists

- **Indentation**: 4 spaces for nested items (MD007 setting)
- **Bullet consistency**: Use `-` for unordered lists
- **Numbered lists**: Start with `1.` for each section
- **Spacing**: Blank line before/after lists

### Code Blocks

- **Language specification**: Always specify language for fenced code blocks

  ````markdown
  ```bash
  echo "Good - has language"
  ```
  ````

  ````text
  echo "Bad - no language specified"
  ```text

  ````

  ```text

  ```text

### Links

- **Internal links**: Use relative paths
- **External links**: Include full URLs
- **Reference links**: Use for repeated URLs
- **Validation**: Ensure internal links remain valid

### HTML Elements

- **Allowed**: `<br>`, `<details>`, `<summary>` (MD033 override)
- **Usage**: Only when markdown syntax insufficient
- **Rationale**: Needed for complex documentation layouts

### File Structure

- **Title requirement**: No requirement for H1 as first line (MD041 disabled)
- **Flexibility**: Documents can start with metadata, warnings, or other content
- **Ending**: Single trailing newline

## DOH-Specific Conventions

### Task References

- **Format**: `T###` for TODO task references
- **Links**: Link to TODO.md when referencing tasks
- **Status**: Use ✅ for completed, 🟡 for in progress, ❌ for blocked

### Version References

- **Current**: Always use current development version (1.4.0-dev)
- **Examples**: Update JSON examples to reflect current version
- **Consistency**: Maintain version consistency across all docs

### Code Examples

- **DOH commands**: Always use `/doh:command` format
- **Paths**: Use `project/` for generic examples, specific paths for DOH system
- **Context**: Provide sufficient context for examples

### Documentation Sections

- **Headers**: Use consistent section structure across similar documents
- **Order**: Purpose → Usage → Examples → Implementation → Integration
- **Cross-references**: Link to related documentation

## Commands

### Local Development

```bash
# Check all markdown files
make lint

# Auto-fix markdown issues
make lint-fix

# Show non-fixable issues
make lint-manual
```

### npm Scripts

```bash
# Direct markdownlint usage
npm run lint:md
npm run lint:md:fix

# Manual execution
npx markdownlint --config dev-tools/linters/.markdownlint.json *.md docs/ analysis/
```

## Pre-commit Integration

DOH includes pre-commit hooks that automatically check markdown quality:

- **Automatic**: Runs on `git commit`
- **Blocking**: Prevents commits with markdown errors
- **Override**: Use `git commit --no-verify` for urgent commits (not recommended)

## Common Issues & Solutions

### MD007 - List Indentation

**Issue**: Nested list items not indented 4 spaces

```markdown
- Item 1
  - Wrong (2 spaces)
    - Also wrong (still 2 space increment)

- Item 1
  - Correct (4 spaces)
    - Correct (8 spaces total)
```

### MD013 - Line Length

**Issue**: Lines exceed 120 characters **Solution**: Break at natural points, preserve meaning

```markdown
# Too long

This is an extremely long sentence that exceeds the 120 character limit and should be broken into multiple lines for
better readability and maintainability.

# Better

This is an extremely long sentence that exceeds the 120 character limit and should be broken into multiple lines for
better readability and maintainability.
```

### MD024 - Duplicate Headings

**Issue**: Same heading text appears multiple times **Solution**: Make headings unique or use different nesting

```markdown
# Bad

## Examples

### User Examples

## Examples (appears again)

# Good

## Usage Examples

### User Examples

## Implementation Examples
```

### MD033 - HTML Elements

**Issue**: HTML elements not in allowed list **Solution**: Use allowed elements or markdown alternatives

```markdown
# Allowed

<details>
<summary>Click to expand</summary>
Content here
</details>

# Not allowed - use markdown

**Bold text** instead of <strong>Bold text</strong>
```

### MD040 - Fenced Code Language

**Issue**: Code blocks without language specification

````markdown
## Bad

```text
echo "no language"
```
````

## Good

```bash
echo "has language"
```text

```text

## Integration with DOH Workflow

### Development Process

1. **Write**: Create or edit markdown files
2. **Fix**: Run `make lint-fix` for automatic corrections
3. **Manual**: Run `make lint-manual` for remaining issues
4. **Commit**: Pre-commit hooks validate quality
5. **Iterate**: Fix any blocking issues

### Quality Gates

- **Local development**: `make lint` before committing
- **Pre-commit**: Automatic validation on git commit
- **Future**: CI/CD integration for pull requests

### File Coverage

Linting applies to all markdown files:
- **Root**: `*.md` (README, TODO, CHANGELOG, etc.)
- **Documentation**: `docs/**/*.md`
- **Analysis**: `analysis/**/*.md`
- **Commands**: `.claude/commands/**/*.md`

## Benefits

- **Consistency**: Uniform documentation style across contributors
- **Quality**: Catch syntax errors and formatting issues
- **Professionalism**: Clean, readable documentation for distribution
- **Automation**: Reduce manual review burden
- **Standards**: Enforce DOH documentation quality standards

## Troubleshooting

### Common Setup Issues

**markdownlint not found**: Run `npm install` to install dependencies
**Config not found**: Ensure `dev-tools/linters/.markdownlint.json` exists
**Rules not applying**: Check config file syntax and path references

### Performance

**Large files**: Linting may be slow on very large markdown files
**Many files**: Consider targeted linting for specific directories
**CI/CD**: May need timeout adjustments for comprehensive linting

This style guide ensures DOH maintains professional, consistent documentation quality that reflects well on the
system's overall quality and attention to detail.
```
