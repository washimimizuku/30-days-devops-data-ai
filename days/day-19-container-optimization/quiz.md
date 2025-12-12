# Day 19 Quiz: Container Optimization and Best Practices

Test your understanding of production-ready container optimization techniques.

## Question 1: Multi-stage Builds
What is the primary benefit of multi-stage Docker builds?

A) Faster build times  
B) Better security  
C) Smaller final image size  
D) Easier debugging  

<details>
<summary>Answer</summary>

**C) Smaller final image size**

Multi-stage builds allow you to use larger images for building/compiling and copy only necessary artifacts to a smaller production image, significantly reducing the final image size.
</details>

---

## Question 2: Security Best Practice
Which is the most important security practice for production containers?

A) Using the latest base image  
B) Running as a non-root user  
C) Installing all available security updates  
D) Using encrypted storage  

<details>
<summary>Answer</summary>

**B) Running as a non-root user**

Running containers as non-root users significantly reduces security risks by limiting potential damage from compromised applications and following the principle of least privilege.
</details>

---

## Question 3: Resource Limits
What happens when a container exceeds its memory limit?

A) The container slows down  
B) The container is killed (OOMKilled)  
C) Docker automatically increases the limit  
D) The container continues running normally  

<details>
<summary>Answer</summary>

**B) The container is killed (OOMKilled)**

When a container exceeds its memory limit, the Linux kernel's Out-of-Memory (OOM) killer terminates the container to protect the system.
</details>

---

## Question 4: Health Checks
What is the purpose of Docker health checks?

A) To monitor CPU usage  
B) To determine if a container is functioning properly  
C) To automatically restart failed containers  
D) To scan for security vulnerabilities  

<details>
<summary>Answer</summary>

**B) To determine if a container is functioning properly**

Health checks test whether a container is working correctly by running specified commands. They help orchestrators and load balancers make routing decisions.
</details>

---

## Question 5: Image Optimization
Which Dockerfile instruction order is most efficient for caching?

A) Copy all files first, then install dependencies  
B) Install dependencies first, then copy application files  
C) Copy and install everything in one step  
D) Order doesn't matter for caching  

<details>
<summary>Answer</summary>

**B) Install dependencies first, then copy application files**

Dependencies change less frequently than application code. Installing dependencies first allows Docker to cache that layer and only rebuild when dependencies actually change.
</details>

---

## Question 6: Base Image Selection
Which base image type is generally most secure for production?

A) ubuntu:latest  
B) python:3.9  
C) python:3.9-slim  
D) scratch  

<details>
<summary>Answer</summary>

**C) python:3.9-slim**

Slim images contain fewer packages and have a smaller attack surface compared to full images, while still providing necessary runtime dependencies. Scratch is secure but only works for static binaries.
</details>

---

## Question 7: Container Monitoring
Which metric is most important for container performance monitoring?

A) Image size  
B) Build time  
C) Memory and CPU usage  
D) Number of layers  

<details>
<summary>Answer</summary>

**C) Memory and CPU usage**

Memory and CPU usage directly impact application performance and system stability. Monitoring these metrics helps identify resource bottlenecks and optimize container performance.
</details>

---

## Question 8: Security Scanning
When should you scan container images for vulnerabilities?

A) Only before production deployment  
B) Only during development  
C) As part of the CI/CD pipeline  
D) Only when security issues are reported  

<details>
<summary>Answer</summary>

**C) As part of the CI/CD pipeline**

Automated vulnerability scanning in CI/CD pipelines catches security issues early and ensures that only secure images are deployed to production.
</details>

---

## Question 9: Graceful Shutdown
What signal should applications handle for graceful shutdown in containers?

A) SIGKILL  
B) SIGTERM  
C) SIGSTOP  
D) SIGHUP  

<details>
<summary>Answer</summary>

**B) SIGTERM**

Docker sends SIGTERM to allow applications to shut down gracefully. Applications should handle this signal to close connections, save state, and clean up resources before terminating.
</details>

---

## Question 10: Production Readiness
Which is NOT a characteristic of production-ready containers?

A) Specific image versions  
B) Health checks implemented  
C) Running as root user for convenience  
D) Resource limits configured  

<details>
<summary>Answer</summary>

**C) Running as root user for convenience**

Production containers should never run as root for security reasons. All other options (specific versions, health checks, resource limits) are essential for production readiness.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand container optimization well.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're learning. Practice more with optimization techniques.
- **Below 4**: Review the lesson material and try the hands-on exercises.

## Practical Challenge

Optimize this Dockerfile for production:

**Original:**
```dockerfile
FROM python:latest
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
EXPOSE 8000
CMD ["python", "app.py"]
```

**Optimized Solution:**
```dockerfile
# Multi-stage build
FROM python:3.9-slim AS builder
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Production stage
FROM python:3.9-slim

# Create non-root user
RUN groupadd -g 1001 appuser && \
    useradd -u 1001 -g appuser -s /bin/sh appuser

# Copy packages and app
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=1001:1001 . /app

WORKDIR /app
USER 1001:1001

# Environment optimization
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

EXPOSE 8000
CMD ["python", "app.py"]
```

**Improvements:**
- Specific Python version instead of `latest`
- Multi-stage build for smaller image
- Non-root user for security
- Proper file ownership
- Environment variable optimization
- Health check for reliability

## Next Steps

Tomorrow (Day 20) we'll learn production deployment strategies, and Day 21 will be the final containerization project.

## Key Takeaways

- Multi-stage builds significantly reduce image size
- Non-root users are essential for container security
- Resource limits prevent containers from consuming excessive resources
- Health checks enable reliable service orchestration
- Vulnerability scanning should be automated in CI/CD
- Graceful shutdown handling improves application reliability
- Performance optimization requires understanding of runtime characteristics
