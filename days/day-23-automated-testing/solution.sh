#!/bin/bash

# Day 23: Automated Testing - Solution Guide
# Reference solutions for comprehensive testing strategies

echo "📚 Day 23: Automated Testing - Solution Guide"
echo "=============================================="

echo ""
echo "🎯 Solution 1: Unit Testing Best Practices"
echo "=========================================="

cat << 'EOF'
# Basic Unit Test Structure
import pytest
from mymodule import Calculator

class TestCalculator:
    """Test suite for Calculator class."""
    
    def test_add(self):
        """Test addition method."""
        calc = Calculator()
        assert calc.add(2, 3) == 5
        assert calc.add(-1, 1) == 0
    
    def test_divide_by_zero(self):
        """Test division by zero raises exception."""
        calc = Calculator()
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            calc.divide(5, 0)
    
    @pytest.mark.parametrize("a,b,expected", [
        (2, 3, 5),
        (-1, 1, 0),
        (0, 0, 0),
    ])
    def test_add_parametrized(self, a, b, expected):
        """Test addition with multiple parameters."""
        calc = Calculator()
        assert calc.add(a, b) == expected

# Test Fixtures
@pytest.fixture
def calculator():
    """Provide calculator instance for tests."""
    return Calculator()

@pytest.fixture
def sample_data():
    """Provide sample data for tests."""
    return pd.DataFrame({
        'name': ['Alice', 'Bob'],
        'age': [25, 30]
    })

def test_with_fixture(calculator, sample_data):
    """Test using fixtures."""
    result = calculator.process_data(sample_data)
    assert len(result) == 2
EOF

echo ""
echo "🎯 Solution 2: Data Science Testing"
echo "=================================="

cat << 'EOF'
# Testing Data Processing Functions
import pytest
import pandas as pd
import numpy as np

class TestDataProcessor:
    """Test data processing functions."""
    
    def test_clean_data_removes_duplicates(self):
        """Test duplicate removal."""
        data = pd.DataFrame({
            'A': [1, 2, 2, 3],
            'B': [1, 2, 2, 4]
        })
        
        cleaned = clean_data(data)
        assert len(cleaned) == 3
        assert not cleaned.duplicated().any()
    
    def test_handle_missing_values(self):
        """Test missing value handling."""
        data = pd.DataFrame({
            'A': [1, 2, np.nan, 4],
            'B': [1, np.nan, 3, 4]
        })
        
        # Test drop strategy
        cleaned = clean_data(data, strategy='drop')
        assert not cleaned.isnull().any().any()
        
        # Test fill strategy
        filled = clean_data(data, strategy='fill', fill_value=0)
        assert not filled.isnull().any().any()
    
    def test_data_validation(self):
        """Test data schema validation."""
        data = pd.DataFrame({'A': [1, 2], 'B': [3, 4]})
        
        # Should pass
        assert validate_schema(data, required_columns=['A', 'B'])
        
        # Should fail
        with pytest.raises(ValueError):
            validate_schema(data, required_columns=['A', 'B', 'C'])

# Testing ML Models
class TestMLModel:
    """Test machine learning model."""
    
    @pytest.fixture
    def model_data(self):
        """Generate test data for model."""
        from sklearn.datasets import make_classification
        X, y = make_classification(n_samples=100, n_features=4, random_state=42)
        return train_test_split(X, y, test_size=0.2, random_state=42)
    
    def test_model_training(self, model_data):
        """Test model can be trained."""
        X_train, X_test, y_train, y_test = model_data
        
        model = MyClassifier()
        model.fit(X_train, y_train)
        
        assert hasattr(model, 'is_fitted_')
        assert model.is_fitted_
    
    def test_model_prediction_shape(self, model_data):
        """Test prediction output shape."""
        X_train, X_test, y_train, y_test = model_data
        
        model = MyClassifier()
        model.fit(X_train, y_train)
        predictions = model.predict(X_test)
        
        assert len(predictions) == len(X_test)
        assert predictions.dtype in [np.int32, np.int64]
    
    def test_model_performance_threshold(self, model_data):
        """Test model meets performance threshold."""
        X_train, X_test, y_train, y_test = model_data
        
        model = MyClassifier()
        model.fit(X_train, y_train)
        accuracy = model.score(X_test, y_test)
        
        assert accuracy > 0.7, f"Model accuracy {accuracy} below threshold"
EOF

echo ""
echo "🎯 Solution 3: API Testing"
echo "========================="

cat << 'EOF'
# Flask API Testing
import pytest
import json
from myapp import create_app

@pytest.fixture
def app():
    """Create test application."""
    app = create_app(testing=True)
    return app

@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()

class TestAPI:
    """Test API endpoints."""
    
    def test_health_endpoint(self, client):
        """Test health check endpoint."""
        response = client.get('/health')
        
        assert response.status_code == 200
        data = response.get_json()
        assert data['status'] == 'healthy'
    
    def test_post_data_valid(self, client):
        """Test posting valid data."""
        data = {
            'name': 'Test User',
            'age': 25,
            'email': 'test@example.com'
        }
        
        response = client.post(
            '/api/users',
            data=json.dumps(data),
            content_type='application/json'
        )
        
        assert response.status_code == 201
        result = response.get_json()
        assert 'id' in result
    
    def test_post_data_invalid(self, client):
        """Test posting invalid data."""
        data = {'name': ''}  # Invalid empty name
        
        response = client.post(
            '/api/users',
            data=json.dumps(data),
            content_type='application/json'
        )
        
        assert response.status_code == 400
        result = response.get_json()
        assert 'error' in result
    
    def test_authentication_required(self, client):
        """Test endpoints require authentication."""
        response = client.get('/api/protected')
        assert response.status_code in [401, 403]

# Database Testing
@pytest.fixture
def db_session():
    """Create test database session."""
    engine = create_engine('sqlite:///:memory:')
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    
    yield session
    
    session.close()

def test_user_creation(db_session):
    """Test user model creation."""
    user = User(name='Test', email='test@example.com')
    db_session.add(user)
    db_session.commit()
    
    assert user.id is not None
    assert user.name == 'Test'
EOF

echo ""
echo "🎯 Solution 4: Performance Testing"
echo "================================="

cat << 'EOF'
# Performance Testing with pytest-benchmark
import pytest
import pandas as pd
import numpy as np

class TestPerformance:
    """Performance tests and benchmarks."""
    
    @pytest.fixture
    def large_dataset(self):
        """Generate large dataset."""
        return pd.DataFrame({
            'id': range(100000),
            'value': np.random.randn(100000)
        })
    
    def test_processing_performance(self, benchmark, large_dataset):
        """Benchmark data processing function."""
        result = benchmark(process_data, large_dataset)
        
        # Verify correctness
        assert len(result) <= len(large_dataset)
        assert 'processed' in result.columns
    
    @pytest.mark.parametrize("size", [1000, 10000, 100000])
    def test_scaling_performance(self, benchmark, size):
        """Test performance scaling."""
        data = pd.DataFrame({'value': np.random.randn(size)})
        
        result = benchmark(process_data, data)
        assert len(result) == size
    
    def test_memory_usage(self):
        """Test memory usage stays within limits."""
        import psutil
        import os
        
        process = psutil.Process(os.getpid())
        initial_memory = process.memory_info().rss
        
        # Run memory-intensive function
        result = memory_intensive_function(size=10000)
        
        final_memory = process.memory_info().rss
        memory_used = final_memory - initial_memory
        
        # Assert reasonable memory usage (< 100MB)
        assert memory_used < 100 * 1024 * 1024
        assert result is not None

# Load Testing
def test_concurrent_requests():
    """Test API under concurrent load."""
    import concurrent.futures
    import requests
    
    def make_request():
        response = requests.get('http://localhost:5000/api/data')
        return response.status_code
    
    # Test with 10 concurrent requests
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(make_request) for _ in range(10)]
        results = [future.result() for future in futures]
    
    # All requests should succeed
    assert all(status == 200 for status in results)
EOF

echo ""
echo "🎯 Solution 5: Mocking and Patching"
echo "==================================="

cat << 'EOF'
# Mocking External Dependencies
import pytest
from unittest.mock import patch, Mock
import requests

class TestExternalServices:
    """Test external service interactions."""
    
    @patch('requests.get')
    def test_api_call_success(self, mock_get):
        """Test successful API call."""
        # Mock successful response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'data': 'test'}
        mock_get.return_value = mock_response
        
        result = fetch_external_data('http://api.example.com')
        
        assert result == {'data': 'test'}
        mock_get.assert_called_once_with('http://api.example.com')
    
    @patch('requests.get')
    def test_api_call_failure(self, mock_get):
        """Test API call failure handling."""
        mock_get.side_effect = requests.RequestException("Connection error")
        
        with pytest.raises(requests.RequestException):
            fetch_external_data('http://api.example.com')
    
    @patch('mymodule.expensive_function')
    def test_with_expensive_function_mocked(self, mock_expensive):
        """Test with expensive function mocked."""
        mock_expensive.return_value = 'mocked_result'
        
        result = function_that_calls_expensive()
        
        assert result == 'processed_mocked_result'
        mock_expensive.assert_called_once()

# Database Mocking
@patch('mymodule.get_database_connection')
def test_database_operation(mock_db):
    """Test database operation with mocked connection."""
    mock_conn = Mock()
    mock_cursor = Mock()
    mock_cursor.fetchall.return_value = [('Alice', 25), ('Bob', 30)]
    mock_conn.cursor.return_value = mock_cursor
    mock_db.return_value = mock_conn
    
    result = get_users()
    
    assert len(result) == 2
    assert result[0]['name'] == 'Alice'
    mock_cursor.execute.assert_called_once()

# Environment Variable Mocking
@patch.dict('os.environ', {'API_KEY': 'test_key'})
def test_with_env_var():
    """Test function that uses environment variable."""
    result = function_using_api_key()
    assert 'test_key' in result
EOF

echo ""
echo "🎯 Solution 6: Test Configuration"
echo "================================="

cat << 'EOF'
# pytest.ini
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
    external: marks tests that require external services

# .coveragerc
[run]
source = src/
omit = 
    */tests/*
    */venv/*
    */migrations/*
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

# conftest.py (shared fixtures)
import pytest
import pandas as pd
from myapp import create_app, db

@pytest.fixture(scope="session")
def app():
    """Create application for testing."""
    app = create_app(testing=True)
    return app

@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()

@pytest.fixture
def sample_data():
    """Provide sample data for tests."""
    return pd.DataFrame({
        'name': ['Alice', 'Bob', 'Carol'],
        'age': [25, 30, 35]
    })

@pytest.fixture(autouse=True)
def setup_database():
    """Setup and teardown database for each test."""
    db.create_all()
    yield
    db.drop_all()
EOF

echo ""
echo "🎯 Solution 7: CI/CD Integration"
echo "==============================="

cat << 'EOF'
# GitHub Actions Workflow
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-test.txt
      
      - name: Run unit tests
        run: pytest tests/unit/ -v --cov=src
      
      - name: Run integration tests
        run: pytest tests/integration/ -v
      
      - name: Run performance tests
        run: pytest tests/performance/ --benchmark-only
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml

# Makefile for local testing
.PHONY: test test-unit test-integration test-performance coverage

test:
	pytest

test-unit:
	pytest tests/unit/ -v

test-integration:
	pytest tests/integration/ -v

test-performance:
	pytest tests/performance/ --benchmark-only

coverage:
	pytest --cov=src --cov-report=html --cov-report=term-missing

test-watch:
	pytest-watch -- --cov=src
EOF

echo ""
echo "🎯 Solution 8: Advanced Testing Patterns"
echo "========================================"

cat << 'EOF'
# Property-Based Testing with Hypothesis
from hypothesis import given, strategies as st
import pytest

@given(st.integers(), st.integers())
def test_add_commutative(a, b):
    """Test addition is commutative."""
    assert add(a, b) == add(b, a)

@given(st.lists(st.floats(allow_nan=False, allow_infinity=False)))
def test_sort_idempotent(lst):
    """Test sorting is idempotent."""
    sorted_once = sorted(lst)
    sorted_twice = sorted(sorted_once)
    assert sorted_once == sorted_twice

# Snapshot Testing
def test_api_response_format(client, snapshot):
    """Test API response format doesn't change."""
    response = client.get('/api/users')
    snapshot.assert_match(response.get_json())

# Contract Testing
def test_api_contract():
    """Test API follows OpenAPI specification."""
    from openapi_spec_validator import validate_spec
    
    spec = load_openapi_spec('api_spec.yaml')
    validate_spec(spec)  # Raises exception if invalid

# Mutation Testing
# Use mutmut to test test quality
# mutmut run --paths-to-mutate src/

# Test Doubles (Stubs, Mocks, Fakes)
class FakeDatabase:
    """Fake database for testing."""
    
    def __init__(self):
        self.data = {}
    
    def save(self, key, value):
        self.data[key] = value
    
    def get(self, key):
        return self.data.get(key)

@pytest.fixture
def fake_db():
    """Provide fake database."""
    return FakeDatabase()

def test_with_fake_database(fake_db):
    """Test using fake database."""
    service = UserService(fake_db)
    user = service.create_user('Alice', 'alice@example.com')
    
    retrieved = service.get_user(user.id)
    assert retrieved.name == 'Alice'
EOF

echo ""
echo "🎯 Solution 9: Test Organization"
echo "==============================="

cat << 'EOF'
# Test Directory Structure
tests/
├── conftest.py              # Shared fixtures
├── unit/                    # Unit tests
│   ├── test_models.py
│   ├── test_utils.py
│   └── test_validators.py
├── integration/             # Integration tests
│   ├── test_api.py
│   ├── test_database.py
│   └── test_workflows.py
├── performance/             # Performance tests
│   ├── test_benchmarks.py
│   └── test_load.py
├── e2e/                    # End-to-end tests
│   ├── test_user_flows.py
│   └── test_scenarios.py
└── data/                   # Test data
    ├── sample.json
    ├── test_data.csv
    └── fixtures/

# Test Naming Conventions
class TestUserModel:
    """Test User model functionality."""
    
    def test_create_user_with_valid_data(self):
        """Test user creation with valid input."""
        pass
    
    def test_create_user_with_invalid_email_raises_error(self):
        """Test user creation fails with invalid email."""
        pass
    
    def test_user_full_name_property_returns_formatted_name(self):
        """Test full_name property formatting."""
        pass

# Test Categories with Markers
@pytest.mark.unit
def test_pure_function():
    """Unit test for pure function."""
    pass

@pytest.mark.integration
def test_database_integration():
    """Integration test with database."""
    pass

@pytest.mark.slow
def test_expensive_operation():
    """Slow test that processes large data."""
    pass

@pytest.mark.external
def test_api_call():
    """Test that calls external API."""
    pass

# Running specific test categories
# pytest -m unit                    # Run only unit tests
# pytest -m "not slow"              # Skip slow tests
# pytest -m "integration or e2e"    # Run integration or e2e tests
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key automated testing concepts mastered:"
echo "✅ Unit testing with pytest fixtures and parameterization"
echo "✅ Integration testing for APIs and databases"
echo "✅ Performance testing and benchmarking"
echo "✅ Mocking and patching external dependencies"
echo "✅ Test coverage analysis and reporting"
echo "✅ CI/CD integration with automated testing"
echo "✅ Advanced testing patterns and best practices"
echo "✅ Test organization and maintenance strategies"
echo ""
echo "💡 Remember:"
echo "   - Follow the testing pyramid: many unit tests, some integration tests, few E2E tests"
echo "   - Use fixtures for reusable test setup and data"
echo "   - Mock external dependencies to isolate tests"
echo "   - Aim for high test coverage but focus on quality over quantity"
echo "   - Integrate testing into CI/CD pipelines for continuous feedback"
echo "   - Organize tests clearly and use descriptive naming"
echo "   - Test both happy paths and error conditions"
