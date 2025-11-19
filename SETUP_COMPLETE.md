# Infrastructure Setup Complete

All components verified and working. See [README.md](README.md) for quick start.

## Verification Results

```bash
cd backend && python test_sdk.py
```

✅ SDK Library (8.9MB) - `Audio2Face-3D-SDK/_build/audio2x-sdk/lib/libaudio2x.so`
✅ Models (1.5GB, 25 files) - Downloaded from Hugging Face
✅ TensorRT 10.7.0.23 - `/usr/local/TensorRT`
✅ CUDA 12.6 - System installation
✅ Sample Executables - Built and ready
✅ Test Audio - Sample files available

## SDK Architecture (Important for Implementation)

The SDK uses **C++ classes**, not C functions. Key interfaces:

### Core Interfaces (in `_build/audio2x-sdk/include/audio2face/`)

**executor.h**:
- `IFaceExecutor` - Base interface with emotions callback
- `IGeometryExecutor` - Returns vertex positions
- `IBlendshapeExecutor` - Returns blendshape weights (72 per frame)

**bundle.h**:
- `IExecutorBundle` - Model + executor management
- `ReadRegressionGeometryExecutorBundle()` - Load geometry executor
- `ReadRegressionBlendshapeExecutorBundle()` - Load blendshape executor

**audio-accumulator.h**:
- `IAudioAccumulator` - Buffers audio input
- `PushAudio()` - Add audio data
- `GetAccumulator()` - Retrieve for executor

### Sample Usage Pattern (from sample-a2f-executor/main.cpp)

```cpp
// 1. Create executor bundle
auto bundle = ToUniquePtr(
    nva2f::ReadRegressionGeometryExecutorBundle(
        8,  // batch size
        model_json_path,
        nva2f::IGeometryExecutor::ExecutionOption::SkinTongue,
        60, 1,  // frame rate, num frames
        nullptr
    )
);

// 2. Create audio accumulator
auto accumulator = ToUniquePtr(
    nva2f::CreateAudioAccumulator(
        bundle->GetExecutor(),
        nullptr
    )
);

// 3. Push audio data
accumulator->PushAudio(audio_buffer, num_samples);

// 4. Execute
bundle->GetExecutor()->Execute(
    batch_size,
    accumulator->GetAccumulator(),
    callback  // receives results
);
```

## Implementation Options

### Option 1: PyBind11 (Recommended for Production)

Create C++ Python bindings:

```cpp
// audio2face_py.cpp
#include <pybind11/pybind11.h>
#include "audio2face/audio2face.h"

namespace py = pybind11;

PYBIND11_MODULE(audio2face_py, m) {
    py::class_<nva2f::IBlendshapeExecutor>(m, "BlendshapeExecutor")
        .def("Execute", &nva2f::IBlendshapeExecutor::Execute);

    // Wrap bundle creation
    m.def("create_blendshape_bundle", [](
        int batch_size,
        const char* model_path,
        int fps
    ) {
        return nva2f::ReadRegressionBlendshapeExecutorBundle(
            batch_size, model_path, fps, 1, nullptr
        );
    });
}
```

**Build**:
```bash
# CMakeLists.txt
find_package(pybind11 REQUIRED)
pybind11_add_module(audio2face_py audio2face_py.cpp)
target_link_libraries(audio2face_py PRIVATE audio2x)
```

### Option 2: Subprocess Wrapper (Quick MVP)

Call sample executables from Python:

```python
# backend/a2f_subprocess.py
import subprocess
import json
from pathlib import Path

def process_audio_to_blendshapes(audio_path: str, model_path: str):
    """Process audio using SDK sample executable"""

    executable = Path("../Audio2Face-3D-SDK/_build/audio2face-sdk/bin/sample-a2f-executor")

    env = {
        "LD_LIBRARY_PATH": "/usr/local/TensorRT/lib:/teamspace/studios/this_studio/audio2face-mvp/Audio2Face-3D-SDK/_build/audio2x-sdk/lib"
    }

    result = subprocess.run([
        str(executable),
        model_path,
        audio_path,
        "/tmp/output.json"
    ], env=env, capture_output=True, text=True, check=True)

    with open("/tmp/output.json") as f:
        return json.load(f)
```

**Pros**: Fast to implement, no compilation
**Cons**: Less control, subprocess overhead

### Option 3: C Wrapper

Create C interface wrapping C++ SDK, then use ctypes. More complex, not recommended.

## Model Files

Located in `Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0/`:

```json
// model.json - Main configuration
{
    "networkInfoPath": "network_info.json",
    "networkPath": "network.trt",  // Will be created from network.onnx
    "modelConfigPaths": [
        "model_config_Claire.json",
        "model_config_James.json",
        "model_config_Mark.json"
    ],
    "blendshapePaths": [
        "bs_skin_Claire.npz", "bs_tongue_Claire.npz",
        "bs_skin_James.npz", "bs_tongue_James.npz",
        "bs_skin_Mark.npz", "bs_tongue_Mark.npz"
    ]
}
```

**File Breakdown**:
- `network.onnx` (692MB) - Neural network, converted to TensorRT on first run
- `bs_skin_*.npz` (15MB each) - 52 ARKit blendshapes per character
- `bs_tongue_*.npz` (1.1MB each) - 20 tongue blendshapes
- `model_config_*.json` - Per-character configuration

## Sample Executables

Test the SDK directly:

```bash
cd Audio2Face-3D-SDK

# Set library path
export LD_LIBRARY_PATH=/usr/local/TensorRT/lib:$PWD/_build/audio2x-sdk/lib:$LD_LIBRARY_PATH

# Run sample executor
./_build/audio2face-sdk/bin/sample-a2f-executor \
  models/Audio2Face-3D-v3.0/model.json \
  sample-data/audio_1sec_16k_s16le.wav \
  /tmp/output.json

# Check output
cat /tmp/output.json | jq .
```

**Available executables**:
- `sample-a2f-executor` - Basic blendshape generation
- `sample-a2f-a2e-executor` - Audio2Emotion + Face
- `sample-a2f-low-level-api-fullface` - Low-level API example

## Next Implementation Steps

1. **Choose approach** - PyBind11 for production, subprocess for quick test
2. **Implement audio preprocessing** - Convert to 16kHz mono PCM-16
3. **Wrap SDK calls** - Create Python interface
4. **Handle output** - Parse blendshapes (72 × N frames)
5. **Integrate with FastAPI** - Update `/process-audio` endpoint
6. **Test pipeline** - End-to-end audio → blendshapes → JSON

## Key Paths

```python
# backend/config.py
SDK_LIB = "../Audio2Face-3D-SDK/_build/audio2x-sdk/lib/libaudio2x.so"
SDK_INCLUDE = "../Audio2Face-3D-SDK/_build/audio2x-sdk/include"
MODEL_JSON = "../Audio2Face-3D-SDK/models/Audio2Face-3D-v3.0/model.json"
TENSORRT_LIB = "/usr/local/TensorRT/lib"
```

## Build Status

- ✅ SDK compiled successfully
- ✅ All dependencies installed
- ✅ Models downloaded (not in git, from Hugging Face)
- ✅ Sample executables working
- ⏳ Python bindings pending implementation

## Resources

- SDK headers: `Audio2Face-3D-SDK/_build/audio2x-sdk/include/audio2face/`
- Sample code: `Audio2Face-3D-SDK/audio2face-sdk/source/samples/`
- API documentation: `Audio2Face-3D-SDK/docs/` (if available)
