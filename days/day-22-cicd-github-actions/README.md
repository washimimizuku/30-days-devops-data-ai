# Day 22: CI/CD with GitHub Actions

**Duration**: 1 hour  
**Prerequisites**: Week 3 (Docker & Containers), Day 21 (Containerized Platform)

## Learning Objectives

By the end of this lesson, you will:
- Understand CI/CD concepts and benefits
- Create GitHub Actions workflows for automated testing
- Implement automated Docker image building and publishing
- Set up deployment pipelines with multiple environments
- Configure security scanning and quality gates
- Use secrets and environment variables securely
- Implement advanced workflow patterns

## CI/CD Fundamentals

### What is CI/CD?

**Continuous Integration (CI)**:
- Automatically build and test code changes
- Merge code frequently to detect issues early
- Run automated tests on every commit
- Provide fast feedback to developers

**Continuous Deployment (CD)**:
- Automatically deploy tested code to environments
- Reduce manual deployment errors
- Enable rapid, reliable releases
- Support rollback capabilities

### Benefits of CI/CD

- **Faster Development**: Automated processes reduce manual work
- **Higher Quality**: Automated testing catches bugs early
- **Reduced Risk**: Small, frequent deployments are safer
- **Better Collaboration**: Standardized processes for all team members
- **Faster Time to Market**: Automated deployments enable rapid releases

## GitHub Actions Overview

### Core Concepts

**Workflow**: Automated process defined in YAML files
**Job**: Set of steps that execute on the same runner
**Step**: Individual task within a job
**Action**: Reusable unit of code for a step
**Runner**: Server that executes workflows
**Event**: Trigger that starts a workflow

### Workflow Structure

```yaml
name: Workflow Name
on: [push, pull_request]  # Events that trigger workflow

jobs:
  job-name:
    runs-on: ubuntu-latest  # Runner environment
    steps:
      - uses: actions/checkout@v3  # Use an action
      - name: Step name
        run: echo "Hello World"   # Run a command
```

## Basic Workflows

### Simple CI Workflow

**.github/workflows/ci.yml**
```yaml
name: Continuous Integration

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-cov
      
      - name: Run tests
        run: |
          pytest --cov=src --cov-report=xml
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
```

### Multi-Language Testing

```yaml
name: Multi-Language CI

on: [push, pull_request]

jobs:
  test-python:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
    
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - run: |
          pip install -r requirements.txt
          pytest

  test-node:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [16, 18, 20]
    
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - run: |
          npm ci
          npm test
```

## Docker Integration

### Build and Push Docker Images

```yaml
name: Docker Build and Push

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
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
            type=semver,pattern={{major}}.{{minor}}
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Multi-Service Docker Build

```yaml
name: Multi-Service Build

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [api, frontend, worker]
    
    steps:
      - uses: actions/checkout@v3
      - uses: docker/setup-buildx-action@v2
      - uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Build and push ${{ matrix.service }}
        uses: docker/build-push-action@v4
        with:
          context: ./${{ matrix.service }}
          push: true
          tags: ghcr.io/${{ github.repository }}/${{ matrix.service }}:${{ github.sha }}
```

## Security and Quality Gates

### Security Scanning

```yaml
name: Security Scan

on: [push, pull_request]

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
```

### Code Quality Checks

```yaml
name: Code Quality

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      
      - name: Install quality tools
        run: |
          pip install flake8 black isort mypy bandit
      
      - name: Code formatting check
        run: black --check .
      
      - name: Import sorting check
        run: isort --check-only .
      
      - name: Linting
        run: flake8 .
      
      - name: Type checking
        run: mypy src/
      
      - name: Security check
        run: bandit -r src/
      
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

## Deployment Workflows

### Multi-Environment Deployment

```yaml
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
          echo "Deploying to staging environment"
          # Add staging deployment commands
        env:
          STAGING_URL: ${{ secrets.STAGING_URL }}
          STAGING_TOKEN: ${{ secrets.STAGING_TOKEN }}
  
  deploy-production:
    runs-on: ubuntu-latest
    environment: production
    if: github.event_name == 'release'
    needs: [deploy-staging]
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to production
        run: |
          echo "Deploying to production environment"
          # Add production deployment commands
        env:
          PROD_URL: ${{ secrets.PROD_URL }}
          PROD_TOKEN: ${{ secrets.PROD_TOKEN }}
```

### Blue-Green Deployment

```yaml
name: Blue-Green Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Determine current environment
        id: current
        run: |
          CURRENT=$(curl -s ${{ secrets.HEALTH_CHECK_URL }}/version | jq -r '.environment')
          NEW_ENV=$([ "$CURRENT" = "blue" ] && echo "green" || echo "blue")
          echo "current=$CURRENT" >> $GITHUB_OUTPUT
          echo "new=$NEW_ENV" >> $GITHUB_OUTPUT
      
      - name: Deploy to ${{ steps.current.outputs.new }} environment
        run: |
          echo "Deploying to ${{ steps.current.outputs.new }} environment"
          # Deploy to new environment
          
      - name: Health check
        run: |
          # Wait for deployment and run health checks
          sleep 60
          curl -f ${{ secrets.NEW_ENV_URL }}/health
      
      - name: Switch traffic
        run: |
          echo "Switching traffic to ${{ steps.current.outputs.new }}"
          # Update load balancer configuration
      
      - name: Cleanup old environment
        run: |
          echo "Cleaning up ${{ steps.current.outputs.current }} environment"
          # Remove old environment
```

## Advanced Patterns

### Conditional Workflows

```yaml
name: Conditional Deployment

on:
  push:
    paths:
      - 'src/**'
      - 'Dockerfile'
      - '.github/workflows/**'

jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      api: ${{ steps.changes.outputs.api }}
      frontend: ${{ steps.changes.outputs.frontend }}
    steps:
      - uses: actions/checkout@v3
      - uses: dorny/paths-filter@v2
        id: changes
        with:
          filters: |
            api:
              - 'api/**'
            frontend:
              - 'frontend/**'

  build-api:
    needs: changes
    if: ${{ needs.changes.outputs.api == 'true' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build API
        run: docker build -t api ./api

  build-frontend:
    needs: changes
    if: ${{ needs.changes.outputs.frontend == 'true' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Frontend
        run: docker build -t frontend ./frontend
```

### Reusable Workflows

**.github/workflows/reusable-deploy.yml**
```yaml
name: Reusable Deploy

on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      image-tag:
        required: true
        type: string
    secrets:
      deploy-token:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    
    steps:
      - name: Deploy ${{ inputs.image-tag }} to ${{ inputs.environment }}
        run: |
          echo "Deploying ${{ inputs.image-tag }} to ${{ inputs.environment }}"
        env:
          DEPLOY_TOKEN: ${{ secrets.deploy-token }}
```

**Using reusable workflow:**
```yaml
name: Main Deploy

on: [push]

jobs:
  deploy-staging:
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: staging
      image-tag: ${{ github.sha }}
    secrets:
      deploy-token: ${{ secrets.STAGING_TOKEN }}
```

### Matrix Deployments

```yaml
name: Multi-Region Deploy

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        region: [us-east-1, us-west-2, eu-west-1]
        environment: [staging, production]
        exclude:
          - environment: production
            region: us-west-2
    
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to ${{ matrix.region }} (${{ matrix.environment }})
        run: |
          echo "Deploying to ${{ matrix.region }} in ${{ matrix.environment }}"
        env:
          AWS_REGION: ${{ matrix.region }}
          ENVIRONMENT: ${{ matrix.environment }}
```

## Secrets and Environment Management

### Using Secrets

```yaml
name: Secure Deployment

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy with secrets
        run: |
          echo "Database URL: ${{ secrets.DATABASE_URL }}"
          echo "API Key: ${{ secrets.API_KEY }}"
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
```

### Environment Variables

```yaml
name: Environment Config

on: [push]

env:
  NODE_VERSION: '18'
  PYTHON_VERSION: '3.9'

jobs:
  build:
    runs-on: ubuntu-latest
    env:
      BUILD_ENV: production
    
    steps:
      - uses: actions/checkout@v3
      - name: Use environment variables
        run: |
          echo "Node version: $NODE_VERSION"
          echo "Python version: $PYTHON_VERSION"
          echo "Build environment: $BUILD_ENV"
```

## Monitoring and Notifications

### Workflow Notifications

```yaml
name: Notify on Failure

on: [push]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: pytest
      
      - name: Notify on failure
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: failure
          channel: '#deployments'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
      
      - name: Notify on success
        if: success()
        uses: 8398a7/action-slack@v3
        with:
          status: success
          channel: '#deployments'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Performance Monitoring

```yaml
name: Performance Tests

on: [push]

jobs:
  performance:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      - name: Run performance tests
        run: |
          # Start application
          docker-compose up -d
          sleep 30
          
          # Run load tests
          artillery run load-test.yml
          
          # Collect metrics
          docker stats --no-stream > performance-metrics.txt
      
      - name: Upload performance results
        uses: actions/upload-artifact@v3
        with:
          name: performance-results
          path: |
            performance-metrics.txt
            artillery-report.json
```

## Best Practices

### Workflow Organization

```yaml
name: Production Pipeline

on:
  push:
    branches: [main]

jobs:
  # Stage 1: Code Quality
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Lint and test
        run: |
          flake8 .
          pytest

  # Stage 2: Security
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Security scan
        uses: aquasecurity/trivy-action@master

  # Stage 3: Build
  build:
    needs: [lint-and-test, security-scan]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t myapp .

  # Stage 4: Deploy
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to production
        run: echo "Deploying..."
```

### Error Handling

```yaml
name: Robust Pipeline

on: [push]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy with retry
        uses: nick-invision/retry@v2
        with:
          timeout_minutes: 10
          max_attempts: 3
          command: |
            ./deploy.sh
      
      - name: Rollback on failure
        if: failure()
        run: |
          echo "Deployment failed, rolling back..."
          ./rollback.sh
      
      - name: Always cleanup
        if: always()
        run: |
          echo "Cleaning up temporary resources..."
          ./cleanup.sh
```

## Next Steps

Tomorrow (Day 23) we'll learn automated testing strategies, building on these CI/CD foundations to create comprehensive test automation.

## Key Takeaways

- GitHub Actions automates development workflows with YAML configuration
- CI/CD pipelines improve code quality and deployment reliability
- Security scanning and quality gates prevent issues from reaching production
- Multi-environment deployments enable safe, gradual rollouts
- Secrets management protects sensitive configuration data
- Conditional workflows optimize resource usage and build times
- Monitoring and notifications provide visibility into pipeline health
- Reusable workflows promote consistency across projects
