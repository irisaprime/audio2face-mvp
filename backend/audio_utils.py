import numpy as np
import soundfile as sf
import librosa
from pathlib import Path
from config import config

class AudioProcessor:
    """Handle audio file processing for Audio2Face"""

    @staticmethod
    def load_and_preprocess(audio_path: str) -> tuple[np.ndarray, int]:
        """
        Load audio and convert to Audio2Face format:
        - 16kHz sample rate
        - Mono channel
        - 16-bit PCM
        """
        # Load audio
        audio, sr = librosa.load(audio_path, sr=None, mono=False)

        # Convert to mono if stereo
        if audio.ndim > 1:
            audio = librosa.to_mono(audio)

        # Resample to 16kHz if needed
        if sr != config.SAMPLE_RATE:
            audio = librosa.resample(audio, orig_sr=sr, target_sr=config.SAMPLE_RATE)

        # Normalize to [-1, 1]
        if np.max(np.abs(audio)) > 0:
            audio = audio / np.max(np.abs(audio))

        return audio, config.SAMPLE_RATE

    @staticmethod
    def save_processed(audio: np.ndarray, output_path: str):
        """Save processed audio as 16-bit PCM WAV"""
        sf.write(output_path, audio, config.SAMPLE_RATE, subtype='PCM_16')

    @staticmethod
    def get_duration(audio: np.ndarray, sr: int) -> float:
        """Get audio duration in seconds"""
        return len(audio) / sr
