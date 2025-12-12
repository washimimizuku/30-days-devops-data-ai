#!/bin/bash

# Day 11: Collaboration Workflows - Exercise
# Practice pull requests, code review, and team collaboration

echo "=== Day 11: Collaboration Workflows Exercise ==="
echo "Learning GitHub/GitLab collaboration through hands-on practice"
echo

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Exercise 1: Setting Up Collaborative Project
echo "=== Exercise 1: Collaborative Project Setup ==="
echo "TODO: Create a project structure for team collaboration"
echo

PROJECT_NAME="collaborative-data-project"
echo "1.1 Creating collaborative project: $PROJECT_NAME"

# Create and initialize project
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"
git init

# Configure Git
git config user.name "Team Lead"
git config user.email "lead@dataproject.com"

echo "1.2 Create comprehensive project structure:"
mkdir -p {src/{data_processing,analysis,utils},tests/{unit,integration},docs/{guides,templates},config,scripts,examples}

# Create project README with collaboration guidelines
cat > README.md << 'EOF'
# Collaborative Data Project

A team-based data processing project demonstrating Git collaboration workflows.

## 🤝 Collaboration Guidelines

### Branch Strategy
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: Feature development branches
- `bugfix/*`: Bug fix branches
- `hotfix/*`: Critical production fixes

### Pull Request Process
1. Create feature branch from `develop`
2. Implement changes with tests
3. Submit pull request to `develop`
4. Request code review from team members
5. Address review feedback
6. Merge after approval

### Code Review Standards
- All code must be reviewed by at least one team member
- Focus on functionality, readability, and maintainability
- Be constructive and specific in feedback
- Test changes locally before approval

## 📋 Issue Templates

Use our issue templates for:
- Bug reports
- Feature requests
- Documentation improvements
- Questions and discussions

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd collaborative-data-project
   ```

2. **Set up development environment**
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Create feature branch**
   ```bash
   git checkout develop
   git checkout -b feature/your-feature-name
   ```

4. **Make changes and submit PR**
   ```bash
   git add .
   git commit -m "Add your feature"
   git push origin feature/your-feature-name
   ```

## 📊 Project Structure

- `src/` - Source code modules
- `tests/` - Test suites
- `docs/` - Documentation and guides
- `config/` - Configuration files
- `scripts/` - Utility scripts
- `examples/` - Usage examples

## 🔧 Development Tools

- **Testing**: pytest
- **Linting**: flake8, black
- **Documentation**: Sphinx
- **CI/CD**: GitHub Actions
EOF

# Create pull request template
mkdir -p .github/pull_request_template.md
cat > .github/pull_request_template.md << 'EOF'
## Description
Brief description of changes made in this PR.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Code refactoring
- [ ] Performance improvement

## What Changed
- List specific changes made
- Include any new dependencies
- Mention configuration changes

## Why
Explain the motivation for these changes:
- What problem does this solve?
- What use case does this address?

## How to Test
Describe how reviewers can test these changes:
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing steps

## Screenshots/Examples
Include relevant screenshots, code examples, or output samples.

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes

## Related Issues
Closes #(issue number)
Related to #(issue number)
EOF

echo "✓ Collaborative project structure created"
