#!/usr/bin/env python3
import os
import socket
import traceback
from faster_whisper import WhisperModel

# --- CONFIG ---
MODEL_PATH = os.path.expanduser("~/models/faster-whisper-medium")
AUDIO_FILE = "/tmp/whisper_audio.wav"
HOST = '127.0.0.1'
PORT = 65432

def main():
    print(f"Loading model from {MODEL_PATH}...")
    # Change device="cuda" if you have a GPU
    model = WhisperModel(MODEL_PATH, device="cpu", compute_type="int8")
    print("Model loaded. Waiting for requests...")

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        s.bind((HOST, PORT))
        s.listen()
        
        while True:
            try:
                conn, addr = s.accept()
                with conn:
                    data = conn.recv(1024)
                    if data == b"transcribe":
                        print("Request received...")
                        
                        if os.path.exists(AUDIO_FILE):
                            try:
                                # Transcribe
                                segments, _ = model.transcribe(AUDIO_FILE, beam_size=1)
                                text = " ".join([segment.text for segment in segments]).strip()
                                print(f"Transcribed: {text[:50]}...") # Print first 50 chars log
                                conn.sendall(text.encode('utf-8'))
                            except Exception as e:
                                print(f"Transcription Error: {e}")
                                conn.sendall(b"Error during transcription")
                        else:
                            print("Audio file missing.")
                            conn.sendall(b"")
            except Exception as e:
                # This catches network/connection errors so the daemon doesn't die
                print(f"Connection Error: {e}")
                traceback.print_exc()

if __name__ == "__main__":
    main()
