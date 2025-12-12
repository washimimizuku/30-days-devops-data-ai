# Day 8: Git Basics

**Duration**: 1 hour  
**Prerequisites**: Day 7 - Mini Project completed

## Learning Objectives

By the end of this lesson, you will:
- Understand Git concepts: repository, commit, staging area
- Initialize and configure Git repositories
- Track changes with add, commit, and status
- View project history with log and diff
- Create and manage .gitignore files
- Navigate Git history effectively

## Core Concepts

### 1. What is Git?

Git is a distributed version control system that tracks changes in files and coordinates work among multiple people.

**Key Benefits:**
- Track every change to your code
- Collaborate with others safely
- Revert to previous versions
- Branch and merge different features
- Backup and synchronize across machines

### 2. Git Repository Structure

```
project/
├── .git/           # Git metadata (hidden)
├── file1.py        # Working directory
├── file2.txt       # Working directory
└── .gitignore      # Files to ignore
```

**Three Areas:**
- **Working Directory**: Your actual files
- **Staging Area**: Files prepared for commit
- **Repository**: Committed snapshots (.git folder)

### 3. Basic Git Workflow

```
Working Directory → Staging Area → Repository
     (edit)      →    (add)     →   (commit)
```

## Essential Commands

### Repository Setup

```bash
# Initialize new repository
git init

# Clone existing repository
git clone https://github.com/user/repo.git
git clone https://github.com/user/repo.git my-folder

# Check repository status
git status
```

### Configuration

```bash
# Set global user information
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# View configuration
git config --list
git config user.name
```

### Tracking Changes

```bash
# Add files to staging area
git add file.txt                # Add specific file
git add .                       # Add all files in current directory
git add *.py                    # Add all Python files
git add -A                      # Add all changes (including deletions)

# Check what's staged
git status
git diff --staged               # See staged changes

# Commit changes
git commit -m "Add data processing script"
git commit -m "Fix bug in validation logic"

# Add and commit in one step (tracked files only)
git commit -am "Update documentation"
```

### Viewing History

```bash
# View commit history
git log                         # Full log
git log --oneline              # Compact view
git log --graph --oneline      # Visual branch structure
git log -5                     # Last 5 commits
git log --since="2 days ago"   # Recent commits

# View specific commit
git show <commit-hash>
git show HEAD                  # Latest commit
git show HEAD~1                # Previous commit

# View changes
git diff                       # Working directory vs staging
git diff --staged              # Staging vs last commit
git diff HEAD~1                # Working directory vs previous commit
```

### File Management

```bash
# Remove files
git rm file.txt                # Remove and stage deletion
git rm --cached file.txt       # Remove from Git but keep file

# Move/rename files
git mv old-name.txt new-name.txt

# Restore files
git restore file.txt           # Discard working directory changes
git restore --staged file.txt  # Unstage file
git checkout HEAD -- file.txt  # Restore from last commit
```

## .gitignore Patterns

Create a `.gitignore` file to exclude files from version control:

```gitignore
# Data files
*.csv
*.json
data/raw/
data/processed/

# Logs
*.log
logs/

# OS files
.DS_Store
Thumbs.db

# Editor files
.vscode/
*.swp
*.swo

# Python
__pycache__/
*.pyc
*.pyo
.env
venv/

# Temporary files
*.tmp
*.temp
backup_*

# Output files
output/
reports/
*.pdf
*.html
```

### .gitignore Rules

```bash
# Patterns
*.txt           # All .txt files
!important.txt  # Exception: keep this .txt file
temp/           # Entire temp directory
/config.json    # Only config.json in root
**/logs         # logs directory anywhere
*.log           # All .log files anywhere

# Check if file is ignored
git check-ignore file.txt
git status --ignored
```

## Data Engineering Examples

### Setting Up a Data Project

```bash
# Initialize repository
mkdir data-analysis-project
cd data-analysis-project
git init

# Create project structure
mkdir -p {data/{raw,processed},scripts,output,docs}
touch README.md scripts/process_data.py

# Create .gitignore for data project
cat > .gitignore << EOF
# Data files
data/raw/
data/processed/
*.csv
*.json
*.parquet

# Output
output/
reports/
*.html
*.pdf

# Logs
*.log
logs/

# Python
__pycache__/
*.pyc
.env
venv/

# Temporary
*.tmp
backup_*
EOF

# Add and commit initial structure
git add .
git commit -m "Initial project structure"
```

### Tracking Script Development

```bash
# Create a data processing script
cat > scripts/clean_data.py << EOF
#!/usr/bin/env python3
import pandas as pd

def clean_sales_data(input_file, output_file):
    df = pd.read_csv(input_file)
    # Remove duplicates
    df = df.drop_duplicates()
    # Save cleaned data
    df.to_csv(output_file, index=False)
    print(f"Cleaned {len(df)} records")

if __name__ == "__main__":
    clean_sales_data("data/raw/sales.csv", "data/processed/sales_clean.csv")
EOF

# Track the new script
git add scripts/clean_data.py
git commit -m "Add data cleaning script"

# Make improvements
cat >> scripts/clean_data.py << EOF

# Add validation
def validate_data(df):
    assert not df.empty, "DataFrame is empty"
    assert 'id' in df.columns, "Missing id column"
    return True
EOF

# Commit improvements
git add scripts/clean_data.py
git commit -m "Add data validation to cleaning script"
```

### Managing Configuration

```bash
# Create configuration template
cat > config.template.json << EOF
{
  "database_url": "postgresql://localhost/mydb",
  "api_key": "your-api-key-here",
  "data_source": "https://api.example.com/data"
}
EOF

# Add to .gitignore to protect secrets
echo "config.json" >> .gitignore

# Track template but not actual config
git add config.template.json .gitignore
git commit -m "Add configuration template and ignore actual config"
```

## Best Practices

### 1. Commit Messages

**Good commit messages:**
```bash
git commit -m "Add customer data validation"
git commit -m "Fix memory leak in data processing"
git commit -m "Update README with installation instructions"
```

**Poor commit messages:**
```bash
git commit -m "fix"
git commit -m "changes"
git commit -m "asdf"
```

**Conventional Commits:**
```bash
git commit -m "feat: add data export functionality"
git commit -m "fix: resolve CSV parsing error"
git commit -m "docs: update API documentation"
git commit -m "refactor: simplify data validation logic"
```

### 2. What to Commit

**DO commit:**
- Source code
- Configuration templates
- Documentation
- Build scripts
- Tests

**DON'T commit:**
- Large data files
- Generated files
- Secrets/passwords
- OS-specific files
- Temporary files

### 3. Commit Frequency

- Commit early and often
- Each commit should represent a logical unit of work
- Commit before switching tasks
- Commit working code, even if incomplete

### 4. Repository Organization

```
data-project/
├── .gitignore
├── README.md
├── requirements.txt
├── config.template.json
├── scripts/
│   ├── download_data.py
│   ├── clean_data.py
│   └── analyze_data.py
├── tests/
│   └── test_data_processing.py
├── docs/
│   └── data_dictionary.md
└── notebooks/
    └── exploratory_analysis.ipynb
```

## Common Workflows

### Starting a New Feature

```bash
# Check current status
git status

# Make sure working directory is clean
git add .
git commit -m "Save current work"

# Start new feature
# (We'll cover branching in Day 9)
```

### Reviewing Changes Before Commit

```bash
# See what changed
git status
git diff

# Review specific files
git diff scripts/process_data.py

# Stage changes incrementally
git add scripts/process_data.py
git diff --staged

# Commit when ready
git commit -m "Improve data processing performance"
```

### Fixing Mistakes

```bash
# Undo changes in working directory
git restore file.txt

# Unstage files
git restore --staged file.txt

# Amend last commit (if not pushed)
git commit --amend -m "Corrected commit message"

# View what would be committed
git diff --staged
```

## Exercise

Complete the exercise in `exercise.sh` to practice Git basics with a data project.

## Quiz

Test your knowledge with `quiz.md`.

## Next Steps

Tomorrow we'll learn about branching and merging to manage parallel development and feature work.
