#!/bin/bash

# Day 13: Advanced Git - Solution Guide
# Reference solutions for advanced Git operations

echo "📚 Day 13: Advanced Git - Solution Guide"
echo "========================================"

echo ""
echo "🎯 Solution 1: Conflict Resolution"
echo "=================================="

cat << 'EOF'
# Merge Conflict Resolution Process

# 1. Identify conflicts
git status
# Shows files with conflicts

# 2. View conflict markers
cat conflicted_file.py
# Look for:
# <<<<<<< HEAD
# current branch content
# =======
# other branch content
# >>>>>>> branch-name

# 3. Resolve conflicts manually
# Edit file to combine changes appropriately
# Remove conflict markers (<<<<<<, =======, >>>>>>>)

# 4. Stage resolved files
git add conflicted_file.py

# 5. Complete merge
git commit -m "Resolve merge conflict in conflicted_file.py"

# Alternative: Abort merge if needed
git merge --abort
EOF

echo ""
echo "🎯 Solution 2: Interactive Rebase"
echo "================================="

cat << 'EOF'
# Interactive Rebase Commands

# Start interactive rebase
git rebase -i HEAD~3

# Rebase editor commands:
# pick   = use commit as-is
# reword = change commit message
# edit   = stop to modify commit
# squash = combine with previous commit
# drop   = remove commit entirely

# Example rebase script:
pick abc1234 Add feature
squash def5678 Fix typo
reword ghi9012 Update documentation
drop jkl3456 Debug commit

# After editing, save and close editor
# Git will process each command

# For squash commits, edit combined message
# For reword commits, edit message
# For edit commits, make changes then:
git add .
git commit --amend
git rebase --continue

# If conflicts during rebase:
# 1. Resolve conflicts
# 2. git add resolved_files
# 3. git rebase --continue

# Abort rebase if needed
git rebase --abort
EOF

echo ""
echo "🎯 Solution 3: Git Stash Operations"
echo "==================================="

cat << 'EOF'
# Basic Stash Operations

# Save current changes
git stash
git stash push -m "WIP: feature description"

# List stashes
git stash list

# Apply stash (keeps stash)
git stash apply
git stash apply stash@{1}

# Pop stash (removes from stash list)
git stash pop

# Show stash contents
git stash show
git stash show -p stash@{1}

# Advanced stash operations
git stash --include-untracked  # Include untracked files
git stash --staged            # Only staged changes
git stash -p                  # Interactive stashing

# Create branch from stash
git stash branch new-feature stash@{1}

# Drop specific stash
git stash drop stash@{1}

# Clear all stashes
git stash clear
EOF

echo ""
echo "🎯 Solution 4: Cherry-pick Operations"
echo "===================================="

cat << 'EOF'
# Cherry-pick Commands

# Pick single commit
git cherry-pick abc1234

# Pick range of commits (exclusive start)
git cherry-pick abc1234..def5678

# Pick multiple specific commits
git cherry-pick abc1234 def5678 ghi9012

# Cherry-pick without committing
git cherry-pick --no-commit abc1234

# Cherry-pick with custom message
git cherry-pick -x abc1234  # Adds "cherry picked from" note

# Handle cherry-pick conflicts
# 1. Resolve conflicts in files
# 2. git add resolved_files
# 3. git cherry-pick --continue

# Abort cherry-pick
git cherry-pick --abort

# Cherry-pick merge commit (specify parent)
git cherry-pick -m 1 merge_commit_hash
EOF

echo ""
echo "🎯 Solution 5: Recovery Techniques"
echo "================================="

cat << 'EOF'
# Git Recovery Commands

# View reflog (recent actions)
git reflog
git reflog --all

# Recover lost commit
git checkout lost_commit_hash
git checkout -b recovery-branch

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo specific file changes
git checkout HEAD -- filename

# Recover deleted branch
git checkout -b recovered-branch lost_commit_hash

# Find commits by message
git log --grep="search term"

# Find commits by content
git log -S "code content" --source --all

# Restore file from specific commit
git show commit_hash:path/to/file > recovered_file

# Reset to specific commit
git reset --hard commit_hash

# Revert commit (creates new commit)
git revert commit_hash
EOF

echo ""
echo "🎯 Solution 6: Rebase Strategies"
echo "==============================="

cat << 'EOF'
# Rebase vs Merge Decision Guide

# Use REBASE when:
# - Feature branch is private/local
# - Want clean linear history
# - Integrating latest changes before merge

# Use MERGE when:
# - Branch is public/shared
# - Want to preserve branch context
# - Merging completed features

# Rebase feature branch onto main
git checkout feature-branch
git rebase main

# Interactive rebase to clean up
git rebase -i HEAD~5

# Rebase with conflict resolution
git rebase main
# Resolve conflicts
git add resolved_files
git rebase --continue

# Force push after rebase (feature branches only!)
git push --force-with-lease origin feature-branch

# Merge with no fast-forward (preserves branch)
git merge --no-ff feature-branch

# Squash merge (single commit)
git merge --squash feature-branch
git commit -m "Add complete feature"
EOF

echo ""
echo "🎯 Solution 7: Advanced Workflows"
echo "================================="

cat << 'EOF'
# Patch Workflow
git format-patch -1 HEAD           # Create patch
git apply patch_file.patch         # Apply patch
git am patch_file.patch           # Apply as commit

# Bisect for Bug Hunting
git bisect start
git bisect bad HEAD               # Current is bad
git bisect good v1.0.0           # v1.0.0 was good
# Test each commit Git checks out
git bisect good                   # Mark as good
git bisect bad                    # Mark as bad
git bisect reset                  # End bisect

# Blame and Annotation
git blame filename                # See who changed each line
git annotate filename             # Alternative to blame

# Archive Repository
git archive --format=zip HEAD > project.zip

# Clean Repository
git clean -n                      # Dry run
git clean -f                      # Remove untracked files
git clean -fd                     # Remove untracked files and directories
EOF

echo ""
echo "🎯 Solution 8: Data Project Scenarios"
echo "====================================="

cat << 'EOF'
# Large File Handling
git lfs track "*.csv"            # Track large files with LFS
git add .gitattributes
git add large_file.csv
git commit -m "Add large dataset"

# Remove large file from history
git filter-branch --tree-filter 'rm -f large_file.csv' HEAD

# Experiment Management
git worktree add ../experiment-1 experiment/model-v1
git worktree add ../experiment-2 experiment/model-v2
git worktree list
git worktree remove ../experiment-1

# Notebook Handling
# Use nbstripout to clean notebooks
pip install nbstripout
nbstripout --install

# Or use .gitattributes
echo "*.ipynb filter=nbstripout" >> .gitattributes
echo "*.ipynb diff=ipynb" >> .gitattributes

# Data Version Control
git tag data-v1.0 -m "Dataset version 1.0"
git tag model-v2.1 -m "Model version 2.1"

# Branch per experiment
git checkout -b experiment/lstm-model
git checkout -b experiment/transformer-model
git checkout -b analysis/quarterly-report
EOF

echo ""
echo "🎯 Solution 9: Team Collaboration"
echo "================================="

cat << 'EOF'
# Safe Force Push
git push --force-with-lease origin feature-branch

# Update feature branch safely
git checkout feature-branch
git fetch origin
git rebase origin/main
git push --force-with-lease origin feature-branch

# Collaborative Conflict Resolution
# 1. Communicate with team about conflicts
# 2. Coordinate who resolves what
# 3. Test after resolution
# 4. Document resolution strategy

# Pull Request Preparation
git checkout feature-branch
git rebase -i HEAD~5              # Clean up commits
git rebase main                   # Update with latest
git push --force-with-lease origin feature-branch

# Code Review Integration
git checkout main
git pull origin main
git checkout feature-branch
git rebase main                   # Ensure up to date
# Address review comments
git commit -m "Address review feedback"
git push origin feature-branch
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key advanced Git skills:"
echo "✅ Systematic conflict resolution"
echo "✅ Interactive rebase for clean history"
echo "✅ Stash for context switching"
echo "✅ Cherry-pick for selective changes"
echo "✅ Recovery with reflog"
echo "✅ Strategic rebase vs merge decisions"
echo ""
echo "💡 Remember:"
echo "   - Practice these techniques in safe environments first"
echo "   - Always communicate with team before force pushing"
echo "   - Use --force-with-lease instead of --force"
echo "   - Keep backups of important work"
