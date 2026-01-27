# Clawdbot Skills Mapping

Recommended skills for each bot type and where to find more.

## Finding Skills

### Official Sources
- **Built-in skills:** `/opt/homebrew/lib/node_modules/clawdbot/skills/`
- **ClawdHub:** https://clawdhub.com (community skills)
- **GitHub:** Search "clawdbot skill" for community contributions

### X/Twitter Sources
- Follow @clawdbot for tips
- Search "clawdbot skills" for community recommendations
- Check @pigeon_trade for trading-related skills

## Skills by Bot Type

### Development Bots (ez-crm, linklounge, aphos, game-assets)
| Skill | Purpose |
|-------|---------|
| github | PR checks, issues, CI status |
| coding-agent | Spawn sub-agents for complex tasks |
| session-logs | Search conversation history |
| tmux | Terminal session control |
| bird | X/Twitter search for solutions |

### iOS App Bots (bmi, bills, translator)
| Skill | Purpose |
|-------|---------|
| peekaboo | macOS UI automation, screenshots |
| github | PRs, releases, CI |
| coding-agent | Build/test automation |
| imsg | iMessage integration (if needed) |

### Monitoring Bot (clawd-monitor)
| Skill | Purpose |
|-------|---------|
| session-logs | Check bot history |
| github | Dashboard updates |
| tmux | View bot sessions |

### Research Bot (shitcoin-brain)
| Skill | Purpose |
|-------|---------|
| bird | X/Twitter search |
| web_fetch | Article scraping |
| notion | Note-taking (optional) |

### Orchestrator (main session)
| Skill | Purpose |
|-------|---------|
| All above | Full capability |
| sessions_spawn | Create sub-agents |
| cron | Schedule tasks |
| nodes | Control remote nodes |

## Key Skills Usage

### github
- Check PR status: `gh pr checks 55 --repo owner/repo`
- List recent runs: `gh run list --limit 10`
- View failed logs: `gh run view <id> --log-failed`

### coding-agent
- Always use `pty:true` for interactive agents
- Spawn for complex multi-file changes

### bird (X/Twitter)
- Search: `bird search "query" -n 10`
- Read thread: `bird thread <url>`
- User timeline: `bird user-tweets @handle -n 20`

### session-logs
- Sessions at: `~/.clawdbot/agents/main/sessions/`
- Search with jq for keywords

## Consistency Patterns

### State File Structure
Every bot maintains `~/clawd/memory/bot-states/<name>.json`:

```json
{
  "lastActive": "2026-01-26T20:00:00Z",
  "project": "project-name",
  "status": "working|blocked|idle",
  "currentTask": "description",
  "progress": ["item1", "item2"],
  "blockers": ["issue1"],
  "recentChanges": ["commit1", "commit2"],
  "nextSteps": ["todo1", "todo2"],
  "learnings": ["insight1"]
}
```

### Continuous Improvement Loop
1. **Start session:** Read state file, understand context
2. **During work:** Track changes, document learnings
3. **End session:** Update state file with progress
4. **Next session:** Build on previous work

### Git Hygiene
- Commit after each working feature
- Clear commit messages
- Push before ending session
- Check `git log` at session start

## Installing New Skills

### From ClawdHub
Check skill page for install instructions.
Usually: `npm install -g <package>` or `brew install <formula>`

### Creating Custom Skills
See `skill-creator` skill for templates.

Skill structure:
```
my-skill/
├── SKILL.md          # Instructions for the bot
├── package.json      # Dependencies (optional)
└── scripts/          # Helper scripts (optional)
```

## Recommended Community Skills

Based on X/Twitter research:

| Skill | Purpose | Source |
|-------|---------|--------|
| agentmail | Email automation | clawdhub.com/adboio/agentmail |
| pigeon-mcp | Crypto trading | @pigeon_trade (coming soon) |
| browserbase | Advanced browser | browserbase.com |
