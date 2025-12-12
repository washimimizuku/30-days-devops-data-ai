#!/bin/bash

# Day 10: Remote Repositories - Exercise
# Practice working with remote repositories and GitHub/GitLab workflows

echo "=== Day 10: Remote Repositories Exercise ==="
echo "Learning remote Git operations and collaboration workflows"
echo

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Exercise 1: Understanding Remotes
echo "=== Exercise 1: Remote Repository Concepts ==="
echo "TODO: Learn about remote repositories and their role in collaboration"
echo

PROJECT_NAME="remote-data-project"
echo "1.1 Creating local project: $PROJECT_NAME"

# Create and initialize project
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"
git init

# Configure Git
git config user.name "Data Engineer"
git config user.email "engineer@example.com"

echo "1.2 Create project structure for data engineering:"
mkdir -p {data/{raw,processed,staging},scripts/{etl,analysis},docs,tests,config}

# Create comprehensive .gitignore for data projects
cat > .gitignore << 'EOF'
# Data files - never commit raw data
data/raw/
data/processed/
data/staging/
*.csv
*.tsv
*.json
*.jsonl
*.parquet
*.avro
*.xlsx
*.sqlite
*.db

# Output and generated files
output/
reports/
charts/
*.html
*.pdf
*.png
*.jpg

# Logs
logs/
*.log

# Python
__pycache__/
*.py[cod]
*.so
.Python
venv/
env/
.env
.venv

# Jupyter Notebook
.ipynb_checkpoints/
*.ipynb

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Configuration with secrets
config/secrets.json
config/production.json
.env.local
EOF

# Create project documentation
cat > README.md << 'EOF'
# Remote Data Project

A data engineering project demonstrating Git remote repository workflows.

## 🏗️ Project Structure

```
├── data/                   # Data files (ignored in Git)
│   ├── raw/               # Raw source data
│   ├── processed/         # Cleaned and processed data
│   └── staging/           # Intermediate processing data
├── scripts/               # Processing scripts
│   ├── etl/              # Extract, Transform, Load scripts
│   └── analysis/         # Data analysis scripts
├── docs/                 # Documentation
├── tests/                # Test files
└── config/               # Configuration files
```

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd remote-data-project
   ```

2. **Set up environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Run data pipeline**
   ```bash
   python scripts/etl/extract_data.py
   python scripts/etl/transform_data.py
   python scripts/analysis/analyze_data.py
   ```

## 📊 Features

- Data extraction from multiple sources
- Data cleaning and validation
- Statistical analysis and reporting
- Automated data pipeline
- Comprehensive testing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.
EOF

# Create requirements file
cat > requirements.txt << 'EOF'
pandas>=1.5.0
numpy>=1.21.0
matplotlib>=3.5.0
seaborn>=0.11.0
jupyter>=1.0.0
pytest>=7.0.0
EOF

echo "✓ Project structure created"

echo "1.3 Make initial commit:"
git add .
git commit -m "Initial project setup with data engineering structure

- Add comprehensive .gitignore for data projects
- Create modular directory structure
- Include documentation and requirements
- Set up for collaborative development"

echo "✓ Initial commit completed"
git log --oneline

echo

# Exercise 2: Simulating Remote Repository Setup
echo "=== Exercise 2: Remote Repository Simulation ==="
echo "TODO: Simulate working with remote repositories"
echo

echo "2.1 Create a 'remote' repository (simulated):"
# Create a bare repository to simulate a remote
cd ..
git clone --bare "$PROJECT_NAME" "${PROJECT_NAME}-remote.git"
echo "✓ Created bare repository (simulates GitHub/GitLab remote)"

cd "$PROJECT_NAME"

echo "2.2 Add remote repository:"
git remote add origin "../${PROJECT_NAME}-remote.git"
echo "✓ Added origin remote"

echo "2.3 View remote configuration:"
git remote -v
echo

echo "2.4 Push to remote repository:"
git push -u origin main
echo "✓ Pushed main branch to origin with upstream tracking"

echo "2.5 View remote branches:"
git branch -a
echo

# Exercise 3: Cloning and Multiple Remotes
echo "=== Exercise 3: Cloning and Multiple Remotes ==="
echo "TODO: Practice cloning and managing multiple remotes"
echo

echo "3.1 Clone repository (simulate team member):"
cd ..
git clone "${PROJECT_NAME}-remote.git" "${PROJECT_NAME}-clone"
cd "${PROJECT_NAME}-clone"

# Configure the cloned repository
git config user.name "Team Member"
git config user.email "team@example.com"

echo "✓ Repository cloned successfully"

echo "3.2 View clone's remote configuration:"
git remote -v
git log --oneline

echo "3.3 Add upstream remote (simulate fork scenario):"
git remote add upstream "../${PROJECT_NAME}-remote.git"
git remote -v
echo "✓ Added upstream remote"

echo

# Exercise 4: Collaborative Development Workflow
echo "=== Exercise 4: Collaborative Development ==="
echo "TODO: Simulate collaborative development with remotes"
echo

echo "4.1 Create feature branch in clone:"
git checkout -b feature/data-extraction

echo "4.2 Develop data extraction module:"
cat > scripts/etl/extract_data.py << 'EOF'
#!/usr/bin/env python3
"""
Data extraction module for the remote data project.
"""

import pandas as pd
import json
from typing import Dict, List, Any
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DataExtractor:
    """Extract data from various sources."""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        logger.info("DataExtractor initialized")
    
    def extract_csv(self, file_path: str) -> pd.DataFrame:
        """Extract data from CSV file."""
        try:
            logger.info(f"Extracting data from CSV: {file_path}")
            df = pd.read_csv(file_path)
            logger.info(f"Successfully extracted {len(df)} rows from CSV")
            return df
        except FileNotFoundError:
            logger.error(f"CSV file not found: {file_path}")
            return pd.DataFrame()
        except Exception as e:
            logger.error(f"Error extracting CSV data: {e}")
            return pd.DataFrame()
    
    def extract_json(self, file_path: str) -> List[Dict[str, Any]]:
        """Extract data from JSON file."""
        try:
            logger.info(f"Extracting data from JSON: {file_path}")
            with open(file_path, 'r') as f:
                data = json.load(f)
            logger.info(f"Successfully extracted JSON data")
            return data if isinstance(data, list) else [data]
        except FileNotFoundError:
            logger.error(f"JSON file not found: {file_path}")
            return []
        except json.JSONDecodeError as e:
            logger.error(f"Invalid JSON format: {e}")
            return []
        except Exception as e:
            logger.error(f"Error extracting JSON data: {e}")
            return []
    
    def extract_database(self, connection_string: str, query: str) -> pd.DataFrame:
        """Extract data from database."""
        logger.info("Database extraction not implemented yet")
        # Placeholder for database extraction
        return pd.DataFrame()

def main():
    """Main extraction function."""
    config = {
        'csv_files': ['data/raw/sample.csv'],
        'json_files': ['data/raw/sample.json']
    }
    
    extractor = DataExtractor(config)
    
    # Example usage
    print("Data Extraction Module")
    print("=====================")
    print("Available methods:")
    print("- extract_csv(file_path)")
    print("- extract_json(file_path)")
    print("- extract_database(connection_string, query)")

if __name__ == "__main__":
    main()
EOF

echo "4.3 Add tests for extraction module:"
cat > tests/test_extract_data.py << 'EOF'
#!/usr/bin/env python3
"""
Tests for data extraction module.
"""

import unittest
import sys
import os
import tempfile
import json
import pandas as pd

# Add scripts directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts', 'etl'))

from extract_data import DataExtractor

class TestDataExtractor(unittest.TestCase):
    """Test cases for DataExtractor class."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.config = {'test': True}
        self.extractor = DataExtractor(self.config)
    
    def test_extract_csv_success(self):
        """Test successful CSV extraction."""
        # Create temporary CSV file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.csv', delete=False) as f:
            f.write("name,age,city\n")
            f.write("Alice,25,NYC\n")
            f.write("Bob,30,LA\n")
            temp_file = f.name
        
        try:
            df = self.extractor.extract_csv(temp_file)
            self.assertEqual(len(df), 2)
            self.assertIn('name', df.columns)
            self.assertIn('age', df.columns)
        finally:
            os.unlink(temp_file)
    
    def test_extract_csv_file_not_found(self):
        """Test CSV extraction with missing file."""
        df = self.extractor.extract_csv('nonexistent.csv')
        self.assertTrue(df.empty)
    
    def test_extract_json_success(self):
        """Test successful JSON extraction."""
        # Create temporary JSON file
        test_data = [{'name': 'Alice', 'age': 25}, {'name': 'Bob', 'age': 30}]
        
        with tempfile.NamedTemporaryFile(mode='w', suffix='.json', delete=False) as f:
            json.dump(test_data, f)
            temp_file = f.name
        
        try:
            data = self.extractor.extract_json(temp_file)
            self.assertEqual(len(data), 2)
            self.assertEqual(data[0]['name'], 'Alice')
        finally:
            os.unlink(temp_file)
    
    def test_extract_json_file_not_found(self):
        """Test JSON extraction with missing file."""
        data = self.extractor.extract_json('nonexistent.json')
        self.assertEqual(data, [])

if __name__ == '__main__':
    unittest.main()
EOF

echo "4.4 Commit feature development:"
git add scripts/etl/extract_data.py tests/test_extract_data.py
git commit -m "Add data extraction module with comprehensive testing

- Implement CSV and JSON extraction capabilities
- Add error handling and logging
- Include comprehensive unit tests
- Support for future database extraction"

echo "✓ Feature development committed"

echo "4.5 Push feature branch to remote:"
git push -u origin feature/data-extraction
echo "✓ Feature branch pushed to remote"

echo

# Exercise 5: Fetching and Merging Changes
echo "=== Exercise 5: Fetching and Merging Remote Changes ==="
echo "TODO: Practice fetching and integrating remote changes"
echo

echo "5.1 Switch to original repository and make changes:"
cd "../$PROJECT_NAME"

# Simulate another developer's work
git checkout -b feature/data-analysis

cat > scripts/analysis/analyze_data.py << 'EOF'
#!/usr/bin/env python3
"""
Data analysis module for statistical analysis and reporting.
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from typing import Dict, Any, List
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DataAnalyzer:
    """Perform statistical analysis on datasets."""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        logger.info("DataAnalyzer initialized")
    
    def descriptive_statistics(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Calculate descriptive statistics for numerical columns."""
        logger.info("Calculating descriptive statistics")
        
        numeric_columns = df.select_dtypes(include=[np.number]).columns
        stats = {}
        
        for col in numeric_columns:
            stats[col] = {
                'count': df[col].count(),
                'mean': df[col].mean(),
                'std': df[col].std(),
                'min': df[col].min(),
                'max': df[col].max(),
                'median': df[col].median()
            }
        
        logger.info(f"Statistics calculated for {len(numeric_columns)} numeric columns")
        return stats
    
    def data_quality_report(self, df: pd.DataFrame) -> Dict[str, Any]:
        """Generate data quality report."""
        logger.info("Generating data quality report")
        
        report = {
            'total_rows': len(df),
            'total_columns': len(df.columns),
            'missing_values': df.isnull().sum().to_dict(),
            'duplicate_rows': df.duplicated().sum(),
            'data_types': df.dtypes.to_dict()
        }
        
        # Calculate completeness percentage
        report['completeness'] = {}
        for col in df.columns:
            non_null_count = df[col].count()
            report['completeness'][col] = (non_null_count / len(df)) * 100
        
        logger.info("Data quality report generated")
        return report
    
    def correlation_analysis(self, df: pd.DataFrame) -> pd.DataFrame:
        """Perform correlation analysis on numerical columns."""
        logger.info("Performing correlation analysis")
        
        numeric_df = df.select_dtypes(include=[np.number])
        if numeric_df.empty:
            logger.warning("No numeric columns found for correlation analysis")
            return pd.DataFrame()
        
        correlation_matrix = numeric_df.corr()
        logger.info("Correlation analysis completed")
        return correlation_matrix
    
    def generate_summary_report(self, df: pd.DataFrame) -> str:
        """Generate comprehensive summary report."""
        logger.info("Generating summary report")
        
        stats = self.descriptive_statistics(df)
        quality = self.data_quality_report(df)
        
        report = []
        report.append("=" * 50)
        report.append("DATA ANALYSIS SUMMARY REPORT")
        report.append("=" * 50)
        report.append(f"Dataset Shape: {quality['total_rows']} rows × {quality['total_columns']} columns")
        report.append(f"Duplicate Rows: {quality['duplicate_rows']}")
        report.append("")
        
        report.append("COLUMN COMPLETENESS:")
        for col, completeness in quality['completeness'].items():
            report.append(f"  {col}: {completeness:.1f}%")
        report.append("")
        
        if stats:
            report.append("NUMERICAL STATISTICS:")
            for col, col_stats in stats.items():
                report.append(f"  {col}:")
                report.append(f"    Mean: {col_stats['mean']:.2f}")
                report.append(f"    Std:  {col_stats['std']:.2f}")
                report.append(f"    Min:  {col_stats['min']:.2f}")
                report.append(f"    Max:  {col_stats['max']:.2f}")
                report.append("")
        
        report.append("=" * 50)
        
        return "\n".join(report)

def main():
    """Main analysis function."""
    config = {'output_dir': 'output'}
    
    analyzer = DataAnalyzer(config)
    
    print("Data Analysis Module")
    print("===================")
    print("Available methods:")
    print("- descriptive_statistics(df)")
    print("- data_quality_report(df)")
    print("- correlation_analysis(df)")
    print("- generate_summary_report(df)")

if __name__ == "__main__":
    main()
EOF

git add scripts/analysis/analyze_data.py
git commit -m "Add comprehensive data analysis module

- Implement descriptive statistics calculation
- Add data quality reporting
- Include correlation analysis
- Generate summary reports with insights"

git push -u origin feature/data-analysis

echo "✓ Analysis feature pushed from original repository"

echo "5.2 Switch back to clone and fetch changes:"
cd "../${PROJECT_NAME}-clone"

echo "5.3 Fetch all remote changes:"
git fetch origin
echo "✓ Fetched changes from origin"

echo "5.4 View remote branches:"
git branch -r

echo "5.5 Merge main branch updates:"
git checkout main
git pull origin main
echo "✓ Main branch updated"

echo "5.6 View available remote branches:"
git branch -a

echo

# Exercise 6: Handling Remote Branch Operations
echo "=== Exercise 6: Remote Branch Operations ==="
echo "TODO: Practice advanced remote branch operations"
echo

echo "6.1 Check out remote feature branch:"
git checkout -b feature/data-analysis origin/feature/data-analysis
echo "✓ Checked out remote analysis feature branch"

echo "6.2 View both feature branches locally:"
git branch

echo "6.3 Compare feature branches:"
echo "Files in data-extraction branch:"
git checkout feature/data-extraction
find scripts tests -name "*.py" 2>/dev/null || echo "No Python files in scripts/tests yet"

echo
echo "Files in data-analysis branch:"
git checkout feature/data-analysis
find scripts tests -name "*.py" 2>/dev/null || echo "No Python files in scripts/tests yet"

echo "6.4 Merge both features into main:"
git checkout main

# Merge data extraction feature
git merge feature/data-extraction
echo "✓ Merged data extraction feature"

# Merge data analysis feature
git merge feature/data-analysis
echo "✓ Merged data analysis feature"

echo "6.5 Push merged changes back to remote:"
git push origin main
echo "✓ Pushed merged changes to remote"

echo "6.6 Clean up merged feature branches:"
git branch -d feature/data-extraction
git branch -d feature/data-analysis

# Delete remote feature branches
git push origin --delete feature/data-extraction
git push origin --delete feature/data-analysis
echo "✓ Cleaned up merged feature branches"

echo

# Exercise 7: Repository Status and Synchronization
echo "=== Exercise 7: Repository Synchronization ==="
echo "TODO: Practice keeping repositories synchronized"
echo

echo "7.1 Check synchronization status:"
git status
git log --oneline -5

echo "7.2 Verify both repositories are synchronized:"
cd "../$PROJECT_NAME"
git checkout main
git pull origin main
echo "Original repository synchronized"

cd "../${PROJECT_NAME}-clone"
git status
echo "Clone repository status checked"

echo "7.3 Create final documentation update:"
cat >> README.md << 'EOF'

## 🔄 Remote Repository Workflow

This project demonstrates Git remote repository operations:

### Workflow Steps
1. **Clone** repository from remote
2. **Create** feature branches for development
3. **Commit** changes with descriptive messages
4. **Push** feature branches to remote
5. **Fetch** and **merge** changes from other contributors
6. **Synchronize** with main branch regularly

### Remote Commands Used
- `git clone` - Copy repository from remote
- `git remote add` - Add remote repository
- `git push` - Upload changes to remote
- `git fetch` - Download changes from remote
- `git pull` - Fetch and merge in one command
- `git branch -r` - List remote branches

### Collaboration Features
- Multiple developers working on different features
- Feature branch workflow with remote synchronization
- Proper merge and cleanup procedures
- Comprehensive testing and documentation
EOF

git add README.md
git commit -m "Document remote repository workflow and collaboration process"
git push origin main

echo "✓ Documentation updated and pushed"

echo

# Exercise 8: Repository Analysis and Cleanup
echo "=== Exercise 8: Repository Analysis ==="
echo "TODO: Analyze repository state and perform cleanup"
echo

echo "8.1 Repository statistics:"
echo "Total commits: $(git rev-list --count --all)"
echo "Contributors: $(git shortlog -sn | wc -l)"
echo "Branches created: $(git reflog | grep -c "checkout: moving")"
echo "Remote repositories: $(git remote | wc -l)"

echo
echo "8.2 Remote configuration:"
git remote -v

echo
echo "8.3 Branch history:"
git log --graph --oneline --all -10

echo
echo "8.4 File tracking status:"
echo "Tracked files: $(git ls-files | wc -l)"
echo "Ignored patterns: $(wc -l < .gitignore)"

echo
echo "8.5 Repository size analysis:"
echo "Repository size: $(du -sh .git | cut -f1)"
echo "Working directory: $(du -sh --exclude=.git . | cut -f1)"

# Cleanup
cd ..

echo
echo "=== Exercise Complete ==="
echo
echo "🎉 Congratulations! You've mastered Git remote repositories."
echo
echo "What you've accomplished:"
echo "✓ Created and configured remote repositories"
echo "✓ Practiced cloning and multiple remote management"
echo "✓ Implemented collaborative development workflow"
echo "✓ Managed feature branches across remotes"
echo "✓ Synchronized changes between repositories"
echo "✓ Performed remote branch operations"
echo "✓ Maintained clean repository history"
echo "✓ Documented collaboration processes"
echo
echo "Repositories created:"
echo "• $PROJECT_NAME (original)"
echo "• ${PROJECT_NAME}-remote.git (bare remote)"
echo "• ${PROJECT_NAME}-clone (team member clone)"
echo
echo "Key skills learned:"
echo "• Remote repository setup and configuration"
echo "• Push/pull/fetch operations"
echo "• Feature branch collaboration"
echo "• Repository synchronization"
echo "• Branch cleanup and maintenance"
echo
echo "Next: Learn about pull requests and code review! 🔄"
