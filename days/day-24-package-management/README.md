# Day 24: Package Management - pip, poetry, uv

**Duration**: 1 hour  
**Prerequisites**: Python basics, virtual environments  
**Learning Goal**: Master modern Python package management tools for data projects

## Overview

Package management is crucial for data and AI projects. You'll learn pip fundamentals, modern poetry workflows, and the blazing-fast uv tool for dependency management.

## Why Package Management Matters

**Problems without proper package management**:
- Dependency conflicts between projects
- Unreproducible environments
- Security vulnerabilities in packages
- Slow installation and resolution times
- Unclear project dependencies

**Benefits of modern package management**:
- Isolated project environments
- Reproducible builds across teams
- Automated security scanning
- Fast dependency resolution
- Clear dependency tracking

## Core Concepts

### Package Managers Comparison

| Tool | Speed | Features | Use Case |
|------|-------|----------|----------|
| **pip** | Slow | Basic | Simple projects, legacy |
| **poetry** | Medium | Full featured | Modern projects, publishing |
| **uv** | Very Fast | Modern, Rust-based | Performance-critical, new projects |

### Virtual Environments

```bash
# Traditional venv
python -m venv myenv
source myenv/bin/activate  # Linux/Mac
myenv\Scripts\activate     # Windows

# Poetry (automatic)
poetry shell

# uv (automatic)
uv venv
source .venv/bin/activate
```

## Tool Deep Dive

### 1. pip - The Foundation

**Basic Operations**:
```bash
# Install packages
pip install pandas numpy
pip install -r requirements.txt

# Upgrade packages
pip install --upgrade pandas
pip list --outdated

# Uninstall
pip uninstall pandas
```

**Requirements Files**:
```txt
# requirements.txt
pandas==2.1.0
numpy>=1.24.0,<2.0.0
scikit-learn~=1.3.0
requests[security]>=2.31.0
```

**Development Dependencies**:
```txt
# requirements-dev.txt
pytest>=7.0.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0
```

### 2. Poetry - Modern Python Packaging

**Project Structure**:
```toml
# pyproject.toml
[tool.poetry]
name = "data-pipeline"
version = "0.1.0"
description = "Data processing pipeline"
authors = ["Your Name <email@example.com>"]

[tool.poetry.dependencies]
python = "^3.9"
pandas = "^2.1.0"
numpy = "^1.24.0"
requests = "^2.31.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.0.0"
black = "^23.0.0"
mypy = "^1.0.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

**Common Commands**:
```bash
# Initialize project
poetry new data-project
poetry init  # In existing directory

# Manage dependencies
poetry add pandas numpy
poetry add --group dev pytest black
poetry remove pandas

# Environment management
poetry install
poetry shell
poetry run python script.py

# Lock dependencies
poetry lock
poetry export -f requirements.txt --output requirements.txt
```

### 3. uv - Ultra-Fast Package Manager

**Installation**:
```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
# or
pip install uv
```

**Basic Usage**:
```bash
# Create project
uv init data-project
cd data-project

# Add dependencies
uv add pandas numpy scikit-learn
uv add --dev pytest black mypy

# Install dependencies
uv sync

# Run commands
uv run python script.py
uv run pytest
```

**pyproject.toml with uv**:
```toml
[project]
name = "data-project"
version = "0.1.0"
description = "Fast data processing"
dependencies = [
    "pandas>=2.1.0",
    "numpy>=1.24.0",
    "scikit-learn>=1.3.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "mypy>=1.0.0",
]

[tool.uv]
dev-dependencies = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "mypy>=1.0.0",
]
```

## Data Science Package Management

### Common Data Packages

```bash
# Core data science stack
pip install pandas numpy matplotlib seaborn jupyter

# Machine learning
pip install scikit-learn xgboost lightgbm

# Deep learning
pip install torch torchvision tensorflow

# Data engineering
pip install apache-airflow dbt-core sqlalchemy

# API and web
pip install fastapi uvicorn requests httpx
```

### Managing Large Dependencies

```bash
# Use constraints for reproducibility
pip install -c constraints.txt -r requirements.txt

# constraints.txt
numpy==1.24.3
pandas==2.1.0
scikit-learn==1.3.0
```

### Environment Files

```bash
# .env file for configuration
DATABASE_URL=postgresql://user:pass@localhost/db
API_KEY=your-secret-key
DEBUG=true

# Load in Python
from dotenv import load_dotenv
import os

load_dotenv()
db_url = os.getenv('DATABASE_URL')
```

## Security Best Practices

### Dependency Scanning

```bash
# Check for vulnerabilities
pip-audit
# or
safety check

# With poetry
poetry audit

# With uv
uv audit
```

### Lock Files

```bash
# Generate lock files
pip freeze > requirements.lock
poetry lock
uv lock
```

### Private Packages

```bash
# Install from private index
pip install --index-url https://private.pypi.org/simple/ private-package

# Poetry with private repos
poetry config repositories.private https://private.pypi.org/simple/
poetry add --source private private-package
```

## Performance Optimization

### Caching

```bash
# pip cache
pip cache dir
pip cache purge

# Poetry cache
poetry cache clear --all pypi

# uv cache (automatic)
uv cache clean
```

### Parallel Installation

```bash
# pip with parallel downloads
pip install --use-pep517 --no-build-isolation package

# uv (parallel by default)
uv add package1 package2 package3
```

## CI/CD Integration

### GitHub Actions with Poetry

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install Poetry
        uses: snok/install-poetry@v1
      - name: Install dependencies
        run: poetry install
      - name: Run tests
        run: poetry run pytest
```

### GitHub Actions with uv

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install uv
        uses: astral-sh/setup-uv@v1
      - name: Set up Python
        run: uv python install 3.11
      - name: Install dependencies
        run: uv sync
      - name: Run tests
        run: uv run pytest
```

## Docker Integration

### Multi-stage Dockerfile with Poetry

```dockerfile
FROM python:3.11-slim as builder

RUN pip install poetry
COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false
RUN poetry install --no-dev

FROM python:3.11-slim
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY . .
CMD ["python", "app.py"]
```

### Dockerfile with uv

```dockerfile
FROM python:3.11-slim

RUN pip install uv
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen
COPY . .
CMD ["uv", "run", "python", "app.py"]
```

## Troubleshooting Common Issues

### Dependency Conflicts

```bash
# Check conflicts
pip check
poetry check

# Resolve with constraints
pip install --constraint constraints.txt package
```

### Version Pinning

```bash
# Pin exact versions for reproducibility
pandas==2.1.0
numpy==1.24.3

# Allow patch updates
pandas~=2.1.0  # >=2.1.0, <2.2.0

# Allow minor updates
pandas^=2.1.0  # >=2.1.0, <3.0.0
```

### Environment Issues

```bash
# Clean environment
pip freeze | xargs pip uninstall -y
poetry env remove python
uv clean
```

## Best Practices

### Project Structure

```
data-project/
├── pyproject.toml          # Project configuration
├── requirements.txt        # pip compatibility
├── requirements-dev.txt    # Development dependencies
├── .env.example           # Environment template
├── .gitignore             # Ignore virtual environments
├── src/
│   └── data_project/
│       ├── __init__.py
│       └── main.py
├── tests/
│   └── test_main.py
└── docs/
    └── README.md
```

### Dependency Management

1. **Use lock files** for reproducible builds
2. **Separate dev dependencies** from production
3. **Pin versions** for critical dependencies
4. **Regular updates** with testing
5. **Security scanning** in CI/CD

### Tool Selection Guide

- **pip**: Legacy projects, simple scripts
- **poetry**: Full-featured projects, publishing packages
- **uv**: New projects, performance-critical applications

## Summary

Package management is essential for professional data projects. Modern tools like poetry and uv provide better dependency resolution, security, and performance than traditional pip workflows.

**Key takeaways**:
- Use virtual environments for isolation
- Lock dependencies for reproducibility
- Separate development and production dependencies
- Integrate security scanning in workflows
- Choose the right tool for your project needs

**Next**: Day 25 will cover API testing with curl and httpie for data pipeline integration.
