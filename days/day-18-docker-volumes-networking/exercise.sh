#!/bin/bash

# Day 18: Docker Volumes and Networking - Hands-on Exercise
# Practice advanced Docker storage and networking concepts

set -e

echo "🚀 Day 18: Docker Volumes and Networking Exercise"
echo "================================================="

# Create exercise directory
EXERCISE_DIR="$HOME/docker-volumes-networking-exercise"
echo "📁 Creating exercise directory: $EXERCISE_DIR"

if [ -d "$EXERCISE_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$EXERCISE_DIR"
fi

mkdir -p "$EXERCISE_DIR"
cd "$EXERCISE_DIR"

echo ""
echo "🎯 Exercise 1: Volume Types and Management"
echo "========================================="

echo "📦 Creating and managing different volume types..."

# Create named volumes
docker volume create data-volume
docker volume create logs-volume
docker volume create cache-volume

echo "✅ Created named volumes"

# List volumes
echo "📋 Current volumes:"
docker volume ls | grep -E "(data-volume|logs-volume|cache-volume)"

# Inspect volume
echo "🔍 Volume details:"
docker volume inspect data-volume | head -10

# Create test data directory
mkdir -p test-data
echo "Sample data file" > test-data/sample.txt
echo "Configuration data" > test-data/config.json

echo "📊 Test data created in: $(pwd)/test-data"

# Test different volume types
echo ""
echo "🧪 Testing volume types..."

# Named volume
echo "1️⃣ Testing named volume..."
docker run --rm -v data-volume:/data alpine sh -c "
    echo 'Named volume test' > /data/named.txt &&
    ls -la /data/ &&
    cat /data/named.txt
"

# Bind mount
echo "2️⃣ Testing bind mount..."
docker run --rm -v $(pwd)/test-data:/data alpine sh -c "
    echo 'Bind mount test' > /data/bind.txt &&
    ls -la /data/ &&
    cat /data/sample.txt
"

# Anonymous volume
echo "3️⃣ Testing anonymous volume..."
docker run --rm -v /tmp alpine sh -c "
    echo 'Anonymous volume test' > /tmp/anon.txt &&
    ls -la /tmp/ | head -5
"

echo "✅ Volume types tested successfully"

echo ""
echo "🎯 Exercise 2: Data Persistence and Sharing"
echo "==========================================="

echo "🗄️ Setting up persistent database..."

# Start PostgreSQL with named volume
docker run -d \
    --name postgres-persistent \
    -e POSTGRES_PASSWORD=testpass \
    -e POSTGRES_DB=testdb \
    -v postgres-data:/var/lib/postgresql/data \
    postgres:13

echo "⏳ Waiting for database to be ready..."
sleep 10

# Create test data
echo "📊 Creating test data in database..."
docker exec postgres-persistent psql -U postgres -d testdb -c "
    CREATE TABLE users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100),
        email VARCHAR(100)
    );
    
    INSERT INTO users (name, email) VALUES 
        ('Alice Johnson', 'alice@example.com'),
        ('Bob Smith', 'bob@example.com'),
        ('Carol Davis', 'carol@example.com');
"

# Verify data
echo "✅ Data created. Verifying..."
docker exec postgres-persistent psql -U postgres -d testdb -c "SELECT * FROM users;"

# Stop and remove container
echo "🔄 Stopping container (data should persist)..."
docker stop postgres-persistent
docker rm postgres-persistent

# Start new container with same volume
echo "🔄 Starting new container with same volume..."
docker run -d \
    --name postgres-new \
    -e POSTGRES_PASSWORD=testpass \
    -e POSTGRES_DB=testdb \
    -v postgres-data:/var/lib/postgresql/data \
    postgres:13

sleep 10

# Verify data persistence
echo "🔍 Verifying data persistence..."
docker exec postgres-new psql -U postgres -d testdb -c "SELECT * FROM users;"

echo "✅ Data persisted successfully!"

# Clean up
docker stop postgres-new
docker rm postgres-new

echo ""
echo "🎯 Exercise 3: Custom Networks"
echo "=============================="

echo "🌐 Creating custom networks..."

# Create custom networks
docker network create frontend-network
docker network create backend-network
docker network create --internal secure-network

echo "✅ Custom networks created"

# List networks
echo "📋 Current networks:"
docker network ls | grep -E "(frontend-network|backend-network|secure-network)"

# Inspect network
echo "🔍 Network details:"
docker network inspect frontend-network | head -20

echo ""
echo "🏗️ Setting up multi-tier application..."

# Create web application
mkdir -p webapp
cat > webapp/app.py << 'EOF'
#!/usr/bin/env python3
"""Simple web application for network testing."""

from flask import Flask, jsonify
import requests
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'service': 'web',
        'message': 'Frontend service running',
        'network_test': 'OK'
    })

@app.route('/api-test')
def api_test():
    try:
        # Test connection to API service
        response = requests.get('http://api-service:5000/data', timeout=5)
        return jsonify({
            'api_connection': 'success',
            'api_response': response.json()
        })
    except Exception as e:
        return jsonify({
            'api_connection': 'failed',
            'error': str(e)
        }), 500

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
EOF

cat > webapp/requirements.txt << 'EOF'
Flask==2.3.2
requests==2.31.0
EOF

cat > webapp/Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 8000

CMD ["python", "app.py"]
EOF

# Create API service
mkdir -p apiservice
cat > apiservice/app.py << 'EOF'
#!/usr/bin/env python3
"""API service for network testing."""

from flask import Flask, jsonify
import psycopg2
import os

app = Flask(__name__)

@app.route('/data')
def get_data():
    try:
        # Connect to database
        conn = psycopg2.connect(
            host='database-service',
            database='testdb',
            user='postgres',
            password='testpass'
        )
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM users")
        count = cur.fetchone()[0]
        cur.close()
        conn.close()
        
        return jsonify({
            'service': 'api',
            'database_connection': 'success',
            'user_count': count,
            'message': 'API service with database access'
        })
    except Exception as e:
        return jsonify({
            'service': 'api',
            'database_connection': 'failed',
            'error': str(e)
        }), 500

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

cat > apiservice/requirements.txt << 'EOF'
Flask==2.3.2
psycopg2-binary==2.9.6
EOF

cat > apiservice/Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
EOF

echo "🐳 Building application images..."
docker build -t webapp:latest webapp/
docker build -t apiservice:latest apiservice/

echo "✅ Images built successfully"

echo ""
echo "🚀 Starting multi-tier application with custom networks..."

# Start database on backend network only
docker run -d \
    --name database-service \
    --network backend-network \
    -e POSTGRES_PASSWORD=testpass \
    -e POSTGRES_DB=testdb \
    -v postgres-data:/var/lib/postgresql/data \
    postgres:13

sleep 10

# Start API service on both networks
docker run -d \
    --name api-service \
    --network backend-network \
    apiservice:latest

docker network connect frontend-network api-service

# Start web service on frontend network only
docker run -d \
    --name web-service \
    --network frontend-network \
    -p 8000:8000 \
    webapp:latest

sleep 5

echo "✅ Multi-tier application started"

echo ""
echo "🧪 Testing network connectivity..."

# Test web service
echo "1️⃣ Testing web service..."
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ Web service is healthy"
    curl -s http://localhost:8000/ | head -5
else
    echo "⚠️ Web service not responding"
fi

# Test API connectivity through web service
echo ""
echo "2️⃣ Testing API connectivity through web service..."
curl -s http://localhost:8000/api-test | head -10

# Test network isolation
echo ""
echo "3️⃣ Testing network isolation..."
echo "Web service trying to connect directly to database (should fail):"
docker exec web-service sh -c "
    python -c 'import socket; socket.create_connection((\"database-service\", 5432), timeout=2)' 2>&1 || echo 'Connection blocked - network isolation working!'
"

echo "API service connecting to database (should work):"
docker exec api-service sh -c "
    python -c 'import socket; socket.create_connection((\"database-service\", 5432), timeout=2) and print(\"Database connection successful\")' 2>&1
"

echo "✅ Network isolation tested"

# Clean up services
docker stop web-service api-service database-service
docker rm web-service api-service database-service

echo ""
echo "🎯 Exercise 4: Volume Backup and Restore"
echo "========================================"

echo "💾 Testing volume backup and restore..."

# Create test volume with data
docker volume create backup-test-volume

# Add test data
docker run --rm -v backup-test-volume:/data alpine sh -c "
    echo 'Important data 1' > /data/file1.txt &&
    echo 'Important data 2' > /data/file2.txt &&
    mkdir -p /data/subdir &&
    echo 'Subdirectory data' > /data/subdir/file3.txt &&
    ls -la /data/
"

echo "✅ Test data created in volume"

# Create backup
echo "📦 Creating backup..."
mkdir -p backups
docker run --rm \
    -v backup-test-volume:/source \
    -v $(pwd)/backups:/backup \
    alpine tar czf /backup/volume-backup.tar.gz -C /source .

echo "✅ Backup created: $(ls -lh backups/volume-backup.tar.gz)"

# Remove original volume
docker volume rm backup-test-volume

# Create new volume and restore
echo "🔄 Restoring from backup..."
docker volume create restored-volume

docker run --rm \
    -v restored-volume:/target \
    -v $(pwd)/backups:/backup \
    alpine tar xzf /backup/volume-backup.tar.gz -C /target

# Verify restoration
echo "🔍 Verifying restored data..."
docker run --rm -v restored-volume:/data alpine sh -c "
    echo 'Restored volume contents:' &&
    find /data -type f -exec echo '{}:' \; -exec cat {} \;
"

echo "✅ Volume backup and restore completed successfully"

# Clean up
docker volume rm restored-volume

echo ""
echo "🎯 Exercise 5: Performance and Monitoring"
echo "========================================"

echo "📊 Monitoring Docker storage and network usage..."

# Show system usage
echo "💾 Docker system usage:"
docker system df

echo ""
echo "📋 Volume usage details:"
docker system df -v | head -20

echo ""
echo "🌐 Network information:"
docker network ls

# Create performance test
echo ""
echo "⚡ Performance testing..."

# Test tmpfs performance
echo "1️⃣ Testing tmpfs performance..."
docker run --rm --tmpfs /tmp:rw,size=100m alpine sh -c "
    time dd if=/dev/zero of=/tmp/testfile bs=1M count=50 2>&1 | grep -E '(copied|MB/s)'
"

# Test volume performance
echo "2️⃣ Testing volume performance..."
docker run --rm -v perf-test-volume:/data alpine sh -c "
    time dd if=/dev/zero of=/data/testfile bs=1M count=50 2>&1 | grep -E '(copied|MB/s)'
"

# Test bind mount performance
echo "3️⃣ Testing bind mount performance..."
mkdir -p perf-test
docker run --rm -v $(pwd)/perf-test:/data alpine sh -c "
    time dd if=/dev/zero of=/data/testfile bs=1M count=50 2>&1 | grep -E '(copied|MB/s)'
"

echo "✅ Performance tests completed"

# Clean up performance test data
docker volume rm perf-test-volume
rm -rf perf-test

echo ""
echo "🎯 Exercise 6: Cleanup"
echo "====================="

echo "🧹 Cleaning up all resources..."

# Remove custom networks
docker network rm frontend-network backend-network secure-network 2>/dev/null || true

# Remove volumes
docker volume rm data-volume logs-volume cache-volume postgres-data 2>/dev/null || true

# Remove images
docker rmi webapp:latest apiservice:latest 2>/dev/null || true

# Clean up files
rm -rf webapp apiservice test-data backups

echo "✅ Cleanup completed"

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully:"
echo "✅ Managed different Docker volume types"
echo "✅ Implemented data persistence with named volumes"
echo "✅ Created and configured custom networks"
echo "✅ Built multi-tier application with network isolation"
echo "✅ Performed volume backup and restore operations"
echo "✅ Monitored performance and resource usage"
echo ""
echo "🔍 Key concepts practiced:"
echo "   Named volumes - Docker-managed persistent storage"
echo "   Bind mounts - Host filesystem integration"
echo "   Custom networks - Service isolation and communication"
echo "   Network security - Multi-tier architecture"
echo "   Volume backup - Data protection strategies"
echo "   Performance monitoring - Resource optimization"
echo ""
echo "💡 Next: Learn container optimization and best practices!"
