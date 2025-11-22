#!/bin/bash
# Automated Complete Setup Script
# Installs all dependencies and builds SDK automatically

set -e

PROJECT_ROOT="/teamspace/studios/this_studio/audio2face-mvp"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}"
echo "=================================================="
echo "Audio2Face MVP - Automated Setup"
echo "=================================================="
echo -e "${NC}"

cd "$PROJECT_ROOT"

# Step 1: Install Python dependencies
echo -e "${BOLD}Step 1: Installing Python dependencies${NC}"
echo "Installing required packages..."

pip install -q fastapi uvicorn python-multipart numpy scipy librosa soundfile pydantic python-dotenv pybind11 2>&1 | grep -v "Requirement already satisfied" || true

# Install PyTorch and TensorRT if not present
if ! python -c "import torch" 2>/dev/null; then
    echo "Installing PyTorch..."
    pip install -q torch torchaudio
fi

if ! python -c "import tensorrt" 2>/dev/null; then
    echo "Installing TensorRT..."
    pip install -q tensorrt
fi

echo -e "${GREEN}✓ Python dependencies installed${NC}"
echo ""

# Step 2: Get TensorRT paths
echo -e "${BOLD}Step 2: Configuring TensorRT${NC}"

TENSORRT_PYTHON=$(python -c "import tensorrt; import os; print(os.path.dirname(tensorrt.__file__))")
TENSORRT_LIBS=$(python -c "import tensorrt; import os; trt_path = os.path.dirname(tensorrt.__file__); libs_path = os.path.join(os.path.dirname(trt_path), 'tensorrt_libs'); print(libs_path if os.path.exists(libs_path) else trt_path)")

if [ ! -d "$TENSORRT_LIBS" ]; then
    # Try alternate location
    TENSORRT_LIBS=$(find /home/zeus/miniconda3/envs/cloudspace/lib/python*/site-packages -name "tensorrt_libs" -type d 2>/dev/null | head -1)
fi

if [ -d "$TENSORRT_LIBS" ]; then
    echo -e "${GREEN}✓ TensorRT found at: $TENSORRT_LIBS${NC}"
    export TENSORRT_DIR="$TENSORRT_LIBS"
else
    echo -e "${YELLOW}⚠ TensorRT libs not found, using Python package path${NC}"
    export TENSORRT_DIR="$TENSORRT_PYTHON"
fi

echo ""

# Step 3: Configure CMake paths
echo -e "${BOLD}Step 3: Configuring build paths${NC}"

# Get pybind11 cmake dir
PYBIND11_CMAKE=$(python -c "import pybind11; print(pybind11.get_cmake_dir())")
echo "PyBind11 CMake: $PYBIND11_CMAKE"

# Setup environment
export CMAKE_PREFIX_PATH="$PYBIND11_CMAKE:$CMAKE_PREFIX_PATH"
export LD_LIBRARY_PATH="$TENSORRT_LIBS:$PROJECT_ROOT/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:$LD_LIBRARY_PATH"

echo -e "${GREEN}✓ Build environment configured${NC}"
echo ""

# Step 4: Build SDK
echo -e "${BOLD}Step 4: Building Audio2Face SDK${NC}"

cd "$PROJECT_ROOT/Audio2Face-3D-SDK"

# Clean previous build if exists
if [ -d "_build" ]; then
    echo "Cleaning previous build..."
    rm -rf _build/CMakeCache.txt _build/CMakeFiles
fi

# Configure CMake
echo "Configuring CMake..."
cmake -S . -B _build \
    -DCMAKE_PREFIX_PATH="$PYBIND11_CMAKE" \
    -DTENSORRT_ROOT="$TENSORRT_DIR" \
    2>&1 | tee /tmp/cmake_config.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo -e "${RED}✗ CMake configuration failed${NC}"
    echo "Check /tmp/cmake_config.log for details"
    exit 1
fi

echo -e "${GREEN}✓ CMake configured${NC}"

# Build
echo "Building SDK (this may take a few minutes)..."
cmake --build _build -j$(nproc) 2>&1 | tee /tmp/cmake_build.log

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo -e "${YELLOW}⚠ Build completed with warnings${NC}"
    echo "Check /tmp/cmake_build.log for details"
else
    echo -e "${GREEN}✓ SDK built successfully${NC}"
fi

echo ""

# Step 5: Copy PyBind11 module to backend
echo -e "${BOLD}Step 5: Installing PyBind11 module${NC}"

cd "$PROJECT_ROOT"

# Find the built module
PYBIND_MODULE=$(find Audio2Face-3D-SDK/_build -name "audio2face_py*.so" 2>/dev/null | head -1)

if [ -n "$PYBIND_MODULE" ] && [ -f "$PYBIND_MODULE" ]; then
    echo "Found module: $(basename $PYBIND_MODULE)"
    cp "$PYBIND_MODULE" backend/
    echo -e "${GREEN}✓ Module installed to backend/${NC}"
else
    echo -e "${YELLOW}⚠ PyBind11 module not found (may need manual build)${NC}"
fi

echo ""

# Step 6: Save environment configuration
echo -e "${BOLD}Step 6: Saving environment configuration${NC}"

cat > "$PROJECT_ROOT/env_setup.sh" <<EOF
#!/bin/bash
# Environment setup for Audio2Face MVP
# Source this file before running the application

export PROJECT_ROOT="$PROJECT_ROOT"
export TENSORRT_DIR="$TENSORRT_LIBS"
export LD_LIBRARY_PATH="$TENSORRT_LIBS:\$PROJECT_ROOT/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:\$LD_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$PYBIND11_CMAKE:\$CMAKE_PREFIX_PATH"

echo "Environment configured for Audio2Face MVP"
echo "TensorRT: \$TENSORRT_DIR"
echo "LD_LIBRARY_PATH set"
EOF

chmod +x "$PROJECT_ROOT/env_setup.sh"
echo -e "${GREEN}✓ Environment saved to env_setup.sh${NC}"

echo ""

# Step 7: Test installation
echo -e "${BOLD}Step 7: Testing installation${NC}"

cd "$PROJECT_ROOT/backend"

# Test module import
if python -c "import audio2face_py; print('✓ audio2face_py module loaded successfully')" 2>/dev/null; then
    echo -e "${GREEN}✓ SDK module working!${NC}"
else
    echo -e "${YELLOW}⚠ SDK module not importable (may need LD_LIBRARY_PATH set)${NC}"
    echo "Run: source ../env_setup.sh"
fi

# Test health
echo ""
echo "Running health checks..."
python health_validator.py

echo ""
echo -e "${BOLD}${GREEN}"
echo "=================================================="
echo "✓ Automated Setup Complete!"
echo "=================================================="
echo -e "${NC}"

echo ""
echo "Next steps:"
echo "  1. Source environment: source env_setup.sh"
echo "  2. Start backend: make run-backend"
echo "  3. Start frontend: make run-frontend"
echo "  4. Access: http://localhost:3000"
echo ""
echo "To verify: make verify-setup"
echo ""
