from pathlib import Path

class Config:
    # Paths
    SDK_PATH = Path("../Audio2Face-3D-SDK/_build/audio2x-sdk/lib")
    MODEL_PATH = Path("../Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0")
    TEMP_DIR = Path("./temp")

    # Audio settings
    SAMPLE_RATE = 16000
    AUDIO_FORMAT = "PCM_16"
    CHANNELS = 1  # Mono

    # Animation settings
    FPS = 30
    BLENDSHAPE_COUNT = 72  # Audio2Face outputs 72 blendshapes

    # Server settings
    HOST = "0.0.0.0"
    PORT = 8000

    def __init__(self):
        self.TEMP_DIR.mkdir(exist_ok=True)

config = Config()
