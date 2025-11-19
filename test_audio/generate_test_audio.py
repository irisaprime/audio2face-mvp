#!/usr/bin/env python3
"""
Generate test audio files for Audio2Face MVP
"""
import numpy as np
import soundfile as sf

def generate_sine_wave(duration=3.0, frequency=440, sample_rate=16000):
    """Generate a simple sine wave (A note)"""
    t = np.linspace(0, duration, int(sample_rate * duration))
    audio = 0.5 * np.sin(2 * np.pi * frequency * t)
    return audio, sample_rate

def generate_speech_like_audio(duration=3.0, sample_rate=16000):
    """Generate speech-like audio with varying frequencies"""
    t = np.linspace(0, duration, int(sample_rate * duration))

    # Combine multiple frequencies to simulate speech
    audio = (
        0.3 * np.sin(2 * np.pi * 200 * t) +  # Base frequency
        0.2 * np.sin(2 * np.pi * 400 * t) +  # First harmonic
        0.1 * np.sin(2 * np.pi * 800 * t) +  # Second harmonic
        0.05 * np.random.randn(len(t))       # Noise
    )

    # Add amplitude modulation to simulate speech patterns
    modulation = 0.5 + 0.5 * np.sin(2 * np.pi * 5 * t)
    audio = audio * modulation

    # Normalize
    audio = audio / np.max(np.abs(audio))

    return audio, sample_rate

def main():
    print("Generating test audio files...")

    # Generate simple sine wave
    audio1, sr1 = generate_sine_wave(duration=3.0)
    sf.write('sample_sine.wav', audio1, sr1, subtype='PCM_16')
    print("✓ Created: sample_sine.wav (3s sine wave)")

    # Generate speech-like audio
    audio2, sr2 = generate_speech_like_audio(duration=5.0)
    sf.write('sample_speech_like.wav', audio2, sr2, subtype='PCM_16')
    print("✓ Created: sample_speech_like.wav (5s speech-like)")

    # Generate short test
    audio3, sr3 = generate_sine_wave(duration=1.0, frequency=523)  # C note
    sf.write('sample_short.wav', audio3, sr3, subtype='PCM_16')
    print("✓ Created: sample_short.wav (1s short test)")

    print("\nTest audio files generated successfully!")
    print("Use these files to test the Audio2Face system.")

if __name__ == "__main__":
    main()
