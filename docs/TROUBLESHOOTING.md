# Troubleshooting Guide

Common issues and solutions for the 30 Days of Developer Tools bootcamp.

## Table of Contents

- [Command Line Issues](#command-line-issues)
- [Git Issues](#git-issues)
- [Docker Issues](#docker-issues)
- [Python Issues](#python-issues)
- [WSL2 Issues (Windows)](#wsl2-issues-windows)
- [General Issues](#general-issues)

---

## Command Line Issues

### "Command not found"

**Problem:** Terminal says command doesn't exist.

**Solutions:**

1. **Check if installed:**
   ```bash
   which command-name
   ```

2. **Install the tool:**
   ```bash
   # macOS
   brew install tool-name
   
   # Linux
   sudo apt install tool-name
   ```

3. **Check PATH:**
   ```bash
   echo $PATH
   # Should include /usr/local/bin, /usr/bin, etc.
   ```

4. **Reload shell configuration:**
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

### Permission Denied

**Problem:** Can't execute script or command.

**Solutions:**

1. **Make script executable:**
   ```bash
   chmod +x script.sh
   ```

2. **Run with bash explicitly:**
   ```bash
   bash script.sh
   ```

3. **Check file ownership:**
   ```bash
   ls -la script.sh
   sudo chown $USER script.sh
   ```

### "No such file or directory"

**Problem:** Can't find file or directory.

**Solutions:**

1. **Check current directory:**
   ```bash
   pwd
   ```

2. **List files:**
   ```bash
   ls -la
   ```

3. **Use absolute path:**
   ```bash
   /full/path/to/file
   ```

4. **Check for typos** in filename

---

## Git Issues

### "fatal: not a git repository"

**Problem:** Running git commands outside a repository.

**Solution:**
```bash
# Initialize repository
git init

# Or clone existing repository
git clone url
```

### Authentication Failed

**Problem:** Can't push/pull from GitHub.

**Solutions:**

1. **Use SSH instead of HTTPS:**
   ```bash
   # Generate SSH key
   ssh-keygen -t ed25519 -C "your.email@example.com"
   
   # Add to ssh-agent
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   
   # Copy public key
   cat ~/.ssh/id_ed25519.pub
   # Add to GitHub: Settings > SSH Keys
   
   # Test connection
   ssh -T git@github.com
   ```

2. **Use Personal Access Token (PAT):**
   - GitHub: Settings > Developer settings > Personal access tokens
   - Use token as password when prompted

3. **Update remote URL:**
   ```bash
   # Change to SSH
   git remote set-url origin git@github.com:username/repo.git
   ```

### Merge Conflicts

**Problem:** Git can't automatically merge changes.

**Solution:**

1. **View conflicted files:**
   ```bash
   git status
   ```

2. **Open file and look for conflict markers:**
   ```
   <<<<<<< HEAD
   Your changes
   =======
   Their changes
   >>>>>>> branch-name
   ```

3. **Edit file to resolve conflict**

4. **Mark as resolved:**
   ```bash
   git add file
   git commit -m "Resolve merge conflict"
   ```

### Accidentally Committed Wrong Files

**Problem:** Committed files you didn't mean to.

**Solutions:**

1. **Undo last commit (keep changes):**
   ```bash
   git reset --soft HEAD~1
   ```

2. **Undo last commit (discard changes):**
   ```bash
   git reset --hard HEAD~1
   ```

3. **Remove file from staging:**
   ```bash
   git reset HEAD file
   ```

### Detached HEAD State

**Problem:** Git says you're in "detached HEAD" state.

**Solution:**
```bash
# Create branch from current state
git checkout -b new-branch-name

# Or return to main branch
git checkout main
```

---

## Docker Issues

### "Cannot connect to Docker daemon"

**Problem:** Docker service not running.

**Solutions:**

1. **macOS:** Start Docker Desktop application

2. **Linux:**
   ```bash
   sudo systemctl start docker
   sudo systemctl enable docker
   ```

3. **Check Docker status:**
   ```bash
   docker info
   ```

### "Permission denied" (Linux)

**Problem:** User not in docker group.

**Solution:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then test
docker run hello-world
```

### "Port already in use"

**Problem:** Container can't bind to port.

**Solutions:**

1. **Find process using port:**
   ```bash
   lsof -i :8080  # Replace 8080 with your port
   ```

2. **Kill process:**
   ```bash
   kill -9 PID
   ```

3. **Use different port:**
   ```bash
   docker run -p 8081:8080 image
   ```

### "No space left on device"

**Problem:** Docker using too much disk space.

**Solution:**
```bash
# Remove unused containers, images, volumes
docker system prune -a

# Remove specific items
docker container prune
docker image prune
docker volume prune
```

### Container Exits Immediately

**Problem:** Container starts then stops.

**Solutions:**

1. **Check logs:**
   ```bash
   docker logs container-name
   ```

2. **Run interactively:**
   ```bash
   docker run -it image bash
   ```

3. **Check Dockerfile CMD/ENTRYPOINT**

### "Image not found"

**Problem:** Docker can't find image.

**Solutions:**

1. **Pull image:**
   ```bash
   docker pull image-name
   ```

2. **Check image name spelling**

3. **Build image if local:**
   ```bash
   docker build -t image-name .
   ```

---

## Python Issues

### "Python not found"

**Problem:** Python not installed or not in PATH.

**Solutions:**

1. **Try python3:**
   ```bash
   python3 --version
   ```

2. **Install Python:**
   ```bash
   # macOS
   brew install python@3.11
   
   # Linux
   sudo apt install python3.11
   ```

3. **Add to PATH** (if installed but not found)

### "pip not found"

**Problem:** pip not installed.

**Solution:**
```bash
# Install pip
python3 -m ensurepip --upgrade

# Or install via package manager
sudo apt install python3-pip  # Linux
brew install python@3.11      # macOS (includes pip)
```

### "ModuleNotFoundError"

**Problem:** Python package not installed.

**Solutions:**

1. **Install package:**
   ```bash
   pip3 install package-name
   ```

2. **Check virtual environment is activated:**
   ```bash
   which python3
   # Should show venv path if activated
   ```

3. **Install from requirements.txt:**
   ```bash
   pip3 install -r requirements.txt
   ```

### Virtual Environment Issues

**Problem:** Can't activate or packages not found.

**Solutions:**

1. **Create new venv:**
   ```bash
   python3 -m venv venv
   ```

2. **Activate correctly:**
   ```bash
   # macOS/Linux
   source venv/bin/activate
   
   # Windows
   venv\Scripts\activate
   ```

3. **Verify activation:**
   ```bash
   which python3
   # Should show: /path/to/venv/bin/python3
   ```

4. **Reinstall packages:**
   ```bash
   pip3 install -r requirements.txt
   ```

### "externally-managed-environment" Error

**Problem:** System Python prevents pip install.

**Solution:**
```bash
# Always use virtual environment
python3 -m venv venv
source venv/bin/activate
pip install package-name
```

---

## WSL2 Issues (Windows)

### WSL2 Not Installing

**Problem:** `wsl --install` fails.

**Solutions:**

1. **Check Windows version:**
   - Need Windows 10 version 2004+ or Windows 11
   - Run `winver` to check

2. **Enable required features:**
   ```powershell
   # Run as Administrator
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

3. **Restart computer**

4. **Update WSL:**
   ```powershell
   wsl --update
   ```

### Can't Access Windows Files

**Problem:** Need to access Windows files from WSL.

**Solution:**
```bash
# Windows drives are mounted at /mnt/
cd /mnt/c/Users/YourUsername/Documents
```

### Can't Access WSL Files from Windows

**Problem:** Need to access WSL files from Windows Explorer.

**Solution:**
```
# In Windows Explorer address bar, type:
\\wsl$\Ubuntu\home\username\
```

### WSL2 Using Too Much Memory

**Problem:** WSL2 consuming excessive RAM.

**Solution:**

Create `.wslconfig` in Windows user directory:

```
# C:\Users\YourUsername\.wslconfig
[wsl2]
memory=4GB
processors=2
```

Restart WSL:
```powershell
wsl --shutdown
```

### Network Issues in WSL2

**Problem:** Can't connect to internet from WSL.

**Solutions:**

1. **Restart WSL:**
   ```powershell
   wsl --shutdown
   ```

2. **Check DNS:**
   ```bash
   # In WSL
   cat /etc/resolv.conf
   
   # If needed, add Google DNS
   echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
   ```

3. **Disable VPN temporarily** (some VPNs interfere)

---

## General Issues

### Slow Performance

**Solutions:**

1. **Docker:** Increase resources in Docker Desktop settings

2. **WSL2:** Adjust memory in `.wslconfig`

3. **Disk space:** Clean up unused files
   ```bash
   docker system prune -a
   ```

### Terminal Freezes

**Solutions:**

1. **Ctrl+C** - Stop current command

2. **Ctrl+Z** - Suspend process

3. **Ctrl+D** - Exit shell

4. **Close and reopen terminal**

### Copy/Paste Not Working

**Solutions:**

1. **macOS Terminal:**
   - Copy: Cmd+C
   - Paste: Cmd+V

2. **Linux Terminal:**
   - Copy: Ctrl+Shift+C
   - Paste: Ctrl+Shift+V

3. **Windows Terminal:**
   - Copy: Ctrl+Shift+C
   - Paste: Ctrl+Shift+V

### "Too many open files"

**Problem:** System limit on open files reached.

**Solution:**
```bash
# Check current limit
ulimit -n

# Increase limit (temporary)
ulimit -n 4096

# Permanent: Add to ~/.bashrc or ~/.zshrc
echo "ulimit -n 4096" >> ~/.bashrc
```

### Exercises Not Working

**Solutions:**

1. **Check you're in correct directory:**
   ```bash
   pwd
   ls
   ```

2. **Read error messages carefully**

3. **Check solution file** for comparison

4. **Review lesson README** for context

5. **Try previous day's exercises** to reinforce basics

---

## Getting More Help

### Documentation

- **Bash**: `man bash` or https://www.gnu.org/software/bash/manual/
- **Git**: `git help` or https://git-scm.com/doc
- **Docker**: https://docs.docker.com/
- **Python**: https://docs.python.org/3/

### Search for Errors

1. **Copy exact error message**
2. **Google it** (often finds Stack Overflow answers)
3. **Check official documentation**
4. **Ask in community forums**

### Debug Systematically

1. **Read error message completely**
2. **Check what changed** since it last worked
3. **Test in isolation** (simplify the problem)
4. **Check logs** (`docker logs`, `git log`, etc.)
5. **Verify prerequisites** (tools installed, services running)

---

## Still Stuck?

If you've tried the solutions above and still have issues:

1. **Check [SETUP.md](./SETUP.md)** for detailed installation
2. **Review [QUICKSTART.md](../QUICKSTART.md)** for setup steps
3. **Check [tools/cheatsheet.md](../tools/cheatsheet.md)** for command reference
4. **Search GitHub issues** for similar problems
5. **Ask for help** in community forums with:
   - Exact error message
   - What you tried
   - Your OS and tool versions

---

**Remember:** Errors are learning opportunities! Every developer encounters these issues.
