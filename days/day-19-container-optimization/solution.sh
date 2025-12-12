#!/bin/bash

# Day 19: Container Optimization - Solution Guide
# Reference solutions for production-ready container optimization

echo "📚 Day 19: Container Optimization - Solution Guide"
echo "=================================================="

echo ""
echo "🎯 Solution 1: Image Size Optimization"
echo "======================================"

cat << 'EOF'
# Multi-stage Build Pattern
FROM python:3.9 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y gcc g++

# Install Python packages
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Production stage
FROM python:3.9-slim
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

COPY . .
CMD ["python", "app.py"]

# Size Optimization Techniques:
# 1. Use slim/alpine base images
# 2. Multi-stage builds
# 3. Combine RUN commands
# 4. Remove package managers after use
# 5. Use .dockerignore

# Example .dockerignore:
.git
.gitignore
README.md
Dockerfile*
node_modules
*.log
__pycache__
.pytest_cache
EOF

echo ""
echo "🎯 Solution 2: Security Hardening"
echo "================================="

cat << 'EOF'
# Security-Hardened Dockerfile
FROM python:3.9.16-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.9.16-slim

# Create specific user with UID/GID
RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -s /bin/sh -m appuser

# Copy packages and app
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=1001:1001 . /app

WORKDIR /app
USER 1001:1001

# Environment variables
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

EXPOSE 8000
CMD ["python", "app.py"]

# Security Best Practices:
# 1. Use specific image versions
# 2. Run as non-root user
# 3. Use specific UID/GID
# 4. Remove unnecessary packages
# 5. Use read-only filesystem when possible
# 6. Implement health checks
# 7. Scan for vulnerabilities
EOF

echo ""
echo "🎯 Solution 3: Resource Management"
echo "================================="

cat << 'EOF'
# Docker Run with Resource Limits
docker run -d \
  --name myapp \
  --memory=1g \
  --cpus="1.5" \
  --restart=unless-stopped \
  --read-only \
  --tmpfs /tmp \
  myapp:latest

# Docker Compose Resource Limits
version: '3.8'

services:
  web:
    image: myapp:latest
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3

# Kubernetes Resource Limits
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: myapp
    image: myapp:latest
    resources:
      limits:
        memory: "1Gi"
        cpu: "1000m"
      requests:
        memory: "512Mi"
        cpu: "500m"

# Memory Optimization for JVM
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:+UseG1GC"

# Python Memory Optimization
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    MALLOC_ARENA_MAX=2
EOF

echo ""
echo "🎯 Solution 4: Health Checks and Monitoring"
echo "==========================================="

cat << 'EOF'
# Dockerfile Health Check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Custom Health Check Script
#!/bin/bash
# healthcheck.sh

# Check application endpoint
if curl -f http://localhost:8000/health >/dev/null 2>&1; then
    exit 0
else
    exit 1
fi

# Python Health Check Endpoint
from flask import Flask, jsonify
import psycopg2

@app.route('/health')
def health():
    checks = {
        'database': check_database(),
        'redis': check_redis(),
        'disk_space': check_disk_space()
    }
    
    status = 'healthy' if all(checks.values()) else 'unhealthy'
    code = 200 if status == 'healthy' else 503
    
    return jsonify({
        'status': status,
        'checks': checks,
        'timestamp': datetime.utcnow().isoformat()
    }), code

# Compose Health Check
version: '3.8'

services:
  web:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
EOF

echo ""
echo "🎯 Solution 5: Performance Optimization"
echo "======================================="

cat << 'EOF'
# Application Performance Optimization

# Python Performance
FROM python:3.9-slim

# Optimize Python runtime
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONOPTIMIZE=1 \
    PIP_NO_CACHE_DIR=1

# Use faster JSON library
RUN pip install ujson

# Pre-compile Python files
RUN python -m compileall .

# Node.js Performance
FROM node:16-alpine

ENV NODE_ENV=production \
    NODE_OPTIONS="--max-old-space-size=1024"

# Use npm ci for faster installs
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# JVM Performance
FROM openjdk:11-jre-slim

ENV JAVA_OPTS="-server \
               -XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:+UseG1GC \
               -XX:+UseStringDeduplication \
               -XX:+OptimizeStringConcat"

# Startup Optimization
FROM alpine:3.16

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

COPY app /app
ENTRYPOINT ["dumb-init", "--"]
CMD ["/app"]

# Build Cache Optimization
# Order by change frequency (least to most)
COPY requirements.txt .          # Changes rarely
RUN pip install -r requirements.txt
COPY config/ ./config/           # Changes sometimes
COPY . .                         # Changes frequently
EOF

echo ""
echo "🎯 Solution 6: Logging and Observability"
echo "========================================"

cat << 'EOF'
# Structured Logging
import json
import logging
from datetime import datetime

# Configure JSON logging
class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        return json.dumps(log_entry)

# Application logging
logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
handler.setFormatter(JSONFormatter())
logger.addHandler(handler)
logger.setLevel(logging.INFO)

# Dockerfile logging configuration
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Compose logging configuration
version: '3.8'

services:
  web:
    image: myapp:latest
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "service=web,environment=production"

# Prometheus Metrics
from prometheus_client import Counter, Histogram, generate_latest

REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

@app.route('/metrics')
def metrics():
    return generate_latest()
EOF

echo ""
echo "🎯 Solution 7: Security Scanning and Compliance"
echo "==============================================="

cat << 'EOF'
# Vulnerability Scanning

# Trivy Scanner
trivy image myapp:latest

# Docker Scout (built-in)
docker scout cves myapp:latest

# Snyk Scanner
snyk container test myapp:latest

# CI/CD Security Pipeline
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload results
        uses: github/codeql-action/upload-sarif@v1
        with:
          sarif_file: 'trivy-results.sarif'

# Security Policy as Code
apiVersion: v1
kind: SecurityPolicy
metadata:
  name: restricted-policy
spec:
  privileged: false
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
  capabilities:
    drop:
      - ALL
    add:
      - NET_BIND_SERVICE

# Runtime Security
docker run -d \
  --security-opt no-new-privileges \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --read-only \
  --tmpfs /tmp \
  --user 1000:1000 \
  myapp:latest
EOF

echo ""
echo "🎯 Solution 8: Production Deployment Patterns"
echo "============================================="

cat << 'EOF'
# Graceful Shutdown
import signal
import sys
import time

class GracefulShutdown:
    def __init__(self):
        self.shutdown = False
        signal.signal(signal.SIGTERM, self.exit_gracefully)
        signal.signal(signal.SIGINT, self.exit_gracefully)
    
    def exit_gracefully(self, signum, frame):
        print("Received shutdown signal, gracefully shutting down...")
        self.shutdown = True
        # Close database connections
        # Finish processing requests
        # Clean up resources
        sys.exit(0)

# Configuration Management
import os
from dataclasses import dataclass

@dataclass
class Config:
    database_url: str = os.getenv('DATABASE_URL', 'sqlite:///app.db')
    redis_url: str = os.getenv('REDIS_URL', 'redis://localhost:6379')
    debug: bool = os.getenv('DEBUG', 'False').lower() == 'true'
    log_level: str = os.getenv('LOG_LEVEL', 'INFO')
    
    def __post_init__(self):
        # Validate required configuration
        if not self.database_url:
            raise ValueError("DATABASE_URL is required")

# Rolling Deployment
version: '3.8'

services:
  web:
    image: myapp:${VERSION}
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
        monitor: 60s
      rollback_config:
        parallelism: 1
        delay: 5s

# Blue-Green Deployment Script
#!/bin/bash

NEW_VERSION=$1
CURRENT=$(docker service ls --filter name=myapp --format "{{.Name}}")

if [[ $CURRENT == *"blue"* ]]; then
    NEW_COLOR="green"
    OLD_COLOR="blue"
else
    NEW_COLOR="blue"
    OLD_COLOR="green"
fi

# Deploy new version
docker service create --name myapp-$NEW_COLOR myapp:$NEW_VERSION

# Health check
sleep 30
if curl -f http://myapp-$NEW_COLOR/health; then
    # Switch traffic
    docker service update --label-add active=true myapp-$NEW_COLOR
    docker service rm myapp-$OLD_COLOR
    echo "Deployment successful"
else
    docker service rm myapp-$NEW_COLOR
    echo "Deployment failed"
    exit 1
fi
EOF

echo ""
echo "🎯 Solution 9: Debugging and Troubleshooting"
echo "============================================"

cat << 'EOF'
# Container Debugging Commands

# Debug running container
docker exec -it container-name bash
docker exec container-name ps aux
docker exec container-name netstat -tulpn

# Debug failed container
docker run -it --entrypoint bash myapp:latest
docker logs --details container-name
docker inspect container-name

# Performance debugging
docker stats container-name
docker exec container-name top
docker exec container-name free -h
docker exec container-name df -h

# Network debugging
docker exec container-name ping target-host
docker exec container-name nslookup service-name
docker exec container-name curl -v http://service:port/health

# Memory debugging
docker exec container-name cat /proc/meminfo
docker exec container-name ps -o pid,ppid,cmd,%mem --sort=-%mem

# Debug startup issues
docker run --rm myapp:latest python -c "import app; print('Import successful')"
docker run --rm -e DEBUG=true myapp:latest

# Common Issues and Solutions

# Issue: Container exits immediately
# Solution: Check entrypoint and CMD
docker run -it --entrypoint sh myapp:latest

# Issue: Permission denied
# Solution: Check user and file permissions
docker exec container-name ls -la /app
docker exec container-name id

# Issue: Out of memory
# Solution: Increase memory limit or optimize application
docker run -m 2g myapp:latest
docker stats --no-stream container-name

# Issue: Slow startup
# Solution: Optimize Dockerfile and dependencies
FROM python:3.9-slim
ENV PYTHONOPTIMIZE=1
RUN python -m compileall .
EOF

echo ""
echo "🎯 Solution 10: Complete Production Dockerfile"
echo "=============================================="

cat << 'EOF'
# Production-Ready Dockerfile Template
FROM python:3.9.16-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.9.16-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user
RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -s /bin/sh -m appuser

# Copy installed packages
COPY --from=builder /root/.local /home/appuser/.local

# Set working directory
WORKDIR /app

# Copy application with proper ownership
COPY --chown=1001:1001 . .

# Set environment variables
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONOPTIMIZE=1

# Switch to non-root user
USER 1001:1001

# Add labels for metadata
LABEL maintainer="team@company.com" \
      version="1.0.0" \
      description="Production-ready Python application"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health', timeout=5)" || exit 1

# Expose port
EXPOSE 8000

# Run application
CMD ["python", "app.py"]
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key container optimization concepts mastered:"
echo "✅ Image size optimization with multi-stage builds"
echo "✅ Security hardening with non-root users"
echo "✅ Resource management and limits"
echo "✅ Health checks and monitoring"
echo "✅ Performance optimization techniques"
echo "✅ Production deployment patterns"
echo "✅ Security scanning and compliance"
echo "✅ Debugging and troubleshooting methods"
echo ""
echo "💡 Remember:"
echo "   - Always use specific image versions in production"
echo "   - Run containers as non-root users"
echo "   - Implement proper health checks"
echo "   - Set appropriate resource limits"
echo "   - Use multi-stage builds for smaller images"
echo "   - Scan images for vulnerabilities regularly"
echo "   - Monitor container performance and logs"
