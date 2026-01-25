#!/bin/bash
# IDE Configs Installation Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== IDE Configs Installer ==="
echo ""

# Claude Code
echo "Installing Claude Code configs..."
mkdir -p ~/.claude/scripts
cp "$SCRIPT_DIR/claude/CLAUDE.md" ~/.claude/
cp "$SCRIPT_DIR/claude/WORKING_PRINCIPLES.md" ~/.claude/
cp "$SCRIPT_DIR/claude/deslop.md" ~/.claude/
cp "$SCRIPT_DIR/claude/settings.json" ~/.claude/
cp "$SCRIPT_DIR/scripts/cleanup-antigravity.sh" ~/.claude/scripts/
chmod +x ~/.claude/scripts/cleanup-antigravity.sh
echo "  ✓ Claude Code configs installed"

# Gemini/Antigravity
echo "Installing Gemini/Antigravity configs..."
mkdir -p ~/.gemini
cp "$SCRIPT_DIR/gemini/GEMINI.md" ~/.gemini/
echo "  ✓ Gemini configs installed"

# VSCode (backup existing first)
echo "Installing VSCode global settings..."
VSCODE_SETTINGS="$HOME/Library/Application Support/Code/User/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    cp "$VSCODE_SETTINGS" "$VSCODE_SETTINGS.backup.$(date +%s)"
    echo "  ✓ Backed up existing settings.json"
fi
mkdir -p "$HOME/Library/Application Support/Code/User"
cp "$SCRIPT_DIR/vscode/global-settings.json" "$VSCODE_SETTINGS"
echo "  ✓ VSCode settings installed"

# Clawd
echo "Installing Clawd config..."
if ! command -v clawd &> /dev/null; then
    echo "  ⚠ Clawd not installed. Installing..."
    npm install -g clawd
fi
mkdir -p ~/.clawd
cp "$SCRIPT_DIR/clawd/config.json" ~/.clawd/
echo "  ✓ Clawd config installed"

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Installed:"
echo "  - ~/.claude/CLAUDE.md"
echo "  - ~/.claude/WORKING_PRINCIPLES.md"
echo "  - ~/.claude/deslop.md"
echo "  - ~/.claude/settings.json"
echo "  - ~/.claude/scripts/cleanup-antigravity.sh"
echo "  - ~/.gemini/GEMINI.md"
echo "  - ~/Library/Application Support/Code/User/settings.json"
echo "  - ~/.clawd/config.json"
echo ""
echo "To clean Antigravity cache: ~/.claude/scripts/cleanup-antigravity.sh"
echo "To use Clawd: ask Claude 'run clawd to [task]'"
