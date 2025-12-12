# Day 20 Quiz: Production Deployment Strategies

Test your understanding of production deployment strategies and orchestration.

## Question 1: Rolling Deployment
What is the main advantage of rolling deployments?

A) Instant rollback capability  
B) Zero downtime during updates  
C) Reduced resource usage  
D) Faster deployment speed  

<details>
<summary>Answer</summary>

**B) Zero downtime during updates**

Rolling deployments gradually replace old instances with new ones, ensuring the application remains available throughout the update process.
</details>

---

## Question 2: Blue-Green Deployment
In a blue-green deployment, when do you switch traffic to the new environment?

A) Immediately after starting the deployment  
B) After all health checks pass in the new environment  
C) Halfway through the deployment process  
D) Only during maintenance windows  

<details>
<summary>Answer</summary>

**B) After all health checks pass in the new environment**

Blue-green deployments wait for the new environment to be fully healthy before switching traffic, enabling instant rollback if issues are detected.
</details>

---

## Question 3: Canary Deployment
What percentage of traffic is typically routed to the canary version initially?

A) 50%  
B) 25%  
C) 5-10%  
D) 90%  

<details>
<summary>Answer</summary>

**C) 5-10%**

Canary deployments start with a small percentage of traffic (typically 5-10%) to minimize risk while testing the new version with real users.
</details>

---

## Question 4: Health Checks
Which type of health check verifies that a container is ready to receive traffic?

A) Liveness probe  
B) Readiness probe  
C) Startup probe  
D) Performance probe  

<details>
<summary>Answer</summary>

**B) Readiness probe**

Readiness probes determine when a container is ready to receive traffic, while liveness probes check if a container is still running properly.
</details>

---

## Question 5: CI/CD Pipeline
In which stage should security scanning typically occur?

A) Only at the end of the pipeline  
B) After building but before deploying to any environment  
C) Only in production  
D) Security scanning is optional  

<details>
<summary>Answer</summary>

**B) After building but before deploying to any environment**

Security scanning should happen early in the pipeline, after the image is built but before deployment, to catch vulnerabilities before they reach any environment.
</details>

---

## Question 6: Secrets Management
What is the most secure way to handle database passwords in containers?

A) Environment variables  
B) Configuration files  
C) Docker secrets or Kubernetes secrets  
D) Hardcoded in the application  

<details>
<summary>Answer</summary>

**C) Docker secrets or Kubernetes secrets**

Container orchestration platforms provide secure secrets management that encrypts sensitive data and provides controlled access to containers.
</details>

---

## Question 7: Monitoring Strategy
Which metric is most critical for detecting deployment issues?

A) CPU usage  
B) Memory usage  
C) Error rate  
D) Disk space  

<details>
<summary>Answer</summary>

**C) Error rate**

Error rate is the most direct indicator of application health and deployment success, as it immediately shows if the new version is functioning correctly.
</details>

---

## Question 8: Load Balancing
What happens when a backend server fails health checks in a load balancer?

A) The load balancer stops working  
B) Traffic is still sent to the failed server  
C) The server is removed from the rotation  
D) All servers are restarted  

<details>
<summary>Answer</summary>

**C) The server is removed from the rotation**

Load balancers automatically remove unhealthy servers from the rotation to prevent traffic from being sent to failed instances.
</details>

---

## Question 9: Disaster Recovery
What is the primary purpose of database replication in a disaster recovery strategy?

A) Improve performance  
B) Reduce storage costs  
C) Provide data redundancy and failover capability  
D) Simplify backup procedures  

<details>
<summary>Answer</summary>

**C) Provide data redundancy and failover capability**

Database replication ensures data is available in multiple locations, enabling quick failover to a standby database if the primary fails.
</details>

---

## Question 10: Deployment Rollback
Which deployment strategy provides the fastest rollback capability?

A) Rolling deployment  
B) Blue-green deployment  
C) Canary deployment  
D) Recreate deployment  

<details>
<summary>Answer</summary>

**B) Blue-green deployment**

Blue-green deployments enable instant rollback by simply switching traffic back to the previous environment, which remains running and ready.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand production deployment strategies well.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're learning. Practice more with deployment scenarios.
- **Below 4**: Review the lesson material and try the hands-on exercises.

## Practical Scenario

Design a deployment strategy for this scenario:

**Requirements:**
- E-commerce application with 99.9% uptime requirement
- Must handle Black Friday traffic spikes
- Zero tolerance for payment processing errors
- Need ability to quickly rollback if issues occur
- Compliance requires audit trail of all deployments

**Recommended Solution:**
```yaml
# Blue-Green Deployment with Monitoring
Strategy: Blue-Green Deployment
Rationale: 
  - Instant rollback capability for zero tolerance errors
  - Zero downtime for 99.9% uptime requirement
  - Full environment testing before traffic switch

Implementation:
  1. Deploy to green environment
  2. Run comprehensive health checks
  3. Perform payment processing tests
  4. Monitor error rates and performance
  5. Switch traffic only after validation
  6. Keep blue environment for instant rollback

Monitoring:
  - Real-time error rate monitoring
  - Payment processing success rate
  - Response time tracking
  - Automated rollback triggers

Compliance:
  - Log all deployment steps
  - Maintain deployment artifacts
  - Track approval workflows
  - Document rollback procedures
```

**Additional Considerations:**
- Load testing in staging environment
- Canary deployment for major changes
- Database migration strategies
- CDN cache invalidation
- Third-party service integration testing

## Next Steps

Tomorrow (Day 21) is the final containerization project, integrating all concepts from Week 3 into a complete production system.

## Key Takeaways

- Different deployment strategies serve different risk tolerances and requirements
- Health checks and monitoring are critical for automated deployments
- Security scanning should be integrated into CI/CD pipelines
- Secrets management protects sensitive configuration data
- Disaster recovery planning prevents business disruption
- Load balancing and high availability eliminate single points of failure
- Proper monitoring enables quick detection and resolution of issues
