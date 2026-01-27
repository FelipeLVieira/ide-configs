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

## Model Selection Guide

| Task | Model | Why |
|------|-------|-----|
| Research / summarization | Sonnet | Good enough, 70% cheaper |
| Code generation | Sonnet | Handles most coding well |
| Complex reasoning | Opus | Only when Sonnet is not enough |
| Human conversation | Opus | Main session quality |

## Daily Cost Estimate (~$5/day, down from ~$15+)

```
Research agents (Sonnet): 48 runs x $0.05 = ~$2.40
Health monitor (Sonnet): 12 runs x $0.03 = ~$0.36
Heartbeat (Opus): 24 runs x $0.02 = ~$0.48
Main session (Opus): ~5 conversations = ~$2.00
Total: ~$5.24/day
```
