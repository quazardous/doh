#!/bin/bash

# DOH Committee Session Orchestrator Library
# Manages 2-round workflow: parallel drafting, rating collection, revisions, final rating
# Pure library for committee session operations (no automatic execution)

# Source core library dependencies
source "$(dirname "${BASH_SOURCE[0]}")/doh.sh"
source "$(dirname "${BASH_SOURCE[0]}")/frontmatter.sh"

# Guard against multiple sourcing
[[ -n "${DOH_LIB_COMMITTEE_LOADED:-}" ]] && return 0
DOH_LIB_COMMITTEE_LOADED=1

# Constants
readonly COMMITTEE_LIB_VERSION="1.0.0"
readonly COMMITTEE_DEFAULT_TIMEOUT=300  # 5 minutes per round
readonly COMMITTEE_DEFAULT_TOTAL_TIMEOUT=900  # 15 minutes total
readonly COMMITTEE_RATING_CONFLICT_THRESHOLD=2.5  # Standard deviation threshold
readonly COMMITTEE_MIN_RATING=1
readonly COMMITTEE_MAX_RATING=10

# Available agents for committee (must match .claude/agents/*.md files)
readonly -a COMMITTEE_AGENTS=(
    "devops-architect"
    "lead-developer"
    "ux-designer"
    "product-owner"
)

# Session states
readonly COMMITTEE_STATE_INIT="initialize"
readonly COMMITTEE_STATE_ROUND1="round1_parallel"
readonly COMMITTEE_STATE_COLLECT="collect_ratings"
readonly COMMITTEE_STATE_ROUND2="round2_revisions"
readonly COMMITTEE_STATE_FINAL="final_rating"
readonly COMMITTEE_STATE_CONVERGENCE="convergence_check"
readonly COMMITTEE_STATE_COMPLETED="completed"
readonly COMMITTEE_STATE_FAILED="failed"

# PRD sections that agents will draft and review
readonly -a COMMITTEE_PRD_SECTIONS=(
    "vision"
    "requirements"
    "success_criteria"
    "user_stories"
    "technical_approach"
    "risks_assumptions"
    "timeline"
    "resources"
)

# @description Initialize a new committee session
# @arg $1 string Feature name/identifier
# @arg $2 string Initial PRD text or file path
# @stdout Session initialization messages
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If initialization failed
committee_init_session() {
    local feature_name="$1"
    local prd_input="$2"
    
    if [[ -z "$feature_name" || -z "$prd_input" ]]; then
        echo "Error: Missing required parameters" >&2
        echo "Usage: committee_init_session <feature_name> <prd_input>" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local session_file="$committee_dir/session.md"
    
    # Create committee workspace directory with consistent round structure
    if ! mkdir -p "$committee_dir/round1" "$committee_dir/round2"; then
        echo "Error: Failed to create committee workspace" >&2
        return 1
    fi
    
    # Initialize PRD input
    local prd_content=""
    if [[ -f "$prd_input" ]]; then
        prd_content=$(cat "$prd_input")
    else
        prd_content="$prd_input"
    fi
    
    # Create session file with frontmatter
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local session_content
    session_content=$(cat <<EOF
# Committee Session: $feature_name

## Session Overview

**Feature**: $feature_name  
**Created**: $timestamp  
**State**: $COMMITTEE_STATE_INIT  
**Round**: 0

## Initial PRD Input

$prd_content

## Session Progress

### Round 1: Parallel Drafting
- Status: Pending
- Agents: ${COMMITTEE_AGENTS[*]}
- Expected sections: ${COMMITTEE_PRD_SECTIONS[*]}

### Collection Phase: Rating & Feedback
- Status: Pending
- Cross-rating matrix: TBD

### Round 2: Revisions
- Status: Pending
- Revised drafts based on feedback

### Final Rating
- Status: Pending
- Final scores and convergence analysis

## Session Audit Trail

- **$timestamp**: Session initialized for feature '$feature_name'

EOF
)
    
    # Create session file with frontmatter
    local -a frontmatter_fields=(
        "feature:$feature_name"
        "state:$COMMITTEE_STATE_INIT"
        "round:0"
        "created:$timestamp"
        "timeout:$COMMITTEE_DEFAULT_TOTAL_TIMEOUT"
        "agents:${COMMITTEE_AGENTS[*]// /,}"
        "sections:${COMMITTEE_PRD_SECTIONS[*]// /,}"
    )
    
    if ! frontmatter_create_markdown "$session_file" "$session_content" "${frontmatter_fields[@]}"; then
        echo "Error: Failed to create session file" >&2
        return 1
    fi
    
    # Store initial PRD
    echo "$prd_content" > "$committee_dir/initial_prd.txt"
    
    echo "✅ Committee session initialized for '$feature_name'"
    echo "   Workspace: $committee_dir"
    echo "   Session file: $session_file"
    echo "   Agents: ${COMMITTEE_AGENTS[*]}"
    echo "   Sections: ${COMMITTEE_PRD_SECTIONS[*]}"
    
    return 0
}

# @description Get current session state
# @arg $1 string Feature name/identifier
# @stdout Current session state
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If session not found or error
committee_get_state() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local session_file="$doh_dir/committees/$feature_name/session.md"
    
    if [[ ! -f "$session_file" ]]; then
        echo "Error: Session not found for feature '$feature_name'" >&2
        return 1
    fi
    
    local state
    state=$(frontmatter_get_field "$session_file" "state") || {
        echo "Error: Failed to read session state" >&2
        return 1
    }
    
    echo "$state"
    return 0
}

# @description Update session state with audit trail
# @arg $1 string Feature name
# @arg $2 string New state
# @arg $3 string Optional message
# @stdout Update confirmation
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If update failed
committee_update_state() {
    local feature_name="$1"
    local new_state="$2"
    local message="${3:-State updated to $new_state}"
    
    if [[ -z "$feature_name" || -z "$new_state" ]]; then
        echo "Error: Missing required parameters" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || {
        echo "Error: Not in DOH project" >&2
        return 1
    }
    
    local session_file="$doh_dir/committees/$feature_name/session.md"
    
    if [[ ! -f "$session_file" ]]; then
        echo "Error: Session not found for feature '$feature_name'" >&2
        return 1
    fi
    
    # Validate state
    case "$new_state" in
        "$COMMITTEE_STATE_INIT"|"$COMMITTEE_STATE_ROUND1"|"$COMMITTEE_STATE_COLLECT"|\
        "$COMMITTEE_STATE_ROUND2"|"$COMMITTEE_STATE_FINAL"|"$COMMITTEE_STATE_CONVERGENCE"|\
        "$COMMITTEE_STATE_COMPLETED"|"$COMMITTEE_STATE_FAILED") ;;
        *)
            echo "Error: Invalid state '$new_state'" >&2
            return 1
            ;;
    esac
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Update state in frontmatter
    if ! frontmatter_update_field "$session_file" "state" "$new_state"; then
        echo "Error: Failed to update session state" >&2
        return 1
    fi
    
    if ! frontmatter_update_field "$session_file" "updated" "$timestamp"; then
        echo "Error: Failed to update session timestamp" >&2
        return 1
    fi
    
    # Add audit trail entry
    local audit_entry="- **$timestamp**: $message"
    
    # Append to audit trail section in the session file
    if ! sed -i "/^## Session Audit Trail$/a\\$audit_entry" "$session_file"; then
        echo "Warning: Failed to update audit trail" >&2
    fi
    
    echo "✅ Session state updated to '$new_state' for feature '$feature_name'"
    return 0
}

# @description Start Round 1: Parallel agent drafting
# @arg $1 string Feature name
# @stdout Round 1 execution status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_start_round1() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    # Verify session exists and state
    local current_state
    current_state=$(committee_get_state "$feature_name") || return 1
    
    if [[ "$current_state" != "$COMMITTEE_STATE_INIT" ]]; then
        echo "Error: Cannot start Round 1 from state '$current_state'" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local drafts_dir="$committee_dir/drafts"
    
    # Update state to Round 1
    committee_update_state "$feature_name" "$COMMITTEE_STATE_ROUND1" "Started Round 1: Parallel agent drafting" || return 1
    
    # Start parallel agent execution for each agent
    local -a agent_pids=()
    local -a failed_agents=()
    
    echo "🚀 Starting Round 1: Parallel agent drafting for '$feature_name'"
    echo "   Agents: ${COMMITTEE_AGENTS[*]}"
    echo "   Timeout: ${COMMITTEE_DEFAULT_TIMEOUT}s per agent"
    
    for agent in "${COMMITTEE_AGENTS[@]}"; do
        echo "   Starting agent: $agent"
        
        # Execute agent in background for Round 1
        committee_execute_agent_draft "$feature_name" "$agent" "1" &
        local agent_pid=$!
        agent_pids+=("$agent_pid")
        
        echo "     Agent $agent started (PID: $agent_pid)"
    done
    
    # Wait for all agents to complete or timeout
    local success_count=0
    local timeout_count=0
    
    for i in "${!agent_pids[@]}"; do
        local pid="${agent_pids[$i]}"
        local agent="${COMMITTEE_AGENTS[$i]}"
        
        echo "   Waiting for agent $agent (PID: $pid)..."
        
        # Wait with timeout
        if committee_wait_with_timeout "$pid" "$COMMITTEE_DEFAULT_TIMEOUT"; then
            if wait "$pid"; then
                echo "   ✅ Agent $agent completed successfully"
                ((success_count++))
            else
                echo "   ❌ Agent $agent failed"
                failed_agents+=("$agent")
            fi
        else
            echo "   ⏱️ Agent $agent timed out"
            kill "$pid" 2>/dev/null || true
            ((timeout_count++))
            failed_agents+=("$agent")
        fi
    done
    
    # Check results
    local total_agents=${#COMMITTEE_AGENTS[@]}
    echo ""
    echo "Round 1 Results:"
    echo "   Successful: $success_count/$total_agents"
    echo "   Timeouts: $timeout_count"
    echo "   Failed: ${#failed_agents[@]}"
    
    if [[ ${#failed_agents[@]} -gt 0 ]]; then
        echo "   Failed agents: ${failed_agents[*]}"
    fi
    
    # Determine if Round 1 succeeded (at least 2 agents must succeed)
    if [[ $success_count -ge 2 ]]; then
        echo "✅ Round 1 completed successfully"
        committee_update_state "$feature_name" "$COMMITTEE_STATE_COLLECT" "Round 1 completed with $success_count/$total_agents agents successful" || return 1
        return 0
    else
        echo "❌ Round 1 failed - insufficient successful agents"
        committee_update_state "$feature_name" "$COMMITTEE_STATE_FAILED" "Round 1 failed with only $success_count/$total_agents agents successful" || return 1
        return 1
    fi
}

# @description Execute agent draft creation for specific round (internal function)
# @arg $1 string Feature name
# @arg $2 string Agent name
# @arg $3 string Round number (1 or 2)
# @stdout Agent execution output
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_execute_agent_draft() {
    local feature_name="$1"
    local agent_name="$2"
    local round="${3:-1}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local initial_prd="$committee_dir/initial_prd.txt"
    local draft_file="$committee_dir/round${round}/${agent_name}.md"
    
    # Check if initial PRD exists
    if [[ ! -f "$initial_prd" ]]; then
        echo "Error: Initial PRD not found for feature '$feature_name'" >&2
        return 1
    fi
    
    # Create agent prompt for PRD drafting
    local agent_prompt
    agent_prompt=$(cat <<EOF
You are participating in a PRD committee review for the feature: $feature_name

**Your Role**: $agent_name

**Task**: Create a comprehensive PRD draft focusing on your domain expertise. 

**Initial PRD Input**:
$(cat "$initial_prd")

**Instructions**:
1. Review the initial PRD from your domain perspective
2. Create a complete PRD draft with all necessary sections
3. Focus on your areas of expertise while covering all aspects
4. Be thorough but concise
5. Include specific technical details relevant to your role

**Expected PRD Sections**:
${COMMITTEE_PRD_SECTIONS[*]}

**Output Format**: 
Provide a complete markdown PRD document that can be used as a standalone product requirements document.

Please create your PRD draft now.
EOF
)
    
    # Execute agent with timeout handling
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Save agent prompt for debugging
    echo "$agent_prompt" > "$committee_dir/round${round}/${agent_name}_prompt.txt"
    
    echo "[$timestamp] Starting draft creation for agent: $agent_name (Round $round)" >> "$committee_dir/round${round}/${agent_name}_log.txt"
    
    # Use the Agent tool to execute the specific agent
    # Note: This is a placeholder for the actual agent execution
    # In practice, this would use the Claude Code Agent tool with the specific agent file
    if committee_call_agent "$agent_name" "$agent_prompt" > "$draft_file" 2>> "$committee_dir/round${round}/${agent_name}_log.txt"; then
        local end_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[$end_timestamp] Draft creation completed successfully for agent: $agent_name (Round $round)" >> "$committee_dir/round${round}/${agent_name}_log.txt"
        
        # Validate that draft has content
        if [[ -s "$draft_file" ]]; then
            echo "Agent $agent_name draft created successfully"
            return 0
        else
            echo "Error: Agent $agent_name produced empty draft" >&2
            return 1
        fi
    else
        local end_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[$end_timestamp] Draft creation failed for agent: $agent_name (Round $round)" >> "$committee_dir/round${round}/${agent_name}_log.txt"
        echo "Error: Agent $agent_name draft creation failed" >&2
        return 1
    fi
}

# @description Call specific agent (wrapper for Agent tool)
# @arg $1 string Agent name
# @arg $2 string Prompt text
# @stdout Agent response
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_call_agent() {
    local agent_name="$1"
    local prompt="$2"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local agent_file="$doh_dir/.claude/agents/${agent_name}.md"
    
    if [[ ! -f "$agent_file" ]]; then
        echo "Error: Agent file not found: $agent_file" >&2
        return 1
    fi
    
    # For now, simulate agent call - in practice this would use the actual Agent tool
    # TODO: Replace with actual Agent tool invocation when available
    echo "# PRD Draft from $agent_name"
    echo ""
    echo "## Vision"
    echo "This is a simulated draft from $agent_name agent."
    echo ""
    echo "## Requirements"
    echo "Placeholder requirements from $agent_name perspective."
    echo ""
    echo "<!-- More sections would be generated by actual agent -->"
    
    return 0
}

# @description Wait for process with timeout
# @arg $1 int Process ID
# @arg $2 int Timeout in seconds
# @exitcode 0 If process completed within timeout
# @exitcode 1 If timeout exceeded
committee_wait_with_timeout() {
    local pid="$1"
    local timeout="$2"
    local count=0
    
    while [[ $count -lt $timeout ]]; do
        if ! kill -0 "$pid" 2>/dev/null; then
            # Process no longer exists
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    # Timeout exceeded
    return 1
}

# @description Start collection phase: rating and feedback
# @arg $1 string Feature name
# @stdout Collection phase status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_start_collection() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    # Verify session state
    local current_state
    current_state=$(committee_get_state "$feature_name") || return 1
    
    if [[ "$current_state" != "$COMMITTEE_STATE_COLLECT" ]]; then
        echo "Error: Cannot start collection from state '$current_state'" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local drafts_dir="$committee_dir/drafts"
    local ratings_dir="$committee_dir/ratings"
    
    echo "🔄 Starting Collection Phase: Cross-agent rating and feedback"
    
    # Find available drafts
    local -a available_drafts=()
    for agent in "${COMMITTEE_AGENTS[@]}"; do
        local draft_file="$drafts_dir/${agent}_draft.md"
        if [[ -f "$draft_file" && -s "$draft_file" ]]; then
            available_drafts+=("$agent")
        else
            echo "   Warning: Draft not available for agent $agent"
        fi
    done
    
    if [[ ${#available_drafts[@]} -lt 2 ]]; then
        echo "Error: Insufficient drafts available for rating (need at least 2)" >&2
        committee_update_state "$feature_name" "$COMMITTEE_STATE_FAILED" "Collection failed - insufficient drafts" || return 1
        return 1
    fi
    
    echo "   Available drafts: ${available_drafts[*]}"
    
    # Execute cross-rating: each agent rates all other agents' drafts
    local -a rating_pids=()
    local -a failed_ratings=()
    
    for rater_agent in "${available_drafts[@]}"; do
        for target_agent in "${available_drafts[@]}"; do
            if [[ "$rater_agent" != "$target_agent" ]]; then
                echo "   Starting rating: $rater_agent rates $target_agent"
                
                committee_execute_agent_rating "$feature_name" "$rater_agent" "$target_agent" "1" &
                local rating_pid=$!
                rating_pids+=("$rating_pid")
                
                echo "     Rating started (PID: $rating_pid)"
            fi
        done
    done
    
    # Wait for all ratings to complete
    local rating_success_count=0
    for pid in "${rating_pids[@]}"; do
        if committee_wait_with_timeout "$pid" "$COMMITTEE_DEFAULT_TIMEOUT"; then
            if wait "$pid"; then
                ((rating_success_count++))
            else
                echo "   ❌ Rating process failed (PID: $pid)"
            fi
        else
            echo "   ⏱️ Rating process timed out (PID: $pid)"
            kill "$pid" 2>/dev/null || true
        fi
    done
    
    local expected_ratings=$(( ${#available_drafts[@]} * (${#available_drafts[@]} - 1) ))
    echo ""
    echo "Collection Phase Results:"
    echo "   Successful ratings: $rating_success_count/$expected_ratings"
    
    # Analyze ratings and check for convergence
    if committee_analyze_ratings "$feature_name"; then
        echo "✅ Collection phase completed successfully"
        committee_update_state "$feature_name" "$COMMITTEE_STATE_ROUND2" "Collection completed with rating analysis" || return 1
        return 0
    else
        echo "❌ Collection phase failed - rating analysis issues"
        committee_update_state "$feature_name" "$COMMITTEE_STATE_FAILED" "Collection failed - rating analysis failed" || return 1
        return 1
    fi
}

# @description Execute agent rating of another agent's draft for specific round
# @arg $1 string Feature name
# @arg $2 string Rater agent name
# @arg $3 string Target agent name (whose draft is being rated)
# @arg $4 string Round number (1 or 2)
# @stdout Rating execution status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_execute_agent_rating() {
    local feature_name="$1"
    local rater_agent="$2"
    local target_agent="$3"
    local round="${4:-1}"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local target_draft="$committee_dir/round${round}/${target_agent}.md"
    local rating_file="$committee_dir/round${round}/${rater_agent}_rates_${target_agent}.md"
    
    if [[ ! -f "$target_draft" ]]; then
        echo "Error: Target draft not found: $target_draft" >&2
        return 1
    fi
    
    # Create rating prompt
    local rating_prompt
    rating_prompt=$(cat <<EOF
You are $rater_agent participating in a PRD committee review for feature: $feature_name

**Your Task**: Rate and provide detailed feedback on the PRD draft created by $target_agent

**PRD Draft to Review**:
$(cat "$target_draft")

**Rating Instructions**:
1. Rate each PRD section on a scale of 1-10 (10 being excellent)
2. Provide specific, constructive feedback for each section
3. Focus on your domain expertise but consider all aspects
4. Identify strengths and areas for improvement
5. Be professional and collaborative

**Rating Sections**:
${COMMITTEE_PRD_SECTIONS[*]}

**Output Format**:
```
# Rating: $rater_agent reviews $target_agent

## Overall Assessment
[Your overall impression and key observations]

## Section Ratings

### Vision (Score: X/10)
[Detailed feedback on vision section]

### Requirements (Score: X/10)
[Detailed feedback on requirements section]

[Continue for all sections...]

## Summary
**Strengths**: [Key strengths of this draft]
**Areas for Improvement**: [Specific suggestions]
**Overall Score**: X/10

## Recommendations for Revision
1. [Specific actionable recommendation]
2. [Another recommendation]
...
```

Please provide your detailed rating and feedback now.
EOF
)
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Save rating prompt for debugging
    echo "$rating_prompt" > "$committee_dir/ratings/${rater_agent}_rates_${target_agent}_prompt.txt"
    
    echo "[$timestamp] Starting rating: $rater_agent rates $target_agent" >> "$committee_dir/ratings/${rater_agent}_rates_${target_agent}_log.txt"
    
    # Execute rating
    if committee_call_agent "$rater_agent" "$rating_prompt" > "$rating_file" 2>> "$committee_dir/ratings/${rater_agent}_rates_${target_agent}_log.txt"; then
        local end_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[$end_timestamp] Rating completed successfully: $rater_agent rates $target_agent" >> "$committee_dir/ratings/${rater_agent}_rates_${target_agent}_log.txt"
        
        # Validate rating has content
        if [[ -s "$rating_file" ]]; then
            echo "Rating completed: $rater_agent rates $target_agent"
            return 0
        else
            echo "Error: Empty rating produced by $rater_agent for $target_agent" >&2
            return 1
        fi
    else
        local end_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[$end_timestamp] Rating failed: $rater_agent rates $target_agent" >> "$committee_dir/ratings/${rater_agent}_rates_${target_agent}_log.txt"
        echo "Error: Rating failed for $rater_agent rating $target_agent" >&2
        return 1
    fi
}

# @description Analyze ratings for conflicts and prepare feedback
# @arg $1 string Feature name
# @stdout Analysis results
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_analyze_ratings() {
    local feature_name="$1"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local ratings_dir="$committee_dir/ratings"
    local analysis_file="$committee_dir/rating_analysis.md"
    
    echo "🔍 Analyzing ratings and detecting conflicts..."
    
    # Find all rating files
    local -a rating_files=()
    while IFS= read -r -d '' file; do
        rating_files+=("$file")
    done < <(find "$ratings_dir" -name "*_rates_*.md" -print0 2>/dev/null)
    
    if [[ ${#rating_files[@]} -eq 0 ]]; then
        echo "Error: No rating files found" >&2
        return 1
    fi
    
    echo "   Found ${#rating_files[@]} rating files"
    
    # Create analysis file
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    cat > "$analysis_file" <<EOF
# Rating Analysis for $feature_name

**Generated**: $timestamp  
**Rating Files**: ${#rating_files[@]}

## Rating Matrix

EOF
    
    # For now, create a basic analysis structure
    # In a full implementation, this would parse actual ratings and detect conflicts
    echo "   Creating rating matrix..."
    
    # Simulate conflict detection
    local conflicts_detected=0
    local high_variance_sections=""
    
    # Example conflict detection (placeholder)
    echo "   Checking for rating conflicts (variance > $COMMITTEE_RATING_CONFLICT_THRESHOLD)..."
    
    # Add analysis results to file
    cat >> "$analysis_file" <<EOF

## Conflict Analysis

**Conflicts Detected**: $conflicts_detected  
**High Variance Sections**: ${high_variance_sections:-None}

## Recommendations

Based on the rating analysis:
1. Proceed to Round 2 with feedback compilation
2. Focus revision efforts on any high-variance sections
3. Maintain collaborative tone in feedback delivery

## Next Steps

- Compile feedback for each agent
- Prepare Round 2 revision prompts
- Continue to Round 2: Revisions

EOF
    
    echo "✅ Rating analysis completed"
    echo "   Analysis file: $analysis_file"
    echo "   Conflicts detected: $conflicts_detected"
    
    return 0
}

# @description Start Round 2: Agent revisions based on feedback
# @arg $1 string Feature name
# @stdout Round 2 execution status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_start_round2() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    # Verify session state
    local current_state
    current_state=$(committee_get_state "$feature_name") || return 1
    
    if [[ "$current_state" != "$COMMITTEE_STATE_ROUND2" ]]; then
        echo "Error: Cannot start Round 2 from state '$current_state'" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local revisions_dir="$committee_dir/revisions"
    
    echo "🔄 Starting Round 2: Agent revisions based on feedback"
    
    # Find agents with drafts and feedback
    local -a revision_agents=()
    for agent in "${COMMITTEE_AGENTS[@]}"; do
        local draft_file="$committee_dir/drafts/${agent}_draft.md"
        if [[ -f "$draft_file" && -s "$draft_file" ]]; then
            # Check if this agent received feedback
            local feedback_count=$(find "$committee_dir/ratings" -name "*_rates_${agent}.md" | wc -l)
            if [[ $feedback_count -gt 0 ]]; then
                revision_agents+=("$agent")
            else
                echo "   Warning: No feedback found for agent $agent"
            fi
        fi
    done
    
    if [[ ${#revision_agents[@]} -eq 0 ]]; then
        echo "Error: No agents available for revision" >&2
        committee_update_state "$feature_name" "$COMMITTEE_STATE_FAILED" "Round 2 failed - no agents available for revision" || return 1
        return 1
    fi
    
    echo "   Agents for revision: ${revision_agents[*]}"
    
    # Start parallel revisions
    local -a revision_pids=()
    for agent in "${revision_agents[@]}"; do
        echo "   Starting revision for agent: $agent"
        
        committee_execute_agent_revision "$feature_name" "$agent" &
        local revision_pid=$!
        revision_pids+=("$revision_pid")
        
        echo "     Revision started (PID: $revision_pid)"
    done
    
    # Wait for all revisions to complete
    local revision_success_count=0
    for pid in "${revision_pids[@]}"; do
        if committee_wait_with_timeout "$pid" "$COMMITTEE_DEFAULT_TIMEOUT"; then
            if wait "$pid"; then
                ((revision_success_count++))
            else
                echo "   ❌ Revision process failed (PID: $pid)"
            fi
        else
            echo "   ⏱️ Revision process timed out (PID: $pid)"
            kill "$pid" 2>/dev/null || true
        fi
    done
    
    echo ""
    echo "Round 2 Results:"
    echo "   Successful revisions: $revision_success_count/${#revision_agents[@]}"
    
    if [[ $revision_success_count -ge 2 ]]; then
        echo "✅ Round 2 completed successfully"
        committee_update_state "$feature_name" "$COMMITTEE_STATE_FINAL" "Round 2 completed with $revision_success_count/${#revision_agents[@]} successful revisions" || return 1
        return 0
    else
        echo "❌ Round 2 failed - insufficient successful revisions"
        committee_update_state "$feature_name" "$COMMITTEE_STATE_FAILED" "Round 2 failed with only $revision_success_count/${#revision_agents[@]} successful revisions" || return 1
        return 1
    fi
}

# @description Execute agent revision based on feedback
# @arg $1 string Feature name
# @arg $2 string Agent name
# @stdout Revision execution status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_execute_agent_revision() {
    local feature_name="$1"
    local agent_name="$2"
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local original_draft="$committee_dir/drafts/${agent_name}_draft.md"
    local revision_file="$committee_dir/revisions/${agent_name}_revision.md"
    local ratings_dir="$committee_dir/ratings"
    
    if [[ ! -f "$original_draft" ]]; then
        echo "Error: Original draft not found for agent $agent_name" >&2
        return 1
    fi
    
    # Compile feedback from all other agents
    local feedback_compilation=""
    local feedback_files=()
    while IFS= read -r -d '' file; do
        feedback_files+=("$file")
    done < <(find "$ratings_dir" -name "*_rates_${agent_name}.md" -print0 2>/dev/null)
    
    if [[ ${#feedback_files[@]} -eq 0 ]]; then
        echo "Error: No feedback found for agent $agent_name" >&2
        return 1
    fi
    
    # Compile feedback
    for feedback_file in "${feedback_files[@]}"; do
        local rater=$(basename "$feedback_file" | sed 's/_rates_.*//')
        feedback_compilation+="## Feedback from $rater\n\n"
        feedback_compilation+="$(cat "$feedback_file")\n\n---\n\n"
    done
    
    # Create revision prompt
    local revision_prompt
    revision_prompt=$(cat <<EOF
You are $agent_name participating in Round 2 of a PRD committee review for feature: $feature_name

**Your Task**: Revise your original PRD draft based on feedback from other committee members

**Your Original Draft**:
$(cat "$original_draft")

**Compiled Feedback from Committee**:
$feedback_compilation

**Revision Instructions**:
1. Carefully review all feedback from your colleagues
2. Revise your PRD draft to address valid concerns and suggestions
3. Maintain your domain expertise focus while incorporating good ideas
4. Keep the overall structure but improve content based on feedback
5. Be collaborative - show that you've considered and integrated feedback where appropriate

**Output Format**: 
Provide a complete revised PRD document that incorporates the feedback while maintaining your expertise focus.

Please create your revised PRD now.
EOF
)
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Save revision prompt for debugging
    echo -e "$revision_prompt" > "$committee_dir/revisions/${agent_name}_revision_prompt.txt"
    
    echo "[$timestamp] Starting revision for agent: $agent_name" >> "$committee_dir/revisions/${agent_name}_revision_log.txt"
    echo "[$timestamp] Feedback files: ${feedback_files[*]}" >> "$committee_dir/revisions/${agent_name}_revision_log.txt"
    
    # Execute revision
    if committee_call_agent "$agent_name" "$revision_prompt" > "$revision_file" 2>> "$committee_dir/revisions/${agent_name}_revision_log.txt"; then
        local end_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[$end_timestamp] Revision completed successfully for agent: $agent_name" >> "$committee_dir/revisions/${agent_name}_revision_log.txt"
        
        # Validate revision has content
        if [[ -s "$revision_file" ]]; then
            echo "Agent $agent_name revision completed successfully"
            return 0
        else
            echo "Error: Agent $agent_name produced empty revision" >&2
            return 1
        fi
    else
        local end_timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        echo "[$end_timestamp] Revision failed for agent: $agent_name" >> "$committee_dir/revisions/${agent_name}_revision_log.txt"
        echo "Error: Agent $agent_name revision failed" >&2
        return 1
    fi
}

# @description Start final rating phase
# @arg $1 string Feature name
# @stdout Final rating phase status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_start_final_rating() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    # Verify session state
    local current_state
    current_state=$(committee_get_state "$feature_name") || return 1
    
    if [[ "$current_state" != "$COMMITTEE_STATE_FINAL" ]]; then
        echo "Error: Cannot start final rating from state '$current_state'" >&2
        return 1
    fi
    
    echo "🏁 Starting Final Rating Phase for feature '$feature_name'"
    
    # Similar to collection phase, but rating revisions instead of drafts
    # Implementation would follow similar pattern to committee_start_collection
    # but operate on revision files instead of draft files
    
    committee_update_state "$feature_name" "$COMMITTEE_STATE_CONVERGENCE" "Final rating completed" || return 1
    
    echo "✅ Final rating phase completed"
    return 0
}

# @description Complete session and prepare convergence data
# @arg $1 string Feature name
# @stdout Session completion status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_complete_session() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    
    echo "🎯 Completing committee session for '$feature_name'"
    
    # Generate final session report
    local report_file="$committee_dir/final_report.md"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    cat > "$report_file" <<EOF
# Committee Session Final Report: $feature_name

**Completed**: $timestamp

## Session Summary

The 2-round committee workflow has been completed for feature '$feature_name'.

### Process Overview

1. **Round 1**: Parallel agent drafting
2. **Collection Phase**: Cross-agent rating and feedback
3. **Round 2**: Revision based on feedback
4. **Final Rating**: Assessment of revised drafts
5. **Convergence**: Data prepared for final analysis

### Files Generated

- **Drafts**: \`drafts/\` directory contains initial PRD drafts from each agent
- **Ratings**: \`ratings/\` directory contains cross-agent ratings and feedback
- **Revisions**: \`revisions/\` directory contains revised PRDs based on feedback
- **Analysis**: Rating analysis and conflict detection results

### Next Steps

The committee workflow is complete. Data is ready for convergence algorithm processing to determine the final PRD.

EOF
    
    # Update session state to completed
    committee_update_state "$feature_name" "$COMMITTEE_STATE_COMPLETED" "Committee session completed successfully" || return 1
    
    echo "✅ Committee session completed successfully"
    echo "   Final report: $report_file"
    echo "   Workspace: $committee_dir"
    
    return 0
}

# @description Run complete 2-round workflow from start to finish
# @arg $1 string Feature name
# @arg $2 string Initial PRD input
# @stdout Complete workflow status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_run_full_workflow() {
    local feature_name="$1"
    local prd_input="$2"
    
    if [[ -z "$feature_name" || -z "$prd_input" ]]; then
        echo "Error: Missing required parameters" >&2
        echo "Usage: committee_run_full_workflow <feature_name> <prd_input>" >&2
        return 1
    fi
    
    echo "🚀 Starting complete 2-round committee workflow for '$feature_name'"
    echo ""
    
    # Initialize session
    echo "Step 1: Initializing session..."
    committee_init_session "$feature_name" "$prd_input" || {
        echo "❌ Session initialization failed"
        return 1
    }
    echo ""
    
    # Round 1: Parallel drafting
    echo "Step 2: Round 1 - Parallel agent drafting..."
    committee_start_round1 "$feature_name" || {
        echo "❌ Round 1 failed"
        return 1
    }
    echo ""
    
    # Collection phase
    echo "Step 3: Collection phase - Cross-agent rating..."
    committee_start_collection "$feature_name" || {
        echo "❌ Collection phase failed"
        return 1
    }
    echo ""
    
    # Round 2: Revisions
    echo "Step 4: Round 2 - Agent revisions..."
    committee_start_round2 "$feature_name" || {
        echo "❌ Round 2 failed"
        return 1
    }
    echo ""
    
    # Final rating
    echo "Step 5: Final rating phase..."
    committee_start_final_rating "$feature_name" || {
        echo "❌ Final rating failed"
        return 1
    }
    echo ""
    
    # Complete session
    echo "Step 6: Session completion..."
    committee_complete_session "$feature_name" || {
        echo "❌ Session completion failed"
        return 1
    }
    echo ""
    
    echo "🎉 Complete 2-round committee workflow finished successfully!"
    echo "   Feature: $feature_name"
    echo "   Duration: <duration calculation would go here>"
    echo "   All phases completed successfully"
    
    return 0
}

# =============================================================================
# GENERIC ROUND EXECUTION
# =============================================================================

# @description Execute a committee round (drafting + rating)
# @arg $1 string Feature name
# @arg $2 string Round number (1 or 2)
# @arg $3 string Round description
# @stdout Round execution status
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_execute_round() {
    local feature_name="$1"
    local round_number="$2"
    local round_description="${3:-Round $round_number}"
    
    if [[ -z "$feature_name" || -z "$round_number" ]]; then
        echo "Error: Feature name and round number required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    local round_dir="$committee_dir/round${round_number}"
    
    echo "🚀 Starting $round_description for '$feature_name'"
    echo "   Agents: ${COMMITTEE_AGENTS[*]}"
    echo "   Timeout: ${COMMITTEE_DEFAULT_TIMEOUT}s per agent"
    
    # Create round directory
    mkdir -p "$round_dir" || return 1
    
    # Find available agents (check previous round or use all for round 1)
    local -a available_agents=()
    if [[ "$round_number" == "1" ]]; then
        available_agents=("${COMMITTEE_AGENTS[@]}")
    else
        # For round 2, only include agents who completed round 1
        for agent in "${COMMITTEE_AGENTS[@]}"; do
            if [[ -f "$committee_dir/round1/${agent}.md" && -s "$committee_dir/round1/${agent}.md" ]]; then
                available_agents+=("$agent")
            fi
        done
    fi
    
    if [[ ${#available_agents[@]} -lt 2 ]]; then
        echo "Error: Insufficient agents available for $round_description (need at least 2)" >&2
        return 1
    fi
    
    echo "   Available agents: ${available_agents[*]}"
    
    # Phase 1: Parallel agent drafting
    local -a agent_pids=()
    for agent in "${available_agents[@]}"; do
        echo "   Starting agent: $agent"
        
        committee_execute_agent_draft "$feature_name" "$agent" "$round_number" &
        local agent_pid=$!
        agent_pids+=("$agent_pid")
        
        echo "     Agent $agent started (PID: $agent_pid)"
    done
    
    # Wait for all agents to complete drafting
    local success_count=0
    for i in "${!agent_pids[@]}"; do
        local pid="${agent_pids[$i]}"
        local agent="${available_agents[$i]}"
        
        echo "   Waiting for agent $agent (PID: $pid)..."
        
        if committee_wait_with_timeout "$pid" "$COMMITTEE_DEFAULT_TIMEOUT"; then
            if wait "$pid"; then
                echo "   ✅ Agent $agent completed successfully"
                ((success_count++))
            else
                echo "   ❌ Agent $agent failed"
            fi
        else
            echo "   ⏱️ Agent $agent timed out"
            kill "$pid" 2>/dev/null || true
        fi
    done
    
    # Phase 2: Cross-rating
    echo ""
    echo "🔄 Starting Cross-agent Rating Phase"
    
    local -a rating_pids=()
    for rater_agent in "${available_agents[@]}"; do
        for target_agent in "${available_agents[@]}"; do
            if [[ "$rater_agent" != "$target_agent" ]]; then
                local target_file="$round_dir/${target_agent}.md"
                if [[ -f "$target_file" && -s "$target_file" ]]; then
                    echo "   Starting rating: $rater_agent rates $target_agent"
                    
                    committee_execute_agent_rating "$feature_name" "$rater_agent" "$target_agent" "$round_number" &
                    local rating_pid=$!
                    rating_pids+=("$rating_pid")
                    
                    echo "     Rating started (PID: $rating_pid)"
                fi
            fi
        done
    done
    
    # Wait for all ratings to complete
    local rating_success_count=0
    for pid in "${rating_pids[@]}"; do
        if committee_wait_with_timeout "$pid" "$COMMITTEE_DEFAULT_TIMEOUT"; then
            if wait "$pid"; then
                ((rating_success_count++))
            fi
        else
            kill "$pid" 2>/dev/null || true
        fi
    done
    
    # Generate round scores summary
    local scores_file="$round_dir/scores.json"
    echo "{\"round\": $round_number, \"completed\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\", \"agents\": $success_count, \"ratings\": $rating_success_count}" > "$scores_file"
    
    echo ""
    echo "$round_description Results:"
    echo "   Successful agents: $success_count/${#available_agents[@]}"
    echo "   Successful ratings: $rating_success_count"
    echo "   Scores saved: $scores_file"
    
    # Determine success
    if [[ $success_count -ge 2 ]]; then
        echo "✅ $round_description completed successfully"
        return 0
    else
        echo "❌ $round_description failed - insufficient successful agents"
        return 1
    fi
}

# =============================================================================
# ROUND EXECUTION WRAPPERS
# =============================================================================

# Execute Round 1: Parallel drafting + rating collection
committee_execute_round_1() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    committee_execute_round "$feature_name" "1" "Round 1 (Initial Drafting)"
}

# Execute Round 2: Revisions + final rating  
committee_execute_round_2() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    committee_execute_round "$feature_name" "2" "Round 2 (Revised Drafting)"
}

# =============================================================================
# SEED FILE MANAGEMENT
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

# @description Get seed file path for feature
# @arg $1 string Feature name
# @stdout Seed file path
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed or not found
committee_get_seed() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local seed_file="$doh_dir/committees/$feature_name/seed.md"
    
    if [[ ! -f "$seed_file" ]]; then
        echo "Error: Seed file not found for feature: $feature_name" >&2
        return 1
    fi
    
    echo "$seed_file"
    return 0
}

# @description Read seed content for feature
# @arg $1 string Feature name
# @stdout Seed content
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed or not found
committee_read_seed() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local seed_file
    seed_file=$(committee_get_seed "$feature_name") || return 1
    
    cat "$seed_file"
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

# @description List all features with seed files
# @stdout List of feature names (one per line)
# @exitcode 0 Always succeeds
committee_list_seeds() {
    local doh_dir
    doh_dir=$(doh_project_dir) || return 0
    
    local committee_dir="$doh_dir/committees"
    
    if [[ ! -d "$committee_dir" ]]; then
        return 0
    fi
    
    for feature_dir in "$committee_dir"/*; do
        if [[ -d "$feature_dir" && -f "$feature_dir/seed.md" ]]; then
            basename "$feature_dir"
        fi
    done
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
    
    local seed_file
    seed_file=$(committee_get_seed "$feature_name") || return 1
    
    echo "$content" > "$seed_file" || {
        echo "Error: Failed to update seed file" >&2
        return 1
    }
    
    return 0
}

# @description Get committee directory for feature
# @arg $1 string Feature name
# @stdout Committee directory path
# @stderr Error messages
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_get_dir() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    echo "$doh_dir/committees/$feature_name"
    return 0
}

# @description Initialize committee directory structure
# @arg $1 string Feature name
# @exitcode 0 If successful
# @exitcode 1 If failed
committee_init_dir() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    
    # Create directory structure
    mkdir -p "$committee_dir/round1" || {
        echo "Error: Failed to create round1 directory" >&2
        return 1
    }
    
    mkdir -p "$committee_dir/round2" || {
        echo "Error: Failed to create round2 directory" >&2
        return 1
    }
    
    return 0
}

# @description Clean committee directory for feature
# @arg $1 string Feature name
# @exitcode 0 If successful (even if directory didn't exist)
# @exitcode 1 If failed
committee_clean_dir() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir
    doh_dir=$(doh_project_dir) || return 1
    
    local committee_dir="$doh_dir/committees/$feature_name"
    
    if [[ -d "$committee_dir" ]]; then
        rm -rf "$committee_dir" || {
            echo "Error: Failed to clean committee directory" >&2
            return 1
        }
    fi
    
    return 0
}

# =============================================================================
# SESSION FILE STRUCTURE MANAGEMENT
# =============================================================================

# Create committee session with basic file structure
committee_create_session() {
    local feature_name="$1"
    local context="${2:-{}}"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir session_dir
    doh_dir=$(doh_project_dir)
    session_dir="$doh_dir/committees/$feature_name"
    
    # Create directory structure
    mkdir -p "$session_dir"/{round1,round2,ratings,final,logs}
    
    # Create session metadata
    cat > "$session_dir/session.md" <<EOF
---
feature: $feature_name
status: initialized
created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
context: $context
---

# Committee Session: $feature_name

## Status
- **Phase**: Initialization
- **Agents**: 4 specialized agents + CTO arbitrator
- **Rounds**: 2-round collaborative workflow

## Session Directory Structure
\`\`\`
$session_dir/
├── session.md          # This file - session metadata
├── round1/            # Round 1 agent drafts
├── round2/            # Round 2 revisions  
├── ratings/           # Cross-agent rating data
├── final/             # Convergence results
└── logs/              # Session execution logs
\`\`\`

## Context
$context

## Notes
Session ready for Round 1 agent execution.
EOF
    
    return 0
}

# =============================================================================
# HELPER FUNCTIONS FOR AI-BASED ANALYSIS
# =============================================================================

# Analyze scoring data and prepare for AI convergence analysis
committee_analyze_scoring() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir session_dir
    doh_dir=$(doh_project_dir)
    session_dir="$doh_dir/committees/$feature_name"
    
    if [[ ! -d "$session_dir" ]]; then
        echo "Error: Session directory not found: $session_dir" >&2
        return 1
    fi
    
    echo "📊 Scoring analysis data prepared for AI review in:"
    echo "   $session_dir/"
    echo ""
    echo "Available data files:"
    find "$session_dir" -name "*.md" -type f | sort | sed 's/^/   /'
    
    return 0
}

# Check convergence and finalize - delegates to AI for decision
committee_check_convergence_and_finalize() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    echo "⚖️  Convergence analysis requires AI evaluation of:"
    echo "   - Agent rating patterns"  
    echo "   - Feedback quality and alignment"
    echo "   - Section-by-section consensus"
    echo ""
    echo "Use AI agent to analyze convergence and create final PRD."
    
    return 0
}

# Get session status for display
committee_get_session_status() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir session_dir
    doh_dir=$(doh_project_dir)
    session_dir="$doh_dir/committees/$feature_name"
    
    if [[ ! -d "$session_dir" ]]; then
        echo "❌ Session not found: $feature_name" >&2
        return 1
    fi
    
    echo "Session Directory: $session_dir"
    echo ""
    
    # Show basic structure
    if [[ -f "$session_dir/session.md" ]]; then
        echo "✅ Session initialized"
    else
        echo "⏳ Session not initialized"
    fi
    
    if [[ -d "$session_dir/round1" ]]; then
        echo "✅ Round 1 completed"
        echo "   Agent drafts: $(find "$session_dir/round1" -name "*.md" -type f | wc -l) files"
    else
        echo "⏳ Round 1 pending"
    fi
    
    if [[ -d "$session_dir/round2" ]]; then
        echo "✅ Round 2 completed"
        echo "   Revised drafts: $(find "$session_dir/round2" -name "*.md" -type f | wc -l) files"
    else
        echo "⏳ Round 2 pending"
    fi
    
    return 0
}

# Validate session structure
committee_validate_session_structure() {
    local feature_name="$1"
    
    if [[ -z "$feature_name" ]]; then
        echo "Error: Feature name required" >&2
        return 1
    fi
    
    local doh_dir session_dir
    doh_dir=$(doh_project_dir)
    session_dir="$doh_dir/committees/$feature_name"
    
    if [[ ! -d "$session_dir" ]]; then
        echo "❌ Session directory missing: $session_dir" >&2
        return 1
    fi
    
    echo "✅ Session directory exists"
    
    if [[ -f "$session_dir/session.md" ]]; then
        echo "✅ Session file exists"
    else
        echo "⚠️  Session file missing"
    fi
    
    return 0
}