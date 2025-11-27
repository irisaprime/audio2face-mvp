#!/bin/bash
# Docker Image Persistence for Lightning.ai
# Saves/loads Docker images to/from persistent storage

set -e

PERSISTENT_DIR="/teamspace/studios/this_studio"
IMAGE_NAME="audio2face-mvp:latest"
TARBALL_PATH="$PERSISTENT_DIR/audio2face-mvp-image.tar"

case "$1" in
    save)
        echo "Saving Docker image to persistent storage..."
        echo "Image: $IMAGE_NAME"
        echo "Target: $TARBALL_PATH"
        docker save $IMAGE_NAME | gzip > "$TARBALL_PATH.gz"
        echo "✓ Image saved ($(du -h $TARBALL_PATH.gz | cut -f1))"
        ;;

    load)
        echo "Loading Docker image from persistent storage..."
        if [ ! -f "$TARBALL_PATH.gz" ]; then
            echo "✗ No saved image found at $TARBALL_PATH.gz"
            echo "Run './docker-save.sh save' first or 'docker-compose build'"
            exit 1
        fi
        gunzip -c "$TARBALL_PATH.gz" | docker load
        echo "✓ Image loaded"
        ;;

    clean)
        echo "Removing saved image..."
        rm -f "$TARBALL_PATH.gz"
        echo "✓ Cleaned"
        ;;

    *)
        echo "Usage: $0 {save|load|clean}"
        echo ""
        echo "  save  - Save current Docker image to persistent storage"
        echo "  load  - Load Docker image from persistent storage"
        echo "  clean - Remove saved image file"
        exit 1
        ;;
esac
