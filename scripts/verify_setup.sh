#!/bin/bash
# Comprehensive Setup Verification Script
# Checks all components of the Audio2Face MVP system

# Don't exit on errors - we want to check everything
# set -e

PROJECT_ROOT="/teamspace/studios/this_studio/audio2face-mvp"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

print_header() {
    echo -e "${BLUE}=================================================="
    echo "Audio2Face MVP - System Verification"
    echo "==================================================${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}$1${NC}"
    echo "$(printf '=%.0s' {1..50})"
}

check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# Check 1: Project Structure
check_project_structure() {
    print_section "1. Project Structure"

    if [ -d "$PROJECT_ROOT/backend" ]; then
        check_pass "backend/ directory exists"
    else
        check_fail "backend/ directory missing"
    fi

    if [ -d "$PROJECT_ROOT/frontend" ]; then
        check_pass "frontend/ directory exists"
    else
        check_fail "frontend/ directory missing"
    fi

    if [ -d "$PROJECT_ROOT/Audio2Face-3D-SDK" ]; then
        check_pass "Audio2Face-3D-SDK/ directory exists"
    else
        check_fail "Audio2Face-3D-SDK/ directory missing"
    fi

    if [ -f "$PROJECT_ROOT/Makefile" ]; then
        check_pass "Makefile exists"
    else
        check_fail "Makefile missing"
    fi
}

# Check 2: Python Environment
check_python_environment() {
    print_section "2. Python Environment"

    if command -v python3 &> /dev/null; then
        version=$(python3 --version)
        check_pass "Python installed: $version"
    else
        check_fail "Python 3 not found"
        return
    fi

    # Check Python packages
    packages=("fastapi" "uvicorn" "numpy" "scipy" "librosa" "soundfile" "pybind11")
    for pkg in "${packages[@]}"; do
        if python3 -c "import $pkg" 2>/dev/null; then
            pkg_version=$(python3 -c "import $pkg; print($pkg.__version__)" 2>/dev/null || echo "unknown")
            check_pass "$pkg installed (v$pkg_version)"
        else
            check_fail "$pkg not installed (pip install $pkg)"
        fi
    done
}

# Check 3: Frontend Files
check_frontend() {
    print_section "3. Frontend"

    critical_files=(
        "frontend/index.html"
        "frontend/js/app.js"
        "frontend/js/health-check.js"
        "frontend/js/scene-manager.js"
        "frontend/js/avatar-controller.js"
        "frontend/js/audio-player.js"
        "frontend/css/style.css"
    )

    for file in "${critical_files[@]}"; do
        if [ -f "$PROJECT_ROOT/$file" ]; then
            check_pass "$file exists"
        else
            check_fail "$file missing"
        fi
    done

    # Check avatar (non-critical)
    if [ -f "$PROJECT_ROOT/frontend/assets/avatar.glb" ]; then
        size=$(du -h "$PROJECT_ROOT/frontend/assets/avatar.glb" | cut -f1)
        check_pass "Avatar file exists ($size)"
    else
        check_warn "Avatar file missing (download from readyplayer.me)"
    fi
}

# Check 4: Backend Files
check_backend() {
    print_section "4. Backend"

    critical_files=(
        "backend/main.py"
        "backend/config.py"
        "backend/audio_utils.py"
        "backend/a2f_wrapper.py"
        "backend/health_validator.py"
    )

    for file in "${critical_files[@]}"; do
        if [ -f "$PROJECT_ROOT/$file" ]; then
            check_pass "$file exists"
        else
            check_fail "$file missing"
        fi
    done

    # Check PyBind11 module (non-critical)
    if ls "$PROJECT_ROOT/backend/audio2face_py"*.so 1> /dev/null 2>&1; then
        module_file=$(ls "$PROJECT_ROOT/backend/audio2face_py"*.so | head -1)
        module_name=$(basename "$module_file")
        check_pass "PyBind11 module: $module_name"
    else
        check_warn "PyBind11 module not built (run: make build-sdk)"
    fi
}

# Check 5: SDK
check_sdk() {
    print_section "5. Audio2Face SDK"

    if [ -d "$PROJECT_ROOT/Audio2Face-3D-SDK/_build" ]; then
        check_pass "SDK build directory exists"
    else
        check_warn "SDK not built yet (run: make build-sdk)"
        return
    fi

    # Check SDK libraries
    if [ -d "$PROJECT_ROOT/Audio2Face-3D-SDK/_build/audio2face-sdk" ]; then
        check_pass "audio2face-sdk built"
    else
        check_warn "audio2face-sdk not built"
    fi

    if [ -d "$PROJECT_ROOT/Audio2Face-3D-SDK/_build/audio2x-sdk" ]; then
        check_pass "audio2x-sdk built"
    else
        check_warn "audio2x-sdk not built"
    fi
}

# Check 6: TensorRT
check_tensorrt() {
    print_section "6. TensorRT"

    # Check LD_LIBRARY_PATH
    if [[ "$LD_LIBRARY_PATH" == *"TensorRT"* ]] || [[ "$LD_LIBRARY_PATH" == *"/usr/lib/x86_64-linux-gnu"* ]] || [[ "$LD_LIBRARY_PATH" == *"tensorrt"* ]]; then
        check_pass "TensorRT in LD_LIBRARY_PATH"
    else
        check_warn "TensorRT not in LD_LIBRARY_PATH"
    fi

    # Check if library exists
    tensorrt_locations=(
        "/usr/local/TensorRT/lib/libnvinfer.so"
        "$PROJECT_ROOT/libs/TensorRT/lib/libnvinfer.so"
        "/usr/lib/x86_64-linux-gnu/libnvinfer.so"
    )

    found=false
    for location in "${tensorrt_locations[@]}"; do
        if [ -f "$location" ]; then
            check_pass "TensorRT library found: $location"
            found=true
            break
        fi
    done

    if [ "$found" = false ]; then
        check_warn "TensorRT library not found (run: make setup-tensorrt)"
    fi
}

# Check 7: Model Files
check_models() {
    print_section "7. Model Files"

    model_locations=(
        "$PROJECT_ROOT/Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0"
        "$PROJECT_ROOT/models/Audio2Face-3D-v3.0"
    )

    found=false
    for location in "${model_locations[@]}"; do
        if [ -d "$location" ]; then
            check_pass "Model directory found: $location"
            if [ -f "$location/model.json" ]; then
                check_pass "model.json exists"
            fi
            found=true
            break
        fi
    done

    if [ "$found" = false ]; then
        check_warn "Model directory not found"
    fi
}

# Check 8: Running Services
check_services() {
    print_section "8. Running Services"

    # Check backend
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        health_status=$(curl -s http://localhost:8000/health | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('status', 'unknown'))" 2>/dev/null || echo "unknown")
        if [ "$health_status" = "healthy" ]; then
            check_pass "Backend running and healthy (port 8000)"
        else
            check_warn "Backend running but unhealthy (SDK may not be loaded)"
        fi
    else
        check_warn "Backend not running (start with: make run-backend)"
    fi

    # Check frontend
    if curl -s -I http://localhost:3000 | head -1 | grep "200" > /dev/null 2>&1; then
        check_pass "Frontend running (port 3000)"
    else
        check_warn "Frontend not running (start with: make run-frontend)"
    fi
}

# Check 9: GPU Availability
check_gpu() {
    print_section "9. GPU & CUDA"

    if command -v nvidia-smi &> /dev/null; then
        gpu_info=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
        check_pass "GPU detected: $gpu_info"

        if command -v nvcc &> /dev/null; then
            cuda_version=$(nvcc --version | grep "release" | awk '{print $5}' | sed 's/,//')
            check_pass "CUDA installed: $cuda_version"
        else
            check_warn "CUDA compiler (nvcc) not found"
        fi
    else
        check_warn "No GPU detected or nvidia-smi not available"
    fi
}

# Print Summary
print_summary() {
    echo ""
    echo -e "${BLUE}=================================================="
    echo "Verification Summary"
    echo "==================================================${NC}"
    echo ""
    echo -e "${GREEN}Passed:   $PASSED${NC}"
    echo -e "${RED}Failed:   $FAILED${NC}"
    echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    echo ""

    if [ $FAILED -eq 0 ]; then
        if [ $WARNINGS -eq 0 ]; then
            echo -e "${GREEN}✓ All checks passed! System is fully operational.${NC}"
        else
            echo -e "${YELLOW}⚠ System operational with $WARNINGS warning(s).${NC}"
            echo "Some features may be limited."
        fi
    else
        echo -e "${RED}✗ $FAILED critical issue(s) found.${NC}"
        echo "Fix the issues above before running the application."
    fi
    echo ""
    echo "==================================================="
    echo ""
}

# Main execution
main() {
    cd "$PROJECT_ROOT"
    print_header
    check_project_structure
    check_python_environment
    check_frontend
    check_backend
    check_sdk
    check_tensorrt
    check_models
    check_services
    check_gpu
    print_summary
}

main
