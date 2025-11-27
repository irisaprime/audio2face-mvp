#!/bin/bash
# Test TensorRT with various NVIDIA environment variables
# Based on NVIDIA Docker and TensorRT forums

echo "Testing TensorRT with different environment configurations..."
echo

# Configuration 1: Disable lazy loading
echo "=== Test 1: CUDA_MODULE_LOADING=EAGER ==="
export CUDA_MODULE_LOADING=EAGER
python -c "
import tensorrt as trt
logger = trt.Logger(trt.Logger.WARNING)
try:
    runtime = trt.Runtime(logger)
    print('✓ Success with CUDA_MODULE_LOADING=EAGER')
except Exception as e:
    print(f'✗ Failed: {e}')
" 2>&1 | grep -v "TRT\|CUDA" | head -5
echo

# Configuration 2: Force compatibility mode
echo "=== Test 2: NVIDIA_DRIVER_CAPABILITIES=all ==="
export NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics
export NVIDIA_VISIBLE_DEVICES=all
python -c "
import tensorrt as trt
logger = trt.Logger(trt.Logger.WARNING)
try:
    runtime = trt.Runtime(logger)
    print('✓ Success with NVIDIA driver capabilities set')
except Exception as e:
    print(f'✗ Failed: {e}')
" 2>&1 | grep -v "TRT\|CUDA" | head -5
echo

# Configuration 3: Disable TensorRT DLA
echo "=== Test 3: TRT_NO_CACHE=1 ==="
export TRT_NO_CACHE=1
python -c "
import tensorrt as trt
logger = trt.Logger(trt.Logger.WARNING)
try:
    runtime = trt.Runtime(logger)
    print('✓ Success with TRT_NO_CACHE')
except Exception as e:
    print(f'✗ Failed: {e}')
" 2>&1 | grep -v "TRT\|CUDA" | head -5
echo

# Configuration 4: Use compatibility mode for older GPU
echo "=== Test 4: CUDA_FORCE_PTX_JIT=1 ==="
export CUDA_FORCE_PTX_JIT=1
python -c "
import tensorrt as trt
logger = trt.Logger(trt.Logger.WARNING)
try:
    runtime = trt.Runtime(logger)
    print('✓ Success with CUDA_FORCE_PTX_JIT')
except Exception as e:
    print(f'✗ Failed: {e}')
" 2>&1 | grep -v "TRT\|CUDA" | head -5
echo

#Configuration 5: Disable GPU persistence
echo "=== Test 5: CUDA_CACHE_DISABLE=1 ==="
export CUDA_CACHE_DISABLE=1
python -c "
import tensorrt as trt
logger = trt.Logger(trt.Logger.WARNING)
try:
    runtime = trt.Runtime(logger)
    print('✓ Success with CUDA_CACHE_DISABLE')
except Exception as e:
    print(f'✗ Failed: {e}')
" 2>&1 | grep -v "TRT\|CUDA" | head -5
echo

# Configuration 6: All combined
echo "=== Test 6: All environment variables combined ==="
export CUDA_MODULE_LOADING=EAGER
export NVIDIA_DRIVER_CAPABILITIES=compute,utility
export CUDA_FORCE_PTX_JIT=1
export TRT_NO_CACHE=1
python -c "
import tensorrt as trt
logger = trt.Logger(trt.Logger.WARNING)
try:
    runtime = trt.Runtime(logger)
    print('✓✓✓ SUCCESS! Found working configuration!')
except Exception as e:
    print(f'✗ Failed even with all variables: {e}')
" 2>&1 | grep -v "TRT\|CUDA" | head -5
echo

echo "Test complete."
