# Day 24 Quiz: Package Management

Test your understanding of Python package management with pip, poetry, and uv.

## Questions

### 1. Which command creates a lock file with exact dependency versions using pip?
a) `pip install --lock`
b) `pip freeze > requirements.lock`
c) `pip lock dependencies`
d) `pip generate-lock`

### 2. What is the main advantage of using constraints files with pip?
a) Faster installation
b) Reproducible builds across environments
c) Automatic security scanning
d) Better error messages

### 3. In Poetry, which file contains the exact versions of all dependencies?
a) `pyproject.toml`
b) `requirements.txt`
c) `poetry.lock`
d) `dependencies.lock`

### 4. Which Poetry command adds a development dependency?
a) `poetry add --dev pytest`
b) `poetry add --group dev pytest`
c) `poetry install --dev pytest`
d) `poetry dev add pytest`

### 5. What makes uv significantly faster than pip?
a) Written in Rust with parallel processing
b) Uses a different package index
c) Caches more aggressively
d) Skips dependency resolution

### 6. Which tool should you use to check for security vulnerabilities in Python packages?
a) `pip check`
b) `pip-audit` or `safety`
c) `pip scan`
d) `pip security`

### 7. What is the correct way to specify a version range that allows patch updates but not minor updates?
a) `pandas>=2.1.0`
b) `pandas~=2.1.0`
c) `pandas^=2.1.0`
d) `pandas==2.1.*`

### 8. In a multi-stage Docker build with Poetry, why install dependencies in a separate stage?
a) Better security
b) Smaller final image size
c) Faster builds
d) All of the above

### 9. Which environment variable should contain sensitive configuration values?
a) Store directly in code
b) Use `.env` files in version control
c) Environment variables or encrypted secrets
d) Configuration files

### 10. What is the recommended approach for managing different dependency sets (dev, test, prod)?
a) Separate requirements files
b) Poetry dependency groups
c) uv optional dependencies
d) All of the above are valid approaches

## Answers

### 1. b) `pip freeze > requirements.lock`
**Explanation**: `pip freeze` outputs all installed packages with exact versions, which can be redirected to a lock file for reproducible installations.

### 2. b) Reproducible builds across environments
**Explanation**: Constraints files pin exact versions of dependencies, ensuring the same versions are installed across different environments and team members.

### 3. c) `poetry.lock`
**Explanation**: The `poetry.lock` file contains the exact versions of all dependencies and their sub-dependencies, ensuring reproducible installations.

### 4. b) `poetry add --group dev pytest`
**Explanation**: Modern Poetry uses `--group dev` to add development dependencies. The older `--dev` flag is deprecated.

### 5. a) Written in Rust with parallel processing
**Explanation**: uv is written in Rust and uses parallel processing for dependency resolution and installation, making it significantly faster than pip.

### 6. b) `pip-audit` or `safety`
**Explanation**: Both `pip-audit` (by PyPA) and `safety` are tools specifically designed to check for known security vulnerabilities in Python packages.

### 7. b) `pandas~=2.1.0`
**Explanation**: The `~=` operator allows patch-level updates but not minor updates. `~=2.1.0` means `>=2.1.0, <2.2.0`.

### 8. d) All of the above
**Explanation**: Multi-stage builds provide better security (no build tools in final image), smaller size (only runtime dependencies), and faster builds (better caching).

### 9. c) Environment variables or encrypted secrets
**Explanation**: Sensitive values should never be in code or version control. Use environment variables or encrypted secret management systems.

### 10. d) All of the above are valid approaches
**Explanation**: Different tools have different approaches: pip uses separate requirements files, Poetry uses dependency groups, and uv uses optional dependencies. All are valid patterns.

## Scoring

- **8-10 correct**: Excellent! You have a strong understanding of modern Python package management.
- **6-7 correct**: Good job! Review the concepts you missed, particularly around security and reproducibility.
- **4-5 correct**: You're getting there. Focus on understanding the differences between tools and best practices.
- **0-3 correct**: Review the lesson material and practice with the exercises to build your foundation.

## Key Takeaways

1. **Lock files are essential** for reproducible builds
2. **Security scanning** should be part of your workflow
3. **Different tools** have different strengths (pip: simple, poetry: full-featured, uv: fast)
4. **Environment separation** prevents conflicts between projects
5. **Proper version pinning** balances stability and updates
6. **CI/CD integration** automates quality and security checks
7. **Docker optimization** reduces image size and improves security
8. **Secret management** keeps sensitive data secure
9. **Dependency groups** organize different types of dependencies
10. **Tool configuration** improves team collaboration and consistency
