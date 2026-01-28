# Local-First Bot Optimization

> **⚠️ PARTIALLY OUTDATED (Jan 28, 2026):** The "local-first" approach for auto-routing has been abandoned. ALL local Ollama models fail at tool-calling. All cron/sub-agents/heartbeats now use Anthropic Sonnet 4.5 exclusively. Local models are available for MANUAL use only. See [model-routing.md](../model-routing.md). The general principles below (file-based memory, bash scripts, research-first) still apply.

Maximize local compute, minimize API token usage.

## Core Principle

**Use Claude API for reasoning, not for data retrieval or monitoring.**

## Local Resources vs API Calls

| Task | [NO] Token-Heavy | [OK] Local-First |
|------|---------------|----------------|
| Bot status | Ask Claude to check | `tmux list-sessions` |
| File reading | Include in prompt | Read file, extract needed parts |
| Log analysis | Send full logs | `grep`, `jq`, `awk` locally |
| Git status | Ask Claude | `git log --oneline -5` |
| Port checking | Ask Claude | `lsof -i :port` |
| Process check | Ask Claude | `ps aux \| grep` |

## Memory Architecture (Token-Efficient)

### Tiered Memory System
```
~/clawd/
 memory/
    YYYY-MM-DD.md # Daily notes (raw)
    bot-states/ # Per-bot state (JSON)
       ez-crm.json
       ios-bmi.json
       ...
    summaries/ # Compressed weekly summaries
        week-YYYY-WW.md
 MEMORY.md # Curated long-term (human reviews)
 context-cache/ # Pre-computed context snippets
     project-summaries.json
     recent-changes.json
```

### Memory Rules
1. **Daily files:** Raw logs, auto-cleanup after 7 days
2. **Bot states:** Current context, JSON for fast parsing
3. **Weekly summaries:** Compress daily -> weekly automatically
4. **MEMORY.md:** Only significant learnings, human-curated

### Auto-Summarization (Cron Job)
```bash
# Weekly: Compress daily notes to summary
0 0 * * 0 ~/clawd/scripts/compress-memory.sh
```

## Context Window Optimization

### Pre-Computed Context
Instead of loading everything each session:

```json
// ~/clawd/context-cache/project-summaries.json
{
  "ez-crm": {
    "status": "active development",
    "stack": "Next.js, Supabase, TailwindCSS",
    "lastCommit": "abc123",
    "currentFocus": "authentication flow"
  },
  "aphos": {
    "status": "feature development",
    "stack": "Next.js, Three.js, WebSocket",
    "lastCommit": "def456",
    "currentFocus": "combat system"
  }
}
```

### Context Loading Script
```bash
#!/bin/bash
# ~/clawd/scripts/build-context.sh
# Run before bot sessions to pre-compute context

# Update project summaries
for repo in ~/repos/*/; do
  cd "$repo"
  PROJECT=$(basename "$repo")
  LAST_COMMIT=$(git log --oneline -1 2>/dev/null)
  BRANCH=$(git branch --show-current 2>/dev/null)
  # Write to JSON cache
done
```

## Monitoring Without API Calls

### Local Dashboard Data
The clawd-monitor already does this right:
- Reads `~/.clawdbot/` files directly
- Uses `clawdbot status --json` (no AI tokens)
- Scrapes tmux panes for bot output
- SSH for Mac Mini resources

### Health Check Script (No API)
```bash
#!/bin/bash
# ~/clawd/scripts/health-check.sh
# Run by cron, triggers API only on issues

ISSUES=0

# Check bots
for session in $(tmux list-sessions -F "#{session_name}" | grep "^bot-"); do
  if ! tmux has-session -t "$session" 2>/dev/null; then
    ISSUES=$((ISSUES + 1))
    echo "ISSUE: $session not running"
  fi
done

# Check ports
for port in 3000 4000 9009; do
  if ! lsof -i :$port | grep -q LISTEN; then
    echo "WARNING: Port $port not listening"
  fi
done

# Only alert if issues found
if [ $ISSUES -gt 0 ]; then
  # This is the only API call - when needed
  clawdbot agent --message "Health check found $ISSUES issues"
fi
```

## Bot Prompt Optimization

### Minimal Context Pattern
```
You are [BOT]. Project: [PROJECT].

Current state: (read from ~/clawd/memory/bot-states/[BOT].json)
Recent changes: (last 5 git commits)

Task: Continue development. Check state file first.
```

Instead of:
```
You are [BOT]. Here is your entire history, all memory files,
complete project documentation, full git log...
(10k tokens of context)
```

### State File as Primary Context
```json
{
  "lastActive": "2026-01-26T20:00:00Z",
  "currentTask": "Fix login validation",
  "context": {
    "files": ["src/auth/login.ts", "src/api/auth.ts"],
    "issue": "Users can't login with special chars",
    "approach": "Add input sanitization"
  },
  "blockers": [],
  "nextSteps": ["Write tests", "Deploy to staging"]
}
```

## Cycle Optimization

### 10-Minute Cycles = 144/day per bot
vs 60-second = 1440/day

### Smart Cycle Triggering
Instead of fixed intervals, trigger on events:
```bash
# Watch for file changes
fswatch -o ~/repos/ez-crm/src | while read; do
  # Only wake bot if significant changes
  CHANGES=$(git status --porcelain | wc -l)
  if [ $CHANGES -gt 5 ]; then
    # Wake the bot
  fi
done
```

## Research Without API

### Use Grok/X First
```bash
# Free research via bird CLI
bird search "react native error XYZ" -n 10

# Check if answer exists before asking Claude
bird read <error-related-tweet>
```

### Local Documentation
```bash
# Build local docs cache
~/clawd/docs-cache/
 react-native.md # Key concepts
 expo.md # Common issues
 supabase.md # API patterns
 threejs.md # 3D patterns
```

## Token Tracking

### Per-Session Budget
```json
// In bot state file
{
  "tokenBudget": {
    "daily": 50000,
    "used": 12340,
    "remaining": 37660
  }
}
```

### Cost Monitoring Script
```bash
# Parse session logs for cost
cat ~/.clawdbot/agents/main/sessions/*.jsonl | \
  jq -s '[.[].message.usage.cost.total // 0] | add'
```

## Summary: Token-Saving Hierarchy

1. **Local scripts first** (0 tokens)
2. **File/log parsing** (0 tokens)
3. **Grok/X research** (0 Claude tokens)
4. **Pre-computed context** (minimal tokens)
5. **Claude for reasoning** (targeted tokens)
