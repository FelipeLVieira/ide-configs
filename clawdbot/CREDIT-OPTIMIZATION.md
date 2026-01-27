# Claude Credit Optimization

Strategies to reduce Claude API usage while maintaining productivity.

## 3-Tier Architecture (2026-01-26)

| Tier | Tool | Cost | Frequency | Purpose |
|------|------|------|-----------|---------|
| 1 | Bash scripts (launchd) | FREE | Every 15 min | Cleanup, monitoring |
| 2 | Sonnet cron jobs | ~$0.05/run | Every 30 min | Research, health checks |
| 3 | Opus heartbeat | ~$0.10/run | Every 60 min | Quick connectivity only |

### Key Insight: Separate Mechanical from Intelligent Work
- **Mechanical** (kill processes, clean files) → bash scripts (zero tokens)
- **Research** (analyze data, write strategies) → Sonnet cron (cheap)
- **Orchestration** (talk to human, complex decisions) → Opus (expensive, minimal)

## Cron vs Persistent Sessions

| Approach | Cost/Run | Context | Model |
|----------|----------|---------|-------|
| Fresh cron session ✅ | Flat ~$0.05 | Fresh each run | Sonnet |
| Persistent session ❌ | Growing | Accumulates | Opus |
| Multi-agent swarm ❌ | 5-20x more | Per-agent | Any |
| sessions_spawn ⚠️ | Low per-run | Fresh | Configurable |

**Winner:** Fresh isolated cron sessions with file-based persistence.
Confirmed by both Claude and Grok research (2026-01-26).

## File-Based Memory (Zero Cost Between Runs)

```
Session Start → Read Files → Work → Write Results → Session End
     ↑                                                    |
     └────── Markdown files persist for free ─────────────┘
```

- Goals: Static prompt files (~/clawd/prompts/*.md)
- Research: Markdown files (~/clawd/memory/shitcoin-brain/*.md)
- Bot state: Logs + JSON (~/repos/shitcoin-bot/logs/)
- Health: JSON output (/tmp/clawdbot/*.json)

## Use Free Resources First

Before asking Claude:
1. **Grok** (x.com/i/grok) — Free with X Premium
2. **X/Twitter** — bird search for real-time info
3. **Web search** — Brave API
4. **Reddit/Stack Overflow** — via web_fetch

## Current Model Configuration (2026-01-27)

**Local Models (FREE)**:
- **Mac Mini**: `qwen3:8b` (5GB RAM, reasoning enabled) — heartbeats, sub-agents
- **MacBook**: `qwen3:8b`, `devstral-24b`, `gpt-oss:20b` — development, fallbacks

**API Models**:
- **Primary**: `anthropic/claude-opus-4-5` — main conversations, complex reasoning
- **Fallback**: `anthropic/claude-sonnet-4-5` — cron jobs, automated tasks

**Fallback Chain**:
1. Sonnet 4.5 → 2. devstral-24b (MacBook) → 3. gpt-oss:20b (MacBook) → 4. qwen3:8b (Mac Mini)

## Model Selection Guide

| Task | Model | Why |
|------|-------|-----|
| Heartbeats | qwen3:8b (local) | FREE, good enough for periodic checks |
| Sub-agents | qwen3:8b (local) | FREE, handles most automation tasks |
| Cron jobs | Sonnet 4.5 | Fresh context, 70% cheaper than Opus |
| Code generation | devstral-24b (local) or Sonnet | Specialized code models |
| Complex reasoning | Opus 4.5 | Best quality when needed |
| Human conversation | Opus 4.5 | Main session quality |

## Daily Cost Estimate (~$3/day, down from ~$15+)

```
Healer Bot (Sonnet): 24 runs x $0.05 = ~$1.20
Cleaner Bot (Sonnet): 24 runs x $0.03 = ~$0.72
App Store Manager (qwen3:8b): 3 runs x $0.00 = FREE
Heartbeat (qwen3:8b): 24 runs x $0.00 = FREE
Sub-agents (qwen3:8b): ~10 runs x $0.00 = FREE
Main session (Opus): ~5 conversations = ~$1.50
Total: ~$3.42/day (90% reduction from $15+)
```

**Key Savings**:
- Heartbeats: $0.48 → FREE (qwen3:8b local)
- Sub-agents: $2.00+ → FREE (qwen3:8b local) 
- App monitoring: $0.60 → FREE (qwen3:8b local)
- Total local compute: ~$3+ daily savings
