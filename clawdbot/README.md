# Clawdbot Gateway Setup

Clawdbot Gateway is a unified multi-agent orchestrator for Claude Code. It provides:
- **Unified session** across VS Code, terminal, Telegram, and other channels
- **Multi-agent orchestration** - spawn and coordinate sub-agents
- **Inter-bot communication** - agents can message each other
- **Centralized management** - one gateway controls all agents

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CLAWDBOT GATEWAY                         │
│                   (Main Orchestrator)                       │
├─────────────────────────────────────────────────────────────┤
│  Main Session (telegram:main)                               │
│  └── Orchestrator Bot (monitors swarm)                      │
│  └── Sub-Agents:                                            │
│      ├── project-a (development)                            │
│      ├── project-b (testing)                                │
│      ├── research-agent (research tasks)                    │
│      └── ... (spawn as needed)                              │
└─────────────────────────────────────────────────────────────┘
```

### How It Works

1. **Gateway** runs as the central orchestrator
2. **Main session** connects to Telegram (or other channels)
3. **Sub-agents** are spawned for specific tasks
4. Agents communicate via:
   - `sessions_list` - See all active sessions
   - `sessions_send` - Message other bots by label
   - `sessions_history` - Read conversation history
   - `sessions_spawn` - Create sub-agents

### Directory Structure

```
~/clawd/                          # Main workspace
├── BOOTSTRAP.md                  # First-run setup (delete after)
├── AGENTS.md                     # Bot rules & guidelines
├── SOUL.md                       # Bot personality
├── IDENTITY.md                   # Bot name, emoji, vibe
├── USER.md                       # User info (name, timezone)
├── TOOLS.md                      # Tool notes
├── HEARTBEAT.md                  # Periodic check tasks
├── MEMORY.md                     # Long-term memory
├── memory/                       # Daily session notes
│   └── YYYY-MM-DD.md
└── docs/
    └── ARCHITECTURE.md           # Architecture docs

~/.clawdbot/                      # Clawdbot state
├── clawdbot.json                 # Gateway config
├── agents/
│   └── main/
│       ├── agent/
│       │   └── auth-profiles.json
│       └── sessions/             # Session transcripts
└── logs/
    └── gateway.log
```

### Workspace Files

| File | Purpose |
|------|---------|
| `BOOTSTRAP.md` | First-run setup guide. Bot reads this on first session, then deletes it. |
| `IDENTITY.md` | Bot's name, emoji, personality vibe |
| `USER.md` | Your info (name, timezone, preferences) |
| `SOUL.md` | Bot's core personality and behavior rules |
| `AGENTS.md` | Guidelines for how bot should operate |
| `MEMORY.md` | Long-term curated memories across sessions |
| `memory/*.md` | Daily session notes (raw logs) |
| `HEARTBEAT.md` | Tasks to check during periodic heartbeats |
| `TOOLS.md` | Notes about available tools and APIs |

The bot will read these files at the start of each session to maintain context.

## Prerequisites

- Node.js 18+
- Claude Code CLI installed and authenticated (`claude` command works)
- Telegram account (for Telegram channel)

## Quick Setup

### 1. Install Clawdbot

```bash
npm install -g clawdbot
```

### 2. Run Setup Wizard

```bash
clawdbot setup
```

This creates `~/.clawdbot/clawdbot.json` with default configuration.

### 3. Create Telegram Bot

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot`
3. Follow prompts to name your bot (e.g., "Clawdbot Master")
4. Save the bot token (looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 4. Configure Telegram

```bash
# Set your bot token
clawdbot config set channels.telegram.botToken "YOUR_BOT_TOKEN_HERE"

# Enable Telegram
clawdbot config set channels.telegram.enabled true

# Set DM policy (pairing = requires pairing code)
clawdbot config set channels.telegram.dmPolicy pairing

# Set gateway mode
clawdbot config set gateway.mode local
```

### 5. Set Up Workspace

```bash
# Create workspace directory
mkdir -p ~/clawd/memory

# Copy workspace files from ide-configs
cp ide-configs/clawd/*.md ~/clawd/
```

### 6. Start the Gateway

```bash
clawdbot gateway
```

You should see:
```
[telegram] [default] starting provider (@your_bot_username)
[gateway] listening on ws://127.0.0.1:18789
```

### 7. Pair Your Telegram Account

Message your bot on Telegram with `/start`. You'll see:

```
Clawdbot: access not configured.

Your Telegram user id: 123456789
Pairing code: ABC123XY

Ask the bot owner to approve with:
clawdbot pairing approve telegram <code>
```

On your machine, approve the pairing:

```bash
clawdbot pairing approve telegram ABC123XY
```

You should see: `Approved telegram sender 123456789.`

### 8. Test It

Message your bot again - it should now respond

## Configuration Reference

Configuration file: `~/.clawdbot/clawdbot.json`

### Full Example Configuration

```json
{
  "agents": {
    "defaults": {
      "workspace": "~/clawd",
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "YOUR_BOT_TOKEN_HERE",
      "dmPolicy": "pairing",
      "groupPolicy": "allowlist",
      "streamMode": "partial"
    }
  },
  "gateway": {
    "mode": "local"
  },
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true
      }
    }
  }
}
```

### Configuration Options

| Key | Description | Values |
|-----|-------------|--------|
| `agents.defaults.workspace` | Default workspace directory | Path |
| `agents.defaults.maxConcurrent` | Max concurrent agents | Number |
| `agents.list[].id` | Agent identifier | String (e.g., `main`) |
| `agents.list[].identity.name` | Bot display name | String |
| `agents.list[].identity.emoji` | Bot emoji | Emoji |
| `agents.list[].identity.theme` | Bot description | String |
| `messages.ackReaction` | Processing indicator emoji | Emoji (e.g., `👀`) |
| `messages.ackReactionScope` | When to show ack | `dm`, `group`, `all`, `group-mentions` |
| `channels.telegram.enabled` | Enable Telegram channel | `true` / `false` |
| `channels.telegram.botToken` | Bot token from BotFather | String |
| `channels.telegram.dmPolicy` | How to handle DMs | `pairing`, `open`, `allowlist` |
| `channels.telegram.groupPolicy` | How to handle groups | `allowlist`, `open` |
| `channels.telegram.streamMode` | Response streaming | `partial`, `full`, `none` |
| `channels.telegram.reactionLevel` | Bot reaction frequency | `minimal`, `extensive` |
| `channels.telegram.reactionNotifications` | Reaction notifications | `all`, `none` |
| `channels.telegram.allowFrom` | Telegram user IDs allowed to use bot | Array of strings |
| `gateway.mode` | Gateway operation mode | `local`, `cloud` |
| `plugins.entries.telegram.enabled` | Enable Telegram plugin | `true` / `false` |
| `tools.elevated.enabled` | Enable elevated/privileged tools | `true` / `false` |
| `tools.elevated.allowFrom.telegram` | User IDs allowed to use elevated tools | Array of strings |
| `tools.exec.security` | Command approval level | `full`, `safe`, `prompt` |

### DM Policies

- **pairing**: User must enter a pairing code (most secure)
- **open**: Anyone can message the bot (not recommended)
- **allowlist**: Only specific users can message

## Telegram Features

### Emoji Reactions

Bot can react to your messages with emojis:

```json
{
  "channels": {
    "telegram": {
      "reactionLevel": "minimal",
      "reactionNotifications": "all"
    }
  }
}
```

| Option | Values | Description |
|--------|--------|-------------|
| `reactionLevel` | `minimal`, `extensive` | How often bot reacts |
| `reactionNotifications` | `all`, `none` | See when you react too |

### Ack Reaction (Processing Indicator)

Show an emoji while bot is processing your message:

```json
{
  "messages": {
    "ackReaction": "👀",
    "ackReactionScope": "all"
  }
}
```

| Option | Values | Description |
|--------|--------|-------------|
| `ackReaction` | Any emoji | Emoji shown while processing |
| `ackReactionScope` | `dm`, `group`, `all`, `group-mentions` | When to show ack |

### Bot Identity

Set bot name and emoji (defined per-agent in `agents.list`):

```json
{
  "agents": {
    "list": [
      {
        "id": "main",
        "identity": {
          "name": "Clawdbot Master",
          "emoji": "🖥️",
          "theme": "Windows automation assistant"
        }
      }
    ]
  }
}
```

### Access Control (allowFrom)

Restrict bot access to specific Telegram users:

```json
{
  "channels": {
    "telegram": {
      "allowFrom": ["123456789", "987654321"]
    }
  }
}
```

Get your Telegram user ID by messaging the bot with `/start` - it will display your ID in the pairing message.

### Elevated Tools

Enable privileged tools (system commands, file operations) with user restrictions:

```json
{
  "tools": {
    "elevated": {
      "enabled": true,
      "allowFrom": {
        "telegram": ["123456789"]
      }
    }
  }
}
```

| Option | Description |
|--------|-------------|
| `tools.elevated.enabled` | Enable elevated tools globally |
| `tools.elevated.allowFrom.telegram` | Telegram user IDs allowed to use elevated tools |

Elevated tools allow the bot to perform privileged operations like:
- Execute system commands
- Modify system files
- Access protected resources
- Run administrative tasks

### Auto-Approve Commands

By default, the bot asks for approval before running commands. Enable auto-approve for trusted users:

```json
{
  "tools": {
    "exec": {
      "security": "full"
    }
  }
}
```

| Option | Values | Description |
|--------|--------|-------------|
| `tools.exec.security` | `full`, `safe`, `prompt` | Command approval level |

- **full**: Auto-approve all commands (trusted user, personal machine)
- **safe**: Auto-approve safe commands, prompt for dangerous ones
- **prompt**: Always ask for approval (default)

### Custom Commands

Add commands to Telegram's menu:

```json
{
  "channels": {
    "telegram": {
      "customCommands": [
        { "command": "backup", "description": "Git backup all repos" },
        { "command": "status", "description": "Check system status" },
        { "command": "screenshot", "description": "Take a screenshot" }
      ]
    }
  }
}
```

### Full Featured Config Example

```json
{
  "agents": {
    "defaults": {
      "workspace": "~/clawd",
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    },
    "list": [
      {
        "id": "main",
        "identity": {
          "name": "Clawdbot Master",
          "emoji": "🖥️",
          "theme": "Your automation assistant"
        }
      }
    ]
  },
  "tools": {
    "elevated": {
      "enabled": true,
      "allowFrom": {
        "telegram": ["YOUR_TELEGRAM_USER_ID"]
      }
    },
    "exec": {
      "security": "full"
    }
  },
  "messages": {
    "ackReaction": "👀",
    "ackReactionScope": "all"
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "YOUR_BOT_TOKEN",
      "dmPolicy": "pairing",
      "groupPolicy": "allowlist",
      "streamMode": "partial",
      "reactionLevel": "minimal",
      "reactionNotifications": "all",
      "allowFrom": ["YOUR_TELEGRAM_USER_ID"]
    }
  },
  "gateway": {
    "mode": "local"
  },
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true
      }
    }
  }
}
```

## Multi-Agent Orchestration

### Spawning Sub-Agents

The orchestrator (main session) can spawn sub-agents for specific tasks:

```
You: spawn a new agent to work on the API refactor
Bot: [spawns "api-refactor" agent]
```

### Agent Communication

Agents can communicate with each other:

```bash
# List all active sessions
sessions_list

# Send message to another agent
sessions_send api-refactor "What's the status of the auth endpoints?"

# Read another agent's history
sessions_history api-refactor
```

### Orchestrator Responsibilities

The main orchestrator bot:
- Monitors all agents for timeouts
- Resolves port conflicts
- Cleans up resources (browser tabs, processes)
- Reports status to you via Telegram

## Browser Control

Clawdbot includes browser automation capabilities through the Clawd browser integration.

### Features

- Open tabs and navigate to URLs
- Click elements and type text
- Take screenshots
- Execute JavaScript
- Interact with web pages programmatically

### How It Works

1. Gateway starts browser control server on `http://127.0.0.1:18791/`
2. Clawd browser profile is created (decorated with orange theme)
3. Bot can control browser tabs via the Clawdbot Chrome extension

### Status Check

Ask the bot for system status to see browser control state:
```
You: what's your system status?
Bot: Browser Control - Clawd browser: Running (PID 12345)
     Can open tabs, navigate, click, type, screenshot
```

### Troubleshooting

If browser control shows errors:
- Restart the gateway: `clawdbot gateway`
- Check if Clawdbot Chrome extension is installed
- Click the extension icon on a tab to attach it

## Playwright MCP Integration

Clawdbot supports Playwright MCP for advanced browser automation.

### Setup

1. Install Playwright MCP server:
```bash
npm install -g @anthropic/mcp-server-playwright
```

2. Add to Claude Code settings (`~/.claude/settings.json`):
```json
{
  "mcp": {
    "servers": {
      "playwright": {
        "command": "npx",
        "args": ["@anthropic/mcp-server-playwright"]
      }
    }
  }
}
```

3. Restart Claude Code or the gateway

### Capabilities

With Playwright MCP, the bot can:
- Navigate complex web applications
- Fill forms and submit data
- Handle authentication flows
- Scrape dynamic content
- Test web applications

### Usage Example

```
You: use playwright to log into my dashboard and take a screenshot
Bot: [Uses Playwright MCP to navigate, authenticate, and capture screenshot]
```

## Running as a Service

### Windows

**Option 1: Install as service (requires Admin)**
```powershell
# Run PowerShell as Administrator
clawdbot gateway install
```

**Option 2: Scheduled Task with Auto-Recovery**

Create a scheduled task that starts at login and restarts on failure:

```powershell
# Create task that restarts on failure
$action = New-ScheduledTaskAction -Execute "clawdbot" -Argument "gateway"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
Register-ScheduledTask -TaskName "Clawdbot Gateway" -Action $action -Trigger $trigger -Principal $principal -Settings $settings
```

**Option 3: Elevated Scheduled Task (Admin Access)**

Give the bot Windows admin privileges. Two approaches:

**User-level admin** (runs as your account with admin):
```powershell
# Run in Admin PowerShell
$action = New-ScheduledTaskAction -Execute "clawdbot" -Argument "gateway"
$trigger = New-ScheduledTaskTrigger -AtLogon
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
Register-ScheduledTask -TaskName "ClawdbotGatewayAdmin" -Action $action -Trigger $trigger -Principal $principal -Settings $settings
```

**SYSTEM-level admin** (recommended - survives config restarts):
```powershell
# Run in Admin PowerShell - runs as SYSTEM with highest privileges
# Stop current gateway first
clawdbot gateway stop

# Create SYSTEM-level task
$action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c clawdbot gateway"
$trigger = New-ScheduledTaskTrigger -AtStartup
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero) -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 1)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "ClawdbotGateway" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force

# Start it now
Start-ScheduledTask -TaskName "ClawdbotGateway"
```

With admin access, the bot can:
- Install/uninstall software
- Modify system files and Windows settings
- Access protected folders
- Run administrative commands

**Why SYSTEM-level is better**: When the bot modifies its config (e.g., enabling elevated tools), the gateway restarts. User-level elevated tasks lose admin on restart. SYSTEM-level tasks maintain admin permanently.

**Manual Admin Session**: For one-time admin access without a scheduled task:
```powershell
# Open PowerShell as Administrator, then:
clawdbot gateway stop
clawdbot gateway
```

**Option 5: Watchdog Script**

Use the watchdog script for more control over restarts:

```powershell
# Copy watchdog script
Copy-Item ide-configs\clawdbot\clawdbot-watchdog.ps1 $env:USERPROFILE\.clawdbot\

# Run watchdog (keeps gateway running)
powershell -ExecutionPolicy Bypass -File $env:USERPROFILE\.clawdbot\clawdbot-watchdog.ps1
```

Create a scheduled task for the watchdog:

```powershell
$action = New-ScheduledTaskAction -Execute "powershell" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File $env:USERPROFILE\.clawdbot\clawdbot-watchdog.ps1"
$trigger = New-ScheduledTaskTrigger -AtLogon
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited
Register-ScheduledTask -TaskName "Clawdbot Watchdog" -Action $action -Trigger $trigger -Principal $principal
```

### macOS (launchd)

Create `~/Library/LaunchAgents/com.clawdbot.gateway.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.clawdbot.gateway</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/clawdbot</string>
        <string>gateway</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Load it:
```bash
launchctl load ~/Library/LaunchAgents/com.clawdbot.gateway.plist
```

### Linux (systemd)

Create `~/.config/systemd/user/clawdbot.service`:
```ini
[Unit]
Description=Clawdbot Gateway
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/clawdbot gateway
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
```

Enable it:
```bash
systemctl --user enable clawdbot
systemctl --user start clawdbot
```

## Troubleshooting

### Gateway won't start

```bash
clawdbot doctor
clawdbot doctor --fix
```

### Token expiring

If you see "expiring (Xh)" in doctor output:
```bash
# Refresh the Claude CLI token
claude setup-token
```

The Claude CLI token expires periodically and needs to be refreshed. If the gateway stops responding or shows authentication errors, this is often the cause.

**Tip**: Set up a reminder to check `clawdbot doctor` periodically to catch expiring tokens before they cause issues.

### Telegram not connecting

1. Verify bot token is correct
2. Check if another instance is running
3. Ensure `channels.telegram.enabled` is `true`

### Check gateway status

```bash
# Quick status check
clawdbot status

# Detailed status with channel probes
clawdbot status --deep

# Follow live logs
clawdbot logs --follow
```

### View logs

**Windows:**
```powershell
type \tmp\clawdbot\clawdbot-*.log
```

**macOS / Linux:**
```bash
cat /tmp/clawdbot/clawdbot-*.log
```

### Bot not responding

```bash
clawdbot sessions list
clawdbot sessions send <label> "ping"
```

### Port conflicts

**macOS / Linux:**
```bash
# Check what's using the port
lsof -i :18789

# Kill the process
kill $(lsof -t -i :18789)
```

**Windows:**
```powershell
# Check what's using the port
netstat -ano | findstr :18789

# Kill process by PID
taskkill /PID <pid> /F
```

### Windows: PowerShell syntax errors

If you see errors like `The token '&&' is not a valid statement separator`:
- Windows PowerShell doesn't support `&&` - use semicolons `;` instead
- The bot should automatically use PowerShell-compatible syntax
- If issues persist, ensure you're running PowerShell 7+ which supports `&&`

### Gateway crashes on config change

If gateway crashes with `AbortError: This operation was aborted`:
- This happens when config is updated while gateway is reloading
- The gateway tries to hot-reload on config changes but can fail
- Common triggers:
  - Bot uses `gateway` tool to modify `clawdbot.json`
  - Manual config file edits while gateway is running
  - `clawdbot config set` commands
- **Solution**: Use the watchdog script for auto-recovery
- **Alternative**: Manually restart with `clawdbot gateway`

**Why this happens**: The bot can modify its own config via the `gateway` tool (e.g., updating `tools.elevated.allowFrom`). When `clawdbot.json` changes, the gateway detects `meta.lastTouchedAt` changed and sends itself `SIGUSR1` to restart. During restart, pending API requests get aborted, causing the crash.

**Recommended setup**: Always use the watchdog script or scheduled task with restart settings to ensure automatic recovery.

### Gateway crashes with "fetch failed"

If you see `TypeError: fetch failed`:
- Usually a network issue or API timeout
- Check internet connectivity
- Verify Claude CLI is authenticated: `claude --version`
- The watchdog script will auto-restart on these failures

### Browser control errors

If you see `Can't reach the clawd browser control server`:
- The browser integration timed out
- This is non-fatal - Telegram still works
- Browser features require the Clawdbot Chrome extension

## Commands Reference

| Command | Description |
|---------|-------------|
| `clawdbot setup` | Run initial setup wizard |
| `clawdbot gateway` | Start gateway in foreground |
| `clawdbot gateway install` | Install as system service |
| `clawdbot doctor` | Check configuration health |
| `clawdbot doctor --fix` | Auto-fix configuration issues |
| `clawdbot config set KEY VALUE` | Set configuration value |
| `clawdbot config get KEY` | Get configuration value |
| `clawdbot status` | Check gateway status |
| `clawdbot status --deep` | Detailed status with probes |
| `clawdbot logs --follow` | Follow live gateway logs |
| `clawdbot sessions list` | List all active sessions |
| `clawdbot sessions send LABEL MSG` | Send message to agent |
| `clawdbot pairing approve telegram CODE` | Approve Telegram pairing |
| `clawdbot security audit` | Run security audit |
| `clawdbot security audit --deep` | Deep security audit |

## Additional MCP Servers

Enhance Clawdbot with additional MCP servers for extended capabilities.

### Web Search (Brave Search API)

Enable web search capabilities:

1. Get API key from [Brave Search API](https://brave.com/search/api/)

2. Add to Claude Code settings:
```json
{
  "mcp": {
    "servers": {
      "brave-search": {
        "command": "npx",
        "args": ["@anthropic/mcp-server-brave-search"],
        "env": {
          "BRAVE_API_KEY": "YOUR_API_KEY"
        }
      }
    }
  }
}
```

### Filesystem Access

Enable file operations:
```json
{
  "mcp": {
    "servers": {
      "filesystem": {
        "command": "npx",
        "args": ["@anthropic/mcp-server-filesystem", "~/Documents", "~/Projects"]
      }
    }
  }
}
```

### Memory (Persistent Context)

Enable long-term memory:
```json
{
  "mcp": {
    "servers": {
      "memory": {
        "command": "npx",
        "args": ["@anthropic/mcp-server-memory"]
      }
    }
  }
}
```

## Cron Jobs (Persistent Automation)

Cron jobs survive compaction, restarts, and session resets. Use them for recurring tasks.

### Schedule Types

| Type | Use For | Example |
|------|---------|---------|
| `at` | One-shot (reminder) | `{ "kind": "at", "atMs": 1769436000000 }` |
| `every` | Fixed interval | `{ "kind": "every", "everyMs": 3600000 }` (1 hour) |
| `cron` | Cron expression | `{ "kind": "cron", "expr": "0 9,15,21 * * *" }` |

### Creating Cron Jobs (from agent)

```
cron action=add job={
  "name": "My Job",
  "schedule": { "kind": "every", "everyMs": 3600000 },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Task instructions here",
    "deliver": true,
    "channel": "last",
    "to": "telegram:USER_ID"
  }
}
```

### Managing Cron Jobs

```
cron action=list              # List all jobs
cron action=update jobId=ID patch={...}  # Update a job
cron action=remove jobId=ID   # Delete a job
cron action=run jobId=ID       # Run immediately
```

### Recommended Cron Setup

| Job | Frequency | Purpose |
|-----|-----------|---------|
| Health Monitor | Every 30 min | Check all services are running |
| App Store Monitor | Every 1 hour | Check iOS builds, resubmit if expired |
| Project CI (per project) | Every 1 hour | Test, fix, commit, push |

**Note:** On Claude Max, cron jobs are effectively free (flat subscription). Run as frequently as needed.

### Cron vs Heartbeat

| Use Cron When | Use Heartbeat When |
|---------------|--------------------|
| Exact timing matters | Multiple checks can batch |
| Task needs isolation | Needs main session context |
| One-shot reminders | Timing can drift slightly |
| Different model/thinking level | Reduce API calls by combining |

## Concurrency Settings

Default concurrency is too low for multi-agent setups. Increase it:

```json
{
  "agents": {
    "defaults": {
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    }
  }
}
```

**Symptoms of low concurrency:**
- Sub-agents show `totalTokens: 0` (queued but never execute)
- Subagent lane wait exceeded warnings in logs
- Agents appear "stuck" or dead

## Security Notes

- **Bot Token**: Keep your bot token secret
- **DM Policy**: Use `pairing` for personal bots
- **Group Policy**: Use `allowlist` to control which groups can use the bot
- **Telegram Encryption**: Bot messages are not end-to-end encrypted
- **Elevated Tools**: Only enable for trusted users via `allowFrom`
- **allowFrom Lists**: Use to restrict access to specific Telegram user IDs

### Gateway Security (CRITICAL)

**923 Clawdbot gateways were found exposed on Shodan (Jan 2026) with zero auth.**

An exposed gateway means: shell access, browser automation, API keys — full device control.

**Always verify:**
```bash
# Check your config
cat ~/.clawdbot/clawdbot.json | python3 -c "
import json, sys
c = json.load(sys.stdin)
gw = c.get('gateway', {})
print(f'bind: {gw.get(\"bind\")}')
print(f'auth token: {\"SET\" if gw.get(\"auth\", {}).get(\"token\") else \"MISSING!\"}')"
```

**Required settings:**
| Setting | Safe Value | Dangerous Value |
|---------|-----------|-----------------|
| `gateway.bind` | `loopback` or `lan` | `all` ⚠️ |
| `gateway.auth.token` | Any string | Missing/empty ⚠️ |

**Fix if exposed:**
```json
{
  "gateway": {
    "bind": "loopback",
    "auth": {
      "token": "your-secure-token-here"
    }
  }
}
```

If you need remote access, use Cloudflare Tunnel — never expose port 18789 directly.

## Upgrading

```bash
npm update -g clawdbot
clawdbot doctor --fix
```
