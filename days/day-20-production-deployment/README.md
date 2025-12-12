# Day 20: Production Deployment Strategies

**Duration**: 1 hour  
**Prerequisites**: Days 15-19 (Complete Docker sequence)

## Learning Objectives

By the end of this lesson, you will:
- Implement various deployment strategies (rolling, blue-green, canary)
- Configure production-ready container orchestration
- Set up monitoring and logging for production systems
- Implement CI/CD pipelines for automated deployments
- Handle secrets and configuration management
- Design disaster recovery and backup strategies

## Deployment Strategies

### Rolling Deployment

**Concept**: Gradually replace old instances with new ones

**Docker Swarm Implementation**
```yaml
version: '3.8'

services:
  web:
    image: myapp:${VERSION}
    deploy:
      replicas: 5
      update_config:
        parallelism: 2        # Update 2 at a time
        delay: 10s           # Wait 10s between updates
        failure_action: rollback
        monitor: 60s         # Monitor for 60s
        max_failure_ratio: 0.2
      rollback_config:
        parallelism: 1
        delay: 5s
        failure_action: pause
```

**Kubernetes Implementation**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
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
```

### Blue-Green Deployment

**Concept**: Maintain two identical environments, switch traffic instantly

**Implementation Script**
```bash
#!/bin/bash
# blue-green-deploy.sh

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
    myapp:$NEW_VERSION

# Health check
echo "Waiting for health checks..."
sleep 30

# Verify deployment
if curl -f http://myapp-$NEW_ENV:8080/health; then
    echo "Health check passed, switching traffic"
    
    # Update load balancer to point to new environment
    docker service update \
        --label-add active=true \
        myapp-$NEW_ENV
    
    # Remove old environment
    docker service rm myapp-$OLD_ENV
    
    echo "Deployment successful"
else
    echo "Health check failed, rolling back"
    docker service rm myapp-$NEW_ENV
    exit 1
fi
```

**Docker Compose Blue-Green**
```yaml
# docker-compose.blue.yml
version: '3.8'

services:
  web-blue:
    image: myapp:${VERSION}
    networks:
      - blue-network
    labels:
      - "environment=blue"
      - "traefik.enable=false"  # Initially disabled

  nginx-blue:
    image: nginx:alpine
    volumes:
      - ./nginx-blue.conf:/etc/nginx/nginx.conf
    networks:
      - blue-network
      - public

networks:
  blue-network:
  public:
    external: true
```

### Canary Deployment

**Concept**: Route small percentage of traffic to new version

**Traefik Configuration**
```yaml
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
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - web

networks:
  web:
```

**Nginx Canary Configuration**
```nginx
upstream backend {
    server web-stable:8080 weight=90;
    server web-canary:8080 weight=10;
}

server {
    listen 80;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Container Orchestration

### Docker Swarm Production Setup

**Initialize Swarm**
```bash
# Manager node
docker swarm init --advertise-addr <MANAGER-IP>

# Worker nodes
docker swarm join --token <TOKEN> <MANAGER-IP>:2377

# Create overlay networks
docker network create --driver overlay --attachable production
docker network create --driver overlay --attachable monitoring
```

**Production Stack**
```yaml
# production-stack.yml
version: '3.8'

services:
  web:
    image: myapp:${VERSION:-latest}
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.role == worker
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    networks:
      - production
    secrets:
      - db_password
      - api_key
    configs:
      - source: app_config
        target: /app/config.yml

  db:
    image: postgres:13
    deploy:
      placement:
        constraints:
          - node.labels.type == database
      resources:
        limits:
          memory: 2G
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - production
    secrets:
      - db_password
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    deploy:
      placement:
        constraints:
          - node.role == manager
    volumes:
      - ./ssl:/etc/ssl:ro
    configs:
      - source: nginx_config
        target: /etc/nginx/nginx.conf
    networks:
      - production

volumes:
  postgres_data:
    driver: local

networks:
  production:
    driver: overlay
    encrypted: true

secrets:
  db_password:
    external: true
  api_key:
    external: true

configs:
  app_config:
    external: true
  nginx_config:
    external: true
```

### Kubernetes Production Setup

**Namespace and Resources**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:v1.0.0
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
  namespace: production
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

## CI/CD Pipeline Integration

### GitHub Actions Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
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
            type=ref,event=branch
            type=ref,event=pr
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
      
      - name: Output image
        id: image
        run: echo "image=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}" >> $GITHUB_OUTPUT

  security-scan:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Scan image
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ needs.build.outputs.image }}
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

  deploy-staging:
    needs: [build, security-scan]
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying ${{ needs.build.outputs.image }} to staging"
          # Deploy to staging environment
          
      - name: Run integration tests
        run: |
          # Run integration tests against staging
          echo "Running integration tests"

  deploy-production:
    needs: [build, security-scan, deploy-staging]
    runs-on: ubuntu-latest
    environment: production
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying ${{ needs.build.outputs.image }} to production"
          # Blue-green deployment to production
```

### GitLab CI/CD Pipeline

```yaml
# .gitlab-ci.yml
stages:
  - build
  - test
  - security
  - deploy-staging
  - deploy-production

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"

build:
  stage: build
  image: docker:20.10.16
  services:
    - docker:20.10.16-dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
    - tags

security-scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy image --exit-code 0 --severity HIGH,CRITICAL $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
    - tags

deploy-staging:
  stage: deploy-staging
  image: docker:20.10.16
  script:
    - docker service update --image $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA myapp-staging
  environment:
    name: staging
    url: https://staging.myapp.com
  only:
    - main

deploy-production:
  stage: deploy-production
  image: docker:20.10.16
  script:
    - ./scripts/blue-green-deploy.sh $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  environment:
    name: production
    url: https://myapp.com
  when: manual
  only:
    - tags
```

## Monitoring and Observability

### Prometheus and Grafana Stack

```yaml
# monitoring-stack.yml
version: '3.8'

services:
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
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./grafana/datasources:/etc/grafana/provisioning/datasources
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    ports:
      - "9100:9100"
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

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    ports:
      - "8080:8080"
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
  monitoring:
```

**Prometheus Configuration**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'myapp'
    static_configs:
      - targets: ['myapp:8080']
    metrics_path: '/metrics'
```

### Centralized Logging

**ELK Stack**
```yaml
# logging-stack.yml
version: '3.8'

services:
  elasticsearch:
    image: elasticsearch:7.14.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
    networks:
      - logging

  logstash:
    image: logstash:7.14.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5044:5044"
    depends_on:
      - elasticsearch
    networks:
      - logging

  kibana:
    image: kibana:7.14.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - logging

  filebeat:
    image: elastic/filebeat:7.14.0
    user: root
    volumes:
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    depends_on:
      - logstash
    networks:
      - logging

volumes:
  elasticsearch_data:

networks:
  logging:
```

## Secrets Management

### Docker Secrets

```bash
# Create secrets
echo "supersecretpassword" | docker secret create db_password -
echo "api-key-12345" | docker secret create api_key -

# Use in service
docker service create \
  --name myapp \
  --secret db_password \
  --secret api_key \
  myapp:latest
```

### HashiCorp Vault Integration

```yaml
# vault-integration.yml
version: '3.8'

services:
  vault:
    image: vault:latest
    cap_add:
      - IPC_LOCK
    environment:
      - VAULT_DEV_ROOT_TOKEN_ID=myroot
      - VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200
    ports:
      - "8200:8200"

  vault-agent:
    image: vault:latest
    command: vault agent -config=/vault/config/agent.hcl
    volumes:
      - ./vault-agent.hcl:/vault/config/agent.hcl
      - vault_secrets:/vault/secrets
    depends_on:
      - vault

  myapp:
    image: myapp:latest
    volumes:
      - vault_secrets:/secrets:ro
    environment:
      - DATABASE_PASSWORD_FILE=/secrets/db_password
    depends_on:
      - vault-agent

volumes:
  vault_secrets:
```

## Backup and Disaster Recovery

### Database Backup Strategy

```bash
#!/bin/bash
# backup-database.sh

BACKUP_DIR="/backups/$(date +%Y%m%d)"
RETENTION_DAYS=30

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup PostgreSQL
docker exec postgres pg_dump -U postgres myapp > "$BACKUP_DIR/myapp.sql"

# Backup volumes
docker run --rm \
  -v postgres_data:/source:ro \
  -v "$BACKUP_DIR":/backup \
  alpine tar czf /backup/postgres_data.tar.gz -C /source .

# Upload to cloud storage
aws s3 sync "$BACKUP_DIR" "s3://myapp-backups/$(date +%Y%m%d)/"

# Clean up old backups
find /backups -type d -mtime +$RETENTION_DAYS -exec rm -rf {} +
```

### Disaster Recovery Plan

```yaml
# disaster-recovery.yml
version: '3.8'

services:
  # Primary database
  db-primary:
    image: postgres:13
    environment:
      - POSTGRES_REPLICATION_MODE=master
      - POSTGRES_REPLICATION_USER=replicator
      - POSTGRES_REPLICATION_PASSWORD=replicator_password
    volumes:
      - postgres_primary:/var/lib/postgresql/data

  # Standby database
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

volumes:
  postgres_primary:
  postgres_standby:
```

## Load Balancing and High Availability

### HAProxy Configuration

```yaml
# haproxy-stack.yml
version: '3.8'

services:
  haproxy:
    image: haproxy:alpine
    ports:
      - "80:80"
      - "443:443"
      - "8404:8404"  # Stats page
    volumes:
      - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
      - ./ssl:/etc/ssl:ro
    networks:
      - frontend
      - backend

  web1:
    image: myapp:latest
    networks:
      - backend
    deploy:
      placement:
        constraints:
          - node.hostname == worker1

  web2:
    image: myapp:latest
    networks:
      - backend
    deploy:
      placement:
        constraints:
          - node.hostname == worker2

  web3:
    image: myapp:latest
    networks:
      - backend
    deploy:
      placement:
        constraints:
          - node.hostname == worker3

networks:
  frontend:
  backend:
```

**HAProxy Configuration**
```
# haproxy.cfg
global
    daemon
    maxconn 4096

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend web_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/cert.pem
    redirect scheme https if !{ ssl_fc }
    default_backend web_servers

backend web_servers
    balance roundrobin
    option httpchk GET /health
    server web1 web1:8080 check
    server web2 web2:8080 check
    server web3 web3:8080 check

listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
```

## Next Steps

Tomorrow (Day 21) will be the final containerization project, integrating all concepts from Week 3 into a complete production-ready system.

## Key Takeaways

- Rolling deployments provide zero-downtime updates with gradual rollout
- Blue-green deployments enable instant rollback capabilities
- Canary deployments reduce risk by testing with limited traffic
- Container orchestration platforms manage complex multi-service applications
- CI/CD pipelines automate testing, security scanning, and deployment
- Monitoring and logging provide operational visibility
- Secrets management protects sensitive configuration data
- Backup and disaster recovery strategies ensure business continuity
- Load balancing and high availability prevent single points of failure
