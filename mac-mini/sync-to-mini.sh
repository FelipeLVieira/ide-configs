#!/bin/bash
# Sync all IDE configs from MacBook to Mac Mini
set -e

MINI="username@hostname.local"

echo "🔄 Syncing IDE configs to Mac Mini..."

# Claude Code settings (hooks)
echo "  → Claude Code settings.json"
scp ~/.claude/settings.json $MINI:~/.claude/settings.json

# Claude Code MCPs (already in ~/.claude.json, sync via python)
echo "  → Claude Code MCPs (manual - edit ~/.claude.json)"

# Cursor MCPs
echo "  → Cursor mcp.json"
ssh $MINI 'mkdir -p ~/.cursor'
scp ~/.cursor/mcp.json $MINI:~/.cursor/mcp.json

# Git config
echo "  → Git config"
scp ~/.gitconfig $MINI:~/.gitconfig 2>/dev/null || true
scp ~/.gitignore_global $MINI:~/.gitignore_global 2>/dev/null || true

# SSH config
echo "  → SSH config"
scp ~/.ssh/config $MINI:~/.ssh/config 2>/dev/null || true

echo "✅ Sync complete!"
echo ""
echo "Manual steps needed:"
echo "  - VSCode: Open VSCode on Mac Mini, MCPs are in User settings"
echo "  - Vercel/Stripe OAuth: May need browser auth on Mac Mini"
