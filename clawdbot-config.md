# Clawdbot Configuration

Multi-machine Clawdbot setup with Ollama integration for local LLM inference.

## 🤖 Model Routing Strategy

### Architecture Philosophy: Reasoning-First, Cost-Second

**ALL machines now use thinking/reasoning by default:**
- `thinkingDefault: "low"` — Extended reasoning on all models that support it
- Reasoning = better decisions, fewer mistakes, less wasted work

### Model Tiers

**Tier 1 — Opus 4.5 (best reasoning):**
- MacBook Pro (main orchestrator)
- Windows MSI (secondary Opus instance)

**Tier 2 — Free local models with reasoning:**
- Mac Mini cron bots → Sonnet 4.5 in isolated sessions
- All heartbeats → qwen3:8b (free, reasoning=true)
- All sub-agents → qwen3:8b (free, reasoning=true)

**Tier 3 — Free research tools (before burning tokens):**
- Grok/X, Brave Search, web_fetch, Reddit

### Primary Models
- **qwen3:8b** (Qwen3.1) — Fast model with reasoning=true, now PRIMARY for sub-agents/heartbeats
- **gpt-oss:20b** (DeepSeek-V3) — On-demand fallback (Mac Mini: NOT kept loaded to save RAM)
- **devstral-small-2:24b** (Mistral) — MacBook only (heavy coding, 48GB RAM)

### Legacy Models (Removed)
- ❌ Legacy 7B coder model — Replaced by qwen3:8b (better reasoning) and gpt-oss:20b

## 🧠 Model Assignment by Task

### Heartbeat (Periodic Checks)
- **Model**: qwen3:8b (reasoning=true) on all machines
- **Why**: Always-on, FREE, reasoning enabled for smarter decisions

### Sub-Agent Cascade
When spawning sub-agents, models cascade in order:
1. **qwen3:8b** (both machines — PRIMARY, reasoning=true, FREE)
2. **gpt-oss:20b** (Mac Mini Ollama — on-demand fallback, NOT kept loaded)
3. **devstral-small-2:24b** (MacBook Ollama — heavy coding only)
4. **Claude Sonnet 4.5** (API, if local fails)
5. **Claude Opus 4.5** (API, last resort)

### Thinking/Reasoning Configuration
**ALL machines now think by default:**
- **MacBook Pro**: `thinkingDefault: "low"` — Opus always thinks
- **Mac Mini**: `thinkingDefault: "low"` — qwen3:8b with reasoning=true
- **Windows MSI**: `thinkingDefault: "low"` — qwen3:8b via Mac Mini with reasoning=true

**Why reasoning everywhere?**
- Better decisions upfront = less wasted work
- Free on local models (qwen3:8b)
- Opus 4.5 has extended thinking built-in
- Minimal token overhead, massive quality gain

## 🔄 Cross-Machine Ollama Fallback (NEW)

Both Macs now have **bidirectional Ollama fallback** — if one machine's Ollama fails, the other catches it automatically.

### Mac Mini Fallback Chain
```
qwen3:8b (local) → gpt-oss:20b (local, on-demand) → MacBook qwen3:8b → 
MacBook devstral → MacBook gpt-oss → Sonnet → Opus
```

### MacBook Fallback Chain
```
qwen3:8b (local) → Mac Mini qwen3:8b → Mac Mini gpt-oss → Sonnet → Opus
```

### Configuration
- Mac Mini config now has `ollama-macbook` provider pointing to MacBook Pro
- MacBook already had `ollama` (Mac Mini) as provider
- Automatic failover with zero manual intervention

**Why it matters:** If Mac Mini Ollama crashes, MacBook picks up the slack. If MacBook sleeps, Mac Mini keeps heartbeats alive.

## 🖥️ Ollama Providers

Two separate Ollama instances for multi-machine access:

### Provider 1: `ollama` (Mac Mini — always-on)
```yaml
name: ollama
baseUrl: http://felipes-mac-mini.local:11434
tailscaleUrl: http://100.115.10.14:11434
models:
  - qwen3:8b         # PRIMARY (5GB, reasoning=true, safe for 16GB RAM)
  - gpt-oss:20b      # On-demand fallback (14GB, NOT kept loaded)
```

**RAM Protection (CRITICAL):**
- Mac Mini has only 16GB RAM
- gpt-oss:20b (14GB) was causing 15.6GB swap — SWAP DEATH
- Primary changed to qwen3:8b (5GB) — safe for 16GB
- gpt-oss:20b still available but NOT kept loaded
- Healer Bot v3 monitors swap and auto-unloads heavy models

### Provider 2: `ollama-macbook` (MacBook Pro — primary for coding)
```yaml
name: ollama-macbook
baseUrl: http://felipes-macbook-pro-2.local:11434
tailscaleUrl: http://100.125.165.107:11434
models:
  - qwen3:8b              # PRIMARY for sub-agents (reasoning=true)
  - devstral-small-2:24b  # Heavy coding tasks (48GB RAM safe)
  - gpt-oss:20b           # General fallback
```

## ⏰ Cron Jobs

### Active Cron Jobs

All cron jobs now use **Sonnet 4.5 in isolated sessions with extended thinking** — they need intelligence for self-healing and diagnostics.

| Job | Schedule | Model | Session | Machines | Purpose |
|-----|----------|-------|---------|----------|---------|
| **Cleaner Bot** | Hourly | `anthropic/claude-sonnet-4-5` | isolated | MacBook + Mac Mini | Deep cleanup (caches, temp, disk) |
| **Healer Bot v3** | Hourly | `anthropic/claude-sonnet-4-5` | isolated | MacBook + Mac Mini | Read event logs, diagnose, heal, **swap monitoring** |
| **App Store Manager** | 3x daily (9 AM, 3 PM, 9 PM EST) | `anthropic/claude-sonnet-4-5` | isolated | MacBook | Monitor iOS apps on App Store Connect |
| **Clear Sessions** | Weekly (Sunday midnight) | — | — | MacBook | Clean stale Clawdbot sessions |

### Cleaned Up (Removed 5 Legacy Jobs)
- ❌ iOS App Store Monitor (old) — Replaced by App Store Manager
- ❌ Project Health Monitor — Replaced by Healer Bot v3
- ❌ EZ-CRM Continuous — Disabled
- ❌ LinkLounge Continuous — Disabled
- ❌ Aphos Game Dev — Disabled

### Why Sonnet for Cron Jobs?
- **Intelligence needed**: Self-healing requires reasoning, diagnostics, web research
- **Isolated sessions**: Each cron run is independent, no context pollution
- **Extended thinking**: Sonnet 4.5 has built-in reasoning for complex decisions
- **Cost-effective**: ~$0.05-0.15 per cron run vs manual debugging time

See [APP-STORE-MANAGER.md](clawdbot/APP-STORE-MANAGER.md) for full App Store Manager docs.

### Configuration Example
```bash
# List cron jobs
clawdbot cron list

# Add a cron job with Sonnet in isolated session
clawdbot cron add --name "cleaner-bot" --schedule "0 * * * *" \
  --model "anthropic/claude-sonnet-4-5" --session-target "isolated"
```

## 🩺 Event Watcher (Launchd Service)

The event watcher runs 24/7 via launchd — NOT a cron job.

- **Service**: `com.clawdbot.event-watcher`
- **Script**: `/Users/felipevieira/clawd/scripts/event-watcher.sh`
- **Interval**: Every 60 seconds
- **Cost**: FREE (pure bash)
- **Logs**: `/tmp/clawdbot/events.jsonl`

See [HYBRID-HEALING.md](clawdbot/HYBRID-HEALING.md) for full architecture.

```bash
# Check status
launchctl list | grep event-watcher

# View recent events
tail -20 /tmp/clawdbot/events.jsonl | jq .
```

## ⚙️ Ollama Performance Tuning

Both machines run with optimized settings:

### Environment Variables
```bash
OLLAMA_HOST=0.0.0.0              # Listen on all interfaces
OLLAMA_FLASH_ATTENTION=1          # Enable flash attention
OLLAMA_KV_CACHE_TYPE=q8_0         # 8-bit quantized KV cache
```

### Flash Attention
- **Benefit**: Faster inference, lower memory usage
- **Trade-off**: Slightly reduced quality (negligible in practice)

### Q8_0 KV Cache
- **Benefit**: 4x memory reduction vs f16 cache
- **Trade-off**: Minimal quality impact, enables larger context windows

## 📊 Model Specs

| Model | Size | RAM | Location | Purpose |
|-------|------|-----|----------|---------|
| devstral-small-2:24b | 15 GB | 48 GB | MacBook | **Primary for coding** |
| gpt-oss:20b | 13 GB | 16 GB | Mac Mini (primary), MacBook | Heartbeats, general |
| qwen3:8b | 5.2 GB | Both | Both | Fast reasoning |

## 🗺️ Model Routing Table (All 3 Machines)

**Reasoning-first architecture — ALL models think by default.**

| Machine | Main Model | Heartbeat | Sub-agents | Thinking | Fallbacks |
|---------|-----------|-----------|------------|----------|-----------|
| **MacBook Pro** | `anthropic/claude-opus-4-5` | `ollama/qwen3:8b` (reasoning) | `ollama/qwen3:8b` (reasoning) | low (always) | Sonnet → Opus |
| **Mac Mini** | `ollama/qwen3:8b` (reasoning) | `ollama/qwen3:8b` (reasoning) | `ollama/qwen3:8b` (reasoning) | low (always) | gpt-oss → MacBook qwen3 → Sonnet → Opus |
| **Windows MSI** | `anthropic/claude-opus-4-5` | `ollama-macmini/qwen3:8b` (reasoning) | `ollama-macmini/qwen3:8b` (reasoning) | low (always) | Sonnet → Opus |

> **Mac Mini is still the CENTRAL BRAIN** — all 3 machines route heartbeats through it, but now with qwen3:8b (5GB) instead of gpt-oss:20b (14GB) for RAM safety.

## 🔄 Load Balancing

- **MacBook** is primary for sub-agents (devstral-24b for coding)
- **Mac Mini** handles heartbeats (always-on, gpt-oss:20b)
- Sub-agents cascade: MacBook devstral → Mac Mini gpt-oss → MacBook gpt-oss → qwen3
- Both machines reachable via hostname or Tailscale IP

## 🎯 Usage Examples

### CLI Override
```bash
# Use specific model
clawd chat --model ollama/gpt-oss:20b

# Use MacBook Ollama
clawd chat --model ollama-macbook/devstral-small-2:24b

# Force reasoning mode
clawd chat --model ollama/qwen3:8b --reasoning
```

### Config File (.clawdbotrc)
```json
{
  "defaultModel": "ollama-macbook/devstral-small-2:24b",
  "heartbeatModel": "ollama/gpt-oss:20b",
  "subAgentModels": [
    "ollama-macbook/devstral-small-2:24b",
    "ollama/gpt-oss:20b",
    "ollama-macbook/gpt-oss:20b",
    "ollama/qwen3:8b",
    "anthropic/claude-sonnet-4-5",
    "anthropic/claude-opus-4-5"
  ]
}
```

## 💰 Cost Savings

| Task Type | Old Model | New Model | Savings |
|-----------|-----------|-----------|---------|
| Heartbeats | Claude Sonnet | gpt-oss:20b (Mac Mini) | 100% |
| Sub-agents (coding) | Claude Sonnet | devstral-small-2:24b (MacBook) | 100% |
| Sub-agents (general) | Claude Sonnet | gpt-oss:20b | 100% |
| Quick tasks | Claude Haiku | qwen3:8b | 100% |
| Self-healing | Claude Sonnet | Event watcher (bash) + local LLM | 95-100% |

**Estimated monthly savings**: $200-300 USD

## 🔧 Troubleshooting

### Model Not Found
```bash
# Check available models
ollama list

# Pull missing model
ollama pull gpt-oss:20b
```

### Slow Inference
```bash
# Verify flash attention is enabled
echo $OLLAMA_FLASH_ATTENTION  # Should be 1

# Check KV cache type
echo $OLLAMA_KV_CACHE_TYPE    # Should be q8_0
```

### Connection Refused
```bash
# Verify Ollama is running
ps aux | grep ollama

# Check port
lsof -i :11434

# Restart Ollama
brew services restart ollama
```

## 🖥️ Windows MSI Config

The Windows MSI machine routes ALL inference through **Mac Mini's Ollama via Tailscale** — no local models needed.

### Provider: `ollama-macmini`
```yaml
name: ollama-macmini
baseUrl: http://100.115.10.14:11434
models:
  - qwen3:8b         # PRIMARY (reasoning=true, FREE)
  - gpt-oss:20b      # On-demand fallback (routed from Mac Mini)
```

### Configuration
```yaml
main: ollama-macmini/qwen3:8b (reasoning=true)
fallbacks:
  - ollama-macmini/gpt-oss:20b
  - anthropic/claude-sonnet-4-5
  - anthropic/claude-opus-4-5
heartbeat: ollama-macmini/qwen3:8b (reasoning=true)
ollama: remote only (via Mac Mini Tailscale 100.115.10.14:11434)
thinkingDefault: "low"
```

### Auto-Start
- **Windows Scheduled Task**: "ClawdbotGateway" — runs on user login
- Ensures Clawdbot gateway starts automatically on boot

### ✅ Credit Leak FIXED
Previously 100% Claude API. Now routes through Mac Mini Ollama — most tasks are **FREE**.

---

## 🔧 Fix History

### 2025-07-27: Credit Leak Fix (legacy model removal)

**Problem**: A legacy 7B model was deleted from both machines but still referenced in configs. Clawdbot would try to use it, fail, and fall back to expensive Claude API models — burning credits unnecessarily.

**What was changed:**
- Mac Mini primary model → `gpt-oss:20b` (20B params, better quality, FREE)
- All fallback chains updated to use current models only
- MacBook sub-agent chain: Added `devstral-small-2:24b` as primary coding model
- Verified all referenced models actually exist on their target machines

### 2025-07-28: Windows MSI routing through Mac Mini

**Problem**: Windows MSI was 100% Claude API — every task burned credits.

**What was changed:**
- Added `ollama-macmini` provider pointing to Mac Mini Tailscale IP (100.115.10.14:11434)
- Windows primary model → `ollama-macmini/gpt-oss:20b` (FREE via Mac Mini)
- Windows fallbacks → `qwen3:8b` → Sonnet → Opus
- Added Windows Scheduled Task "ClawdbotGateway" for auto-start on login
- Mac Mini is now the **CENTRAL BRAIN** — serves both MacBook and Windows heartbeats

---

## 📚 References

- [Three-Machine Architecture](infrastructure/three-machine-architecture.md) — Full infrastructure overview
- [Ollama Setup](ollama-setup.md) — Installation & configuration
- [Tailscale](tailscale.md) — Network configuration for multi-machine access
- [Dev Teams](dev-teams.md) — Model assignment per project/bot
- [Hybrid Healing](clawdbot/HYBRID-HEALING.md) — Self-healing architecture
