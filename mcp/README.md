# MCP Server Configurations

Shared MCP (Model Context Protocol) server configs across all IDEs and machines.

## Current MCP Servers

| Server | Type | Purpose | Auth Needed |
|--------|------|---------|-------------|
| **supabase** | stdio (npx) | Database management, queries, schema | Supabase access token |
| **sequential-thinking** | stdio (npx) | Multi-step reasoning chains | None |
| **vercel** | HTTP | Deployment management | OAuth (browser) |
| **stripe** | HTTP | Payment/subscription management | OAuth (browser) |
| **browsermcp** | stdio (npx) | Browser automation (BrowserMCP) | None |
| **playwright** | stdio (npx) | Browser automation (Playwright) | None |

## Setup Per IDE

### Claude Code CLI (`~/.claude.json`)
MCPs go in the top-level `mcpServers` key. See `claude-code-mcps.json`.

### Cursor (`~/.cursor/mcp.json`)
MCPs go in `mcpServers` key. See `cursor-mcps.json`.

### VSCode (`settings.json`)
MCPs go in `mcp.servers` key in user settings.

### Clawdbot
Clawdbot has its own built-in tools (browser, exec, etc.) — it doesn't use MCP servers directly.

## Synced Machines

| Machine | Claude Code | Cursor | VSCode |
|---------|-------------|--------|--------|
| MacBook Pro | ✅ 6 MCPs | ✅ 5 MCPs | ❌ |
| Mac Mini | ✅ 6 MCPs | ✅ 5 MCPs | ❌ |

## Adding a New MCP

1. Add it to `claude-code-mcps.json` and `cursor-mcps.json`
2. Deploy to both machines:
   ```bash
   # Mac Mini
   ssh felipemacmini@felipes-mac-mini.local 'cat ~/.claude.json | python3 ...'
   ```
3. Update this README
