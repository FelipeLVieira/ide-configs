#!/bin/bash
# Setup secondary Claude Code account for rate-limit fallback
# Run this script ONCE per machine to:
#   1. Authenticate wisedigitalinc@gmail.com in a separate config dir
#   2. Symlink the multi-account adapter into all project directories
#
# Usage: ~/.clawd/scripts/setup-secondary-account.sh

set -e

SECONDARY_CONFIG_DIR="$HOME/.claude-wisedigital"
ADAPTER_SOURCE="$HOME/.clawd/adapter.js"

# Project directories (add new projects here)
PROJECTS=(
  "$HOME/repos/aphos"
  "$HOME/repos/shitcoin-bot"
  "$HOME/repos/ez-crm"
  "$HOME/repos/bmi-calculator"
  "$HOME/repos/bill-subscriptions-organizer-tracker"
  "$HOME/repos/simple-screen-translator"
  "$HOME/repos/linklounge"
  "$HOME/repos/clawd-monitor"
)

echo "=== Clawd Multi-Account Setup ==="
echo ""

# Step 1: Ensure adapter exists
if [ ! -f "$ADAPTER_SOURCE" ]; then
  echo "ERROR: Adapter not found at $ADAPTER_SOURCE"
  echo "Copy it from ide-configs first:"
  echo "  cp ~/repos/ide-configs/clawd/adapter.js ~/.clawd/adapter.js"
  exit 1
fi
echo "[1/3] Adapter found at $ADAPTER_SOURCE"

# Step 2: Symlink adapter into all project directories
echo "[2/3] Symlinking adapter into project directories..."
for dir in "${PROJECTS[@]}"; do
  if [ -d "$dir" ]; then
    mkdir -p "$dir/.clawd"
    ln -sf "$ADAPTER_SOURCE" "$dir/.clawd/adapter.js"
    # Add .clawd/ to gitignore if not already there
    if [ -f "$dir/.gitignore" ]; then
      if ! grep -q "^\.clawd/$" "$dir/.gitignore" 2>/dev/null; then
        echo ".clawd/" >> "$dir/.gitignore"
      fi
    fi
    echo "  -> $dir/.clawd/adapter.js"
  else
    echo "  -- Skipped (not found): $dir"
  fi
done

# Step 3: Authenticate secondary account
echo ""
echo "[3/3] Authenticating secondary Claude Code account..."
echo ""
echo "Config directory: $SECONDARY_CONFIG_DIR"
echo "Account to log in: wisedigitalinc@gmail.com"
echo ""

mkdir -p "$SECONDARY_CONFIG_DIR"

if [ -f "$SECONDARY_CONFIG_DIR/settings.json" ] || [ -d "$SECONDARY_CONFIG_DIR/statsig" ]; then
  echo "Secondary account appears to already be configured."
  read -p "Re-authenticate? (y/N): " REAUTH
  if [ "$REAUTH" != "y" ] && [ "$REAUTH" != "Y" ]; then
    echo "Skipping authentication."
    echo ""
    echo "=== Setup Complete ==="
    exit 0
  fi
fi

echo "A browser window will open. Log in with wisedigitalinc@gmail.com"
echo "and complete the authentication flow."
echo ""
read -p "Press Enter to continue..."

CLAUDE_CONFIG_DIR="$SECONDARY_CONFIG_DIR" claude setup-token

echo ""
echo "=== Setup Complete ==="
echo "Secondary account authenticated at: $SECONDARY_CONFIG_DIR"
echo "Adapter symlinked into ${#PROJECTS[@]} project directories."
echo "Clawd will now automatically switch accounts on rate limits."
