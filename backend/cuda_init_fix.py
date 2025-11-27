"""
CUDA Initialization Fix for TensorRT
Based on solutions from NVIDIA forums and GitHub issues
"""
import ctypes
import sys

def initialize_cuda_driver():
    """
    Manually initialize CUDA driver before TensorRT
    This can help with error 35 (cudaErrorInsufficientDriver)

    References:
    - https://forums.developer.nvidia.com/t/trt-w-cuda-initialization-failure-with-error-35-segmentation-fault-core-dumped/260822
    - https://stackoverflow.com/questions/58369731/adding-multiple-inference-on-tensorrt-invalid-resource-handle-error
    """
    try:
        # Load CUDA driver library
        cuda_lib = ctypes.CDLL('libcuda.so.1')

        # cuInit(0) - Initialize CUDA driver API
        result = cuda_lib.cuInit(0)
        if result != 0:
            print(f"⚠ cuInit failed with error code: {result}")
            return False

        print("✓ CUDA driver initialized successfully via cuInit()")

        # Get device count
        device_count = ctypes.c_int()
        result = cuda_lib.cuDeviceGetCount(ctypes.byref(device_count))
        if result == 0:
            print(f"✓ Found {device_count.value} CUDA device(s)")

        # Create a primary context for device 0
        device = ctypes.c_int()
        result = cuda_lib.cuDeviceGet(ctypes.byref(device), 0)
        if result == 0:
            print(f"✓ Got CUDA device 0: {device.value}")

            # Retain primary context
            context = ctypes.c_void_p()
            result = cuda_lib.cuDevicePrimaryCtxRetain(ctypes.byref(context), device)
            if result == 0:
                print(f"✓ Primary context retained: {context.value}")

                # Set as current context
                result = cuda_lib.cuCtxSetCurrent(context)
                if result == 0:
                    print("✓ Context set as current")
                    return True

        return False

    except Exception as e:
        print(f"✗ Failed to initialize CUDA driver: {e}")
        return False

def initialize_cuda_runtime():
    """
    Initialize CUDA runtime API
    Alternative approach using cudaSetDevice
    """
    try:
        # Load CUDA runtime library
        cudart = ctypes.CDLL('libcudart.so.12')

        # cudaSetDevice(0) - Initialize runtime and set device
        result = cudart.cudaSetDevice(0)
        if result != 0:
            print(f"⚠ cudaSetDevice failed with error code: {result}")
            return False

        print("✓ CUDA runtime initialized via cudaSetDevice()")

        # cudaFree(0) - Force runtime initialization
        result = cudart.cudaFree(None)
        print(f"✓ CUDA runtime fully initialized (cudaFree result: {result})")

        return True

    except Exception as e:
        print(f"✗ Failed to initialize CUDA runtime: {e}")
        return False

def preload_cuda_libraries():
    """
    Preload CUDA libraries in correct order
    """
    libraries = [
        'libcuda.so.1',
        'libcudart.so.12',
        'libnvinfer.so.10',
        'libnvinfer_plugin.so.10',
    ]

    loaded = []
    for lib in libraries:
        try:
            handle = ctypes.CDLL(lib, mode=ctypes.RTLD_GLOBAL)
            loaded.append(lib)
            print(f"✓ Preloaded: {lib}")
        except Exception as e:
            print(f"⚠ Could not preload {lib}: {e}")

    return loaded

if __name__ == "__main__":
    print("=" * 60)
    print("CUDA Initialization Fix Test")
    print("=" * 60)
    print()

    print("1. Preloading CUDA libraries...")
    preload_cuda_libraries()
    print()

    print("2. Initializing CUDA Driver API...")
    driver_ok = initialize_cuda_driver()
    print()

    print("3. Initializing CUDA Runtime API...")
    runtime_ok = initialize_cuda_runtime()
    print()

    if driver_ok or runtime_ok:
        print("✓ CUDA initialized successfully!")
        sys.exit(0)
    else:
        print("✗ CUDA initialization failed")
        sys.exit(1)
