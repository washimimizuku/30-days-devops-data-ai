#!/bin/bash

# Day 11 Exercise - Part 2: Issue templates and initial development

echo "1.3 Create issue templates:"
mkdir -p .github/ISSUE_TEMPLATE

# Bug report template
cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
---
name: Bug Report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

## Bug Description
A clear and concise description of what the bug is.

## Steps to Reproduce
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

## Expected Behavior
A clear and concise description of what you expected to happen.

## Actual Behavior
A clear and concise description of what actually happened.

## Screenshots
If applicable, add screenshots to help explain your problem.

## Environment
- OS: [e.g. macOS, Ubuntu 20.04]
- Python Version: [e.g. 3.11.0]
- Package Version: [e.g. 1.2.3]

## Additional Context
Add any other context about the problem here.

## Possible Solution
If you have ideas on how to fix this, please describe them here.
EOF

# Feature request template
cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
---
name: Feature Request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: enhancement
assignees: ''
---

## Feature Description
A clear and concise description of what you want to happen.

## Problem Statement
Is your feature request related to a problem? Please describe.
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

## Proposed Solution
Describe the solution you'd like.
A clear and concise description of what you want to happen.

## Alternative Solutions
Describe alternatives you've considered.
A clear and concise description of any alternative solutions or features you've considered.

## Use Cases
Describe specific use cases for this feature:
- Use case 1: ...
- Use case 2: ...

## Implementation Ideas
If you have ideas on how to implement this feature, describe them here.

## Additional Context
Add any other context or screenshots about the feature request here.

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3
EOF

echo "✓ Issue templates created"

echo "1.4 Create initial project files:"
# Requirements file
cat > requirements.txt << 'EOF'
pandas>=2.0.0
numpy>=1.24.0
pytest>=7.4.0
flake8>=6.0.0
black>=23.0.0
jupyter>=1.0.0
matplotlib>=3.7.0
seaborn>=0.12.0
EOF

# Configuration file
cat > config/settings.py << 'EOF'
"""Project configuration settings."""

import os
from pathlib import Path

# Project paths
PROJECT_ROOT = Path(__file__).parent.parent
DATA_DIR = PROJECT_ROOT / "data"
OUTPUT_DIR = PROJECT_ROOT / "output"
LOGS_DIR = PROJECT_ROOT / "logs"

# Data processing settings
CHUNK_SIZE = 10000
MAX_WORKERS = 4
TIMEOUT_SECONDS = 300

# Logging configuration
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
LOG_FORMAT = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# Database settings (if needed)
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///data.db")

# API settings
API_BASE_URL = os.getenv("API_BASE_URL", "https://api.example.com")
API_TIMEOUT = int(os.getenv("API_TIMEOUT", "30"))
EOF

# Initial data processing module
cat > src/data_processing/processor.py << 'EOF'
"""Core data processing functionality."""

import pandas as pd
import logging
from typing import Dict, Any, List, Optional
from pathlib import Path

logger = logging.getLogger(__name__)

class DataProcessor:
    """Main data processing class."""
    
    def __init__(self, config: Dict[str, Any]):
        """Initialize processor with configuration."""
        self.config = config
        logger.info("DataProcessor initialized")
    
    def load_data(self, file_path: str) -> pd.DataFrame:
        """Load data from file."""
        path = Path(file_path)
        
        if not path.exists():
            raise FileNotFoundError(f"Data file not found: {file_path}")
        
        if path.suffix.lower() == '.csv':
            df = pd.read_csv(file_path)
        elif path.suffix.lower() == '.json':
            df = pd.read_json(file_path)
        else:
            raise ValueError(f"Unsupported file format: {path.suffix}")
        
        logger.info(f"Loaded {len(df)} rows from {file_path}")
        return df
    
    def clean_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean and validate data."""
        logger.info("Starting data cleaning")
        
        # Remove duplicates
        initial_rows = len(df)
        df = df.drop_duplicates()
        duplicates_removed = initial_rows - len(df)
        
        if duplicates_removed > 0:
            logger.info(f"Removed {duplicates_removed} duplicate rows")
        
        # Handle missing values
        missing_before = df.isnull().sum().sum()
        df = df.dropna()
        missing_after = df.isnull().sum().sum()
        
        if missing_before > missing_after:
            logger.info(f"Removed rows with missing values")
        
        logger.info(f"Data cleaning completed: {len(df)} rows remaining")
        return df
    
    def process_data(self, input_file: str, output_file: Optional[str] = None) -> pd.DataFrame:
        """Complete data processing pipeline."""
        logger.info(f"Starting data processing pipeline for {input_file}")
        
        # Load data
        df = self.load_data(input_file)
        
        # Clean data
        df = self.clean_data(df)
        
        # Save processed data if output file specified
        if output_file:
            df.to_csv(output_file, index=False)
            logger.info(f"Processed data saved to {output_file}")
        
        return df

def main():
    """Main function for testing."""
    config = {"test": True}
    processor = DataProcessor(config)
    
    print("DataProcessor initialized successfully")
    print("Available methods:")
    print("- load_data(file_path)")
    print("- clean_data(dataframe)")
    print("- process_data(input_file, output_file)")

if __name__ == "__main__":
    main()
EOF

echo "✓ Initial project files created"

echo "1.5 Make initial commit:"
git add .
git commit -m "Initial project setup for collaborative development

- Add comprehensive README with collaboration guidelines
- Create GitHub issue and PR templates
- Set up project structure for team development
- Add initial data processing module
- Include configuration and requirements files"

echo "✓ Initial commit completed"

echo

# Exercise 2: Simulating Team Development
echo "=== Exercise 2: Team Development Simulation ==="
echo "TODO: Simulate multiple team members working on different features"
echo

echo "2.1 Create develop branch:"
git checkout -b develop
git push -u origin develop 2>/dev/null || echo "Note: No remote configured for push"

echo "2.2 Simulate Developer 1 - Data Analysis Feature:"
git checkout -b feature/data-analysis

cat > src/analysis/analyzer.py << 'EOF'
"""Data analysis and statistics module."""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from typing import Dict, Any, List, Tuple
import logging

logger = logging.getLogger(__name__)

class DataAnalyzer:
    """Comprehensive data analysis toolkit."""
    
    def __init__(self, config: Dict[str, Any]):
        """Initialize analyzer with configuration."""
        self.config = config
        self.results = {}
        logger.info("DataAnalyzer initialized")
    
    def descriptive_statistics(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Calculate descriptive statistics for numerical columns."""
        logger.info("Calculating descriptive statistics")
        
        numeric_columns = df.select_dtypes(include=[np.number]).columns
        stats = {}
        
        for col in numeric_columns:
            stats[col] = {
                'count': int(df[col].count()),
                'mean': float(df[col].mean()),
                'median': float(df[col].median()),
                'std': float(df[col].std()),
                'min': float(df[col].min()),
                'max': float(df[col].max()),
                'q25': float(df[col].quantile(0.25)),
                'q75': float(df[col].quantile(0.75))
            }
        
        self.results['descriptive_stats'] = stats
        logger.info(f"Statistics calculated for {len(numeric_columns)} columns")
        return stats
    
    def correlation_analysis(self, df: pd.DataFrame) -> pd.DataFrame:
        """Perform correlation analysis on numerical columns."""
        logger.info("Performing correlation analysis")
        
        numeric_df = df.select_dtypes(include=[np.number])
        
        if numeric_df.empty:
            logger.warning("No numerical columns found for correlation analysis")
            return pd.DataFrame()
        
        correlation_matrix = numeric_df.corr()
        self.results['correlation_matrix'] = correlation_matrix
        
        logger.info("Correlation analysis completed")
        return correlation_matrix
    
    def data_quality_report(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Generate comprehensive data quality report."""
        logger.info("Generating data quality report")
        
        report = {
            'total_rows': len(df),
            'total_columns': len(df.columns),
            'memory_usage_mb': df.memory_usage(deep=True).sum() / 1024**2,
            'missing_values': {},
            'data_types': {},
            'unique_values': {},
            'duplicate_rows': int(df.duplicated().sum())
        }
        
        # Analyze each column
        for col in df.columns:
            report['missing_values'][col] = int(df[col].isnull().sum())
            report['data_types'][col] = str(df[col].dtype)
            report['unique_values'][col] = int(df[col].nunique())
        
        # Calculate completeness percentages
        report['completeness'] = {}
        for col in df.columns:
            non_null_count = df[col].count()
            report['completeness'][col] = (non_null_count / len(df)) * 100
        
        self.results['quality_report'] = report
        logger.info("Data quality report generated")
        return report
    
    def generate_summary_report(self, df: pd.DataFrame) -> str:
        """Generate a comprehensive text summary report."""
        logger.info("Generating summary report")
        
        # Run all analyses
        stats = self.descriptive_statistics(df)
        quality = self.data_quality_report(df)
        correlation = self.correlation_analysis(df)
        
        # Build report
        report_lines = [
            "=" * 60,
            "DATA ANALYSIS SUMMARY REPORT",
            "=" * 60,
            f"Dataset Overview:",
            f"  • Total Records: {quality['total_rows']:,}",
            f"  • Total Columns: {quality['total_columns']}",
            f"  • Memory Usage: {quality['memory_usage_mb']:.2f} MB",
            f"  • Duplicate Rows: {quality['duplicate_rows']:,}",
            "",
            "Data Quality Summary:",
        ]
        
        # Add completeness summary
        avg_completeness = np.mean(list(quality['completeness'].values()))
        report_lines.append(f"  • Average Completeness: {avg_completeness:.1f}%")
        
        # Add columns with issues
        incomplete_cols = [col for col, pct in quality['completeness'].items() if pct < 100]
        if incomplete_cols:
            report_lines.append(f"  • Columns with Missing Data: {len(incomplete_cols)}")
        
        # Add numerical statistics summary
        if stats:
            report_lines.extend([
                "",
                "Numerical Columns Summary:",
            ])
            
            for col, col_stats in stats.items():
                report_lines.extend([
                    f"  {col}:",
                    f"    Mean: {col_stats['mean']:.2f}",
                    f"    Median: {col_stats['median']:.2f}",
                    f"    Std Dev: {col_stats['std']:.2f}",
                    f"    Range: {col_stats['min']:.2f} to {col_stats['max']:.2f}",
                ])
        
        # Add correlation insights
        if not correlation.empty:
            report_lines.extend([
                "",
                "Correlation Insights:",
            ])
            
            # Find strong correlations (> 0.7 or < -0.7)
            strong_corr = []
            for i in range(len(correlation.columns)):
                for j in range(i+1, len(correlation.columns)):
                    corr_val = correlation.iloc[i, j]
                    if abs(corr_val) > 0.7:
                        col1, col2 = correlation.columns[i], correlation.columns[j]
                        strong_corr.append(f"    {col1} ↔ {col2}: {corr_val:.3f}")
            
            if strong_corr:
                report_lines.append("  • Strong Correlations (|r| > 0.7):")
                report_lines.extend(strong_corr)
            else:
                report_lines.append("  • No strong correlations found (|r| > 0.7)")
        
        report_lines.append("=" * 60)
        
        report_text = "\n".join(report_lines)
        logger.info("Summary report generated")
        return report_text

def main():
    """Main function for testing."""
    config = {"output_dir": "output"}
    analyzer = DataAnalyzer(config)
    
    print("DataAnalyzer initialized successfully")
    print("Available methods:")
    print("- descriptive_statistics(df)")
    print("- correlation_analysis(df)")
    print("- data_quality_report(df)")
    print("- generate_summary_report(df)")

if __name__ == "__main__":
    main()
EOF

git add src/analysis/analyzer.py
git commit -m "Add comprehensive data analysis module

Features:
- Descriptive statistics calculation
- Correlation analysis with insights
- Data quality reporting
- Comprehensive summary report generation
- Proper logging and error handling

This module provides essential analytics capabilities for the data processing pipeline."

echo "✓ Developer 1 feature committed"
