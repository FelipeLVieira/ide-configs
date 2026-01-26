#!/bin/bash
# Save clawdbot state before shutdown
# Add this to your .zshrc or .bash_profile:
# trap '~/.clawdbot/scripts/save-state-on-shutdown.sh' EXIT

~/.clawdbot/scripts/auto-resume.sh save
