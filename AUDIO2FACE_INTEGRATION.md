# Audio2Face SDK Integration Guide

This document explains the Audio2Face-3D SDK integration in this project, including the corrected PyBind11 wrapper implementation.

## Overview

The integration uses NVIDIA's official Audio2Face-3D SDK to generate facial blendshape animations from audio input. The implementation includes:

1. **Corrected C++ PyBind11 Wrapper** (`audio2face_py.cpp`) - Fixed version based on official SDK samples
2. **Python Wrapper** (`a2f_wrapper.py`) - High-level Python interface
3. **Build System** - Automated build and installation scripts

## Architecture

```
┌─────────────────────────────────────────────────┐
│         FastAPI Backend (main.py)               │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│      Python Wrapper (a2f_wrapper.py)            │
│  - Audio2FaceSDK class                          │
│  - High-level API                               │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│   PyBind11 Module (audio2face_py.so)            │
│  - BlendshapeModel class (C++)                  │
│  - Direct SDK interface                         │
└──────────────────┬──────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────┐
│   Audio2Face-3D SDK (Native C++ Library)        │
│  - ReadDiffusionBlendshapeSolveExecutorBundle   │
│  - IBlendshapeExecutor                          │
│  - CUDA/TensorRT inference                      │
└─────────────────────────────────────────────────┘
```

## Key Components

### 1. PyBind11 Wrapper (`audio2face_py.cpp`)

**Location:** `Audio2Face-3D-SDK/audio2face-sdk/source/samples/python-wrapper/audio2face_py.cpp`

**What was fixed:**
- Uses correct SDK API: `ReadDiffusionBlendshapeSolveExecutorBundle()` (not the non-existent `ReadRegressionBlendshapeExecutorBundle`)
- Proper callback signature: `IBlendshapeExecutor::HostResults` with error code parameter
- Correct method calls: `GetWeightCount()` instead of non-existent `GetNbBlendshapeWeights()`
- Proper numpy array creation using `std::vector<ssize_t>` for shape
- Memory-safe RAII patterns with custom `Destroyer` functor
- Proper audio/emotion accumulator usage following official samples

**Key Features:**
- High-performance C++ implementation
- Direct access to GPU-accelerated inference
- Zero-copy numpy array interface where possible
- Thread-safe blendshape collection via callbacks
- Proper CUDA stream management

### 2. Python Wrapper (`a2f_wrapper.py`)

**Location:** `backend/a2f_wrapper.py`

**Purpose:** Provides a clean Python interface with:
- Automatic audio normalization and validation
- Error handling and user-friendly messages
- ARKit blendshape name mapping
- Result packaging with timestamps and metadata

**API:**
```python
sdk = Audio2FaceSDK(character_index=0, use_gpu_solver=False)

# Process audio (16kHz mono float32)
result = sdk.process_audio(audio_numpy_array)

# Result contains:
# - blendshapes: np.ndarray (num_frames, num_blendshapes)
# - timestamps: np.ndarray (num_frames,)
# - fps: 60
# - duration: float (seconds)
# - num_frames: int
```

### 3. Build System

**Build Script:** `scripts/build_audio2face_wrapper.sh`

Automates:
1. SDK directory verification
2. CMake configuration (if needed)
3. Python output directory creation
4. PyBind11 module compilation
5. Module installation to backend
6. Import verification

**Usage:**
```bash
./scripts/build_audio2face_wrapper.sh
```

## Build Requirements

### System Dependencies
- **CUDA:** ≥12.8.0 (12.9 recommended)
- **TensorRT:** ≥10.13, <11.0
- **Python:** ≥3.8, ≤3.10.x (SDK requirement)
- **CMake:** ≥3.20
- **GCC/G++:** Compatible with CUDA
- **PyBind11:** Installed via pip

### Python Packages
```bash
pip install pybind11 numpy scipy librosa soundfile
```

## Build Instructions

### Option 1: Automated Build (Recommended)

```bash
# From project root
./scripts/build_audio2face_wrapper.sh
```

### Option 2: Manual Build

```bash
# 1. Configure SDK build (first time only)
cd Audio2Face-3D-SDK
export TENSORRT_ROOT_DIR="/path/to/tensorrt"
cmake -B _build -S . -DCMAKE_BUILD_TYPE=Release

# 2. Create python output directory
mkdir -p _build/python

# 3. Build PyBind11 module
make -C _build audio2face_py -j$(nproc)

# 4. Copy to backend
cp _build/python/audio2face_py*.so ../backend/

# 5. Verify
cd ../backend
python3 -c "import audio2face_py; print('Success!')"
```

## Usage

### Python Code Example

```python
import numpy as np
from a2f_wrapper import Audio2FaceSDK

# Initialize SDK
sdk = Audio2FaceSDK(
    character_index=0,  # 0=Claire, 1=James, 2=Mark
    use_gpu_solver=False  # CPU solver for easier debugging
)

# Load audio (must be 16kHz mono)
import librosa
audio, sr = librosa.load("speech.wav", sr=16000, mono=True)

# Generate blendshapes
result = sdk.process_audio(audio)

# Access results
blendshapes = result['blendshapes']  # Shape: (num_frames, 52)
fps = result['fps']  # 60
timestamps = result['timestamps']
```

### FastAPI Integration

The backend automatically initializes the SDK on startup (see `backend/main.py`):

```python
from a2f_wrapper import Audio2FaceSDK

# SDK initialization with error handling
a2f_sdk = Audio2FaceSDK()

@app.post("/process-audio")
async def process_audio(file: UploadFile):
    # Audio preprocessing
    audio, sr = audio_processor.load_and_preprocess(file)

    # SDK inference
    result = a2f_sdk.process_audio(audio)

    return result
```

## Performance Considerations

### GPU vs CPU Solver
- **GPU Solver** (`use_gpu_solver=True`): Faster, requires more VRAM
- **CPU Solver** (`use_gpu_solver=False`): Slower, but easier to debug and lower memory footprint

### Typical Performance (RTX A6000)
- **Audio Processing:** ~500-800ms for 4 seconds of audio
- **FPS:** Fixed at 60 (diffusion models)
- **Throughput:** Faster than real-time (4s audio → <1s processing)

### Memory Usage
- **Model Loading:** ~2-4GB VRAM
- **Inference:** ~1-2GB VRAM per track
- **Python Overhead:** ~100-200MB RAM

## Troubleshooting

### Build Errors

**Error:** `No such file or directory: python/audio2face_py.so`
```bash
mkdir -p Audio2Face-3D-SDK/_build/python
```

**Error:** `cannot find -lnvinfer`
```bash
export LD_LIBRARY_PATH=/path/to/tensorrt/lib:$LD_LIBRARY_PATH
export TENSORRT_ROOT_DIR=/path/to/tensorrt
```

**Error:** `pybind11 not found`
```bash
pip install pybind11
```

### Runtime Errors

**Error:** `ImportError: No module named 'audio2face_py'`
```bash
# Ensure .so file is in backend/
ls backend/audio2face_py*.so

# Check Python can see it
cd backend && python3 -c "import audio2face_py"
```

**Error:** `Failed to load Audio2Face model`
```bash
# Check model path
ls -la /path/to/model/model.json

# Update config.py with correct path
```

**Error:** `CUDA error: no device found`
```bash
# Check GPU availability
nvidia-smi

# Verify CUDA installation
nvcc --version
```

## Implementation Details

### SDK API Used

The wrapper uses the **Diffusion Blendshape Solve Executor**, which:
- Generates ARKit-compatible blendshape weights
- Runs at fixed 60 FPS
- Supports multiple character identities (Claire, James, Mark)
- Uses TensorRT for GPU-accelerated inference

**Key SDK Functions:**
```cpp
// Create executor bundle
ReadDiffusionBlendshapeSolveExecutorBundle(
    numTracks, modelPath, executionOption,
    useGpuSolver, characterIndex, constantNoise,
    jobRunner, cudaStream
)

// Process audio
executor.SetResultsCallback(callback, userdata)
accumulator.Accumulate(audio, cudaStream)
executor.Execute(emotionAccumulator)
executor.Wait(trackIndex)
```

### Callback Mechanism

Blendshapes are returned asynchronously via callbacks:

```cpp
auto callback = [](void* userdata,
                  const IBlendshapeExecutor::HostResults& results,
                  std::error_code error) {
    // Collect blendshape weights
    const float* weights = results.weights.Data();
    size_t count = results.weights.Size();

    // Store for later conversion to numpy
    auto& output = *static_cast<vector<vector<float>>*>(userdata);
    output.push_back(vector<float>(weights, weights + count));
};
```

## References

### Official Documentation
- [Audio2Face-3D SDK GitHub](https://github.com/NVIDIA/Audio2Face-3D-SDK)
- [Audio2Face-3D Paper](https://arxiv.org/abs/2508.16401)
- [NVIDIA Audio2Face](https://www.nvidia.com/en-us/ai/metaverse/)

### SDK Samples Used as Reference
- `audio2face-sdk/source/samples/python-wrapper/audio2face_cli.cpp` - CLI wrapper
- `audio2face-sdk/source/samples/sample-a2f-executor/main.cpp` - Executor sample
- `audio2face-sdk/source/samples/sample-a2f-low-level-api-fullface/main.cpp` - Low-level API

### Related Files
- `backend/a2f_wrapper.py` - Python wrapper implementation
- `backend/main.py` - FastAPI integration
- `Audio2Face-3D-SDK/audio2face-sdk/include/audio2face/` - SDK headers

## License

The Audio2Face-3D SDK is licensed under the MIT License.
This integration code follows the same license as per NVIDIA's sample code.

## Support

For SDK issues:
- GitHub Issues: https://github.com/NVIDIA/Audio2Face-3D-SDK/issues
- NVIDIA Developer Forums: https://forums.developer.nvidia.com/

For integration issues in this project:
- Check the troubleshooting section above
- Review the build logs
- Verify all dependencies are correctly installed
