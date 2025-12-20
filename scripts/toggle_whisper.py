#!/usr/bin/env python3

import os
import signal
import subprocess
import sys
import time
from faster_whisper import WhisperModel

# --- CONFIGURATION ---
# Path to the folder shown in your tree command
# We use expanduser to safely handle the '~' symbol
MODEL_PATH = os.path.expanduser("~/models/faster-whisper-medium") 
PID_FILE = "/tmp/whisper_rec.pid"
AUDIO_FILE = "/tmp/whisper_audio.wav"

def notify(title, message):
    """Sends a system notification via dunst/notify-send."""
    subprocess.run(["notify-send", "-u", "low", title, message])

def start_recording():
    """Starts ffmpeg in the background to record microphone audio."""
    # 16kHz mono audio is optimal for Whisper
    cmd = [
        "ffmpeg",
        "-f", "pulse",    # Use PulseAudio (standard on Ubuntu 22)
        "-i", "default",  # Default microphone
        "-ac", "1",       # Mono channel
        "-ar", "16000",   # 16000 Hz sample rate
        "-y",             # Overwrite output file
        AUDIO_FILE
    ]
    
    # Start process silently (stderr to devnull to avoid log spam)
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # Save the PID so we can kill it later
    with open(PID_FILE, "w") as f:
        f.write(str(proc.pid))
        
    notify("Whisper", "Recording started... (Run again to stop)")

def stop_and_transcribe():
    """Stops the recording, transcribes locally, and outputs text."""
    if not os.path.exists(PID_FILE):
        notify("Error", "No recording active.")
        return

    # 1. Stop Recording
    try:
        with open(PID_FILE, "r") as f:
            pid = int(f.read().strip())
        
        # Send SIGTERM to ffmpeg to stop gracefully
        os.kill(pid, signal.SIGTERM)
        
        # Wait a split second to ensure file writes finish
        time.sleep(0.5)
    except (ProcessLookupError, ValueError):
        pass # Process might have already died
    finally:
        if os.path.exists(PID_FILE):
            os.remove(PID_FILE)

    notify("Whisper", "Transcribing...")

    # 2. Transcribe using Local Model
    try:
        # Load model from your local folder
        # device="cpu" is safer, change to "cuda" if you have an NVIDIA GPU set up
        model = WhisperModel(MODEL_PATH, device="cpu", compute_type="int8")
        
        segments, info = model.transcribe(AUDIO_FILE, beam_size=5)
        
        text_output = " ".join([segment.text for segment in segments]).strip()
        
        if not text_output:
            notify("Whisper", "No speech detected.")
            return

        # 3. Output to Clipboard
        # We pipe the text into xclip
        p = subprocess.Popen(['xclip', '-selection', 'clipboard'], stdin=subprocess.PIPE)
        p.communicate(input=text_output.encode('utf-8'))

        # 4. Output to Cursor
        # xdotool types the text. --delay 10 helps prevent missed characters
        subprocess.run(["xdotool", "type", "--delay", "10", text_output])
        
        notify("Whisper", "Done!")

    except Exception as e:
        notify("Error", f"Failed: {str(e)}")

if __name__ == "__main__":
    if os.path.exists(PID_FILE):
        stop_and_transcribe()
    else:
        start_recording()
