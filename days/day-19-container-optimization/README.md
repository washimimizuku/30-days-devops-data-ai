# Day 19: Container Optimization and Best Practices

**Duration**: 1 hour  
**Prerequisites**: Days 15-18 (Complete Docker sequence)

## Learning Objectives

By the end of this lesson, you will:
- Optimize Docker images for size and performance
- Implement security best practices for containers
- Configure resource limits and monitoring
- Use multi-stage builds effectively
- Apply production-ready container patterns
- Debug and troubleshoot container issues

## Image Optimization

### Size Optimization

**Use Minimal Base Images**
```dockerfile
# Bad: Large base image
FROM ubuntu:20.04

# Good: Minimal base image
FROM python:3.9-slim
FROM alpine:3.16
FROM scratch  # For static binaries
```

**Multi-stage Builds**
```dockerfile
# Build stage
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

**Layer Optimization**
```dockerfile
# Bad: Multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN rm -rf /var/lib/apt/lists/*

# Good: Single layer
RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*
```

### Build Cache Optimization

**Order Instructions by Change Frequency**
```dockerfile
FROM python:3.9-slim

# Install system dependencies (changes rarely)
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first (changes less than code)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy code last (changes frequently)
COPY . .

CMD ["python", "app.py"]
```

**Use .dockerignore**
```dockerignore
.git
.gitignore
README.md
Dockerfile
.dockerignore
node_modules
*.log
.pytest_cache
__pycache__
.coverage
```

### Advanced Optimization Techniques

**Distroless Images**
```dockerfile
# Build stage
FROM python:3.9 AS builder
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Production stage
FROM gcr.io/distroless/python3
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["app.py"]
```

**Scratch Images for Go**
```dockerfile
# Build stage
FROM golang:1.19 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# Production stage
FROM scratch
COPY --from=builder /app/main /main
EXPOSE 8080
CMD ["/main"]
```

## Security Best Practices

### User Security

**Non-root User**
```dockerfile
FROM python:3.9-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Install dependencies as root
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app and change ownership
COPY --chown=appuser:appuser . /app
WORKDIR /app

# Switch to non-root user
USER appuser

CMD ["python", "app.py"]
```

**Specific User ID**
```dockerfile
# Use specific UID/GID for consistency
RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -s /bin/sh appuser

USER 1001:1001
```

### Image Security

**Scan for Vulnerabilities**
```bash
# Docker Scout (built-in)
docker scout cves myapp:latest

# Trivy scanner
trivy image myapp:latest

# Snyk scanner
snyk container test myapp:latest
```

**Use Specific Versions**
```dockerfile
# Bad: Latest versions
FROM python:latest
RUN pip install flask

# Good: Specific versions
FROM python:3.9.16-slim
RUN pip install flask==2.3.2
```

**Secrets Management**
```dockerfile
# Bad: Secrets in image
ENV API_KEY=secret123

# Good: Use secrets at runtime
ENV API_KEY_FILE=/run/secrets/api_key
```

### Runtime Security

**Read-only Filesystem**
```bash
docker run --read-only --tmpfs /tmp myapp:latest
```

**Drop Capabilities**
```bash
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE myapp:latest
```

**Security Options**
```bash
docker run \
  --security-opt no-new-privileges \
  --security-opt seccomp=seccomp.json \
  myapp:latest
```

## Resource Management

### Memory and CPU Limits

**Docker Run Limits**
```bash
# Memory limit
docker run -m 512m myapp:latest

# CPU limit
docker run --cpus="1.5" myapp:latest

# Combined limits
docker run -m 1g --cpus="2" myapp:latest
```

**Docker Compose Limits**
```yaml
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
```

### Health Checks

**Dockerfile Health Check**
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1
```

**Compose Health Check**
```yaml
services:
  web:
    image: myapp:latest
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

**Custom Health Check Script**
```bash
#!/bin/bash
# healthcheck.sh

# Check application endpoint
if curl -f http://localhost:8000/health > /dev/null 2>&1; then
    echo "Application healthy"
    exit 0
else
    echo "Application unhealthy"
    exit 1
fi
```

## Performance Optimization

### Application Performance

**JVM Optimization**
```dockerfile
FROM openjdk:11-jre-slim

# Optimize JVM for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:+UseG1GC \
               -XX:+UseStringDeduplication"

COPY app.jar .
CMD ["java", "-jar", "app.jar"]
```

**Python Optimization**
```dockerfile
FROM python:3.9-slim

# Optimize Python for containers
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Use faster JSON library
RUN pip install ujson

COPY . .
CMD ["python", "app.py"]
```

**Node.js Optimization**
```dockerfile
FROM node:16-alpine

# Optimize Node.js for production
ENV NODE_ENV=production \
    NODE_OPTIONS="--max-old-space-size=1024"

# Use npm ci for faster, reliable builds
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

COPY . .
CMD ["node", "server.js"]
```

### Startup Optimization

**Init System**
```dockerfile
FROM alpine:3.16

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

COPY app /app
ENTRYPOINT ["dumb-init", "--"]
CMD ["/app"]
```

**Parallel Processing**
```dockerfile
# Install dependencies in parallel
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    package1 package2 package3 && \
    rm -rf /var/lib/apt/lists/*
```

## Monitoring and Observability

### Logging Best Practices

**Structured Logging**
```python
import json
import logging

# Configure structured logging
logging.basicConfig(
    format='%(message)s',
    level=logging.INFO
)

logger = logging.getLogger(__name__)

def log_event(event, **kwargs):
    log_data = {
        'timestamp': datetime.utcnow().isoformat(),
        'event': event,
        **kwargs
    }
    logger.info(json.dumps(log_data))
```

**Log to stdout/stderr**
```dockerfile
# Ensure logs go to stdout/stderr
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
```

### Metrics and Monitoring

**Prometheus Metrics**
```python
from prometheus_client import Counter, Histogram, generate_latest

REQUEST_COUNT = Counter('requests_total', 'Total requests')
REQUEST_DURATION = Histogram('request_duration_seconds', 'Request duration')

@app.route('/metrics')
def metrics():
    return generate_latest()
```

**Health Check Endpoint**
```python
@app.route('/health')
def health():
    # Check database connection
    try:
        db.execute('SELECT 1')
        db_status = 'healthy'
    except:
        db_status = 'unhealthy'
    
    return {
        'status': 'healthy' if db_status == 'healthy' else 'unhealthy',
        'database': db_status,
        'timestamp': datetime.utcnow().isoformat()
    }
```

## Production Patterns

### Graceful Shutdown

**Signal Handling**
```python
import signal
import sys

def signal_handler(sig, frame):
    print('Gracefully shutting down...')
    # Close database connections
    # Finish processing requests
    sys.exit(0)

signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)
```

**Dockerfile Signal Handling**
```dockerfile
FROM python:3.9-slim

# Install dumb-init for proper signal handling
RUN apt-get update && apt-get install -y dumb-init

COPY app.py .

ENTRYPOINT ["dumb-init", "--"]
CMD ["python", "app.py"]
```

### Configuration Management

**Environment-based Configuration**
```python
import os

class Config:
    DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///app.db')
    REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379')
    DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
```

**Configuration Validation**
```python
def validate_config():
    required_vars = ['DATABASE_URL', 'SECRET_KEY']
    missing = [var for var in required_vars if not os.getenv(var)]
    
    if missing:
        raise ValueError(f"Missing required environment variables: {missing}")
```

### Deployment Strategies

**Rolling Updates**
```yaml
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
      rollback_config:
        parallelism: 1
        delay: 5s
```

**Blue-Green Deployment**
```bash
#!/bin/bash
# blue-green-deploy.sh

NEW_VERSION=$1
CURRENT_COLOR=$(docker service inspect --format '{{.Spec.Labels.color}}' myapp)

if [ "$CURRENT_COLOR" = "blue" ]; then
    NEW_COLOR="green"
else
    NEW_COLOR="blue"
fi

# Deploy new version
docker service create \
    --name myapp-$NEW_COLOR \
    --label color=$NEW_COLOR \
    myapp:$NEW_VERSION

# Health check new deployment
sleep 30

# Switch traffic
docker service update --label-add active=true myapp-$NEW_COLOR
docker service update --label-rm active myapp-$CURRENT_COLOR

# Remove old deployment
docker service rm myapp-$CURRENT_COLOR
```

## Debugging and Troubleshooting

### Container Debugging

**Debug Running Container**
```bash
# Execute shell in running container
docker exec -it container-name bash

# Check processes
docker exec container-name ps aux

# Check resource usage
docker stats container-name

# View logs
docker logs -f container-name
```

**Debug Failed Container**
```bash
# Run with different entrypoint
docker run -it --entrypoint bash myapp:latest

# Check exit code
docker ps -a
docker inspect container-name | grep ExitCode
```

### Performance Debugging

**Memory Analysis**
```bash
# Memory usage breakdown
docker exec container-name cat /proc/meminfo

# Process memory usage
docker exec container-name ps -o pid,ppid,cmd,%mem,%cpu --sort=-%mem
```

**Network Debugging**
```bash
# Test connectivity
docker exec container-name ping target-host

# Check DNS resolution
docker exec container-name nslookup service-name

# Network statistics
docker exec container-name netstat -i
```

### Common Issues and Solutions

**Out of Memory**
```bash
# Check memory limits
docker inspect container-name | grep -i memory

# Increase memory limit
docker run -m 2g myapp:latest

# Monitor memory usage
docker stats --no-stream container-name
```

**Slow Startup**
```dockerfile
# Optimize startup time
FROM python:3.9-slim

# Pre-compile Python files
ENV PYTHONOPTIMIZE=1

# Use faster package installer
RUN pip install --no-cache-dir -r requirements.txt

# Warm up application
RUN python -c "import app; app.init()"
```

## Security Scanning and Compliance

### Automated Security Scanning

**CI/CD Integration**
```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build image
        run: docker build -t myapp:test .
      
      - name: Scan image
        run: |
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            aquasec/trivy image myapp:test
```

**Security Policies**
```yaml
# security-policy.yml
apiVersion: v1
kind: SecurityPolicy
spec:
  allowPrivilegeEscalation: false
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
```

## Next Steps

Tomorrow (Day 20) we'll learn production deployment strategies, and Day 21 will be the final containerization project integrating all concepts.

## Key Takeaways

- Image optimization reduces deployment time and resource usage
- Security practices protect against vulnerabilities and attacks
- Resource limits prevent containers from consuming excessive resources
- Health checks enable reliable service orchestration
- Monitoring and logging provide operational visibility
- Graceful shutdown ensures data integrity
- Automated security scanning catches vulnerabilities early
- Performance optimization improves user experience and reduces costs
