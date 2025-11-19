import ctypes
import numpy as np
from pathlib import Path
from typing import Dict, List
from config import config
import sys

class Audio2FaceSDK:
    """Python wrapper for Audio2Face-3D C++ SDK"""

    def __init__(self):
        # Load shared library
        if config.SDK_PATH.exists():
            lib_name = "audio2face-sdk.dll" if sys.platform == "win32" else "libaudio2face-sdk.so"
            lib_path = config.SDK_PATH / lib_name
            if lib_path.exists():
                self.lib = ctypes.CDLL(str(lib_path))
            else:
                raise FileNotFoundError(f"SDK library not found at {lib_path}")
        else:
            raise FileNotFoundError(f"SDK path not found at {config.SDK_PATH}")

        # Initialize SDK
        self._setup_function_signatures()
        self._initialize_model()

    def _setup_function_signatures(self):
        """Setup C function signatures"""
        # Initialize model
        self.lib.a2f_init.argtypes = [ctypes.c_char_p]
        self.lib.a2f_init.restype = ctypes.c_int

        # Process audio
        self.lib.a2f_process.argtypes = [
            np.ctypeslib.ndpointer(dtype=np.float32),
            ctypes.c_int,
            ctypes.POINTER(ctypes.c_float),
            ctypes.POINTER(ctypes.c_int)
        ]
        self.lib.a2f_process.restype = ctypes.c_int

        # Cleanup
        self.lib.a2f_cleanup.argtypes = []
        self.lib.a2f_cleanup.restype = None

    def _initialize_model(self):
        """Initialize Audio2Face model"""
        model_path = str(config.MODEL_PATH).encode('utf-8')
        result = self.lib.a2f_init(model_path)
        if result != 0:
            raise RuntimeError(f"Failed to initialize Audio2Face SDK: {result}")
        print(f"✓ Audio2Face-3D-v3.0 model loaded from {config.MODEL_PATH}")

    def process_audio(self, audio: np.ndarray) -> Dict:
        """
        Process audio and return blendshapes

        Returns:
            {
                'blendshapes': np.ndarray,  # Shape: (num_frames, 72)
                'timestamps': np.ndarray,   # Shape: (num_frames,)
                'fps': int,
                'duration': float
            }
        """
        # Ensure float32
        audio = audio.astype(np.float32)

        # Allocate output buffer
        num_frames = int(len(audio) / config.SAMPLE_RATE * config.FPS) + 1
        blendshapes = np.zeros((num_frames, config.BLENDSHAPE_COUNT), dtype=np.float32)
        actual_frames = ctypes.c_int(0)

        # Call SDK
        result = self.lib.a2f_process(
            audio,
            len(audio),
            blendshapes.ctypes.data_as(ctypes.POINTER(ctypes.c_float)),
            ctypes.byref(actual_frames)
        )

        if result != 0:
            raise RuntimeError(f"Audio2Face processing failed: {result}")

        # Trim to actual frames
        blendshapes = blendshapes[:actual_frames.value]

        # Generate timestamps
        timestamps = np.arange(actual_frames.value) / config.FPS

        return {
            'blendshapes': blendshapes,
            'timestamps': timestamps,
            'fps': config.FPS,
            'duration': timestamps[-1] if len(timestamps) > 0 else 0.0
        }

    def get_blendshape_names(self) -> List[str]:
        """Get ARKit blendshape names"""
        # Audio2Face outputs 72 blendshapes
        # First 52 are standard ARKit, rest are additional
        arkit_names = [
            "eyeBlinkLeft", "eyeLookDownLeft", "eyeLookInLeft", "eyeLookOutLeft",
            "eyeLookUpLeft", "eyeSquintLeft", "eyeWideLeft", "eyeBlinkRight",
            "eyeLookDownRight", "eyeLookInRight", "eyeLookOutRight", "eyeLookUpRight",
            "eyeSquintRight", "eyeWideRight", "jawForward", "jawLeft", "jawRight",
            "jawOpen", "mouthClose", "mouthFunnel", "mouthPucker", "mouthLeft",
            "mouthRight", "mouthSmileLeft", "mouthSmileRight", "mouthFrownLeft",
            "mouthFrownRight", "mouthDimpleLeft", "mouthDimpleRight", "mouthStretchLeft",
            "mouthStretchRight", "mouthRollLower", "mouthRollUpper", "mouthShrugLower",
            "mouthShrugUpper", "mouthPressLeft", "mouthPressRight", "mouthLowerDownLeft",
            "mouthLowerDownRight", "mouthUpperUpLeft", "mouthUpperUpRight", "browDownLeft",
            "browDownRight", "browInnerUp", "browOuterUpLeft", "browOuterUpRight",
            "cheekPuff", "cheekSquintLeft", "cheekSquintRight", "noseSneerLeft",
            "noseSneerRight", "tongueOut"
        ]

        # Add Audio2Face specific blendshapes (52-72)
        additional = [f"a2f_extra_{i}" for i in range(config.BLENDSHAPE_COUNT - 52)]

        return arkit_names + additional

    def __del__(self):
        """Cleanup SDK"""
        if hasattr(self, 'lib'):
            self.lib.a2f_cleanup()
