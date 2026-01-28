# Clawdbot Configuration

Multi-machine Clawdbot setup with Anthropic-first model routing.

> **Last updated**: 2026-01-28 (late night) — Anthropic-only routing for all bots/cron/subagents, local models REMOVED from fallback chains, cron delivery disabled (→ clawd-status API), auth cooldowns increased

## Model Routing Strategy

### Architecture Philosophy: Anthropic-Only for Agentic Work

**⚠️ CRITICAL: Local Ollama models CANNOT do tool-calling (Jan 2026)**
- ALL 7 tested local models failed at multi-step tool-calling — see [Tool-Calling Research](#tool-calling-research-jan-2026)
- **ALL cron/sub-agents/heartbeats MUST use Anthropic models only**
- **Local models REMOVED from ALL fallback chains** (as of Jan 28 late night)
- Local models still installed for manual/interactive use but NOT in auto-routing
- Estimated cost: ~$4-5/day for reliable tool-calling

**Routing changes (Jan 28 late night):**
- ❌ ALL local Ollama models REMOVED from fallback chains
- ✅ Main session: `anthropic/claude-opus-4-5` → fallback `anthropic/claude-sonnet-4-5`
- ✅ All bots/cron/subagents: `anthropic/claude-sonnet-4-5` → fallback `anthropic/claude-opus-4-5`
- ✅ No more devstral, mistral-small3.2, phi4, gemma3, qwen3-coder in any auto-routing

**MacBook thinking is OFF to maximize concurrency:**
- `thinkingDefault: "off"` — Disabled to reduce token usage and allow higher parallelism

**Mac Mini swap protection is NON-NEGOTIABLE:**
- Mac Mini has 16GB RAM — heavy models cause swap death
- Only phi4-mini (2.5GB) and phi4:14b (9GB) installed (for manual use only)

### Model Tiers

| Tier | Models | Cost | Use Cases |
|------|--------|------|-----------|
| **1 — Frontier** | Claude Opus 4.5 | $$$ | Main chat session (MacBook) |
| **2 — Smart API** | Claude Sonnet 4.5 | $$ | ALL cron jobs, heartbeats, sub-agents, bots |
| **3 — Free manual** | mistral-small3.2, gemma3:12b | FREE | Manual interactive use ONLY (NOT in auto-routing) |
| **4 — Free research** | Grok, Brave Search, web_fetch | FREE | Research before burning tokens |

### Available Models (Installed but NOT in auto-routing)

| Model | Params | Context | Machine | Notes |
|-------|--------|---------|---------|-------|
| mistral-small3.2:24b | 24B | 32768 | MacBook | Manual use only |
| gemma3:12b | 12B | 32768 | MacBook | Vision-capable (image input), manual use only |
| phi4-mini | 3.8B | — | Mac Mini | Manual use only (~37-41 t/s) |
| phi4:14b | 14.7B | 16384 | Mac Mini | Manual use only, reasoning capable |

**Removed from all machines:**
- ❌ qwen3-coder:30b — removed
- ❌ devstral-small-2:24b — removed (hallucinates on agentic tasks)
- ❌ nemotron-3-nano:30b — removed

## Model Routing Table (All 3 Machines)

### MacBook Pro (48GB RAM) — Orchestrator

| Setting | Model | Notes |
|---------|-------|-------|
| **Main** | `anthropic/claude-opus-4-5` | Frontier reasoning, Felipe's direct chat |
| **Fallback** | `anthropic/claude-sonnet-4-5` | Anthropic only |
| **Heartbeat** | `anthropic/claude-sonnet-4-5` | 60min interval, needs tools |
| **Sub-agents** | `anthropic/claude-sonnet-4-5` → `anthropic/claude-opus-4-5` | Anthropic only |
| **Cron jobs** | `anthropic/claude-sonnet-4-5` | All hourly, staggered |
| **Thinking** | `thinkingDefault: "off"` | Off for higher concurrency |
| **maxConcurrent** | 8 | |
| **subagents.maxConcurrent** | 10 | |
| **cron.maxConcurrentRuns** | 6 | |

### Mac Mini (16GB RAM) — Always-On Server

| Setting | Model | Notes |
|---------|-------|-------|
| **Main** | `anthropic/claude-sonnet-4-5` | Sonnet (no local model fallbacks) |
| **Fallback** | `anthropic/claude-opus-4-5` | Anthropic only |
| **Heartbeat** | N/A | Mac Mini is a NODE, not orchestrator |
| **Sub-agents** | `anthropic/claude-sonnet-4-5` → `anthropic/claude-opus-4-5` | Anthropic only |
| **Thinking** | `thinkingDefault: "medium"` | |

> **Mac Mini is a NODE connected to MacBook orchestrator.** It does NOT run cron jobs. All cron runs on MacBook.

### Windows MSI (No local Ollama)

| Setting | Model | Notes |
|---------|-------|-------|
| **Main** | `anthropic/claude-sonnet-4-5` | Sonnet only (Telegram chat) |
| **Fallback** | `anthropic/claude-opus-4-5` | Anthropic only |
| **Heartbeat** | Disabled | Minimal config |
| **Cron** | None | No cron jobs |
| **Thinking** | `thinkingDefault: "medium"` | |

> **Windows is Telegram-only.** Separate bot token (8506493579). No cron, no heartbeat, minimal config.

## Ollama Providers (Manual Use Only)

### Provider: `ollama` (Mac Mini — always-on)
```yaml
baseUrl: http://127.0.0.1:11434
tailscaleUrl: http://100.115.10.14:11434
models:
  - phi4-mini  # 2.5GB, ultra-fast ~37-41 t/s
  - phi4:14b   # 9.1GB, reasoning=true
note: ⚠️ NOT in auto-routing. Manual use only. ALL local models fail at tool-calling.
```

### Provider: `ollama-macbook` (MacBook Pro)
```yaml
baseUrl: http://100.125.165.107:11434  # Tailscale IP
# From Mac Mini: http://10.144.238.116:11434/v1 (LAN IP — hostname doesn't resolve)
models:
  - mistral-small3.2:24b  # General tasks
  - gemma3:12b            # Vision-capable (image input)
note: ⚠️ NOT in auto-routing. Manual use only.
```

## Cross-Machine Access

Mac Mini can access MacBook's Ollama for manual/resource-sharing purposes:
- URL: `http://10.144.238.116:11434/v1` (LAN IP, not hostname)
- Gateway bridge on port 18789 (both machines)

**⚠️ Cross-machine Ollama is for MANUAL USE ONLY. Auto-routing is Anthropic-only.**

## Memory Search (Semantic Recall)

| Setting | Value |
|---------|-------|
| **Provider** | gemini |
| **Model** | gemini-embedding-001 |
| **Purpose** | Semantic recall — finds relevant memories by meaning |
| **Indexed files** | MEMORY.md, memory/*.md |

## Context Pruning

| Setting | Value |
|---------|-------|
| **Mode** | cache-ttl |
| **keepLastAssistants** | 3 |
| **softTrimRatio** | 0.5 |
| **hardClearRatio** | 0.7 |

## Compaction

| Setting | Value |
|---------|-------|
| **Mode** | safeguard |
| **memoryFlush** | enabled |
| **softThresholdTokens** | 100,000 |

## Auth & Account Rotation

### Active Accounts
- **Primary**: `wisedigital` (rotated from `felipe.lv.90` on Jan 28)
- **Secondary**: `felipe.lv.90`

### Cooldowns (Updated Jan 28)

| Setting | Value | Previous |
|---------|-------|----------|
| **billingBackoffHours** | 2 | was 1 |
| **billingMaxHours** | 8 | was 5 |
| **failureWindowHours** | 2 | was 1 |

**How it works:**
- On billing/quota errors: backs off for 2 hours initially
- Each subsequent billing failure doubles the backoff, capped at 8 hours max
- Auth failures within a 2-hour window are grouped (prevents rapid retry loops)

## Cron Jobs (ALL on MacBook Orchestrator)

See [cron-schedule.md](cron-schedule.md) for full cron documentation.

### Summary (All hourly, staggered)

| Time | Job | Model | Deliver |
|------|-----|-------|---------|
| `:00` | Cleaner Bot + Healer Team | Sonnet 4.5 | `false` → clawd-status API |
| `:05` | EZ-CRM Dev Bot | Sonnet 4.5 | `false` → clawd-status API |
| `:10` | LinkLounge Dev Bot | Sonnet 4.5 | `false` → clawd-status API |
| `:15` | iOS App Dev Bot | Sonnet 4.5 | `false` → clawd-status API |
| Every 6h | R&D Research | Sonnet 4.5 | `false` → clawd-status API |
| 3x/day | App Store Manager | Sonnet 4.5 | `false` → clawd-status API |
| Weekly Sun | Clear Sessions | — | — |

**Key change (Jan 28):** ALL cron Telegram delivery DISABLED. Routine reports go to `clawd-status` API (`POST http://localhost:9010/api/log`). Only CRITICAL alerts go to Telegram.

### Heartbeat
| Setting | Value |
|---------|-------|
| **Model** | `anthropic/claude-sonnet-4-5` |
| **Interval** | 60 min |
| **Reports to** | clawd-status API (routine), Telegram (critical only) |

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
OLLAMA_HOST=0.0.0.0         # Listen on all interfaces
OLLAMA_FLASH_ATTENTION=1     # 2-3x faster, 40% less memory
OLLAMA_KV_CACHE_TYPE=q8_0    # 4x memory reduction vs f16
```

## Cost Analysis (Updated Jan 28)

| Task | Model | Cost/run | Runs/day | Daily Cost |
|------|-------|----------|----------|------------|
| Cron: Cleaner | Sonnet 4.5 | ~$0.03 | 24 | ~$0.72 |
| Cron: Healer Team | Sonnet 4.5 | ~$0.05 | 24 | ~$1.20 |
| Cron: EZ-CRM | Sonnet 4.5 | ~$0.05 | 24 | ~$1.20 |
| Cron: LinkLounge | Sonnet 4.5 | ~$0.05 | 24 | ~$1.20 |
| Cron: iOS Dev | Sonnet 4.5 | ~$0.05 | 24 | ~$1.20 |
| Cron: R&D | Sonnet 4.5 | ~$0.10 | 4 | ~$0.40 |
| Cron: App Store | Sonnet 4.5 | ~$0.10 | 3 | ~$0.30 |
| Heartbeat | Sonnet 4.5 | ~$0.02 | 24 | ~$0.48 |
| Sub-agents | Sonnet 4.5 | ~$0.05 | ~10 | ~$0.50 |
| Main session | Opus 4.5 | ~$0.20 | ~10 | ~$2.00 |
| **TOTAL** | | | | **~$9.20/day** |

**Monthly estimate**: ~$275/month (all Anthropic, no local model fallbacks)

**Local models are still FREE for manual use** but NOT in any auto-routing chain.

## Troubleshooting

### Model Not Found (Manual Ollama Use)
```bash
ollama list                    # Check available models
ollama pull mistral-small3.2   # Pull if needed
```

### Mac Mini Swap Issues
```bash
sysctl vm.swapusage            # Check swap usage
ollama ps                      # Check loaded models
brew services restart ollama   # Restart to free memory
```

### Connection Refused (Remote Ollama)
```bash
echo $OLLAMA_HOST              # Should be 0.0.0.0
curl http://localhost:11434/api/tags           # Local
curl http://100.115.10.14:11434/api/tags       # Mac Mini via Tailscale
curl http://100.125.165.107:11434/api/tags     # MacBook via Tailscale
```

### Sub-agent Using Wrong Model
- **Root cause (Jan 28)**: Sub-agents had local Ollama in fallback chains. When Sonnet rate-limited, they fell to devstral which hallucinates.
- **Fix**: ALL local models removed from fallback chains. Sub-agents now: Sonnet 4.5 → Opus 4.5 (Anthropic only).

## Fix History

### 2026-01-28 (Late Night): Anthropic-Only Routing
**Problem**: Sub-agents falling back to devstral/local models which can't do tool-calling. Two iOS submission pipelines failed because they routed to devstral.

**Root cause**: Fallback chains included local Ollama models. When Sonnet was rate-limited, system fell to devstral which hallucinates tool calls.

**Fixed:**
- **ALL local Ollama models REMOVED from ALL fallback chains** (all 3 machines)
- Main session: Opus 4.5 → Sonnet 4.5 (Anthropic only)
- All bots/cron/subagents: Sonnet 4.5 → Opus 4.5 (Anthropic only)
- Auth cooldowns increased: billingBackoff 1→2h, billingMax 5→8h, failureWindow 1→2h
- Account rotation: felipe.lv.90 → wisedigital
- Cron delivery disabled: all reports → clawd-status API, critical only → Telegram
- New cron jobs added: EZ-CRM Dev, LinkLounge Dev, iOS App Dev (all hourly)
- Cron schedule standardized: all hourly, staggered by 5 min

### 2026-01-28: All Cron/Heartbeats → Sonnet 4.5
- All 7 local Ollama models confirmed failing at tool-calling
- R&D cron switched from qwen3-coder:30b to Sonnet 4.5
- Mac Mini → MacBook Ollama URL fixed to LAN IP
- clawd-status dashboard added at port 9010

### 2026-01-27: Config Audit & Swap Protection
- gpt-oss:20b removed from Mac Mini auto-fallbacks
- Windows MSI: added MacBook as second Ollama provider
- Deleted qwen3-fast:8b (freed 5.2GB)

---

## Tool-Calling Research (Jan 2026)

**Summary:** ALL local Ollama models fail at multi-step agentic tool-calling.

### Models Tested (All Failed)

| Model | Failure Mode | Details |
|-------|-------------|---------|
| qwen3-coder:30b | Broken template | Ollama bug #11621 — omits `<tool_call>` tags |
| devstral-small-2:24b | Hallucinates text | Describes tools instead of calling them |
| mistral-small3.2:24b | Returns text | Ignores tools, responds with text |
| nemotron-3-nano:30b | 1 call then stops | Can do 1 call but multi-step fails |
| phi4-mini:3.8b | Echoes prompt | Never attempts tool calls |
| phi4:14b | Echoes prompt | Same as phi4-mini |
| gemma3:12b | No tool support | Model lacks tool capability entirely |

### Root Cause
Ollama's OpenAI-compatible endpoint translates between OpenAI's tool-calling format and each model's native format. This translation layer has bugs:
1. **Template bugs** (qwen3-coder): Jinja template incorrectly formats tool definitions
2. **Quantization artifacts**: Q4_K_M loses fine-tuned tool-calling behavior
3. **Multi-step weakness**: Even 1-call models fail on tool-result → next-tool-call chain
4. **Format confusion**: Models output native tags instead of OpenAI JSON

### Decision (Jan 28 final)
- **ALL auto-routing → Anthropic only** (Sonnet 4.5 / Opus 4.5)
- **Local models → manual interactive use ONLY** (not in any fallback chain)
- **Monitor**: Ollama releases for improvements (especially bug #11621)

---

## References

- [Model Routing](model-routing.md) — Detailed routing documentation
- [Cron Schedule](cron-schedule.md) — Full cron job documentation
- [Three-Machine Architecture](infrastructure/three-machine-architecture.md) — Full infrastructure overview
- [Ollama Setup](ollama-setup.md) — Installation & configuration
- [Tailscale](tailscale.md) — Network configuration
- [Dev Teams](dev-teams.md) — Model assignment per project/bot
- [Hybrid Healing](clawdbot/HYBRID-HEALING.md) — Self-healing architecture
