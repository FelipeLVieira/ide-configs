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

## Security Notes

- `MEMORY.md` and `memory/` folder contain personal data - DO NOT commit
- `USER.md` may contain personal info - customize or exclude as needed
