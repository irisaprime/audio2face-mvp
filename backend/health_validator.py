"""
Backend Health Validator
Checks all requirements before starting the Audio2Face backend
"""

import sys
import os
from pathlib import Path
from typing import List, Dict, Tuple

class HealthValidator:
    def __init__(self):
        self.checks_passed = []
        self.checks_failed = []
        self.checks_warnings = []

    def check(self, name: str, check_fn, critical: bool = True) -> bool:
        """Run a single health check"""
        try:
            passed, message = check_fn()
            if passed:
                self.checks_passed.append((name, message))
                print(f"✓ {name}: {message}")
                return True
            else:
                if critical:
                    self.checks_failed.append((name, message))
                    print(f"✗ {name}: {message}")
                else:
                    self.checks_warnings.append((name, message))
                    print(f"⚠ {name}: {message}")
                return False
        except Exception as e:
            error_msg = f"Error during check: {str(e)}"
            if critical:
                self.checks_failed.append((name, error_msg))
                print(f"✗ {name}: {error_msg}")
            else:
                self.checks_warnings.append((name, error_msg))
                print(f"⚠ {name}: {error_msg}")
            return False

    def is_healthy(self) -> bool:
        """Check if all critical checks passed"""
        return len(self.checks_failed) == 0

    def get_summary(self) -> Dict:
        """Get summary of all checks"""
        return {
            'passed': len(self.checks_passed),
            'failed': len(self.checks_failed),
            'warnings': len(self.checks_warnings),
            'healthy': self.is_healthy()
        }

    def print_summary(self):
        """Print summary of all health checks"""
        print("\n" + "="*60)
        print("Health Check Summary")
        print("="*60)
        summary = self.get_summary()
        print(f"Passed:   {summary['passed']}")
        print(f"Failed:   {summary['failed']}")
        print(f"Warnings: {summary['warnings']}")
        print("="*60)

        if summary['healthy']:
            if summary['warnings'] > 0:
                print("✓ System ready with warnings")
            else:
                print("✓ All systems operational")
        else:
            print("✗ System not ready - fix critical issues")
        print("="*60 + "\n")

def check_python_version() -> Tuple[bool, str]:
    """Check Python version"""
    version = sys.version_info
    if version.major == 3 and version.minor >= 8:
        return True, f"Python {version.major}.{version.minor}.{version.micro}"
    return False, f"Python 3.8+ required, found {version.major}.{version.minor}"

def check_fastapi() -> Tuple[bool, str]:
    """Check if FastAPI is installed"""
    try:
        import fastapi
        return True, f"FastAPI {fastapi.__version__}"
    except ImportError:
        return False, "FastAPI not installed (pip install fastapi)"

def check_uvicorn() -> Tuple[bool, str]:
    """Check if Uvicorn is installed"""
    try:
        import uvicorn
        return True, f"Uvicorn {uvicorn.__version__}"
    except ImportError:
        return False, "Uvicorn not installed (pip install uvicorn)"

def check_numpy() -> Tuple[bool, str]:
    """Check if NumPy is installed"""
    try:
        import numpy
        return True, f"NumPy {numpy.__version__}"
    except ImportError:
        return False, "NumPy not installed (pip install numpy)"

def check_scipy() -> Tuple[bool, str]:
    """Check if SciPy is installed"""
    try:
        import scipy
        return True, f"SciPy {scipy.__version__}"
    except ImportError:
        return False, "SciPy not installed (pip install scipy)"

def check_librosa() -> Tuple[bool, str]:
    """Check if librosa is installed"""
    try:
        import librosa
        return True, f"librosa {librosa.__version__}"
    except ImportError:
        return False, "librosa not installed (pip install librosa)"

def check_soundfile() -> Tuple[bool, str]:
    """Check if soundfile is installed"""
    try:
        import soundfile
        return True, f"soundfile {soundfile.__version__}"
    except ImportError:
        return False, "soundfile not installed (pip install soundfile)"

def check_audio2face_module() -> Tuple[bool, str]:
    """Check if audio2face_py module can be imported"""
    try:
        import audio2face_py
        return True, "Audio2Face PyBind11 module available"
    except ImportError as e:
        return False, f"audio2face_py not available: {str(e)}"

def check_tensorrt_libs() -> Tuple[bool, str]:
    """Check if TensorRT libraries are accessible"""
    # Check LD_LIBRARY_PATH
    ld_path = os.environ.get('LD_LIBRARY_PATH', '')

    if 'TensorRT' in ld_path:
        # Check if library actually exists
        for path in ld_path.split(':'):
            if 'TensorRT' in path:
                lib_file = Path(path) / 'libnvinfer.so'
                if lib_file.exists():
                    return True, f"TensorRT libs found in {path}"

        return False, "TensorRT in LD_LIBRARY_PATH but libnvinfer.so not found"

    # Check system locations
    system_locations = [
        '/usr/local/TensorRT/lib',
        '/usr/lib/x86_64-linux-gnu'
    ]

    for location in system_locations:
        lib_file = Path(location) / 'libnvinfer.so'
        if lib_file.exists():
            return True, f"TensorRT found at {location} (LD_LIBRARY_PATH not set)"

    return False, "TensorRT libraries not found. Set LD_LIBRARY_PATH or install TensorRT"

def check_config_file() -> Tuple[bool, str]:
    """Check if config.py exists"""
    config_path = Path(__file__).parent / 'config.py'
    if config_path.exists():
        return True, "config.py found"
    return False, "config.py missing"

def check_temp_directory() -> Tuple[bool, str]:
    """Check if temp directory can be created"""
    try:
        from config import config
        temp_dir = Path(config.TEMP_DIR)
        temp_dir.mkdir(parents=True, exist_ok=True)
        if temp_dir.exists():
            return True, f"Temp directory: {temp_dir}"
        return False, f"Cannot create temp directory: {temp_dir}"
    except Exception as e:
        return False, f"Temp directory check failed: {str(e)}"

def check_model_path() -> Tuple[bool, str]:
    """Check if model path is configured"""
    try:
        from config import config
        model_path = Path(config.A2F_MODEL_PATH)
        if model_path.exists():
            return True, f"Model found: {model_path}"
        return False, f"Model not found: {model_path}"
    except Exception as e:
        return False, f"Model check failed: {str(e)}"

def run_all_checks(verbose: bool = True) -> HealthValidator:
    """Run all health checks"""
    validator = HealthValidator()

    if verbose:
        print("\n🏥 Running Backend Health Checks...")
        print("="*60 + "\n")

    # Critical checks
    validator.check("Python Version", check_python_version, critical=True)
    validator.check("FastAPI", check_fastapi, critical=True)
    validator.check("Uvicorn", check_uvicorn, critical=True)
    validator.check("NumPy", check_numpy, critical=True)
    validator.check("SciPy", check_scipy, critical=True)
    validator.check("librosa", check_librosa, critical=True)
    validator.check("soundfile", check_soundfile, critical=True)
    validator.check("Config File", check_config_file, critical=True)
    validator.check("Temp Directory", check_temp_directory, critical=True)

    # Non-critical checks (warnings)
    validator.check("Audio2Face Module", check_audio2face_module, critical=False)
    validator.check("TensorRT Libraries", check_tensorrt_libs, critical=False)
    validator.check("Model Path", check_model_path, critical=False)

    if verbose:
        validator.print_summary()

    return validator

if __name__ == "__main__":
    # Run health checks
    validator = run_all_checks(verbose=True)

    # Exit with appropriate code
    sys.exit(0 if validator.is_healthy() else 1)
