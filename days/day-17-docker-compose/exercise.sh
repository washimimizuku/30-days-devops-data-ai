#!/bin/bash

# Day 17: Docker Compose - Hands-on Exercise
# Practice multi-container orchestration with Docker Compose

set -e

echo "🚀 Day 17: Docker Compose Exercise"
echo "=================================="

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Create exercise directory
EXERCISE_DIR="$HOME/docker-compose-exercise"
echo "📁 Creating exercise directory: $EXERCISE_DIR"

if [ -d "$EXERCISE_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$EXERCISE_DIR"
fi

mkdir -p "$EXERCISE_DIR"
cd "$EXERCISE_DIR"

echo ""
echo "🎯 Exercise 1: Simple Web App with Database"
echo "==========================================="

mkdir -p simple-webapp
cd simple-webapp

# Create a simple Flask application
cat > app.py << 'EOF'
#!/usr/bin/env python3
"""Simple Flask web application with database."""

from flask import Flask, jsonify, request
import psycopg2
import os
import json

app = Flask(__name__)

def get_db_connection():
    """Get database connection."""
    return psycopg2.connect(
        host=os.getenv('DB_HOST', 'db'),
        database=os.getenv('DB_NAME', 'webapp'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'password')
    )

@app.route('/')
def home():
    return jsonify({
        'message': 'Simple Web App with Docker Compose',
        'version': '1.0.0',
        'endpoints': ['/users', '/health', '/stats']
    })

@app.route('/health')
def health():
    try:
        conn = get_db_connection()
        conn.close()
        return jsonify({'status': 'healthy', 'database': 'connected'})
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

@app.route('/users', methods=['GET', 'POST'])
def users():
    conn = get_db_connection()
    cur = conn.cursor()
    
    if request.method == 'POST':
        data = request.get_json()
        cur.execute(
            "INSERT INTO users (name, email) VALUES (%s, %s) RETURNING id",
            (data['name'], data['email'])
        )
        user_id = cur.fetchone()[0]
        conn.commit()
        cur.close()
        conn.close()
        return jsonify({'id': user_id, 'message': 'User created'})
    
    else:
        cur.execute("SELECT id, name, email FROM users")
        users = cur.fetchall()
        cur.close()
        conn.close()
        return jsonify({
            'users': [{'id': u[0], 'name': u[1], 'email': u[2]} for u in users]
        })

@app.route('/stats')
def stats():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM users")
    count = cur.fetchone()[0]
    cur.close()
    conn.close()
    return jsonify({'total_users': count})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
Flask==2.3.2
psycopg2-binary==2.9.6
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app.py .

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Run application
CMD ["python", "app.py"]
EOF

# Create database initialization script
cat > init.sql << 'EOF'
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES 
    ('John Doe', 'john@example.com'),
    ('Jane Smith', 'jane@example.com'),
    ('Bob Johnson', 'bob@example.com');
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    build: .
    ports:
      - "5000:5000"
    environment:
      - DB_HOST=db
      - DB_NAME=webapp
      - DB_USER=postgres
      - DB_PASSWORD=password
    depends_on:
      - db
    networks:
      - webapp-network

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=webapp
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - webapp-network

volumes:
  postgres_data:

networks:
  webapp-network:
    driver: bridge
EOF

echo "📝 Created simple web application with database"
echo "🐳 Starting services with Docker Compose..."

docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 10

# Test the application
echo "🧪 Testing the application..."
if curl -s http://localhost:5000/health > /dev/null; then
    echo "✅ Application is healthy"
    echo "📊 Application info:"
    curl -s http://localhost:5000/ | head -5
    echo ""
    echo "👥 Users in database:"
    curl -s http://localhost:5000/users | head -10
else
    echo "⚠️  Application might still be starting..."
fi

echo "📊 Service status:"
docker-compose ps

cd ..

echo ""
echo "🎯 Exercise 2: Data Science Stack"
echo "================================="

mkdir -p data-science-stack
cd data-science-stack

# Create sample data
mkdir -p data notebooks

cat > data/sample_data.csv << 'EOF'
id,name,age,salary,department
1,Alice Johnson,28,75000,Engineering
2,Bob Smith,35,82000,Engineering
3,Carol Davis,42,95000,Management
4,David Wilson,31,68000,Marketing
5,Eva Brown,29,71000,Engineering
6,Frank Miller,38,88000,Management
7,Grace Lee,26,63000,Marketing
8,Henry Taylor,45,105000,Management
9,Ivy Chen,33,79000,Engineering
10,Jack Anderson,27,65000,Marketing
EOF

# Create Jupyter notebook
cat > notebooks/analysis.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Employee Data Analysis\n",
    "\n",
    "This notebook analyzes employee data using pandas and matplotlib."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "import seaborn as sns\n",
    "\n",
    "# Load data\n",
    "df = pd.read_csv('/home/jovyan/data/sample_data.csv')\n",
    "print(\"Dataset shape:\", df.shape)\n",
    "df.head()"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Basic statistics\n",
    "print(\"Summary statistics:\")\n",
    "print(df.describe())\n",
    "\n",
    "print(\"\\nDepartment distribution:\")\n",
    "print(df['department'].value_counts())"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Visualizations\n",
    "fig, axes = plt.subplots(2, 2, figsize=(12, 10))\n",
    "\n",
    "# Age distribution\n",
    "axes[0, 0].hist(df['age'], bins=10, edgecolor='black')\n",
    "axes[0, 0].set_title('Age Distribution')\n",
    "axes[0, 0].set_xlabel('Age')\n",
    "axes[0, 0].set_ylabel('Count')\n",
    "\n",
    "# Salary by department\n",
    "df.boxplot(column='salary', by='department', ax=axes[0, 1])\n",
    "axes[0, 1].set_title('Salary by Department')\n",
    "\n",
    "# Age vs Salary scatter\n",
    "axes[1, 0].scatter(df['age'], df['salary'])\n",
    "axes[1, 0].set_title('Age vs Salary')\n",
    "axes[1, 0].set_xlabel('Age')\n",
    "axes[1, 0].set_ylabel('Salary')\n",
    "\n",
    "# Department counts\n",
    "df['department'].value_counts().plot(kind='bar', ax=axes[1, 1])\n",
    "axes[1, 1].set_title('Employees by Department')\n",
    "axes[1, 1].set_xlabel('Department')\n",
    "axes[1, 1].set_ylabel('Count')\n",
    "\n",
    "plt.tight_layout()\n",
    "plt.show()"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.9.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

# Create docker-compose.yml for data science stack
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  jupyter:
    image: jupyter/scipy-notebook:latest
    ports:
      - "8888:8888"
    environment:
      - JUPYTER_ENABLE_LAB=yes
      - JUPYTER_TOKEN=easy-password
    volumes:
      - ./notebooks:/home/jovyan/work
      - ./data:/home/jovyan/data
    networks:
      - datascience-network

  postgres:
    image: postgres:13
    environment:
      - POSTGRES_DB=analytics
      - POSTGRES_USER=analyst
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - datascience-network

  pgadmin:
    image: dpage/pgadmin4:latest
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@example.com
      - PGADMIN_DEFAULT_PASSWORD=admin
    ports:
      - "8080:80"
    depends_on:
      - postgres
    networks:
      - datascience-network

volumes:
  postgres_data:

networks:
  datascience-network:
    driver: bridge
EOF

echo "📝 Created data science stack"
echo "🐳 Starting data science services..."

docker-compose up -d

echo "⏳ Waiting for services to be ready..."
sleep 15

echo "✅ Data science stack is running"
echo "🔗 Access points:"
echo "   Jupyter Lab: http://localhost:8888 (token: easy-password)"
echo "   PostgreSQL: localhost:5432 (user: analyst, password: password)"
echo "   PgAdmin: http://localhost:8080 (admin@example.com / admin)"

echo "📊 Service status:"
docker-compose ps

cd ..

echo ""
echo "🎯 Exercise 3: Multi-Service Application"
echo "======================================="

mkdir -p multi-service-app
cd multi-service-app

# Create API service
mkdir -p api
cat > api/app.py << 'EOF'
#!/usr/bin/env python3
"""API service for multi-service application."""

from flask import Flask, jsonify
import redis
import json
import os

app = Flask(__name__)

# Redis connection
redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'redis'),
    port=6379,
    decode_responses=True
)

@app.route('/')
def home():
    return jsonify({
        'service': 'API',
        'version': '1.0.0',
        'endpoints': ['/data', '/cache', '/health']
    })

@app.route('/health')
def health():
    try:
        redis_client.ping()
        return jsonify({'status': 'healthy', 'redis': 'connected'})
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

@app.route('/data')
def get_data():
    # Sample data
    data = {
        'users': [
            {'id': 1, 'name': 'Alice', 'role': 'admin'},
            {'id': 2, 'name': 'Bob', 'role': 'user'},
            {'id': 3, 'name': 'Carol', 'role': 'user'}
        ],
        'timestamp': '2024-01-01T12:00:00Z'
    }
    
    # Cache data in Redis
    redis_client.setex('api_data', 300, json.dumps(data))
    
    return jsonify(data)

@app.route('/cache')
def get_cache():
    cached_data = redis_client.get('api_data')
    if cached_data:
        return jsonify({
            'cached': True,
            'data': json.loads(cached_data)
        })
    else:
        return jsonify({'cached': False, 'message': 'No cached data'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

cat > api/requirements.txt << 'EOF'
Flask==2.3.2
redis==4.5.4
EOF

cat > api/Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["python", "app.py"]
EOF

# Create worker service
mkdir -p worker
cat > worker/worker.py << 'EOF'
#!/usr/bin/env python3
"""Background worker service."""

import redis
import time
import json
import random
import os

# Redis connection
redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST', 'redis'),
    port=6379,
    decode_responses=True
)

def process_tasks():
    """Process background tasks."""
    print("🔄 Worker started, processing tasks...")
    
    while True:
        try:
            # Simulate processing
            task_data = {
                'task_id': random.randint(1000, 9999),
                'status': 'completed',
                'processed_at': time.strftime('%Y-%m-%d %H:%M:%S'),
                'result': random.randint(1, 100)
            }
            
            # Store result in Redis
            redis_client.setex(
                f"task_{task_data['task_id']}", 
                3600, 
                json.dumps(task_data)
            )
            
            print(f"✅ Processed task {task_data['task_id']}")
            
            # Wait before next task
            time.sleep(10)
            
        except Exception as e:
            print(f"❌ Error processing task: {e}")
            time.sleep(5)

if __name__ == '__main__':
    process_tasks()
EOF

cat > worker/requirements.txt << 'EOF'
redis==4.5.4
EOF

cat > worker/Dockerfile << 'EOF'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY worker.py .

CMD ["python", "worker.py"]
EOF

# Create nginx configuration
mkdir -p nginx
cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream api {
        server api:5000;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        location /health {
            access_log off;
            proxy_pass http://api/health;
        }
    }
}
EOF

# Create docker-compose.yml for multi-service app
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  api:
    build: ./api
    environment:
      - REDIS_HOST=redis
    depends_on:
      - redis
    networks:
      - app-network

  worker:
    build: ./worker
    environment:
      - REDIS_HOST=redis
    depends_on:
      - redis
    networks:
      - app-network

  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
    networks:
      - app-network

  nginx:
    image: nginx:alpine
    ports:
      - "8000:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - api
    networks:
      - app-network

volumes:
  redis_data:

networks:
  app-network:
    driver: bridge
EOF

echo "📝 Created multi-service application"
echo "🐳 Building and starting services..."

docker-compose up -d --build

echo "⏳ Waiting for services to be ready..."
sleep 15

# Test the multi-service application
echo "🧪 Testing multi-service application..."
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ Multi-service application is healthy"
    echo "📊 API response:"
    curl -s http://localhost:8000/ | head -5
    echo ""
    echo "💾 Testing cache functionality..."
    curl -s http://localhost:8000/data > /dev/null
    curl -s http://localhost:8000/cache | head -5
else
    echo "⚠️  Application might still be starting..."
fi

echo "📊 Service status:"
docker-compose ps

cd ..

echo ""
echo "🎯 Exercise 4: Service Management"
echo "================================"

echo "📋 Demonstrating Docker Compose commands..."

cd simple-webapp

echo ""
echo "🔍 Viewing logs:"
docker-compose logs --tail=5 web

echo ""
echo "📊 Service status:"
docker-compose ps

echo ""
echo "🔧 Executing command in service:"
docker-compose exec db psql -U postgres -d webapp -c "SELECT COUNT(*) FROM users;"

echo ""
echo "⚖️  Scaling web service:"
docker-compose up -d --scale web=2

echo "📊 Scaled services:"
docker-compose ps

# Scale back down
docker-compose up -d --scale web=1

cd ..

echo ""
echo "🎯 Exercise 5: Cleanup"
echo "====================="

echo "🧹 Stopping and cleaning up all services..."

# Stop all compose projects
cd simple-webapp && docker-compose down -v && cd ..
cd data-science-stack && docker-compose down -v && cd ..
cd multi-service-app && docker-compose down -v && cd ..

echo "✅ All services stopped and cleaned up"

# Clean up files
cd "$EXERCISE_DIR/.."
rm -rf "$EXERCISE_DIR"

echo "✅ Exercise files cleaned up"

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully:"
echo "✅ Created web application with database using Docker Compose"
echo "✅ Built complete data science stack with Jupyter and PostgreSQL"
echo "✅ Orchestrated multi-service application with API, worker, and cache"
echo "✅ Managed services with compose commands"
echo "✅ Scaled services horizontally"
echo "✅ Used networks and volumes for service communication"
echo ""
echo "🔍 Key Docker Compose concepts practiced:"
echo "   docker-compose.yml - Service definitions"
echo "   services - Application components"
echo "   networks - Service communication"
echo "   volumes - Data persistence"
echo "   depends_on - Service dependencies"
echo "   environment - Configuration variables"
echo "   ports - External access"
echo "   build - Custom image building"
echo ""
echo "💡 Next: Learn Docker volumes and networking in detail!"
