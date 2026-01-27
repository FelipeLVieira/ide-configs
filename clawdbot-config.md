# Clawdbot Configuration

Multi-machine Clawdbot setup with Ollama integration for local LLM inference.

> **Last updated**: 2026-01-27 — qwen3-coder:30b primary, gemma3:12b added, gpt-oss:20b removed, concurrency bump

## Model Routing Strategy

### Architecture Philosophy: Reasoning-First, Swap-Safe, Cost-Second

**MacBook thinking is OFF to maximize concurrency:**
- `thinkingDefault: "off"` — Disabled to reduce token usage and allow higher parallelism with local models
- **Valid thinking levels**: off, minimal, low, medium, high, xhigh
- **Rationale**: Local Ollama models have NO rate limits — turning off thinking allows more concurrent requests
- **Native reasoning support**: Only qwen3:8b and phi4:14b have reasoning=true among local models

**Mac Mini swap protection is NON-NEGOTIABLE:**
- Mac Mini has 16GB RAM — heavy models cause swap death
- Only qwen3:8b (5GB) and phi4:14b (9GB) are allowed in Mac Mini auto-fallback chains

### Model Tiers

| Tier | Models | Cost | Use Cases |
|------|--------|------|-----------|
| **1 — Frontier** | Claude Opus 4.5 | $$$ | Main chat, complex reasoning (MacBook + Windows) |
| **2 — Smart API** | Claude Sonnet 4.5 | $$ | Cron jobs (isolated sessions), API fallback |
| **3 — Free powerful** | qwen3-coder:30b | FREE | Sub-agents, heartbeats (MacBook primary, 30B params) |
| **4 — Free coding** | devstral-24b | FREE | Heavy coding tasks (MacBook ONLY, 48GB) |
| **5 — Free light** | qwen3:8b, gemma3:12b, phi4:14b | FREE | Quick tasks, vision (gemma3 has image input!), Mac Mini |
| **6 — Free research** | Grok, Brave Search, web_fetch | FREE | Research before burning tokens |

### Available Models

| Model | Params | Context | MaxTokens | Reasoning | Image | Machines |
|-------|--------|---------|-----------|-----------|-------|----------|
| **qwen3-coder:30b** | 30B | 40960 | 40960 | [NO] | [NO] | MacBook ONLY (48GB) — NEW PRIMARY |
| **devstral-small-2:24b** | 24B | 32768 | 8192 | [NO] | [NO] | MacBook ONLY (48GB) |
| **gemma3:12b** | 12B | 32768 | 8192 | [NO] | [OK] | MacBook ONLY (48GB) — NEW, has image input! |
| **qwen3:8b** | 8B | 40960 | 40960 | [OK] true | [NO] | Both Macs |
| **phi4:14b** | 14B | 16384 | — | [OK] true | [NO] | Mac Mini |

**Removed:**
- [NO] gpt-oss:20b — Deleted from MacBook (replaced by qwen3-coder:30b)
- [NO] qwen3-fast:8b — Deleted from Mac Mini (duplicate of qwen3:8b, freed 5.2GB disk)

## Model Routing Table (All 3 Machines)

### MacBook Pro (48GB RAM) — Orchestrator

| Setting | Model | Notes |
|---------|-------|-------|
| **Main** | `anthropic/claude-opus-4-5` | Frontier reasoning |
| **Fallbacks** | Sonnet 4.5 -> devstral-24b -> gemma3:12b | All safe on 48GB |
| **Heartbeat** | `ollama-macbook/qwen3-coder:30b` | FREE, 30B params |
| **Sub-agents primary** | `ollama-macbook/qwen3-coder:30b` | FREE, 30B coding model |
| **Sub-agent fallbacks** | qwen3:8b (macbook) -> qwen3:8b (mini) -> Sonnet 4.5 | Local-first cascade |
| **Default fallbacks** | devstral-24b -> gemma3:12b -> qwen3:8b (mini) -> phi4:14b (mini) | Cross-machine |
| **Thinking** | `thinkingDefault: "off"` | Off for higher concurrency |
| **maxConcurrent** | 8 (was 4) | Local models have no rate limits |
| **subagents.maxConcurrent** | 10 (was 5) | Ollama queues requests |
| **cron.maxConcurrentRuns** | 6 | New setting |

### Mac Mini (16GB RAM) — Always-On Server

| Setting | Model | Notes |
|---------|-------|-------|
| **Main** | `ollama/qwen3:8b` (local) | FREE, reasoning=true |
| **Fallbacks** | phi4:14b -> MacBook qwen3-coder:30b -> MacBook devstral -> MacBook gemma3:12b -> Sonnet -> Opus | Full local-to-cloud cascade |
| **Heartbeat** | `ollama/qwen3:8b` (local) | FREE, reasoning=true |
| **Sub-agents** | `ollama/qwen3:8b` -> phi4:14b -> MacBook qwen3-coder -> MacBook devstral -> MacBook gemma3:12b -> Sonnet -> Opus | Cross-machine fallback |
| **Thinking** | `thinkingDefault: "medium"` | Mac Mini unchanged |

> **phi4:14b now available** — Microsoft Phi-4 (14B params, 9.1GB, reasoning=true, contextWindow=16384). Safe for Mac Mini 16GB RAM.

### Windows MSI (No local Ollama)

| Setting | Model | Notes |
|---------|-------|-------|
| **Main** | `anthropic/claude-opus-4-5` | Frontier reasoning |
| **Fallbacks** | Sonnet -> MacBook devstral -> MacBook qwen3-coder -> MacBook gemma3:12b -> Mac Mini qwen3 | Dual-provider |
| **Heartbeat** | `ollama-macmini/qwen3:8b` | FREE, via Tailscale |
| **Sub-agents** | Mac Mini qwen3 -> MacBook qwen3-coder:30b -> MacBook devstral -> MacBook gemma3:12b -> Sonnet -> Opus | Mac Mini first (always-on) |
| **Thinking** | `thinkingDefault: "medium"` | Windows unchanged |

## Ollama Providers

### Provider: `ollama` (Mac Mini — always-on)
```yaml
baseUrl: http://127.0.0.1:11434 # local on Mac Mini
tailscaleUrl: http://100.115.10.14:11434 # remote access
models:
  - qwen3:8b # PRIMARY (5GB, reasoning=true, SAFE for 16GB)
  - phi4:14b # NEW: Microsoft Phi-4 (9.1GB, reasoning=true, contextWindow=16384)
note: Only qwen3:8b and phi4:14b are registered for auto-fallback (swap protection)
```

### Provider: `ollama-macbook` (MacBook Pro — heavy compute)
```yaml
baseUrl: http://100.125.165.107:11434 # Tailscale IP (reliable)
# Alternative: http://felipes-macbook-pro-2.local:11434
models:
  - qwen3-coder:30b # PRIMARY for sub-agents/heartbeats (30B, contextWindow=40960)
  - devstral-small-2:24b # Heavy coding (48GB RAM safe)
  - gemma3:12b # NEW: Vision-capable model (image input!, contextWindow=32768)
  - qwen3:8b # Lightweight fallback (reasoning=true, contextWindow=40960)
```

### Windows-specific providers
```yaml
ollama-macbookpro:
  baseUrl: http://100.125.165.107:11434 # MacBook via Tailscale
  models: [qwen3-coder:30b, devstral-24b, gemma3:12b, qwen3:8b]

ollama-macmini:
  baseUrl: http://100.115.10.14:11434 # Mac Mini via Tailscale
  models: [qwen3:8b] # ONLY qwen3:8b (swap protection)
```

## Cross-Machine Fallback

Both Macs have **bidirectional Ollama fallback** — if one machine's Ollama fails, the other catches it automatically.

### Mac Mini -> MacBook fallback
```
qwen3:8b (local) -> phi4:14b (local) -> MacBook qwen3-coder:30b ->
MacBook devstral-24b -> MacBook gemma3:12b -> Sonnet -> Opus
```

### MacBook -> Mac Mini fallback
```
Opus -> Sonnet -> devstral-24b -> gemma3:12b -> qwen3:8b (local) ->
Mac Mini qwen3:8b (remote)
```

### Windows -> Both Macs
```
Opus -> Sonnet -> MacBook qwen3-coder:30b -> MacBook devstral ->
MacBook gemma3:12b -> MacBook qwen3 -> Mac Mini qwen3
```

**Why it matters:** Zero downtime. If Mac Mini Ollama crashes, MacBook picks up. If MacBook sleeps, Mac Mini keeps heartbeats alive.

## Memory Search (Semantic Recall)

Clawdbot uses Gemini embeddings for semantic memory search across MEMORY.md and memory/*.md files.

| Setting | Value |
|---------|-------|
| **Provider** | gemini |
| **Model** | gemini-embedding-001 |
| **Purpose** | Semantic recall -- finds relevant memories by meaning, not keyword match |
| **Indexed files** | MEMORY.md, memory/*.md |

This enables the bot to recall past context even when the exact wording differs from the query. Powered by Google's Gemini embedding model (free tier).

## Context Pruning

Manages context window size by trimming old messages when the conversation grows too long.

| Setting | Value |
|---------|-------|
| **Mode** | cache-ttl |
| **keepLastAssistants** | 3 |
| **softTrimRatio** | 0.5 |
| **hardClearRatio** | 0.7 |

**How it works:**
- Keeps the last 3 assistant messages intact (never pruned)
- At 50% context usage: soft trim -- removes oldest cached messages
- At 70% context usage: hard clear -- aggressively prunes to free space
- Mode `cache-ttl` means messages expire based on cache time-to-live rather than fixed counts

## Compaction

Automatic conversation compaction to prevent context overflow.

| Setting | Value |
|---------|-------|
| **Mode** | safeguard |
| **memoryFlush** | enabled |
| **softThresholdTokens** | 100,000 |

**How it works:**
- Mode `safeguard` triggers compaction only when approaching token limits (not proactively)
- At 100k tokens: compaction kicks in, summarizing older context
- `memoryFlush` writes important context to memory files before compacting, preventing information loss
- Works alongside context pruning -- pruning trims individual messages, compaction summarizes entire sections

## Auth Cooldowns

Rate limiting and backoff for API authentication failures and billing issues.

| Setting | Value |
|---------|-------|
| **billingBackoffHours** | 1 |
| **billingMaxHours** | 5 |
| **failureWindowHours** | 1 |

**How it works:**
- On billing/quota errors: backs off for 1 hour initially
- Each subsequent billing failure doubles the backoff, capped at 5 hours max
- Auth failures within a 1-hour window are grouped (prevents rapid retry loops)
- After the backoff period, the provider is retried automatically

## Cron Jobs

### MacBook Pro (5 jobs + cron.maxConcurrentRuns=6)
| Job | Schedule | Model | Session | Purpose |
|-----|----------|-------|---------|---------|
| **Cleaner Bot** | Hourly | Sonnet 4.5 | isolated | Deep cleanup |
| **Healer Bot v3** | Hourly | Sonnet 4.5 | isolated | Self-healing + swap monitoring |
| **App Store Manager** | 3x/day (9/3/9 EST) | Sonnet 4.5 | isolated | iOS app monitoring |
| **R&D AI Research** | Every 6 hours | Sonnet 4.5 | isolated | Monitors X/Twitter, Reddit, Google for AI improvements. See [rd-research-team.md](rd-research-team.md) |
| **Clear Sessions** | Weekly (Sun midnight) | — | — | Stale session cleanup |

### Mac Mini (3 jobs)
| Job | Schedule | Model | Session | Purpose |
|-----|----------|-------|---------|---------|
| **Shitcoin Brain** | Every 10 min | qwen3:8b | isolated | Trading research |
| **Shitcoin Quant** | Every 15 min | qwen3:8b | isolated | Technical analysis |
| **System Health Monitor** | Every 30 min | qwen3:8b | isolated | Resource monitoring |

**Why Sonnet for cron?** Self-healing requires reasoning, diagnostics, web research. ~$0.05-0.15 per run.

**Cleaned up (removed):**
- [NO] iOS App Store Monitor (old) — Replaced by App Store Manager
- [NO] Project Health Monitor — Replaced by Healer Bot v3
- [NO] EZ-CRM / LinkLounge / Aphos Continuous — Disabled

## Event Watcher (Launchd)

24/7 self-healing bash loop — zero LLM tokens.

- **Service**: `com.clawdbot.event-watcher`
- **Interval**: Every 60 seconds
- **Cost**: FREE (pure bash)
- **Logs**: `/tmp/clawdbot/events.jsonl`
- **Monitors**: Ollama, pm2, zombies, simulators; auto-heals instantly

## Ollama Performance Tuning

Both machines run with optimized settings:

```bash
OLLAMA_HOST=0.0.0.0 # Listen on all interfaces
OLLAMA_FLASH_ATTENTION=1 # 2-3x faster, 40% less memory
OLLAMA_KV_CACHE_TYPE=q8_0 # 4x memory reduction vs f16
```

## Cost Savings

| Task | Before | After | Savings |
|------|--------|-------|---------|
| Heartbeats | Claude Sonnet ($) | qwen3-coder:30b (FREE) | 100% |
| Sub-agents (coding) | Claude Sonnet ($) | qwen3-coder:30b / devstral-24b (FREE) | 100% |
| Sub-agents (general) | Claude Sonnet ($) | qwen3-coder:30b (FREE) | 100% |
| Sub-agents (vision) | Claude Sonnet ($) | gemma3:12b (FREE, image input!) | 100% |
| Self-healing | Claude Sonnet ($) | event-watcher bash (FREE) + Sonnet cron | 95% |
| Windows tasks | Claude API only ($$$) | MacBook + Mac Mini Ollama (FREE) | 90% |

**Estimated monthly savings**: $150-200 USD

## Troubleshooting

### Model Not Found
```bash
ollama list # Check available models
ollama pull qwen3:8b # Pull missing model
```

### Mac Mini Swap Issues
```bash
sysctl vm.swapusage # Check swap usage
ollama ps # Check loaded models
# If swap > 8GB, unload heavy models:
curl -X DELETE http://localhost:11434/api/generate -d '{"model":"gpt-oss:20b"}'
```

### Connection Refused (Remote)
```bash
echo $OLLAMA_HOST # Should be 0.0.0.0
curl http://localhost:11434/api/tags # Local
curl http://100.115.10.14:11434/api/tags # Tailscale (Mac Mini)
curl http://100.125.165.107:11434/api/tags # Tailscale (MacBook)
```

## Fix History

### 2026-01-27: qwen3-coder:30b, gemma3:12b, Concurrency Bump
**Changes:**
- **New MacBook models**: qwen3-coder:30b (30B, primary for sub-agents/heartbeats), gemma3:12b (12B, image input!)
- **Removed**: gpt-oss:20b — replaced by qwen3-coder:30b (better coding, larger context)
- **Heartbeat model**: Changed from `ollama/qwen3:8b` to `ollama-macbook/qwen3-coder:30b`
- **Sub-agent primary**: Changed to `ollama-macbook/qwen3-coder:30b`
- **thinkingDefault**: Changed from "medium" to "off" (reduces token usage, enables higher concurrency)
- **Concurrency bump**: maxConcurrent 4→8, subagents.maxConcurrent 5→10, cron.maxConcurrentRuns=6
- **Why higher concurrency**: Local Ollama models have NO rate limits (unlike Anthropic API which returns 429s). Ollama simply queues requests, so more concurrent agents = faster throughput without errors.
- **R&D Research cron**: Added every-6-hour cron for AI research (see rd-research-team.md)

### 2026-01-27: Config Audit & Swap Protection Enforcement
**Problem**: gpt-oss:20b (14GB) in Mac Mini auto-fallback chains was causing 15.6GB swap death. Windows only had Mac Mini as Ollama provider. qwen3-fast:8b was a dead reference.

**Fixed:**
- Removed gpt-oss:20b from ALL Mac Mini auto-fallback chains (all 3 machines' configs)
- Windows MSI: Added MacBook Pro as second Ollama provider (ollama-macbookpro)
- Mac Mini: Changed MacBook URL from .local hostname -> Tailscale IP (100.125.165.107)
- Mac Mini: Added qwen3:8b to local ollama models array (was empty)
- Deleted qwen3-fast:8b model (freed 5.2GB disk)
- Deleted unnecessary files: CONTEXT_BUFFER.md, OPTIMIZATION_RULES.md, model-recovery.ps1
- Killed 5 stale tmux bot sessions on Mac Mini

### 2026-01-27: Windows MSI Dual-Provider
**Problem**: Windows only routed through Mac Mini — limited to qwen3:8b.

**Fixed:**
- Added `ollama-macbookpro` provider pointing to MacBook Tailscale IP
- Windows fallbacks now include MacBook's devstral-24b and gpt-oss:20b
- Sub-agents prefer Mac Mini qwen3:8b (always-on) then MacBook models

### 2025-07-28: Windows MSI routing through Mac Mini
**Problem**: Windows was 100% Claude API — every task burned credits.

**Fixed:**
- Added `ollama-macmini` provider pointing to Mac Mini Tailscale IP
- Windows primary heartbeats -> Mac Mini qwen3:8b (FREE)

### 2025-07-27: Credit Leak Fix (legacy model removal)
**Problem**: Legacy 7B model deleted but still referenced in configs -> fallback to expensive Claude API.

**Fixed:**
- Removed all dead model references
- Mac Mini primary -> gpt-oss:20b (later changed to qwen3:8b for swap safety)

---

## References

- [Three-Machine Architecture](infrastructure/three-machine-architecture.md) — Full infrastructure overview
- [Ollama Setup](ollama-setup.md) — Installation & configuration
- [Tailscale](tailscale.md) — Network configuration
- [Dev Teams](dev-teams.md) — Model assignment per project/bot
- [Hybrid Healing](clawdbot/HYBRID-HEALING.md) — Self-healing architecture
