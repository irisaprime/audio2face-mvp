# Audio2Face MVP - Docker Container
# Based on NVIDIA TensorRT official image for GPU support

FROM nvcr.io/nvidia/tensorrt:24.11-py3

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    cmake \
    build-essential \
    libsndfile1 \
    ffmpeg \
    wget \
    pybind11-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY backend/ /app/backend/
COPY Audio2Face-3D-SDK/ /app/Audio2Face-3D-SDK/
COPY frontend/ /app/frontend/
COPY scripts/ /app/scripts/
COPY test_audio/ /app/test_audio/

# Install Python dependencies
RUN pip install --no-cache-dir \
    fastapi==0.104.1 \
    uvicorn[standard]==0.24.0 \
    python-multipart==0.0.6 \
    numpy \
    scipy \
    librosa==0.10.1 \
    soundfile==0.12.1 \
    pydantic==2.5.0 \
    python-dotenv==1.0.0 \
    pybind11

# Build Audio2Face SDK
WORKDIR /app/Audio2Face-3D-SDK
# Fetch SDK dependencies
RUN ./fetch_deps.sh release
# Build SDK
RUN cmake -B _build -S . \
    -DCMAKE_BUILD_TYPE=Release \
    -DTENSORRT_ROOT_DIR=/usr/lib/x86_64-linux-gnu \
    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda && \
    cmake --build _build --config Release -- -j$(nproc)

# Copy Python module to backend
RUN cp _build/python/audio2face_py*.so /app/backend/

# Make scripts executable
RUN chmod +x /app/scripts/rebuild_tensorrt_engine.sh /app/scripts/entrypoint.sh

# Set environment variables
ENV LD_LIBRARY_PATH=/app/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}
ENV PYTHONPATH=/app/backend:${PYTHONPATH}
ENV CUDA_MODULE_LOADING=EAGER

# Expose backend port
EXPOSE 8000

# Change to backend directory
WORKDIR /app/backend

# Health check (longer start period to allow TensorRT engine rebuild)
HEALTHCHECK --interval=30s --timeout=10s --start-period=600s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

# Use entrypoint script to rebuild TensorRT engine and start server
ENTRYPOINT ["/app/scripts/entrypoint.sh"]
