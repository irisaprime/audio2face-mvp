# Quick Start Checklist

Follow this checklist when your GPU is connected and ready.

## Pre-GPU Setup (Already Done ✓)

- [x] Project structure created
- [x] Backend Python code implemented
- [x] Frontend HTML/CSS/JavaScript implemented
- [x] Setup scripts created
- [x] Documentation written

## When GPU is Available

### 1. System Check (5 minutes)

```bash
# Check GPU
nvidia-smi

# Check CUDA
nvcc --version

# Check Python
python3 --version  # Should be 3.8-3.10
```

### 2. Install CUDA Dependencies (30 minutes)

See `GPU_SETUP_GUIDE.md` for detailed instructions.

**Linux Quick Install**:
```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake git
# Then install CUDA toolkit from NVIDIA website
```

### 3. Setup SDK (10 minutes)

```bash
cd /teamspace/studios/this_studio/audio2face-mvp
./scripts/setup_sdk.sh
```

Wait for build to complete.

### 4. Download Model (15 minutes)

```bash
# Login to Hugging Face
pip install huggingface-hub
huggingface-cli login

# Visit and accept license
# https://huggingface.co/nvidia/Audio2Face-3D-v3.0

# Download model
cd Audio2Face-3D-SDK
python tools/download_models.py \
  --model nvidia/Audio2Face-3D-v3.0 \
  --output models/
```

### 5. Setup Backend (5 minutes)

```bash
cd /teamspace/studios/this_studio/audio2face-mvp/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 6. Get Avatar (5 minutes)

1. Go to https://readyplayer.me/
2. Create avatar
3. Download as GLB
4. Save to `frontend/assets/avatar.glb`

### 7. Generate Test Audio (1 minute)

```bash
cd /teamspace/studios/this_studio/audio2face-mvp/test_audio
python generate_test_audio.py
```

### 8. Start Services (1 minute)

**Terminal 1**:
```bash
cd /teamspace/studios/this_studio/audio2face-mvp
./scripts/start_backend.sh
```

**Terminal 2**:
```bash
cd /teamspace/studios/this_studio/audio2face-mvp
./scripts/start_frontend.sh
```

### 9. Test Application (2 minutes)

1. Open: http://localhost:3000
2. Select audio file: `test_audio/sample_speech_like.wav`
3. Click "Process Audio"
4. Click "Play Animation"
5. Watch avatar animate! 🎉

## Troubleshooting

If something doesn't work:

1. Check backend terminal for errors
2. Check browser console (F12)
3. See `GPU_SETUP_GUIDE.md` troubleshooting section
4. See `README.md` for detailed help

## Estimated Total Time

- **With fast internet**: ~60 minutes
- **With slow internet**: ~90 minutes
- **If CUDA already installed**: ~30 minutes

## What You Should See

**Backend Terminal**:
```
✓ Audio2Face-3D-v3.0 model loaded from ...
✓ Audio2Face SDK initialized successfully
INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Frontend Browser**:
- 3D scene with avatar
- Control panel on right
- Avatar animates when playing audio

**Performance**:
- Processing: 1-3 seconds per 5 seconds of audio
- Animation: Smooth 30fps playback

## Next Steps

Once working:
- Try different audio files
- Create custom avatars
- Experiment with parameters
- Build your application!

---

Good luck! 🚀
