#!/bin/bash
# Audio2Face MVP - Backend CPU Mode
# Starts backend without GPU access to avoid CUDA/TensorRT crashes
#
# Usage: ./scripts/run_backend_cpu_mode.sh
#
# Note: SDK will not load in this mode, but backend API will be available

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT/backend" || exit 1

echo "=================================================="
echo "Audio2Face Backend - CPU Mode"
echo "=================================================="
echo ""
echo "Starting backend with GPU disabled..."
echo "Note: SDK will report as 'unhealthy' but API will work"
echo ""
echo "Backend will be available at: http://localhost:8000"
echo "API Docs: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Source environment if available
if [ -f "$PROJECT_ROOT/env_setup.sh" ]; then
    source "$PROJECT_ROOT/env_setup.sh"
fi

# Run with CUDA disabled to prevent TensorRT crash
CUDA_VISIBLE_DEVICES='' python3 main.py
