# Your Global Development Context

## Developer Profile

**Name**: Your Name
**Email**: your-email@example.com
**Primary Stack**: Full-stack web, mobile, and game development
**AI Tools**: Local AI asset generation (Stable Diffusion, ComfyUI)

---

## Meta-Cognitive Protocol (Apply to EVERY Task)

**IMPORTANT: Claude MUST follow this protocol for every response.**

### 1. Take a Deep Breath
Before starting any task, pause and ensure full understanding of the request. Don't rush into implementation.

### 2. Self-Challenge
- Question initial assumptions
- Consider alternative approaches
- Ask: "Is this really the best way?"
- Challenge the obvious solution - there might be a better one
- Play devil's advocate with your own reasoning

### 3. Add Stakes
Frame the task with appropriate gravity:
- "This code will run in production"
- "Users depend on this working correctly"
- "Security vulnerabilities here could be exploited"
- "Performance issues here will impact user experience"
- Treat every task as if it matters significantly

### 4. Persona Selection
Analyze and select the best persona for the task:
- **Senior Backend Engineer**: API design, database optimization, server architecture
- **Senior Frontend Engineer**: UI/UX, React/Vue components, state management
- **Game Developer**: Unity/Godot, performance optimization, game loops
- **Mobile Developer**: Flutter/React Native, platform-specific considerations
- **Security Engineer**: Auth, input validation, vulnerability assessment
- **DevOps Engineer**: CI/CD, infrastructure, deployment
- **Architect**: System design, scalability, tech stack decisions
- **Code Reviewer**: Quality, patterns, best practices

### 5. Skills & Agents Selection
Identify which Claude skills and agents are most relevant:
- **Exploration agents**: For understanding large codebases
- **senior-frontend**: React, Next.js, UI implementation
- **senior-backend**: APIs, databases, server logic
- **senior-fullstack**: End-to-end features
- **verify-nextjs/verify-supabase/verify-threejs**: Post-implementation verification
- **code-reviewer**: Quality checks
- **Plan agent**: Complex multi-step implementations

### 6. Confidence Self-Evaluation
Rate confidence on a scale and explain:
- **High (90-100%)**: Well-understood domain, clear requirements, familiar patterns
- **Medium (60-89%)**: Some uncertainty, may need clarification or verification
- **Low (30-59%)**: Significant unknowns, recommend exploration first
- **Very Low (<30%)**: Major gaps, must investigate before proceeding

### Response Format
Every substantive response should include (at the start or end):

```
---
**Meta**:
- Persona: [Selected persona]
- Confidence: [X%] - [Brief reason]
- Skills/Agents: [Relevant ones identified]
- Self-Challenge: [Key assumption questioned or alternative considered]
---
```

For simple questions or quick tasks, this can be abbreviated to a single line.

---

## Development Preferences

### Code Style & Conventions

**General Principles**:
- Write clean, readable, and maintainable code
- Prefer functional programming patterns where appropriate
- Use TypeScript for type safety in JavaScript projects
- Follow SOLID principles for object-oriented code
- Prioritize performance and optimization in game development

**Formatting**:
- Auto-format all code (ESLint + Prettier for web, Dart format for Flutter, etc.)
- Use consistent naming conventions across projects
- Keep functions small and focused (single responsibility)
- Add comments for complex logic, not obvious code

**Error Handling**:
- Always handle errors gracefully
- Use try-catch blocks appropriately
- Provide meaningful error messages
- Log errors for debugging

---

## Resource Management

**Port Management**:
Before starting ANY dev server, check what's already running:
```bash
lsof -i :3000 -i :4000 -i :8080 | grep LISTEN
```
- Check first, never blindly start servers
- Use different ports if one is busy
- Clean up duplicate processes
- Assigned ranges: See project-specific docs

**Context Management (for AI agents)**:
- Check context usage after each task
- If above 50%, compact before next task
- Don't wait until 80%+ to compact

**Browser/Process Cleanup**:
- Close browser tabs after using them (max 2-3 open)
- Kill dev servers when done testing
- Check for orphaned processes before starting new ones

**Git Hygiene**:
- Commit often with clear messages
- Push after significant milestones
- Format: `<type>: <description>` (feat, fix, refactor, docs, etc.)

**Use Grok for Research**:
User is logged into X with Grok access. Use Grok for:
- Market research, news, trends
- Quick fact-checking
- Second opinions on complex decisions
This saves Claude API credits!

---

## Technology Stack

### Web Development
**Frontend Frameworks**:
- React.js (primary)
- Next.js (for SSR/SSG)
- Vue.js, Nuxt
- Svelte, Astro

**Styling**:
- Tailwind CSS (preferred)
- CSS Modules
- Styled Components (React)

**Build Tools**:
- Vite (preferred for speed)
- Webpack (when needed)
- TypeScript
- ESLint + Prettier

**State Management**:
- React Context + Hooks (simple apps)
- Zustand or Jotai (medium complexity)
- Redux Toolkit (complex apps)

### Mobile Development
**Primary**: Flutter + Dart
**Secondary**: React Native
**Native**: Swift (iOS), Kotlin (Android)

**Mobile Best Practices**:
- Optimize for performance and battery life
- Follow platform-specific design guidelines (Material Design, Human Interface Guidelines)
- Test on real devices, not just simulators
- Handle different screen sizes and orientations

### Game Development
**Engines**:
- Unity (C#) - primary for 3D games
- Godot (GDScript) - for 2D games and rapid prototyping
- Unreal Engine (C++) - for AAA-quality projects

**Game Dev Best Practices**:
- Optimize for target platform (mobile, PC, console)
- Use object pooling to reduce memory allocations
- Profile performance regularly
- Keep game loop frame-independent
- Separate game logic from rendering

### Backend & Database
**Preferred Stack**:
- Supabase (primary) - PostgreSQL, Auth, Storage, Realtime
- Node.js/Express or Next.js API routes
- Python for AI/ML backends

**Database**:
- PostgreSQL (via Supabase)
- SQLite for local/offline apps
- Redis for caching

### AI & Asset Generation
**Local Tools**:
- Stable Diffusion WebUI (texture/sprite generation)
- ComfyUI (complex workflows)
- Ollama (local LLMs for code/dialogue)
- Blender + AI plugins (3D assets)

**Use Cases**:
- Game texture generation
- 2D sprite creation
- UI icon generation
- Concept art
- Background images
- 3D model preparation

---

## Common Workflows

### Starting a New Project

**Web Project**:
```bash
# React + Vite + TypeScript
npm create vite@latest project-name -- --template react-ts

# Next.js
npx create-next-app@latest project-name --typescript --tailwind --app

# Install essentials
npm install -D eslint prettier
```

**Mobile Project**:
```bash
# Flutter
flutter create project_name
cd project_name
flutter pub get

# React Native
npx react-native init ProjectName --template react-native-template-typescript
```

**Game Project**:
- Unity: Create new project via Unity Hub
- Godot: Use `godot` command or GUI
- Set up version control immediately

### Build Commands

**Web**:
```bash
npm run dev          # Development server
npm run build        # Production build
npm run lint         # ESLint check
npm run format       # Prettier format
npm test            # Run tests
```

**Mobile**:
```bash
flutter run          # Development
flutter build apk    # Android release
flutter build ios    # iOS release
flutter test         # Run tests
```

**Game**:
- Unity: Build via File → Build Settings
- Godot: Project → Export
- Test on target platform before release

### Testing & Quality

**Always**:
- Write tests for critical business logic
- Test on multiple devices/browsers
- Run linters before commits
- Use TypeScript for type safety
- Profile performance for games and heavy apps

---

## Git Workflow

**Branch Naming**:
- `feature/feature-name` - New features
- `fix/bug-description` - Bug fixes
- `refactor/what-changed` - Code refactoring
- `docs/what-documented` - Documentation
- `chore/task-description` - Maintenance tasks

**Commit Messages**:
- Use conventional commits: `type(scope): description`
- Examples:
  - `feat(auth): add Google OAuth login`
  - `fix(ui): resolve button alignment issue`
  - `refactor(api): simplify error handling`
  - `docs(readme): update installation instructions`

**Before Committing**:
1. Run linters and formatters
2. Run tests
3. Review changes
4. Write clear commit message

---

## Tools & Environment

**Primary Editor**: VSCode with Claude Code extension
**AI Assistants**: Claude Code, GitHub Copilot
**Version Control**: Git + GitHub
**Package Managers**: npm, pnpm, yarn (prefer pnpm for speed)
**Terminal**: iTerm2 / native macOS Terminal
**Shell**: zsh

**Installed Tools**:
- Node.js, npm, pnpm, yarn
- Flutter, Dart
- Python (with PyTorch for AI)
- Docker
- Git, GitHub CLI
- Ollama (local LLMs)

---

## Project Organization

### File Structure Preferences

**Web Projects**:
```
src/
  components/     # Reusable UI components
  pages/         # Route pages
  hooks/         # Custom React hooks
  utils/         # Helper functions
  types/         # TypeScript types
  api/           # API integration
  styles/        # Global styles
  assets/        # Images, fonts, etc.
```

**Mobile (Flutter)**:
```
lib/
  models/        # Data models
  screens/       # UI screens
  widgets/       # Reusable widgets
  services/      # API, storage services
  providers/     # State management
  utils/         # Helpers
```

**Game Projects**:
```
Assets/
  Scripts/       # Game logic
  Prefabs/       # Reusable objects
  Scenes/        # Game levels
  Materials/     # Shaders, materials
  Audio/         # Sound effects, music
  Sprites/       # 2D graphics
  Models/        # 3D models
```

---

## Security & Best Practices

**Never Commit**:
- API keys, tokens, secrets
- `.env` files (use `.env.example` instead)
- Database credentials
- Private keys

**Always**:
- Use environment variables for secrets
- Validate user input
- Sanitize data before database queries
- Use HTTPS in production
- Implement proper authentication and authorization
- Keep dependencies updated

---

## Performance Optimization

**Web**:
- Code splitting and lazy loading
- Image optimization (WebP, lazy loading)
- Minimize bundle size
- Use CDN for static assets
- Implement caching strategies

**Mobile**:
- Optimize images and assets
- Use ListView builders for long lists
- Minimize network requests
- Cache data locally
- Profile with Flutter DevTools

**Games**:
- Object pooling
- LOD (Level of Detail) for 3D models
- Texture atlasing
- Optimize draw calls
- Profile with engine tools

---

## Memory Leak Prevention (CRITICAL)

**IMPORTANT: Claude MUST actively watch for and prevent memory leaks in ALL code written.**

### React/Next.js Memory Leaks
- **Always cleanup useEffect**: Return cleanup functions to remove event listeners, subscriptions, timers
- **Abort fetch requests**: Use AbortController in useEffect cleanup for async operations
- **Clear intervals/timeouts**: Always store refs and clear in cleanup
- **Unsubscribe from observables**: WebSocket, Supabase realtime, event emitters
- **Remove event listeners**: window, document, DOM element listeners
- **Cancel animations**: requestAnimationFrame, CSS transitions, Framer Motion

```typescript
// CORRECT pattern
useEffect(() => {
  const controller = new AbortController();
  const timer = setInterval(() => {}, 1000);
  const handler = () => {};
  window.addEventListener('resize', handler);

  return () => {
    controller.abort();
    clearInterval(timer);
    window.removeEventListener('resize', handler);
  };
}, []);
```

### Common Memory Leak Sources
1. **Event listeners not removed** - window.addEventListener without cleanup
2. **Subscriptions not unsubscribed** - Supabase realtime, WebSocket, RxJS
3. **Timers not cleared** - setInterval, setTimeout without cleanup
4. **Refs to unmounted components** - Async callbacks updating unmounted state
5. **Closures holding references** - Large objects in closures
6. **DOM references** - Storing DOM nodes that get removed
7. **Global state accumulation** - Zustand/Redux stores growing unbounded
8. **Cache without limits** - React Query, SWR without maxAge/staleTime

### React-Specific Patterns
```typescript
// Use isMounted pattern for async operations
useEffect(() => {
  let isMounted = true;

  async function fetchData() {
    const data = await fetch('/api/data');
    if (isMounted) setState(data); // Only update if still mounted
  }

  fetchData();
  return () => { isMounted = false; };
}, []);

// Use refs for values that shouldn't trigger re-renders
const callbackRef = useRef(callback);
useEffect(() => { callbackRef.current = callback; });
```

### Supabase Realtime Cleanup
```typescript
useEffect(() => {
  const channel = supabase.channel('room')
    .on('broadcast', { event: 'message' }, handler)
    .subscribe();

  return () => {
    supabase.removeChannel(channel); // CRITICAL cleanup
  };
}, []);
```

### Map/Canvas/WebGL Cleanup
```typescript
useEffect(() => {
  const map = new mapboxgl.Map({ container: containerRef.current });

  return () => {
    map.remove(); // Remove map instance
  };
}, []);
```

### Three.js/WebGL Memory Management
- Dispose geometries: `geometry.dispose()`
- Dispose materials: `material.dispose()`
- Dispose textures: `texture.dispose()`
- Remove from scene: `scene.remove(object)`
- Clear renderer: `renderer.dispose()`

### Mobile (Flutter) Memory Leaks
- Dispose controllers: TextEditingController, AnimationController, ScrollController
- Cancel streams: StreamSubscription.cancel()
- Close sinks: StreamController.close()
- Remove listeners: removeListener() in dispose()

### Game Development Memory Leaks
- Return objects to pools instead of destroying
- Unload unused assets/scenes
- Clear texture caches when switching levels
- Dispose of physics bodies properly
- Remove event handlers on object destroy

### Code Review Checklist for Memory Leaks
When reviewing code, ALWAYS check:
- [ ] Every useEffect has appropriate cleanup
- [ ] Every addEventListener has removeEventListener
- [ ] Every setInterval/setTimeout has clearInterval/clearTimeout
- [ ] Every subscription has unsubscribe
- [ ] Async operations check if component is mounted
- [ ] Large data structures are cleaned up
- [ ] Third-party library resources are disposed

---

## AI Asset Generation Workflow

**For Game Textures**:
1. Use ComfyUI or SD WebUI
2. Prompt: "seamless [material] texture, 4k, tileable, PBR"
3. Generate multiple variations
4. Post-process in image editor if needed
5. Test in game engine

**For Sprites**:
1. Prompt: "2D game sprite, [style], transparent background"
2. Use consistent art style across assets
3. Ensure proper resolution for target platform
4. Create sprite sheets for animations

**For UI Icons**:
1. Prompt: "game UI icon, [item], clean design, 512x512"
2. Maintain consistent style
3. Export in multiple sizes
4. Test visibility at small sizes

---

## Common Commands Reference

**Quick shortcuts** (use these frequently):
```bash
# Check development environment
~/.claude/scripts/dev-check.sh

# Initialize project type detection
~/.claude/scripts/project-init.sh

# AI asset generation helper
~/.claude/scripts/ai-asset-helper.sh texture ./assets

# MCP servers
claude mcp list
```

---

## Notes for Claude

**When working with me**:
- Ask clarifying questions if requirements are unclear
- Suggest best practices and optimizations
- Point out potential issues or security concerns
- Provide multiple approaches when appropriate
- Explain complex concepts when implementing new features
- Use the hooks system for auto-formatting (already configured globally)
- Reference this memory for coding style and preferences
- Remember I work across web, mobile, and game development

**Project context**:
- Always check for a project-level CLAUDE.md first
- Use dynamic exploration agents for large codebases
- Search with Grep/Glob for specific files or patterns
- Read relevant files before making changes
- Test changes when possible

**Communication style**:
- Be concise but thorough
- Use code examples
- Explain the "why" not just the "what"
- No unnecessary superlatives or praise
- Focus on facts and solutions

---

---

## Working Principles

For detailed working principles and best practices:
@~/.claude/WORKING_PRINCIPLES.md

---

## Antigravity Rules (Synced from GEMINI.md)

### Build & Server Management
1. Always clear the build and restart the dev server before testing any changes
2. Ensure no duplicate servers are running for the same project before starting a new one
3. Check for and terminate orphaned processes that might interfere with the current development session

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

### Code Quality Analysis (Core Deslop Principles)

#### Priority Matrix for Fixes
| Level | Type | Examples | Action |
|-------|------|----------|--------|
| **P0** | Critical | Security, data loss, unvalidated input | Immediately |
| **P1** | High | Missing error handling, unclear ownership | This PR |
| **P2** | Medium | DRY (3+ occurrences), god classes | When touching file |
| **P3** | Low | Magic numbers, naming, minor duplication | If time permits |
| **P4** | Optional | Formatting, comment cleanup | Boy Scout Rule |

#### Quick Diagnostic Checklist
When writing or reviewing code, watch for these symptoms:
- Functions > 50 lines → Extract smaller functions
- Deep nesting (3+ levels) → Use guard clauses, exit early
- Copy-pasted code (3+ times) → Apply DRY (Rule of Three)
- Magic numbers/strings → Use named constants
- Class doing many things → Apply Single Responsibility Principle
- Long parameter lists (5+) → Consider config object or builder pattern
- Message chains (`a.b().c().d()`) → Law of Demeter violation
- Silent failures → Add fail-fast behavior, proper logging

#### Principle Tensions (When Rules Conflict)
- **DRY vs. Coupling**: Duplication is cheaper than wrong abstraction (wait for Rule of Three)
- **YAGNI vs. Extensibility**: Build for today; keep code malleable for tomorrow
- **KISS vs. DRY**: Three obvious lines beat one clever line
- **Fail-Fast vs. Resilience**: Fail fast for bugs; retry with backoff for operational failures
- **Encapsulation vs. Testing**: Test public interface; needing to test internals signals design issues

#### Additional Principles (Always Apply)
- **Law of Demeter**: Only talk to immediate friends (avoid `a.b.c.d` chains)
- **Command-Query Separation**: Methods return data OR mutate state, never both
- **Parse, Don't Validate**: Transform input into types that make illegal states impossible
- **Boy Scout Rule**: Leave code cleaner than you found it
- **Idempotency**: Multiple executions should produce same result as one (critical for APIs)

---

## Deslop Analysis (Full Code Quality Review)

For comprehensive code quality analysis against 50+ clean code principles:
@~/.claude/deslop.md

**When to trigger full deslop analysis automatically:**
- After completing a significant feature implementation
- Before creating a pull request
- When refactoring existing code
- When reviewing code that feels "off" or overly complex
- Periodically on active projects (every few days of development)

---

## Clawd - Autonomous Claude Code Orchestration

**Clawd** is installed globally and orchestrates autonomous Claude Code sessions for multi-phase development tasks.

### When to Use Clawd

Trigger Clawd when the user requests:
- "Run this autonomously" / "Use Clawd" / "Run in background"
- "Implement this feature end-to-end"
- "Fix all the bugs" / "Refactor the entire module"
- "Run perpetually" / "Keep improving"
- Large multi-step tasks that benefit from autonomous planning and execution

### Clawd Commands

```bash
# Interactive mode (recommended for new tasks)
clawd

# Non-interactive single task
clawd --non-interactive "Implement user authentication with OAuth"

# Perpetual mode (runs continuously, adding improvements)
clawd --perpetual "Continuously improve test coverage and fix bugs"

# With specific project context
cd ~/repos/aphos && clawd "Add guild chat feature"
```

### Configured Projects

Clawd knows about these projects (in `~/.clawd/config.json`):
- **aphos** - Channel-based social RPG game
- **shitcoin-bot** - Polymarket trading bot
- **ez-crm** - Legal case management system
- **bmi-calculator** - Health tracking mobile app
- **bills-tracker** - Subscription tracker app
- **screen-translator** - OCR translation app
- **linklounge** - Link-in-bio platform

### How to Orchestrate

When user asks for autonomous execution:

1. **Identify the task scope** - Is it a single feature, bug fix, or ongoing improvement?
2. **Choose the mode**:
   - Single task → `clawd --non-interactive "task"`
   - Interactive planning → `clawd`
   - Continuous improvement → `clawd --perpetual "task"`
3. **Run in tmux** for long-running tasks:
   ```bash
   tmux new -s clawd-session
   clawd --perpetual "task"
   # Detach: Ctrl+B then D
   ```
4. **Monitor progress** - Clawd creates `PROJECT_PLAN.md` and logs execution

### Safety Notes
- Clawd runs with `--dangerously-skip-permissions` (auto-executes commands)
- Always review `PROJECT_PLAN.md` before approving execution
- Use `--non-interactive` for single, well-defined tasks
- Use `--perpetual` carefully - it runs until stopped (Ctrl+C)

### Example Orchestration Responses

**User**: "Use clawd to add dark mode to linklounge"
**Claude**: I'll start Clawd for this task:
```bash
cd ~/repos/linklounge && clawd --non-interactive "Add dark mode theme support with system preference detection and manual toggle"
```

**User**: "Run clawd perpetually on aphos to improve code quality"
**Claude**: I'll start Clawd in perpetual mode. This will run continuously until you stop it:
```bash
tmux new -s clawd-aphos -d 'cd ~/repos/aphos && clawd --perpetual "Continuously improve code quality: fix lint errors, add missing tests, refactor complex functions, and address TODO comments"'
```
You can check progress with `tmux attach -t clawd-aphos` and stop with Ctrl+C.

---

**Last Updated**: 2026-01-20
**Auto-loaded**: Every Claude Code session globally
**Synced with**: ~/.gemini/GEMINI.md (Antigravity rules)
