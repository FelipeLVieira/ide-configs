# Dev Teams - Bot Roles & Model Assignment

Multi-bot architecture with specialized roles per project.

## Aphos MMORPG

**Bot Name**: Aphos Dev
**Repo**: `~/repos/aphos`
**Tech Stack**: Next.js, Three.js, Colyseus, TypeScript

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Game Designer** | Mechanics, balance, systems design. References: Sakaguchi, Koster, Matsuno, Pardo. See [GAME-DESIGN-REFERENCES.md](clawdbot/GAME-DESIGN-REFERENCES.md) | qwen3-coder:30b |
| **Backend Dev** | Colyseus servers, game logic | devstral-small-2:24b |
| **Frontend Dev** | Next.js UI, Three.js rendering | qwen3-coder:30b |
| **QA Engineer** | Testing, bug reports, playtesting | qwen3:8b |
| **Art Director** | Asset generation prompts, visual style | Claude Sonnet |
| **Sound Engineer** | SFX, music, ambient audio. References: Uematsu, Mitsuda, Kikuta, SoundTeMP. See [GAME-DESIGN-REFERENCES.md](clawdbot/GAME-DESIGN-REFERENCES.md) | qwen3-coder:30b |

### Current Focus
- Combat enhancement system (TypeScript TS7053 fixes)
- pm2 server management (prod: 2567, dev: 2568)
- **Aphos crash loop fixed** — EADDRINUSE on port 2567 resolved (stale process cleaned up)
- See [aphos-servers.md](aphos-servers.md) for details

### Project Status (Verified 2026-01-27)
All projects confirmed working:
- ✅ Aphos — pm2 servers stable, crash loop fixed
- ✅ iOS apps (3) — BMI Calculator, Bills Tracker, Screen Translator
- ✅ ez-crm — Next.js + Supabase
- ✅ LinkLounge — Next.js + Supabase

---

## Shitcoin Bot (Trading Research)

**Bot Name**: Degen Brain
**Repo**: `~/repos/shitcoin-bot`
**Tech Stack**: Python, LangChain, Web3
**Machine**: **MacBook Pro ONLY** (48GB RAM for heavy models)

WARNING: **CRITICAL: Shitcoin team must run on MacBook!**
- Mac Mini has only 16GB RAM — insufficient for simultaneous heavy models
- MacBook has 48GB RAM — can run devstral-24b + qwen3:8b concurrently
- Trading analysis needs heavy compute

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Research Analyst** | News, trends, sentiment analysis | qwen3:8b (reasoning=true) |
| **Quant Strategist** | Technical analysis, backtesting | devstral-small-2:24b (MacBook 48GB) |
| **Risk Manager** | Position sizing, stop losses | qwen3:8b (reasoning=true) |
| **Data Engineer** | API integration, data pipelines | qwen3:8b (reasoning=true) |

### Tools & APIs
- **LunarCrush** — Social sentiment, Galaxy Score
- **DeFiLlama** — TVL, protocol data
- **CoinGlass** — Liquidation data, funding rates
- **Santiment** — On-chain metrics
- **Grok (X/Twitter)** — Real-time crypto news

---

## LinkLounge

**Bot Name**: LinkLounge Dev
**Repo**: `~/repos/linklounge`
**Tech Stack**: Next.js, Supabase, TypeScript

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Designer/Frontend** | UX/UI, landing pages, components | qwen3-coder:30b |
| **Backend Dev** | Supabase schema, API routes | qwen3-coder:30b |
| **Growth Hacker** | SEO, analytics, virality | qwen3:8b |
| **QA Engineer** | Testing, edge cases | qwen3:8b |

---

## EZ-CRM

**Bot Name**: EZ-CRM Dev
**Repo**: `~/repos/ez-crm`
**Tech Stack**: Next.js, Supabase, TypeScript

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Backend Dev** | API routes, Supabase schema, auth | devstral-small-2:24b |
| **Frontend Dev** | React components, forms, dashboards | qwen3-coder:30b |
| **Product Designer** | UX flows, wireframes, design system | qwen3-coder:30b |
| **QA Engineer** | Testing, validation, edge cases | qwen3:8b |

---

## Game Asset Tool (Shared Design Studio)

**Bot Name**: Asset Forge
**Repo**: `~/repos/game-asset-tool`
**Tech Stack**: Python, AI image generation
**Special**: Serves ALL projects — shared asset pipeline

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Art Director** | Visual style guide, asset reviews | Claude Sonnet |
| **Sprite Artist** | Character sprites, animations | qwen3-coder:30b |
| **Icon Designer** | UI icons, item icons, badges | qwen3-coder:30b |
| **UI Asset Creator** | Backgrounds, panels, frames | qwen3:8b |
| **Pipeline Engineer** | Asset processing, format conversion | qwen3:8b |

---

## clawd-monitor (Bot Dashboard)

**Bot Name**: Monitor Bot
**Repo**: `~/repos/clawd-monitor`
**Tech Stack**: React, Express, WebSockets

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Dashboard Dev** | UI components, real-time updates | qwen3-coder:30b |
| **DevOps** | Deployment, monitoring setup | qwen3:8b |
| **Analytics** | Metrics, visualizations, alerts | qwen3:8b |

---

## iOS Apps

All iOS apps built with **React Native (Expo)**. Builds on Mac Mini ONLY.

### BMI Calculator

**Bot Name**: BMI App Dev
**Repo**: `~/repos/bmi-calculator`

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Mobile Engineer** | Expo app, BMI logic, navigation | qwen3-coder:30b |
| **UI Designer** | Health-focused design, animations | qwen3:8b |
| **QA Engineer** | Device testing, edge cases | qwen3:8b |

### Bills Tracker

**Bot Name**: Bills Tracker Dev
**Repo**: `~/repos/bills-tracker`

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Mobile Dev** | Expo app, bill reminders, notifications | qwen3-coder:30b |
| **UI Designer** | Finance-focused design, charts | qwen3:8b |
| **Product Designer** | Feature planning, user flows | qwen3-coder:30b |
| **QA Engineer** | Testing, data validation | qwen3:8b |

### Screen Translator

**Bot Name**: Translator Dev
**Repo**: `~/repos/screen-translator`

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Mobile Dev** | Expo app, camera integration | qwen3-coder:30b |
| **ML/Vision Engineer** | OCR, translation API, text detection | devstral-small-2:24b |
| **UI Designer** | Overlay UI, camera preview design | qwen3:8b |
| **QA Engineer** | Multi-language testing, OCR accuracy | qwen3:8b |

---

## App Store Manager (Cross-Cutting Cron)

**Type**: Automated cron job (not a bot)
**Machine**: MacBook Pro (main session)
**Schedule**: 3x daily (9 AM, 3 PM, 9 PM EST)
**Model**: qwen3-coder:30b (local, FREE)

Monitors **all 3 iOS apps** on App Store Connect:

| App | Bundle ID | Version |
|-----|-----------|---------|
| BMI & Calorie Tracker | `com.felipevieira.bmicalculator` | v2.1.1 |
| Bills Tracker | `com.fullstackdev1.bill-subscriptions-organizer-tracker` | v1.0.6 |
| Offline Image Translator | `com.felipevieira.screentranslate` | v1.0.0 |

**Checks**: Review status, ratings, screenshots, pricing/IAP, builds, policy compliance
**Alerts**: Rejections -> Felipe, bad reviews -> dev team, expired builds -> dev team

 See [APP-STORE-MANAGER.md](clawdbot/APP-STORE-MANAGER.md) for full details.

---

## All Bots Summary

| # | Project | Bot Name | Emoji | Roles | Machine | AGENTS.md | Special |
|---|---------|----------|-------|-------|---------|-----------|---------|
| 1 | Aphos | Aphos Dev | | 6 | **Mac Mini** | [OK] | Game studio, persistent session |
| 2 | Shitcoin Bot | Degen Brain | | 4 | **Mac Mini** | [OK] | Trading intelligence, persistent session |
| 3 | LinkLounge | LinkLounge Dev | | 4 | MacBook | [NO] | Web app team |
| 4 | EZ-CRM | EZ-CRM Dev | | 4 | MacBook | [NO] | CRM team |
| 5 | game-asset-tool | Asset Forge | | 5 | MacBook | [NO] | Shared design studio (serves ALL) |
| 6 | clawd-monitor | Monitor Bot | | 3 | **Mac Mini** | [NO] | DevOps team |
| 7 | BMI Calculator | BMI App Dev | | 3 | MacBook | [NO] | iOS mobile |
| 8 | Bills Tracker | Bills Tracker Dev | | 4 | MacBook | [NO] | iOS mobile |
| 9 | Screen Translator | Translator Dev | | 4 | MacBook | [NO] | iOS mobile + ML |

**Total**: 9 project bots, 37 specialized roles

> **Note**: All 9 projects have `SOUL.md`, `IDENTITY.md`, `USER.md` at repo root. Only Aphos and Shitcoin Bot have `AGENTS.md` — the other 7 projects need it added.

### Machine Assignment

| Machine | Bots | Why |
|---------|------|-----|
| **MacBook Pro** | Orchestrator (main), sub-agent spawner | 48GB RAM, primary compute, devstral-24b |
| **Mac Mini** | Aphos, clawd-monitor, iOS bots, trading bot (Python) | Always-on, persistent sessions, game servers, **16GB RAM** |
| **Windows MSI** | Windows-specific tasks only | No persistent bots, on-demand only |

### Mac Mini Cron Jobs Fixed (2026-01-27)
All Mac Mini cron jobs updated from deprecated `qwen2.5-coder` to `qwen3:8b`:
- ✅ Shitcoin Brain (10 min)
- ✅ Shitcoin Quant (15 min)
- ✅ System Health Monitor (30 min)

WARNING: **Mac Mini RAM constraints**: Only qwen3:8b (5GB) and phi4:14b (9GB) are safe for auto-loading on Mac Mini (16GB RAM).

---

## Model Assignment Matrix

**Reasoning-first architecture** — All roles now use models with thinking enabled.

### By Task Complexity

| Complexity | Model | Use Cases |
|------------|-------|-----------|
| **Simple** | qwen3:8b (reasoning=true, both Macs) | QA, testing, quick fixes, research |
| **Medium** | qwen3:8b (reasoning=true) | Feature dev, refactoring, design |
| **Heavy** | devstral-small-2:24b (MacBook 48GB ONLY) | Architecture, backend systems, ML |
| **General** | qwen3-coder:30b (MacBook 48GB ONLY) | Complex tasks needing bigger model |
| **Creative** | Claude Sonnet 4.5 | Art direction, storytelling |
| **Critical** | Claude Opus 4.5 | Major refactors, security |

> WARNING: qwen3-coder:30b, devstral-24b, and gemma3:12b are MacBook-only models. Mac Mini (16GB) can only safely auto-load qwen3:8b and phi4:14b.

### By Role Type

| Role Type | Primary Model | Fallback |
|-----------|---------------|----------|
| **Frontend** | qwen3:8b (reasoning=true) | qwen3-coder:30b |
| **Backend** | qwen3:8b (reasoning=true) | devstral-small-2:24b |
| **QA** | qwen3:8b (reasoning=true) | qwen3-coder:30b |
| **Design** | Claude Sonnet 4.5 | qwen3:8b |
| **Research** | Grok (free!) | qwen3:8b |
| **Data/ML** | qwen3:8b (reasoning=true) | devstral-small-2:24b |

---

## Workflow Patterns

### Research-First Approach

Before using expensive models, check:
1. **Grok (X/Twitter)** — Real-time news, trends
2. **Web search** — Documentation, Stack Overflow
3. **Reddit** — Community opinions, solutions
4. **Then** use local LLM for synthesis

### Sub-Agent Cascade

When spawning sub-agents (reasoning-first, swap-safe):
1. **qwen3-coder:30b** (MacBook primary — 30B params, FREE)
2. **qwen3:8b** (local or cross-machine via Tailscale — reasoning=true, FREE)
3. **devstral-small-2:24b** (MacBook Ollama — heavy coding, 48GB safe)
4. **gemma3:12b** (MacBook Ollama — vision-capable, image input!)
5. **Claude Sonnet 4.5** (API, if all local fail)
6. **Claude Opus 4.5** (critical tasks only)

> NOTE: MacBook-only models (qwen3-coder:30b, devstral-24b, gemma3:12b) require 48GB RAM. Mac Mini (16GB) only auto-loads qwen3:8b and phi4:14b.

### Parallel Work

- **Spawn multiple sub-agents** for independent tasks
- **Mac Mini**: 2-3 bots concurrently (16 GB RAM)
- **MacBook**: 1-2 heavy bots (48 GB RAM)
- **Coordinate**: Use clawd-monitor dashboard

---

## Cost Optimization

### Free Resources (Use First!)
1. **Grok** — X/Twitter AI (Felipe's account)
2. **Web search** — Brave, Google
3. **Local LLMs** — qwen3-coder, devstral, gemma3, qwen3

### Paid APIs (Use Wisely!)
1. **Claude Sonnet** — $3/million tokens input, $15/million output
2. **Claude Opus** — $15/million tokens input, $75/million output

### Savings Achieved
- **90% reduction** in API costs by using local LLMs
- **Research-first** saves $50-100/month
- **Sub-agent batching** reduces redundant calls

---

## Bot Performance Metrics

Track in `clawd-monitor` dashboard:
- **API calls per bot** (Claude vs Ollama)
- **Token usage** (input/output)
- **Task completion rate**
- **Error rate** (retries, fallbacks)
- **Cost per project**

---

## Adding a New Bot

1. Create bot in `~/clawd/scripts/manage-bots.sh`
2. Define roles in this file
3. Assign models based on task complexity
4. Set up project-specific `CLAUDE.md`
5. Configure in `clawd-monitor` dashboard

---

## References

- [Clawdbot Config](clawdbot-config.md) — Model routing details
- [Ollama Setup](ollama-setup.md) — Local LLM configuration
- [PERSISTENT-BOTS.md](clawdbot/PERSISTENT-BOTS.md) — Bot architecture
