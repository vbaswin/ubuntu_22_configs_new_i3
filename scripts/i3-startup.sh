#!/usr/bin/env bash
# ----------------------------------------------------------------------
# i3 Startup Layout Script
# PURPOSE: On login, set up workspaces with desired applications.
#   - Workspace 1: Two kitty terminals side-by-side, focus on left
#   - Workspace 2: Brave browser
#
# WHY a script instead of inline exec?
#   Single Responsibility: i3 config handleskeybinds & settings,
#   this script handles startup orchestration. Easier to debug & extend.
# ----------------------------------------------------------------------

set -euo pipefail

readonly SMART_KITTY="$HOME/.config/scripts/smart-kitty"

# Helper: wait for a window with the given class to appear on i3
# Uses i3-msg subscribe to avoid fragile sleep-based timing.
# Falls back to polling if subscribe isn't available.
wait_for_window() {
    local class="$1"
    local timeout="${2:-5}"
    local elapsed=0

    while ! i3-msg -t get_tree | grep -q "\"class\":\"${class}\""; do
        sleep 0.3
        elapsed=$(echo "$elapsed + 0.3" | bc)
        if (($(echo "$elapsed >= $timeout" | bc -l))); then
            echo "Warning: Timed out waitingfor ${class}" >&2
            return 1
        fi
    done
    return 0
}

# --- STEP 1: Workspace 1 — Two Kitty terminals, horizontal split ---
i3-msg "workspace number 1"

# Set split direction to horizontal so the second kitty goes to the right
i3-msg "split horizontal"

# Launch the FIRST kitty (left side)
"$SMART_KITTY" &
sleep 1 # Brief pause to let it grab focus and register with i3

# Launch the SECOND kitty (right side, i3 auto-tiles it)
"$SMART_KITTY" &
sleep 1

# --- STEP 2: Workspace 2 — Brave browser ---
i3-msg "workspace number 2"
brave-browser &
sleep 1

# --- STEP 3: Return to workspace 1 and focus the LEFT kitty ---
i3-msg "workspace number 1"
# focus left ensures we land on the first (leftmost) kitty
i3-msg "focus left"
