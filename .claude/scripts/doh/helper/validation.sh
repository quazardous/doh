#!/bin/bash

# DOH Validation Helper
# Helper for system validation operations

# Source core library dependencies
source "${DOH_ROOT}/.claude/scripts/doh/lib/doh.sh"
source "${DOH_ROOT}/.claude/scripts/doh/lib/frontmatter.sh"

# @description Perform comprehensive DOH system validation
# @stdout Validation report with errors, warnings, and health status
# @stderr Error messages
# @exitcode 0 If system is healthy (no errors/warnings/invalid files)
# @exitcode 1 If system has issues
helper_validation_validate_system() {
    local project_root
    project_root=$(doh_project_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "🔍 Validating DOH System"
    echo "======================="
    echo ""

    local errors=0 warnings=0 invalid=0

    # Check directory structure
    echo "📁 Directory Structure:"
    
    if [ -d "$project_root/.claude" ]; then
        echo "  ✅ .claude directory exists"
    else
        echo "  ❌ .claude directory missing"
        ((errors++))
    fi
    
    if [ -d "$doh_dir/prds" ]; then
        echo "  ✅ PRDs directory exists"
    else
        echo "  ⚠️ PRDs directory missing"
        ((warnings++))
    fi
    
    if [ -d "$doh_dir/epics" ]; then
        echo "  ✅ Epics directory exists"
    else
        echo "  ⚠️ Epics directory missing"
        ((warnings++))
    fi
    
    if [ -d "$project_root/.claude/rules" ]; then
        echo "  ✅ Rules directory exists"
    else
        echo "  ⚠️ Rules directory missing"
        ((warnings++))
    fi
    
    echo ""

    # Check for orphaned files
    echo "🗂️ Data Integrity:"

    # Check epics have epic.md files
    find "$doh_dir/epics" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | while read -r epic_dir; do
        if [ -d "$epic_dir" ] && [ ! -f "$epic_dir/epic.md" ]; then
            echo "  ⚠️ Missing epic.md in $(basename "$epic_dir")"
            ((warnings++))
        fi
    done

    # Check for tasks without epics
    local orphaned_count
    orphaned_count=$(find "$project_root/.claude" -name "[0-9]*.md" -not -path "$doh_dir/epics/*/*" 2>/dev/null | wc -l)
    if [ "$orphaned_count" -gt 0 ]; then
        echo "  ⚠️ Found $orphaned_count orphaned task files"
        ((warnings++))
    fi

    echo ""
    
    # Check for broken references
    echo "🔗 Reference Check:"
    
    local ref_warnings=0
    find "$doh_dir/epics" -name "[0-9]*.md" -type f 2>/dev/null | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local depends_on
            depends_on=$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null)
            
            if [ -n "$depends_on" ] && [ "$depends_on" != "null" ] && [ "$depends_on" != "" ]; then
                local epic_dir
                epic_dir=$(dirname "$task_file")
                
                # Handle array format [dep1, dep2] or simple dep
                local deps
                deps=$(echo "$depends_on" | sed 's/\[//g' | sed 's/\]//g' | sed 's/,/ /g' | tr -d '"'"'")
                
                for dep in $deps; do
                    dep=$(echo "$dep" | xargs)  # trim whitespace
                    if [ -n "$dep" ] && [ ! -f "$epic_dir/${dep}.md" ]; then
                        echo "  ⚠️ Task $(basename "$task_file" .md) references missing task: $dep"
                        ((ref_warnings++))
                    fi
                done
            fi
        fi
    done
    
    warnings=$((warnings + ref_warnings))
    
    if [ $ref_warnings -eq 0 ]; then
        echo "  ✅ All references valid"
    fi

    echo ""
    
    # Check frontmatter using frontmatter library
    echo "📝 Frontmatter Validation:"
    
    local fm_invalid=0
    find "$doh_dir" -name "*.md" 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            if ! frontmatter_has "$file"; then
                echo "  ⚠️ Missing frontmatter: $(realpath --relative-to="$project_root" "$file")"
                fm_invalid=$((fm_invalid + 1))
            elif ! frontmatter_validate "$file"; then
                echo "  ⚠️ Invalid frontmatter: $(realpath --relative-to="$project_root" "$file")"
                fm_invalid=$((fm_invalid + 1))
            fi
        fi
    done

    invalid=$((invalid + fm_invalid))
    
    if [ $fm_invalid -eq 0 ]; then
        echo "  ✅ All files have valid frontmatter"
    fi

    echo ""
    
    # Summary
    echo "📊 Validation Summary:"
    echo "  Errors: $errors"
    echo "  Warnings: $warnings"
    echo "  Invalid files: $invalid"

    if [ $errors -eq 0 ] && [ $warnings -eq 0 ] && [ $invalid -eq 0 ]; then
        echo ""
        echo "✅ System is healthy!"
        return 0
    else
        echo ""
        echo "💡 Run /doh:clean to fix some issues automatically"
        return 1
    fi
}

# @description Check directory structure validity
# @stdout Directory structure validation results
# @stderr Error messages
# @exitcode 0 If all required directories exist
# @exitcode 1 If critical directories missing
helper_validation_check_directories() {
    local project_root
    project_root=$(doh_project_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    local errors=0

    echo "📁 Directory Structure Check:"
    
    # Critical directories
    if [ ! -d "$project_root/.claude" ]; then
        echo "  ❌ Missing .claude directory"
        ((errors++))
    fi
    
    if [ ! -d "$doh_dir" ]; then
        echo "  ❌ Missing DOH directory"
        ((errors++))
    fi
    
    # Optional but expected directories
    [ -d "$doh_dir/prds" ] || echo "  ⚠️ Missing prds directory"
    [ -d "$doh_dir/epics" ] || echo "  ⚠️ Missing epics directory"
    [ -d "$project_root/.claude/rules" ] || echo "  ⚠️ Missing .claude/rules directory"
    
    if [ $errors -eq 0 ]; then
        echo "  ✅ Directory structure is valid"
        return 0
    else
        return 1
    fi
}

# @description Check frontmatter validity across project files
# @stdout Frontmatter validation results
# @stderr Error messages
# @exitcode 0 If all files have valid frontmatter
# @exitcode 1 If files have invalid or missing frontmatter
helper_validation_check_frontmatter() {
    local project_root
    project_root=$(doh_project_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "📝 Frontmatter Validation:"
    
    local invalid_count=0
    
    find "$doh_dir" -name "*.md" 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            if ! frontmatter_has "$file"; then
                echo "  ⚠️ Missing frontmatter: $(realpath --relative-to="$project_root" "$file")"
                ((invalid_count++))
            elif ! frontmatter_validate "$file"; then
                echo "  ⚠️ Invalid frontmatter: $(realpath --relative-to="$project_root" "$file")"
                ((invalid_count++))
            fi
        fi
    done
    
    if [ $invalid_count -eq 0 ]; then
        echo "  ✅ All files have valid frontmatter"
        return 0
    else
        return 1
    fi
}

# @description Check for broken task references
# @stdout Reference validation results
# @stderr Error messages  
# @exitcode 0 If all references are valid
# @exitcode 1 If broken references found
helper_validation_check_references() {
    local project_root
    project_root=$(doh_project_root) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }

    echo "🔗 Reference Validation:"
    
    local broken_refs=0
    
    find "$doh_dir/epics" -name "[0-9]*.md" -type f 2>/dev/null | while read -r task_file; do
        if [ -f "$task_file" ]; then
            local depends_on
            depends_on=$(frontmatter_get_field "$task_file" "depends_on" 2>/dev/null)
            
            if [ -n "$depends_on" ] && [ "$depends_on" != "null" ] && [ "$depends_on" != "" ]; then
                local epic_dir task_name
                epic_dir=$(dirname "$task_file")
                task_name=$(basename "$task_file" .md)
                
                # Handle array format [dep1, dep2] or simple dep
                local deps
                deps=$(echo "$depends_on" | sed 's/\[//g' | sed 's/\]//g' | sed 's/,/ /g' | tr -d '"'"'")
                
                for dep in $deps; do
                    dep=$(echo "$dep" | xargs)  # trim whitespace
                    if [ -n "$dep" ] && [ ! -f "$epic_dir/${dep}.md" ]; then
                        echo "  ⚠️ Task $task_name references missing task: $dep"
                        ((broken_refs++))
                    fi
                done
            fi
        fi
    done
    
    if [ $broken_refs -eq 0 ]; then
        echo "  ✅ All task references are valid"
        return 0
    else
        return 1
    fi
}