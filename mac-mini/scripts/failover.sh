#!/bin/bash
# Clawdbot Failover Watchdog v3 - simplified TCP check
MACBOOK_IP="10.144.238.116"
PORT=18789
CHECK_INTERVAL=30
FAIL_THRESHOLD=3
RECOVERY_THRESHOLD=5
LOG="/tmp/clawdbot/failover.log"
CONFIG="$HOME/.clawdbot/clawdbot.json"
WORKSPACE="$HOME/clawd"

FAIL_COUNT=0
RECOVER_COUNT=0
IS_ACTIVE=false

mkdir -p /tmp/clawdbot
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG"; }

check_macbook() {
    # Use nc (netcat) for TCP check - available on all macOS
    nc -z -w 5 "$MACBOOK_IP" "$PORT" > /dev/null 2>&1
    return $?
}

set_telegram() {
    local state=$1
    python3 - "$state" "$CONFIG" << 'PYEOF'
import json, sys
enabled = sys.argv[1] == "true"
config_path = sys.argv[2]
with open(config_path) as f:
    conf = json.load(f)
conf.setdefault("plugins", {}).setdefault("entries", {}).setdefault("telegram", {})["enabled"] = enabled
with open(config_path, "w") as f:
    json.dump(conf, f, indent=2)
PYEOF
}

activate() {
    log "🔴 FAILOVER: Activating Mac Mini as primary!"
    cd "$WORKSPACE" && git pull --rebase origin master 2>/dev/null || true
    set_telegram "true"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null
    clawdbot gateway restart 2>/dev/null || clawdbot gateway start 2>/dev/null
    IS_ACTIVE=true
    FAIL_COUNT=0
    log "✅ Mac Mini ACTIVE with Telegram"
}

deactivate() {
    log "🟢 MacBook back! Yielding..."
    cd "$WORKSPACE" && git add -A 2>/dev/null && git diff --cached --quiet 2>/dev/null || git commit -m "auto-sync from failover" 2>/dev/null && git push origin master 2>/dev/null || true
    set_telegram "false"
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null
    clawdbot gateway restart 2>/dev/null
    IS_ACTIVE=false
    RECOVER_COUNT=0
    log "✅ Yielded to MacBook"
}

log "========== Failover Watchdog v3 started =========="
log "Monitoring: $MACBOOK_IP:$PORT every ${CHECK_INTERVAL}s"
set_telegram "false"

while true; do
    if check_macbook; then
        FAIL_COUNT=0
        if $IS_ACTIVE; then
            RECOVER_COUNT=$((RECOVER_COUNT + 1))
            log "MacBook recovered ($RECOVER_COUNT/$RECOVERY_THRESHOLD)"
            [ $RECOVER_COUNT -ge $RECOVERY_THRESHOLD ] && deactivate
        fi
    else
        RECOVER_COUNT=0
        FAIL_COUNT=$((FAIL_COUNT + 1))
        if ! $IS_ACTIVE; then
            log "⚠️  MacBook down ($FAIL_COUNT/$FAIL_THRESHOLD)"
            [ $FAIL_COUNT -ge $FAIL_THRESHOLD ] && activate
        fi
    fi
    sleep $CHECK_INTERVAL
done
