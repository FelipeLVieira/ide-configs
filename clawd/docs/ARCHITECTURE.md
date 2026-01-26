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
│      ├── game-project-rebuild (game dev)                           │
│      ├── crm-app-tester (CRM testing)                        │
│      ├── health-app (iOS app)                           │
│      ├── finance-app-v2 (iOS app)                         │
│      ├── translator-app-v2 (iOS app)                     │
│      ├── trading-bot (trading monitoring)                   │
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
├── game-project/                        # Social RPG game
├── crm-app/                       # CRM project
├── clawd-monitor/                # Dashboard
├── trading-bot/                 # Trading bot
├── health-app/               # iOS app
├── bill-subscriptions-organizer-tracker/  # iOS app
├── simple-translator-app/     # iOS app
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
| 3000 | Web App | crm-app |
| 4000 | Web Client | Aphos |
| 5000-5099 | Reserved | trading-bot |
| 8081 | Expo Web | health-app |
| 8082 | Expo Web | finance-app |
| 8083 | Expo Web | translator-app |
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
cd ~/repos/game-project

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
# crm-app
cd ~/repos/crm-app && pnpm dev

# iOS apps (Expo)
cd ~/repos/health-app && npx expo start --web --port 8081
cd ~/repos/bill-subscriptions-organizer-tracker && npx expo start --web --port 8082
cd ~/repos/simple-translator-app && npx expo start --web --port 8083
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
   git clone git@github.com:UserLVieira/game-project.git
   git clone git@github.com:UserLVieira/crm-app.git
   git clone git@github.com:UserLVieira/clawd-monitor.git
   git clone git@github.com:UserLVieira/trading-bot.git
   git clone git@github.com:UserLVieira/health-app.git
   git clone git@github.com:UserLVieira/bill-subscriptions-organizer-tracker.git
   git clone git@github.com:UserLVieira/simple-translator-app.git
   git clone git@github.com:UserLVieira/ide-configs.git
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
   cd ~/repos/game-project && pnpm install
   cd ~/repos/crm-app && pnpm install
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
   cd ~/repos/game-project && pnpm dev:server:prod &
   cd ~/repos/game-project && pnpm dev:server:dev &
   
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
APPLE_ID=your-email@example.com
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
tmux new-session -d -s trading-bot -c ~/repos/trading-bot
tmux new-session -d -s game-project-bot -c ~/repos/game-project
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

## Multi-Account Rate Limit Fallback

Both **clawd** (orchestrator) and **clawdbot** (gateway) support automatic account switching when rate limits (429) are hit.

### Authentication Method

Uses `CLAUDE_CODE_OAUTH_TOKEN` environment variable with long-lived OAuth tokens generated via `claude setup-token`. Tokens are stored in files (chmod 600) and loaded at runtime.

### How It Works

#### Clawd (Orchestrator) — `adapter.js`

```
Clawd executes task
  -> Adapter picks Account 1 (felipe.lv.90@gmail.com, default auth)
  -> Spawns: claude --dangerously-skip-permissions -p <prompt>
  -> If "Session limit reached" / 429 / rate limit detected:
       -> Marks Account 1 as rate-limited (with parsed reset time)
       -> Immediately retries with Account 2 (wisedigitalinc@gmail.com)
       -> Spawns: CLAUDE_CODE_OAUTH_TOKEN=<token> claude ...
       -> If Account 2 also rate-limited:
            -> Clawd's built-in rate-limit handler waits until reset
```

Clawd loads `adapter.js` from `<project-cwd>/.clawd/adapter.js` (symlinked to `~/.clawd/adapter.js`).

#### Clawdbot (Gateway) — `claude-multi` wrapper

```
Clawdbot sends message to Claude CLI
  -> Spawns: claude-multi <args...>  (configured via cliBackends.command)
  -> Wrapper runs: claude <args...>  (primary account, no token)
  -> If exit code != 0 AND output matches rate limit patterns:
       -> Loads token from ~/.claude-wisedigital/oauth-token
       -> Retries: CLAUDE_CODE_OAUTH_TOKEN=<token> claude <args...>
  -> Returns output + exit code transparently
```

Clawdbot uses `claude-multi` as a drop-in replacement for `claude` in its backend config.

### Accounts

| Account | Email | Auth Method | Token File | Role |
|---------|-------|-------------|------------|------|
| felipe | felipe.lv.90@gmail.com | Default auth (browser session) | None | Primary |
| wisedigital | wisedigitalinc@gmail.com | OAuth token | `~/.claude-wisedigital/oauth-token` | Fallback |

### Setup (per machine)

Each machine (MacBook, Mac Mini) needs both accounts authenticated:

```bash
# 1. Primary account - already authenticated via default claude login

# 2. Secondary account - generate OAuth token (run in Terminal.app, not via script)
CLAUDE_CONFIG_DIR=~/.claude-wisedigital claude setup-token
# Log in with wisedigitalinc@gmail.com in the browser
# Save the displayed token:
echo "<token>" > ~/.claude-wisedigital/oauth-token
chmod 600 ~/.claude-wisedigital/oauth-token

# 3. Install adapter + wrapper
~/.clawd/scripts/setup-secondary-account.sh

# 4. Configure clawdbot backend (add to ~/.clawdbot/clawdbot.json)
# agents.defaults.cliBackends.claude-cli.command = "<absolute-path>/.clawd/scripts/claude-multi"
```

Or use the setup script for steps 1-3:
```bash
~/.clawd/scripts/setup-secondary-account.sh
```

### Clawdbot Config

Add to `~/.clawdbot/clawdbot.json` under `agents.defaults`:

```json
{
  "agents": {
    "defaults": {
      "cliBackends": {
        "claude-cli": {
          "command": "/Users/<username>/.clawd/scripts/claude-multi"
        }
      }
    }
  }
}
```

This merges with clawdbot's default Claude CLI backend config, keeping all default args (`-p`, `--output-format json`, `--dangerously-skip-permissions`) but replacing the command.

### Adding More Accounts

Edit the `ACCOUNTS` array in `~/.clawd/adapter.js` and add a new token check in `claude-multi`:
```javascript
// adapter.js
const ACCOUNTS = [
  { name: "felipe", email: "felipe.lv.90@gmail.com", tokenFile: null },
  { name: "wisedigital", email: "wisedigitalinc@gmail.com", tokenFile: path.join(os.homedir(), ".claude-wisedigital", "oauth-token") },
  // Add more:
  { name: "newaccount", email: "new@example.com", tokenFile: path.join(os.homedir(), ".claude-newaccount", "oauth-token") },
];
```

Then authenticate and save the token:
```bash
CLAUDE_CONFIG_DIR=~/.claude-newaccount claude setup-token
echo "<displayed-token>" > ~/.claude-newaccount/oauth-token
chmod 600 ~/.claude-newaccount/oauth-token
```

### Key Files

| File | Purpose |
|------|---------|
| `~/.clawd/adapter.js` | Multi-account adapter for **clawd** (symlinked into project dirs) |
| `~/.clawd/scripts/claude-multi` | Multi-account wrapper for **clawdbot** (drop-in `claude` replacement) |
| `~/.clawd/scripts/setup-secondary-account.sh` | One-time auth setup + symlink creation |
| `~/.claude-wisedigital/oauth-token` | OAuth token for secondary account (chmod 600) |
| `~/.clawdbot/clawdbot.json` | Clawdbot config (set `cliBackends.claude-cli.command`) |
| `~/.clawdbot/logs/claude-multi.log` | Wrapper script logs (account switches, errors) |

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
