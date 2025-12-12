#!/bin/bash

# Day 24: Package Management Solutions
# Reference implementations and best practices

set -e

echo "🐍 Day 24: Package Management Solutions"
echo "======================================="

# Solution 1: Advanced pip Configuration
echo -e "\n📦 Solution 1: Advanced pip Configuration"

mkdir -p solution1-advanced-pip
cd solution1-advanced-pip

# Create pip.conf for better defaults
mkdir -p ~/.pip
cat > ~/.pip/pip.conf << 'EOF'
[global]
timeout = 60
index-url = https://pypi.org/simple/
trusted-host = pypi.org
               pypi.python.org
               files.pythonhosted.org

[install]
use-pep517 = true
upgrade-strategy = only-if-needed
EOF

# Create comprehensive requirements with constraints
cat > requirements.txt << 'EOF'
# Core data science
pandas>=2.1.0,<3.0.0
numpy>=1.24.0,<2.0.0
scikit-learn>=1.3.0,<2.0.0
matplotlib>=3.7.0,<4.0.0
seaborn>=0.12.0,<1.0.0

# Data processing
requests>=2.31.0,<3.0.0
sqlalchemy>=2.0.0,<3.0.0
pydantic>=2.0.0,<3.0.0

# Optional dependencies with extras
requests[security]>=2.31.0
pandas[performance]>=2.1.0
EOF

# Create constraints file for reproducible builds
cat > constraints.txt << 'EOF'
# Exact versions for reproducible builds
pandas==2.1.4
numpy==1.24.4
scikit-learn==1.3.2
matplotlib==3.8.2
seaborn==0.13.0
requests==2.31.0
sqlalchemy==2.0.23
pydantic==2.5.2
EOF

# Create development requirements
cat > requirements-dev.txt << 'EOF'
# Testing
pytest>=7.4.0
pytest-cov>=4.1.0
pytest-mock>=3.12.0
pytest-xdist>=3.5.0

# Code quality
black>=23.12.0
isort>=5.13.0
flake8>=6.1.0
mypy>=1.8.0
bandit>=1.7.5

# Documentation
sphinx>=7.2.0
sphinx-rtd-theme>=2.0.0

# Development tools
ipython>=8.18.0
jupyter>=1.0.0
pre-commit>=3.6.0
EOF

# Create Makefile for common tasks
cat > Makefile << 'EOF'
.PHONY: install install-dev test lint format clean

# Virtual environment
venv:
	python3 -m venv venv
	venv/bin/pip install --upgrade pip setuptools wheel

# Install production dependencies
install: venv
	venv/bin/pip install -c constraints.txt -r requirements.txt

# Install development dependencies
install-dev: install
	venv/bin/pip install -r requirements-dev.txt

# Run tests
test:
	venv/bin/pytest tests/ -v --cov=src --cov-report=html

# Lint code
lint:
	venv/bin/flake8 src tests
	venv/bin/mypy src
	venv/bin/bandit -r src

# Format code
format:
	venv/bin/black src tests
	venv/bin/isort src tests

# Clean up
clean:
	rm -rf venv __pycache__ .pytest_cache htmlcov .coverage
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
EOF

cd ..
echo "✅ Solution 1: Advanced pip configuration with constraints and Makefile"

# Solution 2: Production-Ready Poetry Project
echo -e "\n🎭 Solution 2: Production-Ready Poetry Project"

poetry new --src data-analytics-platform
cd data-analytics-platform

# Update pyproject.toml with comprehensive configuration
cat > pyproject.toml << 'EOF'
[tool.poetry]
name = "data-analytics-platform"
version = "0.1.0"
description = "Production-ready data analytics platform"
authors = ["Your Name <you@example.com>"]
license = "MIT"
readme = "README.md"
homepage = "https://github.com/yourorg/data-analytics-platform"
repository = "https://github.com/yourorg/data-analytics-platform"
documentation = "https://data-analytics-platform.readthedocs.io"
keywords = ["data", "analytics", "machine-learning"]
classifiers = [
    "Development Status :: 4 - Beta",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

[tool.poetry.dependencies]
python = "^3.9"
pandas = "^2.1.0"
numpy = "^1.24.0"
scikit-learn = "^1.3.0"
fastapi = "^0.104.0"
uvicorn = {extras = ["standard"], version = "^0.24.0"}
pydantic = "^2.5.0"
sqlalchemy = "^2.0.0"
alembic = "^1.13.0"
redis = "^5.0.0"
celery = "^5.3.0"
structlog = "^23.2.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
pytest-cov = "^4.1.0"
pytest-asyncio = "^0.21.0"
pytest-mock = "^3.12.0"
black = "^23.12.0"
isort = "^5.13.0"
mypy = "^1.8.0"
flake8 = "^6.1.0"
bandit = "^1.7.5"
pre-commit = "^3.6.0"
sphinx = "^7.2.0"
sphinx-rtd-theme = "^2.0.0"

[tool.poetry.group.test.dependencies]
httpx = "^0.25.0"
factory-boy = "^3.3.0"
freezegun = "^1.2.0"

[tool.poetry.scripts]
analytics = "data_analytics_platform.cli:main"
migrate = "data_analytics_platform.db:migrate"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"

# Tool configurations
[tool.black]
line-length = 88
target-version = ['py39']
include = '\.pyi?$'
extend-exclude = '''
/(
  # directories
  \.eggs
  | \.git
  | \.hg
  | \.mypy_cache
  | \.tox
  | \.venv
  | build
  | dist
)/
'''

[tool.isort]
profile = "black"
multi_line_output = 3
line_length = 88
known_first_party = ["data_analytics_platform"]

[tool.mypy]
python_version = "3.9"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true

[tool.pytest.ini_options]
minversion = "7.0"
addopts = "-ra -q --strict-markers --strict-config"
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
markers = [
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests",
]

[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/test_*.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
]

[tool.bandit]
exclude_dirs = ["tests"]
skips = ["B101", "B601"]
EOF

# Create comprehensive project structure
mkdir -p src/data_analytics_platform/{api,core,db,models,services,utils}
mkdir -p tests/{unit,integration,fixtures}
mkdir -p docs/{source,examples}
mkdir -p scripts
mkdir -p config

# Create main application
cat > src/data_analytics_platform/__init__.py << 'EOF'
"""Data Analytics Platform."""
__version__ = "0.1.0"
EOF

cat > src/data_analytics_platform/main.py << 'EOF'
"""Main application module."""
from fastapi import FastAPI
from .api.routes import router
from .core.config import settings

def create_app() -> FastAPI:
    """Create FastAPI application."""
    app = FastAPI(
        title="Data Analytics Platform",
        description="Production-ready data analytics API",
        version="0.1.0",
    )
    
    app.include_router(router, prefix="/api/v1")
    
    return app

app = create_app()
EOF

# Add dependencies and run setup
poetry install

cd ..
echo "✅ Solution 2: Production-ready Poetry project with comprehensive configuration"

# Solution 3: High-Performance uv Project
echo -e "\n⚡ Solution 3: High-Performance uv Project"

uv init --python 3.11 ml-inference-service
cd ml-inference-service

# Create comprehensive pyproject.toml for uv
cat > pyproject.toml << 'EOF'
[project]
name = "ml-inference-service"
version = "0.1.0"
description = "High-performance ML inference service"
authors = [{name = "Your Name", email = "you@example.com"}]
license = {text = "MIT"}
readme = "README.md"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.104.0",
    "uvicorn[standard]>=0.24.0",
    "pydantic>=2.5.0",
    "numpy>=1.24.0",
    "scikit-learn>=1.3.0",
    "torch>=2.1.0",
    "transformers>=4.35.0",
    "redis>=5.0.0",
    "structlog>=23.2.0",
    "prometheus-client>=0.19.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.1.0",
    "httpx>=0.25.0",
    "black>=23.12.0",
    "ruff>=0.1.0",
    "mypy>=1.8.0",
]
gpu = [
    "torch[cuda]>=2.1.0",
    "nvidia-ml-py>=12.535.0",
]
monitoring = [
    "prometheus-client>=0.19.0",
    "grafana-client>=3.5.0",
]

[project.scripts]
ml-serve = "ml_inference_service.cli:serve"
ml-benchmark = "ml_inference_service.cli:benchmark"

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.uv]
dev-dependencies = [
    "pytest>=7.4.0",
    "pytest-asyncio>=0.21.0",
    "pytest-cov>=4.1.0",
    "httpx>=0.25.0",
    "black>=23.12.0",
    "ruff>=0.1.0",
    "mypy>=1.8.0",
]

[tool.ruff]
line-length = 88
target-version = "py311"
select = ["E", "F", "I", "N", "W", "UP"]
ignore = ["E501"]

[tool.ruff.per-file-ignores]
"tests/*" = ["F401", "F811"]

[tool.black]
line-length = 88
target-version = ['py311']

[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
EOF

# Create high-performance ML service
mkdir -p src/ml_inference_service/{api,core,models,utils}

cat > src/ml_inference_service/core/model_manager.py << 'EOF'
"""High-performance model manager with caching."""
import asyncio
import time
from typing import Dict, Any, Optional
from functools import lru_cache
import numpy as np
from sklearn.base import BaseEstimator
import structlog

logger = structlog.get_logger()

class ModelManager:
    """Manages ML models with caching and async loading."""
    
    def __init__(self):
        self._models: Dict[str, BaseEstimator] = {}
        self._model_stats: Dict[str, Dict[str, Any]] = {}
        self._lock = asyncio.Lock()
    
    async def load_model(self, model_name: str, model_path: str) -> None:
        """Load model asynchronously."""
        async with self._lock:
            if model_name in self._models:
                return
            
            start_time = time.time()
            # Simulate model loading
            await asyncio.sleep(0.1)  # Simulate I/O
            
            # In real implementation, load actual model
            from sklearn.ensemble import RandomForestClassifier
            model = RandomForestClassifier(n_estimators=100)
            
            # Simulate training with dummy data
            X_dummy = np.random.randn(100, 10)
            y_dummy = np.random.randint(0, 2, 100)
            model.fit(X_dummy, y_dummy)
            
            self._models[model_name] = model
            self._model_stats[model_name] = {
                'loaded_at': time.time(),
                'load_time': time.time() - start_time,
                'predictions': 0,
                'total_inference_time': 0.0
            }
            
            logger.info("Model loaded", model=model_name, load_time=time.time() - start_time)
    
    async def predict(self, model_name: str, features: np.ndarray) -> np.ndarray:
        """Make prediction with performance tracking."""
        if model_name not in self._models:
            raise ValueError(f"Model {model_name} not loaded")
        
        start_time = time.time()
        
        # Make prediction
        model = self._models[model_name]
        prediction = model.predict(features)
        
        # Update stats
        inference_time = time.time() - start_time
        stats = self._model_stats[model_name]
        stats['predictions'] += 1
        stats['total_inference_time'] += inference_time
        
        logger.debug("Prediction made", 
                    model=model_name, 
                    inference_time=inference_time,
                    features_shape=features.shape)
        
        return prediction
    
    def get_stats(self) -> Dict[str, Dict[str, Any]]:
        """Get model performance statistics."""
        stats = {}
        for model_name, model_stats in self._model_stats.items():
            avg_inference_time = (
                model_stats['total_inference_time'] / model_stats['predictions']
                if model_stats['predictions'] > 0 else 0
            )
            stats[model_name] = {
                **model_stats,
                'avg_inference_time': avg_inference_time
            }
        return stats

# Global model manager instance
model_manager = ModelManager()
EOF

# Add all dependencies
uv add fastapi uvicorn pydantic numpy scikit-learn structlog
uv add --dev pytest pytest-asyncio httpx black ruff mypy

# Sync dependencies
uv sync

cd ..
echo "✅ Solution 3: High-performance uv project with async ML inference"

# Solution 4: Security-First Package Management
echo -e "\n🔒 Solution 4: Security-First Package Management"

mkdir -p solution4-security
cd solution4-security

# Create security-focused requirements
cat > requirements.txt << 'EOF'
# Core dependencies with security considerations
requests[security]==2.31.0
cryptography>=41.0.0
pyjwt[crypto]>=2.8.0
bcrypt>=4.1.0
passlib[bcrypt]>=1.7.4

# Data processing (pinned for security)
pandas==2.1.4
numpy==1.24.4

# Web framework with security extras
fastapi[all]==0.104.1
uvicorn[standard]==0.24.0
EOF

# Create security configuration
cat > .bandit << 'EOF'
[bandit]
exclude_dirs = ["tests", "venv", ".venv"]
skips = ["B101"]  # Skip assert_used test

[bandit.assert_used]
skips = ["*_test.py", "test_*.py"]
EOF

# Create pre-commit configuration
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: debug-statements

  - repo: https://github.com/psf/black
    rev: 23.12.1
    hooks:
      - id: black

  - repo: https://github.com/pycqa/isort
    rev: 5.13.2
    hooks:
      - id: isort

  - repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
      - id: flake8

  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ["-c", ".bandit"]

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.8.0
    hooks:
      - id: mypy
        additional_dependencies: [types-requests]
EOF

# Create security scanning script
cat > security_scan.sh << 'EOF'
#!/bin/bash

echo "🔒 Running security scans..."

# Install security tools
pip install pip-audit safety bandit semgrep

# Run pip-audit
echo "Running pip-audit..."
pip-audit --format=json --output=pip-audit-report.json || true

# Run safety check
echo "Running safety check..."
safety check --json --output=safety-report.json || true

# Run bandit
echo "Running bandit..."
bandit -r . -f json -o bandit-report.json || true

# Run semgrep (if available)
if command -v semgrep &> /dev/null; then
    echo "Running semgrep..."
    semgrep --config=auto --json --output=semgrep-report.json . || true
fi

echo "Security scan complete. Check *-report.json files for results."
EOF

chmod +x security_scan.sh

# Create secure configuration management
cat > secure_config.py << 'EOF'
"""Secure configuration management."""
import os
from typing import Optional
from cryptography.fernet import Fernet
import structlog

logger = structlog.get_logger()

class SecureConfig:
    """Secure configuration manager with encryption."""
    
    def __init__(self, key: Optional[bytes] = None):
        if key is None:
            key = os.environ.get('ENCRYPTION_KEY')
            if key:
                key = key.encode()
            else:
                key = Fernet.generate_key()
                logger.warning("Generated new encryption key. Set ENCRYPTION_KEY env var.")
        
        self.cipher = Fernet(key)
    
    def encrypt_value(self, value: str) -> str:
        """Encrypt a configuration value."""
        return self.cipher.encrypt(value.encode()).decode()
    
    def decrypt_value(self, encrypted_value: str) -> str:
        """Decrypt a configuration value."""
        return self.cipher.decrypt(encrypted_value.encode()).decode()
    
    def get_secret(self, key: str, default: Optional[str] = None) -> Optional[str]:
        """Get secret from environment, decrypt if needed."""
        value = os.environ.get(key, default)
        if value and value.startswith('gAAAAA'):  # Fernet token prefix
            try:
                return self.decrypt_value(value)
            except Exception as e:
                logger.error("Failed to decrypt secret", key=key, error=str(e))
                return None
        return value

# Example usage
if __name__ == "__main__":
    config = SecureConfig()
    
    # Encrypt a secret
    secret = "my-secret-api-key"
    encrypted = config.encrypt_value(secret)
    print(f"Encrypted: {encrypted}")
    
    # Decrypt it back
    decrypted = config.decrypt_value(encrypted)
    print(f"Decrypted: {decrypted}")
EOF

cd ..
echo "✅ Solution 4: Security-first package management with scanning and encryption"

# Solution 5: CI/CD Integration Examples
echo -e "\n🚀 Solution 5: CI/CD Integration Examples"

mkdir -p solution5-cicd/.github/workflows
cd solution5-cicd

# Create comprehensive GitHub Actions workflow
cat > .github/workflows/ci.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: "3.11"

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.9", "3.10", "3.11", "3.12"]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install uv
        uses: astral-sh/setup-uv@v1
      
      - name: Install dependencies
        run: |
          uv sync --all-extras
      
      - name: Run tests
        run: |
          uv run pytest --cov=src --cov-report=xml
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Install security tools
        run: |
          pip install pip-audit safety bandit
      
      - name: Run pip-audit
        run: pip-audit --format=json --output=pip-audit.json
        continue-on-error: true
      
      - name: Run safety check
        run: safety check --json --output=safety.json
        continue-on-error: true
      
      - name: Run bandit
        run: bandit -r src -f json -o bandit.json
        continue-on-error: true
      
      - name: Upload security reports
        uses: actions/upload-artifact@v3
        with:
          name: security-reports
          path: "*.json"

  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Install uv
        uses: astral-sh/setup-uv@v1
      
      - name: Install dependencies
        run: uv sync --dev
      
      - name: Run black
        run: uv run black --check src tests
      
      - name: Run isort
        run: uv run isort --check-only src tests
      
      - name: Run flake8
        run: uv run flake8 src tests
      
      - name: Run mypy
        run: uv run mypy src

  build:
    needs: [test, security, quality]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Install build tools
        run: pip install build twine
      
      - name: Build package
        run: python -m build
      
      - name: Check package
        run: twine check dist/*
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production
    
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v3
        with:
          name: dist
          path: dist/
      
      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1
        with:
          password: ${{ secrets.PYPI_API_TOKEN }}
EOF

# Create Docker workflow
cat > .github/workflows/docker.yml << 'EOF'
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
EOF

# Create optimized Dockerfile
cat > Dockerfile << 'EOF'
# Multi-stage build for optimal image size
FROM python:3.11-slim as builder

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-dev

# Production stage
FROM python:3.11-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/.venv /app/.venv

# Copy application code
COPY src/ ./src/

# Change ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Set environment variables
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH="/app/src"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# Run application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cd ..
echo "✅ Solution 5: Comprehensive CI/CD integration with security and quality checks"

echo -e "\n🎉 All Day 24 solutions completed!"
echo ""
echo "Solutions demonstrated:"
echo "1. Advanced pip configuration with constraints and Makefile automation"
echo "2. Production-ready Poetry project with comprehensive tooling"
echo "3. High-performance uv project with async ML inference"
echo "4. Security-first package management with scanning and encryption"
echo "5. Complete CI/CD integration with GitHub Actions"
echo ""
echo "Key best practices:"
echo "- Use lock files and constraints for reproducible builds"
echo "- Implement comprehensive security scanning"
echo "- Automate quality checks and testing"
echo "- Optimize Docker builds with multi-stage approach"
echo "- Configure tools properly for team collaboration"
