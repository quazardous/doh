# DOH Tests

## Overview

This folder contains all test elements and validation for the /doh system.

## Structure

```bash
tests/
├── README.md           # This documentation
├── test_data.json      # Automated test scenarios
├── test_data.md        # Test documentation
└── scenarios/          # (Future) Domain-specific tests
    ├── sync/           # GitHub synchronization tests
    ├── commands/       # /doh command tests
    └── workflows/      # End-to-end workflow tests
```

## Files

### test_data.json

Main test scenarios for validation:

- Creating PRDs, Epics, Features, Tasks
- Hierarchical workflows
- Natural language commands
- Structure and traceability validation

### test_data.md

Complete test documentation:

- Scenario explanations
- Validation criteria
- Manual and automated usage
- Maintenance process

## Usage

### Manual Tests

```bash
# Execute individual scenarios
/doh:prd
/doh:prd-epics 1

# Verify results according to documentation
```

### Automated Tests (Future)

```bash
# Complete validation
/doh:test-all

# Specialized tests
/doh:test-sync
/doh:test-commands
/doh:test-workflows
```

## Extension

To add new tests:

1. Add scenarios in `test_data.json`
2. Document in `test_data.md`
3. Create specialized subfolders if necessary

---

## Maintenance

Test folder maintained up-to-date with /doh system evolution.