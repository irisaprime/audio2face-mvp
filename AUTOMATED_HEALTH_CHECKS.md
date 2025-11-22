# Automated Health Checks & Validation

This document describes the automated health check and validation systems built into the Audio2Face MVP application.

## Overview

The application now includes comprehensive automated health checking at multiple levels:
- **Frontend**: Real-time browser-based health checks
- **Backend**: Python-based dependency and environment validation
- **System**: Shell-based comprehensive verification script
- **Makefile**: Easy-to-use commands for health checking

## 🎯 Quick Start

### Check Everything
```bash
cd /teamspace/studios/this_studio/audio2face-mvp
make verify-setup
```

### Check Backend Only
```bash
make health-backend
```

### Check Individual Components
```bash
# Backend health (Python dependencies, SDK status)
cd backend && python3 health_validator.py

# Frontend health (open browser console at http://localhost:3000)
# Health checks run automatically on page load

# Comprehensive system check
./scripts/verify_setup.sh
```

---

## 📋 Frontend Health Checks

### Location
- Script: `frontend/js/health-check.js`
- Auto-runs: On page load in `frontend/js/app.js`

### Checks Performed

| Check | Type | Description |
|-------|------|-------------|
| THREE.js Library | Critical | Verifies THREE.js is loaded |
| GLTFLoader | Warning | Checks if GLTFLoader is available |
| OrbitControls | Warning | Checks if OrbitControls is available |
| Backend API | Critical | Tests connection to backend |
| Audio2Face SDK | Warning | Checks if SDK is initialized |
| Avatar File | Warning | Verifies avatar.glb exists |

### How It Works

1. **Automatic Execution**:
   - Runs automatically when page loads
   - Results logged to browser console (F12)
   - Status shown in UI

2. **Critical vs Warning**:
   - **Critical failures**: App won't start (e.g., no THREE.js)
   - **Warnings**: App works with limited functionality (e.g., no SDK)

3. **User Feedback**:
   - Clear status messages in UI
   - Animated loading indicators
   - Helpful error messages with fixes

### Example Console Output
```
🚀 Starting Audio2Face MVP...
🏥 Running health checks...
✓ THREE.js Library: PASSED
✓ GLTFLoader: PASSED
✓ OrbitControls: PASSED
✓ Backend API: PASSED
⚠ Audio2Face SDK: WARNING - SDK not initialized
✓ Avatar File: PASSED

📊 Health Check Summary: {passed: 5, failed: 0, warnings: 1, healthy: true}
✓ 3D scene initialized
✓ Avatar loaded successfully
✅ Initialization complete!
```

### Integration

The health check system is automatically integrated:

```javascript
// In app.js
async function init() {
    // Run health checks first
    const healthResults = await healthChecker.runAll();
    const summary = healthChecker.getSummary();

    // Only proceed if healthy
    if (!summary.healthy) {
        // Show errors and stop
        return;
    }

    // Continue with initialization...
}
```

---

## 🔧 Backend Health Checks

### Location
- Script: `backend/health_validator.py`
- Auto-runs: On backend startup in `backend/main.py`

### Checks Performed

| Check | Type | Description |
|-------|------|-------------|
| Python Version | Critical | Requires Python 3.8+ |
| FastAPI | Critical | Web framework |
| Uvicorn | Critical | ASGI server |
| NumPy | Critical | Numerical computing |
| SciPy | Critical | Scientific computing |
| librosa | Critical | Audio processing |
| soundfile | Critical | Audio I/O |
| Config File | Critical | config.py must exist |
| Temp Directory | Critical | Must be writable |
| Audio2Face Module | Warning | PyBind11 module |
| TensorRT Libraries | Warning | GPU inference |
| Model Path | Warning | A2F model files |

### How It Works

1. **Startup Validation**:
   ```python
   # In main.py
   validator = run_all_checks(verbose=True)

   if not validator.is_healthy():
       print("❌ Critical issues detected")
       # Backend still starts for debugging
   ```

2. **Graceful Degradation**:
   - Critical failures: Logged but backend starts
   - Warnings: Feature unavailable (e.g., no SDK = no processing)

3. **Detailed Output**:
   ```
   🏥 Running Backend Health Checks...
   ============================================================

   ✓ Python Version: Python 3.12.11
   ✓ FastAPI: FastAPI 0.104.1
   ✓ Uvicorn: Uvicorn 0.24.0
   ✓ NumPy: NumPy 1.26.4
   ✓ SciPy: SciPy 1.11.4
   ✓ librosa: librosa 0.10.1
   ✓ soundfile: soundfile 0.12.1
   ✓ Config File: config.py found
   ✓ Temp Directory: Temp directory: /tmp
   ⚠ Audio2Face Module: audio2face_py not available
   ⚠ TensorRT Libraries: TensorRT libraries not found
   ⚠ Model Path: Model not found

   ============================================================
   Health Check Summary
   ============================================================
   Passed:   9
   Failed:   0
   Warnings: 3
   ============================================================
   ⚠ System ready with warnings
   ============================================================
   ```

### Manual Usage

```bash
# Run health checks independently
cd backend
python3 health_validator.py

# Exit code: 0 if healthy, 1 if critical failures
```

---

## 🏥 Comprehensive System Verification

### Location
- Script: `scripts/verify_setup.sh`
- Command: `make verify-setup`

### Checks Performed

#### 1. Project Structure
- backend/ directory
- frontend/ directory
- Audio2Face-3D-SDK/ directory
- Makefile

#### 2. Python Environment
- Python 3 installation
- All required packages (fastapi, uvicorn, numpy, scipy, librosa, soundfile, pybind11)
- Package versions

#### 3. Frontend Files
- HTML, CSS, JavaScript files
- Health check script
- Avatar file (optional)

#### 4. Backend Files
- main.py, config.py, utils
- Health validator
- PyBind11 module (optional)

#### 5. Audio2Face SDK
- Build directory
- SDK libraries
- Compiled components

#### 6. TensorRT
- LD_LIBRARY_PATH configuration
- Library files
- Multiple search locations

#### 7. Model Files
- Model directory
- model.json
- Model configuration

#### 8. Running Services
- Backend (port 8000)
- Frontend (port 3000)
- Health status

#### 9. GPU & CUDA
- nvidia-smi availability
- GPU detection
- CUDA compiler

### Example Output

```bash
$ make verify-setup

==================================================
Audio2Face MVP - System Verification
==================================================

1. Project Structure
==================================================
✓ backend/ directory exists
✓ frontend/ directory exists
✓ Audio2Face-3D-SDK/ directory exists
✓ Makefile exists

2. Python Environment
==================================================
✓ Python installed: Python 3.12.11
✓ fastapi installed (v0.104.1)
✓ uvicorn installed (v0.24.0)
✓ numpy installed (v1.26.4)
✓ scipy installed (v1.11.4)
✓ librosa installed (v0.10.1)
✓ soundfile installed (v0.12.1)
✓ pybind11 installed (v3.0.1)

3. Frontend
==================================================
✓ frontend/index.html exists
✓ frontend/js/app.js exists
✓ frontend/js/health-check.js exists
✓ frontend/js/scene-manager.js exists
✓ frontend/js/avatar-controller.js exists
✓ frontend/js/audio-player.js exists
✓ frontend/css/style.css exists
✓ Avatar file exists (15M)

4. Backend
==================================================
✓ backend/main.py exists
✓ backend/config.py exists
✓ backend/audio_utils.py exists
✓ backend/a2f_wrapper.py exists
✓ backend/health_validator.py exists
⚠ PyBind11 module not built (run: make build-sdk)

5. Audio2Face SDK
==================================================
⚠ SDK not built yet (run: make build-sdk)

6. TensorRT
==================================================
⚠ TensorRT not in LD_LIBRARY_PATH
⚠ TensorRT library not found (run: make setup-tensorrt)

7. Model Files
==================================================
⚠ Model directory not found

8. Running Services
==================================================
✓ Backend running and healthy (port 8000)
✓ Frontend running (port 3000)

9. GPU & CUDA
==================================================
✓ GPU detected: NVIDIA A100-SXM4-40GB
✓ CUDA installed: V12.6

==================================================
Verification Summary
==================================================

Passed:   25
Failed:   0
Warnings: 4

⚠ System operational with 4 warning(s).
Some features may be limited.

===================================================
```

---

## 🛠️ Makefile Commands

### Health Check Commands

| Command | Description |
|---------|-------------|
| `make verify-setup` | Comprehensive system verification (all checks) |
| `make health-backend` | Backend health check only |
| `make health-frontend` | Frontend health check instructions |
| `make health-all` | Run all health checks |
| `make status` | Quick project status |

### Integration with Workflow

```bash
# After setup or restart
make verify-setup

# Before starting services
make health-backend

# After starting services
curl http://localhost:8000/health
```

---

## 🚨 Troubleshooting

### Frontend Won't Load

1. Check browser console (F12)
2. Look for failed health checks
3. Common issues:
   - Backend not running → `make run-backend`
   - THREE.js not loading → Check CDN connection
   - Avatar missing → Download from readyplayer.me

### Backend Won't Start

1. Run health check:
   ```bash
   cd backend && python3 health_validator.py
   ```

2. Common issues:
   - Missing dependencies → `pip install -r requirements.txt`
   - Config missing → Check config.py exists
   - Port in use → `pkill -f uvicorn`

### SDK Not Working

1. Check if built:
   ```bash
   ls backend/audio2face_py*.so
   ```

2. Check TensorRT:
   ```bash
   make verify-tensorrt
   ```

3. Rebuild if needed:
   ```bash
   make build-sdk
   ```

---

## 📊 Health Check API Endpoints

The backend exposes health check endpoints:

### GET /health
Returns backend health status

```bash
$ curl http://localhost:8000/health
{
  "status": "healthy",  # or "unhealthy"
  "sdk_loaded": true    # or false
}
```

### GET /
Returns general info

```bash
$ curl http://localhost:8000/
{
  "message": "Audio2Face MVP API",
  "status": "ready",
  "model": "Audio2Face-3D-v3.0",
  "note": "SDK requires GPU and built libraries to function"
}
```

---

## 🎯 Best Practices

### During Development

1. **Before starting work**:
   ```bash
   make verify-setup
   ```

2. **After making changes**:
   ```bash
   make health-backend  # If backend changed
   # Refresh browser to see frontend health checks
   ```

3. **Before committing**:
   ```bash
   make verify-setup
   make test
   ```

### In Production

1. **After deployment**:
   ```bash
   make verify-setup
   ```

2. **Monitoring**:
   ```bash
   # Add to monitoring scripts
   curl -f http://localhost:8000/health || alert "Backend unhealthy"
   ```

3. **Automated checks**:
   - Add `make health-backend` to CI/CD pipeline
   - Monitor `/health` endpoint

---

## 🔄 Continuous Validation

### On Startup (Automatic)

- **Frontend**: Health checks run on page load
- **Backend**: Health checks run on server start

### Manual (As Needed)

```bash
# Full verification
make verify-setup

# Quick check
make status
```

### CI/CD Integration

```yaml
# Example GitHub Actions
steps:
  - name: Verify Setup
    run: make verify-setup

  - name: Check Backend Health
    run: make health-backend

  - name: Run Tests
    run: make test
```

---

## 📝 Summary

The automated health check system provides:

- ✅ **Early Detection**: Catch issues before they cause failures
- ✅ **Clear Feedback**: Detailed, actionable error messages
- ✅ **Graceful Degradation**: App works with limited features if possible
- ✅ **Easy Debugging**: Know exactly what's wrong and how to fix it
- ✅ **Production Ready**: Monitor health in deployment

**Usage**: Just run `make verify-setup` to check everything!
