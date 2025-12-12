#!/bin/bash

# Day 8: Git Basics - Exercise
# Practice fundamental Git operations with a data project

echo "=== Day 8: Git Basics Exercise ==="
echo "Learning Git fundamentals through hands-on practice"
echo

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Exercise 1: Git Configuration and Setup
echo "=== Exercise 1: Git Configuration ==="
echo "TODO: Configure Git with your information"
echo

echo "1.1 Check current Git configuration:"
echo "Current Git user name: $(git config user.name || echo 'Not set')"
echo "Current Git user email: $(git config user.email || echo 'Not set')"

echo
echo "1.2 Set up Git configuration (if not already set):"
# Check if already configured
if [[ -z "$(git config user.name)" ]]; then
    echo "Setting up Git configuration..."
    git config --global user.name "Data Engineer"
    git config --global user.email "engineer@example.com"
    echo "✓ Git configured with default values"
else
    echo "✓ Git already configured"
fi

# Set other useful defaults
git config --global init.defaultBranch main
git config --global core.editor "nano"

echo "1.3 View complete Git configuration:"
git config --list | head -10

echo

# Exercise 2: Repository Initialization
echo "=== Exercise 2: Repository Initialization ==="
echo "TODO: Create and initialize a new Git repository"
echo

PROJECT_NAME="git-data-project"
echo "2.1 Creating project: $PROJECT_NAME"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

echo "2.2 Initialize Git repository:"
git init
echo "✓ Git repository initialized"

echo "2.3 Check repository status:"
git status

echo

# Exercise 3: Project Structure and .gitignore
echo "=== Exercise 3: Project Structure and .gitignore ==="
echo "TODO: Create project structure and configure .gitignore"
echo

echo "3.1 Create project directory structure:"
mkdir -p {data/{raw,processed,archive},scripts,output/{reports,charts},docs,tests}

# Create sample files
cat > README.md << 'EOF'
# Git Data Project

A sample data processing project to learn Git basics.

## Structure
- `data/` - Data files (raw, processed, archived)
- `scripts/` - Processing scripts
- `output/` - Generated reports and charts
- `docs/` - Documentation
- `tests/` - Test files

## Usage
1. Place raw data in `data/raw/`
2. Run processing scripts from `scripts/`
3. View results in `output/`
EOF

cat > scripts/process_data.py << 'EOF'
#!/usr/bin/env python3
"""
Data processing script for the Git tutorial project.
"""

def process_sales_data(input_file, output_file):
    """Process sales data and save results."""
    print(f"Processing {input_file} -> {output_file}")
    # Placeholder for actual processing
    with open(output_file, 'w') as f:
        f.write("processed_data,value\n")
        f.write("sample,123\n")

if __name__ == "__main__":
    process_sales_data("data/raw/sales.csv", "data/processed/sales_clean.csv")
EOF

cat > docs/data_dictionary.md << 'EOF'
# Data Dictionary

## Sales Data
- `id`: Unique transaction identifier
- `date`: Transaction date (YYYY-MM-DD)
- `customer_id`: Customer identifier
- `product_id`: Product identifier
- `amount`: Transaction amount
EOF

echo "✓ Project structure created"

echo "3.2 Create comprehensive .gitignore:"
cat > .gitignore << 'EOF'
# Data files - don't commit large datasets
data/raw/
data/processed/
*.csv
*.json
*.parquet
*.xlsx

# Output files - generated content
output/
reports/
charts/
*.html
*.pdf
*.png
*.jpg

# Logs
*.log
logs/

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.env
.venv

# Jupyter Notebooks checkpoints
.ipynb_checkpoints/

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Temporary files
*.tmp
*.temp
backup_*
*~

# Configuration files with secrets
config.json
secrets.json
.env.local
EOF

echo "✓ .gitignore created"

echo "3.3 Check what Git sees:"
git status

echo

# Exercise 4: First Commits
echo "=== Exercise 4: Making Your First Commits ==="
echo "TODO: Add files and make initial commits"
echo

echo "4.1 Add project structure files:"
git add README.md docs/ scripts/ .gitignore
git status

echo "4.2 Make initial commit:"
git commit -m "Initial project structure with README, docs, and scripts"
echo "✓ Initial commit made"

echo "4.3 View commit history:"
git log --oneline

echo

# Exercise 5: Working with Changes
echo "=== Exercise 5: Working with Changes ==="
echo "TODO: Make changes and practice Git workflow"
echo

echo "5.1 Create sample data files (will be ignored):"
mkdir -p data/raw data/processed
echo "id,date,customer,amount" > data/raw/sales.csv
echo "1,2023-12-01,C001,100.50" >> data/raw/sales.csv
echo "2,2023-12-01,C002,75.25" >> data/raw/sales.csv

echo "processed_id,clean_amount" > data/processed/sales_clean.csv
echo "1,100.50" >> data/processed/sales_clean.csv

echo "✓ Sample data created"

echo "5.2 Check Git status (data files should be ignored):"
git status

echo "5.3 Modify existing tracked file:"
cat >> README.md << 'EOF'

## Getting Started
1. Clone this repository
2. Install dependencies: `pip install -r requirements.txt`
3. Run data processing: `python scripts/process_data.py`
EOF

echo "✓ README.md updated"

echo "5.4 Create new tracked file:"
cat > requirements.txt << 'EOF'
pandas>=1.5.0
numpy>=1.21.0
matplotlib>=3.5.0
EOF

echo "✓ requirements.txt created"

echo "5.5 View changes:"
git status
echo
echo "Detailed diff of changes:"
git diff

echo

# Exercise 6: Staging and Committing
echo "=== Exercise 6: Staging and Committing Changes ==="
echo "TODO: Practice selective staging and committing"
echo

echo "6.1 Stage changes selectively:"
git add README.md
echo "✓ README.md staged"

echo "6.2 Check staged vs unstaged changes:"
echo "Staged changes:"
git diff --staged
echo
echo "Unstaged changes:"
git diff

echo "6.3 Stage remaining changes:"
git add requirements.txt
echo "✓ All changes staged"

echo "6.4 Commit staged changes:"
git commit -m "Add getting started instructions and requirements"
echo "✓ Changes committed"

echo "6.5 View updated history:"
git log --oneline

echo

# Exercise 7: Exploring History
echo "=== Exercise 7: Exploring Git History ==="
echo "TODO: Practice viewing and understanding Git history"
echo

echo "7.1 View detailed commit history:"
git log --graph --pretty=format:'%h -%d %s (%cr) <%an>' --abbrev-commit

echo
echo "7.2 View specific commit details:"
echo "Latest commit details:"
git show HEAD

echo
echo "7.3 Compare versions:"
echo "Changes in last commit:"
git diff HEAD~1 HEAD

echo

# Exercise 8: File Operations
echo "=== Exercise 8: Git File Operations ==="
echo "TODO: Practice Git file management"
echo

echo "8.1 Create test files:"
touch tests/test_data_processing.py
cat > tests/test_data_processing.py << 'EOF'
#!/usr/bin/env python3
"""
Tests for data processing functions.
"""

def test_process_sales_data():
    """Test sales data processing."""
    # Placeholder test
    assert True

if __name__ == "__main__":
    test_process_sales_data()
    print("All tests passed!")
EOF

echo "✓ Test file created"

echo "8.2 Add and commit test file:"
git add tests/
git commit -m "Add initial test structure"

echo "8.3 Rename a file using Git:"
git mv scripts/process_data.py scripts/data_processor.py
git status

echo "8.4 Commit the rename:"
git commit -m "Rename data processing script for clarity"

echo "8.5 View history with file tracking:"
git log --follow scripts/data_processor.py

echo

# Exercise 9: Undoing Changes
echo "=== Exercise 9: Undoing Changes ==="
echo "TODO: Practice undoing changes safely"
echo

echo "9.1 Make some changes to test undoing:"
echo "# This is a temporary change" >> README.md
echo "temporary_file.txt" > temp_file.txt

echo "9.2 Check status:"
git status

echo "9.3 Undo working directory changes:"
git restore README.md
echo "✓ README.md changes discarded"

echo "9.4 Add file to staging, then unstage:"
git add temp_file.txt
echo "File staged:"
git status

git restore --staged temp_file.txt
echo "✓ File unstaged"
git status

echo "9.5 Clean up temporary file:"
rm temp_file.txt

echo

# Exercise 10: Advanced .gitignore
echo "=== Exercise 10: Advanced .gitignore Patterns ==="
echo "TODO: Test .gitignore patterns"
echo

echo "10.1 Create files that should be ignored:"
mkdir -p output/reports logs
echo "Sample report content" > output/reports/daily_report.html
echo "Log entry 1" > logs/application.log
echo "Backup data" > backup_20231201.csv
touch .DS_Store

echo "10.2 Create files that should be tracked:"
echo "# Configuration template" > config.template.json
echo "# Important notes" > IMPORTANT.txt

echo "10.3 Check what Git ignores:"
git status
echo
echo "Checking specific files:"
git check-ignore output/reports/daily_report.html logs/application.log backup_20231201.csv .DS_Store || echo "Some files not ignored"

echo "10.4 Add and commit trackable files:"
git add config.template.json IMPORTANT.txt
git commit -m "Add configuration template and important notes"

echo

# Exercise 11: Repository Summary
echo "=== Exercise 11: Repository Summary ==="
echo "TODO: Review what we've accomplished"
echo

echo "11.1 Final repository status:"
git status

echo "11.2 Complete commit history:"
git log --oneline --graph

echo "11.3 Repository statistics:"
echo "Total commits: $(git rev-list --count HEAD)"
echo "Files tracked: $(git ls-files | wc -l)"
echo "Files ignored: $(git status --ignored --porcelain | wc -l)"

echo "11.4 Repository structure:"
find . -type f -not -path './.git/*' | sort

echo

# Cleanup and summary
cd ..

echo "=== Exercise Complete ==="
echo
echo "🎉 Congratulations! You've completed Git basics training."
echo
echo "What you've learned:"
echo "✓ Git repository initialization and configuration"
echo "✓ Creating and managing .gitignore files"
echo "✓ Adding files to staging area"
echo "✓ Making commits with meaningful messages"
echo "✓ Viewing Git history and diffs"
echo "✓ File operations (add, remove, rename)"
echo "✓ Undoing changes safely"
echo "✓ Working with ignored files"
echo
echo "Your Git repository is ready at: $PROJECT_NAME"
echo
echo "Next steps:"
echo "1. Explore the repository: cd $PROJECT_NAME"
echo "2. Try more Git commands: git log, git diff, git show"
echo "3. Practice making more commits as you work"
echo "4. Complete the quiz to test your knowledge"
echo
echo "Tomorrow: Learn about branching and merging! 🌿"
