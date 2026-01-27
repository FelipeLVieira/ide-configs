# IDE Configs

Personal configuration files for Claude Code, Cursor, VSCode, Clawdbot, and Mac Mini bot factory.

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
├── clawdbot/                  # Clawdbot Bot Factory
│   ├── PERSISTENT-BOTS.md     # 9-bot architecture & management
│   ├── HYBRID-HEALING.md      # 3-layer self-healing system
│   ├── CREDIT-OPTIMIZATION.md # API credit savings (90% reduction)
│   ├── SCRIPTS-REFERENCE.md   # Scripts docs (event-watcher, cleanup)
│   ├── APP-STORE-MANAGER.md   # iOS App Store monitoring cron
│   ├── GAME-DESIGN-REFERENCES.md # Game design & sound engineering research
│   ├── MONITOR-INTEGRATION.md # Dashboard setup
│   ├── PREREQUISITES.md       # System requirements
│   └── README.md              # Clawdbot overview
│
├── clawd/                     # Clawdbot workspace files
│   ├── AGENTS.md              # Agent behavior rules
│   ├── SOUL.md                # Personality & tone
│   ├── USER.md                # Human profile
│   ├── IDENTITY.md            # Bot identity
│   ├── HEARTBEAT.md           # Periodic check tasks
│   ├── adapter.js             # Multi-account failover
│   ├── scripts/               # Auto-resume, shutdown scripts
│   └── docs/ARCHITECTURE.md   # Multi-account rate limit docs
│
├── claude/                    # Claude Code CLI configs
│   ├── CLAUDE.md              # Per-project template
│   ├── CLAUDE-global.md       # Global settings
│   └── settings.json          # Hooks (ESLint, Prettier)
│
├── mcp/                       # MCP Server configs
│   ├── claude-code-mcps.json
│   ├── cursor-mcps.json
│   └── vscode-mcps.json
│
├── mac-mini/                  # Mac Mini server setup
│   ├── README.md              # Setup guide
│   ├── PERSISTENCE.md         # Bot persistence
│   ├── launchagents/          # LaunchAgent plists
│   └── scripts/               # Startup scripts
│
├── project-templates/         # Per-project CLAUDE.md
├── homebrew/                  # Brewfiles
├── vscode/                    # VSCode settings
├── git/                       # Git configs
├── infrastructure/            # Multi-machine architecture docs
│   ├── three-machine-architecture.md
│   └── port-assignments.md    # Master port registry
└── ssh/                       # SSH configs
```

## Clawdbot Bot Factory (3-Tier Architecture)

The Mac Mini runs a cost-optimized bot factory with automated cleanup and monitoring.

### Tier 1: Event Watcher (FREE, 60s loop, launchd)
Instant healing via bash -- zero LLM tokens, 24/7.
- event-watcher.sh monitors Ollama, pm2, zombies, simulators; auto-heals instantly
- Logs to `/tmp/clawdbot/events.jsonl`

### Tier 2: Bash Cleanup Scripts (FREE, every 15 min)
Mechanical cleanup via launchd -- zero LLM tokens.
- mac-mini-cleanup.sh kills simulators, zombies, duplicates; checks health
- macbook-cleanup.sh same for MacBook (no simulators allowed)

### Tier 3: AI Cron Jobs (local LLMs, hourly)
| Job | Schedule | Purpose |
|-----|----------|---------|
| Cleaner Bot | Hourly | Deep cleanup (caches, temp files, disk) |
| Healer Bot | Hourly | Read event logs, diagnose, smart healing |
| Clear Sessions | Sunday midnight | Weekly session cleanup |
| App Store Manager | 3x daily (9/3/9 EST) | iOS app monitoring (reviews, builds, status) |

### Tier 4: Always-On Services (launchd)
| Service | Purpose |
|---------|---------|
| Clawdbot Gateway | AI orchestrator (port 18789) |
| Python Trading Bot | Polymarket trading (run_bots) |
| Failover Watchdog | MacBook health monitor |

### Quick Commands
```bash
# Check event watcher
launchctl list | grep event-watcher
tail -20 /tmp/clawdbot/events.jsonl | jq .

# Check cron jobs
clawdbot cron list

# Check services
ps aux | grep -E "clawdbot-gateway|run_bots" | grep -v grep

# Check cleanup health
cat /tmp/clawdbot/system-health.json
```

See [clawdbot/HYBRID-HEALING.md](clawdbot/HYBRID-HEALING.md) for the full 3-layer architecture.
See [clawdbot/PERSISTENT-BOTS.md](clawdbot/PERSISTENT-BOTS.md) for bot docs.

## Credit Optimization

3-tier architecture reduced daily costs from ~$15 to ~$5:

| Tier | Tool | Cost | Purpose |
|------|------|------|---------|
| Bash scripts | launchd (15 min) | FREE | Cleanup, monitoring |
| Sonnet cron | Clawdbot (30 min) | ~$0.05/run | Research, health |
| Opus heartbeat | Clawdbot (60 min) | ~$0.10/run | Connectivity only |

See [clawdbot/CREDIT-OPTIMIZATION.md](clawdbot/CREDIT-OPTIMIZATION.md)

## Mac Mini Architecture

```
+------------------------------------------+
|          MAC MINI BOT FACTORY            |
+------------------------------------------+
|  Clawdbot Gateway (port 18789)           |
|  -- 9 Persistent Bots (tmux)            |
|  -- Python Trading Bot                   |
|  -- clawd-monitor Dashboard (:9009)      |
+------------------------------------------+
|  Scripts: ~/clawd/scripts/               |
|  Memory: ~/clawd/memory/                 |
|  Repos: ~/repos/                         |
+------------------------------------------+
```

## Installation

### macOS/Linux
```bash
./install.sh
```

Creates symlinks for:
- `~/.claude/CLAUDE.md` -- Global Claude settings
- `~/.claude/settings.json` -- Claude hooks
- `~/.gitconfig` -- Git config
- `~/.ssh/config` -- SSH config

### Windows
```powershell
.\install.ps1
```

### Homebrew Packages
```bash
# MacBook
brew bundle --file=homebrew/Brewfile-macbook

# Mac Mini
brew bundle --file=homebrew/Brewfile-macmini
```

## Configuration Files

### Claude Code
| File | Purpose |
|------|---------|
| `claude/CLAUDE.md` | Per-project rules template |
| `claude/CLAUDE-global.md` | Global ~/.claude/CLAUDE.md |
| `claude/settings.json` | Pre-commit hooks |
| `claude/deslop.md` | Anti-slop writing guide |

### Clawdbot Workspace
| File | Purpose |
|------|---------|
| `clawd/AGENTS.md` | Bot behavior & memory rules |
| `clawd/SOUL.md` | Personality & tone |
| `clawd/USER.md` | Human profile |
| `clawd/HEARTBEAT.md` | Periodic check tasks |
| `clawd/adapter.js` | Multi-account rate limit adapter |

### MCP Servers
| File | IDEs |
|------|------|
| `mcp/claude-code-mcps.json` | Claude Code |
| `mcp/cursor-mcps.json` | Cursor |
| `mcp/vscode-mcps.json` | VSCode |

## Syncing

### MacBook to Mac Mini
```bash
./mac-mini/sync-to-mini.sh
```

### Pull latest on both
```bash
# MacBook
cd ~/repos/ide-configs && git pull

# Mac Mini (via SSH)
ssh mac-mini 'cd ~/repos/ide-configs && git pull'
```

## Documentation Index

### Clawdbot
- [RESEARCH-2026-01-27.md](clawdbot/RESEARCH-2026-01-27.md) - Grok research: trading bot improvements, Clawdbot updates
- [GAME-DESIGN-REFERENCES.md](clawdbot/GAME-DESIGN-REFERENCES.md) - Game design and sound engineering research for Aphos
- [PERSISTENT-BOTS.md](clawdbot/PERSISTENT-BOTS.md) - Bot architecture & management
- [HYBRID-HEALING.md](clawdbot/HYBRID-HEALING.md) - 3-layer self-healing system
- [CREDIT-OPTIMIZATION.md](clawdbot/CREDIT-OPTIMIZATION.md) - API savings strategies
- [SCRIPTS-REFERENCE.md](clawdbot/SCRIPTS-REFERENCE.md) - Script documentation (event-watcher, cleanup)
- [APP-STORE-MANAGER.md](clawdbot/APP-STORE-MANAGER.md) - iOS App Store monitoring cron
- [MONITOR-INTEGRATION.md](clawdbot/MONITOR-INTEGRATION.md) - Dashboard setup
- [ARCHITECTURE.md](clawd/docs/ARCHITECTURE.md) - Multi-account failover

### Infrastructure
- [Three-Machine Architecture](infrastructure/three-machine-architecture.md) - Full 3-machine overview (MacBook, Mac Mini, Windows MSI)
- [Port Assignments](infrastructure/port-assignments.md) - Master port registry (all services, all machines)

### Configuration
- [clawdbot-config.md](clawdbot-config.md) - Model routing & Ollama configuration
- [ollama-setup.md](ollama-setup.md) - Local LLM setup (Mac Mini & MacBook)
- [tailscale.md](tailscale.md) - Private mesh VPN configuration
- [ssh-config.md](ssh-config.md) - SSH setup across all machines

### Development
- [dev-teams.md](dev-teams.md) - Bot roles & model assignments per project
- [aphos-servers.md](aphos-servers.md) - Game server setup (pm2 on Mac Mini)

### Mac Mini
- [mac-mini/README.md](mac-mini/README.md) - Server setup guide
- [mac-mini/PERSISTENCE.md](mac-mini/PERSISTENCE.md) - Bot persistence strategy

### Claude Code
- [claude/WORKING_PRINCIPLES.md](claude/WORKING_PRINCIPLES.md) - Dev principles
- [claude/deslop.md](claude/deslop.md) - Writing quality guide

## Project Templates

Pre-configured CLAUDE.md for each project:

| Template | Project |
|----------|---------|
| `game-project-CLAUDE.md` | Aphos MMORPG |
| `crm-app-CLAUDE.md` | EZ-CRM |
| `links-app-CLAUDE.md` | LinkLounge |
| `health-app-CLAUDE.md` | BMI Calculator |
| `finance-app-CLAUDE.md` | Bills Tracker |
| `translator-app-CLAUDE.md` | Screen Translator |
| `trading-bot-CLAUDE.md` | Shitcoin Bot |
| `clawd-monitor-CLAUDE.md` | Bot Dashboard |

## License

Personal configuration files. Feel free to use as inspiration for your own setup.
