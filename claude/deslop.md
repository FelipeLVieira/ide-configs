# Deslop: Comprehensive Code Quality Analysis

**Purpose**: Deep analysis of code against 50+ clean code principles to identify and fix "slop" (code quality issues).

**When this file is referenced**: Perform a thorough code quality review of the specified files/directories.

---

## How to Use This Analysis

### Invocation
When triggered (manually via `@~/.claude/deslop.md` or automatically), analyze the target code against all principles below and:

1. **Read** the target file(s) or directory
2. **Scan** for violations organized by principle category
3. **Prioritize** using the Priority Matrix
4. **Report** findings with:
   - Principle violated
   - Location (file:line)
   - Before/after code examples
   - Priority level (P0-P4)
5. **Ask** user confirmation before implementing fixes

### Output Format
```
## Deslop Analysis: [target]

### P0 - Critical (Fix Immediately)
- [principle]: [file:line] - [description]
  ```before
  [problematic code]
  ```
  ```after
  [fixed code]
  ```

### P1 - High Priority
...

### Summary
- Total violations: X
- P0: X, P1: X, P2: X, P3: X, P4: X
- Recommended action: [suggestion]
```

---

## Part I: Clean Code Principles

### Simplicity & Minimalism

#### KISS (Keep It Simple, Stupid)
- Avoid unnecessary complexity
- Simpler solutions are easier to maintain, test, and debug
- If you can't explain it simply, it's too complex
- **Violation signs**: Overly clever code, unnecessary abstractions, premature optimization

#### YAGNI (You Aren't Gonna Need It)
- Build only what's needed NOW
- Don't add functionality until it's actually required
- Wait for proof (3+ use cases) before generalizing
- **Violation signs**: Unused parameters, empty extension points, speculative features

#### Small Functions (5-20 lines ideal)
- Functions should do ONE thing well
- Extract when exceeding 30 lines
- If you need comments to explain sections, extract those sections
- **Violation signs**: Functions > 50 lines, multiple levels of abstraction, section comments

#### Guard Clauses
- Exit early for edge cases and exceptions
- Flatten nested conditionals
- Put the happy path at the end, not nested inside
- **Violation signs**: Deep nesting (3+ levels), else blocks that could be guard clauses

### Clarity & Readability

#### Cognitive Load Management
- Working memory holds ~4 chunks; minimize extraneous load
- Group related concepts together
- Use consistent patterns and naming
- **Violation signs**: Too many concepts in one function, inconsistent patterns, surprising behavior

#### SLAP (Single Level of Abstraction Principle)
- Each function should operate at one abstraction level
- Don't mix high-level logic with low-level details
- **Violation signs**: Database queries next to business logic, UI code mixed with data processing

#### Self-Documenting Code
- Names should reveal intent
- Code should read like prose
- Comments explain WHY, not WHAT
- **Violation signs**: Cryptic names (x, temp, data), comments explaining obvious code

#### Documentation Discipline
- Code shows WHAT and HOW
- Comments explain WHY and WHY NOT
- Document decisions, not mechanics
- **Violation signs**: Outdated comments, commented-out code, excessive obvious documentation

#### Principle of Least Surprise
- Components should behave as users expect
- Follow conventions and patterns
- Side effects should be obvious from names
- **Violation signs**: Surprising return values, hidden side effects, unconventional API shapes

#### Elegance
- Minimize while accomplishing the goal
- Reveal domain insight through code structure
- Simple but not simplistic
- **Violation signs**: Over-engineered solutions, brute-force approaches where elegant ones exist

---

## Part II: Architecture Principles

### Organization & Structure

#### DRY (Don't Repeat Yourself)
- Every piece of knowledge has one authoritative location
- But: Incidental similarity ≠ duplication
- Apply Rule of Three: abstract on 3rd occurrence, not before
- **Violation signs**: Copy-pasted code (3+ times), same logic in multiple places, parallel changes needed

#### Single Source of Truth
- Each data point has one canonical location
- Derived data should be computed, not stored redundantly
- **Violation signs**: Same data stored in multiple places, sync issues, conflicting values

#### Separation of Concerns
- One concern per component
- High cohesion within, low coupling between
- **Violation signs**: UI code handling business logic, database code in components, mixed responsibilities

#### Modularity
- Hide design decisions behind simple interfaces
- Changes should be localized
- Modules should be replaceable
- **Violation signs**: Shotgun surgery (one change touches many files), leaky abstractions

### Coupling & Dependencies

#### Encapsulation
- Bundle data with the behavior that operates on it
- Tell objects what to do, don't ask for their data
- Hide internal state
- **Violation signs**: Getters used to extract data for external processing, exposed internals

#### Law of Demeter (Principle of Least Knowledge)
- Only talk to immediate friends
- One-dot rule: `a.method()` good, `a.b.c.method()` bad
- Reduces coupling and makes refactoring easier
- **Violation signs**: Long method chains, reaching through objects, train wrecks (`a.getB().getC().doThing()`)

#### Orthogonality
- Changes in one component shouldn't require changes in others
- Components should be independently deployable/testable
- **Violation signs**: Changing A requires changing B, tightly coupled modules

#### Dependency Injection
- Dependencies should be injected, not created internally
- Enables testing and flexibility
- **Violation signs**: `new` keyword inside business logic, hardcoded dependencies, difficulty mocking

#### Composition Over Inheritance
- Prefer combining objects over class hierarchies
- "Has-a" often beats "is-a"
- Avoid deep inheritance trees
- **Violation signs**: Deep inheritance (3+ levels), fragile base class problems, diamond inheritance

### Design Patterns

#### SOLID Principles

**S - Single Responsibility**: One reason to change per class/module
- **Violation signs**: Class with multiple unrelated methods, "and" in class description

**O - Open/Closed**: Open for extension, closed for modification
- **Violation signs**: Modifying existing code to add features, switch statements on types

**L - Liskov Substitution**: Subtypes must be substitutable for base types
- **Violation signs**: Type checking before method calls, different behavior in overrides

**I - Interface Segregation**: No client should depend on methods it doesn't use
- **Violation signs**: Fat interfaces, empty method implementations, unused dependencies

**D - Dependency Inversion**: Depend on abstractions, not concretions
- **Violation signs**: High-level modules importing low-level modules, no interface layer

#### Command-Query Separation (CQS)
- Commands change state, return nothing
- Queries return data, change nothing
- Never mix the two
- **Violation signs**: Methods that return data AND have side effects

#### Convention Over Configuration
- Sensible defaults that work out of the box
- Only configure when deviating from convention
- **Violation signs**: Excessive configuration for common cases, boilerplate setup code

---

## Part III: Reliability Principles

### Data & State

#### Parse, Don't Validate
- Transform input into types that make illegal states impossible
- Validation throws away information; parsing preserves it
- **Violation signs**: Validation followed by unsafe operations, trusting stringly-typed data

#### Immutability
- Once created, state cannot change
- Create new objects instead of mutating
- Enables thread safety and simpler reasoning
- **Violation signs**: Mutable shared state, unexpected mutations, defensive copying everywhere

#### Idempotency
- Multiple executions produce same result as one
- Critical for retries and distributed systems
- **Violation signs**: Operations that compound (double-charging, duplicate records)

### Robustness & Safety

#### Fail-Fast
- Detect and report errors immediately
- Validate at system boundaries
- Don't let bad data propagate
- **Violation signs**: Silent failures, error swallowing, late error detection

#### Design by Contract
- Explicit preconditions (what caller must provide)
- Explicit postconditions (what function guarantees)
- Invariants (what's always true)
- **Violation signs**: Implicit assumptions, undocumented requirements, surprising failures

#### Postel's Law (Robustness Principle)
- Be conservative in what you send
- Be liberal in what you accept
- But: Be strict about required data
- **Violation signs**: Overly strict input parsing, overly loose output format

#### Resilience
- Retry with exponential backoff for transient failures
- Circuit breakers for cascading failure prevention
- Graceful degradation over complete failure
- **Violation signs**: No retry logic, failures cascading through system, all-or-nothing operations

#### Principle of Least Privilege
- Minimum permissions necessary
- Default deny, explicit allow
- **Violation signs**: Over-permissive access, broad scopes, admin access for simple operations

### Maintainability & Operations

#### Boy Scout Rule
- Leave code better than you found it
- Small improvements with each commit
- Don't let quality degrade
- **Violation signs**: Ignoring small issues, "not my code" mentality, accumulating tech debt

#### Observability
- Make system behavior visible in production
- Structured logging with context
- Metrics for key operations
- Tracing for request flows
- **Violation signs**: Silent operations, missing logs, no metrics, difficult debugging

---

## Anti-Patterns Reference

### Structural Anti-Patterns
| Anti-Pattern | Symptoms | Fix |
|--------------|----------|-----|
| **God Class** | 500+ lines, 10+ responsibilities | Extract classes by responsibility |
| **Feature Envy** | Method uses other class's data more than own | Move method to data's class |
| **Shotgun Surgery** | One change touches 10+ files | Consolidate related code |
| **Long Method** | 50+ lines, multiple abstraction levels | Extract methods |
| **Large Class** | Too many instance variables | Split into focused classes |

### Behavioral Anti-Patterns
| Anti-Pattern | Symptoms | Fix |
|--------------|----------|-----|
| **Magic Numbers** | Hardcoded `86400`, `3.14159` | Named constants |
| **Message Chains** | `a.getB().getC().getD().doThing()` | Law of Demeter, encapsulation |
| **Dead Code** | Unused functions, unreachable branches | Delete it |
| **Speculative Generality** | Unused abstractions "for later" | YAGNI - delete it |
| **Cargo Cult** | Patterns used without understanding | Understand or remove |

### Data Anti-Patterns
| Anti-Pattern | Symptoms | Fix |
|--------------|----------|-----|
| **Primitive Obsession** | Using strings for emails, money, etc. | Value objects |
| **Data Clumps** | Same 3 params always together | Extract parameter object |
| **Parallel Arrays** | `names[i]`, `ages[i]` | Array of objects |

---

## Priority Matrix

| Level | Type | Examples | Action |
|-------|------|----------|--------|
| **P0** | Critical | Security vulnerabilities, data loss risks, unvalidated user input, SQL injection, XSS | Fix immediately, block PR |
| **P1** | High | Missing error handling, unclear data ownership, race conditions, no input validation | Must fix in this PR |
| **P2** | Medium | DRY violations (3+), god classes, missing tests, poor naming | Fix when touching file |
| **P3** | Low | Magic numbers, minor naming issues, small duplication (2x) | Fix if time permits |
| **P4** | Optional | Formatting, comment cleanup, style preferences | Boy Scout Rule |

### Effort Modifiers
- **Quick win** (< 5 min): Bump priority up one level
- **Risky change** (could break things): Bump priority down one level
- **Test code**: Lower standards acceptable (DAMP over DRY)
- **Prototype/spike**: Skip analysis entirely

---

## Special Considerations

### When NOT to Apply Strictly
- **Test code**: Prefer DAMP (Descriptive And Meaningful Phrases) over DRY
- **Prototypes**: Speed over quality is acceptable
- **Performance-critical code**: Sometimes clarity sacrificed for speed (document why)
- **Legacy code**: Incremental improvement, not wholesale rewrite

### Framework-Specific Notes
- **React**: Watch for useEffect cleanup, memoization abuse, prop drilling
- **Next.js**: Server/client boundary issues, hydration mismatches
- **Node.js**: Callback hell, unhandled promise rejections, memory leaks
- **TypeScript**: `any` escape hatches, improper type narrowing

---

## Automation Triggers

**Claude should automatically consider running deslop analysis when:**
1. User says "review this code" or "check for issues"
2. After completing a feature with 100+ lines of new code
3. User mentions code "feels wrong" or "could be cleaner"
4. Before suggesting a PR is ready
5. When asked to refactor or improve code quality
6. Periodically during long development sessions (offer to run)

**Do not run automatically when:**
- User is in rapid prototyping mode
- Explicitly asked to skip quality checks
- Working on throwaway/spike code
- Time-critical fixes where speed matters

---

**Source**: Adapted from [Theta-Tech-AI/llm-public-utils](https://github.com/Theta-Tech-AI/llm-public-utils/blob/production/slash_commands/deslop.md)
**Last Updated**: 2026-01-19
