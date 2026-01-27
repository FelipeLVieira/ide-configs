# Three-Machine Architecture

Complete infrastructure documentation across all 3 machines in the Clawdbot ecosystem.

> **Last updated**: January 2025 — Reasoning-first models, swap protection, cross-machine fallback

---

## 🖥️ Machine 1: MacBook Pro (48GB RAM) — Orchestrator

**Role**: Main session (Claude Opus), heavy sub-agent compute, orchestration

### Ollama Models
| Model | Size | Purpose |
|-------|------|---------|
| **qwen3:8b** | 5.2 GB | **PRIMARY** for sub-agents/heartbeats (reasoning=true) |
| devstral-small-2:24b | 15 GB | Heavy coding tasks (48GB RAM safe) |
| gpt-oss:20b | 13 GB | General tasks fallback |

### Clawdbot Config
| Setting | Value |
|---------|-------|
| **Main model** | `anthropic/claude-opus-4-5` |
| **Fallbacks** | Sonnet → qwen3:8b → devstral-24b → gpt-oss:20b |
| **Heartbeat** | `ollama/qwen3:8b` (reasoning=true, via Mac Mini, **FREE**) |
| **Sub-agents** | `ollama/qwen3:8b` (reasoning=true) → `ollama-macbook/devstral-small-2:24b` → `ollama/gpt-oss:20b` → Sonnet → Opus |
| **Thinking** | `thinkingDefault: "low"` (Opus always thinks) |

### Services
- **Clawdbot Gateway** — AI orchestrator (port 18789+)
- **Ollama** — Local LLM inference (port 11434, launchd)
- **event-watcher.sh** — Self-healing bash loop (launchd, 60s interval)
- **Bash cleanup scripts** — macbook-cleanup.sh (launchd, 15 min)

### Self-Healing
- **event-watcher.sh** (60s loop) — Monitors Ollama, pm2, zombies, simulators
- **Cleaner Bot** (hourly cron) — Deep cleanup (caches, temp files, disk)
- **Healer Bot** (hourly cron) — Read event logs, diagnose, smart healing

### Network
- **Hostname**: `felipes-macbook-pro-2.local`
- **Tailscale IP**: `100.125.165.107`
- **Ollama URL**: `http://felipes-macbook-pro-2.local:11434`
- **Ports**: 11434 (Ollama), 18789+ (Clawdbot)

---

## 🖥️ Machine 2: Mac Mini (16GB RAM) — Always-On Server

**Role**: **CENTRAL BRAIN** — Always-on services, heartbeats, Ollama hub for all machines, game servers

### Ollama Models

⚠️ **CRITICAL: Mac Mini has only 16GB RAM!**

| Model | Size | Purpose | Status |
|-------|------|---------|--------|
| **qwen3:8b** | 5.2 GB | **PRIMARY** model (reasoning=true, safe for 16GB RAM) | ✅ Always loaded |
| gpt-oss:20b | 13 GB | On-demand fallback (DeepSeek-V3, causes swap) | ⚠️ NOT kept loaded |
| qwen3-fast:8b | 5.2 GB | Faster variant for quick responses | Optional |

**Swap Protection:**
- gpt-oss:20b (14GB) was causing **15.6GB swap** — SWAP DEATH
- Primary changed to qwen3:8b (5GB) — safe for 16GB
- Healer Bot v3 monitors swap and auto-unloads heavy models
- desired-state.json has resource_limits: swap_warn_gb=8, critical=12, max_loaded_model_gb=6

### Clawdbot Config
| Setting | Value |
|---------|-------|
| **Main model** | `ollama/qwen3:8b` (reasoning=true, **FREE**) |
| **Fallbacks** | `ollama/gpt-oss:20b` (on-demand) → `ollama-macbook/qwen3:8b` → Sonnet → Opus |
| **Heartbeat** | `ollama/qwen3:8b` (reasoning=true, **FREE**) |
| **Sub-agents** | `ollama/qwen3:8b` (reasoning=true) → `ollama/gpt-oss:20b` → Sonnet → Opus |
| **Thinking** | `thinkingDefault: "low"` (qwen3:8b with reasoning=true) |

### Services
- **Clawdbot Gateway** — AI orchestrator (port 18789)
- **Ollama** — Local LLM inference (port 11434, Homebrew service)
- **pm2** — Process manager for game servers
- **clawd-monitor** — Bot dashboard (port 9009)

### pm2 Processes
| Process | Port | Description |
|---------|------|-------------|
| aphos-server-prod | 2567 | Aphos game server (production) |
| aphos-server-dev | 2568 | Aphos game server (development) |

### Agents
- **main** — Primary Clawdbot agent
- **aphos** — Game server management bot
- **shitcoin-bot** — Trading research bot

### Session Data
- **64 session files** — Persistent sessions for all projects
- Sessions survive reboots via pm2 and tmux

### Network
- **Hostname**: `felipes-mac-mini.local`
- **Tailscale IP**: `100.115.10.14`
- **Ollama URL**: `http://felipes-mac-mini.local:11434`
- **Ports**: 11434 (Ollama), 18789 (Clawdbot), 9009 (clawd-monitor), 2567-2568 (Aphos)

---

## 🖥️ Machine 3: Windows MSI — Dedicated Windows Bot

**Role**: Windows-specific automation tasks  
**Identity**: "Clawdbot Master Windows" 🖥️

### Ollama Models
- ❌ **No local Ollama** — Routes ALL inference through Mac Mini via Tailscale

### Clawdbot Config
| Setting | Value |
|---------|-------|
| **Main model** | `anthropic/claude-opus-4-5` |
| **Fallbacks** | `ollama-macmini/qwen3:8b` (reasoning=true) → Sonnet → Opus |
| **Heartbeat** | `ollama-macmini/qwen3:8b` (reasoning=true, via Mac Mini, **FREE**) |
| **Sub-agents** | `ollama-macmini/qwen3:8b` (reasoning=true) → Sonnet → Opus |
| **Ollama provider** | `ollama-macmini` → `http://100.115.10.14:11434` |
| **Auto-start** | Windows Scheduled Task "ClawdbotGateway" (runs on login) |
| **Thinking** | `thinkingDefault: "low"` (Opus always thinks) |

### Architecture Flow
```
Windows MSI → Mac Mini Ollama (100.115.10.14:11434)
                    ↓ (if needed)
              MacBook Ollama (felipes-macbook-pro-2.local:11434)
                    ↓ (last resort)
              Claude API (Sonnet → Opus)
```

### ✅ Credit Leak FIXED
Previously 100% Claude-powered. Now routes through Mac Mini's Ollama via Tailscale — **FREE local inference** for most tasks.

### Network
- **Tailscale IP**: `100.67.241.32`
- **SSH**: `ssh msi` from both Macs (SOCKS proxy through Tailscale)
- **User**: `felip`
- **Note**: Both Macs use Tailscale in userspace-networking mode (SOCKS5 on `localhost:1055`)

---

## 🌐 Network Topology

```
MacBook Pro (48GB) ←──local network──→ Mac Mini (16GB) ← CENTRAL BRAIN
       ↕                                    ↕
    Tailscale                           Tailscale
       ↕                                    ↕
Windows MSI ───Ollama via Tailscale───→ Mac Mini (100.115.10.14:11434)

Heartbeat routing (reasoning-first):
  MacBook  → Mac Mini Ollama (qwen3:8b, reasoning=true)
  Mac Mini → Local Ollama (qwen3:8b, reasoning=true)
  Windows  → Mac Mini Ollama via Tailscale (qwen3:8b, reasoning=true)

Cross-machine fallback (NEW):
  Mac Mini Ollama fails → MacBook Ollama catches it
  MacBook Ollama fails → Mac Mini Ollama catches it
  Automatic failover, zero downtime
```

### Tailscale IPs

| Device | IP | Role |
|--------|----|------|
| MacBook Pro | `100.125.165.107` | Orchestrator |
| Mac Mini | `100.115.10.14` | Always-on server |
| Windows MSI | `100.67.241.32` | Windows bot |
| iPhone | `100.89.50.26` | Mobile access |

### SSH Access
```bash
# MacBook → Mac Mini
ssh felipemacmini@felipes-mac-mini.local

# MacBook → Windows MSI
ssh msi  # Uses SOCKS proxy through Tailscale

# Mac Mini → Windows MSI
ssh msi  # Same SOCKS proxy config
```

### Cross-Machine Ollama Access
```bash
# MacBook → Mac Mini Ollama
curl http://felipes-mac-mini.local:11434/api/tags
curl http://100.115.10.14:11434/api/tags  # Tailscale

# Mac Mini → MacBook Ollama
curl http://felipes-macbook-pro-2.local:11434/api/tags
curl http://100.125.165.107:11434/api/tags  # Tailscale
```

---

## 💰 Cost Analysis by Machine

| Machine | Local Models | API Usage | Monthly Estimate |
|---------|-------------|-----------|-----------------|
| MacBook Pro | ✅ 3 models (FREE compute) | Opus for main session | $50-100 |
| Mac Mini | ✅ 3 models (FREE compute) | Minimal API (fallback only) | $5-15 |
| Windows MSI | ✅ Via Mac Mini Ollama (FREE) | Sonnet/Opus fallback only | $5-15 |

**Total estimated**: $60-130/month (down from $300+ before local LLMs)

---

## 📋 Quick Reference: Which Machine for What?

| Task | Machine | Why |
|------|---------|-----|
| Main chat session | MacBook | Opus 4.5 (thinking=low) + orchestration |
| Sub-agent coding | MacBook | qwen3:8b (reasoning=true), devstral-24b (48GB RAM) |
| Heartbeats | Mac Mini | Always-on, qwen3:8b (reasoning=true, FREE) |
| Game servers (Aphos) | Mac Mini | pm2, always-on |
| **Trading bot (Shitcoin)** | **MacBook** | **48GB RAM for heavy models** |
| iOS builds | Mac Mini | Xcode, simulators |
| Bot dashboard | Mac Mini | clawd-monitor:9009 |
| Windows tasks | Windows MSI | Only Windows machine |
| Self-healing | MacBook + Mac Mini | event-watcher + Healer Bot v3 (swap monitoring) |

---

## 📚 References

- [Clawdbot Config](../clawdbot-config.md) — Model routing details
- [Ollama Setup](../ollama-setup.md) — Local LLM configuration
- [Tailscale](../tailscale.md) — Network configuration
- [SSH Config](../ssh-config.md) — SSH setup
- [Dev Teams](../dev-teams.md) — Bot roles per project
- [Hybrid Healing](../clawdbot/HYBRID-HEALING.md) — Self-healing architecture
