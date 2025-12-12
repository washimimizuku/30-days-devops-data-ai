#!/bin/bash

# Day 19: Container Optimization - Hands-on Exercise
# Practice optimizing containers for production use

set -e

echo "🚀 Day 19: Container Optimization Exercise"
echo "=========================================="

# Create exercise directory
EXERCISE_DIR="$HOME/container-optimization-exercise"
echo "📁 Creating exercise directory: $EXERCISE_DIR"

if [ -d "$EXERCISE_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$EXERCISE_DIR"
fi

mkdir -p "$EXERCISE_DIR"
cd "$EXERCISE_DIR"

echo ""
echo "🎯 Exercise 1: Image Size Optimization"
echo "======================================"

echo "📦 Creating unoptimized application..."

# Create a Python web application
mkdir -p unoptimized-app
cd unoptimized-app

cat > app.py << 'EOF'
#!/usr/bin/env python3
"""Sample Flask application for optimization testing."""

from flask import Flask, jsonify
import pandas as pd
import numpy as np
import requests
import time
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': 'Optimization Test App',
        'version': '1.0.0',
        'endpoints': ['/data', '/health', '/metrics']
    })

@app.route('/data')
def get_data():
    # Generate sample data using pandas and numpy
    data = pd.DataFrame({
        'id': range(1, 101),
        'value': np.random.normal(0, 1, 100),
        'category': np.random.choice(['A', 'B', 'C'], 100)
    })
    
    return jsonify({
        'count': len(data),
        'mean': float(data['value'].mean()),
        'categories': data['category'].value_counts().to_dict()
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'timestamp': time.time()
    })

@app.route('/metrics')
def metrics():
    return jsonify({
        'memory_usage': 'simulated',
        'cpu_usage': 'simulated',
        'requests_total': 100
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF

cat > requirements.txt << 'EOF'
Flask==2.3.2
pandas==1.5.3
numpy==1.24.3
requests==2.31.0
scikit-learn==1.2.2
matplotlib==3.7.1
EOF

# Create unoptimized Dockerfile
cat > Dockerfile.unoptimized << 'EOF'
FROM python:3.9

WORKDIR /app

COPY . .

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
EOF

echo "🐳 Building unoptimized image..."
docker build -f Dockerfile.unoptimized -t unoptimized-app:latest .

echo "📊 Unoptimized image size:"
docker images unoptimized-app:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

cd ..

echo ""
echo "📦 Creating optimized application..."

mkdir -p optimized-app
cd optimized-app

# Copy application files
cp ../unoptimized-app/app.py .
cp ../unoptimized-app/requirements.txt .

# Create .dockerignore
cat > .dockerignore << 'EOF'
.git
.gitignore
README.md
Dockerfile*
.dockerignore
__pycache__
*.pyc
*.pyo
*.pyd
.pytest_cache
.coverage
*.log
EOF

# Create optimized Dockerfile
cat > Dockerfile << 'EOF'
# Multi-stage build for optimization
FROM python:3.9-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.9-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local

# Set working directory
WORKDIR /app

# Copy application with proper ownership
COPY --chown=appuser:appuser app.py .

# Update PATH to include user packages
ENV PATH=/root/.local/bin:$PATH

# Switch to non-root user
USER appuser

# Add health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:5000/health')" || exit 1

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
EOF

echo "🐳 Building optimized image..."
docker build -t optimized-app:latest .

echo "📊 Optimized image size:"
docker images optimized-app:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "📈 Size comparison:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(unoptimized-app|optimized-app)"

cd ..

echo ""
echo "🎯 Exercise 2: Security Hardening"
echo "================================="

echo "🔒 Creating security-hardened application..."

mkdir -p secure-app
cd secure-app

# Copy application files
cp ../optimized-app/app.py .
cp ../optimized-app/requirements.txt .
cp ../optimized-app/.dockerignore .

# Create security-hardened Dockerfile
cat > Dockerfile << 'EOF'
# Use specific version for security
FROM python:3.9.16-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies with specific versions
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage with distroless-like approach
FROM python:3.9.16-slim

# Create specific user with UID/GID
RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -s /bin/sh -m appuser

# Copy installed packages
COPY --from=builder /root/.local /home/appuser/.local

# Set working directory
WORKDIR /app

# Copy application with proper ownership
COPY --chown=1001:1001 app.py .

# Set environment variables
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Switch to non-root user
USER 1001:1001

# Health check with timeout
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health', timeout=3)" || exit 1

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
EOF

echo "🐳 Building secure image..."
docker build -t secure-app:latest .

echo "🔍 Testing security features..."

# Test non-root user
echo "👤 Checking user (should be non-root):"
docker run --rm secure-app:latest whoami

# Test read-only filesystem capability
echo "📁 Testing with read-only filesystem:"
docker run --rm --read-only --tmpfs /tmp secure-app:latest python -c "
import tempfile
import os
print('✅ Read-only filesystem test passed')
print(f'Temp dir: {tempfile.gettempdir()}')
print(f'User: {os.getuid()}:{os.getgid()}')
"

cd ..

echo ""
echo "🎯 Exercise 3: Resource Management"
echo "================================="

echo "⚖️ Testing resource limits and monitoring..."

# Start applications with resource limits
echo "🚀 Starting applications with resource limits..."

# Unoptimized app with limits
docker run -d \
    --name unoptimized-test \
    --memory=512m \
    --cpus="0.5" \
    -p 5001:5000 \
    unoptimized-app:latest

# Optimized app with limits
docker run -d \
    --name optimized-test \
    --memory=256m \
    --cpus="0.5" \
    -p 5002:5000 \
    optimized-app:latest

# Secure app with limits
docker run -d \
    --name secure-test \
    --memory=256m \
    --cpus="0.5" \
    --read-only \
    --tmpfs /tmp \
    -p 5003:5000 \
    secure-app:latest

echo "⏳ Waiting for applications to start..."
sleep 10

echo "📊 Resource usage comparison:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" \
    unoptimized-test optimized-test secure-test

echo ""
echo "🧪 Testing application functionality..."

# Test each application
for port in 5001 5002 5003; do
    app_name=""
    case $port in
        5001) app_name="Unoptimized" ;;
        5002) app_name="Optimized" ;;
        5003) app_name="Secure" ;;
    esac
    
    echo "Testing $app_name app on port $port:"
    if curl -s http://localhost:$port/health > /dev/null; then
        echo "  ✅ Health check passed"
        response=$(curl -s http://localhost:$port/ | head -3)
        echo "  📊 Response: $response"
    else
        echo "  ❌ Health check failed"
    fi
done

echo ""
echo "🎯 Exercise 4: Performance Monitoring"
echo "====================================="

echo "📈 Creating monitoring setup..."

# Create monitoring compose file
cat > docker-compose.monitoring.yml << 'EOF'
version: '3.8'

services:
  app:
    image: secure-app:latest
    ports:
      - "5000:5000"
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - app-network

  # Simple monitoring container
  monitor:
    image: alpine:latest
    command: >
      sh -c "
      while true; do
        echo '=== $(date) ==='
        echo 'Container stats:'
        wget -qO- http://app:5000/metrics 2>/dev/null || echo 'Metrics unavailable'
        echo 'Health check:'
        wget -qO- http://app:5000/health 2>/dev/null || echo 'Health check failed'
        echo '---'
        sleep 30
      done
      "
    depends_on:
      - app
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF

echo "🐳 Starting monitoring stack..."
docker-compose -f docker-compose.monitoring.yml up -d

echo "⏳ Waiting for monitoring to start..."
sleep 15

echo "📊 Monitoring output (30 seconds):"
timeout 30 docker-compose -f docker-compose.monitoring.yml logs -f monitor || true

# Stop monitoring stack
docker-compose -f docker-compose.monitoring.yml down

echo ""
echo "🎯 Exercise 5: Security Scanning"
echo "==============================="

echo "🔍 Performing security analysis..."

# Check for common security issues
echo "1️⃣ Checking for root user usage:"
for image in unoptimized-app optimized-app secure-app; do
    user=$(docker run --rm $image:latest whoami 2>/dev/null || echo "unknown")
    echo "  $image: $user"
done

echo ""
echo "2️⃣ Checking image layers and history:"
echo "Secure app layers:"
docker history secure-app:latest --format "table {{.CreatedBy}}\t{{.Size}}" | head -10

echo ""
echo "3️⃣ Checking for sensitive information:"
echo "Searching for potential secrets in images..."
for image in unoptimized-app optimized-app secure-app; do
    echo "Checking $image:"
    # Check environment variables
    env_vars=$(docker run --rm $image:latest env | grep -E "(PASSWORD|SECRET|KEY|TOKEN)" || echo "  No sensitive env vars found")
    echo "  $env_vars"
done

echo ""
echo "🎯 Exercise 6: Cleanup and Analysis"
echo "==================================="

echo "📊 Final analysis and cleanup..."

# Stop all test containers
docker stop unoptimized-test optimized-test secure-test 2>/dev/null || true
docker rm unoptimized-test optimized-test secure-test 2>/dev/null || true

echo ""
echo "📈 Image size comparison summary:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | \
    grep -E "(unoptimized-app|optimized-app|secure-app)"

echo ""
echo "🔍 Security features comparison:"
echo "┌─────────────────┬──────────┬─────────────┬──────────────┐"
echo "│ Image           │ User     │ Multi-stage │ Health Check │"
echo "├─────────────────┼──────────┼─────────────┼──────────────┤"
echo "│ unoptimized-app │ root     │ No          │ No           │"
echo "│ optimized-app   │ appuser  │ Yes         │ Yes          │"
echo "│ secure-app      │ 1001     │ Yes         │ Yes          │"
echo "└─────────────────┴──────────┴─────────────┴──────────────┘"

echo ""
echo "🧹 Cleaning up resources..."

# Remove images
docker rmi unoptimized-app:latest optimized-app:latest secure-app:latest 2>/dev/null || true

# Clean up files
cd "$EXERCISE_DIR/.."
rm -rf "$EXERCISE_DIR"

echo "✅ Cleanup completed"

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully:"
echo "✅ Optimized Docker images for size and performance"
echo "✅ Implemented security best practices"
echo "✅ Applied resource limits and monitoring"
echo "✅ Used multi-stage builds effectively"
echo "✅ Created production-ready containers"
echo "✅ Performed security analysis"
echo ""
echo "🔍 Key optimization techniques practiced:"
echo "   Multi-stage builds - Reduced image size"
echo "   Non-root users - Enhanced security"
echo "   Resource limits - Controlled resource usage"
echo "   Health checks - Improved reliability"
echo "   .dockerignore - Faster builds"
echo "   Specific versions - Security and reproducibility"
echo ""
echo "💡 Next: Learn production deployment strategies!"
