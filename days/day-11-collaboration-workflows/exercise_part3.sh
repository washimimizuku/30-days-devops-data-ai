#!/bin/bash

# Day 11 Exercise - Part 3: More team development and collaboration

echo "2.3 Simulate Developer 2 - Testing Framework:"
git checkout develop
git checkout -b feature/testing-framework

cat > tests/test_processor.py << 'EOF'
"""Tests for data processing module."""

import pytest
import pandas as pd
import tempfile
import os
from pathlib import Path
import sys

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from data_processing.processor import DataProcessor

class TestDataProcessor:
    """Test suite for DataProcessor class."""
    
    def setup_method(self):
        """Set up test fixtures before each test."""
        self.config = {"test_mode": True}
        self.processor = DataProcessor(self.config)
    
    def test_processor_initialization(self):
        """Test processor initializes correctly."""
        assert self.processor.config == self.config
    
    def test_load_csv_data(self):
        """Test loading CSV data."""
        # Create temporary CSV file
        test_data = "name,age,city\nAlice,25,NYC\nBob,30,LA\nCharlie,35,Chicago"
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
            f.write(test_data)
            temp_file = f.name
        
        try:
            df = self.processor.load_data(temp_file)
            
            assert len(df) == 3
            assert list(df.columns) == ['name', 'age', 'city']
            assert df.iloc[0]['name'] == 'Alice'
            assert df.iloc[0]['age'] == 25
            
        finally:
            os.unlink(temp_file)
    
    def test_load_json_data(self):
        """Test loading JSON data."""
        test_data = '[{"name": "Alice", "age": 25}, {"name": "Bob", "age": 30}]'
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            f.write(test_data)
            temp_file = f.name
        
        try:
            df = self.processor.load_data(temp_file)
            
            assert len(df) == 2
            assert 'name' in df.columns
            assert 'age' in df.columns
            
        finally:
            os.unlink(temp_file)
    
    def test_load_nonexistent_file(self):
        """Test loading non-existent file raises error."""
        with pytest.raises(FileNotFoundError):
            self.processor.load_data("nonexistent_file.csv")
    
    def test_load_unsupported_format(self):
        """Test loading unsupported file format raises error."""
        with tempfile.NamedTemporaryFile(suffix='.txt', delete=False) as f:
            temp_file = f.name
        
        try:
            with pytest.raises(ValueError, match="Unsupported file format"):
                self.processor.load_data(temp_file)
        finally:
            os.unlink(temp_file)
    
    def test_clean_data_removes_duplicates(self):
        """Test data cleaning removes duplicates."""
        # Create DataFrame with duplicates
        data = {
            'name': ['Alice', 'Bob', 'Alice', 'Charlie'],
            'age': [25, 30, 25, 35],
            'city': ['NYC', 'LA', 'NYC', 'Chicago']
        }
        df = pd.DataFrame(data)
        
        cleaned_df = self.processor.clean_data(df)
        
        assert len(cleaned_df) == 3  # One duplicate removed
        assert not cleaned_df.duplicated().any()
    
    def test_clean_data_removes_nulls(self):
        """Test data cleaning removes null values."""
        # Create DataFrame with null values
        data = {
            'name': ['Alice', 'Bob', None, 'Charlie'],
            'age': [25, None, 30, 35],
            'city': ['NYC', 'LA', 'Boston', None]
        }
        df = pd.DataFrame(data)
        
        cleaned_df = self.processor.clean_data(df)
        
        assert not cleaned_df.isnull().any().any()
        assert len(cleaned_df) == 1  # Only complete rows remain
    
    def test_process_data_pipeline(self):
        """Test complete data processing pipeline."""
        # Create test CSV file
        test_data = "name,age,city\nAlice,25,NYC\nBob,30,LA\nAlice,25,NYC\nCharlie,35,Chicago"
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as input_file:
            input_file.write(test_data)
            input_path = input_file.name
        
        with tempfile.NamedTemporaryFile(suffix='.csv', delete=False) as output_file:
            output_path = output_file.name
        
        try:
            # Process data
            result_df = self.processor.process_data(input_path, output_path)
            
            # Verify results
            assert len(result_df) == 3  # Duplicate removed
            assert os.path.exists(output_path)
            
            # Verify output file
            saved_df = pd.read_csv(output_path)
            assert len(saved_df) == 3
            
        finally:
            os.unlink(input_path)
            if os.path.exists(output_path):
                os.unlink(output_path)

# Integration tests
class TestDataProcessorIntegration:
    """Integration tests for DataProcessor."""
    
    def test_end_to_end_workflow(self):
        """Test complete end-to-end data processing workflow."""
        processor = DataProcessor({"integration_test": True})
        
        # Create realistic test data
        test_data = """customer_id,name,email,age,purchase_amount,city
1,Alice Johnson,alice@email.com,25,150.50,New York
2,Bob Smith,bob@email.com,30,200.00,Los Angeles
1,Alice Johnson,alice@email.com,25,150.50,New York
3,Charlie Brown,charlie@email.com,35,75.25,Chicago
4,Diana Prince,,28,300.00,Seattle
5,Eve Wilson,eve@email.com,,125.75,Boston"""
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
            f.write(test_data)
            temp_file = f.name
        
        try:
            # Process the data
            result_df = processor.process_data(temp_file)
            
            # Verify processing results
            assert len(result_df) > 0
            assert not result_df.duplicated().any()
            assert not result_df.isnull().any().any()
            
            # Verify expected columns exist
            expected_columns = ['customer_id', 'name', 'email', 'age', 'purchase_amount', 'city']
            for col in expected_columns:
                assert col in result_df.columns
            
        finally:
            os.unlink(temp_file)

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
EOF

cat > tests/test_analyzer.py << 'EOF'
"""Tests for data analysis module."""

import pytest
import pandas as pd
import numpy as np
import sys
from pathlib import Path

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent / "src"))

from analysis.analyzer import DataAnalyzer

class TestDataAnalyzer:
    """Test suite for DataAnalyzer class."""
    
    def setup_method(self):
        """Set up test fixtures."""
        self.config = {"test_mode": True}
        self.analyzer = DataAnalyzer(self.config)
        
        # Create sample data for testing
        self.sample_data = pd.DataFrame({
            'age': [25, 30, 35, 40, 45],
            'income': [50000, 60000, 70000, 80000, 90000],
            'score': [85, 90, 88, 92, 87],
            'category': ['A', 'B', 'A', 'C', 'B'],
            'active': [True, True, False, True, True]
        })
    
    def test_analyzer_initialization(self):
        """Test analyzer initializes correctly."""
        assert self.analyzer.config == self.config
        assert self.analyzer.results == {}
    
    def test_descriptive_statistics(self):
        """Test descriptive statistics calculation."""
        stats = self.analyzer.descriptive_statistics(self.sample_data)
        
        # Check that stats were calculated for numeric columns
        assert 'age' in stats
        assert 'income' in stats
        assert 'score' in stats
        
        # Verify age statistics
        age_stats = stats['age']
        assert age_stats['count'] == 5
        assert age_stats['mean'] == 35.0
        assert age_stats['min'] == 25.0
        assert age_stats['max'] == 45.0
        
        # Verify results are stored
        assert 'descriptive_stats' in self.analyzer.results
    
    def test_correlation_analysis(self):
        """Test correlation analysis."""
        correlation_matrix = self.analyzer.correlation_analysis(self.sample_data)
        
        # Check matrix properties
        assert isinstance(correlation_matrix, pd.DataFrame)
        assert correlation_matrix.shape[0] == correlation_matrix.shape[1]
        
        # Check diagonal values are 1.0
        for col in correlation_matrix.columns:
            assert abs(correlation_matrix.loc[col, col] - 1.0) < 1e-10
        
        # Verify results are stored
        assert 'correlation_matrix' in self.analyzer.results
    
    def test_correlation_analysis_no_numeric_columns(self):
        """Test correlation analysis with no numeric columns."""
        text_data = pd.DataFrame({
            'name': ['Alice', 'Bob', 'Charlie'],
            'city': ['NYC', 'LA', 'Chicago']
        })
        
        correlation_matrix = self.analyzer.correlation_analysis(text_data)
        assert correlation_matrix.empty
    
    def test_data_quality_report(self):
        """Test data quality report generation."""
        # Add some missing values for testing
        test_data = self.sample_data.copy()
        test_data.loc[0, 'income'] = np.nan
        test_data.loc[1, 'score'] = np.nan
        
        quality_report = self.analyzer.data_quality_report(test_data)
        
        # Check report structure
        assert 'total_rows' in quality_report
        assert 'total_columns' in quality_report
        assert 'missing_values' in quality_report
        assert 'completeness' in quality_report
        
        # Verify values
        assert quality_report['total_rows'] == 5
        assert quality_report['total_columns'] == 5
        assert quality_report['missing_values']['income'] == 1
        assert quality_report['missing_values']['score'] == 1
        
        # Check completeness percentages
        assert quality_report['completeness']['age'] == 100.0
        assert quality_report['completeness']['income'] == 80.0
    
    def test_generate_summary_report(self):
        """Test summary report generation."""
        report = self.analyzer.generate_summary_report(self.sample_data)
        
        # Check report is a string
        assert isinstance(report, str)
        
        # Check key sections are present
        assert "DATA ANALYSIS SUMMARY REPORT" in report
        assert "Dataset Overview" in report
        assert "Data Quality Summary" in report
        assert "Numerical Columns Summary" in report
        
        # Check specific data points
        assert "Total Records: 5" in report
        assert "Total Columns: 5" in report
    
    def test_empty_dataframe_handling(self):
        """Test handling of empty DataFrame."""
        empty_df = pd.DataFrame()
        
        # Should not raise errors
        stats = self.analyzer.descriptive_statistics(empty_df)
        quality = self.analyzer.data_quality_report(empty_df)
        correlation = self.analyzer.correlation_analysis(empty_df)
        
        assert stats == {}
        assert quality['total_rows'] == 0
        assert correlation.empty

if __name__ == "__main__":
    pytest.main([__file__, "-v"])
EOF

git add tests/
git commit -m "Add comprehensive testing framework

Features:
- Unit tests for DataProcessor class
- Unit tests for DataAnalyzer class
- Integration tests for end-to-end workflows
- Test fixtures and proper setup/teardown
- Edge case testing (empty data, missing files, etc.)
- Pytest configuration and test discovery

This testing framework ensures code quality and prevents regressions."

echo "✓ Developer 2 testing framework committed"

echo "2.4 Simulate Developer 3 - Documentation:"
git checkout develop
git checkout -b feature/documentation

mkdir -p docs/guides
cat > docs/guides/GETTING_STARTED.md << 'EOF'
# Getting Started Guide

Welcome to the Collaborative Data Project! This guide will help you get up and running quickly.

## Prerequisites

- Python 3.8 or higher
- Git 2.20 or higher
- Basic familiarity with command line

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd collaborative-data-project
```

### 2. Set Up Python Environment

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Verify Installation

```bash
# Run tests to verify everything works
pytest tests/ -v

# Check code style
flake8 src/
black --check src/
```

## Quick Start

### Processing Data

```python
from src.data_processing.processor import DataProcessor

# Initialize processor
config = {"chunk_size": 1000}
processor = DataProcessor(config)

# Process a CSV file
df = processor.process_data("input.csv", "output.csv")
print(f"Processed {len(df)} records")
```

### Analyzing Data

```python
from src.analysis.analyzer import DataAnalyzer
import pandas as pd

# Load your data
df = pd.read_csv("your_data.csv")

# Initialize analyzer
config = {"output_dir": "results"}
analyzer = DataAnalyzer(config)

# Generate comprehensive report
report = analyzer.generate_summary_report(df)
print(report)
```

## Development Workflow

### 1. Create Feature Branch

```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### 2. Make Changes

- Write code following our style guidelines
- Add tests for new functionality
- Update documentation as needed

### 3. Test Your Changes

```bash
# Run all tests
pytest tests/ -v

# Check code style
flake8 src/
black src/

# Run specific tests
pytest tests/test_processor.py -v
```

### 4. Submit Pull Request

```bash
git add .
git commit -m "Add your feature description"
git push origin feature/your-feature-name
```

Then create a pull request on GitHub/GitLab.

## Project Structure

```
collaborative-data-project/
├── src/                    # Source code
│   ├── data_processing/    # Data processing modules
│   ├── analysis/          # Data analysis modules
│   └── utils/             # Utility functions
├── tests/                 # Test suites
│   ├── unit/              # Unit tests
│   └── integration/       # Integration tests
├── docs/                  # Documentation
│   ├── guides/            # User guides
│   └── templates/         # Document templates
├── config/                # Configuration files
├── scripts/               # Utility scripts
└── examples/              # Usage examples
```

## Configuration

The project uses configuration files in the `config/` directory:

- `settings.py` - Main configuration settings
- Environment variables for sensitive data

## Troubleshooting

### Common Issues

**Import Errors**
```bash
# Make sure you're in the project root and virtual environment is activated
source venv/bin/activate
export PYTHONPATH="${PYTHONPATH}:$(pwd)/src"
```

**Test Failures**
```bash
# Run tests with verbose output to see details
pytest tests/ -v -s

# Run specific failing test
pytest tests/test_processor.py::TestDataProcessor::test_load_csv_data -v
```

**Style Check Failures**
```bash
# Auto-format code
black src/
isort src/

# Check what needs fixing
flake8 src/ --show-source
```

## Getting Help

- Check the [documentation](../README.md)
- Look at [examples](../../examples/)
- Open an [issue](../../issues) for bugs or questions
- Join our team discussions

## Next Steps

- Read the [API Documentation](API.md)
- Check out [Examples](../../examples/)
- Review [Contributing Guidelines](CONTRIBUTING.md)
- Explore the [Architecture Guide](ARCHITECTURE.md)
EOF

cat > docs/guides/API.md << 'EOF'
# API Documentation

## DataProcessor Class

The `DataProcessor` class handles data loading, cleaning, and processing operations.

### Constructor

```python
DataProcessor(config: Dict[str, Any])
```

**Parameters:**
- `config`: Configuration dictionary with processing settings

### Methods

#### load_data(file_path: str) -> pd.DataFrame

Load data from a file (CSV or JSON format).

**Parameters:**
- `file_path`: Path to the data file

**Returns:**
- `pd.DataFrame`: Loaded data

**Raises:**
- `FileNotFoundError`: If file doesn't exist
- `ValueError`: If file format is unsupported

**Example:**
```python
processor = DataProcessor({})
df = processor.load_data("data.csv")
```

#### clean_data(df: pd.DataFrame) -> pd.DataFrame

Clean data by removing duplicates and handling missing values.

**Parameters:**
- `df`: Input DataFrame to clean

**Returns:**
- `pd.DataFrame`: Cleaned data

**Example:**
```python
cleaned_df = processor.clean_data(raw_df)
```

#### process_data(input_file: str, output_file: Optional[str] = None) -> pd.DataFrame

Complete data processing pipeline.

**Parameters:**
- `input_file`: Path to input data file
- `output_file`: Optional path to save processed data

**Returns:**
- `pd.DataFrame`: Processed data

**Example:**
```python
result = processor.process_data("input.csv", "output.csv")
```

## DataAnalyzer Class

The `DataAnalyzer` class provides comprehensive data analysis capabilities.

### Constructor

```python
DataAnalyzer(config: Dict[str, Any])
```

### Methods

#### descriptive_statistics(df: pd.DataFrame) -> Dict[str, Any]

Calculate descriptive statistics for numerical columns.

**Returns:**
- Dictionary with statistics for each numerical column

#### correlation_analysis(df: pd.DataFrame) -> pd.DataFrame

Perform correlation analysis on numerical columns.

**Returns:**
- Correlation matrix as DataFrame

#### data_quality_report(df: pd.DataFrame) -> Dict[str, Any]

Generate comprehensive data quality report.

**Returns:**
- Dictionary with quality metrics

#### generate_summary_report(df: pd.DataFrame) -> str

Generate a comprehensive text summary report.

**Returns:**
- Formatted text report string

## Configuration Options

### DataProcessor Configuration

```python
config = {
    "chunk_size": 10000,        # Processing chunk size
    "max_workers": 4,           # Maximum parallel workers
    "timeout_seconds": 300,     # Processing timeout
    "log_level": "INFO"         # Logging level
}
```

### DataAnalyzer Configuration

```python
config = {
    "output_dir": "results",    # Output directory for reports
    "correlation_threshold": 0.7,  # Strong correlation threshold
    "missing_threshold": 0.1    # Missing data threshold
}
```

## Error Handling

All methods include proper error handling and logging. Common exceptions:

- `FileNotFoundError`: File operations on missing files
- `ValueError`: Invalid parameters or data formats
- `pandas.errors.EmptyDataError`: Empty data files
- `MemoryError`: Insufficient memory for large datasets

## Examples

See the `examples/` directory for complete usage examples and tutorials.
EOF

git add docs/guides/
git commit -m "Add comprehensive documentation and API reference

Features:
- Getting started guide with installation steps
- Complete API documentation with examples
- Troubleshooting section for common issues
- Configuration options and best practices
- Clear code examples and usage patterns

This documentation helps new team members get up to speed quickly."

echo "✓ Developer 3 documentation committed"

# Combine all exercise parts
cd ..
cat "${PROJECT_NAME}/exercise.sh" "${PROJECT_NAME}/exercise_part2.sh" "${PROJECT_NAME}/exercise_part3.sh" > exercise_combined.sh 2>/dev/null
mv exercise_combined.sh "${PROJECT_NAME}/exercise.sh" 2>/dev/null
rm -f "${PROJECT_NAME}/exercise_part2.sh" "${PROJECT_NAME}/exercise_part3.sh" 2>/dev/null

cd "$PROJECT_NAME"

echo

# Exercise 3: Pull Request Simulation
echo "=== Exercise 3: Pull Request and Code Review Simulation ==="
echo "TODO: Simulate pull request creation and code review process"
echo

echo "3.1 Merge features into develop branch:"
# Simulate merging the features
git checkout develop

echo "Merging data analysis feature..."
git merge --no-ff feature/data-analysis
echo "✓ Data analysis feature merged"

echo "Merging testing framework..."
git merge --no-ff feature/testing-framework
echo "✓ Testing framework merged"

echo "Merging documentation..."
git merge --no-ff feature/documentation
echo "✓ Documentation merged"

echo "3.2 Create comprehensive project summary:"
cat >> README.md << 'EOF'

## 🎯 Recent Updates

### Data Analysis Module (v1.1.0)
- Added comprehensive statistical analysis capabilities
- Implemented correlation analysis with insights
- Created data quality reporting system
- Generated automated summary reports

### Testing Framework (v1.1.0)
- Comprehensive unit test suite for all modules
- Integration tests for end-to-end workflows
- Pytest configuration and test discovery
- Edge case testing and error handling validation

### Documentation (v1.1.0)
- Complete getting started guide
- Comprehensive API documentation
- Troubleshooting and configuration guides
- Code examples and usage patterns

## 📈 Project Statistics

- **Modules**: 3 core modules (processor, analyzer, utils)
- **Tests**: 15+ unit tests, 5+ integration tests
- **Documentation**: 4 comprehensive guides
- **Code Coverage**: 90%+ (target)
- **Team Members**: 3 active contributors

## 🔄 Development Status

- ✅ Core data processing pipeline
- ✅ Statistical analysis capabilities
- ✅ Comprehensive testing framework
- ✅ Complete documentation
- 🚧 Advanced visualization features (in progress)
- 🚧 API endpoints for web integration (planned)
- 🚧 Performance optimization (planned)
EOF

git add README.md
git commit -m "Update project summary with recent team contributions

- Document new data analysis capabilities
- Highlight comprehensive testing framework
- Showcase improved documentation
- Add project statistics and development status
- Reflect collaborative team development process"

echo "✓ Project summary updated"

echo "3.3 Repository collaboration statistics:"
echo "Collaboration Statistics:"
echo "========================"
echo "Total commits: $(git rev-list --count --all)"
echo "Feature branches created: 4"
echo "Features merged: 3"
echo "Contributors: 3 team members"
echo "Files created: $(git ls-files | wc -l)"
echo "Lines of code: $(find src tests -name "*.py" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo 'N/A')"

echo
echo "Branch history:"
git log --oneline --graph -10

# Cleanup
cd ..

echo
echo "=== Exercise Complete ==="
echo
echo "🎉 Congratulations! You've mastered Git collaboration workflows."
echo
echo "What you've accomplished:"
echo "✓ Set up collaborative project with proper structure"
echo "✓ Created GitHub issue and PR templates"
echo "✓ Simulated multi-developer team environment"
echo "✓ Implemented feature branch workflow"
echo "✓ Created comprehensive testing framework"
echo "✓ Added detailed documentation and API reference"
echo "✓ Practiced merge and integration workflows"
echo "✓ Established team collaboration standards"
echo
echo "Key collaboration skills learned:"
echo "• Pull request creation and management"
echo "• Code review processes and standards"
echo "• Issue tracking and project management"
echo "• Team development workflows"
echo "• Documentation and knowledge sharing"
echo "• Quality assurance through testing"
echo
echo "Your collaborative project: $PROJECT_NAME"
echo
echo "Next: Learn about Git workflows (GitFlow, Feature Branch, Trunk-based)! 🔄"
