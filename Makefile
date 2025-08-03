# IPTV Manager Makefile
# 简化项目管理的Makefile

.PHONY: help install test clean lint format check-deps

# Default target
help:
	@echo "IPTV Manager - Available Commands"
	@echo "=================================="
	@echo "install     - Run installation script"
	@echo "test        - Run installation tests"
	@echo "clean       - Clean generated files"
	@echo "lint        - Run code linting"
	@echo "format      - Format code"
	@echo "check-deps  - Check Python dependencies"
	@echo "run         - Run IPTV Manager interactively"
	@echo "download    - Download sources directly"
	@echo "status      - Show system status"

# Installation
install:
	@echo "Running installation script..."
	@bash install.sh

# Testing
test:
	@echo "Running installation tests..."
	@python3 test_installation.py

# Clean up
clean:
	@echo "Cleaning up generated files..."
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@rm -rf .pytest_cache/
	@rm -rf build/
	@rm -rf dist/
	@rm -rf *.egg-info/

# Code linting (if pylint is available)
lint:
	@echo "Running code linting..."
	@if command -v pylint >/dev/null 2>&1; then \
		pylint iptv_manager.py languages.py test_installation.py; \
	else \
		echo "pylint not found, skipping lint check"; \
		echo "Install with: pip3 install pylint"; \
	fi

# Code formatting (if black is available)
format:
	@echo "Formatting code..."
	@if command -v black >/dev/null 2>&1; then \
		black iptv_manager.py languages.py test_installation.py; \
	else \
		echo "black not found, skipping formatting"; \
		echo "Install with: pip3 install black"; \
	fi

# Check dependencies
check-deps:
	@echo "Checking Python dependencies..."
	@python3 -c "import requests; print('✓ requests available')" 2>/dev/null || echo "✗ requests missing"
	@python3 -c "import chardet; print('✓ chardet available')" 2>/dev/null || echo "✗ chardet missing"

# Run IPTV Manager
run:
	@echo "Starting IPTV Manager..."
	@python3 iptv_manager.py

# Download sources
download:
	@echo "Downloading IPTV sources..."
	@python3 iptv_manager.py --download

# Show status
status:
	@echo "Showing system status..."
	@python3 iptv_manager.py --status

# Development setup
dev-setup:
	@echo "Setting up development environment..."
	@pip3 install --user requests chardet pylint black
	@echo "Development dependencies installed"

# Create release package
package:
	@echo "Creating release package..."
	@mkdir -p dist
	@tar -czf dist/iptv-manager-$(shell date +%Y%m%d).tar.gz \
		--exclude='.git*' \
		--exclude='dist' \
		--exclude='__pycache__' \
		--exclude='*.pyc' \
		--exclude='data' \
		--exclude='backup' \
		--exclude='logs' \
		.
	@echo "Package created in dist/"

# Quick installation test
quick-test:
	@echo "Running quick functionality test..."
	@python3 -c "import iptv_manager; print('✓ Main module imports successfully')"
	@python3 -c "import languages; print('✓ Language module imports successfully')"
	@python3 iptv_manager.py --version
	@echo "✓ Quick test completed"