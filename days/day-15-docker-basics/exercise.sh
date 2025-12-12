#!/bin/bash

# Day 15: Docker Basics - Hands-on Exercise
# Practice Docker fundamentals with containers and images

set -e

echo "🚀 Day 15: Docker Basics Exercise"
echo "================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   macOS: brew install --cask docker"
    echo "   Linux: Follow installation guide in README.md"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running. Please start Docker."
    echo "   macOS: Start Docker Desktop application"
    echo "   Linux: sudo systemctl start docker"
    exit 1
fi

echo "✅ Docker is installed and running"
docker --version

echo ""
echo "🎯 Exercise 1: Hello World"
echo "=========================="

echo "🐳 Running hello-world container..."
docker run hello-world

echo "✅ Hello World completed"

echo ""
echo "🎯 Exercise 2: Interactive Containers"
echo "===================================="

echo "🐍 Running Python container interactively..."
echo "   (This will start Python REPL - type 'exit()' to quit)"

# Create a simple Python script to run
cat > /tmp/docker_test.py << 'EOF'
print("🐍 Hello from Python in Docker!")
print("Python version:", end=" ")
import sys
print(sys.version.split()[0])

# Test some basic operations
numbers = [1, 2, 3, 4, 5]
print(f"Sum of {numbers} = {sum(numbers)}")

# Test importing common libraries
try:
    import json
    data = {"message": "JSON works!", "numbers": numbers}
    print("JSON test:", json.dumps(data))
except ImportError:
    print("JSON not available")

print("🎉 Python container test completed!")
EOF

echo "📝 Running Python script in container..."
docker run --rm -v /tmp:/tmp python:3.9 python /tmp/docker_test.py

echo "✅ Interactive Python container completed"

echo ""
echo "🎯 Exercise 3: Web Server Container"
echo "=================================="

echo "🌐 Starting Nginx web server container..."
NGINX_CONTAINER=$(docker run -d -p 8080:80 --name nginx-test nginx:alpine)

echo "✅ Nginx container started with ID: $NGINX_CONTAINER"
echo "🌍 Web server available at: http://localhost:8080"

# Wait a moment for server to start
sleep 2

# Test if server is responding
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ Web server is responding"
else
    echo "⚠️  Web server might still be starting..."
fi

echo "📊 Container status:"
docker ps --filter "name=nginx-test"

echo ""
echo "🎯 Exercise 4: Container Management"
echo "=================================="

echo "📋 Listing all containers..."
docker ps -a

echo ""
echo "📊 Container resource usage:"
docker stats --no-stream

echo ""
echo "🔍 Inspecting nginx container..."
docker inspect nginx-test | head -20

echo ""
echo "📜 Viewing nginx container logs..."
docker logs nginx-test

echo ""
echo "🎯 Exercise 5: Working with Data"
echo "==============================="

# Create a data directory
DATA_DIR="/tmp/docker-data-exercise"
mkdir -p "$DATA_DIR"

# Create sample data file
cat > "$DATA_DIR/customers.csv" << 'EOF'
name,age,city
John Doe,25,New York
Jane Smith,30,Boston
Bob Johnson,35,Chicago
Alice Brown,28,Seattle
Charlie Wilson,32,Denver
EOF

echo "📊 Created sample data file:"
cat "$DATA_DIR/customers.csv"

echo ""
echo "🐍 Processing data with Python container..."

# Create data processing script
cat > "$DATA_DIR/process_data.py" << 'EOF'
import csv
import json

print("📊 Processing customer data...")

# Read CSV file
customers = []
with open('/data/customers.csv', 'r') as file:
    reader = csv.DictReader(file)
    customers = list(reader)

print(f"📈 Loaded {len(customers)} customers")

# Calculate statistics
ages = [int(customer['age']) for customer in customers]
avg_age = sum(ages) / len(ages)

# Count cities
cities = {}
for customer in customers:
    city = customer['city']
    cities[city] = cities.get(city, 0) + 1

# Create summary
summary = {
    'total_customers': len(customers),
    'average_age': round(avg_age, 1),
    'cities': cities,
    'customers': customers
}

# Save results
with open('/data/summary.json', 'w') as file:
    json.dump(summary, file, indent=2)

print("📋 Summary:")
print(f"   Total customers: {summary['total_customers']}")
print(f"   Average age: {summary['average_age']}")
print(f"   Cities: {summary['cities']}")
print("💾 Results saved to summary.json")
EOF

# Run data processing in container with volume mount
docker run --rm -v "$DATA_DIR:/data" python:3.9 python /data/process_data.py

echo ""
echo "📄 Generated summary file:"
cat "$DATA_DIR/summary.json"

echo ""
echo "🎯 Exercise 6: Database Container"
echo "==============================="

echo "🗄️  Starting PostgreSQL database container..."
POSTGRES_CONTAINER=$(docker run -d \
    --name postgres-test \
    -e POSTGRES_PASSWORD=testpass \
    -e POSTGRES_DB=analytics \
    -p 5432:5432 \
    postgres:13)

echo "✅ PostgreSQL container started with ID: $POSTGRES_CONTAINER"

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Test database connection
echo "🔗 Testing database connection..."
docker exec postgres-test psql -U postgres -d analytics -c "SELECT version();" || echo "⚠️  Database might still be starting..."

echo ""
echo "🎯 Exercise 7: Multiple Containers"
echo "================================="

echo "🐍 Starting Python data processor container..."
PYTHON_CONTAINER=$(docker run -d \
    --name python-processor \
    -v "$DATA_DIR:/workspace" \
    python:3.9 \
    tail -f /dev/null)  # Keep container running

echo "✅ Python processor container started"

echo "📊 Current running containers:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🎯 Exercise 8: Container Interaction"
echo "==================================="

echo "💻 Executing commands in Python container..."
docker exec python-processor python -c "
import os
print('🐍 Python version:', end=' ')
import sys
print(sys.version.split()[0])
print('📁 Working directory:', os.getcwd())
print('📂 Files in /workspace:')
for f in os.listdir('/workspace'):
    print(f'   {f}')
"

echo ""
echo "🔧 Installing packages in container..."
docker exec python-processor pip install pandas numpy

echo "📊 Testing pandas in container..."
docker exec python-processor python -c "
import pandas as pd
import numpy as np
print('📊 Pandas version:', pd.__version__)
print('🔢 NumPy version:', np.__version__)

# Load and analyze data
df = pd.read_csv('/workspace/customers.csv')
print('📈 Data shape:', df.shape)
print('📋 Age statistics:')
print(df['age'].describe())
"

echo ""
echo "🎯 Exercise 9: Resource Monitoring"
echo "================================="

echo "📊 Container resource usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo ""
echo "💾 Docker system information:"
docker system df

echo ""
echo "🎯 Exercise 10: Cleanup"
echo "======================"

echo "🧹 Stopping and removing containers..."

# Stop containers
docker stop nginx-test postgres-test python-processor 2>/dev/null || true

# Remove containers
docker rm nginx-test postgres-test python-processor 2>/dev/null || true

echo "✅ Containers stopped and removed"

echo "🧹 Cleaning up unused resources..."
docker system prune -f

echo "✅ Cleanup completed"

# Clean up data directory
rm -rf "$DATA_DIR"

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully:"
echo "✅ Run your first Docker containers"
echo "✅ Used interactive Python containers"
echo "✅ Started web server containers"
echo "✅ Managed container lifecycle"
echo "✅ Worked with data using volume mounts"
echo "✅ Run database containers"
echo "✅ Executed commands in running containers"
echo "✅ Monitored container resources"
echo "✅ Cleaned up containers and resources"
echo ""
echo "🔍 Key commands you practiced:"
echo "   docker run - Create and start containers"
echo "   docker ps - List containers"
echo "   docker exec - Execute commands in containers"
echo "   docker logs - View container logs"
echo "   docker stop/rm - Stop and remove containers"
echo "   docker system prune - Clean up resources"
echo ""
echo "💡 Next: Learn to create custom Docker images with Dockerfiles!"
