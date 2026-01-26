#!/bin/bash
# Sync repos and clawdbot state to Mac Mini

set -e

MAC_MINI="felipemacmini@felipes-mac-mini.local"

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
echo "=== Syncing clawdbot config ==="
scp ~/.clawdbot/clawdbot.json $MAC_MINI:~/.clawdbot/

echo ""
echo "=== Sync complete! ==="
echo ""
echo "To start clawdbot on Mac Mini:"
echo "  ssh $MAC_MINI 'tmux new -d -s clawdbot \"eval \\\"\\\$(/opt/homebrew/bin/brew shellenv)\\\" && clawdbot gateway start\"'"
