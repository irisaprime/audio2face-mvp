#!/usr/bin/env python3
"""
Test script to verify Audio2Face SDK infrastructure
"""
import os
import sys
from pathlib import Path

def check_infrastructure():
    """Check all infrastructure components"""
    print("=" * 60)
    print("Audio2Face MVP Infrastructure Check")
    print("=" * 60)

    checks = []

    # Check SDK library
    sdk_lib = Path("../Audio2Face-3D-SDK/_build/audio2x-sdk/lib/libaudio2x.so")
    if sdk_lib.exists():
        size_mb = sdk_lib.stat().st_size / (1024 * 1024)
        checks.append(("SDK Library", True, f"{size_mb:.1f}MB"))
    else:
        checks.append(("SDK Library", False, "Not found"))

    # Check models
    model_dir = Path("../Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0")
    if model_dir.exists():
        model_files = list(model_dir.glob("*"))
        checks.append(("Models", True, f"{len(model_files)} files"))
    else:
        checks.append(("Models", False, "Not found"))

    # Check network model
    network_model = model_dir / "network.onnx"
    if network_model.exists():
        size_mb = network_model.stat().st_size / (1024 * 1024)
        checks.append(("Network Model", True, f"{size_mb:.1f}MB"))
    else:
        checks.append(("Network Model", False, "Not found"))

    # Check TensorRT
    tensorrt_lib = Path("/usr/local/TensorRT/lib/libnvinfer.so")
    if tensorrt_lib.exists():
        checks.append(("TensorRT", True, "Installed"))
    else:
        checks.append(("TensorRT", False, "Not found"))

    # Check CUDA
    cuda_lib = Path("/usr/local/cuda/lib64/libcudart.so")
    if cuda_lib.exists():
        checks.append(("CUDA", True, "Installed"))
    else:
        checks.append(("CUDA", False, "Not found"))

    # Check sample executables
    sample_exec = Path("../Audio2Face-3D-SDK/_build/audio2face-sdk/bin/sample-a2f-executor")
    if sample_exec.exists():
        checks.append(("Sample Executables", True, "Built"))
    else:
        checks.append(("Sample Executables", False, "Not found"))

    # Check test audio
    test_audio = Path("../Audio2Face-3D-SDK/sample-data/audio_4sec_16k_s16le.wav")
    if test_audio.exists():
        size_kb = test_audio.stat().st_size / 1024
        checks.append(("Test Audio", True, f"{size_kb:.1f}KB"))
    else:
        checks.append(("Test Audio", False, "Not found"))

    # Print results
    print()
    all_passed = True
    for name, passed, details in checks:
        status = "✓" if passed else "✗"
        color = "\033[92m" if passed else "\033[91m"
        reset = "\033[0m"
        print(f"{color}{status}{reset} {name:.<40} {details}")
        if not passed:
            all_passed = False

    print()
    print("=" * 60)
    if all_passed:
        print("\033[92m✓ All infrastructure checks passed!\033[0m")
        print()
        print("Next Steps:")
        print("1. Create Python bindings using PyBind11")
        print("2. Implement audio processing pipeline")
        print("3. Integrate with backend API")
        print("4. Test with frontend UI")
    else:
        print("\033[91m✗ Some components missing\033[0m")
        print()
        print("Run the setup script to complete installation:")
        print("  cd .. && ./scripts/setup_sdk.sh")
    print("=" * 60)

    return all_passed

def demo_info():
    """Show information about using the SDK"""
    print()
    print("Demo Information:")
    print("-" * 60)
    print()
    print("Available Character Models:")
    print("  • Claire - Female character model")
    print("  • James - Male character model")
    print("  • Mark - Male character model")
    print()
    print("Each model includes:")
    print("  • Skin blendshapes (facial animation)")
    print("  • Tongue blendshapes (mouth interior)")
    print("  • Model configuration")
    print()
    print("SDK Capabilities:")
    print("  • Real-time audio processing")
    print("  • Facial animation generation")
    print("  • Emotion detection")
    print("  • Multi-track support")
    print("  • GPU-accelerated inference")
    print()
    print("Sample Executables Available:")
    sample_dir = Path("../Audio2Face-3D-SDK/_build/audio2face-sdk/bin")
    if sample_dir.exists():
        for exe in sample_dir.glob("sample-*"):
            print(f"  • {exe.name}")
    print()

if __name__ == "__main__":
    all_passed = check_infrastructure()
    demo_info()

    sys.exit(0 if all_passed else 1)
