#!/bin/bash
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin"
eval "$(/opt/homebrew/bin/brew shellenv)"
cd ~/repos/shitcoin-bot
exec uv run python -m src.run_bots
