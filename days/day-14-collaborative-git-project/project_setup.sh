#!/bin/bash

# Day 14: Collaborative Git Project - Automated Setup
# Creates the complete customer analytics platform project

set -e

echo "🚀 Day 14: Collaborative Git Project Setup"
echo "=========================================="

# Create project directory
PROJECT_DIR="$HOME/customer-analytics-platform"
echo "📁 Creating project directory: $PROJECT_DIR"

if [ -d "$PROJECT_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$PROJECT_DIR"
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo ""
echo "🎯 Phase 1: Repository Initialization"
echo "===================================="

# Initialize Git repository
git init
git config user.name "Git Student"
git config user.email "student@example.com"

# Create project structure
mkdir -p src tests docs config

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/

# Data files
*.csv
*.json
data/
*.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Environment
.env
.env.local
EOF

# Create requirements.txt
cat > requirements.txt << 'EOF'
pandas>=1.3.0
numpy>=1.21.0
matplotlib>=3.4.0
flask>=2.0.0
pytest>=6.2.0
EOF

# Create initial README
cat > README.md << 'EOF'
# Customer Analytics Platform

A comprehensive platform for customer data analysis and visualization.

## Features
- Data loading from multiple formats
- Statistical analysis
- Data visualization
- REST API

## Setup
```bash
pip install -r requirements.txt
python -m pytest tests/
```

## Usage
```python
from src.data_loader import DataLoader
loader = DataLoader()
data = loader.load_csv('customers.csv')
```
EOF

# Create Python package
touch src/__init__.py

# Initial commit
git add .
git commit -m "Initial project setup

- Add project structure
- Configure .gitignore
- Setup Python package structure"

echo "✅ Repository initialized"

echo ""
echo "🎯 Phase 2: Gitflow Setup"
echo "========================="

# Create develop branch
git checkout -b develop

# Create initial data loader
cat > src/data_loader.py << 'EOF'
"""Data loading utilities."""
import csv
import json

class DataLoader:
    def __init__(self):
        self.supported_formats = ['csv', 'json']
    
    def load_csv(self, filepath):
        """Load data from CSV file."""
        data = []
        with open(filepath, 'r') as file:
            reader = csv.DictReader(file)
            data = list(reader)
        return data
    
    def load_json(self, filepath):
        """Load data from JSON file."""
        with open(filepath, 'r') as file:
            data = json.load(file)
        return data
EOF

git add .
git commit -m "feat: add initial data loading functionality

- Implement DataLoader class
- Support CSV and JSON formats
- Add project documentation
- Setup requirements"

echo "✅ Develop branch created with initial code"

echo ""
echo "🎯 Phase 3: Feature Development"
echo "==============================="

# Feature 1: Analytics Engine
git checkout -b feature/analytics-engine

cat > src/analytics.py << 'EOF'
"""Analytics engine for customer data."""
import statistics
from collections import Counter

class CustomerAnalytics:
    def __init__(self, data):
        self.data = data
    
    def customer_count(self):
        """Get total customer count."""
        return len(self.data)
    
    def average_age(self):
        """Calculate average customer age."""
        ages = [int(customer.get('age', 0)) for customer in self.data if customer.get('age')]
        return statistics.mean(ages) if ages else 0
    
    def top_cities(self, limit=5):
        """Get top cities by customer count."""
        cities = [customer.get('city', 'Unknown') for customer in self.data]
        return Counter(cities).most_common(limit)
    
    def age_distribution(self):
        """Get age distribution statistics."""
        ages = [int(customer.get('age', 0)) for customer in self.data if customer.get('age')]
        if not ages:
            return {}
        
        return {
            'mean': statistics.mean(ages),
            'median': statistics.median(ages),
            'min': min(ages),
            'max': max(ages)
        }
EOF

cat > tests/test_analytics.py << 'EOF'
"""Tests for analytics module."""
import pytest
from src.analytics import CustomerAnalytics

def test_customer_count():
    data = [{'name': 'John', 'age': '25'}, {'name': 'Jane', 'age': '30'}]
    analytics = CustomerAnalytics(data)
    assert analytics.customer_count() == 2

def test_average_age():
    data = [{'age': '25'}, {'age': '35'}]
    analytics = CustomerAnalytics(data)
    assert analytics.average_age() == 30.0

def test_average_age_empty_data():
    analytics = CustomerAnalytics([])
    assert analytics.average_age() == 0

def test_top_cities():
    data = [
        {'city': 'New York'}, 
        {'city': 'New York'}, 
        {'city': 'Boston'}
    ]
    analytics = CustomerAnalytics(data)
    result = analytics.top_cities()
    assert result[0] == ('New York', 2)
EOF

git add .
git commit -m "feat: implement customer analytics engine

- Add CustomerAnalytics class
- Implement age statistics
- Add city analysis
- Include comprehensive tests"

echo "✅ Analytics feature completed"

# Feature 2: Visualization
git checkout develop
git checkout -b feature/data-visualization

cat > src/visualizer.py << 'EOF'
"""Data visualization utilities."""
import matplotlib.pyplot as plt
from collections import Counter

class DataVisualizer:
    def __init__(self, analytics):
        self.analytics = analytics
    
    def plot_age_distribution(self, save_path=None):
        """Create age distribution histogram."""
        ages = [int(c.get('age', 0)) for c in self.analytics.data if c.get('age')]
        
        plt.figure(figsize=(10, 6))
        plt.hist(ages, bins=20, edgecolor='black', alpha=0.7)
        plt.title('Customer Age Distribution')
        plt.xlabel('Age')
        plt.ylabel('Count')
        
        if save_path:
            plt.savefig(save_path)
        return plt
    
    def plot_city_distribution(self, save_path=None):
        """Create city distribution bar chart."""
        cities = self.analytics.top_cities(10)
        
        names = [city[0] for city in cities]
        counts = [city[1] for city in cities]
        
        plt.figure(figsize=(12, 6))
        plt.bar(names, counts)
        plt.title('Top Cities by Customer Count')
        plt.xlabel('City')
        plt.ylabel('Customer Count')
        plt.xticks(rotation=45)
        
        if save_path:
            plt.savefig(save_path, bbox_inches='tight')
        return plt
EOF

git add .
git commit -m "feat: add data visualization capabilities

- Implement DataVisualizer class
- Add age distribution histogram
- Add city distribution bar chart
- Support saving plots to files"

echo "✅ Visualization feature completed"

# Feature 3: REST API
git checkout develop
git checkout -b feature/rest-api

cat > src/api.py << 'EOF'
"""REST API for customer analytics."""
from flask import Flask, jsonify, request
from src.data_loader import DataLoader
from src.analytics import CustomerAnalytics

app = Flask(__name__)

@app.route('/health')
def health_check():
    """Health check endpoint."""
    return jsonify({'status': 'healthy', 'version': '1.0.0'})

@app.route('/analytics/summary')
def analytics_summary():
    """Get analytics summary."""
    # Sample data for demo
    sample_data = [
        {'name': 'John', 'age': '25', 'city': 'New York'},
        {'name': 'Jane', 'age': '30', 'city': 'Boston'},
        {'name': 'Bob', 'age': '35', 'city': 'New York'}
    ]
    
    analytics = CustomerAnalytics(sample_data)
    
    return jsonify({
        'customer_count': analytics.customer_count(),
        'average_age': analytics.average_age(),
        'top_cities': analytics.top_cities(5),
        'age_distribution': analytics.age_distribution()
    })

@app.route('/data/upload', methods=['POST'])
def upload_data():
    """Upload customer data."""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    return jsonify({'message': 'File uploaded successfully'})

if __name__ == '__main__':
    app.run(debug=True)
EOF

cat > tests/test_api.py << 'EOF'
"""Tests for REST API."""
import pytest
from src.api import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_health_check(client):
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'

def test_analytics_summary(client):
    response = client.get('/analytics/summary')
    assert response.status_code == 200
    data = response.get_json()
    assert 'customer_count' in data
    assert 'average_age' in data
EOF

git add .
git commit -m "feat: implement REST API endpoints

- Add Flask-based REST API
- Implement health check endpoint
- Add analytics summary endpoint
- Add data upload endpoint
- Include API tests"

echo "✅ API feature completed"

echo ""
echo "🎯 Phase 4: Integration"
echo "======================"

# Merge features to develop
git checkout develop
git merge feature/analytics-engine
echo "✅ Merged analytics feature"

git merge feature/data-visualization
echo "✅ Merged visualization feature"

git merge feature/rest-api
echo "✅ Merged API feature"

# Clean up feature branches
git branch -d feature/analytics-engine
git branch -d feature/data-visualization
git branch -d feature/rest-api

echo ""
echo "🎯 Phase 5: Release Preparation"
echo "==============================="

# Create release branch
git checkout -b release/v1.0.0

# Add version file
echo "1.0.0" > VERSION

# Create changelog
cat > CHANGELOG.md << 'EOF'
# Changelog

## [1.0.0] - 2024-12-12

### Added
- Customer data loading (CSV, JSON)
- Analytics engine with age and city analysis
- Data visualization with matplotlib
- REST API with Flask
- Comprehensive test suite

### Features
- Load customer data from multiple formats
- Calculate customer statistics
- Generate visualizations
- RESTful API endpoints
- Health monitoring

### Technical
- Python 3.8+ support
- Flask web framework
- Matplotlib for visualization
- Pytest for testing
EOF

# Create API documentation
cat > docs/API.md << 'EOF'
# API Documentation

## Endpoints

### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0"
}
```

### GET /analytics/summary
Get customer analytics summary.

**Response:**
```json
{
  "customer_count": 150,
  "average_age": 32.5,
  "top_cities": [["New York", 45], ["Boston", 32]],
  "age_distribution": {
    "mean": 32.5,
    "median": 31.0,
    "min": 18,
    "max": 65
  }
}
```
EOF

git add .
git commit -m "chore: prepare release v1.0.0

- Add version file
- Create comprehensive changelog
- Add API documentation"

echo "✅ Release prepared"

# Complete release
git checkout main
git merge release/v1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0 - Customer Analytics Platform"

git checkout develop
git merge release/v1.0.0
git branch -d release/v1.0.0

echo "✅ Release v1.0.0 completed"

echo ""
echo "🎯 Phase 6: Hotfix Simulation"
echo "============================="

# Create hotfix for critical bug
git checkout main
git checkout -b hotfix/v1.0.1

# Update version
echo "1.0.1" > VERSION

# Update changelog
cat > CHANGELOG.md << 'EOF'
# Changelog

## [1.0.1] - 2024-12-12

### Fixed
- Handle empty age data in analytics calculations
- Prevent division by zero errors
- Add null checks for missing data fields

## [1.0.0] - 2024-12-12

### Added
- Customer data loading (CSV, JSON)
- Analytics engine with age and city analysis
- Data visualization with matplotlib
- REST API with Flask
- Comprehensive test suite

### Features
- Load customer data from multiple formats
- Calculate customer statistics
- Generate visualizations
- RESTful API endpoints
- Health monitoring

### Technical
- Python 3.8+ support
- Flask web framework
- Matplotlib for visualization
- Pytest for testing
EOF

git add .
git commit -m "fix: handle empty age data in analytics

- Add null check for age calculations
- Handle missing age fields gracefully
- Prevent division by zero errors
- Update changelog"

# Complete hotfix
git checkout main
git merge hotfix/v1.0.1
git tag -a v1.0.1 -m "Hotfix version 1.0.1 - Fix age calculation bug"

git checkout develop
git merge hotfix/v1.0.1
git branch -d hotfix/v1.0.1

echo "✅ Hotfix v1.0.1 completed"

echo ""
echo "🎉 Project Setup Complete!"
echo "========================="
echo ""
echo "📊 Final repository state:"
git log --oneline --graph --all -10

echo ""
echo "🏷️  Tags created:"
git tag -l

echo ""
echo "📁 Project structure:"
find . -type f -name "*.py" -o -name "*.md" -o -name "*.txt" | head -15

echo ""
echo "✅ You have successfully created:"
echo "   - Complete Gitflow workflow"
echo "   - Multiple feature branches"
echo "   - Integrated codebase"
echo "   - Release management"
echo "   - Hotfix process"
echo "   - Production-ready code"
echo ""
echo "📁 Project location: $PROJECT_DIR"
echo ""
echo "🔍 Explore your work:"
echo "   cd $PROJECT_DIR"
echo "   git log --oneline --graph --all"
echo "   python -m pytest tests/"
echo "   python src/api.py"
