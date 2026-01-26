# Persistent Bot Architecture

> Last updated: 2026-01-26

## Overview

Bots run **24/7** as persistent tmux sessions on Mac Mini. Each bot is a **SPECIALIST** focused on ONE project only.

## Active Bots (7 Specialists + 1 Trading Bot)

| Bot | Project | Port | Simulator | Tech Stack |
|-----|---------|------|-----------|------------|
| **ez-crm** | ~/repos/ez-crm | 3000-3099 | - | Next.js, Supabase |
| **linklounge** | ~/repos/linklounge | 3100-3199 | - | Link-in-bio platform |
| **aphos** | ~/repos/aphos | 4000 (web), 2567 (game) | - | **Next.js + Three.js** (2.5D) |
| **ios-bmi** | ~/repos/bmi-calculator | 8081 | iPhone 16 Pro | React Native/Expo |
| **ios-bills** | ~/repos/bill-subscriptions-organizer-tracker | 8082 | iPhone 16 Pro Max | React Native/Expo |
| **ios-translator** | ~/repos/simple-screen-translator | 8083 | iPad Air 5th gen | React Native/Expo |
| **clawd-monitor** | ~/repos/clawd-monitor | 9009 | - | Next.js dashboard |
| **shitcoin-bot** | ~/repos/shitcoin-bot | - | - | Python (run_bots.py) |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    MAC MINI (Bot Server)                    │
├─────────────────────────────────────────────────────────────┤
│  Clawdbot Gateway (always running)                          │
│                                                             │
│  Specialist Bots (tmux sessions):                           │
│  ├── bot-ez-crm         Port: 3000    Next.js/Supabase     │
│  ├── bot-linklounge     Port: 3100    Link-in-bio          │
│  ├── bot-aphos          Port: 4000    Next.js/Three.js 2.5D│
│  ├── bot-ios-bmi        Port: 8081    iPhone 16 Pro        │
│  ├── bot-ios-bills      Port: 8082    iPhone 16 Pro Max    │
│  ├── bot-ios-translator Port: 8083    iPad Air 5th gen     │
│  └── bot-clawd-monitor  Port: 9009    Dashboard            │
│                                                             │
│  Trading Bot (Python process):                              │
│  └── run_bots.py        Crypto trading                      │
│                                                             │
│  Health Check: Every 30 min (cron)                          │
│  Auto-start: @reboot startup-bots.sh                        │
└─────────────────────────────────────────────────────────────┘
```

## Critical Rules

### 1. SPECIALIZATION
Each bot works **ONLY** on its assigned project. No cross-project work.

### 2. PORT ISOLATION
Each bot has assigned ports. Check before starting: `lsof -i :<port>`

| Range | Project |
|-------|---------|
| 2567-2599 | Aphos game servers |
| 3000-3099 | EZ-CRM |
| 3100-3199 | LinkLounge |
| 4000-4099 | Aphos web |
| 8081 | BMI Calculator (Expo) |
| 8082 | Bills Tracker (Expo) |
| 8083 | Screen Translator (Expo) |
| 9009 | Clawd Monitor |

### 3. SIMULATOR ISOLATION (iOS bots)
Each iOS bot uses **ONLY** its assigned simulator:
- `ios-bmi` → iPhone 16 Pro
- `ios-bills` → iPhone 16 Pro Max
- `ios-translator` → iPad Air 5th generation

### 4. BROWSER RULES
- ❌ **DO NOT** close the browser entirely
- ✅ Only close excess tabs from YOUR OWN project
- ✅ Use browser lock before accessing: `acquire_browser_lock "BotName"`

### 5. Aphos Tech Stack
- **Next.js** for web application
- **Three.js** for rendering
- **2.5D game** (isometric/top-down perspective)
- **3D only for skill effects** (spells, particles)
- ❌ **DO NOT use Colyseus or Phaser** (deprecated)

### 6. iOS Builds
- ✅ **LOCAL ONLY** - use `xcodebuild` or `npx expo run:ios`
- ❌ **NEVER use `eas build`** (no EAS Cloud!)

### 7. Cloud Storage
- ✅ Use **MEGA**
- ❌ **NEVER use Google Drive**

## Management Commands

```bash
# Check all bots
~/clawd/scripts/manage-bots.sh status

# Start all bots
~/clawd/scripts/manage-bots.sh start

# Stop all bots
~/clawd/scripts/manage-bots.sh stop

# Restart all bots
~/clawd/scripts/manage-bots.sh restart

# Health check (restart crashed bots)
~/clawd/scripts/manage-bots.sh health

# View specific bot logs
tmux attach -t bot-ez-crm
tmux attach -t bot-aphos
# Detach: Ctrl+B, then D

# Check shitcoin bot
ps aux | grep run_bots
```

## Adding a New Bot

1. Edit `~/clawd/scripts/manage-bots.sh` - add to BOTS array:
   ```bash
   "new-bot|/path/to/workspace"
   ```

2. Edit `~/clawd/scripts/run-persistent-bot.sh` - add case:
   ```bash
   new-bot)
       PROMPT="You are the **NewBot Specialist**..."
       ;;
   ```

3. Start: `~/clawd/scripts/manage-bots.sh start`

## Files

| File | Purpose |
|------|---------|
| `~/clawd/scripts/manage-bots.sh` | Bot manager (start/stop/status) |
| `~/clawd/scripts/run-persistent-bot.sh` | Bot runner with prompts |
| `~/clawd/scripts/startup-bots.sh` | Auto-start on reboot |
| `~/clawd/scripts/browser-lock.sh` | Browser lock system |
| `~/clawd/memory/bot-states/` | Bot state persistence |

## Troubleshooting

### Bot not running
```bash
~/clawd/scripts/manage-bots.sh health
```

### Bot stuck/frozen
```bash
tmux kill-session -t bot-<name>
~/clawd/scripts/run-persistent-bot.sh <name> <workspace>
```

### Port conflict
```bash
lsof -i :<port>
kill <pid>
```

### Gateway issues
```bash
ps aux | grep clawdbot-gateway
clawdbot gateway restart
```
