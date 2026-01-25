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
| `config.json` | Clawdbot gateway configuration |

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
