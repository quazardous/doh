# /commit-interactive - Interactive Semantic Commit Review

Quick access to interactive semantic commit splitting with full review control - automatically splits staging area into focused commits and lets you review, edit, and approve each one.

## Usage

```bash
/commit-interactive [task-completion] [--staged-focused] [--dry-run]
```

## Description

This is a shortcut command for `/dd:commit --split --interactive` optimized for developers who want full control over their commit sequence. Perfect when you have complex changes that need careful commit message crafting and sequence review.

## Parameters

- `task-completion`: (Optional) Overall description applied to the first commit
  - **Example**: `"T066 audit system complete"`
  - **Smart usage**: Subsequent commits get auto-generated semantic messages
- `--staged-focused`: Process only staged files + obvious semantic matches
  - **Focus**: Ignores unrelated unstaged/untracked files
  - **Clean**: Produces focused commits without workspace clutter
- `--dry-run`: Preview the planned commit sequence without interactive review

## Interactive Review Process

1. **Analysis Phase**: Scans staging area and groups files semantically
2. **Preview Phase**: Shows complete commit sequence with files and messages
3. **Review Phase**: For each commit:
   - ✅ **Accept**: Use the generated message and commit
   - ✏️ **Edit**: Modify the commit message  
   - ⏭️ **Skip**: Skip this commit (files remain staged)
   - 🛑 **Abort**: Cancel entire sequence (no commits made)

## Smart Commit Sequencing

Interactive review follows semantic priority:

1. **Epic/TODO Updates** → Review task completion commits first
2. **System Changes** → Review infrastructure/tool improvements  
3. **Documentation** → Review README, guides, workflow updates
4. **Implementation** → Review core functionality changes
5. **Configuration** → Review settings, package, build changes

## Example Usage

```bash
# Full interactive control
/commit-interactive
# Split → review each commit → edit messages → full control

# Focus on staged work with interaction
/commit-interactive --staged-focused
# Staged files only → interactive review → clean focused commits

# Epic completion with careful messaging
/commit-interactive "T065 beautification complete"
# Epic description → review each semantic commit → perfect messages

# Preview then interact
/commit-interactive --dry-run
# See the plan first
/commit-interactive  
# Then execute with full control
```

## Interactive Examples

**Epic Task Review:**
```
🔍 Commit 1/3: feat: Complete T065 command beautification
  Files: todo/T065.md, todo/NEXT.md
  
  [A]ccept / [E]dit / [S]kip / A[b]ort: E
  
  New message: feat: Complete T065 command beautification and task updates
  ✅ Commit 1 created with custom message
```

**System Enhancement Review:**
```  
🔍 Commit 2/3: feat: Enhance DOH commands with auto-completion
  Files: .claude/commands/doh-sys/commit.md, .claude/commands/commit-split.md
  
  [A]ccept / [E]dit / [S]kip / A[b]ort: A
  ✅ Commit 2 created with auto-generated message
```

## Common Workflow Patterns

**Careful Epic Completion:**
```bash
# Epic work often needs perfect commit messages for project history
/commit-interactive "T054 memory system implementation complete"
# Review each commit → ensure professional messages → clean epic history
```

**Complex Feature Development:**
```bash  
# Multiple system components modified
/commit-interactive --staged-focused
# Focus on staged work → review logical groupings → perfect commit sequence
```

**Professional Polish:**
```bash
# Before important milestones or releases
/commit-interactive --dry-run  # Preview first
/commit-interactive             # Then review each commit carefully
# Ensure commit history tells a professional development story
```

## Integration

This command is equivalent to:
```bash
/dd:commit --split --interactive [same-parameters]
```

But provides:
- **Focused workflow** for interactive commit crafting
- **Shorter syntax** for the most careful commit workflow
- **Clear documentation** on interactive review features
- **Quick access** to professional commit sequence creation

Perfect for:
- Epic task completions requiring careful commit messages
- Complex features needing logical commit breakdown
- Professional development where commit history matters
- Learning semantic commit patterns through guided review

## Success Criteria

- Provides full interactive control over semantic commit splitting
- Maintains all safety and preview features of parent command
- Shorter, focused syntax for interactive workflows
- Professional commit history creation with user guidance