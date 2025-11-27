# Audio2Face MVP

Real-time audio-driven facial animation using NVIDIA Audio2Face-3D SDK.

## Quick Start

### Option A: Docker (Recommended - Works Everywhere)

```bash
# Build and run with GPU
docker-compose up --build

# Access:
# - Frontend: http://localhost:3000
# - Backend API: http://localhost:8000
# - API Docs: http://localhost:8000/docs
```

### Option B: Native (Lightning.ai / Local GPU)

```bash
# Setup
make setup-all

# Run
make run

# Or separately:
make run-backend  # Terminal 1
make run-frontend # Terminal 2
```

## Requirements

- **Docker**: NVIDIA Docker runtime with `--gpus` support
- **Native**:
  - NVIDIA GPU (L4, A100, etc.)
  - CUDA 12.6+
  - TensorRT 10.x
  - Python 3.12

## Architecture

```
audio2face-mvp/
├── backend/           # FastAPI server + Audio2Face SDK
├── frontend/          # Web UI (Three.js + GLB avatar)
├── Audio2Face-3D-SDK/ # NVIDIA SDK (built from source)
├── Dockerfile         # Production container
├── docker-compose.yml # Multi-service setup
└── Makefile          # Build & run automation
```

## Docker Commands

```bash
# Build image
docker-compose build

# Run services
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down

# Rebuild after changes
docker-compose up --build

# Shell into container
docker-compose exec backend bash
```

## Makefile Commands

```bash
make help          # Show all commands
make verify-setup  # Check system requirements
make build-docker  # Build Docker image
make run-docker    # Run via Docker Compose
make run           # Run natively
make stop          # Stop all services
make clean         # Clean temporary files
```

## API Endpoints

- `GET /` - API info
- `GET /health` - Health check
- `GET /blendshape-names` - List all 72 blendshapes
- `POST /process-audio` - Upload audio, get blendshapes
- `GET /docs` - Interactive API documentation

## Development

### Rebuild SDK
```bash
make setup-sdk
```

### Test API
```bash
curl http://localhost:8000/health
```

### Run tests
```bash
make test
```

## Troubleshooting

### TensorRT Error on Host
**Solution**: Use Docker - it has proper GPU passthrough:
```bash
docker-compose up --build
```

### Docker Image Not Persisting (Lightning.ai)
**Solution**: Use `docker-save.sh` to save/load images:
```bash
./docker-save.sh save    # Save to persistent storage
./docker-save.sh load    # Load after restart
```

### GPU Not Detected in Container
**Solution**: Check NVIDIA Docker runtime:
```bash
docker run --rm --gpus all nvidia/cuda:12.6.0-base nvidia-smi
```

## Environment Variables

```bash
# Backend
CUDA_MODULE_LOADING=EAGER
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Model paths (auto-configured)
MODEL_PATH=../Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0
```

## License

This project uses NVIDIA Audio2Face-3D SDK. See SDK license terms.

## Links

- [NVIDIA Audio2Face-3D](https://github.com/NVIDIA/Audio2Face-3D-SDK)
- [Ready Player Me](https://readyplayer.me/) (Avatar creator)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
