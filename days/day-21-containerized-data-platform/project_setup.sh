#!/bin/bash

# Day 21: Containerized Data Platform - Automated Setup
# Creates the complete production-ready data analytics platform

set -e

echo "🚀 Day 21: Containerized Data Analytics Platform"
echo "==============================================="

# Create project directory
PROJECT_DIR="$HOME/containerized-data-platform"
echo "📁 Creating project directory: $PROJECT_DIR"

if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$PROJECT_DIR"
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo ""
echo "🎯 Phase 1: Project Structure Setup"
echo "==================================="

# Create directory structure
mkdir -p {api,jupyter,nginx,monitoring/{grafana/{dashboards,datasources}},scripts,data/{raw,processed,models},.github/workflows}

echo "✅ Directory structure created"

echo ""
echo "🎯 Phase 2: API Service"
echo "======================"

# Create API Dockerfile
cat > api/Dockerfile << 'EOF'
FROM python:3.9-slim AS builder

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.9-slim

RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -s /bin/sh appuser

COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=1001:1001 . /app

WORKDIR /app
USER 1001:1001

ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
EOF

# Create API requirements
cat > api/requirements.txt << 'EOF'
Flask==2.3.2
gunicorn==20.1.0
psycopg2-binary==2.9.6
redis==4.5.4
pandas==1.5.3
numpy==1.24.3
scikit-learn==1.2.2
prometheus-client==0.16.0
EOF

# Create API application
cat > api/app.py << 'EOF'
#!/usr/bin/env python3
"""Data Analytics API Service."""

from flask import Flask, jsonify, request
import psycopg2
import redis
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error
import os
import json
import time
from prometheus_client import Counter, Histogram, generate_latest

app = Flask(__name__)

# Metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'postgres'),
        database=os.getenv('DB_NAME', 'analytics'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'password')
    )

redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'redis'),
    port=6379,
    decode_responses=True
)

@app.route('/')
def home():
    REQUEST_COUNT.labels(method='GET', endpoint='/').inc()
    return jsonify({
        'service': 'Data Analytics API',
        'version': '1.0.0',
        'endpoints': ['/data', '/analytics', '/model', '/health', '/metrics']
    })

@app.route('/health')
def health():
    try:
        conn = get_db_connection()
        conn.close()
        db_status = 'healthy'
    except:
        db_status = 'unhealthy'
    
    try:
        redis_client.ping()
        redis_status = 'healthy'
    except:
        redis_status = 'unhealthy'
    
    status = 'healthy' if db_status == 'healthy' and redis_status == 'healthy' else 'unhealthy'
    
    return jsonify({
        'status': status,
        'database': db_status,
        'redis': redis_status,
        'timestamp': time.time()
    }), 200 if status == 'healthy' else 503

@app.route('/data', methods=['GET', 'POST'])
def data():
    REQUEST_COUNT.labels(method=request.method, endpoint='/data').inc()
    
    if request.method == 'POST':
        data = request.get_json()
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute("""
            INSERT INTO customer_data (name, age, income, score)
            VALUES (%s, %s, %s, %s) RETURNING id
        """, (data['name'], data['age'], data['income'], data['score']))
        
        customer_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        
        return jsonify({'id': customer_id, 'message': 'Data stored successfully'})
    
    else:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT * FROM customer_data ORDER BY id DESC LIMIT 100")
        
        columns = [desc[0] for desc in cur.description]
        data = [dict(zip(columns, row)) for row in cur.fetchall()]
        
        cur.close()
        conn.close()
        
        return jsonify({'data': data, 'count': len(data)})

@app.route('/analytics')
def analytics():
    REQUEST_COUNT.labels(method='GET', endpoint='/analytics').inc()
    
    cached_result = redis_client.get('analytics_summary')
    if cached_result:
        return jsonify(json.loads(cached_result))
    
    conn = get_db_connection()
    df = pd.read_sql("SELECT * FROM customer_data", conn)
    conn.close()
    
    if df.empty:
        return jsonify({'error': 'No data available'}), 404
    
    analytics = {
        'total_customers': len(df),
        'average_age': float(df['age'].mean()),
        'average_income': float(df['income'].mean()),
        'average_score': float(df['score'].mean()),
        'age_distribution': {
            'min': int(df['age'].min()),
            'max': int(df['age'].max()),
            'std': float(df['age'].std())
        }
    }
    
    redis_client.setex('analytics_summary', 300, json.dumps(analytics))
    return jsonify(analytics)

@app.route('/model/train', methods=['POST'])
def train_model():
    REQUEST_COUNT.labels(method='POST', endpoint='/model/train').inc()
    
    conn = get_db_connection()
    df = pd.read_sql("SELECT age, income, score FROM customer_data", conn)
    conn.close()
    
    if len(df) < 10:
        return jsonify({'error': 'Insufficient data for training'}), 400
    
    X = df[['age', 'income']]
    y = df['score']
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    model = LinearRegression()
    model.fit(X_train, y_train)
    
    y_pred = model.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)
    
    model_info = {
        'mse': float(mse),
        'training_samples': len(X_train),
        'test_samples': len(X_test),
        'timestamp': time.time()
    }
    
    redis_client.setex('model_info', 3600, json.dumps(model_info))
    return jsonify(model_info)

@app.route('/metrics')
def metrics():
    return generate_latest()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF

echo "✅ API service created"

echo ""
echo "🎯 Phase 3: Jupyter Environment"
echo "==============================="

# Create Jupyter Dockerfile
cat > jupyter/Dockerfile << 'EOF'
FROM jupyter/scipy-notebook:latest

USER root

RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

USER $NB_UID

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

WORKDIR /home/jovyan/work

CMD ["start-notebook.sh", "--NotebookApp.default_url=/lab"]
EOF

cat > jupyter/requirements.txt << 'EOF'
psycopg2-binary==2.9.6
redis==4.5.4
plotly==5.14.1
seaborn==0.12.2
scikit-learn==1.2.2
EOF

echo "✅ Jupyter environment created"

echo ""
echo "🎯 Phase 4: Load Balancer"
echo "========================="

# Create Nginx Dockerfile
cat > nginx/Dockerfile << 'EOF'
FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf

RUN apk add --no-cache curl

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 80 443
EOF

# Create Nginx configuration
cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream api_backend {
        server api:5000 max_fails=3 fail_timeout=30s;
    }

    upstream jupyter_backend {
        server jupyter:8888 max_fails=3 fail_timeout=30s;
    }

    upstream grafana_backend {
        server grafana:3000 max_fails=3 fail_timeout=30s;
    }

    server {
        listen 80;
        server_name _;

        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        location /api/ {
            proxy_pass http://api_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location /jupyter/ {
            proxy_pass http://jupyter_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        location /grafana/ {
            proxy_pass http://grafana_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location / {
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
EOF

echo "✅ Load balancer created"

echo ""
echo "🎯 Phase 5: Docker Compose Configuration"
echo "========================================"

# Create main docker-compose file
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  nginx:
    build: ./nginx
    ports:
      - "80:80"
    depends_on:
      - api
      - jupyter
      - grafana
    networks:
      - frontend
    restart: unless-stopped

  api:
    build: ./api
    environment:
      - DB_HOST=postgres
      - DB_NAME=analytics
      - DB_USER=postgres
      - DB_PASSWORD=${DB_PASSWORD:-password}
      - REDIS_HOST=redis
    depends_on:
      - postgres
      - redis
    networks:
      - frontend
      - backend
    volumes:
      - ./data:/app/data
    restart: unless-stopped

  jupyter:
    build: ./jupyter
    environment:
      - JUPYTER_ENABLE_LAB=yes
      - JUPYTER_TOKEN=${JUPYTER_TOKEN:-analytics}
    volumes:
      - ./data:/home/jovyan/data
      - jupyter_notebooks:/home/jovyan/work
    networks:
      - frontend
      - backend
    restart: unless-stopped

  postgres:
    image: postgres:13
    environment:
      - POSTGRES_DB=analytics
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${DB_PASSWORD:-password}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - backend
    restart: unless-stopped

  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - backend
    restart: unless-stopped

  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
    networks:
      - backend
      - monitoring
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD:-admin}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources
    networks:
      - frontend
      - monitoring
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  prometheus_data:
  grafana_data:
  jupyter_notebooks:

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
  monitoring:
    driver: bridge
EOF

echo "✅ Docker Compose configuration created"

echo ""
echo "🎯 Phase 6: Monitoring Configuration"
echo "==================================="

# Create Prometheus configuration
cat > monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'api'
    static_configs:
      - targets: ['api:5000']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:80']
    metrics_path: '/health'
    scrape_interval: 30s
EOF

# Create Grafana datasource
cat > monitoring/grafana/datasources/prometheus.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOF

echo "✅ Monitoring configuration created"

echo ""
echo "🎯 Phase 7: Database Initialization"
echo "==================================="

# Create database initialization script
cat > scripts/init.sql << 'EOF'
-- Create customer data table
CREATE TABLE IF NOT EXISTS customer_data (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INTEGER NOT NULL,
    income DECIMAL(10,2) NOT NULL,
    score DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO customer_data (name, age, income, score) VALUES
    ('Alice Johnson', 28, 75000.00, 8.5),
    ('Bob Smith', 35, 82000.00, 7.2),
    ('Carol Davis', 42, 95000.00, 9.1),
    ('David Wilson', 31, 68000.00, 6.8),
    ('Eva Brown', 29, 71000.00, 8.0),
    ('Frank Miller', 38, 88000.00, 7.9),
    ('Grace Lee', 26, 63000.00, 7.5),
    ('Henry Taylor', 45, 105000.00, 9.3),
    ('Ivy Chen', 33, 79000.00, 8.2),
    ('Jack Anderson', 27, 65000.00, 7.1);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_customer_age ON customer_data(age);
CREATE INDEX IF NOT EXISTS idx_customer_income ON customer_data(income);
CREATE INDEX IF NOT EXISTS idx_customer_score ON customer_data(score);
EOF

echo "✅ Database initialization created"

echo ""
echo "🎯 Phase 8: Automation Scripts"
echo "=============================="

# Create deployment script
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash

set -e

VERSION=${1:-latest}
ENVIRONMENT=${2:-development}

echo "🚀 Deploying Data Analytics Platform"
echo "Version: $VERSION"
echo "Environment: $ENVIRONMENT"

echo "🐳 Building images..."
docker-compose build

echo "🚀 Starting services..."
docker-compose up -d

echo "⏳ Waiting for services..."
sleep 30

echo "🔍 Health checks..."
curl -f http://localhost/health || exit 1
curl -f http://localhost/api/health || exit 1

echo "✅ Deployment completed successfully"
EOF

# Create health check script
cat > scripts/health-check.sh << 'EOF'
#!/bin/bash

echo "🔍 Health Check Report"
echo "====================="

# API Health
echo "API Service:"
curl -s http://localhost/api/health | head -3 || echo "❌ API unhealthy"

# Database connectivity
echo -e "\nDatabase:"
docker exec postgres pg_isready -U postgres || echo "❌ Database unhealthy"

# Redis connectivity
echo -e "\nRedis:"
docker exec redis redis-cli ping || echo "❌ Redis unhealthy"

# Service status
echo -e "\nService Status:"
docker-compose ps

echo -e "\n✅ Health check completed"
EOF

# Create backup script
cat > scripts/backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/tmp/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

echo "💾 Starting backup process..."

# Database backup
docker exec postgres pg_dump -U postgres analytics > "$BACKUP_DIR/database.sql"

echo "✅ Backup completed: $BACKUP_DIR"
EOF

# Make scripts executable
chmod +x scripts/*.sh

echo "✅ Automation scripts created"

echo ""
echo "🎯 Phase 9: Configuration Files"
echo "==============================="

# Create environment template
cat > .env.example << 'EOF'
# Database
DB_PASSWORD=your_secure_password_here

# Jupyter
JUPYTER_TOKEN=your_jupyter_token_here

# Grafana
GRAFANA_PASSWORD=your_grafana_password_here
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
.git
.gitignore
README.md
.env
.env.example
docker-compose*.yml
.dockerignore
node_modules
*.log
__pycache__
.pytest_cache
EOF

# Create Makefile
cat > Makefile << 'EOF'
.PHONY: build up down logs test health clean

build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

health:
	./scripts/health-check.sh

clean:
	docker-compose down -v --rmi all
	docker system prune -f

deploy:
	./scripts/deploy.sh latest development
EOF

echo "✅ Configuration files created"

echo ""
echo "🎯 Phase 10: Platform Deployment"
echo "==============================="

echo "🐳 Building and starting the platform..."
docker-compose build
docker-compose up -d

echo "⏳ Waiting for services to initialize..."
sleep 45

echo "🔍 Running health checks..."
./scripts/health-check.sh

echo ""
echo "🧪 Testing API endpoints..."

# Test API endpoints
echo "Testing API health:"
curl -s http://localhost/api/health | head -3

echo -e "\nTesting analytics endpoint:"
curl -s http://localhost/api/analytics | head -5

echo -e "\nAdding sample data:"
curl -X POST http://localhost/api/data \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","age":30,"income":70000,"score":8.0}' | head -3

echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "🎉 Platform Setup Complete!"
echo "=========================="
echo ""
echo "🌐 Access Points:"
echo "   Main API: http://localhost/api/"
echo "   Jupyter Lab: http://localhost/jupyter/ (token: analytics)"
echo "   Grafana: http://localhost/grafana/ (admin/admin)"
echo "   Health Check: http://localhost/health"
echo ""
echo "📁 Project location: $PROJECT_DIR"
echo ""
echo "🔧 Management Commands:"
echo "   make up      - Start services"
echo "   make down    - Stop services"
echo "   make logs    - View logs"
echo "   make health  - Health check"
echo "   make clean   - Clean up everything"
echo ""
echo "📊 Test the platform:"
echo "   curl http://localhost/api/health"
echo "   curl http://localhost/api/analytics"
echo "   curl -X POST http://localhost/api/data -H 'Content-Type: application/json' -d '{\"name\":\"John\",\"age\":25,\"income\":50000,\"score\":7.5}'"
echo ""
echo "✅ Production-ready containerized data analytics platform is running!"
