# Day 11: Collaboration Workflows

**Duration**: 1 hour  
**Prerequisites**: Day 10 - Remote Repositories

## Learning Objectives

By the end of this lesson, you will:
- Create and manage pull requests/merge requests
- Conduct effective code reviews
- Implement forking workflows for open source contribution
- Use issue tracking for project management
- Organize work with project boards and milestones
- Establish team collaboration standards

## Core Concepts

### 1. Pull Requests (GitHub) / Merge Requests (GitLab)

Pull requests are proposals to merge code changes from one branch into another, enabling:
- **Code Review**: Team members review changes before merging
- **Discussion**: Collaborate on implementation details
- **Testing**: Automated tests run on proposed changes
- **Documentation**: Track what changes and why

### 2. Code Review Process

Code review is a systematic examination of code changes to:
- **Catch Bugs**: Find issues before they reach production
- **Improve Quality**: Ensure code meets team standards
- **Share Knowledge**: Learn from each other's approaches
- **Maintain Consistency**: Keep codebase coherent

### 3. Collaboration Models

**Centralized Model**: Team members push to shared repository
**Forking Model**: Contributors fork repository and submit pull requests
**Hybrid Model**: Core team uses centralized, external contributors use forks

## Pull Request Workflow

### 1. Creating Pull Requests

```bash
# 1. Create feature branch
git checkout main
git pull origin main
git checkout -b feature/data-validation

# 2. Make changes and commit
echo "def validate_data():" > validate.py
git add validate.py
git commit -m "Add data validation function"

# 3. Push feature branch
git push -u origin feature/data-validation

# 4. Create pull request on GitHub/GitLab
# - Navigate to repository
# - Click "New Pull Request"
# - Select source and target branches
# - Add title and description
# - Request reviewers
# - Submit pull request
```

### 2. Pull Request Best Practices

**Title and Description:**
```
Title: Add data validation for CSV imports

Description:
## What
- Implements comprehensive data validation for CSV file imports
- Adds schema validation and data type checking
- Includes error reporting and logging

## Why
- Prevents invalid data from entering the pipeline
- Improves data quality and reliability
- Reduces downstream processing errors

## How
- Uses pandas for data type validation
- Implements custom validation rules
- Adds comprehensive error messages

## Testing
- Added unit tests for all validation functions
- Tested with various CSV formats
- Verified error handling edge cases

## Screenshots/Examples
[Include relevant examples or screenshots]
```

**Checklist Template:**
```markdown
## Checklist
- [ ] Code follows team style guidelines
- [ ] Self-review completed
- [ ] Tests added for new functionality
- [ ] Documentation updated
- [ ] No sensitive data included
- [ ] Performance impact considered
```

### 3. Review Process

**For Authors:**
- Keep changes focused and small
- Write clear commit messages
- Add comprehensive description
- Respond to feedback promptly
- Update based on review comments

**For Reviewers:**
- Review promptly (within 24-48 hours)
- Be constructive and specific
- Focus on code quality, not personal style
- Ask questions to understand intent
- Approve when satisfied with changes

## Code Review Guidelines

### 1. What to Review

**Functionality:**
- Does the code do what it's supposed to do?
- Are edge cases handled properly?
- Is error handling appropriate?

**Code Quality:**
- Is the code readable and maintainable?
- Are functions and variables well-named?
- Is the code properly documented?

**Performance:**
- Are there any obvious performance issues?
- Is the algorithm efficient for the data size?
- Are resources properly managed?

**Security:**
- Are there any security vulnerabilities?
- Is sensitive data properly handled?
- Are inputs properly validated?

### 2. Review Comments

**Good Review Comments:**
```
✅ "Consider using a more descriptive variable name here. 
   `df` could be `customer_data` for clarity."

✅ "This function is doing a lot. Could we split it into 
   smaller, more focused functions?"

✅ "Great error handling! This will make debugging much easier."

✅ "What happens if the CSV file is empty? Should we add a check?"
```

**Poor Review Comments:**
```
❌ "This is wrong."
❌ "I don't like this approach."
❌ "Fix this."
❌ "Use my way instead."
```

### 3. Review Tools and Features

**GitHub Review Features:**
- Line-by-line comments
- Suggested changes
- Review status (approve, request changes, comment)
- Review assignments
- Draft pull requests

**GitLab Review Features:**
- Merge request discussions
- Approval rules
- Merge request templates
- Code quality reports
- Security scanning

## Forking Workflow

### 1. Contributing to Open Source

```bash
# 1. Fork repository on GitHub/GitLab
# Click "Fork" button on repository page

# 2. Clone your fork
git clone git@github.com:yourusername/project.git
cd project

# 3. Add upstream remote
git remote add upstream git@github.com:original/project.git

# 4. Create feature branch
git checkout -b feature/improvement

# 5. Make changes and commit
git add .
git commit -m "Improve data processing performance"

# 6. Push to your fork
git push origin feature/improvement

# 7. Create pull request from your fork to original repository
```

### 2. Keeping Fork Updated

```bash
# Fetch upstream changes
git fetch upstream

# Update main branch
git checkout main
git merge upstream/main
git push origin main

# Update feature branch (if needed)
git checkout feature/improvement
git rebase main
git push --force-with-lease origin feature/improvement
```

### 3. Fork Maintenance

```bash
# Sync fork regularly
git fetch upstream
git checkout main
git merge upstream/main
git push origin main

# Clean up merged branches
git branch --merged | grep -v main | xargs git branch -d
git remote prune origin
```

## Issue Tracking

### 1. Creating Effective Issues

**Bug Report Template:**
```markdown
## Bug Description
Brief description of the bug

## Steps to Reproduce
1. Step one
2. Step two
3. Step three

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- OS: macOS 13.0
- Python: 3.11.0
- Package Version: 1.2.3

## Additional Context
Screenshots, logs, or other relevant information
```

**Feature Request Template:**
```markdown
## Feature Description
Clear description of the proposed feature

## Use Case
Why is this feature needed? What problem does it solve?

## Proposed Solution
How should this feature work?

## Alternatives Considered
Other approaches that were considered

## Additional Context
Mockups, examples, or related issues
```

### 2. Issue Management

**Labels and Categories:**
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `priority: high` - Critical issues
- `status: in progress` - Currently being worked on

**Milestones:**
- Group related issues for releases
- Set target dates for completion
- Track progress toward goals

### 3. Linking Issues and Pull Requests

```bash
# In commit messages
git commit -m "Fix data validation bug

Closes #123
Fixes #456
Resolves #789"

# In pull request descriptions
Fixes #123 - This PR resolves the data validation issue
Related to #456 - Part of the larger data quality initiative
```

## Project Boards and Planning

### 1. Kanban Boards

**Column Structure:**
- **Backlog**: Ideas and future work
- **To Do**: Ready to start
- **In Progress**: Currently being worked on
- **Review**: Waiting for code review
- **Done**: Completed work

### 2. GitHub Projects

```markdown
## Project Setup
1. Go to repository → Projects → New Project
2. Choose template (Kanban, Table, etc.)
3. Add columns and automation rules
4. Link issues and pull requests
5. Set up filters and views
```

### 3. Planning Workflows

**Sprint Planning:**
- Review backlog items
- Estimate effort required
- Assign issues to team members
- Set sprint goals and timeline

**Daily Standups:**
- What did you work on yesterday?
- What will you work on today?
- Any blockers or issues?

## Data Engineering Collaboration Examples

### 1. Data Pipeline Review

```python
# Example: Data validation pull request
def validate_customer_data(df):
    """
    Validate customer data before processing.
    
    Args:
        df: pandas DataFrame with customer data
        
    Returns:
        tuple: (is_valid, error_messages)
    """
    errors = []
    
    # Check required columns
    required_cols = ['customer_id', 'email', 'signup_date']
    missing_cols = [col for col in required_cols if col not in df.columns]
    if missing_cols:
        errors.append(f"Missing required columns: {missing_cols}")
    
    # Validate email format
    if 'email' in df.columns:
        invalid_emails = df[~df['email'].str.contains('@', na=False)]
        if not invalid_emails.empty:
            errors.append(f"Invalid email formats in rows: {invalid_emails.index.tolist()}")
    
    # Check for duplicates
    if 'customer_id' in df.columns:
        duplicates = df[df['customer_id'].duplicated()]
        if not duplicates.empty:
            errors.append(f"Duplicate customer IDs: {duplicates['customer_id'].tolist()}")
    
    return len(errors) == 0, errors
```

**Review Comments:**
```
Reviewer: "Great validation logic! A few suggestions:

1. Consider using a validation library like Pydantic or Great Expectations 
   for more robust schema validation.

2. The email regex could be more comprehensive. Maybe use a dedicated 
   email validation library?

3. Should we log these validation errors for monitoring purposes?

4. What's the performance impact on large datasets? Consider sampling 
   for very large files."
```

### 2. Documentation Review

```markdown
# Data Processing Pipeline Documentation

## Overview
This pipeline processes customer transaction data and generates daily reports.

## Architecture
```
[Include architecture diagram]
```

## Data Flow
1. **Extract**: Pull data from customer database
2. **Transform**: Clean and validate data
3. **Load**: Store in data warehouse
4. **Report**: Generate daily summary reports

## Configuration
See `config/pipeline.yaml` for configuration options.

## Monitoring
Pipeline metrics are available in Grafana dashboard.
```

**Review Feedback:**
```
"Documentation looks good! Could you add:
- Example configuration file
- Troubleshooting section
- Performance benchmarks
- Data schema definitions"
```

## Team Collaboration Standards

### 1. Branch Naming Conventions

```bash
# Feature branches
feature/user-authentication
feature/data-export-api
feature/performance-optimization

# Bug fixes
bugfix/csv-parsing-error
bugfix/memory-leak-fix

# Hotfixes
hotfix/security-patch
hotfix/critical-data-loss

# Documentation
docs/api-documentation
docs/setup-guide

# Refactoring
refactor/database-layer
refactor/error-handling
```

### 2. Commit Message Standards

```bash
# Format: type(scope): description
feat(auth): add OAuth2 authentication
fix(parser): handle malformed CSV files
docs(api): update endpoint documentation
refactor(db): optimize query performance
test(validation): add edge case tests
```

### 3. Code Review Checklist

```markdown
## Code Review Checklist

### Functionality
- [ ] Code accomplishes the intended purpose
- [ ] Edge cases are handled appropriately
- [ ] Error handling is comprehensive

### Code Quality
- [ ] Code is readable and well-documented
- [ ] Functions are focused and single-purpose
- [ ] Variable names are descriptive
- [ ] No code duplication

### Testing
- [ ] Unit tests cover new functionality
- [ ] Integration tests pass
- [ ] Manual testing completed

### Performance
- [ ] No obvious performance issues
- [ ] Memory usage is reasonable
- [ ] Database queries are optimized

### Security
- [ ] No hardcoded secrets or credentials
- [ ] Input validation is present
- [ ] Security best practices followed

### Documentation
- [ ] Code is properly commented
- [ ] API documentation updated
- [ ] README updated if needed
```

## Automation and Integration

### 1. Automated Checks

```yaml
# .github/workflows/pr-checks.yml
name: Pull Request Checks

on:
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run tests
        run: pytest tests/
      - name: Run linting
        run: flake8 src/
      - name: Check code formatting
        run: black --check src/
```

### 2. Branch Protection Rules

```markdown
## Branch Protection Settings
- Require pull request reviews before merging
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Restrict pushes that create files larger than 100MB
- Require signed commits
```

## Exercise

Complete the exercise in `exercise.sh` to practice collaboration workflows with pull requests and code review.

## Quiz

Test your knowledge with `quiz.md`.

## Next Steps

Tomorrow we'll learn about different Git workflows (GitFlow, Feature Branch, Trunk-based) and release management strategies.
