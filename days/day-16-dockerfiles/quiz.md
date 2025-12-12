# Day 16 Quiz: Dockerfiles

Test your understanding of creating custom Docker images with Dockerfiles.

## Question 1: Dockerfile Instructions
Which Dockerfile instruction sets the working directory inside the container?

A) `WORKDIR`  
B) `DIRECTORY`  
C) `SETDIR`  
D) `CD`  

<details>
<summary>Answer</summary>

**A) `WORKDIR`**

`WORKDIR` sets the working directory for subsequent instructions like `RUN`, `CMD`, `COPY`, and `ADD`.
</details>

---

## Question 2: Layer Optimization
Why should you copy `requirements.txt` before copying the entire application code?

A) It's required by Docker  
B) To leverage Docker's layer caching for dependencies  
C) To reduce image size  
D) To improve security  

<details>
<summary>Answer</summary>

**B) To leverage Docker's layer caching for dependencies**

Dependencies change less frequently than application code. Copying requirements first allows Docker to cache the dependency installation layer.
</details>

---

## Question 3: Multi-stage Builds
What is the primary benefit of multi-stage Docker builds?

A) Faster build times  
B) Better security  
C) Smaller final image size  
D) Easier debugging  

<details>
<summary>Answer</summary>

**C) Smaller final image size**

Multi-stage builds allow you to use a larger image for building/compiling and copy only the necessary artifacts to a smaller production image.
</details>

---

## Question 4: CMD vs ENTRYPOINT
What's the difference between `CMD` and `ENTRYPOINT`?

A) No difference, they're aliases  
B) `CMD` can be overridden, `ENTRYPOINT` cannot  
C) `ENTRYPOINT` sets the fixed command, `CMD` provides default arguments  
D) `CMD` is for development, `ENTRYPOINT` for production  

<details>
<summary>Answer</summary>

**C) `ENTRYPOINT` sets the fixed command, `CMD` provides default arguments**

`ENTRYPOINT` defines the executable that will always run, while `CMD` provides default arguments that can be overridden.
</details>

---

## Question 5: Build Arguments
How do you pass a build-time variable to a Dockerfile?

A) `ENV BUILD_VAR=value`  
B) `ARG BUILD_VAR=value`  
C) `SET BUILD_VAR=value`  
D) `VAR BUILD_VAR=value`  

<details>
<summary>Answer</summary>

**B) `ARG BUILD_VAR=value`**

`ARG` defines build-time variables that can be passed using `docker build --build-arg BUILD_VAR=value`.
</details>

---

## Question 6: Security Best Practice
Which practice improves Docker container security?

A) Always use `FROM ubuntu:latest`  
B) Run applications as root user  
C) Create and use a non-root user  
D) Include all system tools in the image  

<details>
<summary>Answer</summary>

**C) Create and use a non-root user**

Running containers as non-root users reduces security risks by limiting potential damage from compromised applications.
</details>

---

## Question 7: .dockerignore
What is the purpose of a `.dockerignore` file?

A) To ignore Docker commands  
B) To exclude files from the build context  
C) To hide the Dockerfile  
D) To ignore container logs  

<details>
<summary>Answer</summary>

**B) To exclude files from the build context**

`.dockerignore` prevents unnecessary files from being sent to the Docker daemon, reducing build context size and build time.
</details>

---

## Question 8: Layer Minimization
Which approach creates fewer Docker layers?

A) Multiple separate `RUN` commands  
B) Combining commands with `&&` in a single `RUN`  
C) Using multiple `COPY` commands  
D) Separate `ENV` commands for each variable  

<details>
<summary>Answer</summary>

**B) Combining commands with `&&` in a single `RUN`**

Each Dockerfile instruction creates a new layer. Combining commands in a single `RUN` instruction reduces the number of layers.
</details>

---

## Question 9: Health Checks
What does the `HEALTHCHECK` instruction do?

A) Checks if the image is valid  
B) Monitors container resource usage  
C) Defines how to test if the container is healthy  
D) Validates the Dockerfile syntax  

<details>
<summary>Answer</summary>

**C) Defines how to test if the container is healthy**

`HEALTHCHECK` tells Docker how to test if a container is still working properly by running a specified command.
</details>

---

## Question 10: Build Context
What happens when you run `docker build .`?

A) Builds from the current directory as context  
B) Builds all Dockerfiles in the directory  
C) Creates a new Dockerfile  
D) Runs the built container  

<details>
<summary>Answer</summary>

**A) Builds from the current directory as context**

The `.` specifies the current directory as the build context, which is sent to the Docker daemon for building the image.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand Dockerfile creation well.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're learning. Practice more with the exercises.
- **Below 4**: Review the lesson material and try building some Dockerfiles.

## Practical Challenge

Create a Dockerfile for this scenario:

**Requirements:**
- Python 3.9 web application
- Install dependencies from `requirements.txt`
- Copy application code to `/app`
- Run as non-root user
- Expose port 8000
- Include health check

**Solution:**
```dockerfile
FROM python:3.9-slim

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy and install dependencies first
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8000/health || exit 1

# Run application
CMD ["python", "app.py"]
```

## Next Steps

Tomorrow (Day 17) we'll learn Docker Compose to orchestrate multi-container applications, building on these custom image creation skills.

## Key Takeaways

- Dockerfiles automate image creation with repeatable instructions
- Layer optimization improves build speed and reduces image size
- Multi-stage builds create smaller production images
- Security practices include non-root users and specific versions
- Build arguments provide flexibility for different environments
- Health checks enable container monitoring and orchestration
