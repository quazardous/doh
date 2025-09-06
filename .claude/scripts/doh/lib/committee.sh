#!/bin/bash

# DOH Committee Library (Minimal Version)
# Only contains functions actually used by helper and orchestrator

# Source core library dependencies  
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_COMMITTEE_LOADED:-}" ]] && return 0
DOH_LIB_COMMITTEE_LOADED=1

# =============================================================================
# SEED FILE MANAGEMENT (Used by helper/committee.sh)
# =============================================================================

# @description Create seed file for committee session
# @arg $1 string Feature name
# @arg $2 string Seed content
# @stdout Seed file path
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_create_seed() {
    local feature_name="$1"
    local content="$2"
    
    if [[ -z "$feature_name" || -z "$content" ]]; then
        echo "Error: Feature name and content required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local seed_file="$committee_dir/seed.md"
    
    # Create committee directory if it doesn't exist
    mkdir -p "$committee_dir" || {
        echo "Error: Failed to create committee directory" >&2
        return 1
    }
    
    # Write seed content
    echo "$content" > "$seed_file" || {
        echo "Error: Failed to write seed file" >&2
        return 1
    }
    
    echo "$seed_file"
    return 0
}

# @description Check if seed file exists for feature
# @arg $1 string Feature name
# @exitcode 0 If exists
# @exitcode 1 If not exists or error
committee_has_seed() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local seed_file="$doh_dir/committees/$feature_name/seed.md"
    
    [[ -f "$seed_file" ]]
}

# @description Update seed file for feature
# @arg $1 string Feature name
# @arg $2 string New content
# @exitcode 0 If successful
# @exitcode 1 If failed or seed doesn't exist
committee_update_seed() {
    local feature_name="$1"
    local content="$2"
    
    if [[ -z "$feature_name" || -z "$content" ]]; then
        echo "Error: Feature name and content required" >&2
        return 1
    fi
    
    if ! committee_has_seed "$feature_name"; then
        echo "Error: Seed file does not exist for feature: $feature_name" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local seed_file="$doh_dir/committees/$feature_name/seed.md"
    
    echo "$content" > "$seed_file" || {
        echo "Error: Failed to update seed file" >&2
        return 1
    }
    
    return 0
}

# @description Delete seed file for feature
# @arg $1 string Feature name
# @exitcode 0 If successful (even if file didn't exist)
# @exitcode 1 If failed
committee_delete_seed() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local seed_file="$doh_dir/committees/$feature_name/seed.md"
    
    if [[ -f "$seed_file" ]]; then
        rm "$seed_file" || {
            echo "Error: Failed to delete seed file" >&2
            return 1
        }
    fi
    
    return 0
}

# =============================================================================
# PRD TEMPLATE GENERATION (Used by orchestrator)
# =============================================================================

# @description Create final PRD template with frontmatter
# @arg $1 string Feature name
# @stdout Final PRD template content
committee_create_final_prd() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir committee_dir
    doh_dir=$(doh_project_dir)
    committee_dir="$doh_dir/committees/$feature_name"
    
    # Read seed for context if available
    local seed_content description target_version
    seed_content=$(cat "$committee_dir/seed.md" 2>/dev/null || echo "")
    description=$(echo "$seed_content" | grep "^description:" | cut -d' ' -f2- || echo "Committee-generated feature")
    target_version=$(echo "$seed_content" | grep "^target_version:" | cut -d' ' -f2 || echo "1.0.0")
    
    cat <<EOF
---
id: $feature_name
title: $(echo $feature_name | tr '-' ' ' | sed 's/\b\w/\U&/g')
description: $description
version: $target_version
status: pending
priority: high
complexity: high
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
updated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
type: new-feature
breaking_changes: true
author: Committee (4 specialized agents + CTO)
committee_session: $feature_name
convergence_level: high
---

# $(echo $feature_name | tr '-' ' ' | sed 's/\b\w/\U&/g')

## 🎯 Executive Summary

This PRD represents the collaborative output of a 4-agent committee workflow with CTO convergence analysis. The feature has achieved high cross-functional agreement and is ready for implementation.

**Committee Process:**
- **Round 1**: Initial drafting by DevOps, Lead Dev, UX, and Product Owner agents
- **Round 2**: Revision based on cross-agent feedback and ratings  
- **Convergence**: CTO analysis confirmed strong alignment

## 🏗️ Technical Architecture

Based on DevOps Architect and Lead Developer convergence:

### System Design
- Multi-tenant architecture with proper isolation
- Scalable approach with proper infrastructure
- Security-first design principles
- Performance optimized for target user scale

### Technology Stack
- Backend: [TO BE SPECIFIED BY CTO]
- Frontend: [TO BE SPECIFIED BY CTO]
- Database: [TO BE SPECIFIED BY CTO]
- Infrastructure: [TO BE SPECIFIED BY CTO]

## 🎨 User Experience

Based on UX Designer specifications:

### Design Principles
- Mobile-first responsive design
- Accessibility compliance (WCAG 2.1 AA)
- Intuitive user workflows
- Consistent design system

### User Journeys
- [TO BE SPECIFIED BY CTO]

## 💼 Business Requirements

Based on Product Owner analysis:

### Success Metrics
- [TO BE SPECIFIED BY CTO]

### Go-to-Market Strategy
- [TO BE SPECIFIED BY CTO]

## 🚀 Implementation Plan

### Development Phases
1. **Foundation Phase**: Core architecture and security
2. **Feature Phase**: Primary functionality development
3. **Enhancement Phase**: Advanced features and optimization
4. **Launch Phase**: Production deployment and monitoring

### Timeline
- **Phase 1**: Foundation (Months 1-2)
- **Phase 2**: Core Features (Months 3-4)
- **Phase 3**: Enhancement (Months 5-6)
- **Phase 4**: Launch (Month 7)

## 📊 Success Criteria

### Technical Metrics
- [TO BE SPECIFIED BY CTO]

### Business Metrics
- [TO BE SPECIFIED BY CTO]

## ⚠️ Risks and Mitigation

### Technical Risks
- [TO BE SPECIFIED BY CTO]

### Business Risks
- [TO BE SPECIFIED BY CTO]

## 🔄 Next Steps

1. **Epic Creation**: Use \`/doh:prd-parse $feature_name\` to break down into development tasks
2. **Team Assignment**: Allocate development resources based on technical requirements
3. **Timeline Planning**: Create detailed development schedule with milestones
4. **Stakeholder Communication**: Share PRD with relevant teams and stakeholders

---

*This PRD template was generated by DOH Committee system. CTO agent should fill in the [TO BE SPECIFIED BY CTO] sections based on committee analysis.*
EOF
}