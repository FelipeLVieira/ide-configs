# Dev Teams - Bot Roles & Model Assignment

Multi-bot architecture with specialized roles per project.

## 🎮 Aphos MMORPG

**Bot Name**: 🎮 Aphos Dev  
**Repo**: `~/repos/aphos`  
**Tech Stack**: Next.js, Three.js, Colyseus, TypeScript

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Game Designer** | Mechanics, balance, systems design. References: Sakaguchi, Koster, Matsuno, Pardo. See [GAME-DESIGN-REFERENCES.md](clawdbot/GAME-DESIGN-REFERENCES.md) | gpt-oss:20b |
| **Backend Dev** | Colyseus servers, game logic | devstral-small-2:24b |
| **Frontend Dev** | Next.js UI, Three.js rendering | gpt-oss:20b |
| **QA Engineer** | Testing, bug reports, playtesting | qwen3:8b |
| **Art Director** | Asset generation prompts, visual style | Claude Sonnet |
| **Sound Engineer** | SFX, music, ambient audio. References: Uematsu, Mitsuda, Kikuta, SoundTeMP. See [GAME-DESIGN-REFERENCES.md](clawdbot/GAME-DESIGN-REFERENCES.md) | gpt-oss:20b |

### Current Focus
- Combat enhancement system (TypeScript TS7053 fixes)
- pm2 server management (prod: 2567, dev: 2568)
- See [aphos-servers.md](aphos-servers.md) for details

---

## 🧠💰 Shitcoin Bot (Trading Research)

**Bot Name**: 🧠💰 Degen Brain  
**Repo**: `~/repos/shitcoin-bot`  
**Tech Stack**: Python, LangChain, Web3  
**Machine**: **MacBook Pro ONLY** (48GB RAM for heavy models)

⚠️ **CRITICAL: Shitcoin team must run on MacBook!**
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

## 🔗 LinkLounge

**Bot Name**: 🔗 LinkLounge Dev  
**Repo**: `~/repos/linklounge`  
**Tech Stack**: Next.js, Supabase, TypeScript

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Designer/Frontend** | UX/UI, landing pages, components | gpt-oss:20b |
| **Backend Dev** | Supabase schema, API routes | gpt-oss:20b |
| **Growth Hacker** | SEO, analytics, virality | qwen3:8b |
| **QA Engineer** | Testing, edge cases | qwen3:8b |

---

## 📇 EZ-CRM

**Bot Name**: 📇 EZ-CRM Dev  
**Repo**: `~/repos/ez-crm`  
**Tech Stack**: Next.js, Supabase, TypeScript

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Backend Dev** | API routes, Supabase schema, auth | devstral-small-2:24b |
| **Frontend Dev** | React components, forms, dashboards | gpt-oss:20b |
| **Product Designer** | UX flows, wireframes, design system | gpt-oss:20b |
| **QA Engineer** | Testing, validation, edge cases | qwen3:8b |

---

## 🎨🔨 Game Asset Tool (Shared Design Studio)

**Bot Name**: 🎨🔨 Asset Forge  
**Repo**: `~/repos/game-asset-tool`  
**Tech Stack**: Python, AI image generation  
**Special**: Serves ALL projects — shared asset pipeline

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Art Director** | Visual style guide, asset reviews | Claude Sonnet |
| **Sprite Artist** | Character sprites, animations | gpt-oss:20b |
| **Icon Designer** | UI icons, item icons, badges | gpt-oss:20b |
| **UI Asset Creator** | Backgrounds, panels, frames | qwen3:8b |
| **Pipeline Engineer** | Asset processing, format conversion | qwen3:8b |

---

## 📊 clawd-monitor (Bot Dashboard)

**Bot Name**: 📊 Monitor Bot  
**Repo**: `~/repos/clawd-monitor`  
**Tech Stack**: React, Express, WebSockets

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Dashboard Dev** | UI components, real-time updates | gpt-oss:20b |
| **DevOps** | Deployment, monitoring setup | qwen3:8b |
| **Analytics** | Metrics, visualizations, alerts | qwen3:8b |

---

## 📱 iOS Apps

All iOS apps built with **React Native (Expo)**. Builds on Mac Mini ONLY.

### ⚖️ BMI Calculator

**Bot Name**: ⚖️ BMI App Dev  
**Repo**: `~/repos/bmi-calculator`

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Mobile Engineer** | Expo app, BMI logic, navigation | gpt-oss:20b |
| **UI Designer** | Health-focused design, animations | qwen3:8b |
| **QA Engineer** | Device testing, edge cases | qwen3:8b |

### 💳 Bills Tracker

**Bot Name**: 💳 Bills Tracker Dev  
**Repo**: `~/repos/bills-tracker`

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Mobile Dev** | Expo app, bill reminders, notifications | gpt-oss:20b |
| **UI Designer** | Finance-focused design, charts | qwen3:8b |
| **Product Designer** | Feature planning, user flows | gpt-oss:20b |
| **QA Engineer** | Testing, data validation | qwen3:8b |

### 🌐 Screen Translator

**Bot Name**: 🌐 Translator Dev  
**Repo**: `~/repos/screen-translator`

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Mobile Dev** | Expo app, camera integration | gpt-oss:20b |
| **ML/Vision Engineer** | OCR, translation API, text detection | devstral-small-2:24b |
| **UI Designer** | Overlay UI, camera preview design | qwen3:8b |
| **QA Engineer** | Multi-language testing, OCR accuracy | qwen3:8b |

---

## 🍎 App Store Manager (Cross-Cutting Cron)

**Type**: Automated cron job (not a bot)
**Machine**: MacBook Pro (main session)
**Schedule**: 3x daily (9 AM, 3 PM, 9 PM EST)
**Model**: gpt-oss:20b (local, FREE)

Monitors **all 3 iOS apps** on App Store Connect:

| App | Bundle ID | Version |
|-----|-----------|---------|
| BMI & Calorie Tracker | `com.felipevieira.bmicalculator` | v2.1.1 |
| Bills Tracker | `com.fullstackdev1.bill-subscriptions-organizer-tracker` | v1.0.6 |
| Offline Image Translator | `com.felipevieira.screentranslate` | v1.0.0 |

**Checks**: Review status, ratings, screenshots, pricing/IAP, builds, policy compliance
**Alerts**: Rejections → Felipe, bad reviews → dev team, expired builds → dev team

📖 See [APP-STORE-MANAGER.md](clawdbot/APP-STORE-MANAGER.md) for full details.

---

## 📋 All Bots Summary

| # | Project | Bot Name | Emoji | Roles | Machine | AGENTS.md | Special |
|---|---------|----------|-------|-------|---------|-----------|---------|
| 1 | Aphos | Aphos Dev | 🎮 | 6 | **Mac Mini** | ✅ | Game studio, persistent session |
| 2 | Shitcoin Bot | Degen Brain | 🧠💰 | 4 | **Mac Mini** | ✅ | Trading intelligence, persistent session |
| 3 | LinkLounge | LinkLounge Dev | 🔗 | 4 | MacBook | ❌ | Web app team |
| 4 | EZ-CRM | EZ-CRM Dev | 📇 | 4 | MacBook | ❌ | CRM team |
| 5 | game-asset-tool | Asset Forge | 🎨🔨 | 5 | MacBook | ❌ | Shared design studio (serves ALL) |
| 6 | clawd-monitor | Monitor Bot | 📊 | 3 | **Mac Mini** | ❌ | DevOps team |
| 7 | BMI Calculator | BMI App Dev | ⚖️ | 3 | MacBook | ❌ | iOS mobile |
| 8 | Bills Tracker | Bills Tracker Dev | 💳 | 4 | MacBook | ❌ | iOS mobile |
| 9 | Screen Translator | Translator Dev | 🌐 | 4 | MacBook | ❌ | iOS mobile + ML |

**Total**: 9 project bots, 37 specialized roles

> **Note**: All 9 projects have `SOUL.md`, `IDENTITY.md`, `USER.md` at repo root. Only Aphos and Shitcoin Bot have `AGENTS.md` — the other 7 projects need it added.

### Machine Assignment

| Machine | Bots | Why |
|---------|------|-----|
| **MacBook Pro** | Orchestrator (main), **Shitcoin Bot**, sub-agent spawner, dev bots | 48GB RAM, primary compute, devstral-24b for heavy models |
| **Mac Mini** | Aphos, clawd-monitor | Always-on, persistent sessions, game servers, **16GB RAM (resource-constrained)** |
| **Windows MSI** | Windows-specific tasks only | No persistent bots, on-demand only |

⚠️ **Note**: Shitcoin Bot moved from Mac Mini → MacBook Pro due to RAM constraints. Mac Mini's 16GB insufficient for heavy trading models.

---

## 🤖 Model Assignment Matrix

**Reasoning-first architecture** — All roles now use models with thinking enabled.

### By Task Complexity

| Complexity | Model | Use Cases |
|------------|-------|-----------|
| **Simple** | qwen3:8b (reasoning=true) | QA, testing, quick fixes, research |
| **Medium** | qwen3:8b (reasoning=true) | Feature dev, refactoring, design |
| **Heavy** | devstral-small-2:24b (MacBook 48GB) | Architecture, backend systems, ML |
| **Creative** | Claude Sonnet 4.5 | Art direction, storytelling |
| **Critical** | Claude Opus 4.5 | Major refactors, security |

### By Role Type

| Role Type | Primary Model | Fallback |
|-----------|---------------|----------|
| **Frontend** | qwen3:8b (reasoning=true) | gpt-oss:20b |
| **Backend** | qwen3:8b (reasoning=true) | devstral-small-2:24b |
| **QA** | qwen3:8b (reasoning=true) | gpt-oss:20b |
| **Design** | Claude Sonnet 4.5 | qwen3:8b |
| **Research** | Grok (free!) | qwen3:8b |
| **Data/ML** | qwen3:8b (reasoning=true) | devstral-small-2:24b |

---

## 🔄 Workflow Patterns

### Research-First Approach

Before using expensive models, check:
1. **Grok (X/Twitter)** — Real-time news, trends
2. **Web search** — Documentation, Stack Overflow
3. **Reddit** — Community opinions, solutions
4. **Then** use local LLM for synthesis

### Sub-Agent Cascade

When spawning sub-agents:
1. **devstral-small-2:24b** (MacBook Ollama, primary for coding)
2. **gpt-oss:20b** (Mac Mini Ollama, always on)
3. **gpt-oss:20b** (MacBook Ollama, fallback)
4. **qwen3:8b** (both machines, fast fallback)
5. **Claude Sonnet** (API, if local fails)
6. **Claude Opus** (critical tasks only)

### Parallel Work

- **Spawn multiple sub-agents** for independent tasks
- **Mac Mini**: 2-3 bots concurrently (16 GB RAM)
- **MacBook**: 1-2 heavy bots (48 GB RAM)
- **Coordinate**: Use clawd-monitor dashboard

---

## 💰 Cost Optimization

### Free Resources (Use First!)
1. **Grok** — X/Twitter AI (Felipe's account)
2. **Web search** — Brave, Google
3. **Local LLMs** — gpt-oss, qwen3, devstral

### Paid APIs (Use Wisely!)
1. **Claude Sonnet** — $3/million tokens input, $15/million output
2. **Claude Opus** — $15/million tokens input, $75/million output

### Savings Achieved
- **90% reduction** in API costs by using local LLMs
- **Research-first** saves $50-100/month
- **Sub-agent batching** reduces redundant calls

---

## 📊 Bot Performance Metrics

Track in `clawd-monitor` dashboard:
- **API calls per bot** (Claude vs Ollama)
- **Token usage** (input/output)
- **Task completion rate**
- **Error rate** (retries, fallbacks)
- **Cost per project**

---

## 🚀 Adding a New Bot

1. Create bot in `~/clawd/scripts/manage-bots.sh`
2. Define roles in this file
3. Assign models based on task complexity
4. Set up project-specific `CLAUDE.md`
5. Configure in `clawd-monitor` dashboard

---

## 📚 References

- [Clawdbot Config](clawdbot-config.md) — Model routing details
- [Ollama Setup](ollama-setup.md) — Local LLM configuration
- [PERSISTENT-BOTS.md](clawdbot/PERSISTENT-BOTS.md) — Bot architecture
