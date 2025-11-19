# Audio2Face MVP

Real-time audio-driven facial animation using NVIDIA Audio2Face-3D SDK.

## Quick Start

### Prerequisites
- NVIDIA GPU with CUDA 12.6+
- TensorRT 10.7+ at `/usr/local/TensorRT`
- Python 3.10+, Node.js 18+

### Setup (5 minutes)

```bash
# 1. Build SDK
cd Audio2Face-3D-SDK
./scripts/setup_sdk.sh
cd ..

# 2. Download models (requires Hugging Face login)
huggingface-cli login
huggingface-cli download nvidia/Audio2Face-3D-v3.0 \
  --local-dir Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0

# 3. Install backend dependencies
cd backend
pip install -r requirements.txt
cd ..

# 4. Install frontend dependencies
cd frontend
npm install
cd ..
```

### Run

```bash
# Terminal 1: Backend
cd backend && python main.py

# Terminal 2: Frontend
cd frontend && npm run dev
```

Open `http://localhost:3000`

## Verify Setup

```bash
cd backend && python test_sdk.py
```

All checks should show ✓

## Project Structure

```
audio2face-mvp/
├── Audio2Face-3D-SDK/         # NVIDIA C++ SDK
│   ├── _build/                # Compiled library (8.9MB)
│   └── models/                # Downloaded models (1.5GB, not in git)
├── backend/                   # FastAPI server (port 8000)
│   ├── main.py               # API endpoints
│   ├── test_sdk.py           # Infrastructure check
│   └── config.py             # SDK paths
├── frontend/                  # React + Three.js UI (port 3000)
├── scripts/                  # Build scripts
└── SETUP_COMPLETE.md         # Detailed setup notes
```

## Status

✅ Audio2Face SDK compiled
✅ TensorRT + CUDA configured
✅ Models downloaded (1.5GB from Hugging Face)
✅ Backend API running
✅ Frontend running

## Next Implementation Steps

1. **Python SDK bindings** - PyBind11 wrapper for C++ API
2. **Audio processing** - Handle uploaded WAV files
3. **Animation pipeline** - Connect SDK to Three.js
4. **Real-time streaming** - WebSocket support

## Architecture Notes

The SDK uses C++ classes (not C functions):
- `IBlendshapeExecutor` - Outputs 72 blendshape weights per frame
- `IGeometryExecutor` - Outputs vertex positions directly

Sample executables in `_build/audio2face-sdk/bin/` can be called via subprocess for quick MVP testing.

## Key Files

- `backend/a2f_wrapper.py` - SDK wrapper (needs PyBind11 implementation)
- `backend/config.py` - Paths to SDK and models
- `Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0/model.json` - Model config
- `Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0/network.onnx` - 692MB neural network

## Models

Models are downloaded from Hugging Face (not stored in git):
- **network.onnx** - 692MB main model
- **Characters** - Claire, James, Mark
- **Blendshapes** - Skin + tongue (15MB + 1.1MB per character)

Re-download anytime:
```bash
huggingface-cli download nvidia/Audio2Face-3D-v3.0 \
  --local-dir Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0
```

## Troubleshooting

**SDK undefined symbol errors**: SDK is C++, not C. Needs PyBind11 bindings or subprocess wrapper.

**Port 8000 in use**: Kill existing backend process
```bash
lsof -ti:8000 | xargs kill -9
```

**Models not found**: Run the huggingface-cli download command above

**CUDA/TensorRT errors**: Verify installation
```bash
nvcc --version
ls /usr/local/TensorRT/
```

## Repository

https://github.com/irisaprime/audio2face-mvp

## Resources

- [Audio2Face-3D SDK](https://github.com/NVIDIA/Audio2Face-3D-SDK)
- [Model on Hugging Face](https://huggingface.co/nvidia/Audio2Face-3D-v3.0)
- API docs: `http://localhost:8000/docs` (when backend running)
