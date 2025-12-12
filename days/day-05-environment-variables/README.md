# Day 5: Environment Variables and PATH

**Duration**: 1 hour  
**Prerequisites**: Day 4 - Process Management

## Learning Objectives

By the end of this lesson, you will:
- Understand and manage environment variables
- Configure and modify the PATH variable
- Customize shell configuration files
- Create useful aliases and functions
- Understand the shell startup process
- Set up a productive development environment

## Core Concepts

### 1. Environment Variables

Environment variables are key-value pairs that affect how processes run on your system.

#### Viewing Environment Variables
```bash
# Show all environment variables
printenv
env

# Show specific variable
echo $HOME
echo $PATH
echo $USER

# Show variable with default value
echo ${PYTHON_PATH:-/usr/bin/python}
```

#### Setting Environment Variables
```bash
# Set for current session only
export DATA_DIR="/path/to/data"
export API_KEY="your-api-key"

# Unset variable
unset DATA_DIR

# Set temporarily for one command
DATA_DIR="/tmp/data" python script.py
```

#### Common Environment Variables
```bash
HOME        # User's home directory
PATH        # Executable search path
USER        # Current username
SHELL       # Current shell
PWD         # Present working directory
OLDPWD      # Previous working directory
LANG        # System language/locale
EDITOR      # Default text editor
PAGER       # Default pager (less, more)
```

### 2. PATH Configuration

The PATH variable tells the shell where to look for executable programs.

#### Understanding PATH
```bash
# View current PATH
echo $PATH

# PATH is colon-separated list of directories
# /usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Check which executable will run
which python
which git
type python
```

#### Modifying PATH
```bash
# Add directory to beginning of PATH (highest priority)
export PATH="/new/directory:$PATH"

# Add directory to end of PATH (lowest priority)
export PATH="$PATH:/new/directory"

# Add multiple directories
export PATH="/dir1:/dir2:$PATH"

# Remove directory from PATH
export PATH=$(echo $PATH | tr ':' '\n' | grep -v '/unwanted/dir' | tr '\n' ':' | sed 's/:$//')
```

### 3. Shell Configuration Files

Different shells use different configuration files that run at startup.

#### Bash Configuration Files
```bash
# System-wide configuration
/etc/profile        # Login shells (all users)
/etc/bash.bashrc    # Interactive shells (all users)

# User-specific configuration
~/.profile          # Login shells (any POSIX shell)
~/.bashrc           # Interactive bash shells
~/.bash_profile     # Login bash shells
~/.bash_logout      # When bash login shell exits
```

#### Zsh Configuration Files
```bash
# System-wide
/etc/zshenv         # Always sourced
/etc/zprofile       # Login shells
/etc/zshrc          # Interactive shells

# User-specific
~/.zshenv           # Always sourced
~/.zprofile         # Login shells
~/.zshrc            # Interactive shells
~/.zlogout          # When login shell exits
```

#### Loading Order
1. **Login Shell**: `.profile` → `.bash_profile` (or `.zprofile`)
2. **Interactive Shell**: `.bashrc` (or `.zshrc`)
3. **Non-interactive**: Usually just `.bashrc` or `.zshrc`

### 4. Aliases and Functions

#### Creating Aliases
```bash
# Simple command shortcuts
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# Navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# Data processing shortcuts
alias csv='column -t -s,'
alias json='python -m json.tool'
```

#### Creating Functions
```bash
# Simple function
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Function with multiple parameters
backup() {
    local source=$1
    local dest="${2:-backup_$(date +%Y%m%d)}"
    cp -r "$source" "$dest"
    echo "Backed up $source to $dest"
}

# Data processing function
csvstat() {
    local file=$1
    echo "File: $file"
    echo "Rows: $(wc -l < "$file")"
    echo "Columns: $(head -1 "$file" | tr ',' '\n' | wc -l)"
}
```

### 5. Development Environment Setup

#### Python Environment
```bash
# Python path and virtual environments
export PYTHONPATH="$HOME/python/lib:$PYTHONPATH"
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Python aliases
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv'
```

#### Data Tools Environment
```bash
# Data directories
export DATA_HOME="$HOME/data"
export DATASETS_DIR="$DATA_HOME/datasets"
export MODELS_DIR="$DATA_HOME/models"
export LOGS_DIR="$DATA_HOME/logs"

# Tool configurations
export JUPYTER_CONFIG_DIR="$HOME/.jupyter"
export PANDAS_DISPLAY_MAX_ROWS=100
```

#### AWS and Cloud Tools
```bash
# AWS configuration
export AWS_DEFAULT_REGION="us-west-2"
export AWS_PROFILE="default"

# Other cloud tools
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp/credentials.json"
```

## Configuration Examples

### Complete .bashrc Setup
```bash
# ~/.bashrc - Data Engineering Configuration

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Environment Variables
export EDITOR="nano"
export PAGER="less"
export HISTSIZE=10000
export HISTFILESIZE=20000

# Data Engineering Paths
export DATA_HOME="$HOME/data"
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Python Configuration
export PYTHONPATH="$HOME/python/lib:$PYTHONPATH"
alias py='python3'
alias pip='pip3'

# Git Aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline'

# Data Processing Aliases
alias csv='column -t -s,'
alias json='python -m json.tool'
alias ll='ls -la'
alias la='ls -A'

# Useful Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
backup() { cp -r "$1" "${2:-$1.backup.$(date +%Y%m%d)}"; }
findfile() { find . -name "*$1*" -type f; }

# Load additional configurations
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Custom prompt
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
```

### Project-Specific Environment
```bash
# .env file for project
PROJECT_NAME="data_pipeline"
DATA_DIR="/path/to/project/data"
LOG_LEVEL="INFO"
DATABASE_URL="postgresql://localhost/mydb"
API_BASE_URL="https://api.example.com"

# Load with: source .env
```

## Best Practices

### 1. Environment Variable Management
- Use descriptive names: `DATA_HOME` not `DH`
- Use UPPER_CASE for environment variables
- Group related variables together
- Document non-obvious variables

### 2. PATH Management
- Add user directories before system directories
- Keep PATH clean and organized
- Use absolute paths when possible
- Test PATH changes before making permanent

### 3. Configuration Files
- Keep configurations in version control
- Use modular configuration (separate files for different tools)
- Comment your configurations
- Test configurations on fresh systems

### 4. Security Considerations
- Never put secrets in shell configuration files
- Use separate files for sensitive variables
- Set appropriate file permissions (600 for config files)
- Use tools like `direnv` for project-specific environments

## Common Patterns

### Conditional Configuration
```bash
# OS-specific configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS specific
    export PATH="/opt/homebrew/bin:$PATH"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux specific
    export PATH="/usr/local/bin:$PATH"
fi

# Tool-specific configuration
if command -v code >/dev/null 2>&1; then
    export EDITOR="code --wait"
elif command -v nano >/dev/null 2>&1; then
    export EDITOR="nano"
fi
```

### Dynamic PATH Building
```bash
# Build PATH dynamically
NEW_PATH=""
for dir in "$HOME/bin" "$HOME/.local/bin" "/usr/local/bin" "/usr/bin" "/bin"; do
    if [ -d "$dir" ]; then
        NEW_PATH="$NEW_PATH:$dir"
    fi
done
export PATH="${NEW_PATH#:}"  # Remove leading colon
```

## Exercise

Complete the exercise in `exercise.sh` to practice environment configuration for data engineering workflows.

## Quiz

Test your knowledge with `quiz.md`.

## Next Steps

Tomorrow we'll learn about Make and task automation to streamline development workflows.
