# Day 15: Docker Basics

**Duration**: 1 hour  
**Prerequisites**: Week 2 (Git & Version Control)

## Learning Objectives

By the end of this lesson, you will:
- Understand Docker concepts and architecture
- Install and configure Docker
- Run your first containers
- Understand images vs containers
- Use basic Docker commands
- Pull and run pre-built images

## Concepts

### What is Docker?

Docker is a containerization platform that packages applications and their dependencies into lightweight, portable containers.

**Key Benefits**:
- **Consistency**: "Works on my machine" → "Works everywhere"
- **Isolation**: Applications run in separate environments
- **Portability**: Run anywhere Docker is installed
- **Efficiency**: Share OS kernel, faster than VMs

### Docker Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Docker Client │────│  Docker Daemon  │
│   (docker CLI)  │    │   (dockerd)     │
└─────────────────┘    └─────────────────┘
                              │
                       ┌─────────────────┐
                       │  Container      │
                       │  Runtime        │
                       └─────────────────┘
```

**Components**:
- **Docker Client**: Command-line interface (CLI)
- **Docker Daemon**: Background service managing containers
- **Docker Images**: Read-only templates for containers
- **Docker Containers**: Running instances of images
- **Docker Registry**: Storage for images (Docker Hub)

### Images vs Containers

**Docker Image**:
- Read-only template
- Contains application code, runtime, libraries
- Built in layers for efficiency
- Stored in registries

**Docker Container**:
- Running instance of an image
- Writable layer on top of image
- Isolated process with own filesystem
- Can be started, stopped, deleted

```bash
# Image is like a class, Container is like an object
docker run python:3.9  # Creates container from python:3.9 image
```

## Installation

### macOS
```bash
# Install Docker Desktop
brew install --cask docker

# Or download from docker.com
# Start Docker Desktop application
```

### Linux (Ubuntu/Debian)
```bash
# Update package index
sudo apt update

# Install dependencies
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
sudo apt update
sudo apt install docker-ce

# Add user to docker group
sudo usermod -aG docker $USER
```

### Verify Installation
```bash
# Check Docker version
docker --version

# Test Docker installation
docker run hello-world
```

## Basic Docker Commands

### Image Management
```bash
# List local images
docker images
docker image ls

# Pull image from registry
docker pull python:3.9
docker pull nginx:alpine

# Remove image
docker rmi image_name
docker image rm image_id

# Search for images
docker search python
```

### Container Management
```bash
# Run container
docker run image_name
docker run -it python:3.9  # Interactive mode

# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop container
docker stop container_id

# Start stopped container
docker start container_id

# Remove container
docker rm container_id

# Remove all stopped containers
docker container prune
```

### Container Interaction
```bash
# Run command in container
docker exec -it container_id bash

# View container logs
docker logs container_id

# Copy files to/from container
docker cp file.txt container_id:/path/
docker cp container_id:/path/file.txt ./
```

## Running Your First Containers

### Hello World
```bash
# Run hello-world container
docker run hello-world

# What happens:
# 1. Docker looks for hello-world image locally
# 2. Downloads from Docker Hub if not found
# 3. Creates and runs container
# 4. Container prints message and exits
```

### Interactive Python Container
```bash
# Run Python interactively
docker run -it python:3.9

# Inside container:
>>> print("Hello from Docker!")
>>> import sys
>>> sys.version
>>> exit()
```

### Web Server Container
```bash
# Run Nginx web server
docker run -d -p 8080:80 nginx:alpine

# Flags explained:
# -d: Run in background (detached)
# -p 8080:80: Map host port 8080 to container port 80

# Visit http://localhost:8080 in browser
# Stop container: docker stop container_id
```

### Ubuntu Container
```bash
# Run Ubuntu container
docker run -it ubuntu:20.04 bash

# Inside container:
apt update
apt install -y python3 pip
python3 --version
exit
```

## Common Docker Flags

```bash
# -i: Interactive (keep STDIN open)
# -t: Allocate pseudo-TTY (terminal)
# -d: Detached (run in background)
# -p: Port mapping (host:container)
# -v: Volume mounting (host:container)
# -e: Environment variables
# --name: Container name
# --rm: Remove container when it exits

# Examples:
docker run -it --name my-python python:3.9
docker run -d -p 3000:3000 --name my-app node:16
docker run --rm -v $(pwd):/app python:3.9 python /app/script.py
```

## Working with Data

### Volume Mounting
```bash
# Mount current directory to container
docker run -it -v $(pwd):/workspace python:3.9 bash

# Inside container, /workspace contains host files
cd /workspace
ls -la
```

### Environment Variables
```bash
# Set environment variables
docker run -e DATABASE_URL=postgres://localhost:5432/db python:3.9

# Multiple variables
docker run -e VAR1=value1 -e VAR2=value2 python:3.9
```

## Data Science Containers

### Jupyter Notebook
```bash
# Run Jupyter notebook
docker run -p 8888:8888 jupyter/scipy-notebook

# With volume mounting for persistent notebooks
docker run -p 8888:8888 -v $(pwd):/home/jovyan/work jupyter/scipy-notebook
```

### Python Data Science Stack
```bash
# Run container with pandas, numpy, matplotlib
docker run -it python:3.9 bash

# Inside container:
pip install pandas numpy matplotlib jupyter
python -c "import pandas as pd; print(pd.__version__)"
```

### PostgreSQL Database
```bash
# Run PostgreSQL database
docker run -d \
  --name postgres-db \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=analytics \
  -p 5432:5432 \
  postgres:13

# Connect to database
docker exec -it postgres-db psql -U postgres -d analytics
```

## Container Lifecycle

### Container States
```
Created → Running → Paused → Stopped → Deleted
    ↑         ↓         ↑         ↓
    └─────────┴─────────┴─────────┘
```

### Lifecycle Commands
```bash
# Create container without starting
docker create --name my-container python:3.9

# Start created container
docker start my-container

# Pause running container
docker pause my-container

# Unpause container
docker unpause my-container

# Stop container gracefully
docker stop my-container

# Kill container forcefully
docker kill my-container

# Remove container
docker rm my-container
```

## Best Practices

### Resource Management
```bash
# Limit memory usage
docker run -m 512m python:3.9

# Limit CPU usage
docker run --cpus="1.5" python:3.9

# View resource usage
docker stats
```

### Container Naming
```bash
# Use meaningful names
docker run --name data-processor python:3.9
docker run --name web-server nginx:alpine
docker run --name postgres-dev postgres:13
```

### Cleanup
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove everything unused
docker system prune

# Remove everything (including volumes)
docker system prune -a --volumes
```

## Troubleshooting

### Common Issues
```bash
# Container exits immediately
docker run python:3.9  # Exits because no command specified
docker run python:3.9 python -c "print('Hello')"  # Runs and exits

# Port already in use
docker run -p 8080:80 nginx  # Error if 8080 is busy
docker run -p 8081:80 nginx  # Use different port

# Permission denied
sudo docker run hello-world  # If user not in docker group

# Container not found
docker ps -a  # List all containers to find correct ID/name
```

### Debugging
```bash
# View container logs
docker logs container_name

# Inspect container details
docker inspect container_name

# Execute commands in running container
docker exec -it container_name bash

# View processes in container
docker top container_name
```

## Docker Hub

### Finding Images
```bash
# Search for images
docker search python
docker search postgres
docker search jupyter

# Popular official images:
# - python, node, nginx, postgres, mysql
# - ubuntu, alpine, centos
# - jupyter/scipy-notebook, tensorflow/tensorflow
```

### Image Tags
```bash
# Specific versions
docker pull python:3.9
docker pull python:3.8-slim
docker pull postgres:13.4

# Latest version (default)
docker pull python:latest
docker pull python  # Same as python:latest
```

## Next Steps

Tomorrow (Day 16) we'll learn to create custom Docker images using Dockerfiles, building on these container fundamentals.

## Key Takeaways

- Docker containers provide consistent, isolated environments
- Images are templates, containers are running instances
- Use `-it` for interactive containers, `-d` for background services
- Volume mounting connects host and container filesystems
- Docker Hub provides thousands of pre-built images
- Proper cleanup prevents resource waste
- Containers are perfect for data science and development workflows
