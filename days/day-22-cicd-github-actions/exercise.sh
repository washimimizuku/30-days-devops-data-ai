#!/bin/bash

# Day 22: CI/CD with GitHub Actions - Hands-on Exercise
# Practice creating GitHub Actions workflows for automated CI/CD

set -e

echo "🚀 Day 22: CI/CD with GitHub Actions Exercise"
echo "============================================="

# Create exercise directory
EXERCISE_DIR="$HOME/github-actions-exercise"
echo "📁 Creating exercise directory: $EXERCISE_DIR"

if [ -d "$EXERCISE_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$EXERCISE_DIR"
fi

mkdir -p "$EXERCISE_DIR"
cd "$EXERCISE_DIR"

echo ""
echo "🎯 Exercise 1: Basic CI Workflow"
echo "================================"

echo "📦 Creating sample Python project..."

# Create project structure
mkdir -p {src,tests,.github/workflows}

# Create Python application
cat > src/calculator.py << 'EOF'
"""Simple calculator module for CI/CD demonstration."""

def add(a, b):
    """Add two numbers."""
    return a + b

def subtract(a, b):
    """Subtract two numbers."""
    return a - b

def multiply(a, b):
    """Multiply two numbers."""
    return a * b

def divide(a, b):
    """Divide two numbers."""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

def calculate_average(numbers):
    """Calculate average of a list of numbers."""
    if not numbers:
        raise ValueError("Cannot calculate average of empty list")
    return sum(numbers) / len(numbers)
EOF

cat > src/__init__.py << 'EOF'
"""Calculator package."""
from .calculator import add, subtract, multiply, divide, calculate_average

__version__ = "1.0.0"
__all__ = ["add", "subtract", "multiply", "divide", "calculate_average"]
EOF

# Create tests
cat > tests/test_calculator.py << 'EOF'
"""Tests for calculator module."""

import pytest
from src.calculator import add, subtract, multiply, divide, calculate_average

def test_add():
    """Test addition function."""
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0

def test_subtract():
    """Test subtraction function."""
    assert subtract(5, 3) == 2
    assert subtract(0, 5) == -5
    assert subtract(-1, -1) == 0

def test_multiply():
    """Test multiplication function."""
    assert multiply(3, 4) == 12
    assert multiply(-2, 3) == -6
    assert multiply(0, 5) == 0

def test_divide():
    """Test division function."""
    assert divide(10, 2) == 5
    assert divide(7, 2) == 3.5
    
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(5, 0)

def test_calculate_average():
    """Test average calculation function."""
    assert calculate_average([1, 2, 3, 4, 5]) == 3.0
    assert calculate_average([10, 20]) == 15.0
    
    with pytest.raises(ValueError, match="Cannot calculate average of empty list"):
        calculate_average([])
EOF

cat > tests/__init__.py << 'EOF'
"""Test package."""
EOF

# Create requirements files
cat > requirements.txt << 'EOF'
# No runtime dependencies for this simple example
EOF

cat > requirements-dev.txt << 'EOF'
pytest==7.3.1
pytest-cov==4.1.0
flake8==6.0.0
black==23.3.0
isort==5.12.0
mypy==1.3.0
EOF

# Create setup files
cat > setup.py << 'EOF'
"""Setup configuration for calculator package."""

from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="calculator-cicd",
    version="1.0.0",
    author="CI/CD Student",
    author_email="student@example.com",
    description="A simple calculator for CI/CD demonstration",
    long_description=long_description,
    long_description_content_type="text/markdown",
    packages=find_packages(),
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
    ],
    python_requires=">=3.8",
)
EOF

cat > README.md << 'EOF'
# Calculator CI/CD Demo

A simple calculator application demonstrating CI/CD with GitHub Actions.

## Features

- Basic arithmetic operations (add, subtract, multiply, divide)
- Average calculation
- Comprehensive test suite
- CI/CD pipeline with GitHub Actions

## Installation

```bash
pip install -e .
```

## Usage

```python
from src.calculator import add, subtract, multiply, divide, calculate_average

result = add(2, 3)  # 5
average = calculate_average([1, 2, 3, 4, 5])  # 3.0
```

## Development

```bash
# Install development dependencies
pip install -r requirements-dev.txt

# Run tests
pytest

# Run tests with coverage
pytest --cov=src --cov-report=html

# Code formatting
black .
isort .

# Linting
flake8 .

# Type checking
mypy src/
```
EOF

echo "✅ Python project created"

echo ""
echo "🎯 Exercise 2: Basic CI Workflow"
echo "================================"

# Create basic CI workflow
cat > .github/workflows/ci.yml << 'EOF'
name: Continuous Integration

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Cache pip dependencies
        uses: actions/cache@v3
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements*.txt') }}
          restore-keys: |
            ${{ runner.os }}-pip-
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements-dev.txt
          pip install -e .
      
      - name: Run linting
        run: |
          flake8 src/ tests/
          black --check src/ tests/
          isort --check-only src/ tests/
      
      - name: Run type checking
        run: mypy src/
      
      - name: Run tests with coverage
        run: |
          pytest --cov=src --cov-report=xml --cov-report=html
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          flags: unittests
          name: codecov-umbrella
EOF

echo "✅ Basic CI workflow created"

echo ""
echo "🎯 Exercise 3: Docker Build Workflow"
echo "===================================="

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ ./src/
COPY setup.py .
COPY README.md .

# Install package
RUN pip install -e .

# Create non-root user
RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -s /bin/sh appuser

USER 1001:1001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "from src.calculator import add; print(add(1, 1))" || exit 1

# Default command
CMD ["python", "-c", "from src.calculator import *; print('Calculator ready!')"]
EOF

# Create Docker build workflow
cat > .github/workflows/docker.yml << 'EOF'
name: Docker Build and Push

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}/calculator

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to Container Registry
        if: github.event_name != 'pull_request'
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha,prefix={{branch}}-
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Test Docker image
        run: |
          docker run --rm ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
EOF

echo "✅ Docker build workflow created"

echo ""
echo "🎯 Exercise 4: Security and Quality Workflow"
echo "============================================"

# Create security workflow
cat > .github/workflows/security.yml << 'EOF'
name: Security and Quality

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1'  # Weekly on Monday at 2 AM

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results to GitHub Security tab
        uses: github/codeql-action/upload-sarif@v2
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'
      
      - name: Run Bandit security linter
        run: |
          pip install bandit
          bandit -r src/ -f json -o bandit-report.json || true
      
      - name: Upload security scan results
        uses: actions/upload-artifact@v3
        with:
          name: security-reports
          path: |
            trivy-results.sarif
            bandit-report.json

  code-quality:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          pip install -r requirements-dev.txt
          pip install radon complexity-report
      
      - name: Code complexity analysis
        run: |
          radon cc src/ --json > complexity-report.json
          radon mi src/ --json > maintainability-report.json
      
      - name: Generate code quality report
        run: |
          echo "## Code Quality Report" > quality-report.md
          echo "### Complexity Analysis" >> quality-report.md
          radon cc src/ >> quality-report.md
          echo "### Maintainability Index" >> quality-report.md
          radon mi src/ >> quality-report.md
      
      - name: Upload quality reports
        uses: actions/upload-artifact@v3
        with:
          name: quality-reports
          path: |
            complexity-report.json
            maintainability-report.json
            quality-report.md
EOF

echo "✅ Security and quality workflow created"

echo ""
echo "🎯 Exercise 5: Multi-Environment Deployment"
echo "==========================================="

# Create deployment workflow
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy to Environments

on:
  push:
    branches: [main]
  release:
    types: [published]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/main' || github.event.inputs.environment == 'staging'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Deploy to staging
        run: |
          echo "🚀 Deploying to staging environment"
          echo "Image: ghcr.io/${{ github.repository }}/calculator:${{ github.sha }}"
          echo "Environment: staging"
          # Simulate deployment
          sleep 5
          echo "✅ Staging deployment completed"
        env:
          STAGING_URL: ${{ vars.STAGING_URL }}
          DEPLOY_KEY: ${{ secrets.STAGING_DEPLOY_KEY }}
      
      - name: Run smoke tests
        run: |
          echo "🧪 Running smoke tests on staging"
          # Simulate smoke tests
          python -c "
          from src.calculator import add, multiply
          assert add(2, 3) == 5
          assert multiply(4, 5) == 20
          print('✅ Smoke tests passed')
          "
      
      - name: Notify deployment
        run: |
          echo "📢 Staging deployment notification sent"

  deploy-production:
    runs-on: ubuntu-latest
    environment: production
    needs: deploy-staging
    if: github.event_name == 'release' || github.event.inputs.environment == 'production'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Deploy to production
        run: |
          echo "🏭 Deploying to production environment"
          echo "Image: ghcr.io/${{ github.repository }}/calculator:${{ github.sha }}"
          echo "Environment: production"
          # Simulate blue-green deployment
          echo "🔵 Deploying to blue environment"
          sleep 10
          echo "🔍 Health checking blue environment"
          sleep 5
          echo "🔄 Switching traffic to blue environment"
          sleep 3
          echo "🟢 Cleaning up green environment"
          echo "✅ Production deployment completed"
        env:
          PROD_URL: ${{ vars.PROD_URL }}
          DEPLOY_KEY: ${{ secrets.PROD_DEPLOY_KEY }}
      
      - name: Run production tests
        run: |
          echo "🧪 Running production validation tests"
          # Simulate production tests
          python -c "
          from src.calculator import add, subtract, multiply, divide, calculate_average
          
          # Test all functions
          assert add(10, 20) == 30
          assert subtract(20, 10) == 10
          assert multiply(5, 6) == 30
          assert divide(20, 4) == 5
          assert calculate_average([1, 2, 3, 4, 5]) == 3.0
          
          print('✅ Production validation tests passed')
          "
      
      - name: Create deployment record
        run: |
          echo "📝 Creating deployment record"
          echo "Deployment ID: deploy-$(date +%Y%m%d-%H%M%S)"
          echo "Version: ${{ github.sha }}"
          echo "Environment: production"
          echo "Status: success"
EOF

echo "✅ Multi-environment deployment workflow created"

echo ""
echo "🎯 Exercise 6: Advanced Workflow Patterns"
echo "========================================="

# Create reusable workflow
mkdir -p .github/workflows/reusable
cat > .github/workflows/reusable/test.yml << 'EOF'
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      python-version:
        required: false
        type: string
        default: '3.9'
      run-coverage:
        required: false
        type: boolean
        default: true
    outputs:
      test-result:
        description: "Test execution result"
        value: ${{ jobs.test.outputs.result }}

jobs:
  test:
    runs-on: ubuntu-latest
    outputs:
      result: ${{ steps.test.outputs.result }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Python ${{ inputs.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ inputs.python-version }}
      
      - name: Install dependencies
        run: |
          pip install -r requirements-dev.txt
          pip install -e .
      
      - name: Run tests
        id: test
        run: |
          if [ "${{ inputs.run-coverage }}" = "true" ]; then
            pytest --cov=src --cov-report=xml
          else
            pytest
          fi
          echo "result=success" >> $GITHUB_OUTPUT
EOF

# Create workflow that uses reusable workflow
cat > .github/workflows/comprehensive.yml << 'EOF'
name: Comprehensive Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test-python-38:
    uses: ./.github/workflows/reusable/test.yml
    with:
      python-version: '3.8'
      run-coverage: false

  test-python-39:
    uses: ./.github/workflows/reusable/test.yml
    with:
      python-version: '3.9'
      run-coverage: true

  test-python-310:
    uses: ./.github/workflows/reusable/test.yml
    with:
      python-version: '3.10'
      run-coverage: false

  integration-test:
    needs: [test-python-38, test-python-39, test-python-310]
    runs-on: ubuntu-latest
    if: ${{ needs.test-python-39.outputs.test-result == 'success' }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run integration tests
        run: |
          echo "🔗 Running integration tests"
          # Simulate integration tests
          python -c "
          import sys
          sys.path.append('src')
          from calculator import *
          
          # Integration test scenarios
          result1 = add(multiply(2, 3), divide(10, 2))  # 6 + 5 = 11
          assert result1 == 11
          
          numbers = [add(1, 2), multiply(2, 2), divide(10, 2)]  # [3, 4, 5]
          avg = calculate_average(numbers)
          assert avg == 4.0
          
          print('✅ Integration tests passed')
          "

  performance-test:
    needs: integration-test
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Run performance tests
        run: |
          echo "⚡ Running performance tests"
          python -c "
          import time
          import sys
          sys.path.append('src')
          from calculator import add, multiply, calculate_average
          
          # Performance test
          start_time = time.time()
          
          # Simulate heavy computation
          for i in range(10000):
              result = add(i, multiply(i, 2))
          
          # Test average calculation with large dataset
          large_numbers = list(range(1000))
          avg = calculate_average(large_numbers)
          
          end_time = time.time()
          duration = end_time - start_time
          
          print(f'Performance test completed in {duration:.4f} seconds')
          print(f'Average of 1000 numbers: {avg}')
          
          # Assert performance threshold
          assert duration < 1.0, f'Performance test failed: {duration}s > 1.0s'
          print('✅ Performance tests passed')
          "
EOF

echo "✅ Advanced workflow patterns created"

echo ""
echo "🎯 Exercise 7: Workflow Simulation"
echo "=================================="

echo "📊 Simulating GitHub Actions workflows locally..."

# Create local workflow simulation script
cat > simulate-workflows.sh << 'EOF'
#!/bin/bash

echo "🔄 Simulating GitHub Actions Workflows"
echo "======================================"

echo ""
echo "1️⃣ Continuous Integration Simulation"
echo "-----------------------------------"

echo "🐍 Setting up Python environment..."
python3 -m venv venv
source venv/bin/activate
pip install -r requirements-dev.txt
pip install -e .

echo "🧹 Running code quality checks..."
echo "  - Linting with flake8..."
flake8 src/ tests/ || echo "⚠️ Linting issues found"

echo "  - Code formatting check..."
black --check src/ tests/ || echo "⚠️ Formatting issues found"

echo "  - Import sorting check..."
isort --check-only src/ tests/ || echo "⚠️ Import sorting issues found"

echo "  - Type checking..."
mypy src/ || echo "⚠️ Type checking issues found"

echo "🧪 Running tests with coverage..."
pytest --cov=src --cov-report=term-missing

echo ""
echo "2️⃣ Docker Build Simulation"
echo "-------------------------"

echo "🐳 Building Docker image..."
docker build -t calculator-cicd:local .

echo "🧪 Testing Docker image..."
docker run --rm calculator-cicd:local

echo ""
echo "3️⃣ Security Scan Simulation"
echo "---------------------------"

echo "🔍 Running security checks..."
echo "  - Bandit security scan..."
bandit -r src/ || echo "⚠️ Security issues found"

echo ""
echo "4️⃣ Deployment Simulation"
echo "-----------------------"

echo "🚀 Simulating staging deployment..."
echo "  - Image: calculator-cicd:local"
echo "  - Environment: staging"
echo "  - Status: ✅ Success"

echo "🧪 Running smoke tests..."
python -c "
from src.calculator import add, multiply
assert add(2, 3) == 5
assert multiply(4, 5) == 20
print('✅ Smoke tests passed')
"

echo ""
echo "✅ All workflow simulations completed successfully!"

deactivate
EOF

chmod +x simulate-workflows.sh

echo "🔄 Running workflow simulation..."
./simulate-workflows.sh

echo ""
echo "🎯 Exercise 8: Workflow Analysis"
echo "==============================="

echo "📊 Analyzing created workflows..."

echo ""
echo "📋 Workflow Summary:"
echo "==================="

echo "1. Basic CI Workflow (ci.yml):"
echo "   - Multi-Python version testing"
echo "   - Code quality checks (linting, formatting, type checking)"
echo "   - Test execution with coverage reporting"
echo "   - Caching for faster builds"

echo ""
echo "2. Docker Build Workflow (docker.yml):"
echo "   - Multi-platform Docker image building"
echo "   - Container registry publishing"
echo "   - Image testing and validation"
echo "   - Build caching optimization"

echo ""
echo "3. Security Workflow (security.yml):"
echo "   - Vulnerability scanning with Trivy"
echo "   - Security linting with Bandit"
echo "   - Code complexity analysis"
echo "   - Scheduled security scans"

echo ""
echo "4. Deployment Workflow (deploy.yml):"
echo "   - Multi-environment deployment (staging/production)"
echo "   - Environment-specific configurations"
echo "   - Smoke testing and validation"
echo "   - Manual deployment triggers"

echo ""
echo "5. Comprehensive Pipeline (comprehensive.yml):"
echo "   - Reusable workflow components"
echo "   - Integration testing"
echo "   - Performance testing"
echo "   - Conditional execution"

echo ""
echo "🔍 Workflow Files Created:"
find .github/workflows -name "*.yml" -exec echo "   {}" \;

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully:"
echo "✅ Created a complete Python project with CI/CD workflows"
echo "✅ Implemented basic CI with multi-version testing"
echo "✅ Set up Docker build and publish workflows"
echo "✅ Configured security scanning and quality gates"
echo "✅ Created multi-environment deployment pipelines"
echo "✅ Implemented advanced workflow patterns"
echo "✅ Simulated workflow execution locally"
echo ""
echo "🔍 Key GitHub Actions concepts practiced:"
echo "   Workflow triggers - push, PR, schedule, manual"
echo "   Job dependencies - needs, conditional execution"
echo "   Matrix strategies - multi-version testing"
echo "   Caching - pip dependencies, Docker layers"
echo "   Secrets management - secure credential handling"
echo "   Artifacts - test reports, security scans"
echo "   Reusable workflows - DRY principles"
echo "   Environment protection - staging/production gates"
echo ""
echo "📁 Project location: $EXERCISE_DIR"
echo ""
echo "💡 Next steps:"
echo "   1. Push this project to GitHub to see workflows in action"
echo "   2. Configure repository secrets for deployment"
echo "   3. Set up environment protection rules"
echo "   4. Add status badges to README.md"
echo ""
echo "🚀 Ready for automated testing strategies!"
