# Day 17: Docker Compose

**Duration**: 1 hour  
**Prerequisites**: Days 15-16 (Docker Basics & Dockerfiles)

## Learning Objectives

By the end of this lesson, you will:
- Understand Docker Compose concepts and benefits
- Write docker-compose.yml files for multi-container applications
- Manage application stacks with compose commands
- Configure networks, volumes, and environment variables
- Build complete data science and web application stacks
- Use compose for development and production workflows

## Concepts

### What is Docker Compose?

Docker Compose is a tool for defining and running multi-container Docker applications using a YAML file.

**Benefits**:
- **Declarative**: Define entire application stack in one file
- **Reproducible**: Same environment across development, testing, production
- **Simplified**: Single command to start/stop entire application
- **Networking**: Automatic service discovery between containers
- **Scaling**: Easy horizontal scaling of services

### Docker Compose vs Docker Run

**Docker Run** (manual):
```bash
docker network create myapp-network
docker run -d --name database --network myapp-network postgres:13
docker run -d --name redis --network myapp-network redis:alpine
docker run -d --name api --network myapp-network -p 8000:8000 myapi:latest
```

**Docker Compose** (declarative):
```yaml
version: '3.8'
services:
  database:
    image: postgres:13
  redis:
    image: redis:alpine
  api:
    image: myapi:latest
    ports:
      - "8000:8000"
```

## Basic docker-compose.yml Structure

```yaml
version: '3.8'

services:
  service-name:
    image: image:tag
    # or
    build: ./path/to/dockerfile
    
    ports:
      - "host:container"
    
    environment:
      - VAR=value
    
    volumes:
      - host-path:container-path
    
    depends_on:
      - other-service

volumes:
  volume-name:

networks:
  network-name:
```

## Simple Examples

### Web Application with Database
```yaml
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
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

### Data Science Stack
```yaml
version: '3.8'

services:
  jupyter:
    image: jupyter/scipy-notebook
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/home/jovyan/work
      - ./data:/home/jovyan/data
    environment:
      - JUPYTER_ENABLE_LAB=yes
  
  postgres:
    image: postgres:13
    environment:
      - POSTGRES_DB=analytics
      - POSTGRES_USER=analyst
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
```

## Docker Compose Commands

### Basic Operations
```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# Stop services
docker-compose down

# View running services
docker-compose ps

# View logs
docker-compose logs
docker-compose logs service-name

# Build images
docker-compose build

# Pull images
docker-compose pull
```

### Service Management
```bash
# Start specific service
docker-compose up service-name

# Stop specific service
docker-compose stop service-name

# Restart service
docker-compose restart service-name

# Scale service
docker-compose up --scale web=3

# Execute command in service
docker-compose exec service-name bash
```

### Development Workflow
```bash
# Build and start
docker-compose up --build

# Recreate containers
docker-compose up --force-recreate

# Remove volumes
docker-compose down -v

# Remove everything
docker-compose down --rmi all --volumes --remove-orphans
```

## Advanced Configuration

### Environment Variables
```yaml
version: '3.8'

services:
  web:
    build: .
    environment:
      - DEBUG=1
      - DATABASE_URL=${DATABASE_URL}
    env_file:
      - .env
      - .env.local
```

**.env file**:
```env
DATABASE_URL=postgresql://user:pass@db:5432/myapp
REDIS_URL=redis://redis:6379/0
SECRET_KEY=your-secret-key
```

### Networks
```yaml
version: '3.8'

services:
  web:
    build: .
    networks:
      - frontend
      - backend
  
  db:
    image: postgres:13
    networks:
      - backend
  
  nginx:
    image: nginx:alpine
    networks:
      - frontend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
```

### Volumes
```yaml
version: '3.8'

services:
  web:
    build: .
    volumes:
      # Named volume
      - app_data:/app/data
      # Bind mount
      - ./src:/app/src
      # Anonymous volume
      - /app/node_modules

volumes:
  app_data:
    driver: local
```

### Health Checks
```yaml
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
  
  db:
    image: postgres:13
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
```

## Complete Data Analytics Stack

### Full-Stack Application
```yaml
version: '3.8'

services:
  # Web API
  api:
    build: ./api
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/analytics
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    volumes:
      - ./api:/app
    networks:
      - backend

  # Frontend
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:8000
    volumes:
      - ./frontend:/app
      - /app/node_modules
    networks:
      - frontend

  # Database
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=analytics
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - backend

  # Cache
  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
    networks:
      - backend

  # Jupyter for analysis
  jupyter:
    image: jupyter/scipy-notebook
    ports:
      - "8888:8888"
    environment:
      - JUPYTER_ENABLE_LAB=yes
    volumes:
      - ./notebooks:/home/jovyan/work
      - ./data:/home/jovyan/data
    networks:
      - backend

  # Reverse proxy
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - api
      - frontend
    networks:
      - frontend
      - backend

volumes:
  postgres_data:
  redis_data:

networks:
  frontend:
  backend:
```

### ML Training Pipeline
```yaml
version: '3.8'

services:
  # Data preprocessing
  preprocessor:
    build: ./preprocessing
    volumes:
      - ./data:/data
      - ./processed:/processed
    environment:
      - INPUT_PATH=/data
      - OUTPUT_PATH=/processed
    networks:
      - ml-pipeline

  # Model training
  trainer:
    build: ./training
    volumes:
      - ./processed:/data
      - ./models:/models
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

  # MLflow tracking
  mlflow:
    image: python:3.9
    command: >
      bash -c "pip install mlflow psycopg2-binary &&
               mlflow server --host 0.0.0.0 --port 5000 
               --backend-store-uri postgresql://postgres:password@db:5432/mlflow
               --default-artifact-root /artifacts"
    ports:
      - "5000:5000"
    volumes:
      - ./artifacts:/artifacts
    depends_on:
      - db
    networks:
      - ml-pipeline

  # Database for MLflow
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=mlflow
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - mlflow_db:/var/lib/postgresql/data
    networks:
      - ml-pipeline

volumes:
  mlflow_db:

networks:
  ml-pipeline:
```

## Development vs Production

### Development Configuration
```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app  # Live code reloading
    environment:
      - DEBUG=1
      - FLASK_ENV=development
```

### Production Override
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  web:
    image: myapp:latest  # Pre-built image
    restart: unless-stopped
    environment:
      - DEBUG=0
      - FLASK_ENV=production
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.prod.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
```

**Usage**:
```bash
# Development
docker-compose up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Best Practices

### Service Design
```yaml
version: '3.8'

services:
  web:
    build: .
    restart: unless-stopped  # Auto-restart on failure
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    depends_on:
      db:
        condition: service_healthy  # Wait for healthy database
    networks:
      - app-network

  db:
    image: postgres:13
    restart: unless-stopped
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    secrets:
      - db_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

secrets:
  db_password:
    file: ./secrets/db_password.txt

volumes:
  postgres_data:
    driver: local

networks:
  app-network:
    driver: bridge
```

### Resource Limits
```yaml
version: '3.8'

services:
  web:
    build: .
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
```

### Logging
```yaml
version: '3.8'

services:
  web:
    build: .
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## Troubleshooting

### Common Issues
```bash
# Service won't start
docker-compose logs service-name

# Network connectivity issues
docker-compose exec service-name ping other-service

# Volume mounting problems
docker-compose exec service-name ls -la /mounted/path

# Environment variable issues
docker-compose exec service-name env

# Port conflicts
docker-compose ps
netstat -tulpn | grep :8000
```

### Debugging Commands
```bash
# Validate compose file
docker-compose config

# Check service status
docker-compose ps

# Follow logs in real-time
docker-compose logs -f service-name

# Execute interactive shell
docker-compose exec service-name bash

# Inspect networks
docker network ls
docker network inspect project_default
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Deploy with Docker Compose

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy to server
        run: |
          docker-compose -f docker-compose.prod.yml pull
          docker-compose -f docker-compose.prod.yml up -d
          docker-compose -f docker-compose.prod.yml exec web python manage.py migrate
```

## Next Steps

Tomorrow (Day 18) we'll learn Docker volumes and networking in detail, building on this multi-container orchestration foundation.

## Key Takeaways

- Docker Compose simplifies multi-container application management
- YAML configuration is declarative and version-controlled
- Services automatically discover each other via service names
- Environment-specific configurations use override files
- Health checks and restart policies improve reliability
- Volumes provide data persistence across container restarts
- Networks enable secure service communication
