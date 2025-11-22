#!/bin/bash
# Lightning.ai On-Start Hook
# This script runs automatically when the studio starts/restarts
# It ensures all dependencies and environment are ready

set -e

PROJECT_ROOT="/teamspace/studios/this_studio/audio2face-mvp"
LOG_DIR="/teamspace/studios/this_studio/.logs"
LOG_FILE="$LOG_DIR/audio2face_startup_$(date +%Y%m%d_%H%M%S).log"

# Create log directory
mkdir -p "$LOG_DIR"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=================================================="
log "Audio2Face MVP - Startup Hook"
log "=================================================="

cd "$PROJECT_ROOT"

# Step 1: Check and install Python dependencies
log "Step 1: Checking Python dependencies..."

REQUIRED_PACKAGES="fastapi uvicorn numpy scipy librosa soundfile pydantic python-dotenv pybind11 tensorrt torch"

for package in $REQUIRED_PACKAGES; do
    if python -c "import $package" 2>/dev/null; then
        log "  ✓ $package installed"
    else
        log "  ⚠ Installing $package..."
        pip install -q "$package" >> "$LOG_FILE" 2>&1 || log "    Warning: Failed to install $package"
    fi
done

# Step 2: Configure environment
log "Step 2: Configuring environment..."

# Get TensorRT path
TENSORRT_LIBS=$(find /home/zeus/miniconda3/envs/cloudspace/lib/python*/site-packages -name "tensorrt_libs" -type d 2>/dev/null | head -1)

if [ -n "$TENSORRT_LIBS" ]; then
    log "  ✓ TensorRT found: $TENSORRT_LIBS"

    # Create/update env_setup.sh
    cat > "$PROJECT_ROOT/env_setup.sh" <<EOF
#!/bin/bash
export PROJECT_ROOT="$PROJECT_ROOT"
export TENSORRT_DIR="$TENSORRT_LIBS"
export LD_LIBRARY_PATH="$TENSORRT_LIBS:\$PROJECT_ROOT/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:\$LD_LIBRARY_PATH"
export PYBIND11_CMAKE=\$(python -c "import pybind11; print(pybind11.get_cmake_dir())" 2>/dev/null)
export CMAKE_PREFIX_PATH="\$PYBIND11_CMAKE:\$CMAKE_PREFIX_PATH"
EOF
    chmod +x "$PROJECT_ROOT/env_setup.sh"
    log "  ✓ Environment configuration saved"
else
    log "  ⚠ TensorRT not found"
fi

# Step 3: Check SDK build
log "Step 3: Checking SDK build status..."

if [ -d "$PROJECT_ROOT/Audio2Face-3D-SDK/_build" ]; then
    log "  ✓ SDK build directory exists"

    # Check if PyBind11 module exists in backend
    if ls "$PROJECT_ROOT/backend/audio2face_py"*.so 1> /dev/null 2>&1; then
        log "  ✓ PyBind11 module found in backend"
    else
        log "  ⚠ PyBind11 module not in backend (may need rebuild)"

        # Try to copy from build directory
        PYBIND_MODULE=$(find "$PROJECT_ROOT/Audio2Face-3D-SDK/_build" -name "audio2face_py*.so" 2>/dev/null | head -1)
        if [ -n "$PYBIND_MODULE" ] && [ -f "$PYBIND_MODULE" ]; then
            log "  → Copying module from build directory..."
            cp "$PYBIND_MODULE" "$PROJECT_ROOT/backend/"
            log "  ✓ Module copied"
        fi
    fi
else
    log "  ⚠ SDK not built - run 'make automated-setup' to build"
fi

# Step 4: Check avatar file
log "Step 4: Checking avatar file..."

if [ -f "$PROJECT_ROOT/frontend/assets/avatar.glb" ]; then
    SIZE=$(du -h "$PROJECT_ROOT/frontend/assets/avatar.glb" | cut -f1)
    log "  ✓ Avatar file exists ($SIZE)"
else
    log "  ⚠ Avatar file missing (download from readyplayer.me)"
fi

# Step 5: Create convenience aliases
log "Step 5: Setting up convenience commands..."

cat >> ~/.bashrc 2>/dev/null <<'EOF'

# Audio2Face MVP aliases
alias a2f-setup='cd /teamspace/studios/this_studio/audio2face-mvp && make automated-setup'
alias a2f-verify='cd /teamspace/studios/this_studio/audio2face-mvp && make verify-setup'
alias a2f-run='cd /teamspace/studios/this_studio/audio2face-mvp && source env_setup.sh && make run'
alias a2f-backend='cd /teamspace/studios/this_studio/audio2face-mvp && source env_setup.sh && make run-backend'
alias a2f-frontend='cd /teamspace/studios/this_studio/audio2face-mvp && make run-frontend'
alias a2f-status='cd /teamspace/studios/this_studio/audio2face-mvp && make status'
alias a2f-build-wrapper='cd /teamspace/studios/this_studio/audio2face-mvp && ./scripts/build_audio2face_wrapper.sh'
EOF

log "  ✓ Aliases added to ~/.bashrc"

# Step 6: Summary
log ""
log "=================================================="
log "Startup Complete"
log "=================================================="

# Run quick health check
cd "$PROJECT_ROOT/backend"
if python -c "import audio2face_py" 2>/dev/null; then
    log "✓ SDK Status: Ready"
else
    log "⚠ SDK Status: Not loaded (set LD_LIBRARY_PATH)"
fi

log ""
log "Quick commands:"
log "  a2f-setup    - Run automated setup"
log "  a2f-verify   - Verify system"
log "  a2f-run      - Start application"
log "  a2f-status   - Check status"
log ""
log "Log saved to: $LOG_FILE"
log "=================================================="

# Make the log readable
chmod 644 "$LOG_FILE"

exit 0
