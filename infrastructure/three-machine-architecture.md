# Three-Machine Architecture

Complete infrastructure documentation across all 3 machines in the Clawdbot ecosystem.

> **Last updated**: 2026-01-27 — Config audit, swap protection enforced, Windows dual-provider, stale cleanup

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
| **Fallbacks** | Sonnet → devstral-24b → gpt-oss:20b → qwen3:8b |
| **Heartbeat** | `ollama/qwen3:8b` (local, reasoning=true, **FREE**) |
| **Sub-agents** | `ollama/qwen3:8b` → `ollama-macbook/qwen3:8b` → `ollama-macbook/devstral-small-2:24b` → `ollama/gpt-oss:20b` → Sonnet → Opus |
| **Thinking** | `thinkingDefault: "low"` (always) |

### Ollama Providers
| Provider | URL | Models |
|----------|-----|--------|
| `ollama` | `http://127.0.0.1:11434` (Mac Mini via config) | qwen3:8b, gpt-oss:20b |
| `ollama-macbook` | `http://felipes-macbook-pro-2.local:11434` | qwen3:8b, devstral-24b, gpt-oss:20b |

### Services
- **Clawdbot Gateway** — AI orchestrator (launchd)
- **Ollama** — Local LLM inference (port 11434, launchd)
- **event-watcher.sh** — Self-healing bash loop (launchd, 60s)
- **Tailscale** — Userspace networking mode (SOCKS5 on localhost:1055)

### Network
- **Hostname**: `felipes-macbook-pro-2.local`
- **Tailscale IP**: `100.125.165.107`
- **Ollama URL**: `http://100.125.165.107:11434` (Tailscale) or `http://felipes-macbook-pro-2.local:11434` (local)

---

## 🖥️ Machine 2: Mac Mini (16GB RAM) — Always-On Server

**Role**: Always-on services, heartbeats, game servers, iOS builds, bot dashboard

### Ollama Models

⚠️ **CRITICAL: Mac Mini has only 16GB RAM — swap protection enforced!**

| Model | Size | Purpose | Status |
|-------|------|---------|--------|
| **qwen3:8b** | 5.2 GB | **PRIMARY** — only model safe for auto-fallback (reasoning=true) | ✅ Always loaded |
| gpt-oss:20b | 13 GB | On-demand ONLY — causes swap death if kept loaded (14GB active) | ⚠️ NOT in auto-fallback |

**Swap Protection Rules:**
- gpt-oss:20b (14GB) was causing **15.6GB swap** — system grinding to a halt
- gpt-oss:20b is **NEVER** in any automatic fallback chain on Mac Mini
- Only qwen3:8b (5GB) is in auto-fallbacks — leaves 11GB for OS + services
- Healer Bot v3 monitors swap hourly; auto-unloads heavy models if swap >8GB
- desired-state.json limits: swap_warn=8GB, swap_critical=12GB, max_loaded_model=6GB

**Removed models:**
- ❌ qwen3-fast:8b — Deleted (duplicate of qwen3:8b, wasted 5.2GB disk)

### Clawdbot Config
| Setting | Value |
|---------|-------|
| **Main model** | `ollama/qwen3:8b` (local, reasoning=true, **FREE**) |
| **Fallbacks** | MacBook qwen3:8b → MacBook devstral-24b → MacBook gpt-oss:20b → Sonnet → Opus |
| **Heartbeat** | `ollama/qwen3:8b` (local, reasoning=true, **FREE**) |
| **Sub-agents** | `ollama/qwen3:8b` → MacBook qwen3 → MacBook devstral → MacBook gpt-oss → Sonnet → Opus |
| **Thinking** | `thinkingDefault: "low"` |

> ⚠️ **No gpt-oss:20b in any auto-fallback chain.** If Mac Mini local fails, it goes to MacBook, NOT to a bigger local model.

### Ollama Providers
| Provider | URL | Models |
|----------|-----|--------|
| `ollama` | `http://127.0.0.1:11434` | qwen3:8b |
| `ollama-macbook` | `http://100.125.165.107:11434` (Tailscale IP) | qwen3:8b, devstral-24b, gpt-oss:20b |

### Services
| Service | Port | Purpose |
|---------|------|---------|
| Clawdbot Gateway | 18789 | AI orchestrator (launchd) |
| Ollama | 11434 | Local LLM inference (Homebrew service) |
| clawd-monitor | 9009 | Bot dashboard |
| Aphos prod server | 2567 | Game server (pm2) |
| Aphos dev server | 2568 | Game server (pm2) |
| Python trading bot | 8080 | Shitcoin bot (run_bots) |

### Active tmux Sessions
| Session | Project |
|---------|---------|
| bot-aphos | Game server management |
| bot-clawd-monitor | Dashboard dev |
| bot-ios-bills | Bills Tracker iOS builds |
| bot-ios-bmi | BMI Calculator iOS builds |
| bot-ios-translator | Screen Translator iOS builds |

**Cleaned up (2026-01-27):** Killed 5 stale tmux sessions: bot-ez-crm, bot-linklounge, bot-game-assets, bot-swarm-reviewer, bot-swarm-tester. These are now handled by cron jobs / isolated sessions.

### Network
- **Hostname**: `felipes-mac-mini.local`
- **Tailscale IP**: `100.115.10.14`
- **Ollama URL**: `http://100.115.10.14:11434` (Tailscale) or `http://felipes-mac-mini.local:11434` (local)

---

## 🖥️ Machine 3: Windows MSI — Secondary Bot

**Role**: Windows-specific automation tasks
**Identity**: "Clawdbot Master Windows" 🖥️

### Ollama Models
- ❌ **No local Ollama** — Routes ALL inference through MacBook Pro + Mac Mini via Tailscale

### Clawdbot Config
| Setting | Value |
|---------|-------|
| **Main model** | `anthropic/claude-opus-4-5` |
| **Fallbacks** | Sonnet → MacBook devstral-24b → MacBook gpt-oss:20b → MacBook qwen3:8b → Mac Mini qwen3:8b |
| **Heartbeat** | `ollama-macmini/qwen3:8b` (via Tailscale, reasoning=true, **FREE**) |
| **Sub-agents** | Mac Mini qwen3:8b → MacBook qwen3 → MacBook devstral → MacBook gpt-oss → Sonnet → Opus |
| **Thinking** | `thinkingDefault: "low"` |

### Ollama Providers (TWO remote providers)
| Provider | URL | Models |
|----------|-----|--------|
| `ollama-macbookpro` | `http://100.125.165.107:11434` | devstral-24b, gpt-oss:20b, qwen3:8b |
| `ollama-macmini` | `http://100.115.10.14:11434` | qwen3:8b ONLY |

> Windows has access to both Macs' Ollama — MacBook for heavy models, Mac Mini for always-on qwen3:8b.

### Network
- **Tailscale IP**: `100.67.241.32`
- **SSH**: `ssh msi` from both Macs (SOCKS proxy through Tailscale)
- **User**: `felip`

---

## 🌐 Network Topology

```
┌──────────────────────────────────────────────────┐
│          MacBook Pro (48GB) — ORCHESTRATOR        │
│  Main: Opus 4.5 | Local: qwen3, devstral, gpt-oss│
│  Tailscale: 100.125.165.107                       │
└─────────┬──────────────────────────┬─────────────┘
          │ local + Tailscale        │ Tailscale
          ▼                          │
┌─────────────────────────────┐     │
│  Mac Mini (16GB) — ALWAYS ON │     │
│  Local: qwen3:8b ONLY (safe) │     │
│  Tailscale: 100.115.10.14    │     │
└─────────┬───────────────────┘     │
          │ Tailscale                │
          ▼                          ▼
┌──────────────────────────────────────────────────┐
│          Windows MSI — SECONDARY                  │
│  No local models                                  │
│  Routes to MacBook (heavy) + Mac Mini (heartbeat) │
│  Tailscale: 100.67.241.32                         │
└──────────────────────────────────────────────────┘

Cross-machine failover:
  Mac Mini local fails → MacBook catches it (via Tailscale)
  MacBook Ollama fails → Mac Mini catches it (via local/Tailscale)
  Automatic failover, zero manual intervention
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

# MacBook → Windows MSI (SOCKS proxy)
ssh msi

# Mac Mini → Windows MSI (SOCKS proxy)
ssh msi
```

---

## 💰 Cost Analysis by Machine

| Machine | Local Models | API Usage | Monthly Estimate |
|---------|-------------|-----------|-----------------|
| MacBook Pro | ✅ 3 models (FREE) | Opus for main session | $50-100 |
| Mac Mini | ✅ qwen3:8b (FREE) | Minimal API (fallback only) | $5-15 |
| Windows MSI | Via MacBook + Mac Mini (FREE) | Opus main + Sonnet fallback | $10-25 |

**Total estimated**: $65-140/month (down from $300+ before local LLMs)

---

## 📋 Quick Reference: Which Machine for What?

| Task | Machine | Why |
|------|---------|-----|
| Main chat session | MacBook | Opus 4.5 + orchestration |
| Sub-agent coding | MacBook | devstral-24b (48GB RAM) |
| Heartbeats | Mac Mini (local) or MacBook (local) | Always-on, qwen3:8b, FREE |
| Game servers (Aphos) | Mac Mini | pm2, always-on |
| Trading bot (Shitcoin) | Mac Mini (Python) | Always-on, run_bots |
| iOS builds | Mac Mini | Xcode, simulators |
| Bot dashboard | Mac Mini | clawd-monitor:9009 |
| Windows tasks | Windows MSI | Only Windows machine |
| Self-healing | Both Macs | event-watcher + Healer Bot v3 |

---

## 🔄 Change Log

### 2026-01-27: Config Audit & Swap Protection
- **gpt-oss:20b removed from ALL Mac Mini auto-fallbacks** (was causing 15.6GB swap death)
- **Windows MSI: added MacBook Pro as second Ollama provider** (was only Mac Mini before)
- **Mac Mini: MacBook URL changed to Tailscale IP** (100.125.165.107 instead of .local hostname)
- **Deleted qwen3-fast:8b** from Mac Mini (duplicate, freed 5.2GB disk)
- **Killed 5 stale tmux sessions** on Mac Mini (ez-crm, linklounge, game-assets, swarm-reviewer, swarm-tester)
- **Cleaned 15GB** across all machines (node_modules, brew packages, stale builds, _archive)

### 2026-01-27: Reasoning-First Architecture
- All machines now use `thinkingDefault: "low"`
- qwen3:8b (reasoning=true) is PRIMARY for all sub-agents and heartbeats
- gpt-oss:20b changed from primary to on-demand fallback on Mac Mini

### 2026-01-27: Windows MSI Dual-Provider
- Windows now routes to BOTH MacBook (heavy models) and Mac Mini (heartbeats)
- Main model: Opus 4.5 (unchanged)
- Subagents: Mac Mini qwen3:8b (free) → MacBook models → API fallback

---

## 📚 References

- [Clawdbot Config](../clawdbot-config.md) — Model routing details
- [Ollama Setup](../ollama-setup.md) — Local LLM configuration
- [Tailscale](../tailscale.md) — Network configuration
- [SSH Config](../ssh-config.md) — SSH setup
- [Dev Teams](../dev-teams.md) — Bot roles per project
- [Hybrid Healing](../clawdbot/HYBRID-HEALING.md) — Self-healing architecture
