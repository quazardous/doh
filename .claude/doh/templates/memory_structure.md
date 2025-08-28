# DOH Memory Structure Templates

This document defines the intelligent memory structure for DOH runtime projects, used by `/doh:next` for AI-powered task recommendations.

## Directory Structure

```
.doh/memory/
├── NEXT.md              # AI memory for task recommendations
├── patterns.md          # Learned project patterns  
├── preferences.md       # User preference tracking
└── optimization.md      # AI optimization log
```

## Memory File Templates

### NEXT.md - AI Task Intelligence Memory

```markdown
# DOH Task Intelligence Memory 🧠
**Last Analysis**: {DATE}  
**Project Context**: {PROJECT_NAME}  
**Epic Progress**: {ACTIVE_EPICS_SUMMARY}  
**Total Tasks**: {TOTAL_COUNT} active, {READY_COUNT} ready to start

## 🎯 Top Recommendations

### Immediate Priority (Next Session)

#### 1. **{TASK_ID}** - {TASK_TITLE} ({EFFORT_ESTIMATE})
- **Score**: {PRIORITY_SCORE}/10 - {IMPACT_DESCRIPTION}
- **Status**: 🟢 READY ({DEPENDENCIES_MET})
- **Impact**: {IMPACT_DESCRIPTION}
- **Why Now**: {RECOMMENDATION_REASONING}

#### 2. **{TASK_ID}** - {TASK_TITLE} ({EFFORT_ESTIMATE})
- **Score**: {PRIORITY_SCORE}/10 - {CATEGORY}
- **Status**: 🟡 WAITING ({BLOCKING_DEPENDENCIES})
- **Impact**: {IMPACT_DESCRIPTION}
- **Why**: {RECOMMENDATION_REASONING}

## 📊 Task Dependency Graph

```
Legend: 🟢 Ready | 🟡 Waiting | 🔴 Blocked | ✅ Complete

{EPIC_ID} ({EPIC_TITLE})
    ├─→ ✅ {TASK_ID} ({TASK_TITLE})
    │       └─→ 🟢 {DEPENDENT_TASK}
    └─→ 🟡 {TASK_ID} ({TASK_TITLE})
            └─→ 🔴 {BLOCKED_TASK}
```

## 🔍 Pre-computed Queries

### "high priority"
1. {TASK_ID} - {TASK_TITLE} (unlocks {DEPENDENT_COUNT} tasks)
2. {TASK_ID} - {TASK_TITLE} (epic critical path)

### "quick wins"  
1. {TASK_ID} - {TASK_TITLE} ({EFFORT_POINTS} points)
2. {TASK_ID} - {TASK_TITLE} ({EFFORT_POINTS} points)

### "epic {N}"
**{EPIC_TITLE}** ({COMPLETION_PERCENTAGE}% complete):
- Phase {N}: {TASK_LIST}

### "agent {NAME}"
**{AGENT_NAME}** workload ({CURRENT_LOAD}/10):
- {ASSIGNED_TASK_LIST}

### "blocked tasks"
1. {TASK_ID} - waiting for {BLOCKING_TASK}
2. {TASK_ID} - dependency on {EXTERNAL_BLOCKER}

### "documentation"
1. {TASK_ID} - {DOC_TASK_TITLE}
2. {TASK_ID} - {DOC_TASK_TITLE}

## 📈 Strategic Context

### Current Sprint/Milestone
- **Focus**: {CURRENT_FOCUS_AREA}
- **Goal**: {SPRINT_GOAL}
- **Critical Path**: {CRITICAL_PATH_TASKS}

### Team Coordination
- **Agent Workload**: {WORKLOAD_DISTRIBUTION}
- **Collaboration Points**: {COORDINATION_NEEDS}
- **Handoff Dependencies**: {HANDOFF_TASKS}

## 💡 Context Patterns

### Recent Completions
- {RECENT_COMPLETED_TASKS} - {COMPLETION_PATTERNS}

### Development Momentum
- {MOMENTUM_ANALYSIS}
- {FOCUS_AREA_TRENDS}

### Team Preferences
- {OBSERVED_PREFERENCES}
- {WORKING_PATTERNS}

## 🎯 Natural Language Mappings

### Intent → Task Mappings
- "work on {KEYWORD}" → {MATCHED_TASKS}
- "quick task" → {QUICK_WIN_TASKS}
- "{EPIC_KEYWORD}" → {EPIC_RELATED_TASKS}

### Context Filters
- `#{TAG}`: {TAG_MATCHED_TASKS}
- `agent:{NAME}`: {AGENT_TASKS}
- `epic:{ID}`: {EPIC_TASKS}

---
*Memory Version: 1.0 | DOH Project: {PROJECT_NAME} | Analysis Engine: /doh:next*
```

### patterns.md - Project Pattern Learning

```markdown
# DOH Project Pattern Learning 📊
**Last Updated**: {DATE}
**Project**: {PROJECT_NAME}
**Analysis Period**: {ANALYSIS_WINDOW}

## Task Completion Patterns

### Typical Effort Estimates vs Actual
- **1 point tasks**: Usually take {ACTUAL_TIME} (accuracy: {ACCURACY}%)
- **3 point tasks**: Usually take {ACTUAL_TIME} (accuracy: {ACCURACY}%)
- **5 point tasks**: Usually take {ACTUAL_TIME} (accuracy: {ACCURACY}%)

### Dependencies & Blockers
- **Most common blockers**: {COMMON_BLOCKERS}
- **Average dependency chain length**: {AVG_CHAIN_LENGTH}
- **Frequent bottlenecks**: {BOTTLENECK_TASKS}

### Epic Progression
- **{EPIC_ID}**: {PROGRESSION_PATTERN}
- **Average phase duration**: {PHASE_DURATION}
- **Common phase transitions**: {TRANSITION_PATTERNS}

## Team Collaboration Patterns

### Agent Specialization
- **{AGENT_NAME}**: Strong in {SPECIALIZATION_AREAS}
- **Cross-agent dependencies**: {COLLABORATION_PATTERNS}
- **Handoff efficiency**: {HANDOFF_METRICS}

### Working Rhythm
- **Peak productivity times**: {PEAK_TIMES}
- **Typical session lengths**: {SESSION_PATTERNS}
- **Break patterns**: {BREAK_ANALYSIS}

## Context Switch Patterns

### Task Switching
- **Effective switches**: {GOOD_SWITCH_PATTERNS}
- **Costly switches**: {EXPENSIVE_SWITCHES}
- **Optimal sequencing**: {SEQUENCE_RECOMMENDATIONS}

### Focus Area Rotation
- **Documentation → Development**: {ROTATION_EFFICIENCY}
- **Testing → Features**: {ROTATION_PATTERNS}
- **Architecture → Implementation**: {TRANSITION_SUCCESS}

---
*Pattern analysis helps /doh:next provide increasingly accurate recommendations*
```

### preferences.md - User Preference Tracking

```markdown
# DOH User Preference Tracking 👤
**Last Updated**: {DATE}
**User Context**: {USER_IDENTIFIER}
**Tracking Period**: {TRACKING_WINDOW}

## Task Selection Preferences

### Consistently Chosen Over Recommended
- **User picks {TASK_TYPE}** when AI suggests {OTHER_TYPE}: {FREQUENCY}%
- **Preference pattern**: {PATTERN_DESCRIPTION}
- **Adaptation**: Increase weight for {PREFERRED_CHARACTERISTICS}

### Context Preferences
- **"Quick wins"**: Prefers {TASK_CHARACTERISTICS}
- **"High impact"**: Values {IMPACT_FACTORS}
- **"Documentation"**: Focuses on {DOC_PREFERENCES}

### Work Style Indicators
- **Sequential vs Parallel**: Tends to {WORK_STYLE_PREFERENCE}
- **Deep focus vs Variety**: Prefers {FOCUS_PREFERENCE}
- **Planning vs Doing**: Leans toward {APPROACH_PREFERENCE}

## Epic & Strategic Preferences

### Epic Affinity
- **Most engaged with**: {PREFERRED_EPICS}
- **Avoids**: {AVOIDED_EPIC_TYPES}
- **Timing preferences**: Works on {EPIC_TYPE} during {PREFERRED_TIMING}

### Priority Interpretation
- **User's P1 vs System P1**: {PRIORITY_ALIGNMENT}%
- **Urgency vs Importance**: Prioritizes {PREFERENCE_BALANCE}

## Query Pattern Learning

### Natural Language Preferences
- **Most used queries**: {COMMON_QUERIES}
- **Effective phrasings**: {SUCCESSFUL_QUERIES}
- **Misunderstood queries**: {PROBLEMATIC_QUERIES}

### Context Usage
- **Frequently used contexts**: {POPULAR_CONTEXTS}
- **Effective combinations**: {SUCCESSFUL_COMBINATIONS}
- **Underutilized features**: {UNUSED_FEATURES}

## Adaptation Recommendations

### AI Behavior Adjustments
- **Increase weight on**: {BOOST_FACTORS}
- **Decrease emphasis on**: {REDUCE_FACTORS}
- **Add new filters for**: {NEW_FILTER_SUGGESTIONS}

### Interface Optimizations
- **Suggest shortcuts for**: {SHORTCUT_OPPORTUNITIES}
- **Default contexts to**: {PREFERRED_DEFAULTS}
- **Proactive suggestions**: {PROACTIVE_OPPORTUNITIES}

---
*Preference tracking enables /doh:next to adapt to individual working styles*
```

### optimization.md - AI Optimization Log

```markdown
# DOH AI Optimization Log 🔧
**Last Updated**: {DATE}
**Project**: {PROJECT_NAME}
**Optimization Version**: {VERSION}

## Applied Optimizations

### {DATE} - {OPTIMIZATION_TITLE}
**Pattern Detected**: {DETECTED_PATTERN}
**Issue**: {IDENTIFIED_ISSUE}
**Solution**: {IMPLEMENTED_SOLUTION}
**Impact**: {MEASURED_IMPACT}
**Status**: ✅ Active | 🔄 Testing | ❌ Reverted

### Performance Improvements
- **Query response time**: Improved from {OLD_TIME}ms to {NEW_TIME}ms
- **Recommendation accuracy**: Increased from {OLD_ACCURACY}% to {NEW_ACCURACY}%
- **User satisfaction**: {SATISFACTION_METRICS}

## Detected Patterns Awaiting Optimization

### {PATTERN_NAME}
**Observed**: {PATTERN_DESCRIPTION}
**Frequency**: {OCCURRENCE_RATE}
**Potential Impact**: {ESTIMATED_IMPROVEMENT}
**Proposed Solution**: {SOLUTION_PROPOSAL}
**Risk Assessment**: {RISK_LEVEL}

## Failed Optimizations

### {OPTIMIZATION_NAME}
**Attempted**: {DATE}
**Reason for Failure**: {FAILURE_ANALYSIS}
**Lessons Learned**: {INSIGHTS}
**Alternative Approaches**: {ALTERNATIVES}

## Optimization Pipeline

### Scheduled Reviews
- **Weekly pattern analysis**: {NEXT_ANALYSIS_DATE}
- **Monthly accuracy audit**: {NEXT_AUDIT_DATE}
- **Quarterly system optimization**: {NEXT_OPTIMIZATION_DATE}

### Continuous Learning Triggers
- **Accuracy drops below**: {THRESHOLD}%
- **Response time exceeds**: {THRESHOLD}ms
- **User override rate above**: {THRESHOLD}%

---
*Optimization log ensures /doh:next continuously improves its intelligence*
```

## Memory Initialization

When `/doh:next` is first run in a project, it creates these templates populated with initial analysis:

1. **Scan .doh/ structure** - Tasks, epics, features
2. **Analyze dependencies** - Build dependency graph
3. **Calculate initial priorities** - Apply scoring algorithm
4. **Generate memory files** - Create populated templates
5. **Set up optimization tracking** - Initialize learning systems

## Memory Update Triggers

- **Task status changes** - When tasks are completed, blocked, or unblocked
- **New task creation** - When `/doh:task` creates new tasks
- **Epic updates** - When epic phases change or milestones are reached
- **Manual refresh** - When user runs `/doh:next --refresh`
- **Time-based refresh** - Automatic refresh after configured intervals

---

This memory structure enables `/doh:next` to provide intelligent, contextual, and continuously improving task recommendations tailored to each DOH project's specific patterns and team dynamics.