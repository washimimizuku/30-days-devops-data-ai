#!/bin/bash

# Day 9: Branching and Merging - Exercise
# Practice Git branching workflows with a data project

echo "=== Day 9: Branching and Merging Exercise ==="
echo "Learning Git branching through hands-on data project development"
echo

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Exercise 1: Project Setup and Initial Branch
echo "=== Exercise 1: Project Setup ==="
echo "TODO: Set up a data project with proper Git structure"
echo

PROJECT_NAME="branching-data-project"
echo "1.1 Creating project: $PROJECT_NAME"

# Create and initialize project
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"
git init

# Configure Git
git config user.name "Data Engineer"
git config user.email "engineer@example.com"

echo "1.2 Create initial project structure:"
mkdir -p {data/{raw,processed},scripts,tests,docs,output}

# Create initial files
cat > README.md << 'EOF'
# Data Processing Project

A project to demonstrate Git branching workflows in data engineering.

## Features
- Data extraction and cleaning
- Statistical analysis
- Report generation
- Data validation

## Branches
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature development
- `hotfix/*`: Critical fixes
EOF

cat > .gitignore << 'EOF'
# Data files
data/raw/
data/processed/
*.csv
*.json

# Output
output/
*.html
*.pdf

# Python
__pycache__/
*.pyc
.env

# Logs
*.log
EOF

cat > scripts/main.py << 'EOF'
#!/usr/bin/env python3
"""
Main data processing pipeline.
"""

def main():
    print("Data processing pipeline v1.0")
    print("Ready for feature development!")

if __name__ == "__main__":
    main()
EOF

echo "1.3 Make initial commit:"
git add .
git commit -m "Initial project setup with basic structure"

echo "✓ Project initialized with main branch"
git log --oneline

echo

# Exercise 2: Basic Branching
echo "=== Exercise 2: Basic Branching Operations ==="
echo "TODO: Practice creating and switching branches"
echo

echo "2.1 View current branches:"
git branch

echo "2.2 Create and switch to development branch:"
git checkout -b develop
echo "✓ Created and switched to develop branch"

echo "2.3 Create feature branch for data extraction:"
git checkout -b feature/data-extraction
echo "✓ Created feature/data-extraction branch"

echo "2.4 View all branches:"
git branch

echo "2.5 Check current branch:"
echo "Current branch: $(git branch --show-current)"

echo

# Exercise 3: Feature Development
echo "=== Exercise 3: Feature Development Workflow ==="
echo "TODO: Develop a feature using proper Git workflow"
echo

echo "3.1 Develop data extraction feature:"
cat > scripts/extract.py << 'EOF'
#!/usr/bin/env python3
"""
Data extraction module.
"""

import csv
import json

def extract_csv(file_path):
    """Extract data from CSV file."""
    print(f"Extracting data from {file_path}")
    data = []
    try:
        with open(file_path, 'r') as f:
            reader = csv.DictReader(f)
            data = list(reader)
        print(f"Extracted {len(data)} records")
        return data
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return []

def extract_json(file_path):
    """Extract data from JSON file."""
    print(f"Extracting data from {file_path}")
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
        print(f"Extracted JSON data with {len(data)} items")
        return data
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return {}

if __name__ == "__main__":
    # Test extraction
    csv_data = extract_csv("data/raw/sample.csv")
    json_data = extract_json("data/raw/sample.json")
EOF

echo "3.2 Add and commit extraction module:"
git add scripts/extract.py
git commit -m "Add data extraction module with CSV and JSON support"

echo "3.3 Add tests for extraction module:"
cat > tests/test_extract.py << 'EOF'
#!/usr/bin/env python3
"""
Tests for data extraction module.
"""

import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from extract import extract_csv, extract_json

def test_extract_csv():
    """Test CSV extraction."""
    # This would normally use actual test data
    print("Testing CSV extraction...")
    result = extract_csv("nonexistent.csv")
    assert result == []
    print("✓ CSV extraction test passed")

def test_extract_json():
    """Test JSON extraction."""
    print("Testing JSON extraction...")
    result = extract_json("nonexistent.json")
    assert result == {}
    print("✓ JSON extraction test passed")

if __name__ == "__main__":
    test_extract_csv()
    test_extract_json()
    print("All extraction tests passed!")
EOF

git add tests/test_extract.py
git commit -m "Add unit tests for data extraction module"

echo "3.4 Update main pipeline to use extraction:"
cat > scripts/main.py << 'EOF'
#!/usr/bin/env python3
"""
Main data processing pipeline.
"""

from extract import extract_csv, extract_json

def main():
    print("Data processing pipeline v1.1")
    print("Features:")
    print("- Data extraction (CSV, JSON)")
    
    # Example usage
    print("\nTesting extraction capabilities...")
    csv_data = extract_csv("data/raw/sample.csv")
    json_data = extract_json("data/raw/sample.json")

if __name__ == "__main__":
    main()
EOF

git add scripts/main.py
git commit -m "Integrate data extraction into main pipeline"

echo "✓ Feature development completed"
git log --oneline

echo

# Exercise 4: Merging Features
echo "=== Exercise 4: Merging Feature Branch ==="
echo "TODO: Merge feature branch back to develop"
echo

echo "4.1 Switch to develop branch:"
git checkout develop
echo "Current branch: $(git branch --show-current)"

echo "4.2 Merge feature branch:"
git merge feature/data-extraction
echo "✓ Feature merged into develop branch"

echo "4.3 View merge history:"
git log --graph --oneline

echo "4.4 Clean up feature branch:"
git branch -d feature/data-extraction
echo "✓ Feature branch deleted"

echo "4.5 View remaining branches:"
git branch

echo

# Exercise 5: Parallel Development
echo "=== Exercise 5: Parallel Feature Development ==="
echo "TODO: Simulate multiple developers working on different features"
echo

echo "5.1 Create data cleaning feature branch:"
git checkout -b feature/data-cleaning

cat > scripts/clean.py << 'EOF'
#!/usr/bin/env python3
"""
Data cleaning module.
"""

def remove_duplicates(data):
    """Remove duplicate records from data."""
    if isinstance(data, list):
        seen = set()
        cleaned = []
        for item in data:
            item_str = str(item)
            if item_str not in seen:
                seen.add(item_str)
                cleaned.append(item)
        print(f"Removed {len(data) - len(cleaned)} duplicates")
        return cleaned
    return data

def handle_missing_values(data, strategy='remove'):
    """Handle missing values in data."""
    if isinstance(data, list):
        if strategy == 'remove':
            cleaned = [item for item in data if all(v for v in item.values())]
            print(f"Removed {len(data) - len(cleaned)} records with missing values")
            return cleaned
    return data

def validate_data_types(data):
    """Validate and convert data types."""
    print("Validating data types...")
    # Placeholder for data type validation
    return data

if __name__ == "__main__":
    print("Data cleaning module loaded")
EOF

git add scripts/clean.py
git commit -m "Add data cleaning module with duplicate removal and validation"

echo "5.2 Switch to develop and create analysis feature:"
git checkout develop
git checkout -b feature/data-analysis

cat > scripts/analyze.py << 'EOF'
#!/usr/bin/env python3
"""
Data analysis module.
"""

def calculate_statistics(data):
    """Calculate basic statistics for numerical data."""
    if not data:
        return {}
    
    stats = {
        'count': len(data),
        'sample_data': data[:3] if len(data) >= 3 else data
    }
    
    print(f"Calculated statistics for {stats['count']} records")
    return stats

def generate_summary(data):
    """Generate data summary report."""
    stats = calculate_statistics(data)
    
    summary = f"""
Data Summary Report
==================
Total Records: {stats.get('count', 0)}
Sample Data: {stats.get('sample_data', [])}
"""
    
    print("Generated data summary")
    return summary

def detect_anomalies(data):
    """Detect anomalies in data."""
    print("Scanning for data anomalies...")
    # Placeholder for anomaly detection
    anomalies = []
    print(f"Found {len(anomalies)} anomalies")
    return anomalies

if __name__ == "__main__":
    print("Data analysis module loaded")
EOF

git add scripts/analyze.py
git commit -m "Add data analysis module with statistics and anomaly detection"

echo "✓ Two parallel features developed"

echo

# Exercise 6: Merge Conflicts
echo "=== Exercise 6: Handling Merge Conflicts ==="
echo "TODO: Create and resolve merge conflicts"
echo

echo "6.1 Modify main.py in analysis branch:"
cat > scripts/main.py << 'EOF'
#!/usr/bin/env python3
"""
Main data processing pipeline.
"""

from extract import extract_csv, extract_json
from analyze import calculate_statistics, generate_summary

def main():
    print("Data processing pipeline v2.0")
    print("Features:")
    print("- Data extraction (CSV, JSON)")
    print("- Data analysis and statistics")
    
    # Example usage
    print("\nRunning analysis pipeline...")
    csv_data = extract_csv("data/raw/sample.csv")
    stats = calculate_statistics(csv_data)
    summary = generate_summary(csv_data)
    print(summary)

if __name__ == "__main__":
    main()
EOF

git add scripts/main.py
git commit -m "Integrate data analysis into main pipeline"

echo "6.2 Switch to cleaning branch and modify main.py differently:"
git checkout feature/data-cleaning

cat > scripts/main.py << 'EOF'
#!/usr/bin/env python3
"""
Main data processing pipeline.
"""

from extract import extract_csv, extract_json
from clean import remove_duplicates, handle_missing_values

def main():
    print("Data processing pipeline v2.0")
    print("Features:")
    print("- Data extraction (CSV, JSON)")
    print("- Data cleaning and validation")
    
    # Example usage
    print("\nRunning cleaning pipeline...")
    csv_data = extract_csv("data/raw/sample.csv")
    cleaned_data = remove_duplicates(csv_data)
    validated_data = handle_missing_values(cleaned_data)
    print(f"Processed {len(validated_data)} clean records")

if __name__ == "__main__":
    main()
EOF

git add scripts/main.py
git commit -m "Integrate data cleaning into main pipeline"

echo "6.3 Merge cleaning feature into develop:"
git checkout develop
git merge feature/data-cleaning
echo "✓ Cleaning feature merged"

echo "6.4 Attempt to merge analysis feature (will create conflict):"
echo "Merging analysis feature..."
if git merge feature/data-analysis; then
    echo "✓ Merge completed without conflicts"
else
    echo "⚠️  Merge conflict detected in scripts/main.py"
    
    echo "6.5 View conflict:"
    echo "Conflict in scripts/main.py:"
    grep -A 10 -B 2 "<<<<<<< HEAD" scripts/main.py || echo "Conflict markers not found"
    
    echo "6.6 Resolve conflict by combining both features:"
    cat > scripts/main.py << 'EOF'
#!/usr/bin/env python3
"""
Main data processing pipeline.
"""

from extract import extract_csv, extract_json
from clean import remove_duplicates, handle_missing_values
from analyze import calculate_statistics, generate_summary

def main():
    print("Data processing pipeline v2.0")
    print("Features:")
    print("- Data extraction (CSV, JSON)")
    print("- Data cleaning and validation")
    print("- Data analysis and statistics")
    
    # Example usage
    print("\nRunning complete pipeline...")
    
    # Extract data
    csv_data = extract_csv("data/raw/sample.csv")
    
    # Clean data
    cleaned_data = remove_duplicates(csv_data)
    validated_data = handle_missing_values(cleaned_data)
    
    # Analyze data
    stats = calculate_statistics(validated_data)
    summary = generate_summary(validated_data)
    
    print(f"Pipeline completed: {len(validated_data)} records processed")
    print(summary)

if __name__ == "__main__":
    main()
EOF
    
    echo "6.7 Mark conflict as resolved and complete merge:"
    git add scripts/main.py
    git commit -m "Merge feature/data-analysis with conflict resolution

Combined data cleaning and analysis features into unified pipeline"
    
    echo "✓ Merge conflict resolved"
fi

echo

# Exercise 7: Advanced Branching
echo "=== Exercise 7: Advanced Branching Techniques ==="
echo "TODO: Practice advanced Git branching operations"
echo

echo "7.1 View branch history:"
git log --graph --oneline --all

echo "7.2 Create release branch:"
git checkout -b release/v1.0.0

echo "7.3 Prepare release documentation:"
cat > docs/CHANGELOG.md << 'EOF'
# Changelog

## Version 1.0.0 (2023-12-12)

### Features
- Data extraction from CSV and JSON files
- Data cleaning with duplicate removal and missing value handling
- Data analysis with statistics and anomaly detection
- Integrated processing pipeline

### Technical Details
- Modular architecture with separate extraction, cleaning, and analysis modules
- Comprehensive test coverage
- Error handling and validation

### Usage
```bash
python scripts/main.py
```
EOF

cat > docs/README_v1.0.md << 'EOF'
# Data Processing Pipeline v1.0.0

## Installation
1. Clone the repository
2. Run: `python scripts/main.py`

## Modules
- `extract.py`: Data extraction utilities
- `clean.py`: Data cleaning and validation
- `analyze.py`: Statistical analysis and reporting
- `main.py`: Integrated pipeline

## Testing
Run tests with: `python tests/test_extract.py`
EOF

git add docs/
git commit -m "Add release documentation for v1.0.0"

echo "7.4 Merge release to main:"
git checkout main
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0"

echo "7.5 Merge release back to develop:"
git checkout develop
git merge --no-ff release/v1.0.0

echo "7.6 Clean up release branch:"
git branch -d release/v1.0.0

echo "✓ Release workflow completed"

echo

# Exercise 8: Hotfix Workflow
echo "=== Exercise 8: Hotfix Workflow ==="
echo "TODO: Practice hotfix workflow for critical bugs"
echo

echo "8.1 Simulate critical bug discovery in main:"
git checkout main
git checkout -b hotfix/fix-extraction-error

echo "8.2 Fix critical bug:"
cat > scripts/extract.py << 'EOF'
#!/usr/bin/env python3
"""
Data extraction module.
"""

import csv
import json

def extract_csv(file_path):
    """Extract data from CSV file."""
    print(f"Extracting data from {file_path}")
    data = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:  # Fix: Add encoding
            reader = csv.DictReader(f)
            data = list(reader)
        print(f"Extracted {len(data)} records")
        return data
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return []
    except UnicodeDecodeError:  # Fix: Handle encoding errors
        print(f"Encoding error in file: {file_path}")
        return []

def extract_json(file_path):
    """Extract data from JSON file."""
    print(f"Extracting data from {file_path}")
    try:
        with open(file_path, 'r', encoding='utf-8') as f:  # Fix: Add encoding
            data = json.load(f)
        print(f"Extracted JSON data with {len(data)} items")
        return data
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return {}
    except json.JSONDecodeError:  # Fix: Handle JSON errors
        print(f"Invalid JSON in file: {file_path}")
        return {}

if __name__ == "__main__":
    # Test extraction
    csv_data = extract_csv("data/raw/sample.csv")
    json_data = extract_json("data/raw/sample.json")
EOF

git add scripts/extract.py
git commit -m "Fix encoding and error handling in data extraction"

echo "8.3 Merge hotfix to main:"
git checkout main
git merge --no-ff hotfix/fix-extraction-error
git tag -a v1.0.1 -m "Hotfix version 1.0.1 - Fix extraction encoding"

echo "8.4 Merge hotfix to develop:"
git checkout develop
git merge --no-ff hotfix/fix-extraction-error

echo "8.5 Clean up hotfix branch:"
git branch -d hotfix/fix-extraction-error

echo "✓ Hotfix workflow completed"

echo

# Exercise 9: Branch Analysis
echo "=== Exercise 9: Branch Analysis and Cleanup ==="
echo "TODO: Analyze branch history and clean up"
echo

echo "9.1 View complete branch history:"
git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all

echo
echo "9.2 View all tags:"
git tag

echo
echo "9.3 Show branch relationships:"
git show-branch --all

echo
echo "9.4 Clean up merged feature branches:"
git branch --merged develop | grep -v "main\|develop" | xargs -r git branch -d

echo "9.5 Final branch status:"
git branch -a

echo
echo "9.6 Repository statistics:"
echo "Total commits: $(git rev-list --count --all)"
echo "Total branches created: $(git reflog | grep -c "checkout: moving")"
echo "Current branches: $(git branch | wc -l)"
echo "Tags: $(git tag | wc -l)"

# Cleanup
cd ..

echo
echo "=== Exercise Complete ==="
echo
echo "🎉 Congratulations! You've mastered Git branching and merging."
echo
echo "What you've accomplished:"
echo "✓ Created and managed multiple branches"
echo "✓ Developed features in parallel"
echo "✓ Merged branches with different strategies"
echo "✓ Resolved merge conflicts"
echo "✓ Implemented release workflow"
echo "✓ Handled hotfix workflow"
echo "✓ Used proper branch naming conventions"
echo "✓ Maintained clean Git history"
echo
echo "Your branching project is ready at: $PROJECT_NAME"
echo
echo "Key workflows learned:"
echo "• Feature branch workflow"
echo "• Release branch workflow"
echo "• Hotfix workflow"
echo "• Conflict resolution"
echo "• Branch cleanup and maintenance"
echo
echo "Next: Learn about remote repositories and collaboration! 🌐"
