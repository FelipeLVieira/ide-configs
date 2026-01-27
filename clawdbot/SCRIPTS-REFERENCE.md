# Mac Mini Scripts Reference

All scripts located in `~/clawd/scripts/`

## Bot Management

### manage-bots.sh
Main bot orchestration script.

```bash
~/clawd/scripts/manage-bots.sh <action> [bot-name]

Actions:
  status    - Show status of all bots
  start     - Start all bots (or specific bot)
  stop      - Stop all bots (or specific bot)  
  restart   - Restart all bots
  health    - Restart any stopped bots
  cleanup   - Kill orphan processes on bot ports
```

### run-persistent-bot.sh
Runs a single bot in continuous loop.

```bash
~/clawd/scripts/run-persistent-bot.sh <bot-name> <workspace-path>
```

### run-shitcoin-brain.sh
Special script for the research agent (30 min cycles).

### startup-bots.sh
Called on system reboot (@reboot crontab).

## Simulator Management

### sim-manager.sh
Coordinates iOS simulator usage between bots.

```bash
~/clawd/scripts/sim-manager.sh <action> <bot-name> [args]

Actions:
  check       - Check if safe to boot simulator
  boot        - Boot assigned simulator
  shutdown    - Shut down simulator
  shutdown-all - Shut down all simulators
  click       - Click at coordinates via Hammerspoon
  type        - Type text via Hammerspoon
  screenshot  - Take simulator screenshot
```

## Browser Coordination

### browser-lock.sh
Mutex for browser access.

```bash
source ~/clawd/scripts/browser-lock.sh
acquire_browser_lock "bot-name"
# ... use browser ...
release_browser_lock
```

### check-browser.sh
Verify Chrome extension has attached tab.

```bash
~/clawd/scripts/check-browser.sh
# Exit 0 = browser available
# Exit 1 = no tab attached, skip browser tasks
```

## Multi-Account

### claude-multi (in ~/.clawd/scripts/)
Wrapper that auto-switches accounts on rate limit.

```bash
~/.clawd/scripts/claude-multi [claude args...]
```

## Prompts

Bot-specific prompts in `~/clawd/prompts/`:
- `shitcoin-brain.md` - Research agent instructions

## Bot Instructions

Dynamic instructions in `~/clawd/bot-instructions/`:
- Bots check here for urgent tasks
- Orchestrator can write instructions for specific bots
