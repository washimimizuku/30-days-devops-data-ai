# Day 23: Automated Testing Strategies

**Duration**: 1 hour  
**Prerequisites**: Day 22 (CI/CD with GitHub Actions)

## Learning Objectives

By the end of this lesson, you will:
- Understand different types of automated testing
- Implement unit, integration, and end-to-end tests
- Use pytest for comprehensive Python testing
- Create test fixtures and parameterized tests
- Implement test coverage and quality metrics
- Set up automated testing in CI/CD pipelines
- Apply testing best practices for data and AI projects

## Testing Fundamentals

### Testing Pyramid

```
    /\
   /  \     E2E Tests (Few)
  /____\    
 /      \   Integration Tests (Some)
/__________\ Unit Tests (Many)
```

**Unit Tests**: Test individual functions/methods in isolation
**Integration Tests**: Test component interactions
**End-to-End Tests**: Test complete user workflows

### Benefits of Automated Testing

- **Quality Assurance**: Catch bugs before production
- **Regression Prevention**: Ensure changes don't break existing functionality
- **Documentation**: Tests serve as living documentation
- **Confidence**: Safe refactoring and feature development
- **Faster Development**: Quick feedback on code changes

## Python Testing with pytest

### Basic Test Structure

```python
# test_calculator.py
import pytest
from calculator import add, divide

def test_add():
    """Test addition function."""
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0

def test_divide():
    """Test division function."""
    assert divide(10, 2) == 5
    assert divide(7, 2) == 3.5

def test_divide_by_zero():
    """Test division by zero raises exception."""
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(5, 0)
```

### Test Fixtures

```python
# conftest.py
import pytest
import pandas as pd
from sqlalchemy import create_engine

@pytest.fixture
def sample_data():
    """Provide sample data for tests."""
    return pd.DataFrame({
        'name': ['Alice', 'Bob', 'Carol'],
        'age': [25, 30, 35],
        'salary': [50000, 60000, 70000]
    })

@pytest.fixture
def database_connection():
    """Provide test database connection."""
    engine = create_engine('sqlite:///:memory:')
    yield engine
    engine.dispose()

@pytest.fixture(scope="session")
def api_client():
    """Provide API client for testing."""
    from flask import Flask
    from myapp import create_app
    
    app = create_app(testing=True)
    with app.test_client() as client:
        yield client
```

### Parameterized Tests

```python
import pytest

@pytest.mark.parametrize("a,b,expected", [
    (2, 3, 5),
    (-1, 1, 0),
    (0, 0, 0),
    (10, -5, 5),
])
def test_add_parametrized(a, b, expected):
    """Test addition with multiple parameter sets."""
    assert add(a, b) == expected

@pytest.mark.parametrize("input_data,expected_length", [
    ([1, 2, 3], 3),
    ([], 0),
    ([1], 1),
    (range(100), 100),
])
def test_data_processing(input_data, expected_length):
    """Test data processing with various inputs."""
    result = process_data(list(input_data))
    assert len(result) == expected_length
```

## Data Science Testing Patterns

### Testing Data Processing Functions

```python
# test_data_processing.py
import pytest
import pandas as pd
import numpy as np
from data_processor import clean_data, validate_schema, transform_features

class TestDataCleaning:
    """Test suite for data cleaning functions."""
    
    def test_remove_duplicates(self, sample_data):
        """Test duplicate removal."""
        # Add duplicate row
        data_with_duplicates = pd.concat([sample_data, sample_data.iloc[[0]]])
        
        cleaned = clean_data(data_with_duplicates)
        
        assert len(cleaned) == len(sample_data)
        assert not cleaned.duplicated().any()
    
    def test_handle_missing_values(self):
        """Test missing value handling."""
        data = pd.DataFrame({
            'A': [1, 2, np.nan, 4],
            'B': [1, np.nan, 3, 4]
        })
        
        cleaned = clean_data(data, strategy='drop')
        assert not cleaned.isnull().any().any()
        
        cleaned = clean_data(data, strategy='fill', fill_value=0)
        assert (cleaned.fillna(0) == cleaned).all().all()
    
    def test_outlier_detection(self):
        """Test outlier detection and removal."""
        data = pd.DataFrame({
            'values': [1, 2, 3, 4, 5, 100]  # 100 is outlier
        })
        
        cleaned = clean_data(data, remove_outliers=True)
        assert 100 not in cleaned['values'].values

class TestSchemaValidation:
    """Test suite for schema validation."""
    
    def test_required_columns(self):
        """Test required column validation."""
        data = pd.DataFrame({'A': [1, 2], 'B': [3, 4]})
        
        # Should pass
        assert validate_schema(data, required_columns=['A', 'B'])
        
        # Should fail
        with pytest.raises(ValueError, match="Missing required columns"):
            validate_schema(data, required_columns=['A', 'B', 'C'])
    
    def test_data_types(self):
        """Test data type validation."""
        data = pd.DataFrame({
            'int_col': [1, 2, 3],
            'float_col': [1.1, 2.2, 3.3],
            'str_col': ['a', 'b', 'c']
        })
        
        schema = {
            'int_col': 'int64',
            'float_col': 'float64',
            'str_col': 'object'
        }
        
        assert validate_schema(data, data_types=schema)
```

### Testing Machine Learning Models

```python
# test_ml_models.py
import pytest
import numpy as np
from sklearn.datasets import make_classification, make_regression
from sklearn.model_selection import train_test_split
from ml_models import ClassificationModel, RegressionModel

class TestClassificationModel:
    """Test suite for classification models."""
    
    @pytest.fixture
    def classification_data(self):
        """Generate classification dataset."""
        X, y = make_classification(
            n_samples=1000, 
            n_features=20, 
            n_classes=2, 
            random_state=42
        )
        return train_test_split(X, y, test_size=0.2, random_state=42)
    
    def test_model_training(self, classification_data):
        """Test model training process."""
        X_train, X_test, y_train, y_test = classification_data
        
        model = ClassificationModel()
        model.fit(X_train, y_train)
        
        # Check model is trained
        assert hasattr(model, 'is_fitted_')
        assert model.is_fitted_
    
    def test_model_prediction(self, classification_data):
        """Test model prediction."""
        X_train, X_test, y_train, y_test = classification_data
        
        model = ClassificationModel()
        model.fit(X_train, y_train)
        
        predictions = model.predict(X_test)
        
        # Check prediction shape and type
        assert len(predictions) == len(X_test)
        assert predictions.dtype in [np.int32, np.int64]
        assert set(predictions).issubset({0, 1})
    
    def test_model_performance(self, classification_data):
        """Test model performance meets threshold."""
        X_train, X_test, y_train, y_test = classification_data
        
        model = ClassificationModel()
        model.fit(X_train, y_train)
        
        accuracy = model.score(X_test, y_test)
        
        # Performance threshold
        assert accuracy > 0.8, f"Model accuracy {accuracy} below threshold"
    
    def test_model_serialization(self, classification_data, tmp_path):
        """Test model saving and loading."""
        X_train, X_test, y_train, y_test = classification_data
        
        model = ClassificationModel()
        model.fit(X_train, y_train)
        
        # Save model
        model_path = tmp_path / "model.pkl"
        model.save(model_path)
        
        # Load model
        loaded_model = ClassificationModel.load(model_path)
        
        # Compare predictions
        original_pred = model.predict(X_test)
        loaded_pred = loaded_model.predict(X_test)
        
        np.testing.assert_array_equal(original_pred, loaded_pred)
```

## API Testing

### Testing Flask APIs

```python
# test_api.py
import pytest
import json
from api import create_app

@pytest.fixture
def app():
    """Create test application."""
    app = create_app(testing=True)
    return app

@pytest.fixture
def client(app):
    """Create test client."""
    return app.test_client()

class TestHealthEndpoint:
    """Test health check endpoint."""
    
    def test_health_check(self, client):
        """Test health endpoint returns 200."""
        response = client.get('/health')
        
        assert response.status_code == 200
        assert response.json['status'] == 'healthy'

class TestDataEndpoints:
    """Test data-related endpoints."""
    
    def test_get_data_empty(self, client):
        """Test getting data when database is empty."""
        response = client.get('/api/data')
        
        assert response.status_code == 200
        assert response.json['data'] == []
        assert response.json['count'] == 0
    
    def test_post_data_valid(self, client):
        """Test posting valid data."""
        data = {
            'name': 'Test User',
            'age': 25,
            'email': 'test@example.com'
        }
        
        response = client.post(
            '/api/data',
            data=json.dumps(data),
            content_type='application/json'
        )
        
        assert response.status_code == 201
        assert 'id' in response.json
        assert response.json['message'] == 'Data created successfully'
    
    def test_post_data_invalid(self, client):
        """Test posting invalid data."""
        data = {
            'name': '',  # Invalid: empty name
            'age': -5,   # Invalid: negative age
        }
        
        response = client.post(
            '/api/data',
            data=json.dumps(data),
            content_type='application/json'
        )
        
        assert response.status_code == 400
        assert 'error' in response.json
    
    @pytest.mark.parametrize("endpoint", [
        '/api/data',
        '/api/analytics',
        '/api/models'
    ])
    def test_endpoints_require_auth(self, client, endpoint):
        """Test endpoints require authentication."""
        response = client.get(endpoint)
        
        # Assuming authentication is required
        assert response.status_code in [401, 403]
```

### Testing with Database

```python
# test_database.py
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from database import Base, User, create_tables
from api import create_app

@pytest.fixture(scope="session")
def test_engine():
    """Create test database engine."""
    engine = create_engine('sqlite:///:memory:', echo=False)
    create_tables(engine)
    return engine

@pytest.fixture
def db_session(test_engine):
    """Create database session for testing."""
    Session = sessionmaker(bind=test_engine)
    session = Session()
    
    yield session
    
    session.rollback()
    session.close()

@pytest.fixture
def app_with_db(test_engine):
    """Create app with test database."""
    app = create_app(testing=True)
    app.config['DATABASE_URL'] = str(test_engine.url)
    return app

class TestUserModel:
    """Test User model operations."""
    
    def test_create_user(self, db_session):
        """Test user creation."""
        user = User(
            name='Test User',
            email='test@example.com',
            age=25
        )
        
        db_session.add(user)
        db_session.commit()
        
        assert user.id is not None
        assert user.name == 'Test User'
    
    def test_user_validation(self, db_session):
        """Test user validation rules."""
        # Test invalid email
        with pytest.raises(ValueError):
            user = User(name='Test', email='invalid-email', age=25)
            db_session.add(user)
            db_session.commit()
        
        # Test negative age
        with pytest.raises(ValueError):
            user = User(name='Test', email='test@example.com', age=-5)
            db_session.add(user)
            db_session.commit()
```

## Performance Testing

### Load Testing with pytest-benchmark

```python
# test_performance.py
import pytest
import pandas as pd
import numpy as np
from data_processor import process_large_dataset

class TestPerformance:
    """Performance tests for data processing."""
    
    @pytest.fixture
    def large_dataset(self):
        """Generate large dataset for performance testing."""
        return pd.DataFrame({
            'id': range(100000),
            'value': np.random.randn(100000),
            'category': np.random.choice(['A', 'B', 'C'], 100000)
        })
    
    def test_processing_performance(self, benchmark, large_dataset):
        """Test data processing performance."""
        result = benchmark(process_large_dataset, large_dataset)
        
        # Verify result correctness
        assert len(result) <= len(large_dataset)
        assert 'processed' in result.columns
    
    @pytest.mark.parametrize("size", [1000, 10000, 100000])
    def test_scaling_performance(self, benchmark, size):
        """Test performance scaling with data size."""
        data = pd.DataFrame({
            'value': np.random.randn(size)
        })
        
        result = benchmark(process_large_dataset, data)
        assert len(result) == size
```

### Memory Usage Testing

```python
# test_memory.py
import pytest
import psutil
import os
from memory_profiler import profile
from data_processor import memory_intensive_function

class TestMemoryUsage:
    """Test memory usage of functions."""
    
    def test_memory_limit(self):
        """Test function doesn't exceed memory limit."""
        process = psutil.Process(os.getpid())
        initial_memory = process.memory_info().rss
        
        # Run memory-intensive function
        result = memory_intensive_function(size=10000)
        
        final_memory = process.memory_info().rss
        memory_used = final_memory - initial_memory
        
        # Assert memory usage is reasonable (< 100MB)
        assert memory_used < 100 * 1024 * 1024
        assert result is not None
    
    @profile
    def test_memory_profile(self):
        """Profile memory usage line by line."""
        # This will generate memory usage report
        result = memory_intensive_function(size=50000)
        assert result is not None
```

## Test Coverage and Quality

### Coverage Configuration

```ini
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

[html]
directory = htmlcov
```

### Quality Metrics

```python
# test_quality.py
import pytest
import ast
import os
from radon.complexity import cc_visit
from radon.metrics import mi_visit

class TestCodeQuality:
    """Test code quality metrics."""
    
    def test_cyclomatic_complexity(self):
        """Test cyclomatic complexity is reasonable."""
        source_dir = 'src/'
        
        for root, dirs, files in os.walk(source_dir):
            for file in files:
                if file.endswith('.py'):
                    filepath = os.path.join(root, file)
                    
                    with open(filepath, 'r') as f:
                        code = f.read()
                    
                    tree = ast.parse(code)
                    complexity = cc_visit(tree)
                    
                    for item in complexity:
                        # Complexity should be reasonable
                        assert item.complexity <= 10, f"High complexity in {filepath}: {item.name}"
    
    def test_maintainability_index(self):
        """Test maintainability index is acceptable."""
        source_dir = 'src/'
        
        for root, dirs, files in os.walk(source_dir):
            for file in files:
                if file.endswith('.py'):
                    filepath = os.path.join(root, file)
                    
                    with open(filepath, 'r') as f:
                        code = f.read()
                    
                    tree = ast.parse(code)
                    mi = mi_visit(tree, True)
                    
                    # Maintainability index should be > 20
                    assert mi > 20, f"Low maintainability in {filepath}: {mi}"
```

## CI/CD Integration

### pytest Configuration

```ini
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
    --cov=src
    --cov-report=term-missing
    --cov-report=html
    --cov-report=xml
    --cov-fail-under=80

markers =
    slow: marks tests as slow
    integration: marks tests as integration tests
    unit: marks tests as unit tests
    performance: marks tests as performance tests
```

### GitHub Actions Integration

```yaml
# .github/workflows/test.yml
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
        run: pytest tests/unit/ -v --cov=src --cov-report=xml
      
      - name: Run integration tests
        run: pytest tests/integration/ -v
      
      - name: Run performance tests
        run: pytest tests/performance/ -v --benchmark-only
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          flags: unittests
          name: codecov-umbrella
```

## Testing Best Practices

### Test Organization

```
tests/
├── conftest.py           # Shared fixtures
├── unit/                 # Unit tests
│   ├── test_models.py
│   ├── test_utils.py
│   └── test_validators.py
├── integration/          # Integration tests
│   ├── test_api.py
│   ├── test_database.py
│   └── test_workflows.py
├── performance/          # Performance tests
│   ├── test_benchmarks.py
│   └── test_memory.py
└── e2e/                 # End-to-end tests
    ├── test_user_flows.py
    └── test_scenarios.py
```

### Test Data Management

```python
# conftest.py
import pytest
import json
import pandas as pd
from pathlib import Path

@pytest.fixture
def test_data_dir():
    """Get test data directory."""
    return Path(__file__).parent / 'data'

@pytest.fixture
def sample_json_data(test_data_dir):
    """Load sample JSON data."""
    with open(test_data_dir / 'sample.json') as f:
        return json.load(f)

@pytest.fixture
def sample_csv_data(test_data_dir):
    """Load sample CSV data."""
    return pd.read_csv(test_data_dir / 'sample.csv')

@pytest.fixture
def mock_api_response():
    """Mock API response data."""
    return {
        'status': 'success',
        'data': [
            {'id': 1, 'name': 'Test Item 1'},
            {'id': 2, 'name': 'Test Item 2'}
        ]
    }
```

### Mocking and Patching

```python
# test_external_services.py
import pytest
from unittest.mock import patch, Mock
import requests
from external_service import fetch_data, process_api_response

class TestExternalServices:
    """Test external service interactions."""
    
    @patch('requests.get')
    def test_fetch_data_success(self, mock_get):
        """Test successful data fetching."""
        # Mock successful response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {'data': 'test'}
        mock_get.return_value = mock_response
        
        result = fetch_data('http://api.example.com/data')
        
        assert result == {'data': 'test'}
        mock_get.assert_called_once_with('http://api.example.com/data')
    
    @patch('requests.get')
    def test_fetch_data_failure(self, mock_get):
        """Test handling of API failures."""
        # Mock failed response
        mock_get.side_effect = requests.RequestException("Connection error")
        
        with pytest.raises(requests.RequestException):
            fetch_data('http://api.example.com/data')
    
    @patch('external_service.fetch_data')
    def test_process_api_response(self, mock_fetch):
        """Test API response processing."""
        # Mock the fetch_data function
        mock_fetch.return_value = {
            'items': [
                {'id': 1, 'value': 10},
                {'id': 2, 'value': 20}
            ]
        }
        
        result = process_api_response()
        
        assert len(result) == 2
        assert sum(item['value'] for item in result) == 30
```

## Next Steps

Tomorrow (Day 24) we'll learn package management and dependency handling, building on these testing foundations to create maintainable, well-tested applications.

## Key Takeaways

- Automated testing provides quality assurance and regression prevention
- The testing pyramid guides test distribution: many unit tests, some integration tests, few E2E tests
- pytest provides powerful fixtures, parameterization, and assertion capabilities
- Data science testing requires special attention to data validation and model performance
- API testing ensures endpoints work correctly under various conditions
- Performance testing catches scalability issues early
- Test coverage and quality metrics guide testing effectiveness
- CI/CD integration automates testing and provides continuous feedback
- Proper test organization and data management improve maintainability
- Mocking enables testing of external dependencies and error conditions
