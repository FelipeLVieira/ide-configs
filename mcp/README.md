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

## Sync Status

| Machine | Claude Code | Cursor | VSCode | Clawdbot |
|---------|-------------|--------|--------|----------|
| MacBook Pro | [OK] 6 MCPs | [OK] 5 MCPs | [NO] (no MCP) | Built-in tools |
| Mac Mini | [OK] 6 MCPs | [OK] 5 MCPs | [OK] 5 MCPs | Built-in tools |

## Config Files Per IDE

| IDE | Config Location | Template |
|-----|-----------------|----------|
| Claude Code CLI | `~/.claude.json` -> `mcpServers` | `claude-code-mcps.json` |
| Claude Code (per-project) | `~/.claude/settings.json` -> hooks | `../claude/settings.json` |
| Cursor | `~/.cursor/mcp.json` -> `mcpServers` | `cursor-mcps.json` |
| VSCode | User Settings -> `mcp.servers` | `vscode-mcps.json` |
| Clawdbot | N/A (has browser, exec, etc. built-in) | — |

## Adding a New MCP

1. Add to all 3 template files (`claude-code-mcps.json`, `cursor-mcps.json`, `vscode-mcps.json`)
2. Deploy to both machines (see `../mac-mini/sync-to-mini.sh`)
3. Update this README
