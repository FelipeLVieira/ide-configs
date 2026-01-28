# Claude Credit Optimization

Strategies to reduce Claude API usage while maintaining reliability.

> **Last updated**: 2026-01-28 (late night) — Anthropic-only routing, cost analysis updated

## Architecture: Anthropic-Only (Jan 28, 2026)

### Why Not Local Models?
ALL 7 tested local Ollama models FAIL at tool-calling (Jan 2026 research):
- qwen3-coder: broken Jinja template
- devstral: hallucinates completions
- mistral-small3.2: ignores tools
- nemotron: 1 call then stops
- phi4-mini/phi4: echoes prompt
- gemma3: no tool support

**Result**: ALL cron/sub-agents/heartbeats use `anthropic/claude-sonnet-4-5`. No local model fallbacks.

### Current Cost Structure

| Tier | Tool | Cost | Purpose |
|------|------|------|---------|
| **FREE** | Grok, Brave, web_fetch | $0 | Research first — always |
| **FREE** | Event-watcher (bash) | $0 | 24/7 self-healing (launchd) |
| **FREE** | Local Ollama (manual) | $0 | Interactive text/vision queries |
| **$** | Sonnet 4.5 cron | ~$0.03-0.10/run | ALL cron + heartbeat + sub-agents |
| **$$** | Opus 4.5 main | ~$0.20/turn | Felipe's direct chat only |

### Daily Cost Breakdown

| Category | Cost/day | Monthly |
|----------|----------|---------|
| Cron jobs (7 jobs) | ~$6.22 | ~$187 |
| Heartbeat (24/day) | ~$0.48 | ~$14 |
| Sub-agents (~10/day) | ~$0.50 | ~$15 |
| Main session (Opus) | ~$2.00 | ~$60 |
| **TOTAL** | **~$9.20** | **~$276** |

### Savings Already Implemented

| Strategy | Savings | How |
|----------|---------|-----|
| Event-watcher (bash) | ~$30/mo | Replaced Opus self-healing checks |
| Cron isolation | ~$50/mo | Fresh sessions vs persistent (no context growth) |
| Research-first (Grok) | ~$20/mo | Free research before API calls |
| Sonnet over Opus | ~$100/mo | Cron/sub-agents use cheaper Sonnet |
| **Total saved** | **~$200/mo** | vs all-Opus approach |

## Key Principles

### 1. Separate Mechanical from Intelligent Work
- **Mechanical** (kill processes, clean files) → bash scripts (zero tokens)
- **Research** (analyze data, find info) → Grok/web_fetch (zero Claude tokens)
- **Agentic** (multi-step tool-calling) → Sonnet 4.5 (cheap, reliable)
- **Complex reasoning** → Opus 4.5 (expensive, Felipe's chat only)

### 2. Fresh Cron Sessions > Persistent Sessions
| Approach | Cost | Why |
|----------|------|-----|
| Fresh cron (current) | Flat ~$0.03-0.10/run | Context resets each run |
| Persistent session | Growing over time | Context accumulates → expensive |

### 3. File-Based Memory (Zero Cost Between Runs)
```
Session Start → Read Files → Work → Write Results → Session End
     ^                                                    |
      ─── Markdown files persist for free ───────────────
```

### 4. Report to clawd-status, Not Telegram
- Cron `deliver=false` → POST to `http://localhost:9010/api/log`
- Dashboard at port 9010 shows all cron results
- Only CRITICAL alerts go to Telegram

## Future Optimizations (Not Yet Implemented)

### Phase 2: Claude Haiku 4.5
- Haiku 4.5 at $1/$5 MTok is 3x cheaper than Sonnet
- Could save ~$60/month on cron jobs
- Needs testing for tool-calling reliability
- **Status**: Research complete, awaiting decision

### Phase 3: Improved Local Models
- Monitor Ollama releases for tool-calling fixes
- Bug #11621 (qwen3 template) is tracked
- If fixed, could route simple cron jobs to local models
- **Status**: Monitoring

## Use Free Resources First

Before asking Claude:
1. **Grok** (x.com/i/grok) — Free with X Premium
2. **Web search** — Brave API (free tier)
3. **web_fetch** — Direct URL content extraction
4. **X/Twitter** — Real-time info search
5. **Reddit/Stack Overflow** — via web_fetch

## References

- [Model Routing](../model-routing.md) — Routing details
- [Cron Schedule](../cron-schedule.md) — All cron jobs
- [Clawdbot Config](../clawdbot-config.md) — Full config
