#!/bin/bash

# Day 16: Dockerfiles - Solution Guide
# Reference solutions for creating custom Docker images

echo "📚 Day 16: Dockerfiles - Solution Guide"
echo "======================================="

echo ""
echo "🎯 Solution 1: Basic Dockerfile Structure"
echo "========================================="

cat << 'EOF'
# Basic Python Application Dockerfile
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy requirements first (better caching)
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run application
CMD ["python", "app.py"]

# Build command:
# docker build -t myapp:latest .
EOF

echo ""
echo "🎯 Solution 2: Optimized Dockerfile"
echo "=================================="

cat << 'EOF'
FROM python:3.9-slim

# Install system dependencies in single layer
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy and install dependencies first
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application with proper ownership
COPY --chown=appuser:appuser . .

# Set environment variables
ENV PYTHONPATH=/app
ENV FLASK_ENV=production

# Switch to non-root user
USER appuser

# Add metadata
LABEL maintainer="team@company.com"
LABEL version="1.0.0"

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]
EOF

echo ""
echo "🎯 Solution 3: Multi-stage Build"
echo "==============================="

cat << 'EOF'
# Build stage
FROM python:3.9 AS builder

WORKDIR /app

# Install build dependencies
RUN pip install --user build wheel

# Copy source and build
COPY . .
RUN python -m build

# Production stage
FROM python:3.9-slim AS production

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy built packages from builder
COPY --from=builder /root/.local /root/.local

# Create app user
RUN useradd --create-home --shell /bin/bash app
USER app

WORKDIR /app
COPY --chown=app:app . .

# Update PATH
ENV PATH=/root/.local/bin:$PATH

EXPOSE 8000
CMD ["python", "app.py"]

# Build specific stage:
# docker build --target=builder -t myapp-build .
EOF

echo ""
echo "🎯 Solution 4: Data Science Dockerfile"
echo "====================================="

cat << 'EOF'
FROM jupyter/scipy-notebook:latest

USER root

# Install system packages
RUN apt-get update && apt-get install -y \
    graphviz \
    git \
    && rm -rf /var/lib/apt/lists/*

USER $NB_UID

# Install additional Python packages
RUN pip install --no-cache-dir \
    seaborn \
    plotly \
    scikit-learn \
    xgboost \
    mlflow \
    dvc

# Copy notebooks and data
COPY --chown=$NB_UID:$NB_GID notebooks/ ./work/notebooks/
COPY --chown=$NB_UID:$NB_GID data/ ./work/data/

# Set working directory
WORKDIR /home/jovyan/work

# Start Jupyter Lab by default
CMD ["start-notebook.sh", "--NotebookApp.default_url=/lab"]
EOF

echo ""
echo "🎯 Solution 5: Web API Dockerfile"
echo "================================"

cat << 'EOF'
FROM node:16-alpine

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source code
COPY --chown=nodejs:nodejs . .

# Switch to app user
USER nodejs

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD node healthcheck.js

CMD ["node", "server.js"]
EOF

echo ""
echo "🎯 Solution 6: Database Dockerfile"
echo "================================="

cat << 'EOF'
FROM postgres:13

# Install additional extensions
RUN apt-get update && apt-get install -y \
    postgresql-13-postgis-3 \
    postgresql-13-postgis-3-scripts \
    && rm -rf /var/lib/apt/lists/*

# Copy initialization scripts
COPY init-scripts/ /docker-entrypoint-initdb.d/

# Copy custom configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf

# Set environment variables
ENV POSTGRES_DB=analytics
ENV POSTGRES_USER=analyst
ENV POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password

# Create data directory
VOLUME ["/var/lib/postgresql/data"]

EXPOSE 5432

# Use custom entrypoint if needed
# COPY entrypoint.sh /usr/local/bin/
# ENTRYPOINT ["entrypoint.sh"]
EOF

echo ""
echo "🎯 Solution 7: Build Arguments and Variables"
echo "==========================================="

cat << 'EOF'
FROM python:3.9-slim

# Define build arguments
ARG VERSION=latest
ARG ENVIRONMENT=production
ARG BUILD_DATE
ARG VCS_REF

# Set environment variables from build args
ENV APP_VERSION=$VERSION
ENV APP_ENV=$ENVIRONMENT

# Add build metadata
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.version=$VERSION

WORKDIR /app

# Use build args in RUN commands
RUN echo "Building version: $VERSION for $ENVIRONMENT"

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Environment-specific configuration
RUN if [ "$ENVIRONMENT" = "development" ] ; then \
        pip install pytest flake8 ; \
    fi

CMD ["python", "app.py"]

# Build with arguments:
# docker build \
#   --build-arg VERSION=1.2.0 \
#   --build-arg ENVIRONMENT=production \
#   --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
#   --build-arg VCS_REF=$(git rev-parse --short HEAD) \
#   -t myapp:1.2.0 .
EOF

echo ""
echo "🎯 Solution 8: .dockerignore File"
echo "================================"

cat << 'EOF'
# .dockerignore - Exclude files from build context

# Version control
.git
.gitignore
.gitattributes

# Documentation
README.md
CHANGELOG.md
docs/

# Build artifacts
Dockerfile*
.dockerignore
docker-compose*.yml

# Dependencies
node_modules/
venv/
env/
.venv/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.pytest_cache/
.coverage
.tox/

# Logs
*.log
logs/

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Environment files
.env
.env.local
.env.*.local

# Data files (usually)
data/
*.csv
*.json
*.db
EOF

echo ""
echo "🎯 Solution 9: Common Dockerfile Patterns"
echo "========================================"

cat << 'EOF'
# Pattern 1: Copy requirements first for better caching
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# Pattern 2: Combine RUN commands to reduce layers
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# Pattern 3: Use specific versions
FROM python:3.9.7-slim
RUN pip install pandas==1.5.3 numpy==1.24.3

# Pattern 4: Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Pattern 5: Set proper working directory
WORKDIR /app
COPY . .

# Pattern 6: Use ENTRYPOINT + CMD for flexibility
ENTRYPOINT ["python"]
CMD ["app.py"]

# Pattern 7: Add health checks
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8000/health || exit 1

# Pattern 8: Use build-time variables
ARG VERSION=latest
ENV APP_VERSION=$VERSION
EOF

echo ""
echo "🎯 Solution 10: Debugging Dockerfiles"
echo "===================================="

cat << 'EOF'
# Debug build process
docker build --progress=plain --no-cache -t myapp .

# Build and inspect intermediate stages
docker build --target=builder -t myapp-debug .
docker run -it myapp-debug bash

# Check image layers
docker history myapp:latest

# Inspect image configuration
docker inspect myapp:latest

# Run with debugging
docker run -it --entrypoint bash myapp:latest

# Check file permissions
docker run --rm myapp:latest ls -la /app

# Test specific commands
docker run --rm myapp:latest python --version
docker run --rm myapp:latest pip list

# Common debugging commands inside container:
# ls -la                    # Check files and permissions
# whoami                    # Check current user
# env                       # Check environment variables
# python -c "import sys; print(sys.path)"  # Check Python path
# curl localhost:8000/health  # Test application
EOF

echo ""
echo "🎯 Solution 11: Build Optimization"
echo "================================="

cat << 'EOF'
# Use smaller base images
FROM python:3.9-slim          # Instead of python:3.9
FROM node:16-alpine           # Instead of node:16
FROM nginx:alpine             # Instead of nginx

# Multi-stage builds for smaller final images
FROM node:16 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html

# Use .dockerignore to reduce build context
# See .dockerignore solution above

# Leverage build cache
# Copy requirements before source code
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .  # This layer only rebuilds when source changes

# Use BuildKit for advanced features
# export DOCKER_BUILDKIT=1
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# Minimize layers
RUN apt-get update && apt-get install -y \
    package1 package2 package3 \
    && rm -rf /var/lib/apt/lists/*
# Instead of separate RUN commands
EOF

echo ""
echo "🎯 Solution 12: Security Best Practices"
echo "======================================"

cat << 'EOF'
# Use specific image versions
FROM python:3.9.7-slim  # Not python:latest

# Run as non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Use read-only root filesystem when possible
docker run --read-only myapp:latest

# Scan images for vulnerabilities
docker scan myapp:latest

# Use minimal base images
FROM scratch  # For static binaries
FROM distroless/python3  # Google's distroless images

# Don't include secrets in images
# Use environment variables or mounted secrets
ENV DATABASE_URL_FILE=/run/secrets/db_url

# Set proper file permissions
COPY --chown=appuser:appuser . /app

# Use HTTPS for downloads
RUN curl -fsSL https://example.com/install.sh | sh

# Validate checksums when downloading
RUN curl -fsSL https://example.com/file.tar.gz -o file.tar.gz \
    && echo "expected_checksum file.tar.gz" | sha256sum -c -

# Remove package managers after use
RUN apt-get update && apt-get install -y package \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/*
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key Dockerfile concepts mastered:"
echo "✅ Basic Dockerfile structure and instructions"
echo "✅ Layer optimization and caching strategies"
echo "✅ Multi-stage builds for smaller images"
echo "✅ Security best practices with non-root users"
echo "✅ Build arguments and environment variables"
echo "✅ Health checks and metadata labels"
echo "✅ Debugging and troubleshooting techniques"
echo ""
echo "💡 Remember:"
echo "   - Order instructions by change frequency"
echo "   - Use specific image versions in production"
echo "   - Always run as non-root user when possible"
echo "   - Use .dockerignore to reduce build context"
echo "   - Combine RUN commands to minimize layers"
echo "   - Add health checks for production containers"
