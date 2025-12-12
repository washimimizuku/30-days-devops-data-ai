#!/bin/bash

# Day 22: CI/CD with GitHub Actions - Solution Guide
# Reference solutions for GitHub Actions workflows

echo "📚 Day 22: CI/CD with GitHub Actions - Solution Guide"
echo "====================================================="

echo ""
echo "🎯 Solution 1: Basic CI Workflow"
echo "================================"

cat << 'EOF'
# .github/workflows/ci.yml
name: Continuous Integration

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Cache dependencies
        uses: actions/cache@v3
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements*.txt') }}
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-cov flake8 black
      
      - name: Lint with flake8
        run: flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
      
      - name: Test with pytest
        run: pytest --cov=./ --cov-report=xml
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
EOF

echo ""
echo "🎯 Solution 2: Docker Build and Push"
echo "===================================="

cat << 'EOF'
# .github/workflows/docker.yml
name: Docker Build and Push

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=sha,prefix={{branch}}-
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
EOF

echo ""
echo "🎯 Solution 3: Multi-Environment Deployment"
echo "==========================================="

cat << 'EOF'
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
  release:
    types: [published]

jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to staging
        run: |
          echo "Deploying to staging"
          # Add deployment commands
        env:
          DEPLOY_URL: ${{ secrets.STAGING_URL }}
          DEPLOY_TOKEN: ${{ secrets.STAGING_TOKEN }}
      
      - name: Run smoke tests
        run: |
          # Add smoke test commands
          curl -f ${{ secrets.STAGING_URL }}/health

  deploy-production:
    runs-on: ubuntu-latest
    environment: production
    needs: deploy-staging
    if: github.event_name == 'release'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to production
        run: |
          echo "Deploying to production"
          # Add production deployment commands
        env:
          DEPLOY_URL: ${{ secrets.PROD_URL }}
          DEPLOY_TOKEN: ${{ secrets.PROD_TOKEN }}
EOF

echo ""
echo "🎯 Solution 4: Security Scanning"
echo "==============================="

cat << 'EOF'
# .github/workflows/security.yml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * 1'  # Weekly

jobs:
  security:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy scan results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'
      
      - name: Docker image scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'myapp:latest'
          format: 'table'
          exit-code: '1'
          severity: 'CRITICAL,HIGH'
      
      - name: Run Bandit security linter
        run: |
          pip install bandit
          bandit -r . -f json -o bandit-report.json
      
      - name: Upload security reports
        uses: actions/upload-artifact@v3
        with:
          name: security-reports
          path: |
            trivy-results.sarif
            bandit-report.json
EOF

echo ""
echo "🎯 Solution 5: Reusable Workflows"
echo "================================="

cat << 'EOF'
# .github/workflows/reusable-test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      python-version:
        required: false
        type: string
        default: '3.9'
      coverage:
        required: false
        type: boolean
        default: true
    outputs:
      coverage-percentage:
        description: "Test coverage percentage"
        value: ${{ jobs.test.outputs.coverage }}

jobs:
  test:
    runs-on: ubuntu-latest
    outputs:
      coverage: ${{ steps.coverage.outputs.percentage }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python ${{ inputs.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ inputs.python-version }}
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov
      
      - name: Run tests
        run: |
          if [ "${{ inputs.coverage }}" = "true" ]; then
            pytest --cov=./ --cov-report=term-missing
          else
            pytest
          fi
      
      - name: Extract coverage
        id: coverage
        if: inputs.coverage
        run: |
          COVERAGE=$(pytest --cov=./ --cov-report=term | grep TOTAL | awk '{print $4}')
          echo "percentage=$COVERAGE" >> $GITHUB_OUTPUT

# Using the reusable workflow
# .github/workflows/main.yml
name: Main Pipeline

on: [push, pull_request]

jobs:
  test-python-39:
    uses: ./.github/workflows/reusable-test.yml
    with:
      python-version: '3.9'
      coverage: true
  
  test-python-310:
    uses: ./.github/workflows/reusable-test.yml
    with:
      python-version: '3.10'
      coverage: false
EOF

echo ""
echo "🎯 Solution 6: Advanced Patterns"
echo "==============================="

cat << 'EOF'
# Conditional workflows based on file changes
name: Conditional Build

on: [push]

jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      backend: ${{ steps.changes.outputs.backend }}
      frontend: ${{ steps.changes.outputs.frontend }}
    steps:
      - uses: actions/checkout@v3
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            backend:
              - 'backend/**'
            frontend:
              - 'frontend/**'

  build-backend:
    needs: changes
    if: ${{ needs.changes.outputs.backend == 'true' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build backend
        run: echo "Building backend"

  build-frontend:
    needs: changes
    if: ${{ needs.changes.outputs.frontend == 'true' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build frontend
        run: echo "Building frontend"

# Matrix with exclusions
name: Matrix Build

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
        os: [ubuntu-latest, windows-latest, macos-latest]
        exclude:
          - python-version: 3.8
            os: macos-latest
          - python-version: '3.10'
            os: windows-latest
    
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - run: python --version
EOF

echo ""
echo "🎯 Solution 7: Performance and Monitoring"
echo "========================================="

cat << 'EOF'
# Performance testing workflow
name: Performance Tests

on:
  push:
    branches: [main]
  schedule:
    - cron: '0 1 * * *'  # Daily at 1 AM

jobs:
  performance:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up environment
        run: |
          docker-compose up -d
          sleep 30  # Wait for services to be ready
      
      - name: Run load tests
        run: |
          # Install artillery or k6
          npm install -g artillery
          artillery run load-test.yml
      
      - name: Collect performance metrics
        run: |
          # Collect metrics from monitoring system
          curl -s http://localhost:9090/api/v1/query?query=up > metrics.json
      
      - name: Performance regression check
        run: |
          # Compare with baseline performance
          python scripts/check-performance.py metrics.json
      
      - name: Upload performance results
        uses: actions/upload-artifact@v3
        with:
          name: performance-results
          path: |
            artillery-report.json
            metrics.json

# Notification workflow
name: Notifications

on:
  workflow_run:
    workflows: ["CI", "Deploy"]
    types: [completed]

jobs:
  notify:
    runs-on: ubuntu-latest
    if: ${{ github.event.workflow_run.conclusion == 'failure' }}
    
    steps:
      - name: Notify Slack on failure
        uses: 8398a7/action-slack@v3
        with:
          status: failure
          channel: '#deployments'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
      
      - name: Create GitHub issue on failure
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `Workflow failure: ${context.payload.workflow_run.name}`,
              body: `Workflow ${context.payload.workflow_run.name} failed. Please investigate.`,
              labels: ['bug', 'ci-failure']
            })
EOF

echo ""
echo "🎯 Solution 8: Complete Production Pipeline"
echo "==========================================="

cat << 'EOF'
# Complete production-ready pipeline
name: Production Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  release:
    types: [published]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # Stage 1: Code Quality and Testing
  quality-gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov flake8 black isort mypy bandit
      
      - name: Code quality checks
        run: |
          black --check .
          isort --check-only .
          flake8 .
          mypy src/
          bandit -r src/
      
      - name: Run tests
        run: pytest --cov=src --cov-report=xml --cov-fail-under=80
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  # Stage 2: Security Scanning
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          exit-code: '1'
          severity: 'CRITICAL,HIGH'

  # Stage 3: Build and Push
  build:
    needs: [quality-gate, security-scan]
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    outputs:
      image: ${{ steps.image.outputs.image }}
    
    steps:
      - uses: actions/checkout@v3
      - uses: docker/setup-buildx-action@v2
      - uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          push: true
          tags: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
      
      - name: Output image
        id: image
        run: echo "image=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}" >> $GITHUB_OUTPUT

  # Stage 4: Deploy to Staging
  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Deploy to staging
        run: |
          echo "Deploying ${{ needs.build.outputs.image }} to staging"
          # Add actual deployment commands
      
      - name: Integration tests
        run: |
          # Run integration tests against staging
          echo "Running integration tests"

  # Stage 5: Deploy to Production
  deploy-production:
    needs: [build, deploy-staging]
    runs-on: ubuntu-latest
    environment: production
    if: github.event_name == 'release'
    
    steps:
      - name: Blue-green deployment
        run: |
          echo "Performing blue-green deployment"
          echo "Image: ${{ needs.build.outputs.image }}"
          # Add blue-green deployment logic
      
      - name: Post-deployment verification
        run: |
          # Verify production deployment
          echo "Verifying production deployment"
EOF

echo ""
echo "🎯 Solution 9: Workflow Best Practices"
echo "======================================"

cat << 'EOF'
# Best practices for GitHub Actions workflows

1. Use specific action versions
   - ✅ uses: actions/checkout@v3
   - ❌ uses: actions/checkout@main

2. Cache dependencies for faster builds
   - uses: actions/cache@v3
     with:
       path: ~/.cache/pip
       key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}

3. Use matrix strategies for multi-version testing
   strategy:
     matrix:
       python-version: [3.8, 3.9, '3.10']
       os: [ubuntu-latest, windows-latest]

4. Implement proper error handling
   - name: Deploy with retry
     uses: nick-invision/retry@v2
     with:
       timeout_minutes: 10
       max_attempts: 3
       command: ./deploy.sh

5. Use environment protection for sensitive deployments
   environment: production  # Requires approval

6. Implement security scanning
   - Trivy for vulnerability scanning
   - Bandit for Python security issues
   - CodeQL for code analysis

7. Use secrets for sensitive data
   env:
     API_KEY: ${{ secrets.API_KEY }}

8. Optimize workflow performance
   - Use caching
   - Conditional execution
   - Parallel jobs where possible

9. Monitor and notify on failures
   - Slack notifications
   - GitHub issue creation
   - Email alerts

10. Document workflows
    - Clear job and step names
    - Comments for complex logic
    - README documentation
EOF

echo ""
echo "🎯 Solution 10: Troubleshooting Guide"
echo "====================================="

cat << 'EOF'
# Common GitHub Actions issues and solutions

1. Workflow not triggering
   - Check trigger conditions (branches, paths, events)
   - Verify YAML syntax
   - Check repository permissions

2. Permission denied errors
   - Add required permissions to job
   - Check GITHUB_TOKEN permissions
   - Verify repository settings

3. Cache not working
   - Check cache key uniqueness
   - Verify cache paths
   - Monitor cache hit rates

4. Secrets not accessible
   - Verify secret names (case-sensitive)
   - Check environment restrictions
   - Confirm secret scope (repo vs organization)

5. Matrix builds failing
   - Check matrix combinations
   - Use exclude for unsupported combinations
   - Verify matrix variable usage

6. Docker build issues
   - Check Dockerfile syntax
   - Verify build context
   - Monitor build cache usage

7. Deployment failures
   - Check environment protection rules
   - Verify deployment credentials
   - Monitor deployment logs

8. Performance issues
   - Use caching effectively
   - Optimize Docker layers
   - Parallelize independent jobs

9. Debugging workflows
   - Add debug logging
   - Use tmate for interactive debugging
   - Check runner logs

10. Security concerns
    - Scan for vulnerabilities regularly
    - Use least privilege principles
    - Rotate secrets periodically
EOF

echo ""
echo "🎉 Solutions Complete!"
echo "====================="
echo ""
echo "Key GitHub Actions concepts mastered:"
echo "✅ Workflow triggers and events"
echo "✅ Job dependencies and conditions"
echo "✅ Matrix strategies for multi-version testing"
echo "✅ Docker integration and container registries"
echo "✅ Security scanning and quality gates"
echo "✅ Multi-environment deployments"
echo "✅ Secrets and environment management"
echo "✅ Reusable workflows and advanced patterns"
echo "✅ Performance optimization and monitoring"
echo "✅ Error handling and notifications"
echo ""
echo "💡 Remember:"
echo "   - Use specific action versions for reproducibility"
echo "   - Implement proper security scanning and quality gates"
echo "   - Cache dependencies for faster builds"
echo "   - Use environment protection for production deployments"
echo "   - Monitor workflow performance and optimize accordingly"
echo "   - Document workflows clearly for team collaboration"
