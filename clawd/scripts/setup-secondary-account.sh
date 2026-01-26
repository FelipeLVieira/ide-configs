#!/bin/bash
# Setup secondary Claude Code account for rate-limit fallback
# Run this script ONCE to authenticate wisedigitalinc@gmail.com
#
# This creates a separate config directory (~/.claude-wisedigital)
# with its own auth token, so Clawd can switch accounts on rate limits.

set -e

SECONDARY_CONFIG_DIR="$HOME/.claude-wisedigital"

echo "=== Clawd Secondary Account Setup ==="
echo ""
echo "This will authenticate your secondary Claude Code account."
echo "Config directory: $SECONDARY_CONFIG_DIR"
echo ""
echo "Account to log in: wisedigitalinc@gmail.com"
echo ""
echo "A browser window will open. Log in with wisedigitalinc@gmail.com"
echo "and complete the authentication flow."
echo ""
read -p "Press Enter to continue..."

# Run claude setup-token with the secondary config dir
CLAUDE_CONFIG_DIR="$SECONDARY_CONFIG_DIR" claude setup-token

echo ""
echo "=== Setup Complete ==="
echo "Secondary account authenticated at: $SECONDARY_CONFIG_DIR"
echo "Clawd will now automatically switch to this account on rate limits."
