#!/bin/bash
# Audio2Face MVP - Docker Build Script

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

echo "======================================================"
echo "Audio2Face MVP - Docker Build"
echo "======================================================"
echo

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

# Check if NVIDIA Docker runtime is available
if ! docker info | grep -q nvidia; then
    echo "⚠️  Warning: NVIDIA Docker runtime not detected"
    echo "GPU access may not work"
fi

echo "✓ Docker available: $(docker --version)"
echo

# Build the image
echo "Building Audio2Face Docker image..."
echo "This may take 10-15 minutes..."
echo

docker build \
    --tag audio2face-mvp:latest \
    --progress=plain \
    .

echo
echo "======================================================"
echo "✓ Docker image built successfully!"
echo "======================================================"
echo
echo "To run the container:"
echo "  docker-compose up -d"
echo
echo "Or manually:"
echo "  docker run --gpus all -p 8000:8000 audio2face-mvp:latest"
echo
echo "To test GPU access:"
echo "  docker run --rm --gpus all audio2face-mvp:latest nvidia-smi"
echo
