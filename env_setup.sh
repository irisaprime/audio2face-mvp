#!/bin/bash
export PROJECT_ROOT="/teamspace/studios/this_studio/audio2face-mvp"
export TENSORRT_DIR="/usr/lib/x86_64-linux-gnu"
export CUDA_HOME="/usr/local/cuda-12.6"
# Use TensorRT from Python package (tensorrt_libs) - this is what the SDK was built with
export TENSORRT_LIBS="$(python -c 'import os; import tensorrt_libs; print(os.path.dirname(tensorrt_libs.__file__))' 2>/dev/null)"
export LD_LIBRARY_PATH="$TENSORRT_LIBS:$PROJECT_ROOT/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:/usr/local/cuda-12.6/targets/x86_64-linux/lib:$LD_LIBRARY_PATH"
export PYBIND11_CMAKE=$(python -c "import pybind11; print(pybind11.get_cmake_dir())" 2>/dev/null)
export CMAKE_PREFIX_PATH="$PYBIND11_CMAKE:$CMAKE_PREFIX_PATH"
