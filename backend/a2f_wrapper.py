"""
Audio2Face SDK Python Wrapper
Uses PyBind11 bindings for Audio2Face-3D SDK
"""

import numpy as np
from pathlib import Path
from typing import Dict, List
from config import config
import sys

class Audio2FaceSDK:
    """Python wrapper for Audio2Face-3D SDK using PyBind11 bindings"""

    def __init__(self, character_index: int = 0, use_gpu_solver: bool = False):
        """
        Initialize Audio2Face SDK

        Args:
            character_index: Character to use (0=Claire, 1=James, 2=Mark)
            use_gpu_solver: Use GPU for blendshape solving (default: False for CPU)
        """
        self.character_index = character_index
        self.use_gpu_solver = use_gpu_solver
        self.model_loaded = False
        self.bundle = None

        try:
            # Import PyBind11 module
            import audio2face_py
            self.a2f = audio2face_py

            # Load model
            model_path = str(config.MODEL_PATH / "model.json")
            if not Path(model_path).exists():
                raise FileNotFoundError(f"Model not found at {model_path}")

            print(f"Loading Audio2Face model from: {model_path}")
            print(f"Character: {self._get_character_name(character_index)}")
            print(f"GPU Solver: {use_gpu_solver}")

            # Create blendshape model using the CORRECTED API
            self.bundle = self.a2f.BlendshapeModel(
                model_path=model_path,
                character_index=character_index,
                use_gpu_solver=use_gpu_solver,
                constant_noise=False
            )

            self.num_blendshapes = self.bundle.get_num_blendshapes()
            self.fps = self.bundle.get_fps()
            self.model_loaded = True

            print(f"✓ Audio2Face SDK initialized successfully")
            print(f"✓ Blendshapes: {self.num_blendshapes}")
            print(f"✓ FPS: {self.fps}")

        except ImportError as e:
            print(f"✗ Failed to import audio2face_py module: {e}")
            print("NOTE: PyBind11 wrapper needs to be built first")
            print("Run: cd Audio2Face-3D-SDK/_build && make audio2face_py")
            raise RuntimeError("PyBind11 module not available") from e

        except Exception as e:
            print(f"✗ Failed to initialize Audio2Face SDK: {e}")
            raise

    def process_audio(self, audio: np.ndarray) -> Dict:
        """
        Process audio and return blendshapes

        Args:
            audio: Audio data as float32 numpy array (16kHz mono)

        Returns:
            Dictionary with:
                - blendshapes: np.ndarray of shape (num_frames, num_blendshapes)
                - timestamps: np.ndarray of frame timestamps
                - fps: int
                - duration: float
                - num_frames: int
        """
        if not self.model_loaded:
            raise RuntimeError("SDK not initialized")

        # Ensure audio is float32 and 1D
        audio = audio.astype(np.float32)
        if audio.ndim > 1:
            audio = audio.flatten()

        # Normalize if needed
        max_val = np.abs(audio).max()
        if max_val > 1.0:
            audio = audio / max_val
            print(f"Normalized audio (max was {max_val:.2f})")

        print(f"Processing audio: {len(audio)} samples ({len(audio)/config.SAMPLE_RATE:.2f}s)")

        # Process through SDK - this calls the C++ implementation
        blendshapes = self.bundle.process_audio(audio)

        # blendshapes is now a numpy array of shape (num_frames, num_blendshapes)
        num_frames = blendshapes.shape[0]
        timestamps = np.arange(num_frames) / self.fps
        duration = timestamps[-1] if num_frames > 0 else 0.0

        print(f"✓ Generated {num_frames} frames ({duration:.2f}s @ {self.fps}fps)")

        return {
            'blendshapes': blendshapes,
            'timestamps': timestamps,
            'fps': self.fps,
            'duration': duration,
            'num_frames': num_frames
        }

    def get_blendshape_names(self) -> List[str]:
        """Get list of blendshape names"""
        # ARKit standard blendshapes (52)
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

        # Add extra blendshapes if model has more
        if self.model_loaded and self.num_blendshapes > 52:
            additional = [f"a2f_extra_{i}" for i in range(self.num_blendshapes - 52)]
            return arkit_names + additional

        return arkit_names[:self.num_blendshapes] if self.model_loaded else arkit_names

    def _get_character_name(self, index: int) -> str:
        """Get character name from index"""
        characters = ["Claire", "James", "Mark"]
        return characters[index] if index < len(characters) else f"Character_{index}"

    def __del__(self):
        """Cleanup"""
        if hasattr(self, 'bundle') and self.bundle:
            del self.bundle
            print("✓ Audio2Face SDK cleaned up")
