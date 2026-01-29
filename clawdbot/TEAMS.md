# Clawdbot Teams — Bot Agents & Cron Jobs

**Last Updated:** 2026-01-29  
**Documentation Owner:** Docs Team (Subagent)

---

## Overview

Clawdbot runs 10 specialized bot agents on cron schedules. Each bot is a domain expert that reads its backlog, picks the top priority task, works on it, updates the backlog, and reports status.

**All cron jobs run on MacBook Pro** (48GB RAM) to keep Mac Mini (16GB) lean for services.

**All cron jobs use Claude Sonnet 4.5** (paid) — local Ollama models can't do agentic tool-calling.

---

## Team Roster

| # | Team | Schedule | Model | Backlog File |
|---|------|----------|-------|--------------|
| 1 | 🧹 Cleaner Bot | `0 */2 * * *` (every 2h) | Sonnet 4.5 | `backlogs/cleaner.md` |
| 2 | 🏥 Healer Team | `0 */2 * * *` (every 2h) | Sonnet 4.5 | `backlogs/healer.md` |
| 3 | 📱 App Store Manager | `0 9,15,21 * * *` (3x/day) | Sonnet 4.5 | `backlogs/appstore.md` |
| 4 | 🔬 R&D AI Research | `0 */6 * * *` (every 6h) | Sonnet 4.5 | Memory files only |
| 5 | 📱 iOS App Dev Bot | `15 */2 * * *` (every 2h, :15) | Sonnet 4.5 | `backlogs/ios-apps.md` |
| 6 | 🔗 LinkLounge Dev Bot | `10 */2 * * *` (every 2h, :10) | Sonnet 4.5 | `backlogs/linklounge.md` |
| 7 | 📋 EZ-CRM Dev Bot | `5 */2 * * *` (every 2h, :05) | Sonnet 4.5 | `backlogs/ez-crm.md` |
| 8 | 🧠 Shitcoin Brain | `20 * * * *` (every hour, :20) | Sonnet 4.5 | `backlogs/shitcoin-brain.md` |
| 9 | 📊 Shitcoin Quant | `25 * * * *` (every hour, :25) | Sonnet 4.5 | `backlogs/shitcoin-quant.md` |
| 10 | 🗑️ Session Cleanup | `0 0 * * 0` (weekly, Sunday) | Ollama mistral-small3.2 | N/A (system task) |

---

## Team Details

### 1. 🧹 Cleaner Bot

**Purpose:** Cleans simulators, zombies, stale processes, temp files on both MacBook + Mac Mini

**Schedule:** `0 */2 * * *` (every 2 hours, on the hour)

**Model:** Claude Sonnet 4.5

**Backlog:** `backlogs/cleaner.md`

**Tasks:**
1. **Simulator check:** SSH to Mac Mini, if >20 CoreSimulator processes → `xcrun simctl shutdown all`
2. **Orphans:** Kill shell-snapshots/SSH with PPID=1 older than 2h (both machines)
3. **Zombies:** Kill zombie processes
4. **Duplicates:** Check for duplicate processes on same ports
5. **Disk:** Warn if >80% on either machine
6. **Services:** Health-check Crabwalk (9009), Aphos (2567), clawd-status (9010)

**Protected Services (DO NOT KILL):**
- Crabwalk (9009, LaunchAgent)
- Aphos (2567-2599, PM2)
- clawd-status (9010)

**Reporting:**
- Posts to clawd-status API (`http://localhost:9010/api/log`)
- Only sends to Telegram if >10 orphans killed or service dead

**Recent Wins (Jan 29, 2026):**
- 💰 **Repo log rotation** — Created rotate-logs.sh utility, cleaned shitcoin-bot logs (30MB → 13MB)
- 💰 **Playwright cache cleanup** — Recovered 2.3GB disk space
- 💰 **Duplicate Ollama killed** — Saved 62MB RAM
- Cleans 4-6 zombie processes per run

---

### 2. 🏥 Healer Team

**Purpose:** SRE/DevOps team for diagnostics, analysis, fix, and verify

**Schedule:** `0 */2 * * *` (every 2 hours, on the hour)

**Model:** Claude Sonnet 4.5

**Backlog:** `backlogs/healer.md`

**Tasks:**
1. **Diagnostics (always run):**
   - MacBook Pro: check swap usage, disk, Ollama, Crabwalk
   - Mac Mini: check swap, disk, PM2 services (Aphos, Ollama)
   - Cross-machine: verify Ollama remote access (MacBook → Mac Mini)

2. **Classify & Fix:**
   - **OK/INFO:** Log only
   - **WARNING:** Mac Mini swap >8GB, MacBook swap >16GB, disk >80%
   - **CRITICAL:** Swap >12GB (Mini) or >16GB (MacBook), disk >90%, service dead

3. **Auto-Recovery:**
   - Max 2 service restarts per run
   - Never delete data
   - Document all interventions

**Reporting:**
- Posts to clawd-status API
- CRITICAL only → also Telegram alert

**Rules:**
- Batch SSH commands to reduce overhead
- Always read backlog first, then run diagnostics

---

### 3. 📱 App Store Manager

**Purpose:** Monitors App Store Connect for reviews, status, screenshots, pricing, policies

**Schedule:** `0 9,15,21 * * *` (3 times per day: 9am, 3pm, 9pm)

**Model:** Claude Sonnet 4.5

**Backlog:** `backlogs/appstore.md`

**Apps Managed:**
1. **BMI & Calorie Tracker** — com.felipevieira.bmicalculator (v2.1.1, ASC ID: 6756639140)
2. **Bills Tracker** — com.fullstackdev1.bill-subscriptions-organizer-tracker (v1.0.6)
3. **Screen Translator** — com.felipevieira.screentranslate (v1.0.0, ASC ID: 6740551796)

**Tasks:**
- Check app status (live? pending review? removed?)
- Scan for new reviews — summarize negative ones, draft responses
- Verify privacy labels are current
- Check screenshot compliance
- Review pricing/IAP configuration
- Research latest App Store Review Guidelines changes
- Competitor analysis

**Credentials:**
- Apple ID: felipe.lv.90@gmail.com | Team: 824F44HKCD
- API Keys: `~/.private_keys/AuthKey_HFT29Q659H.p8` + `AuthKey_5XKJ7PVQ9K.p8`

**Reporting:**
- Posts to clawd-status API
- CRITICAL (rejection, policy violation) → also Telegram alert

**Critical Issues (Jan 28, 2026):**
- P0: All 3 apps returning 404 on App Store URLs — status unknown
- P0: API auth issues (Issuer ID verification needed)

---

### 4. 🔬 R&D AI Research

**Purpose:** Monitor AI/ML developments, discover new tools, track breakthroughs

**Schedule:** `0 */6 * * *` (every 6 hours)

**Model:** Claude Sonnet 4.5

**Backlog:** Memory files only (`memory/rd-findings.md`)

**Research Focus:**
- New Ollama models
- Clawdbot/Moltbot updates
- Local LLM breakthroughs (Apple Silicon)
- AI agent frameworks and techniques
- X/Twitter trends (#AIAgents, #LocalLLM, #Ollama, #AppleSilicon)
- Reddit deep dive (r/LocalLLaMA, r/MachineLearning, r/ollama)

**Research Tools:**
1. **browser** (headless, profile=clawd) — PRIMARY research tool
   - Google search: `https://www.google.com/search?q=YOUR+QUERY`
   - Brave search: `https://search.brave.com/search?q=YOUR+QUERY`
   - Grok: navigate to x.com/i/grok, type question, read answer
   - ALWAYS CLOSE TABS after reading!
2. **web_fetch** — grab article content from URLs found via browser

**Grok Integration:**
- Ask Grok for analysis: "What are the most impactful AI developments in the last 24h for local LLMs on Apple Silicon?"
- Uses Grok queue system (`./utils/with-grok.sh`) — FREE, saves Claude credits

**Reporting:**
- Appends to: `/Users/felipevieira/clawd/memory/rd-findings.md`
- Posts to clawd-status API
- ONLY reports to main session for game-changers
- If any tools were broken, ALWAYS reports that

**Quality Standard:** Report game-changers and broken tooling only, not noise.

---

### 5. 📱 iOS App Dev Bot

**Purpose:** Develops, tests, and maintains all 3 iOS apps on Mac Mini

**Schedule:** `15 */2 * * *` (every 2 hours, at :15 minutes)

**Model:** Claude Sonnet 4.5

**Backlog:** `backlogs/ios-apps.md`

**Apps:**
1. **BMI & Calorie Tracker** — `~/repos/bmi-calculator` (v2.1.1)
2. **Bills Tracker** — `~/repos/bill-subscriptions-organizer-tracker` (v1.0.6)
3. **Screen Translator** — `~/repos/simple-screen-translator` (v1.0.0)

**Tasks:**
- Access Mac Mini: `exec('ssh felipemacmini@felipes-mac-mini.local "<command>"')`
- Build ONE app at a time (16GB memory constraint)
- Run tests, check deps, fix bugs
- Commit fixes, push to GitHub
- **ALWAYS shutdown simulators:** `xcrun simctl shutdown all`

**Critical Rules:**
- Do NOT submit to App Store without approval
- ALWAYS clean simulators after builds
- All iOS work happens on Mac Mini (NOT MacBook)
- Build locally with Xcode (NOT EAS Cloud)

**Reporting:**
- Posts to clawd-status API
- Does NOT send to Telegram (deliver is disabled)

**Recent Work (Jan 28, 2026):**
- Fixed rejection issues across all 3 apps
- Updated privacy policies
- Added proper permissions

---

### 6. 🔗 LinkLounge Dev Bot

**Purpose:** Develops and tests LinkLounge (Linktree competitor) with Supabase

**Schedule:** `10 */2 * * *` (every 2 hours, at :10 minutes)

**Model:** Claude Sonnet 4.5

**Backlog:** `backlogs/linklounge.md`

**Repo:** `~/repos/linklounge`

**Port:** 3100

**Tasks:**
- Git status, verify build
- Test Supabase integration
- Use browser to visually test pages (headless)
- Fix bugs, add features
- Commit and push

**Reporting:**
- Posts to clawd-status API
- Does NOT send to Telegram (deliver is disabled)

**Recent Work (Jan 28, 2026):**
- Meta pixel integration
- Analytics setup

---

### 7. 📋 EZ-CRM Dev Bot

**Purpose:** Develops and tests EZ-CRM (personal injury CRM)

**Schedule:** `5 */2 * * *` (every 2 hours, at :05 minutes)

**Model:** Claude Sonnet 4.5

**Backlog:** `backlogs/ez-crm.md`

**Repo:** `~/repos/ez-crm`

**Port:** 3000

**Tasks:**
- Git status, verify build
- Browser test pages (headless)
- Fix bugs found
- Commit and push

**Reporting:**
- Posts to clawd-status API
- Does NOT send to Telegram (deliver is disabled)

**Recent Work (Jan 28, 2026):**
- Onboarding tour implementation
- Data export functionality

---

### 8. 🧠 Shitcoin Brain

**Purpose:** Research, market analysis, strategy review, Polymarket monitoring

**Schedule:** `20 * * * *` (every hour, at :20 minutes)

**Model:** Claude Sonnet 4.5

**Backlog:** `backlogs/shitcoin-brain.md`

**Tasks:**
1. Use browser (headless, profile=clawd) for Polymarket, X/Twitter research
2. Use Grok (x.com/i/grok) for market analysis and trader research — FREE
3. Check research queue: `/Users/felipevieira/clawd/memory/shitcoin-brain/research-queue.md`
4. Monitor whale activity on Polymarket — profitable traders, large positions
5. Scan X for crypto/prediction market signals
6. Write findings to research queue file

**Key Traders to Monitor:**
- **RN1** (@renzosalpha) — $1k→$4M, 400K% growth, 0 losing days
- **@carverfomo / @distinct-baguette** — $452K profit, 27K trades, 65% win rate
- **@w1nklerr** — $5→$3.7M

**Python Bot:**
- Repo: `~/repos/shitcoin-bot` on Mac Mini
- **Status:** DISABLED (Jan 28 — manual trading only, no auto-trade)
- Runs as headless LaunchAgent

**Reporting:**
- Posts to clawd-status API
- Only alerts Felipe on Telegram for CRITICAL opportunities (>90% confidence)

**Rules:**
- Auto-trade is OFF — research and signals ONLY
- High confidence threshold: 80%+ before recommending any trade
- Use Grok for market research (saves Claude credits)
- ALWAYS close browser tabs after research

---

### 9. 📊 Shitcoin Quant

**Purpose:** Portfolio tracking, copy trade analysis, risk management

**Schedule:** `25 * * * *` (every hour, at :25 minutes)

**Model:** Claude Sonnet 4.5

**Backlog:** `backlogs/shitcoin-quant.md`

**Tasks:**
1. Check Python bot status on Mac Mini
2. Analyze portfolio positions, P/L, open trades
3. Use browser (headless, profile=clawd) for Polymarket data — trader profiles, market odds
4. Use Grok for quantitative analysis and backtesting ideas
5. Track copy trade candidates: position sizes, timing, market selection, win rates
6. Calculate risk metrics: drawdowns, exposure, correlation

**Key Traders to Analyze:**
- **RN1** (@renzosalpha) — "The Profit Loophole"
- **@carverfomo / @distinct-baguette** — YES/NO arbitrage specialist
- **@w1nklerr** — Massive returns

**Risk Framework:**
- Max position size: TBD (awaiting Felipe's input)
- Stop-loss triggers: TBD
- Portfolio allocation: TBD
- Confidence threshold: 80%+ for any recommendation

**Reporting:**
- Posts to clawd-status API
- Only alerts Felipe on Telegram for CRITICAL risk events (>10% drawdown, bot crash)

**Rules:**
- Auto-trade is OFF — analysis and recommendations ONLY
- NEVER execute trades or modify bot config without Felipe's approval
- Use Grok for quant research (saves Claude credits)
- ALWAYS close browser tabs after research

---

### 10. 🗑️ Session Cleanup

**Purpose:** Clear clawdbot sessions weekly to prevent context overflow

**Schedule:** `0 0 * * 0` (weekly, Sunday at midnight)

**Model:** Ollama mistral-small3.2

**Backlog:** N/A (system task)

**Tasks:**
- Executes `/tmp/clear-clawdbot-sessions.sh`
- Clears old session data
- Prevents context overflow

**Reporting:** Logs to `/tmp/clear-sessions.log`

---

## Backlog Workflow

### Standard Backlog Process (All Teams)

1. **Read Backlog** — At the START of every cycle, read `backlogs/<team>.md`
2. **Pick Top Priority** — Select the top unchecked P0/P1 item. If none, pick P2. If all done, run standard tasks.
3. **Work** — Execute the task, using tools/resources as needed
4. **Update Backlog:**
   - Mark completed items with `[x]` and `[done: YYYY-MM-DD]`
   - Add new issues discovered as P2/P3
   - Write the updated file back
5. **Report:**
   - Post summary to clawd-status API
   - CRITICAL only → also Telegram alert

### Priority Levels

- **P0:** Critical (blocking, broken, rejected, security issue)
- **P1:** High (Felipe requested, important bug, cost optimization)
- **P2:** Medium (improvement, refactor, dependency update)
- **P3:** Low (nice-to-have, polish, documentation)

---

## Resource Usage & Cost Optimization

### Model Strategy
- **All cron jobs:** Claude Sonnet 4.5 (paid) — local models can't do tool-calling
- **Main session:** Claude Opus 4.5 (most expensive, direct chat with Felipe)
- **Heartbeat:** Claude Sonnet 4.5 (every 60 minutes)
- **Subagents:** qwen3-coder:30b (free local model, 73.7% accuracy on code tasks)

### Queue Systems (Prevent Conflicts)

1. **Grok Queue** — Only 1 bot uses Grok at a time:
   ```bash
   ./utils/with-grok.sh <bot-name> --query "Your question"
   ```

2. **Ollama Queue** — Max 2 concurrent inference requests:
   ```bash
   ./utils/with-ollama.sh <bot-name> <model> <command>
   ```

3. **Claude API Tracker** — Check before using Claude:
   ```bash
   python3 utils/resource-queue.py claude-check normal
   ```

### Cost Savings (Jan 28, 2026)
- **Before:** $15-40/day on API calls (3 Claude accounts exhausted)
- **After:** <$5/day (70-90% reduction)
- **How:**
  - Mac Mini Gateway DISABLED (was burning $150-300/month)
  - Grok queue system (FREE research tool)
  - Ollama queue system (FREE local models)
  - Claude API rotation with cooldowns

---

## Monitoring & Alerts

### Crabwalk Dashboard (port 9009)
Real-time monitoring dashboard for all bot sessions:
- Session grouping by job/agent
- Heartbeat status modal
- Active-only filter
- Machine stats display

### clawd-status API (port 9010)
Centralized reporting endpoint:
```bash
curl -sf http://localhost:9010/api/log -X POST \
  -H "Content-Type: application/json" \
  -d '{"jobId":"<job-name>","message":"<summary>","status":"<ok|warning|critical>"}'
```

### Telegram Alerts
- **Group:** Clawdbot HQ (Chat ID: `-5200506892`)
- **Policy:** Only CRITICAL alerts sent to Telegram
- **Routine reports:** Go to clawd-status API only

---

## Key Lessons

### What Works
- **Specialization:** Each bot is a domain expert
- **Backlogs:** Persistent task tracking across sessions
- **Reporting:** clawd-status API for routine, Telegram for critical
- **Queue systems:** Prevent resource conflicts and API exhaustion
- **Grok integration:** FREE research tool saves Claude credits

### What Doesn't Work
- **Local models for tool-calling:** ALL Ollama models fail at agentic tool-calling (systemic issue)
- **EAS Cloud builds:** Use local Xcode instead (faster, free)
- **Google Drive:** Felipe uses MEGA only
- **Simulators on MacBook:** All iOS work happens on Mac Mini

### Common Patterns
- Always read backlog FIRST, then work
- Always update backlog AFTER work
- Always close browser tabs after research
- Always commit and push fixes
- Always shutdown simulators after iOS builds
- Always check port availability before starting servers

---

## Future Improvements

### Planned Enhancements
- Repo log rotation — Weekly cleanup of large log files (IMPLEMENTED Jan 29)
- PM2 log cleanup on Mac Mini — Flush accumulated logs
- Google Chrome cache cleanup — Monthly cleanup of 2GB cache
- Xcode DerivedData cleanup — Can grow to 50GB, add to monthly cleanup
- Persistence TTL for Crabwalk — Auto-purge >48h sessions, >24h actions

### Backlog Items in Progress
See individual backlog files in `backlogs/` for current priorities.

---

**End of Teams Documentation**
