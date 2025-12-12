#!/bin/bash

# Day 20: Production Deployment - Solution Guide
# Reference solutions for production deployment strategies

echo "📚 Day 20: Production Deployment - Solution Guide"
echo "================================================="

echo ""
echo "🎯 Solution 1: Rolling Deployment"
echo "================================="

cat << 'EOF'
# Docker Swarm Rolling Deployment
version: '3.8'

services:
  web:
    image: myapp:${VERSION}
    deploy:
      replicas: 5
      update_config:
        parallelism: 2          # Update 2 containers at a time
        delay: 10s             # Wait 10s between batches
        failure_action: rollback
        monitor: 60s           # Monitor for 60s after update
        max_failure_ratio: 0.2 # Rollback if >20% fail
      rollback_config:
        parallelism: 1
        delay: 5s
        failure_action: pause
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3

# Kubernetes Rolling Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1    # Max 1 pod unavailable during update
      maxSurge: 1         # Max 1 extra pod during update
  template:
    spec:
      containers:
      - name: myapp
        image: myapp:v2.0.0
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5

# Rolling Deployment Commands
# Deploy new version
docker service update --image myapp:v2.0.0 myapp_web

# Monitor deployment
docker service ps myapp_web

# Rollback if needed
docker service rollback myapp_web
EOF

echo ""
echo "🎯 Solution 2: Blue-Green Deployment"
echo "===================================="

cat << 'EOF'
# Blue-Green Deployment Script
#!/bin/bash

NEW_VERSION=$1
CURRENT_ENV=$(docker service inspect myapp --format '{{.Spec.Labels.environment}}' 2>/dev/null || echo "blue")

if [ "$CURRENT_ENV" = "blue" ]; then
    NEW_ENV="green"
    OLD_ENV="blue"
else
    NEW_ENV="blue"
    OLD_ENV="green"
fi

echo "Deploying $NEW_VERSION to $NEW_ENV environment"

# Deploy to new environment
docker service create \
    --name myapp-$NEW_ENV \
    --label environment=$NEW_ENV \
    --replicas 3 \
    --network production \
    --health-cmd "curl -f http://localhost:8080/health || exit 1" \
    --health-interval 30s \
    --health-retries 3 \
    myapp:$NEW_VERSION

# Wait for health checks
echo "Waiting for health checks..."
sleep 60

# Verify deployment health
HEALTHY_REPLICAS=$(docker service ps myapp-$NEW_ENV --filter desired-state=running --format "{{.CurrentState}}" | grep -c "Running")

if [ "$HEALTHY_REPLICAS" -eq 3 ]; then
    echo "Health checks passed, switching traffic"
    
    # Update load balancer configuration
    # This could be updating nginx config, DNS, or load balancer rules
    update_load_balancer $NEW_ENV
    
    # Remove old environment
    docker service rm myapp-$OLD_ENV
    
    echo "Blue-green deployment completed successfully"
else
    echo "Health checks failed, rolling back"
    docker service rm myapp-$NEW_ENV
    exit 1
fi

# Docker Compose Blue-Green
version: '3.8'

services:
  web-blue:
    image: myapp:v1.0.0
    networks:
      - blue-network
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.web-blue.rule=Host(`myapp.com`) && Headers(`X-Environment`, `blue`)"

  web-green:
    image: myapp:v2.0.0
    networks:
      - green-network
    labels:
      - "traefik.enable=false"  # Initially disabled
      - "traefik.http.routers.web-green.rule=Host(`myapp.com`) && Headers(`X-Environment`, `green`)"

  traefik:
    image: traefik:v2.8
    command:
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

networks:
  blue-network:
  green-network:
EOF

echo ""
echo "🎯 Solution 3: Canary Deployment"
echo "================================"

cat << 'EOF'
# Canary Deployment with Traefik
version: '3.8'

services:
  web-stable:
    image: myapp:v1.0.0
    deploy:
      replicas: 9
      labels:
        - "traefik.http.services.web.loadbalancer.weight=90"
    networks:
      - web

  web-canary:
    image: myapp:v2.0.0
    deploy:
      replicas: 1
      labels:
        - "traefik.http.services.web.loadbalancer.weight=10"
    networks:
      - web

  traefik:
    image: traefik:v2.8
    command:
      - "--providers.docker=true"
      - "--providers.docker.swarmMode=true"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - web

# Nginx Canary Configuration
upstream backend {
    server web-stable:8080 weight=90;
    server web-canary:8080 weight=10;
}

# Istio Canary Deployment
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: myapp
spec:
  http:
  - match:
    - headers:
        canary:
          exact: "true"
    route:
    - destination:
        host: myapp
        subset: canary
  - route:
    - destination:
        host: myapp
        subset: stable
      weight: 90
    - destination:
        host: myapp
        subset: canary
      weight: 10

# Canary Deployment Script
#!/bin/bash

CANARY_PERCENTAGE=${1:-10}
NEW_VERSION=$2

echo "Starting canary deployment: $CANARY_PERCENTAGE% traffic to $NEW_VERSION"

# Deploy canary version
kubectl set image deployment/myapp-canary myapp=myapp:$NEW_VERSION

# Update traffic split
kubectl patch virtualservice myapp --type='json' -p="[
  {
    'op': 'replace',
    'path': '/spec/http/1/route/1/weight',
    'value': $CANARY_PERCENTAGE
  },
  {
    'op': 'replace',
    'path': '/spec/http/1/route/0/weight',
    'value': $((100 - CANARY_PERCENTAGE))
  }
]"

echo "Canary deployment active: $CANARY_PERCENTAGE% traffic to new version"
EOF

echo ""
echo "🎯 Solution 4: CI/CD Pipeline"
echo "============================="

cat << 'EOF'
# GitHub Actions Production Pipeline
name: Production Deployment

on:
  push:
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    outputs:
      image: ${{ steps.image.outputs.image }}
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
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Run tests
        run: |
          docker run --rm ${{ steps.meta.outputs.tags }} python -m pytest
      
      - name: Output image
        id: image
        run: echo "image=${{ steps.meta.outputs.tags }}" >> $GITHUB_OUTPUT

  security-scan:
    needs: build-and-test
    runs-on: ubuntu-latest
    steps:
      - name: Scan image
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ needs.build-and-test.outputs.image }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          exit-code: '1'
          severity: 'CRITICAL,HIGH'

  deploy-staging:
    needs: [build-and-test, security-scan]
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          # Deploy to staging environment
          kubectl set image deployment/myapp myapp=${{ needs.build-and-test.outputs.image }}
          kubectl rollout status deployment/myapp
      
      - name: Run integration tests
        run: |
          # Run integration tests against staging
          ./scripts/integration-tests.sh

  deploy-production:
    needs: [build-and-test, security-scan, deploy-staging]
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Blue-Green Deployment
        run: |
          ./scripts/blue-green-deploy.sh ${{ needs.build-and-test.outputs.image }}
      
      - name: Verify deployment
        run: |
          # Verify production deployment
          curl -f https://myapp.com/health

# GitLab CI/CD Pipeline
stages:
  - build
  - test
  - security
  - deploy-staging
  - deploy-production

variables:
  DOCKER_DRIVER: overlay2

build:
  stage: build
  image: docker:20.10.16
  services:
    - docker:20.10.16-dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
  only:
    - tags

test:
  stage: test
  image: docker:20.10.16
  script:
    - docker run --rm $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG python -m pytest
  only:
    - tags

security-scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --exit-code 1 --severity HIGH,CRITICAL $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
  only:
    - tags

deploy-staging:
  stage: deploy-staging
  script:
    - kubectl set image deployment/myapp myapp=$CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
    - kubectl rollout status deployment/myapp
  environment:
    name: staging
    url: https://staging.myapp.com
  only:
    - tags

deploy-production:
  stage: deploy-production
  script:
    - ./scripts/blue-green-deploy.sh $CI_REGISTRY_IMAGE:$CI_COMMIT_TAG
  environment:
    name: production
    url: https://myapp.com
  when: manual
  only:
    - tags
EOF

echo ""
echo "🎯 Solution 5: Monitoring and Observability"
echo "==========================================="

cat << 'EOF'
# Production Monitoring Stack
version: '3.8'

services:
  # Application
  app:
    image: myapp:latest
    deploy:
      replicas: 3
    networks:
      - app-network
      - monitoring

  # Prometheus
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  # Grafana
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
    networks:
      - monitoring

  # Alertmanager
  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
    networks:
      - monitoring

  # Node Exporter
  node-exporter:
    image: prom/node-exporter:latest
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    networks:
      - monitoring

  # cAdvisor
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:

networks:
  app-network:
  monitoring:

# Prometheus Configuration
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

  - job_name: 'app'
    static_configs:
      - targets: ['app:8080']
    metrics_path: '/metrics'

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

# Alert Rules
groups:
  - name: application
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"

      - alert: HighMemoryUsage
        expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
EOF

echo ""
echo "🎯 Solution 6: Secrets Management"
echo "================================="

cat << 'EOF'
# Docker Secrets
# Create secrets
echo "supersecretpassword" | docker secret create db_password -
echo "api-key-12345" | docker secret create api_key -

# Use in service
version: '3.8'

services:
  web:
    image: myapp:latest
    secrets:
      - db_password
      - api_key
    environment:
      - DATABASE_PASSWORD_FILE=/run/secrets/db_password
      - API_KEY_FILE=/run/secrets/api_key

secrets:
  db_password:
    external: true
  api_key:
    external: true

# Kubernetes Secrets
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  database-password: <base64-encoded-password>
  api-key: <base64-encoded-key>

---
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: myapp
        env:
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-password

# HashiCorp Vault Integration
#!/bin/bash

# Authenticate with Vault
vault auth -method=aws

# Read secrets
DB_PASSWORD=$(vault kv get -field=password secret/myapp/database)
API_KEY=$(vault kv get -field=key secret/myapp/api)

# Start application with secrets
docker run -d \
  -e DATABASE_PASSWORD="$DB_PASSWORD" \
  -e API_KEY="$API_KEY" \
  myapp:latest

# Vault Agent Configuration
vault {
  address = "https://vault.example.com:8200"
}

auto_auth {
  method "aws" {
    mount_path = "auth/aws"
    config = {
      type = "iam"
      role = "myapp-role"
    }
  }

  sink "file" {
    config = {
      path = "/vault/token"
    }
  }
}

template {
  source      = "/vault/templates/config.tpl"
  destination = "/app/config.yml"
  command     = "restart myapp"
}
EOF

echo ""
echo "🎯 Solution 7: Backup and Disaster Recovery"
echo "==========================================="

cat << 'EOF'
# Database Backup Strategy
#!/bin/bash

BACKUP_DIR="/backups/$(date +%Y%m%d)"
RETENTION_DAYS=30

# Create backup directory
mkdir -p "$BACKUP_DIR"

# PostgreSQL backup
docker exec postgres pg_dump -U postgres myapp > "$BACKUP_DIR/myapp.sql"

# Volume backup
docker run --rm \
  -v postgres_data:/source:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/postgres_data.tar.gz -C /source .

# Upload to cloud storage
aws s3 sync "$BACKUP_DIR" "s3://myapp-backups/$(date +%Y%m%d)/"

# Clean up old backups
find /backups -type d -mtime +$RETENTION_DAYS -exec rm -rf {} +

# Database Replication
version: '3.8'

services:
  db-primary:
    image: postgres:13
    environment:
      - POSTGRES_REPLICATION_MODE=master
      - POSTGRES_REPLICATION_USER=replicator
      - POSTGRES_REPLICATION_PASSWORD=replicator_password
    volumes:
      - postgres_primary:/var/lib/postgresql/data

  db-standby:
    image: postgres:13
    environment:
      - POSTGRES_REPLICATION_MODE=slave
      - POSTGRES_REPLICATION_USER=replicator
      - POSTGRES_REPLICATION_PASSWORD=replicator_password
      - POSTGRES_MASTER_SERVICE=db-primary
    volumes:
      - postgres_standby:/var/lib/postgresql/data
    depends_on:
      - db-primary

# Disaster Recovery Plan
#!/bin/bash

# 1. Detect failure
if ! curl -f http://primary-site.com/health; then
    echo "Primary site is down, initiating failover"
    
    # 2. Promote standby database
    docker exec db-standby pg_promote
    
    # 3. Update DNS to point to DR site
    aws route53 change-resource-record-sets \
        --hosted-zone-id Z123456789 \
        --change-batch file://failover-dns.json
    
    # 4. Start application on DR site
    docker service update --replicas 3 myapp-dr
    
    echo "Failover completed"
fi

# Multi-region Deployment
version: '3.8'

services:
  app:
    image: myapp:latest
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.labels.region == us-east-1
    networks:
      - app-network

  app-dr:
    image: myapp:latest
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.region == us-west-2
    networks:
      - app-network
EOF

echo ""
echo "🎯 Solution 8: Load Balancing and High Availability"
echo "=================================================="

cat << 'EOF'
# HAProxy Configuration
global
    daemon
    maxconn 4096
    log stdout local0

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    option httplog

frontend web_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/cert.pem
    redirect scheme https if !{ ssl_fc }
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk GET /health
    http-check expect status 200
    server web1 web1:8080 check inter 30s
    server web2 web2:8080 check inter 30s
    server web3 web3:8080 check inter 30s

listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s

# Nginx Load Balancer
upstream backend {
    least_conn;
    server web1:8080 max_fails=3 fail_timeout=30s;
    server web2:8080 max_fails=3 fail_timeout=30s;
    server web3:8080 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    listen 443 ssl;
    
    ssl_certificate /etc/ssl/cert.pem;
    ssl_certificate_key /etc/ssl/key.pem;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Health check
        proxy_connect_timeout 5s;
        proxy_send_timeout 5s;
        proxy_read_timeout 5s;
    }
    
    location /health {
        access_log off;
        proxy_pass http://backend;
    }
}

# Kubernetes Service with Load Balancing
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
  sessionAffinity: ClientIP

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - myapp.com
    secretName: myapp-tls
  rules:
  - host: myapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: myapp-service
            port:
              number: 80
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key production deployment concepts mastered:"
echo "✅ Rolling deployments for zero-downtime updates"
echo "✅ Blue-green deployments for instant rollback"
echo "✅ Canary deployments for risk mitigation"
echo "✅ CI/CD pipeline automation"
echo "✅ Production monitoring and alerting"
echo "✅ Secrets management and security"
echo "✅ Backup and disaster recovery"
echo "✅ Load balancing and high availability"
echo ""
echo "💡 Remember:"
echo "   - Always test deployments in staging first"
echo "   - Implement proper health checks and monitoring"
echo "   - Have rollback procedures ready"
echo "   - Use secrets management for sensitive data"
echo "   - Plan for disaster recovery scenarios"
echo "   - Monitor application and infrastructure metrics"
