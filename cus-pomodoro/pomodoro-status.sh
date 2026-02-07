#!/usr/bin/env bash
# pomodoro_status.sh - Polybar status script

STATE_FILE="/tmp/pomodoro.state"
CONFIG_DIR="$HOME/.config/cus-pomodoro"

# Auto-start daemon if not running
if
    [[ ! -f /tmp/pomodoro.pid ]] || ! kill -0 "$(cat /tmp/pomodoro.pid 2>/dev/null)"
    2>/dev/null
then
    "$CONFIG_DIR/pomodoro" --daemon &>/dev/null &
    sleep 0.2
fi

# Read and format state
if [[ -f "$STATE_FILE" ]]; then
    STATE=$(cat "$STATE_FILE" 2>/dev/null)

    if [[ "$STATE" == running:* ]]; then
        TIME="${STATE#running:}"
        echo "🍅 $TIME"
    else
        echo "break"
    fi
else
    echo "break"
fi
