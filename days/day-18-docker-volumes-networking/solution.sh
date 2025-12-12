#!/bin/bash

# Day 18: Docker Volumes and Networking - Solution Guide
# Reference solutions for advanced Docker storage and networking

echo "📚 Day 18: Docker Volumes and Networking - Solution Guide"
echo "========================================================="

echo ""
echo "🎯 Solution 1: Volume Management"
echo "==============================="

cat << 'EOF'
# Volume Types and Usage

# Named Volumes (Docker-managed)
docker volume create mydata
docker run -v mydata:/app/data nginx:alpine

# Bind Mounts (Host path mapping)
docker run -v $(pwd):/app nginx:alpine
docker run -v /host/config:/etc/app/config:ro nginx:alpine

# Anonymous Volumes (Temporary)
docker run -v /tmp nginx:alpine

# tmpfs Mounts (In-memory, Linux only)
docker run --tmpfs /tmp:rw,size=100m nginx:alpine

# Volume Management Commands
docker volume ls                    # List volumes
docker volume create volume-name    # Create volume
docker volume inspect volume-name   # Inspect volume
docker volume rm volume-name        # Remove volume
docker volume prune                 # Remove unused volumes

# Volume with specific driver options
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfs-volume
EOF

echo ""
echo "🎯 Solution 2: Data Persistence Patterns"
echo "========================================"

cat << 'EOF'
# Database Persistence
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=password \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:13

# Application Data Persistence
docker run -d \
  --name app \
  -v app_data:/app/data \
  -v app_logs:/var/log/app \
  myapp:latest

# Configuration Management
docker run -d \
  --name nginx \
  -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v $(pwd)/ssl:/etc/ssl:ro \
  nginx:alpine

# Shared Data Between Containers
docker volume create shared_data
docker run -d --name producer -v shared_data:/output producer:latest
docker run -d --name consumer -v shared_data:/input consumer:latest

# Development Workflow
docker run -d \
  --name dev-app \
  -v $(pwd)/src:/app/src \
  -v $(pwd)/config:/app/config \
  -v node_modules:/app/node_modules \
  -p 3000:3000 \
  node:16
EOF

echo ""
echo "🎯 Solution 3: Volume Backup and Restore"
echo "========================================"

cat << 'EOF'
# Backup Volume to Archive
docker run --rm \
  -v source_volume:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup-$(date +%Y%m%d).tar.gz -C /data .

# Restore Volume from Archive
docker volume create restored_volume
docker run --rm \
  -v restored_volume:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/backup-20240101.tar.gz -C /data

# Copy Between Volumes
docker run --rm \
  -v source_volume:/source \
  -v target_volume:/target \
  alpine cp -r /source/. /target/

# Backup to Cloud Storage (AWS S3)
docker run --rm \
  -v source_volume:/data \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  amazon/aws-cli s3 sync /data s3://my-backup-bucket/

# Database Backup
docker exec postgres pg_dump -U postgres mydb > backup.sql
docker run --rm \
  -v postgres_data:/var/lib/postgresql/data \
  -v $(pwd):/backup \
  postgres:13 pg_dump -U postgres -f /backup/db-backup.sql mydb
EOF

echo ""
echo "🎯 Solution 4: Network Management"
echo "================================="

cat << 'EOF'
# Network Types and Creation

# Bridge Network (Default)
docker network create mynetwork
docker network create --driver bridge mynetwork

# Custom Subnet
docker network create --subnet=172.20.0.0/16 mynetwork

# Host Network (No isolation)
docker run --network host nginx:alpine

# None Network (No networking)
docker run --network none alpine

# Network Management Commands
docker network ls                           # List networks
docker network create network-name          # Create network
docker network inspect network-name         # Inspect network
docker network connect network-name container # Connect container
docker network disconnect network-name container # Disconnect
docker network rm network-name              # Remove network
docker network prune                        # Remove unused networks

# Advanced Network Configuration
docker network create \
  --driver bridge \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  --ip-range=172.20.240.0/20 \
  mynetwork

# Run container with specific IP
docker run -d --network mynetwork --ip 172.20.0.10 nginx:alpine
EOF

echo ""
echo "🎯 Solution 5: Multi-Tier Architecture"
echo "======================================"

cat << 'EOF'
# Docker Compose Multi-Tier Setup
version: '3.8'

services:
  # Frontend (Public network only)
  frontend:
    image: nginx:alpine
    ports:
      - "80:80"
    networks:
      - frontend
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro

  # Application (Both networks)
  app:
    build: .
    networks:
      - frontend
      - backend
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
    depends_on:
      - db

  # Database (Backend network only)
  db:
    image: postgres:13
    networks:
      - backend
    environment:
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # Cache (Backend network only)
  redis:
    image: redis:alpine
    networks:
      - backend
    volumes:
      - redis_data:/data

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access

volumes:
  postgres_data:
  redis_data:

# Manual Network Setup
docker network create frontend
docker network create --internal backend

docker run -d --name db --network backend postgres:13
docker run -d --name app --network backend --network frontend myapp:latest
docker run -d --name nginx --network frontend -p 80:80 nginx:alpine
EOF

echo ""
echo "🎯 Solution 6: Network Security"
echo "==============================="

cat << 'EOF'
# Network Isolation Patterns

# DMZ Network Architecture
docker network create dmz
docker network create internal --internal

# Web server in DMZ
docker run -d --name web --network dmz -p 80:80 nginx:alpine

# App server in both networks
docker run -d --name app --network dmz --network internal myapp:latest

# Database in internal only
docker run -d --name db --network internal postgres:13

# Firewall Rules (iptables)
# Block container access to host network
iptables -I DOCKER-USER -s 172.17.0.0/16 -d 192.168.1.0/24 -j DROP

# Allow specific container access
iptables -I DOCKER-USER -s 172.17.0.2 -d 192.168.1.100 -p tcp --dport 5432 -j ACCEPT

# Container Security
docker run -d \
  --name secure-app \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --read-only \
  --tmpfs /tmp \
  --user 1000:1000 \
  myapp:latest

# Network Policies (Docker Swarm)
docker network create \
  --driver overlay \
  --opt encrypted \
  secure-overlay
EOF

echo ""
echo "🎯 Solution 7: Performance Optimization"
echo "======================================="

cat << 'EOF'
# Volume Performance Optimization

# Use tmpfs for temporary data
docker run --tmpfs /tmp:rw,noexec,nosuid,size=1g myapp:latest

# Optimize bind mounts (macOS)
docker run -v $(pwd):/app:cached myapp:latest

# Use volume drivers for performance
docker volume create --driver local \
  --opt type=tmpfs \
  --opt device=tmpfs \
  --opt o=size=1g \
  fast-volume

# SSD-optimized volume
docker volume create --driver local \
  --opt type=none \
  --opt o=bind \
  --opt device=/fast/ssd/path \
  ssd-volume

# Network Performance Optimization

# Host networking for performance-critical apps
docker run --network host myapp:latest

# Optimize bridge network
docker network create \
  --opt com.docker.network.bridge.enable_icc=true \
  --opt com.docker.network.bridge.enable_ip_masquerade=true \
  optimized-bridge

# Use overlay networks for multi-host
docker network create --driver overlay --attachable multi-host

# Container Resource Limits
docker run -d \
  --memory=1g \
  --cpus="1.5" \
  --blkio-weight=500 \
  myapp:latest
EOF

echo ""
echo "🎯 Solution 8: Monitoring and Troubleshooting"
echo "============================================="

cat << 'EOF'
# Volume Monitoring

# Check volume usage
docker system df -v

# Find containers using volume
docker ps -a --filter volume=volume-name

# Inspect volume mount points
docker inspect container-name | jq '.[0].Mounts'

# Monitor volume I/O
docker stats --format "table {{.Container}}\t{{.BlockIO}}"

# Network Troubleshooting

# Test connectivity
docker exec container1 ping container2
docker exec container1 telnet container2 5432

# Check DNS resolution
docker exec container1 nslookup container2
docker exec container1 dig container2

# Inspect network configuration
docker network inspect network-name
docker inspect container-name | jq '.[0].NetworkSettings'

# Check port bindings
docker port container-name
netstat -tulpn | grep :8080

# Network packet capture
docker exec container1 tcpdump -i eth0 -w /tmp/capture.pcap

# Debug network issues
# 1. Check container logs
docker logs container-name

# 2. Verify network connectivity
docker exec container1 ping 8.8.8.8

# 3. Check DNS resolution
docker exec container1 cat /etc/resolv.conf

# 4. Verify service discovery
docker exec container1 getent hosts service-name

# 5. Check firewall rules
iptables -L DOCKER-USER
EOF

echo ""
echo "🎯 Solution 9: Production Patterns"
echo "=================================="

cat << 'EOF'
# High Availability Storage

# Distributed storage with Docker Swarm
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
      encrypted: "true"

# Network Load Balancing
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    configs:
      - source: nginx_config
        target: /etc/nginx/nginx.conf
    networks:
      - frontend

  app:
    image: myapp:latest
    networks:
      - frontend
      - backend
    deploy:
      replicas: 5
      update_config:
        parallelism: 2
        delay: 10s

networks:
  frontend:
    external: true
  backend:
    driver: overlay
    encrypted: true

# Backup Strategy
#!/bin/bash
# backup-volumes.sh

BACKUP_DIR="/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup all named volumes
for volume in $(docker volume ls -q); do
    echo "Backing up volume: $volume"
    docker run --rm \
        -v "$volume":/source:ro \
        -v "$BACKUP_DIR":/backup \
        alpine tar czf "/backup/${volume}.tar.gz" -C /source .
done

# Upload to cloud storage
aws s3 sync "$BACKUP_DIR" "s3://my-backup-bucket/$(date +%Y%m%d)/"
EOF

echo ""
echo "🎯 Solution 10: Docker Compose Advanced Patterns"
echo "==============================================="

cat << 'EOF'
# Complete Production Stack
version: '3.8'

services:
  # Load Balancer
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx:/etc/nginx/conf.d:ro
      - ./ssl:/etc/ssl:ro
      - nginx_logs:/var/log/nginx
    networks:
      - frontend
    depends_on:
      - app

  # Application
  app:
    image: myapp:${VERSION:-latest}
    environment:
      - DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@db:5432/myapp
      - REDIS_URL=redis://redis:6379/0
    volumes:
      - app_data:/app/data
      - app_logs:/app/logs
    networks:
      - frontend
      - backend
    depends_on:
      - db
      - redis
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M

  # Database
  db:
    image: postgres:13
    environment:
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    networks:
      - backend
    deploy:
      resources:
        limits:
          memory: 2G

  # Cache
  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
    networks:
      - backend
    command: redis-server --appendonly yes

  # Monitoring
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    networks:
      - monitoring
    ports:
      - "9090:9090"

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  app_data:
    driver: local
  app_logs:
    driver: local
  nginx_logs:
    driver: local
  prometheus_data:
    driver: local

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
  monitoring:
    driver: bridge
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key Docker volumes and networking concepts mastered:"
echo "✅ Volume types and management strategies"
echo "✅ Data persistence and backup/restore"
echo "✅ Custom network configuration and security"
echo "✅ Multi-tier architecture implementation"
echo "✅ Performance optimization techniques"
echo "✅ Production deployment patterns"
echo "✅ Monitoring and troubleshooting methods"
echo ""
echo "💡 Remember:"
echo "   - Use named volumes for persistent data"
echo "   - Implement network segmentation for security"
echo "   - Regular backup strategies are essential"
echo "   - Monitor volume and network performance"
echo "   - Use appropriate volume drivers for your use case"
echo "   - Test network connectivity and isolation"
