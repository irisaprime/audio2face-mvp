# Audio2Face MVP - Complete Implementation

A full-stack application for real-time audio-driven facial animation using NVIDIA's Audio2Face-3D SDK.

## Overview

This project implements a complete Audio2Face system with:
- **Backend**: FastAPI server with Audio2Face-3D SDK integration
- **Frontend**: Three.js web application with Ready Player Me avatar
- **Model**: Audio2Face-3D-v3.0 (180M parameters, diffusion-based)

## Project Structure

```
audio2face-mvp/
├── backend/                    # FastAPI backend
│   ├── main.py                # API server
│   ├── config.py              # Configuration
│   ├── audio_utils.py         # Audio processing
│   ├── a2f_wrapper.py         # SDK Python wrapper
│   └── requirements.txt       # Python dependencies
├── frontend/                   # Three.js frontend
│   ├── index.html             # Main HTML
│   ├── css/style.css          # Styling
│   ├── js/                    # JavaScript modules
│   │   ├── scene-manager.js   # 3D scene setup
│   │   ├── avatar-controller.js
│   │   ├── audio-player.js
│   │   └── app.js
│   └── assets/
│       └── avatar.glb         # Ready Player Me avatar
├── test_audio/                # Test audio files
│   └── generate_test_audio.py
├── scripts/                   # Setup and startup scripts
│   ├── setup_sdk.sh/.bat     # SDK setup
│   ├── start_backend.sh/.bat # Backend server
│   └── start_frontend.sh/.bat # Frontend server
└── Audio2Face-3D-SDK/        # NVIDIA SDK (clone separately)
```

## System Requirements

### Hardware
- **GPU**: NVIDIA GPU with CUDA support (RTX 2060 or higher recommended)
- **VRAM**: 8GB+ recommended
- **RAM**: 16GB+ system memory

### Software
- **OS**: Linux (Ubuntu 20.04+) or Windows 10/11
- **GPU Driver**: NVIDIA Driver 525+
- **CUDA**: CUDA Toolkit 12.x
- **cuDNN**: 8.9+
- **TensorRT**: 10.x
- **Python**: 3.8-3.10
- **CMake**: 3.20+
- **Git**: Latest version

## Installation

### 1. Install System Dependencies

#### Linux (Ubuntu/Debian)

```bash
# Update system
sudo apt-get update

# Install build tools
sudo apt-get install -y build-essential cmake git python3 python3-pip python3-venv

# Install CUDA 12.x
wget https://developer.download.nvidia.com/compute/cuda/12.3.0/local_installers/cuda_12.3.0_545.23.06_linux.run
sudo sh cuda_12.3.0_545.23.06_linux.run

# Install cuDNN
sudo apt-get install -y libcudnn8 libcudnn8-dev

# Install TensorRT
sudo apt-get install -y tensorrt
```

#### Windows

1. Install Visual Studio 2019/2022 with C++ tools
2. Download and install [CUDA 12.x](https://developer.nvidia.com/cuda-downloads)
3. Download and install [cuDNN 8.9+](https://developer.nvidia.com/cudnn)
4. Download and install [TensorRT 10.x](https://developer.nvidia.com/tensorrt)
5. Download and install [CMake](https://cmake.org/download/)
6. Download and install [Git](https://git-scm.com/download/win)

### 2. Setup Audio2Face SDK

#### Automated Setup

Linux:
```bash
cd audio2face-mvp
./scripts/setup_sdk.sh
```

Windows:
```cmd
cd audio2face-mvp
scripts\setup_sdk.bat
```

#### Manual Setup

```bash
# Clone SDK
git clone https://github.com/NVIDIA/Audio2Face-3D-SDK.git
cd Audio2Face-3D-SDK

# Fetch dependencies (Linux)
./fetch_deps.sh

# Fetch dependencies (Windows)
fetch_deps.bat

# Build (Linux)
cmake -B _build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build _build --config Release -- -j$(nproc)

# Build (Windows)
cmake -B _build -S . -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Release
cmake --build _build --config Release --parallel
```

### 3. Download Models

```bash
# Login to Hugging Face
huggingface-cli login

# Accept license at: https://huggingface.co/nvidia/Audio2Face-3D-v3.0

# Download model
cd Audio2Face-3D-SDK
python tools/download_models.py --model nvidia/Audio2Face-3D-v3.0 --output models/
```

**Note**: Model download requires GPU access and ~2GB bandwidth.

### 4. Install Python Dependencies

```bash
cd backend
python -m venv venv

# Activate (Linux)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

### 5. Setup Avatar

1. Go to [Ready Player Me](https://readyplayer.me/)
2. Create and customize your avatar
3. Download as GLB format
4. Save to `frontend/assets/avatar.glb`

## Usage

### Quick Start

#### Option 1: Using Startup Scripts

**Terminal 1 - Backend**:
```bash
# Linux
./scripts/start_backend.sh

# Windows
scripts\start_backend.bat
```

**Terminal 2 - Frontend**:
```bash
# Linux
./scripts/start_frontend.sh

# Windows
scripts\start_frontend.bat
```

#### Option 2: Manual Start

**Terminal 1 - Backend**:
```bash
cd backend
source venv/bin/activate  # Linux
# or venv\Scripts\activate  # Windows
python main.py
```

**Terminal 2 - Frontend**:
```bash
cd frontend
python -m http.server 3000
```

### Access the Application

1. Open browser: `http://localhost:3000`
2. Click "Select Audio File" and choose a WAV file
3. Click "Process Audio" (wait 1-3 seconds)
4. Click "Play Animation" to see lip-sync!

### API Endpoints

- `GET /` - API status
- `GET /health` - Health check
- `GET /blendshape-names` - List all blendshape names
- `POST /process-audio` - Process audio file
- `GET /docs` - Interactive API documentation

## Testing

### Generate Test Audio

```bash
cd test_audio
python generate_test_audio.py
```

This creates three test files:
- `sample_sine.wav` - 3s sine wave
- `sample_speech_like.wav` - 5s speech-like audio
- `sample_short.wav` - 1s short test

### Test Backend

```bash
# Health check
curl http://localhost:8000/health

# Get blendshape names
curl http://localhost:8000/blendshape-names

# Process audio
curl -X POST http://localhost:8000/process-audio \
  -F "file=@test_audio/sample_sine.wav"
```

## Configuration

Edit `backend/config.py` to customize:

```python
# Paths
SDK_PATH = Path("../Audio2Face-3D-SDK/_build/release/audio2face-sdk/bin")
MODEL_PATH = Path("../Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0")

# Audio settings
SAMPLE_RATE = 16000
CHANNELS = 1  # Mono

# Animation settings
FPS = 30
BLENDSHAPE_COUNT = 72

# Server settings
HOST = "0.0.0.0"
PORT = 8000
```

## Performance

Expected processing speeds:

| GPU | Processing Speed | Real-time Factor |
|-----|-----------------|------------------|
| RTX 4090 | ~150 fps | 5x real-time |
| RTX 3080 | ~100 fps | 3x real-time |
| RTX 2060 | ~60 fps | 2x real-time |

Memory usage:
- GPU VRAM: ~2GB
- System RAM: ~1GB

## Troubleshooting

### GPU Not Available

**Error**: `SDK not initialized` or `CUDA not available`

**Solution**:
```bash
# Check NVIDIA driver
nvidia-smi

# Check CUDA
nvcc --version

# Verify GPU is enabled
python -c "import torch; print(torch.cuda.is_available())"
```

### SDK Build Fails

**Error**: CMake configuration errors

**Solution**:
```bash
# Verify CMake version
cmake --version  # Should be 3.20+

# Check CUDA installation
echo $CUDA_PATH  # Linux
echo %CUDA_PATH%  # Windows

# Clean and rebuild
rm -rf _build
./scripts/setup_sdk.sh
```

### Model Download Fails

**Error**: 401 Unauthorized or 403 Forbidden

**Solution**:
1. Login: `huggingface-cli login`
2. Visit: https://huggingface.co/nvidia/Audio2Face-3D-v3.0
3. Click "Agree and access repository"
4. Retry download

### Avatar Not Animating

**Solution**:
1. Open browser console (F12)
2. Check for JavaScript errors
3. Verify blendshape names match:
   ```javascript
   console.log(avatar.morphTargetDictionary)
   ```
4. Ensure audio processing completed successfully

### CORS Errors

**Solution**: Already handled by FastAPI CORS middleware. If issues persist:
1. Check backend is running on port 8000
2. Verify frontend API_URL in `js/app.js`
3. Try accessing from `localhost` instead of `127.0.0.1`

## Architecture

### Backend Flow

```
Audio File Upload
    ↓
Audio Preprocessing (librosa)
    ↓ 16kHz, Mono, PCM-16
Audio2Face SDK (C++)
    ↓
Blendshape Generation (72 × N frames)
    ↓
JSON Response
```

### Frontend Flow

```
User Uploads Audio
    ↓
Send to Backend API
    ↓
Receive Blendshapes
    ↓
Sync Audio Playback
    ↓
Apply Blendshapes to Avatar (30fps)
```

### Blendshape Mapping

Audio2Face outputs 72 blendshapes:
- **0-51**: Standard ARKit blendshapes
  - Eyes (0-13): Blink, look, squint, wide
  - Jaw (14-17): Forward, left, right, open
  - Mouth (18-41): Various mouth shapes
  - Brow (41-45): Eyebrow movements
  - Cheek (46-48): Cheek puff and squint
  - Nose (49-50): Nose sneer
  - Tongue (51): Tongue out
- **52-71**: Audio2Face extended blendshapes

## Development

### Adding Custom Blendshapes

Edit `backend/a2f_wrapper.py`:

```python
def get_blendshape_names(self) -> List[str]:
    # Add your custom blendshape names here
    custom_names = ["myCustomBlendshape1", "myCustomBlendshape2"]
    return arkit_names + custom_names
```

### Changing Avatar

1. Download new GLB from Ready Player Me
2. Replace `frontend/assets/avatar.glb`
3. Verify morph targets in browser console
4. Adjust blendshape mapping if needed

### API Integration

Example Python client:

```python
import requests

# Process audio
with open('audio.wav', 'rb') as f:
    response = requests.post(
        'http://localhost:8000/process-audio',
        files={'file': f}
    )

data = response.json()
blendshapes = data['data']['blendshapes']  # List of frames
fps = data['data']['fps']  # 30
```

## Next Steps

Potential enhancements:
1. Real-time microphone input
2. Multiple avatar selection
3. Emotion control (Audio2Emotion integration)
4. Export animation to video
5. WebSocket for real-time streaming
6. Cloud deployment (AWS, GCP)
7. Mobile support
8. VTuber mode

## Resources

- [Audio2Face-3D SDK](https://github.com/NVIDIA/Audio2Face-3D-SDK)
- [Audio2Face-3D-v3.0 Model](https://huggingface.co/nvidia/Audio2Face-3D-v3.0)
- [Ready Player Me](https://readyplayer.me/)
- [Three.js Documentation](https://threejs.org/docs/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

## License

This project uses:
- Audio2Face-3D SDK: [NVIDIA License](https://github.com/NVIDIA/Audio2Face-3D-SDK/blob/main/LICENSE)
- Audio2Face-3D-v3.0 Model: Check Hugging Face for license terms

## Support

For issues:
1. Check the Troubleshooting section
2. Review SDK documentation
3. Open an issue with:
   - System specs (OS, GPU, CUDA version)
   - Error messages
   - Steps to reproduce

## Acknowledgments

- NVIDIA for Audio2Face-3D SDK
- Ready Player Me for avatar platform
- Three.js community

---

**Status**: Ready for GPU setup and testing

**Note**: This project requires a NVIDIA GPU with CUDA support. When GPU is connected and drivers installed, run the setup scripts to build the SDK and download models.
