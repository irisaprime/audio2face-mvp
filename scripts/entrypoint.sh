#!/bin/bash
# Docker container entrypoint script
# Handles TensorRT engine rebuild and starts the backend server

set -e

# Rebuild TensorRT engine if needed (requires GPU access)
/app/scripts/rebuild_tensorrt_engine.sh

# Start the backend server
echo "=================================================="
echo "Starting Audio2Face Backend Server"
echo "=================================================="
cd /app/backend
exec python main.py
