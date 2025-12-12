# Quick Start Guide - 30 Days of Developer Tools for Data and AI

Get started in 5 minutes! 🚀

## Prerequisites

- Computer (Windows, Mac, or Linux)
- 5GB free disk space
- Internet connection
- GitHub account (optional, but recommended for tracking progress)

---

## Step 0: Fork the Repository (Recommended)

**Why fork?** Track your progress, build your portfolio, and practice Git!

### Option A: Fork (Recommended)

1. **Go to**: https://github.com/YOUR-ORG/30-days-devtools-data-ai
2. **Click "Fork"** button (top right)
3. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/30-days-devtools-data-ai.git
   cd 30-days-devtools-data-ai
   ```

### Option B: Download (No Git)

If you don't want to use Git initially, download the ZIP file from GitHub.

> 💡 **Tip**: You'll learn Git in Week 2, so you can always set it up then!

---

## Step 1: Check Your Operating System

This bootcamp works on:
- ✅ **macOS** - Native Unix environment
- ✅ **Linux** - Native Unix environment
- ✅ **Windows** - Requires WSL2 (Windows Subsystem for Linux)

### Windows Users: Install WSL2

**Why WSL2?** Most data engineering tools are designed for Unix/Linux environments.

1. **Open PowerShell as Administrator** and run:
   ```powershell
   wsl --install
   ```

2. **Restart your computer**

3. **Open Ubuntu** from Start menu (installed automatically)

4. **Create username and password** when prompted

5. **Update packages**:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

👉 **See [docs/SETUP.md](./docs/SETUP.md) for detailed WSL2 setup**

---

## Step 2: Install Required Tools (5 minutes)

### macOS

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essential tools
brew install git docker jq

# Install Python (for later weeks)
brew install python@3.11
```

### Linux (Ubuntu/Debian)

```bash
# Update package list
sudo apt update

# Install essential tools
sudo apt install -y git curl wget jq make

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Python
sudo apt install -y python3.11 python3-pip python3-venv

# Log out and back in for Docker group to take effect
```

### Windows (WSL2)

Follow the Linux instructions above inside your WSL2 Ubuntu terminal.

---

## Step 3: Verify Installation (1 minute)

Run the setup verification script:

```bash
bash tools/test_setup.sh
```

You should see:
```
✅ bash: /bin/bash
✅ git: version 2.x.x
✅ docker: version 24.x.x
✅ jq: version 1.x
✅ python3: version 3.11.x
✅ All essential tools installed! Ready to start Day 1
```

---

## Step 4: Start Learning! 🎉

Open the first lesson:

```bash
cd days/day-01-terminal-basics
cat README.md
# Or open in your preferred text editor
```

---

## Daily Routine

### Before Starting Each Day:

```bash
# Navigate to the bootcamp directory
cd ~/30-days-devtools-data-ai

# Navigate to today's lesson
cd days/day-XX-topic-name
```

### Follow This Pattern:

1. **📖 Read** the `README.md` (15 min)
   - Learn the concepts
   - Study the examples

2. **💻 Practice** the exercises (40 min)
   - Complete the TODO exercises
   - Try commands in your terminal

3. **✅ Check** the solutions (if stuck)
   - Compare your approach
   - Learn from examples

4. **🎯 Quiz** with `quiz.md` (5 min)
   - Test your understanding
   - Review if needed

---

## Recommended Tools

### Terminal Emulator

**macOS:**
- Built-in Terminal (good)
- iTerm2 (better) - [iterm2.com](https://iterm2.com/)

**Linux:**
- Built-in terminal (good)
- Terminator (better) - `sudo apt install terminator`

**Windows (WSL2):**
- Windows Terminal (recommended) - Install from Microsoft Store
- Built-in Ubuntu terminal (good)

### Code Editor (Choose One)

**VS Code** (Recommended)
- Download: [code.visualstudio.com](https://code.visualstudio.com/)
- Install extensions: Python, Docker, GitLens
- Free and beginner-friendly

**Vim/Neovim** (Advanced)
- Pre-installed on most systems
- Steep learning curve but powerful

**Any text editor works!** - Sublime, Atom, nano, etc.

---

## Learning Tips

✅ **Type commands yourself** - Don't copy-paste  
✅ **Experiment** - Try variations of commands  
✅ **Take breaks** - It's okay to split a day across sessions  
✅ **Practice daily** - Consistency builds muscle memory  
✅ **Use man pages** - `man command` shows documentation  
✅ **Google errors** - Error messages are learning opportunities  
✅ **Be patient** - Command line takes time to master  

---

## Project Days (Extra Time Needed)

These days are mini-projects and may take 1.5-2 hours:
- **Day 7**: Automated Data Pipeline (shell scripts)
- **Day 14**: Collaborative Workflow (Git)
- **Day 21**: Containerized Data Application (Docker)
- **Day 30**: Full CI/CD Pipeline (Capstone)

Don't rush these - they're where you consolidate your learning!

---

## Troubleshooting

### "Command not found"
```bash
# Check if tool is installed
which git
which docker

# If not found, reinstall (see Step 2)
```

### Docker permission denied (Linux)
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then test
docker run hello-world
```

### WSL2 not working (Windows)
1. Ensure Windows 10 version 2004+ or Windows 11
2. Enable virtualization in BIOS
3. Run `wsl --update` in PowerShell (admin)
4. See [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)

### Python not found
```bash
# Try python3 instead of python
python3 --version

# Install if needed (see Step 2)
```

### Still stuck?
1. Check [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)
2. Check [docs/SETUP.md](./docs/SETUP.md)
3. Google the error message
4. Ask in community forums

---

## Daily Workflow (If Using Git)

### Each Day:

1. **Complete the exercises** in `days/day-XX-topic/`

2. **Commit your work**:
   ```bash
   git add days/day-XX-topic/
   git commit -m "Complete Day XX: Topic Name"
   git push origin main
   ```

### Sample Commit Messages:
```bash
git commit -m "Complete Day 1: Terminal Basics"
git commit -m "Complete Day 7: Mini Project - Automated Pipeline"
git commit -m "Complete Day 30: Capstone CI/CD Pipeline"
```

### Track Your Progress:
- Your GitHub profile will show daily commits (green squares!)
- Employers can see your learning journey
- You have a backup of all your work

👉 **See [docs/GIT_SETUP.md](./docs/GIT_SETUP.md) for detailed Git workflow**

---

## What's Next?

After completing all 30 days, you'll be ready for:
- Professional data engineering workflows
- Team collaboration with Git and Docker
- CI/CD pipeline development
- Cloud-based data projects
- MLOps and production ML systems

---

## Need More Help?

- 📖 **Detailed Setup**: See [docs/SETUP.md](./docs/SETUP.md)
- 📝 **Quick Reference**: See [tools/cheatsheet.md](./tools/cheatsheet.md)
- 🆘 **Troubleshooting**: See [docs/TROUBLESHOOTING.md](./docs/TROUBLESHOOTING.md)
- 📚 **Curriculum Overview**: See [docs/CURRICULUM.md](./docs/CURRICULUM.md)
- 🏠 **Main README**: See [README.md](./README.md)

---

## Quick Command Reference

### Navigation
```bash
pwd                 # Print working directory
cd directory        # Change directory
ls -la              # List files (detailed)
```

### File Operations
```bash
mkdir folder        # Create directory
touch file.txt      # Create file
cp source dest      # Copy
mv source dest      # Move/rename
rm file             # Remove file
```

### Getting Help
```bash
man command         # Manual page
command --help      # Help flag
tldr command        # Simplified examples (install: brew install tldr)
```

---

**Ready? Let's start with Day 1!** 🚀

```bash
cd days/day-01-terminal-basics
cat README.md
```

Or open `days/day-01-terminal-basics/README.md` in your editor!
