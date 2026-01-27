# IDE Configs

Personal configuration files for Claude Code, Cursor, VSCode, Clawdbot, and the multi-machine bot infrastructure.

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
 clawd/ # Clawdbot WORKSPACE files
                             # These define WHO the bot IS.
                             # Deployed to ~/clawd/ on each machine.
    AGENTS.md # Behavior rules, memory, safety
    SOUL.md # Personality & tone
    USER.md # Human profile (Felipe)
    IDENTITY.md # Bot identity (name, emoji)
    HEARTBEAT.md # Periodic check tasks
    TOOLS.md # Tool configurations and notes
    CROSS-BOT-BRIEFING.md # Inter-bot communication protocols
    OPTIMIZATION_RULES.md # Performance optimization guidelines
    BOOTSTRAP.md # First-run setup (ephemeral)
    adapter.js # Multi-account failover adapter
    scripts/ # Auto-resume, shutdown scripts
    docs/ARCHITECTURE.md # Multi-account rate limit docs

 clawdbot/ # Clawdbot OPERATIONS documentation
                             # Docs about HOW the bot factory WORKS.
                             # Architecture, healing, monitoring, research.
    PERSISTENT-BOTS.md # Bot architecture & management
    HYBRID-HEALING.md # 3-layer self-healing system
    CREDIT-OPTIMIZATION.md # API credit savings (90% reduction)
    LOCAL-FIRST-OPTIMIZATION.md # Local model optimization strategies
    SCRIPTS-REFERENCE.md # Scripts docs (event-watcher, cleanup)
    APP-STORE-MANAGER.md # iOS App Store monitoring cron
    SKILLS-MAPPING.md # Bot skills and capabilities mapping
    GAME-DESIGN-REFERENCES.md # Game design & sound research
    SWARM-RESEARCH.md # Multi-agent swarm research
    RESEARCH-2026-01-27.md # Latest research notes
    MONITOR-INTEGRATION.md # Dashboard setup
    PREREQUISITES.md # System requirements
    README.md # Clawdbot overview

 claude/ # Claude Code CLI configs
    CLAUDE.md # Per-project template
    CLAUDE-global.md # Global settings
    settings.json # Hooks (ESLint, Prettier)

 mcp/ # MCP Server configs
    claude-code-mcps.json
    cursor-mcps.json
    vscode-mcps.json

 mac-mini/ # Mac Mini server setup
    README.md # Setup guide
    PERSISTENCE.md # Bot persistence
    launchagents/ # LaunchAgent plists
    scripts/ # Startup scripts

 infrastructure/ # Multi-machine architecture docs
    three-machine-architecture.md
    port-assignments.md # Master port registry

 project-templates/ # Per-project CLAUDE.md templates
 homebrew/ # Brewfiles
 vscode/ # VSCode settings
 git/ # Git configs
 ssh/ # SSH configs

 clawdbot-config.md # Model routing & Ollama configuration
 ollama-setup.md # Local LLM setup guide
 dev-teams.md # Bot roles & model assignments
 tailscale.md # Private mesh VPN configuration
 ssh-config.md # SSH setup across machines
 aphos-servers.md # Game server setup (pm2)
```

### `clawd/` vs `clawdbot/` — What's the Difference?

| Folder | Purpose | Analogy | Deployed to |
|--------|---------|---------|-------------|
| **`clawd/`** | **Workspace files** — AGENTS.md, SOUL.md, USER.md, HEARTBEAT.md, scripts | The bot's **identity & brain** | `~/clawd/` on each machine |
| **`clawdbot/`** | **Operations docs** — architecture, healing, monitoring, research | The **operations manual** | Reference only (not deployed) |

Think of it this way: `clawd/` is **who the bot is** (personality, rules, memory). `clawdbot/` is **how the factory works** (documentation about the infrastructure, healing systems, and operational procedures).

---

## Three-Machine Architecture

```

   MacBook Pro (48GB) — MAIN
   Opus 4.5 + local Ollama
   3 models: qwen3:8b, devstral
   -24b, gpt-oss:20b
   Role: Orchestrator, heavy AI

            local network + Tailscale

   Mac Mini (16GB) — ALWAYS ON
   qwen3:8b ONLY (swap-safe)
   Role: Heartbeats, game server,
   iOS builds, bot dashboard

            Tailscale VPN

   Windows MSI — SECONDARY
   No local models
   Routes to MacBook + Mac Mini
   Role: Windows-specific tasks

```

### Model Routing (Current — 2026-01-27)

| Machine | Main Model | Heartbeat | Sub-agents | Fallback Chain |
|---------|-----------|-----------|------------|----------------|
| **MacBook Pro** | Opus 4.5 | qwen3:8b (local, FREE) | qwen3:8b (local) | Sonnet 4.5 -> devstral-24b -> gpt-oss:20b -> qwen3:8b |
| **Mac Mini** | qwen3:8b (local, FREE) | qwen3:8b (local, FREE) | qwen3:8b (local) | MacBook qwen3 -> MacBook devstral -> MacBook gpt-oss -> Sonnet -> Opus |
| **Windows MSI** | Opus 4.5 | Mac Mini qwen3:8b (FREE) | Mac Mini qwen3:8b | Sonnet -> MacBook devstral -> MacBook gpt-oss -> MacBook qwen3 -> Mac Mini qwen3 |

> WARNING: **Mac Mini swap protection**: gpt-oss:20b (14GB) is NEVER in Mac Mini auto-fallbacks. It caused 15.6GB swap death on 16GB RAM. Only qwen3:8b (5GB) is safe.

See [infrastructure/three-machine-architecture.md](infrastructure/three-machine-architecture.md) for full details.

---

## Active Services

### Mac Mini (Always-On)
| Service | Port | Purpose |
|---------|------|---------|
| Clawdbot Gateway | 18789 | AI orchestrator |
| Ollama | 11434 | Local LLM (qwen3:8b) |
| clawd-monitor | 9009 | Bot dashboard |
| Aphos prod server | 2567 | Game server |
| Aphos dev server | 2568 | Game server |
| Python trading bot | 8080 | Shitcoin bot |

### Active tmux Sessions (Mac Mini)
| Session | Project |
|---------|---------|
| bot-aphos | Game server management |
| bot-clawd-monitor | Dashboard |
| bot-ios-bills | Bills Tracker builds |
| bot-ios-bmi | BMI Calculator builds |
| bot-ios-translator | Screen Translator builds |

### Cron Jobs
| Job | Schedule | Model | Purpose |
|-----|----------|-------|---------|
| Healer Bot v3 | Hourly | Sonnet 4.5 | Self-healing + swap monitoring |
| Cleaner Bot | Hourly | Sonnet 4.5 | Deep cleanup (both machines) |
| App Store Manager | 3x/day | qwen3:8b | iOS app monitoring |
| Clear Sessions | Weekly (system cron) | — | Stale session cleanup |

**System-Level Cron (crontab)**:
| Job | Schedule | Purpose |
|-----|----------|---------|
| lume-update | 10:00 AM daily | Lume updater maintenance |
| clawd git sync | Every 15 min | Auto-sync workspace changes |

---

## Cost Optimization

| Tier | Tool | Cost | Purpose |
|------|------|------|---------|
| Free research | Grok, Brave Search, web_fetch | $0 | Research before burning tokens |
| Free local LLMs | Ollama (qwen3:8b, devstral, gpt-oss) | $0 | Heartbeats, sub-agents, cron |
| Sonnet cron | Clawdbot isolated sessions | ~$0.05-0.15/run | Self-healing, monitoring |
| Opus main | MacBook + Windows main chat | ~$0.10-0.50/turn | Complex reasoning, orchestration |

**Estimated monthly**: $50-100 (down from $300+ before local LLMs, ~85% reduction)

---

## Installation

### macOS/Linux
```bash
./install.sh
```

Creates symlinks for `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, `~/.gitconfig`, `~/.ssh/config`.

### Windows
```powershell
.\install.ps1
```

### Homebrew Packages
```bash
brew bundle --file=homebrew/Brewfile-macbook # MacBook
brew bundle --file=homebrew/Brewfile-macmini # Mac Mini
```

---

## Documentation Index

### Infrastructure
- [Three-Machine Architecture](infrastructure/three-machine-architecture.md) — Full 3-machine overview
- [Port Assignments](infrastructure/port-assignments.md) — Master port registry

### Clawdbot Configuration
- [clawdbot-config.md](clawdbot-config.md) — Model routing & Ollama config
- [ollama-setup.md](ollama-setup.md) — Local LLM setup guide
- [dev-teams.md](dev-teams.md) — Bot roles & model assignments per project
- [tailscale.md](tailscale.md) — Private mesh VPN
- [ssh-config.md](ssh-config.md) — SSH setup

### Clawdbot Operations (clawdbot/)
- [PERSISTENT-BOTS.md](clawdbot/PERSISTENT-BOTS.md) — Bot architecture & management
- [HYBRID-HEALING.md](clawdbot/HYBRID-HEALING.md) — 3-layer self-healing system
- [CREDIT-OPTIMIZATION.md](clawdbot/CREDIT-OPTIMIZATION.md) — API savings strategies
- [SCRIPTS-REFERENCE.md](clawdbot/SCRIPTS-REFERENCE.md) — Script documentation
- [APP-STORE-MANAGER.md](clawdbot/APP-STORE-MANAGER.md) — iOS App Store monitoring
- [GAME-DESIGN-REFERENCES.md](clawdbot/GAME-DESIGN-REFERENCES.md) — Game design & sound research
- [RESEARCH-2026-01-27.md](clawdbot/RESEARCH-2026-01-27.md) — Grok research notes

### Clawdbot Workspace (clawd/)
- [AGENTS.md](clawd/AGENTS.md) — Bot behavior & memory rules
- [SOUL.md](clawd/SOUL.md) — Personality & tone
- [USER.md](clawd/USER.md) — Human profile
- [HEARTBEAT.md](clawd/HEARTBEAT.md) — Periodic check tasks
- [docs/ARCHITECTURE.md](clawd/docs/ARCHITECTURE.md) — Multi-account failover

### Claude Code
- [claude/CLAUDE-global.md](claude/CLAUDE-global.md) — Global settings
- [claude/WORKING_PRINCIPLES.md](claude/WORKING_PRINCIPLES.md) — Dev principles
- [claude/deslop.md](claude/deslop.md) — Writing quality guide

### Mac Mini
- [mac-mini/README.md](mac-mini/README.md) — Server setup guide
- [mac-mini/PERSISTENCE.md](mac-mini/PERSISTENCE.md) — Bot persistence
- [aphos-servers.md](aphos-servers.md) — Game server setup (pm2)

### Project Templates
Pre-configured CLAUDE.md for: Aphos, EZ-CRM, LinkLounge, BMI Calculator, Bills Tracker, Screen Translator, Shitcoin Bot, clawd-monitor.

---

## License

Personal configuration files. Feel free to use as inspiration for your own setup.
