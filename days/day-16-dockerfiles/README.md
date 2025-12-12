# Day 16: Dockerfiles

**Duration**: 1 hour  
**Prerequisites**: Day 15 (Docker Basics)

## Learning Objectives

By the end of this lesson, you will:
- Write Dockerfiles to create custom images
- Understand Docker build process and layers
- Use multi-stage builds for optimization
- Apply best practices for efficient images
- Build images for data science applications
- Manage image tags and versions

## Concepts

### What is a Dockerfile?

A Dockerfile is a text file containing instructions to build a Docker image automatically. It defines:
- Base image to start from
- Dependencies to install
- Files to copy
- Commands to run
- Default execution behavior

### Dockerfile Instructions

**FROM** - Base image
```dockerfile
FROM python:3.9-slim
FROM ubuntu:20.04
FROM node:16-alpine
```

**RUN** - Execute commands during build
```dockerfile
RUN apt-get update && apt-get install -y curl
RUN pip install pandas numpy
```

**COPY** - Copy files from host to image
```dockerfile
COPY app.py /app/
COPY requirements.txt .
COPY . /workspace
```

**WORKDIR** - Set working directory
```dockerfile
WORKDIR /app
WORKDIR /workspace
```

**ENV** - Set environment variables
```dockerfile
ENV PYTHONPATH=/app
ENV NODE_ENV=production
```

**EXPOSE** - Document port usage
```dockerfile
EXPOSE 8080
EXPOSE 5000 3000
```

**CMD** - Default command when container starts
```dockerfile
CMD ["python", "app.py"]
CMD ["npm", "start"]
```

**ENTRYPOINT** - Fixed entry point
```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]  # Default argument
```

## Basic Dockerfile Examples

### Simple Python Application
```dockerfile
# Use official Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first (for layer caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
```

### Data Science Environment
```dockerfile
FROM python:3.9

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Install Python packages
RUN pip install \
    pandas \
    numpy \
    matplotlib \
    jupyter \
    scikit-learn

# Copy notebooks and data
COPY notebooks/ ./notebooks/
COPY data/ ./data/

# Expose Jupyter port
EXPOSE 8888

# Start Jupyter
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root"]
```

### Web API
```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy source code
COPY src/ ./src/

# Set environment
ENV FLASK_APP=src/app.py
ENV FLASK_ENV=production

EXPOSE 5000

CMD ["flask", "run", "--host=0.0.0.0"]
```

## Building Images

### Build Command
```bash
# Build image with tag
docker build -t myapp:latest .

# Build with specific tag
docker build -t myapp:v1.0.0 .

# Build from different directory
docker build -t myapp -f /path/to/Dockerfile /path/to/context

# Build with build arguments
docker build --build-arg VERSION=1.0 -t myapp .
```

### Build Context
```bash
# Current directory is build context
docker build -t myapp .

# Specific directory as context
docker build -t myapp /path/to/project

# Use .dockerignore to exclude files
echo "*.log" > .dockerignore
echo "node_modules/" >> .dockerignore
```

## Layer Optimization

### Understanding Layers
Each Dockerfile instruction creates a new layer:
```dockerfile
FROM python:3.9        # Layer 1
RUN pip install pandas # Layer 2
COPY app.py .          # Layer 3
CMD ["python", "app.py"] # Layer 4
```

### Optimization Strategies

**1. Order Instructions by Change Frequency**
```dockerfile
# Good: Dependencies change less than code
FROM python:3.9
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# Bad: Code changes invalidate dependency layer
FROM python:3.9
COPY . .
RUN pip install -r requirements.txt
```

**2. Combine RUN Commands**
```dockerfile
# Good: Single layer
RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

# Bad: Multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
```

**3. Use .dockerignore**
```dockerignore
# Exclude unnecessary files
.git
.gitignore
README.md
Dockerfile
.dockerignore
node_modules
*.log
.pytest_cache
__pycache__
```

## Multi-stage Builds

Build smaller production images by separating build and runtime:

```dockerfile
# Build stage
FROM python:3.9 AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Production stage
FROM python:3.9-slim

# Copy only installed packages
COPY --from=builder /root/.local /root/.local

WORKDIR /app
COPY . .

# Update PATH
ENV PATH=/root/.local/bin:$PATH

CMD ["python", "app.py"]
```

### Complex Multi-stage Example
```dockerfile
# Development dependencies
FROM node:16 AS development
WORKDIR /app
COPY package*.json ./
RUN npm install

# Build stage
FROM development AS build
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine AS production
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Data Science Dockerfiles

### Jupyter Environment
```dockerfile
FROM jupyter/scipy-notebook:latest

USER root

# Install additional system packages
RUN apt-get update && apt-get install -y \
    graphviz \
    && rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Install Python packages
RUN pip install \
    seaborn \
    plotly \
    scikit-learn \
    xgboost

# Copy notebooks
COPY --chown=$NB_UID:$NB_GID notebooks/ ./work/

# Set default working directory
WORKDIR /home/jovyan/work
```

### ML Training Environment
```dockerfile
FROM tensorflow/tensorflow:2.8.0-gpu

WORKDIR /workspace

# Install additional packages
RUN pip install \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    mlflow

# Copy training scripts
COPY src/ ./src/
COPY data/ ./data/
COPY models/ ./models/

# Set environment variables
ENV PYTHONPATH=/workspace/src
ENV MLFLOW_TRACKING_URI=http://localhost:5000

# Default command
CMD ["python", "src/train.py"]
```

### Data Processing Pipeline
```dockerfile
FROM python:3.9-slim

# Install system dependencies for data processing
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /pipeline

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy pipeline code
COPY src/ ./src/
COPY config/ ./config/

# Create directories for data
RUN mkdir -p data/raw data/processed data/output

# Set environment
ENV PYTHONPATH=/pipeline/src

# Default command
CMD ["python", "src/main.py"]
```

## Build Arguments and Environment Variables

### Build Arguments
```dockerfile
FROM python:3.9

# Define build argument
ARG VERSION=latest
ARG ENVIRONMENT=development

# Use in RUN commands
RUN echo "Building version: $VERSION"

# Convert to environment variable
ENV APP_VERSION=$VERSION
ENV APP_ENV=$ENVIRONMENT

COPY . .
CMD ["python", "app.py"]
```

Build with arguments:
```bash
docker build --build-arg VERSION=1.2.0 --build-arg ENVIRONMENT=production -t myapp .
```

### Environment Variables
```dockerfile
FROM python:3.9

# Set environment variables
ENV PYTHONPATH=/app
ENV FLASK_ENV=production
ENV DATABASE_URL=sqlite:///app.db

WORKDIR /app
COPY . .

CMD ["python", "app.py"]
```

## Best Practices

### Security
```dockerfile
# Use specific image versions
FROM python:3.9.7-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set ownership
COPY --chown=appuser:appuser . /app

# Switch to non-root user
USER appuser

WORKDIR /app
CMD ["python", "app.py"]
```

### Efficiency
```dockerfile
FROM python:3.9-slim

# Install system packages in single layer
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Use pip cache mount (BuildKit)
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# Use specific COPY commands
COPY requirements.txt .
COPY src/ ./src/
COPY config/ ./config/

CMD ["python", "src/app.py"]
```

### Maintainability
```dockerfile
FROM python:3.9-slim

# Use labels for metadata
LABEL maintainer="team@company.com"
LABEL version="1.0.0"
LABEL description="Customer analytics API"

# Document exposed ports
EXPOSE 5000

# Use health checks
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

WORKDIR /app
COPY . .

CMD ["python", "app.py"]
```

## Common Patterns

### Python Web Application
```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app
USER app

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
```

### Node.js Application
```dockerfile
FROM node:16-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

EXPOSE 3000

CMD ["npm", "start"]
```

## Image Tagging Strategy

### Semantic Versioning
```bash
# Build with multiple tags
docker build -t myapp:1.2.3 -t myapp:1.2 -t myapp:1 -t myapp:latest .

# Environment-specific tags
docker build -t myapp:dev .
docker build -t myapp:staging .
docker build -t myapp:prod .

# Feature tags
docker build -t myapp:feature-auth .
```

### Automated Tagging
```bash
# Use Git commit hash
TAG=$(git rev-parse --short HEAD)
docker build -t myapp:$TAG .

# Use timestamp
TAG=$(date +%Y%m%d-%H%M%S)
docker build -t myapp:$TAG .
```

## Debugging Dockerfiles

### Build with Debug
```bash
# See build steps
docker build --progress=plain -t myapp .

# Build specific stage
docker build --target=build -t myapp-build .

# Interactive debugging
docker run -it myapp-build bash
```

### Common Issues
```dockerfile
# Fix: Use absolute paths
WORKDIR /app
COPY . .  # Not COPY . ./

# Fix: Install dependencies first
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .  # Copy code after dependencies

# Fix: Use proper user permissions
RUN chown -R appuser:appuser /app
USER appuser
```

## Next Steps

Tomorrow (Day 17) we'll learn Docker Compose to orchestrate multi-container applications, building on these custom image creation skills.

## Key Takeaways

- Dockerfiles automate image creation with repeatable instructions
- Layer optimization improves build speed and image size
- Multi-stage builds separate build and runtime environments
- Build arguments and environment variables provide flexibility
- Security practices include non-root users and specific versions
- Proper tagging enables version management and deployment strategies
