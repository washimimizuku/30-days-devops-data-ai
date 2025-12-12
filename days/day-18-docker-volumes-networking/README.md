# Day 18: Docker Volumes and Networking

**Duration**: 1 hour  
**Prerequisites**: Days 15-17 (Docker Basics, Dockerfiles, Compose)

## Learning Objectives

By the end of this lesson, you will:
- Master Docker volume types and use cases
- Configure custom networks for container communication
- Implement data persistence strategies
- Secure container networking
- Optimize data sharing between containers
- Troubleshoot volume and network issues

## Docker Volumes

### Volume Types

**1. Anonymous Volumes**
```bash
# Created automatically, Docker manages location
docker run -v /app/data nginx:alpine
```

**2. Named Volumes**
```bash
# Docker manages, but you name it
docker volume create mydata
docker run -v mydata:/app/data nginx:alpine
```

**3. Bind Mounts**
```bash
# Direct host path mapping
docker run -v /host/path:/container/path nginx:alpine
docker run -v $(pwd):/app nginx:alpine
```

**4. tmpfs Mounts**
```bash
# In-memory filesystem (Linux only)
docker run --tmpfs /tmp nginx:alpine
```

### Volume Management Commands

```bash
# List volumes
docker volume ls

# Create volume
docker volume create volume-name

# Inspect volume
docker volume inspect volume-name

# Remove volume
docker volume rm volume-name

# Remove unused volumes
docker volume prune

# Remove all volumes
docker volume rm $(docker volume ls -q)
```

### Volume Use Cases

**Data Persistence**
```bash
# Database data
docker run -d -v postgres_data:/var/lib/postgresql/data postgres:13

# Application logs
docker run -d -v app_logs:/var/log/app myapp:latest
```

**Development Workflow**
```bash
# Live code reloading
docker run -d -v $(pwd)/src:/app/src -p 8000:8000 myapp:dev

# Shared configuration
docker run -d -v $(pwd)/config:/etc/myapp/config myapp:latest
```

**Data Sharing Between Containers**
```bash
# Shared volume
docker volume create shared_data
docker run -d -v shared_data:/data producer:latest
docker run -d -v shared_data:/data consumer:latest
```

## Docker Networking

### Network Types

**1. Bridge Network (Default)**
- Isolated network on single host
- Containers can communicate via container names
- NAT for external access

**2. Host Network**
- Container uses host's network stack
- No network isolation
- Better performance

**3. None Network**
- No network access
- Complete isolation

**4. Custom Bridge Networks**
- User-defined networks
- Better isolation and DNS resolution

### Network Commands

```bash
# List networks
docker network ls

# Create network
docker network create mynetwork
docker network create --driver bridge mynetwork

# Inspect network
docker network inspect mynetwork

# Connect container to network
docker network connect mynetwork container-name

# Disconnect container from network
docker network disconnect mynetwork container-name

# Remove network
docker network rm mynetwork

# Remove unused networks
docker network prune
```

### Custom Network Configuration

```bash
# Create network with custom subnet
docker network create --subnet=172.20.0.0/16 mynetwork

# Create network with gateway
docker network create --gateway=172.20.0.1 --subnet=172.20.0.0/16 mynetwork

# Run container with specific IP
docker run -d --network mynetwork --ip 172.20.0.10 nginx:alpine
```

## Advanced Volume Patterns

### Volume Drivers

**Local Driver (Default)**
```bash
docker volume create --driver local myvolume
```

**NFS Driver**
```bash
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfs-volume
```

**Cloud Storage**
```bash
# AWS EFS
docker volume create --driver rexray/efs efs-volume

# Azure Files
docker volume create --driver rexray/azurefile azure-volume
```

### Volume Backup and Restore

**Backup Volume**
```bash
# Create backup container
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /data .
```

**Restore Volume**
```bash
# Restore from backup
docker run --rm \
  -v myvolume:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /data
```

**Copy Between Volumes**
```bash
# Copy data between volumes
docker run --rm \
  -v source_volume:/source \
  -v target_volume:/target \
  alpine cp -r /source/. /target/
```

## Advanced Networking Patterns

### Multi-Host Networking

**Overlay Networks**
```bash
# Initialize swarm mode
docker swarm init

# Create overlay network
docker network create --driver overlay myoverlay

# Deploy service on overlay network
docker service create --network myoverlay nginx:alpine
```

**External Networks**
```bash
# Connect to existing network
docker network create --external mynetwork
```

### Network Security

**Network Isolation**
```bash
# Create isolated networks
docker network create frontend
docker network create backend

# Web server on both networks
docker run -d --network frontend --network backend web:latest

# Database only on backend
docker run -d --network backend postgres:13
```

**Firewall Rules**
```bash
# Restrict container access
docker run -d --cap-drop ALL --cap-add NET_BIND_SERVICE nginx:alpine

# Custom iptables rules
iptables -I DOCKER-USER -s 172.17.0.0/16 -d 192.168.1.0/24 -j DROP
```

## Docker Compose Volume and Network Examples

### Volume Configuration
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    volumes:
      # Named volume
      - web_data:/var/www/html
      # Bind mount
      - ./config:/etc/nginx/conf.d
      # Anonymous volume
      - /var/log/nginx
      # Read-only mount
      - ./static:/usr/share/nginx/html:ro

  db:
    image: postgres:13
    volumes:
      # Named volume for persistence
      - postgres_data:/var/lib/postgresql/data
      # Initialization scripts
      - ./init:/docker-entrypoint-initdb.d:ro
    environment:
      - POSTGRES_PASSWORD=password

volumes:
  web_data:
    driver: local
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /host/postgres/data
```

### Network Configuration
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    networks:
      - frontend
      - backend
    ports:
      - "80:80"

  api:
    image: myapi:latest
    networks:
      - backend
    depends_on:
      - db

  db:
    image: postgres:13
    networks:
      - backend
    environment:
      - POSTGRES_PASSWORD=password

networks:
  frontend:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
  backend:
    driver: bridge
    internal: true  # No external access
```

## Data Science Volume Patterns

### Jupyter with Persistent Storage
```yaml
version: '3.8'

services:
  jupyter:
    image: jupyter/scipy-notebook
    ports:
      - "8888:8888"
    volumes:
      # Notebooks persistence
      - jupyter_notebooks:/home/jovyan/work
      # Data directory
      - ./data:/home/jovyan/data:ro
      # Custom packages
      - pip_cache:/home/jovyan/.cache/pip
    environment:
      - JUPYTER_ENABLE_LAB=yes

  postgres:
    image: postgres:13
    volumes:
      # Database persistence
      - postgres_data:/var/lib/postgresql/data
      # Backup directory
      - ./backups:/backups
    environment:
      - POSTGRES_DB=analytics
      - POSTGRES_PASSWORD=password

volumes:
  jupyter_notebooks:
  postgres_data:
  pip_cache:
```

### ML Pipeline with Shared Data
```yaml
version: '3.8'

services:
  data-processor:
    build: ./processor
    volumes:
      - raw_data:/input:ro
      - processed_data:/output
    networks:
      - ml-pipeline

  trainer:
    build: ./trainer
    volumes:
      - processed_data:/data:ro
      - model_artifacts:/models
      - training_logs:/logs
    networks:
      - ml-pipeline
    depends_on:
      - data-processor

  model-server:
    build: ./server
    volumes:
      - model_artifacts:/models:ro
    ports:
      - "8080:8080"
    networks:
      - ml-pipeline
      - public
    depends_on:
      - trainer

volumes:
  raw_data:
  processed_data:
  model_artifacts:
  training_logs:

networks:
  ml-pipeline:
    internal: true
  public:
    driver: bridge
```

## Performance Optimization

### Volume Performance
```bash
# Use tmpfs for temporary data
docker run --tmpfs /tmp:rw,noexec,nosuid,size=1g myapp:latest

# Optimize bind mounts
docker run -v $(pwd):/app:cached myapp:latest  # macOS optimization

# Use volume drivers for better performance
docker volume create --driver local \
  --opt type=tmpfs \
  --opt device=tmpfs \
  --opt o=size=1g \
  fast-volume
```

### Network Performance
```bash
# Use host networking for performance-critical apps
docker run --network host myapp:latest

# Optimize container communication
docker network create --opt com.docker.network.bridge.enable_icc=true mynetwork
```

## Monitoring and Troubleshooting

### Volume Monitoring
```bash
# Check volume usage
docker system df -v

# Inspect volume details
docker volume inspect volume-name

# Find containers using volume
docker ps -a --filter volume=volume-name

# Check volume mount points
docker inspect container-name | grep -A 10 "Mounts"
```

### Network Troubleshooting
```bash
# Test connectivity between containers
docker exec container1 ping container2

# Check network configuration
docker network inspect network-name

# View container network settings
docker inspect container-name | grep -A 20 "NetworkSettings"

# Debug DNS resolution
docker exec container-name nslookup service-name

# Check port bindings
docker port container-name
```

### Common Issues and Solutions

**Volume Permission Issues**
```bash
# Fix ownership in container
docker exec container-name chown -R user:group /data

# Use init containers to set permissions
docker run --rm -v myvolume:/data alpine chown -R 1000:1000 /data
```

**Network Connectivity Issues**
```bash
# Restart Docker daemon
sudo systemctl restart docker

# Recreate default bridge
docker network rm bridge
docker network create bridge

# Check firewall rules
iptables -L DOCKER-USER
```

## Security Best Practices

### Volume Security
```bash
# Use read-only mounts when possible
docker run -v $(pwd)/config:/etc/app:ro myapp:latest

# Avoid mounting sensitive host paths
# Don't: -v /:/host
# Do: -v /specific/path:/container/path

# Use secrets for sensitive data
echo "password" | docker secret create db_password -
```

### Network Security
```bash
# Use custom networks instead of default bridge
docker network create --internal backend-only

# Implement network segmentation
docker network create dmz
docker network create internal

# Use least privilege networking
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE myapp:latest
```

## Production Patterns

### High Availability Storage
```yaml
version: '3.8'

services:
  app:
    image: myapp:latest
    volumes:
      - app_data:/data
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.role == worker

volumes:
  app_data:
    driver: rexray/ebs
    driver_opts:
      size: 100
      volumetype: gp2
```

### Network Load Balancing
```yaml
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - frontend
    configs:
      - source: nginx_config
        target: /etc/nginx/nginx.conf

  app:
    image: myapp:latest
    networks:
      - frontend
      - backend
    deploy:
      replicas: 3

networks:
  frontend:
    external: true
  backend:
    internal: true

configs:
  nginx_config:
    external: true
```

## Next Steps

Tomorrow (Day 19) we'll learn container optimization and best practices, building on this storage and networking foundation.

## Key Takeaways

- Named volumes provide persistent, Docker-managed storage
- Bind mounts enable development workflows and host integration
- Custom networks improve security and service discovery
- Volume drivers extend storage capabilities to cloud and NFS
- Network isolation enhances security architecture
- Performance optimization requires understanding volume and network types
- Monitoring and troubleshooting tools help diagnose issues
- Security practices protect data and network access
