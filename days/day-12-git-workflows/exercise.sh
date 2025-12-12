#!/bin/bash

# Day 12: Git Workflows - Hands-on Exercise
# Practice implementing different Git workflows

set -e

echo "🚀 Day 12: Git Workflows Exercise"
echo "=================================="

# Create exercise directory
EXERCISE_DIR="$HOME/git-workflows-exercise"
echo "📁 Creating exercise directory: $EXERCISE_DIR"

if [ -d "$EXERCISE_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$EXERCISE_DIR"
fi

mkdir -p "$EXERCISE_DIR"
cd "$EXERCISE_DIR"

echo ""
echo "🎯 Exercise 1: Feature Branch Workflow"
echo "======================================"

# Initialize repository
git init
echo "# Data Analytics Project" > README.md
echo "data/" >> .gitignore
echo "*.log" >> .gitignore
git add .
git commit -m "Initial commit"

echo "✅ Repository initialized"

# Create main branch content
cat > data_processor.py << 'EOF'
#!/usr/bin/env python3
"""Simple data processor for analytics."""

def load_data(filename):
    """Load data from file."""
    print(f"Loading data from {filename}")
    return []

def process_data(data):
    """Process the data."""
    print("Processing data...")
    return data

if __name__ == "__main__":
    data = load_data("sample.csv")
    processed = process_data(data)
    print("Data processing complete")
EOF

git add data_processor.py
git commit -m "Add basic data processor"

echo "✅ Basic project structure created"

# Feature branch workflow
echo ""
echo "🌟 Creating feature branch for user authentication..."

git checkout -b feature/user-auth

cat > auth.py << 'EOF'
#!/usr/bin/env python3
"""User authentication module."""

def authenticate_user(username, password):
    """Authenticate user credentials."""
    if username == "admin" and password == "secret":
        return True
    return False

def get_user_permissions(username):
    """Get user permissions."""
    if username == "admin":
        return ["read", "write", "admin"]
    return ["read"]
EOF

git add auth.py
git commit -m "feat: add user authentication module"

# Update main processor to use auth
cat > data_processor.py << 'EOF'
#!/usr/bin/env python3
"""Simple data processor for analytics."""

from auth import authenticate_user

def load_data(filename, username=None):
    """Load data from file."""
    if username and not authenticate_user(username, "secret"):
        raise PermissionError("Authentication required")
    print(f"Loading data from {filename}")
    return []

def process_data(data):
    """Process the data."""
    print("Processing data...")
    return data

if __name__ == "__main__":
    data = load_data("sample.csv", "admin")
    processed = process_data(data)
    print("Data processing complete")
EOF

git add data_processor.py
git commit -m "feat: integrate authentication with data processor"

echo "✅ Feature development complete"

# Merge feature back to main
git checkout main
git merge feature/user-auth
git branch -d feature/user-auth

echo "✅ Feature merged to main"

echo ""
echo "🎯 Exercise 2: Gitflow Workflow"
echo "==============================="

# Create develop branch
git checkout -b develop
git push --set-upstream origin develop 2>/dev/null || echo "Note: No remote configured"

echo "✅ Develop branch created"

# Start new feature
git checkout -b feature/data-validation

cat > validator.py << 'EOF'
#!/usr/bin/env python3
"""Data validation module."""

def validate_csv_format(filename):
    """Validate CSV file format."""
    print(f"Validating CSV format for {filename}")
    return True

def validate_data_types(data):
    """Validate data types in dataset."""
    print("Validating data types...")
    return True

def validate_required_fields(data, required_fields):
    """Validate required fields are present."""
    print(f"Validating required fields: {required_fields}")
    return True
EOF

git add validator.py
git commit -m "feat: add data validation module"

# Update processor to use validation
cat >> data_processor.py << 'EOF'

from validator import validate_csv_format, validate_data_types

def load_data_with_validation(filename, username=None):
    """Load and validate data from file."""
    if username and not authenticate_user(username, "secret"):
        raise PermissionError("Authentication required")
    
    if not validate_csv_format(filename):
        raise ValueError("Invalid CSV format")
    
    print(f"Loading data from {filename}")
    data = []
    
    if not validate_data_types(data):
        raise ValueError("Invalid data types")
    
    return data
EOF

git add data_processor.py
git commit -m "feat: integrate data validation with processor"

echo "✅ Feature development complete"

# Finish feature (merge to develop)
git checkout develop
git merge feature/data-validation
git branch -d feature/data-validation

echo "✅ Feature merged to develop"

# Start release
git checkout -b release/v1.0.0

# Update version file
echo "1.0.0" > VERSION
cat > CHANGELOG.md << 'EOF'
# Changelog

## [1.0.0] - 2024-12-12

### Added
- User authentication module
- Data validation functionality
- Basic data processor

### Security
- Authentication required for data access
EOF

git add VERSION CHANGELOG.md
git commit -m "chore: prepare release v1.0.0"

echo "✅ Release prepared"

# Finish release
git checkout main
git merge release/v1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0"

git checkout develop
git merge release/v1.0.0
git branch -d release/v1.0.0

echo "✅ Release v1.0.0 completed and tagged"

echo ""
echo "🎯 Exercise 3: Hotfix Workflow"
echo "============================="

# Simulate critical bug in production
git checkout main
git checkout -b hotfix/v1.0.1

# Fix the bug
cat > data_processor.py << 'EOF'
#!/usr/bin/env python3
"""Simple data processor for analytics."""

from auth import authenticate_user

def load_data(filename, username=None):
    """Load data from file."""
    if username and not authenticate_user(username, "secret"):
        raise PermissionError("Authentication required")
    print(f"Loading data from {filename}")
    return []

def process_data(data):
    """Process the data."""
    if data is None:
        raise ValueError("Data cannot be None")
    print("Processing data...")
    return data

if __name__ == "__main__":
    data = load_data("sample.csv", "admin")
    processed = process_data(data)
    print("Data processing complete")

from validator import validate_csv_format, validate_data_types

def load_data_with_validation(filename, username=None):
    """Load and validate data from file."""
    if username and not authenticate_user(username, "secret"):
        raise PermissionError("Authentication required")
    
    if not validate_csv_format(filename):
        raise ValueError("Invalid CSV format")
    
    print(f"Loading data from {filename}")
    data = []
    
    if not validate_data_types(data):
        raise ValueError("Invalid data types")
    
    return data
EOF

git add data_processor.py
git commit -m "fix: add null check for data processing"

# Update version and changelog
echo "1.0.1" > VERSION
cat > CHANGELOG.md << 'EOF'
# Changelog

## [1.0.1] - 2024-12-12

### Fixed
- Add null check to prevent data processing errors

## [1.0.0] - 2024-12-12

### Added
- User authentication module
- Data validation functionality
- Basic data processor

### Security
- Authentication required for data access
EOF

git add VERSION CHANGELOG.md
git commit -m "chore: bump version to 1.0.1"

echo "✅ Hotfix prepared"

# Finish hotfix
git checkout main
git merge hotfix/v1.0.1
git tag -a v1.0.1 -m "Hotfix version 1.0.1"

git checkout develop
git merge hotfix/v1.0.1
git branch -d hotfix/v1.0.1

echo "✅ Hotfix v1.0.1 completed and tagged"

echo ""
echo "🎯 Exercise 4: Branch Management"
echo "==============================="

# Show branch history
echo "📊 Branch and tag summary:"
echo ""
echo "Branches:"
git branch -a

echo ""
echo "Tags:"
git tag -l

echo ""
echo "Recent commits:"
git log --oneline --graph --all -10

echo ""
echo "🎯 Exercise 5: Workflow Comparison"
echo "================================="

cat > WORKFLOW_COMPARISON.md << 'EOF'
# Git Workflow Comparison

## Feature Branch Workflow
- ✅ Simple and straightforward
- ✅ Good for small teams
- ❌ Can become messy with many features
- ❌ No structured release process

## Gitflow Workflow
- ✅ Structured and organized
- ✅ Clear separation of concerns
- ✅ Supports parallel development
- ❌ More complex to learn
- ❌ Overhead for simple projects

## Trunk-based Development
- ✅ Simple integration
- ✅ Fast feedback
- ✅ Encourages small changes
- ❌ Requires strong CI/CD
- ❌ Needs disciplined team

## Recommendation for Data Projects
- Small team (1-3): Feature Branch Workflow
- Medium team (4-8): Gitflow Workflow
- Large team (8+): Trunk-based with strong CI/CD
EOF

git add WORKFLOW_COMPARISON.md
git commit -m "docs: add workflow comparison guide"

echo "✅ Workflow comparison documented"

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully:"
echo "✅ Implemented Feature Branch Workflow"
echo "✅ Practiced Gitflow Workflow"
echo "✅ Handled hotfix process"
echo "✅ Managed releases with tags"
echo "✅ Compared different workflows"
echo ""
echo "📁 Exercise files created in: $EXERCISE_DIR"
echo ""
echo "🔍 Review your work:"
echo "   cd $EXERCISE_DIR"
echo "   git log --oneline --graph --all"
echo "   git tag -l"
echo ""
echo "💡 Next: Try implementing these workflows in your own projects!"
