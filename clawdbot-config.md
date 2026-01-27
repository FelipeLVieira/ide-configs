# Clawdbot Configuration

Multi-machine Clawdbot setup with Ollama integration for local LLM inference.

> **Last updated**: 2026-01-27 — Config audit, swap protection enforced, Windows dual-provider

## Model Routing Strategy

### Architecture Philosophy: Reasoning-First, Swap-Safe, Cost-Second

**ALL machines use thinking/reasoning by default:**
- `thinkingDefault: "low"` — Extended reasoning on all models that support it
- Reasoning = better decisions, fewer mistakes, less wasted work

**Mac Mini swap protection is NON-NEGOTIABLE:**
- Mac Mini has 16GB RAM — gpt-oss:20b (14GB) causes swap death
- Only qwen3:8b (5GB) is allowed in Mac Mini auto-fallback chains
- gpt-oss:20b exists on disk but is NEVER in automatic cascades

### Model Tiers

| Tier | Models | Cost | Use Cases |
|------|--------|------|-----------|
| **1 — Frontier** | Claude Opus 4.5 | $$$ | Main chat, complex reasoning (MacBook + Windows) |
| **2 — Smart API** | Claude Sonnet 4.5 | $$ | Cron jobs (isolated sessions), API fallback |
| **3 — Free local** | qwen3:8b (reasoning=true) | FREE | Heartbeats, sub-agents, quick tasks (all machines) |
| **4 — Free heavy** | devstral-24b, gpt-oss:20b | FREE | Heavy coding, general tasks (MacBook ONLY, 48GB) |
| **5 — Free research** | Grok, Brave Search, web_fetch | FREE | Research before burning tokens |

### Available Models

| Model | Params | Disk | RAM | Reasoning | Machines |
|-------|--------|------|-----|-----------|----------|
| **qwen3:8b** | 8B | 5.2 GB | ~6 GB | [OK] true | Both Macs |
| **devstral-small-2:24b** | 24B | 15 GB | ~18 GB | [NO] | MacBook ONLY (48GB) |
| **gpt-oss:20b** | 20B (DeepSeek-V3) | 13 GB | ~14 GB | [NO] | MacBook (safe), Mac Mini (on-demand ONLY) |

**Removed:**
- [NO] qwen3-fast:8b — Deleted from Mac Mini (duplicate of qwen3:8b, freed 5.2GB disk)

## Model Routing Table (All 3 Machines)

### MacBook Pro (48GB RAM) — Orchestrator

| Setting | Model | Notes |
|---------|-------|-------|
| **Main** | `anthropic/claude-opus-4-5` | Frontier reasoning |
| **Fallbacks** | Sonnet -> devstral-24b -> gpt-oss:20b -> qwen3:8b | All safe on 48GB |
| **Heartbeat** | `ollama/qwen3:8b` (local) | FREE, reasoning=true |
| **Sub-agents** | `ollama/qwen3:8b` -> macbook qwen3 -> macbook devstral -> gpt-oss -> Sonnet -> Opus | Local-first cascade |
| **Thinking** | `thinkingDefault: "low"` | Always |

### Mac Mini (16GB RAM) — Always-On Server

| Setting | Model | Notes |
|---------|-------|-------|
| **Main** | `ollama/qwen3:8b` (local) | FREE, reasoning=true |
| **Fallbacks** | MacBook qwen3 -> MacBook devstral -> MacBook gpt-oss -> Sonnet -> Opus | WARNING: NO local gpt-oss! |
| **Heartbeat** | `ollama/qwen3:8b` (local) | FREE, reasoning=true |
| **Sub-agents** | `ollama/qwen3:8b` -> MacBook qwen3 -> MacBook devstral -> MacBook gpt-oss -> Sonnet -> Opus | Cross-machine fallback |
| **Thinking** | `thinkingDefault: "low"` | Always |

> WARNING: **gpt-oss:20b is NOT in any Mac Mini auto-fallback chain.** If local qwen3:8b fails, it goes to MacBook, not to a bigger local model.

### Windows MSI (No local Ollama)

| Setting | Model | Notes |
|---------|-------|-------|
| **Main** | `anthropic/claude-opus-4-5` | Frontier reasoning |
| **Fallbacks** | Sonnet -> MacBook devstral -> MacBook gpt-oss -> MacBook qwen3 -> Mac Mini qwen3 | Dual-provider |
| **Heartbeat** | `ollama-macmini/qwen3:8b` | FREE, via Tailscale |
| **Sub-agents** | Mac Mini qwen3 -> MacBook qwen3 -> MacBook devstral -> MacBook gpt-oss -> Sonnet -> Opus | Mac Mini first (always-on) |
| **Thinking** | `thinkingDefault: "low"` | Always |

## Ollama Providers

### Provider: `ollama` (Mac Mini — always-on)
```yaml
baseUrl: http://127.0.0.1:11434 # local on Mac Mini
tailscaleUrl: http://100.115.10.14:11434 # remote access
models:
  - qwen3:8b # PRIMARY (5GB, reasoning=true, SAFE for 16GB)
note: gpt-oss:20b exists on disk but is NOT registered as auto-fallback
```

### Provider: `ollama-macbook` (MacBook Pro — heavy compute)
```yaml
baseUrl: http://100.125.165.107:11434 # Tailscale IP (reliable)
# Alternative: http://felipes-macbook-pro-2.local:11434
models:
  - qwen3:8b # PRIMARY for sub-agents (reasoning=true)
  - devstral-small-2:24b # Heavy coding (48GB RAM safe)
  - gpt-oss:20b # General fallback (48GB RAM safe)
```

### Windows-specific providers
```yaml
ollama-macbookpro:
  baseUrl: http://100.125.165.107:11434 # MacBook via Tailscale
  models: [devstral-24b, gpt-oss:20b, qwen3:8b]

ollama-macmini:
  baseUrl: http://100.115.10.14:11434 # Mac Mini via Tailscale
  models: [qwen3:8b] # ONLY qwen3:8b (swap protection)
```

## Cross-Machine Fallback

Both Macs have **bidirectional Ollama fallback** — if one machine's Ollama fails, the other catches it automatically.

### Mac Mini -> MacBook fallback
```
qwen3:8b (local) -> MacBook qwen3:8b -> MacBook devstral-24b ->
MacBook gpt-oss:20b -> Sonnet -> Opus
```

### MacBook -> Mac Mini fallback
```
Opus -> Sonnet -> devstral-24b -> gpt-oss:20b -> qwen3:8b (local) ->
Mac Mini qwen3:8b (remote)
```

### Windows -> Both Macs
```
Opus -> Sonnet -> MacBook devstral -> MacBook gpt-oss ->
MacBook qwen3 -> Mac Mini qwen3
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

| Job | Schedule | Model | Session | Purpose |
|-----|----------|-------|---------|---------|
| **Cleaner Bot** | Hourly | Sonnet 4.5 | isolated | Deep cleanup (both machines) |
| **Healer Bot v3** | Hourly | Sonnet 4.5 | isolated | Self-healing + swap monitoring |
| **App Store Manager** | 3x/day (9/3/9 EST) | Sonnet 4.5 | isolated | iOS app monitoring |
| **Clear Sessions** | Weekly (Sun midnight) | — | — | Stale session cleanup |

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
| Heartbeats | Claude Sonnet ($) | qwen3:8b (FREE) | 100% |
| Sub-agents (coding) | Claude Sonnet ($) | devstral-24b / qwen3:8b (FREE) | 100% |
| Sub-agents (general) | Claude Sonnet ($) | qwen3:8b (FREE) | 100% |
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
