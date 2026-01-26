#!/bin/bash
# Clawdbot Auto-Resume Script
# Checks for incomplete tasks after restart and notifies/resumes them

CLAWDBOT_DIR="$HOME/.clawdbot"
RUNS_FILE="$CLAWDBOT_DIR/subagents/runs.json"
SESSIONS_DIR="$CLAWDBOT_DIR/agents/main/sessions"
LOG_FILE="$CLAWDBOT_DIR/logs/auto-resume.log"
STATE_FILE="$CLAWDBOT_DIR/state/last-shutdown.json"

mkdir -p "$CLAWDBOT_DIR/logs" "$CLAWDBOT_DIR/state"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

# Save current state before shutdown (call this on shutdown)
save_state() {
    log "Saving state before shutdown..."

    # Get active session IDs
    local active_sessions=$(ls -1 "$SESSIONS_DIR"/*.jsonl 2>/dev/null | grep -v deleted | xargs -I{} basename {} .jsonl)

    # Get incomplete runs
    local incomplete_runs=""
    if [ -f "$RUNS_FILE" ]; then
        incomplete_runs=$(jq -r '[.runs | to_entries[] | select(.value.endedAt == null) | .key] | join(",")' "$RUNS_FILE" 2>/dev/null)
    fi

    # Save state
    cat > "$STATE_FILE" << EOF
{
    "shutdownAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "incompleteTasks": "$incomplete_runs",
    "activeSessions": "$(echo $active_sessions | tr '\n' ',')"
}
EOF
    log "State saved to $STATE_FILE"
}

# Check and resume on startup
check_and_resume() {
    log "=== Clawdbot Auto-Resume Check ==="

    # Check if gateway is running
    if ! pgrep -f "clawdbot-gateway" > /dev/null; then
        log "Gateway not running. Starting..."
        # Wait for gateway to start (it should auto-start via LaunchAgent)
        sleep 5
    fi

    # Check for incomplete runs
    local incomplete_count=0
    if [ -f "$RUNS_FILE" ]; then
        incomplete_count=$(jq -r '[.runs | to_entries[] | select(.value.endedAt == null)] | length' "$RUNS_FILE" 2>/dev/null || echo "0")
    fi

    if [ "$incomplete_count" -gt 0 ]; then
        log "Found $incomplete_count incomplete task(s)!"

        # List incomplete tasks
        jq -r '.runs | to_entries[] | select(.value.endedAt == null) | "- \(.value.label // .key): \(.value.task | split("\n")[0])"' "$RUNS_FILE" 2>/dev/null >> "$LOG_FILE"

        # Send notification via Telegram (if configured)
        if command -v clawdbot &> /dev/null; then
            clawdbot message send --to telegram:1997535887 "Clawdbot restarted. Found $incomplete_count incomplete task(s) from before shutdown. Check logs or ask me to resume." 2>/dev/null || true
        fi

        return 1
    else
        log "No incomplete tasks found. All good!"
        return 0
    fi
}

# Check recent session activity
check_sessions() {
    log "Checking recent sessions..."

    local recent_sessions=$(find "$SESSIONS_DIR" -name "*.jsonl" -not -name "*deleted*" -mmin -60 2>/dev/null | wc -l | tr -d ' ')
    log "Found $recent_sessions sessions active in last hour"

    # Check last heartbeat
    if [ -f "$SESSIONS_DIR/sessions.json" ]; then
        local last_heartbeat=$(jq -r '."agent:main:main".lastHeartbeatText // "none"' "$SESSIONS_DIR/sessions.json" 2>/dev/null | head -c 100)
        log "Last heartbeat: $last_heartbeat"
    fi
}

# Main
case "${1:-check}" in
    save)
        save_state
        ;;
    check)
        check_and_resume
        check_sessions
        ;;
    resume)
        check_and_resume
        if [ $? -eq 1 ]; then
            log "Attempting to resume tasks..."
            # This would need clawdbot CLI support for resuming specific tasks
            # For now, just notify
            log "Manual resume required - tasks logged above"
        fi
        ;;
    *)
        echo "Usage: $0 {save|check|resume}"
        exit 1
        ;;
esac
