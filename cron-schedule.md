# Cron Schedule — All Jobs

Complete cron job documentation for the Clawdbot ecosystem.

> **Last updated**: 2026-01-28 (late night) — All hourly staggered, deliver=false, clawd-status API reporting

---

## Overview

- **ALL cron jobs run on MacBook Pro** (orchestrator)
- **ALL use `anthropic/claude-sonnet-4-5`** (local models can't tool-call)
- **ALL have `deliver: false`** — routine reports go to clawd-status API, NOT Telegram
- **Critical alerts ONLY** go to Telegram (via HEARTBEAT.md instructions)

---

## Schedule (Hourly, Staggered by 5 Minutes)

```
:00  ─── Cleaner Bot + Healer Team
:05  ─── EZ-CRM Dev Bot
:10  ─── LinkLounge Dev Bot
:15  ─── iOS App Dev Bot

Every 6h ─── R&D AI Research
3x/day   ─── App Store Manager (9 AM, 3 PM, 9 PM EST)
Weekly   ─── Clear Sessions (Sunday midnight)
```

---

## Job Details

### Cleaner Bot (`:00` — Hourly)
| Setting | Value |
|---------|-------|
| **Schedule** | `0 * * * *` (every hour at :00) |
| **Model** | `anthropic/claude-sonnet-4-5` |
| **Session** | Isolated |
| **Deliver** | `false` |
| **Reports to** | clawd-status API (`POST http://localhost:9010/api/log`) |
| **Tools needed** | exec, SSH |
| **Purpose** | Deep cleanup — orphaned processes, stale files, disk space |

**What it does:**
- Kill orphaned processes (PPID=1, shell-snapshot, stale SSH)
- Clean /tmp, DerivedData, node_modules caches
- Check disk usage on both Macs
- Kill duplicate dev servers
- Report cleanup actions to clawd-status

### Healer Team (`:00` — Hourly, runs with Cleaner)
| Setting | Value |
|---------|-------|
| **Schedule** | `0 * * * *` (every hour at :00) |
| **Model** | `anthropic/claude-sonnet-4-5` |
| **Session** | Isolated |
| **Deliver** | `false` |
| **Reports to** | clawd-status API |
| **Tools needed** | exec, SSH, curl |
| **Purpose** | Multi-agent SRE team: Diagnostics → Analyst → Fixer → Verifier |

**What it does:**
- Diagnose system health (swap, disk, services)
- Analyze issues and plan fixes
- Apply fixes (restart services, unload models, kill zombies)
- Verify fixes worked
- Report to clawd-status, CRITICAL issues → Telegram

### EZ-CRM Dev Bot (`:05` — Hourly)
| Setting | Value |
|---------|-------|
| **Schedule** | `5 * * * *` (every hour at :05) |
| **Model** | `anthropic/claude-sonnet-4-5` |
| **Session** | Isolated |
| **Deliver** | `false` |
| **Reports to** | clawd-status API |
| **Tools needed** | exec, browser |
| **Repo** | `~/repos/ez-crm` |
| **Purpose** | Autonomous dev — git status, build check, bug fixes, push |

**Per-cycle workflow:**
1. `git status` — check for uncommitted/new changes
2. Start dev server — verify clean build
3. Browser test — headless screenshots to verify pages render
4. Fix bugs found — auto-fix and commit
5. Check TODOs — review code for improvements
6. `git push` — push working changes

### LinkLounge Dev Bot (`:10` — Hourly)
| Setting | Value |
|---------|-------|
| **Schedule** | `10 * * * *` (every hour at :10) |
| **Model** | `anthropic/claude-sonnet-4-5` |
| **Session** | Isolated |
| **Deliver** | `false` |
| **Reports to** | clawd-status API |
| **Tools needed** | exec, browser |
| **Repo** | `~/repos/linklounge` |
| **Purpose** | Same workflow as EZ-CRM — autonomous dev cycle |

### iOS App Dev Bot (`:15` — Hourly)
| Setting | Value |
|---------|-------|
| **Schedule** | `15 * * * *` (every hour at :15) |
| **Model** | `anthropic/claude-sonnet-4-5` |
| **Session** | Isolated |
| **Deliver** | `false` |
| **Reports to** | clawd-status API |
| **Tools needed** | exec, SSH (to Mac Mini for builds) |
| **Apps** | BMI Calculator, Bills Tracker, Screen Translator |
| **Purpose** | iOS dev — build, test, fix, push |

**Simulator rules:**
- ONE simulator at a time (Mac Mini has only 16GB)
- Always `xcrun simctl shutdown all` after testing
- Cleaner Bot auto-kills if >20 sim processes detected

### R&D AI Research (Every 6h)
| Setting | Value |
|---------|-------|
| **Schedule** | `0 */6 * * *` (every 6 hours) |
| **Model** | `anthropic/claude-sonnet-4-5` |
| **Session** | Isolated |
| **Deliver** | `false` |
| **Reports to** | clawd-status API + `memory/rd-findings.md` |
| **Tools needed** | browser, web_fetch, web_search |
| **Purpose** | Monitor AI developments — X/Twitter, Reddit, Google, Ollama releases |

See [rd-research-team.md](rd-research-team.md) for full details.

### App Store Manager (3x/day)
| Setting | Value |
|---------|-------|
| **Schedule** | `0 9,15,21 * * *` (9 AM, 3 PM, 9 PM EST) |
| **Model** | `anthropic/claude-sonnet-4-5` |
| **Session** | Isolated |
| **Deliver** | `false` |
| **Reports to** | clawd-status API |
| **Tools needed** | exec, web_fetch, browser |
| **Purpose** | iOS App Store monitoring — reviews, rejections, builds |

**Apps monitored:**
| App | Bundle ID |
|-----|-----------|
| BMI & Calorie Tracker | `com.felipevieira.bmicalculator` |
| Bills Tracker | `com.fullstackdev1.bill-subscriptions-organizer-tracker` |
| Offline Image Translator | `com.felipevieira.screentranslate` |

See [APP-STORE-MANAGER.md](clawdbot/APP-STORE-MANAGER.md) for full details.

### Clear Sessions (Weekly)
| Setting | Value |
|---------|-------|
| **Schedule** | `0 0 * * 0` (Sunday midnight) |
| **Model** | — (system task) |
| **Purpose** | Clean up stale session transcripts |

---

## Reporting Architecture

### Before Jan 28
```
Cron Job → Telegram message (deliver=true)
```
**Problem**: 10+ cron jobs × hourly = flood of Telegram messages. Felipe can't sleep.

### After Jan 28
```
Cron Job → clawd-status API (deliver=false)
         → POST http://localhost:9010/api/log
         → Viewable at http://100.125.165.107:9010

Critical only → Telegram (via HEARTBEAT.md instructions)
```

### clawd-status Dashboard
- **Port**: 9010
- **URL**: http://100.125.165.107:9010 (Tailscale) or http://localhost:9010
- **Features**: 
  - Services tab (health checks)
  - Cron Jobs tab (status, schedule, last/next run)
  - Log viewer per cron job
  - Overdue detection (orange border if >10min past due)
  - Header summary: "X/Y services" + "X/Y cron on schedule"
- **API**:
  - `POST /api/log` — Submit cron job log
  - `GET /api/logs/:jobId` — Get logs for a job
  - `GET /api/cron` — List all cron jobs
  - `GET /api/health` — Health check (some checks may timeout)

---

## Mac Mini Cron Jobs (Legacy — REMOVED)

These were previously on Mac Mini but have been **removed/consolidated**:

| Job | Status | Notes |
|-----|--------|-------|
| Shitcoin Brain (10min) | ❌ Removed | Was on qwen3:8b (can't tool-call) |
| Shitcoin Quant (15min) | ❌ Removed | Was on qwen3:8b (can't tool-call) |
| System Health Monitor (30min) | ❌ Removed | Replaced by Healer Team on MacBook |

Mac Mini is now a **NODE only** — no independent cron jobs. All orchestration runs on MacBook.

---

## Cost Analysis

| Job | Cost/run | Runs/day | Daily | Monthly |
|-----|----------|----------|-------|---------|
| Cleaner Bot | ~$0.03 | 24 | $0.72 | $21.60 |
| Healer Team | ~$0.05 | 24 | $1.20 | $36.00 |
| EZ-CRM Dev | ~$0.05 | 24 | $1.20 | $36.00 |
| LinkLounge Dev | ~$0.05 | 24 | $1.20 | $36.00 |
| iOS App Dev | ~$0.05 | 24 | $1.20 | $36.00 |
| R&D Research | ~$0.10 | 4 | $0.40 | $12.00 |
| App Store | ~$0.10 | 3 | $0.30 | $9.00 |
| Heartbeat | ~$0.02 | 24 | $0.48 | $14.40 |
| **TOTAL** | | | **$6.70** | **$201** |

---

## Key Lessons

1. **ALL local models fail at tool-calling** — don't try to save money by routing cron to Ollama
2. **devstral hallucinates completions** — runs 1 command then says "done" without doing work
3. **Cron Telegram delivery creates noise** — use clawd-status API for routine, Telegram for critical
4. **Stagger cron jobs** — prevents gateway overload from concurrent sessions
5. **ONE simulator at a time** — Mac Mini has only 16GB, multiple simulators cause swap death

---

## References

- [Clawdbot Config](clawdbot-config.md) — Full configuration
- [Model Routing](model-routing.md) — How models are selected
- [Three-Machine Architecture](infrastructure/three-machine-architecture.md) — Infrastructure overview
- [R&D Research Team](rd-research-team.md) — R&D cron details
- [App Store Manager](clawdbot/APP-STORE-MANAGER.md) — App Store cron details
