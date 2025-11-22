# Persistence & Automation Guide

This guide explains all the automated features and persistence mechanisms for the Audio2Face MVP application.

## 🎯 Overview

Your application now includes:
- ✅ **Automated Health Checks** - Frontend & backend validation
- ✅ **Persistence Scripts** - Survives Lightning.ai restarts
- ✅ **One-Command Setup** - `make automated-setup`
- ✅ **Graceful Degradation** - Works without SDK for UI testing

## 🚀 Automated Setup

### Quick Start (Current State)

Your app is **ready to use right now** with:

```bash
# Check everything
make verify-setup

# Start the app
make run-backend  # Terminal 1
make run-frontend # Terminal 2

# Access
http://localhost:3000
```

**Current Capabilities:**
- ✅ Full UI and 3D rendering
- ✅ Avatar display (you added it!)
- ✅ Backend API
- ✅ Health checking
- ⚠️ Audio processing (requires SDK build - see below)

### What Works Without SDK

The application is fully functional for:
- UI development and testing
- 3D scene visualization
- Avatar loading and display
- Backend API testing
- Health monitoring
- File upload interface

**Only unavailable**: Audio → face animation processing

## 📦 What's Been Automated

### 1. Automated Setup Script
**File**: `scripts/automated_setup.sh`

Automatically:
- ✅ Installs all Python dependencies
- ✅ Configures TensorRT paths
- ✅ Sets up build environment
- ✅ Attempts SDK build
- ✅ Copies modules to backend
- ✅ Creates env_setup.sh
- ✅ Runs health checks

**Run it**:
```bash
make automated-setup
```

### 2. Persistence Hook (on_start.sh)
**File**: `on_start.sh`

Runs on Lightning.ai restart and:
- ✅ Checks/installs dependencies
- ✅ Configures environment
- ✅ Checks SDK status
- ✅ Verifies avatar
- ✅ Creates convenience aliases
- ✅ Logs everything

**Setup for auto-run**:
```bash
make persist-setup
```

Then follow the instructions to add to Lightning.ai startup.

### 3. Health Check Systems

**Frontend** (`frontend/js/health-check.js`):
- Runs automatically on page load
- Checks all dependencies
- Shows clear status in console
- Animated progress indicators

**Backend** (`backend/health_validator.py`):
- Runs on server start
- Validates all requirements
- Shows detailed status
- Graceful degradation

**System** (`scripts/verify_setup.sh`):
- Complete system check
- 9 categories of validation
- Detailed reporting
- Run anytime with `make verify-setup`

### 4. Makefile Automation

New commands:
```bash
make automated-setup  # Complete automated setup
make persist-setup    # Configure persistence
make verify-setup     # Full system verification
make health-backend   # Backend health only
make health-frontend  # Frontend health
make health-all       # All health checks
```

## 🔧 TensorRT & SDK Build Status

### Current Situation

**TensorRT Runtime**: ✅ Installed via pip
- Version: 10.14.1
- Location: `/home/zeus/miniconda3/.../tensorrt_libs/`
- Libraries: Available (libnvinfer.so, etc.)

**TensorRT Development Headers**: ❌ Not included in pip package
- Required for: SDK building
- Status: Not available in pip version
- Impact: Cannot build SDK automatically

### Why SDK Build Fails

The pip-installed TensorRT package includes:
- ✅ Runtime libraries (.so files)
- ✅ Python bindings
- ❌ Development headers (.h files)
- ❌ CMake configuration files

The Audio2Face SDK requires the **full TensorRT development package** from NVIDIA, which includes headers for C++ compilation.

### Solutions

#### Option 1: Use Without SDK (Recommended for UI Development)
**What you have now** - Perfect for:
- UI development
- Frontend testing
- 3D visualization
- Backend API development
- Learning the codebase

```bash
# Just use it!
make run
# App works great for everything except audio processing
```

#### Option 2: Manual TensorRT Setup (For Full Functionality)

To enable audio processing:

1. **Download Full TensorRT**:
   - Visit: https://developer.nvidia.com/tensorrt-download
   - Version: TensorRT 10.x for Linux x86_64, CUDA 12.6
   - Requires: Free NVIDIA Developer account

2. **Extract and Configure**:
   ```bash
   # Upload .tar.gz to /teamspace/studios/this_studio/
   tar -xzf TensorRT-10.*.tar.gz
   mv TensorRT-10.* /teamspace/studios/this_studio/audio2face-mvp/libs/TensorRT
   ```

3. **Run Automated Setup**:
   ```bash
   cd /teamspace/studios/this_studio/audio2face-mvp
   make automated-setup
   ```

4. **Verify**:
   ```bash
   make verify-setup
   ```

#### Option 3: Use Pre-built Module (If Available)

If someone shares a pre-built `audio2face_py.so`:

```bash
# Copy to backend
cp audio2face_py.*.so backend/

# Set library path
source env_setup.sh

# Test
cd backend && python -c "import audio2face_py"
```

## 🔄 Persistence Configuration

### Automatic Restart Recovery

Your `on_start.sh` handles restarts automatically:

**To Enable in Lightning.ai**:

1. Go to Studio Settings
2. Find "Startup Command" or "On Start Script"
3. Add:
   ```bash
   bash /teamspace/studios/this_studio/audio2face-mvp/on_start.sh
   ```
4. Save settings

**What it does**:
- Checks dependencies
- Configures environment
- Verifies setup
- Creates logs in `.logs/`
- Sets up convenience aliases

### Convenience Aliases

After running `on_start.sh`, you get:

```bash
a2f-setup    # Run automated setup
a2f-verify   # Verify system
a2f-run      # Start application
a2f-backend  # Start backend only
a2f-frontend # Start frontend only
a2f-status   # Check status
```

### Environment Configuration

The `env_setup.sh` file (auto-generated) contains:

```bash
export PROJECT_ROOT="/teamspace/studios/this_studio/audio2face-mvp"
export TENSORRT_DIR="..."
export LD_LIBRARY_PATH="..."
export CMAKE_PREFIX_PATH="..."
```

**Use it**:
```bash
source env_setup.sh  # Before running backend
```

## 📊 Health Check Details

### Frontend Health Checks

Open browser console (F12) to see:

```
🚀 Starting Audio2Face MVP...
🏥 Running health checks...
✓ THREE.js Library: PASSED
✓ GLTFLoader: PASSED
✓ OrbitControls: PASSED
✓ Backend API: PASSED
⚠ Audio2Face SDK: WARNING - SDK not initialized
✓ Avatar File: PASSED (15M)

📊 Health Check Summary: {
  passed: 5,
  failed: 0,
  warnings: 1,
  healthy: true
}
```

### Backend Health Checks

Backend startup shows:

```
🏥 Running Backend Health Checks...
✓ Python Version: Python 3.12.11
✓ FastAPI: FastAPI 0.104.1
✓ NumPy: NumPy 2.3.4
⚠ Audio2Face Module: audio2face_py not available
✓ System ready with warnings
```

### System Verification

Run `make verify-setup` to see:

```
1. Project Structure ✓
2. Python Environment ✓
3. Frontend ✓
4. Backend ✓
5. Audio2Face SDK ⚠
6. TensorRT ⚠
7. Model Files ⚠
8. Running Services ✓
9. GPU & CUDA ✓

Summary: 25 passed, 0 failed, 4 warnings
⚠ System operational with warnings.
```

## 🎯 Current Status Summary

### What's Fully Working ✅

- Frontend with health checks
- Backend with validation
- 3D rendering (THREE.js)
- Avatar display
- Automated setup scripts
- Persistence mechanisms
- Health monitoring
- Convenience commands
- Documentation

### What Needs Manual Setup ⚠️

- TensorRT development headers
- SDK build (depends on TensorRT)
- Audio processing (depends on SDK)

### Impact

**For UI Development**: Everything works perfectly!
**For Audio Processing**: Need TensorRT dev package from NVIDIA

## 📝 Daily Workflow

### Development (Current State)

```bash
# Start working
cd /teamspace/studios/this_studio/audio2face-mvp

# Check status
make status

# Start app
make run-backend   # Terminal 1
make run-frontend  # Terminal 2

# Access
open http://localhost:3000

# Make changes, test UI, develop features
```

### After Restart

```bash
# Lightning.ai restarts are automatic if you configured on_start.sh

# Or manually:
./on_start.sh

# Then:
a2f-run
```

### Verification Anytime

```bash
make verify-setup  # Full check
make health-all    # Health checks
make status        # Quick status
```

## 🚀 Next Steps

### Immediate (Works Now)
1. Use the UI for development ✅
2. Test avatar display ✅
3. Develop frontend features ✅
4. Test backend API ✅

### When Ready for Audio Processing
1. Download TensorRT from NVIDIA
2. Run `make automated-setup`
3. Verify with `make verify-setup`
4. Test audio processing

## 📚 Documentation Reference

- `QUICK_START.md` - Get started fast
- `AUTOMATED_HEALTH_CHECKS.md` - Health system details
- `AFTER_RESTART_CHECKLIST.md` - Manual restart recovery
- `IMPLEMENTATION_COMPLETE.md` - Technical details
- `README.md` - Project overview

## ✅ Summary

Your Audio2Face MVP now has:

1. **Complete Automation**
   - One-command setup
   - Auto health checks
   - Persistence hooks
   - Convenience aliases

2. **Production-Ready Features**
   - Comprehensive validation
   - Graceful degradation
   - Clear error messages
   - Detailed logging

3. **Excellent Developer Experience**
   - Works immediately
   - Clear status at all times
   - Easy troubleshooting
   - Well documented

4. **Flexible Deployment**
   - Works without SDK (UI dev)
   - Can add SDK later (audio processing)
   - Survives restarts
   - Easy to verify

**You can start developing right now!** 🎉

The app is fully functional for UI development and testing. Audio processing can be added later when you have the TensorRT development package.

All automation scripts are in place and will persist across restarts once you configure `on_start.sh` in Lightning.ai settings.
