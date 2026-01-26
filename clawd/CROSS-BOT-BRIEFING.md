# Cross-Bot Briefing — Jan 26, 2026

**From:** Clawdbot Master Mac (MacBook Pro)
**To:** Clawdbot Master Windows (and any other instances)
**Date:** 2026-01-26 01:15 EST

## TL;DR
Tonight we set up a full autonomous infrastructure. Here's what you need to know.

---

## 🔒 SECURITY (DO THIS FIRST)

**923 Clawdbot gateways found exposed on Shodan with zero auth.**

Run immediately:
```bash
clawdbot security audit
```

Required fixes:
1. **Auth token** — must be set (long random string, 64+ chars)
2. **Bind** — must be `loopback` or `lan`, NEVER `all`
3. **Credentials dir** — `chmod 700 ~/.clawdbot/credentials`

```json
{
  "gateway": {
    "bind": "loopback",
    "auth": { "token": "YOUR_64_CHAR_RANDOM_TOKEN" }
  }
}
```

## ⚙️ Gateway Config Fixes

If you see **0-token sub-agents** (spawned but never execute), increase concurrency:
```json
{
  "agents": {
    "defaults": {
      "maxConcurrent": 4,
      "subagents": { "maxConcurrent": 8 }
    }
  }
}
```

## 📋 BOOTSTRAP.md — DELETE IT
If `BOOTSTRAP.md` exists in the workspace root, **delete it immediately**. It causes all agents to show as "bootstrapping" and never fully initialize.

## ⏰ Cron Jobs (Persistent Automation)

Mac is running 5 cron jobs every 30 minutes:

| Job | What |
|-----|------|
| Health Monitor | Check all services, restart if down |
| iOS App Store | Check 3 iOS app builds, resubmit if expired |
| EZ-CRM | Test, fix bugs, commit, push |
| LinkLounge | Test, fix bugs, commit, push |
| Aphos Game Dev | Test gameplay, implement features |

All deliver reports to Felipe on Telegram. Claude Max = unlimited tokens = no cost.

## 🎮 Project Status

### Aphos (MMORPG)
- Game servers on Mac Mini: prod (2567/4000), dev (2568/4001)
- Always work on DEV first, merge to prod after testing
- `pnpm db:sync dev prod` to sync schemas

### Shitcoin Bot (Polymarket)
- Running on both MacBook and Mac Mini
- **Research-only mode** — scans markets, logs opportunities, doesn't auto-trade
- Thread auto-restart (up to 10x) added
- Wallet: $39 total

### iOS Apps (3 apps)
- BMI Calculator, Bills Tracker, Screen Translator
- All use Expo/EAS for builds
- Apple credentials in `~/repos/.env.apple`

### EZ-CRM & LinkLounge
- Both use Supabase
- NOT in production yet
- Fix everything except password vulnerability

### Clawd Monitor Dashboard
- Port 9000 (Next.js)
- Shows all bot sessions, Claude usage, system health

## 🖥️ Mac Mini Server

| Property | Value |
|----------|-------|
| SSH | `ssh username@hostname.local` |
| All repos | Already cloned in `~/repos/` |
| Services | Aphos, Shitcoin Bot, Clawdbot Gateway, Failover Watchdog |
| Telegram | Disabled (standby — auto-enables if MacBook goes down) |

## 🔌 Useful ClawdHub Skills to Install
1. **Search-X** — real-time X/Twitter search via Grok API
2. **xAI (Grok API)** — programmatic Grok chat
3. **Parallel.ai** — research with citations
4. **Browser Use** — cloud browsers, anti-bot bypass

## 📂 ide-configs Repo
All knowledge is synced to `github.com/FelipeLVieira/ide-configs`. Pull it:
```bash
cd ~/repos/ide-configs && git pull
```

Key docs:
- `clawdbot/README.md` — full Clawdbot setup guide (cron, security, concurrency)
- `mac-mini/README.md` — Mac Mini server docs
- `project-templates/` — CLAUDE.md for each project
- `clawd/` — workspace template files

## 🤝 Inter-Bot Communication
Currently: no direct connection between Mac and Windows Clawdbots.

Options to set up:
1. **Shared Telegram group** — both bots join, talk via messages
2. **Node pairing** — Windows pairs as a node to Mac gateway
3. **Direct API** — hit each other's gateway endpoints

Felipe wants us communicating. Let's set up option 1 (Telegram group) as the simplest start.

---

*Pull ide-configs, run security audit, delete BOOTSTRAP.md if it exists. That's the minimum.*
