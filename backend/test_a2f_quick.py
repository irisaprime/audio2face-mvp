#!/usr/bin/env python
"""
Quick test to see if Audio2Face SDK can load before cleanup crash
"""
import sys
import os

# Set environment variables BEFORE importing anything
os.environ['CUDA_MODULE_LOADING'] = 'EAGER'
os.environ['NVIDIA_DRIVER_CAPABILITIES'] = 'compute,utility'
os.environ['CUDA_FORCE_PTX_JIT'] = '1'

# Pre-initialize CUDA
from cuda_init_fix import initialize_cuda_driver, initialize_cuda_runtime, preload_cuda_libraries

print("Pre-initializing CUDA...")
preload_cuda_libraries()
initialize_cuda_driver()
initialize_cuda_runtime()
print()

# Try to load Audio2Face
print("Loading Audio2Face SDK...")
try:
    from a2f_wrapper import Audio2FaceSDK

    print("Creating SDK instance...")
    sdk = Audio2FaceSDK()

    print(f"✓ SDK loaded! Blendshapes: {sdk.num_blendshapes}, FPS: {sdk.fps}")
    print(f"✓ Model loaded: {sdk.model_loaded}")

    # Try to process a dummy audio sample
    import numpy as np
    dummy_audio = np.zeros(16000, dtype=np.float32)  # 1 second of silence

    print("\nTesting inference with dummy audio...")
    result = sdk.process_audio(dummy_audio)

    print(f"✓ Inference successful!")
    print(f"  Output shape: {result['blendshapes'].shape}")
    print(f"  Duration: {result['duration']:.2f}s")
    print(f"  Frames: {len(result['timestamps'])}")

    print("\n" + "="*60)
    print("SUCCESS! Audio2Face SDK is WORKING!")
    print("="*60)

    # Exit immediately with success code (skip Python cleanup)
    os._exit(0)

except Exception as e:
    print(f"\n✗ Failed: {e}")
    import traceback
    traceback.print_exc()
    os._exit(1)
