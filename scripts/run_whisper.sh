#!/bin/bash

# 1. Force a clean environment (Fixes Segfaults)
unset LD_LIBRARY_PATH
unset PYTHONPATH

# 2. Force X11 backend (Fixes GUI crashes on some systems)
export GDK_BACKEND=x11

# 3. Kill any zombie instances of the script to prevent conflicts
pkill -f "whisper_local.py"

# 4. Run the Python script
# Replace with the actual path to your python and script
/usr/bin/python3 ~/.config/scripts/whisper_local.py
