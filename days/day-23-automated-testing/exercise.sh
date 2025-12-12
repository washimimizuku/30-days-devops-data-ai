#!/bin/bash

# Day 23: Automated Testing - Hands-on Exercise
# Practice comprehensive automated testing strategies

set -e

echo "🚀 Day 23: Automated Testing Exercise"
echo "====================================="

# Create exercise directory
EXERCISE_DIR="$HOME/automated-testing-exercise"
echo "📁 Creating exercise directory: $EXERCISE_DIR"

if [ -d "$EXERCISE_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$EXERCISE_DIR"
fi

mkdir -p "$EXERCISE_DIR"
cd "$EXERCISE_DIR"

echo ""
echo "🎯 Exercise 1: Project Setup"
echo "============================"

# Create project structure
mkdir -p {src,tests/{unit,integration,performance},data}

# Create main application
cat > src/data_processor.py << 'EOF'
"""Data processing module for testing demonstration."""

import pandas as pd
import numpy as np
from typing import List, Dict, Any, Optional

class DataProcessor:
    """Main data processing class."""
    
    def __init__(self):
        self.processed_count = 0
    
    def clean_data(self, df: pd.DataFrame, strategy: str = 'drop') -> pd.DataFrame:
        """Clean data by handling missing values and duplicates."""
        if df.empty:
            return df
        
        # Remove duplicates
        df_clean = df.drop_duplicates()
        
        # Handle missing values
        if strategy == 'drop':
            df_clean = df_clean.dropna()
        elif strategy == 'fill':
            df_clean = df_clean.fillna(0)
        
        self.processed_count += 1
        return df_clean
    
    def validate_schema(self, df: pd.DataFrame, required_columns: List[str]) -> bool:
        """Validate dataframe schema."""
        missing_cols = set(required_columns) - set(df.columns)
        if missing_cols:
            raise ValueError(f"Missing required columns: {missing_cols}")
        return True
    
    def calculate_statistics(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Calculate basic statistics for numeric columns."""
        if df.empty:
            return {}
        
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        if len(numeric_cols) == 0:
            return {}
        
        stats = {}
        for col in numeric_cols:
            stats[col] = {
                'mean': float(df[col].mean()),
                'std': float(df[col].std()),
                'min': float(df[col].min()),
                'max': float(df[col].max()),
                'count': int(df[col].count())
            }
        
        return stats
    
    def filter_outliers(self, df: pd.DataFrame, column: str, method: str = 'iqr') -> pd.DataFrame:
        """Remove outliers from specified column."""
        if column not in df.columns:
            raise ValueError(f"Column '{column}' not found in dataframe")
        
        if method == 'iqr':
            Q1 = df[column].quantile(0.25)
            Q3 = df[column].quantile(0.75)
            IQR = Q3 - Q1
            lower_bound = Q1 - 1.5 * IQR
            upper_bound = Q3 + 1.5 * IQR
            
            return df[(df[column] >= lower_bound) & (df[column] <= upper_bound)]
        
        return df

def add(a: float, b: float) -> float:
    """Add two numbers."""
    return a + b

def divide(a: float, b: float) -> float:
    """Divide two numbers."""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

def calculate_average(numbers: List[float]) -> float:
    """Calculate average of a list of numbers."""
    if not numbers:
        raise ValueError("Cannot calculate average of empty list")
    return sum(numbers) / len(numbers)
EOF

# Create API module
cat > src/api.py << 'EOF'
"""Simple API for testing demonstration."""

from flask import Flask, jsonify, request
import pandas as pd
from .data_processor import DataProcessor

def create_app(testing=False):
    """Create Flask application."""
    app = Flask(__name__)
    
    if testing:
        app.config['TESTING'] = True
    
    processor = DataProcessor()
    
    @app.route('/health')
    def health():
        """Health check endpoint."""
        return jsonify({'status': 'healthy', 'version': '1.0.0'})
    
    @app.route('/api/process', methods=['POST'])
    def process_data():
        """Process data endpoint."""
        try:
            data = request.get_json()
            
            if not data or 'data' not in data:
                return jsonify({'error': 'No data provided'}), 400
            
            df = pd.DataFrame(data['data'])
            cleaned = processor.clean_data(df)
            stats = processor.calculate_statistics(cleaned)
            
            return jsonify({
                'processed_rows': len(cleaned),
                'statistics': stats,
                'status': 'success'
            })
        
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    @app.route('/api/validate', methods=['POST'])
    def validate_data():
        """Validate data schema endpoint."""
        try:
            data = request.get_json()
            
            if not data:
                return jsonify({'error': 'No data provided'}), 400
            
            df = pd.DataFrame(data.get('data', []))
            required_cols = data.get('required_columns', [])
            
            is_valid = processor.validate_schema(df, required_cols)
            
            return jsonify({
                'valid': is_valid,
                'columns': list(df.columns),
                'status': 'success'
            })
        
        except ValueError as e:
            return jsonify({'valid': False, 'error': str(e)}), 400
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    
    return app
EOF

# Create requirements files
cat > requirements.txt << 'EOF'
pandas>=1.5.0
numpy>=1.20.0
flask>=2.0.0
EOF

cat > requirements-test.txt << 'EOF'
pytest>=7.0.0
pytest-cov>=4.0.0
pytest-mock>=3.10.0
pytest-benchmark>=4.0.0
requests>=2.28.0
memory-profiler>=0.60.0
EOF

echo "✅ Project structure created"

echo ""
echo "🎯 Exercise 2: Unit Tests"
echo "========================="

# Create unit tests
cat > tests/conftest.py << 'EOF'
"""Shared test fixtures."""

import pytest
import pandas as pd
import numpy as np
from src.data_processor import DataProcessor
from src.api import create_app

@pytest.fixture
def processor():
    """Create DataProcessor instance."""
    return DataProcessor()

@pytest.fixture
def sample_data():
    """Create sample dataframe for testing."""
    return pd.DataFrame({
        'name': ['Alice', 'Bob', 'Carol', 'David'],
        'age': [25, 30, 35, 40],
        'salary': [50000, 60000, 70000, 80000],
        'department': ['Engineering', 'Marketing', 'Engineering', 'Sales']
    })

@pytest.fixture
def data_with_missing():
    """Create dataframe with missing values."""
    return pd.DataFrame({
        'A': [1, 2, np.nan, 4],
        'B': [1, np.nan, 3, 4],
        'C': ['a', 'b', 'c', 'd']
    })

@pytest.fixture
def data_with_outliers():
    """Create dataframe with outliers."""
    return pd.DataFrame({
        'values': [1, 2, 3, 4, 5, 100, 6, 7, 8, 9]  # 100 is outlier
    })

@pytest.fixture
def app():
    """Create test Flask application."""
    return create_app(testing=True)

@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()
EOF

cat > tests/unit/test_data_processor.py << 'EOF'
"""Unit tests for DataProcessor class."""

import pytest
import pandas as pd
import numpy as np
from src.data_processor import DataProcessor, add, divide, calculate_average

class TestBasicFunctions:
    """Test basic utility functions."""
    
    def test_add(self):
        """Test addition function."""
        assert add(2, 3) == 5
        assert add(-1, 1) == 0
        assert add(0, 0) == 0
        assert add(2.5, 3.5) == 6.0
    
    def test_divide(self):
        """Test division function."""
        assert divide(10, 2) == 5
        assert divide(7, 2) == 3.5
        assert divide(-10, 2) == -5
    
    def test_divide_by_zero(self):
        """Test division by zero raises exception."""
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            divide(5, 0)
    
    @pytest.mark.parametrize("numbers,expected", [
        ([1, 2, 3, 4, 5], 3.0),
        ([10, 20], 15.0),
        ([5], 5.0),
        ([1.5, 2.5, 3.5], 2.5),
    ])
    def test_calculate_average(self, numbers, expected):
        """Test average calculation with various inputs."""
        assert calculate_average(numbers) == expected
    
    def test_calculate_average_empty(self):
        """Test average calculation with empty list."""
        with pytest.raises(ValueError, match="Cannot calculate average of empty list"):
            calculate_average([])

class TestDataProcessor:
    """Test DataProcessor class methods."""
    
    def test_init(self):
        """Test DataProcessor initialization."""
        processor = DataProcessor()
        assert processor.processed_count == 0
    
    def test_clean_data_drop_strategy(self, processor, data_with_missing):
        """Test data cleaning with drop strategy."""
        cleaned = processor.clean_data(data_with_missing, strategy='drop')
        
        assert not cleaned.isnull().any().any()
        assert len(cleaned) < len(data_with_missing)
        assert processor.processed_count == 1
    
    def test_clean_data_fill_strategy(self, processor, data_with_missing):
        """Test data cleaning with fill strategy."""
        cleaned = processor.clean_data(data_with_missing, strategy='fill')
        
        assert not cleaned.isnull().any().any()
        assert len(cleaned) == len(data_with_missing)
        assert (cleaned.fillna(0) == cleaned).all().all()
    
    def test_clean_data_empty_dataframe(self, processor):
        """Test cleaning empty dataframe."""
        empty_df = pd.DataFrame()
        result = processor.clean_data(empty_df)
        
        assert result.empty
        assert processor.processed_count == 1
    
    def test_validate_schema_success(self, processor, sample_data):
        """Test successful schema validation."""
        required_cols = ['name', 'age']
        result = processor.validate_schema(sample_data, required_cols)
        
        assert result is True
    
    def test_validate_schema_missing_columns(self, processor, sample_data):
        """Test schema validation with missing columns."""
        required_cols = ['name', 'age', 'missing_column']
        
        with pytest.raises(ValueError, match="Missing required columns"):
            processor.validate_schema(sample_data, required_cols)
    
    def test_calculate_statistics(self, processor, sample_data):
        """Test statistics calculation."""
        stats = processor.calculate_statistics(sample_data)
        
        assert 'age' in stats
        assert 'salary' in stats
        assert stats['age']['mean'] == 32.5
        assert stats['age']['count'] == 4
        assert stats['salary']['min'] == 50000
    
    def test_calculate_statistics_empty(self, processor):
        """Test statistics on empty dataframe."""
        empty_df = pd.DataFrame()
        stats = processor.calculate_statistics(empty_df)
        
        assert stats == {}
    
    def test_calculate_statistics_no_numeric(self, processor):
        """Test statistics on dataframe with no numeric columns."""
        text_df = pd.DataFrame({'text': ['a', 'b', 'c']})
        stats = processor.calculate_statistics(text_df)
        
        assert stats == {}
    
    def test_filter_outliers_iqr(self, processor, data_with_outliers):
        """Test outlier filtering with IQR method."""
        filtered = processor.filter_outliers(data_with_outliers, 'values', method='iqr')
        
        assert 100 not in filtered['values'].values
        assert len(filtered) < len(data_with_outliers)
    
    def test_filter_outliers_missing_column(self, processor, sample_data):
        """Test outlier filtering with missing column."""
        with pytest.raises(ValueError, match="Column 'missing' not found"):
            processor.filter_outliers(sample_data, 'missing')
EOF

echo "✅ Unit tests created"

echo ""
echo "🎯 Exercise 3: Integration Tests"
echo "==============================="

cat > tests/integration/test_api.py << 'EOF'
"""Integration tests for API endpoints."""

import pytest
import json
from src.api import create_app

class TestHealthEndpoint:
    """Test health check endpoint."""
    
    def test_health_check(self, client):
        """Test health endpoint returns correct response."""
        response = client.get('/health')
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['status'] == 'healthy'
        assert data['version'] == '1.0.0'

class TestProcessEndpoint:
    """Test data processing endpoint."""
    
    def test_process_valid_data(self, client):
        """Test processing valid data."""
        test_data = {
            'data': [
                {'name': 'Alice', 'age': 25, 'salary': 50000},
                {'name': 'Bob', 'age': 30, 'salary': 60000}
            ]
        }
        
        response = client.post(
            '/api/process',
            data=json.dumps(test_data),
            content_type='application/json'
        )
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['status'] == 'success'
        assert data['processed_rows'] == 2
        assert 'statistics' in data
        assert 'age' in data['statistics']
    
    def test_process_empty_data(self, client):
        """Test processing empty data."""
        test_data = {'data': []}
        
        response = client.post(
            '/api/process',
            data=json.dumps(test_data),
            content_type='application/json'
        )
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['processed_rows'] == 0
        assert data['statistics'] == {}
    
    def test_process_no_data(self, client):
        """Test processing request without data."""
        response = client.post(
            '/api/process',
            data=json.dumps({}),
            content_type='application/json'
        )
        
        assert response.status_code == 400
        data = response.get_json()
        assert 'error' in data
    
    def test_process_invalid_json(self, client):
        """Test processing invalid JSON."""
        response = client.post(
            '/api/process',
            data='invalid json',
            content_type='application/json'
        )
        
        assert response.status_code == 500

class TestValidateEndpoint:
    """Test data validation endpoint."""
    
    def test_validate_success(self, client):
        """Test successful validation."""
        test_data = {
            'data': [
                {'name': 'Alice', 'age': 25},
                {'name': 'Bob', 'age': 30}
            ],
            'required_columns': ['name', 'age']
        }
        
        response = client.post(
            '/api/validate',
            data=json.dumps(test_data),
            content_type='application/json'
        )
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['valid'] is True
        assert data['status'] == 'success'
        assert set(data['columns']) == {'name', 'age'}
    
    def test_validate_missing_columns(self, client):
        """Test validation with missing columns."""
        test_data = {
            'data': [
                {'name': 'Alice'},
                {'name': 'Bob'}
            ],
            'required_columns': ['name', 'age']
        }
        
        response = client.post(
            '/api/validate',
            data=json.dumps(test_data),
            content_type='application/json'
        )
        
        assert response.status_code == 400
        data = response.get_json()
        assert data['valid'] is False
        assert 'error' in data
EOF

echo "✅ Integration tests created"

echo ""
echo "🎯 Exercise 4: Performance Tests"
echo "==============================="

cat > tests/performance/test_benchmarks.py << 'EOF'
"""Performance tests and benchmarks."""

import pytest
import pandas as pd
import numpy as np
from src.data_processor import DataProcessor

class TestPerformance:
    """Performance benchmarks for data processing."""
    
    @pytest.fixture
    def large_dataset(self):
        """Generate large dataset for performance testing."""
        np.random.seed(42)
        return pd.DataFrame({
            'id': range(10000),
            'value': np.random.randn(10000),
            'category': np.random.choice(['A', 'B', 'C'], 10000),
            'score': np.random.uniform(0, 100, 10000)
        })
    
    def test_clean_data_performance(self, benchmark, large_dataset):
        """Benchmark data cleaning performance."""
        processor = DataProcessor()
        
        # Add some missing values
        large_dataset.loc[::100, 'value'] = np.nan
        
        result = benchmark(processor.clean_data, large_dataset)
        
        # Verify result correctness
        assert len(result) < len(large_dataset)  # Some rows removed
        assert not result.isnull().any().any()  # No missing values
    
    def test_statistics_performance(self, benchmark, large_dataset):
        """Benchmark statistics calculation performance."""
        processor = DataProcessor()
        
        result = benchmark(processor.calculate_statistics, large_dataset)
        
        # Verify result correctness
        assert 'value' in result
        assert 'score' in result
        assert result['value']['count'] == 10000
    
    @pytest.mark.parametrize("size", [1000, 5000, 10000])
    def test_scaling_performance(self, benchmark, size):
        """Test performance scaling with different data sizes."""
        processor = DataProcessor()
        
        # Generate data of specified size
        data = pd.DataFrame({
            'value': np.random.randn(size),
            'category': np.random.choice(['A', 'B'], size)
        })
        
        result = benchmark(processor.calculate_statistics, data)
        
        assert 'value' in result
        assert result['value']['count'] == size
EOF

echo "✅ Performance tests created"

echo ""
echo "🎯 Exercise 5: Test Configuration"
echo "================================"

# Create pytest configuration
cat > pytest.ini << 'EOF'
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    --strict-markers
    --strict-config
    --verbose
    --tb=short
    --cov=src
    --cov-report=term-missing
    --cov-report=html:htmlcov
    --cov-report=xml:coverage.xml
    --cov-fail-under=80

markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
    unit: marks tests as unit tests
    performance: marks tests as performance tests
EOF

# Create coverage configuration
cat > .coveragerc << 'EOF'
[run]
source = src/
omit = 
    */tests/*
    */venv/*
    setup.py

[report]
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:

[html]
directory = htmlcov
EOF

echo "✅ Test configuration created"

echo ""
echo "🎯 Exercise 6: Running Tests"
echo "============================"

echo "🐍 Setting up Python environment..."
python3 -m venv venv
source venv/bin/activate

echo "📦 Installing dependencies..."
pip install -r requirements.txt
pip install -r requirements-test.txt

echo "🧪 Running test suite..."

echo ""
echo "1️⃣ Running unit tests..."
pytest tests/unit/ -v --tb=short

echo ""
echo "2️⃣ Running integration tests..."
pytest tests/integration/ -v --tb=short

echo ""
echo "3️⃣ Running performance tests..."
pytest tests/performance/ -v --benchmark-only --tb=short

echo ""
echo "4️⃣ Running full test suite with coverage..."
pytest --cov=src --cov-report=term-missing --tb=short

echo ""
echo "5️⃣ Generating coverage report..."
pytest --cov=src --cov-report=html --tb=short
echo "📊 Coverage report generated in htmlcov/index.html"

deactivate

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully:"
echo "✅ Created comprehensive test suite with unit, integration, and performance tests"
echo "✅ Implemented pytest fixtures and parameterized tests"
echo "✅ Set up test configuration with coverage reporting"
echo "✅ Created API tests for Flask endpoints"
echo "✅ Implemented performance benchmarks"
echo "✅ Generated test coverage reports"
echo ""
echo "📁 Project location: $EXERCISE_DIR"
echo ""
echo "🔍 Key testing concepts practiced:"
echo "   Unit Tests - Testing individual functions in isolation"
echo "   Integration Tests - Testing component interactions"
echo "   Performance Tests - Benchmarking and scaling analysis"
echo "   Test Fixtures - Reusable test data and setup"
echo "   Parameterized Tests - Testing multiple scenarios efficiently"
echo "   Coverage Analysis - Measuring test completeness"
echo "   API Testing - Testing HTTP endpoints and responses"
echo ""
echo "💡 Next: Learn package management and dependency handling!"
