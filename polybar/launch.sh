#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Launch Polybar
echo "---" | tee -a /home/vbaswin/.gemini/tmp/polybar.log
polybar -c /home/vbaswin/.config/polybar/config.ini main 2>&1 | tee -a /home/vbaswin/.gemini/tmp/polybar.log & disown

echo "Polybar launched..."
