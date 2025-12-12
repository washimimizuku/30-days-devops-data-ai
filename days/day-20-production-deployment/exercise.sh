#!/bin/bash

# Day 20: Production Deployment - Hands-on Exercise
# Practice production deployment strategies and orchestration

set -e

echo "🚀 Day 20: Production Deployment Exercise"
echo "========================================="

# Create exercise directory
EXERCISE_DIR="$HOME/production-deployment-exercise"
echo "📁 Creating exercise directory: $EXERCISE_DIR"

if [ -d "$EXERCISE_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$EXERCISE_DIR"
fi

mkdir -p "$EXERCISE_DIR"
cd "$EXERCISE_DIR"

echo ""
echo "🎯 Exercise 1: Rolling Deployment"
echo "================================="

echo "📦 Creating production-ready application..."

# Create application
mkdir -p rolling-app
cd rolling-app

cat > app.py << 'EOF'
#!/usr/bin/env python3
"""Production-ready Flask application with versioning."""

from flask import Flask, jsonify
import os
import time
import socket

app = Flask(__name__)

VERSION = os.getenv('APP_VERSION', '1.0.0')
HOSTNAME = socket.gethostname()

@app.route('/')
def home():
    return jsonify({
        'message': 'Production Application',
        'version': VERSION,
        'hostname': HOSTNAME,
        'timestamp': time.time()
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'version': VERSION,
        'hostname': HOSTNAME
    })

@app.route('/ready')
def ready():
    # Simulate readiness check
    return jsonify({
        'status': 'ready',
        'version': VERSION,
        'hostname': HOSTNAME
    })

@app.route('/version')
def version():
    return jsonify({
        'version': VERSION,
        'hostname': HOSTNAME,
        'deployment_time': time.time()
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)
EOF

cat > requirements.txt << 'EOF'
Flask==2.3.2
gunicorn==20.1.0
EOF

# Create optimized Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim AS builder

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.9-slim

RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -s /bin/sh appuser

COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=1001:1001 app.py /app/

WORKDIR /app
USER 1001:1001

ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
EOF

# Build versions
echo "🐳 Building application versions..."
docker build -t rolling-app:v1.0.0 --build-arg APP_VERSION=1.0.0 .

# Create v2.0.0 with updated message
sed -i.bak 's/Production Application/Production Application v2/' app.py
docker build -t rolling-app:v2.0.0 --build-arg APP_VERSION=2.0.0 .

# Restore original
mv app.py.bak app.py

echo "✅ Application versions built"

# Create rolling deployment compose
cat > docker-compose.rolling.yml << 'EOF'
version: '3.8'

services:
  web:
    image: rolling-app:${VERSION:-v1.0.0}
    environment:
      - APP_VERSION=${VERSION:-v1.0.0}
    ports:
      - "8080-8085:8080"
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
        monitor: 30s
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 3
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - web
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF

# Create nginx configuration for load balancing
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server web:8080 max_fails=3 fail_timeout=30s;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            
            # Health check
            proxy_connect_timeout 5s;
            proxy_send_timeout 5s;
            proxy_read_timeout 5s;
        }
        
        location /nginx-health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

echo "🚀 Starting initial deployment (v1.0.0)..."
VERSION=v1.0.0 docker-compose -f docker-compose.rolling.yml up -d

echo "⏳ Waiting for deployment to be ready..."
sleep 15

# Test initial deployment
echo "🧪 Testing v1.0.0 deployment..."
for i in {1..5}; do
    response=$(curl -s http://localhost/version | head -3)
    echo "Request $i: $response"
    sleep 1
done

echo ""
echo "🔄 Performing rolling update to v2.0.0..."
VERSION=v2.0.0 docker-compose -f docker-compose.rolling.yml up -d

echo "⏳ Monitoring rolling update..."
for i in {1..20}; do
    echo "Check $i:"
    curl -s http://localhost/version | grep -E "(version|hostname)" || echo "Service unavailable"
    sleep 3
done

echo "✅ Rolling deployment completed"

# Stop rolling deployment
docker-compose -f docker-compose.rolling.yml down

cd ..

echo ""
echo "🎯 Exercise 2: Blue-Green Deployment"
echo "===================================="

echo "🔵🟢 Setting up blue-green deployment..."

mkdir -p blue-green-deployment
cd blue-green-deployment

# Copy application files
cp ../rolling-app/app.py .
cp ../rolling-app/requirements.txt .
cp ../rolling-app/Dockerfile .

# Create blue environment
cat > docker-compose.blue.yml << 'EOF'
version: '3.8'

services:
  web-blue:
    image: rolling-app:v1.0.0
    environment:
      - APP_VERSION=v1.0.0
      - ENVIRONMENT=blue
    networks:
      - blue-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 3

  nginx-blue:
    image: nginx:alpine
    ports:
      - "8081:80"
    volumes:
      - ./nginx-blue.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - web-blue
    networks:
      - blue-network

networks:
  blue-network:
    driver: bridge
EOF

# Create green environment
cat > docker-compose.green.yml << 'EOF'
version: '3.8'

services:
  web-green:
    image: rolling-app:v2.0.0
    environment:
      - APP_VERSION=v2.0.0
      - ENVIRONMENT=green
    networks:
      - green-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 3

  nginx-green:
    image: nginx:alpine
    ports:
      - "8082:80"
    volumes:
      - ./nginx-green.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - web-green
    networks:
      - green-network

networks:
  green-network:
    driver: bridge
EOF

# Create nginx configurations
cat > nginx-blue.conf << 'EOF'
events { worker_connections 1024; }
http {
    upstream backend {
        server web-blue:8080;
    }
    server {
        listen 80;
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            add_header X-Environment "blue";
        }
    }
}
EOF

cat > nginx-green.conf << 'EOF'
events { worker_connections 1024; }
http {
    upstream backend {
        server web-green:8080;
    }
    server {
        listen 80;
        location / {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            add_header X-Environment "green";
        }
    }
}
EOF

# Create main load balancer
cat > docker-compose.lb.yml << 'EOF'
version: '3.8'

services:
  main-lb:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx-main.conf:/etc/nginx/nginx.conf:ro
    networks:
      - public

networks:
  public:
    driver: bridge
EOF

# Create main load balancer config (initially pointing to blue)
cat > nginx-main.conf << 'EOF'
events { worker_connections 1024; }
http {
    upstream active_environment {
        server host.docker.internal:8081;  # Blue environment
    }
    server {
        listen 80;
        location / {
            proxy_pass http://active_environment;
            proxy_set_header Host $host;
            add_header X-Active-Environment "blue";
        }
    }
}
EOF

# Blue-green deployment script
cat > blue-green-deploy.sh << 'EOF'
#!/bin/bash

NEW_VERSION=$1
CURRENT_ENV=${2:-blue}

if [ "$CURRENT_ENV" = "blue" ]; then
    NEW_ENV="green"
    NEW_PORT="8082"
else
    NEW_ENV="blue"
    NEW_PORT="8081"
fi

echo "🚀 Deploying $NEW_VERSION to $NEW_ENV environment"

# Start new environment
docker-compose -f docker-compose.$NEW_ENV.yml up -d

# Wait for health checks
echo "⏳ Waiting for health checks..."
sleep 20

# Test new environment
if curl -f http://localhost:$NEW_PORT/health > /dev/null 2>&1; then
    echo "✅ Health check passed for $NEW_ENV environment"
    
    # Update main load balancer to point to new environment
    sed -i.bak "s/host.docker.internal:808[12]/host.docker.internal:$NEW_PORT/" nginx-main.conf
    sed -i.bak "s/X-Active-Environment \"[^\"]*\"/X-Active-Environment \"$NEW_ENV\"/" nginx-main.conf
    
    # Reload main load balancer
    docker-compose -f docker-compose.lb.yml up -d --force-recreate
    
    echo "🔄 Traffic switched to $NEW_ENV environment"
    
    # Stop old environment
    OLD_ENV=$CURRENT_ENV
    docker-compose -f docker-compose.$OLD_ENV.yml down
    
    echo "✅ Blue-green deployment completed successfully"
else
    echo "❌ Health check failed for $NEW_ENV environment"
    docker-compose -f docker-compose.$NEW_ENV.yml down
    exit 1
fi
EOF

chmod +x blue-green-deploy.sh

echo "🔵 Starting blue environment (v1.0.0)..."
docker-compose -f docker-compose.blue.yml up -d
docker-compose -f docker-compose.lb.yml up -d

sleep 15

echo "🧪 Testing blue environment..."
curl -s http://localhost/version | head -3

echo ""
echo "🟢 Deploying to green environment (v2.0.0)..."
./blue-green-deploy.sh v2.0.0 blue

sleep 5

echo "🧪 Testing after blue-green switch..."
curl -s http://localhost/version | head -3

# Cleanup
docker-compose -f docker-compose.lb.yml down
docker-compose -f docker-compose.green.yml down

cd ..

echo ""
echo "🎯 Exercise 3: Monitoring Setup"
echo "==============================="

echo "📊 Setting up monitoring stack..."

mkdir -p monitoring-stack
cd monitoring-stack

# Create monitoring compose
cat > docker-compose.monitoring.yml << 'EOF'
version: '3.8'

services:
  # Application to monitor
  app:
    image: rolling-app:v1.0.0
    environment:
      - APP_VERSION=v1.0.0
    ports:
      - "8080:8080"
    networks:
      - monitoring

  # Prometheus
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  # Grafana
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - ./grafana-datasources.yml:/etc/grafana/provisioning/datasources/datasources.yml
    networks:
      - monitoring

  # Node Exporter
  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    networks:
      - monitoring

networks:
  monitoring:
    driver: bridge
EOF

# Create Prometheus configuration
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'app'
    static_configs:
      - targets: ['app:8080']
    metrics_path: '/health'
    scrape_interval: 10s
EOF

# Create Grafana datasource configuration
cat > grafana-datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF

echo "🚀 Starting monitoring stack..."
docker-compose -f docker-compose.monitoring.yml up -d

echo "⏳ Waiting for services to start..."
sleep 20

echo "📊 Monitoring stack is ready:"
echo "   Prometheus: http://localhost:9090"
echo "   Grafana: http://localhost:3000 (admin/admin)"
echo "   Application: http://localhost:8080"

# Generate some load for monitoring
echo "🔄 Generating load for monitoring..."
for i in {1..20}; do
    curl -s http://localhost:8080/ > /dev/null
    curl -s http://localhost:8080/health > /dev/null
    curl -s http://localhost:8080/version > /dev/null
    sleep 1
done

echo "✅ Load generation completed"

# Stop monitoring stack
docker-compose -f docker-compose.monitoring.yml down

cd ..

echo ""
echo "🎯 Exercise 4: CI/CD Pipeline Simulation"
echo "========================================"

echo "🔄 Simulating CI/CD pipeline..."

mkdir -p cicd-simulation
cd cicd-simulation

# Create pipeline simulation script
cat > simulate-pipeline.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting CI/CD Pipeline Simulation"
echo "====================================="

VERSION=${1:-v1.1.0}

echo ""
echo "📋 Stage 1: Build"
echo "=================="
echo "✅ Code checkout completed"
echo "✅ Dependencies installed"
echo "🐳 Building Docker image..."
sleep 2
echo "✅ Image built: myapp:$VERSION"

echo ""
echo "📋 Stage 2: Test"
echo "================"
echo "🧪 Running unit tests..."
sleep 1
echo "✅ Unit tests passed (15/15)"
echo "🧪 Running integration tests..."
sleep 2
echo "✅ Integration tests passed (8/8)"

echo ""
echo "📋 Stage 3: Security Scan"
echo "========================="
echo "🔍 Scanning image for vulnerabilities..."
sleep 2
echo "✅ Security scan completed - No critical vulnerabilities found"

echo ""
echo "📋 Stage 4: Deploy to Staging"
echo "============================="
echo "🚀 Deploying to staging environment..."
sleep 2
echo "✅ Staging deployment completed"
echo "🧪 Running smoke tests..."
sleep 1
echo "✅ Smoke tests passed"

echo ""
echo "📋 Stage 5: Deploy to Production"
echo "================================"
echo "⏳ Waiting for manual approval..."
sleep 3
echo "✅ Approval received"
echo "🚀 Deploying to production using blue-green strategy..."
sleep 3
echo "✅ Production deployment completed"

echo ""
echo "📋 Stage 6: Post-deployment"
echo "==========================="
echo "📊 Running health checks..."
sleep 1
echo "✅ All health checks passed"
echo "📈 Monitoring metrics look good"
echo "✅ Pipeline completed successfully!"

echo ""
echo "🎉 Deployment Summary"
echo "===================="
echo "Version: $VERSION"
echo "Strategy: Blue-Green"
echo "Duration: ~2 minutes"
echo "Status: SUCCESS ✅"
EOF

chmod +x simulate-pipeline.sh

echo "🔄 Running pipeline simulation..."
./simulate-pipeline.sh v1.1.0

cd ..

echo ""
echo "🎯 Exercise 5: Cleanup and Summary"
echo "=================================="

echo "🧹 Cleaning up resources..."

# Remove images
docker rmi rolling-app:v1.0.0 rolling-app:v2.0.0 2>/dev/null || true

# Clean up files
cd "$EXERCISE_DIR/.."
rm -rf "$EXERCISE_DIR"

echo "✅ Cleanup completed"

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully:"
echo "✅ Implemented rolling deployment strategy"
echo "✅ Performed blue-green deployment with traffic switching"
echo "✅ Set up production monitoring with Prometheus and Grafana"
echo "✅ Simulated complete CI/CD pipeline"
echo "✅ Practiced production deployment best practices"
echo ""
echo "🔍 Key deployment strategies practiced:"
echo "   Rolling Deployment - Zero-downtime gradual updates"
echo "   Blue-Green Deployment - Instant rollback capability"
echo "   Health Checks - Automated deployment validation"
echo "   Load Balancing - Traffic distribution and failover"
echo "   Monitoring - Operational visibility and alerting"
echo "   CI/CD Pipeline - Automated testing and deployment"
echo ""
echo "💡 Next: Complete containerization project integrating all concepts!"
