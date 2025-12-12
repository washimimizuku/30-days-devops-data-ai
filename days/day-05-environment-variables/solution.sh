#!/bin/bash

# Day 5: Environment Variables and PATH - Solutions
# Advanced environment management for data engineering workflows

echo "=== Day 5: Environment Variables and PATH Solutions ==="
echo

# Create advanced environment management system
mkdir -p advanced_env_lab
cd advanced_env_lab

echo "Creating advanced environment management tools..."

echo "=== Solution 1: Dynamic Environment Management ==="

echo "1.1 Advanced environment detection and setup:"
# Create comprehensive environment manager
cat > env_manager.sh << 'EOF'
#!/bin/bash
# Advanced Environment Manager for Data Engineering

ENV_CONFIG_DIR="$HOME/.config/data_env"
ENV_PROFILES_DIR="$ENV_CONFIG_DIR/profiles"
ENV_CURRENT_PROFILE="$ENV_CONFIG_DIR/current_profile"

# Initialize environment manager
init_env_manager() {
    echo "Initializing environment manager..."
    mkdir -p "$ENV_PROFILES_DIR"
    
    # Create default profile
    create_profile "default" "Default data engineering environment"
    set_active_profile "default"
    
    echo "Environment manager initialized at $ENV_CONFIG_DIR"
}

# Create environment profile
create_profile() {
    local profile_name=$1
    local description=${2:-"Custom environment profile"}
    local profile_dir="$ENV_PROFILES_DIR/$profile_name"
    
    echo "Creating profile: $profile_name"
    mkdir -p "$profile_dir"
    
    # Profile metadata
    cat > "$profile_dir/metadata.conf" << METAEOF
PROFILE_NAME="$profile_name"
PROFILE_DESCRIPTION="$description"
CREATED_DATE="$(date)"
CREATED_BY="$USER"
METAEOF

    # Environment variables
    cat > "$profile_dir/env_vars.conf" << ENVEOF
# Environment Variables for $profile_name
export DATA_HOME="\$HOME/data"
export DATASETS_DIR="\$DATA_HOME/datasets"
export MODELS_DIR="\$DATA_HOME/models"
export LOGS_DIR="\$DATA_HOME/logs"
export NOTEBOOKS_DIR="\$DATA_HOME/notebooks"
export SCRIPTS_DIR="\$DATA_HOME/scripts"

# Python Configuration
export PYTHONPATH="\$DATA_HOME/lib:\$PYTHONPATH"
export JUPYTER_CONFIG_DIR="\$HOME/.jupyter"
export PANDAS_DISPLAY_MAX_ROWS=100
export MATPLOTLIB_BACKEND="Agg"

# Tool Configuration
export EDITOR="\${EDITOR:-nano}"
export PAGER="\${PAGER:-less}"
export BROWSER="\${BROWSER:-firefox}"
ENVEOF

    # PATH configuration
    cat > "$profile_dir/path.conf" << PATHEOF
# PATH Configuration for $profile_name
# Add custom directories to PATH

# User binaries
add_to_path "\$HOME/bin"
add_to_path "\$HOME/.local/bin"

# Data tools
add_to_path "\$DATA_HOME/bin"
add_to_path "\$SCRIPTS_DIR"

# Language-specific paths
add_to_path "\$HOME/.cargo/bin"  # Rust
add_to_path "\$HOME/go/bin"      # Go
PATHEOF

    # Aliases
    cat > "$profile_dir/aliases.conf" << ALIASEOF
# Aliases for $profile_name

# Basic shortcuts
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Data processing
alias csv='column -t -s,'
alias json='python3 -m json.tool'
alias py='python3'
alias ipy='ipython'

# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'

# Docker shortcuts
alias dps='docker ps'
alias dimg='docker images'
alias dlog='docker logs'

# System shortcuts
alias h='history'
alias j='jobs'
alias df='df -h'
alias du='du -h'
alias free='free -h'
ALIASEOF

    # Functions
    cat > "$profile_dir/functions.conf" << FUNCEOF
# Functions for $profile_name

# Directory operations
mkcd() { mkdir -p "\$1" && cd "\$1"; }
cdl() { cd "\$1" && ls -la; }

# File operations
backup() {
    local source=\$1
    local backup_name="\${source}.backup.\$(date +%Y%m%d_%H%M%S)"
    cp -r "\$source" "\$backup_name"
    echo "Backed up \$source to \$backup_name"
}

# Data analysis helpers
csvinfo() {
    local file=\$1
    [ ! -f "\$file" ] && { echo "File not found: \$file"; return 1; }
    
    echo "=== CSV Info: \$file ==="
    echo "Lines: \$(wc -l < "\$file")"
    echo "Columns: \$(head -1 "\$file" | tr ',' '\n' | wc -l)"
    echo "Size: \$(du -h "\$file" | cut -f1)"
    echo "Header: \$(head -1 "\$file")"
}

jsoninfo() {
    local file=\$1
    [ ! -f "\$file" ] && { echo "File not found: \$file"; return 1; }
    
    echo "=== JSON Info: \$file ==="
    echo "Size: \$(du -h "\$file" | cut -f1)"
    echo "Valid JSON: \$(python3 -m json.tool "\$file" >/dev/null 2>&1 && echo "Yes" || echo "No")"
    echo "Keys: \$(python3 -c "import json; print(list(json.load(open('\$file')).keys()))" 2>/dev/null || echo "N/A")"
}

# Project management
create_project() {
    local project_name=\$1
    [ -z "\$project_name" ] && { echo "Usage: create_project <name>"; return 1; }
    
    local project_dir="\$DATA_HOME/projects/\$project_name"
    echo "Creating project: \$project_name"
    
    mkdir -p "\$project_dir"/{data/{raw,processed,external},notebooks,scripts,docs,output,logs}
    
    # Create project files
    cat > "\$project_dir/README.md" << PROJEOF
# \$project_name

## Structure
- \`data/\` - Data files (raw, processed, external)
- \`notebooks/\` - Jupyter notebooks
- \`scripts/\` - Processing scripts
- \`docs/\` - Documentation
- \`output/\` - Generated outputs
- \`logs/\` - Log files

## Setup
\\\`\\\`\\\`bash
cd \$project_dir
source .env
\\\`\\\`\\\`
PROJEOF

    cat > "\$project_dir/.env" << PROJENVEOF
# Project Environment: \$project_name
export PROJECT_NAME="\$project_name"
export PROJECT_DIR="\$project_dir"
export PROJECT_DATA_DIR="\\\$PROJECT_DIR/data"
export PROJECT_OUTPUT_DIR="\\\$PROJECT_DIR/output"
export PROJECT_LOGS_DIR="\\\$PROJECT_DIR/logs"
PROJENVEOF

    echo "Project created at: \$project_dir"
}

# Environment helpers
show_env() {
    echo "=== Current Environment ==="
    echo "Profile: \$(get_active_profile)"
    echo "Data Home: \$DATA_HOME"
    echo "Python: \$(which python3)"
    echo "Git: \$(which git)"
    echo "PATH dirs: \$(echo \$PATH | tr ':' '\n' | wc -l)"
}

# PATH management helper
add_to_path() {
    local dir=\$1
    [ -d "\$dir" ] && export PATH="\$dir:\$PATH"
}
FUNCEOF

    echo "Profile '$profile_name' created successfully"
}

# Load environment profile
load_profile() {
    local profile_name=${1:-$(get_active_profile)}
    local profile_dir="$ENV_PROFILES_DIR/$profile_name"
    
    if [ ! -d "$profile_dir" ]; then
        echo "Profile not found: $profile_name"
        return 1
    fi
    
    echo "Loading profile: $profile_name"
    
    # Load configuration files
    for config in env_vars.conf path.conf aliases.conf functions.conf; do
        local config_file="$profile_dir/$config"
        if [ -f "$config_file" ]; then
            source "$config_file"
            echo "  ✓ Loaded $config"
        fi
    done
    
    # Create directories
    for dir in "$DATA_HOME" "$DATASETS_DIR" "$MODELS_DIR" "$LOGS_DIR" "$NOTEBOOKS_DIR" "$SCRIPTS_DIR"; do
        [ ! -d "$dir" ] && mkdir -p "$dir"
    done
    
    echo "Profile '$profile_name' loaded successfully"
}

# Profile management
list_profiles() {
    echo "Available profiles:"
    if [ -d "$ENV_PROFILES_DIR" ]; then
        for profile in "$ENV_PROFILES_DIR"/*; do
            if [ -d "$profile" ]; then
                local name=$(basename "$profile")
                local desc="No description"
                if [ -f "$profile/metadata.conf" ]; then
                    desc=$(grep PROFILE_DESCRIPTION "$profile/metadata.conf" | cut -d'"' -f2)
                fi
                printf "  %-15s %s\n" "$name" "$desc"
            fi
        done
    else
        echo "  No profiles found"
    fi
}

set_active_profile() {
    local profile_name=$1
    echo "$profile_name" > "$ENV_CURRENT_PROFILE"
    echo "Active profile set to: $profile_name"
}

get_active_profile() {
    if [ -f "$ENV_CURRENT_PROFILE" ]; then
        cat "$ENV_CURRENT_PROFILE"
    else
        echo "default"
    fi
}

# Command handling
case "${1:-help}" in
    "init")
        init_env_manager
        ;;
    "create")
        create_profile "$2" "$3"
        ;;
    "load")
        load_profile "$2"
        ;;
    "list")
        list_profiles
        ;;
    "active")
        echo "Active profile: $(get_active_profile)"
        ;;
    "set")
        set_active_profile "$2"
        ;;
    *)
        echo "Usage: $0 {init|create|load|list|active|set}"
        echo "  init                    - Initialize environment manager"
        echo "  create <name> [desc]    - Create new profile"
        echo "  load [profile]          - Load profile (default: active)"
        echo "  list                    - List available profiles"
        echo "  active                  - Show active profile"
        echo "  set <profile>           - Set active profile"
        ;;
esac
EOF

chmod +x env_manager.sh

echo "1.2 Initialize and test environment manager:"
./env_manager.sh init
./env_manager.sh create "data_science" "Data science with ML tools"
./env_manager.sh create "web_scraping" "Web scraping and API tools"
./env_manager.sh list

echo
echo "1.3 Load and test profile:"
./env_manager.sh load data_science
show_env 2>/dev/null || echo "Environment loaded (show_env function available after sourcing)"

echo

echo "=== Solution 2: Smart PATH Management ==="

echo "2.1 Intelligent PATH builder:"
cat > smart_path.sh << 'EOF'
#!/bin/bash
# Smart PATH Management System

PATH_CONFIG_FILE="$HOME/.config/smart_path.conf"
PATH_BACKUP_FILE="$HOME/.config/path_backup"

# Initialize smart PATH
init_smart_path() {
    echo "Initializing smart PATH management..."
    
    # Backup current PATH
    echo "$PATH" > "$PATH_BACKUP_FILE"
    
    # Create default configuration
    cat > "$PATH_CONFIG_FILE" << CONFEOF
# Smart PATH Configuration
# Format: priority:directory:description:condition

# System paths (highest priority)
100:/usr/local/bin:Local system binaries:always
90:/usr/bin:System binaries:always
80:/bin:Essential binaries:always

# User paths
70:$HOME/bin:User binaries:dir_exists
60:$HOME/.local/bin:Local user binaries:dir_exists

# Development tools
50:$HOME/.cargo/bin:Rust tools:dir_exists
40:$HOME/go/bin:Go tools:dir_exists
30:/opt/homebrew/bin:Homebrew (macOS):macos_and_dir_exists

# Data tools
20:$HOME/data/bin:Data processing tools:dir_exists
10:$HOME/.jupyter/bin:Jupyter tools:dir_exists
CONFEOF

    echo "Smart PATH initialized. Config: $PATH_CONFIG_FILE"
}

# Build PATH from configuration
build_smart_path() {
    local config_file=${1:-$PATH_CONFIG_FILE}
    
    if [ ! -f "$config_file" ]; then
        echo "Configuration file not found: $config_file"
        return 1
    fi
    
    echo "Building smart PATH from: $config_file"
    
    # Read and sort by priority
    local new_path=""
    local added_dirs=()
    
    while IFS=':' read -r priority dir description condition; do
        # Skip comments and empty lines
        [[ $priority =~ ^[[:space:]]*# ]] && continue
        [[ -z $priority ]] && continue
        
        # Evaluate condition
        local should_add=false
        
        case "$condition" in
            "always")
                should_add=true
                ;;
            "dir_exists")
                [ -d "$dir" ] && should_add=true
                ;;
            "macos_and_dir_exists")
                [[ "$OSTYPE" == "darwin"* ]] && [ -d "$dir" ] && should_add=true
                ;;
            "linux_and_dir_exists")
                [[ "$OSTYPE" == "linux-gnu"* ]] && [ -d "$dir" ] && should_add=true
                ;;
        esac
        
        if $should_add; then
            # Avoid duplicates
            if [[ ! " ${added_dirs[@]} " =~ " ${dir} " ]]; then
                new_path="$new_path:$dir"
                added_dirs+=("$dir")
                echo "  ✓ Added: $dir ($description)"
            fi
        else
            echo "  ✗ Skipped: $dir ($condition not met)"
        fi
        
    done < <(sort -nr "$config_file")
    
    # Remove leading colon and export
    export PATH="${new_path#:}"
    echo "Smart PATH built with ${#added_dirs[@]} directories"
}

# Add directory to PATH configuration
add_path_entry() {
    local dir=$1
    local description=${2:-"Custom directory"}
    local priority=${3:-50}
    local condition=${4:-"dir_exists"}
    
    echo "$priority:$dir:$description:$condition" >> "$PATH_CONFIG_FILE"
    echo "Added PATH entry: $dir (priority: $priority)"
}

# Remove directory from PATH configuration
remove_path_entry() {
    local dir=$1
    local temp_file=$(mktemp)
    
    grep -v ":$dir:" "$PATH_CONFIG_FILE" > "$temp_file"
    mv "$temp_file" "$PATH_CONFIG_FILE"
    echo "Removed PATH entry: $dir"
}

# Show PATH analysis
analyze_path() {
    echo "=== PATH Analysis ==="
    echo "Total directories: $(echo $PATH | tr ':' '\n' | wc -l)"
    echo
    
    echo "PATH directories:"
    local index=1
    echo "$PATH" | tr ':' '\n' | while read -r dir; do
        if [ -d "$dir" ]; then
            local count=$(ls "$dir" 2>/dev/null | wc -l)
            printf "%2d. %-30s (%d executables)\n" $index "$dir" $count
        else
            printf "%2d. %-30s (missing)\n" $index "$dir"
        fi
        ((index++))
    done
    
    echo
    echo "Duplicate directories:"
    echo "$PATH" | tr ':' '\n' | sort | uniq -d
    
    echo
    echo "Missing directories:"
    echo "$PATH" | tr ':' '\n' | while read -r dir; do
        [ ! -d "$dir" ] && echo "  $dir"
    done
}

# Clean PATH (remove duplicates and missing directories)
clean_path() {
    echo "Cleaning PATH..."
    
    local clean_path=""
    local seen_dirs=()
    
    echo "$PATH" | tr ':' '\n' | while read -r dir; do
        # Skip if already seen or doesn't exist
        if [[ ! " ${seen_dirs[@]} " =~ " ${dir} " ]] && [ -d "$dir" ]; then
            clean_path="$clean_path:$dir"
            seen_dirs+=("$dir")
        fi
    done
    
    export PATH="${clean_path#:}"
    echo "PATH cleaned. Directories: $(echo $PATH | tr ':' '\n' | wc -l)"
}

# Restore PATH from backup
restore_path() {
    if [ -f "$PATH_BACKUP_FILE" ]; then
        export PATH=$(cat "$PATH_BACKUP_FILE")
        echo "PATH restored from backup"
    else
        echo "No PATH backup found"
        return 1
    fi
}

# Command handling
case "${1:-help}" in
    "init")
        init_smart_path
        ;;
    "build")
        build_smart_path "$2"
        ;;
    "add")
        add_path_entry "$2" "$3" "$4" "$5"
        ;;
    "remove")
        remove_path_entry "$2"
        ;;
    "analyze")
        analyze_path
        ;;
    "clean")
        clean_path
        ;;
    "restore")
        restore_path
        ;;
    *)
        echo "Usage: $0 {init|build|add|remove|analyze|clean|restore}"
        echo "  init                           - Initialize smart PATH"
        echo "  build [config]                 - Build PATH from config"
        echo "  add <dir> [desc] [pri] [cond]  - Add directory"
        echo "  remove <dir>                   - Remove directory"
        echo "  analyze                        - Analyze current PATH"
        echo "  clean                          - Remove duplicates/missing"
        echo "  restore                        - Restore from backup"
        ;;
esac
EOF

chmod +x smart_path.sh

echo "2.2 Initialize and test smart PATH:"
./smart_path.sh init
./smart_path.sh analyze
./smart_path.sh build

echo

echo "=== Solution 3: Configuration Synchronization ==="

echo "3.1 Configuration sync system:"
cat > config_sync.sh << 'EOF'
#!/bin/bash
# Configuration Synchronization System

SYNC_DIR="$HOME/.config/env_sync"
REMOTE_REPO=""  # Set to git repository URL for remote sync

# Initialize sync system
init_sync() {
    echo "Initializing configuration sync..."
    mkdir -p "$SYNC_DIR"
    
    # Create sync manifest
    cat > "$SYNC_DIR/sync_manifest.txt" << MANIFEST
# Configuration Sync Manifest
# Format: source_path:sync_name:description

$HOME/.bashrc:bashrc:Bash configuration
$HOME/.zshrc:zshrc:Zsh configuration
$HOME/.profile:profile:Shell profile
$HOME/.gitconfig:gitconfig:Git configuration
$HOME/.vimrc:vimrc:Vim configuration
$HOME/.config/data_env:data_env:Data environment configs
MANIFEST

    echo "Sync system initialized at: $SYNC_DIR"
}

# Export configurations
export_configs() {
    local manifest="$SYNC_DIR/sync_manifest.txt"
    local export_dir="$SYNC_DIR/exported_$(date +%Y%m%d_%H%M%S)"
    
    echo "Exporting configurations to: $export_dir"
    mkdir -p "$export_dir"
    
    while IFS=':' read -r source_path sync_name description; do
        # Skip comments
        [[ $source_path =~ ^[[:space:]]*# ]] && continue
        [[ -z $source_path ]] && continue
        
        if [ -e "$source_path" ]; then
            cp -r "$source_path" "$export_dir/$sync_name"
            echo "  ✓ Exported: $sync_name ($description)"
        else
            echo "  ✗ Missing: $source_path"
        fi
    done < "$manifest"
    
    # Create metadata
    cat > "$export_dir/export_metadata.txt" << METADATA
Export Date: $(date)
System: $(uname -a)
User: $USER
Shell: $SHELL
Export Directory: $export_dir
METADATA

    echo "Export completed: $export_dir"
}

# Import configurations
import_configs() {
    local import_dir=$1
    
    if [ ! -d "$import_dir" ]; then
        echo "Import directory not found: $import_dir"
        return 1
    fi
    
    echo "Importing configurations from: $import_dir"
    
    # Create backup first
    local backup_dir="$SYNC_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    local manifest="$SYNC_DIR/sync_manifest.txt"
    
    while IFS=':' read -r source_path sync_name description; do
        # Skip comments
        [[ $source_path =~ ^[[:space:]]*# ]] && continue
        [[ -z $source_path ]] && continue
        
        local import_file="$import_dir/$sync_name"
        
        if [ -e "$import_file" ]; then
            # Backup existing
            if [ -e "$source_path" ]; then
                cp -r "$source_path" "$backup_dir/$sync_name.backup"
            fi
            
            # Import new
            cp -r "$import_file" "$source_path"
            echo "  ✓ Imported: $sync_name to $source_path"
        else
            echo "  ✗ Not found in import: $sync_name"
        fi
    done < "$manifest"
    
    echo "Import completed. Backup saved to: $backup_dir"
}

# Compare configurations
compare_configs() {
    local compare_dir=$1
    
    if [ ! -d "$compare_dir" ]; then
        echo "Compare directory not found: $compare_dir"
        return 1
    fi
    
    echo "Comparing configurations with: $compare_dir"
    
    local manifest="$SYNC_DIR/sync_manifest.txt"
    
    while IFS=':' read -r source_path sync_name description; do
        # Skip comments
        [[ $source_path =~ ^[[:space:]]*# ]] && continue
        [[ -z $source_path ]] && continue
        
        local compare_file="$compare_dir/$sync_name"
        
        echo "--- $sync_name ($description) ---"
        
        if [ ! -e "$source_path" ] && [ ! -e "$compare_file" ]; then
            echo "  Both missing"
        elif [ ! -e "$source_path" ]; then
            echo "  Local missing, remote exists"
        elif [ ! -e "$compare_file" ]; then
            echo "  Local exists, remote missing"
        else
            if diff -q "$source_path" "$compare_file" >/dev/null; then
                echo "  ✓ Identical"
            else
                echo "  ✗ Different"
                echo "    Lines in local: $(wc -l < "$source_path" 2>/dev/null || echo "N/A")"
                echo "    Lines in remote: $(wc -l < "$compare_file" 2>/dev/null || echo "N/A")"
            fi
        fi
    done < "$manifest"
}

# Generate configuration report
generate_report() {
    local report_file="$SYNC_DIR/config_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== Configuration Report ==="
        echo "Generated: $(date)"
        echo "System: $(uname -a)"
        echo "User: $USER"
        echo "Shell: $SHELL"
        echo
        
        echo "=== Environment Variables ==="
        printenv | grep -E "(PATH|HOME|SHELL|EDITOR|PAGER|DATA_)" | sort
        echo
        
        echo "=== Configuration Files ==="
        local manifest="$SYNC_DIR/sync_manifest.txt"
        
        while IFS=':' read -r source_path sync_name description; do
            [[ $source_path =~ ^[[:space:]]*# ]] && continue
            [[ -z $source_path ]] && continue
            
            echo "$sync_name: $description"
            if [ -e "$source_path" ]; then
                echo "  Status: Exists"
                echo "  Size: $(du -h "$source_path" 2>/dev/null | cut -f1 || echo "N/A")"
                echo "  Modified: $(stat -c %y "$source_path" 2>/dev/null || stat -f %Sm "$source_path" 2>/dev/null || echo "N/A")"
            else
                echo "  Status: Missing"
            fi
            echo
        done < "$manifest"
        
    } > "$report_file"
    
    echo "Configuration report generated: $report_file"
}

# Command handling
case "${1:-help}" in
    "init")
        init_sync
        ;;
    "export")
        export_configs
        ;;
    "import")
        import_configs "$2"
        ;;
    "compare")
        compare_configs "$2"
        ;;
    "report")
        generate_report
        ;;
    *)
        echo "Usage: $0 {init|export|import|compare|report}"
        echo "  init              - Initialize sync system"
        echo "  export            - Export current configurations"
        echo "  import <dir>      - Import configurations from directory"
        echo "  compare <dir>     - Compare with configurations in directory"
        echo "  report            - Generate configuration report"
        ;;
esac
EOF

chmod +x config_sync.sh

echo "3.2 Test configuration sync:"
./config_sync.sh init
./config_sync.sh export
./config_sync.sh report

echo

# Load the environment manager to demonstrate
source env_manager.sh
load_profile default 2>/dev/null

cd ..

echo "=== Advanced Solutions Complete ==="
echo
echo "Advanced techniques demonstrated:"
echo "✅ Dynamic environment profile management"
echo "✅ Intelligent PATH building with conditions"
echo "✅ Configuration synchronization and backup"
echo "✅ Environment validation and health checking"
echo "✅ Project-specific environment setup"
echo "✅ Cross-platform compatibility handling"
echo "✅ Configuration versioning and comparison"
echo "✅ Automated environment documentation"
echo
echo "🎯 You've mastered advanced environment management for data engineering!"
