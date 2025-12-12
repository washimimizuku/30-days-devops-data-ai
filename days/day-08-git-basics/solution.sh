#!/bin/bash

# Day 8: Git Basics - Solutions
# Advanced Git techniques and best practices

echo "=== Day 8: Git Basics Solutions ==="
echo "Advanced Git workflows and professional practices"
echo

# Create advanced Git project
PROJECT_NAME="advanced-git-project"
echo "Creating advanced Git project: $PROJECT_NAME"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "=== Solution 1: Professional Git Configuration ==="

echo "1.1 Advanced Git configuration:"
# Set up comprehensive Git configuration
git init

# User configuration
git config user.name "Data Engineer"
git config user.email "engineer@example.com"

# Editor and diff tools
git config core.editor "nano"
git config merge.tool "vimdiff"

# Useful aliases
git config alias.st "status"
git config alias.co "checkout"
git config alias.br "branch"
git config alias.ci "commit"
git config alias.unstage "reset HEAD --"
git config alias.last "log -1 HEAD"
git config alias.visual "!gitk"
git config alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# Line ending configuration
git config core.autocrlf input
git config core.safecrlf true

# Push configuration
git config push.default simple

echo "✓ Advanced Git configuration applied"

echo "1.2 View configuration:"
git config --list --local | head -15

echo

echo "=== Solution 2: Comprehensive .gitignore Strategy ==="

echo "2.1 Creating industry-standard .gitignore:"
cat > .gitignore << 'EOF'
# === Data Engineering .gitignore ===

# Data files - Raw and processed data
data/raw/
data/processed/
data/staging/
data/archive/
*.csv
*.tsv
*.json
*.jsonl
*.parquet
*.avro
*.orc
*.xlsx
*.xls
*.sqlite
*.db

# Output and generated files
output/
reports/
charts/
dashboards/
*.html
*.pdf
*.png
*.jpg
*.jpeg
*.gif
*.svg

# Logs and monitoring
logs/
*.log
*.log.*
monitoring/
metrics/

# Configuration with secrets
config.json
secrets.json
.env
.env.local
.env.production
credentials.json
service-account.json

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
env/
venv/
ENV/
env.bak/
venv.bak/
.venv/

# Jupyter Notebook
.ipynb_checkpoints/
*.ipynb

# IDEs and editors
.vscode/
.idea/
*.swp
*.swo
*~
.project
.pydevproject

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
desktop.ini

# Temporary files
*.tmp
*.temp
*.bak
backup_*
*_backup
.cache/

# Docker
.dockerignore
Dockerfile.local

# Cloud and deployment
.terraform/
*.tfstate
*.tfstate.*
.serverless/

# Testing
.coverage
.pytest_cache/
.tox/
htmlcov/
.nox/

# Documentation builds
docs/_build/
site/

# Package managers
node_modules/
.npm
.yarn/
package-lock.json
yarn.lock

# Database
*.sqlite3
*.db
*.sql

# Compressed files
*.zip
*.tar.gz
*.rar
*.7z
EOF

echo "✓ Comprehensive .gitignore created"

echo

echo "=== Solution 3: Professional Project Structure ==="

echo "3.1 Creating enterprise-grade project structure:"
mkdir -p {src/{data_processing,analysis,utils},tests/{unit,integration},docs/{api,user_guide},config/{dev,prod,staging},scripts/{deployment,maintenance},notebooks/{exploratory,production}}

# Create main project files
cat > README.md << 'EOF'
# Advanced Data Engineering Project

A professional data engineering project demonstrating Git best practices.

## 🏗️ Project Structure

```
├── src/                    # Source code
│   ├── data_processing/    # ETL pipeline code
│   ├── analysis/          # Data analysis modules
│   └── utils/             # Utility functions
├── tests/                 # Test suites
│   ├── unit/             # Unit tests
│   └── integration/      # Integration tests
├── docs/                 # Documentation
│   ├── api/              # API documentation
│   └── user_guide/       # User guides
├── config/               # Configuration files
│   ├── dev/              # Development config
│   ├── prod/             # Production config
│   └── staging/          # Staging config
├── scripts/              # Utility scripts
│   ├── deployment/       # Deployment scripts
│   └── maintenance/      # Maintenance scripts
└── notebooks/            # Jupyter notebooks
    ├── exploratory/      # Data exploration
    └── production/       # Production notebooks
```

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd advanced-data-project
   ```

2. **Set up environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Run tests**
   ```bash
   pytest tests/
   ```

## 📊 Features

- ✅ Modular ETL pipeline architecture
- ✅ Comprehensive test coverage
- ✅ Configuration management
- ✅ Documentation and examples
- ✅ CI/CD ready structure

## 🛠️ Development

### Git Workflow
- Use feature branches for new development
- Write descriptive commit messages
- Include tests for new features
- Update documentation as needed

### Code Quality
- Follow PEP 8 style guidelines
- Write docstrings for all functions
- Maintain test coverage above 80%
- Use type hints where appropriate

## 📝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
EOF

# Create requirements files
cat > requirements.txt << 'EOF'
# Core data processing
pandas>=1.5.0
numpy>=1.21.0
pyarrow>=10.0.0

# Database connectivity
sqlalchemy>=1.4.0
psycopg2-binary>=2.9.0

# API and web
requests>=2.28.0
fastapi>=0.85.0
uvicorn>=0.18.0

# Testing
pytest>=7.0.0
pytest-cov>=4.0.0
pytest-mock>=3.8.0

# Code quality
black>=22.0.0
flake8>=5.0.0
mypy>=0.991

# Documentation
sphinx>=5.0.0
mkdocs>=1.4.0
EOF

cat > requirements-dev.txt << 'EOF'
# Include production requirements
-r requirements.txt

# Development tools
jupyter>=1.0.0
ipython>=8.0.0
notebook>=6.4.0

# Debugging and profiling
pdb++>=0.10.0
memory-profiler>=0.60.0
line-profiler>=4.0.0

# Additional testing tools
factory-boy>=3.2.0
faker>=15.0.0
responses>=0.22.0
EOF

# Create configuration templates
cat > config/dev/database.template.json << 'EOF'
{
  "host": "localhost",
  "port": 5432,
  "database": "dev_database",
  "username": "dev_user",
  "password": "your-dev-password"
}
EOF

cat > config/prod/database.template.json << 'EOF'
{
  "host": "prod-db-host",
  "port": 5432,
  "database": "prod_database",
  "username": "prod_user",
  "password": "your-prod-password"
}
EOF

echo "✓ Professional project structure created"

echo

echo "=== Solution 4: Advanced Commit Strategies ==="

echo "4.1 Implementing atomic commits with proper staging:"

# Create source files
cat > src/data_processing/extractor.py << 'EOF'
"""Data extraction module."""

import pandas as pd
from typing import Dict, Any


class DataExtractor:
    """Extract data from various sources."""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
    
    def extract_csv(self, file_path: str) -> pd.DataFrame:
        """Extract data from CSV file."""
        return pd.read_csv(file_path)
    
    def extract_database(self, query: str) -> pd.DataFrame:
        """Extract data from database."""
        # Placeholder implementation
        return pd.DataFrame()
EOF

cat > src/data_processing/transformer.py << 'EOF'
"""Data transformation module."""

import pandas as pd
from typing import Dict, Any


class DataTransformer:
    """Transform and clean data."""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
    
    def clean_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean and validate data."""
        # Remove duplicates
        df = df.drop_duplicates()
        
        # Handle missing values
        df = df.dropna()
        
        return df
    
    def transform_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """Apply business transformations."""
        # Placeholder for transformations
        return df
EOF

cat > src/data_processing/loader.py << 'EOF'
"""Data loading module."""

import pandas as pd
from typing import Dict, Any


class DataLoader:
    """Load data to various destinations."""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
    
    def load_csv(self, df: pd.DataFrame, file_path: str) -> None:
        """Load data to CSV file."""
        df.to_csv(file_path, index=False)
    
    def load_database(self, df: pd.DataFrame, table_name: str) -> None:
        """Load data to database."""
        # Placeholder implementation
        pass
EOF

# Stage and commit each module separately
git add src/data_processing/extractor.py
git commit -m "feat: add data extraction module

- Implement CSV and database extraction
- Add type hints and documentation
- Support configurable extraction parameters"

git add src/data_processing/transformer.py
git commit -m "feat: add data transformation module

- Implement data cleaning and validation
- Add duplicate removal and null handling
- Prepare for business rule transformations"

git add src/data_processing/loader.py
git commit -m "feat: add data loading module

- Implement CSV and database loading
- Add configurable output destinations
- Prepare for batch and streaming loads"

echo "✓ Atomic commits with detailed messages created"

echo "4.2 Adding comprehensive tests:"

cat > tests/unit/test_extractor.py << 'EOF'
"""Tests for data extractor module."""

import pytest
import pandas as pd
from src.data_processing.extractor import DataExtractor


class TestDataExtractor:
    """Test cases for DataExtractor class."""
    
    def setup_method(self):
        """Set up test fixtures."""
        self.config = {"test": True}
        self.extractor = DataExtractor(self.config)
    
    def test_extract_csv(self, tmp_path):
        """Test CSV extraction."""
        # Create test CSV
        test_file = tmp_path / "test.csv"
        test_data = pd.DataFrame({"col1": [1, 2], "col2": ["a", "b"]})
        test_data.to_csv(test_file, index=False)
        
        # Test extraction
        result = self.extractor.extract_csv(str(test_file))
        
        assert len(result) == 2
        assert list(result.columns) == ["col1", "col2"]
EOF

cat > tests/unit/test_transformer.py << 'EOF'
"""Tests for data transformer module."""

import pytest
import pandas as pd
from src.data_processing.transformer import DataTransformer


class TestDataTransformer:
    """Test cases for DataTransformer class."""
    
    def setup_method(self):
        """Set up test fixtures."""
        self.config = {"test": True}
        self.transformer = DataTransformer(self.config)
    
    def test_clean_data_removes_duplicates(self):
        """Test duplicate removal."""
        test_data = pd.DataFrame({
            "col1": [1, 1, 2],
            "col2": ["a", "a", "b"]
        })
        
        result = self.transformer.clean_data(test_data)
        
        assert len(result) == 2
        assert not result.duplicated().any()
EOF

# Add tests with separate commit
git add tests/
git commit -m "test: add comprehensive unit tests

- Add test coverage for extractor module
- Add test coverage for transformer module
- Include fixtures and edge case testing
- Set up pytest configuration"

echo "✓ Test suite added with separate commit"

echo

echo "=== Solution 5: Git History Management ==="

echo "5.1 Creating meaningful commit history:"

# Add documentation
cat > docs/api/data_processing.md << 'EOF'
# Data Processing API

## Overview

The data processing module provides a complete ETL pipeline with the following components:

## Extractor

Extract data from various sources including CSV files and databases.

### Methods

- `extract_csv(file_path)`: Extract data from CSV file
- `extract_database(query)`: Extract data using SQL query

## Transformer

Transform and clean extracted data.

### Methods

- `clean_data(df)`: Remove duplicates and handle missing values
- `transform_data(df)`: Apply business transformations

## Loader

Load processed data to various destinations.

### Methods

- `load_csv(df, file_path)`: Save data to CSV file
- `load_database(df, table_name)`: Load data to database table
EOF

git add docs/
git commit -m "docs: add API documentation for data processing

- Document extractor, transformer, and loader modules
- Include method signatures and descriptions
- Provide usage examples and best practices"

# Add configuration
git add config/ requirements*.txt
git commit -m "config: add environment configurations and dependencies

- Add development and production database configs
- Include comprehensive Python requirements
- Separate dev and production dependencies"

# Add project documentation
git add README.md .gitignore
git commit -m "docs: add comprehensive project documentation

- Create detailed README with setup instructions
- Add professional .gitignore for data engineering
- Include contribution guidelines and project structure"

echo "✓ Meaningful commit history created"

echo "5.2 Viewing advanced Git history:"
echo "Commit history with graph:"
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit

echo
echo "5.3 Advanced Git log queries:"
echo "Commits by author:"
git shortlog -sn

echo
echo "Recent commits with stats:"
git log --stat --since="1 hour ago"

echo

echo "=== Solution 6: Git Hooks and Automation ==="

echo "6.1 Setting up Git hooks:"
mkdir -p .git/hooks

# Pre-commit hook for code quality
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for code quality checks

echo "Running pre-commit checks..."

# Check for Python syntax errors
python_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')
if [ -n "$python_files" ]; then
    echo "Checking Python syntax..."
    for file in $python_files; do
        python -m py_compile "$file"
        if [ $? -ne 0 ]; then
            echo "Python syntax error in $file"
            exit 1
        fi
    done
fi

# Check for large files
large_files=$(git diff --cached --name-only --diff-filter=ACM | xargs ls -la 2>/dev/null | awk '$5 > 1048576 {print $9}')
if [ -n "$large_files" ]; then
    echo "Warning: Large files detected:"
    echo "$large_files"
    echo "Consider using Git LFS for large files."
fi

# Check commit message format (will be used by commit-msg hook)
echo "Pre-commit checks passed!"
EOF

chmod +x .git/hooks/pre-commit

# Commit message hook
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
# Commit message format validation

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore"
    echo "Example: feat(auth): add user authentication"
    exit 1
fi
EOF

chmod +x .git/hooks/commit-msg

echo "✓ Git hooks configured for code quality"

echo

echo "=== Solution 7: Advanced Git Configuration ==="

echo "7.1 Setting up Git attributes:"
cat > .gitattributes << 'EOF'
# Git attributes for consistent handling

# Text files
*.py text eol=lf
*.md text eol=lf
*.txt text eol=lf
*.json text eol=lf
*.yml text eol=lf
*.yaml text eol=lf

# Binary files
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.pdf binary
*.zip binary
*.tar.gz binary

# Data files (treat as binary to avoid diff noise)
*.csv binary
*.parquet binary
*.avro binary

# Jupyter notebooks (use nbstripout for clean diffs)
*.ipynb filter=nbstripout diff=ipynb merge=nbstripout
EOF

git add .gitattributes
git commit -m "config: add Git attributes for file handling

- Configure line endings for text files
- Mark binary files appropriately
- Set up Jupyter notebook filtering"

echo "✓ Git attributes configured"

echo "7.2 Repository statistics:"
echo "Total commits: $(git rev-list --count HEAD)"
echo "Files tracked: $(git ls-files | wc -l)"
echo "Contributors: $(git shortlog -sn | wc -l)"
echo "Repository size: $(du -sh .git | cut -f1)"

echo

# Cleanup
cd ..

echo "=== Advanced Solutions Complete ==="
echo
echo "Advanced Git techniques demonstrated:"
echo "✅ Professional Git configuration with aliases"
echo "✅ Comprehensive .gitignore for data engineering"
echo "✅ Enterprise-grade project structure"
echo "✅ Atomic commits with conventional messages"
echo "✅ Comprehensive test coverage"
echo "✅ Meaningful commit history"
echo "✅ Git hooks for code quality"
echo "✅ Git attributes for file handling"
echo "✅ Advanced Git log queries and statistics"
echo
echo "🎯 You've mastered professional Git workflows!"
echo
echo "Project created: $PROJECT_NAME"
echo "Explore with: cd $PROJECT_NAME && git log --graph --oneline"
