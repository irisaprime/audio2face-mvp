#!/bin/bash
# TensorRT Download and Cache Script
# Downloads TensorRT 10.7.0 and caches it in persistent storage

set -e  # Exit on error

PROJECT_ROOT="/teamspace/studios/this_studio/audio2face-mvp"
TENSORRT_DIR="$PROJECT_ROOT/libs/TensorRT"
TENSORRT_VERSION="10.7.0.23"
TENSORRT_TARBALL="TensorRT-${TENSORRT_VERSION}.Linux.x86_64-gnu.cuda-12.6.tar.gz"
TENSORRT_URL="https://developer.nvidia.com/downloads/compute/machine-learning/tensorrt/10.7.0/${TENSORRT_TARBALL}"

echo "=================================================="
echo "TensorRT Setup for Audio2Face MVP"
echo "=================================================="
echo ""

# Check if already installed
if [ -d "$TENSORRT_DIR" ] && [ -f "$TENSORRT_DIR/lib/libnvinfer.so" ]; then
    echo "✓ TensorRT already cached at: $TENSORRT_DIR"
    echo ""
    echo "Version info:"
    ls -lh "$TENSORRT_DIR/lib/libnvinfer.so"* | head -3
    echo ""
    echo "To reinstall, remove directory: rm -rf $TENSORRT_DIR"
    exit 0
fi

echo "TensorRT not found. Checking download options..."
echo ""

# Option 1: Try to install from system package manager
echo "Checking if TensorRT available via apt..."
if apt-cache show tensorrt >/dev/null 2>&1; then
    echo "TensorRT package found in apt!"
    echo ""
    read -p "Install TensorRT via apt? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt-get update
        sudo apt-get install -y tensorrt

        # Create symlink to libs
        mkdir -p "$PROJECT_ROOT/libs"
        ln -sf /usr/lib/x86_64-linux-gnu "$TENSORRT_DIR"

        echo "✓ TensorRT installed via apt"
        exit 0
    fi
fi

# Option 2: Try conda
echo "Checking if TensorRT available via conda..."
if conda search tensorrt 2>/dev/null | grep -q tensorrt; then
    echo "TensorRT package found in conda!"
    echo ""
    read -p "Install TensorRT via conda? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        conda install -y tensorrt

        # Find conda tensorrt and symlink
        CONDA_TENSORRT=$(find $CONDA_PREFIX -name "libnvinfer.so*" 2>/dev/null | head -1)
        if [ -n "$CONDA_TENSORRT" ]; then
            CONDA_TRT_DIR=$(dirname "$CONDA_TENSORRT")
            mkdir -p "$PROJECT_ROOT/libs"
            ln -sf "$(dirname $CONDA_TRT_DIR)" "$TENSORRT_DIR"
            echo "✓ TensorRT installed via conda"
            exit 0
        fi
    fi
fi

# Option 3: Manual download
echo ""
echo "=================================================="
echo "Manual TensorRT Download Required"
echo "=================================================="
echo ""
echo "TensorRT cannot be automatically downloaded."
echo "You need to:"
echo ""
echo "1. Visit: https://developer.nvidia.com/tensorrt-download"
echo "2. Login with NVIDIA Developer account (free)"
echo "3. Download: TensorRT 10.7.0 for Linux x86_64 (CUDA 12.6)"
echo "4. Upload the .tar.gz file to this directory:"
echo "   $PROJECT_ROOT/libs/"
echo ""
echo "Then run this script again, or extract manually:"
echo "  tar -xzvf libs/$TENSORRT_TARBALL -C libs/"
echo "  mv libs/TensorRT-${TENSORRT_VERSION} libs/TensorRT"
echo ""

# Check if tarball already downloaded
if [ -f "$PROJECT_ROOT/libs/$TENSORRT_TARBALL" ]; then
    echo "✓ Found downloaded tarball: $TENSORRT_TARBALL"
    echo ""
    read -p "Extract now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$PROJECT_ROOT/libs"
        echo "Extracting TensorRT..."
        tar -xzf "$TENSORRT_TARBALL"

        # Find extracted directory and rename
        EXTRACTED_DIR=$(tar -tzf "$TENSORRT_TARBALL" | head -1 | cut -f1 -d"/")
        if [ -d "$EXTRACTED_DIR" ]; then
            mv "$EXTRACTED_DIR" TensorRT
            echo ""
            echo "✓ TensorRT extracted successfully!"
            echo "✓ Location: $TENSORRT_DIR"
            echo ""
            echo "Library files:"
            ls -lh "$TENSORRT_DIR/lib/"libnvinfer.so* | head -3
            exit 0
        fi
    fi
fi

echo "=================================================="
echo "Setup incomplete. Please download TensorRT manually."
echo "=================================================="
exit 1
