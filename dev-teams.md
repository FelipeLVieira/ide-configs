# Dev Teams - Bot Roles & Model Assignment

Multi-bot architecture with specialized roles per project.

> **Last updated**: 2026-01-28 (late night) — Anthropic-only routing, all cron on Sonnet 4.5, new dev bots (EZ-CRM, LinkLounge, iOS)

> **⚠️ CRITICAL:** ALL local Ollama models FAIL at tool-calling. ALL bots/cron/sub-agents use `anthropic/claude-sonnet-4-5` (or Opus 4.5 fallback). Local models are for manual interactive use ONLY. See [model-routing.md](model-routing.md).

---

## Active Cron Bots (All on MacBook Orchestrator)

All bots run as hourly cron jobs with `deliver=false` (reports to clawd-status API).

| Bot | Schedule | Model | Tools | Repo |
|-----|----------|-------|-------|------|
| **Cleaner Bot** | `:00` hourly | Sonnet 4.5 | exec, SSH | — |
| **Healer Team** | `:00` hourly | Sonnet 4.5 | exec, SSH, curl | — |
| **EZ-CRM Dev Bot** | `:05` hourly | Sonnet 4.5 | exec, browser | `~/repos/ez-crm` |
| **LinkLounge Dev Bot** | `:10` hourly | Sonnet 4.5 | exec, browser | `~/repos/linklounge` |
| **iOS App Dev Bot** | `:15` hourly | Sonnet 4.5 | exec, SSH | `~/repos/bmi-calculator`, `bills-tracker`, `screen-translator` |
| **R&D Research** | Every 6h | Sonnet 4.5 | browser, web_fetch | — |
| **App Store Manager** | 3x/day | Sonnet 4.5 | exec, web_fetch, browser | — |

See [cron-schedule.md](cron-schedule.md) for full schedule details.

---

## Aphos MMORPG

**Bot Name**: Aphos Dev
**Repo**: `~/repos/aphos`
**Tech Stack**: Next.js, Three.js, WebSocket (raw ws), TypeScript
**Servers**: PM2 on Mac Mini (prod: 2567, dev: 2568)

### Recent Changes
- JWT auth implemented (game token exchange via Supabase)
- Rate limiting: 100 req/15min API, 20 req/15min auth, 10 WS conn/min per IP
- CORS locked: localhost:4000/4001/3000 + aphos.gg
- WebSocket auth: noServer mode, JWT verified before handshake
- **No Colyseus** — server uses raw `ws` library

---

## EZ-CRM

**Bot Name**: EZ-CRM Dev
**Repo**: `~/repos/ez-crm`
**Tech Stack**: Next.js, Supabase, TypeScript
**Cron**: `:05` hourly (autonomous dev cycle)

### Recent Changes
- 7 critical security issues fixed (crypto-secure OTP, audit verified)
- Autonomous dev bot runs hourly: git status → build → browser test → fix → push

---

## LinkLounge

**Bot Name**: LinkLounge Dev
**Repo**: `~/repos/linklounge`
**Tech Stack**: Next.js, Supabase, TypeScript
**Cron**: `:10` hourly (autonomous dev cycle)

---

## iOS Apps

All iOS apps built with **React Native (Expo)**. Builds on Mac Mini ONLY.

**Bot Name**: iOS App Dev Bot
**Cron**: `:15` hourly

### BMI Calculator
- **Repo**: `~/repos/bmi-calculator`
- **Bundle ID**: `com.felipevieira.bmicalculator`

### Bills Tracker
- **Repo**: `~/repos/bills-tracker`
- **Bundle ID**: `com.fullstackdev1.bill-subscriptions-organizer-tracker`

### Screen Translator
- **Repo**: `~/repos/screen-translator`
- **Bundle ID**: `com.felipevieira.screentranslate`

**Simulator rules:**
- ONE simulator at a time (Mac Mini has only 16GB)
- Always `xcrun simctl shutdown all` after testing
- Cleaner Bot auto-kills if >20 sim processes detected

---

## Shitcoin Bot (Trading Research)

**Bot Name**: Degen Brain
**Repo**: `~/repos/shitcoin-bot`
**Tech Stack**: Python, LangChain, Web3
**Machine**: Mac Mini (Python trading bot on port 8080)

### Research Queue
- RN1 (@renzosalpha): $1k→$4M, 400K% growth, 0 losing days
- @carverfomo / @distinct-baguette: $452K profit, 27K trades, 65% win rate

---

## Monitoring & Infrastructure

### Crabwalk (Bot Dashboard)
**Repo**: `~/repos/crabwalk` (MacBook) / `~/repos/clawd-monitor` (Mac Mini)
**Port**: 9009
**Features**: Session monitor, action graph, session grouping, heartbeat modal

### clawd-status (Status Dashboard)
**Repo**: `github.com/FelipeLVieira/clawd-status`
**Port**: 9010 (MacBook)
**Features**: Services tab, cron jobs tab, log viewer, overdue detection, health checks

---

## App Store Manager (Cross-Cutting Cron)

**Schedule**: 3x daily (9 AM, 3 PM, 9 PM EST)
**Model**: Sonnet 4.5

Monitors all 3 iOS apps on App Store Connect:
- Review status, ratings, screenshots, pricing/IAP, builds, policy compliance
- Rejections → Felipe, bad reviews → dev team, expired builds → dev team

See [APP-STORE-MANAGER.md](clawdbot/APP-STORE-MANAGER.md) for full details.

---

## Model Assignment (Jan 28, 2026)

### Anthropic-Only Architecture

ALL agentic work uses Anthropic models:

| Context | Model | Notes |
|---------|-------|-------|
| Felipe's main chat | Opus 4.5 | Frontier reasoning |
| ALL cron jobs | Sonnet 4.5 | Hourly, staggered |
| ALL sub-agents | Sonnet 4.5 → Opus 4.5 | Anthropic-only fallback |
| Heartbeat | Sonnet 4.5 | 60min interval |
| Windows Telegram | Sonnet 4.5 | Minimal config |

### Local Models (Manual Only — NOT in routing)
| Machine | Models | Use |
|---------|--------|-----|
| MacBook | mistral-small3.2, gemma3:12b | Interactive text/vision queries |
| Mac Mini | phi4-mini, phi4:14b | Quick text responses |

> ⚠️ **ALL local Ollama models FAIL at tool-calling** (7/7 tested, all failed). See [model-routing.md](model-routing.md).

---

## Machine Assignment

| Machine | Role | Notes |
|---------|------|-------|
| **MacBook Pro** | Orchestrator — runs ALL cron, heartbeat, sub-agents | 48GB RAM, primary compute |
| **Mac Mini** | Always-on NODE — game servers, iOS builds, PM2 | 16GB RAM, connected to MacBook |
| **Windows MSI** | Telegram chat only | No cron, no heartbeat, separate bot token |

---

## References

- [Clawdbot Config](clawdbot-config.md) — Model routing details
- [Model Routing](model-routing.md) — Detailed routing documentation
- [Cron Schedule](cron-schedule.md) — All cron jobs and schedules
- [Ollama Setup](ollama-setup.md) — Local LLM configuration
