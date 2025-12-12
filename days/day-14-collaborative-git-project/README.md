# Day 14: Mini Project - Collaborative Git Workflow

**Duration**: 1.5-2 hours (Project Day)  
**Prerequisites**: Days 8-13 (Complete Git sequence)

## Project Overview

Build a collaborative data analytics platform using all Git concepts learned in Week 2. This project simulates a real team environment with multiple developers, feature branches, code reviews, and release management.

## Learning Objectives

By completing this project, you will:
- Implement a complete Gitflow workflow
- Handle realistic merge conflicts
- Conduct code reviews and pull requests
- Manage releases with proper tagging
- Practice advanced Git techniques in context
- Simulate team collaboration scenarios

## Project Scenario

**Team**: Data Analytics Startup  
**Product**: Customer Analytics Platform  
**Timeline**: Sprint planning → Feature development → Code review → Release  
**Team Roles**: You'll simulate multiple developers working on different features

## Project Structure

```
customer-analytics-platform/
├── README.md
├── requirements.txt
├── .gitignore
├── src/
│   ├── __init__.py
│   ├── data_loader.py
│   ├── analytics.py
│   ├── visualizer.py
│   └── api.py
├── tests/
│   ├── test_data_loader.py
│   ├── test_analytics.py
│   └── test_api.py
├── docs/
│   ├── API.md
│   └── DEPLOYMENT.md
└── config/
    ├── development.yml
    └── production.yml
```

## Phase 1: Project Setup (15 minutes)

### Initialize Repository
```bash
# Create project directory
mkdir customer-analytics-platform
cd customer-analytics-platform

# Initialize Git with main branch
git init
git checkout -b main

# Configure Git (if not already done)
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Create Initial Project Structure
```bash
# Create directories
mkdir -p src tests docs config

# Create basic files
touch src/__init__.py
touch requirements.txt
touch .gitignore
```

### Setup .gitignore
```gitignore
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
```

### Initial Commit
```bash
git add .
git commit -m "Initial project setup

- Add project structure
- Configure .gitignore
- Setup Python package structure"
```

## Phase 2: Gitflow Setup (10 minutes)

### Create Develop Branch
```bash
# Create and switch to develop branch
git checkout -b develop
git push -u origin develop  # If using remote
```

### Create Initial Codebase
Create basic application files:

**src/data_loader.py**:
```python
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
```

**requirements.txt**:
```
pandas>=1.3.0
numpy>=1.21.0
matplotlib>=3.4.0
flask>=2.0.0
pytest>=6.2.0
```

**README.md**:
```markdown
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
```

Commit initial codebase:
```bash
git add .
git commit -m "feat: add initial data loading functionality

- Implement DataLoader class
- Support CSV and JSON formats
- Add project documentation
- Setup requirements"
```

## Phase 3: Feature Development (30 minutes)

### Feature 1: Analytics Module (Developer A)
```bash
# Start feature branch
git checkout develop
git checkout -b feature/analytics-engine

# Create analytics module
```

**src/analytics.py**:
```python
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
        ages = [int(customer.get('age', 0)) for customer in self.data]
        return statistics.mean(ages) if ages else 0
    
    def top_cities(self, limit=5):
        """Get top cities by customer count."""
        cities = [customer.get('city', 'Unknown') for customer in self.data]
        return Counter(cities).most_common(limit)
    
    def age_distribution(self):
        """Get age distribution statistics."""
        ages = [int(customer.get('age', 0)) for customer in self.data]
        if not ages:
            return {}
        
        return {
            'mean': statistics.mean(ages),
            'median': statistics.median(ages),
            'mode': statistics.mode(ages),
            'min': min(ages),
            'max': max(ages)
        }
```

**tests/test_analytics.py**:
```python
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

def test_top_cities():
    data = [
        {'city': 'New York'}, 
        {'city': 'New York'}, 
        {'city': 'Boston'}
    ]
    analytics = CustomerAnalytics(data)
    result = analytics.top_cities()
    assert result[0] == ('New York', 2)
```

Commit feature:
```bash
git add .
git commit -m "feat: implement customer analytics engine

- Add CustomerAnalytics class
- Implement age statistics
- Add city analysis
- Include comprehensive tests"
```

### Feature 2: Visualization Module (Developer B)
```bash
# Switch to develop and create new feature
git checkout develop
git checkout -b feature/data-visualization

# Create visualization module
```

**src/visualizer.py**:
```python
"""Data visualization utilities."""
import matplotlib.pyplot as plt
from collections import Counter

class DataVisualizer:
    def __init__(self, analytics):
        self.analytics = analytics
    
    def plot_age_distribution(self, save_path=None):
        """Create age distribution histogram."""
        ages = [int(c.get('age', 0)) for c in self.analytics.data]
        
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
```

Commit visualization feature:
```bash
git add .
git commit -m "feat: add data visualization capabilities

- Implement DataVisualizer class
- Add age distribution histogram
- Add city distribution bar chart
- Support saving plots to files"
```

### Feature 3: REST API (Developer C)
```bash
# Create API feature branch
git checkout develop
git checkout -b feature/rest-api

# Create API module
```

**src/api.py**:
```python
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
    # In real app, this would load from database
    sample_data = [
        {'name': 'John', 'age': '25', 'city': 'New York'},
        {'name': 'Jane', 'age': '30', 'city': 'Boston'}
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
    
    # Implementation would handle file upload
    return jsonify({'message': 'File uploaded successfully'})

if __name__ == '__main__':
    app.run(debug=True)
```

**tests/test_api.py**:
```python
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
```

Commit API feature:
```bash
git add .
git commit -m "feat: implement REST API endpoints

- Add Flask-based REST API
- Implement health check endpoint
- Add analytics summary endpoint
- Add data upload endpoint
- Include API tests"
```

## Phase 4: Integration and Conflicts (20 minutes)

### Merge Features to Develop
```bash
# Merge analytics feature
git checkout develop
git merge feature/analytics-engine

# Merge visualization (may cause conflicts)
git merge feature/data-visualization

# If conflicts occur in imports or dependencies:
# Resolve by combining imports properly
```

### Create Integration Conflicts
Simulate realistic conflicts by modifying the same files:

**Update src/analytics.py** on develop:
```python
# Add new method that conflicts with API branch
def export_summary(self):
    """Export analytics summary."""
    return {
        'total_customers': self.customer_count(),
        'avg_age': self.average_age(),
        'cities': self.top_cities()
    }
```

**Merge API branch** (will conflict):
```bash
git merge feature/rest-api
# Resolve conflicts by combining both export_summary and API functionality
```

### Resolve Conflicts
Edit conflicted files to combine functionality properly, then:
```bash
git add .
git commit -m "resolve: merge API feature with analytics updates

- Combine export_summary method
- Integrate API endpoints with analytics
- Resolve import conflicts"
```

## Phase 5: Code Review Simulation (15 minutes)

### Create Pull Request Branch
```bash
git checkout -b review/integration-v1.0
```

### Code Review Checklist
Review the integrated code for:
- [ ] Functionality works as expected
- [ ] Tests pass for all modules
- [ ] Code follows Python conventions
- [ ] Documentation is complete
- [ ] No security vulnerabilities
- [ ] Performance considerations addressed

### Address Review Feedback
Make improvements based on review:

**Update documentation**:
```bash
# Add API documentation
```

**docs/API.md**:
```markdown
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
```

Commit improvements:
```bash
git add .
git commit -m "docs: add comprehensive API documentation

- Document all endpoints
- Add request/response examples
- Include error handling info"
```

## Phase 6: Release Management (15 minutes)

### Prepare Release
```bash
# Create release branch
git checkout develop
git checkout -b release/v1.0.0

# Update version information
echo "1.0.0" > VERSION

# Create changelog
```

**CHANGELOG.md**:
```markdown
# Changelog

## [1.0.0] - 2024-12-12

### Added
- Customer data loading (CSV, JSON)
- Analytics engine with age and city analysis
- Data visualization with matplotlib
- REST API with Flask
- Comprehensive test suite
- API documentation

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
```

Commit release preparation:
```bash
git add .
git commit -m "chore: prepare release v1.0.0

- Add version file
- Create comprehensive changelog
- Document all features and improvements"
```

### Complete Release
```bash
# Merge to main
git checkout main
git merge release/v1.0.0

# Tag release
git tag -a v1.0.0 -m "Release version 1.0.0

Customer Analytics Platform v1.0.0
- Complete analytics engine
- Data visualization
- REST API
- Comprehensive testing"

# Merge back to develop
git checkout develop
git merge release/v1.0.0

# Clean up release branch
git branch -d release/v1.0.0
```

## Phase 7: Hotfix Simulation (10 minutes)

### Critical Bug Discovery
```bash
# Create hotfix branch from main
git checkout main
git checkout -b hotfix/v1.0.1

# Fix critical bug in analytics
```

**Fix in src/analytics.py**:
```python
def average_age(self):
    """Calculate average customer age."""
    ages = [int(customer.get('age', 0)) for customer in self.data if customer.get('age')]
    return statistics.mean(ages) if ages else 0  # Handle empty ages list
```

**Add test for fix**:
```python
def test_average_age_empty_data():
    analytics = CustomerAnalytics([])
    assert analytics.average_age() == 0

def test_average_age_missing_ages():
    data = [{'name': 'John'}, {'name': 'Jane'}]  # No age field
    analytics = CustomerAnalytics(data)
    assert analytics.average_age() == 0
```

### Complete Hotfix
```bash
git add .
git commit -m "fix: handle empty age data in analytics

- Add null check for age calculations
- Handle missing age fields gracefully
- Add tests for edge cases
- Prevent division by zero errors"

# Update version
echo "1.0.1" > VERSION
git add VERSION
git commit -m "chore: bump version to 1.0.1"

# Merge to main and tag
git checkout main
git merge hotfix/v1.0.1
git tag -a v1.0.1 -m "Hotfix version 1.0.1 - Fix age calculation bug"

# Merge to develop
git checkout develop
git merge hotfix/v1.0.1

# Clean up
git branch -d hotfix/v1.0.1
```

## Project Completion

### Final Repository State
```bash
# View final project structure
git log --oneline --graph --all -15

# Show all tags
git tag -l

# Show branch history
git branch -a
```

### Project Summary
You have successfully:
- ✅ Implemented complete Gitflow workflow
- ✅ Developed multiple features in parallel
- ✅ Resolved realistic merge conflicts
- ✅ Conducted code review process
- ✅ Managed releases with proper tagging
- ✅ Handled emergency hotfix deployment
- ✅ Created production-ready codebase

## Key Takeaways

- **Gitflow Structure**: Organized development with clear branch purposes
- **Conflict Resolution**: Systematic approach to merging parallel work
- **Code Review**: Quality assurance through peer review process
- **Release Management**: Proper versioning and change documentation
- **Hotfix Process**: Rapid response to production issues
- **Team Collaboration**: Simulated real-world development scenarios

## Next Steps

Week 3 (Days 15-21) will focus on Docker and containerization, building on the solid Git foundation you've established. You'll containerize this analytics platform and learn modern deployment practices.
