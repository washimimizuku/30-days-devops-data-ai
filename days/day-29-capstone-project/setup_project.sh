#!/bin/bash

# Day 29: Capstone Project Setup
# Creates the complete DataFlow Analytics project structure

set -e

echo "🚀 Day 29: Capstone Project - DataFlow Analytics"
echo "================================================"

PROJECT_NAME="dataflow-analytics"

# Create main project directory
echo "📁 Creating project structure..."
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Initialize Git repository
echo "🔧 Initializing Git repository..."
git init
echo "# DataFlow Analytics - Capstone Project" > README.md
echo "" >> README.md
echo "A complete data processing pipeline demonstrating 30 days of developer tools mastery." >> README.md

# Create directory structure
echo "📂 Creating directory structure..."
mkdir -p src/{ingestion,processing,api,common,config}
mkdir -p tests/{unit,integration,api}
mkdir -p data/{raw,processed,archive}
mkdir -p docker/{ingestion,processing,api,database}
mkdir -p scripts docs .github/workflows

# Create configuration files
echo "⚙️ Creating configuration files..."

# Environment template
cat > .env.example << 'EOF'
# Database Configuration
DATABASE_URL=postgresql://dataflow:password@localhost:5432/dataflow
DB_PASSWORD=secure_password_123

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
SECRET_KEY=your-secret-key-here

# Processing Configuration
BATCH_SIZE=1000
MAX_WORKERS=4

# Monitoring Configuration
LOG_LEVEL=INFO
ENABLE_METRICS=true

# Security Configuration
ENCRYPTION_KEY=your-encryption-key-here
JWT_SECRET=your-jwt-secret-here
EOF

# Docker Compose
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  database:
    image: postgres:15
    environment:
      POSTGRES_DB: dataflow
      POSTGRES_USER: dataflow
      POSTGRES_PASSWORD: ${DB_PASSWORD:-password123}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/database/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dataflow"]
      interval: 30s
      timeout: 10s
      retries: 3

  ingestion:
    build: 
      context: .
      dockerfile: docker/ingestion/Dockerfile
    environment:
      - DATABASE_URL=postgresql://dataflow:${DB_PASSWORD:-password123}@database:5432/dataflow
      - LOG_LEVEL=${LOG_LEVEL:-INFO}
    depends_on:
      database:
        condition: service_healthy
    volumes:
      - ./data:/app/data
      - ./src:/app/src

  processing:
    build:
      context: .
      dockerfile: docker/processing/Dockerfile
    environment:
      - DATABASE_URL=postgresql://dataflow:${DB_PASSWORD:-password123}@database:5432/dataflow
      - BATCH_SIZE=${BATCH_SIZE:-1000}
      - MAX_WORKERS=${MAX_WORKERS:-4}
    depends_on:
      database:
        condition: service_healthy
    volumes:
      - ./data:/app/data
      - ./src:/app/src

  api:
    build:
      context: .
      dockerfile: docker/api/Dockerfile
    environment:
      - DATABASE_URL=postgresql://dataflow:${DB_PASSWORD:-password123}@database:5432/dataflow
      - SECRET_KEY=${SECRET_KEY:-dev-secret-key}
      - API_HOST=${API_HOST:-0.0.0.0}
      - API_PORT=${API_PORT:-8000}
    ports:
      - "8000:8000"
    depends_on:
      database:
        condition: service_healthy
    volumes:
      - ./src:/app/src

volumes:
  postgres_data:
EOF

# Makefile for task automation
cat > Makefile << 'EOF'
.PHONY: help setup build test run clean deploy

help:
	@echo "DataFlow Analytics - Available Commands:"
	@echo "  setup    - Set up development environment"
	@echo "  build    - Build Docker images"
	@echo "  test     - Run all tests"
	@echo "  run      - Start all services"
	@echo "  clean    - Clean up containers and volumes"
	@echo "  deploy   - Deploy to production"

setup:
	@echo "Setting up development environment..."
	cp .env.example .env
	pip install -r requirements.txt
	pip install -r requirements-dev.txt

build:
	@echo "Building Docker images..."
	docker-compose build

test:
	@echo "Running tests..."
	pytest tests/ --cov=src --cov-report=html --cov-report=term

run:
	@echo "Starting services..."
	docker-compose up -d
	@echo "Services started. API available at http://localhost:8000"

clean:
	@echo "Cleaning up..."
	docker-compose down -v
	docker system prune -f

deploy:
	@echo "Deploying to production..."
	./scripts/deploy.sh
EOF

# Requirements files
cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
pandas==2.1.4
numpy==1.24.4
aiohttp==3.9.1
pydantic==2.5.2
python-dotenv==1.0.0
structlog==23.2.0
cryptography==41.0.8
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
alembic==1.13.1
EOF

cat > requirements-dev.txt << 'EOF'
pytest==7.4.3
pytest-asyncio==0.21.1
pytest-cov==4.1.0
pytest-mock==3.12.0
httpx==0.25.2
black==23.12.1
isort==5.13.2
flake8==6.1.0
mypy==1.8.0
bandit==1.7.5
safety==2.3.5
pre-commit==3.6.0
EOF

# Git ignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Testing
.coverage
htmlcov/
.pytest_cache/
.tox/

# Database
*.db
*.sqlite3

# Logs
*.log
logs/

# Data files
data/raw/*
data/processed/*
data/archive/*
!data/raw/.gitkeep
!data/processed/.gitkeep
!data/archive/.gitkeep

# Docker
.dockerignore

# OS
.DS_Store
Thumbs.db
EOF

# Create source code structure
echo "💻 Creating source code templates..."

# Configuration management
cat > src/config/__init__.py << 'EOF'
"""Configuration management module."""
EOF

cat > src/config/settings.py << 'EOF'
"""Application settings and configuration."""
import os
from dataclasses import dataclass
from typing import Optional

@dataclass
class Settings:
    """Application settings loaded from environment variables."""
    
    # Database
    database_url: str = os.getenv('DATABASE_URL', 'sqlite:///dataflow.db')
    
    # API
    api_host: str = os.getenv('API_HOST', '0.0.0.0')
    api_port: int = int(os.getenv('API_PORT', '8000'))
    secret_key: str = os.getenv('SECRET_KEY', 'dev-secret-key')
    
    # Processing
    batch_size: int = int(os.getenv('BATCH_SIZE', '1000'))
    max_workers: int = int(os.getenv('MAX_WORKERS', '4'))
    
    # Monitoring
    log_level: str = os.getenv('LOG_LEVEL', 'INFO')
    enable_metrics: bool = os.getenv('ENABLE_METRICS', 'true').lower() == 'true'
    
    # Security
    encryption_key: Optional[str] = os.getenv('ENCRYPTION_KEY')
    jwt_secret: str = os.getenv('JWT_SECRET', 'jwt-secret-key')
    
    @classmethod
    def load(cls) -> 'Settings':
        """Load settings from environment."""
        return cls()
    
    def validate(self) -> list[str]:
        """Validate configuration and return any errors."""
        errors = []
        
        if not self.database_url:
            errors.append("DATABASE_URL is required")
        
        if not self.secret_key or self.secret_key == 'dev-secret-key':
            errors.append("SECRET_KEY must be set to a secure value")
        
        if self.batch_size <= 0:
            errors.append("BATCH_SIZE must be positive")
        
        if self.max_workers <= 0:
            errors.append("MAX_WORKERS must be positive")
        
        return errors
EOF

# Common models
cat > src/common/__init__.py << 'EOF'
"""Common utilities and models."""
EOF

cat > src/common/models.py << 'EOF'
"""Data models for the application."""
from dataclasses import dataclass
from datetime import datetime
from typing import Optional, Dict, Any
from enum import Enum

class RecordStatus(Enum):
    RAW = "raw"
    PROCESSING = "processing"
    PROCESSED = "processed"
    FAILED = "failed"

@dataclass
class DataRecord:
    """Represents a data record in the pipeline."""
    id: str
    timestamp: datetime
    source: str
    data: Dict[str, Any]
    processed_at: Optional[datetime] = None
    status: RecordStatus = RecordStatus.RAW
    
@dataclass
class ProcessingResult:
    """Result of processing a data record."""
    record_id: str
    success: bool
    processed_data: Optional[Dict[str, Any]] = None
    error_message: Optional[str] = None
    processing_time: float = 0.0
    
@dataclass
class HealthStatus:
    """Health check status."""
    service: str
    status: str
    timestamp: float
    details: Dict[str, Any]
EOF

# Create placeholder files for services
touch src/ingestion/__init__.py
touch src/processing/__init__.py
touch src/api/__init__.py

# Create test structure
echo "🧪 Creating test templates..."
touch tests/__init__.py
touch tests/unit/__init__.py
touch tests/integration/__init__.py
touch tests/api/__init__.py

# Create basic unit test
cat > tests/unit/test_settings.py << 'EOF'
"""Tests for configuration settings."""
import pytest
from src.config.settings import Settings

def test_settings_load():
    """Test settings loading."""
    settings = Settings.load()
    assert settings is not None
    assert settings.api_port > 0
    assert settings.batch_size > 0

def test_settings_validation():
    """Test settings validation."""
    settings = Settings()
    errors = settings.validate()
    # Should have errors for default dev values
    assert len(errors) > 0
EOF

# Create Docker files
echo "🐳 Creating Docker configurations..."

# Base Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY src/ ./src/

# Create non-root user
RUN useradd --create-home --shell /bin/bash dataflow
USER dataflow

CMD ["python", "-m", "src.api.main"]
EOF

# API Dockerfile
cat > docker/api/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/

RUN useradd --create-home --shell /bin/bash dataflow
USER dataflow

EXPOSE 8000

CMD ["uvicorn", "src.api.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Database init script
cat > docker/database/init.sql << 'EOF'
-- Initialize DataFlow Analytics database

CREATE TABLE IF NOT EXISTS data_records (
    id VARCHAR(255) PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    source VARCHAR(100) NOT NULL,
    data JSONB NOT NULL,
    processed_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'raw',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_data_records_status ON data_records(status);
CREATE INDEX idx_data_records_timestamp ON data_records(timestamp);
CREATE INDEX idx_data_records_source ON data_records(source);

-- Create processing results table
CREATE TABLE IF NOT EXISTS processing_results (
    id SERIAL PRIMARY KEY,
    record_id VARCHAR(255) REFERENCES data_records(id),
    success BOOLEAN NOT NULL,
    processed_data JSONB,
    error_message TEXT,
    processing_time FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_processing_results_record_id ON processing_results(record_id);
CREATE INDEX idx_processing_results_success ON processing_results(success);
EOF

# Create CI/CD pipeline
echo "🔄 Creating CI/CD pipeline..."
cat > .github/workflows/ci.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  PYTHON_VERSION: '3.11'

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_dataflow
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ env.PYTHON_VERSION }}
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Run tests
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_dataflow
        run: |
          pytest tests/ --cov=src --cov-report=xml --cov-report=term
      
      - name: Run security checks
        run: |
          bandit -r src/
          safety check
      
      - name: Run code quality checks
        run: |
          black --check src/ tests/
          isort --check-only src/ tests/
          flake8 src/ tests/
          mypy src/

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker images
        run: |
          docker-compose build
      
      - name: Test Docker setup
        run: |
          docker-compose up -d
          sleep 30
          curl -f http://localhost:8000/health || exit 1
          docker-compose down

  deploy:
    needs: [test, build]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment..."
          # Add actual deployment steps here
EOF

# Create setup script
cat > scripts/setup.sh << 'EOF'
#!/bin/bash

echo "🚀 Setting up DataFlow Analytics development environment..."

# Copy environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Created .env file from template"
fi

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Set up pre-commit hooks
echo "🔧 Setting up pre-commit hooks..."
pre-commit install

# Create data directories
mkdir -p data/{raw,processed,archive}
touch data/raw/.gitkeep
touch data/processed/.gitkeep
touch data/archive/.gitkeep

echo "✅ Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Review and update .env file with your configuration"
echo "2. Run 'make build' to build Docker images"
echo "3. Run 'make run' to start all services"
echo "4. Visit http://localhost:8000/docs for API documentation"
EOF

chmod +x scripts/setup.sh

# Create sample data
echo "📊 Creating sample data..."
cat > data/raw/sample_data.csv << 'EOF'
id,value,category,timestamp
1,100,A,2024-01-01T10:00:00Z
2,200,B,2024-01-01T10:01:00Z
3,150,A,2024-01-01T10:02:00Z
4,300,C,2024-01-01T10:03:00Z
5,250,B,2024-01-01T10:04:00Z
EOF

# Create documentation
echo "📚 Creating documentation..."
cat > docs/README.md << 'EOF'
# DataFlow Analytics Documentation

## Architecture Overview

DataFlow Analytics is a complete data processing pipeline that demonstrates:

- **Data Ingestion**: Fetch data from APIs and process files
- **Data Processing**: Clean, transform, and validate data
- **Data Storage**: Store processed data in PostgreSQL
- **REST API**: Provide endpoints for data access
- **Monitoring**: Health checks and logging
- **Security**: Authentication and authorization

## Quick Start

1. Clone the repository
2. Run `./scripts/setup.sh` to set up the environment
3. Run `make build` to build Docker images
4. Run `make run` to start all services
5. Visit http://localhost:8000/docs for API documentation

## Development Workflow

1. Make changes to source code
2. Run `make test` to run tests
3. Commit changes with descriptive messages
4. Push to trigger CI/CD pipeline

## Deployment

The application is containerized and can be deployed to any Docker-compatible platform.

See deployment.md for detailed deployment instructions.
EOF

# Create gitkeep files for empty directories
touch data/raw/.gitkeep
touch data/processed/.gitkeep
touch data/archive/.gitkeep

# Initial git commit
echo "📝 Creating initial Git commit..."
git add .
git commit -m "Initial commit: DataFlow Analytics capstone project

- Complete project structure with Docker setup
- Configuration management with environment variables
- CI/CD pipeline with GitHub Actions
- Test framework with pytest
- Documentation and setup scripts
- Sample data and database schema

Ready for development and deployment!"

echo ""
echo "🎉 DataFlow Analytics project created successfully!"
echo ""
echo "Project location: $(pwd)"
echo ""
echo "Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. ./scripts/setup.sh"
echo "3. make build"
echo "4. make run"
echo "5. Open http://localhost:8000/docs"
echo ""
echo "Happy coding! 🚀"
