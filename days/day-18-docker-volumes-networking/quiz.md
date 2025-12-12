# Day 18 Quiz: Docker Volumes and Networking

Test your understanding of Docker storage and networking concepts.

## Question 1: Volume Types
What's the main difference between named volumes and bind mounts?

A) Named volumes are faster than bind mounts  
B) Named volumes are managed by Docker, bind mounts link to host paths  
C) Bind mounts are more secure than named volumes  
D) There's no difference between them  

<details>
<summary>Answer</summary>

**B) Named volumes are managed by Docker, bind mounts link to host paths**

Named volumes are created and managed by Docker in its own storage area, while bind mounts directly map host filesystem paths into containers.
</details>

---

## Question 2: Data Persistence
What happens to data in a named volume when its container is removed?

A) Data is automatically deleted  
B) Data persists until the volume is explicitly removed  
C) Data is moved to the host filesystem  
D) Data is backed up automatically  

<details>
<summary>Answer</summary>

**B) Data persists until the volume is explicitly removed**

Named volumes persist independently of container lifecycle. Data remains available even after containers are removed, until the volume itself is deleted.
</details>

---

## Question 3: Network Communication
How do containers communicate with each other in a custom Docker network?

A) Using IP addresses only  
B) Using service names as hostnames  
C) Through the host network interface  
D) Communication is not possible  

<details>
<summary>Answer</summary>

**B) Using service names as hostnames**

Docker provides automatic DNS resolution within custom networks, allowing containers to communicate using service/container names as hostnames.
</details>

---

## Question 4: Network Isolation
What does the `internal: true` option do for a Docker network?

A) Makes the network faster  
B) Prevents external internet access from containers  
C) Encrypts network traffic  
D) Allows only root containers  

<details>
<summary>Answer</summary>

**B) Prevents external internet access from containers**

The `internal: true` option creates a network that blocks external connectivity, allowing only communication between containers within that network.
</details>

---

## Question 5: Volume Backup
Which command correctly backs up a Docker volume to a tar file?

A) `docker volume backup volume-name backup.tar`  
B) `docker run --rm -v volume-name:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .`  
C) `docker cp volume-name backup.tar`  
D) `docker export volume-name > backup.tar`  

<details>
<summary>Answer</summary>

**B) `docker run --rm -v volume-name:/data -v $(pwd):/backup alpine tar czf /backup/backup.tar.gz -C /data .`**

This command mounts the volume and a backup directory, then uses tar to create an archive of the volume contents.
</details>

---

## Question 6: tmpfs Mounts
When would you use a tmpfs mount in Docker?

A) For permanent data storage  
B) For temporary data that should be stored in memory  
C) For sharing data between containers  
D) For backing up data  

<details>
<summary>Answer</summary>

**B) For temporary data that should be stored in memory**

tmpfs mounts create in-memory filesystems, ideal for temporary data, caches, or sensitive information that shouldn't persist to disk.
</details>

---

## Question 7: Network Drivers
What is the default network driver for Docker containers?

A) host  
B) bridge  
C) overlay  
D) none  

<details>
<summary>Answer</summary>

**B) bridge**

The bridge driver is the default network driver, creating an isolated network on the host where containers can communicate with each other and the outside world through NAT.
</details>

---

## Question 8: Volume Performance
Which volume type typically offers the best performance for temporary data?

A) Named volumes  
B) Bind mounts  
C) tmpfs mounts  
D) Anonymous volumes  

<details>
<summary>Answer</summary>

**C) tmpfs mounts**

tmpfs mounts store data in memory (RAM), providing the fastest I/O performance for temporary data that doesn't need persistence.
</details>

---

## Question 9: Multi-Host Networking
Which network driver enables communication between containers on different Docker hosts?

A) bridge  
B) host  
C) overlay  
D) macvlan  

<details>
<summary>Answer</summary>

**C) overlay**

Overlay networks enable communication between containers running on different Docker hosts, typically used in Docker Swarm or Kubernetes clusters.
</details>

---

## Question 10: Volume Drivers
What is the purpose of volume drivers in Docker?

A) To speed up volume operations  
B) To extend storage capabilities beyond local filesystem  
C) To encrypt volume data  
D) To compress volume data  

<details>
<summary>Answer</summary>

**B) To extend storage capabilities beyond local filesystem**

Volume drivers enable Docker to use various storage backends like NFS, cloud storage (AWS EBS, Azure Files), or distributed storage systems.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand Docker volumes and networking well.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're learning. Practice more with the exercises.
- **Below 4**: Review the lesson material and try the hands-on exercises.

## Practical Challenge

Design a Docker setup for this scenario:

**Requirements:**
- Web application with persistent user uploads
- Database with persistent data
- Redis cache (temporary data)
- Network isolation between tiers
- Backup strategy for persistent data

**Solution:**
```yaml
version: '3.8'

services:
  web:
    image: webapp:latest
    volumes:
      - user_uploads:/app/uploads  # Persistent uploads
      - /tmp:/app/temp            # Temporary files
    networks:
      - frontend
      - backend
    ports:
      - "80:80"

  db:
    image: postgres:13
    volumes:
      - postgres_data:/var/lib/postgresql/data  # Persistent DB
      - ./backups:/backups                      # Backup location
    networks:
      - backend
    environment:
      - POSTGRES_PASSWORD=password

  redis:
    image: redis:alpine
    tmpfs:
      - /data:rw,size=1g  # In-memory cache
    networks:
      - backend

volumes:
  user_uploads:    # Persistent user data
  postgres_data:   # Persistent database

networks:
  frontend:        # Public access
  backend:         # Internal services only
    internal: true

# Backup script
# docker run --rm -v postgres_data:/data -v $(pwd)/backups:/backup \
#   alpine tar czf /backup/db-backup-$(date +%Y%m%d).tar.gz -C /data .
```

## Next Steps

Tomorrow (Day 19) we'll learn container optimization and best practices, building on this storage and networking foundation.

## Key Takeaways

- Named volumes provide Docker-managed persistent storage
- Bind mounts enable host filesystem integration
- Custom networks improve security through isolation
- tmpfs mounts offer high-performance temporary storage
- Volume drivers extend storage to cloud and distributed systems
- Network segmentation enhances security architecture
- Regular backup strategies protect against data loss
