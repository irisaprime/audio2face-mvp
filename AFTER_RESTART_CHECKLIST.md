# After Lightning.ai Restart - Setup Checklist

## ✅ Automatic (Already Done by on_start.sh)

When studio restarts, these happen automatically:
- ✅ Install pybind11 and numpy
- ✅ Verify project structure
- ✅ Set up environment
- ✅ Log everything to `~/.lightning_studio/logs/`

---

## 📋 Manual Steps (You Need to Do)

### Step 1: Check Automatic Startup Status

```bash
# View the automatic startup log
tail -f ~/.lightning_studio/logs/audio2face_startup_*.log

# Or check latest log
ls -lt ~/.lightning_studio/logs/audio2face_startup_*.log | head -1
```

**Expected**: Should show "✓ Restart recovery complete!"

---

### Step 2: Verify Project Status

```bash
cd /teamspace/studios/this_studio/audio2face-mvp
make status
```

**Expected Output**:
- ✓ Directories verified
- ✓ SDK built
- ✓ Models downloaded
- ✗ TensorRT not found (we'll fix this next)

---

### Step 3: Install TensorRT ⚠️ CRITICAL

```bash
cd /teamspace/studios/this_studio/audio2face-mvp

# Option A: Try automatic setup
make setup-tensorrt
```

**If automatic fails**, follow manual steps:

1. Download TensorRT 10.7.0 from NVIDIA:
   - Visit: https://developer.nvidia.com/tensorrt-download
   - Select: TensorRT 10.7.0, Linux x86_64, CUDA 12.6
   - Download: `TensorRT-10.7.0.*.tar.gz`

2. Upload to studio and extract:
   ```bash
   # Upload .tar.gz to /teamspace/studios/this_studio/audio2face-mvp/libs/
   cd /teamspace/studios/this_studio/audio2face-mvp/libs
   tar -xzf TensorRT-10.7.0.*.tar.gz
   mv TensorRT-10.7.0.* TensorRT
   ```

3. Verify:
   ```bash
   make verify-tensorrt
   ```

**Expected**: "✓ TensorRT found at libs/TensorRT"

---

### Step 4: Build PyBind11 Python Module

```bash
cd /teamspace/studios/this_studio/audio2face-mvp/Audio2Face-3D-SDK

# A. Install PyBind11
pip install pybind11

# B. Add python-wrapper to build
echo "add_subdirectory(python-wrapper)" >> audio2face-sdk/source/samples/CMakeLists.txt

# C. Set library path for TensorRT
export LD_LIBRARY_PATH=/teamspace/studios/this_studio/audio2face-mvp/libs/TensorRT/lib:$LD_LIBRARY_PATH

# D. Configure CMake with TensorRT
cmake -B _build -S . -DCMAKE_BUILD_TYPE=Release \
    -DTENSORRT_ROOT_DIR=/teamspace/studios/this_studio/audio2face-mvp/libs/TensorRT \
    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda

# E. Build PyBind11 wrapper
cmake --build _build --target audio2face_py -j$(nproc)

# F. Copy Python module to backend
cp _build/python/audio2face_py.*.so ../backend/
```

**Expected**:
- Build completes without errors
- File created: `_build/python/audio2face_py.cpython-*.so`
- File copied to: `backend/audio2face_py.*.so`

---

### Step 5: Test PyBind11 Module Import

```bash
cd /teamspace/studios/this_studio/audio2face-mvp/backend

python3 -c "import audio2face_py; print('✓ Module loaded successfully!')"
```

**Expected**: "✓ Module loaded successfully!"

**If it fails**: Check error message and ensure:
- TensorRT libraries are in LD_LIBRARY_PATH
- Module was copied to backend directory
- No import errors

---

### Step 6: Start Backend Server

```bash
cd /teamspace/studios/this_studio/audio2face-mvp/backend

# Set library paths
export LD_LIBRARY_PATH=/teamspace/studios/this_studio/audio2face-mvp/libs/TensorRT/lib:/teamspace/studios/this_studio/audio2face-mvp/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:$LD_LIBRARY_PATH

# Start backend
python3 main.py
```

**Expected Output**:
```
Loading Audio2Face model from: ...
Character: Claire
FPS: 60
✓ Audio2Face SDK initialized successfully
✓ Blendshapes: 68
INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

### Step 7: Start Frontend (New Terminal)

```bash
cd /teamspace/studios/this_studio/audio2face-mvp/frontend
python3 -m http.server 3000
```

**Expected**: "Serving HTTP on 0.0.0.0 port 3000"

---

### Step 8: Test API Endpoints

In a new terminal:

```bash
# Test health
curl http://localhost:8000/health

# Expected: {"status":"healthy","sdk_loaded":true}

# Test blendshape names
curl http://localhost:8000/blendshape-names

# Expected: ["eyeBlinkLeft", "eyeLookDownLeft", ...]
```

---

### Step 9: Test Audio Processing (Full Pipeline)

```bash
cd /teamspace/studios/this_studio/audio2face-mvp

# Generate test audio
cd test_audio
python3 generate_test_audio.py
cd ..

# Process audio
curl -X POST http://localhost:8000/process-audio \
  -F "file=@test_audio/sample_sine.wav" \
  | python3 -m json.tool | head -30
```

**Expected**: JSON with blendshapes array

---

## 🎯 Quick Commands Reference

```bash
# Check status
make status

# Verify TensorRT
make verify-tensorrt

# Run both servers (uses tmux)
make run

# Stop servers
make stop

# View logs
make logs-backend
make logs-frontend
```

---

## 🔧 Troubleshooting

### Problem: TensorRT not found
**Solution**: Make sure you ran `make setup-tensorrt` or manually downloaded TensorRT to `libs/TensorRT/`

### Problem: PyBind11 build fails
**Solution**:
1. Check TensorRT is installed: `make verify-tensorrt`
2. Check CUDA is available: `nvcc --version`
3. Install pybind11: `pip install pybind11`

### Problem: Backend fails to start with "libnvinfer.so.10 not found"
**Solution**: Export LD_LIBRARY_PATH before starting:
```bash
export LD_LIBRARY_PATH=/teamspace/studios/this_studio/audio2face-mvp/libs/TensorRT/lib:/teamspace/studios/this_studio/audio2face-mvp/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:$LD_LIBRARY_PATH
```

### Problem: "ImportError: No module named 'audio2face_py'"
**Solution**:
1. Check module exists: `ls backend/audio2face_py.*.so`
2. If missing, rebuild: Follow Step 4
3. Copy to backend: `cp Audio2Face-3D-SDK/_build/python/audio2face_py.*.so backend/`

---

## ✅ Success Checklist

Mark these off as you complete them:

- [ ] Step 1: Checked startup log (automatic recovery ran)
- [ ] Step 2: Verified project status
- [ ] Step 3: Installed TensorRT
- [ ] Step 4: Built PyBind11 module
- [ ] Step 5: Tested module import
- [ ] Step 6: Backend started successfully
- [ ] Step 7: Frontend started successfully
- [ ] Step 8: API endpoints responding
- [ ] Step 9: Audio processing works

**When all checked**: System is fully operational! 🎉

---

## 📞 Need Help?

See detailed documentation:
- `IMPLEMENTATION_COMPLETE.md` - Full implementation details
- `SETUP_COMPLETE.md` - Technical architecture
- `README.md` - Quick start guide
- `Audio2Face-3D-SDK/audio2face-sdk/source/samples/python-wrapper/BUILD_INSTRUCTIONS.md` - Build details
