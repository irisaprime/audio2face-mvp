# Audio2Face MVP - Comprehensive Makefile
# Location: Project Root Directory
# Handles: backend/, frontend/, test_audio/, scripts/, Audio2Face-3D-SDK/

# Project directories
PROJECT_ROOT := $(shell pwd)
BACKEND_DIR := $(PROJECT_ROOT)/backend
FRONTEND_DIR := $(PROJECT_ROOT)/frontend
SCRIPTS_DIR := $(PROJECT_ROOT)/scripts
TEST_AUDIO_DIR := $(PROJECT_ROOT)/test_audio
SDK_DIR := $(PROJECT_ROOT)/Audio2Face-3D-SDK

# Configuration
PYTHON := python3
VENV_DIR := $(BACKEND_DIR)/venv
BACKEND_PORT := 8000
FRONTEND_PORT := 3000
# Use system TensorRT installation (Lightning.ai has it pre-installed)
TENSORRT_DIR := /usr/lib/x86_64-linux-gnu
TENSORRT_LIB := $(TENSORRT_DIR)
ENV_SETUP := $(PROJECT_ROOT)/env_setup.sh

# Colors for output
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m

.PHONY: help install setup-sdk check test clean run-backend run-backend-cpu run-frontend run generate-test-audio \
        stop status setup-all dev-backend logs-backend logs-frontend clean-all install-system-deps \
        quick-test open list verify-dirs download-model get-avatar build-sdk test-backend test-frontend \
        setup-pybind11 build-pybind11 install-pybind11 test-pybind11 pybind11-all setup-tensorrt \
        verify-tensorrt restart-recovery verify-setup health-backend health-frontend health-all \
        automated-setup persist-setup

# Default target
.DEFAULT_GOAL := help

##@ General Commands

help: ## Show this help message
	@echo "$(COLOR_BOLD)=================================================="
	@echo "Audio2Face MVP - Makefile Commands"
	@echo "Root Directory: $(PROJECT_ROOT)"
	@echo "==================================================$(COLOR_RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make $(COLOR_BLUE)<target>$(COLOR_RESET)\n"} \
		/^[a-zA-Z_-]+:.*?##/ { printf "  $(COLOR_GREEN)%-20s$(COLOR_RESET) %s\n", $$1, $$2 } \
		/^##@/ { printf "\n$(COLOR_BOLD)%s$(COLOR_RESET)\n", substr($$0, 5) }' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(COLOR_YELLOW)Quick Start:$(COLOR_RESET)"
	@echo "  1. make verify-dirs  # Verify project structure"
	@echo "  2. make check        # Check requirements"
	@echo "  3. make install      # Install dependencies"
	@echo "  4. make setup-all    # Complete setup"
	@echo "  5. make run          # Start application"
	@echo ""

list: ## List all available make targets
	@echo "Available targets:"
	@grep '^[^#[:space:]].*:' Makefile | grep -v '^.PHONY' | sed 's/:.*//' | sort | sed 's/^/  make /'

##@ Project Structure

verify-dirs: ## Verify all project directories exist
	@echo "$(COLOR_BOLD)Verifying project structure...$(COLOR_RESET)"
	@echo "Project Root: $(PROJECT_ROOT)"
	@test -d "$(BACKEND_DIR)" && echo "  ✓ backend/" || (echo "  ✗ backend/ missing!" && exit 1)
	@test -d "$(FRONTEND_DIR)" && echo "  ✓ frontend/" || (echo "  ✗ frontend/ missing!" && exit 1)
	@test -d "$(SCRIPTS_DIR)" && echo "  ✓ scripts/" || (echo "  ✗ scripts/ missing!" && exit 1)
	@test -d "$(TEST_AUDIO_DIR)" && echo "  ✓ test_audio/" || (echo "  ✗ test_audio/ missing!" && exit 1)
	@echo "$(COLOR_GREEN)✓ All directories verified$(COLOR_RESET)"

##@ Health Checks & Validation

verify-setup: ## Run comprehensive system verification
	@echo "$(COLOR_BOLD)Running comprehensive system verification...$(COLOR_RESET)"
	@chmod +x $(SCRIPTS_DIR)/verify_setup.sh
	@if [ -f "$(ENV_SETUP)" ]; then \
		bash -c "source $(ENV_SETUP) && $(SCRIPTS_DIR)/verify_setup.sh"; \
	else \
		$(SCRIPTS_DIR)/verify_setup.sh; \
	fi

health-backend: ## Check backend health and dependencies
	@echo "$(COLOR_BOLD)Checking backend health...$(COLOR_RESET)"
	@if [ -f "$(ENV_SETUP)" ]; then \
		cd $(BACKEND_DIR) && bash -c "source $(ENV_SETUP) && $(PYTHON) health_validator.py"; \
	else \
		cd $(BACKEND_DIR) && \
		export LD_LIBRARY_PATH=$(TENSORRT_LIB):$(SDK_DIR)/_build/audio2x-sdk/lib:$$LD_LIBRARY_PATH && \
		$(PYTHON) health_validator.py; \
	fi

health-frontend: ## Check frontend health (requires backend running)
	@echo "$(COLOR_BOLD)Checking frontend health...$(COLOR_RESET)"
	@echo "Opening browser console to view health checks..."
	@echo "Visit: http://localhost:3000 and open DevTools (F12)"
	@echo "Health check results will be logged to console."

health-all: health-backend health-frontend ## Run all health checks
	@echo ""
	@echo "$(COLOR_GREEN)✓ All health checks complete$(COLOR_RESET)"
	@echo "For comprehensive verification, run: make verify-setup"

##@ Setup Commands

automated-setup: ## Run complete automated setup (builds everything)
	@echo "$(COLOR_BOLD)Running automated setup...$(COLOR_RESET)"
	@chmod +x $(SCRIPTS_DIR)/automated_setup.sh
	@$(SCRIPTS_DIR)/automated_setup.sh

persist-setup: ## Configure persistence for Lightning.ai restarts
	@echo "$(COLOR_BOLD)Configuring persistence...$(COLOR_RESET)"
	@chmod +x on_start.sh
	@echo "  ✓ on_start.sh configured"
	@echo ""
	@# Add environment setup to .bashrc if not already there
	@if ! grep -q "audio2face-mvp/env_setup.sh" ~/.bashrc 2>/dev/null; then \
		echo "" >> ~/.bashrc; \
		echo "# Audio2Face MVP - Auto-load environment" >> ~/.bashrc; \
		echo "if [ -f \"$(ENV_SETUP)\" ]; then" >> ~/.bashrc; \
		echo "    source $(ENV_SETUP)" >> ~/.bashrc; \
		echo "fi" >> ~/.bashrc; \
		echo "  $(COLOR_GREEN)✓ Added env_setup.sh to ~/.bashrc$(COLOR_RESET)"; \
	else \
		echo "  $(COLOR_YELLOW)env_setup.sh already in ~/.bashrc$(COLOR_RESET)"; \
	fi
	@echo ""
	@echo "Environment will be automatically loaded in new shells."
	@echo "For current shell, run: source env_setup.sh"
	@echo ""
	@echo "To enable auto-start on Lightning.ai:"
	@echo "  1. Go to Studio Settings"
	@echo "  2. Add 'Startup Command': bash /teamspace/studios/this_studio/audio2face-mvp/on_start.sh"
	@echo "  3. Save settings"
	@echo ""
	@echo "Or manually run: ./on_start.sh"

check: ## Check system requirements and dependencies
	@echo "$(COLOR_BOLD)Checking system requirements...$(COLOR_RESET)"
	@$(PYTHON) $(SCRIPTS_DIR)/check_requirements.py

install: verify-dirs ## Install all Python dependencies
	@echo "$(COLOR_BOLD)Installing Python dependencies...$(COLOR_RESET)"
	@# Check if we're on Lightning.ai (which doesn't allow venv)
	@if [ -n "$$LIGHTNING_CLOUD_PROJECT_ID" ] || [ -d "/teamspace" ]; then \
		echo "  $(COLOR_YELLOW)Lightning.ai detected - using system Python$(COLOR_RESET)"; \
		echo "Installing dependencies to system Python..."; \
		cd $(BACKEND_DIR) && \
			pip install --upgrade pip -q && \
			pip install -r requirements.txt -q; \
		echo "  $(COLOR_GREEN)✓ Dependencies installed successfully!$(COLOR_RESET)"; \
	else \
		echo "Creating virtual environment in: $(VENV_DIR)"; \
		if [ ! -d "$(VENV_DIR)" ]; then \
			$(PYTHON) -m venv $(VENV_DIR); \
			echo "  $(COLOR_GREEN)✓ Virtual environment created$(COLOR_RESET)"; \
		else \
			echo "  $(COLOR_YELLOW)Virtual environment already exists$(COLOR_RESET)"; \
		fi; \
		echo "Installing dependencies..."; \
		cd $(BACKEND_DIR) && \
			. $(VENV_DIR)/bin/activate && \
			pip install --upgrade pip -q && \
			pip install -r requirements.txt -q && \
			touch $(VENV_DIR)/.installed; \
		echo "$(COLOR_GREEN)✓ Dependencies installed successfully!$(COLOR_RESET)"; \
	fi

install-system-deps: ## Install system dependencies (Ubuntu/Debian, requires sudo)
	@echo "$(COLOR_BOLD)Installing system dependencies...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)This requires sudo access$(COLOR_RESET)"
	@sudo apt-get update
	@sudo apt-get install -y \
		python3 python3-pip python3-venv \
		git cmake build-essential \
		tmux curl entr \
		libsndfile1 ffmpeg
	@echo "$(COLOR_GREEN)✓ System dependencies installed$(COLOR_RESET)"

setup-sdk: verify-dirs ## Setup Audio2Face SDK (requires GPU)
	@echo "$(COLOR_BOLD)Setting up Audio2Face SDK...$(COLOR_RESET)"
	@if [ ! -f "$(SCRIPTS_DIR)/setup_sdk.sh" ]; then \
		echo "$(COLOR_YELLOW)Error: setup_sdk.sh not found$(COLOR_RESET)"; \
		exit 1; \
	fi
	@chmod +x $(SCRIPTS_DIR)/setup_sdk.sh
	@cd $(PROJECT_ROOT) && $(SCRIPTS_DIR)/setup_sdk.sh

build-sdk: ## Build Audio2Face SDK from source (GPU required)
	@echo "$(COLOR_BOLD)Building Audio2Face SDK...$(COLOR_RESET)"
	@if [ ! -d "$(SDK_DIR)" ]; then \
		echo "Cloning Audio2Face-3D SDK..."; \
		git clone https://github.com/NVIDIA/Audio2Face-3D-SDK.git $(SDK_DIR); \
	fi
	@cd $(SDK_DIR) && \
		cmake -B _build -S . -DCMAKE_BUILD_TYPE=Release && \
		cmake --build _build --config Release -- -j$$(nproc)
	@echo "$(COLOR_GREEN)✓ SDK built successfully$(COLOR_RESET)"

download-model: ## Download Audio2Face model from Hugging Face
	@echo "$(COLOR_BOLD)Downloading Audio2Face model...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Make sure you've logged in: huggingface-cli login$(COLOR_RESET)"
	@if ! command -v huggingface-cli >/dev/null 2>&1; then \
		echo "$(COLOR_YELLOW)Installing huggingface-cli...$(COLOR_RESET)"; \
		pip install -U "huggingface_hub[cli]"; \
	fi
	@huggingface-cli download nvidia/Audio2Face-3D-v3.0 \
		--local-dir $(SDK_DIR)/models/Audio2Face-3D-v3.0
	@echo "$(COLOR_GREEN)✓ Model downloaded$(COLOR_RESET)"

get-avatar: ## Instructions to get Ready Player Me avatar
	@echo "$(COLOR_BOLD)Getting Ready Player Me Avatar$(COLOR_RESET)"
	@echo ""
	@echo "1. Visit: $(COLOR_BLUE)https://readyplayer.me/$(COLOR_RESET)"
	@echo "2. Create and customize your avatar"
	@echo "3. Download as GLB format"
	@echo "4. Save to: $(FRONTEND_DIR)/assets/avatar.glb"
	@echo ""
	@if [ -f "$(FRONTEND_DIR)/assets/avatar.glb" ]; then \
		echo "$(COLOR_GREEN)✓ Avatar already present$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)✗ Avatar not found$(COLOR_RESET)"; \
	fi

setup-all: check install generate-test ## Complete setup (all steps except GPU)
	@echo ""
	@echo "$(COLOR_BOLD)=================================================="
	@echo "✓ Basic setup complete!"
	@echo "==================================================$(COLOR_RESET)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. $(COLOR_YELLOW)When GPU available:$(COLOR_RESET) make setup-sdk"
	@echo "  2. $(COLOR_YELLOW)Download model:$(COLOR_RESET) make download-model"
	@echo "  3. $(COLOR_YELLOW)Get avatar:$(COLOR_RESET) make get-avatar"
	@echo "  4. $(COLOR_GREEN)Run application:$(COLOR_RESET) make run"
	@echo ""

##@ Run Commands

run-backend: ## Start FastAPI backend server
	@echo "$(COLOR_BOLD)Starting FastAPI backend...$(COLOR_RESET)"
	@echo "Directory: $(BACKEND_DIR)"
	@echo "API: http://localhost:$(BACKEND_PORT)"
	@echo "Docs: http://localhost:$(BACKEND_PORT)/docs"
	@echo "$(COLOR_YELLOW)Press Ctrl+C to stop$(COLOR_RESET)"
	@echo ""
	@# Check if dependencies are installed
	@if ! $(PYTHON) -c "import fastapi" 2>/dev/null; then \
		echo "$(COLOR_YELLOW)Dependencies not found. Run 'make install' first.$(COLOR_RESET)"; \
		exit 1; \
	fi
	@# Run with environment setup
	@if [ -f "$(ENV_SETUP)" ]; then \
		if [ -d "$(VENV_DIR)" ] && [ -f "$(VENV_DIR)/bin/activate" ]; then \
			cd $(BACKEND_DIR) && \
			bash -c "source $(ENV_SETUP) && . $(VENV_DIR)/bin/activate && $(PYTHON) main.py"; \
		else \
			cd $(BACKEND_DIR) && \
			bash -c "source $(ENV_SETUP) && $(PYTHON) main.py"; \
		fi \
	else \
		if [ -d "$(VENV_DIR)" ] && [ -f "$(VENV_DIR)/bin/activate" ]; then \
			cd $(BACKEND_DIR) && \
			. $(VENV_DIR)/bin/activate && \
			export LD_LIBRARY_PATH=$(TENSORRT_LIB):$(SDK_DIR)/_build/audio2x-sdk/lib:$$LD_LIBRARY_PATH && \
			$(PYTHON) main.py; \
		else \
			cd $(BACKEND_DIR) && \
			export LD_LIBRARY_PATH=$(TENSORRT_LIB):$(SDK_DIR)/_build/audio2x-sdk/lib:$$LD_LIBRARY_PATH && \
			$(PYTHON) main.py; \
		fi \
	fi

run-backend-cpu: ## Start backend in CPU-only mode (GPU disabled, SDK unavailable)
	@echo "$(COLOR_BOLD)Starting backend in CPU-only mode...$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Note: GPU disabled to avoid CUDA/TensorRT crashes$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)SDK will report as 'unhealthy' but API will work$(COLOR_RESET)"
	@echo ""
	@chmod +x $(SCRIPTS_DIR)/run_backend_cpu_mode.sh
	@$(SCRIPTS_DIR)/run_backend_cpu_mode.sh

run-frontend: ## Start frontend HTTP server
	@echo "$(COLOR_BOLD)Starting frontend server...$(COLOR_RESET)"
	@echo "Directory: $(FRONTEND_DIR)"
	@echo "URL: http://localhost:$(FRONTEND_PORT)"
	@echo "$(COLOR_YELLOW)Press Ctrl+C to stop$(COLOR_RESET)"
	@echo ""
	@cd $(FRONTEND_DIR) && $(PYTHON) -m http.server $(FRONTEND_PORT)

run: ## Start both backend and frontend (uses tmux if available)
	@echo "$(COLOR_BOLD)Starting Audio2Face MVP...$(COLOR_RESET)"
	@echo "Project Root: $(PROJECT_ROOT)"
	@echo ""
	@if command -v tmux >/dev/null 2>&1; then \
		echo "$(COLOR_GREEN)Using tmux for parallel execution...$(COLOR_RESET)"; \
		if [ -f "$(ENV_SETUP)" ]; then \
			if [ -d "$(VENV_DIR)" ] && [ -f "$(VENV_DIR)/bin/activate" ]; then \
				tmux new-session -d -s audio2face-backend \
					bash -c "source $(ENV_SETUP) && cd $(BACKEND_DIR) && . $(VENV_DIR)/bin/activate && $(PYTHON) main.py"; \
			else \
				tmux new-session -d -s audio2face-backend \
					bash -c "source $(ENV_SETUP) && cd $(BACKEND_DIR) && $(PYTHON) main.py"; \
			fi \
		else \
			if [ -d "$(VENV_DIR)" ] && [ -f "$(VENV_DIR)/bin/activate" ]; then \
				tmux new-session -d -s audio2face-backend \
					bash -c "export LD_LIBRARY_PATH=$(TENSORRT_LIB):$(SDK_DIR)/_build/audio2x-sdk/lib:$$LD_LIBRARY_PATH && cd $(BACKEND_DIR) && . $(VENV_DIR)/bin/activate && $(PYTHON) main.py"; \
			else \
				tmux new-session -d -s audio2face-backend \
					bash -c "export LD_LIBRARY_PATH=$(TENSORRT_LIB):$(SDK_DIR)/_build/audio2x-sdk/lib:$$LD_LIBRARY_PATH && cd $(BACKEND_DIR) && $(PYTHON) main.py"; \
			fi \
		fi; \
		tmux new-session -d -s audio2face-frontend \
			bash -c "cd $(FRONTEND_DIR) && $(PYTHON) -m http.server $(FRONTEND_PORT)"; \
		echo ""; \
		echo "$(COLOR_GREEN)✓ Backend started$(COLOR_RESET) in tmux session 'audio2face-backend'"; \
		echo "$(COLOR_GREEN)✓ Frontend started$(COLOR_RESET) in tmux session 'audio2face-frontend'"; \
		echo ""; \
		echo "$(COLOR_BOLD)Access URLs:$(COLOR_RESET)"; \
		echo "  Frontend:  http://localhost:$(FRONTEND_PORT)"; \
		echo "  Backend:   http://localhost:$(BACKEND_PORT)"; \
		echo "  API Docs:  http://localhost:$(BACKEND_PORT)/docs"; \
		echo ""; \
		echo "$(COLOR_BOLD)Manage Sessions:$(COLOR_RESET)"; \
		echo "  View logs:     make logs-backend  |  make logs-frontend"; \
		echo "  Stop services: make stop"; \
		echo "  List sessions: tmux list-sessions"; \
	else \
		echo "$(COLOR_YELLOW)tmux not found. Please run in separate terminals:$(COLOR_RESET)"; \
		echo "  Terminal 1: make run-backend"; \
		echo "  Terminal 2: make run-frontend"; \
		echo ""; \
		echo "Or install tmux: sudo apt-get install tmux"; \
	fi

dev-backend: ## Start backend in development mode (auto-reload on changes)
	@echo "$(COLOR_BOLD)Starting backend in dev mode...$(COLOR_RESET)"
	@if command -v entr >/dev/null 2>&1; then \
		echo "$(COLOR_GREEN)Auto-reload enabled (using entr)$(COLOR_RESET)"; \
		echo "Watching: $(BACKEND_DIR)/*.py"; \
		echo ""; \
		cd $(BACKEND_DIR) && \
		. $(VENV_DIR)/bin/activate && \
		find . -name "*.py" | entr -r $(PYTHON) main.py; \
	else \
		echo "$(COLOR_YELLOW)entr not installed. Install with:$(COLOR_RESET) sudo apt-get install entr"; \
		echo "Falling back to normal mode..."; \
		$(MAKE) run-backend; \
	fi

stop: ## Stop all running services
	@echo "$(COLOR_BOLD)Stopping Audio2Face MVP services...$(COLOR_RESET)"
	@if command -v tmux >/dev/null 2>&1; then \
		tmux kill-session -t audio2face-backend 2>/dev/null && echo "  ✓ Backend stopped" || echo "  Backend not running"; \
		tmux kill-session -t audio2face-frontend 2>/dev/null && echo "  ✓ Frontend stopped" || echo "  Frontend not running"; \
	fi
	@pkill -f "python.*main.py" 2>/dev/null && echo "  ✓ Killed backend process" || true
	@pkill -f "python.*http.server $(FRONTEND_PORT)" 2>/dev/null && echo "  ✓ Killed frontend process" || true
	@echo "$(COLOR_GREEN)✓ All services stopped$(COLOR_RESET)"

logs-backend: ## Attach to backend logs (tmux session)
	@if command -v tmux >/dev/null 2>&1; then \
		tmux attach -t audio2face-backend || echo "$(COLOR_YELLOW)Backend session not found$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)tmux not installed$(COLOR_RESET)"; \
	fi

logs-frontend: ## Attach to frontend logs (tmux session)
	@if command -v tmux >/dev/null 2>&1; then \
		tmux attach -t audio2face-frontend || echo "$(COLOR_YELLOW)Frontend session not found$(COLOR_RESET)"; \
	else \
		echo "$(COLOR_YELLOW)tmux not installed$(COLOR_RESET)"; \
	fi

##@ Testing Commands

generate-test: verify-dirs ## Generate test audio files
	@echo "$(COLOR_BOLD)Generating test audio files...$(COLOR_RESET)"
	@echo "Directory: $(TEST_AUDIO_DIR)"
	@cd $(TEST_AUDIO_DIR) && $(PYTHON) generate_test_audio.py
	@echo "$(COLOR_GREEN)✓ Test audio files generated$(COLOR_RESET)"
	@ls -lh $(TEST_AUDIO_DIR)/*.wav 2>/dev/null | awk '{print "  " $$9 " (" $$5 ")"}'

test-backend: ## Test backend API endpoints
	@echo "$(COLOR_BOLD)Testing backend API...$(COLOR_RESET)"
	@echo ""
	@echo "1. Health check:"
	@curl -s http://localhost:$(BACKEND_PORT)/health | $(PYTHON) -m json.tool || echo "  $(COLOR_YELLOW)Backend not running$(COLOR_RESET)"
	@echo ""
	@echo "2. Blendshape names:"
	@curl -s http://localhost:$(BACKEND_PORT)/blendshape-names | head -c 200 || echo "  $(COLOR_YELLOW)Backend not running$(COLOR_RESET)"
	@echo ""

test-frontend: ## Test frontend availability
	@echo "$(COLOR_BOLD)Testing frontend...$(COLOR_RESET)"
	@curl -s -o /dev/null -w "Status: %{http_code}\n" http://localhost:$(FRONTEND_PORT)/ || echo "$(COLOR_YELLOW)Frontend not running$(COLOR_RESET)"

test: test-backend test-frontend ## Run all tests

quick-test: ## Quick test with sample audio
	@echo "$(COLOR_BOLD)Running quick test...$(COLOR_RESET)"
	@if [ ! -f "$(TEST_AUDIO_DIR)/sample_sine.wav" ]; then \
		echo "Generating test audio..."; \
		$(MAKE) generate-test; \
	fi
	@echo ""
	@echo "Processing sample audio..."
	@curl -X POST http://localhost:$(BACKEND_PORT)/process-audio \
		-F "file=@$(TEST_AUDIO_DIR)/sample_sine.wav" \
		-s | head -n 30
	@echo ""
	@echo "$(COLOR_GREEN)✓ Test complete$(COLOR_RESET)"

##@ Utility Commands

status: ## Show comprehensive project status
	@echo "$(COLOR_BOLD)=================================================="
	@echo "Audio2Face MVP - Project Status"
	@echo "Project Root: $(PROJECT_ROOT)"
	@echo "==================================================$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)Directories:$(COLOR_RESET)"
	@test -d "$(BACKEND_DIR)" && echo "  ✓ backend/" || echo "  ✗ backend/"
	@test -d "$(FRONTEND_DIR)" && echo "  ✓ frontend/" || echo "  ✗ frontend/"
	@test -d "$(SCRIPTS_DIR)" && echo "  ✓ scripts/" || echo "  ✗ scripts/"
	@test -d "$(TEST_AUDIO_DIR)" && echo "  ✓ test_audio/" || echo "  ✗ test_audio/"
	@echo ""
	@echo "$(COLOR_BOLD)Python Environment:$(COLOR_RESET)"
	@if [ -d "$(VENV_DIR)" ]; then \
		echo "  ✓ Virtual environment exists ($(VENV_DIR))"; \
		if [ -f "$(VENV_DIR)/.installed" ]; then \
			echo "  ✓ Dependencies installed"; \
		else \
			echo "  $(COLOR_YELLOW)⚠ Dependencies may need installation (run: make install)$(COLOR_RESET)"; \
		fi \
	elif [ -n "$$LIGHTNING_CLOUD_PROJECT_ID" ] || [ -d "/teamspace" ]; then \
		echo "  ✓ Using system Python (Lightning.ai)"; \
		if $(PYTHON) -c "import fastapi" 2>/dev/null; then \
			echo "  ✓ Dependencies installed"; \
		else \
			echo "  $(COLOR_YELLOW)⚠ Dependencies may need installation (run: make install)$(COLOR_RESET)"; \
		fi \
	else \
		echo "  $(COLOR_YELLOW)✗ Virtual environment missing (run: make install)$(COLOR_RESET)"; \
	fi
	@echo ""
	@echo "$(COLOR_BOLD)SDK Status:$(COLOR_RESET)"
	@if [ -d "$(SDK_DIR)/_build" ]; then \
		echo "  ✓ SDK built"; \
	else \
		echo "  $(COLOR_YELLOW)✗ SDK not built (run: make setup-sdk)$(COLOR_RESET)"; \
	fi
	@echo ""
	@echo "$(COLOR_BOLD)Model Status:$(COLOR_RESET)"
	@if [ -d "$(SDK_DIR)/models/Audio2Face-3D-v3.0" ]; then \
		echo "  ✓ Model downloaded"; \
	else \
		echo "  $(COLOR_YELLOW)✗ Model not downloaded (run: make download-model)$(COLOR_RESET)"; \
	fi
	@echo ""
	@echo "$(COLOR_BOLD)Avatar Status:$(COLOR_RESET)"
	@if [ -f "$(FRONTEND_DIR)/assets/avatar.glb" ]; then \
		echo "  ✓ Avatar present"; \
		ls -lh $(FRONTEND_DIR)/assets/avatar.glb | awk '{print "    Size: " $$5}'; \
	else \
		echo "  $(COLOR_YELLOW)✗ Avatar missing (run: make get-avatar for instructions)$(COLOR_RESET)"; \
	fi
	@echo ""
	@echo "$(COLOR_BOLD)Test Audio:$(COLOR_RESET)"
	@if ls $(TEST_AUDIO_DIR)/*.wav >/dev/null 2>&1; then \
		echo "  ✓ Test audio files exist"; \
		ls -lh $(TEST_AUDIO_DIR)/*.wav | awk '{print "    " $$9 " (" $$5 ")"}'; \
	else \
		echo "  $(COLOR_YELLOW)✗ No test audio (run: make generate-test)$(COLOR_RESET)"; \
	fi
	@echo ""
	@echo "$(COLOR_BOLD)Running Services:$(COLOR_RESET)"
	@if pgrep -f "python.*main.py" >/dev/null 2>&1; then \
		echo "  $(COLOR_GREEN)✓ Backend running$(COLOR_RESET) (PID: $$(pgrep -f 'python.*main.py'))"; \
		echo "    URL: http://localhost:$(BACKEND_PORT)"; \
	else \
		echo "  ✗ Backend not running"; \
	fi
	@if pgrep -f "python.*http.server $(FRONTEND_PORT)" >/dev/null 2>&1; then \
		echo "  $(COLOR_GREEN)✓ Frontend running$(COLOR_RESET) (PID: $$(pgrep -f 'python.*http.server $(FRONTEND_PORT)'))"; \
		echo "    URL: http://localhost:$(FRONTEND_PORT)"; \
	else \
		echo "  ✗ Frontend not running"; \
	fi
	@echo ""

clean: ## Clean temporary files and caches
	@echo "$(COLOR_BOLD)Cleaning temporary files...$(COLOR_RESET)"
	@rm -rf $(BACKEND_DIR)/temp/* 2>/dev/null || true
	@rm -rf $(BACKEND_DIR)/__pycache__ 2>/dev/null || true
	@rm -f $(TEST_AUDIO_DIR)/*.wav 2>/dev/null || true
	@find $(PROJECT_ROOT) -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find $(PROJECT_ROOT) -type f -name "*.pyc" -delete 2>/dev/null || true
	@find $(PROJECT_ROOT) -type f -name "*.pyo" -delete 2>/dev/null || true
	@find $(PROJECT_ROOT) -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(COLOR_GREEN)✓ Temporary files cleaned$(COLOR_RESET)"

clean-all: clean stop ## Clean everything including virtual environment
	@echo "$(COLOR_BOLD)Performing full cleanup...$(COLOR_RESET)"
	@rm -rf $(VENV_DIR)
	@rm -rf $(SDK_DIR)/_build 2>/dev/null || true
	@echo "$(COLOR_GREEN)✓ Full cleanup complete$(COLOR_RESET)"
	@echo "$(COLOR_YELLOW)Note: SDK and models not deleted. Remove manually if needed.$(COLOR_RESET)"

open: ## Open frontend in browser
	@echo "$(COLOR_BOLD)Opening browser...$(COLOR_RESET)"
	@if command -v xdg-open >/dev/null 2>&1; then \
		xdg-open http://localhost:$(FRONTEND_PORT); \
	elif command -v open >/dev/null 2>&1; then \
		open http://localhost:$(FRONTEND_PORT); \
	else \
		echo "$(COLOR_YELLOW)Please open http://localhost:$(FRONTEND_PORT) in your browser$(COLOR_RESET)"; \
	fi

##@ Information

info: ## Show project information
	@echo "$(COLOR_BOLD)=================================================="
	@echo "Audio2Face MVP - Project Information"
	@echo "==================================================$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)Project Structure:$(COLOR_RESET)"
	@echo "  Root:         $(PROJECT_ROOT)"
	@echo "  Backend:      $(BACKEND_DIR)"
	@echo "  Frontend:     $(FRONTEND_DIR)"
	@echo "  Scripts:      $(SCRIPTS_DIR)"
	@echo "  Test Audio:   $(TEST_AUDIO_DIR)"
	@echo "  SDK:          $(SDK_DIR)"
	@echo ""
	@echo "$(COLOR_BOLD)Configuration:$(COLOR_RESET)"
	@echo "  Python:       $(PYTHON)"
	@echo "  Venv:         $(VENV_DIR)"
	@echo "  Backend Port: $(BACKEND_PORT)"
	@echo "  Frontend Port:$(FRONTEND_PORT)"
	@echo ""
	@echo "$(COLOR_BOLD)URLs:$(COLOR_RESET)"
	@echo "  Frontend:     http://localhost:$(FRONTEND_PORT)"
	@echo "  Backend:      http://localhost:$(BACKEND_PORT)"
	@echo "  API Docs:     http://localhost:$(BACKEND_PORT)/docs"
	@echo "  Health:       http://localhost:$(BACKEND_PORT)/health"
	@echo ""
	@echo "$(COLOR_BOLD)Quick Commands:$(COLOR_RESET)"
	@echo "  make help     - Show all commands"
	@echo "  make status   - Check project status"
	@echo "  make run      - Start application"
	@echo ""

version: ## Show version information
	@echo "Audio2Face MVP v1.0.0"
	@echo "Python: $$($(PYTHON) --version)"
	@echo "Make: $$(make --version | head -n 1)"
	@if command -v git >/dev/null 2>&1; then \
		echo "Git: $$(git --version)"; \
	fi
	@if command -v tmux >/dev/null 2>&1; then \
		echo "Tmux: $$(tmux -V)"; \
	fi

##@ TensorRT & Restart Recovery

setup-tensorrt: ## Download and cache TensorRT in persistent storage
	@echo "$(COLOR_BOLD)Setting up TensorRT...$(COLOR_RESET)"
	@if [ ! -f "$(SCRIPTS_DIR)/setup_tensorrt.sh" ]; then \
		echo "$(COLOR_YELLOW)Error: setup_tensorrt.sh not found$(COLOR_RESET)"; \
		exit 1; \
	fi
	@chmod +x $(SCRIPTS_DIR)/setup_tensorrt.sh
	@$(SCRIPTS_DIR)/setup_tensorrt.sh

verify-tensorrt: ## Check if TensorRT is available and configured
	@echo "$(COLOR_BOLD)Verifying TensorRT...$(COLOR_RESET)"
	@if [ -d "$(TENSORRT_DIR)" ] && [ -f "$(TENSORRT_LIB)/libnvinfer.so" ]; then \
		echo "  $(COLOR_GREEN)✓ TensorRT found$(COLOR_RESET) at $(TENSORRT_DIR)"; \
		echo "  Library: $$(ls -lh $(TENSORRT_LIB)/libnvinfer.so* | head -1 | awk '{print $$9 " (" $$5 ")"}')"; \
	else \
		echo "  $(COLOR_YELLOW)✗ TensorRT not found$(COLOR_RESET)"; \
		echo "  Run: make setup-tensorrt"; \
		exit 1; \
	fi

restart-recovery: ## Run post-restart setup (auto-called by on_start.sh)
	@echo "$(COLOR_BOLD)=================================================="
	@echo "Audio2Face MVP - Restart Recovery"
	@echo "==================================================$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)1. Verifying TensorRT...$(COLOR_RESET)"
	@if [ -f "$(TENSORRT_LIB)/libnvinfer.so" ]; then \
		echo "  $(COLOR_GREEN)✓ TensorRT found at $(TENSORRT_DIR)$(COLOR_RESET)"; \
	else \
		echo "  $(COLOR_YELLOW)⚠ TensorRT not found$(COLOR_RESET)"; \
	fi
	@echo ""
	@echo "$(COLOR_BOLD)2. Installing Python packages...$(COLOR_RESET)"
	@pip install -q pybind11 numpy scipy 2>/dev/null && echo "  $(COLOR_GREEN)✓ Python packages ready$(COLOR_RESET)" || echo "  $(COLOR_YELLOW)⚠ Some packages may need manual installation$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)3. Ensuring environment setup...$(COLOR_RESET)"
	@if [ ! -f "$(ENV_SETUP)" ]; then \
		echo "Creating env_setup.sh..."; \
		echo "#!/bin/bash" > $(ENV_SETUP); \
		echo "export PROJECT_ROOT=\"$(PROJECT_ROOT)\"" >> $(ENV_SETUP); \
		echo "export TENSORRT_DIR=\"$(TENSORRT_DIR)\"" >> $(ENV_SETUP); \
		echo "export LD_LIBRARY_PATH=\"$(TENSORRT_LIB):$(SDK_DIR)/_build/audio2x-sdk/lib:\$$LD_LIBRARY_PATH\"" >> $(ENV_SETUP); \
		echo "export PYBIND11_CMAKE=\$$(python -c \"import pybind11; print(pybind11.get_cmake_dir())\" 2>/dev/null)" >> $(ENV_SETUP); \
		echo "export CMAKE_PREFIX_PATH=\"\$$PYBIND11_CMAKE:\$$CMAKE_PREFIX_PATH\"" >> $(ENV_SETUP); \
		chmod +x $(ENV_SETUP); \
	fi
	@echo "  $(COLOR_GREEN)✓ Environment setup ready: source env_setup.sh$(COLOR_RESET)"
	@echo ""
	@echo "$(COLOR_BOLD)4. Verifying project structure...$(COLOR_RESET)"
	@$(MAKE) verify-dirs
	@echo ""
	@echo "$(COLOR_GREEN)=================================================="
	@echo "✓ Restart recovery complete!"
	@echo "==================================================$(COLOR_RESET)"
	@echo ""
	@echo "Next steps:"
	@echo "  make status           # Check overall status"
	@echo "  make pybind11-all     # Build PyBind11 wrapper (if TensorRT ready)"
	@echo "  make run              # Start servers"
	@echo ""

##@ PyBind11 Wrapper

setup-pybind11: ## Install PyBind11 dependencies
	@echo "$(COLOR_BOLD)Installing PyBind11 dependencies...$(COLOR_RESET)"
	@pip install pybind11 numpy scipy
	@echo "  $(COLOR_GREEN)✓ PyBind11 ready$(COLOR_RESET)"

build-pybind11: verify-tensorrt ## Build PyBind11 Python module from SDK
	@echo "$(COLOR_BOLD)Building PyBind11 wrapper...$(COLOR_RESET)"
	@if [ ! -d "$(SDK_DIR)" ]; then \
		echo "  $(COLOR_YELLOW)SDK directory not found$(COLOR_RESET)"; \
		exit 1; \
	fi
	@echo "  Checking python-wrapper directory..."
	@if [ ! -f "$(SDK_DIR)/audio2face-sdk/source/samples/python-wrapper/audio2face_py.cpp" ]; then \
		echo "  $(COLOR_YELLOW)PyBind11 source files not found$(COLOR_RESET)"; \
		echo "  Expected: $(SDK_DIR)/audio2face-sdk/source/samples/python-wrapper/"; \
		echo "  Run: git status in SDK directory to check"; \
		exit 1; \
	fi
	@echo "  $(COLOR_GREEN)✓ Source files found$(COLOR_RESET)"
	@echo ""
	@echo "  Adding python-wrapper to CMake..."
	@if ! grep -q "add_subdirectory(python-wrapper)" $(SDK_DIR)/audio2face-sdk/source/samples/CMakeLists.txt 2>/dev/null; then \
		echo "add_subdirectory(python-wrapper)" >> $(SDK_DIR)/audio2face-sdk/source/samples/CMakeLists.txt; \
		echo "  $(COLOR_GREEN)✓ Added to CMakeLists.txt$(COLOR_RESET)"; \
	else \
		echo "  $(COLOR_YELLOW)Already in CMakeLists.txt$(COLOR_RESET)"; \
	fi
	@echo ""
	@echo "  Creating python output directory..."
	@mkdir -p $(SDK_DIR)/_build/python
	@echo "  $(COLOR_GREEN)✓ Output directory ready$(COLOR_RESET)"
	@echo ""
	@echo "  Configuring CMake with TensorRT..."
	@cd $(SDK_DIR) && \
		export LD_LIBRARY_PATH=$(TENSORRT_LIB):$$LD_LIBRARY_PATH && \
		cmake -B _build -S . -DCMAKE_BUILD_TYPE=Release \
			-DTENSORRT_ROOT_DIR=$(TENSORRT_DIR) \
			-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda
	@echo ""
	@echo "  Building audio2face_py module..."
	@cd $(SDK_DIR) && \
		export LD_LIBRARY_PATH=$(TENSORRT_LIB):$$LD_LIBRARY_PATH && \
		cmake --build _build --target audio2face_py -j$$(nproc)
	@echo ""
	@echo "  $(COLOR_GREEN)✓ PyBind11 module built successfully$(COLOR_RESET)"
	@ls -lh $(SDK_DIR)/_build/python/audio2face_py.*.so 2>/dev/null || echo "  $(COLOR_YELLOW)Warning: Module not found at expected location$(COLOR_RESET)"

install-pybind11: ## Copy PyBind11 module to backend
	@echo "$(COLOR_BOLD)Installing PyBind11 module to backend...$(COLOR_RESET)"
	@if [ -f $(SDK_DIR)/_build/python/audio2face_py.*.so ]; then \
		cp $(SDK_DIR)/_build/python/audio2face_py.*.so $(BACKEND_DIR)/ && \
		echo "  $(COLOR_GREEN)✓ Module installed to backend/$(COLOR_RESET)" && \
		ls -lh $(BACKEND_DIR)/audio2face_py.*.so; \
	else \
		echo "  $(COLOR_YELLOW)Module not found. Run: make build-pybind11$(COLOR_RESET)"; \
		exit 1; \
	fi

test-pybind11: ## Test PyBind11 module import
	@echo "$(COLOR_BOLD)Testing PyBind11 module import...$(COLOR_RESET)"
	@cd $(BACKEND_DIR) && \
		$(PYTHON) -c "import audio2face_py; print('  $(COLOR_GREEN)✓ Module imported successfully!$(COLOR_RESET)')" || \
		(echo "  $(COLOR_YELLOW)✗ Import failed. Check:$(COLOR_RESET)" && \
		 echo "    1. Module exists: ls backend/audio2face_py.*.so" && \
		 echo "    2. Run: make install-pybind11" && \
		 exit 1)

pybind11-all: setup-pybind11 build-pybind11 install-pybind11 test-pybind11 ## Complete PyBind11 setup (all steps)
	@echo ""
	@echo "$(COLOR_GREEN)=================================================="
	@echo "✓ PyBind11 wrapper complete!"
	@echo "==================================================$(COLOR_RESET)"
	@echo ""
	@echo "Next: Start the backend server"
	@echo "  make run-backend"
	@echo ""
	@echo "Or manually:"
	@echo "  source env_setup.sh"
	@echo "  cd backend && $(PYTHON) main.py"
	@echo ""

##@ Docker Commands

build-docker: ## Build Docker image
	@echo "$(COLOR_BOLD)Building Docker image...$(COLOR_RESET)"
	@docker-compose build
	@echo "$(COLOR_GREEN)✓ Docker image built$(COLOR_RESET)"

run-docker: ## Run with Docker Compose
	@echo "$(COLOR_BOLD)Starting Audio2Face with Docker...$(COLOR_RESET)"
	@docker-compose up -d
	@echo ""
	@echo "$(COLOR_GREEN)✓ Services started$(COLOR_RESET)"
	@echo "  Frontend:  http://localhost:3000"
	@echo "  Backend:   http://localhost:8000"
	@echo "  API Docs:  http://localhost:8000/docs"
	@echo ""
	@echo "View logs: docker-compose logs -f"
	@echo "Stop:      docker-compose down"

stop-docker: ## Stop Docker containers
	@echo "$(COLOR_BOLD)Stopping Docker services...$(COLOR_RESET)"
	@docker-compose down
	@echo "$(COLOR_GREEN)✓ Services stopped$(COLOR_RESET)"

logs-docker: ## View Docker logs
	@docker-compose logs -f

shell-docker: ## Shell into backend container
	@docker-compose exec backend bash

save-docker: ## Save Docker image to persistent storage (Lightning.ai)
	@echo "$(COLOR_BOLD)Saving Docker image...$(COLOR_RESET)"
	@./docker-save.sh save

load-docker: ## Load Docker image from persistent storage (Lightning.ai)
	@echo "$(COLOR_BOLD)Loading Docker image...$(COLOR_RESET)"
	@./docker-save.sh load

test-docker: ## Test Docker GPU access
	@echo "$(COLOR_BOLD)Testing Docker GPU access...$(COLOR_RESET)"
	@docker run --rm --gpus all nvidia/cuda:12.6.0-base nvidia-smi

docker-all: build-docker save-docker run-docker ## Complete Docker setup and run
	@echo "$(COLOR_GREEN)✓ Docker setup complete$(COLOR_RESET)"
