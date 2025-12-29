import json
import os
import tempfile
from typing import List
from kitty.boss import Boss

# Where we store the snapshot
SNAPSHOT_FILE = os.path.expanduser("~/.config/kitty/snapshot.json")

def main(args: List[str]) -> str:
    # This function routes the command line arguments
    if len(args) == 0:
        return "Please specify 'save' or 'load'"
    return args[0]

def handle_result(args: List[str], answer: str, target_window_id: int, boss: Boss) -> None:
    if answer == "save":
        save_state(boss)
    elif answer == "load":
        restore_state(boss)
    else:
        print("Usage: kitten snapshot.py [save|load]")

def save_state(boss: Boss):
    window = boss.active_window
    if not window:
        return

    # 1. Capture Environment
    # Note: We only get env vars known to Kitty, or initial vars. 
    # Internal shell vars (like specific aliases) cannot be grabbed easily.
    env = window.child.environ if hasattr(window.child, 'environ') else {}

    # 2. Capture History with Colors (ANSI)
    # as_ansi=True keeps the colors.
    history = window.as_text(as_ansi=True, add_history=True)

    data = {
        "cwd": window.cwd_of_child,
        "cmdline": window.child.cmdline,
        "env": env,
        "history": history
    }

    with open(SNAPSHOT_FILE, 'w') as f:
        json.dump(data, f, indent=2)

    window.write_to_child(f"\n[Snapshot] Saved state to {SNAPSHOT_FILE}!\n")

def restore_state(boss: Boss):
    if not os.path.exists(SNAPSHOT_FILE):
        boss.active_window.paste_text("\n[Snapshot] No saved state found.\n")
        return

    with open(SNAPSHOT_FILE, 'r') as f:
        data = json.load(f)

    # 1. Prepare the history replay file
    # We write the history to a temp file so we can 'cat' it later
    fd, history_path = tempfile.mkstemp()
    with os.fdopen(fd, 'w') as tmp:
        tmp.write(data["history"])

    # 2. Create a NEW OS Window (A fresh terminal instance)
    # We pass the CWD directly here
    new_win_id = boss.call_remote_control(
        window=None, 
        payload={
            "cmd": "new-window",
            "type": "os-window", 
            "cwd": data["cwd"]
        }
    )
    
    # Getting the window object requires searching for the ID we just got.
    # Because call_remote_control returns the ID as a string.
    new_window = boss.window_id_map.get(int(new_win_id))

    if not new_window:
        return

    # 3. Restore Environment Variables
    # We have to inject them as export commands because the shell is already starting.
    # We skip common system vars to avoid breaking things.
    ignore_vars = {"PWD", "SHLVL", "_", "TERM", "HOME", "PATH"}
    for k, v in data["env"].items():
        if k not in ignore_vars:
            # We assume a POSIX shell (bash/zsh)
            new_window.write_to_child(f"export {k}='{v}'\r")

    # 4. Replay History
    # We use 'cat' to print the old history to the screen, then remove the temp file.
    # We add 'clear' first to wipe the "export" commands we just typed from view.
    cmd = f"clear && cat {history_path} && rm {history_path}\r"
    new_window.write_to_child(cmd)

    # 5. Optional: Restore the running command?
    # Usually dangerous to auto-run commands, but we can print the cmdline for user reference
    original_cmd = " ".join(data["cmdline"])
    # Just print it to prompt (without \r) so user can hit enter if they want
    if "sh" not in original_cmd and "bash" not in original_cmd and "zsh" not in original_cmd:
        new_window.write_to_child(f"# Previous command was: {original_cmd}")
