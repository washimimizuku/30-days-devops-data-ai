#!/bin/bash

# Day 17: Docker Compose - Solution Guide
# Reference solutions for multi-container orchestration

echo "📚 Day 17: Docker Compose - Solution Guide"
echo "=========================================="

echo ""
echo "🎯 Solution 1: Basic Web App with Database"
echo "=========================================="

cat << 'EOF'
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
    depends_on:
      - db
    networks:
      - app-network

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge

# Commands:
# docker-compose up -d          # Start services
# docker-compose logs web       # View logs
# docker-compose exec db psql   # Connect to database
# docker-compose down -v        # Stop and remove volumes
EOF

echo ""
echo "🎯 Solution 2: Data Science Stack"
echo "================================="

cat << 'EOF'
# docker-compose.yml
version: '3.8'

services:
  jupyter:
    image: jupyter/scipy-notebook:latest
    ports:
      - "8888:8888"
    environment:
      - JUPYTER_ENABLE_LAB=yes
      - JUPYTER_TOKEN=secure-token
    volumes:
      - ./notebooks:/home/jovyan/work
      - ./data:/home/jovyan/data
    networks:
      - datascience

  postgres:
    image: postgres:13
    environment:
      - POSTGRES_DB=analytics
      - POSTGRES_USER=analyst
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - datascience

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - datascience

volumes:
  postgres_data:
  redis_data:

networks:
  datascience:
    driver: bridge
EOF

echo ""
echo "🎯 Solution 3: Microservices Architecture"
echo "========================================"

cat << 'EOF'
# docker-compose.yml
version: '3.8'

services:
  # API Gateway
  gateway:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - user-service
      - order-service
    networks:
      - frontend
      - backend

  # User Service
  user-service:
    build: ./user-service
    environment:
      - DATABASE_URL=postgresql://postgres:password@user-db:5432/users
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - user-db
      - redis
    networks:
      - backend

  # Order Service
  order-service:
    build: ./order-service
    environment:
      - DATABASE_URL=postgresql://postgres:password@order-db:5432/orders
      - USER_SERVICE_URL=http://user-service:5000
    depends_on:
      - order-db
    networks:
      - backend

  # Databases
  user-db:
    image: postgres:13
    environment:
      - POSTGRES_DB=users
      - POSTGRES_PASSWORD=password
    volumes:
      - user_data:/var/lib/postgresql/data
    networks:
      - backend

  order-db:
    image: postgres:13
    environment:
      - POSTGRES_DB=orders
      - POSTGRES_PASSWORD=password
    volumes:
      - order_data:/var/lib/postgresql/data
    networks:
      - backend

  # Cache
  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
    networks:
      - backend

volumes:
  user_data:
  order_data:
  redis_data:

networks:
  frontend:
  backend:
EOF

echo ""
echo "🎯 Solution 4: Development vs Production"
echo "======================================="

cat << 'EOF'
# docker-compose.yml (base)
version: '3.8'

services:
  web:
    build: .
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_PASSWORD=password

# docker-compose.override.yml (development - auto-loaded)
version: '3.8'

services:
  web:
    ports:
      - "8000:8000"
    volumes:
      - .:/app  # Live code reloading
    environment:
      - DEBUG=1
      - FLASK_ENV=development

  db:
    ports:
      - "5432:5432"  # Expose for development tools

# docker-compose.prod.yml (production)
version: '3.8'

services:
  web:
    image: myapp:latest  # Pre-built image
    restart: unless-stopped
    environment:
      - DEBUG=0
      - FLASK_ENV=production
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.prod.conf:/etc/nginx/nginx.conf

# Usage:
# Development: docker-compose up
# Production: docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
EOF

echo ""
echo "🎯 Solution 5: ML Training Pipeline"
echo "=================================="

cat << 'EOF'
# docker-compose.yml
version: '3.8'

services:
  # Data preprocessing
  preprocessor:
    build: ./preprocessing
    volumes:
      - ./data:/input
      - processed_data:/output
    environment:
      - INPUT_PATH=/input
      - OUTPUT_PATH=/output
    networks:
      - ml-pipeline

  # Model training
  trainer:
    build: ./training
    volumes:
      - processed_data:/data
      - model_artifacts:/models
      - ./logs:/logs
    environment:
      - DATA_PATH=/data
      - MODEL_PATH=/models
      - MLFLOW_TRACKING_URI=http://mlflow:5000
    depends_on:
      - preprocessor
      - mlflow
    networks:
      - ml-pipeline

  # MLflow tracking server
  mlflow:
    image: python:3.9
    command: >
      bash -c "pip install mlflow psycopg2-binary &&
               mlflow server --host 0.0.0.0 --port 5000 
               --backend-store-uri postgresql://postgres:password@mlflow-db:5432/mlflow
               --default-artifact-root /artifacts"
    ports:
      - "5000:5000"
    volumes:
      - mlflow_artifacts:/artifacts
    depends_on:
      - mlflow-db
    networks:
      - ml-pipeline

  # MLflow database
  mlflow-db:
    image: postgres:13
    environment:
      - POSTGRES_DB=mlflow
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - mlflow_db_data:/var/lib/postgresql/data
    networks:
      - ml-pipeline

  # Model serving
  model-server:
    build: ./serving
    ports:
      - "8080:8080"
    volumes:
      - model_artifacts:/models
    environment:
      - MODEL_PATH=/models
    depends_on:
      - trainer
    networks:
      - ml-pipeline

volumes:
  processed_data:
  model_artifacts:
  mlflow_artifacts:
  mlflow_db_data:

networks:
  ml-pipeline:
    driver: bridge
EOF

echo ""
echo "🎯 Solution 6: Environment Configuration"
echo "======================================="

cat << 'EOF'
# .env file
DATABASE_URL=postgresql://postgres:secret@db:5432/myapp
REDIS_URL=redis://redis:6379/0
SECRET_KEY=your-secret-key-here
DEBUG=1

# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    env_file:
      - .env
    environment:
      - FLASK_ENV=development  # Override .env values
    ports:
      - "${WEB_PORT:-8000}:8000"

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=${DB_NAME:-myapp}
      - POSTGRES_PASSWORD=${DB_PASSWORD:-password}

# Multiple environment files
services:
  web:
    env_file:
      - .env          # Base configuration
      - .env.local    # Local overrides
      - .env.secrets  # Sensitive data
EOF

echo ""
echo "🎯 Solution 7: Health Checks and Dependencies"
echo "============================================="

cat << 'EOF'
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

  db:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    environment:
      - POSTGRES_PASSWORD=password

  redis:
    image: redis:alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3
EOF

echo ""
echo "🎯 Solution 8: Scaling and Load Balancing"
echo "========================================"

cat << 'EOF'
# docker-compose.yml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web

  web:
    build: .
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
    depends_on:
      - db

  db:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD=password

# nginx.conf for load balancing
upstream web_servers {
    server web_1:8000;
    server web_2:8000;
    server web_3:8000;
}

server {
    listen 80;
    location / {
        proxy_pass http://web_servers;
    }
}

# Scale web service:
# docker-compose up -d --scale web=3
EOF

echo ""
echo "🎯 Solution 9: Secrets Management"
echo "================================"

cat << 'EOF'
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    secrets:
      - db_password
      - api_key
    environment:
      - DATABASE_PASSWORD_FILE=/run/secrets/db_password
      - API_KEY_FILE=/run/secrets/api_key

  db:
    image: postgres:13
    secrets:
      - db_password
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    external: true  # Managed externally

# Create secrets directory
# mkdir secrets
# echo "supersecretpassword" > secrets/db_password.txt
# chmod 600 secrets/db_password.txt
EOF

echo ""
echo "🎯 Solution 10: Monitoring and Logging"
echo "====================================="

cat << 'EOF'
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.web.rule=Host(`myapp.local`)"

  # Prometheus monitoring
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

  # Grafana dashboards
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

  # Log aggregation
  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  kibana:
    image: kibana:7.14.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch

volumes:
  prometheus_data:
  grafana_data:
  elasticsearch_data:
EOF

echo ""
echo "🎯 Solution 11: Common Docker Compose Commands"
echo "=============================================="

cat << 'EOF'
# Basic operations
docker-compose up                    # Start services
docker-compose up -d                 # Start in background
docker-compose down                  # Stop services
docker-compose down -v               # Stop and remove volumes
docker-compose restart               # Restart services
docker-compose pause                 # Pause services
docker-compose unpause               # Unpause services

# Building and pulling
docker-compose build                 # Build images
docker-compose build --no-cache      # Build without cache
docker-compose pull                  # Pull latest images
docker-compose up --build            # Build and start

# Service management
docker-compose start service-name    # Start specific service
docker-compose stop service-name     # Stop specific service
docker-compose restart service-name  # Restart specific service
docker-compose logs service-name     # View service logs
docker-compose logs -f service-name  # Follow logs

# Scaling
docker-compose up --scale web=3      # Scale web service to 3 instances
docker-compose up --scale web=3 --scale worker=2

# Execution
docker-compose exec service-name bash           # Execute bash in service
docker-compose exec service-name python app.py # Execute command
docker-compose run service-name command         # Run one-off command

# Information
docker-compose ps                    # List services
docker-compose top                   # Show running processes
docker-compose config                # Validate and view config
docker-compose images                # List images
docker-compose port service-name 80  # Show port mapping

# Multiple compose files
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Environment-specific
docker-compose --env-file .env.prod up -d
EOF

echo ""
echo "🎯 Solution 12: Troubleshooting"
echo "==============================="

cat << 'EOF'
# Debug compose file syntax
docker-compose config

# Check service status
docker-compose ps

# View service logs
docker-compose logs service-name
docker-compose logs --tail=50 service-name

# Test network connectivity
docker-compose exec service1 ping service2
docker-compose exec service1 nslookup service2

# Check environment variables
docker-compose exec service-name env

# Inspect volumes
docker volume ls
docker volume inspect project_volume-name

# Check port bindings
docker-compose port service-name 8000

# Resource usage
docker stats $(docker-compose ps -q)

# Recreate services
docker-compose up --force-recreate

# Remove everything
docker-compose down --rmi all --volumes --remove-orphans

# Common issues:
# 1. Port conflicts: Change host port in compose file
# 2. Volume permissions: Check file ownership and permissions
# 3. Network issues: Verify service names and network configuration
# 4. Environment variables: Check .env file and environment section
# 5. Build context: Ensure Dockerfile and build context are correct
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key Docker Compose concepts mastered:"
echo "✅ Multi-container application orchestration"
echo "✅ Service definitions and dependencies"
echo "✅ Network and volume configuration"
echo "✅ Environment variable management"
echo "✅ Health checks and scaling"
echo "✅ Development vs production configurations"
echo "✅ Secrets and security best practices"
echo ""
echo "💡 Remember:"
echo "   - Use specific image versions in production"
echo "   - Implement health checks for all services"
echo "   - Use secrets for sensitive data"
echo "   - Configure resource limits for production"
echo "   - Use override files for environment-specific configs"
echo "   - Always validate compose files with 'docker-compose config'"
