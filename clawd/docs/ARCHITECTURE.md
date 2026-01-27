# Clawdbot Multi-Agent Architecture

Documentation for migrating to new Mac Mini.

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CLAWDBOT GATEWAY                         │
│                   (Main Orchestrator)                       │
├─────────────────────────────────────────────────────────────┤
│  Main Session (telegram:main)                               │
│  └── Orchestrator Bot (monitors swarm)                      │
│  └── Sub-Agents:                                            │
│      ├── aphos-rebuild (game dev)                           │
│      ├── ez-crm-tester (CRM testing)                        │
│      ├── bmi-calculator (iOS app)                           │
│      ├── bills-tracker-v2 (iOS app)                         │
│      ├── screen-translator-v2 (iOS app)                     │
│      ├── shitcoin-bot (crypto monitoring)                   │
│      └── orchestration-research (research tasks)            │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
~/clawd/                          # Main workspace
├── AGENTS.md                     # Bot rules & guidelines
├── SOUL.md                       # Bot personality
├── USER.md                       # User info
├── TOOLS.md                      # Tool notes
├── HEARTBEAT.md                  # Periodic check tasks
├── MEMORY.md                     # Long-term memory
├── memory/                       # Daily session notes
│   └── YYYY-MM-DD.md
└── docs/
    └── ARCHITECTURE.md           # This file

~/repos/                          # Project repositories
├── aphos/                        # Game project
├── ez-crm/                       # CRM project
├── clawd-monitor/                # Dashboard
├── shitcoin-bot/                 # Crypto bot
├── bmi-calculator/               # iOS app
├── bill-subscriptions-organizer-tracker/  # iOS app
├── simple-screen-translator/     # iOS app
└── ide-configs/                  # Shared configs

~/.clawdbot/                      # Clawdbot state
├── agents/
│   └── main/
│       ├── agent/
│       │   └── auth-profiles.json
│       └── sessions/             # Session transcripts
├── config.json                   # Gateway config
└── logs/
    └── gateway.log
```

## Port Assignments

| Port | Service | Project |
|------|---------|---------|
| 2567 | Game Server (prod) | Aphos |
| 2568 | Game Server (dev) | Aphos |
| 3000 | Web App | ez-crm |
| 4000 | Web Client | Aphos |
| 5000-5099 | Reserved | shitcoin-bot |
| 8081 | Expo Web | bmi-calculator |
| 8082 | Expo Web | bills-tracker |
| 8083 | Expo Web | screen-translator |
| 9000 | Dashboard | clawd-monitor |
| 18789 | Internal | Clawdbot API |

## Services to Run

### 1. Clawdbot Gateway
```bash
clawdbot gateway start
# Or: clawdbot gateway start --daemon
```

### 2. Aphos Game Servers
```bash
cd ~/repos/aphos

# Production (port 2567)
pnpm dev:server:prod

# Development (port 2568)
pnpm dev:server:dev

# Web client (port 4000)
pnpm dev
```

### 3. clawd-monitor Dashboard
```bash
cd ~/repos/clawd-monitor
PORT=9000 pnpm dev
```

### 4. Other Services (as needed)
```bash
# ez-crm
cd ~/repos/ez-crm && pnpm dev

# iOS apps (Expo)
cd ~/repos/bmi-calculator && npx expo start --web --port 8081
cd ~/repos/bill-subscriptions-organizer-tracker && npx expo start --web --port 8082
cd ~/repos/simple-screen-translator && npx expo start --web --port 8083
```

## Migration Checklist

### Pre-Migration (on current Mac)
- [ ] Push all repos to GitHub
- [ ] Export `~/.clawdbot/` directory
- [ ] Export `~/clawd/` workspace
- [ ] Note all running tmux sessions
- [ ] Document any local-only credentials

### On New Mac Mini
1. **Install Prerequisites:**
   ```bash
   # Homebrew
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   
   # Node.js
   brew install node
   
   # pnpm
   npm install -g pnpm
   
   # Clawdbot
   npm install -g clawdbot
   ```

2. **Clone Repositories:**
   ```bash
   mkdir -p ~/repos && cd ~/repos
   git clone git@github.com:FelipeLVieira/aphos.git
   git clone git@github.com:FelipeLVieira/ez-crm.git
   git clone git@github.com:FelipeLVieira/clawd-monitor.git
   git clone git@github.com:FelipeLVieira/shitcoin-bot.git
   git clone git@github.com:FelipeLVieira/bmi-calculator.git
   git clone git@github.com:FelipeLVieira/bill-subscriptions-organizer-tracker.git
   git clone git@github.com:FelipeLVieira/simple-screen-translator.git
   git clone git@github.com:FelipeLVieira/ide-configs.git
   ```

3. **Restore Clawdbot State:**
   ```bash
   # Copy from backup
   cp -r /backup/.clawdbot ~/.clawdbot
   
   # Or reconfigure
   clawdbot configure
   ```

4. **Restore Workspace:**
   ```bash
   cp -r /backup/clawd ~/clawd
   ```

5. **Install Dependencies:**
   ```bash
   cd ~/repos/aphos && pnpm install
   cd ~/repos/ez-crm && pnpm install
   cd ~/repos/clawd-monitor && pnpm install
   # ... etc
   ```

6. **Configure Telegram/Channels:**
   ```bash
   clawdbot configure --section telegram
   ```

7. **Start Services:**
   ```bash
   # Start gateway
   clawdbot gateway start
   
   # Start Aphos servers
   cd ~/repos/aphos && pnpm dev:server:prod &
   cd ~/repos/aphos && pnpm dev:server:dev &
   
   # Start dashboard
   cd ~/repos/clawd-monitor && PORT=9000 pnpm dev &
   ```

8. **Verify:**
   ```bash
   # Check ports
   lsof -i :2567 -i :2568 -i :9000 | grep LISTEN
   
   # Check gateway
   clawdbot status
   ```

## Environment Variables

Create `~/repos/.env` for shared credentials:
```bash
# Apple Developer
APPLE_ID=felipe.lv.90@gmail.com
APPLE_TEAM_ID=824F44HKCD

# Supabase (if needed)
SUPABASE_URL=
SUPABASE_ANON_KEY=

# Other APIs
BRAVE_API_KEY=
```

## Tmux Sessions

Current tmux sessions to recreate:
```bash
tmux new-session -d -s shitcoin-bot -c ~/repos/shitcoin-bot
tmux new-session -d -s aphos-bot -c ~/repos/aphos
tmux new-session -d -s monitor-bot -c ~/repos/clawd-monitor
```

## Bot Communication

Bots communicate via:
- `sessions_list` - See all active sessions
- `sessions_send` - Message other bots by label
- `sessions_history` - Read conversation history
- `sessions_spawn` - Create sub-agents

The **orchestrator bot** monitors all agents and coordinates:
- Timeout detection
- Port conflict resolution
- Resource cleanup (browser tabs)
- Status reporting

## Key Files to Backup

Priority files for migration:
1. `~/.clawdbot/config.json` - Gateway configuration
2. `~/.clawdbot/agents/main/agent/auth-profiles.json` - API keys
3. `~/clawd/MEMORY.md` - Long-term memory
4. `~/clawd/memory/*.md` - Recent session notes
5. `~/repos/.env` - Shared credentials

## Key Files to Backup

Priority files for migration:
1. `~/.clawdbot/config.json` - Gateway configuration
2. `~/.clawdbot/agents/main/agent/auth-profiles.json` - API keys
3. `~/clawd/MEMORY.md` - Long-term memory
4. `~/clawd/memory/*.md` - Recent session notes
5. `~/repos/.env` - Shared credentials

## Troubleshooting

### Gateway won't start
```bash
clawdbot doctor
clawdbot gateway logs
```

### Port conflicts
```bash
lsof -i :<port> | grep LISTEN
kill $(lsof -t -i :<port>)
```

### Bot not responding
```bash
clawdbot sessions list
clawdbot sessions send <label> "ping"
```
