#!/bin/bash

# Day 5: Environment Variables and PATH - Exercise
# Practice configuring development environment for data engineering

echo "=== Day 5: Environment Variables and PATH Exercise ==="
echo

# Create test environment
mkdir -p env_config_lab
cd env_config_lab

echo "Creating development environment configuration..."

# Exercise 1: Understanding Environment Variables
echo "=== Exercise 1: Environment Variables Basics ==="
echo "TODO: Explore and understand current environment"
echo

echo "1.1 Current environment overview:"
# Your code here:
echo "User: $USER"
echo "Home: $HOME"
echo "Shell: $SHELL"
echo "Current directory: $PWD"
echo "PATH (first 3 directories): $(echo $PATH | cut -d: -f1-3)"

echo
echo "1.2 Check specific variables:"
# Your code here:
echo "EDITOR: ${EDITOR:-not set}"
echo "LANG: ${LANG:-not set}"
echo "PYTHONPATH: ${PYTHONPATH:-not set}"

echo
echo "1.3 Set temporary environment variables:"
# Your code here:
export DATA_PROJECT="data_pipeline_demo"
export LOG_LEVEL="DEBUG"
export TEMP_DIR="/tmp/data_work"

echo "Set DATA_PROJECT: $DATA_PROJECT"
echo "Set LOG_LEVEL: $LOG_LEVEL"
echo "Set TEMP_DIR: $TEMP_DIR"

echo

# Exercise 2: PATH Configuration
echo "=== Exercise 2: PATH Management ==="
echo "TODO: Practice modifying PATH variable"
echo

echo "2.1 Current PATH analysis:"
# Your code here:
echo "Current PATH has $(echo $PATH | tr ':' '\n' | wc -l) directories:"
echo $PATH | tr ':' '\n' | nl

echo
echo "2.2 Create custom bin directory and add to PATH:"
# Your code here:
mkdir -p "$HOME/custom_bin"

# Create a simple script
cat > "$HOME/custom_bin/datainfo" << 'EOF'
#!/bin/bash
echo "=== Data Info Tool ==="
echo "Date: $(date)"
echo "User: $USER"
echo "Data Project: ${DATA_PROJECT:-none}"
echo "Working Dir: $PWD"
EOF

chmod +x "$HOME/custom_bin/datainfo"

# Add to PATH (temporarily)
export PATH="$HOME/custom_bin:$PATH"

echo "Added $HOME/custom_bin to PATH"
echo "Testing custom command:"
datainfo

echo
echo "2.3 PATH verification:"
# Your code here:
echo "Which datainfo: $(which datainfo)"
echo "Type datainfo: $(type datainfo)"

echo

# Exercise 3: Shell Configuration
echo "=== Exercise 3: Shell Configuration Files ==="
echo "TODO: Create and manage shell configuration"
echo

echo "3.1 Identify current shell and config files:"
# Your code here:
echo "Current shell: $SHELL"
echo "Shell config files that exist:"
for config in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile; do
    if [ -f "$config" ]; then
        echo "  ✓ $config ($(wc -l < "$config") lines)"
    else
        echo "  ✗ $config (not found)"
    fi
done

echo
echo "3.2 Create a custom configuration file:"
# Your code here:
cat > custom_data_config.sh << 'EOF'
#!/bin/bash
# Custom Data Engineering Configuration

# Data Engineering Environment Variables
export DATA_HOME="$HOME/data"
export DATASETS_DIR="$DATA_HOME/datasets"
export MODELS_DIR="$DATA_HOME/models"
export LOGS_DIR="$DATA_HOME/logs"
export NOTEBOOKS_DIR="$DATA_HOME/notebooks"

# Python Configuration
export PYTHONPATH="$DATA_HOME/lib:$PYTHONPATH"
export JUPYTER_CONFIG_DIR="$HOME/.jupyter"

# Tool Preferences
export EDITOR="${EDITOR:-nano}"
export PAGER="${PAGER:-less}"

# Create directories if they don't exist
for dir in "$DATA_HOME" "$DATASETS_DIR" "$MODELS_DIR" "$LOGS_DIR" "$NOTEBOOKS_DIR"; do
    [ ! -d "$dir" ] && mkdir -p "$dir"
done

echo "Data engineering environment configured!"
echo "Data home: $DATA_HOME"
EOF

chmod +x custom_data_config.sh

echo "3.3 Source the configuration:"
# Your code here:
source custom_data_config.sh

echo "Configuration loaded. Checking directories:"
ls -la "$DATA_HOME"

echo

# Exercise 4: Aliases and Functions
echo "=== Exercise 4: Aliases and Functions ==="
echo "TODO: Create useful aliases and functions for data work"
echo

echo "4.1 Create data processing aliases:"
# Your code here:
alias ll='ls -la'
alias la='ls -A'
alias csv='column -t -s,'
alias json='python3 -m json.tool'
alias py='python3'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gl='git log --oneline -10'

echo "Created aliases:"
alias | grep -E "(ll|csv|json|py|gs)"

echo
echo "4.2 Create useful functions:"
# Your code here:

# Function to create and enter directory
mkcd() {
    mkdir -p "$1" && cd "$1"
    echo "Created and entered directory: $1"
}

# Function to backup files with timestamp
backup() {
    local source=$1
    local backup_name="${source}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -e "$source" ]; then
        cp -r "$source" "$backup_name"
        echo "✓ Backed up $source to $backup_name"
    else
        echo "✗ Source $source not found"
        return 1
    fi
}

# Function to analyze CSV files
csvinfo() {
    local file=$1
    
    if [ ! -f "$file" ]; then
        echo "File not found: $file"
        return 1
    fi
    
    echo "=== CSV Analysis: $file ==="
    echo "Total lines: $(wc -l < "$file")"
    echo "Data rows: $(($(wc -l < "$file") - 1))"
    echo "Columns: $(head -1 "$file" | tr ',' '\n' | wc -l)"
    echo "File size: $(du -h "$file" | cut -f1)"
    echo "Header: $(head -1 "$file")"
}

# Function to set up project environment
setup_project() {
    local project_name=$1
    
    if [ -z "$project_name" ]; then
        echo "Usage: setup_project <project_name>"
        return 1
    fi
    
    local project_dir="$DATA_HOME/projects/$project_name"
    
    echo "Setting up project: $project_name"
    mkdir -p "$project_dir"/{data,scripts,notebooks,output,logs}
    
    # Create basic project structure
    cat > "$project_dir/README.md" << PROJEOF
# $project_name

## Project Structure
- \`data/\` - Raw and processed data
- \`scripts/\` - Processing scripts
- \`notebooks/\` - Jupyter notebooks
- \`output/\` - Generated outputs
- \`logs/\` - Log files

## Setup
\`\`\`bash
cd $project_dir
source setup_env.sh
\`\`\`
PROJEOF

    cat > "$project_dir/setup_env.sh" << ENVEOF
#!/bin/bash
# Project environment setup for $project_name

export PROJECT_NAME="$project_name"
export PROJECT_DIR="$project_dir"
export PROJECT_DATA_DIR="\$PROJECT_DIR/data"
export PROJECT_OUTPUT_DIR="\$PROJECT_DIR/output"
export PROJECT_LOGS_DIR="\$PROJECT_DIR/logs"

echo "Environment set for project: $project_name"
echo "Project directory: \$PROJECT_DIR"
ENVEOF

    chmod +x "$project_dir/setup_env.sh"
    
    echo "✓ Project $project_name created at $project_dir"
    echo "✓ Run 'cd $project_dir && source setup_env.sh' to activate"
}

echo "Created functions: mkcd, backup, csvinfo, setup_project"

echo
echo "4.3 Test the functions:"
# Your code here:

# Test mkcd
echo "Testing mkcd function:"
mkcd "test_directory"
pwd
cd ..

# Test backup function
echo -e "name,age\nAlice,25\nBob,30" > sample.csv
echo "Testing backup function:"
backup sample.csv

# Test csvinfo function
echo "Testing csvinfo function:"
csvinfo sample.csv

# Test setup_project function
echo "Testing setup_project function:"
setup_project "demo_pipeline"

echo

# Exercise 5: Environment File Management
echo "=== Exercise 5: Environment File Management ==="
echo "TODO: Create and manage environment files"
echo

echo "5.1 Create project-specific .env file:"
# Your code here:
cat > project.env << 'EOF'
# Project Environment Configuration
PROJECT_NAME=data_analysis_project
DATABASE_URL=postgresql://localhost:5432/datadb
API_KEY=demo_api_key_12345
LOG_LEVEL=INFO
DEBUG_MODE=false
MAX_WORKERS=4
CACHE_SIZE=1000
OUTPUT_FORMAT=json
EOF

echo "Created project.env file:"
cat project.env

echo
echo "5.2 Create environment loading function:"
# Your code here:
load_env() {
    local env_file=${1:-.env}
    
    if [ ! -f "$env_file" ]; then
        echo "Environment file not found: $env_file"
        return 1
    fi
    
    echo "Loading environment from: $env_file"
    
    # Load variables (skip comments and empty lines)
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ $key =~ ^[[:space:]]*# ]] && continue
        [[ -z $key ]] && continue
        
        # Remove quotes if present
        value=$(echo "$value" | sed 's/^["'\'']//' | sed 's/["'\'']$//')
        
        export "$key=$value"
        echo "  $key=$value"
    done < "$env_file"
}

echo "5.3 Test environment loading:"
load_env project.env

echo "Loaded variables:"
echo "PROJECT_NAME: $PROJECT_NAME"
echo "DATABASE_URL: $DATABASE_URL"
echo "LOG_LEVEL: $LOG_LEVEL"

echo

# Exercise 6: Configuration Validation
echo "=== Exercise 6: Configuration Validation ==="
echo "TODO: Create tools to validate environment setup"
echo

echo "6.1 Environment validation function:"
# Your code here:
validate_env() {
    echo "=== Environment Validation ==="
    
    local issues=0
    
    # Check required directories
    echo "Checking directories:"
    for dir in "$HOME" "$DATA_HOME" "$DATASETS_DIR"; do
        if [ -d "$dir" ]; then
            echo "  ✓ $dir exists"
        else
            echo "  ✗ $dir missing"
            ((issues++))
        fi
    done
    
    # Check PATH
    echo "Checking PATH:"
    if echo "$PATH" | grep -q "$HOME/custom_bin"; then
        echo "  ✓ Custom bin directory in PATH"
    else
        echo "  ✗ Custom bin directory not in PATH"
        ((issues++))
    fi
    
    # Check required tools
    echo "Checking tools:"
    for tool in python3 git; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  ✓ $tool available at $(which $tool)"
        else
            echo "  ✗ $tool not found"
            ((issues++))
        fi
    done
    
    # Check environment variables
    echo "Checking environment variables:"
    for var in HOME USER SHELL; do
        if [ -n "${!var}" ]; then
            echo "  ✓ $var = ${!var}"
        else
            echo "  ✗ $var not set"
            ((issues++))
        fi
    done
    
    echo
    if [ $issues -eq 0 ]; then
        echo "✅ Environment validation passed!"
    else
        echo "⚠️  Environment validation found $issues issues"
    fi
    
    return $issues
}

echo "6.2 Run environment validation:"
validate_env

echo

# Exercise 7: Configuration Backup and Restore
echo "=== Exercise 7: Configuration Management ==="
echo "TODO: Create backup and restore system for configurations"
echo

echo "7.1 Configuration backup system:"
# Your code here:
backup_config() {
    local backup_dir="config_backup_$(date +%Y%m%d_%H%M%S)"
    
    echo "Creating configuration backup: $backup_dir"
    mkdir -p "$backup_dir"
    
    # Backup shell configurations
    for config in ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile; do
        if [ -f "$config" ]; then
            cp "$config" "$backup_dir/"
            echo "  ✓ Backed up $(basename "$config")"
        fi
    done
    
    # Backup custom configurations
    if [ -f "custom_data_config.sh" ]; then
        cp custom_data_config.sh "$backup_dir/"
        echo "  ✓ Backed up custom_data_config.sh"
    fi
    
    # Create environment snapshot
    printenv > "$backup_dir/environment_snapshot.txt"
    echo "  ✓ Created environment snapshot"
    
    # Create PATH snapshot
    echo "$PATH" > "$backup_dir/path_snapshot.txt"
    echo "  ✓ Created PATH snapshot"
    
    echo "Backup completed: $backup_dir"
}

echo "7.2 Create configuration summary:"
config_summary() {
    echo "=== Configuration Summary ==="
    echo "Date: $(date)"
    echo "User: $USER"
    echo "Shell: $SHELL"
    echo "Home: $HOME"
    echo
    
    echo "Environment Variables (custom):"
    printenv | grep -E "(DATA_|PROJECT_|LOG_)" | sort
    echo
    
    echo "PATH directories:"
    echo "$PATH" | tr ':' '\n' | nl
    echo
    
    echo "Aliases:"
    alias | head -10
    echo
    
    echo "Functions:"
    declare -F | head -10
}

echo "7.3 Generate reports:"
backup_config
config_summary > environment_summary.txt

echo "Configuration summary saved to environment_summary.txt"
head -20 environment_summary.txt

# Cleanup
cd ..

echo
echo "=== Exercise Complete ==="
echo
echo "You've practiced:"
echo "✓ Environment variable management and configuration"
echo "✓ PATH modification and custom tool installation"
echo "✓ Shell configuration file creation and management"
echo "✓ Useful aliases and functions for data engineering"
echo "✓ Project-specific environment setup"
echo "✓ Environment validation and troubleshooting"
echo "✓ Configuration backup and documentation"
echo
echo "Next: Run 'bash solution.sh' to see advanced environment management"
echo "Then: Complete the quiz in quiz.md"
