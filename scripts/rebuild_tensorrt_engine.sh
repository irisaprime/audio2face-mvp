#!/bin/bash
# Rebuild TensorRT engine from ONNX for current TensorRT version
# This script runs at container startup to ensure GPU compatibility

MODEL_DIR="/app/Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0"
ENGINE_FILE="$MODEL_DIR/network.trt"
ONNX_FILE="$MODEL_DIR/network.onnx"
REBUILD_FLAG="/app/backend/.trt_rebuilt"

# Check if rebuild is needed
if [ -f "$REBUILD_FLAG" ]; then
    echo "TensorRT engine already rebuilt for this container"
    exit 0
fi

echo "=================================================="
echo "Rebuilding TensorRT engine for GPU compatibility"
echo "=================================================="

cd "$MODEL_DIR" || exit 1

# Backup original engine if it exists
if [ -f "$ENGINE_FILE" ]; then
    echo "Backing up original engine file..."
    mv "$ENGINE_FILE" "${ENGINE_FILE}.original"
fi

# Rebuild engine from ONNX
echo "Building TensorRT engine from ONNX..."
echo "This may take 5-10 minutes..."
trtexec \
    --onnx="$ONNX_FILE" \
    --saveEngine="$ENGINE_FILE" \
    --fp16 \
    --memPoolSize=workspace:4096M

if [ $? -eq 0 ] && [ -f "$ENGINE_FILE" ]; then
    echo "✓ TensorRT engine rebuilt successfully"
    ls -lh "$ENGINE_FILE"
    # Mark rebuild as complete
    touch "$REBUILD_FLAG"
    exit 0
else
    echo "✗ Failed to rebuild TensorRT engine"
    # Restore backup if rebuild failed
    if [ -f "${ENGINE_FILE}.original" ]; then
        mv "${ENGINE_FILE}.original" "$ENGINE_FILE"
    fi
    exit 1
fi
