# Three-Machine Architecture

Complete infrastructure documentation across all 3 machines in the Clawdbot ecosystem.

> **Last updated**: 2026-01-28 (late night) — Anthropic-only routing, local models removed from fallbacks, cron delivery → clawd-status API, new cron jobs (EZ-CRM, LinkLounge, iOS Dev), Mac Mini is NODE only

---

## Machine 1: MacBook Pro (48GB RAM) — Orchestrator

**Role**: Main session (Opus 4.5), ALL cron jobs, ALL heartbeats, sub-agent orchestration

### Model Routing (Anthropic-Only)
| Setting | Value |
|---------|-------|
| **Main model** | `anthropic/claude-opus-4-5` |
| **Fallback** | `anthropic/claude-sonnet-4-5` (Anthropic only) |
| **Heartbeat** | `anthropic/claude-sonnet-4-5` (60min) |
| **Sub-agents** | `anthropic/claude-sonnet-4-5` → `anthropic/claude-opus-4-5` |
| **Cron jobs** | `anthropic/claude-sonnet-4-5` (all hourly, staggered) |
| **Thinking** | `thinkingDefault: "off"` (saves tokens, enables concurrency) |

> ⚠️ **NO local Ollama models in fallback chains.** All auto-routing is Anthropic-only. Local models available for manual use.

### Ollama Models (Manual Use Only — NOT in auto-routing)
| Model | Size | Purpose |
|-------|------|---------|
| mistral-small3.2:24b | 15 GB | General text generation |
| gemma3:12b | ~8 GB | Vision-capable (image input) |

### Services
| Service | Port | Purpose |
|---------|------|---------|
| Clawdbot Gateway | 18789 | AI orchestrator (LaunchAgent) |
| Ollama | 11434 | Local LLM inference (LaunchAgent) |
| Crabwalk | 9009 | Bot monitoring dashboard |
| clawd-status | 9010 | Status dashboard + health checks + cron monitoring |
| event-watcher.sh | — | Self-healing bash loop (LaunchAgent, 60s) |
| Tailscale | — | Userspace networking mode (SOCKS5 on localhost:1055) |

### Cron Jobs (ALL run here)
| Time | Job | Purpose |
|------|-----|---------|
| `:00` | Cleaner Bot + Healer Team | Cleanup + SRE healing |
| `:05` | EZ-CRM Dev Bot | Autonomous dev cycle |
| `:10` | LinkLounge Dev Bot | Autonomous dev cycle |
| `:15` | iOS App Dev Bot | iOS builds + testing |
| Every 6h | R&D Research | AI news monitoring |
| 3x/day | App Store Manager | iOS app monitoring |
| Weekly Sun | Clear Sessions | Stale session cleanup |

All cron jobs: `deliver=false` → reports to clawd-status API, NOT Telegram.

### Network
| Property | Value |
|----------|-------|
| Hostname | `felipes-macbook-pro-2.local` |
| Tailscale IP | `100.125.165.107` |
| Ollama URL | `http://100.125.165.107:11434` (Tailscale) |

---

## Machine 2: Mac Mini (16GB RAM) — Always-On Node

**Role**: Always-on services (game servers, PM2, iOS builds). **NODE** connected to MacBook orchestrator. Does NOT run cron jobs independently.

### Model Routing (Anthropic-Only)
| Setting | Value |
|---------|-------|
| **Main model** | `anthropic/claude-sonnet-4-5` |
| **Fallback** | `anthropic/claude-opus-4-5` (Anthropic only) |
| **Sub-agents** | `anthropic/claude-sonnet-4-5` → `anthropic/claude-opus-4-5` |
| **Thinking** | `thinkingDefault: "medium"` |

> Mac Mini is a **NODE** connected to the MacBook orchestrator. It does NOT run cron jobs.

### Ollama Models (Manual Use Only — NOT in auto-routing)

⚠️ **CRITICAL: Mac Mini has only 16GB RAM — swap protection enforced!**

| Model | Size | Purpose | Status |
|-------|------|---------|--------|
| phi4-mini | 2.5 GB | Ultra-fast (~37-41 t/s), manual use | Available |
| phi4:14b | 9.1 GB | Reasoning tasks, manual use | Available |

### Ollama Providers
| Provider | URL | Notes |
|----------|-----|-------|
| `ollama` (local) | `http://127.0.0.1:11434` | phi4-mini, phi4:14b |
| `ollama-macbook` (remote) | `http://10.144.238.116:11434/v1` | LAN IP (hostname doesn't resolve from Mac Mini) |

### Services (PM2 Managed)
| Service | Port | Purpose | PM2 Name |
|---------|------|---------|----------|
| Aphos prod server | 2567 | Game server | `aphos-server-prod` |
| Aphos dev server | 2568 | Game server | `aphos-server-dev` |
| Ollama | 11434 | Local LLM | `ollama` |
| Clawdbot Gateway | 18789 | AI orchestrator | `clawdbot-gateway` |

### Node Connection
- Connected to MacBook orchestrator as a NODE
- Capabilities: browser, system, system.run
- LaunchAgent: `com.clawdbot.node.plist` (may need manual start via `nohup` after reboot)
- **Note**: LaunchAgent bootstrap fails via SSH (no GUI domain access). After reboot, may need manual start.

### Network
| Property | Value |
|----------|-------|
| Hostname | `felipes-mac-mini.local` |
| Tailscale IP | `100.115.10.14` |
| Ollama URL | `http://100.115.10.14:11434` (Tailscale) |

---

## Machine 3: Windows MSI — Telegram Bot

**Role**: Windows-specific Telegram chat only. Minimal config.

### Model Routing (Anthropic-Only)
| Setting | Value |
|---------|-------|
| **Main model** | `anthropic/claude-sonnet-4-5` |
| **Fallback** | `anthropic/claude-opus-4-5` (Anthropic only) |
| **Identity** | "Clawdbot Master Windows" 🖥️ |
| **Telegram** | Separate bot token (8506493579) |
| **Cron** | None |
| **Heartbeat** | Disabled |
| **Thinking** | `thinkingDefault: "medium"` |

> Windows is **Telegram-only**. No cron, no heartbeat, no sub-agents. Separate bot token from MacBook.

### Services
| Service | Purpose |
|---------|---------|
| Clawdbot Gateway | AI orchestrator (2 node.exe processes) |

- 31 node.exe processes total, 65GB RAM, 18GB available
- No local Ollama (routes through Anthropic API directly)
- Previous: routed through Mac Mini Ollama → **REMOVED** (now Anthropic direct)

### Network
| Property | Value |
|----------|-------|
| Tailscale IP | `100.67.241.32` |
| SSH | `ssh msi` from both Macs (SOCKS proxy through Tailscale) |
| User | `felip` |

---

## Network Topology

```
       MacBook Pro (48GB) — ORCHESTRATOR
  Main: Opus 4.5 | All cron/heartbeat: Sonnet 4.5
  ALL routing: Anthropic-only (no local model fallbacks)
  Services: Crabwalk (9009), clawd-status (9010), Gateway (18789)
  Ollama: mistral-small3.2, gemma3:12b (manual use only)
  Tailscale: 100.125.165.107

        LAN + Tailscale          Tailscale
              ↕                      ↕

       Mac Mini (16GB) — ALWAYS-ON NODE
  NODE connected to MacBook orchestrator
  No independent cron jobs
  Ollama: phi4-mini, phi4:14b (manual use only)
  MacBook Ollama: http://10.144.238.116:11434/v1 (LAN IP)
  PM2: aphos-server-prod, aphos-server-dev, ollama, clawdbot-gateway
  Tailscale: 100.115.10.14

        Tailscale
              ↕

       Windows MSI — TELEGRAM BOT
  Sonnet 4.5 only (Anthropic direct, no Ollama routing)
  Telegram-only usage (separate bot token)
  No cron, no heartbeat
  Tailscale: 100.67.241.32
```

### Tailscale IPs

| Device | IP | Role |
|--------|----|------|
| MacBook Pro | `100.125.165.107` | Orchestrator |
| Mac Mini | `100.115.10.14` | Always-on node |
| Windows MSI | `100.67.241.32` | Telegram bot |
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

## Cost Analysis by Machine (Updated Jan 28)

| Machine | Local Models | API Usage | Monthly Estimate |
|---------|-------------|-----------|-----------------|
| MacBook Pro | Manual use only (FREE) | Opus main + Sonnet all cron/heartbeat/subagents | $200-275 |
| Mac Mini | Manual use only (FREE) | Sonnet via node (minimal) | $10-20 |
| Windows MSI | None | Sonnet Telegram chat | $5-15 |

**Total estimated**: $215-310/month
- Cron + heartbeat: ~$201/month (see [cron-schedule.md](../cron-schedule.md))
- Main session Opus: ~$60-80/month
- Sub-agents: ~$15/month
- **Trade-off**: Local models can't tool-call, so Anthropic is required for all agentic work

---

## Quick Reference: Which Machine for What?

| Task | Machine | Why |
|------|---------|-----|
| Main chat session | MacBook | Opus 4.5 + orchestration |
| ALL cron jobs | MacBook | Sonnet 4.5, orchestrator |
| Heartbeats | MacBook | Sonnet 4.5, needs tools |
| Sub-agents | MacBook | Sonnet 4.5, needs tools |
| Game servers (Aphos) | Mac Mini | PM2, always-on |
| iOS builds | Mac Mini | Xcode, simulators (ONE at a time!) |
| Status dashboard | MacBook | clawd-status:9010 |
| Bot dashboard | MacBook | Crabwalk:9009 |
| Windows Telegram | Windows MSI | Separate bot token |
| Self-healing | MacBook | event-watcher + Healer Team cron |

---

## Change Log

### 2026-01-28 (Late Night): Anthropic-Only Routing + Cron Overhaul
- **ALL local Ollama models REMOVED from ALL fallback chains** (all 3 machines)
- **Main session**: Opus 4.5 → Sonnet 4.5 (Anthropic only)
- **All bots/cron/subagents**: Sonnet 4.5 → Opus 4.5 (Anthropic only)
- **New cron jobs**: EZ-CRM Dev (:05), LinkLounge Dev (:10), iOS App Dev (:15)
- **All cron delivery disabled**: `deliver=false`, reports to clawd-status API
- **Auth rotation**: `felipe.lv.90` → `wisedigital`
- **Auth cooldowns increased**: billingBackoff 2h, billingMax 8h, failureWindow 2h
- **Mac Mini role clarified**: NODE only, no independent cron jobs
- **Windows simplified**: Sonnet 4.5 direct, no Ollama routing, Telegram-only
- **Healer Team redesigned**: Multi-agent SRE team (Diagnostics → Analyst → Fixer → Verifier)
- **clawd-status dashboard**: Port 9010, cron monitoring + log viewer
- **Crabwalk updates**: Session grouping, active-only sidebar, heartbeat modal

### 2026-01-28 (Earlier): All Cron/Heartbeats → Sonnet 4.5
- All 7 local Ollama models confirmed failing at tool-calling
- Mac Mini → MacBook Ollama URL fixed to LAN IP (10.144.238.116)
- R&D cron switched from qwen3-coder:30b to Sonnet 4.5
- clawd-status dashboard added

### 2026-01-27: Config Audit & Swap Protection
- gpt-oss:20b removed from Mac Mini auto-fallbacks
- Windows MSI: added MacBook as second Ollama provider
- Deleted qwen3-fast:8b (freed 5.2GB)
- Cleaned 15GB across all machines

---

## References

- [Clawdbot Config](../clawdbot-config.md) — Model routing details
- [Model Routing](../model-routing.md) — Detailed routing documentation
- [Cron Schedule](../cron-schedule.md) — All cron jobs and schedules
- [Ollama Setup](../ollama-setup.md) — Local LLM configuration
- [Tailscale](../tailscale.md) — Network configuration
- [SSH Config](../ssh-config.md) — SSH setup
- [Dev Teams](../dev-teams.md) — Bot roles per project
- [Port Assignments](port-assignments.md) — Master port registry
