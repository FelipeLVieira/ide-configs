# Ollama Setup

Local LLM inference on Mac Mini and MacBook Pro via Ollama.

> **⚠️ IMPORTANT (Jan 28, 2026):** ALL local Ollama models are for **MANUAL USE ONLY**. They have been REMOVED from all auto-routing fallback chains because ALL 7 tested models fail at tool-calling. See [model-routing.md](model-routing.md).

## Hardware Overview

### Mac Mini (24/7 Server)
- **RAM**: 16 GB
- **OS**: macOS Sequoia
- **Tailscale IP**: 100.115.10.14
- **Hostname**: felipes-mac-mini.local
- **Ollama URL**: http://felipes-mac-mini.local:11434
- **Service**: `homebrew.mxcl.ollama` (brew services)
- **Role**: Primary inference server (heartbeats, always-on)

### MacBook Pro (On-Demand)
- **RAM**: 48 GB
- **OS**: macOS Sequoia
- **Tailscale IP**: 100.125.165.107
- **Hostname**: felipes-macbook-pro-2.local
- **Ollama URL**: http://felipes-macbook-pro-2.local:11434
- **Role**: Primary for coding sub-agents (devstral-24b)

## Installation

Both machines use Homebrew:

```bash
brew install ollama
```

## Configuration

### Environment Variables

Add to `~/.zshrc` or `~/.bash_profile`:

```bash
# Ollama Server Config
export OLLAMA_HOST=0.0.0.0 # Listen on all interfaces
export OLLAMA_FLASH_ATTENTION=1 # Enable flash attention
export OLLAMA_KV_CACHE_TYPE=q8_0 # 8-bit quantized KV cache
```

Then reload:
```bash
source ~/.zshrc
```

### Launchd Service (MacBook Pro Only)

MacBook runs Ollama via launchd for auto-start.

**File**: `~/Library/LaunchAgents/com.ollama.serve.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ollama.serve</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/ollama</string>
        <string>serve</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OLLAMA_HOST</key>
        <string>0.0.0.0</string>
        <key>OLLAMA_FLASH_ATTENTION</key>
        <string>1</string>
        <key>OLLAMA_KV_CACHE_TYPE</key>
        <string>q8_0</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/ollama.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/ollama.err.log</string>
</dict>
</plist>
```

**Load the service:**
```bash
launchctl load ~/Library/LaunchAgents/com.ollama.serve.plist
launchctl start com.ollama.serve
```

**Check status:**
```bash
launchctl list | grep ollama
```

### Mac Mini Service (Homebrew)

Mac Mini uses **Homebrew services** (`homebrew.mxcl.ollama`) for Ollama management. Environment variables are set in `~/.zshrc` and the Homebrew service config picks them up.

> **Note**: A previous custom `com.user.ollama.plist` was removed — it was causing dual Ollama processes (two instances fighting for port 11434). Homebrew services is now the single source of truth.

**Management:**
```bash
# Start
brew services start ollama

# Stop
brew services stop ollama

# Restart
brew services restart ollama

# Check status
brew services info ollama

# View logs
tail -f /tmp/ollama.out.log
tail -f /tmp/ollama.err.log
```

## Models

### Mac Mini (16 GB RAM) — RESOURCE-CONSTRAINED!

WARNING: **CRITICAL: Swap Protection**

Mac Mini has ONLY 16GB RAM. Heavy models cause swap death:
- Heavy models (14GB+) were causing **15.6GB swap** — system grinding to a halt
- **Solution**: Primary changed to phi4-mini (2.5GB), only phi4:14b (9GB) as secondary

| Model | Params | Size | Speed | Purpose | Status |
|-------|--------|------|-------|---------|--------|
| **phi4-mini** | 3.8B | 2.5 GB | ~37-41 t/s | **PRIMARY** — cron/heartbeats, ultra-lightweight | [OK] Always loaded |
| **phi4:14b** | 14.7B | 9.1 GB | — | **Secondary** — reasoning tasks, contextWindow=16384 | [OK] Available |

**Removed:**
- [NO] qwen3:8b — Removed (too slow, deep /think by default, 60s+ per prompt)
- [NO] qwen2.5-coder:7b — Removed (legacy)
- [NO] qwen3-fast:8b — Deleted (duplicate of qwen3:8b, freed 5.2GB disk)

**Resource Limits (desired-state.json):**
```json
{
  "resource_limits": {
    "macmini_swap_warn_gb": 8,
    "macmini_swap_critical_gb": 12,
    "max_loaded_model_gb": 6
  }
}
```

**Healer Bot v3 monitors swap:**
- Checks every hour for swap usage
- Auto-unloads heavy models if swap >8GB
- Alerts Felipe if swap >12GB (critical)

**Pull models:**
```bash
ollama pull phi4-mini # PRIMARY (2.5GB, ultra-fast ~37-41 t/s)
ollama pull phi4:14b # Secondary (9GB, safe for 16GB)
```

### MacBook Pro (48 GB RAM)

| Model | Params | Size | Context | MaxTokens | Purpose |
|-------|--------|------|---------|-----------|---------|
| **qwen3-coder:30b** | 30B | ~19 GB | 40960 | 40960 | **PRIMARY** for sub-agents (NEW) |
| devstral-small-2:24b | 24B | 15 GB | 32768 | 8192 | Heavy coding tasks (48GB RAM safe) |
| **gemma3:12b** | 12B | ~8 GB | 32768 | 8192 | Vision-capable (image input!) |

**Image input support**: gemma3:12b (can analyze images!)

**Pull models:**
```bash
ollama pull qwen3-coder:30b # PRIMARY (30B coding model)
ollama pull devstral-small-2:24b # Heavy coding
ollama pull gemma3:12b # Vision model (image input!)
```

### Removed Models
- [NO] **qwen3:8b** — Removed from Mac Mini (too slow, deep /think by default, 60s+ per prompt). Replaced by phi4-mini.
- [NO] **qwen2.5-coder:7b** — Removed (legacy). Replaced by phi4-mini.
- [NO] **gpt-oss:20b** — Deleted from MacBook (2026-01-27). Replaced by qwen3-coder:30b.
- [NO] **qwen3-fast:8b** — Deleted from Mac Mini (2026-01-27). Duplicate of qwen3:8b, freed 5.2GB disk.

### Windows MSI — Remote Ollama via MacBook + Mac Mini
- [NO] **No local Ollama** on Windows MSI
- [OK] **Routes through both Macs** via Tailscale:
  - `ollama-macbookpro` -> `http://100.125.165.107:11434` (qwen3-coder:30b, devstral-24b, gemma3:12b)
  - `ollama-macmini` -> `http://100.115.10.14:11434` (phi4-mini, phi4:14b)

### Future Models
- **qwen2.5vl:32b** — Planned for Asset Forge (design vision model)

## Mac Mini as Central Ollama Hub

The Mac Mini serves as the **central Ollama inference hub** for all machines in the ecosystem.

### Clients Served

| Client | Access Method | URL |
|--------|--------------|-----|
| **Mac Mini Clawdbot** | Local (direct) | `http://localhost:11434` |
| **Windows MSI** | Remote via Tailscale | `http://100.115.10.14:11434` |
| **MacBook Pro** | Local network | `http://felipes-mac-mini.local:11434` |

### Why Mac Mini is the Hub
- **Always-on** (24/7, never sleeps)
- **Serves heartbeats** for all 3 machines (FREE)
- **Windows has no local Ollama** — 100% dependent on Mac Mini
- **MacBook uses Mac Mini** for heartbeats (saves MacBook GPU for coding models)

### Models Available on Each Machine

| Machine | Models | Total Size | Status |
|---------|--------|-----------|--------|
| **MacBook Pro** | qwen3-coder:30b (~19GB, **PRIMARY**), devstral-small-2:24b (15GB), gemma3:12b (~8GB, image input!) | ~42 GB | [OK] All loaded |
| **Mac Mini** | phi4-mini (2.5GB, **PRIMARY**), phi4:14b (9.1GB, secondary) | ~12 GB | [OK] Safe for 16GB RAM |
| **Windows MSI** | NONE (routes through Mac Mini + MacBook) | 0 GB | [OK] Via Tailscale |

---

## Model Routing (Updated Jan 28, 2026)

**Anthropic-only architecture** — ALL auto-routing uses Anthropic API. Local models are manual-only.

```
ALL routing (cron, sub-agents, heartbeat):
  Sonnet 4.5 (API) → Opus 4.5 (API)

Main session:
  Opus 4.5 (API) → Sonnet 4.5 (API)

Local models (manual use only):
  MacBook: mistral-small3.2, gemma3:12b
  Mac Mini: phi4-mini, phi4:14b
```

> ⚠️ **ALL local Ollama models FAIL at tool-calling.** They have been REMOVED from all fallback chains. See [model-routing.md](model-routing.md) for full details.

### Why Not Local Models for Auto-Routing?
All 7 tested models failed at multi-step tool-calling:
- qwen3-coder:30b — Broken Jinja template (Ollama bug #11621)
- devstral-small-2:24b — Hallucinates "Task completed" after 1 command
- mistral-small3.2 — Ignores tools, returns text
- phi4-mini/phi4:14b — Echoes prompt
- gemma3:12b — No tool support
- nemotron-3-nano — 1 call then stops

## Network Access

Both machines reachable via **hostname** or **Tailscale IP**.

### Hostname Access (Local Network)
```bash
# Mac Mini
curl http://felipes-mac-mini.local:11434/api/tags

# MacBook
curl http://felipes-macbook-pro-2.local:11434/api/tags
```

### Tailscale Access (Remote/VPN)
```bash
# Mac Mini
curl http://100.115.10.14:11434/api/tags

# MacBook
curl http://100.125.165.107:11434/api/tags
```

### Cross-Machine Ollama Access (Bidirectional)

Both Macs can use each other's Ollama instances for **automatic failover** and load balancing:

```bash
# MacBook -> Mac Mini (always-on, heartbeats)
curl http://felipes-mac-mini.local:11434/api/tags

# Mac Mini -> MacBook (coding models, devstral-24b)
curl http://felipes-macbook-pro-2.local:11434/api/tags
```

**In Clawdbot config**, two providers are defined:
- `ollama` -> Mac Mini (always-on)
- `ollama-macbook` -> MacBook Pro (coding-focused)

**Mac Mini fallback chain:**
```
phi4-mini (local) -> phi4:14b (local) -> MacBook qwen3-coder:30b -> MacBook devstral -> MacBook gemma3:12b -> Sonnet -> Opus
```

**MacBook fallback chain:**
```
Opus -> Sonnet -> devstral-24b -> gemma3:12b (all local/safe on 48GB)
```

This means: **if one machine's Ollama fails, the other catches it automatically**. Zero downtime.

### Tailscale CLI Fix

Tailscale userspace mode requires a socket flag for CLI:

```bash
# Add to ~/.zshrc
alias tailscale='tailscale --socket=~/.tailscale/tailscaled.sock'
```

## Performance Tuning

### Flash Attention
- **What**: Optimized attention mechanism for Transformers
- **Benefit**: 2-3x faster inference, 40% less memory
- **Enabled**: `OLLAMA_FLASH_ATTENTION=1`

### Q8_0 KV Cache
- **What**: 8-bit quantized key-value cache
- **Benefit**: 4x memory reduction vs f16 (16-bit float)
- **Trade-off**: Negligible quality loss (<1% perplexity increase)
- **Enabled**: `OLLAMA_KV_CACHE_TYPE=q8_0`

### Why It Matters
- **Mac Mini (16 GB)**: Can run phi4:14b (9 GB) with headroom
- **MacBook (48 GB)**: Can run devstral-small-2:24b (15 GB) + multiple contexts

## Management Commands

### List Models
```bash
ollama list
```

### Pull/Update Models
```bash
ollama pull qwen3-coder:30b
```

### Remove Models
```bash
ollama rm <model-name> # Remove unused models to free disk space
```

### Check Running Models
```bash
curl http://localhost:11434/api/tags
```

### Stop Model (Free Memory)
```bash
# Models auto-unload after 5 minutes of inactivity
# Or restart service
brew services restart ollama
```

## Firewall & Security

### Allow Ollama Port

**macOS Firewall:**
```bash
# Ollama runs on port 11434
# Add firewall rule if needed
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /opt/homebrew/bin/ollama
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /opt/homebrew/bin/ollama
```

### Tailscale Security
- Only Tailscale network can access (private mesh VPN)
- No public internet exposure
- All traffic encrypted end-to-end

## Troubleshooting

### Service Not Starting
```bash
# Check logs
tail -f /tmp/ollama.err.log

# Check status
brew services info ollama

# Restart
launchctl stop com.ollama.serve && launchctl start com.ollama.serve # MacBook
brew services restart ollama # Mac Mini (uses homebrew.mxcl.ollama)
```

### Port Already in Use
```bash
# Find process using port 11434
lsof -i :11434

# Kill it
kill -9 <PID>
```

### Model Not Found
```bash
# List available models
ollama list

# Pull missing model
ollama pull qwen3-coder:30b
```

### Out of Memory
```bash
# Check memory usage
ollama ps

# Stop all models
brew services restart ollama

# Use smaller model or different machine
```

### Connection Refused (Remote)
```bash
# Verify Ollama is listening on 0.0.0.0
echo $OLLAMA_HOST # Should be 0.0.0.0

# Test local
curl http://localhost:11434/api/tags

# Test via hostname
curl http://felipes-mac-mini.local:11434/api/tags

# Test Tailscale IP
curl http://100.115.10.14:11434/api/tags

# Check Tailscale status
tailscale status
```

## Monitoring

### Check Inference Speed
```bash
time ollama run qwen3-coder:30b "What is 2+2?"
```

### Memory Usage
```bash
# Active model memory
ollama ps

# System memory
vm_stat

# Or use Activity Monitor
```

### GPU Usage (Apple Silicon)
```bash
# Metal GPU usage
sudo powermetrics --samplers gpu_power -i 1000 -n 1
```

## References

- [Ollama Docs](https://ollama.ai/docs)
- [Flash Attention Paper](https://arxiv.org/abs/2205.14135)
- [Clawdbot Config](clawdbot-config.md) — Model routing
- [Tailscale Setup](tailscale.md) — Network configuration
