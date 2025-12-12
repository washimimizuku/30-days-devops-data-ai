#!/bin/bash

# Day 24: Package Management - pip, poetry, uv
# Hands-on exercises for mastering Python package management

set -e

echo "🐍 Day 24: Package Management Exercises"
echo "========================================"

# Exercise 1: pip Fundamentals
echo -e "\n📦 Exercise 1: pip Fundamentals"
echo "Creating requirements.txt and installing packages..."

mkdir -p exercise1-pip
cd exercise1-pip

# Create requirements.txt
cat > requirements.txt << 'EOF'
pandas==2.1.0
numpy>=1.24.0,<2.0.0
requests~=2.31.0
matplotlib>=3.7.0
EOF

# Create dev requirements
cat > requirements-dev.txt << 'EOF'
pytest>=7.0.0
black>=23.0.0
flake8>=6.0.0
mypy>=1.0.0
jupyter>=1.0.0
EOF

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install packages
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Create simple data script
cat > data_analysis.py << 'EOF'
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

def analyze_data():
    # Generate sample data
    data = {
        'x': np.random.randn(100),
        'y': np.random.randn(100)
    }
    df = pd.DataFrame(data)
    
    # Basic analysis
    print(f"Data shape: {df.shape}")
    print(f"Mean x: {df['x'].mean():.2f}")
    print(f"Mean y: {df['y'].mean():.2f}")
    
    return df

if __name__ == "__main__":
    df = analyze_data()
    print("✅ Data analysis complete!")
EOF

# Test the script
python data_analysis.py

# Generate lock file
pip freeze > requirements.lock

deactivate
cd ..

echo "✅ Exercise 1 complete: pip basics with virtual environment"

# Exercise 2: Poetry Project Setup
echo -e "\n🎭 Exercise 2: Poetry Project Setup"
echo "Creating a new Poetry project..."

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo "Installing Poetry..."
    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="$HOME/.local/bin:$PATH"
fi

# Create new poetry project
poetry new data-pipeline
cd data-pipeline

# Add dependencies
poetry add pandas numpy scikit-learn requests
poetry add --group dev pytest black mypy jupyter

# Create main module
cat > data_pipeline/processor.py << 'EOF'
"""Data processing module."""
import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler

def process_data(data: pd.DataFrame) -> pd.DataFrame:
    """Process and normalize data."""
    scaler = StandardScaler()
    numeric_cols = data.select_dtypes(include=[np.number]).columns
    
    data_processed = data.copy()
    data_processed[numeric_cols] = scaler.fit_transform(data[numeric_cols])
    
    return data_processed

def generate_sample_data(n_samples: int = 100) -> pd.DataFrame:
    """Generate sample dataset."""
    np.random.seed(42)
    return pd.DataFrame({
        'feature1': np.random.randn(n_samples),
        'feature2': np.random.randn(n_samples),
        'target': np.random.randint(0, 2, n_samples)
    })
EOF

# Create CLI script
cat > data_pipeline/cli.py << 'EOF'
"""Command line interface for data pipeline."""
import click
from .processor import generate_sample_data, process_data

@click.command()
@click.option('--samples', default=100, help='Number of samples to generate')
def main(samples):
    """Run data processing pipeline."""
    click.echo(f"Generating {samples} samples...")
    data = generate_sample_data(samples)
    
    click.echo("Processing data...")
    processed = process_data(data)
    
    click.echo(f"Original shape: {data.shape}")
    click.echo(f"Processed shape: {processed.shape}")
    click.echo("✅ Pipeline complete!")

if __name__ == '__main__':
    main()
EOF

# Add click dependency
poetry add click

# Create test
mkdir -p tests
cat > tests/test_processor.py << 'EOF'
"""Tests for data processor."""
import pytest
import pandas as pd
from data_pipeline.processor import process_data, generate_sample_data

def test_generate_sample_data():
    """Test sample data generation."""
    data = generate_sample_data(50)
    assert data.shape == (50, 3)
    assert list(data.columns) == ['feature1', 'feature2', 'target']

def test_process_data():
    """Test data processing."""
    data = generate_sample_data(100)
    processed = process_data(data)
    
    # Check normalization
    assert abs(processed['feature1'].mean()) < 0.1
    assert abs(processed['feature2'].mean()) < 0.1
EOF

# Run tests
poetry run pytest

# Run the CLI
poetry run python -m data_pipeline.cli --samples 50

cd ..

echo "✅ Exercise 2 complete: Poetry project with dependencies and tests"

# Exercise 3: uv Ultra-Fast Package Manager
echo -e "\n⚡ Exercise 3: uv Ultra-Fast Package Manager"
echo "Setting up project with uv..."

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Create new uv project
uv init ml-project
cd ml-project

# Add dependencies
uv add pandas numpy scikit-learn matplotlib seaborn
uv add --dev pytest black mypy jupyter

# Create ML script
cat > src/ml_project/model.py << 'EOF'
"""Machine learning model module."""
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
import matplotlib.pyplot as plt
import seaborn as sns

class MLPipeline:
    """Simple ML pipeline."""
    
    def __init__(self):
        self.model = RandomForestClassifier(n_estimators=100, random_state=42)
        self.is_trained = False
    
    def prepare_data(self, n_samples=1000):
        """Generate and prepare sample data."""
        np.random.seed(42)
        
        # Generate features
        X = np.random.randn(n_samples, 4)
        # Create target with some pattern
        y = (X[:, 0] + X[:, 1] > 0).astype(int)
        
        return train_test_split(X, y, test_size=0.2, random_state=42)
    
    def train(self, X_train, y_train):
        """Train the model."""
        self.model.fit(X_train, y_train)
        self.is_trained = True
        return self
    
    def evaluate(self, X_test, y_test):
        """Evaluate model performance."""
        if not self.is_trained:
            raise ValueError("Model must be trained first")
        
        predictions = self.model.predict(X_test)
        accuracy = accuracy_score(y_test, predictions)
        
        print(f"Accuracy: {accuracy:.3f}")
        print("\nClassification Report:")
        print(classification_report(y_test, predictions))
        
        return accuracy

def main():
    """Run ML pipeline."""
    pipeline = MLPipeline()
    
    print("Preparing data...")
    X_train, X_test, y_train, y_test = pipeline.prepare_data()
    
    print("Training model...")
    pipeline.train(X_train, y_train)
    
    print("Evaluating model...")
    accuracy = pipeline.evaluate(X_test, y_test)
    
    return accuracy

if __name__ == "__main__":
    main()
EOF

# Create test
mkdir -p tests
cat > tests/test_model.py << 'EOF'
"""Tests for ML model."""
import pytest
import numpy as np
from src.ml_project.model import MLPipeline

def test_ml_pipeline():
    """Test ML pipeline."""
    pipeline = MLPipeline()
    
    # Test data preparation
    X_train, X_test, y_train, y_test = pipeline.prepare_data(100)
    assert X_train.shape[0] == 80
    assert X_test.shape[0] == 20
    
    # Test training
    pipeline.train(X_train, y_train)
    assert pipeline.is_trained
    
    # Test evaluation
    accuracy = pipeline.evaluate(X_test, y_test)
    assert 0 <= accuracy <= 1
EOF

# Run with uv
uv run python src/ml_project/model.py
uv run pytest

cd ..

echo "✅ Exercise 3 complete: uv project with ML pipeline"

# Exercise 4: Dependency Security and Auditing
echo -e "\n🔒 Exercise 4: Dependency Security and Auditing"
echo "Checking for security vulnerabilities..."

cd exercise1-pip
source venv/bin/activate

# Install security tools
pip install pip-audit safety

# Run security audit
echo "Running pip-audit..."
pip-audit || echo "Some vulnerabilities found (expected for demo)"

echo "Running safety check..."
safety check || echo "Some vulnerabilities found (expected for demo)"

deactivate
cd ..

# Check poetry project
cd data-pipeline
echo "Checking Poetry project..."
poetry audit || echo "Audit complete"
cd ..

echo "✅ Exercise 4 complete: Security auditing"

# Exercise 5: Multi-Environment Setup
echo -e "\n🌍 Exercise 5: Multi-Environment Setup"
echo "Creating development and production configurations..."

mkdir -p exercise5-environments
cd exercise5-environments

# Create base requirements
cat > requirements-base.txt << 'EOF'
pandas==2.1.0
numpy==1.24.3
requests==2.31.0
EOF

# Development requirements
cat > requirements-dev.txt << 'EOF'
-r requirements-base.txt
pytest>=7.0.0
black>=23.0.0
mypy>=1.0.0
jupyter>=1.0.0
ipython>=8.0.0
pytest-cov>=4.0.0
EOF

# Production requirements
cat > requirements-prod.txt << 'EOF'
-r requirements-base.txt
gunicorn>=21.0.0
psycopg2-binary>=2.9.0
redis>=4.5.0
EOF

# Create environment-specific configs
cat > .env.development << 'EOF'
DEBUG=true
DATABASE_URL=sqlite:///dev.db
REDIS_URL=redis://localhost:6379/0
LOG_LEVEL=DEBUG
EOF

cat > .env.production << 'EOF'
DEBUG=false
DATABASE_URL=postgresql://user:pass@prod-db:5432/app
REDIS_URL=redis://prod-redis:6379/0
LOG_LEVEL=INFO
EOF

# Create app with environment loading
cat > app.py << 'EOF'
"""Sample application with environment configuration."""
import os
from dotenv import load_dotenv

# Load environment variables
env_file = f".env.{os.getenv('ENVIRONMENT', 'development')}"
load_dotenv(env_file)

class Config:
    """Application configuration."""
    DEBUG = os.getenv('DEBUG', 'false').lower() == 'true'
    DATABASE_URL = os.getenv('DATABASE_URL')
    REDIS_URL = os.getenv('REDIS_URL')
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')

def main():
    """Main application."""
    config = Config()
    
    print(f"Environment: {os.getenv('ENVIRONMENT', 'development')}")
    print(f"Debug mode: {config.DEBUG}")
    print(f"Database: {config.DATABASE_URL}")
    print(f"Redis: {config.REDIS_URL}")
    print(f"Log level: {config.LOG_LEVEL}")

if __name__ == "__main__":
    main()
EOF

# Test different environments
python3 -m venv dev-env
source dev-env/bin/activate
pip install python-dotenv

echo "Testing development environment:"
ENVIRONMENT=development python app.py

echo -e "\nTesting production environment:"
ENVIRONMENT=production python app.py

deactivate
cd ..

echo "✅ Exercise 5 complete: Multi-environment setup"

# Exercise 6: Package Publishing Simulation
echo -e "\n📦 Exercise 6: Package Publishing Simulation"
echo "Creating a publishable package structure..."

mkdir -p exercise6-package
cd exercise6-package

# Create package structure
mkdir -p src/datatools tests docs

# Create setup files
cat > pyproject.toml << 'EOF'
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "datatools"
version = "0.1.0"
description = "Simple data processing tools"
authors = [{name = "Your Name", email = "you@example.com"}]
license = {text = "MIT"}
readme = "README.md"
requires-python = ">=3.8"
dependencies = [
    "pandas>=1.5.0",
    "numpy>=1.20.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "mypy>=1.0.0",
]

[project.scripts]
datatools = "datatools.cli:main"
EOF

# Create package code
cat > src/datatools/__init__.py << 'EOF'
"""Simple data processing tools."""
__version__ = "0.1.0"

from .processor import DataProcessor
from .utils import load_csv, save_csv

__all__ = ["DataProcessor", "load_csv", "save_csv"]
EOF

cat > src/datatools/processor.py << 'EOF'
"""Data processing utilities."""
import pandas as pd
import numpy as np

class DataProcessor:
    """Simple data processor."""
    
    def __init__(self):
        self.data = None
    
    def load_data(self, data):
        """Load data for processing."""
        self.data = data
        return self
    
    def clean_data(self):
        """Clean the data."""
        if self.data is None:
            raise ValueError("No data loaded")
        
        # Remove duplicates
        self.data = self.data.drop_duplicates()
        
        # Fill missing values
        numeric_cols = self.data.select_dtypes(include=[np.number]).columns
        self.data[numeric_cols] = self.data[numeric_cols].fillna(0)
        
        return self
    
    def get_summary(self):
        """Get data summary."""
        if self.data is None:
            raise ValueError("No data loaded")
        
        return {
            'shape': self.data.shape,
            'columns': list(self.data.columns),
            'dtypes': dict(self.data.dtypes),
            'missing': dict(self.data.isnull().sum())
        }
EOF

cat > src/datatools/utils.py << 'EOF'
"""Utility functions."""
import pandas as pd

def load_csv(filepath, **kwargs):
    """Load CSV file."""
    return pd.read_csv(filepath, **kwargs)

def save_csv(data, filepath, **kwargs):
    """Save data to CSV."""
    data.to_csv(filepath, index=False, **kwargs)
EOF

cat > src/datatools/cli.py << 'EOF'
"""Command line interface."""
import click
import pandas as pd
from .processor import DataProcessor

@click.command()
@click.option('--input', '-i', help='Input CSV file')
@click.option('--output', '-o', help='Output CSV file')
def main(input, output):
    """Process data from command line."""
    if not input:
        click.echo("No input file specified")
        return
    
    # Load and process data
    data = pd.read_csv(input)
    processor = DataProcessor()
    processor.load_data(data).clean_data()
    
    # Show summary
    summary = processor.get_summary()
    click.echo(f"Processed {summary['shape'][0]} rows, {summary['shape'][1]} columns")
    
    # Save if output specified
    if output:
        processor.data.to_csv(output, index=False)
        click.echo(f"Saved to {output}")

if __name__ == '__main__':
    main()
EOF

# Create tests
cat > tests/test_processor.py << 'EOF'
"""Tests for data processor."""
import pytest
import pandas as pd
from datatools.processor import DataProcessor

def test_data_processor():
    """Test data processor."""
    # Create sample data
    data = pd.DataFrame({
        'a': [1, 2, 2, 4],
        'b': [1, None, 3, 4]
    })
    
    processor = DataProcessor()
    processor.load_data(data).clean_data()
    
    # Check results
    assert processor.data.shape[0] == 3  # Duplicate removed
    assert processor.data['b'].isnull().sum() == 0  # NaN filled
EOF

# Create README
cat > README.md << 'EOF'
# DataTools

Simple data processing tools for Python.

## Installation

```bash
pip install datatools
```

## Usage

```python
from datatools import DataProcessor

processor = DataProcessor()
processor.load_data(data).clean_data()
summary = processor.get_summary()
```

## CLI

```bash
datatools -i input.csv -o output.csv
```
EOF

# Build package (simulation)
echo "Package structure created. In real scenario, you would run:"
echo "pip install build"
echo "python -m build"
echo "twine upload dist/*"

cd ..

echo "✅ Exercise 6 complete: Package publishing structure"

echo -e "\n🎉 All Day 24 exercises completed!"
echo "You've practiced:"
echo "- pip fundamentals with requirements.txt"
echo "- Poetry project management"
echo "- uv ultra-fast package management"
echo "- Security auditing and vulnerability scanning"
echo "- Multi-environment configuration"
echo "- Package publishing structure"
echo ""
echo "Next: Day 25 - API Testing with curl and httpie"
