# Persistent Bot Architecture

## Overview

Bots run 24/7 as persistent tmux sessions. Each bot is a **SPECIALIST** focused on ONE project only.

## Specialist Bots (7 Total)

| Bot | Project | Port | Simulator |
|-----|---------|------|-----------|
| **ez-crm** | ~/repos/ez-crm | 3000-3099 | - |
| **linklounge** | ~/repos/linklounge | 3100-3199 | - |
| **aphos** | ~/repos/aphos | 4000 (web), 2567 (game) | - |
| **ios-bmi** | ~/repos/bmi-calculator | 8081 | iPhone 16 Pro |
| **ios-bills** | ~/repos/bill-subscriptions-organizer-tracker | 8082 | iPhone 16 Pro Max |
| **ios-translator** | ~/repos/simple-screen-translator | 8083 | iPad Air 5th gen |
| **clawd-monitor** | ~/repos/clawd-monitor | 9009 | - |

## Key Rules

### 1. SPECIALIZATION
Each bot works ONLY on its assigned project.

### 2. PORT ISOLATION
Each bot has assigned ports. Check before starting: `lsof -i :<port>`

### 3. SIMULATOR ISOLATION (iOS bots)
Each iOS bot uses ONLY its assigned simulator:
- ios-bmi → iPhone 16 Pro
- ios-bills → iPhone 16 Pro Max  
- ios-translator → iPad Air 5th generation

### 4. BROWSER RULES
- **DO NOT close the browser entirely!**
- Only close excess tabs FROM YOUR OWN PROJECT
- Use browser lock before accessing

### 5. Aphos Tech Stack
- **Next.js + Three.js** (NOT Colyseus/Phaser!)
- **2.5D game** (isometric/top-down)
- **3D only for skill effects**

### 6. iOS Builds
- **LOCAL ONLY** - use xcodebuild
- **NEVER use eas build**

## Management Commands

```bash
# Check all bots
~/clawd/scripts/manage-bots.sh status

# Start/Stop/Restart
~/clawd/scripts/manage-bots.sh start
~/clawd/scripts/manage-bots.sh stop
~/clawd/scripts/manage-bots.sh restart

# Health check (restart crashed bots)
~/clawd/scripts/manage-bots.sh health

# View specific bot logs
tmux attach -t bot-aphos
# Detach: Ctrl+B, then D
```

## Port Reference

| Range | Project | Notes |
|-------|---------|-------|
| 2567-2599 | Aphos game servers | 2567=prod, 2568=dev |
| 3000-3099 | EZ-CRM | 3000=default |
| 3100-3199 | LinkLounge | 3100=default |
| 4000-4099 | Aphos web | 4000=default |
| 8081 | BMI Calculator | Expo Metro |
| 8082 | Bills Tracker | Expo Metro |
| 8083 | Screen Translator | Expo Metro |
| 9009 | Clawd Monitor | Dashboard |
