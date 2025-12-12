# Contributing to 30 Days of Developer Tools

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Ways to Contribute

- 🐛 Report bugs and issues
- 💡 Suggest new features or improvements
- 📝 Improve documentation
- ✨ Add new exercises or examples
- 🔧 Fix bugs or typos
- 🌍 Translate content

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally
3. **Create a branch** for your changes
4. **Make your changes**
5. **Test your changes**
6. **Submit a pull request**

## Reporting Issues

### Bug Reports

When reporting bugs, please include:

- **Clear title** describing the issue
- **Steps to reproduce** the problem
- **Expected behavior** vs actual behavior
- **Environment details** (OS, tool versions)
- **Error messages** (full text)
- **Screenshots** if applicable

**Example:**
```
Title: Docker exercise fails on macOS

Steps to reproduce:
1. Navigate to day-15-docker-basics
2. Run: bash exercise.sh
3. Error appears

Expected: Container should start
Actual: Permission denied error

Environment:
- macOS 13.0
- Docker Desktop 4.15.0
- bash 5.2.15

Error message:
docker: permission denied while trying to connect to the Docker daemon socket
```

### Feature Requests

When suggesting features, please include:

- **Clear description** of the feature
- **Use case** - why is it needed?
- **Examples** of how it would work
- **Alternatives** you've considered

## Making Changes

### Code Style

**Shell Scripts:**
```bash
#!/bin/bash

# Use descriptive variable names
data_file="input.csv"

# Add comments for complex logic
# Process each line in the file
while read -r line; do
    echo "$line"
done < "$data_file"

# Use functions for reusability
process_data() {
    local input=$1
    # Function logic here
}
```

**Python:**
```python
# Follow PEP 8 style guide
# Use type hints
def process_data(input_file: str) -> list:
    """Process data from input file.
    
    Args:
        input_file: Path to input file
        
    Returns:
        List of processed records
    """
    # Implementation here
    pass
```

**Markdown:**
- Use clear headings
- Include code blocks with language tags
- Add examples for concepts
- Keep lines under 100 characters when possible

### Documentation

When adding or updating documentation:

- **Be clear and concise**
- **Include examples**
- **Test all commands**
- **Update table of contents** if needed
- **Check spelling and grammar**

### Exercises

When creating exercises:

1. **Clear learning objective**
2. **Step-by-step instructions**
3. **TODO comments** in starter code
4. **Complete solution** provided
5. **Test cases** if applicable

**Example exercise structure:**
```bash
#!/bin/bash
# Exercise: Process CSV file

# TODO: Read the CSV file
# Hint: Use cat or while read

# TODO: Extract the second column
# Hint: Use awk or cut

# TODO: Sort the results
# Hint: Use sort command

# TODO: Remove duplicates
# Hint: Use uniq command
```

## Pull Request Process

### Before Submitting

1. **Test your changes** thoroughly
2. **Update documentation** if needed
3. **Add examples** for new features
4. **Check for typos** and errors
5. **Follow existing style** and structure

### PR Guidelines

**Title:** Clear and descriptive
```
Good: Add jq examples to Day 3 exercises
Bad: Update files
```

**Description:** Include:
- What changes were made
- Why the changes are needed
- How to test the changes
- Related issues (if any)

**Example:**
```markdown
## Changes
- Added 3 new jq exercises to Day 3
- Updated solution file with explanations
- Added quiz questions about jq

## Why
Students requested more practice with jq for JSON processing

## Testing
1. Navigate to days/day-03-text-processing
2. Run: bash exercise.sh
3. Verify all jq commands work correctly

## Related Issues
Closes #42
```

### Review Process

1. Maintainers will review your PR
2. Address any requested changes
3. Once approved, PR will be merged
4. Your contribution will be credited!

## Development Setup

### Prerequisites

- Git
- Bash/Zsh
- Docker (for Week 3 content)
- Python 3.11+ (for Week 4 content)

### Local Setup

```bash
# Fork and clone
git clone https://github.com/YOUR-USERNAME/30-days-devtools-data-ai.git
cd 30-days-devtools-data-ai

# Create branch
git checkout -b feature/your-feature-name

# Make changes
# ... edit files ...

# Test changes
bash tools/test_setup.sh

# Commit
git add .
git commit -m "Description of changes"

# Push
git push origin feature/your-feature-name
```

## Testing Guidelines

### Shell Scripts

```bash
# Test script runs without errors
bash script.sh

# Test with different inputs
bash script.sh input1.txt
bash script.sh input2.csv

# Test error handling
bash script.sh nonexistent.txt
```

### Docker

```bash
# Test Dockerfile builds
docker build -t test-image .

# Test container runs
docker run test-image

# Test docker-compose
docker-compose up
docker-compose down
```

### Documentation

- **Read through** all changes
- **Test all commands** in a fresh environment
- **Check all links** work
- **Verify code blocks** have correct syntax highlighting

## Content Guidelines

### Lesson Structure

Each day should follow this structure:

```markdown
# Day X: Topic Name

## Learning Objectives
- Objective 1
- Objective 2

## Concepts

### Concept 1
Explanation with examples

### Concept 2
Explanation with examples

## Exercises

Instructions for hands-on practice

## Key Takeaways
- Takeaway 1
- Takeaway 2

## Resources
- Link 1
- Link 2
```

### Exercise Structure

```markdown
# Exercise: Title

## Goal
What you'll build/learn

## Instructions

### Step 1: Setup
Detailed instructions

### Step 2: Implementation
Detailed instructions

### Step 3: Testing
How to verify it works

## Bonus Challenges
Optional advanced exercises
```

## Community Guidelines

### Code of Conduct

- **Be respectful** and inclusive
- **Be patient** with beginners
- **Provide constructive** feedback
- **Assume good intentions**
- **Help others** learn and grow

### Communication

- **Be clear** in issues and PRs
- **Provide context** for changes
- **Ask questions** if unsure
- **Thank contributors** for their work

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Credited in release notes
- Thanked in the community

## Questions?

- **Open an issue** for questions
- **Check existing issues** first
- **Be specific** about what you need help with

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing!** 🎉

Your contributions help make this bootcamp better for everyone learning developer tools.
