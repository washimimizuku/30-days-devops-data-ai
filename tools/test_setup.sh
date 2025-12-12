#!/bin/bash

# Setup verification script for 30 Days of Developer Tools
# This script checks if all essential tools are installed

echo "🔍 Checking your development environment..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track if all checks pass
ALL_GOOD=true

# Function to check if command exists
check_command() {
    local cmd=$1
    local name=$2
    local required=$3
    
    if command -v "$cmd" &> /dev/null; then
        version=$($cmd --version 2>&1 | head -n 1)
        echo -e "${GREEN}✅ $name: $version${NC}"
        return 0
    else
        if [ "$required" = "required" ]; then
            echo -e "${RED}❌ $name: Not found (REQUIRED)${NC}"
            ALL_GOOD=false
        else
            echo -e "${YELLOW}⚠️  $name: Not found (optional for later weeks)${NC}"
        fi
        return 1
    fi
}

# Essential tools (Week 1)
echo "📦 Essential Tools (Week 1):"
check_command "bash" "bash" "required"
check_command "git" "git" "required"
check_command "grep" "grep" "required"
check_command "sed" "sed" "required"
check_command "awk" "awk" "required"
check_command "jq" "jq" "required"
check_command "make" "make" "required"

echo ""
echo "🐍 Python (Week 4):"
check_command "python3" "python3" "optional"
check_command "pip3" "pip3" "optional"

echo ""
echo "🐳 Docker (Week 3):"
check_command "docker" "docker" "optional"
check_command "docker-compose" "docker-compose" "optional"

echo ""
echo "☁️  Cloud Tools (Week 4):"
check_command "aws" "AWS CLI" "optional"

echo ""
echo "📊 Data Tools (Week 1):"
check_command "csvkit" "csvkit" "optional"

echo ""
echo "---"

if [ "$ALL_GOOD" = true ]; then
    echo -e "${GREEN}✅ All essential tools installed! Ready to start Day 1${NC}"
    echo ""
    echo "📚 Next steps:"
    echo "   cd days/day-01-terminal-basics"
    echo "   cat README.md"
    exit 0
else
    echo -e "${RED}❌ Some required tools are missing${NC}"
    echo ""
    echo "📖 Installation instructions:"
    echo "   See QUICKSTART.md or docs/SETUP.md"
    echo ""
    echo "🔧 Quick install (macOS):"
    echo "   brew install git jq make"
    echo ""
    echo "🔧 Quick install (Linux):"
    echo "   sudo apt install -y git jq make"
    exit 1
fi
