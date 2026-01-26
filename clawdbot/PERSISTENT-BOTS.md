# Persistent Bot Architecture

> Last updated: 2026-01-26

## Overview

Bots run **24/7** as persistent processes on Mac Mini. Each bot is a **SPECIALIST** focused on ONE project only.

## Active Bots (9 Total)

| Bot | Project | Port | Simulator | Focus |
|-----|---------|------|-----------|-------|
| **ez-crm** | ~/repos/ez-crm | 3000-3099 | - | Legal CRM (Next.js/Supabase) |
| **linklounge** | ~/repos/linklounge | 3100-3199 | - | Link-in-bio (Linktree competitor) |
| **game-assets** | ~/repos/game-asset-tool | 3200-3299 | - | Asset generation (Aphos + iOS) |
| **aphos** | ~/repos/aphos | 4000, 2567 | - | MMORPG (Next.js + Three.js 2.5D) |
| **ios-bmi** | ~/repos/bmi-calculator | 8081 | iPhone 16 Pro | BMI Calculator app |
| **ios-bills** | ~/repos/bill-subscriptions-organizer-tracker | 8082 | iPhone 16 Pro Max | Bills Tracker app |
| **ios-translator** | ~/repos/simple-screen-translator | 8083 | iPad Air 5th gen | Screen Translator app |
| **clawd-monitor** | ~/repos/clawd-monitor | 9009 | - | Bot monitoring dashboard |
| **shitcoin-bot** | ~/repos/shitcoin-bot | 5000-5099 | - | Crypto trading (Python) |

## Bot Specializations

### ez-crm
- **Focus:** Legal/law firm CRM application
- **Stack:** Next.js 14+, Supabase, Tailwind, shadcn/ui

### linklounge
- **Focus:** Link-in-bio platform (Linktree competitor)
- **Competitors to monitor:**
  - Linktree (linktree.com) - Market leader
  - Beacons (beacons.ai) - Creator monetization
  - Stan Store (stan.store) - E-commerce focused
  - Koji (koji.to) - Interactive mini-apps
  - Shorby (shorby.com) - Multiple links per platform
  - Lnk.Bio (lnk.bio) - Simple and free
  - Tap.bio (tap.bio) - Card-style layout
  - Campsite.bio (campsite.bio) - Clean design
  - Milkshake (milkshake.app) - Mobile-first
  - bio.fm - Music artist focused
  - Carrd (carrd.co) - One-page sites
  - Later Linkin.bio - Instagram combo
  - Hoobe/Hobee - Social commerce
  - Snipfeed - Creator monetization
  - Komi - Premium features
  - Many.link - Simple alternative

### game-assets
- **Focus:** Visual asset generation tool
- **Serves:**
  - Aphos game (sprites, tiles, effects, UI)
  - iOS apps (icons, screenshots, promo images)
  - Any other image generation needs
- **Output:** ~/repos/shared-assets

### aphos
- **Focus:** MMORPG with real Earth map
- **Stack:** Next.js + Three.js (NOT Colyseus/Phaser!)
- **Style:** 2.5D isometric (3D only for skill effects)

### ios-bmi / ios-bills / ios-translator
- **Focus:** Individual iOS apps (one bot per app)
- **Stack:** React Native / Expo
- **Builds:** LOCAL ONLY (xcodebuild), NO EAS Cloud
- **Assets:** Request from game-assets bot

### clawd-monitor
- **Focus:** Bot monitoring dashboard
- **Stack:** Next.js, WebSockets

### shitcoin-bot
- **Focus:** Crypto trading on Polymarket
- **Stack:** Python (run_bots.py)
- **Process:** 24/7 Python + cron brain for strategy

## Port Assignments

| Range | Project |
|-------|---------|
| 2567-2599 | Aphos game servers |
| 3000-3099 | EZ-CRM |
| 3100-3199 | LinkLounge |
| 3200-3299 | Game Assets Tool |
| 4000-4099 | Aphos web |
| 5000-5099 | Shitcoin Bot |
| 8081 | BMI Calculator (Expo) |
| 8082 | Bills Tracker (Expo) |
| 8083 | Screen Translator (Expo) |
| 9009 | Clawd Monitor |

## Simulator Assignments

| Bot | Simulator |
|-----|-----------|
| ios-bmi | iPhone 16 Pro |
| ios-bills | iPhone 16 Pro Max |
| ios-translator | iPad Air 5th generation |

## Critical Rules

1. **SPECIALIZATION** - Each bot works ONLY on its assigned project
2. **PORT ISOLATION** - Use assigned ports only
3. **SIMULATOR ISOLATION** - iOS bots use assigned simulator only
4. **BROWSER** - Do not close entirely, only excess tabs from own project
5. **iOS Builds** - LOCAL ONLY, NO EAS Cloud
6. **Storage** - MEGA only, NO Google Drive
7. **Research** - Use Grok (x.com/i/grok)

## Management

```bash
~/clawd/scripts/manage-bots.sh status
~/clawd/scripts/manage-bots.sh restart
tmux attach -t bot-<name>
```
