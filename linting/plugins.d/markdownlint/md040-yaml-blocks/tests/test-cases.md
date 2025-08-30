# Test Cases for MD040 YAML Blocks Plugin

This file contains test cases that should trigger MD040 errors and be resolved by the plugin.

## Test Case 1: Basic YAML Key-Value

```
key: value
another_key: another_value
```

## Test Case 2: YAML List

```
items:
  - first_item
  - second_item
  - third_item
```

## Test Case 3: YAML Document Separator

```
---
name: test
version: 1.0
---
```

## Test Case 4: Complex YAML Structure

```
database:
  host: localhost
  port: 5432
  credentials:
    username: user
    password: pass
services:
  - name: web
    port: 80
  - name: api
    port: 8080
```

## Test Case 5: Mixed Content (Should NOT be detected as YAML)

```
This is just text
Not YAML at all
```

## Expected Results

After plugin application:

- Cases 1-4: Should have `yaml` language added automatically
- Case 5: Should remain as plain text block (no language added)
