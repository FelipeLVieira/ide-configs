# Ollama Setup

Local LLM inference on Mac Mini and MacBook Pro via Ollama.

## 🖥️ Hardware Overview

### Mac Mini (24/7 Server)
- **RAM**: 16 GB
- **OS**: macOS Sequoia
- **Tailscale IP**: 100.115.10.14
- **Hostname**: felipes-mac-mini.local
- **Ollama URL**: http://felipes-mac-mini.local:11434
- **Role**: Primary inference server (heartbeats, always-on)

### MacBook Pro (On-Demand)
- **RAM**: 48 GB
- **OS**: macOS Sequoia
- **Tailscale IP**: 100.125.165.107
- **Hostname**: felipes-macbook-pro-2.local
- **Ollama URL**: http://felipes-macbook-pro-2.local:11434
- **Role**: Primary for coding sub-agents (devstral-24b)

## 📦 Installation

Both machines use Homebrew:

```bash
brew install ollama
```

## 🔧 Configuration

### Environment Variables

Add to `~/.zshrc` or `~/.bash_profile`:

```bash
# Ollama Server Config
export OLLAMA_HOST=0.0.0.0              # Listen on all interfaces
export OLLAMA_FLASH_ATTENTION=1          # Enable flash attention
export OLLAMA_KV_CACHE_TYPE=q8_0         # 8-bit quantized KV cache
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

### Mac Mini Service (Custom LaunchAgent)

Mac Mini uses a **custom launchd plist** instead of Homebrew services. This is required because `brew services` does not reliably persist environment variables like `OLLAMA_HOST=0.0.0.0` -- after a reboot, Ollama reverts to binding `127.0.0.1` only, breaking cross-machine access.

**File**: `~/Library/LaunchAgents/com.user.ollama.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.ollama</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/opt/ollama/bin/ollama</string>
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
    <key>StandardErrorPath</key>
    <string>/tmp/ollama.err.log</string>
    <key>StandardOutPath</key>
    <string>/tmp/ollama.out.log</string>
</dict>
</plist>
```

**Migration from Homebrew services:**
```bash
# 1. Stop Homebrew service first (avoids port conflict)
brew services stop ollama

# 2. Load the custom plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.ollama.plist

# 3. Verify it's running and bound to 0.0.0.0
curl http://localhost:11434/api/tags
curl http://felipes-mac-mini.local:11434/api/tags  # from another machine
```

**Why not Homebrew services?** Homebrew's `brew services` creates an ephemeral launchd config that does not include custom environment variables. Setting `OLLAMA_HOST` in `~/.zshrc` only works for interactive shells, not launchd-spawned processes. The custom plist embeds environment variables directly, guaranteeing they persist across reboots. This was discovered after the Healer Bot detected 5 consecutive cross-machine failures (see [HYBRID-HEALING.md incident log](clawdbot/HYBRID-HEALING.md)).

**Management:**
```bash
# Check status
launchctl list | grep com.user.ollama

# Stop
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.user.ollama.plist

# Start
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.user.ollama.plist

# View logs
tail -f /tmp/ollama.out.log
tail -f /tmp/ollama.err.log
```

## 🤖 Models

### Mac Mini (16 GB RAM) — RESOURCE-CONSTRAINED!

⚠️ **CRITICAL: Swap Protection**

Mac Mini has ONLY 16GB RAM. Heavy models cause swap death:
- **gpt-oss:20b (14GB)** was causing **15.6GB swap** — system grinding to a halt
- **Solution**: Primary changed to qwen3:8b (5GB), gpt-oss as on-demand fallback ONLY

| Model | Size | Purpose | Status |
|-------|------|---------|--------|
| **qwen3:8b** | 5.2 GB | **PRIMARY** — only safe model for auto-fallback (reasoning=true) | ✅ Always loaded |
| gpt-oss:20b | 13 GB | On-demand ONLY — causes swap death if kept loaded (14GB active) | ⚠️ NOT in auto-fallback |

**Removed:**
- ❌ qwen3-fast:8b — Deleted (duplicate of qwen3:8b, freed 5.2GB disk)

**Future upgrade candidate:**
- **qwen3:14b** (Q3_K_M) — ~9GB VRAM, fits 16GB with 7GB headroom. Nearly doubles reasoning quality. Not yet pulled.

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
ollama pull qwen3:8b      # Keep loaded (5GB, safe)
ollama pull gpt-oss:20b   # On-demand only (14GB, dangerous)
```

### MacBook Pro (48 GB RAM)

| Model | Size | Purpose |
|-------|------|---------|
| **qwen3:8b** | 5.2 GB | **PRIMARY** for sub-agents/heartbeats (reasoning=true) |
| devstral-small-2:24b | 15 GB | Heavy coding tasks (48GB RAM safe) |
| gpt-oss:20b | 13 GB | General tasks fallback |

**Pull models:**
```bash
ollama pull qwen3:8b              # PRIMARY (reasoning-first)
ollama pull devstral-small-2:24b  # Heavy coding
ollama pull gpt-oss:20b           # Fallback
```

### Removed Models
- ❌ **Legacy 7B coder model** — Deleted from both machines (2025-07-27). Replaced by qwen3:8b and gpt-oss:20b.
- ❌ **qwen3-fast:8b** — Deleted from Mac Mini (2026-01-27). Duplicate of qwen3:8b, freed 5.2GB disk.

### Windows MSI — Remote Ollama via MacBook + Mac Mini
- ❌ **No local Ollama** on Windows MSI
- ✅ **Routes through both Macs** via Tailscale:
  - `ollama-macbookpro` → `http://100.125.165.107:11434` (devstral-24b, gpt-oss:20b, qwen3:8b)
  - `ollama-macmini` → `http://100.115.10.14:11434` (qwen3:8b ONLY)

### Future Models
- **qwen3:14b** (Q3_K_M) — Best upgrade for Mac Mini: ~9GB, fits 16GB with headroom
- **qwen2.5vl:32b** — Planned for Asset Forge (design vision model)

## 🌐 Mac Mini as Central Ollama Hub

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
| **MacBook Pro** | qwen3:8b (5.2GB, **PRIMARY**), devstral-small-2:24b (15GB), gpt-oss:20b (13GB) | ~33 GB | ✅ All loaded |
| **Mac Mini** | qwen3:8b (5.2GB, **PRIMARY**), gpt-oss:20b (13GB, on-demand ONLY) | ~18 GB | ⚠️ Only qwen3:8b kept loaded |
| **Windows MSI** | NONE (routes through Mac Mini) | 0 GB | ✅ Via Tailscale |

---

## 🎯 Sub-Agent Priority Chain

**Reasoning-first architecture** — sub-agents cascade with thinking enabled:

```
1. qwen3:8b (local, reasoning=true)         ← PRIMARY (FREE, smart)
2. qwen3:8b (cross-machine via Tailscale)   ← If local Ollama fails
3. devstral-small-2:24b (MacBook 48GB)      ← Heavy coding
4. gpt-oss:20b (MacBook 48GB ONLY)          ← General fallback (NOT on Mac Mini!)
5. Claude Sonnet 4.5 (API)                  ← If all local fail
6. Claude Opus 4.5 (API)                    ← Critical tasks only
```

### Heartbeat Model
- **qwen3:8b (reasoning=true) on all machines** — Always-on, FREE, thinking enabled for smarter decisions

### Why qwen3:8b as Primary?
- **Reasoning enabled**: Thinks before acting, fewer mistakes
- **5GB RAM**: Safe for Mac Mini's 16GB limit
- **FREE**: No API costs
- **Fast**: Quick inference for most tasks
- **Quality**: Qwen3.1 8B with reasoning rivals larger models

## 🌐 Network Access

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
# MacBook → Mac Mini (always-on, heartbeats)
curl http://felipes-mac-mini.local:11434/api/tags

# Mac Mini → MacBook (coding models, devstral-24b)
curl http://felipes-macbook-pro-2.local:11434/api/tags
```

**In Clawdbot config**, two providers are defined:
- `ollama` → Mac Mini (always-on)
- `ollama-macbook` → MacBook Pro (coding-focused)

**Mac Mini fallback chain:**
```
qwen3:8b (local) → MacBook qwen3 → MacBook devstral → MacBook gpt-oss → Sonnet → Opus
```
> ⚠️ No gpt-oss:20b in Mac Mini auto-fallback — goes to MacBook instead!

**MacBook fallback chain:**
```
Opus → Sonnet → devstral-24b → gpt-oss:20b → qwen3:8b (all local/safe on 48GB)
```

This means: **if one machine's Ollama fails, the other catches it automatically**. Zero downtime.

### Tailscale CLI Fix

Tailscale userspace mode requires a socket flag for CLI:

```bash
# Add to ~/.zshrc
alias tailscale='tailscale --socket=~/.tailscale/tailscaled.sock'
```

## ⚡ Performance Tuning

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
- **Mac Mini (16 GB)**: Can run gpt-oss:20b (13 GB) with headroom
- **MacBook (48 GB)**: Can run devstral-small-2:24b (15 GB) + multiple contexts

## 🛠️ Management Commands

### List Models
```bash
ollama list
```

### Pull/Update Models
```bash
ollama pull gpt-oss:20b
```

### Remove Models
```bash
ollama rm <model-name>  # Remove unused models to free disk space
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

## 🔥 Firewall & Security

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

## 🐛 Troubleshooting

### Service Not Starting
```bash
# Check logs (launchd on MacBook)
tail -f /tmp/ollama.err.log

# Check logs (Homebrew on Mac Mini)
brew services info ollama

# Restart
launchctl stop com.ollama.serve && launchctl start com.ollama.serve  # MacBook
brew services restart ollama  # Mac Mini
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
ollama pull gpt-oss:20b
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
echo $OLLAMA_HOST  # Should be 0.0.0.0

# Test local
curl http://localhost:11434/api/tags

# Test via hostname
curl http://felipes-mac-mini.local:11434/api/tags

# Test Tailscale IP
curl http://100.115.10.14:11434/api/tags

# Check Tailscale status
tailscale status
```

## 📊 Monitoring

### Check Inference Speed
```bash
time ollama run gpt-oss:20b "What is 2+2?"
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

## 📚 References

- [Ollama Docs](https://ollama.ai/docs)
- [Flash Attention Paper](https://arxiv.org/abs/2205.14135)
- [Clawdbot Config](clawdbot-config.md) — Model routing
- [Tailscale Setup](tailscale.md) — Network configuration
