# Claude Code Working Principles

**Auto-loaded globally with every session**

---

## Communication Style

- **Factual and concise** - No unnecessary praise or validation
- **Evidence-based** - Reference actual files/code when making claims
- **Label uncertainty** - Mark inferences, speculation, or unverified info
- **No emojis** - Keep all output professional

### Before Making Claims

- Verify with codebase evidence (`Grep`, `Read`, or MCP queries)
- Quote real files when referencing
- If unsure: "Need to check [aspect] to confirm"

---

## Tool Usage Best Practices

### Smart Tool Selection

- **Grep** - Exact matches, symbols, specific text
- **Glob** - File patterns, finding files
- **Read** - Reading specific files
- **Task/Explore agents** - Multi-step exploration, codebase understanding
- **MCP (Supabase)** - Database queries, live data
- **BrowserMCP** - Web automation, scraping

### Maximize Efficiency

- **Batch operations** - Read multiple files in parallel
- **Use exploration agents** - For "where/how" questions about codebase
- **Combine tools** - Grep + Read for comprehensive understanding

### Always Check First

Before editing:
1. Read the file to understand current state
2. Check for dependencies
3. Consider impact on architecture

---

## Code Quality Standards

### Every Code Change

- Follow project patterns (check existing code)
- Self-documenting code (clear names, no unnecessary comments)
- Error handling with try-catch
- TypeScript types for web projects
- Validate user input
- Security-first (no hardcoded secrets, use env vars)

### Testing Approach

- Test critical business logic
- Run linters before suggesting (hooks do this automatically)
- Consider edge cases
- Profile performance for games/heavy features

---

## Project Organization

### Respect Structure

```
src/
  core/        - Core logic
  components/  - Reusable UI
  services/    - External integrations
  utils/       - Helper functions
  types/       - TypeScript definitions
```

### Documentation

- Update README.md for major features
- Keep architecture.md current
- Document non-obvious decisions

---

## Git Best Practices

**Commit Messages**:
```
type(scope): description

feat(auth): add Supabase OAuth
fix(ui): resolve button alignment
refactor(api): simplify error handling
```

**Types**: feat, fix, refactor, docs, chore, test

---

## Context Management

### Building Understanding

1. Start with broad questions: "Overview of this codebase"
2. Use exploration agents for large codebases
3. Read project CLAUDE.md for context
4. Progressively dive deeper into specifics

### Memory Usage

- Check for project CLAUDE.md first
- Reference documented patterns
- Update CLAUDE.md when discovering important patterns

---

## Workflow

### Standard Process

1. **Understand** - Use tools to explore/analyze
2. **Plan** - Break down into steps (can use `/todo`)
3. **Execute** - Implement with attention to detail
4. **Verify** - Check hooks ran, tests pass, fits architecture

### When Blocked

- Ask clarifying questions
- Suggest multiple approaches
- Explain tradeoffs
- Document assumptions

---

## Security & Performance

### Security

- Environment variables for secrets (never hardcode)
- Validate all user input
- Sanitize before database queries
- Use HTTPS in production
- Check dependencies for vulnerabilities

### Performance

**Web**: Code splitting, lazy loading, image optimization
**Mobile**: Optimize assets, cache data, profile with DevTools
**Games**: Object pooling, LOD, texture atlasing, optimize draw calls

---

## Platform-Specific Considerations

### Web (React/Next.js/Vue)
- TypeScript for type safety
- ESLint + Prettier (automated via hooks)
- Tailwind CSS preferred
- Performance: Bundle size, lazy loading

### Mobile (Flutter/React Native)
- Platform-specific guidelines (Material/iOS)
- Test on real devices
- Optimize for battery life
- Handle different screen sizes

### Games (Unity/Godot/Unreal)
- Profile performance regularly
- Object pooling for frequently created objects
- Frame-independent game loops
- Separate game logic from rendering

---

## AI Asset Generation (For Games)

### Workflow

**Textures**: ComfyUI/SD WebUI → "seamless [material] texture, 4k, tileable, PBR"
**Sprites**: "2D game sprite, [style], transparent background"
**Icons**: "game UI icon, [item], clean design, 512x512"

### Consistency

- Maintain consistent art style
- Document successful prompts
- Post-process as needed
- Test in target engine

---

## Notes for Me (Claude)

### When Working with User

- He works across web, mobile, and game development
- Prefers TypeScript, Tailwind, Flutter, Unity
- Values clean, maintainable code
- Appreciates multiple approaches when unclear
- Uses local AI for asset generation

### Project Approach

- Always check for project CLAUDE.md
- Use exploration agents for large codebases
- Read relevant files before editing
- Test changes when possible
- Explain "why" not just "what"

---

**Auto-loaded**: Every Claude Code session
**Last Updated**: 2025-11-15
