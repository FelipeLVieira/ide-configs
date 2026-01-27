# Persistent Bot Architecture

Documentation for running 24/7 specialist bots on Mac Mini.

## Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    MAC MINI BOT FACTORY                     │
├─────────────────────────────────────────────────────────────┤
│  9 Persistent Bots (tmux sessions)                          │
│  ├── bot-ez-crm          (Next.js/Supabase CRM)            │
│  ├── bot-linklounge      (Linktree competitor)              │
│  ├── bot-aphos           (MMORPG - Next.js+Three.js)        │
│  ├── bot-game-assets     (Game asset tool)                  │
│  ├── bot-ios-bmi         (iOS BMI Calculator)               │
│  ├── bot-ios-bills       (iOS Bills Tracker)                │
│  ├── bot-ios-translator  (iOS Screen Translator)            │
│  ├── bot-clawd-monitor   (Dashboard)                        │
│  └── bot-shitcoin-brain  (Trading research AI)              │
│                                                             │
│  + Python Trading Bot (shitcoin-bot/run_bots.py)            │
└─────────────────────────────────────────────────────────────┘
```

## Bot Configuration

| Bot | Project | Port | Simulator | Pause |
|-----|---------|------|-----------|-------|
| ez-crm | ~/repos/ez-crm | 3000-3099 | - | 10 min |
| linklounge | ~/repos/linklounge | 3100-3199 | - | 10 min |
| aphos | ~/repos/aphos | 4000, 2567 | - | 10 min |
| game-assets | ~/repos/game-asset-tool | 3200-3299 | - | 10 min |
| ios-bmi | ~/repos/bmi-calculator | 8081 | iPhone 16 Pro | 10 min |
| ios-bills | ~/repos/bill-subscriptions-organizer-tracker | 8082 | iPhone 16 Pro Max | 10 min |
| ios-translator | ~/repos/simple-screen-translator | 8083 | iPad Air 5th gen | 10 min |
| clawd-monitor | ~/repos/clawd-monitor | 9009 | - | 10 min |
| shitcoin-brain | ~/repos/shitcoin-bot | - | - | 30 min |

## Management Commands

```bash
# All bots
~/clawd/scripts/manage-bots.sh status     # Check all bots
~/clawd/scripts/manage-bots.sh start      # Start all bots
~/clawd/scripts/manage-bots.sh stop       # Stop all bots
~/clawd/scripts/manage-bots.sh restart    # Restart all bots
~/clawd/scripts/manage-bots.sh health     # Restart any stopped bots

# Single bot
~/clawd/scripts/manage-bots.sh start <name>
~/clawd/scripts/manage-bots.sh stop <name>

# View bot logs
tmux attach -t bot-<name>
# Detach: Ctrl+B, D
```

## Simulator Management

iOS bots must coordinate simulator usage to avoid conflicts.

```bash
# Check if safe to boot
~/clawd/scripts/sim-manager.sh check ios-bmi

# Boot assigned simulator
~/clawd/scripts/sim-manager.sh boot ios-bmi

# Take screenshot
~/clawd/scripts/sim-manager.sh screenshot ios-bmi /tmp/screenshot.png

# Click via Hammerspoon
~/clawd/scripts/sim-manager.sh click ios-bmi 200 400

# Type via Hammerspoon  
~/clawd/scripts/sim-manager.sh type ios-bmi "hello"

# ALWAYS shut down when done!
~/clawd/scripts/sim-manager.sh shutdown ios-bmi
```

### Simulator Rules
1. **CHECK** before booting - never boot if another sim is running
2. **WAIT** if another bot is using a simulator
3. **SHUT DOWN** immediately after testing
4. **One simulator at a time** - no parallel simulators

## Browser Management

Bots share a single Chrome instance. Use browser lock to coordinate.

```bash
# Check browser availability
~/clawd/scripts/check-browser.sh

# Acquire lock before browser use
source ~/clawd/scripts/browser-lock.sh
acquire_browser_lock "bot-name"

# Release when done
release_browser_lock
```

If Chrome extension relay has no tab attached, bots should **skip browser tasks**.

## Multi-Account Rate Limit Fallback

Two Claude accounts configured with automatic failover on 429 errors.

| Account | Email | Role |
|---------|-------|------|
| felipe | felipe.lv.90@gmail.com | Primary |
| wisedigital | wisedigitalinc@gmail.com | Fallback |

### Key Files
- `~/.clawd/scripts/claude-multi` - Wrapper with auto-switch
- `~/.claude-wisedigital/oauth-token` - Fallback OAuth token
- `~/.clawdbot/agents/main/agent/auth-profiles.json` - Profile config

## Cron Jobs (Minimal)

Only 2 cron jobs to reduce overhead:

| Job | Schedule | Purpose |
|-----|----------|---------|
| Bot Health Check | */30 * * * * | Restart crashed bots |
| clear-sessions | 0 0 * * 0 | Weekly session cleanup |

## Bot Prompt Rules

All bots receive these instructions:

### Resource Rules
- 🎯 Stay focused on assigned project ONLY
- 🔌 Use assigned port - check before starting servers
- 📱 iOS bots: Use assigned simulator only
- 🌐 Do not close browser - only close own excess tabs
- 📁 Use MEGA not Google Drive

### Credit Saving
- 🔍 Use Grok (x.com/i/grok) for research FIRST
- 📱 Search X/Twitter for error messages
- 💬 Check Reddit (r/reactnative, r/nextjs, etc.)
- 📖 Search Stack Overflow before trying yourself

### Server Cleanup
```bash
# Before starting, check your port
lsof -i :<port>

# Kill orphan on your port  
kill $(lsof -t -i :<port>)
```

## Shitcoin Brain (Research Agent)

Special bot that monitors the Python trading bot and researches strategies.

**Role:** Monitor and improve, NOT trade directly
**Output:** `~/clawd/memory/shitcoin-brain/YYYY-MM-DD.md`

### Research Topics
- Polymarket whale strategies
- Copy trading optimization
- Position sizing algorithms
- pigeon-mcp updates (@pigeon_trade)
- Kalshi vs Polymarket arbitrage

## Auto-Start on Reboot

```bash
# Add to crontab
crontab -e

# Add this line:
@reboot ~/clawd/scripts/startup-bots.sh
```

## Monitoring Dashboard

clawd-monitor runs on port 9009 and provides:
- Real-time bot status
- Token usage tracking
- Session management
- Machine resource monitoring

**Token-safe:** Dashboard only reads files and runs status commands. No AI tokens consumed by auto-refresh.

## Troubleshooting

### Bot not starting
```bash
# Check if session exists
tmux has-session -t bot-<name>

# Kill zombie session
tmux kill-session -t bot-<name>

# Start fresh
~/clawd/scripts/manage-bots.sh start <name>
```

### Session lock error
```bash
rm -f ~/.clawdbot/agents/main/sessions/persistent-<name>.jsonl.lock
```

### Port conflict
```bash
lsof -i :<port>
kill $(lsof -t -i :<port>)
```

### Simulator stuck
```bash
xcrun simctl shutdown all
```
