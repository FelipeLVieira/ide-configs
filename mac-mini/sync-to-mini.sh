#!/bin/bash
# Sync repos and clawdbot state to Mac Mini
# Usage: ./sync-to-mini.sh [--full]
#   --full: Also sync Claude/Gemini configs

set -e

MAC_MINI="felipemacmini@felipes-mac-mini.local"
FULL_SYNC=false

if [ "$1" = "--full" ]; then
    FULL_SYNC=true
fi

echo "=== Syncing repos to Mac Mini ==="
rsync -avz --progress \
  --exclude 'node_modules' \
  --exclude '.next' \
  --exclude 'dist' \
  --exclude '.git/objects/pack/*.pack' \
  ~/repos/ $MAC_MINI:~/repos/

echo ""
echo "=== Syncing clawdbot agents state ==="
rsync -avz ~/.clawdbot/agents/ $MAC_MINI:~/.clawdbot/agents/

echo ""
echo "=== Syncing clawdbot subagents state ==="
rsync -avz ~/.clawdbot/subagents/ $MAC_MINI:~/.clawdbot/subagents/

echo ""
echo "=== Syncing clawd workspace (memory, identity, tools) ==="
rsync -avz ~/clawd/ $MAC_MINI:~/clawd/

if [ "$FULL_SYNC" = true ]; then
    echo ""
    echo "=== Syncing Claude config ==="
    rsync -avz ~/.claude/ $MAC_MINI:~/.claude/

    echo ""
    echo "=== Syncing Gemini config ==="
    rsync -avz ~/.gemini/ $MAC_MINI:~/.gemini/
fi

echo ""
echo "=== Sync complete! ==="
echo ""
echo "NOTE: clawdbot.json NOT synced (Mac Mini has different Telegram settings)"
echo ""
echo "To start clawdbot on Mac Mini:"
echo "  ssh $MAC_MINI 'tmux new -d -s clawdbot \"eval \\\"\\\$(/opt/homebrew/bin/brew shellenv)\\\" && clawdbot gateway start\"'"
echo ""
echo "To enable Telegram failover on Mac Mini (when MacBook is offline):"
echo "  ssh $MAC_MINI  # then edit ~/.clawdbot/clawdbot.json: plugins.entries.telegram.enabled = true"
