# Makefile Quick Reference Guide

This project includes a comprehensive Makefile for easy project management.

## 🚀 Quick Start

```bash
# 1. Check requirements
make check

# 2. Install dependencies
make install

# 3. Generate test audio
make generate-test

# 4. Run the application
make run
```

## 📋 All Available Commands

### Setup Commands

| Command | Description |
|---------|-------------|
| `make help` | Show all available commands |
| `make check` | Check system requirements and dependencies |
| `make install` | Install Python dependencies in virtual environment |
| `make setup-sdk` | Setup Audio2Face SDK (requires GPU) |
| `make setup-all` | Run all setup steps (check + install + generate-test) |
| `make install-system-deps` | Install system dependencies (Ubuntu/Debian, requires sudo) |

### Run Commands

| Command | Description |
|---------|-------------|
| `make run-backend` | Start FastAPI backend server on port 8000 |
| `make run-frontend` | Start frontend HTTP server on port 3000 |
| `make run` | Start both backend and frontend (uses tmux if available) |
| `make stop` | Stop all running services |
| `make dev-backend` | Start backend in dev mode with auto-reload (requires entr) |

### Testing Commands

| Command | Description |
|---------|-------------|
| `make generate-test` | Generate test audio files (WAV) |
| `make test` | Run basic API tests |
| `make quick-test` | Quick test with sample audio file |

### Utility Commands

| Command | Description |
|---------|-------------|
| `make status` | Show project status (dependencies, SDK, services) |
| `make clean` | Clean temporary files and Python cache |
| `make clean-all` | Clean everything including virtual environment |
| `make logs-backend` | Attach to backend logs (if running in tmux) |
| `make logs-frontend` | Attach to frontend logs (if running in tmux) |
| `make open` | Open frontend in browser |
| `make list` | List all available make targets |

## 💡 Common Usage Patterns

### First Time Setup

```bash
# Complete setup from scratch
make check              # Verify requirements
make install            # Install dependencies
make generate-test      # Create test audio
make status             # Check everything is ready
```

Or use the all-in-one command:
```bash
make setup-all
```

### Daily Development

```bash
# Start the application
make run

# Check if services are running
make status

# Open frontend in browser
make open

# Stop everything when done
make stop
```

### Running Services Manually (Without tmux)

If you don't have tmux installed or prefer separate terminals:

**Terminal 1 - Backend**:
```bash
make run-backend
```

**Terminal 2 - Frontend**:
```bash
make run-frontend
```

### Testing Your Setup

```bash
# Generate test audio if not already done
make generate-test

# Start backend in one terminal
make run-backend

# In another terminal, run tests
make test

# Or run a quick test with sample audio
make quick-test
```

### Cleaning Up

```bash
# Clean temporary files only
make clean

# Clean everything (removes virtual environment too)
make clean-all

# Then reinstall if needed
make install
```

### When GPU is Available

```bash
# First time GPU setup
make check              # Should show CUDA tools now
make setup-sdk          # Build Audio2Face SDK
make status             # Verify SDK is built

# Then download model manually:
cd Audio2Face-3D-SDK
huggingface-cli login
python tools/download_models.py \
  --model nvidia/Audio2Face-3D-v3.0 \
  --output models/
```

## 🔧 Advanced Usage

### Development Mode (Auto-reload)

```bash
# Install entr for auto-reload
sudo apt-get install entr

# Run backend in dev mode
make dev-backend

# Now backend will auto-restart when you edit Python files
```

### Parallel Execution with tmux

The `make run` command automatically uses tmux if available:

```bash
# Install tmux
sudo apt-get install tmux

# Run both services
make run

# Check running tmux sessions
tmux list-sessions

# Attach to backend logs
make logs-backend

# Attach to frontend logs
make logs-frontend

# Stop all services
make stop
```

### Checking Project Status

```bash
make status
```

Output example:
```
Python Environment:
  ✓ Virtual environment exists

SDK Status:
  ✗ SDK not built (run: make setup-sdk)

Model Status:
  ✗ Model not downloaded

Avatar Status:
  ✗ Avatar missing (download from readyplayer.me)

Test Audio:
  ✓ Test audio files exist
    sample_sine.wav (96K)
    sample_speech_like.wav (160K)

Running Services:
  ✓ Backend running (PID: 12345)
  ✓ Frontend running (PID: 12346)
```

## 📝 Tips & Tricks

### 1. Quick Project Overview
```bash
make help
```

### 2. One-Command Setup
```bash
make setup-all
```

### 3. Check Before You Run
```bash
make status
```

### 4. Test API Without Frontend
```bash
# Start backend
make run-backend

# In another terminal
curl http://localhost:8000/health
curl http://localhost:8000/blendshape-names
```

### 5. Reset Everything
```bash
make clean-all
make setup-all
```

### 6. Install System Dependencies
```bash
# On Ubuntu/Debian
make install-system-deps
```

## 🐛 Troubleshooting

### "Virtual environment not found"
```bash
make install
```

### "Backend not running" during tests
```bash
make run-backend
# Then in another terminal:
make test
```

### Port already in use
```bash
# Kill existing processes
make stop

# Or manually
pkill -f "python main.py"
pkill -f "python3 -m http.server 3000"
```

### tmux not working
```bash
# Install tmux
sudo apt-get install tmux

# Or run manually in separate terminals
make run-backend    # Terminal 1
make run-frontend   # Terminal 2
```

### Clean start
```bash
make stop
make clean-all
make setup-all
make run
```

## 📚 Integration with Project Workflow

### Morning Routine
```bash
cd /teamspace/studios/this_studio/audio2face-mvp
make status         # Check project state
make run            # Start everything
make open           # Open browser
```

### Development Session
```bash
make dev-backend    # Auto-reload backend
# Edit code, backend restarts automatically
```

### End of Day
```bash
make stop           # Stop all services
make clean          # Clean up temp files
```

### Testing Changes
```bash
make stop
make clean
make run
make test
```

## 🎯 Recommended Workflow

1. **Initial Setup** (one time):
   ```bash
   make check
   make install
   make generate-test
   ```

2. **When GPU Available** (one time):
   ```bash
   make setup-sdk
   # Download model from Hugging Face
   # Download avatar from Ready Player Me
   ```

3. **Daily Usage**:
   ```bash
   make run          # Start
   make status       # Verify
   make open         # Use
   make stop         # Stop
   ```

4. **Development**:
   ```bash
   make dev-backend  # Backend with auto-reload
   make run-frontend # Frontend in another terminal
   # Code, test, repeat
   ```

## 📖 Help

For detailed help on any command:
```bash
make help
```

For complete project documentation:
- `README.md` - Complete guide
- `QUICKSTART.md` - Quick start checklist
- `GPU_SETUP_GUIDE.md` - GPU setup instructions

---

**Tip**: Add `make help` to your shell profile to always have it handy!
