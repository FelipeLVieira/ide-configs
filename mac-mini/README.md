# Mac Mini Server Setup

Dedicated always-on server for running all bots 24/7 with automatic failover from MacBook.

## Server Details

| Property | Value |
|----------|-------|
| Hostname | `hostname.local` |
| Username | `username` |
| IP (LAN) | `10.144.238.249` (DHCP, may change) |
| macOS | Tahoe 26.2 |
| Chip | Apple M4, 16GB RAM |
| Disk | 460GB (335GB free) |
| SSH | Key-based (passwordless) |
| Sudo | Passwordless enabled |

## Central Ollama Hub

The Mac Mini serves as the **central Ollama inference hub** for the entire ecosystem:

| Client | How it connects |
|--------|----------------|
| **Mac Mini** (local) | `http://localhost:11434` |
| **MacBook Pro** | `http://felipes-mac-mini.local:11434` |
| **Windows MSI** | `http://100.115.10.14:11434` (Tailscale) |

All heartbeats across all 3 machines route through Mac Mini Ollama (gpt-oss:20b) — **FREE**.

### Windows Auto-Start
The Windows MSI has a **Scheduled Task "ClawdbotGateway"** that auto-starts the gateway on login, routing inference through Mac Mini.

---

## Architecture

```
MacBook (PRIMARY)                Mac Mini (STANDBY)
┌────────────────────┐          ┌────────────────────┐
│ Clawdbot Gateway   │◄─health──│ Failover Watchdog  │
│ Telegram Bot ✅    │  check   │ (every 30s)        │
│ All bots running   │  (TCP)   │                    │
│                    │          │ Clawdbot Gateway   │
│                    │          │ Telegram Bot ❌    │
│                    │          │ All bots running   │
└────────────────────┘          └────────────────────┘
        │                              │
        │  MacBook goes down           │
        └──────────────────────────────┘
                                       │
                                ┌──────▼─────────────┐
                                │ Clawdbot Gateway   │
                                │ Telegram Bot ✅    │
                                │ All bots ACTIVE    │
                                └────────────────────┘
```

| Machine | Role | Telegram | When Active |
|---------|------|----------|-------------|
| **MacBook** | Primary (gateway + Telegram) | Enabled | Default |
| **Mac Mini** | Standby (all bots running, no Telegram) | Disabled | Default |
| **Mac Mini** | Failover Primary | Enabled | When MacBook offline (auto) |

## Quick SSH Access

```bash
ssh username@hostname.local
```

## Automatic Failover System

The Mac Mini runs a watchdog that monitors the MacBook's Clawdbot gateway via TCP health checks.

### How it works:
1. Watchdog checks MacBook port 18789 every 30 seconds
2. After **3 consecutive failures** (90s): Mac Mini enables Telegram, restarts gateway
3. After **5 consecutive recoveries** (150s): Mac Mini disables Telegram, yields back
4. Workspace synced via git before activation

### Failover script: `~/.clawdbot/scripts/failover.sh`
### LaunchAgent: `com.clawdbot.failover`

### Manual failover (if needed):
```bash
# Enable Telegram on Mac Mini
ssh username@hostname.local 'python3 -c "
import json
with open(\"/Users/username/.clawdbot/clawdbot.json\") as f:
    c = json.load(f)
c[\"plugins\"][\"entries\"][\"telegram\"][\"enabled\"] = True
with open(\"/Users/username/.clawdbot/clawdbot.json\", \"w\") as f:
    json.dump(c, f, indent=2)
" && eval "$(/opt/homebrew/bin/brew shellenv)" && clawdbot gateway restart'

# Disable Telegram (yield back)
ssh username@hostname.local 'python3 -c "
import json
with open(\"/Users/username/.clawdbot/clawdbot.json\") as f:
    c = json.load(f)
c[\"plugins\"][\"entries\"][\"telegram\"][\"enabled\"] = False
with open(\"/Users/username/.clawdbot/clawdbot.json\", \"w\") as f:
    json.dump(c, f, indent=2)
" && eval "$(/opt/homebrew/bin/brew shellenv)" && clawdbot gateway restart'
```

**Important**: Only ONE machine should have Telegram enabled at a time.

## LaunchAgents (Auto-Start on Boot)

All services run as LaunchAgents — they auto-start on boot and auto-restart on crash.

| LaunchAgent | Service | Status |
|-------------|---------|--------|
| `com.clawdbot.gateway` | Clawdbot Gateway (port 18789) | Always running |
| `com.clawdbot.game-server` | Game Server game servers (2567, 2568, 4000, 4001) | Always running |
| `com.clawdbot.trading-bot` | Polymarket trading bot | Always running |
| `com.clawdbot.failover` | MacBook health monitor | Always running |
| `com.clawdbot.node` | Clawdbot node (connects to MacBook gateway) | Always running |

### Managing LaunchAgents:
```bash
# Stop a service
launchctl unload ~/Library/LaunchAgents/com.clawdbot.game-server.plist

# Start a service
launchctl load ~/Library/LaunchAgents/com.clawdbot.game-server.plist

# Check status
launchctl list | grep clawdbot
```

### Startup scripts: `~/.clawdbot/scripts/`
- `start-game-server.sh` — starts game servers + web frontends
- `start-trading-bot.sh` — starts Polymarket bot with uv
- `failover.sh` — MacBook health monitor + auto-failover

### Log locations:
- Gateway: `/tmp/clawdbot/clawdbot-YYYY-MM-DD.log`
- Game Server: `/tmp/clawdbot/game-server-stdout.log`, `/tmp/clawdbot/game-server-stderr.log`
- Trading bot: `/tmp/clawdbot/trading-bot-stdout.log`
- Failover: `/tmp/clawdbot/failover.log`
- Node: `~/.clawdbot/logs/node.log`, `~/.clawdbot/logs/node.err.log`

## Node Pairing (Remote Command Execution)

The Mac Mini is paired as a Clawdbot node, allowing the MacBook gateway to execute commands on it remotely.

### Status:
- Node ID: `mac-mini`
- Connected: Yes (WebSocket to MacBook gateway)
- Exec approvals: `full` (no restrictions)
- Capabilities: `browser`, `system` (system.run, system.which)

### Execute commands remotely:
```bash
# From MacBook terminal
clawdbot nodes invoke --node mac-mini --command system.run --params '{"command":["hostname"]}'

# Or from Clawdbot agent (using exec tool with host=node)
exec host=node node=mac-mini command="ls ~/repos"
```

### Re-pair if needed:
```bash
# On MacBook
clawdbot devices list        # Check pending
clawdbot devices approve <requestId>
```

## Workspace Sync (Git)

The `~/clawd` workspace is synced between both Macs via GitHub.

- **Repo**: `github.com/username/clawd-workspace` (private)
- **MacBook**: Auto-pushes every 15 minutes (cron)
- **Mac Mini**: Pulls on failover activation

### Manual sync:
```bash
# Push from MacBook
cd ~/clawd && git add -A && git commit -m "sync" && git push origin master

# Pull on Mac Mini
ssh username@hostname.local 'cd ~/clawd && git pull origin master'
```

## Installed Software

| Tool | Version | Purpose |
|------|---------|---------|
| Homebrew | latest | Package manager |
| Node.js | v25.4.0 | Game Server, Clawdbot |
| npm | 11.7.0 | Package management |
| pnpm | 10.28.1 | Game Server monorepo |
| Python | 3.14.2 | Trading bot |
| uv | 0.9.26 | Python venv manager |
| Git | 2.52.0 | Version control |
| gh | latest | GitHub CLI |
| Clawdbot | 2026.1.24-3 | AI orchestrator |
| Claude Code | latest | AI coding |
| tmux | latest | Terminal multiplexer |
| ffmpeg | latest | Media processing |
| jq | latest | JSON processing |
| htop | latest | Process monitoring |
| dotenv-cli | latest | Env file loading |
| cross-env | latest | Cross-platform env |
| cairo, pango, etc. | latest | Canvas native deps |

## Running Services & Ports

| Service | Port | Protocol |
|---------|------|----------|
| Game Server Game Server (prod) | 2567 | WebSocket |
| Game Server Game Server (dev) | 2568 | WebSocket |
| Game Server Web Frontend (prod) | 4000 | HTTP |
| Game Server Web Frontend (dev) | 4001 | HTTP |
| Clawdbot Gateway | 18789 | HTTP/WS |
| Shitcoin Bot | — | Background |
| Failover Watchdog | — | Background |
| Clawd Monitor | 9000 | HTTP (Next.js) |

## Trading Bot

### Recommended Execution Engine: Freqtrade
**Freqtrade** is the recommended CEX execution engine (Python-native, Ollama-compatible, extensive backtesting). Install alongside existing Polymarket bot for CEX trading. See [RESEARCH-2026-01-27.md](../clawdbot/RESEARCH-2026-01-27.md) for details.

### Sentiment: Perception.to (replaces LunarCrush)
LunarCrush pricing became prohibitive. **Perception.to** provides equivalent social sentiment data with a free tier. Update shitcoin bot API integrations accordingly.

- Uses VPN SOCKS5 proxy for geo-bypass
- Proxy credentials in `~/repos/trading-bot/.env`
- Split tunneling: only trading platform API goes through proxy
- All other traffic (Claude API, web) uses direct connection

### Operating Modes (brain_control.json)

| Mode | auto_invest | copy_trading | manual_trading | Description |
|------|:-----------:|:------------:|:--------------:|-------------|
| **Research Only** | ❌ | ❌ | ✅ | Scans whales & markets, logs opportunities to `data/research_opportunities.json`. Clawdbot reviews & approves. |
| **Conservative** | ✅ | ✅ | ✅ | Copy trading ON, momentum OFF. Small positions ($3 max). |
| **Full Auto** | ✅ | ✅ | ✅ | All strategies enabled. Use with caution. |
| **Emergency Stop** | ❌ | ❌ | ❌ | All trading halted. |

Current mode: **Research Only** (set 2026-01-26)

### Thread Auto-Restart

Bot threads (Price Lag, Cross-Arb, LP, etc.) now auto-restart up to 10 times when they die, instead of just logging a warning. 5s health check interval with 2s backoff. See `src/run_bots.py`.

### Key Files

| File | Purpose |
|------|---------|
| `data/brain_control.json` | Runtime trading config (read every 60s) |
| `data/research_opportunities.json` | Logged opportunities in research mode |
| `data/wallet_snapshot_*.json` | Periodic wallet snapshots |
| `src/utils/brain_control.py` | Brain control reader + research mode |
| `src/strategies/copy_trading.py` | Copy trading with research mode integration |

### Lessons Learned (Jan 2026)

- ❌ **15-min crypto Up/Down markets**: Coin flips with 3.15% dynamic fees. Strategy dead.
- ❌ **Sports bets via copy trading**: Whales inconsistent on sports. All losses.
- ✅ **Political/geopolitical "NO" bets**: High-conviction unlikely events. Best performers.
- ✅ **Research-first approach**: Let bot scan, human/AI reviews before trading.

## Game Server Game (Dual Environment)

| Environment | Server Port | Frontend Port | Data Dir | Purpose |
|------------|:-----------:|:-------------:|----------|---------|
| **Production** | 2567 | 4000 | `data/storage/` | Production users |
| **Development** | 2568 | 4001 | `data/storage-dev/` | Bots develop & test |

```bash
# Commands
pnpm dev:server:prod    # Start prod server (2567)
pnpm dev:server:dev     # Start dev server (2568)
pnpm db:sync prod dev   # Sync schema prod → dev
pnpm db:sync dev prod   # Sync schema dev → prod
```

See `~/repos/game-server/docs/DUAL-ENVIRONMENT.md` for full details.

## Clawdbot Agent Bootstrap

After initial setup, **delete `BOOTSTRAP.md`** from the workspace root. If it exists, the gateway reports all agents as "bootstrapping" and they won't fully initialize. Identity files (`IDENTITY.md`, `SOUL.md`, `USER.md`) must exist before deletion.

## Energy Settings (Always-On)

```bash
sudo pmset -a displaysleep 0 sleep 0 disksleep 0 womp 1 autorestart 1
```

| Setting | Value |
|---------|-------|
| Display sleep | Disabled |
| System sleep | Disabled |
| Disk sleep | Disabled |
| Wake on network | Enabled |
| Auto-restart after power failure | Enabled |

## Remote Access

### Screen Sharing (VNC)
```bash
# From MacBook
open vnc://hostname.local
```
- Port: 5900
- Login: `username` + password
- Remote Management (ARD) enabled with full privileges

### Mouse & Keyboard Control (cliclick)
```bash
# Via Clawdbot node (preferred)
clawdbot nodes invoke --node mac-mini --command system.run --params '{"command":["cliclick","m:500,500"]}'

# Via SSH + osascript (Terminal.app has Accessibility)
ssh username@hostname.local 'osascript -e "tell application \"Terminal\" to do script \"/opt/homebrew/bin/cliclick m:500,500\""'
```

**cliclick commands:**
| Command | Action | Example |
|---------|--------|---------|
| `m:X,Y` | Move mouse | `cliclick m:500,500` |
| `c:X,Y` | Click | `cliclick c:500,500` |
| `dc:X,Y` | Double-click | `cliclick dc:500,500` |
| `rc:X,Y` | Right-click | `cliclick rc:500,500` |
| `t:TEXT` | Type text | `cliclick t:"hello"` |
| `kp:KEY` | Key press | `cliclick kp:return` |
| `p` | Print position | `cliclick p` |

**Accessibility permissions required:**
- System Settings → Privacy & Security → Accessibility
- Must have: Terminal (and/or sshd, node)
- cliclick installed at: `/opt/homebrew/bin/cliclick`

### iOS Development (Remote)
| Tool | Version | Path |
|------|---------|------|
| Xcode | 26.2 | `/Applications/Xcode.app` |
| EAS CLI | v16.28 | `eas` |
| CocoaPods | 1.16.2 | `pod` |
| Simulators | iPhone + iPad | via `xcrun simctl` |

**Apple Store Connect (automated builds):**
- App-Specific Password stored in `~/repos/.env.apple`
- Env vars: `EXPO_APPLE_ID`, `EXPO_APPLE_PASSWORD`, `APPLE_TEAM_ID`
- Bots can `eas build` + `eas submit` without 2FA prompts

## SSH Keys

| From → To | Key | Purpose |
|-----------|-----|---------|
| MacBook → Mac Mini | `~/.ssh/id_ed25519` | SSH access |
| Mac Mini → GitHub | `~/.ssh/id_ed25519` | Git push/pull |
| Mac Mini → MacBook | `~/.ssh/id_ed25519` | (not working yet - uses TCP health check instead) |

## Clawdbot Config

Location: `~/.clawdbot/clawdbot.json`

Key differences from MacBook config:
- `plugins.entries.telegram.enabled`: **false** (standby mode)
- `gateway.bind`: **lan** (accessible from MacBook)
- `gateway.auth.token`: **SET** (required! was missing initially — security fix 2026-01-26)
- Same bot token as MacBook (for failover)
- Same agents list (main, trading-bot, game-server)

**⚠️ ALWAYS ensure auth token is set.** Without it, anyone on the network has full shell access.

## Troubleshooting

### SSH Connection Failed
```bash
ping hostname.local
# If unreachable, check if Mini is awake/on same network
```

### Services Not Running
```bash
ssh username@hostname.local 'launchctl list | grep clawdbot'
# Restart a service:
ssh username@hostname.local 'launchctl unload ~/Library/LaunchAgents/com.clawdbot.SERVICE.plist; launchctl load ~/Library/LaunchAgents/com.clawdbot.SERVICE.plist'
```

### Telegram Conflict (HTTP 429 / getUpdates conflict)
Only ONE gateway should have Telegram enabled. Check both machines:
```bash
# MacBook
cat ~/.clawdbot/clawdbot.json | python3 -c "import json,sys; c=json.load(sys.stdin); print('MacBook Telegram:', c['plugins']['entries']['telegram']['enabled'])"

# Mac Mini
ssh username@hostname.local 'cat ~/.clawdbot/clawdbot.json | python3 -c "import json,sys; c=json.load(sys.stdin); print(\"Mac Mini Telegram:\", c[\"plugins\"][\"entries\"][\"telegram\"][\"enabled\"])"'
```

### Node Not Connected
```bash
# Check node status from MacBook
clawdbot nodes status

# Check node logs on Mac Mini
ssh username@hostname.local 'tail -10 ~/.clawdbot/logs/node.err.log'

# Re-pair if needed
clawdbot devices list
clawdbot devices approve <requestId>
```

### Failover Not Working
```bash
# Check watchdog log
ssh username@hostname.local 'tail -20 /tmp/clawdbot/failover.log'

# Check if watchdog is running
ssh username@hostname.local 'ps aux | grep failover | grep -v grep'

# Manual test: stop MacBook gateway and watch failover log
```

### MacBook IP Changed (DHCP)
Update the failover script:
```bash
ssh username@hostname.local 'sed -i "" "s/MACBOOK_IP=\".*\"/MACBOOK_IP=\"NEW_IP_HERE\"/" ~/.clawdbot/scripts/failover.sh'
# Restart watchdog
ssh username@hostname.local 'launchctl unload ~/Library/LaunchAgents/com.clawdbot.failover.plist; launchctl load ~/Library/LaunchAgents/com.clawdbot.failover.plist'
```

---

## Clawdbot Persistent Bots (Added 2026-01-26)

The Mac Mini runs 5 persistent AI bots 24/7:

| Bot | Workspace | Purpose |
|-----|-----------|---------|
| ez-crm | ~/repos/ez-crm | CRM development |
| linklounge | ~/repos/linklounge | Linktree clone |
| aphos | ~/repos/aphos | MMORPG game |
| ios-appstore | ~/repos/bmi-calculator | iOS app builds |
| clawd-monitor | ~/repos/clawd-monitor | Bot dashboard |

Plus the shitcoin trading bot (Python process).

### Quick Commands

```bash
# Check bot status
~/clawd/scripts/manage-bots.sh status

# View bot logs
tmux attach -t bot-ez-crm

# Restart all bots
~/clawd/scripts/manage-bots.sh restart
```

### Critical Rules

1. **iOS builds: LOCAL ONLY** - xcodebuild, never eas build
2. **MEGA not Google Drive**
3. **Browser lock before browser use**

See `~/repos/ide-configs/clawdbot/PERSISTENT-BOTS.md` for full documentation.
