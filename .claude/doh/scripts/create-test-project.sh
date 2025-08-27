#!/bin/bash
# Create DOH Test Project - Sets up dummy project for testing T013 utilities
# Usage: create-test-project.sh [project_name] [--populate] [--edge-cases]

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOH_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Configuration
TEST_PROJECT_NAME="${1:-doh-test-project}"
TEST_PROJECT_ROOT="/tmp/$TEST_PROJECT_NAME"
POPULATE_DATA=false
EDGE_CASES=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse arguments
shift || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --populate)
            POPULATE_DATA=true
            shift
            ;;
        --edge-cases)
            EDGE_CASES=true
            shift
            ;;
        --help)
            cat << EOF
Usage: $0 [project_name] [--populate] [--edge-cases]

Options:
  project_name    Name of test project (default: doh-test-project)
  --populate      Populate with sample tasks, epics, features
  --edge-cases    Create edge cases for testing (corrupted files, etc.)

Examples:
  $0                          # Basic test project
  $0 my-test --populate       # Test project with sample data
  $0 stress-test --populate --edge-cases  # Full test suite

EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Create test project
create_test_project() {
    echo -e "${BLUE}🏗️  Creating test project: $TEST_PROJECT_NAME${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Clean up existing test project
    if [[ -d "$TEST_PROJECT_ROOT" ]]; then
        echo -e "${YELLOW}⚠️  Removing existing test project${NC}"
        rm -rf "$TEST_PROJECT_ROOT"
    fi
    
    # Create project directory
    mkdir -p "$TEST_PROJECT_ROOT"
    cd "$TEST_PROJECT_ROOT"
    
    # Initialize git
    echo -e "${BLUE}📦 Initializing git repository${NC}"
    git init --quiet
    echo "# $TEST_PROJECT_NAME" > README.md
    echo "Test project for DOH system validation" >> README.md
    git add README.md
    git commit -m "Initial commit" --quiet
    
    # Create basic project structure
    echo -e "${BLUE}📁 Creating project structure${NC}"
    mkdir -p src/{components,services,utils}
    mkdir -p tests/{unit,integration}
    mkdir -p docs
    
    # Create sample files
    cat > src/index.js << 'EOF'
// Main application entry point
console.log("DOH Test Project");
EOF
    
    cat > package.json << EOF
{
  "name": "$TEST_PROJECT_NAME",
  "version": "1.0.0",
  "description": "DOH test project for validation",
  "main": "src/index.js",
  "scripts": {
    "test": "echo \"No tests yet\"",
    "dev": "node src/index.js"
  }
}
EOF
    
    echo -e "${GREEN}✅ Basic project structure created${NC}"
}

# Initialize DOH in test project
initialize_doh() {
    echo -e "${BLUE}🚀 Initializing DOH system${NC}"
    
    # Run doh-init.sh
    if [[ -f "$SCRIPT_DIR/doh-init.sh" ]]; then
        cd "$TEST_PROJECT_ROOT"
        "$SCRIPT_DIR/doh-init.sh"
    else
        echo -e "${RED}❌ doh-init.sh not found${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ DOH initialized successfully${NC}"
}

# Populate with sample data
populate_sample_data() {
    if [[ "$POPULATE_DATA" != "true" ]]; then
        return
    fi
    
    echo -e "${BLUE}📝 Populating sample data${NC}"
    
    cd "$TEST_PROJECT_ROOT"
    
    # Update project-index.json with sample data
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Create sample epics
    cat > .doh/epics/epic1.md << 'EOF'
# Epic !1 - User Authentication System

**Status**: Active
**Created**: 2025-08-27
**Priority**: High

## Description
Implement complete user authentication system with login, registration, and password reset.

## Tasks
- !101: Create login form
- !102: Implement JWT tokens  
- !103: Add password reset flow
EOF
    
    cat > .doh/epics/epic2.md << 'EOF'
# Epic !2 - API Development

**Status**: Planning
**Created**: 2025-08-27
**Priority**: Medium

## Description
Build REST API endpoints for all major features.

## Tasks
- !201: Design API schema
- !202: Implement CRUD operations
- !203: Add API documentation
EOF
    
    # Create sample tasks
    mkdir -p .doh/tasks
    
    cat > .doh/tasks/task101.md << 'EOF'
# Task !101 - Create login form

**Status**: In Progress
**Parent Epic**: !1
**Assigned**: Developer A
**Created**: 2025-08-27

## Description
Create responsive login form with validation.

## Acceptance Criteria
- [ ] Email validation
- [ ] Password minimum requirements
- [ ] Remember me checkbox
- [ ] Error message display
EOF
    
    cat > .doh/tasks/task102.md << 'EOF'
# Task !102 - Implement JWT tokens

**Status**: Pending
**Parent Epic**: !1
**Created**: 2025-08-27

## Description
Implement JWT token generation and validation.
EOF
    
    # Update project-index.json with the sample data
    if command -v jq >/dev/null 2>&1; then
        jq '.items.epics["1"] = {
            "id": "1",
            "title": "User Authentication System",
            "description": "Complete authentication system",
            "status": "active",
            "created_at": "'$current_time'",
            "file_path": "epics/epic1.md"
        } | .items.epics["2"] = {
            "id": "2", 
            "title": "API Development",
            "description": "REST API implementation",
            "status": "planning",
            "created_at": "'$current_time'",
            "file_path": "epics/epic2.md"
        } | .items.tasks["101"] = {
            "id": "101",
            "title": "Create login form",
            "status": "in_progress",
            "parent_epic": "1",
            "created_at": "'$current_time'",
            "file_path": "tasks/task101.md"
        } | .items.tasks["102"] = {
            "id": "102",
            "title": "Implement JWT tokens",
            "status": "pending",
            "parent_epic": "1", 
            "created_at": "'$current_time'",
            "file_path": "tasks/task102.md"
        } | .counters.next_task_id = 103 | .counters.next_epic_id = 3' \
        .doh/project-index.json > .doh/project-index.json.tmp
        
        mv .doh/project-index.json.tmp .doh/project-index.json
        
        echo -e "${GREEN}✅ Added 2 epics and 2 tasks${NC}"
    else
        echo -e "${YELLOW}⚠️  jq not found - skipping JSON update${NC}"
    fi
    
    # Create some features
    mkdir -p .doh/features
    
    cat > .doh/features/feature1.md << 'EOF'
# Feature !501 - Dark Mode Support

**Status**: Completed
**Parent Epic**: !2
**Created**: 2025-08-27

## Description
Add dark mode toggle to application UI.
EOF
    
    # Add to project-index.json
    if command -v jq >/dev/null 2>&1; then
        jq '.items.features["501"] = {
            "id": "501",
            "title": "Dark Mode Support",
            "status": "completed",
            "parent_epic": "2",
            "created_at": "'$current_time'",
            "file_path": "features/feature1.md"
        } | .counters.next_feature_id = 502' \
        .doh/project-index.json > .doh/project-index.json.tmp
        
        mv .doh/project-index.json.tmp .doh/project-index.json
        
        echo -e "${GREEN}✅ Added 1 feature${NC}"
    fi
}

# Create edge cases for testing
create_edge_cases() {
    if [[ "$EDGE_CASES" != "true" ]]; then
        return
    fi
    
    echo -e "${BLUE}⚠️  Creating edge cases for testing${NC}"
    
    cd "$TEST_PROJECT_ROOT/.doh"
    
    # 1. Create corrupted JSON file
    echo '{"corrupted": json file}' > corrupted.json
    echo -e "${YELLOW}  Created corrupted.json${NC}"
    
    # 2. Create empty JSON file
    echo '' > empty.json
    echo -e "${YELLOW}  Created empty.json${NC}"
    
    # 3. Create large dataset for performance testing
    if command -v jq >/dev/null 2>&1; then
        # Generate 100 tasks for performance testing
        local large_tasks='{}'
        for i in {1000..1099}; do
            large_tasks=$(echo "$large_tasks" | jq --arg id "$i" --arg title "Task $i" \
                '.[$id] = {"id": $id, "title": $title, "status": "pending"}')
        done
        
        jq --argjson tasks "$large_tasks" '.items.tasks += $tasks | .counters.next_task_id = 1100' \
            project-index.json > project-index.json.tmp
        mv project-index.json.tmp project-index.json
        
        echo -e "${YELLOW}  Added 100 tasks for performance testing${NC}"
    fi
    
    # 4. Create file with special characters
    cat > "tasks/task-with-special-chars-!@#.md" << 'EOF'
# Task with special chars !@#$%

Testing special character handling
EOF
    echo -e "${YELLOW}  Created file with special characters${NC}"
    
    # 5. Create circular dependency
    if command -v jq >/dev/null 2>&1; then
        jq '.dependency_graph = {
            "101": ["102"],
            "102": ["103"],
            "103": ["101"]
        }' project-index.json > project-index.json.tmp
        mv project-index.json.tmp project-index.json
        
        echo -e "${YELLOW}  Created circular dependency for testing${NC}"
    fi
    
    # 6. Create symlink for path resolution testing
    ln -s "$TEST_PROJECT_ROOT" "/tmp/doh-test-symlink"
    echo -e "${YELLOW}  Created symlink at /tmp/doh-test-symlink${NC}"
    
    echo -e "${GREEN}✅ Edge cases created${NC}"
}

# Display test project info
display_info() {
    echo
    echo -e "${GREEN}🎉 Test project created successfully!${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${BLUE}📍 Location:${NC} $TEST_PROJECT_ROOT"
    
    if [[ -L "/tmp/doh-test-symlink" ]]; then
        echo -e "${BLUE}🔗 Symlink:${NC} /tmp/doh-test-symlink"
    fi
    
    echo -e "${BLUE}📊 Contents:${NC}"
    
    # Count items if jq is available
    if command -v jq >/dev/null 2>&1 && [[ -f "$TEST_PROJECT_ROOT/.doh/project-index.json" ]]; then
        local task_count=$(jq '.items.tasks | length' "$TEST_PROJECT_ROOT/.doh/project-index.json")
        local epic_count=$(jq '.items.epics | length' "$TEST_PROJECT_ROOT/.doh/project-index.json")
        local feature_count=$(jq '.items.features | length // 0' "$TEST_PROJECT_ROOT/.doh/project-index.json")
        
        echo "  - Epics: $epic_count"
        echo "  - Tasks: $task_count"
        echo "  - Features: $feature_count"
    fi
    
    if [[ "$EDGE_CASES" == "true" ]]; then
        echo -e "${YELLOW}  - Edge cases created for testing${NC}"
    fi
    
    echo
    echo -e "${BLUE}🧪 To test bash utilities:${NC}"
    echo "  cd $TEST_PROJECT_ROOT"
    echo "  $SCRIPT_DIR/test-bash-utilities.sh"
    echo
    echo -e "${BLUE}⚡ To run benchmarks:${NC}"
    echo "  cd $TEST_PROJECT_ROOT"
    echo "  $SCRIPT_DIR/benchmark-operations.sh"
    echo
    echo -e "${BLUE}🧹 To clean up:${NC}"
    echo "  rm -rf $TEST_PROJECT_ROOT /tmp/doh-test-symlink"
}

# Main execution
main() {
    echo -e "${GREEN}🧪 DOH Test Project Creator${NC}"
    echo "================================"
    echo
    
    # Create test project
    create_test_project
    
    # Initialize DOH
    initialize_doh
    
    # Populate sample data if requested
    populate_sample_data
    
    # Create edge cases if requested
    create_edge_cases
    
    # Display info
    display_info
}

# Run main
main