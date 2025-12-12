# Day 13: Advanced Git

**Duration**: 1 hour  
**Prerequisites**: Day 12 (Git Workflows)

## Learning Objectives

By the end of this lesson, you will:
- Resolve merge conflicts effectively
- Use git rebase vs merge strategically
- Perform interactive rebasing to clean up history
- Use git stash for temporary changes
- Cherry-pick commits between branches
- Recover from common Git mistakes

## Concepts

### Merge Conflicts

Conflicts occur when Git can't automatically merge changes:

```bash
# Conflict markers in file
<<<<<<< HEAD
current_branch_content
=======
other_branch_content
>>>>>>> feature/new-feature
```

**Resolution Process**:
1. Identify conflicted files: `git status`
2. Edit files to resolve conflicts
3. Remove conflict markers
4. Stage resolved files: `git add`
5. Complete merge: `git commit`

### Rebase vs Merge

**Merge**: Creates merge commit, preserves branch history
```bash
git checkout main
git merge feature/auth
# Creates merge commit
```

**Rebase**: Replays commits on top of target branch
```bash
git checkout feature/auth
git rebase main
# Moves commits to tip of main
```

**When to use each**:
- **Merge**: Public branches, preserving context
- **Rebase**: Private branches, clean linear history

### Interactive Rebase

Clean up commit history before merging:

```bash
git rebase -i HEAD~3
```

**Actions available**:
- `pick` - Keep commit as-is
- `reword` - Change commit message
- `edit` - Modify commit content
- `squash` - Combine with previous commit
- `drop` - Remove commit entirely

### Git Stash

Temporarily save uncommitted changes:

```bash
# Save current changes
git stash

# Save with message
git stash push -m "WIP: user authentication"

# List stashes
git stash list

# Apply latest stash
git stash pop

# Apply specific stash
git stash apply stash@{1}
```

## Conflict Resolution

### Common Conflict Scenarios

**1. Same Line Modified**
```python
# Branch A
def process_data(data):
    return clean_data(data)  # Added cleaning

# Branch B  
def process_data(data):
    return validate_data(data)  # Added validation
```

**Resolution**:
```python
def process_data(data):
    validated = validate_data(data)
    return clean_data(validated)
```

**2. File Renamed vs Modified**
- One branch renames file
- Other branch modifies original file
- Git shows both as conflicts

**3. Deleted vs Modified**
- One branch deletes file
- Other branch modifies it
- Choose to keep modified or confirm deletion

### Conflict Resolution Tools

```bash
# Configure merge tool
git config --global merge.tool vimdiff

# Launch merge tool
git mergetool

# Abort merge if needed
git merge --abort

# Continue rebase after resolving
git rebase --continue
```

## Rebase Strategies

### Basic Rebase
```bash
# Update feature branch with latest main
git checkout feature/data-pipeline
git rebase main

# If conflicts occur:
# 1. Resolve conflicts in files
# 2. git add resolved_file
# 3. git rebase --continue
```

### Interactive Rebase Examples

**Squash commits**:
```bash
git rebase -i HEAD~3

# Change pick to squash for commits to combine
pick abc1234 Add data validation
squash def5678 Fix validation bug
squash ghi9012 Update validation tests
```

**Reorder commits**:
```bash
# Reorder lines in interactive rebase
pick ghi9012 Add tests
pick abc1234 Add feature
pick def5678 Fix bug
```

**Edit commit**:
```bash
# Mark commit for editing
edit abc1234 Add data validation

# Make changes, then:
git add .
git commit --amend
git rebase --continue
```

## Cherry-picking

Apply specific commits to current branch:

```bash
# Apply single commit
git cherry-pick abc1234

# Apply range of commits
git cherry-pick abc1234..def5678

# Apply without committing
git cherry-pick --no-commit abc1234
```

**Use cases**:
- Apply hotfix to multiple branches
- Move commits between branches
- Backport features to older versions

## Stashing Strategies

### Advanced Stash Operations

```bash
# Stash only staged changes
git stash --staged

# Stash including untracked files
git stash -u

# Stash with patch mode (selective)
git stash -p

# Create branch from stash
git stash branch feature/temp-work stash@{1}

# Clear all stashes
git stash clear
```

### Stash Workflow
```bash
# Working on feature, need to switch branches
git stash push -m "WIP: authentication module"
git checkout main
git pull origin main

# Return to work
git checkout feature/auth
git stash pop
```

## Recovery Techniques

### Undo Last Commit
```bash
# Keep changes in working directory
git reset --soft HEAD~1

# Remove changes completely
git reset --hard HEAD~1

# Amend last commit
git commit --amend -m "Better commit message"
```

### Find Lost Commits
```bash
# Show all recent actions
git reflog

# Recover lost commit
git checkout abc1234
git checkout -b recovery-branch
```

### Reset vs Revert
```bash
# Reset (changes history)
git reset --hard HEAD~2

# Revert (creates new commit)
git revert HEAD~2
```

## Data Project Scenarios

### Handling Large Files
```bash
# Remove large file from history
git filter-branch --tree-filter 'rm -f large_dataset.csv' HEAD

# Better: use git-lfs for large files
git lfs track "*.csv"
git add .gitattributes
```

### Experiment Branches
```bash
# Save experiment state
git stash push -m "Experiment: new algorithm"

# Try different approach
git checkout -b experiment/alternative-model

# Compare results
git diff main experiment/alternative-model -- results/
```

### Collaborative Conflicts
```bash
# Pull with rebase to avoid merge commits
git pull --rebase origin main

# Push force safely (only for feature branches)
git push --force-with-lease origin feature/my-branch
```

## Best Practices

### Rebase Guidelines
- **Never rebase public branches** (main, develop)
- **Always rebase feature branches** before merging
- **Use interactive rebase** to clean up commits
- **Test after rebasing** to ensure functionality

### Conflict Prevention
- **Pull frequently** to stay updated
- **Make small commits** easier to resolve conflicts
- **Communicate changes** that might conflict
- **Use .gitattributes** for merge strategies

### Commit Hygiene
```bash
# Good commit structure
git commit -m "feat: add data validation

- Add CSV format validation
- Add required field checks  
- Add data type validation
- Update tests for new validators"

# Atomic commits
git add validator.py
git commit -m "feat: add data validator module"

git add tests/test_validator.py  
git commit -m "test: add validator tests"
```

## Common Mistakes and Fixes

### Mistake: Committed to wrong branch
```bash
# Move last commit to correct branch
git checkout correct-branch
git cherry-pick wrong-branch
git checkout wrong-branch
git reset --hard HEAD~1
```

### Mistake: Need to split large commit
```bash
# Reset to before commit, keeping changes
git reset --soft HEAD~1

# Stage and commit parts separately
git add specific_file.py
git commit -m "feat: add specific feature"

git add other_file.py
git commit -m "refactor: improve other module"
```

### Mistake: Pushed sensitive data
```bash
# Remove from history (dangerous!)
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch secrets.txt' \
--prune-empty --tag-name-filter cat -- --all

# Force push (coordinate with team!)
git push --force-with-lease --all
```

## Advanced Workflows

### Patch Workflow
```bash
# Create patch file
git format-patch -1 HEAD

# Apply patch
git apply 0001-feature-patch.patch

# Apply as commit
git am 0001-feature-patch.patch
```

### Bisect for Bug Hunting
```bash
# Start bisect
git bisect start
git bisect bad HEAD
git bisect good v1.0.0

# Git will checkout commits to test
# Mark each as good or bad
git bisect good  # or git bisect bad

# Find the problematic commit
git bisect reset
```

## Next Steps

Tomorrow (Day 14) we'll put everything together in a collaborative project that combines all Git concepts from Days 8-13.

## Key Takeaways

- Conflicts are normal - learn to resolve them systematically
- Rebase for clean history, merge for preserving context
- Interactive rebase is powerful for commit cleanup
- Stash is essential for context switching
- Cherry-pick moves specific changes between branches
- Git reflog can recover almost anything
- Prevention is better than complex recovery
