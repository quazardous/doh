# Project Configuration for Claude

## Language Convention for .claude/*
**All files under `.claude/` directory MUST be written in English**, regardless of the project's primary language. This ensures consistency and universal understanding of Claude configuration and tools.

## Project Management System
This project uses the **/doh** system for complete task management and traceability.

📖 **DOH Documentation**: See `.claude/doh/inclaude.md`

### DOH Rules
- **ALL code modifications must be linked to a /doh issue**
- Code comments: `// DOH #123: Description`
- Commits: `[DOH #123] Description of change`
- Complete traceability: PRD → Epic → [Feature] → Task → Code

## Code Quality Standards

### Architecture & Design Patterns
- **DRY** (Don't Repeat Yourself): Factor out duplicated code
- **SOLID Principles**: Apply systematically
- **Separation of Concerns**: One function = one responsibility
- **Error Handling**: Appropriate try-catch, explicit error management

### Naming Conventions
- **Variables/Functions**: camelCase (JavaScript/PHP)
- **Classes**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Files**: kebab-case.js or PascalCase.php depending on context
- **Explicit names**: `getUserById()` > `getUser()`

### Documentation & Comments
- **JSDoc/PHPDoc** for all public functions
- **Comments only when necessary** (self-documenting code preferred)
- **TODO/FIXME**: Always with DOH reference: `// TODO DOH #123: Description`
- **No commented code**: Delete or create /doh issue

### Tests & Validation
- **Unit tests** for critical business logic
- **Linting**: Fix all warnings before commit
- **Type checking**: TypeScript/PHP strict types when available
- **Coverage**: Target 80% on critical code

### Performance & Optimization
- **Lazy Loading**: Load resources on demand
- **Memoization**: Cache expensive results
- **Debouncing/Throttling**: For frequent events
- **Bundle Size**: Analyze and optimize imports

### Security Best Practices
- **Input Validation**: Always validate external data
- **SQL Injection**: Use prepared statements
- **XSS Prevention**: Escape HTML output
- **CSRF Protection**: Tokens on forms
- **Secrets**: NEVER in code, use .env
- **Dependencies**: Check vulnerabilities regularly

### Git & Version Control
- **Atomic commits**: One commit = one logical change
- **Descriptive messages**: `[DOH #123] Add user authentication with JWT`
- **Branch naming**: `feature/doh-123-user-auth` or `fix/doh-456-login-bug`
- **No direct push to main**: Always via PR
- **Rebase vs Merge**: Rebase feature branches, merge to main

### Code Review Checklist
Before finalizing:
1. ✅ Tests pass
2. ✅ Linting clean
3. ✅ Performance acceptable
4. ✅ Security verified
5. ✅ Documentation updated
6. ✅ DOH reference in code/commit

## Essential Commands

### Code Validation
```bash
# Linting
npm run lint       # or yarn lint
npm run lint:fix   # Auto-fix

# Tests
npm test           # Unit tests
npm run test:e2e   # End-to-end tests

# Type checking (if applicable)
npm run typecheck

# Security audit
npm audit
```

### Build & Development
```bash
# Development
npm run dev        # Dev build
npm run watch      # Watch mode
npm run serve      # Dev server

# Production
npm run build      # Prod build
npm run analyze    # Bundle analysis
```

## Typical Project Structure

```
project/
├── .claude/           # Claude configuration
│   └── doh/          # DOH system
├── .doh/             # Project content (tasks, epics)
├── src/              # Source code
│   ├── components/   # Reusable components
│   ├── services/     # Business logic
│   ├── utils/        # Helpers
│   └── types/        # Types/Interfaces
├── tests/            # Tests
├── docs/             # Project documentation
└── config/           # Configuration
```

## Optimal Development Workflow

1. **Analysis**: Understand requirement via /doh
2. **Design**: Plan architecture before coding
3. **Implementation**: Incremental code with tests
4. **Review**: Self-review with checklist
5. **Integration**: PR with DOH references

## Anti-Patterns to Avoid

❌ **God Objects**: Classes/functions too large
❌ **Magic Numbers**: Use named constants
❌ **Callback Hell**: Prefer async/await
❌ **Global State**: Use dependency injection
❌ **Copy-Paste**: Refactor immediately
❌ **Premature Optimization**: Measure before optimizing

## Debug & Troubleshooting

### Debug Strategies
1. **Structured console logs**: `console.log('[DOH #123]', data)`
2. **Breakpoints**: Use IDE debugger
3. **Error boundaries**: Catch errors gracefully
4. **Monitoring**: Structured logs in production

### Common Issues
- **Module not found**: Check imports and node_modules
- **Type errors**: Verify types/interfaces
- **Performance**: Profile before optimizing
- **Memory leaks**: Cleanup event listeners

## Resources & References

### Official Documentation
- Language/Framework docs
- API references
- Security guidelines

### Tools
- **Linting**: ESLint, Prettier, StyleLint
- **Testing**: Jest, Mocha, PHPUnit
- **Security**: npm audit, Snyk
- **Performance**: Lighthouse, WebPageTest

---

*This file defines quality standards for all development in this project. Following these guidelines ensures maintainable, performant, and secure code.*