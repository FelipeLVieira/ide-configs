# Dev Teams - Bot Roles & Model Assignment

Multi-bot architecture with specialized roles per project.

## 🎮 Aphos MMORPG

**Bot Name**: 🎮 Aphos Dev  
**Repo**: `~/repos/aphos`  
**Tech Stack**: Next.js, Three.js, Colyseus, TypeScript

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Game Designer** | Mechanics, balance, systems design | gpt-oss:20b |
| **Backend Dev** | Colyseus servers, game logic | devstral-small-2:24b |
| **Frontend Dev** | Next.js UI, Three.js rendering | gpt-oss:20b |
| **QA Engineer** | Testing, bug reports, playtesting | qwen3:8b |
| **Art Director** | Asset generation prompts, visual style | Claude Sonnet |

### Current Focus
- Combat enhancement system (TypeScript TS7053 fixes)
- pm2 server management (prod: 2567, dev: 2568)
- See [aphos-servers.md](aphos-servers.md) for details

---

## 🧠 Shitcoin Bot (Trading Research)

**Bot Name**: 🧠 Degen Brain  
**Repo**: `~/repos/shitcoin-bot`  
**Tech Stack**: Python, LangChain, Web3

### Team Roles

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Research Analyst** | News, trends, sentiment analysis | gpt-oss:20b |
| **Quant Strategist** | Technical analysis, backtesting | devstral-small-2:24b |
| **Risk Manager** | Position sizing, stop losses | gpt-oss:20b |
| **Data Engineer** | API integration, data pipelines | qwen3:8b |

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
| **Product Designer** | UX/UI, landing pages | gpt-oss:20b |
| **Backend Dev** | Supabase schema, API routes | gpt-oss:20b |
| **Growth Hacker** | SEO, analytics, virality | qwen3:8b |
| **QA Engineer** | Testing, edge cases | qwen3:8b |

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
| **Data Analyst** | Metrics, visualizations | qwen3:8b |

---

## 📱 iOS Apps

All iOS apps built with **React Native (Expo)**.

### ⚖️ BMI Calculator

**Bot Name**: ⚖️ BMI Bot  
**Repo**: `~/repos/bmi-calculator`

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Mobile Dev** | Expo app, BMI logic | gpt-oss:20b |
| **UI Designer** | Health-focused design | qwen3:8b |

### 💳 Bills Tracker

**Bot Name**: 💳 Bills Bot  
**Repo**: `~/repos/bills-tracker`

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Mobile Dev** | Expo app, bill reminders | gpt-oss:20b |
| **Backend Dev** | Supabase integration | qwen3:8b |

### 🌐 Screen Translator

**Bot Name**: 🌐 Translator Bot  
**Repo**: `~/repos/screen-translator`

| Role | Responsibilities | Model |
|------|-----------------|-------|
| **Mobile Dev** | Expo app, OCR | gpt-oss:20b |
| **ML Engineer** | Translation API, text detection | qwen3:8b |

---

## 🤖 Model Assignment Matrix

### By Task Complexity

| Complexity | Model | Use Cases |
|------------|-------|-----------|
| **Simple** | qwen3:8b | QA, testing, quick fixes, research |
| **Medium** | gpt-oss:20b | Feature dev, refactoring, design |
| **Heavy** | devstral-small-2:24b | Architecture, backend systems |
| **Creative** | Claude Sonnet | Art direction, storytelling |
| **Critical** | Claude Opus | Major refactors, security |

### By Role Type

| Role Type | Primary Model | Fallback |
|-----------|---------------|----------|
| **Frontend** | gpt-oss:20b | qwen3:8b |
| **Backend** | devstral-small-2:24b | gpt-oss:20b |
| **QA** | qwen3:8b | gpt-oss:20b |
| **Design** | Claude Sonnet | gpt-oss:20b |
| **Research** | gpt-oss:20b | Grok (free!) |
| **Data** | qwen3:8b | gpt-oss:20b |

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
1. **gpt-oss:20b** (Mac Mini, always on)
2. **devstral-small-2:24b** (MacBook, on-demand)
3. **qwen3:8b** (fast fallback)
4. **Claude Sonnet** (API, if local fails)
5. **Claude Opus** (critical tasks only)

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
