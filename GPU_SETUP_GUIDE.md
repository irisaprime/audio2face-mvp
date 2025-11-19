# GPU Setup Guide

This guide walks you through the complete setup process when your GPUs are available.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] NVIDIA GPU connected and powered on
- [ ] NVIDIA Driver 525+ installed
- [ ] CUDA Toolkit 12.x installed
- [ ] cuDNN 8.9+ installed
- [ ] TensorRT 10.x installed (optional but recommended)
- [ ] CMake 3.20+ installed
- [ ] Python 3.8-3.10 installed
- [ ] Git installed

## Step-by-Step Setup

### Step 1: Verify GPU Access

```bash
# Check GPU is detected
nvidia-smi

# Expected output: GPU info, driver version, CUDA version

# Check CUDA
nvcc --version

# Check Python can access GPU
python3 -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

### Step 2: Clone and Setup SDK

```bash
# Navigate to project directory
cd /teamspace/studios/this_studio/audio2face-mvp

# Run automated setup script
# Linux:
./scripts/setup_sdk.sh

# This will:
# 1. Clone Audio2Face-3D-SDK repository
# 2. Fetch dependencies
# 3. Build SDK with CUDA support
# 4. Verify build
```

### Step 3: Login to Hugging Face

```bash
# Install Hugging Face CLI (if not already installed)
pip install huggingface-hub

# Login (you'll need a Hugging Face account)
huggingface-cli login
# Enter your token when prompted
```

### Step 4: Accept Model License

1. Visit: https://huggingface.co/nvidia/Audio2Face-3D-v3.0
2. Click "Agree and access repository"
3. Verify you can see the model files

### Step 5: Download Model

```bash
cd Audio2Face-3D-SDK

# Download Audio2Face-3D-v3.0 model (~2GB)
python tools/download_models.py \
  --model nvidia/Audio2Face-3D-v3.0 \
  --output models/

# This will download to: models/Audio2Face-3D-v3.0/
```

### Step 6: Setup Python Backend

```bash
cd ../backend

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # Linux
# or: venv\Scripts\activate  # Windows

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 7: Get Ready Player Me Avatar

1. Visit: https://readyplayer.me/
2. Create an account (free)
3. Customize your avatar
4. Download as GLB format
5. Save to: `frontend/assets/avatar.glb`

### Step 8: Generate Test Audio

```bash
cd ../test_audio

# Generate test audio files
python generate_test_audio.py

# This creates:
# - sample_sine.wav
# - sample_speech_like.wav
# - sample_short.wav
```

### Step 9: Start Backend

```bash
cd ../backend
source venv/bin/activate

# Start FastAPI server
python main.py

# Expected output:
# ✓ Audio2Face-3D-v3.0 model loaded from ...
# ✓ Audio2Face SDK initialized successfully
# INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Step 10: Start Frontend (New Terminal)

```bash
cd /teamspace/studios/this_studio/audio2face-mvp/frontend

# Start HTTP server
python3 -m http.server 3000

# Expected output:
# Serving HTTP on 0.0.0.0 port 3000 (http://0.0.0.0:3000/) ...
```

### Step 11: Test Application

1. Open browser: http://localhost:3000
2. You should see the 3D scene with your avatar
3. Click "Select Audio File"
4. Choose one of the test audio files
5. Click "Process Audio"
6. Wait for processing (1-3 seconds)
7. Click "Play Animation"
8. Watch your avatar lip-sync to the audio!

## Verification Tests

### Test 1: API Health

```bash
curl http://localhost:8000/health

# Expected: {"status":"healthy","sdk_loaded":true}
```

### Test 2: Blendshape Names

```bash
curl http://localhost:8000/blendshape-names

# Expected: JSON with 72 blendshape names
```

### Test 3: Process Audio

```bash
curl -X POST http://localhost:8000/process-audio \
  -F "file=@test_audio/sample_sine.wav"

# Expected: JSON with blendshapes array
```

### Test 4: Frontend Console

Open browser console (F12) and check for:
```
✓ Avatar loaded successfully
Found morph targets: {...}
```

## Performance Benchmarks

After setup, test performance:

```bash
cd backend
python -c "
import time
import numpy as np
from audio_utils import AudioProcessor
from a2f_wrapper import Audio2FaceSDK

# Load SDK
sdk = Audio2FaceSDK()

# Generate 1 second of audio
audio = np.random.randn(16000).astype(np.float32)

# Benchmark
start = time.time()
for i in range(10):
    result = sdk.process_audio(audio)
end = time.time()

fps = 10 / (end - start)
print(f'Processing speed: {fps:.1f} iterations/sec')
print(f'Real-time factor: {fps:.1f}x')
"
```

Expected results:
- RTX 4090: 150+ fps (5x real-time)
- RTX 3080: 100+ fps (3x real-time)
- RTX 2060: 60+ fps (2x real-time)

## Common Issues

### Issue 1: SDK Not Found

**Symptom**: Backend shows "SDK not initialized"

**Solution**:
```bash
# Verify SDK built successfully
ls Audio2Face-3D-SDK/_build/release/audio2face-sdk/bin/

# Should see: libaudio2face-sdk.so (Linux) or audio2face-sdk.dll (Windows)

# Check paths in backend/config.py match your setup
```

### Issue 2: Model Not Found

**Symptom**: "Failed to initialize Audio2Face SDK: model not found"

**Solution**:
```bash
# Verify model exists
ls Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0/

# Should see model files (.onnx, .plan, etc.)

# Re-download if needed
cd Audio2Face-3D-SDK
python tools/download_models.py --model nvidia/Audio2Face-3D-v3.0 --output models/
```

### Issue 3: CUDA Out of Memory

**Symptom**: RuntimeError: CUDA out of memory

**Solution**:
```bash
# Check GPU memory
nvidia-smi

# If GPU is full, close other GPU applications

# Or reduce batch size in SDK config
```

### Issue 4: Avatar Not Animating

**Symptom**: Avatar loads but doesn't move

**Solution**:
1. Open browser console (F12)
2. Check for errors
3. Verify morph target dictionary matches blendshape names:
   ```javascript
   console.log(avatarController.morphTargets.morphTargetDictionary)
   ```
4. Some Ready Player Me avatars may have different morph target names

## Next Steps After Setup

Once everything works:

1. **Try Real Audio**: Use actual speech recordings
2. **Customize Avatar**: Create different avatars on Ready Player Me
3. **Tune Performance**: Adjust FPS, quality settings
4. **Add Features**:
   - Microphone input
   - Emotion control
   - Multiple avatars
5. **Deploy**: Consider cloud deployment for production use

## Getting Help

If you encounter issues:

1. Check logs in terminal where backend is running
2. Check browser console (F12) for frontend errors
3. Verify all steps in this guide
4. Review main README.md troubleshooting section
5. Check NVIDIA SDK documentation

## Resources

- [Audio2Face SDK Documentation](https://github.com/NVIDIA/Audio2Face-3D-SDK)
- [CUDA Installation Guide](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/)
- [Ready Player Me Docs](https://docs.readyplayer.me/)
- [FastAPI Tutorial](https://fastapi.tiangolo.com/tutorial/)

---

**Estimated Setup Time**: 30-60 minutes (depending on download speeds)

**Download Size**: ~5GB (CUDA + cuDNN + TensorRT + Model)

Good luck with your setup! 🚀
