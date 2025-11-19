#!/usr/bin/env python3
"""
Check system requirements for Audio2Face MVP
Run this script to verify all dependencies are installed
"""

import sys
import subprocess
import shutil
from pathlib import Path

def check_command(cmd, name, version_flag="--version"):
    """Check if a command exists and get version"""
    if shutil.which(cmd):
        try:
            result = subprocess.run(
                [cmd, version_flag],
                capture_output=True,
                text=True,
                timeout=5
            )
            version = result.stdout.strip().split('\n')[0]
            print(f"✓ {name}: {version}")
            return True
        except Exception as e:
            print(f"⚠ {name}: Found but cannot get version")
            return True
    else:
        print(f"✗ {name}: Not found")
        return False

def check_python_package(package, import_name=None):
    """Check if Python package is installed"""
    if import_name is None:
        import_name = package

    try:
        __import__(import_name)
        print(f"✓ Python package: {package}")
        return True
    except ImportError:
        print(f"✗ Python package: {package} (run: pip install {package})")
        return False

def check_file_exists(path, description):
    """Check if file or directory exists"""
    p = Path(path)
    if p.exists():
        print(f"✓ {description}: {path}")
        return True
    else:
        print(f"✗ {description}: {path} (not found)")
        return False

def main():
    print("=" * 60)
    print("Audio2Face MVP - Requirements Check")
    print("=" * 60)
    print()

    results = {
        "system": [],
        "python": [],
        "files": [],
        "optional": []
    }

    # System commands
    print("System Tools:")
    print("-" * 60)
    results["system"].append(check_command("python3", "Python", "--version"))
    results["system"].append(check_command("git", "Git", "--version"))
    results["system"].append(check_command("cmake", "CMake", "--version"))
    print()

    # CUDA (optional but recommended)
    print("CUDA Tools (Required for GPU):")
    print("-" * 60)
    results["optional"].append(check_command("nvcc", "CUDA Compiler", "--version"))
    results["optional"].append(check_command("nvidia-smi", "NVIDIA Driver", "--version"))
    print()

    # Python packages
    print("Python Packages:")
    print("-" * 60)
    results["python"].append(check_python_package("fastapi"))
    results["python"].append(check_python_package("uvicorn"))
    results["python"].append(check_python_package("numpy"))
    results["python"].append(check_python_package("librosa"))
    results["python"].append(check_python_package("soundfile"))
    results["python"].append(check_python_package("torch"))
    print()

    # Files and directories
    print("Project Files:")
    print("-" * 60)
    results["files"].append(check_file_exists("backend/main.py", "Backend"))
    results["files"].append(check_file_exists("frontend/index.html", "Frontend"))
    results["files"].append(check_file_exists("scripts/setup_sdk.sh", "Setup script"))
    print()

    # SDK and Model (optional, will be downloaded)
    print("SDK and Model (Will be downloaded):")
    print("-" * 60)
    results["optional"].append(check_file_exists(
        "Audio2Face-3D-SDK/_build",
        "SDK Build"
    ))
    results["optional"].append(check_file_exists(
        "Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0",
        "Model"
    ))
    results["optional"].append(check_file_exists(
        "frontend/assets/avatar.glb",
        "Avatar"
    ))
    print()

    # Summary
    print("=" * 60)
    print("Summary:")
    print("-" * 60)

    system_ok = all(results["system"])
    python_ok = all(results["python"])
    files_ok = all(results["files"])
    optional_ok = all(results["optional"])

    print(f"System Tools:      {'✓ PASS' if system_ok else '✗ FAIL'}")
    print(f"Python Packages:   {'✓ PASS' if python_ok else '✗ FAIL'}")
    print(f"Project Files:     {'✓ PASS' if files_ok else '✗ FAIL'}")
    print(f"Optional (SDK):    {'✓ PASS' if optional_ok else '⚠ NOT YET'}")
    print()

    if system_ok and files_ok:
        print("✓ Core requirements met!")
        if not python_ok:
            print("⚠ Install Python packages: cd backend && pip install -r requirements.txt")
        if not optional_ok:
            print("⚠ GPU setup needed: See GPU_SETUP_GUIDE.md")
    else:
        print("✗ Missing required dependencies. See above for details.")
        return 1

    print()
    print("=" * 60)
    print("Next Steps:")
    print("-" * 60)

    if not python_ok:
        print("1. Install Python dependencies:")
        print("   cd backend && pip install -r requirements.txt")

    if not optional_ok:
        print("2. When GPU is available, setup SDK:")
        print("   ./scripts/setup_sdk.sh")
        print("3. Download model from Hugging Face")
        print("4. Get avatar from Ready Player Me")
    else:
        print("✓ Everything is ready!")
        print("  Start backend:  ./scripts/start_backend.sh")
        print("  Start frontend: ./scripts/start_frontend.sh")

    print()
    return 0

if __name__ == "__main__":
    sys.exit(main())
