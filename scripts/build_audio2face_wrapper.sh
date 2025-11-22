#!/bin/bash
# Build Audio2Face PyBind11 Wrapper
# This script builds the corrected PyBind11 wrapper for Audio2Face SDK

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SDK_DIR="$PROJECT_ROOT/Audio2Face-3D-SDK"
BACKEND_DIR="$PROJECT_ROOT/backend"
BUILD_DIR="$SDK_DIR/_build"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Audio2Face PyBind11 Wrapper Build${NC}"
echo -e "${BLUE}========================================${NC}"
echo

# Check if SDK exists
if [ ! -d "$SDK_DIR" ]; then
    echo -e "${RED}✗ Audio2Face SDK not found at: $SDK_DIR${NC}"
    echo -e "${YELLOW}Please clone the SDK first:${NC}"
    echo "  git clone https://github.com/NVIDIA/Audio2Face-3D-SDK.git"
    exit 1
fi

echo -e "${GREEN}✓${NC} SDK directory found"

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${YELLOW}⚠ Build directory not found, creating...${NC}"
    cd "$SDK_DIR"
    cmake -B _build -S . -DCMAKE_BUILD_TYPE=Release
fi

echo -e "${GREEN}✓${NC} Build directory ready"

# Create python output directory if needed
mkdir -p "$BUILD_DIR/python"
echo -e "${GREEN}✓${NC} Python output directory created"

# Build the PyBind11 module
echo
echo -e "${BLUE}Building PyBind11 module...${NC}"
cd "$SDK_DIR"
make -C _build audio2face_py -j$(nproc)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} PyBind11 module built successfully"
else
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi

# Find the .so file
SO_FILE=$(find "$BUILD_DIR/python" -name "audio2face_py*.so" -type f | head -1)

if [ -z "$SO_FILE" ]; then
    echo -e "${RED}✗ Built module not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Module found: $(basename $SO_FILE)"

# Copy to backend
echo
echo -e "${BLUE}Installing module to backend...${NC}"
cp "$SO_FILE" "$BACKEND_DIR/"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Module installed to: $BACKEND_DIR/$(basename $SO_FILE)"
else
    echo -e "${RED}✗ Failed to copy module${NC}"
    exit 1
fi

# Verify module can be imported
echo
echo -e "${BLUE}Verifying module...${NC}"
cd "$BACKEND_DIR"
python3 -c "import audio2face_py; print('✓ Module imports successfully')" 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Module verified and ready to use"
else
    echo -e "${YELLOW}⚠ Module import test failed (may be OK if dependencies not yet installed)${NC}"
fi

echo
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Build Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo
echo "Next steps:"
echo "  1. Ensure you have the Audio2Face model downloaded"
echo "  2. Set up TensorRT libraries in your environment"
echo "  3. Run the backend: cd backend && python3 main.py"
echo
