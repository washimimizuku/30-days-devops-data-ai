#!/bin/bash

# Day 15: Docker Basics - Solution Guide
# Reference solutions for Docker fundamentals

echo "📚 Day 15: Docker Basics - Solution Guide"
echo "========================================="

echo ""
echo "🎯 Solution 1: Essential Docker Commands"
echo "======================================="

cat << 'EOF'
# Image Management
docker images                    # List local images
docker pull python:3.9         # Download image
docker rmi python:3.9          # Remove image
docker search python           # Search Docker Hub

# Container Lifecycle
docker run hello-world          # Run container
docker run -it python:3.9      # Interactive container
docker run -d nginx:alpine     # Background container
docker ps                      # List running containers
docker ps -a                   # List all containers
docker stop container_id       # Stop container
docker start container_id      # Start stopped container
docker rm container_id         # Remove container

# Container Interaction
docker exec -it container_id bash    # Execute command
docker logs container_id             # View logs
docker inspect container_id          # Detailed info
docker stats                         # Resource usage
EOF

echo ""
echo "🎯 Solution 2: Common Docker Run Patterns"
echo "========================================="

cat << 'EOF'
# Interactive Development
docker run -it --rm python:3.9 bash
docker run -it --rm -v $(pwd):/app python:3.9 bash

# Web Services
docker run -d -p 8080:80 --name web nginx:alpine
docker run -d -p 3000:3000 --name app node:16

# Databases
docker run -d --name postgres \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=mydb \
  -p 5432:5432 \
  postgres:13

docker run -d --name redis \
  -p 6379:6379 \
  redis:alpine

# Data Science
docker run -p 8888:8888 jupyter/scipy-notebook
docker run -it --rm -v $(pwd):/workspace python:3.9

# One-off Tasks
docker run --rm -v $(pwd):/app python:3.9 python /app/script.py
docker run --rm alpine:latest echo "Hello World"
EOF

echo ""
echo "🎯 Solution 3: Volume Mounting Patterns"
echo "======================================="

cat << 'EOF'
# Mount current directory
docker run -v $(pwd):/workspace python:3.9

# Mount specific directories
docker run -v /host/data:/container/data python:3.9
docker run -v ~/projects:/projects python:3.9

# Named volumes (persistent data)
docker volume create mydata
docker run -v mydata:/data postgres:13

# Read-only mounts
docker run -v $(pwd):/app:ro python:3.9

# Multiple mounts
docker run \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/config:/app/config \
  python:3.9
EOF

echo ""
echo "🎯 Solution 4: Environment Variables"
echo "===================================="

cat << 'EOF'
# Single environment variable
docker run -e DATABASE_URL=postgres://localhost/db python:3.9

# Multiple variables
docker run \
  -e DB_HOST=localhost \
  -e DB_PORT=5432 \
  -e DB_NAME=analytics \
  python:3.9

# Environment file
echo "DB_HOST=localhost" > .env
echo "DB_PORT=5432" >> .env
docker run --env-file .env python:3.9

# Common patterns
docker run -e PYTHONPATH=/app python:3.9
docker run -e NODE_ENV=production node:16
docker run -e POSTGRES_PASSWORD=secret postgres:13
EOF

echo ""
echo "🎯 Solution 5: Data Processing Workflows"
echo "========================================"

cat << 'EOF'
# CSV Processing
docker run --rm \
  -v $(pwd):/data \
  python:3.9 \
  python -c "
import csv
with open('/data/input.csv') as f:
    reader = csv.DictReader(f)
    data = list(reader)
print(f'Processed {len(data)} records')
"

# JSON Processing
docker run --rm \
  -v $(pwd):/data \
  python:3.9 \
  python -c "
import json
with open('/data/data.json') as f:
    data = json.load(f)
print(json.dumps(data, indent=2))
"

# Pandas Analysis
docker run --rm \
  -v $(pwd):/workspace \
  python:3.9 \
  bash -c "
pip install pandas numpy &&
python -c '
import pandas as pd
df = pd.read_csv(\"/workspace/data.csv\")
print(df.describe())
'"
EOF

echo ""
echo "🎯 Solution 6: Database Containers"
echo "================================="

cat << 'EOF'
# PostgreSQL
docker run -d --name postgres \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=analytics \
  -e POSTGRES_USER=analyst \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:13

# Connect to PostgreSQL
docker exec -it postgres psql -U analyst -d analytics

# MySQL
docker run -d --name mysql \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=analytics \
  -e MYSQL_USER=analyst \
  -e MYSQL_PASSWORD=password \
  -p 3306:3306 \
  mysql:8.0

# MongoDB
docker run -d --name mongo \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=password \
  -p 27017:27017 \
  mongo:5.0

# Redis
docker run -d --name redis \
  -p 6379:6379 \
  redis:alpine redis-server --appendonly yes
EOF

echo ""
echo "🎯 Solution 7: Development Environments"
echo "======================================"

cat << 'EOF'
# Python Development
docker run -it --rm \
  --name python-dev \
  -v $(pwd):/workspace \
  -w /workspace \
  python:3.9 bash

# Node.js Development
docker run -it --rm \
  --name node-dev \
  -v $(pwd):/app \
  -w /app \
  -p 3000:3000 \
  node:16 bash

# Jupyter Notebook
docker run -d --name jupyter \
  -p 8888:8888 \
  -v $(pwd):/home/jovyan/work \
  -e JUPYTER_ENABLE_LAB=yes \
  jupyter/scipy-notebook

# R Development
docker run -it --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  r-base:latest R
EOF

echo ""
echo "🎯 Solution 8: Container Networking"
echo "=================================="

cat << 'EOF'
# Create custom network
docker network create mynetwork

# Run containers on same network
docker run -d --name database --network mynetwork postgres:13
docker run -d --name app --network mynetwork python:3.9

# Containers can communicate using container names
# app can connect to database using hostname "database"

# List networks
docker network ls

# Inspect network
docker network inspect mynetwork

# Remove network
docker network rm mynetwork
EOF

echo ""
echo "🎯 Solution 9: Resource Management"
echo "================================="

cat << 'EOF'
# Memory limits
docker run -m 512m python:3.9              # 512MB limit
docker run -m 1g nginx:alpine              # 1GB limit

# CPU limits
docker run --cpus="1.5" python:3.9         # 1.5 CPU cores
docker run --cpus="0.5" nginx:alpine       # 0.5 CPU cores

# Combined limits
docker run -m 1g --cpus="2" python:3.9

# Monitor resource usage
docker stats                                # Live stats
docker stats --no-stream                   # One-time stats

# System resource usage
docker system df                            # Disk usage
docker system events                        # System events
EOF

echo ""
echo "🎯 Solution 10: Cleanup and Maintenance"
echo "======================================="

cat << 'EOF'
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Remove everything unused
docker system prune

# Remove everything including volumes
docker system prune -a --volumes

# Force removal
docker rm -f container_name                 # Force remove container
docker rmi -f image_name                   # Force remove image

# Bulk operations
docker stop $(docker ps -q)               # Stop all containers
docker rm $(docker ps -aq)                # Remove all containers
docker rmi $(docker images -q)            # Remove all images
EOF

echo ""
echo "🎯 Solution 11: Troubleshooting"
echo "==============================="

cat << 'EOF'
# Debug container startup issues
docker run --rm python:3.9 python --version    # Test command
docker logs container_name                      # Check logs
docker inspect container_name                   # Detailed info

# Debug networking issues
docker port container_name                      # Check port mappings
docker network ls                              # List networks
netstat -tulpn | grep :8080                   # Check if port is used

# Debug volume issues
docker inspect container_name | grep -A 10 Mounts
ls -la /host/path                              # Check host permissions

# Debug resource issues
docker stats container_name                     # Check resource usage
docker system df                               # Check disk usage

# Common fixes
docker restart container_name                   # Restart container
docker system prune                            # Clean up resources
docker pull image_name                         # Update image
EOF

echo ""
echo "🎯 Solution 12: Best Practices"
echo "=============================="

cat << 'EOF'
# Use specific image tags
docker run python:3.9-slim                    # Not python:latest

# Use meaningful container names
docker run --name web-server nginx:alpine

# Clean up after one-time tasks
docker run --rm python:3.9 python script.py

# Use read-only mounts when possible
docker run -v $(pwd):/app:ro python:3.9

# Set resource limits for production
docker run -m 1g --cpus="2" myapp:latest

# Use environment files for configuration
docker run --env-file .env myapp:latest

# Regular cleanup
docker system prune -f                        # Add to cron job

# Security considerations
docker run --user 1000:1000 python:3.9       # Non-root user
docker run --read-only python:3.9             # Read-only filesystem
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key Docker concepts mastered:"
echo "✅ Container lifecycle management"
echo "✅ Volume mounting for data persistence"
echo "✅ Environment variable configuration"
echo "✅ Port mapping for network access"
echo "✅ Resource monitoring and limits"
echo "✅ Cleanup and maintenance"
echo ""
echo "💡 Remember:"
echo "   - Always use specific image tags in production"
echo "   - Clean up unused resources regularly"
echo "   - Use meaningful container names"
echo "   - Set appropriate resource limits"
echo "   - Mount volumes for persistent data"
