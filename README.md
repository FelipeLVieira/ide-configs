# IDE Configs

Personal configuration files for Claude Code, Cursor, VSCode, Clawdbot, and the multi-machine bot infrastructure.

> **Last updated**: 2026-01-28 — Anthropic-only model routing, new cron schedule, clawd-status dashboard

## Quick Start

```bash
# Clone
git clone git@github.com:FelipeLVieira/ide-configs.git ~/repos/ide-configs
cd ~/repos/ide-configs

# Install (macOS/Linux)
./install.sh

# Sync to Mac Mini
./mac-mini/sync-to-mini.sh
```

## Repository Structure

```
ide-configs/
├── clawd/                    # Clawdbot WORKSPACE files (deployed to ~/clawd/)
│   ├── AGENTS.md             # Behavior rules, memory, safety
│   ├── SOUL.md               # Personality & tone
│   ├── USER.md               # Human profile (Felipe)
│   ├── IDENTITY.md           # Bot identity
│   ├── HEARTBEAT.md          # Periodic check tasks
│   ├── TOOLS.md              # Tool configurations
│   ├── CROSS-BOT-BRIEFING.md # Inter-bot protocols
│   ├── scripts/              # Auto-resume, shutdown scripts
│   └── docs/ARCHITECTURE.md  # Multi-account failover
│
├── clawdbot/                 # Clawdbot OPERATIONS docs (reference only)
│   ├── PERSISTENT-BOTS.md    # Bot architecture
│   ├── HYBRID-HEALING.md     # Self-healing system
│   ├── CREDIT-OPTIMIZATION.md# Cost savings strategies
│   ├── APP-STORE-MANAGER.md  # iOS App Store cron
│   └── ...
│
├── infrastructure/           # Multi-machine architecture
│   ├── three-machine-architecture.md  # Full 3-machine overview
│   └── port-assignments.md   # Master port registry
│
├── claude/                   # Claude Code CLI configs
├── mcp/                      # MCP Server configs
├── mac-mini/                 # Mac Mini server setup
├── project-templates/        # Per-project CLAUDE.md templates
├── homebrew/                 # Brewfiles
├── vscode/                   # VSCode settings
├── git/                      # Git configs
├── ssh/                      # SSH configs
│
├── clawdbot-config.md        # 🔑 Model routing & configuration
├── model-routing.md          # 🔑 Detailed routing documentation (NEW)
├── cron-schedule.md          # 🔑 Full cron job schedule (NEW)
├── dev-teams.md              # Bot roles & assignments
├── ollama-setup.md           # Local LLM setup (manual use only)
├── rd-research-team.md       # R&D research cron
├── tailscale.md              # Private mesh VPN
└── ssh-config.md             # SSH setup
```

### `clawd/` vs `clawdbot/` — What's the Difference?

| Folder | Purpose | Deployed to |
|--------|---------|-------------|
| **`clawd/`** | **Workspace files** — AGENTS.md, SOUL.md, USER.md | `~/clawd/` on each machine |
| **`clawdbot/`** | **Operations docs** — architecture, healing, monitoring | Reference only (not deployed) |

---

## Three-Machine Architecture

```
     MacBook Pro (48GB) — ORCHESTRATOR
     Main: Opus 4.5 | All cron/heartbeat: Sonnet 4.5
     ALL routing: Anthropic-only (no local fallbacks)
     Services: Crabwalk (9009), clawd-status (9010), Gateway (18789)
                    ↕
     Mac Mini (16GB) — ALWAYS-ON NODE
     Connected to MacBook orchestrator
     PM2: aphos-server-prod/dev, ollama, gateway
     No independent cron jobs
                    ↕
     Windows MSI — TELEGRAM BOT
     Sonnet 4.5 only (Anthropic direct)
     Telegram-only, separate bot token
     No cron, no heartbeat
```

### Model Routing (Jan 28, 2026)

| Machine | Main | Bots/Cron/Subagents | Fallback | Local Models |
|---------|------|--------------------| ---------|-------------|
| **MacBook Pro** | Opus 4.5 | Sonnet 4.5 | Anthropic only | Manual use only |
| **Mac Mini** | Sonnet 4.5 | Sonnet 4.5 (via node) | Anthropic only | Manual use only |
| **Windows MSI** | Sonnet 4.5 | N/A (no cron) | Anthropic only | None |

> ⚠️ **ALL local Ollama models removed from fallback chains** (Jan 28). They fail at tool-calling. See [model-routing.md](model-routing.md).

### Cron Schedule (All Hourly, Staggered)

| Time | Job | Model |
|------|-----|-------|
| `:00` | Cleaner Bot + Healer Team | Sonnet 4.5 |
| `:05` | EZ-CRM Dev Bot | Sonnet 4.5 |
| `:10` | LinkLounge Dev Bot | Sonnet 4.5 |
| `:15` | iOS App Dev Bot | Sonnet 4.5 |
| Every 6h | R&D Research | Sonnet 4.5 |
| 3x/day | App Store Manager | Sonnet 4.5 |

All deliver=false → reports to clawd-status API (port 9010). See [cron-schedule.md](cron-schedule.md).

---

## Active Services

### MacBook Pro (Orchestrator)
| Service | Port | Purpose |
|---------|------|---------|
| Clawdbot Gateway | 18789 | AI orchestrator |
| Crabwalk | 9009 | Bot monitoring dashboard |
| clawd-status | 9010 | Status + cron monitoring |
| Ollama | 11434 | Local LLM (manual use only) |

### Mac Mini (Always-On Node)
| Service | Port | Purpose | Manager |
|---------|------|---------|---------|
| Aphos prod server | 2567 | Game server | PM2 |
| Aphos dev server | 2568 | Game server | PM2 |
| Ollama | 11434 | Local LLM (manual use) | PM2 |
| Clawdbot Gateway | 18789 | AI orchestrator | PM2 |

---

## Key Lessons (Jan 2026)

1. **ALL local models fail at tool-calling** — 7/7 tested, all failed
2. **Ollama translation layer has bugs** — per-model template issues
3. **devstral hallucinates** — says "Task completed" without doing work
4. **Only Anthropic models reliable** for agentic work (Sonnet/Opus)
5. **Cron Telegram delivery disabled** — use clawd-status API instead
6. **ONE simulator at a time** — Mac Mini 16GB, multiple = swap death

---

## Documentation Index

### 🔑 Key Configuration Files
- [clawdbot-config.md](clawdbot-config.md) — Master configuration reference
- [model-routing.md](model-routing.md) — Detailed model routing (NEW)
- [cron-schedule.md](cron-schedule.md) — All cron jobs and schedules (NEW)

### Infrastructure
- [Three-Machine Architecture](infrastructure/three-machine-architecture.md) — Full 3-machine overview
- [Port Assignments](infrastructure/port-assignments.md) — Master port registry

### Configuration
- [dev-teams.md](dev-teams.md) — Bot roles & assignments
- [ollama-setup.md](ollama-setup.md) — Local LLM setup (manual use only)
- [rd-research-team.md](rd-research-team.md) — R&D research cron
- [tailscale.md](tailscale.md) — Private mesh VPN
- [ssh-config.md](ssh-config.md) — SSH setup

### Operations (clawdbot/)
- [CREDIT-OPTIMIZATION.md](clawdbot/CREDIT-OPTIMIZATION.md) — API cost savings
- [HYBRID-HEALING.md](clawdbot/HYBRID-HEALING.md) — Self-healing system
- [APP-STORE-MANAGER.md](clawdbot/APP-STORE-MANAGER.md) — iOS App Store monitoring
- [PERSISTENT-BOTS.md](clawdbot/PERSISTENT-BOTS.md) — Bot architecture

### Workspace (clawd/)
- [AGENTS.md](clawd/AGENTS.md) — Bot behavior & memory rules
- [SOUL.md](clawd/SOUL.md) — Personality & tone
- [HEARTBEAT.md](clawd/HEARTBEAT.md) — Periodic check tasks

### Claude Code
- [CLAUDE-global.md](claude/CLAUDE-global.md) — Global settings
- [WORKING_PRINCIPLES.md](claude/WORKING_PRINCIPLES.md) — Dev principles

### Mac Mini
- [mac-mini/README.md](mac-mini/README.md) — Server setup guide
- [mac-mini/PERSISTENCE.md](mac-mini/PERSISTENCE.md) — Bot persistence
- [aphos-servers.md](aphos-servers.md) — Game server setup (PM2)

---

## Installation

### macOS/Linux
```bash
./install.sh
```

### Windows
```powershell
.\install.ps1
```

### Homebrew Packages
```bash
brew bundle --file=homebrew/Brewfile-macbook  # MacBook
brew bundle --file=homebrew/Brewfile-macmini  # Mac Mini
```

---

## License

Personal configuration files. Feel free to use as inspiration for your own setup.
