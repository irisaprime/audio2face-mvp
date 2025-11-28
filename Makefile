# Audio2Face MVP - Makefile v2.0.0
# Containerized Deployment with Docker

.PHONY: help build up down restart logs status test clean version

# Colors for output
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
BOLD := \033[1m
RESET := \033[0m

# Configuration
VERSION := 2.0.0
COMPOSE := docker compose

##@ General Commands

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo "$(BOLD)=================================================="
	@echo "Audio2Face MVP v$(VERSION) - Docker Edition"
	@echo "==================================================$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "$(BLUE)Usage:$(RESET) make $(GREEN)<target>$(RESET)\n\n"} \
		/^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-15s$(RESET) %s\n", $$1, $$2 } \
		/^##@/ { printf "\n$(BOLD)%s$(RESET)\n", substr($$0, 5) }' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Quick Start:$(RESET)"
	@echo "  make build    # Build Docker images"
	@echo "  make up       # Start all services"
	@echo "  make logs     # View logs"
	@echo "  make down     # Stop all services"
	@echo ""

version: ## Show version information
	@echo "Audio2Face MVP v$(VERSION)"
	@echo "Docker: $$(docker --version)"
	@echo "Docker Compose: $$(docker compose version)"

##@ Docker Commands

build: ## Build Docker images
	@echo "$(BOLD)Building Docker images...$(RESET)"
	@chmod +x docker-build.sh
	@./docker-build.sh
	@echo "$(GREEN)✓ Build complete$(RESET)"

up: ## Start all services
	@echo "$(BOLD)Starting services...$(RESET)"
	@$(COMPOSE) up -d
	@echo ""
	@echo "$(GREEN)✓ Services started$(RESET)"
	@echo ""
	@echo "$(BOLD)Access URLs:$(RESET)"
	@echo "  Frontend:  http://localhost:3000"
	@echo "  Backend:   http://localhost:8000"
	@echo "  API Docs:  http://localhost:8000/docs"
	@echo "  Health:    http://localhost:8000/health"
	@echo ""
	@echo "$(YELLOW)View logs:$(RESET) make logs"
	@echo "$(YELLOW)Stop:$(RESET)      make down"

down: ## Stop all services
	@echo "$(BOLD)Stopping services...$(RESET)"
	@$(COMPOSE) down
	@echo "$(GREEN)✓ Services stopped$(RESET)"

restart: down up ## Restart all services

##@ Monitoring & Logs

logs: ## View logs from all services
	@$(COMPOSE) logs -f

logs-backend: ## View backend logs only
	@$(COMPOSE) logs -f backend

logs-frontend: ## View frontend logs only
	@$(COMPOSE) logs -f frontend

status: ## Show service status
	@echo "$(BOLD)Service Status:$(RESET)"
	@$(COMPOSE) ps
	@echo ""
	@echo "$(BOLD)Health Status:$(RESET)"
	@curl -s http://localhost:8000/health 2>/dev/null | python3 -m json.tool || echo "$(YELLOW)Backend not responding$(RESET)"

##@ Testing & Validation

test: ## Run health checks
	@echo "$(BOLD)Running health checks...$(RESET)"
	@echo ""
	@echo "$(BOLD)1. Backend Health:$(RESET)"
	@curl -s http://localhost:8000/health | python3 -m json.tool || echo "  $(YELLOW)✗ Backend not responding$(RESET)"
	@echo ""
	@echo "$(BOLD)2. Frontend Status:$(RESET)"
	@curl -s -o /dev/null -w "  Status: %{http_code}\n" http://localhost:3000/ || echo "  $(YELLOW)✗ Frontend not responding$(RESET)"
	@echo ""
	@echo "$(BOLD)3. Blendshapes API:$(RESET)"
	@curl -s http://localhost:8000/blendshape-names | head -c 200 && echo "..." || echo "  $(YELLOW)✗ API not responding$(RESET)"
	@echo ""

shell: ## Shell into backend container
	@$(COMPOSE) exec backend bash

shell-frontend: ## Shell into frontend container
	@$(COMPOSE) exec frontend sh

##@ Cleanup

clean: ## Remove stopped containers and unused images
	@echo "$(BOLD)Cleaning up Docker resources...$(RESET)"
	@docker system prune -f
	@echo "$(GREEN)✓ Cleanup complete$(RESET)"

clean-all: down ## Stop services and remove all containers, images, and volumes
	@echo "$(BOLD)Removing all Docker resources...$(RESET)"
	@$(COMPOSE) down -v --rmi all
	@echo "$(GREEN)✓ Full cleanup complete$(RESET)"

##@ Development

rebuild: ## Rebuild images and restart services
	@echo "$(BOLD)Rebuilding and restarting...$(RESET)"
	@$(COMPOSE) down
	@chmod +x docker-build.sh
	@./docker-build.sh
	@$(COMPOSE) up -d
	@echo "$(GREEN)✓ Rebuild complete$(RESET)"

pull: ## Pull base images
	@echo "$(BOLD)Pulling base images...$(RESET)"
	@docker pull nvcr.io/nvidia/tensorrt:24.11-py3
	@docker pull python:3.12-slim
	@echo "$(GREEN)✓ Images updated$(RESET)"

##@ GPU & System

gpu-test: ## Test GPU access in containers
	@echo "$(BOLD)Testing GPU access...$(RESET)"
	@docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu22.04 nvidia-smi || \
		echo "$(YELLOW)⚠ GPU access not available$(RESET)"

system-info: ## Show system information
	@echo "$(BOLD)System Information:$(RESET)"
	@echo "Docker: $$(docker --version)"
	@echo "Docker Compose: $$(docker compose version)"
	@echo "GPU: $$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'Not available')"
	@echo "CUDA: $$(nvcc --version 2>/dev/null | grep 'release' || echo 'Not available')"

##@ Information

info: ## Show project information
	@echo "$(BOLD)=================================================="
	@echo "Audio2Face MVP v$(VERSION)"
	@echo "==================================================$(RESET)"
	@echo ""
	@echo "$(BOLD)Architecture:$(RESET)"
	@echo "  Backend:  FastAPI + Audio2Face SDK + TensorRT"
	@echo "  Frontend: Three.js + Ready Player Me avatars"
	@echo "  GPU:      NVIDIA L4 with CUDA 12.6 + TensorRT 10.6"
	@echo ""
	@echo "$(BOLD)Key Features:$(RESET)"
	@echo "  • Real-time facial animation from audio"
	@echo "  • 68 ARKit-compatible blendshapes"
	@echo "  • 60 FPS animation output"
	@echo "  • GPU-accelerated inference"
	@echo "  • Docker-based deployment"
	@echo ""
	@echo "$(BOLD)Ports:$(RESET)"
	@echo "  Frontend: 3000"
	@echo "  Backend:  8000"
	@echo ""
	@echo "$(BOLD)Quick Commands:$(RESET)"
	@echo "  make build    # Build images"
	@echo "  make up       # Start services"
	@echo "  make logs     # View logs"
	@echo "  make test     # Run health checks"
	@echo "  make down     # Stop services"
	@echo ""
