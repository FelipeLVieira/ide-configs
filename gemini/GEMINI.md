## Suggested Global Antigravity Rules

### Build & Server Management
1. Always clear the build and restart the dev server before testing any changes
2. Ensure no duplicate servers are running for the same project before starting a new one
3. Check for and terminate orphaned processes that might interfere with the current development session
4. Check ports before starting: `lsof -i :3000 -i :4000 | grep LISTEN`
5. Use different ports if one is busy (add `--port 3001` or `PORT=3001`)

### Resource Management
- Close browser tabs after using them (max 2-3 open)
- Kill dev servers when done testing
- Context: If above 50%, compact before next task
- Use Grok (x.com/i/grok) for research to save API credits

### Testing & Verification
4. Prefer manual browser testing in Chrome for UI verification
5. Always check browser console logs for JavaScript errors and warnings during testing
6. Always check server logs for backend errors and exceptions
7. Run the existing test suite before and after making changes to ensure no regressions
8. Ensure essential tests exist for all new functionalities added
9. Perform visual verification of UI changes, not just functional testing
10. Test error handling paths, not just the happy path

### Code Quality & Review
11. Always double-check changes before presenting them as complete
12. Ensure no duplicated logic - check for existing utilities, helpers, or similar implementations before creating new ones
13. Review and validate all generated code for correctness, performance, and security
14. Follow existing coding patterns and conventions in the codebase
15. Avoid creating redundant variables or functions that already exist
16. Keep code DRY (Don't Repeat Yourself) - refactor when patterns emerge

### Git & Version Control
17. Do NOT commit and push until explicitly requested by the user
18. Stage changes incrementally and review diffs before committing
19. Write clear, descriptive commit messages following project conventions

### Communication & Workflow
20. Ask for clarification rather than making assumptions on ambiguous requirements
21. Break down complex tasks into smaller, verifiable steps
22. Report any unexpected issues or blockers immediately
23. Provide context when suggesting architectural changes or major refactors

### Security & Best Practices
24. Never hardcode secrets, API keys, or sensitive credentials in code
25. Validate all inputs and handle edge cases appropriately
26. Follow secure coding practices for authentication, authorization, and data handling

### Documentation
27. Update relevant documentation when adding or modifying features
28. Add meaningful code comments for complex logic or non-obvious implementations

### Memory Management
29. Always clean up event listeners, subscriptions, and timers when components unmount or are destroyed
30. Avoid storing references to DOM elements or large objects that outlive their intended scope
31. Use weak references (WeakMap, WeakSet) when appropriate to allow garbage collection
32. Clear intervals, timeouts, and animation frames when no longer needed
33. Properly dispose of WebSocket connections, database connections, and other resources
34. Watch for circular references that prevent garbage collection
35. Profile memory usage during development to identify and fix leaks early
36. Nullify references to large objects when they are no longer needed
37. Be cautious with closures that may inadvertently capture and retain large scopes

### Code Quality Analysis (Deslop Principles)

#### Priority Matrix for Fixes
| Level | Type | Examples | Action |
|-------|------|----------|--------|
| **P0** | Critical | Security, data loss, unvalidated input | Immediately |
| **P1** | High | Missing error handling, unclear ownership | This PR |
| **P2** | Medium | DRY (3+ occurrences), god classes | When touching file |
| **P3** | Low | Magic numbers, naming, minor duplication | If time permits |
| **P4** | Optional | Formatting, comment cleanup | Boy Scout Rule |

#### Quick Diagnostic Checklist
38. Functions > 50 lines -> Extract smaller functions
39. Deep nesting (3+ levels) -> Use guard clauses, exit early
40. Copy-pasted code (3+ times) -> Apply DRY (Rule of Three)
41. Magic numbers/strings -> Use named constants
42. Class doing many things -> Apply Single Responsibility Principle
43. Long parameter lists (5+) -> Consider config object or builder pattern
44. Message chains (`a.b().c().d()`) -> Law of Demeter violation
45. Silent failures -> Add fail-fast behavior, proper logging

#### Principle Tensions (When Rules Conflict)
- **DRY vs. Coupling**: Duplication is cheaper than wrong abstraction (wait for Rule of Three)
- **YAGNI vs. Extensibility**: Build for today; keep code malleable for tomorrow
- **KISS vs. DRY**: Three obvious lines beat one clever line
- **Fail-Fast vs. Resilience**: Fail fast for bugs; retry with backoff for operational failures

#### Additional Principles (Always Apply)
46. **Law of Demeter**: Only talk to immediate friends (avoid `a.b.c.d` chains)
47. **Command-Query Separation**: Methods return data OR mutate state, never both
48. **Parse, Don't Validate**: Transform input into types that make illegal states impossible
49. **Boy Scout Rule**: Leave code cleaner than you found it
50. **Idempotency**: Multiple executions should produce same result as one (critical for APIs)

---

## Clawd - Autonomous Execution

**Clawd** orchestrates autonomous coding sessions for multi-phase tasks.

### Trigger Phrases
- "Run autonomously" / "Use Clawd" / "Run in background"
- "Implement end-to-end" / "Fix all bugs" / "Refactor entire module"
- "Run perpetually" / "Keep improving"

### Commands
```bash
clawd # Interactive mode
clawd --non-interactive "task" # Single task
clawd --perpetual "task" # Continuous (runs until Ctrl+C)
```

### Configured Projects
game-project, trading-bot, crm-app, health-app, finance-app, translator-app, links-app

---

**Last Updated**: 2026-01-20
**Synced with**: ~/.claude/CLAUDE.md (Antigravity rules)
