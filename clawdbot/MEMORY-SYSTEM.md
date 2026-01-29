# Memory System - How Memory Works

**Last Updated**: 2026-01-29  
**Philosophy**: Text > Brain — If you want to remember something, WRITE IT TO A FILE

---

## Table of Contents
1. [Memory Types](#memory-types)
2. [Directory Structure](#directory-structure)
3. [Memory Lifecycle](#memory-lifecycle)
4. [Compaction & Survival](#compaction--survival)
5. [Best Practices](#best-practices)
6. [Team Coordination](#team-coordination)

---

## Memory Types

### 1. Daily Notes (Session Logs)

**Location**: `~/clawd/memory/YYYY-MM-DD.md`

**Purpose**: Raw logs of what happened each day

**Who Uses**: ALL sessions (main, isolated, subagents)

**Format**:
```markdown
# 2026-01-29

## Main Session
- Felipe asked for architecture review
- Spawned docs team subagent
- Reviewed all cron jobs and services

## Cleaner Bot (2:00 AM)
- Killed 3 orphaned shell-snapshots
- Disk usage: MacBook 65%, Mac Mini 42%
- All services healthy

## iOS Dev Bot (2:15 AM)
- Built BMI Calculator v2.1.1
- Tests passed
- Committed fix for privacy manifest
```

**Rules**:
- Create new file each day (auto-created by first bot)
- Write immediately (don't wait until end of session)
- Include timestamps for important events
- Keep it chronological

---

### 2. Long-Term Memory (MEMORY.md)

**Location**: `~/clawd/MEMORY.md`

**Purpose**: Curated insights — the distilled essence, not raw logs

**Who Uses**: **MAIN SESSION ONLY** (security — contains personal context)

**DO NOT load in**:
- Discord group chats
- Shared contexts
- Sessions with other people
- Subagents working on public tasks

**Format**:
```markdown
# MEMORY.md - Long-Term Memory

## 🖥️ Infrastructure (Jan 25, 2026)
- Three-machine setup: MacBook Pro + Mac Mini + Windows MSI
- Moltbot architecture pattern deployed

## 💰 Cost Optimization (Jan 28, 2026)
- Reduced API costs: $15-40/day → <$5/day
- qwen3-coder:30b validated (73.7% accuracy)

## 📝 Lessons Learned
- Compact at 50% context, don't wait until 76%+
- Local models can't do tool-calling in Clawdbot
- Always close browser tabs after research
```

**Rules**:
- Curated, not comprehensive (highlights only)
- Updated after significant milestones
- Review daily files monthly, distill to MEMORY.md
- Delete old/irrelevant entries to keep it concise

---

### 3. Team Shared Memory

**Location**: `~/clawd/memory/teams/{team-name}.md`

**Purpose**: Multi-agent coordination space

**Who Uses**: Multiple bots working on the same project

**Format**:
```markdown
# Team: iOS Unified Team

## Status
- BMI Calculator: Ready for submission
- Bills Tracker: Needs ASC setup
- Screen Translator: Ready for submission

## Work Log
**2026-01-29 02:15** (iOS Dev Bot)
- Fixed privacy manifest for BMI Calculator
- Build successful, tests passed
- Committed to GitHub

**2026-01-29 09:00** (App Store Manager)
- Checked ASC status, no new reviews
- Bills Tracker still needs ASC account setup

## Decisions
- Use local Xcode builds (NOT EAS Cloud)
- Build one app at a time (memory constraint)
- Always shutdown simulators after builds

## TODOs
- [ ] Set up ASC account for Bills Tracker
- [ ] Submit BMI Calculator to review
- [ ] Submit Screen Translator to review
```

**Rules**:
- Check BEFORE starting work (avoid duplicates)
- Update AFTER completing work (keep team in sync)
- Document decisions (why we did X instead of Y)
- Keep TODOs prioritized

**See**: `~/clawd/memory/teams/README.md` for full guide

---

### 4. Backlogs (Task Queues)

**Location**: `~/clawd/backlogs/{team}.md`

**Purpose**: Prioritized task queue for each bot team

**Who Uses**: Each bot reads ONLY its own backlog

**Format**:
```markdown
## Queue
- [ ] P0: Fix App Store rejection — privacy manifest [source: appstore-manager] [added: 2026-01-29]
- [ ] P1: Update dependencies to latest versions [source: bot] [added: 2026-01-28]
- [ ] P2: Refactor authentication flow [source: felipe] [added: 2026-01-27]
- [ ] P3: Polish UI transitions [source: bot] [added: 2026-01-26]
- [x] Fix crash on launch [done: 2026-01-28]

## Notes
- Privacy manifest template: ios/PrivacyInfo.xcprivacy
- Apple requires NSPrivacyAccessedAPITypes for file access
```

**Priority Levels**:
- **P0**: Critical (blocking, broken, rejected)
- **P1**: High (Felipe requested, important bug)
- **P2**: Medium (improvement, refactor, dependency update)
- **P3**: Low (nice-to-have, polish)

**Rules**:
- Bots pick top unchecked item (P0 → P1 → P2 → P3)
- Mark [x] when done, add [done: YYYY-MM-DD]
- Add new issues discovered as P2/P3
- Keep file SHORT (max 20 items, move completed to ## Done monthly)

---

### 5. Research Findings

**Location**: `~/clawd/memory/{topic}/research-queue.md`

**Purpose**: Ongoing research accumulation

**Who Uses**: Research bots (R&D, Shitcoin Brain)

**Examples**:
- `~/clawd/memory/rd-findings.md` — AI/ML breakthroughs
- `~/clawd/memory/shitcoin-brain/research-queue.md` — Market research

**Format**:
```markdown
# R&D Findings

## 2026-01-29
### New Ollama Model: qwen3-coder:34b
- Source: Reddit r/LocalLLaMA
- Accuracy: 76% on HumanEval (better than qwen3-coder:30b)
- Size: 21GB (fits on MacBook)
- Recommendation: Test for code generation tasks

## 2026-01-28
### DeepSeek V3 Released
- Source: Hacker News
- Context: 128K tokens
- Not available on Ollama yet
- Watch for release
```

**Rules**:
- Append new findings (chronological)
- Include source and date
- ONLY report game-changers to main session
- Keep growing (don't delete old findings)

---

## Directory Structure

```
~/clawd/
├── MEMORY.md                      # Long-term curated (MAIN SESSION ONLY)
├── memory/
│   ├── 2026-01-27.md             # Daily session log
│   ├── 2026-01-28.md             # Daily session log
│   ├── 2026-01-29.md             # Daily session log (today)
│   ├── ARCHITECTURE.md           # System design docs
│   ├── IOS-UNIFIED-TEAM-INDEX.md # iOS team master doc
│   ├── grok-access.log           # Grok usage tracking
│   ├── teams/
│   │   ├── README.md             # Team shared memory guide
│   │   ├── architecture-review.md
│   │   ├── crabwalk-fix.md
│   │   └── r-and-d-todo-dashboard.md
│   ├── shitcoin-brain/
│   │   └── research-queue.md     # Market research findings
│   └── 2026-01-28-*.md           # Specific task reports
├── backlogs/
│   ├── README.md                 # Backlog format guide
│   ├── cleaner.md
│   ├── healer.md
│   ├── appstore.md
│   ├── ios-apps.md
│   ├── linklounge.md
│   ├── ez-crm.md
│   ├── shitcoin-brain.md
│   └── shitcoin-quant.md
├── AGENTS.md                     # Workspace guide
├── TOOLS.md                      # Setup-specific notes
├── SOUL.md                       # Agent personality/values
└── USER.md                       # Felipe's preferences
```

---

## Memory Lifecycle

### Session Start (Every Bot, Every Cycle)

```
1. READ relevant memory files:
   - AGENTS.md (workspace guide)
   - TOOLS.md (setup-specific)
   - memory/YYYY-MM-DD.md (today + yesterday)
   - backlogs/{my-team}.md (my task queue)
   - [MAIN SESSION ONLY] MEMORY.md (long-term)

2. UNDERSTAND context:
   - What happened recently?
   - What am I working on?
   - What's my current task priority?

3. WORK on task

4. WRITE updates:
   - Update backlog (mark [x], add new tasks)
   - Append to daily log (what I did)
   - [IF SIGNIFICANT] Update MEMORY.md or team shared memory

5. REPORT:
   - POST to clawd-status API
   - [IF CRITICAL] Telegram alert
```

### During Work (Continuous)

**Write immediately, don't wait:**

```markdown
# Bad Pattern ❌
# (do work for 2 hours)
# (get compacted before writing anything)
# LOST: All context, no memory of what was done

# Good Pattern ✅
# Start task
echo "$(date): Starting iOS build for BMI Calculator" >> memory/2026-01-29.md

# Complete subtask
echo "$(date): Build successful, tests passed" >> memory/2026-01-29.md

# Discover issue
echo "$(date): Found privacy manifest missing, adding template" >> memory/2026-01-29.md

# Complete task
echo "$(date): BMI Calculator v2.1.1 ready for submission" >> memory/2026-01-29.md
```

**Result**: Even if compacted, disk files survive!

---

### Session End

**Before ending:**
1. Check `git status` (uncommitted work?)
2. Update backlog with progress
3. Write summary to daily log
4. [IF SIGNIFICANT] Update MEMORY.md or team memory
5. Commit and push any code changes

---

## Compaction & Survival

### What Is Compaction?

**Context window is limited** — when usage is high, Clawdbot automatically:
- **Soft limit (50%)**: Prune old tool results
- **Hard limit (70%)**: Full compaction — conversation gets summarized

**memoryFlush is enabled** — important context automatically saved before compaction

### What Gets LOST in Compaction

- ❌ Conversation history (chat messages)
- ❌ Tool outputs (unless written to disk)
- ❌ Intermediate reasoning
- ❌ "Mental notes" (if not written down)

### What SURVIVES Compaction

- ✅ Files written to disk (MEMORY.md, daily logs, backlogs)
- ✅ Project-specific docs (architecture, lessons learned)
- ✅ Git commits (code changes, commit messages)
- ✅ External systems (clawd-status API, Crabwalk, PM2 logs)

### Compaction Survival Strategy

**1. Write Plans to Files (BEFORE Work)**
```markdown
# memory/2026-01-29.md
## iOS Dev Bot Plan (2:15 AM)
- Build BMI Calculator v2.1.1
- Run tests
- Fix privacy manifest if needed
- Commit and push
```

**2. Write Progress During Work**
```markdown
# memory/2026-01-29.md
## iOS Dev Bot Progress (2:15 AM)
- ✅ Build started
- ✅ Tests passed
- 🔄 Adding privacy manifest
```

**3. Write Results After Work**
```markdown
# memory/2026-01-29.md
## iOS Dev Bot Complete (2:45 AM)
- ✅ Build successful
- ✅ Privacy manifest added
- ✅ Committed to GitHub (commit abc1234)
- ✅ Ready for App Store submission
```

**Result**: If compacted at 2:30 AM, you still have complete record on disk!

---

## Best Practices

### 1. Write Immediately

**Don't**:
```
# Work for 2 hours
# Get compacted
# Lose everything
```

**Do**:
```
# Write at start: "Starting task X"
# Write during: "Completed subtask Y"
# Write at end: "Task X complete, results: Z"
```

### 2. Use Descriptive Filenames

**Don't**:
```
memory/notes.md
memory/temp.md
memory/stuff.md
```

**Do**:
```
memory/2026-01-28-ios-rejection-fixes.md
memory/2026-01-28-cost-optimization-report.md
memory/2026-01-28-architecture-review.md
```

### 3. Keep MEMORY.md Concise

**Don't**:
```
# MEMORY.md (10,000 lines)
Every single thing that ever happened...
```

**Do**:
```
# MEMORY.md (500 lines)
Key milestones, lessons learned, important context
Review monthly, archive old entries
```

### 4. Document Decisions

**Don't**:
```
# (make decision)
# (no record of why)
# (future-you confused)
```

**Do**:
```markdown
## Decisions
**2026-01-28**: Use qwen3-coder:30b instead of gemma3:12b
- Reason: 73.7% accuracy vs 51.3% baseline
- Validated by R&D team
- See: memory/2026-01-28-model-comparison.md
```

### 5. Cross-Reference

**Don't**:
```
# Duplicate information in multiple files
# (gets out of sync)
```

**Do**:
```markdown
## iOS Build Process
See: memory/IOS-UNIFIED-TEAM-INDEX.md
See: backlogs/ios-apps.md for current tasks
See: INFRASTRUCTURE.md for Mac Mini SSH commands
```

---

## Team Coordination

### Pattern: Multi-Bot Project

**Example**: iOS App Development

**Bots Involved**:
1. iOS Dev Bot (builds, tests, fixes)
2. App Store Manager (monitors reviews, status)

**Shared Memory**: `~/clawd/memory/teams/ios-unified-team.md`

**Workflow**:

**App Store Manager** (9:00 AM):
```markdown
# teams/ios-unified-team.md
## Latest Status (2026-01-29 09:00)
- BMI Calculator: Rejection — missing privacy manifest
- Deadline: 7 days
- Priority: P0

## Work Log
**2026-01-29 09:00** (App Store Manager)
- Found rejection for BMI Calculator
- Added P0 task to iOS Dev backlog
```

**iOS Dev Bot** (2:15 PM):
```markdown
# Read team memory FIRST
cat ~/clawd/memory/teams/ios-unified-team.md

# See rejection, pick P0 task from backlog
# Fix issue, build, test, commit

# Update team memory
## Work Log
**2026-01-29 14:15** (iOS Dev Bot)
- Fixed privacy manifest issue
- Build v2.1.1 successful
- Committed to GitHub (commit abc1234)
- Ready for resubmission

## Status
- BMI Calculator: Fixed, ready for resubmission
```

**App Store Manager** (9:00 PM):
```markdown
# Read team memory FIRST
cat ~/clawd/memory/teams/ios-unified-team.md

# See fix complete, resubmit to App Store

# Update team memory
## Work Log
**2026-01-29 21:00** (App Store Manager)
- Resubmitted BMI Calculator v2.1.1
- Status: In Review
- ETA: 24-48 hours
```

**Result**: Perfect coordination without Telegram spam!

---

## Troubleshooting

### Problem: "I forgot what I was doing"

**Cause**: Didn't write to files before compaction

**Solution**:
```bash
# Check daily log
cat ~/clawd/memory/$(date +%Y-%m-%d).md

# Check yesterday's log
cat ~/clawd/memory/$(date -v-1d +%Y-%m-%d).md

# Check backlog
cat ~/clawd/backlogs/{my-team}.md

# Check team memory (if applicable)
cat ~/clawd/memory/teams/{my-team}.md
```

---

### Problem: "Memory files getting too large"

**Cause**: Writing too much detail

**Solution**:
- **Daily logs**: Summarize at end of day, archive weekly
- **MEMORY.md**: Review monthly, move old entries to archive
- **Team memory**: Keep only last 7 days of work log
- **Research findings**: Keep growing (don't delete)

---

### Problem: "Can't find past decision"

**Cause**: Didn't document decision at time

**Solution**:
```bash
# Search memory files
grep -r "decision" ~/clawd/memory/

# Search git history
cd ~/clawd
git log --all --grep="decision" --oneline

# Check MEMORY.md
grep "Decisions" ~/clawd/MEMORY.md -A 20
```

**Prevention**: Always write decisions immediately:
```markdown
## Decisions (2026-01-29)
**Use qwen3-coder:30b for all bots**
- Reason: 73.7% accuracy validated
- Replaces: gemma3:12b (51.3% baseline)
- Source: R&D team validation report
```

---

## Advanced: Knowledge Graph (Future)

**Vision**: Automatically extract insights from memory files

```
Daily Logs → Extract entities, relationships, decisions
            ↓
         Knowledge Graph
            ↓
      Queryable via LLM
```

**Example Query**:
```
Q: "What models did we test in January 2026?"
A: "qwen3-coder:30b (73.7%), gemma3:12b (51.3%), 
    devstral-small-2:24b, phi4-mini (all tested Jan 28)"
```

**Status**: Future work (Q1 2026)

---

**Document Status**: ✅ Complete  
**Last Review**: 2026-01-29 00:45 EST  
**Maintained By**: Main Agent + Docs Team Subagent

**Key Takeaway**: **TEXT > BRAIN** — Write it down or lose it! 📝
