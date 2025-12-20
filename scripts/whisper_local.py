#!/usr/bin/env python3
import os
import signal
import subprocess
import time
import socket 

# --- CONFIGURATION ---
PID_FILE = "/tmp/whisper_rec.pid"
AUDIO_FILE = "/tmp/whisper_audio.wav"
HOST = '127.0.0.1'
PORT = 65432

def notify(title, message):
    subprocess.run(["notify-send", "-u", "low", title, message])

def start_recording():
    cmd = [
        "ffmpeg", "-f", "pulse", "-i", "default", "-ac", "1",
        "-ar", "16000", "-y", AUDIO_FILE
    ]
    proc = subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    with open(PID_FILE, "w") as f:
        f.write(str(proc.pid))
    print("Recording started...")
    notify("Whisper", "Recording started...")

def stop_and_transcribe():
    if not os.path.exists(PID_FILE):
        print("No recording active.")
        return

    # 1. Stop Recording
    try:
        with open(PID_FILE, "r") as f:
            pid = int(f.read().strip())
        os.kill(pid, signal.SIGTERM)
        # Give ffmpeg a moment to close the file handle properly
        time.sleep(0.5) 
    except (ProcessLookupError, ValueError):
        pass
    finally:
        if os.path.exists(PID_FILE):
            os.remove(PID_FILE)

    print("Requesting transcription...")
    notify("Whisper", "Transcribing...")

    # 2. Connect to Daemon
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            # TIMEOUT REMOVED for long recordings
            s.connect((HOST, PORT))
            s.sendall(b"transcribe")
            
            # Increased buffer size for very long text
            # We loop to receive all data if it's massive
            fragments = []
            while True:
                chunk = s.recv(4096)
                if not chunk:
                    break
                fragments.append(chunk)
            
            text_output = b"".join(fragments).decode('utf-8')

        if not text_output:
            print("No speech detected.")
            notify("Whisper", "No speech detected.")
            return

        # 3. Output
        print(f"Transcribed: {text_output}")
        p = subprocess.Popen(['xclip', '-selection', 'clipboard'], stdin=subprocess.PIPE)
        p.communicate(input=text_output.encode('utf-8'))
        subprocess.run(["xdotool", "type", "--delay", "10", text_output])
        notify("Whisper", "Done!")

    except ConnectionRefusedError:
        print("ERROR: Daemon not running. Run whisper_daemon.py first.")
        notify("Error", "Daemon not running!")
    except Exception as e:
        print(f"Error: {e}")
        notify("Error", f"Failed: {str(e)}")

if __name__ == "__main__":
    if os.path.exists(PID_FILE):
        stop_and_transcribe()
    else:
        start_recording()
