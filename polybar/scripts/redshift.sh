#!/bin/bash

# --- Configuration ---
# Your specific location settings
LAT="8.44"
LON="77.01"
# Default Day/Night for Auto Mode
AUTO_DAY="4500"
AUTO_NIGHT="2500"
# Steps for scrolling (in Kelvin)
STEP=250
MIN=1000
MAX=9000

# State file to track mode
STATE_FILE="/tmp/redshift_polybar_state"

# --- Functions ---

get_temp() {
    # Try to grab the current temp from redshift output
    # Use a more flexible pattern to match 3-5 digit temperatures
    redshift -p 2>/dev/null | grep "Color temperature" | grep -oE "[0-9]{3,5}" | head -n1
}

check_status() {
    if pgrep -x "redshift" > /dev/null; then
        echo "on"
    else
        echo "off"
    fi
}

get_mode() {
    # Read the mode from state file (auto or manual)
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "auto"
    fi
}

set_mode() {
    echo "$1" > "$STATE_FILE"
}

# --- Handle User Actions ---

case "$1" in
    status)
        STATUS=$(check_status)
        if [ "$STATUS" = "on" ]; then
            TEMP=$(get_temp)
            MODE=$(get_mode)
            
            if [ -z "$TEMP" ]; then
                # Can't get temperature, show generic on status
                echo "%{F#F9E2AF} On%{F-}"
            else
                # Show Temperature with K suffix
                if [ "$MODE" = "manual" ]; then
                    # Manual mode indicator
                    echo "%{F#F9E2AF} ${TEMP}K [M]%{F-}"
                else
                    # Auto mode
                    echo "%{F#F9E2AF} ${TEMP}K%{F-}"
                fi
            fi
        else
            echo "%{F#585B70} Off%{F-}"
        fi
        ;;

    toggle)
        if [ "$(check_status)" = "on" ]; then
            # Kill redshift and clear state
            pkill -x redshift
            rm -f "$STATE_FILE"
        else
            # Start in Auto mode
            pkill -x redshift  # Ensure clean state
            sleep 0.2
            redshift -l $LAT:$LON -t $AUTO_DAY:$AUTO_NIGHT -m randr &
            set_mode "auto"
        fi
        ;;

    auto)
        # Switch to automatic mode
        pkill -x redshift
        sleep 0.3
        redshift -l $LAT:$LON -t $AUTO_DAY:$AUTO_NIGHT -m randr &
        set_mode "auto"
        ;;

    increase|decrease)
        # Get current numeric temp or default
        CURRENT=$(get_temp)
        
        # If we can't get current temp or redshift is off, start with default
        if [ -z "$CURRENT" ] || [ "$(check_status)" = "off" ]; then
            CURRENT=4500
        fi

        # Calculate new temp
        if [ "$1" = "increase" ]; then
            NEW=$((CURRENT + STEP))
        else
            NEW=$((CURRENT - STEP))
        fi

        # Clamp values
        if [ "$NEW" -gt "$MAX" ]; then NEW=$MAX; fi
        if [ "$NEW" -lt "$MIN" ]; then NEW=$MIN; fi

        # Kill any running redshift first
        pkill -x redshift
        sleep 0.2

        # Apply Manual Mode with one-shot command
        # Using -P to clear existing adjustments, -O for one-shot temp
        redshift -P -O $NEW -m randr
        
        # Mark as manual mode
        set_mode "manual"
        ;;

    *)
        echo "Usage: $0 {status|toggle|auto|increase|decrease}"
        exit 1
        ;;
esac
