# Model Routing — Detailed Documentation

How models are routed across all 3 machines in the Clawdbot ecosystem.

> **Last updated**: 2026-01-28 (late night) — Anthropic-only routing, ALL local models removed from fallback chains

---

## Routing Philosophy

### Before Jan 28 (Local-First)
```
Sub-agent → qwen3-coder:30b (local) → devstral-24b (local) → Sonnet 4.5 (API) → Opus 4.5 (API)
```
**Problem**: Local models hallucinate tool calls. devstral says "Task completed" after 1 command. Sub-agents fail silently.

### After Jan 28 (Anthropic-Only)
```
Sub-agent → Sonnet 4.5 (API) → Opus 4.5 (API)
Main chat → Opus 4.5 (API) → Sonnet 4.5 (API)
```
**Result**: 100% reliable tool-calling. Higher cost, but zero wasted runs.

---

## Current Routing (Jan 28, 2026)

### MacBook Pro — Orchestrator (runs ALL cron + heartbeat)

| Context | Primary | Fallback | Notes |
|---------|---------|----------|-------|
| Main session (Felipe chat) | `anthropic/claude-opus-4-5` | `anthropic/claude-sonnet-4-5` | Frontier reasoning |
| Heartbeat (60min) | `anthropic/claude-sonnet-4-5` | `anthropic/claude-opus-4-5` | Needs tools: exec, SSH, sessions, nodes, cron |
| Sub-agents | `anthropic/claude-sonnet-4-5` | `anthropic/claude-opus-4-5` | All need tool-calling |
| Cron jobs (all) | `anthropic/claude-sonnet-4-5` | `anthropic/claude-opus-4-5` | Hourly, staggered |
| **Thinking** | `off` | — | Saves tokens, enables higher concurrency |
| **maxConcurrent** | 8 | — | No Ollama rate limits apply (API only now) |
| **subagents.maxConcurrent** | 10 | — | |
| **cron.maxConcurrentRuns** | 6 | — | |

### Mac Mini — Always-On Node

| Context | Primary | Fallback | Notes |
|---------|---------|----------|-------|
| Main session | `anthropic/claude-sonnet-4-5` | `anthropic/claude-opus-4-5` | Node, not orchestrator |
| Sub-agents | `anthropic/claude-sonnet-4-5` | `anthropic/claude-opus-4-5` | Anthropic only |
| **Thinking** | `medium` | — | |

> Mac Mini is a **NODE** connected to the MacBook orchestrator. It does NOT run cron jobs independently.

### Windows MSI — Telegram Bot

| Context | Primary | Fallback | Notes |
|---------|---------|----------|-------|
| Main session | `anthropic/claude-sonnet-4-5` | `anthropic/claude-opus-4-5` | Telegram chat only |
| **Thinking** | `medium` | — | |

> Windows has **NO cron, NO heartbeat, NO sub-agents**. Just Telegram chat. Separate bot token (8506493579).

---

## What Was Removed (Jan 28 Late Night)

These models were REMOVED from ALL auto-fallback chains across ALL 3 machines:

| Model | Where It Was | Why Removed |
|-------|-------------|-------------|
| `ollama-macbook/devstral-small-2:24b` | MacBook fallback, sub-agent fallback | Hallucinates — says "Task completed" without doing work |
| `ollama-macbook/gemma3:12b` | MacBook fallback | No tool support at all |
| `ollama-macbook/mistral-small3.2:latest` | MacBook default | Returns text, ignores tools |
| `ollama-macbook/qwen3-coder:30b` | MacBook sub-agent primary | Broken Jinja template (Ollama bug #11621) |
| `ollama/phi4-mini` | Mac Mini default, all machines | Echoes prompt, never calls tools |
| `ollama/phi4:14b` | Mac Mini fallback | Echoes prompt, same as phi4-mini |

**These models are still INSTALLED on the machines for manual interactive use.** They just aren't in any auto-routing path.

---

## Local Models — Manual Use Only

### MacBook Pro (48GB)
| Model | Size | Manual Use Cases |
|-------|------|-----------------|
| mistral-small3.2:24b | 15 GB | General text generation, quick queries |
| gemma3:12b | 8 GB | Image analysis (vision-capable), text generation |

### Mac Mini (16GB)
| Model | Size | Manual Use Cases |
|-------|------|-----------------|
| phi4-mini | 2.5 GB | Quick text responses, testing |
| phi4:14b | 9.1 GB | Reasoning tasks (reasoning=true) |

### How to Use Manually
```bash
# Direct Ollama CLI
ollama run mistral-small3.2 "What is the capital of France?"

# Via API
curl http://localhost:11434/api/generate -d '{"model":"gemma3:12b","prompt":"Describe this image","images":["base64..."]}'
```

---

## Why Anthropic-Only?

### The Tool-Calling Problem
Every cron job, heartbeat, and sub-agent in Clawdbot needs tool-calling:
- `exec` — run shell commands
- `SSH` — connect to remote machines
- `browser` — web automation
- `web_fetch` — HTTP requests
- `sessions_list` — list active sessions
- `nodes` — manage connected nodes
- `cron` — manage cron jobs

ALL 7 tested local Ollama models FAILED at multi-step tool-calling. See [clawdbot-config.md#tool-calling-research-jan-2026](clawdbot-config.md#tool-calling-research-jan-2026).

### The devstral Problem (Root Cause of Jan 28 Failures)
Two iOS submission sub-agents failed on Jan 28 because:
1. Sub-agent requested Sonnet 4.5
2. Sonnet was rate-limited/slow
3. System fell back to `devstral-small-2:24b` (local Ollama)
4. devstral ran 1 command, then said "Task completed" (hallucinated completion)
5. Entire pipeline failed — no iOS builds submitted

**Fix**: Remove ALL local models from ALL fallback chains. If Sonnet is rate-limited, fall to Opus (more expensive but reliable).

### Cost vs Reliability
| Approach | Cost/day | Reliability |
|----------|----------|-------------|
| Local-first (before) | ~$0-2 | 30-50% (hallucinated outputs) |
| Anthropic-only (after) | ~$9-10 | ~99% (real tool-calling) |

The extra ~$7/day ($210/month) is worth it for zero wasted bot runs.

---

## Account Rotation & Auth

### Active Accounts
| Account | Role | Status |
|---------|------|--------|
| `wisedigital` | Primary | Active (rotated Jan 28) |
| `felipe.lv.90` | Secondary | Backup |

### Cooldowns (Updated Jan 28)
| Setting | Value | Purpose |
|---------|-------|---------|
| billingBackoffHours | 2 | Initial backoff on billing error |
| billingMaxHours | 8 | Max backoff cap |
| failureWindowHours | 2 | Group failures in this window |

When primary account hits rate limits, system automatically rotates to secondary. Cooldown prevents rapid retry loops.

---

## Future Considerations

### Haiku 4.5 (Phase 2 — Not Yet Implemented)
- Claude Haiku 4.5 at $1/$5 MTok is 3x cheaper than Sonnet
- Could save ~$60/month on cron jobs
- Needs testing for tool-calling reliability
- **Status**: Research complete, awaiting Felipe's decision

### Local Model Monitoring
- Continue monitoring Ollama releases for tool-calling fixes
- Bug #11621 (qwen3 template) is tracked
- LiteLLM proxy as future experiment for better local↔API translation

---

## References

- [Clawdbot Config](clawdbot-config.md) — Full configuration reference
- [Cron Schedule](cron-schedule.md) — All cron jobs and schedules
- [Three-Machine Architecture](infrastructure/three-machine-architecture.md) — Infrastructure overview
- [Dev Teams](dev-teams.md) — Bot roles per project
