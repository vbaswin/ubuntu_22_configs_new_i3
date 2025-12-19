#!/usr/bin/env python3
"""
whisper_gui.py - Simple GUI-based voice recorder with transcription
- Opens GUI when started
- Records audio continuously
- Press Enter to stop, transcribe, and paste
- Forces CPU-only (no CUDA issues)
"""

import os
import sys
import time
import signal
import subprocess
import logging
import tkinter as tk
from pathlib import Path
from threading import Thread

# Logging
LOGFILE = "/tmp/voice_gui.log"
logging.basicConfig(
    level=logging.INFO,
    format="[%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(LOGFILE),
        logging.StreamHandler(sys.stdout)
    ]
)

# File paths
WAVFILE = "/tmp/voice_record_gui.wav"
TRIMMED_WAV = "/tmp/voice_record_gui_trim.wav"
KEEP_AUDIO = os.environ.get("KEEP_AUDIO", "0") == "1"

# Model configuration - FORCE CPU
FALLBACK_MODEL = os.environ.get("WHISPER_MODEL", "medium")
FALLBACK_MODEL_PATH = os.path.expanduser(
    os.environ.get("WHISPER_MODEL_PATH", "~/models/faster-whisper-medium")
)
FALLBACK_BEAM = int(os.environ.get("BEAM_SIZE", "5"))

# Global variables
recording_process = None


class RecordingGUI:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Voice Recorder")
        
        # Window configuration
        self.root.geometry("400x200")
        self.root.configure(bg="#2b2b2b")
        self.root.resizable(False, False)
        
        # Make window stay on top
        self.root.attributes("-topmost", True)
        
        # Status label
        self.status_label = tk.Label(
            self.root,
            text="🎤 RECORDING",
            font=("Arial", 24, "bold"),
            bg="#2b2b2b",
            fg="#ff4444"
        )
        self.status_label.pack(expand=True)
        
        # Instructions
        self.instruction_label = tk.Label(
            self.root,
            text="Press ENTER to stop and transcribe",
            font=("Arial", 12),
            bg="#2b2b2b",
            fg="#cccccc"
        )
        self.instruction_label.pack(pady=(0, 20))
        
        # Bind Enter key
        self.root.bind("<Return>", self.on_enter_pressed)
        
        # Handle window close
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)
        
        self.transcribing = False
        
    def on_enter_pressed(self, event=None):
        if not self.transcribing:
            self.transcribing = True
            self.status_label.config(text="⏳ Processing...", fg="#ffaa00")
            self.instruction_label.config(text="Transcribing audio, please wait...")
            self.root.update()
            
            # Stop recording and transcribe in thread
            Thread(target=self.stop_and_transcribe, daemon=True).start()
    
    def on_close(self):
        if recording_process:
            try:
                os.killpg(recording_process.pid, signal.SIGINT)
            except:
                pass
        self.cleanup_files()
        self.root.destroy()
        sys.exit(0)
    
    def stop_and_transcribe(self):
        try:
            # Stop recording
            stop_recording()
            
            # Trim silence
            audio_file = silence_trim(WAVFILE, TRIMMED_WAV)
            
            # Transcribe
            transcript = run_faster_whisper_cpu(
                audio_file,
                model_name=FALLBACK_MODEL,
                model_path=FALLBACK_MODEL_PATH,
                beam_size=FALLBACK_BEAM
            )
            
            final_text = transcript.strip()
            
            if final_text:
                # Copy and paste
                copy_and_paste(final_text)
                logging.info(f"Transcribed: {final_text}")
                
                # Update GUI to show success
                self.root.after(0, lambda: self.show_success(final_text))
            else:
                logging.info("No transcription text produced")
                self.root.after(0, lambda: self.show_error("No speech detected"))
                
        except Exception as e:
            logging.error(f"Transcription failed: {e}")
            self.root.after(0, lambda: self.show_error(str(e)))
        
        # Cleanup and close
        self.cleanup_files()
        time.sleep(1)
        self.root.after(0, self.root.destroy)
    
    def show_success(self, text):
        self.status_label.config(text="✓ Done!", fg="#44ff44")
        preview = text[:50] + "..." if len(text) > 50 else text
        self.instruction_label.config(text=f"Pasted: {preview}")
    
    def show_error(self, error):
        self.status_label.config(text="✗ Error", fg="#ff4444")
        self.instruction_label.config(text=f"Error: {error}")
    
    def cleanup_files(self):
        if not KEEP_AUDIO:
            for f in [WAVFILE, TRIMMED_WAV]:
                try:
                    if os.path.exists(f):
                        os.remove(f)
                except:
                    pass
    
    def run(self):
        self.root.mainloop()

def start_recording():
    """Start FFmpeg recording (Fixed for robustness)"""
    global recording_process
    
    # Remove old file
    if os.path.exists(WAVFILE):
        try:
            os.remove(WAVFILE)
        except OSError:
            pass
    
    # Use the exact command that worked in your manual test
    ffmpeg_cmd = [
        "ffmpeg", "-y",
        "-f", "pulse", "-i", "default",
        "-ac", "1", "-ar", "16000",
        "-vn", WAVFILE
    ]
    
    # Start process with a new session ID to avoid signal conflicts
    recording_process = subprocess.Popen(
        ffmpeg_cmd,
        stdout=subprocess.DEVNULL,  # Keep stdout clean
        stderr=sys.stderr,          # PRINT ERRORS to terminal if it fails
        start_new_session=True      # <--- The Critical Fix
    )
    
    # Wait a split second to ensure it started and created the file
    time.sleep(0.5)
    if recording_process.poll() is not None:
        logging.error("FFmpeg failed to start! Check terminal output above.")
    else:
        logging.info(f"Recording started (pid {recording_process.pid})")

def stop_recording():
    """Stop FFmpeg recording cleanly"""
    global recording_process
    
    if recording_process:
        # Send SIGINT (Ctrl+C) to the specific process
        try:
            os.kill(recording_process.pid, signal.SIGINT)
        except ProcessLookupError:
            pass
        
        # Wait up to 3 seconds for the file to be finalized
        waited = 0.0
        while recording_process.poll() is None and waited < 3.0:
            time.sleep(0.1)
            waited += 0.1
            
        logging.info("Recording stopped")
def silence_trim(input_wav, output_wav):
    """Trim silence from audio"""
    try:
        if not os.path.exists(input_wav):
            logging.warning(f"Input file {input_wav} does not exist")
            return input_wav
            
        if os.path.getsize(input_wav) < 1000:
            logging.warning(f"Input file {input_wav} is too small")
            return input_wav
        
        trim_cmd = [
            "ffmpeg", "-y", "-i", input_wav,
            "-af", "silenceremove=start_periods=1:start_duration=0:start_threshold=-50dB:detection=peak",
            "-ac", "1",
            "-ar", "16000",
            output_wav
        ]
        
        result = subprocess.run(
            trim_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=30
        )
        
        if result.returncode == 0 and os.path.exists(output_wav) and os.path.getsize(output_wav) > 1000:
            logging.info("Silence trim succeeded")
            return output_wav
        else:
            logging.info("Using original file")
            return input_wav
            
    except Exception as e:
        logging.warning(f"Silence trim error: {e}; using original")
        return input_wav


def run_faster_whisper_cpu(audio_file, model_name="medium", model_path=None, beam_size=5):
    """Run faster-whisper with FORCED CPU (no CUDA issues)"""
    logging.info("Starting faster-whisper transcription (CPU ONLY)...")
    
    try:
        from faster_whisper import WhisperModel
    except ImportError as e:
        raise RuntimeError(f"faster-whisper not installed: {e}")
    
    # FORCE CPU - no CUDA
    device = "cpu"
    compute_type = "int8"
    
    logging.info("FORCED CPU MODE - No CUDA")
    
    # Load model
    model = None
    
    # Try local model first
    if model_path and os.path.exists(model_path):
        if os.path.exists(os.path.join(model_path, "model.bin")):
            logging.info(f"Loading local model from: {model_path}")
            try:
                model = WhisperModel(
                    model_path,
                    device=device,
                    compute_type=compute_type
                )
            except Exception as e:
                logging.warning(f"Failed to load local model: {e}")
    
    # Fallback to downloading
    if model is None:
        logging.info(f"Downloading/loading '{model_name}' model...")
        model = WhisperModel(
            model_name,
            device=device,
            compute_type=compute_type,
            download_root=os.path.expanduser("~/models")
        )
    
    # Transcribe
    logging.info(f"Transcribing (device=CPU, compute_type=int8, beam_size={beam_size})...")
    segments, info = model.transcribe(
        audio_file,
        beam_size=beam_size,
        language="en"
    )
    
    # Collect segments
    transcript_parts = []
    for segment in segments:
        transcript_parts.append(segment.text)
    
    result = " ".join(transcript_parts).strip()
    logging.info(f"Language: {info.language} (prob: {info.language_probability:.2f})")
    
    return result


def copy_and_paste(text):
    """Copy to clipboard and paste"""
    try:
        p = subprocess.Popen(
            ["xclip", "-selection", "clipboard"],
            stdin=subprocess.PIPE
        )
        p.communicate(input=text.encode("utf-8"))
        logging.info("Copied to clipboard")
    except Exception as e:
        logging.error(f"Failed to copy: {e}")

    try:
        subprocess.run(
            ["xdotool", "key", "--clearmodifiers", "ctrl+v"],
            check=True
        )
        logging.info("Pasted into focused window")
    except Exception as e:
        logging.error(f"Paste failed: {e}")


if __name__ == "__main__":
    # Start recording
    start_recording()
    
    # Show GUI
    gui = RecordingGUI()
    gui.run()
