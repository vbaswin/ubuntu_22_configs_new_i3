#!/bin/bash

# ==============================================================================
# Redshift Polybar Controller (Fixed)
# - Uses state files for reliable tracking
# - Manual mode persists screen tint without daemon
# ==============================================================================

# --- Configuration ---
LAT="8.44"
LON="77.01"
AUTO_DAY="3500"
AUTO_NIGHT="2500"
STEP=100
MIN=1000
MAX=9000

# --- State Files ---
# ACTIVE_FILE: "on" or "off" - tracks if redshift effect is active
# MODE_FILE: "auto" or "manual"
# TEMP_FILE: current temperature value
STATE_DIR="/tmp/redshift_polybar"
ACTIVE_FILE="$STATE_DIR/active"
MODE_FILE="$STATE_DIR/mode"
TEMP_FILE="$STATE_DIR/temp"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# --- Functions ---

is_active() {
    [ -f "$ACTIVE_FILE" ] && [ "$(cat "$ACTIVE_FILE")" = "on" ] && echo "on" || echo "off"
}

set_active() {
    echo "$1" >"$ACTIVE_FILE"
}

get_mode() {
    [ -f "$MODE_FILE" ] && cat "$MODE_FILE" || echo "auto"
}

set_mode() {
    echo "$1" >"$MODE_FILE"
}

get_temp() {
    [ -f "$TEMP_FILE" ] && cat "$TEMP_FILE" || echo "$AUTO_DAY"
}

set_temp() {
    echo "$1" >"$TEMP_FILE"
}

# Check if redshift daemon is running (for auto mode)
daemon_running() {
    pgrep -x "redshift" >/dev/null && echo "yes" || echo "no"
}

# --- Main Logic ---

case "$1" in
status)
    if [ "$(is_active)" = "on" ]; then
        TEMP=$(get_temp)
        MODE=$(get_mode)
        if [ "$MODE" = "manual" ]; then
            echo "%{F#F9E2AF} ${TEMP}K [M]%{F-}"
        else
            echo "%{F#F9E2AF} ${TEMP}K%{F-}"
        fi
    else
        echo "%{F#585B70} Off%{F-}"
    fi
    ;;

toggle)
    if [ "$(is_active)" = "on" ]; then
        # Turn OFF
        pkill -x redshift 2>/dev/null
        redshift -x 2>/dev/null # Reset screen to normal
        set_active "off"
        rm -f "$MODE_FILE" "$TEMP_FILE"
    else
        # Turn ON in auto mode
        pkill -x redshift 2>/dev/null
        sleep 0.2
        redshift -l "$LAT:$LON" -t "$AUTO_DAY:$AUTO_NIGHT" -m randr &
        set_active "on"
        set_mode "auto"
        set_temp "$AUTO_DAY"
    fi
    ;;

auto)
    # Switch to auto mode
    pkill -x redshift 2>/dev/null
    sleep 0.2
    redshift -l "$LAT:$LON" -t "$AUTO_DAY:$AUTO_NIGHT" -m randr &
    set_active "on"
    set_mode "auto"
    set_temp "$AUTO_DAY"
    ;;

increase | decrease)
    CURRENT=$(get_temp)

    if [ "$1" = "increase" ]; then
        NEW=$((CURRENT + STEP))
    else
        NEW=$((CURRENT - STEP))
    fi

    # Clamp values
    [ "$NEW" -gt "$MAX" ] && NEW=$MAX
    [ "$NEW" -lt "$MIN" ] && NEW=$MIN

    # Kill any running daemon
    pkill -x redshift 2>/dev/null
    sleep 0.1

    # Apply one-shot temperature (persists even after redshift exits)
    redshift -P -O "$NEW" -m randr

    # Update state
    set_active "on"
    set_mode "manual"
    set_temp "$NEW"
    ;;

*)
    echo "Usage: $0 {status|toggle|auto|increase|decrease}"
    exit 1
    ;;
esac
