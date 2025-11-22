# Audio2Face Wrapper - Persistence Checklist ✅

## What's Been Persisted

All fixes and improvements have been committed to git and will survive restarts.

### Git Commits

#### 1. Audio2Face-3D-SDK Repository
```bash
Commit: 1042f5c
Message: Fix PyBind11 wrapper for Audio2Face SDK

Files changed:
✅ audio2face-sdk/source/samples/python-wrapper/audio2face_py.cpp (NEW)
   - Complete rewrite with correct API
   - 261 lines of production-ready code
   - Based on official NVIDIA samples
```

#### 2. Main Project Repository
```bash
Commit: 47f9bb5
Message: Update Audio2Face wrapper and add build automation

Files changed:
✅ backend/a2f_wrapper.py (UPDATED)
   - Updated to match new PyBind11 API
   - Improved error handling

✅ scripts/build_audio2face_wrapper.sh (NEW)
   - Automated build script
   - One-command rebuild capability

✅ AUDIO2FACE_INTEGRATION.md (NEW)
   - Complete integration guide
   - API reference
   - Troubleshooting guide

✅ FIXED_WRAPPER_SUMMARY.md (NEW)
   - What was broken
   - What was fixed
   - Technical details
```

### Build Artifacts

The compiled PyBind11 module is stored in two locations:

```
✅ Audio2Face-3D-SDK/_build/python/audio2face_py.cpython-312-x86_64-linux-gnu.so
   - Build output directory
   - Regenerated on rebuild

✅ backend/audio2face_py.cpython-312-x86_64-linux-gnu.so
   - Runtime location
   - Used by Python imports
   - Auto-copied by on_start.sh if missing
```

### Startup Automation

The `on_start.sh` script (runs on Lightning.ai restart) now includes:

```bash
✅ Check for PyBind11 module in backend/
✅ Auto-copy from build directory if found
✅ Convenience alias: a2f-build-wrapper
```

## How to Rebuild After Restart

### Quick Method (Recommended)
```bash
# Use the convenience alias (added to ~/.bashrc)
a2f-build-wrapper
```

### Manual Method
```bash
# Run the build script directly
cd /teamspace/studios/this_studio/audio2face-mvp
./scripts/build_audio2face_wrapper.sh
```

### From Makefile
```bash
# If you prefer make
cd /teamspace/studios/this_studio/audio2face-mvp
make pybind11-all
```

### From SDK Directory
```bash
# Low-level build
cd Audio2Face-3D-SDK
mkdir -p _build/python
make -C _build audio2face_py
cp _build/python/audio2face_py*.so ../backend/
```

## Verification After Restart

Run these commands to verify everything persisted correctly:

### 1. Check Git Commits
```bash
# Main project
cd /teamspace/studios/this_studio/audio2face-mvp
git log --oneline | head -5

# Should show:
# 47f9bb5 Update Audio2Face wrapper and add build automation

# SDK
cd Audio2Face-3D-SDK
git log --oneline | head -5

# Should show:
# 1042f5c Fix PyBind11 wrapper for Audio2Face SDK
```

### 2. Check Source Files
```bash
# Fixed C++ wrapper exists
ls -lh Audio2Face-3D-SDK/audio2face-sdk/source/samples/python-wrapper/audio2face_py.cpp

# Build script exists
ls -lh scripts/build_audio2face_wrapper.sh

# Documentation exists
ls -lh AUDIO2FACE_INTEGRATION.md FIXED_WRAPPER_SUMMARY.md
```

### 3. Check Compiled Module
```bash
# Module in backend
ls -lh backend/audio2face_py*.so

# Module in build directory
ls -lh Audio2Face-3D-SDK/_build/python/audio2face_py*.so
```

### 4. Test Module Import
```bash
cd backend
python3 -c "import audio2face_py; print('✓ Module loads successfully')"
```

## What Happens on Lightning.ai Restart

### Automatic (via on_start.sh)
1. ✅ Python dependencies installed
2. ✅ Environment variables configured
3. ✅ PyBind11 module copied to backend (if exists in build dir)
4. ✅ Convenience aliases added

### Manual (if module rebuild needed)
1. ⚠️ Compiled .so file may be lost (if _build was cleared)
2. 💡 Simply run: `a2f-build-wrapper`
3. ✅ Module rebuilds in ~30 seconds

## Files Tracked in Git

### Main Repository
```
✅ backend/a2f_wrapper.py
✅ scripts/build_audio2face_wrapper.sh
✅ AUDIO2FACE_INTEGRATION.md
✅ FIXED_WRAPPER_SUMMARY.md
✅ PERSISTENCE_CHECKLIST.md (this file)
✅ on_start.sh
```

### SDK Repository (Audio2Face-3D-SDK)
```
✅ audio2face-sdk/source/samples/python-wrapper/audio2face_py.cpp
```

### NOT Tracked (Build Artifacts)
```
❌ backend/audio2face_py*.so (binary)
❌ Audio2Face-3D-SDK/_build/ (build directory)
❌ Audio2Face-3D-SDK/models/ (large model files)
```

## Recovery Procedure

If something is lost after restart:

### Source Code Missing
```bash
# This should NEVER happen (tracked in git)
git status
git checkout HEAD -- <missing_file>
```

### Compiled Module Missing
```bash
# Rebuild it (takes ~30 seconds)
a2f-build-wrapper

# Or manually:
cd Audio2Face-3D-SDK
mkdir -p _build/python
make -C _build audio2face_py
cp _build/python/audio2face_py*.so ../backend/
```

### Build Directory Cleared
```bash
# Reconfigure CMake
cd Audio2Face-3D-SDK
export TENSORRT_ROOT_DIR="/path/to/tensorrt"
cmake -B _build -S . -DCMAKE_BUILD_TYPE=Release

# Then rebuild
a2f-build-wrapper
```

## Summary

| Item | Persisted? | How |
|------|------------|-----|
| C++ Source Code | ✅ Yes | Git (SDK repo) |
| Python Wrapper | ✅ Yes | Git (main repo) |
| Build Script | ✅ Yes | Git (main repo) |
| Documentation | ✅ Yes | Git (main repo) |
| Compiled .so | ⚠️ Maybe | on_start.sh copies if exists |
| _build Directory | ❌ No | Rebuild with script |

**Bottom Line:** All **source code** is safe in git. The **compiled module** may need a quick rebuild after restart, but it's automated with `a2f-build-wrapper`.

## Quick Reference

```bash
# Check what's persisted
git log --oneline | head -5
git status

# Rebuild module after restart
a2f-build-wrapper

# Verify everything works
cd backend && python3 -c "import audio2face_py"

# If module import fails
source ../env_setup.sh
export LD_LIBRARY_PATH=/path/to/tensorrt/lib:$LD_LIBRARY_PATH
```

---

**Last Updated:** $(date)
**Status:** ✅ All fixes committed and persisted
