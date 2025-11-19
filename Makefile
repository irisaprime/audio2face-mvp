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

# Colors for output
COLOR_RESET := \033[0m
COLOR_BOLD := \033[1m
COLOR_GREEN := \033[32m
COLOR_YELLOW := \033[33m
COLOR_BLUE := \033[34m

.PHONY: help install setup-sdk check test clean run-backend run-frontend run generate-test-audio \
        stop status setup-all dev-backend logs-backend logs-frontend clean-all install-system-deps \
        quick-test open list verify-dirs download-model get-avatar build-sdk test-backend test-frontend

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

##@ Setup Commands

check: ## Check system requirements and dependencies
	@echo "$(COLOR_BOLD)Checking system requirements...$(COLOR_RESET)"
	@$(PYTHON) $(SCRIPTS_DIR)/check_requirements.py

install: verify-dirs ## Install all Python dependencies
	@echo "$(COLOR_BOLD)Installing Python dependencies...$(COLOR_RESET)"
	@echo "Creating virtual environment in: $(VENV_DIR)"
	@if [ ! -d "$(VENV_DIR)" ]; then \
		$(PYTHON) -m venv $(VENV_DIR); \
		echo "  $(COLOR_GREEN)✓ Virtual environment created$(COLOR_RESET)"; \
	else \
		echo "  $(COLOR_YELLOW)Virtual environment already exists$(COLOR_RESET)"; \
	fi
	@echo "Installing dependencies..."
	@cd $(BACKEND_DIR) && \
		. $(VENV_DIR)/bin/activate && \
		pip install --upgrade pip -q && \
		pip install -r requirements.txt -q && \
		touch $(VENV_DIR)/.installed
	@echo "$(COLOR_GREEN)✓ Dependencies installed successfully!$(COLOR_RESET)"

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
	@if [ ! -d "$(SDK_DIR)" ]; then \
		echo "SDK directory not found. Run 'make setup-sdk' first"; \
		exit 1; \
	fi
	@cd $(SDK_DIR) && \
		$(PYTHON) tools/download_models.py \
			--model nvidia/Audio2Face-3D-v3.0 \
			--output models/
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
	@if [ ! -d "$(VENV_DIR)" ]; then \
		echo "$(COLOR_YELLOW)Virtual environment not found. Run 'make install' first.$(COLOR_RESET)"; \
		exit 1; \
	fi
	@cd $(BACKEND_DIR) && \
		. $(VENV_DIR)/bin/activate && \
		$(PYTHON) main.py

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
		tmux new-session -d -s audio2face-backend \
			"cd $(BACKEND_DIR) && . $(VENV_DIR)/bin/activate && $(PYTHON) main.py"; \
		tmux new-session -d -s audio2face-frontend \
			"cd $(FRONTEND_DIR) && $(PYTHON) -m http.server $(FRONTEND_PORT)"; \
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
