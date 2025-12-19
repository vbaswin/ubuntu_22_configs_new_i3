#!/usr/bin/env python3
import os
import sys
import time
import signal
import subprocess
import logging
import gc
import tkinter as tk
from threading import Thread

# --- Configuration ---
WAVFILE = "/tmp/voice_record_gui.wav"
# Point to your local model folder
MODEL_PATH = os.path.expanduser("~/models/faster-whisper-medium")

logging.basicConfig(level=logging.INFO, format="[%(levelname)s] %(message)s")

recording_process = None

class RecordingGUI:
    def __init__(self):
        # 1. SAFETY: Kill any left-over ffmpeg processes from previous crashes
        subprocess.run(["pkill", "-f", WAVFILE], stderr=subprocess.DEVNULL)

        self.root = tk.Tk()
        self.root.title("Voice Recorder")
        self.root.geometry("400x200")
        self.root.configure(bg="#2b2b2b")
        self.root.attributes("-topmost", True)
        
        # UI Setup
        self.status_label = tk.Label(
            self.root, 
            text="⏳ STARTING...", 
            font=("Arial", 24, "bold"), 
            bg="#2b2b2b", 
            fg="#cccccc"
        )
        self.status_label.pack(expand=True)
        
        self.instruction_label = tk.Label(
            self.root, 
            text="Initializing audio driver...", 
            font=("Arial", 12), 
            bg="#2b2b2b", 
            fg="#888888"
        )
        self.instruction_label.pack(pady=(0, 20))
        
        self.root.bind("<Return>", self.on_enter_pressed)
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)
        
        self.transcribing = False
        
        # Start recording in a non-daemon thread so we can manage it
        Thread(target=self.background_start_recording, daemon=True).start()

    def background_start_recording(self):
        global recording_process
        
        if os.path.exists(WAVFILE):
            try: os.remove(WAVFILE)
            except: pass

        # Using ALSA as it successfully detected audio in your logs
        cmd = [
            "ffmpeg", "-y", "-f", "alsa", "-i", "default",
            "-ac", "1", "-ar", "16000", "-vn", WAVFILE
        ]
        
        try:
            recording_process = subprocess.Popen(
                cmd,
                stdout=subprocess.DEVNULL,
                stderr=sys.stderr,
                start_new_session=True
            )
            logging.info(f"Recording started (pid {recording_process.pid})")
            self.root.after(0, self.update_gui_recording_started)
            
        except Exception as e:
            logging.error(f"Start failed: {e}")
            self.root.after(0, lambda: self.show_error(f"Mic Error: {e}"))

    def update_gui_recording_started(self):
        self.status_label.config(text="🎤 RECORDING", fg="#ff4444")
        self.instruction_label.config(text="Press ENTER to stop and transcribe", fg="#cccccc")

    def on_enter_pressed(self, event=None):
        if not self.transcribing:
            self.transcribing = True
            self.status_label.config(text="⏳ Processing...", fg="#ffaa00")
            self.instruction_label.config(text="Loading local model...")
            self.root.update()
            
            # Start transcription thread
            # We do NOT use daemon=True here so it finishes cleanly before exit
            Thread(target=self.stop_and_transcribe).start()
    
    def stop_and_transcribe(self):
        global recording_process
        
        # 1. Stop Recording
        if recording_process:
            try:
                os.kill(recording_process.pid, signal.SIGINT)
                # Wait for ffmpeg to actually release the file
                for _ in range(50):
                    if recording_process.poll() is not None: break
                    time.sleep(0.1)
            except: pass
        
        # 2. Transcribe
        try:
            if os.path.exists(WAVFILE) and os.path.getsize(WAVFILE) > 4000:
                from faster_whisper import WhisperModel
                
                # Check for local model
                if not os.path.exists(MODEL_PATH):
                     # Fallback to download if local path is wrong, but warn user
                     logging.warning(f"Local path {MODEL_PATH} not found, downloading...")
                     model = WhisperModel("medium", device="cpu", compute_type="int8")
                else:
                     model = WhisperModel(MODEL_PATH, device="cpu", compute_type="int8", local_files_only=True)

                segments, _ = model.transcribe(WAVFILE, beam_size=5)
                text = " ".join([s.text for s in segments]).strip()
                
                logging.info(f"Result: {text}")
                
                # Paste
                self.paste_text(text)
                self.root.after(0, lambda: self.show_success(text))

                # CRITICAL FIX: Explicitly delete model to prevent C++ crash on exit
                del model
                gc.collect() 

            else:
                self.root.after(0, lambda: self.show_error("No audio recorded"))
                
        except Exception as e:
            logging.error(f"Transcription error: {e}")
            self.root.after(0, lambda: self.show_error(str(e)))
            
        time.sleep(1.0)
        self.root.after(0, self.quit_app)

    def paste_text(self, text):
        try:
            # Try xclip first
            p = subprocess.Popen(["xclip", "-selection", "clipboard"], stdin=subprocess.PIPE)
            p.communicate(input=text.encode('utf-8'))
            subprocess.run(["xdotool", "key", "--clearmodifiers", "ctrl+v"])
        except:
            logging.error("Paste failed")

    def show_success(self, text):
        self.status_label.config(text="✓ Done!", fg="#44ff44")
        self.instruction_label.config(text=text[:40] + "...")

    def show_error(self, msg):
        self.status_label.config(text="Error", fg="red")
        self.instruction_label.config(text=msg)

    def on_close(self):
        # Handle X button click
        global recording_process
        if recording_process:
            try: os.kill(recording_process.pid, signal.SIGKILL)
            except: pass
        self.quit_app()

    def quit_app(self):
        self.root.quit()
        self.root.destroy()
        sys.exit(0)

    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    gui = RecordingGUI()
    gui.run()
