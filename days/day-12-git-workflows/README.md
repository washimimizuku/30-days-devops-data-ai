# Day 12: Git Workflows

**Duration**: 1 hour  
**Prerequisites**: Day 11 (Collaboration Workflows)

## Learning Objectives

By the end of this lesson, you will:
- Understand different Git workflow strategies
- Implement Gitflow for structured development
- Use feature branch workflows effectively
- Manage releases with Git tags
- Choose the right workflow for your team

## Concepts

### Git Workflow Strategies

Different teams use different Git workflows based on their needs:

#### 1. Feature Branch Workflow
- Simple and effective for small teams
- Each feature gets its own branch
- Merge back to main when complete

```bash
# Create feature branch
git checkout -b feature/user-authentication
# Work on feature
git add . && git commit -m "Add login functionality"
# Merge back to main
git checkout main
git merge feature/user-authentication
```

#### 2. Gitflow Workflow
- Structured approach with specific branch types
- Separate branches for features, releases, and hotfixes
- Good for scheduled releases

**Branch Types**:
- `main` - Production-ready code
- `develop` - Integration branch for features
- `feature/*` - New features
- `release/*` - Prepare releases
- `hotfix/*` - Emergency fixes

#### 3. Trunk-based Development
- Everyone commits to main branch
- Short-lived feature branches (< 1 day)
- Requires strong CI/CD and testing

### Release Management

**Semantic Versioning**: `MAJOR.MINOR.PATCH`
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

**Git Tags**: Mark specific commits as releases
```bash
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0
```

## Gitflow in Detail

### Setup Gitflow

```bash
# Initialize gitflow (if using git-flow extension)
git flow init

# Or manually create branches
git checkout -b develop
git push -u origin develop
```

### Feature Development

```bash
# Start new feature
git flow feature start user-dashboard
# Or manually:
git checkout develop
git checkout -b feature/user-dashboard

# Work on feature
git add .
git commit -m "Add dashboard components"

# Finish feature
git flow feature finish user-dashboard
# Or manually:
git checkout develop
git merge feature/user-dashboard
git branch -d feature/user-dashboard
```

### Release Process

```bash
# Start release
git flow release start 1.2.0
# Or manually:
git checkout develop
git checkout -b release/1.2.0

# Prepare release (update version, changelog)
echo "1.2.0" > VERSION
git add VERSION
git commit -m "Bump version to 1.2.0"

# Finish release
git flow release finish 1.2.0
# Or manually:
git checkout main
git merge release/1.2.0
git tag -a v1.2.0 -m "Release 1.2.0"
git checkout develop
git merge release/1.2.0
git branch -d release/1.2.0
```

### Hotfix Process

```bash
# Start hotfix from main
git flow hotfix start 1.2.1
# Or manually:
git checkout main
git checkout -b hotfix/1.2.1

# Fix the issue
git add .
git commit -m "Fix critical security vulnerability"

# Finish hotfix
git flow hotfix finish 1.2.1
# Or manually:
git checkout main
git merge hotfix/1.2.1
git tag -a v1.2.1 -m "Hotfix 1.2.1"
git checkout develop
git merge hotfix/1.2.1
git branch -d hotfix/1.2.1
```

## Choosing the Right Workflow

### Feature Branch Workflow
**Best for**:
- Small teams (2-5 developers)
- Simple projects
- Continuous deployment

**Pros**: Simple, flexible
**Cons**: Can become messy with many features

### Gitflow Workflow
**Best for**:
- Larger teams
- Scheduled releases
- Multiple environments (dev, staging, prod)

**Pros**: Structured, clear release process
**Cons**: Complex, overhead for simple projects

### Trunk-based Development
**Best for**:
- Experienced teams
- Strong CI/CD culture
- Rapid deployment

**Pros**: Simple, fast integration
**Cons**: Requires discipline, good testing

## Branch Protection and Policies

### GitHub Branch Protection
```bash
# Via GitHub UI or API
# Require pull request reviews
# Require status checks
# Restrict pushes to main
# Require up-to-date branches
```

### Branch Naming Conventions
```bash
feature/JIRA-123-user-authentication
bugfix/fix-login-error
hotfix/security-patch-cve-2023-1234
release/v1.2.0
docs/update-api-documentation
```

## Data Project Workflows

### Data Science Workflow
```bash
# Experiment branches
git checkout -b experiment/new-model-architecture

# Data branches (for large datasets)
git checkout -b data/customer-segmentation-v2

# Analysis branches
git checkout -b analysis/quarterly-report-q4
```

### Pipeline Development
```bash
# Pipeline feature
git checkout -b pipeline/add-data-validation

# Infrastructure changes
git checkout -b infra/update-docker-images

# Configuration updates
git checkout -b config/update-prod-settings
```

## Best Practices

### Commit Messages
```bash
# Good commit messages
git commit -m "feat: add user authentication endpoint"
git commit -m "fix: resolve memory leak in data processor"
git commit -m "docs: update API documentation"

# Use conventional commits
# type(scope): description
# Types: feat, fix, docs, style, refactor, test, chore
```

### Branch Management
```bash
# Keep branches up to date
git checkout feature/my-feature
git rebase develop

# Clean up merged branches
git branch -d feature/completed-feature
git push origin --delete feature/completed-feature

# List merged branches
git branch --merged develop
```

### Release Notes
```markdown
# Release v1.2.0

## Features
- Add user dashboard with analytics
- Implement data export functionality

## Bug Fixes
- Fix memory leak in data processor
- Resolve authentication timeout issues

## Breaking Changes
- API endpoint `/users` now requires authentication
```

## Common Pitfalls

1. **Too many long-lived branches** - Keep feature branches short
2. **Forgetting to update develop** - Always merge back to develop
3. **Not using tags** - Tag releases for easy rollback
4. **Inconsistent naming** - Follow branch naming conventions
5. **Large commits** - Make small, focused commits

## Next Steps

Tomorrow (Day 13) we'll cover advanced Git techniques including conflict resolution, rebasing, and interactive Git operations.

## Key Takeaways

- Choose workflow based on team size and project needs
- Gitflow provides structure for complex projects
- Feature branches keep main stable
- Tags mark important releases
- Consistent naming and commit messages improve collaboration
- Branch protection prevents direct pushes to main
