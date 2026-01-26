# Persistent Bot Architecture

> Last updated: 2026-01-26

## Overview

Bots run **24/7** as persistent processes on Mac Mini. Each bot is a **SPECIALIST** focused on ONE project only.

## Active Bots (8 Total)

| Bot | Project | Port | Simulator | Tech Stack |
|-----|---------|------|-----------|------------|
| **ez-crm** | ~/repos/ez-crm | 3000-3099 | - | Next.js, Supabase, Legal CRM |
| **linklounge** | ~/repos/linklounge | 3100-3199 | - | Link-in-bio platform |
| **aphos** | ~/repos/aphos | 4000 (web), 2567 (game) | - | **Next.js + Three.js** (2.5D MMORPG) |
| **ios-bmi** | ~/repos/bmi-calculator | 8081 | iPhone 16 Pro | React Native/Expo |
| **ios-bills** | ~/repos/bill-subscriptions-organizer-tracker | 8082 | iPhone 16 Pro Max | React Native/Expo |
| **ios-translator** | ~/repos/simple-screen-translator | 8083 | iPad Air 5th gen | React Native/Expo |
| **clawd-monitor** | ~/repos/clawd-monitor | 9009 | - | Next.js dashboard |
| **shitcoin-bot** | ~/repos/shitcoin-bot | 5000-5099 | - | Python trading bot |

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
│  Shitcoin Trading Bot:                                      │
│  ├── run_bots.py        24/7 Python trading process        │
│  └── Cron Brain         Strategic analysis (every 4 hours) │
│                                                             │
│  Health Check: Every 30 min (cron)                          │
│  Auto-start: @reboot startup-bots.sh                        │
└─────────────────────────────────────────────────────────────┘
```

## Bot Specializations

### ez-crm
- **Focus:** Legal/law firm CRM application
- **Stack:** Next.js 14+, Supabase, Tailwind, shadcn/ui
- **Tasks:** Code review, bug fixes, UX improvements, security

### linklounge
- **Focus:** Linktree competitor / link-in-bio platform
- **Stack:** Web platform with user profiles
- **Tasks:** Features, analytics, social integration

### aphos
- **Focus:** MMORPG game with real Earth map
- **Stack:** Next.js + Three.js (**NOT Colyseus/Phaser!**)
- **Style:** 2.5D isometric (3D only for skill effects)
- **Tasks:** Game mechanics, rendering, multiplayer

### ios-bmi
- **Focus:** BMI & Calorie Tracker iOS app
- **Stack:** React Native / Expo
- **Simulator:** iPhone 16 Pro only
- **Tasks:** Features, ASO, App Store submission

### ios-bills
- **Focus:** Bills & Subscription Tracker iOS app
- **Stack:** React Native / Expo
- **Simulator:** iPhone 16 Pro Max only
- **Tasks:** Features, ASO, App Store submission

### ios-translator
- **Focus:** Screen Translator iOS app
- **Stack:** React Native / Expo
- **Simulator:** iPad Air 5th generation only
- **Tasks:** OCR, translation, App Store submission

### clawd-monitor
- **Focus:** Bot monitoring dashboard
- **Stack:** Next.js, WebSockets
- **Tasks:** Real-time status, data visualization

### shitcoin-bot
- **Focus:** Cryptocurrency trading on Polymarket
- **Stack:** Python (run_bots.py)
- **Process:** 24/7 Python process + Cron brain for strategy
- **Tasks:** Trade execution, position management, research via Grok

## Port Assignments

| Range | Project | Notes |
|-------|---------|-------|
| 2567-2599 | Aphos game servers | 2567=prod, 2568=dev |
| 3000-3099 | EZ-CRM | 3000=default |
| 3100-3199 | LinkLounge | 3100=default |
| 4000-4099 | Aphos web | 4000=default |
| 5000-5099 | Shitcoin Bot | If web interface needed |
| 8081 | BMI Calculator | Expo Metro |
| 8082 | Bills Tracker | Expo Metro |
| 8083 | Screen Translator | Expo Metro |
| 9009 | Clawd Monitor | Dashboard |

## Simulator Assignments

| Bot | Simulator | Notes |
|-----|-----------|-------|
| ios-bmi | iPhone 16 Pro | DO NOT use other simulators |
| ios-bills | iPhone 16 Pro Max | DO NOT use other simulators |
| ios-translator | iPad Air 5th gen | DO NOT use other simulators |

## Critical Rules

### 1. SPECIALIZATION
Each bot works **ONLY** on its assigned project. No cross-project work.

### 2. PORT ISOLATION
Check before starting: `lsof -i :<port>`

### 3. SIMULATOR ISOLATION
iOS bots use ONLY their assigned simulator.

### 4. BROWSER RULES
- ❌ **DO NOT** close the browser entirely
- ✅ Only close excess tabs from YOUR OWN project
- ✅ Use browser lock: `acquire_browser_lock "BotName"`

### 5. iOS Builds
- ✅ **LOCAL ONLY** - use `xcodebuild` or `npx expo run:ios`
- ❌ **NEVER use `eas build`** (no EAS Cloud!)

### 6. Cloud Storage
- ✅ Use **MEGA**
- ❌ **NEVER use Google Drive**

### 7. Research
- ✅ Use **Grok** (x.com/i/grok) to save API credits

## Management Commands

```bash
# Clawdbot bots
~/clawd/scripts/manage-bots.sh status
~/clawd/scripts/manage-bots.sh start
~/clawd/scripts/manage-bots.sh stop
~/clawd/scripts/manage-bots.sh restart
~/clawd/scripts/manage-bots.sh health

# View bot logs
tmux attach -t bot-ez-crm
# Detach: Ctrl+B, then D

# Shitcoin bot
ps aux | grep run_bots
cd ~/repos/shitcoin-bot && python -m src.run_bots
```

## Troubleshooting

### Bot not running
```bash
~/clawd/scripts/manage-bots.sh health
```

### Shitcoin bot not running
```bash
cd ~/repos/shitcoin-bot
nohup python -m src.run_bots &
```

### Port conflict
```bash
lsof -i :<port>
kill <pid>
```
