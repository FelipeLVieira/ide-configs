# Clawdbot System Architecture

**Last Updated:** 2026-01-29  
**Documentation Owner:** Docs Team (Subagent)

## Overview

Clawdbot is a 24/7 proactive AI orchestration system running across multiple machines. It follows the **"moltbot" architecture pattern** for persistent, resource-aware, multi-agent coordination.

### Core Philosophy
- **Orchestration > Chat** — Persistent missions, not ephemeral Q&A
- **Specialization > Generalization** — Each cron job is a domain specialist
- **Local Control, Cloud Intelligence** — Run locally, rent brain from Anthropic
- **Disk Is State, Git Is Memory** — All work committed, memory persists across sessions
- **Cost-Conscious Design** — FREE local models first → Claude Sonnet fallback → Never Opus (except main session)

---

## Infrastructure

### Three-Machine Setup

#### 1. **MacBook Pro** (M3 Max, 48GB RAM)
**Role:** Primary Orchestrator

- **Runs:**
  - Main agent session (Claude Opus 4.5) — direct chat with Felipe
  - Heartbeat agent (Sonnet 4.5, every 60m)
  - ALL cron job agents (10 scheduled bots)
  - Crabwalk dashboard (port 9009)
  - clawd-status API (port 9010)
  - Ollama model server (11434) — hosts ALL models for entire system

- **Ollama Models Hosted:**
  - `qwen3-coder:30b` (19GB) — PRIMARY for all bots (73.7% accuracy validated)
  - `gemma3:12b` (8GB) — Vision-capable fallback
  - `devstral-small-2:24b` (15GB) — Optional heavy coding model

- **Network:**
  - LAN IP: 10.144.238.116
  - Tailscale: 100.125.165.107 (userspace-networking, SOCKS5 on localhost:1055)
  - Ollama accessible at: `http://10.144.238.116:11434` (LAN) or via Tailscale

- **Services (LaunchAgents):**
  - `com.clawdbot.gateway` (port 18789, loopback-only)
  - `com.clawdbot.watchdog` (monitors Mac Mini gateway health)
  - `com.clawdbot.macbook-cleanup` (system maintenance)
  - `com.clawdbot.auto-resume` (session recovery)
  - `com.clawdbot.event-watcher` (file system monitoring)

#### 2. **Mac Mini** (M4, 16GB RAM)
**Role:** Worker / Build Server

- **CRITICAL:** **NO models installed!** Uses MacBook's Ollama remotely via Tailscale.

- **Runs:**
  - Aphos game servers (PM2)
    - Production (port 2567)
    - Development (port 2568)
  - Ollama service (PM2) — forwards to MacBook models
  - Xcode + iOS simulators (iOS app builds)
  - Node service (connects to MacBook gateway)

- **Network:**
  - LAN: 10.144.238.14 (local hostname: felipes-mac-mini.local)
  - Tailscale: 100.115.10.14 (userspace-networking)
  - SSH: `ssh felipemacmini@felipes-mac-mini.local` (passwordless from MacBook)

- **Mac Mini Gateway:** **DISABLED** (Jan 28, 2026)
  - Was burning $150-300/month in Claude API credits (1382 restarts)
  - Mac Mini now uses MacBook's gateway + Ollama only

#### 3. **Windows MSI** (Gaming PC)
**Role:** Windows-Specific Tasks

- **Access:** `ssh msi` (via Tailscale SOCKS proxy)
- **User:** felip
- **Tailscale:** 100.67.241.32
- **Note:** SSH is slow (use 10-15s timeout)

---

## Communication & Coordination

### Cross-Machine Communication
- **SSH:** MacBook → Mac Mini (passwordless key-based auth)
- **Tailscale VPN:** Secure mesh network for all devices
- **Gateway Bridge:** HTTP API on port 18789 for agent delegation (MacBook ↔ Mac Mini)
- **Git Sync:** Workspace changes committed to GitHub private repo (`FelipeLVieira/clawd-workspace`)

### Resource Sharing
- **Ollama Models:** Mac Mini uses MacBook's models remotely (http://10.144.238.116:11434)
- **iOS Builds:** MacBook orchestrates, Mac Mini executes (via SSH/nodes.run)
- **Browser Automation:** Shared Grok access via queue system (only 1 bot at a time)

---

## Model Strategy & Cost Optimization

### Current Crisis (Jan 28, 2026)
- **Felipe exhausted 3 Claude accounts:** felipevieiradrive, claude-cli, wisedigital
- **Daily burn:** $15-40/day on API calls
- **Solution:** Default to FREE local models, use Claude sparingly

### Model Selection Priority

1. **FREE Local Models (ALWAYS TRY FIRST):**
   - **Primary:** `qwen3-coder:30b` (VALIDATED: 73.7% accuracy vs 51.3% baseline)
   - **Fallback:** `gemma3:12b` (if primary is busy/unavailable, vision-capable)
   - **Connection:** http://10.144.238.116:11434 (LAN) or via Tailscale
   - **Queue System:** `./utils/with-ollama.sh bot-name qwen3-coder:30b "command"` (max 2 concurrent)

2. **Research Tools (FREE):**
   - **web_fetch** — Grab content from URLs
   - **Grok (X/Twitter)** — Real-time news, trends, market data (when logged in)
   - **Queue System:** `./utils/with-grok.sh bot-name --query "question"` (only 1 bot at a time)

3. **Claude Sonnet 4.5 (EXPENSIVE - USE SPARINGLY):**
   - Only when local models fail or hallucinate
   - Complex reasoning that local models can't handle
   - When accuracy is absolutely critical
   - **ALL cron jobs:** Sonnet 4.5 (local models can't do agentic tool-calling)

4. **Claude Opus 4.5 (MOST EXPENSIVE - MAIN SESSION ONLY):**
   - Direct conversation with Felipe ONLY
   - Never used in fallback chains

### Intelligent Fallback Strategy
1. Try MacBook's local model first (via Tailscale if Mac Mini)
2. If result is wrong/hallucination → escalate to Claude Sonnet
3. After Claude solves it, **remember the solution** and try local model again next time
4. Bots should **learn patterns** where local models fail and improve over time

### Resource Queue System (Deployed Jan 28, 2026)
Prevents resource conflicts and API exhaustion:

1. **Grok Queue** - Only 1 bot can use Grok at a time:
   ```bash
   ./utils/with-grok.sh <bot-name> --query "Your question"
   ```

2. **Ollama Queue** - Max 2 concurrent inference requests:
   ```bash
   ./utils/with-ollama.sh <bot-name> <model> <command>
   ```

3. **Claude API Tracker** - Check before using Claude:
   ```bash
   python3 utils/resource-queue.py claude-check normal
   # Returns: {"use": "claude"|"ollama"|"wait", "reason": str, ...}
   ```

**Cost Savings:** $15-40/day → <$5/day (70-90% reduction)

**Full docs:** `RESOURCE-QUEUE-USAGE.md` + `GROK-USAGE-PATTERN.md`

---

## Memory & Persistence

### Memory Hierarchy
- **Daily Notes:** `memory/YYYY-MM-DD.md` — Raw logs of what happened
- **Long-Term Memory:** `MEMORY.md` — Curated memories, like a human's long-term memory (MAIN SESSION ONLY, security-sensitive)
- **Team Shared Memory:** `memory/teams/{team-name}.md` — Coordination space for multi-agent teams

### Backlog System
Each bot team has a backlog file in `backlogs/<team>.md`:

**Format:**
```markdown
## Queue
- [ ] P0: Critical (blocking, broken, rejected)
- [ ] P1: High (Felipe requested, important bug)
- [ ] P2: Medium (improvement, refactor, dependency update)
- [ ] P3: Low (nice-to-have, polish)
- [x] Completed task [done: YYYY-MM-DD]

## Notes
<any context the bot needs between cycles>
```

**Rules:**
- Bots READ the file at the START of every cycle
- Pick the top unchecked item, work on it
- MARK items [x] when done, add [done: date]
- ADD new items they discover (bugs, TODOs, improvements)
- Felipe can add items directly (just edit the file)
- Keep files SHORT — move completed items to `## Done` section monthly

### Context Compaction
Context gets compacted automatically when usage is high:
- **Soft limit (50%):** Context pruning starts trimming old tool results
- **Hard limit (70%):** Full compaction — conversation gets summarized

**What SURVIVES compaction:** Files written to disk!

**Pattern for critical info:**
1. Learn something important → IMMEDIATELY write to `memory/YYYY-MM-DD.md`
2. Don't wait until end of session — you might get compacted first
3. Before starting complex work, write your plan to a file
4. After completing work, write results to a file

---

## Security & Safety

### Credential Management
- **NEVER commit .env files to git!** They contain private keys, API keys, database credentials
- ✅ Always verify .env is in .gitignore
- ✅ Use .env.example for documentation (placeholder values only)
- ✅ Install pre-commit hooks to prevent accidents
- 🔄 Rotate credentials immediately if exposed

**Security audit completed:** 2026-01-28 — All repos have pre-commit hooks installed

### Cloud Storage
- **Felipe uses MEGA, NOT Google Drive**
- ❌ NEVER access Google Drive
- ❌ NEVER suggest Google Drive
- ✅ Use MEGA for all cloud storage needs

### iOS Development
- **All iOS simulator/Xcode work must happen on Mac Mini!**
- ❌ NEVER open simulators on MacBook
- ❌ NEVER run xcodebuild on MacBook
- ✅ Use SSH: `ssh felipemacmini@felipes-mac-mini.local '<command>'`
- ✅ Use nodes.run: `nodes.run(mac-mini, [...])`

### iOS Builds - LOCAL ONLY, NO EAS CLOUD
- ❌ NEVER use `eas build` for iOS
- ✅ Use `xcodebuild` locally on Mac Mini
- ✅ Use `npx expo run:ios` for dev builds

---

## Port Management

**Assigned port ranges (avoid conflicts!):**

| Range      | Project            | Notes                      |
|------------|-------------------|----------------------------|
| 2567-2599  | Aphos game servers | 2567=prod, 2568=dev       |
| 3000-3099  | ez-crm            | 3000=default               |
| 3100-3199  | linklounge        | 3100=default               |
| 4000-4099  | Aphos web         | 4000=default               |
| 5000-5099  | shitcoin-bot      | If needs web server        |
| 8081       | bmi-calculator    | Expo web                   |
| 8082       | bills-tracker     | Expo web                   |
| 8083       | screen-translator | Expo web                   |
| 9000-9099  | crabwalk          | 9009=default               |
| 9010       | clawd-status API  | Bot reporting              |
| 11434      | Ollama            | MacBook model server       |
| 18789      | Gateway Bridge    | Agent delegation (loopback)|

**Before starting a server, ALWAYS check your assigned range!**

---

## Projects Overview

### 🎮 Aphos
- **Type:** MMORPG game
- **Running on:** Mac Mini (prod: 2567, dev: 2568)
- **Tech:** Colyseus game server, Real Earth + fantasy setting
- **Status:** JWT auth added (Jan 28), prod server needs rebuild

### 🔗 LinkLounge
- **Type:** Linktree competitor
- **Repo:** ~/repos/linklounge
- **Port:** 3100
- **Status:** Active development

### 📋 ez-crm
- **Type:** Personal injury CRM
- **Repo:** ~/repos/ez-crm
- **Port:** 3000
- **Status:** Active development

### 📊 Crabwalk
- **Type:** Bot monitoring dashboard
- **Repo:** ~/repos/clawd-monitor
- **Port:** 9009 (MacBook LaunchAgent)
- **Status:** Active, session grouping + heartbeat display (Jan 28)

### 💰 shitcoin-bot
- **Type:** Polymarket trading bot
- **Running on:** Mac Mini (LaunchAgent, headless)
- **Status:** Disabled (Jan 28 — manual trading only, no auto-trade)
- **Note:** NO web interface, CLI only

### 📱 iOS Apps (3 apps)
1. **BMI & Calorie Tracker**
   - Repo: bmi-calculator
   - Version: v2.1.1 (build 33)
   - ASC ID: 6756639140
   - Status: Ready for submission

2. **Bills Tracker**
   - Repo: bill-subscriptions-organizer-tracker
   - Version: v1.0.6
   - Status: Needs ASC setup

3. **Screen Translator**
   - Repo: simple-screen-translator
   - Version: v1.0.0 (build 1)
   - ASC ID: 6740551796
   - Status: Ready for submission

---

## Cron Jobs & System Services

### System Cron Jobs (crontab)
```bash
0 10 * * * /Users/felipevieira/.local/bin/lume-update >/tmp/lume_updater.log 2>&1
*/15 * * * * /Users/felipevieira/clawd/.git-auto-sync.sh >> /tmp/clawd-sync.log 2>&1
0 0 * * 0 /tmp/clear-clawdbot-sessions.sh > /tmp/clear-sessions.log 2>&1
0 * * * * ~/.clawdbot/scripts/auto-trim-agents.sh >> ~/.clawdbot/logs/auto-trim.log 2>&1
* * * * * ~/.clawdbot/scripts/crash-monitor.sh >> ~/.clawdbot/logs/crash-monitor.log 2>&1
```

### LaunchAgents (MacBook)
- `com.clawdbot.gateway` (port 18789)
- `com.clawdbot.watchdog` (monitors Mac Mini)
- `com.clawdbot.macbook-cleanup` (system maintenance)
- `com.clawdbot.auto-resume` (session recovery)
- `com.clawdbot.event-watcher` (file system monitoring)

### PM2 Services (Mac Mini)
- `aphos-server-prod` (port 2567)
- `aphos-server-dev` (port 2568)
- `ollama` (port 11434 — forwards to MacBook models)

See **TEAMS.md** for detailed cron job agent documentation.

---

## Monitoring & Observability

### Crabwalk Dashboard (port 9009)
Real-time monitoring dashboard for all bot sessions:
- Session grouping by job/agent
- Heartbeat status modal (scrollable, real data)
- Active-only filter (performance optimized)
- Machine stats display (from heartbeat-data.json)

### clawd-status API (port 9010)
Centralized reporting endpoint for cron job agents:
```bash
curl -sf http://localhost:9010/api/log -X POST \
  -H "Content-Type: application/json" \
  -d '{"jobId":"<job-name>","message":"<summary>","status":"<ok|warning|critical>"}'
```

**Status levels:**
- **ok:** Routine completion, no issues
- **warning:** Non-critical issues (high resource usage, minor bugs)
- **critical:** Blocking issues, service failures, API exhaustion

### Telegram Notifications
- **Group:** Clawdbot HQ (Chat ID: `-5200506892`)
- **Policy:** Only CRITICAL alerts sent to Telegram
- **Routine reports:** Go to clawd-status API only (reduces noise)

---

## Key Lessons & Best Practices

### Model Selection
- **ALL local Ollama models fail at multi-step tool-calling in Clawdbot** (tested 7 models, Jan 28)
- Root cause: Ollama's template translation layer breaks OpenAI-format tool_calls responses
- **DO NOT try more Ollama models** — problem is systemic, not model-specific
- Stick with Sonnet 4.5 for all tool-calling (cron jobs, heartbeat)
- Local models (qwen3-coder:30b) work great for non-tool-calling tasks (73.7% accuracy)

### Resource Management
- Compact at 50% context, don't wait until 76%+
- Close browser tabs after using them (max 2-3 tabs open)
- Kill dev servers when done testing
- Check for orphaned processes before starting new ones
- Use queue systems (Grok/Ollama) to prevent conflicts

### Git Hygiene
- Commit often — after each working feature/fix
- Clear commit messages (future-you needs to understand)
- Group related changes — one commit per logical unit of work
- Push after significant milestones
- Check `git status` before ending a session

### Port Management
- ALWAYS check what's running before starting a server (`lsof -i :PORT`)
- NO duplicates — if your server is running, don't start another
- Use different ports if another bot/project is using one
- Clean up your mess — kill duplicate processes

---

## Remote Access

### Mac Mini Remote Control
- **Screen Sharing (VNC):** `vnc://felipes-mac-mini.local` (port 5900)
- **SSH:** `ssh felipemacmini@felipes-mac-mini.local` (passwordless)
- **Mouse control:** `cliclick` installed, Accessibility permissions granted
- **AppleScript:** `osascript` works (dialogs, app control, UI scripting)
- **Screen capture:** `screencapture -x /tmp/screen.png` via nodes.run
- **Peekaboo:** Screen Recording permission granted

### Windows MSI (via Tailscale SSH)
- **SSH:** `ssh msi` (configured in ~/.ssh/config with SOCKS proxy)
- **User:** felip
- **Note:** Both Macs use Tailscale in userspace-networking mode (SOCKS5 on localhost:1055)

### Felipe's Remote Access
- **Chrome Remote Desktop** (internet access)

---

## Configuration Backup

### ide-configs Repo
- **Repo:** `FelipeLVieira/ide-configs`
- **Purpose:** Complete IDE/machine config backup
- **Contents:** 50+ files (MCPs, Brewfiles, LaunchAgents, scripts, templates)
- **Capability:** Can rebuild entire setup from scratch with this repo

---

## Moltbot Architecture Pattern

We follow the **"moltbot" pattern** for 24/7 proactive multi-agent systems:

1. **24/7 Proactive Agents** — Always running, not just reactive (cron jobs + heartbeats)
2. **Persistent Memory** — Survives restarts, compaction, sessions (MEMORY.md + daily logs)
3. **Multi-Agent Coordination** — Specialized agents working together (orchestrator + specialists)
4. **Resource-Aware** — Queue management, rate limiting, cost optimization (Grok/Ollama/Claude queues)
5. **Self-Healing** — Monitors own health, auto-recovers from failures (healer-auto-recovery)

**Community Tools:**
- **memU** (NevaMind-AI) — Memory for 24/7 agents like moltbot/clawdbot
- **IxA-supervisor** (Ocaxtar) — Coordination center using moltbolt architecture

**Key Difference:** "Clawdbot" is the product name, "moltbot" is the architecture pattern.

---

## Contact & Support

- **Owner:** Felipe Vieira
- **Telegram:** @felipe (user ID: 1997535887)
- **Clawdbot HQ:** https://t.me/+7d4oSz4Zd7c2ODJh

---

**End of Architecture Documentation**
