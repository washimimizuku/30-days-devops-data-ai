# Detailed Setup Guide

Complete installation instructions for all operating systems.

## Table of Contents

- [macOS Setup](#macos-setup)
- [Linux Setup](#linux-setup)
- [Windows Setup (WSL2)](#windows-setup-wsl2)
- [Tool Installation](#tool-installation)
- [Verification](#verification)

---

## macOS Setup

### Prerequisites

- macOS 10.15 (Catalina) or later
- Administrator access
- Internet connection

### Step 1: Install Homebrew

Homebrew is the package manager for macOS.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the on-screen instructions. After installation:

```bash
# Add Homebrew to PATH (if prompted)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Step 2: Install Essential Tools

```bash
# Command line tools
brew install git jq make wget curl

# Python
brew install python@3.11

# Docker Desktop
brew install --cask docker

# Optional: Better terminal
brew install --cask iterm2
```

### Step 3: Configure Shell

macOS Catalina+ uses zsh by default:

```bash
# Edit ~/.zshrc
nano ~/.zshrc

# Add useful aliases
alias ll='ls -la'
alias gs='git status'
alias dc='docker-compose'

# Save and reload
source ~/.zshrc
```

---

## Linux Setup

### Ubuntu/Debian

```bash
# Update package list
sudo apt update && sudo apt upgrade -y

# Essential tools
sudo apt install -y \
    git \
    curl \
    wget \
    jq \
    make \
    build-essential \
    python3.11 \
    python3-pip \
    python3-venv

# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Docker Compose
sudo apt install -y docker-compose-plugin

# Log out and back in for Docker group to take effect
```

### Fedora/RHEL

```bash
# Update system
sudo dnf update -y

# Essential tools
sudo dnf install -y \
    git \
    curl \
    wget \
    jq \
    make \
    gcc \
    python3.11 \
    python3-pip

# Docker
sudo dnf install -y docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### Arch Linux

```bash
# Update system
sudo pacman -Syu

# Essential tools
sudo pacman -S \
    git \
    curl \
    wget \
    jq \
    make \
    gcc \
    python \
    python-pip

# Docker
sudo pacman -S docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

---

## Windows Setup (WSL2)

### Why WSL2?

Most data engineering and DevOps tools are designed for Unix/Linux. WSL2 provides a full Linux environment on Windows.

### Step 1: Enable WSL2

**Requirements:**
- Windows 10 version 2004+ (Build 19041+) or Windows 11
- Administrator access

**Install WSL2:**

1. Open PowerShell as Administrator
2. Run:
   ```powershell
   wsl --install
   ```
3. Restart your computer
4. Open "Ubuntu" from Start menu
5. Create username and password when prompted

### Step 2: Update Ubuntu

```bash
sudo apt update && sudo apt upgrade -y
```

### Step 3: Install Tools

Follow the [Ubuntu/Debian](#ubuntudebian) instructions above.

### Step 4: Install Windows Terminal (Recommended)

1. Open Microsoft Store
2. Search for "Windows Terminal"
3. Install
4. Set Ubuntu as default profile

### Step 5: Configure WSL2

**Access Windows files from WSL:**
```bash
cd /mnt/c/Users/YourUsername/
```

**Access WSL files from Windows:**
```
\\wsl$\Ubuntu\home\username\
```

**Set WSL2 as default:**
```powershell
wsl --set-default-version 2
```

---

## Tool Installation

### Git

**Verify installation:**
```bash
git --version
```

**Configure Git:**
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

**Generate SSH key for GitHub:**
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
cat ~/.ssh/id_ed25519.pub
# Copy output and add to GitHub: Settings > SSH Keys
```

### Docker

**macOS:**
- Docker Desktop installed via Homebrew
- Start Docker Desktop from Applications
- Verify: `docker --version`

**Linux:**
- Installed via package manager
- Start service: `sudo systemctl start docker`
- Verify: `docker --version`

**Test Docker:**
```bash
docker run hello-world
```

### Python

**Verify installation:**
```bash
python3 --version
pip3 --version
```

**Create virtual environment:**
```bash
python3 -m venv ~/venvs/devtools
source ~/venvs/devtools/bin/activate
pip install --upgrade pip
```

### jq (JSON processor)

**macOS:**
```bash
brew install jq
```

**Linux:**
```bash
sudo apt install jq  # Ubuntu/Debian
sudo dnf install jq  # Fedora
```

**Verify:**
```bash
echo '{"name":"test"}' | jq '.name'
```

### csvkit (CSV tools)

```bash
pip3 install csvkit
```

**Verify:**
```bash
csvlook --version
```

### AWS CLI

**macOS:**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Verify:**
```bash
aws --version
```

**Configure (if you have AWS account):**
```bash
aws configure
```

### httpie (API testing)

```bash
pip3 install httpie
```

**Verify:**
```bash
http --version
```

---

## Verification

### Run Setup Test

```bash
cd 30-days-devtools-data-ai
bash tools/test_setup.sh
```

### Manual Verification

```bash
# Essential tools
bash --version
git --version
grep --version
sed --version
awk --version
jq --version
make --version

# Python
python3 --version
pip3 --version

# Docker
docker --version
docker-compose --version

# Optional tools
aws --version
http --version
csvlook --version
```

---

## Troubleshooting

### macOS: Command not found after Homebrew install

```bash
# Add Homebrew to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

### Linux: Docker permission denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then test
docker run hello-world
```

### WSL2: Can't access Windows files

```bash
# Windows C: drive is at /mnt/c/
cd /mnt/c/Users/YourUsername/
```

### Python: pip not found

```bash
# Install pip
sudo apt install python3-pip  # Linux
brew install python@3.11      # macOS
```

### Git: SSH key issues

```bash
# Generate new key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key
ssh-add ~/.ssh/id_ed25519

# Test GitHub connection
ssh -T git@github.com
```

---

## Optional Tools

### Better Terminal Experience

**macOS:**
```bash
brew install --cask iterm2
```

**Linux:**
```bash
sudo apt install terminator  # Ubuntu
```

### Shell Enhancements

**Oh My Zsh (macOS/Linux):**
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**Starship (cross-platform prompt):**
```bash
curl -sS https://starship.rs/install.sh | sh
```

### Code Editors

**VS Code:**
- Download: https://code.visualstudio.com/
- Extensions: Python, Docker, GitLens, Remote-WSL (for Windows)

**Vim/Neovim:**
```bash
brew install neovim  # macOS
sudo apt install neovim  # Linux
```

---

## Next Steps

After setup is complete:

1. ✅ Run `bash tools/test_setup.sh`
2. ✅ Read [QUICKSTART.md](../QUICKSTART.md)
3. ✅ Start Day 1: `cd days/day-01-terminal-basics`

---

## Getting Help

- **Homebrew issues**: https://docs.brew.sh/Troubleshooting
- **WSL2 issues**: https://docs.microsoft.com/en-us/windows/wsl/troubleshooting
- **Docker issues**: https://docs.docker.com/get-started/
- **Git issues**: https://git-scm.com/doc

---

**Ready?** Run the verification script and start learning!

```bash
bash tools/test_setup.sh
```
