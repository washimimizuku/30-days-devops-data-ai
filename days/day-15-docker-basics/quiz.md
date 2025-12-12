# Day 15 Quiz: Docker Basics

Test your understanding of Docker fundamentals and container management.

## Question 1: Docker Architecture
What is the relationship between Docker images and containers?

A) Images and containers are the same thing  
B) Images are running instances of containers  
C) Containers are running instances of images  
D) Images are smaller versions of containers  

<details>
<summary>Answer</summary>

**C) Containers are running instances of images**

Docker images are read-only templates that contain application code and dependencies. Containers are running instances created from these images.
</details>

---

## Question 2: Docker Run Command
What does the command `docker run -it python:3.9` do?

A) Downloads Python 3.9 to the host system  
B) Runs a Python 3.9 container in interactive mode with a terminal  
C) Installs Python 3.9 in the current directory  
D) Creates a Python 3.9 image  

<details>
<summary>Answer</summary>

**B) Runs a Python 3.9 container in interactive mode with a terminal**

The `-i` flag keeps STDIN open (interactive) and `-t` allocates a pseudo-TTY (terminal), allowing you to interact with the container.
</details>

---

## Question 3: Port Mapping
In the command `docker run -p 8080:80 nginx`, what does the port mapping mean?

A) Container port 8080 maps to host port 80  
B) Host port 8080 maps to container port 80  
C) Both ports must be the same  
D) Port mapping is not needed for web servers  

<details>
<summary>Answer</summary>

**B) Host port 8080 maps to container port 80**

The format is `-p host_port:container_port`. Traffic to localhost:8080 on the host will be forwarded to port 80 inside the container.
</details>

---

## Question 4: Volume Mounting
What does `docker run -v $(pwd):/workspace python:3.9` accomplish?

A) Creates a new directory called workspace  
B) Mounts the current directory to /workspace inside the container  
C) Copies files from the container to the host  
D) Creates a backup of the current directory  

<details>
<summary>Answer</summary>

**B) Mounts the current directory to /workspace inside the container**

Volume mounting with `-v` connects host directories to container directories, allowing file sharing between host and container.
</details>

---

## Question 5: Container Lifecycle
Which command stops a running container gracefully?

A) `docker kill container_id`  
B) `docker remove container_id`  
C) `docker stop container_id`  
D) `docker pause container_id`  

<details>
<summary>Answer</summary>

**C) `docker stop container_id`**

`docker stop` sends a SIGTERM signal for graceful shutdown. `docker kill` forces termination, `docker remove` deletes stopped containers, and `docker pause` suspends processes.
</details>

---

## Question 6: Background Containers
What flag runs a container in the background (detached mode)?

A) `-b`  
B) `-d`  
C) `-bg`  
D) `--background`  

<details>
<summary>Answer</summary>

**B) `-d`**

The `-d` or `--detach` flag runs containers in the background, returning control to the terminal while the container continues running.
</details>

---

## Question 7: Container Inspection
Which command shows detailed information about a container's configuration?

A) `docker info container_id`  
B) `docker show container_id`  
C) `docker inspect container_id`  
D) `docker details container_id`  

<details>
<summary>Answer</summary>

**C) `docker inspect container_id`**

`docker inspect` returns detailed JSON-formatted information about containers, including configuration, networking, and volume details.
</details>

---

## Question 8: Environment Variables
How do you pass environment variables to a Docker container?

A) `docker run --env VAR=value image`  
B) `docker run -e VAR=value image`  
C) `docker run --environment VAR=value image`  
D) All of the above  

<details>
<summary>Answer</summary>

**D) All of the above**

Docker accepts `-e`, `--env`, and `--environment` as equivalent ways to set environment variables in containers.
</details>

---

## Question 9: Container Cleanup
What does `docker system prune` do?

A) Removes only stopped containers  
B) Removes only unused images  
C) Removes unused containers, networks, and images  
D) Removes all containers and images  

<details>
<summary>Answer</summary>

**C) Removes unused containers, networks, and images**

`docker system prune` removes stopped containers, unused networks, dangling images, and build cache to free up space.
</details>

---

## Question 10: Data Persistence
What happens to data inside a container when the container is removed?

A) Data is automatically backed up  
B) Data is lost unless stored in mounted volumes  
C) Data is moved to the host filesystem  
D) Data is preserved in the Docker daemon  

<details>
<summary>Answer</summary>

**B) Data is lost unless stored in mounted volumes**

Container filesystems are ephemeral. Data persists only if stored in mounted volumes or bind mounts that connect to the host filesystem.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand Docker fundamentals well.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're learning. Practice more with the exercises.
- **Below 4**: Review the lesson material and try the hands-on exercises.

## Practical Challenge

Try these commands to reinforce your learning:

```bash
# 1. Run a Python container and execute a simple script
docker run --rm python:3.9 python -c "print('Hello Docker!')"

# 2. Start a web server and access it from your browser
docker run -d -p 8080:80 --name test-web nginx:alpine
# Visit http://localhost:8080

# 3. Mount a directory and process a file
echo "name,age\nJohn,25\nJane,30" > data.csv
docker run --rm -v $(pwd):/data python:3.9 python -c "
import csv
with open('/data/data.csv') as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(f'{row[\"name\"]} is {row[\"age\"]} years old')
"

# 4. Clean up
docker stop test-web && docker rm test-web
rm data.csv
```

## Next Steps

Tomorrow (Day 16) we'll learn to create custom Docker images using Dockerfiles, building on these container fundamentals to package your own applications.

## Key Takeaways

- Docker containers provide consistent, portable environments
- Images are templates, containers are running instances
- Use volume mounting for data persistence
- Port mapping enables network access to containerized services
- Proper cleanup prevents resource waste
- Environment variables configure container behavior
- Docker Hub provides thousands of pre-built images
