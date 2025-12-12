# Day 10: Remote Repositories

**Duration**: 1 hour  
**Prerequisites**: Day 9 - Branching and Merging

## Learning Objectives

By the end of this lesson, you will:
- Understand remote repository concepts and terminology
- Set up and manage remote repositories
- Push and pull changes to/from remote repositories
- Configure SSH keys for secure authentication
- Clone and fork repositories effectively
- Collaborate using GitHub/GitLab workflows

## Core Concepts

### 1. What are Remote Repositories?

Remote repositories are versions of your project hosted on the internet or network, allowing:
- **Collaboration**: Multiple developers working on the same project
- **Backup**: Your code is stored in multiple locations
- **Distribution**: Share code with others easily
- **Synchronization**: Keep local and remote versions in sync

### 2. Remote Repository Terminology

**Common Remote Names:**
- `origin`: Default remote (your main repository)
- `upstream`: Original repository (when you fork)
- `fork`: Your personal copy of someone else's repository

**Repository Relationships:**
```
Original Repo (upstream)
    ↓ fork
Your Fork (origin)
    ↓ clone
Local Repository
```

### 3. Remote URLs

**HTTPS URLs:**
```
https://github.com/username/repository.git
https://gitlab.com/username/repository.git
```

**SSH URLs:**
```
git@github.com:username/repository.git
git@gitlab.com:username/repository.git
```

## Essential Commands

### Remote Management

```bash
# View remotes
git remote                    # List remote names
git remote -v                 # List remotes with URLs
git remote show origin        # Detailed remote info

# Add remotes
git remote add origin https://github.com/user/repo.git
git remote add upstream https://github.com/original/repo.git

# Change remote URLs
git remote set-url origin git@github.com:user/repo.git

# Remove remotes
git remote remove upstream
```

### Cloning Repositories

```bash
# Clone repository
git clone https://github.com/user/repo.git
git clone git@github.com:user/repo.git

# Clone to specific directory
git clone https://github.com/user/repo.git my-project

# Clone specific branch
git clone -b develop https://github.com/user/repo.git

# Shallow clone (recent history only)
git clone --depth 1 https://github.com/user/repo.git
```

### Pushing Changes

```bash
# Push to remote
git push origin main          # Push main branch to origin
git push origin feature-name  # Push feature branch

# Push all branches
git push --all origin

# Push tags
git push --tags origin

# Force push (use carefully!)
git push --force origin main

# Set upstream tracking
git push -u origin main       # Set origin/main as upstream for main
```

### Fetching and Pulling

```bash
# Fetch changes (download without merging)
git fetch origin             # Fetch from origin
git fetch --all              # Fetch from all remotes

# Pull changes (fetch + merge)
git pull origin main         # Pull and merge from origin/main
git pull                     # Pull from tracked upstream

# Pull with rebase
git pull --rebase origin main
```

## GitHub/GitLab Setup

### 1. Creating a Repository

**GitHub:**
1. Go to github.com and sign in
2. Click "New repository"
3. Enter repository name and description
4. Choose public/private
5. Initialize with README (optional)
6. Click "Create repository"

**GitLab:**
1. Go to gitlab.com and sign in
2. Click "New project"
3. Choose "Create blank project"
4. Enter project details
5. Click "Create project"

### 2. Connecting Local Repository

```bash
# Method 1: Start with local repository
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/username/repo.git
git push -u origin main

# Method 2: Clone existing repository
git clone https://github.com/username/repo.git
cd repo
# Make changes, commit, and push
```

## SSH Key Authentication

### 1. Generate SSH Key

```bash
# Generate new SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# For older systems
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"

# Save to default location (~/.ssh/id_ed25519)
# Set passphrase (recommended)
```

### 2. Add SSH Key to SSH Agent

```bash
# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key to agent
ssh-add ~/.ssh/id_ed25519

# On macOS, add to keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### 3. Add SSH Key to GitHub/GitLab

**GitHub:**
1. Copy public key: `cat ~/.ssh/id_ed25519.pub`
2. Go to GitHub Settings → SSH and GPG keys
3. Click "New SSH key"
4. Paste key and save

**GitLab:**
1. Copy public key: `cat ~/.ssh/id_ed25519.pub`
2. Go to GitLab Settings → SSH Keys
3. Paste key and save

### 4. Test SSH Connection

```bash
# Test GitHub connection
ssh -T git@github.com

# Test GitLab connection
ssh -T git@gitlab.com

# Expected response: "Hi username! You've successfully authenticated..."
```

## Data Engineering Workflows

### Setting Up Data Project Repository

```bash
# Create new data project
mkdir data-analysis-project
cd data-analysis-project
git init

# Create project structure
mkdir -p {data/{raw,processed},scripts,notebooks,docs,tests}

# Create .gitignore for data projects
cat > .gitignore << EOF
# Data files
data/raw/
data/processed/
*.csv
*.json
*.parquet

# Notebooks
.ipynb_checkpoints/

# Python
__pycache__/
*.pyc
.env
venv/

# Outputs
output/
reports/
*.html
*.pdf
EOF

# Create README
cat > README.md << EOF
# Data Analysis Project

## Structure
- \`data/\` - Data files (ignored in git)
- \`scripts/\` - Processing scripts
- \`notebooks/\` - Jupyter notebooks
- \`docs/\` - Documentation
- \`tests/\` - Test files

## Setup
1. Clone repository
2. Install dependencies: \`pip install -r requirements.txt\`
3. Run analysis: \`python scripts/analyze.py\`
EOF

# Initial commit and push
git add .
git commit -m "Initial data project structure"
git remote add origin git@github.com:username/data-project.git
git push -u origin main
```

### Collaborative Data Science Workflow

```bash
# Clone team repository
git clone git@github.com:team/data-science-project.git
cd data-science-project

# Create feature branch for your analysis
git checkout -b analysis/customer-segmentation

# Work on analysis
jupyter notebook notebooks/customer_analysis.ipynb
# ... develop analysis ...

# Commit notebook (clean output first)
jupyter nbconvert --clear-output --inplace notebooks/customer_analysis.ipynb
git add notebooks/customer_analysis.ipynb
git commit -m "Add customer segmentation analysis"

# Push feature branch
git push -u origin analysis/customer-segmentation

# Create pull request on GitHub/GitLab
```

### Syncing with Upstream Repository

```bash
# Add upstream remote (original repository)
git remote add upstream git@github.com:original/data-project.git

# Fetch upstream changes
git fetch upstream

# Sync your main branch
git checkout main
git merge upstream/main
git push origin main

# Update feature branch with latest main
git checkout feature-branch
git rebase main
git push --force-with-lease origin feature-branch
```

## Advanced Remote Operations

### Multiple Remotes

```bash
# Working with multiple remotes
git remote add origin git@github.com:myuser/project.git
git remote add upstream git@github.com:original/project.git
git remote add backup git@gitlab.com:myuser/project.git

# Push to multiple remotes
git push origin main
git push backup main

# Fetch from specific remote
git fetch upstream
git merge upstream/main
```

### Remote Branch Management

```bash
# List remote branches
git branch -r

# Track remote branch
git checkout -b local-branch origin/remote-branch

# Delete remote branch
git push origin --delete feature-branch

# Prune deleted remote branches
git remote prune origin
```

### Handling Diverged Branches

```bash
# When local and remote have diverged
git fetch origin
git status  # Shows "Your branch and 'origin/main' have diverged"

# Option 1: Merge
git merge origin/main

# Option 2: Rebase
git rebase origin/main

# Option 3: Reset (lose local changes)
git reset --hard origin/main
```

## Best Practices

### 1. Repository Setup

- Use descriptive repository names
- Include comprehensive README
- Set up proper .gitignore before first commit
- Choose appropriate license
- Enable branch protection rules

### 2. SSH vs HTTPS

**Use SSH when:**
- You push frequently
- You want seamless authentication
- You're on a trusted machine

**Use HTTPS when:**
- You're on a shared/public machine
- Corporate firewall blocks SSH
- You only need read access

### 3. Commit and Push Strategy

```bash
# Good practice: frequent small commits
git add scripts/new_feature.py
git commit -m "Add data validation function"
git push origin feature-branch

# Avoid: large infrequent commits
git add .
git commit -m "Lots of changes"
git push origin main  # Don't push directly to main
```

### 4. Branch Management

- Use feature branches for all development
- Keep main branch stable and deployable
- Delete merged branches regularly
- Use descriptive branch names

### 5. Security Considerations

- Never commit secrets or API keys
- Use SSH keys with passphrases
- Regularly rotate SSH keys
- Use .env files for local configuration
- Review public repository content carefully

## Common Workflows

### Fork and Pull Request Workflow

```bash
# 1. Fork repository on GitHub/GitLab
# 2. Clone your fork
git clone git@github.com:yourusername/project.git
cd project

# 3. Add upstream remote
git remote add upstream git@github.com:original/project.git

# 4. Create feature branch
git checkout -b feature/new-analysis

# 5. Make changes and commit
git add .
git commit -m "Add new analysis feature"

# 6. Push to your fork
git push origin feature/new-analysis

# 7. Create pull request on GitHub/GitLab
```

### Centralized Workflow

```bash
# Team members work on shared repository
git clone git@github.com:team/project.git
cd project

# Always start with latest main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/data-cleaning

# Work, commit, and push
git add .
git commit -m "Improve data cleaning pipeline"
git push -u origin feature/data-cleaning

# Merge via pull request
```

## Troubleshooting

### Common Issues

```bash
# Permission denied (SSH key issues)
ssh -T git@github.com  # Test SSH connection
ssh-add -l             # List SSH keys
ssh-add ~/.ssh/id_ed25519  # Add key to agent

# Authentication failed (HTTPS)
git config --global credential.helper store  # Store credentials
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Push rejected (non-fast-forward)
git fetch origin
git rebase origin/main  # or git merge origin/main
git push origin main

# Remote branch doesn't exist
git push -u origin new-branch  # Create remote branch
```

### Recovery Commands

```bash
# Undo last push (if no one else pulled)
git reset --hard HEAD~1
git push --force-with-lease origin main

# Recover deleted branch
git reflog  # Find commit hash
git checkout -b recovered-branch <commit-hash>

# Fix wrong remote URL
git remote set-url origin git@github.com:correct/repo.git
```

## Exercise

Complete the exercise in `exercise.sh` to practice remote repository operations with GitHub/GitLab.

## Quiz

Test your knowledge with `quiz.md`.

## Next Steps

Tomorrow we'll learn about collaboration workflows including pull requests, code review, and team development processes.
