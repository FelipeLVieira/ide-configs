# Clawdbot Workspace Configuration

These files configure the Clawdbot AI assistant workspace.

## Files

| File | Purpose |
|------|---------|
| `AGENTS.md` | Global instructions for all agents (bots) |
| `SOUL.md` | Personality and behavior guidelines |
| `TOOLS.md` | Local tool configurations (Grok, cameras, SSH, etc.) |
| `USER.md` | Information about the human user |
| `IDENTITY.md` | Bot identity (name, emoji, avatar) |
| `HEARTBEAT.md` | Periodic task checklist |
| `BOOTSTRAP.md` | First-run setup instructions |
| `OPTIMIZATION_RULES.md` | Performance and cost optimization rules |
| `config.json` | Clawd orchestrator configuration |
| `clawdbot.template.json` | Clawdbot gateway config template |

## Rate Limit Prevention

**Important:** The default Clawdbot settings allow too many concurrent API calls, causing HTTP 429 rate limit errors from Anthropic.

Recommended settings in `~/.clawdbot/clawdbot.json`:
```json
"agents": {
  "defaults": {
    "maxConcurrent": 2,      // Max 2 agents at once (default is 4)
    "subagents": {
      "maxConcurrent": 2     // Max 2 subagents per agent (default is 8)
    }
  }
}
```

This limits to ~4 concurrent API calls instead of 32, preventing rate limit errors.

## Key Features

- **Multi-agent orchestration** - Main bot can spawn sub-agents for tasks
- **Grok integration** - Use X/Grok for research to save Claude credits
- **Memory system** - Daily notes + long-term memory (not in repo)
- **Heartbeat system** - Proactive background tasks

## Usage

Copy these files to your Clawdbot workspace (`~/clawd/` or similar).

## Auto-Resume on Restart

Clawdbot doesn't automatically resume tasks after a sudden shutdown. Use these scripts to track and notify about incomplete work:

**Setup (already installed at `~/.clawdbot/scripts/`):**
```bash
# Check for incomplete tasks
~/.clawdbot/scripts/auto-resume.sh check

# Save state before shutdown (added to .zshrc trap)
~/.clawdbot/scripts/auto-resume.sh save
```

**What gets saved:**
- Conversation history (`.jsonl` files) - always persisted
- Session metadata (`sessions.json`) - always persisted
- Completed task results (`runs.json`) - always persisted

**What is NOT auto-resumed:**
- Mid-API-call responses (lost)
- In-progress tool executions (lost)
- Active subagent tasks (won't auto-resume)

**LaunchAgent:** `~/Library/LaunchAgents/com.clawdbot.auto-resume.plist`
- Runs on login to check for incomplete tasks
- Sends Telegram notification if tasks were interrupted

## Security Notes

- `MEMORY.md` and `memory/` folder contain personal data - DO NOT commit
- `USER.md` may contain personal info - customize or exclude as needed
