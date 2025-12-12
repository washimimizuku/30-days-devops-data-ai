# Day 17 Quiz: Docker Compose

Test your understanding of multi-container orchestration with Docker Compose.

## Question 1: Docker Compose Purpose
What is the primary benefit of using Docker Compose?

A) It makes containers run faster  
B) It manages multi-container applications declaratively  
C) It replaces Docker entirely  
D) It only works with web applications  

<details>
<summary>Answer</summary>

**B) It manages multi-container applications declaratively**

Docker Compose allows you to define and manage multi-container applications using a YAML file, making complex deployments simple and reproducible.
</details>

---

## Question 2: Service Communication
How do services communicate with each other in Docker Compose?

A) Using IP addresses only  
B) Through external networks only  
C) Using service names as hostnames  
D) Communication is not possible  

<details>
<summary>Answer</summary>

**C) Using service names as hostnames**

Docker Compose automatically creates a network where services can communicate using their service names as hostnames (e.g., `http://database:5432`).
</details>

---

## Question 3: Volume Types
What's the difference between named volumes and bind mounts in Docker Compose?

A) No difference, they're the same  
B) Named volumes are managed by Docker, bind mounts link to host paths  
C) Bind mounts are faster than named volumes  
D) Named volumes only work in production  

<details>
<summary>Answer</summary>

**B) Named volumes are managed by Docker, bind mounts link to host paths**

Named volumes (`volume_name:/container/path`) are managed by Docker, while bind mounts (`./host/path:/container/path`) directly link to host filesystem paths.
</details>

---

## Question 4: Service Dependencies
What does `depends_on` do in a Docker Compose service definition?

A) Makes services run in parallel  
B) Controls the startup order of services  
C) Ensures services are healthy before starting  
D) Shares volumes between services  

<details>
<summary>Answer</summary>

**B) Controls the startup order of services**

`depends_on` ensures that dependent services start before the current service, but doesn't wait for them to be ready (use health checks for that).
</details>

---

## Question 5: Environment Variables
Which is NOT a valid way to set environment variables in Docker Compose?

A) `environment:` section in service definition  
B) `env_file:` pointing to a .env file  
C) `ENV` instruction in docker-compose.yml  
D) Command line with `--env-file`  

<details>
<summary>Answer</summary>

**C) `ENV` instruction in docker-compose.yml**

`ENV` is a Dockerfile instruction, not a Docker Compose directive. Use `environment:` or `env_file:` in compose files.
</details>

---

## Question 6: Scaling Services
How do you scale a service to 3 instances with Docker Compose?

A) `docker-compose scale service=3`  
B) `docker-compose up --scale service=3`  
C) `docker-compose replicas service 3`  
D) `docker-compose multiply service 3`  

<details>
<summary>Answer</summary>

**B) `docker-compose up --scale service=3`**

The `--scale` flag with `docker-compose up` allows you to specify the number of instances for a service.
</details>

---

## Question 7: Override Files
What is the purpose of `docker-compose.override.yml`?

A) To replace the main compose file  
B) To provide development-specific configurations  
C) To store production secrets  
D) To backup the original file  

<details>
<summary>Answer</summary>

**B) To provide development-specific configurations**

`docker-compose.override.yml` is automatically loaded and merged with `docker-compose.yml`, typically used for development-specific settings.
</details>

---

## Question 8: Health Checks
What happens when a service fails its health check in Docker Compose?

A) The service is automatically restarted  
B) The service is marked as unhealthy  
C) All services are stopped  
D) Nothing happens  

<details>
<summary>Answer</summary>

**B) The service is marked as unhealthy**

Failed health checks mark the service as unhealthy, which can be used by orchestrators and load balancers, but Docker Compose doesn't automatically restart services.
</details>

---

## Question 9: Network Configuration
What happens if you don't specify networks in a Docker Compose file?

A) Services can't communicate  
B) Docker Compose creates a default network  
C) You must create networks manually  
D) Only the first service gets network access  

<details>
<summary>Answer</summary>

**B) Docker Compose creates a default network**

Docker Compose automatically creates a default network for all services if no networks are explicitly defined.
</details>

---

## Question 10: Production Best Practices
Which is a Docker Compose best practice for production?

A) Use `latest` tags for all images  
B) Mount source code as volumes  
C) Use specific image versions and health checks  
D) Run all services as root  

<details>
<summary>Answer</summary>

**C) Use specific image versions and health checks**

Production deployments should use specific image versions (not `latest`) and implement health checks for reliability and predictability.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand Docker Compose well.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're learning. Practice more with the exercises.
- **Below 4**: Review the lesson material and try building some compose applications.

## Practical Challenge

Create a Docker Compose file for this scenario:

**Requirements:**
- Web application (Python Flask) on port 8000
- PostgreSQL database with persistent storage
- Redis cache
- All services should be able to communicate
- Include health checks

**Solution:**
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 3

volumes:
  postgres_data:
```

## Next Steps

Tomorrow (Day 18) we'll dive deeper into Docker volumes and networking, building on this multi-container orchestration knowledge.

## Key Takeaways

- Docker Compose simplifies multi-container application management
- Services communicate using service names as hostnames
- Volumes provide data persistence and file sharing
- Environment variables configure service behavior
- Health checks enable reliable service monitoring
- Override files support environment-specific configurations
- Scaling allows horizontal service expansion
