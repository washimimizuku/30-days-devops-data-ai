#!/bin/bash

# Day 12: Git Workflows - Solution Guide
# Reference solutions for common workflow scenarios

echo "📚 Day 12: Git Workflows - Solution Guide"
echo "=========================================="

echo ""
echo "🎯 Solution 1: Feature Branch Workflow"
echo "======================================"

cat << 'EOF'
# Basic Feature Branch Workflow

# 1. Create and switch to feature branch
git checkout -b feature/new-feature

# 2. Make changes and commit
git add .
git commit -m "feat: implement new feature"

# 3. Switch back to main and merge
git checkout main
git merge feature/new-feature

# 4. Clean up
git branch -d feature/new-feature

# 5. Push changes
git push origin main
EOF

echo ""
echo "🎯 Solution 2: Gitflow Commands"
echo "=============================="

cat << 'EOF'
# Gitflow Workflow Commands

# Initialize gitflow
git flow init

# Feature workflow
git flow feature start my-feature
# ... make changes ...
git flow feature finish my-feature

# Release workflow
git flow release start 1.0.0
# ... prepare release ...
git flow release finish 1.0.0

# Hotfix workflow
git flow hotfix start 1.0.1
# ... fix issue ...
git flow hotfix finish 1.0.1

# Manual gitflow (without git-flow extension)

# Start feature
git checkout develop
git checkout -b feature/my-feature

# Finish feature
git checkout develop
git merge feature/my-feature
git branch -d feature/my-feature

# Start release
git checkout develop
git checkout -b release/1.0.0

# Finish release
git checkout main
git merge release/1.0.0
git tag -a v1.0.0 -m "Release 1.0.0"
git checkout develop
git merge release/1.0.0
git branch -d release/1.0.0
EOF

echo ""
echo "🎯 Solution 3: Release Management"
echo "==============================="

cat << 'EOF'
# Release Management Best Practices

# 1. Semantic versioning
# MAJOR.MINOR.PATCH
# 1.0.0 -> 1.1.0 (new features)
# 1.1.0 -> 1.1.1 (bug fixes)
# 1.1.1 -> 2.0.0 (breaking changes)

# 2. Create annotated tags
git tag -a v1.0.0 -m "Release version 1.0.0"

# 3. Push tags to remote
git push origin v1.0.0
git push origin --tags

# 4. List tags
git tag -l
git tag -l "v1.*"

# 5. Checkout specific version
git checkout v1.0.0

# 6. Delete tags
git tag -d v1.0.0
git push origin --delete v1.0.0
EOF

echo ""
echo "🎯 Solution 4: Branch Protection Setup"
echo "====================================="

cat << 'EOF'
# Branch Protection (GitHub/GitLab)

# GitHub CLI setup
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["ci/tests"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":2}' \
  --field restrictions=null

# GitLab API setup
curl --request POST --header "PRIVATE-TOKEN: <token>" \
  "https://gitlab.example.com/api/v4/projects/:id/protected_branches" \
  --data "name=main&push_access_level=40&merge_access_level=30"
EOF

echo ""
echo "🎯 Solution 5: Workflow Decision Tree"
echo "===================================="

cat << 'EOF'
# Choosing the Right Workflow

## Team Size: 1-3 developers
→ Feature Branch Workflow
  - Simple and effective
  - Direct merges to main
  - Continuous deployment friendly

## Team Size: 4-10 developers
→ Gitflow Workflow
  - Structured development
  - Parallel feature development
  - Scheduled releases

## Team Size: 10+ developers
→ Trunk-based Development
  - Short-lived branches
  - Strong CI/CD required
  - Rapid integration

## Project Type Considerations

### Data Science Projects
- Experiment branches for model testing
- Data branches for dataset versions
- Analysis branches for reports

### Production Systems
- Strict release process
- Hotfix capabilities
- Environment promotion

### Open Source Projects
- Fork-based workflow
- Community contributions
- Maintainer review process
EOF

echo ""
echo "🎯 Solution 6: Common Issues and Fixes"
echo "====================================="

cat << 'EOF'
# Common Workflow Issues

## Issue: Forgot to create feature branch
# Solution: Create branch from current commit
git checkout -b feature/my-feature

## Issue: Need to move commits to different branch
# Solution: Use cherry-pick
git checkout target-branch
git cherry-pick <commit-hash>

## Issue: Feature branch is behind develop
# Solution: Rebase onto develop
git checkout feature/my-feature
git rebase develop

## Issue: Need to undo last merge
# Solution: Reset to before merge
git reset --hard HEAD~1

## Issue: Want to see what changed in release
# Solution: Compare branches
git diff develop..release/1.0.0
git log develop..release/1.0.0 --oneline

## Issue: Clean up old branches
# Solution: Delete merged branches
git branch --merged develop | grep -v develop | xargs git branch -d
EOF

echo ""
echo "🎯 Solution 7: Automation Scripts"
echo "==============================="

cat << 'EOF'
# Workflow Automation Scripts

## Start Feature Script
#!/bin/bash
feature_name=$1
git checkout develop
git pull origin develop
git checkout -b feature/$feature_name
echo "Feature branch feature/$feature_name created"

## Finish Feature Script
#!/bin/bash
current_branch=$(git branch --show-current)
git checkout develop
git pull origin develop
git merge $current_branch
git branch -d $current_branch
git push origin develop
echo "Feature $current_branch merged and cleaned up"

## Release Script
#!/bin/bash
version=$1
git checkout develop
git pull origin develop
git checkout -b release/$version
echo $version > VERSION
git add VERSION
git commit -m "chore: bump version to $version"
echo "Release branch release/$version created"

## Hotfix Script
#!/bin/bash
version=$1
git checkout main
git pull origin main
git checkout -b hotfix/$version
echo "Hotfix branch hotfix/$version created"
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key takeaways:"
echo "✅ Feature branches keep main stable"
echo "✅ Gitflow provides structure for complex projects"
echo "✅ Tags mark important releases"
echo "✅ Branch protection prevents accidents"
echo "✅ Choose workflow based on team and project needs"
echo ""
echo "💡 Practice these workflows in your daily development!"
