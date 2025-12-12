#!/bin/bash

# Day 16: Dockerfiles - Hands-on Exercise
# Practice creating custom Docker images with Dockerfiles

set -e

echo "🚀 Day 16: Dockerfiles Exercise"
echo "==============================="

# Create exercise directory
EXERCISE_DIR="$HOME/dockerfile-exercise"
echo "📁 Creating exercise directory: $EXERCISE_DIR"

if [ -d "$EXERCISE_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$EXERCISE_DIR"
fi

mkdir -p "$EXERCISE_DIR"
cd "$EXERCISE_DIR"

echo ""
echo "🎯 Exercise 1: Simple Python Application"
echo "========================================"

# Create a simple Python app
mkdir -p simple-python-app
cd simple-python-app

cat > app.py << 'EOF'
#!/usr/bin/env python3
"""Simple Python web application."""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import datetime

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            response = {
                'message': 'Hello from Dockerized Python!',
                'timestamp': datetime.datetime.now().isoformat(),
                'path': self.path
            }
            
            self.wfile.write(json.dumps(response, indent=2).encode())
        
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            response = {'status': 'healthy'}
            self.wfile.write(json.dumps(response).encode())
        
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not Found')

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8000), RequestHandler)
    print("🚀 Server starting on port 8000...")
    server.serve_forever()
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
# Use official Python image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy application file
COPY app.py .

# Expose port
EXPOSE 8000

# Run application
CMD ["python", "app.py"]
EOF

echo "📝 Created simple Python application"
echo "🐳 Building Docker image..."

docker build -t simple-python-app:latest .

echo "✅ Image built successfully"

# Test the application
echo "🧪 Testing the application..."
CONTAINER_ID=$(docker run -d -p 8001:8000 --name simple-app simple-python-app:latest)

sleep 2

if curl -s http://localhost:8001/ > /dev/null; then
    echo "✅ Application is running successfully"
    curl -s http://localhost:8001/ | head -5
else
    echo "⚠️  Application might still be starting..."
fi

# Stop and remove container
docker stop simple-app && docker rm simple-app

cd ..

echo ""
echo "🎯 Exercise 2: Data Science Environment"
echo "======================================"

mkdir -p data-science-env
cd data-science-env

# Create requirements file
cat > requirements.txt << 'EOF'
pandas==1.5.3
numpy==1.24.3
matplotlib==3.7.1
seaborn==0.12.2
jupyter==1.0.0
scikit-learn==1.2.2
EOF

# Create sample notebook
cat > sample_analysis.py << 'EOF'
#!/usr/bin/env python3
"""Sample data analysis script."""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

def generate_sample_data():
    """Generate sample customer data."""
    np.random.seed(42)
    
    data = {
        'customer_id': range(1, 1001),
        'age': np.random.normal(35, 10, 1000).astype(int),
        'income': np.random.normal(50000, 15000, 1000),
        'purchases': np.random.poisson(5, 1000),
        'satisfaction': np.random.uniform(1, 5, 1000)
    }
    
    return pd.DataFrame(data)

def analyze_data(df):
    """Perform basic data analysis."""
    print("📊 Dataset Overview:")
    print(f"   Shape: {df.shape}")
    print(f"   Columns: {list(df.columns)}")
    
    print("\n📈 Summary Statistics:")
    print(df.describe())
    
    print("\n🔍 Age Distribution:")
    print(f"   Mean age: {df['age'].mean():.1f}")
    print(f"   Age range: {df['age'].min()} - {df['age'].max()}")
    
    print("\n💰 Income Analysis:")
    print(f"   Average income: ${df['income'].mean():,.0f}")
    print(f"   Income std: ${df['income'].std():,.0f}")
    
    return df

if __name__ == "__main__":
    print("🔬 Starting data analysis...")
    
    # Generate and analyze data
    df = generate_sample_data()
    df = analyze_data(df)
    
    # Save results
    df.to_csv('/workspace/customer_data.csv', index=False)
    print("\n💾 Data saved to customer_data.csv")
    
    print("✅ Analysis complete!")
EOF

# Create Dockerfile for data science environment
cat > Dockerfile << 'EOF'
FROM python:3.9

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /workspace

# Copy requirements and install packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy analysis script
COPY sample_analysis.py .

# Create data directory
RUN mkdir -p data output

# Set environment variables
ENV PYTHONPATH=/workspace

# Default command
CMD ["python", "sample_analysis.py"]
EOF

echo "📝 Created data science environment"
echo "🐳 Building Docker image..."

docker build -t data-science-env:latest .

echo "✅ Image built successfully"

# Test the data science environment
echo "🧪 Running data analysis..."
docker run --rm -v $(pwd)/output:/workspace/output data-science-env:latest

if [ -f "customer_data.csv" ]; then
    echo "✅ Data analysis completed successfully"
    echo "📊 Generated data preview:"
    head -5 customer_data.csv
else
    echo "⚠️  Data file not found, checking container output..."
fi

cd ..

echo ""
echo "🎯 Exercise 3: Multi-stage Build"
echo "==============================="

mkdir -p multi-stage-app
cd multi-stage-app

# Create a Node.js application
cat > package.json << 'EOF'
{
  "name": "data-api",
  "version": "1.0.0",
  "description": "Simple data API",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "build": "echo 'Building application...'"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

cat > server.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

// Sample data
const customers = [
    { id: 1, name: 'John Doe', age: 25, city: 'New York' },
    { id: 2, name: 'Jane Smith', age: 30, city: 'Boston' },
    { id: 3, name: 'Bob Johnson', age: 35, city: 'Chicago' }
];

app.get('/', (req, res) => {
    res.json({
        message: 'Data API Server',
        version: '1.0.0',
        endpoints: ['/customers', '/health']
    });
});

app.get('/customers', (req, res) => {
    res.json({
        customers: customers,
        count: customers.length
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

app.listen(port, '0.0.0.0', () => {
    console.log(`🚀 Data API server running on port ${port}`);
});
EOF

# Create multi-stage Dockerfile
cat > Dockerfile << 'EOF'
# Build stage
FROM node:16 AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev)
RUN npm install

# Copy source code
COPY . .

# Run build process
RUN npm run build

# Production stage
FROM node:16-alpine AS production

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy built application from builder stage
COPY --from=builder --chown=nodejs:nodejs /app/server.js .

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Start application
CMD ["node", "server.js"]
EOF

echo "📝 Created multi-stage Node.js application"
echo "🐳 Building Docker image with multi-stage build..."

docker build -t data-api:latest .

echo "✅ Multi-stage image built successfully"

# Test the API
echo "🧪 Testing the API..."
API_CONTAINER=$(docker run -d -p 3001:3000 --name data-api data-api:latest)

sleep 3

if curl -s http://localhost:3001/health > /dev/null; then
    echo "✅ API is running successfully"
    echo "📊 API response:"
    curl -s http://localhost:3001/customers | head -10
else
    echo "⚠️  API might still be starting..."
fi

# Stop and remove container
docker stop data-api && docker rm data-api

cd ..

echo ""
echo "🎯 Exercise 4: Optimized Dockerfile"
echo "=================================="

mkdir -p optimized-app
cd optimized-app

# Create Python application with dependencies
cat > requirements.txt << 'EOF'
flask==2.3.2
pandas==1.5.3
numpy==1.24.3
gunicorn==20.1.0
EOF

cat > app.py << 'EOF'
#!/usr/bin/env python3
"""Optimized Flask application."""

from flask import Flask, jsonify
import pandas as pd
import numpy as np
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        'message': 'Optimized Flask App',
        'version': os.getenv('APP_VERSION', '1.0.0'),
        'environment': os.getenv('FLASK_ENV', 'production')
    })

@app.route('/data')
def get_data():
    # Generate sample data
    np.random.seed(42)
    data = {
        'values': np.random.normal(0, 1, 100).tolist(),
        'mean': float(np.mean(np.random.normal(0, 1, 100))),
        'std': float(np.std(np.random.normal(0, 1, 100)))
    }
    return jsonify(data)

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
.git
.gitignore
README.md
Dockerfile
.dockerignore
__pycache__
*.pyc
*.pyo
*.pyd
.pytest_cache
.coverage
.env
*.log
EOF

# Create optimized Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim

# Set build arguments
ARG APP_VERSION=1.0.0

# Install system dependencies in single layer
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /app

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=appuser:appuser . .

# Set environment variables
ENV APP_VERSION=$APP_VERSION
ENV FLASK_ENV=production
ENV PYTHONPATH=/app

# Switch to non-root user
USER appuser

# Add labels
LABEL maintainer="student@example.com"
LABEL version="$APP_VERSION"
LABEL description="Optimized Flask application"

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Use gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
EOF

echo "📝 Created optimized Flask application"
echo "🐳 Building optimized Docker image..."

docker build --build-arg APP_VERSION=1.2.0 -t optimized-app:1.2.0 .

echo "✅ Optimized image built successfully"

# Test the optimized app
echo "🧪 Testing the optimized application..."
OPT_CONTAINER=$(docker run -d -p 5001:5000 --name optimized-app optimized-app:1.2.0)

sleep 3

if curl -s http://localhost:5001/health > /dev/null; then
    echo "✅ Optimized app is running successfully"
    echo "📊 App info:"
    curl -s http://localhost:5001/ | head -5
else
    echo "⚠️  App might still be starting..."
fi

# Stop and remove container
docker stop optimized-app && docker rm optimized-app

cd ..

echo ""
echo "🎯 Exercise 5: Image Analysis"
echo "============================"

echo "📊 Analyzing built images..."

echo ""
echo "📋 Image sizes:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "(simple-python-app|data-science-env|data-api|optimized-app)"

echo ""
echo "🔍 Image layers (simple-python-app):"
docker history simple-python-app:latest --format "table {{.CreatedBy}}\t{{.Size}}"

echo ""
echo "🏷️  Image labels (optimized-app):"
docker inspect optimized-app:1.2.0 --format '{{json .Config.Labels}}' | python3 -m json.tool

echo ""
echo "🎯 Exercise 6: Cleanup"
echo "====================="

echo "🧹 Cleaning up containers and images..."

# Remove images
docker rmi simple-python-app:latest data-science-env:latest data-api:latest optimized-app:1.2.0 2>/dev/null || true

echo "✅ Images removed"

# Clean up files
cd "$EXERCISE_DIR/.."
rm -rf "$EXERCISE_DIR"

echo "✅ Exercise files cleaned up"

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully:"
echo "✅ Created simple Python application Dockerfile"
echo "✅ Built data science environment with dependencies"
echo "✅ Implemented multi-stage build for Node.js app"
echo "✅ Optimized Dockerfile with best practices"
echo "✅ Analyzed image sizes and layers"
echo "✅ Used build arguments and labels"
echo ""
echo "🔍 Key Dockerfile concepts practiced:"
echo "   FROM - Base image selection"
echo "   RUN - Execute build commands"
echo "   COPY - Copy files to image"
echo "   WORKDIR - Set working directory"
echo "   ENV - Environment variables"
echo "   EXPOSE - Document ports"
echo "   CMD - Default command"
echo "   USER - Security with non-root user"
echo "   HEALTHCHECK - Container health monitoring"
echo ""
echo "💡 Next: Learn Docker Compose for multi-container applications!"
