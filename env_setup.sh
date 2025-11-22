#!/bin/bash
export PROJECT_ROOT="/teamspace/studios/this_studio/audio2face-mvp"
export TENSORRT_DIR="/usr/lib/x86_64-linux-gnu"
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$PROJECT_ROOT/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:$LD_LIBRARY_PATH"
export PYBIND11_CMAKE=$(python -c "import pybind11; print(pybind11.get_cmake_dir())" 2>/dev/null)
export CMAKE_PREFIX_PATH="$PYBIND11_CMAKE:$CMAKE_PREFIX_PATH"
