# Day 22 Quiz: CI/CD with GitHub Actions

Test your understanding of GitHub Actions and CI/CD pipeline concepts.

## Question 1: Workflow Triggers
Which event trigger runs a workflow when code is pushed to the main branch?

A) `on: push`  
B) `on: push: branches: [main]`  
C) `on: main`  
D) `on: commit`  

<details>
<summary>Answer</summary>

**B) `on: push: branches: [main]`**

This syntax specifically triggers the workflow only when code is pushed to the main branch, not on pushes to other branches.
</details>

---

## Question 2: Job Dependencies
How do you make a job wait for another job to complete successfully?

A) `depends_on: job-name`  
B) `needs: job-name`  
C) `requires: job-name`  
D) `after: job-name`  

<details>
<summary>Answer</summary>

**B) `needs: job-name`**

The `needs` keyword creates dependencies between jobs, ensuring one job completes successfully before another starts.
</details>

---

## Question 3: Matrix Strategy
What does a matrix strategy allow you to do?

A) Run jobs in parallel only  
B) Run the same job with different configurations  
C) Create job dependencies  
D) Cache build artifacts  

<details>
<summary>Answer</summary>

**B) Run the same job with different configurations**

Matrix strategies allow you to run the same job multiple times with different parameter combinations (e.g., different Python versions, operating systems).
</details>

---

## Question 4: Secrets Management
How should you handle sensitive data like API keys in GitHub Actions?

A) Hard-code them in the workflow file  
B) Use environment variables directly  
C) Store them as repository secrets  
D) Include them in the repository  

<details>
<summary>Answer</summary>

**C) Store them as repository secrets**

GitHub repository secrets provide secure storage for sensitive data and are accessed using `${{ secrets.SECRET_NAME }}` syntax.
</details>

---

## Question 5: Caching
What is the primary benefit of using caching in GitHub Actions?

A) Improved security  
B) Faster build times  
C) Better error handling  
D) Automatic deployments  

<details>
<summary>Answer</summary>

**B) Faster build times**

Caching stores dependencies and build artifacts between workflow runs, significantly reducing build times by avoiding repeated downloads and installations.
</details>

---

## Question 6: Docker Integration
Which action is used to build and push Docker images in GitHub Actions?

A) `docker/build-action`  
B) `docker/build-push-action`  
C) `actions/docker-build`  
D) `github/docker-push`  

<details>
<summary>Answer</summary>

**B) `docker/build-push-action`**

This is the official Docker action for building and optionally pushing Docker images to registries within GitHub Actions workflows.
</details>

---

## Question 7: Environment Protection
What is the purpose of environment protection rules?

A) To encrypt workflow files  
B) To require manual approval for deployments  
C) To cache environment variables  
D) To run jobs in parallel  

<details>
<summary>Answer</summary>

**B) To require manual approval for deployments**

Environment protection rules add security gates, requiring manual approval or specific reviewers before deploying to sensitive environments like production.
</details>

---

## Question 8: Conditional Execution
How do you run a job only when the previous job succeeds?

A) `if: success()`  
B) `if: ${{ success() }}`  
C) `when: success`  
D) `condition: success`  

<details>
<summary>Answer</summary>

**B) `if: ${{ success() }}`**

The `if` condition with `${{ success() }}` function ensures a job only runs when all previous jobs in the dependency chain succeed.
</details>

---

## Question 9: Artifact Management
What are GitHub Actions artifacts used for?

A) Storing workflow configurations  
B) Sharing files between jobs and workflow runs  
C) Managing repository secrets  
D) Triggering other workflows  

<details>
<summary>Answer</summary>

**B) Sharing files between jobs and workflow runs**

Artifacts allow you to persist and share files (like test reports, build outputs) between jobs in the same workflow run or across different runs.
</details>

---

## Question 10: Reusable Workflows
What is the main advantage of reusable workflows?

A) Faster execution times  
B) Better security  
C) Code reuse and consistency across repositories  
D) Automatic error handling  

<details>
<summary>Answer</summary>

**C) Code reuse and consistency across repositories**

Reusable workflows allow you to define common workflow patterns once and use them across multiple repositories, promoting consistency and reducing duplication.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand GitHub Actions and CI/CD well.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're learning. Practice more with workflow creation.
- **Below 4**: Review the lesson material and try the hands-on exercises.

## Practical Challenge

Design a CI/CD pipeline for this scenario:

**Requirements:**
- Python web application with tests
- Multi-environment deployment (staging → production)
- Security scanning before deployment
- Docker containerization
- Manual approval for production
- Notification on failures

**Solution:**
```yaml
name: Complete CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  # Stage 1: Test and Quality
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
      - name: Install and test
        run: |
          pip install -r requirements.txt
          pytest --cov=src

  # Stage 2: Security Scan
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          exit-code: '1'

  # Stage 3: Build Docker Image
  build:
    needs: [test, security]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: docker/build-push-action@v4
        with:
          push: true
          tags: myapp:${{ github.sha }}

  # Stage 4: Deploy to Staging
  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to staging
        run: echo "Deploying to staging"

  # Stage 5: Deploy to Production
  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production  # Requires manual approval
    steps:
      - name: Deploy to production
        run: echo "Deploying to production"

  # Stage 6: Notify on Failure
  notify:
    needs: [test, security, build, deploy-staging, deploy-production]
    runs-on: ubuntu-latest
    if: failure()
    steps:
      - name: Notify team
        uses: 8398a7/action-slack@v3
        with:
          status: failure
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Workflow Patterns

### Common Patterns:

1. **Multi-Stage Pipeline**
   ```yaml
   jobs:
     test → security → build → deploy-staging → deploy-production
   ```

2. **Matrix Testing**
   ```yaml
   strategy:
     matrix:
       python-version: [3.8, 3.9, '3.10']
       os: [ubuntu-latest, windows-latest]
   ```

3. **Conditional Deployment**
   ```yaml
   if: github.ref == 'refs/heads/main' && github.event_name == 'push'
   ```

4. **Environment Protection**
   ```yaml
   environment: production  # Requires approval
   ```

## Next Steps

Tomorrow (Day 23) we'll learn automated testing strategies, building on these CI/CD foundations to create comprehensive test automation.

## Key Takeaways

- GitHub Actions automate development workflows with YAML configuration
- Matrix strategies enable testing across multiple configurations
- Job dependencies create structured pipeline stages
- Secrets management protects sensitive configuration data
- Environment protection adds security gates for deployments
- Caching improves build performance significantly
- Conditional execution provides flexible workflow control
- Reusable workflows promote consistency across projects
- Proper error handling and notifications improve reliability
