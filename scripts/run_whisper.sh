#!/bin/bash
# 1. Unset CUDA libraries to prevent segfaults
export LD_LIBRARY_PATH=""

# 2. Force X11 backend for Tkinter
export GDK_BACKEND=x11

# 3. Run the python script (using absolute path)
/usr/bin/python3 $HOME/.config/scripts/whisper_local.py
