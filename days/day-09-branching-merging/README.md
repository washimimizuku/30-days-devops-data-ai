# Day 9: Branching and Merging

**Duration**: 1 hour  
**Prerequisites**: Day 8 - Git Basics

## Learning Objectives

By the end of this lesson, you will:
- Understand Git branching concepts and workflows
- Create, switch, and manage branches
- Merge branches using different strategies
- Handle merge conflicts effectively
- Implement feature branch workflows for data projects

## Core Concepts

### 1. What are Branches?

Branches are independent lines of development that allow you to:
- Work on features without affecting main code
- Experiment safely with new ideas
- Collaborate with others without conflicts
- Maintain stable and development versions

```
main:     A---B---C---F---G
               \         /
feature:        D---E---/
```

### 2. Branch Types

**Main Branches:**
- `main` (or `master`): Production-ready code
- `develop`: Integration branch for features

**Supporting Branches:**
- `feature/*`: New features or enhancements
- `hotfix/*`: Critical bug fixes
- `release/*`: Prepare new releases

### 3. Git Branching Model

```
main        ●---●---●---●---●
             \       \     /
develop       ●---●---●---●
               \   /
feature/auth    ●-●
```

## Essential Commands

### Branch Management

```bash
# List branches
git branch                    # Local branches
git branch -a                 # All branches (local + remote)
git branch -r                 # Remote branches only

# Create branches
git branch feature-name       # Create branch
git checkout -b feature-name  # Create and switch
git switch -c feature-name    # Modern syntax (Git 2.23+)

# Switch branches
git checkout branch-name      # Traditional syntax
git switch branch-name        # Modern syntax

# Delete branches
git branch -d feature-name    # Safe delete (merged only)
git branch -D feature-name    # Force delete
```

### Merging Branches

```bash
# Merge branch into current branch
git merge feature-name

# Merge types
git merge --ff-only feature-name     # Fast-forward only
git merge --no-ff feature-name       # Always create merge commit
git merge --squash feature-name      # Squash commits into one

# Abort merge
git merge --abort
```

### Branch Information

```bash
# Show branch relationships
git log --graph --oneline --all

# Show branches with last commit
git branch -v

# Show merged/unmerged branches
git branch --merged
git branch --no-merged

# Track branch changes
git log main..feature-name    # Commits in feature not in main
git diff main...feature-name  # Changes between branches
```

## Merge Strategies

### 1. Fast-Forward Merge

When target branch hasn't changed:

```
Before:
main:     A---B---C
               \
feature:        D---E

After:
main:     A---B---C---D---E
```

```bash
git checkout main
git merge feature-branch  # Fast-forward merge
```

### 2. Three-Way Merge

When both branches have new commits:

```
Before:
main:     A---B---C---F
               \
feature:        D---E

After:
main:     A---B---C---F---M
               \         /
feature:        D---E---/
```

```bash
git checkout main
git merge feature-branch  # Creates merge commit M
```

### 3. Squash Merge

Combines all feature commits into one:

```bash
git checkout main
git merge --squash feature-branch
git commit -m "Add complete feature X"
```

## Data Engineering Workflows

### Feature Branch Workflow

```bash
# Start new feature
git checkout main
git pull origin main
git checkout -b feature/data-validation

# Work on feature
echo "def validate_data():" > scripts/validation.py
git add scripts/validation.py
git commit -m "Add data validation function"

# Continue development
echo "    return True" >> scripts/validation.py
git commit -am "Implement basic validation logic"

# Merge back to main
git checkout main
git merge feature/data-validation
git branch -d feature/data-validation
```

### Hotfix Workflow

```bash
# Critical bug in production
git checkout main
git checkout -b hotfix/fix-csv-parser

# Fix the bug
sed -i 's/,/;/g' scripts/parser.py
git commit -am "Fix CSV delimiter bug"

# Merge to main and develop
git checkout main
git merge hotfix/fix-csv-parser

git checkout develop
git merge hotfix/fix-csv-parser

git branch -d hotfix/fix-csv-parser
```

### Experiment Branch

```bash
# Try new algorithm
git checkout -b experiment/new-algorithm

# Implement experimental code
cat > scripts/new_algo.py << EOF
def experimental_process():
    # New approach to data processing
    pass
EOF

git add scripts/new_algo.py
git commit -m "Experiment with new processing algorithm"

# If experiment fails
git checkout main
git branch -D experiment/new-algorithm  # Force delete

# If experiment succeeds
git checkout main
git merge experiment/new-algorithm
```

## Handling Merge Conflicts

### 1. Understanding Conflicts

Conflicts occur when the same lines are modified in both branches:

```
<<<<<<< HEAD
def process_data(file_path):
    return pd.read_csv(file_path)
=======
def process_data(file_path, delimiter=','):
    return pd.read_csv(file_path, sep=delimiter)
>>>>>>> feature-branch
```

### 2. Resolving Conflicts

```bash
# Start merge
git merge feature-branch
# Auto-merging file.py
# CONFLICT (content): Merge conflict in file.py

# View conflicted files
git status

# Edit files to resolve conflicts
nano file.py  # Remove conflict markers, choose correct version

# Mark as resolved
git add file.py

# Complete merge
git commit -m "Merge feature-branch with conflict resolution"
```

### 3. Conflict Resolution Tools

```bash
# Use merge tool
git mergetool

# View conflict in different ways
git diff                    # Show conflicts
git log --merge            # Show conflicting commits
git show :1:file.py        # Common ancestor
git show :2:file.py        # Current branch version
git show :3:file.py        # Merging branch version
```

## Advanced Branching

### Branch Naming Conventions

```bash
# Feature branches
feature/user-authentication
feature/data-export
feature/performance-optimization

# Bug fixes
bugfix/csv-parsing-error
bugfix/memory-leak

# Hotfixes
hotfix/security-patch
hotfix/critical-data-loss

# Releases
release/v1.2.0
release/2023-12-sprint
```

### Branch Protection

```bash
# Prevent accidental deletion
git config branch.main.mergeoptions "--no-ff"

# Require clean working directory
git config merge.ours.driver true
```

### Interactive Rebase

```bash
# Clean up feature branch before merging
git checkout feature-branch
git rebase -i main

# Options in interactive rebase:
# pick = use commit
# reword = change commit message
# edit = modify commit
# squash = combine with previous commit
# drop = remove commit
```

## Data Project Examples

### ETL Pipeline Development

```bash
# Create ETL feature branch
git checkout -b feature/etl-pipeline

# Develop extractor
cat > scripts/extract.py << EOF
def extract_data(source):
    # Extract data from source
    pass
EOF
git add scripts/extract.py
git commit -m "Add data extraction module"

# Develop transformer
cat > scripts/transform.py << EOF
def transform_data(data):
    # Transform extracted data
    pass
EOF
git add scripts/transform.py
git commit -m "Add data transformation module"

# Develop loader
cat > scripts/load.py << EOF
def load_data(data, destination):
    # Load transformed data
    pass
EOF
git add scripts/load.py
git commit -m "Add data loading module"

# Merge complete ETL pipeline
git checkout main
git merge --no-ff feature/etl-pipeline
git branch -d feature/etl-pipeline
```

### Parallel Development

```bash
# Developer 1: Works on data cleaning
git checkout -b feature/data-cleaning
# ... develop cleaning logic ...
git commit -m "Implement data cleaning pipeline"

# Developer 2: Works on visualization
git checkout main
git checkout -b feature/visualization
# ... develop charts and reports ...
git commit -m "Add data visualization dashboard"

# Merge both features
git checkout main
git merge feature/data-cleaning
git merge feature/visualization

# Clean up
git branch -d feature/data-cleaning
git branch -d feature/visualization
```

## Best Practices

### 1. Branch Naming

- Use descriptive names: `feature/user-auth` not `feature1`
- Include ticket numbers: `feature/JIRA-123-data-export`
- Use consistent prefixes: `feature/`, `bugfix/`, `hotfix/`

### 2. Commit Strategy

- Keep feature branches focused and small
- Commit frequently with meaningful messages
- Rebase feature branches before merging
- Use merge commits for feature integration

### 3. Merge Strategy

- Use fast-forward for simple updates
- Use `--no-ff` for feature merges to preserve history
- Squash commits for cleaner history when appropriate
- Always test before merging

### 4. Branch Lifecycle

```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Develop and commit
git add .
git commit -m "Implement feature"

# 3. Keep updated with main
git checkout main
git pull
git checkout feature/new-feature
git rebase main

# 4. Merge when complete
git checkout main
git merge --no-ff feature/new-feature

# 5. Clean up
git branch -d feature/new-feature
```

## Common Workflows

### Git Flow

```bash
# Main branches: main, develop
# Supporting: feature/*, release/*, hotfix/*

# Start feature
git checkout develop
git checkout -b feature/new-feature

# Finish feature
git checkout develop
git merge --no-ff feature/new-feature
git branch -d feature/new-feature

# Start release
git checkout develop
git checkout -b release/1.2.0

# Finish release
git checkout main
git merge --no-ff release/1.2.0
git checkout develop
git merge --no-ff release/1.2.0
git branch -d release/1.2.0
```

### GitHub Flow

```bash
# Simpler workflow: main + feature branches
# 1. Create feature branch from main
git checkout main
git checkout -b feature/new-feature

# 2. Develop and push
git push -u origin feature/new-feature

# 3. Create pull request
# 4. Merge via GitHub interface
# 5. Delete feature branch
```

## Exercise

Complete the exercise in `exercise.sh` to practice branching and merging with a data project.

## Quiz

Test your knowledge with `quiz.md`.

## Next Steps

Tomorrow we'll learn about remote repositories and collaboration with GitHub/GitLab.
