# Day 21: Mini Project - Containerized Data Analytics Platform

**Duration**: 1.5-2 hours (Project Day)  
**Prerequisites**: Days 15-20 (Complete Docker & Containers sequence)

## Project Overview

Build a complete, production-ready containerized data analytics platform that integrates all Docker concepts learned in Week 3. This project demonstrates enterprise-grade containerization practices for data engineering and AI workloads.

## Learning Objectives

By completing this project, you will:
- Integrate all Docker concepts into a cohesive system
- Build a production-ready data analytics platform
- Implement enterprise deployment strategies
- Configure comprehensive monitoring and logging
- Apply security best practices throughout
- Create automated CI/CD pipelines
- Design disaster recovery and backup strategies

## Project Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Load Balancer (Nginx)                    │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────┼───────────────────────────────────────┐
│                 Frontend Network                            │
├─────────────────────┼───────────────────────────────────────┤
│  ┌─────────────────┐│┌─────────────────┐ ┌─────────────────┐│
│  │   Web API       │││   Jupyter Lab   │ │   Grafana       ││
│  │   (Flask)       │││   (Analytics)   │ │   (Monitoring)  ││
│  └─────────────────┘│└─────────────────┘ └─────────────────┘│
└─────────────────────┼───────────────────────────────────────┘
                      │
┌─────────────────────┼───────────────────────────────────────┐
│                 Backend Network                             │
├─────────────────────┼───────────────────────────────────────┤
│  ┌─────────────────┐│┌─────────────────┐ ┌─────────────────┐│
│  │   PostgreSQL    │││     Redis       │ │   Prometheus    ││
│  │   (Database)    │││    (Cache)      │ │   (Metrics)     ││
│  └─────────────────┘│└─────────────────┘ └─────────────────┘│
└─────────────────────┴───────────────────────────────────────┘
```

## Project Structure

```
containerized-data-platform/
├── README.md
├── docker-compose.yml
├── docker-compose.prod.yml
├── .env.example
├── .dockerignore
├── Makefile
│
├── api/
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── app.py
│   ├── models.py
│   └── utils.py
│
├── jupyter/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── notebooks/
│       ├── data_analysis.ipynb
│       └── model_training.ipynb
│
├── nginx/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── ssl/
│
├── monitoring/
│   ├── prometheus.yml
│   ├── grafana/
│   │   ├── dashboards/
│   │   └── datasources/
│   └── alertmanager.yml
│
├── scripts/
│   ├── backup.sh
│   ├── deploy.sh
│   ├── health-check.sh
│   └── restore.sh
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── models/
│
└── .github/
    └── workflows/
        └── deploy.yml
```

## Phase 1: Core Application Development (30 minutes)

### API Service (Flask)

**api/Dockerfile**
```dockerfile
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
```

**api/requirements.txt**
```
Flask==2.3.2
gunicorn==20.1.0
psycopg2-binary==2.9.6
redis==4.5.4
pandas==1.5.3
numpy==1.24.3
scikit-learn==1.2.2
prometheus-client==0.16.0
```

**api/app.py**
```python
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

# Database connection
def get_db_connection():
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'postgres'),
        database=os.getenv('DB_NAME', 'analytics'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'password')
    )

# Redis connection
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
        # Check database
        conn = get_db_connection()
        conn.close()
        db_status = 'healthy'
    except:
        db_status = 'unhealthy'
    
    try:
        # Check Redis
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
        # Store data
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
        # Retrieve data
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
    
    # Check cache first
    cached_result = redis_client.get('analytics_summary')
    if cached_result:
        return jsonify(json.loads(cached_result))
    
    # Generate analytics
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
        },
        'income_distribution': {
            'min': float(df['income'].min()),
            'max': float(df['income'].max()),
            'std': float(df['income'].std())
        }
    }
    
    # Cache result for 5 minutes
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
    
    # Prepare data
    X = df[['age', 'income']]
    y = df['score']
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Train model
    model = LinearRegression()
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test)
    mse = mean_squared_error(y_test, y_pred)
    
    # Store model metrics
    model_info = {
        'mse': float(mse),
        'training_samples': len(X_train),
        'test_samples': len(X_test),
        'coefficients': model.coef_.tolist(),
        'intercept': float(model.intercept_),
        'timestamp': time.time()
    }
    
    redis_client.setex('model_info', 3600, json.dumps(model_info))
    
    return jsonify(model_info)

@app.route('/metrics')
def metrics():
    return generate_latest()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
```

### Jupyter Analytics Environment

**jupyter/Dockerfile**
```dockerfile
FROM jupyter/scipy-notebook:latest

USER root

RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

USER $NB_UID

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY --chown=$NB_UID:$NB_GID notebooks/ ./work/

WORKDIR /home/jovyan/work

CMD ["start-notebook.sh", "--NotebookApp.default_url=/lab"]
```

**jupyter/requirements.txt**
```
psycopg2-binary==2.9.6
redis==4.5.4
plotly==5.14.1
seaborn==0.12.2
scikit-learn==1.2.2
```

## Phase 2: Infrastructure and Orchestration (25 minutes)

### Docker Compose Configuration

**docker-compose.yml**
```yaml
version: '3.8'

services:
  # Load Balancer
  nginx:
    build: ./nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - api
      - jupyter
      - grafana
    networks:
      - frontend
    volumes:
      - ./nginx/ssl:/etc/ssl:ro
    restart: unless-stopped

  # API Service
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
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M

  # Jupyter Lab
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

  # Database
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
    deploy:
      resources:
        limits:
          memory: 2G

  # Cache
  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - backend
    restart: unless-stopped

  # Monitoring
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
      - '--web.enable-lifecycle'
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
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
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
```

### Production Override

**docker-compose.prod.yml**
```yaml
version: '3.8'

services:
  nginx:
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.role == worker

  api:
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3

  postgres:
    deploy:
      placement:
        constraints:
          - node.labels.type == database
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G

  # Add backup service for production
  backup:
    image: postgres:13
    volumes:
      - postgres_data:/var/lib/postgresql/data:ro
      - ./backups:/backups
    command: >
      bash -c "
      while true; do
        pg_dump -h postgres -U postgres analytics > /backups/backup-$$(date +%Y%m%d-%H%M%S).sql
        find /backups -name '*.sql' -mtime +7 -delete
        sleep 86400
      done
      "
    networks:
      - backend
    depends_on:
      - postgres
```

### Nginx Load Balancer

**nginx/Dockerfile**
```dockerfile
FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf

RUN apk add --no-cache curl

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

EXPOSE 80 443
```

**nginx/nginx.conf**
```nginx
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

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }

        # API routes
        location /api/ {
            proxy_pass http://api_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # Jupyter Lab
        location /jupyter/ {
            proxy_pass http://jupyter_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }

        # Grafana
        location /grafana/ {
            proxy_pass http://grafana_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # Default to API
        location / {
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
```

## Phase 3: Monitoring and Observability (20 minutes)

### Prometheus Configuration

**monitoring/prometheus.yml**
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

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

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
    scrape_interval: 30s
```

### Grafana Dashboard Configuration

**monitoring/grafana/datasources/prometheus.yml**
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

## Phase 4: Automation and CI/CD (15 minutes)

### Deployment Scripts

**scripts/deploy.sh**
```bash
#!/bin/bash

set -e

VERSION=${1:-latest}
ENVIRONMENT=${2:-development}

echo "🚀 Deploying Data Analytics Platform"
echo "Version: $VERSION"
echo "Environment: $ENVIRONMENT"

# Build images
echo "🐳 Building images..."
docker-compose build

# Run tests
echo "🧪 Running tests..."
docker-compose run --rm api python -m pytest tests/ || exit 1

# Deploy based on environment
if [ "$ENVIRONMENT" = "production" ]; then
    echo "🏭 Production deployment"
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
else
    echo "🔧 Development deployment"
    docker-compose up -d
fi

# Health checks
echo "⏳ Waiting for services..."
sleep 30

echo "🔍 Health checks..."
curl -f http://localhost/health || exit 1
curl -f http://localhost/api/health || exit 1

echo "✅ Deployment completed successfully"
```

**scripts/backup.sh**
```bash
#!/bin/bash

BACKUP_DIR="/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

echo "💾 Starting backup process..."

# Database backup
docker exec postgres pg_dump -U postgres analytics > "$BACKUP_DIR/database.sql"

# Volume backups
docker run --rm \
  -v postgres_data:/source:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/postgres_data.tar.gz -C /source .

docker run --rm \
  -v grafana_data:/source:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/grafana_data.tar.gz -C /source .

# Upload to cloud (if configured)
if [ -n "$AWS_S3_BUCKET" ]; then
    aws s3 sync "$BACKUP_DIR" "s3://$AWS_S3_BUCKET/backups/$(date +%Y%m%d)/"
fi

echo "✅ Backup completed: $BACKUP_DIR"
```

### GitHub Actions Pipeline

**.github/workflows/deploy.yml**
```yaml
name: Deploy Data Analytics Platform

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          pip install -r api/requirements.txt
          pip install pytest
      
      - name: Run tests
        run: pytest api/tests/

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push images
        run: |
          docker-compose build
          docker-compose push

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying to staging environment"
          # Add staging deployment logic

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    environment: production
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production environment"
          # Add production deployment logic
```

## Phase 5: Security and Best Practices (10 minutes)

### Environment Configuration

**.env.example**
```env
# Database
DB_PASSWORD=your_secure_password_here

# Jupyter
JUPYTER_TOKEN=your_jupyter_token_here

# Grafana
GRAFANA_PASSWORD=your_grafana_password_here

# Backup
AWS_S3_BUCKET=your_backup_bucket

# SSL
SSL_CERT_PATH=./nginx/ssl/cert.pem
SSL_KEY_PATH=./nginx/ssl/key.pem
```

### Database Initialization

**scripts/init.sql**
```sql
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
```

### Makefile for Easy Management

**Makefile**
```makefile
.PHONY: build up down logs test backup restore clean

# Build all images
build:
	docker-compose build

# Start development environment
up:
	docker-compose up -d

# Start production environment
up-prod:
	docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Stop all services
down:
	docker-compose down

# View logs
logs:
	docker-compose logs -f

# Run tests
test:
	docker-compose run --rm api python -m pytest tests/

# Create backup
backup:
	./scripts/backup.sh

# Restore from backup
restore:
	./scripts/restore.sh

# Health check
health:
	./scripts/health-check.sh

# Clean up everything
clean:
	docker-compose down -v --rmi all
	docker system prune -f

# Deploy to production
deploy:
	./scripts/deploy.sh latest production
```

## Project Completion Checklist

### ✅ Core Functionality
- [ ] Multi-service containerized architecture
- [ ] RESTful API with database integration
- [ ] Jupyter environment for data analysis
- [ ] Redis caching for performance
- [ ] Load balancing with Nginx

### ✅ Production Readiness
- [ ] Optimized Docker images with multi-stage builds
- [ ] Non-root users for security
- [ ] Health checks for all services
- [ ] Resource limits and monitoring
- [ ] Comprehensive logging

### ✅ Monitoring and Observability
- [ ] Prometheus metrics collection
- [ ] Grafana dashboards
- [ ] Application performance monitoring
- [ ] Infrastructure monitoring
- [ ] Alerting configuration

### ✅ Security
- [ ] Secrets management
- [ ] Network segmentation
- [ ] SSL/TLS configuration
- [ ] Security scanning integration
- [ ] Backup and recovery procedures

### ✅ Automation
- [ ] CI/CD pipeline
- [ ] Automated testing
- [ ] Deployment scripts
- [ ] Backup automation
- [ ] Health monitoring

## Testing Your Platform

```bash
# 1. Deploy the platform
make up

# 2. Test API endpoints
curl http://localhost/api/health
curl http://localhost/api/analytics

# 3. Access Jupyter Lab
# Visit: http://localhost/jupyter (token: analytics)

# 4. View monitoring
# Visit: http://localhost/grafana (admin/admin)

# 5. Load test
for i in {1..100}; do
  curl -X POST http://localhost/api/data \
    -H "Content-Type: application/json" \
    -d '{"name":"Test User","age":30,"income":70000,"score":8.0}'
done

# 6. Check metrics
curl http://localhost/api/metrics
```

## Key Achievements

By completing this project, you have:

- ✅ **Built a production-ready containerized data platform**
- ✅ **Implemented enterprise security and monitoring practices**
- ✅ **Created automated CI/CD pipelines**
- ✅ **Designed scalable microservices architecture**
- ✅ **Applied all Docker optimization techniques**
- ✅ **Established comprehensive backup and recovery procedures**

## Next Steps

This completes Week 3 (Docker & Containers). Week 4 will focus on CI/CD and Professional Tools, building on this containerized foundation to create complete DevOps workflows.

## Project Extensions

Consider these enhancements:
- Add machine learning model serving
- Implement data streaming with Kafka
- Add authentication and authorization
- Create mobile/web frontend
- Integrate with cloud services (AWS, GCP, Azure)
- Add data pipeline orchestration with Airflow
