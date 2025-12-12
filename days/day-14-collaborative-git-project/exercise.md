# Day 14: Manual Exercise Guide

This guide walks you through creating the collaborative Git project step-by-step. Follow along to practice all Git concepts from Week 2.

## Option 1: Automated Setup (Recommended for Review)

Run the automated setup script to see the complete project:

```bash
cd /Users/nfb/Code/30-days-devtools-data-ai/days/day-14-collaborative-git-project
./project_setup.sh
```

Then explore the created project to understand the workflow.

## Option 2: Manual Step-by-Step (Recommended for Learning)

Follow the detailed instructions in `README.md` to build the project manually. This gives you hands-on practice with:

### Phase 1: Repository Setup (15 min)
- Initialize Git repository
- Create project structure
- Configure .gitignore
- Make initial commit

### Phase 2: Gitflow Setup (10 min)
- Create develop branch
- Add initial codebase
- Establish branching strategy

### Phase 3: Feature Development (30 min)
- **Feature A**: Analytics engine with statistics
- **Feature B**: Data visualization with matplotlib  
- **Feature C**: REST API with Flask
- Practice parallel development

### Phase 4: Integration (20 min)
- Merge features to develop
- Resolve merge conflicts
- Test integrated functionality

### Phase 5: Code Review (15 min)
- Create review branch
- Apply code review checklist
- Address feedback and improve code

### Phase 6: Release Management (15 min)
- Create release branch
- Prepare changelog and documentation
- Tag and deploy release v1.0.0

### Phase 7: Hotfix Process (10 min)
- Identify critical bug
- Create hotfix branch
- Deploy emergency fix v1.0.1

## Learning Objectives Checklist

By completing this project, you should be able to:

- [ ] Set up a complete Gitflow workflow
- [ ] Develop features in parallel branches
- [ ] Resolve realistic merge conflicts
- [ ] Conduct systematic code reviews
- [ ] Manage releases with proper versioning
- [ ] Handle emergency hotfixes
- [ ] Create production-ready documentation
- [ ] Use advanced Git techniques in context

## Key Commands You'll Practice

```bash
# Gitflow operations
git checkout -b develop
git checkout -b feature/feature-name
git checkout -b release/v1.0.0
git checkout -b hotfix/v1.0.1

# Merging and conflicts
git merge feature-branch
git add resolved-file
git commit -m "resolve: merge conflicts"

# Tagging releases
git tag -a v1.0.0 -m "Release message"
git push origin v1.0.0

# Advanced operations
git rebase develop
git cherry-pick commit-hash
git stash push -m "WIP message"
```

## Project Deliverables

After completion, you'll have:

1. **Complete Git Repository** with proper history
2. **Customer Analytics Platform** - working Python application
3. **Comprehensive Test Suite** - pytest-based testing
4. **REST API** - Flask-based web service
5. **Documentation** - API docs and changelog
6. **Release Tags** - v1.0.0 and v1.0.1
7. **Clean Git History** - demonstrating professional workflows

## Next Steps

This project prepares you for Week 3 (Docker & Containers) where you'll:
- Containerize this analytics platform
- Create Docker images and containers
- Use Docker Compose for multi-service apps
- Deploy containerized applications

The Git skills you've mastered here are essential for managing containerized applications and CI/CD pipelines in the coming weeks.
