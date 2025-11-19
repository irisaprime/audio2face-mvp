#!/bin/bash
# Start Audio2Face Frontend Server

cd "$(dirname "$0")/../frontend"

echo "=========================================="
echo "Audio2Face Frontend Server"
echo "=========================================="

PORT=3000

echo ""
echo "Starting HTTP server on port $PORT..."
echo "Frontend will be available at: http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Check if Python 3 is available
if command -v python3 &> /dev/null; then
    python3 -m http.server $PORT
else
    python -m http.server $PORT
fi
