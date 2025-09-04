# DOH Test Skeleton Projects

This directory contains pre-built DOH project skeletons that are used as templates for test fixtures. Each skeleton is a complete DOH project structure that can be copied to test environments.

## Skeleton Architecture

### Directory Structure Mapping

The key insight of the skeleton system is that **skeleton structure directly mirrors the test environment structure**. This eliminates complex mapping and makes copying straightforward.

#### Real Project Structure
```
my-project/                    # Real project root
├── VERSION                    # Project version
├── .git/                     # Git repository
└── .doh/                     # DOH project data
    ├── epics/
    ├── prds/
    └── versions/
```

#### Test Environment Structure  
```
/tmp/doh.XXXXXX/              # Test container (DOH_TEST_CLEANUP_DIR)
├── VERSION                   # DOH_VERSION_FILE (project version)
├── global_doh/              # DOH_GLOBAL_DIR (workspace data)
└── project_doh/             # DOH_PROJECT_DIR (≡ .doh/)
    ├── epics/
    ├── prds/
    └── versions/
```

#### Skeleton Structure
```
skeleton-name/
├── VERSION                   # → /tmp/doh.XXXXXX/VERSION
├── project_doh/             # → /tmp/doh.XXXXXX/project_doh/ (DOH_PROJECT_DIR)
│   ├── epics/
│   ├── prds/
│   └── versions/
└── global_doh/              # → /tmp/doh.XXXXXX/global_doh/ (optional)
    ├── projects/
    └── caches/
```

### Key Design Principles

1. **Direct Mapping**: `cp -r skeleton/* container/` works without complex path manipulation
2. **Namespace Clarity**: `project_doh/` clearly indicates this is DOH project data (≡ `.doh/`)
3. **Extensible**: Can add `global_doh/` for tests needing global workspace data
4. **Isolation**: Each skeleton is completely self-contained
5. **Flexible Structure**: No elements are mandatory in a skeleton - an empty directory is a valid skeleton

### Why `project_doh/` instead of `.doh/`?

- **Test Clarity**: Makes it obvious this is test DOH data, not a real `.doh/` directory
- **Direct Mapping**: `project_doh/` maps directly to `DOH_PROJECT_DIR` environment variable
- **No Conflicts**: Avoids confusion with real `.doh/` directories during development
- **Extensible**: Consistent naming allows for `global_doh/`, `cache_doh/`, etc.

## Usage in Tests

The fixture system automatically handles skeleton copying:

```bash
# In your test file
source "$(dirname "${BASH_SOURCE[0]}")/../helpers/doh_fixtures.sh"

_tf_setup() {
    # Choose appropriate skeleton for your test needs
    _tff_create_helper_test_project "$DOH_PROJECT_DIR" >/dev/null
    _tff_setup_workspace_for_helpers
}
```

Available fixture functions in `doh_fixtures.sh`:
- `_tff_create_minimal_doh_project` - Basic empty structure
- `_tff_create_helper_test_project` - Complete helper testing data
- `_tff_create_sample_doh_project` - General testing samples
- `_tff_create_version_test_project` - Version-specific scenarios
- `_tff_create_cache_test_project` - Cache/registry testing data

## Skeleton Structure

Each skeleton can contain any combination of these elements that mirrors the test container exactly:

```
skeleton-name/
├── VERSION                    # Project version file (optional)
├── project_doh/              # DOH project structure ≡ .doh/ (optional)
│   ├── epics/                # Epic directories and files
│   ├── prds/                 # PRD files  
│   ├── versions/             # Version files
│   └── quick/                # Quick access files
└── global_doh/               # DOH global structure (optional)
    ├── projects/             # Workspace registry
    └── caches/               # DOH caches
```

**Structure Benefits**: 
- **Direct mapping**: Skeleton structure matches test environment exactly
- **Simple copy**: `cp -r skeleton/* container/` works directly  
- **Extensible**: Can add `global_doh/` for tests needing global DOH data
- **Clear separation**: Project vs global DOH data clearly distinguished
- **Minimal viable**: An empty skeleton directory is valid - tests can be completely isolated or build from scratch

## Maintenance

### Adding New Skeletons

1. Create new directory: `mkdir tests/fixtures/skl/new-skeleton`
2. Add any needed structure (VERSION, project_doh/, global_doh/) - **or leave empty for minimal tests**
3. Add corresponding `_tff_create_new_skeleton_project()` function in `doh_fixtures.sh`
4. Export the function
5. Document in this README

**Note**: A skeleton can be completely empty - this is useful for tests that need full isolation or want to build DOH structure programmatically during test setup.

### Modifying Skeletons

When modifying skeleton files:
- Ensure all frontmatter is valid and complete
- Use realistic dates and consistent metadata
- Test that the skeleton works with intended test scenarios
- Update documentation if structure changes

## Benefits of Skeleton Approach

- **Maintainability**: Test data lives in files, not inline strings
- **Reusability**: Same skeleton used across multiple tests
- **Consistency**: All tests using same skeleton get identical data
- **Version Control**: Test data changes are tracked in git
- **Debugging**: Easy to examine test data structure
- **Performance**: Fast copying vs. programmatic generation