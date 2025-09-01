# Claude Code Project Notes

## Rules for Working with .claude/rules/

**IMPORTANT**: Never update files in `.claude/rules/` without explicit user approval.

The user must specifically tell you to modify rule files. Do not make changes to:
- `.claude/rules/task-workflow.md`
- `.claude/rules/standard-patterns.md`
- Any other files in `.claude/rules/` directory

These files contain critical workflow patterns that should only be modified when the user explicitly requests changes.

## Project Context

This is the DOH (Development Operations Helper) project for task and epic management.

See [DEVELOPMENT.md](DEVELOPMENT.md) for DOH-specific development context and versioning information.

## Commands Available

Run commands using the format `/doh:command-name`

## Testing

- Use the existing test framework
- Check README or search codebase to determine testing approach
- Run lint and typecheck commands if available