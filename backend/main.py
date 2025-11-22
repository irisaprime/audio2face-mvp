from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pathlib import Path
import uuid
import traceback
import sys

from config import config
from audio_utils import AudioProcessor
from a2f_wrapper import Audio2FaceSDK
from health_validator import run_all_checks

# Run health checks on startup
print("\n" + "="*60)
print("Audio2Face Backend - Startup Validation")
print("="*60 + "\n")

validator = run_all_checks(verbose=True)

if not validator.is_healthy():
    print("\n❌ Critical issues detected. Backend may not function properly.")
    print("Fix the issues above and restart the backend.\n")
    # Don't exit - allow backend to start for debugging
else:
    summary = validator.get_summary()
    if summary['warnings'] > 0:
        print(f"\n⚠️  Backend starting with {summary['warnings']} warning(s).")
        print("Some features may be unavailable.\n")
    else:
        print("\n✅ All checks passed. Starting backend...\n")

# Initialize FastAPI
app = FastAPI(title="Audio2Face API", version="1.0.0")

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Audio2Face SDK
try:
    a2f_sdk = Audio2FaceSDK()
    audio_processor = AudioProcessor()
    print("✓ Audio2Face SDK initialized successfully")
except Exception as e:
    print(f"✗ Failed to initialize Audio2Face SDK: {e}")
    print("NOTE: This is expected if GPU is not available or SDK is not built yet")
    traceback.print_exc()
    a2f_sdk = None

@app.get("/")
async def root():
    return {
        "message": "Audio2Face MVP API",
        "status": "ready" if a2f_sdk else "error",
        "model": "Audio2Face-3D-v3.0",
        "note": "SDK requires GPU and built libraries to function"
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy" if a2f_sdk else "unhealthy",
        "sdk_loaded": a2f_sdk is not None
    }

@app.get("/blendshape-names")
async def get_blendshape_names():
    """Get list of blendshape names"""
    if not a2f_sdk:
        raise HTTPException(status_code=500, detail="SDK not initialized")

    return {"blendshape_names": a2f_sdk.get_blendshape_names()}

@app.post("/process-audio")
async def process_audio(file: UploadFile = File(...)):
    """
    Process audio file and return blendshape animation data

    Expected input: WAV file (any format, will be converted)
    Returns: JSON with blendshapes, timestamps, and metadata
    """
    if not a2f_sdk:
        raise HTTPException(status_code=500, detail="SDK not initialized")

    # Validate file type
    if not file.filename.endswith(('.wav', '.mp3', '.ogg', '.flac')):
        raise HTTPException(status_code=400, detail="Only audio files supported")

    try:
        # Save uploaded file
        temp_id = str(uuid.uuid4())
        input_path = config.TEMP_DIR / f"{temp_id}_input{Path(file.filename).suffix}"
        processed_path = config.TEMP_DIR / f"{temp_id}_processed.wav"

        with open(input_path, "wb") as f:
            content = await file.read()
            f.write(content)

        print(f"Processing: {file.filename} ({len(content)} bytes)")

        # Load and preprocess audio
        audio, sr = audio_processor.load_and_preprocess(str(input_path))
        audio_processor.save_processed(audio, str(processed_path))
        duration = audio_processor.get_duration(audio, sr)

        print(f"Audio preprocessed: {duration:.2f}s @ {sr}Hz")

        # Run Audio2Face inference
        result = a2f_sdk.process_audio(audio)

        print(f"Generated {len(result['blendshapes'])} frames @ {result['fps']}fps")

        # Cleanup temp files
        input_path.unlink(missing_ok=True)
        processed_path.unlink(missing_ok=True)

        # Return results
        return JSONResponse({
            "success": True,
            "data": {
                "blendshapes": result['blendshapes'].tolist(),
                "timestamps": result['timestamps'].tolist(),
                "fps": result['fps'],
                "duration": result['duration'],
                "num_frames": len(result['blendshapes']),
                "blendshape_count": config.BLENDSHAPE_COUNT
            },
            "metadata": {
                "original_filename": file.filename,
                "audio_duration": duration,
                "sample_rate": sr
            }
        })

    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Processing failed: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=config.HOST, port=config.PORT)
