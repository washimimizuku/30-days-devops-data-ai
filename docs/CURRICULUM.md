# 30 Days of Developer Tools for Data and AI - Curriculum

## Week 1: Command Line & Shell (Days 1-7)

### Day 1: Terminal Basics
- Terminal vs shell vs command line
- Navigation: pwd, cd, ls
- File operations: cp, mv, rm, mkdir, touch
- Viewing files: cat, less, head, tail
- File permissions and chmod
- **Exercise**: Navigate filesystem, organize data files

### Day 2: Shell Scripting Basics
- Shell scripts and shebang
- Variables and command substitution
- Conditionals (if/else)
- Basic loops (for, while)
- Exit codes and error handling
- **Exercise**: Write data validation script

### Day 3: Text Processing Tools
- grep - pattern searching
- sed - stream editing
- awk - text processing
- jq - JSON processing
- csvkit - CSV manipulation
- **Exercise**: Process log files and extract data

### Day 4: Process Management
- ps, top, htop - monitoring processes
- kill, pkill - managing processes
- Background jobs (&, bg, fg)
- nohup and screen/tmux basics
- System resources monitoring
- **Exercise**: Monitor and manage long-running data jobs

### Day 5: Environment Variables and PATH
- Environment variables (export, printenv)
- PATH configuration
- Shell configuration files (.bashrc, .zshrc)
- Aliases and functions
- Shell startup process
- **Exercise**: Configure development environment

### Day 6: Make and Task Automation
- Makefile basics
- Targets, dependencies, and rules
- Variables in Makefiles
- Phony targets
- Alternative: just, task runners
- **Exercise**: Create data pipeline Makefile

### Day 7: Mini Project - Automated Data Pipeline
- Build complete shell-based data pipeline
- Combine all Week 1 tools
- Process CSV/JSON data
- Generate reports
- Error handling and logging
- **Project**: ETL pipeline with shell scripts

---

## Week 2: Git & Version Control (Days 8-14)

### Day 8: Git Basics
- Git concepts: repository, commit, staging
- git init, clone, status
- git add, commit, log
- .gitignore patterns
- Viewing history and diffs
- **Exercise**: Initialize repo, make commits

### Day 9: Branching and Merging
- Branch concepts and workflows
- git branch, checkout, switch
- Creating and switching branches
- Merging branches
- Fast-forward vs three-way merge
- **Exercise**: Feature branch workflow

### Day 10: Remote Repositories
- Remote concepts (origin, upstream)
- git remote, push, pull, fetch
- GitHub/GitLab setup
- SSH keys and authentication
- Cloning and forking
- **Exercise**: Push to GitHub, collaborate

### Day 11: Collaboration Workflows
- Pull requests / Merge requests
- Code review process
- Forking workflow
- Issue tracking
- Project boards
- **Exercise**: Create PR, review code

### Day 12: Git Workflows
- Gitflow workflow
- Feature branch workflow
- Trunk-based development
- Release management
- Tagging versions
- **Exercise**: Implement team workflow

### Day 13: Advanced Git
- Resolving merge conflicts
- git rebase vs merge
- Interactive rebase
- Cherry-picking commits
- Stashing changes
- **Exercise**: Handle conflicts, rebase branches

### Day 14: Mini Project - Collaborative Workflow
- Team collaboration simulation
- Multiple feature branches
- Pull requests and reviews
- Conflict resolution
- Release tagging
- **Project**: Collaborative data project with Git

---

## Week 3: Docker & Containers (Days 15-21)

### Day 15: Docker Basics
- Container concepts vs VMs
- Docker architecture
- Images vs containers
- docker run, ps, stop, rm
- Docker Hub and registries
- **Exercise**: Run data processing containers

### Day 16: Dockerfile
- Dockerfile syntax and instructions
- FROM, RUN, COPY, CMD, ENTRYPOINT
- Layer caching and optimization
- Multi-stage builds
- Best practices
- **Exercise**: Build Python data app image

### Day 17: Docker Volumes and Networking
- Volume types and persistence
- Bind mounts vs volumes
- Docker networks
- Container communication
- Port mapping
- **Exercise**: Persist data, connect containers

### Day 18: Docker Compose
- docker-compose.yml syntax
- Multi-container applications
- Service dependencies
- Environment variables
- Networks and volumes in Compose
- **Exercise**: Multi-service data stack

### Day 19: Container Best Practices
- Image size optimization
- Security best practices
- Health checks
- Resource limits
- Logging strategies
- **Exercise**: Optimize data pipeline container

### Day 20: Docker for Data Tools
- Jupyter in Docker
- Database containers (PostgreSQL, DuckDB)
- Spark in containers
- Volume mounting for notebooks
- papermill for notebook automation
- **Exercise**: Containerized Jupyter environment

### Day 21: Mini Project - Containerized Data Application
- Multi-container data pipeline
- Database + processing + API
- Docker Compose orchestration
- Volume persistence
- Environment configuration
- **Project**: Full containerized ETL system

---

## Week 4: CI/CD & Professional Tools (Days 22-30)

### Day 22: CI/CD Concepts and GitHub Actions
- CI/CD principles
- GitHub Actions basics
- Workflows, jobs, steps
- Triggers and events
- Secrets management
- **Exercise**: Basic CI workflow

### Day 23: Testing Automation
- pytest for data pipelines
- Data validation testing
- Schema validation
- great_expectations basics
- Linting and formatting (black, ruff)
- **Exercise**: Test data pipeline

### Day 24: Package Managers
- pip basics and requirements.txt
- poetry for dependency management
- uv - fast Python package installer
- Lock files and reproducibility
- Publishing packages
- **Exercise**: Manage project dependencies

### Day 25: Virtual Environments
- venv and virtualenv
- conda environments
- pyenv for Python versions
- Environment best practices
- requirements.txt vs pyproject.toml
- **Exercise**: Set up isolated environments

### Day 26: API Testing Tools
- curl basics and options
- httpie for human-friendly requests
- REST API concepts
- Authentication (tokens, API keys)
- Testing API endpoints
- **Exercise**: Test data APIs

### Day 27: AWS CLI Basics
- AWS CLI installation and configuration
- S3 operations (cp, sync, ls)
- EC2 basics
- IAM and credentials
- CloudWatch logs
- **Exercise**: Upload data to S3, query logs

### Day 28: Debugging and Profiling
- Python debugger (pdb, ipdb)
- Memory profiling (memory_profiler)
- Performance profiling (cProfile)
- Line profiling (line_profiler)
- Debugging data pipelines
- **Exercise**: Profile and optimize code

### Day 29: Security and Configuration
- Environment variables and .env files
- python-dotenv
- Secrets management
- Config files (YAML, TOML)
- Pydantic settings
- **Exercise**: Secure configuration management

### Day 30: Capstone - Full CI/CD Pipeline
- Complete data project with:
  - Git version control
  - Docker containerization
  - Automated testing
  - GitHub Actions CI/CD
  - AWS deployment
  - Monitoring and logging
- **Project**: Production-ready data pipeline

---

## Learning Path

### Prerequisites
- Basic computer literacy
- Willingness to learn command line
- No programming required (but helpful)

### After This Bootcamp
You'll be ready for:
- Professional data engineering work
- DevOps for data/AI projects
- Cloud-based data pipelines
- Team collaboration on data projects
- MLOps and production ML systems

### Recommended Next Steps
1. **30 Days of Python for Data and AI** - If you haven't done it
2. **100 Days of Data and AI** - Comprehensive data engineering
3. **Advanced bootcamps** - Kubernetes, Terraform, cloud platforms

---

## Time Estimates

**Regular Days**: 1 hour
- Reading: 15 minutes
- Exercises: 40 minutes
- Quiz: 5 minutes

**Project Days** (7, 14, 21, 30): 1.5-2 hours
- Planning: 15 minutes
- Implementation: 60-90 minutes
- Testing: 15 minutes

**Total Time**: 35-40 hours over 30 days

---

## Tools You'll Master

### Command Line
- bash/zsh scripting
- grep, sed, awk
- jq, csvkit
- make

### Version Control
- git
- GitHub/GitLab
- Pull requests
- Code review

### Containers
- Docker
- Docker Compose
- Container registries
- Multi-stage builds

### CI/CD
- GitHub Actions
- Automated testing
- Deployment pipelines

### Development
- Virtual environments
- Package management
- Debugging tools
- Profiling tools

### Cloud
- AWS CLI
- S3 operations
- EC2 basics

### Security
- Secrets management
- Environment variables
- Configuration management

---

## Daily Routine

1. **Activate environment** (if needed)
2. **Read lesson** (README.md)
3. **Complete exercises** (hands-on practice)
4. **Check solutions** (if stuck)
5. **Take quiz** (test understanding)
6. **Commit progress** (if using Git)

---

## Success Tips

- **Practice daily** - Consistency is key
- **Type commands** - Don't copy-paste
- **Experiment** - Try variations
- **Take notes** - Build your own cheatsheet
- **Use in projects** - Apply to real work
- **Ask questions** - Use community resources
- **Be patient** - Tools take time to master

---

## Assessment

After completing this bootcamp, you should be able to:

✅ Navigate and automate tasks with command line  
✅ Write shell scripts for data processing  
✅ Use Git for version control and collaboration  
✅ Containerize applications with Docker  
✅ Set up CI/CD pipelines  
✅ Manage Python environments and dependencies  
✅ Debug and profile data applications  
✅ Work with AWS cloud services  
✅ Follow security best practices  
✅ Build production-ready data pipelines  

---

**Ready to start?** Begin with Day 1: Terminal Basics!
