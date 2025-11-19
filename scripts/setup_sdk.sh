#!/bin/bash
# Setup script for Audio2Face-3D SDK (Linux)

set -e

echo "=========================================="
echo "Audio2Face-3D SDK Setup (Linux)"
echo "=========================================="

# Check if running in project directory
if [ ! -f "scripts/setup_sdk.sh" ]; then
    echo "Error: Please run this script from the audio2face-mvp directory"
    exit 1
fi

# Check prerequisites
echo "Checking prerequisites..."

# Check CUDA
if ! command -v nvcc &> /dev/null; then
    echo "Warning: CUDA toolkit not found. Please install CUDA 12.x"
    echo "Download from: https://developer.nvidia.com/cuda-downloads"
fi

# Check CMake
if ! command -v cmake &> /dev/null; then
    echo "Error: CMake not found. Please install CMake 3.20+"
    echo "Run: sudo apt-get install cmake"
    exit 1
fi

# Check Git
if ! command -v git &> /dev/null; then
    echo "Error: Git not found. Please install git"
    echo "Run: sudo apt-get install git"
    exit 1
fi

echo "✓ Prerequisites check completed"

# Clone SDK repository
echo ""
echo "Cloning Audio2Face-3D SDK..."
if [ ! -d "Audio2Face-3D-SDK" ]; then
    git clone https://github.com/NVIDIA/Audio2Face-3D-SDK.git
    echo "✓ SDK repository cloned"
else
    echo "✓ SDK repository already exists"
fi

cd Audio2Face-3D-SDK

# Fetch dependencies
echo ""
echo "Fetching SDK dependencies..."
if [ -f "fetch_deps.sh" ]; then
    chmod +x fetch_deps.sh
    ./fetch_deps.sh
else
    echo "Warning: fetch_deps.sh not found"
fi

# Build SDK
echo ""
echo "Building SDK..."

# Use system CUDA (more reliable than conda CUDA for building)
CUDA_ROOT="/usr/local/cuda"
TENSORRT_ROOT="/usr/local/TensorRT"
echo "Using system CUDA at: $CUDA_ROOT"
echo "Using TensorRT at: $TENSORRT_ROOT"
export CUDA_PATH="$CUDA_ROOT"
export PATH="$CUDA_ROOT/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_ROOT/lib64:$TENSORRT_ROOT/lib:$LD_LIBRARY_PATH"

cmake -B _build -S . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCUDA_TOOLKIT_ROOT_DIR="$CUDA_ROOT" \
    -DTENSORRT_ROOT_DIR="$TENSORRT_ROOT"

cmake --build _build --config Release -- -j$(nproc)

# Verify build
echo ""
echo "Verifying build..."
if [ -f "_build/release/audio2face-sdk/bin/libaudio2face-sdk.so" ]; then
    echo "✓ SDK built successfully!"
else
    echo "✗ SDK build failed. Check error messages above."
    exit 1
fi

# Download models
echo ""
echo "=========================================="
echo "Model Download"
echo "=========================================="
echo ""
echo "To download the Audio2Face-3D-v3.0 model:"
echo "1. Login to Hugging Face:"
echo "   huggingface-cli login"
echo ""
echo "2. Accept the model license at:"
echo "   https://huggingface.co/nvidia/Audio2Face-3D-v3.0"
echo ""
echo "3. Download the model:"
echo "   python tools/download_models.py --model nvidia/Audio2Face-3D-v3.0 --output models/"
echo ""
echo "Note: This requires GPU access and ~2GB download"

cd ..

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Download the model (instructions above)"
echo "2. Install Python dependencies: cd backend && pip install -r requirements.txt"
echo "3. Start the backend: cd backend && python main.py"
echo "4. Start the frontend: cd frontend && python -m http.server 3000"
