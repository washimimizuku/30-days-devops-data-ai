# Git Setup and Workflow Guide

Learn how to use Git to track your progress through the bootcamp and build your portfolio.

## Why Use Git?

- 📊 **Track Progress** - See your learning journey
- 💾 **Backup** - Never lose your work
- 🎯 **Portfolio** - Show employers your skills
- 🌱 **GitHub Activity** - Green squares on your profile
- 🛠️ **Practice Git** - Learn by doing

## Initial Setup

### Step 1: Install Git

**Check if installed:**
```bash
git --version
```

**Install if needed:**
```bash
# macOS
brew install git

# Linux
sudo apt install git

# Windows (WSL)
sudo apt install git
```

### Step 2: Configure Git

```bash
# Set your name
git config --global user.name "Your Name"

# Set your email (use GitHub email)
git config --global user.email "your.email@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Verify configuration
git config --list
```

### Step 3: Set Up SSH Keys (Recommended)

**Why SSH?** More secure and convenient than passwords.

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Press Enter to accept default location
# Enter passphrase (optional but recommended)

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key to ssh-agent
ssh-add ~/.ssh/id_ed25519

# Copy public key to clipboard
# macOS:
pbcopy < ~/.ssh/id_ed25519.pub

# Linux:
cat ~/.ssh/id_ed25519.pub
# Copy the output manually

# Windows (WSL):
cat ~/.ssh/id_ed25519.pub | clip.exe
```

**Add to GitHub:**
1. Go to GitHub.com
2. Settings > SSH and GPG keys
3. Click "New SSH key"
4. Paste your public key
5. Click "Add SSH key"

**Test connection:**
```bash
ssh -T git@github.com
# Should see: "Hi username! You've successfully authenticated..."
```

## Forking the Repository

### Step 1: Fork on GitHub

1. Go to the bootcamp repository on GitHub
2. Click the **"Fork"** button (top right)
3. Select your account as the destination
4. Wait for fork to complete

### Step 2: Clone Your Fork

```bash
# Clone using SSH (recommended)
git clone git@github.com:YOUR-USERNAME/30-days-devtools-data-ai.git

# Or using HTTPS
git clone https://github.com/YOUR-USERNAME/30-days-devtools-data-ai.git

# Navigate into directory
cd 30-days-devtools-data-ai
```

### Step 3: Set Up Remotes

```bash
# Check current remotes
git remote -v

# Add upstream (original repository)
git remote add upstream git@github.com:ORIGINAL-OWNER/30-days-devtools-data-ai.git

# Verify remotes
git remote -v
# Should show:
# origin    git@github.com:YOUR-USERNAME/30-days-devtools-data-ai.git (fetch)
# origin    git@github.com:YOUR-USERNAME/30-days-devtools-data-ai.git (push)
# upstream  git@github.com:ORIGINAL-OWNER/30-days-devtools-data-ai.git (fetch)
# upstream  git@github.com:ORIGINAL-OWNER/30-days-devtools-data-ai.git (push)
```

## Daily Workflow

### Starting Each Day

```bash
# Make sure you're on main branch
git checkout main

# Pull latest changes (if any)
git pull origin main

# Navigate to today's lesson
cd days/day-XX-topic-name
```

### Working on Exercises

```bash
# Edit exercise files
nano exercise.sh
# or use your preferred editor

# Test your solution
bash exercise.sh

# Check status
git status
```

### Committing Your Work

```bash
# Stage the files you changed
git add days/day-XX-topic-name/exercise.sh

# Or stage all changes in the day's directory
git add days/day-XX-topic-name/

# Commit with descriptive message
git commit -m "Complete Day XX: Topic Name"

# Push to your GitHub
git push origin main
```

### Commit Message Examples

**Good commit messages:**
```bash
git commit -m "Complete Day 1: Terminal Basics"
git commit -m "Complete Day 7: Mini Project - Automated Pipeline"
git commit -m "Add notes to Day 3: Text Processing"
git commit -m "Fix typo in Day 5 exercise"
```

**Bad commit messages:**
```bash
git commit -m "update"
git commit -m "done"
git commit -m "asdf"
```

## Recommended Commit Strategy

### Option 1: Commit After Each Day

```bash
# Complete day's exercises
# Then commit everything for that day
git add days/day-XX-topic-name/
git commit -m "Complete Day XX: Topic Name"
git push origin main
```

**Pros:**
- Simple and straightforward
- One commit per day
- Easy to track progress

### Option 2: Commit After Each Exercise

```bash
# Complete exercise 1
git add days/day-XX-topic-name/exercise.sh
git commit -m "Day XX: Complete exercise 1"

# Complete exercise 2
git add days/day-XX-topic-name/exercise.sh
git commit -m "Day XX: Complete exercise 2"

# Finish day
git add days/day-XX-topic-name/
git commit -m "Day XX: Complete all exercises and quiz"

git push origin main
```

**Pros:**
- More granular history
- Can revert individual exercises
- Shows detailed progress

### Option 3: Commit After Each Session

```bash
# Work for 30 minutes
git add days/day-XX-topic-name/
git commit -m "Day XX: Work in progress"

# Continue later
git add days/day-XX-topic-name/
git commit -m "Day XX: Complete exercises"

git push origin main
```

**Pros:**
- Flexible for interrupted sessions
- Saves work frequently
- Good for longer project days

## Viewing Your Progress

### Check Commit History

```bash
# View all commits
git log

# View compact history
git log --oneline

# View last 10 commits
git log --oneline -10

# View commits for specific day
git log --oneline -- days/day-01-terminal-basics/
```

### Check What Changed

```bash
# See uncommitted changes
git diff

# See changes in specific file
git diff days/day-01-terminal-basics/exercise.sh

# See changes in last commit
git show
```

### Check Status

```bash
# See what's changed
git status

# See what's staged
git diff --staged
```

## Syncing with Upstream

If the original repository is updated:

```bash
# Fetch updates from upstream
git fetch upstream

# Merge updates into your main branch
git checkout main
git merge upstream/main

# Push updates to your fork
git push origin main
```

## Branching Strategy (Optional)

For project days, you might want to use branches:

```bash
# Create branch for project
git checkout -b day-07-project

# Work on project
# ... make changes ...

# Commit changes
git add .
git commit -m "Day 7: Complete pipeline project"

# Merge back to main
git checkout main
git merge day-07-project

# Delete branch
git branch -d day-07-project

# Push to GitHub
git push origin main
```

## Handling Mistakes

### Undo Last Commit (Keep Changes)

```bash
git reset --soft HEAD~1
# Changes are still staged
```

### Undo Last Commit (Discard Changes)

```bash
git reset --hard HEAD~1
# WARNING: This deletes your changes!
```

### Unstage Files

```bash
git reset HEAD file.sh
# File is unstaged but changes remain
```

### Discard Changes in File

```bash
git checkout -- file.sh
# WARNING: This deletes your changes!
```

### Amend Last Commit

```bash
# Fix typo in commit message
git commit --amend -m "New message"

# Add forgotten file to last commit
git add forgotten-file.sh
git commit --amend --no-edit
```

## .gitignore

The bootcamp includes a `.gitignore` file that excludes:

- Python cache files (`__pycache__/`)
- Virtual environments (`venv/`)
- IDE settings (`.vscode/`, `.idea/`)
- Data files (`data/raw/*`, `data/processed/*`)
- Environment variables (`.env`)
- Logs (`*.log`)

**Add your own patterns:**
```bash
# Edit .gitignore
nano .gitignore

# Add patterns
my-notes.txt
temp/
*.tmp
```

## GitHub Profile Benefits

### Green Squares

Committing daily creates activity on your GitHub profile:
- Shows consistency
- Demonstrates commitment
- Impresses employers

### Portfolio

Your fork becomes part of your portfolio:
- Shows what you've learned
- Demonstrates Git skills
- Provides code samples

### Contributions Graph

Your profile shows:
- Commit frequency
- Learning streaks
- Activity over time

## Tips for Success

### Commit Often

- Don't wait until everything is perfect
- Commit working code frequently
- Push to GitHub regularly

### Write Good Messages

- Be descriptive
- Use present tense: "Add feature" not "Added feature"
- Reference day number and topic

### Keep It Clean

- Don't commit sensitive data
- Don't commit large files
- Use .gitignore appropriately

### Stay Organized

- One commit per day minimum
- Keep commits focused
- Push to GitHub daily

## Common Git Commands

```bash
# Status and info
git status              # Check status
git log                 # View history
git diff                # See changes

# Basic workflow
git add file            # Stage file
git commit -m "msg"     # Commit changes
git push origin main    # Push to GitHub

# Branching
git branch              # List branches
git checkout -b name    # Create and switch branch
git merge branch        # Merge branch

# Syncing
git pull origin main    # Pull from your fork
git fetch upstream      # Fetch from original
git merge upstream/main # Merge upstream changes

# Undoing
git reset HEAD file     # Unstage file
git checkout -- file    # Discard changes
git reset --soft HEAD~1 # Undo last commit
```

## Troubleshooting

### "Permission denied (publickey)"

**Solution:** Set up SSH keys (see Step 3 above)

### "fatal: not a git repository"

**Solution:** Make sure you're in the project directory
```bash
cd 30-days-devtools-data-ai
```

### "Your branch is ahead of 'origin/main'"

**Solution:** Push your commits
```bash
git push origin main
```

### "Merge conflict"

**Solution:** See [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for detailed help

## Resources

- **Git Documentation**: https://git-scm.com/doc
- **GitHub Guides**: https://guides.github.com/
- **Git Cheatsheet**: https://education.github.com/git-cheat-sheet-education.pdf
- **Interactive Git Tutorial**: https://learngitbranching.js.org/

---

## Quick Reference

### Daily Routine

```bash
# 1. Navigate to day
cd days/day-XX-topic-name

# 2. Complete exercises
# ... work on files ...

# 3. Commit progress
git add .
git commit -m "Complete Day XX: Topic Name"
git push origin main
```

### Weekly Routine

```bash
# Sync with upstream (if needed)
git fetch upstream
git merge upstream/main
git push origin main
```

---

**Happy committing!** 🚀

Remember: Every commit is progress. Don't aim for perfection, aim for consistency!
