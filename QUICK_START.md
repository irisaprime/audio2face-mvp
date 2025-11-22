# Quick Start Guide - Audio2Face MVP

Get up and running in 5 minutes!

## Prerequisites

- Python 3.8+
- Node.js (for development)
- NVIDIA GPU (optional, for audio processing)
- Linux environment

## 🚀 Installation

### 1. Clone and Navigate
```bash
cd /teamspace/studios/this_studio/audio2face-mvp
```

### 2. Verify Setup
```bash
make verify-setup
```

This will check all requirements and show you what's missing.

### 3. Install Dependencies
```bash
# Install Python packages
pip install fastapi uvicorn python-multipart numpy scipy librosa soundfile pydantic python-dotenv torch torchaudio huggingface-hub pybind11

# Or use the requirements file
pip install -r backend/requirements.txt
```

### 4. Add Avatar (Optional but Recommended)
```bash
# Download avatar from https://readyplayer.me/
# Save as: frontend/assets/avatar.glb
```

## 🎮 Running the App

### Simple Method (Two Terminals)

**Terminal 1 - Backend:**
```bash
cd backend
python main.py
```

**Terminal 2 - Frontend:**
```bash
cd frontend
python -m http.server 3000
```

### Using Make (Recommended)

```bash
# Start both services
make run

# Or individually
make run-backend   # Terminal 1
make run-frontend  # Terminal 2
```

## 🌐 Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

## ⚡ Expected Behavior

### On First Load

You should see in the browser console (F12):

```
🚀 Starting Audio2Face MVP...
🏥 Running health checks...
✓ THREE.js Library: PASSED
✓ Backend API: PASSED
⚠ Audio2Face SDK: WARNING - SDK not initialized
✓ Avatar File: PASSED
✅ Initialization complete!
```

### Status Messages

- ✅ **All systems operational**: Everything working perfectly
- ⚠️ **Ready with warnings**: App works but some features unavailable
  - Common: SDK not built (audio processing disabled)
  - Common: Avatar missing (3D view empty)
- ❌ **Critical errors**: Something is wrong, check console

## 🧪 Testing

### Quick Test

```bash
# Check health
curl http://localhost:8000/health

# Expected response:
# {"status":"unhealthy","sdk_loaded":false}
# (unhealthy is OK without SDK)
```

### Full Test

```bash
make quick-test
```

## 🐛 Troubleshooting

### "Initializing" Hangs Forever

**Fixed!** The app now includes:
- 10-second timeout on avatar loading
- Clear error messages
- Animated progress indicators

If it still hangs, check console for errors.

### Backend Won't Start

```bash
# Check health
cd backend
python health_validator.py

# Common fixes:
pip install -r requirements.txt
```

### Frontend Shows Errors

Open browser console (F12) to see detailed health check results.

### No 3D View

- Avatar file missing → Download from readyplayer.me
- THREE.js not loading → Check internet connection
- Check console for specific errors

## 📊 Current Limitations

### Without SDK Built

- ❌ Audio processing disabled
- ❌ Cannot generate facial animations
- ✅ Frontend works (UI, 3D view)
- ✅ Backend API responds
- ✅ Can test upload interface

### Without TensorRT

- ❌ Cannot build SDK
- ❌ Audio processing unavailable

### With Everything Setup

- ✅ Full audio-to-face animation
- ✅ Real-time preview
- ✅ Export animations

## 🔧 Optional: Enable Audio Processing

To enable full functionality (audio → face animation):

### 1. Setup TensorRT (Manual)

TensorRT cannot be auto-downloaded. You need to:

1. Visit: https://developer.nvidia.com/tensorrt-download
2. Download: TensorRT 10.7.0 for Linux x86_64 (CUDA 12.6)
3. Extract to: `libs/TensorRT/`

```bash
# After downloading TensorRT-10.7.0....tar.gz
mkdir -p libs
tar -xzf TensorRT-10.7.0....tar.gz -C libs/
mv libs/TensorRT-10.7.0.* libs/TensorRT
```

### 2. Build SDK

```bash
# Set environment
export CMAKE_PREFIX_PATH=/home/zeus/miniconda3/envs/cloudspace/lib/python3.12/site-packages/pybind11/share/cmake/pybind11
export LD_LIBRARY_PATH=$PWD/libs/TensorRT/lib:$PWD/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:$LD_LIBRARY_PATH

# Build
cd Audio2Face-3D-SDK
cmake -S . -B _build
cmake --build _build
```

### 3. Restart Backend

```bash
cd backend
python main.py
```

Now the SDK will be loaded and audio processing will work!

## 📋 Verification Checklist

Use this to verify your setup:

```bash
make verify-setup
```

Or manually:

- [ ] Backend starts: `python backend/main.py`
- [ ] Frontend accessible: http://localhost:3000
- [ ] Health check passes: `curl http://localhost:8000/health`
- [ ] Console shows health checks (F12)
- [ ] No "hanging" on initialization
- [ ] Avatar loads (if file exists)

## 🎯 Next Steps

1. **Basic Testing**: Upload a WAV file and see the UI
2. **Setup SDK**: Follow TensorRT + SDK build steps above
3. **Full Test**: Process audio and see face animation
4. **Customize**: Add your own avatar, tweak settings

## 📚 More Documentation

- `AUTOMATED_HEALTH_CHECKS.md` - Health check system details
- `IMPLEMENTATION_COMPLETE.md` - Technical implementation
- `AFTER_RESTART_CHECKLIST.md` - Post-restart setup
- `README.md` - Full project documentation

## 💡 Tips

### Development Workflow

```bash
# 1. Start development
make verify-setup

# 2. Run services
make run

# 3. Make changes
# ... edit code ...

# 4. Test
make quick-test

# 5. Verify
make verify-setup
```

### Common Commands

```bash
make help          # Show all commands
make status        # Quick status check
make verify-setup  # Full verification
make run           # Start everything
make stop          # Stop all services
make health-all    # Run health checks
```

## ✅ Success!

When everything works, you'll see:

**Browser Console:**
```
✅ Initialization complete!
✓ All systems operational!
```

**Backend Terminal:**
```
✅ All checks passed. Starting backend...
INFO: Uvicorn running on http://0.0.0.0:8000
```

**Make Verify:**
```
✓ 25 checks passed
✓ All systems operational!
```

Now you're ready to use Audio2Face MVP! 🎉

## 🆘 Need Help?

1. Check console for errors (F12)
2. Run `make verify-setup` to diagnose issues
3. Check `AUTOMATED_HEALTH_CHECKS.md` for troubleshooting
4. Review logs in backend terminal

**Most Common Issue**: SDK not built → App still works for UI testing, but audio processing is disabled. This is expected and OK for development!
