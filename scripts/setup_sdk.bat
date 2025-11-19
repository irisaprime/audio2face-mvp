@echo off
REM Setup script for Audio2Face-3D SDK (Windows)

echo ==========================================
echo Audio2Face-3D SDK Setup (Windows)
echo ==========================================

REM Check if running in project directory
if not exist "scripts\setup_sdk.bat" (
    echo Error: Please run this script from the audio2face-mvp directory
    exit /b 1
)

REM Check prerequisites
echo Checking prerequisites...

REM Check CUDA
where nvcc >nul 2>nul
if %errorlevel% neq 0 (
    echo Warning: CUDA toolkit not found. Please install CUDA 12.x
    echo Download from: https://developer.nvidia.com/cuda-downloads
)

REM Check CMake
where cmake >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: CMake not found. Please install CMake 3.20+
    echo Download from: https://cmake.org/download/
    exit /b 1
)

REM Check Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Git not found. Please install git
    echo Download from: https://git-scm.com/download/win
    exit /b 1
)

echo ✓ Prerequisites check completed

REM Clone SDK repository
echo.
echo Cloning Audio2Face-3D SDK...
if not exist "Audio2Face-3D-SDK" (
    git clone https://github.com/NVIDIA/Audio2Face-3D-SDK.git
    echo ✓ SDK repository cloned
) else (
    echo ✓ SDK repository already exists
)

cd Audio2Face-3D-SDK

REM Fetch dependencies
echo.
echo Fetching SDK dependencies...
if exist "fetch_deps.bat" (
    call fetch_deps.bat
) else (
    echo Warning: fetch_deps.bat not found
)

REM Set CUDA and TensorRT paths (modify these if needed)
set CUDA_PATH=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v12.3
set TENSORRT_ROOT_DIR=C:\TensorRT-10.0

REM Build SDK
echo.
echo Building SDK...
cmake -B _build -S . -G "Visual Studio 17 2022" -A x64 ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCUDA_TOOLKIT_ROOT_DIR="%CUDA_PATH%" ^
    -DTENSORRT_ROOT_DIR="%TENSORRT_ROOT_DIR%"

cmake --build _build --config Release --parallel

REM Verify build
echo.
echo Verifying build...
if exist "_build\release\audio2face-sdk\bin\audio2face-sdk.dll" (
    echo ✓ SDK built successfully!
) else (
    echo ✗ SDK build failed. Check error messages above.
    exit /b 1
)

REM Download models
echo.
echo ==========================================
echo Model Download
echo ==========================================
echo.
echo To download the Audio2Face-3D-v3.0 model:
echo 1. Login to Hugging Face:
echo    huggingface-cli login
echo.
echo 2. Accept the model license at:
echo    https://huggingface.co/nvidia/Audio2Face-3D-v3.0
echo.
echo 3. Download the model:
echo    python tools\download_models.py --model nvidia/Audio2Face-3D-v3.0 --output models\
echo.
echo Note: This requires GPU access and ~2GB download

cd ..

echo.
echo ==========================================
echo Setup Complete!
echo ==========================================
echo.
echo Next steps:
echo 1. Download the model (instructions above)
echo 2. Install Python dependencies: cd backend ^&^& pip install -r requirements.txt
echo 3. Start the backend: cd backend ^&^& python main.py
echo 4. Start the frontend: cd frontend ^&^& python -m http.server 3000

pause
