# Markdown Quality Control System

**Purpose**: Complete markdown linting workflow for maintaining documentation quality  
**Target**: All DOH-DEV project documentation  
**Commands**: `make lint`, `make lint-fix`, `make lint-manual`

## 🔧 Quality Control Commands

### **Primary Commands**

- **`make lint`** - Run all linters (markdown + shell scripts)
- **`make lint-fix`** - Auto-correct markdown formatting issues
- **`make lint-manual`** - Show non-auto-fixable issues that need manual correction

### **Command Usage Pattern**

```bash
# Typical workflow
make lint-fix      # Auto-correct what can be fixed
make lint-manual   # Review what needs manual attention
# Fix manual issues
make lint          # Verify all issues resolved
```

## 📝 Quality Control Workflow

### **Step-by-Step Process**

1. **Write/Edit markdown** - Create or modify documentation
2. **Auto-fix** - Run `make lint-fix` to correct formatting automatically
3. **Manual fixes** - Run `make lint-manual` to see issues requiring manual attention
4. **Verify** - Run `make lint` to confirm all issues resolved
5. **Commit** - Pre-commit hooks automatically block commits with linting errors

### **Pre-commit Protection**

The pre-commit hook automatically runs markdown linting on staged files:

- ✅ **Passes** - Commit proceeds normally
- ❌ **Fails** - Commit blocked, fix issues first

## 🔍 Common Issues and Solutions

### **📏 Line Length (MD013)**

**Issue**: Lines exceed 120 character limit

**Solutions**:

- Keep lines under 120 characters (modern standard)
- Break extremely long sentences into multiple lines
- Split very long URLs or code examples when needed
- Break at natural points (commas, conjunctions)

**Example**:

```markdown
❌ This is an extremely long line that exceeds the 120 character limit and should be broken into multiple lines for
better readability and adherence to markdown standards.

✅ This is an extremely long line that exceeds the 120 character limit and should be broken into multiple lines for
better readability and adherence to markdown standards.
```

### **🔢 List Numbering (MD029)**

**Issue**: Inconsistent ordered list numbering

**Solutions**:

- Each ordered list should start with `1.`
- Use `1. 2. 3.` not `4. 5. 6.` in separate sections
- Restart numbering for each new list

**Example**:

```markdown
❌ Previous section ended with item 3 4. Next item 5. Another item

✅ Previous section ended with item 3

1. Next item
2. Another item
```

### **📑 Duplicate Headings (MD024)**

**Issue**: Multiple headings with identical text

**Solutions**:

- Make headings unique within the document
- Add context: `### Added (v1.2.0)` instead of just `### Added`
- Use different heading levels appropriately

**Example**:

```markdown
❌ Multiple "Installation" headings

## Installation

### Installation

✅ Contextual headings

## Installation

### Installation Requirements
```

### **📝 Emphasis as Heading (MD036)**

**Issue**: Bold text used instead of proper heading syntax

**Solutions**:

- Use `## Heading` instead of `**Bold text**` for headings
- Bold text should emphasize words, not create structure
- Reserve bold for inline emphasis within paragraphs

**Example**:

```markdown
❌ **Configuration Section** This explains configuration...

✅ ## Configuration Section This explains configuration...
```

### **🏷️ Code Block Language (MD040)**

**Issue**: Code blocks without language specification

**Solutions**:

- Always specify language: `bash` not just triple backticks
- Use `text` for non-code content
- Common languages: `bash`, `json`, `javascript`, `text`, `markdown`

**Example**:

```markdown
❌ Code block without language
```

echo "Hello World"

````

✅ Code block with language
```bash
echo "Hello World"
````

````

## 📋 Best Practices

### **Writing Workflow**

- **Preview before commit**: Run `make lint` locally
- **Auto-fix first**: Use `make lint-fix` to catch obvious issues
- **Manual review**: Use `make lint-manual` for remaining issues
- **Consistent structure**: Follow existing document patterns

### **Content Guidelines**

- **Short lines**: Break at natural points (commas, conjunctions)
- **Clear structure**: Use appropriate heading hierarchy
- **Code examples**: Always include language specification
- **Lists**: Maintain consistent numbering and formatting

### **Quality Standards**

- All markdown files must pass `make lint` before commit
- No manual intervention required for auto-fixable issues
- Manual issues must be resolved before merge
- Pre-commit hooks enforce these standards automatically

## 🚨 Common Errors and Quick Fixes

### **Line Length Issues**

**Quick Fix Pattern**:
```markdown
# Find long lines
make lint-manual | grep MD013

# Break at logical points
❌ Long sentence with multiple clauses that should be broken up for readability
✅ Long sentence with multiple clauses
that should be broken up for readability
````

### **List Formatting Issues**

**Quick Fix Pattern**:

```markdown
# Always restart numbering for new lists

Section A:

1. First item
2. Second item

Section B:

1. First item (not 3.)
2. Second item (not 4.)
```

### **Heading Conflicts**

**Quick Fix Pattern**:

```markdown
# Add context to duplicate headings

❌ ## Setup

## Setup

✅ ## Initial Setup

## Advanced Setup
```

## 🔧 Troubleshooting

### **Linting Failures**

**Common Issues**:

- Mixed line endings (use Unix LF)
- Trailing whitespace (auto-fixed by `make lint-fix`)
- Inconsistent indentation in lists

**Resolution Steps**:

1. Run `make lint-manual` to see specific issues
2. Fix issues manually based on error descriptions
3. Re-run `make lint` to verify resolution
4. Commit with confidence

### **Pre-commit Hook Issues**

**If commits are blocked**:

1. Don't bypass the hooks
2. Run the full lint workflow
3. Fix all identified issues
4. Retry the commit

**Recovery Commands**:

```bash
# Fix what can be automated
make lint-fix

# See what needs manual attention
make lint-manual

# Verify everything is clean
make lint
```

This quality control system ensures all DOH-DEV documentation maintains professional standards and consistency across
the entire project.
