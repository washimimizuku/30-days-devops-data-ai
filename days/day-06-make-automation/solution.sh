#!/bin/bash

# Day 6: Make and Task Automation - Solutions
# Advanced Make techniques and automation patterns

echo "=== Day 6: Make and Task Automation Solutions ==="
echo

# Create advanced automation lab
mkdir -p advanced_make_lab
cd advanced_make_lab

echo "Creating advanced Make automation system..."

# Create comprehensive directory structure
mkdir -p {data/{raw,processed,external,archive},scripts/{processing,analysis,utils},output/{reports,charts,exports},config,logs,tests,docs}

echo "=== Solution 1: Enterprise-Grade Makefile ==="

echo "1.1 Creating production-ready Makefile with advanced features:"
cat > Makefile << 'EOF'
# Enterprise Data Processing Pipeline
# Advanced Makefile with comprehensive features

# Shell and behavior configuration
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:
.SUFFIXES:

# Make configuration
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# Project metadata
PROJECT_NAME := data_pipeline
VERSION := $(shell git describe --tags --always 2>/dev/null || echo "dev")
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
BUILD_USER := $(shell whoami)

# Environment detection
OS := $(shell uname -s)
ARCH := $(shell uname -m)
IS_CI := $(if $(CI),true,false)

# Configuration
CONFIG_FILE := config/pipeline.conf
-include $(CONFIG_FILE)

# Default configuration values
PYTHON ?= python3
PARALLEL_JOBS ?= 4
LOG_LEVEL ?= INFO
OUTPUT_FORMAT ?= json
ENABLE_CACHE ?= true

# Directories
SRC_DIR := scripts
DATA_DIR := data
RAW_DIR := $(DATA_DIR)/raw
PROCESSED_DIR := $(DATA_DIR)/processed
EXTERNAL_DIR := $(DATA_DIR)/external
ARCHIVE_DIR := $(DATA_DIR)/archive
OUTPUT_DIR := output
REPORTS_DIR := $(OUTPUT_DIR)/reports
CHARTS_DIR := $(OUTPUT_DIR)/charts
EXPORTS_DIR := $(OUTPUT_DIR)/exports
CONFIG_DIR := config
LOGS_DIR := logs
TESTS_DIR := tests
DOCS_DIR := docs

# Timestamped directories
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)
RUN_DIR := $(OUTPUT_DIR)/runs/$(TIMESTAMP)
LOG_FILE := $(LOGS_DIR)/pipeline_$(TIMESTAMP).log

# File patterns
RAW_CSV_FILES := $(wildcard $(RAW_DIR)/*.csv)
RAW_JSON_FILES := $(wildcard $(RAW_DIR)/*.json)
PROCESSED_FILES := $(patsubst $(RAW_DIR)/%.csv,$(PROCESSED_DIR)/%.processed.csv,$(RAW_CSV_FILES))
ANALYSIS_FILES := $(patsubst $(PROCESSED_DIR)/%.processed.csv,$(RUN_DIR)/%.analysis.json,$(PROCESSED_FILES))

# Phony targets
.PHONY: all clean install test lint format check-deps setup-env
.PHONY: process analyze report deploy backup restore
.PHONY: help version status debug monitor
.PHONY: docker-build docker-run docker-clean

# Color output
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
MAGENTA := \033[35m
CYAN := \033[36m
WHITE := \033[37m
RESET := \033[0m

# Logging functions
define log_info
	@echo "$(CYAN)[INFO]$(RESET) $(1)"
endef

define log_warn
	@echo "$(YELLOW)[WARN]$(RESET) $(1)"
endef

define log_error
	@echo "$(RED)[ERROR]$(RESET) $(1)"
endef

define log_success
	@echo "$(GREEN)[SUCCESS]$(RESET) $(1)"
endef

# Main targets
all: setup-env process analyze report ## Run complete pipeline

# Environment setup
setup-env: $(LOGS_DIR) $(RUN_DIR) check-deps ## Setup environment and dependencies
	$(call log_info,Environment setup complete)

$(LOGS_DIR) $(RUN_DIR) $(PROCESSED_DIR) $(REPORTS_DIR) $(CHARTS_DIR) $(EXPORTS_DIR):
	@mkdir -p $@

# Dependency checking
check-deps: ## Check system dependencies
	$(call log_info,Checking dependencies...)
	@command -v $(PYTHON) >/dev/null || ($(call log_error,Python not found) && exit 1)
	@command -v git >/dev/null || $(call log_warn,Git not found - version info unavailable)
	@$(PYTHON) -c "import pandas, numpy, matplotlib" 2>/dev/null || \
		($(call log_error,Required Python packages missing. Run 'make install') && exit 1)
	$(call log_success,All dependencies satisfied)

# Installation
install: requirements.txt ## Install Python dependencies
	$(call log_info,Installing Python dependencies...)
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -r requirements.txt
	$(call log_success,Dependencies installed)

# Pattern rules with advanced features
$(PROCESSED_DIR)/%.processed.csv: $(RAW_DIR)/%.csv $(SRC_DIR)/processing/process_%.py | $(PROCESSED_DIR)
	$(call log_info,Processing $< -> $@)
	@echo "$(BUILD_DATE): Processing $<" >> $(LOG_FILE)
	$(PYTHON) $(SRC_DIR)/processing/process_$*.py $< $@ --log-level $(LOG_LEVEL)
	@touch $@  # Ensure timestamp is updated

$(RUN_DIR)/%.analysis.json: $(PROCESSED_DIR)/%.processed.csv $(SRC_DIR)/analysis/analyze.py | $(RUN_DIR)
	$(call log_info,Analyzing $< -> $@)
	$(PYTHON) $(SRC_DIR)/analysis/analyze.py $< $@ --format $(OUTPUT_FORMAT)

# Conditional processing based on file age
ifeq ($(ENABLE_CACHE),true)
$(PROCESSED_DIR)/%.processed.csv: $(RAW_DIR)/%.csv
	@if [ "$<" -nt "$@" ] || [ ! -f "$@" ]; then \
		$(call log_info,Cache miss - processing $<); \
		$(MAKE) --no-print-directory $@; \
	else \
		$(call log_info,Cache hit - using existing $@); \
	fi
endif

# Parallel processing
process: $(PROCESSED_FILES) ## Process all raw data files
	$(call log_success,Processing complete - $(words $(PROCESSED_FILES)) files processed)

analyze: $(ANALYSIS_FILES) ## Analyze all processed data
	$(call log_success,Analysis complete - $(words $(ANALYSIS_FILES)) analyses generated)

# Report generation with multiple formats
report: $(RUN_DIR)/final_report.html $(RUN_DIR)/final_report.pdf ## Generate comprehensive reports
	$(call log_success,Reports generated in $(RUN_DIR))

$(RUN_DIR)/final_report.html: $(ANALYSIS_FILES) $(SRC_DIR)/reporting/generate_html.py | $(RUN_DIR)
	$(call log_info,Generating HTML report...)
	$(PYTHON) $(SRC_DIR)/reporting/generate_html.py $(RUN_DIR) $@

$(RUN_DIR)/final_report.pdf: $(RUN_DIR)/final_report.html $(SRC_DIR)/reporting/html_to_pdf.py
	$(call log_info,Converting to PDF...)
	$(PYTHON) $(SRC_DIR)/reporting/html_to_pdf.py $< $@

# Quality assurance
test: ## Run test suite
	$(call log_info,Running tests...)
	$(PYTHON) -m pytest $(TESTS_DIR) -v --tb=short
	$(call log_success,All tests passed)

lint: ## Run code linting
	$(call log_info,Running linter...)
	$(PYTHON) -m flake8 $(SRC_DIR) --max-line-length=100
	$(call log_success,Linting passed)

format: ## Format code
	$(call log_info,Formatting code...)
	$(PYTHON) -m black $(SRC_DIR)
	$(call log_success,Code formatted)

# Utility targets
clean: ## Remove generated files
	$(call log_warn,Cleaning generated files...)
	rm -rf $(PROCESSED_DIR) $(OUTPUT_DIR)
	rm -f $(LOGS_DIR)/*.log
	$(call log_success,Cleanup complete)

backup: ## Create backup of current state
	$(call log_info,Creating backup...)
	@backup_file="backup_$(TIMESTAMP).tar.gz"; \
	tar -czf "$$backup_file" $(DATA_DIR) $(OUTPUT_DIR) $(CONFIG_DIR) 2>/dev/null || true; \
	$(call log_success,Backup created: $$backup_file)

status: ## Show pipeline status
	@echo "$(MAGENTA)=== Pipeline Status ===$(RESET)"
	@echo "Project: $(PROJECT_NAME)"
	@echo "Version: $(VERSION)"
	@echo "Build Date: $(BUILD_DATE)"
	@echo "Build User: $(BUILD_USER)"
	@echo "OS/Arch: $(OS)/$(ARCH)"
	@echo "CI Mode: $(IS_CI)"
	@echo ""
	@echo "Configuration:"
	@echo "  Python: $(PYTHON) ($(shell $(PYTHON) --version 2>&1))"
	@echo "  Parallel Jobs: $(PARALLEL_JOBS)"
	@echo "  Log Level: $(LOG_LEVEL)"
	@echo "  Cache Enabled: $(ENABLE_CACHE)"
	@echo ""
	@echo "Files:"
	@echo "  Raw CSV files: $(words $(RAW_CSV_FILES))"
	@echo "  Raw JSON files: $(words $(RAW_JSON_FILES))"
	@echo "  Processed files: $(words $(wildcard $(PROCESSED_FILES)))"
	@echo "  Analysis files: $(words $(wildcard $(ANALYSIS_FILES)))"

version: ## Show version information
	@echo "$(PROJECT_NAME) version $(VERSION)"
	@echo "Built on $(BUILD_DATE) by $(BUILD_USER)"

debug: ## Show debug information
	@echo "$(YELLOW)=== Debug Information ===$(RESET)"
	@echo "MAKEFLAGS: $(MAKEFLAGS)"
	@echo "SHELL: $(SHELL)"
	@echo "Raw files found: $(RAW_CSV_FILES)"
	@echo "Processed targets: $(PROCESSED_FILES)"
	@echo "Analysis targets: $(ANALYSIS_FILES)"

help: ## Show this help message
	@echo "$(BLUE)$(PROJECT_NAME) - Data Processing Pipeline$(RESET)"
	@echo "Version: $(VERSION)"
	@echo ""
	@echo "$(CYAN)Usage:$(RESET) make [target]"
	@echo ""
	@echo "$(CYAN)Targets:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(CYAN)Examples:$(RESET)"
	@echo "  make all              # Run complete pipeline"
	@echo "  make process          # Process raw data only"
	@echo "  make PARALLEL_JOBS=8  # Use 8 parallel jobs"
	@echo "  make LOG_LEVEL=DEBUG  # Enable debug logging"
EOF

echo "1.2 Creating configuration system:"
cat > config/pipeline.conf << 'EOF'
# Pipeline Configuration
PYTHON = python3
PARALLEL_JOBS = 4
LOG_LEVEL = INFO
OUTPUT_FORMAT = json
ENABLE_CACHE = true

# Data source configuration
DATA_SOURCE_URL = https://api.example.com/data
API_KEY_FILE = config/api_key.txt
REFRESH_INTERVAL = 3600

# Processing configuration
CHUNK_SIZE = 10000
MEMORY_LIMIT = 2GB
TIMEOUT = 300

# Output configuration
REPORT_TEMPLATE = templates/report.html
CHART_STYLE = seaborn
EXPORT_FORMATS = csv,json,parquet
EOF

echo "1.3 Creating requirements file:"
cat > requirements.txt << 'EOF'
pandas>=1.5.0
numpy>=1.21.0
matplotlib>=3.5.0
seaborn>=0.11.0
pytest>=7.0.0
flake8>=5.0.0
black>=22.0.0
jinja2>=3.0.0
pyyaml>=6.0.0
requests>=2.28.0
EOF

echo "Enterprise Makefile created with advanced features!"
echo
#!/bin/bash

# Day 6 Solutions - Part 2: Advanced automation tools

echo "=== Solution 2: Multi-Environment Build System ==="

echo "2.1 Creating environment-specific Makefiles:"
cat > Makefile.dev << 'EOF'
# Development Environment Makefile
include Makefile

# Development-specific overrides
LOG_LEVEL := DEBUG
PARALLEL_JOBS := 2
ENABLE_CACHE := false

# Development targets
dev-setup: install ## Setup development environment
	$(call log_info,Setting up development environment...)
	pre-commit install || true
	$(PYTHON) -m pip install -e .

dev-test: ## Run development tests with coverage
	$(call log_info,Running development tests...)
	$(PYTHON) -m pytest $(TESTS_DIR) --cov=$(SRC_DIR) --cov-report=html

dev-watch: ## Watch files and auto-rebuild
	$(call log_info,Starting file watcher...)
	while inotifywait -e modify $(SRC_DIR)/**/*.py; do \
		make process; \
	done

dev-profile: ## Profile pipeline performance
	$(call log_info,Profiling pipeline...)
	$(PYTHON) -m cProfile -o profile.stats $(SRC_DIR)/main.py
	$(PYTHON) -c "import pstats; pstats.Stats('profile.stats').sort_stats('cumulative').print_stats(20)"
EOF

cat > Makefile.prod << 'EOF'
# Production Environment Makefile
include Makefile

# Production-specific overrides
LOG_LEVEL := ERROR
PARALLEL_JOBS := 8
ENABLE_CACHE := true

# Production targets
prod-deploy: test lint ## Deploy to production
	$(call log_info,Deploying to production...)
	docker build -t $(PROJECT_NAME):$(VERSION) .
	docker tag $(PROJECT_NAME):$(VERSION) $(PROJECT_NAME):latest

prod-monitor: ## Monitor production pipeline
	$(call log_info,Monitoring production pipeline...)
	tail -f $(LOGS_DIR)/pipeline_*.log

prod-backup: ## Create production backup
	$(call log_info,Creating production backup...)
	aws s3 sync $(OUTPUT_DIR) s3://$(S3_BUCKET)/backups/$(TIMESTAMP)/
EOF

echo "2.2 Creating Docker integration:"
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    make \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Set up environment
ENV PYTHONPATH=/app
ENV LOG_LEVEL=INFO

# Default command
CMD ["make", "all"]
EOF

cat >> Makefile << 'EOF'

# Docker targets
docker-build: ## Build Docker image
	$(call log_info,Building Docker image...)
	docker build -t $(PROJECT_NAME):$(VERSION) .
	docker tag $(PROJECT_NAME):$(VERSION) $(PROJECT_NAME):latest

docker-run: docker-build ## Run pipeline in Docker
	$(call log_info,Running pipeline in Docker...)
	docker run --rm -v $(PWD)/data:/app/data -v $(PWD)/output:/app/output $(PROJECT_NAME):latest

docker-shell: docker-build ## Open shell in Docker container
	docker run --rm -it -v $(PWD):/app $(PROJECT_NAME):latest /bin/bash

docker-clean: ## Clean Docker images
	docker rmi $(PROJECT_NAME):$(VERSION) $(PROJECT_NAME):latest 2>/dev/null || true
EOF

echo "=== Solution 3: Advanced Task Orchestration ==="

echo "3.1 Creating sophisticated justfile:"
cat > justfile.advanced << 'EOF'
# Advanced justfile with complex workflows

# Configuration
python := "python3"
project := "data_pipeline"
version := `git describe --tags --always 2>/dev/null || echo "dev"`

# Environment detection
os := if os() == "linux" { "linux" } else if os() == "macos" { "darwin" } else { "windows" }
arch := arch()

# Default recipe
default: help

# Setup and installation
[group('setup')]
install: ## Install all dependencies
    {{python}} -m pip install --upgrade pip
    {{python}} -m pip install -r requirements.txt

[group('setup')]
setup-dev: install ## Setup development environment
    {{python}} -m pip install -e .
    pre-commit install || echo "pre-commit not available"

[group('setup')]
setup-prod: install ## Setup production environment
    {{python}} -m pip install --no-dev

# Data processing workflows
[group('data')]
download *args: ## Download data with optional arguments
    mkdir -p data/raw
    {{python}} scripts/download.py {{args}}

[group('data')]
process dataset="all": ## Process specific dataset or all
    #!/usr/bin/env bash
    if [ "{{dataset}}" = "all" ]; then
        for file in data/raw/*.csv; do
            echo "Processing $file..."
            {{python}} scripts/process.py "$file"
        done
    else
        {{python}} scripts/process.py "data/raw/{{dataset}}.csv"
    fi

[group('data')]
analyze format="json": ## Run analysis with specified output format
    mkdir -p output
    {{python}} scripts/analyze.py --format {{format}}

# Quality assurance
[group('qa')]
test *args: ## Run tests with optional pytest arguments
    {{python}} -m pytest tests/ {{args}}

[group('qa')]
test-coverage: ## Run tests with coverage report
    {{python}} -m pytest tests/ --cov=scripts --cov-report=html --cov-report=term

[group('qa')]
lint: ## Run code linting
    {{python}} -m flake8 scripts/
    {{python}} -m black --check scripts/

[group('qa')]
format: ## Format code
    {{python}} -m black scripts/
    {{python}} -m isort scripts/

# Deployment and operations
[group('ops')]
build: ## Build Docker image
    docker build -t {{project}}:{{version}} .
    docker tag {{project}}:{{version}} {{project}}:latest

[group('ops')]
deploy env="dev": build ## Deploy to specified environment
    #!/usr/bin/env bash
    case "{{env}}" in
        "dev")
            echo "Deploying to development..."
            docker run --rm {{project}}:latest
            ;;
        "prod")
            echo "Deploying to production..."
            # Add production deployment logic
            ;;
        *)
            echo "Unknown environment: {{env}}"
            exit 1
            ;;
    esac

[group('ops')]
backup: ## Create backup
    #!/usr/bin/env bash
    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="backup_${timestamp}.tar.gz"
    tar -czf "$backup_file" data/ output/ config/
    echo "Backup created: $backup_file"

# Monitoring and debugging
[group('debug')]
status: ## Show project status
    @echo "Project: {{project}}"
    @echo "Version: {{version}}"
    @echo "OS/Arch: {{os}}/{{arch}}"
    @echo "Python: $({{python}} --version)"
    @echo ""
    @echo "Data files:"
    @ls -la data/raw/ 2>/dev/null || echo "  No raw data found"
    @echo ""
    @echo "Output files:"
    @ls -la output/ 2>/dev/null || echo "  No output files found"

[group('debug')]
logs: ## Show recent logs
    tail -f logs/*.log 2>/dev/null || echo "No log files found"

[group('debug')]
profile: ## Profile pipeline performance
    {{python}} -m cProfile -o profile.stats scripts/main.py
    {{python}} -c "import pstats; pstats.Stats('profile.stats').sort_stats('cumulative').print_stats(20)"

# Utility recipes
[group('utils')]
clean level="basic": ## Clean generated files (basic|full|all)
    #!/usr/bin/env bash
    case "{{level}}" in
        "basic")
            rm -rf output/temp/ logs/*.log
            ;;
        "full")
            rm -rf output/ data/processed/
            ;;
        "all")
            rm -rf output/ data/processed/ data/cache/ __pycache__/ .pytest_cache/
            ;;
        *)
            echo "Unknown clean level: {{level}}"
            exit 1
            ;;
    esac

[group('utils')]
reset: ## Reset project to clean state
    just clean all
    git clean -fdx || echo "Not a git repository"

# Help and documentation
help: ## Show this help message
    @echo "{{project}} - Advanced Data Pipeline"
    @echo "Version: {{version}}"
    @echo ""
    @just --list --unsorted
    @echo ""
    @echo "Examples:"
    @echo "  just setup-dev           # Setup development environment"
    @echo "  just process sales       # Process sales dataset"
    @echo "  just test --verbose      # Run tests with verbose output"
    @echo "  just deploy prod         # Deploy to production"
EOF

echo "3.2 Creating Python invoke tasks with advanced features:"
cat > tasks_advanced.py << 'EOF'
from invoke import task, Collection
import os
import sys
from pathlib import Path

# Configuration
PROJECT_NAME = "data_pipeline"
PYTHON = sys.executable
DATA_DIR = Path("data")
OUTPUT_DIR = Path("output")
SCRIPTS_DIR = Path("scripts")

# Utility functions
def log_info(msg):
    print(f"\033[36m[INFO]\033[0m {msg}")

def log_success(msg):
    print(f"\033[32m[SUCCESS]\033[0m {msg}")

def log_error(msg):
    print(f"\033[31m[ERROR]\033[0m {msg}")

# Setup tasks
@task
def install(c):
    """Install Python dependencies"""
    log_info("Installing dependencies...")
    c.run(f"{PYTHON} -m pip install --upgrade pip")
    c.run(f"{PYTHON} -m pip install -r requirements.txt")
    log_success("Dependencies installed")

@task
def setup_dev(c):
    """Setup development environment"""
    log_info("Setting up development environment...")
    install(c)
    c.run(f"{PYTHON} -m pip install -e .", warn=True)
    c.run("pre-commit install", warn=True)
    log_success("Development environment ready")

# Data processing tasks
@task
def download(c, source="default"):
    """Download data from specified source"""
    log_info(f"Downloading data from {source}...")
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    c.run(f"{PYTHON} {SCRIPTS_DIR}/download.py --source {source}")

@task
def process(c, dataset="all", parallel=True):
    """Process datasets with optional parallelization"""
    log_info(f"Processing dataset: {dataset}")
    
    if dataset == "all":
        raw_files = list((DATA_DIR / "raw").glob("*.csv"))
        if parallel and len(raw_files) > 1:
            # Process in parallel using multiprocessing
            c.run(f"{PYTHON} {SCRIPTS_DIR}/process_parallel.py")
        else:
            for file in raw_files:
                c.run(f"{PYTHON} {SCRIPTS_DIR}/process.py {file}")
    else:
        c.run(f"{PYTHON} {SCRIPTS_DIR}/process.py {DATA_DIR}/raw/{dataset}.csv")
    
    log_success("Processing complete")

@task
def analyze(c, format="json", output_dir=None):
    """Run data analysis with specified format"""
    if output_dir is None:
        output_dir = OUTPUT_DIR
    
    log_info(f"Running analysis (format: {format})...")
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    c.run(f"{PYTHON} {SCRIPTS_DIR}/analyze.py --format {format} --output {output_dir}")

# Quality assurance tasks
@task
def test(c, coverage=False, verbose=False):
    """Run test suite with optional coverage"""
    log_info("Running tests...")
    
    cmd = f"{PYTHON} -m pytest tests/"
    if coverage:
        cmd += " --cov=scripts --cov-report=html --cov-report=term"
    if verbose:
        cmd += " -v"
    
    result = c.run(cmd, warn=True)
    if result.ok:
        log_success("All tests passed")
    else:
        log_error("Some tests failed")
        sys.exit(1)

@task
def lint(c, fix=False):
    """Run code linting with optional auto-fix"""
    log_info("Running linter...")
    
    # Run flake8
    c.run(f"{PYTHON} -m flake8 {SCRIPTS_DIR}/", warn=True)
    
    # Run black
    if fix:
        c.run(f"{PYTHON} -m black {SCRIPTS_DIR}/")
        c.run(f"{PYTHON} -m isort {SCRIPTS_DIR}/")
        log_success("Code formatted")
    else:
        c.run(f"{PYTHON} -m black --check {SCRIPTS_DIR}/", warn=True)

# Pipeline tasks
@task(pre=[process, analyze])
def pipeline(c, format="json"):
    """Run complete data pipeline"""
    log_info("Running complete pipeline...")
    
    # Generate reports
    c.run(f"{PYTHON} {SCRIPTS_DIR}/generate_report.py --format {format}")
    
    log_success("Pipeline completed successfully")

# Operations tasks
@task
def build(c, tag="latest"):
    """Build Docker image"""
    log_info(f"Building Docker image with tag: {tag}")
    c.run(f"docker build -t {PROJECT_NAME}:{tag} .")

@task(pre=[build])
def deploy(c, env="dev", tag="latest"):
    """Deploy to specified environment"""
    log_info(f"Deploying to {env} environment...")
    
    if env == "dev":
        c.run(f"docker run --rm -v $(pwd)/data:/app/data {PROJECT_NAME}:{tag}")
    elif env == "prod":
        # Add production deployment logic
        log_info("Production deployment not implemented")
    else:
        log_error(f"Unknown environment: {env}")
        sys.exit(1)

@task
def backup(c, destination="./backups"):
    """Create backup of current state"""
    from datetime import datetime
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = f"{destination}/backup_{timestamp}.tar.gz"
    
    log_info(f"Creating backup: {backup_file}")
    Path(destination).mkdir(parents=True, exist_ok=True)
    c.run(f"tar -czf {backup_file} data/ output/ config/")
    log_success(f"Backup created: {backup_file}")

# Utility tasks
@task
def clean(c, level="basic"):
    """Clean generated files (basic|full|all)"""
    log_info(f"Cleaning with level: {level}")
    
    if level == "basic":
        c.run("rm -rf output/temp/ logs/*.log", warn=True)
    elif level == "full":
        c.run("rm -rf output/ data/processed/", warn=True)
    elif level == "all":
        c.run("rm -rf output/ data/processed/ __pycache__/ .pytest_cache/", warn=True)
    else:
        log_error(f"Unknown clean level: {level}")
        sys.exit(1)
    
    log_success("Cleanup complete")

@task
def status(c):
    """Show project status"""
    print(f"Project: {PROJECT_NAME}")
    print(f"Python: {PYTHON}")
    print(f"Working Directory: {os.getcwd()}")
    print()
    
    print("Data files:")
    if (DATA_DIR / "raw").exists():
        c.run(f"ls -la {DATA_DIR}/raw/", warn=True)
    else:
        print("  No raw data directory found")
    
    print("\nOutput files:")
    if OUTPUT_DIR.exists():
        c.run(f"ls -la {OUTPUT_DIR}/", warn=True)
    else:
        print("  No output directory found")

# Create collections for better organization
setup_tasks = Collection('setup')
setup_tasks.add_task(install)
setup_tasks.add_task(setup_dev, 'dev')

data_tasks = Collection('data')
data_tasks.add_task(download)
data_tasks.add_task(process)
data_tasks.add_task(analyze)

qa_tasks = Collection('qa')
qa_tasks.add_task(test)
qa_tasks.add_task(lint)

ops_tasks = Collection('ops')
ops_tasks.add_task(build)
ops_tasks.add_task(deploy)
ops_tasks.add_task(backup)

# Main namespace
ns = Collection()
ns.add_collection(setup_tasks)
ns.add_collection(data_tasks)
ns.add_collection(qa_tasks)
ns.add_collection(ops_tasks)
ns.add_task(pipeline)
ns.add_task(clean)
ns.add_task(status)
EOF

echo "Advanced task orchestration tools created!"
echo
#!/bin/bash

# Day 6 Solutions - Part 3: Testing and demonstration

echo "=== Solution 4: Continuous Integration Integration ==="

echo "4.1 Creating GitHub Actions workflow:"
mkdir -p .github/workflows
cat > .github/workflows/pipeline.yml << 'EOF'
name: Data Pipeline CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

env:
  PYTHON_VERSION: '3.11'
  CACHE_VERSION: v1

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11']
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Cache dependencies
      uses: actions/cache@v3
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ env.CACHE_VERSION }}-${{ hashFiles('requirements.txt') }}
    
    - name: Install dependencies
      run: make install
    
    - name: Run linting
      run: make lint
    
    - name: Run tests
      run: make test
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      if: matrix.python-version == '3.11'

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build Docker image
      run: make docker-build
    
    - name: Test Docker image
      run: make docker-run

  deploy:
    needs: [test, build]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to production
      run: make prod-deploy
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
EOF

echo "4.2 Creating pre-commit configuration:"
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict

  - repo: https://github.com/psf/black
    rev: 23.3.0
    hooks:
      - id: black
        language_version: python3

  - repo: https://github.com/pycqa/flake8
    rev: 6.0.0
    hooks:
      - id: flake8
        args: [--max-line-length=100]

  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
        args: [--profile=black]

  - repo: local
    hooks:
      - id: make-test
        name: Run Make tests
        entry: make test
        language: system
        pass_filenames: false
        always_run: true
EOF

echo "=== Solution 5: Performance Optimization ==="

echo "5.1 Creating performance-optimized Makefile:"
cat > Makefile.performance << 'EOF'
# Performance-Optimized Makefile

# Enable parallel execution by default
MAKEFLAGS += -j$(shell nproc 2>/dev/null || echo 4)

# Use faster shell
SHELL := /bin/dash

# Optimize for speed
.NOTPARALLEL: help status version
.ONESHELL:

# Performance variables
CHUNK_SIZE ?= 10000
MEMORY_LIMIT ?= 2G
PARALLEL_WORKERS ?= $(shell nproc)

# Cached intermediate files
CACHE_DIR := .make_cache
$(CACHE_DIR):
	@mkdir -p $@

# Fast dependency checking
.PHONY: check-fast-deps
check-fast-deps: | $(CACHE_DIR)
	@if [ ! -f $(CACHE_DIR)/deps_checked ]; then \
		echo "Checking dependencies..."; \
		command -v python3 >/dev/null && \
		python3 -c "import pandas" 2>/dev/null && \
		touch $(CACHE_DIR)/deps_checked; \
	fi

# Optimized pattern rules
$(PROCESSED_DIR)/%.fast.csv: $(RAW_DIR)/%.csv | check-fast-deps $(PROCESSED_DIR)
	@echo "Fast processing: $< -> $@"
	python3 -c "
import pandas as pd
import sys
df = pd.read_csv('$<', chunksize=$(CHUNK_SIZE))
processed = pd.concat([chunk.dropna() for chunk in df])
processed.to_csv('$@', index=False)
"

# Memory-efficient processing
process-memory-efficient: $(patsubst $(RAW_DIR)/%.csv,$(PROCESSED_DIR)/%.fast.csv,$(wildcard $(RAW_DIR)/*.csv))
	@echo "Memory-efficient processing complete"

# Parallel processing with GNU parallel
process-parallel: | check-fast-deps
	@echo "Starting parallel processing..."
	find $(RAW_DIR) -name "*.csv" | \
	parallel -j$(PARALLEL_WORKERS) --bar \
		'python3 scripts/process_single.py {} $(PROCESSED_DIR)/{/.}_processed.csv'

# Clean cache
clean-cache:
	rm -rf $(CACHE_DIR)

clean: clean-cache
EOF

echo "5.2 Creating monitoring and profiling tools:"
cat > scripts/monitor_make.py << 'EOF'
#!/usr/bin/env python3
"""
Make process monitor - tracks resource usage during Make execution
"""
import psutil
import time
import sys
import json
from datetime import datetime
import subprocess
import threading

class MakeMonitor:
    def __init__(self, make_command):
        self.make_command = make_command
        self.monitoring = False
        self.stats = []
        
    def monitor_resources(self):
        """Monitor system resources during Make execution"""
        while self.monitoring:
            stats = {
                'timestamp': datetime.now().isoformat(),
                'cpu_percent': psutil.cpu_percent(interval=1),
                'memory_percent': psutil.virtual_memory().percent,
                'disk_io': psutil.disk_io_counters()._asdict() if psutil.disk_io_counters() else {},
                'load_avg': psutil.getloadavg() if hasattr(psutil, 'getloadavg') else [0, 0, 0]
            }
            self.stats.append(stats)
            time.sleep(2)
    
    def run_make(self):
        """Run Make command and monitor it"""
        print(f"Starting Make command: {' '.join(self.make_command)}")
        
        # Start monitoring
        self.monitoring = True
        monitor_thread = threading.Thread(target=self.monitor_resources)
        monitor_thread.start()
        
        # Run Make
        start_time = time.time()
        try:
            result = subprocess.run(self.make_command, capture_output=True, text=True)
            end_time = time.time()
            
            # Stop monitoring
            self.monitoring = False
            monitor_thread.join()
            
            # Generate report
            self.generate_report(start_time, end_time, result)
            
        except KeyboardInterrupt:
            self.monitoring = False
            monitor_thread.join()
            print("\nMonitoring interrupted")
    
    def generate_report(self, start_time, end_time, result):
        """Generate performance report"""
        duration = end_time - start_time
        
        if self.stats:
            avg_cpu = sum(s['cpu_percent'] for s in self.stats) / len(self.stats)
            max_cpu = max(s['cpu_percent'] for s in self.stats)
            avg_memory = sum(s['memory_percent'] for s in self.stats) / len(self.stats)
            max_memory = max(s['memory_percent'] for s in self.stats)
        else:
            avg_cpu = max_cpu = avg_memory = max_memory = 0
        
        report = {
            'command': ' '.join(self.make_command),
            'duration': duration,
            'exit_code': result.returncode,
            'performance': {
                'avg_cpu_percent': avg_cpu,
                'max_cpu_percent': max_cpu,
                'avg_memory_percent': avg_memory,
                'max_memory_percent': max_memory
            },
            'output': result.stdout,
            'errors': result.stderr
        }
        
        # Save detailed stats
        with open('make_performance.json', 'w') as f:
            json.dump({
                'summary': report,
                'detailed_stats': self.stats
            }, f, indent=2)
        
        # Print summary
        print(f"\n=== Make Performance Report ===")
        print(f"Duration: {duration:.2f} seconds")
        print(f"Exit Code: {result.returncode}")
        print(f"Average CPU: {avg_cpu:.1f}%")
        print(f"Peak CPU: {max_cpu:.1f}%")
        print(f"Average Memory: {avg_memory:.1f}%")
        print(f"Peak Memory: {max_memory:.1f}%")
        print(f"Detailed report saved to: make_performance.json")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 monitor_make.py <make_command> [args...]")
        sys.exit(1)
    
    make_command = sys.argv[1:]
    monitor = MakeMonitor(make_command)
    monitor.run_make()
EOF

chmod +x scripts/monitor_make.py

echo "=== Solution 6: Testing and Demonstration ==="

echo "6.1 Creating sample data and scripts for testing:"
# Create sample processing scripts
mkdir -p scripts/{processing,analysis,reporting,utils}

cat > scripts/processing/process_sales.py << 'EOF'
#!/usr/bin/env python3
import sys
import pandas as pd
import time

def process_sales(input_file, output_file):
    print(f"Processing sales data: {input_file}")
    time.sleep(0.5)  # Simulate processing time
    
    df = pd.read_csv(input_file)
    df['revenue'] = df['price'] * df['quantity']
    df['processed_date'] = pd.Timestamp.now()
    
    df.to_csv(output_file, index=False)
    print(f"Sales processing complete: {output_file}")

if __name__ == "__main__":
    process_sales(sys.argv[1], sys.argv[2])
EOF

cat > scripts/analysis/analyze.py << 'EOF'
#!/usr/bin/env python3
import sys
import pandas as pd
import json
import argparse

def analyze_data(input_file, output_file, format='json'):
    print(f"Analyzing data: {input_file}")
    
    df = pd.read_csv(input_file)
    
    analysis = {
        'total_records': len(df),
        'total_revenue': float(df['revenue'].sum()) if 'revenue' in df.columns else 0,
        'avg_revenue': float(df['revenue'].mean()) if 'revenue' in df.columns else 0,
        'analysis_timestamp': pd.Timestamp.now().isoformat()
    }
    
    if format == 'json':
        with open(output_file, 'w') as f:
            json.dump(analysis, f, indent=2)
    
    print(f"Analysis complete: {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('input_file')
    parser.add_argument('output_file')
    parser.add_argument('--format', default='json')
    
    args = parser.parse_args()
    analyze_data(args.input_file, args.output_file, args.format)
EOF

chmod +x scripts/processing/*.py scripts/analysis/*.py

# Create sample data
cat > data/raw/sales.csv << 'EOF'
date,product,price,quantity
2023-12-01,Laptop,999.99,2
2023-12-01,Mouse,25.50,5
2023-12-02,Keyboard,75.00,3
EOF

echo "6.2 Testing the complete system:"
echo "Testing basic Makefile functionality..."
make -f Makefile help
echo
make -f Makefile status
echo

echo "Testing advanced features..."
if command -v just >/dev/null 2>&1; then
    echo "Testing justfile..."
    just -f justfile.advanced help
else
    echo "just not installed - skipping justfile test"
fi

echo
echo "Testing Python invoke tasks..."
if python3 -c "import invoke" 2>/dev/null; then
    echo "invoke available - testing tasks"
    python3 -c "from tasks_advanced import status; status(None)"
else
    echo "invoke not installed - skipping invoke test"
fi

# Combine all solution parts
cd ..
cat solution.sh solution_part2.sh solution_part3.sh > solution_combined.sh
mv solution_combined.sh solution.sh
rm solution_part2.sh solution_part3.sh

cd advanced_make_lab

echo
echo "=== Advanced Solutions Complete ==="
echo
echo "Advanced techniques demonstrated:"
echo "✅ Enterprise-grade Makefile with comprehensive features"
echo "✅ Multi-environment build system (dev/prod)"
echo "✅ Docker integration and containerization"
echo "✅ Advanced task orchestration with justfile"
echo "✅ Sophisticated Python invoke tasks with collections"
echo "✅ CI/CD integration with GitHub Actions"
echo "✅ Performance optimization and monitoring"
echo "✅ Resource usage tracking and profiling"
echo "✅ Pre-commit hooks and code quality"
echo "✅ Parallel processing and optimization"
echo
echo "🎯 You've mastered advanced automation for data engineering pipelines!"
echo
echo "Files created:"
echo "- Makefile (enterprise-grade with advanced features)"
echo "- Makefile.dev / Makefile.prod (environment-specific)"
echo "- justfile.advanced (modern task runner)"
echo "- tasks_advanced.py (Python invoke with collections)"
echo "- Dockerfile (containerization)"
echo "- .github/workflows/pipeline.yml (CI/CD)"
echo "- Performance monitoring and profiling tools"
