# Audio2Face MVP - Changelog

## 2025-11-22 - TensorRT Environment Fixes and Persistence

### Fixed
- **TensorRT LD_LIBRARY_PATH Warning**: Resolved the warning about TensorRT not being in LD_LIBRARY_PATH
  - Updated Makefile to use system TensorRT installation at `/usr/lib/x86_64-linux-gnu`
  - Changed from non-existent `$(PROJECT_ROOT)/libs/TensorRT` to actual system path
  - All make targets now properly load environment before execution

### Changed
- **Makefile Configuration (lines 18-21)**:
  - `TENSORRT_DIR`: Changed from `$(PROJECT_ROOT)/libs/TensorRT` to `/usr/lib/x86_64-linux-gnu`
  - `TENSORRT_LIB`: Simplified to `$(TENSORRT_DIR)` (same as TENSORRT_DIR for system install)
  - Added `ENV_SETUP` variable pointing to `env_setup.sh`

- **Make Targets Updated**:
  - `verify-setup`: Now sources `env_setup.sh` before running verification script
  - `run-backend`: Sources environment setup to ensure LD_LIBRARY_PATH is set
  - `run`: tmux sessions now include environment setup
  - `health-backend`: Sources environment before running health checks
  - `restart-recovery`: Auto-creates `env_setup.sh` if missing
  - `pybind11-all`: Updated instructions to use `make run-backend`

- **Persistence Configuration**:
  - `persist-setup` target now adds `env_setup.sh` sourcing to `~/.bashrc`
  - Environment automatically loads in new shell sessions
  - Compatible with Lightning.ai's startup hooks

### Environment Files
- **env_setup.sh**: Already correctly configured with:
  ```bash
  export TENSORRT_DIR="/usr/lib/x86_64-linux-gnu"
  export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$PROJECT_ROOT/Audio2Face-3D-SDK/_build/audio2x-sdk/lib:$LD_LIBRARY_PATH"
  ```

- **on_start.sh**: Lightning.ai startup hook
  - Creates/updates `env_setup.sh` on studio restart
  - Checks and installs Python dependencies
  - Verifies SDK and PyBind11 module status
  - Adds convenience aliases to `~/.bashrc`

### Verification Results
**Before Fix:**
- Passed: 34
- Failed: 0
- Warnings: 3 (including TensorRT LD_LIBRARY_PATH warning)

**After Fix:**
- Passed: 35 ✓
- Failed: 0
- Warnings: 2 (only backend/frontend not running)

### Usage
All environment setup is now automatic:

1. **New Shell Sessions**: Environment auto-loads from `~/.bashrc`
2. **Make Commands**: Automatically source environment when needed
3. **Manual Setup**: Run `source env_setup.sh` in current shell

### Commands
```bash
# Configure persistence (already done)
make persist-setup

# Verify system (now passes TensorRT check)
make verify-setup

# Run backend (with environment)
make run-backend

# Run full application
make run
```

### Compatibility
All changes are backward compatible with existing scripts and workflows. The Makefile gracefully handles cases where `env_setup.sh` doesn't exist by falling back to manual LD_LIBRARY_PATH exports.
