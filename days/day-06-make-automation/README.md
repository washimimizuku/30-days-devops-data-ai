# Day 6: Make and Task Automation

**Duration**: 1 hour  
**Prerequisites**: Day 5 - Environment Variables and PATH

## Learning Objectives

By the end of this lesson, you will:
- Understand Makefile syntax and structure
- Create targets, dependencies, and rules
- Use variables and functions in Makefiles
- Implement phony targets for task automation
- Build data processing pipelines with Make
- Explore modern alternatives like `just` and task runners

## Core Concepts

### 1. Makefile Basics

Make is a build automation tool that uses a `Makefile` to define tasks and their dependencies.

#### Basic Syntax
```makefile
target: dependencies
	command
	another_command
```

**Important**: Commands must be indented with a **TAB**, not spaces.

#### Simple Example
```makefile
# Basic Makefile
hello:
	echo "Hello, World!"

clean:
	rm -f *.tmp
```

### 2. Targets and Dependencies

#### File-based Targets
```makefile
# Target depends on source files
output.txt: input.txt process.py
	python process.py input.txt > output.txt

# Multiple dependencies
report.pdf: data.csv analysis.py template.tex
	python analysis.py data.csv
	pdflatex report.tex
```

#### Dependency Chains
```makefile
# Chain of dependencies
final_report.pdf: processed_data.csv
processed_data.csv: raw_data.csv clean_data.py
	python clean_data.py raw_data.csv processed_data.csv

raw_data.csv: download_data.py
	python download_data.py
```

### 3. Variables

#### Defining Variables
```makefile
# Variable definitions
PYTHON = python3
DATA_DIR = data
OUTPUT_DIR = output
SCRIPTS_DIR = scripts

# Using variables
process: $(DATA_DIR)/input.csv
	$(PYTHON) $(SCRIPTS_DIR)/process.py $< > $(OUTPUT_DIR)/result.csv
```

#### Automatic Variables
```makefile
# $@ = target name
# $< = first dependency
# $^ = all dependencies
# $? = dependencies newer than target

%.csv: %.json
	$(PYTHON) json_to_csv.py $< $@

process_all: file1.csv file2.csv file3.csv
	echo "Processed: $^"
```

### 4. Phony Targets

Phony targets don't create files - they're just task names.

```makefile
.PHONY: clean install test help

clean:
	rm -f *.tmp *.log
	rm -rf __pycache__

install:
	pip install -r requirements.txt

test:
	python -m pytest tests/

help:
	@echo "Available targets:"
	@echo "  clean    - Remove temporary files"
	@echo "  install  - Install dependencies"
	@echo "  test     - Run tests"
```

### 5. Pattern Rules and Functions

#### Pattern Rules
```makefile
# Process any .json file to .csv
%.csv: %.json
	$(PYTHON) json_to_csv.py $< $@

# Compile any .py file (syntax check)
%.pyc: %.py
	$(PYTHON) -m py_compile $<
```

#### Built-in Functions
```makefile
# String functions
SOURCES = $(wildcard *.py)
OBJECTS = $(patsubst %.py,%.pyc,$(SOURCES))

# Directory functions
SRC_DIR = src
SOURCES = $(wildcard $(SRC_DIR)/*.py)

# Shell function
CURRENT_DATE = $(shell date +%Y-%m-%d)
```

## Data Pipeline Examples

### Basic Data Processing Pipeline
```makefile
# Data Processing Pipeline
.PHONY: all clean download process analyze report

# Variables
PYTHON = python3
DATA_URL = https://example.com/data.csv
RAW_DATA = data/raw/dataset.csv
CLEAN_DATA = data/processed/clean_dataset.csv
ANALYSIS = output/analysis.json
REPORT = output/report.html

# Default target
all: $(REPORT)

# Download data
$(RAW_DATA):
	mkdir -p data/raw
	curl -o $@ $(DATA_URL)

# Clean data
$(CLEAN_DATA): $(RAW_DATA) scripts/clean_data.py
	mkdir -p data/processed
	$(PYTHON) scripts/clean_data.py $< $@

# Analyze data
$(ANALYSIS): $(CLEAN_DATA) scripts/analyze.py
	mkdir -p output
	$(PYTHON) scripts/analyze.py $< $@

# Generate report
$(REPORT): $(ANALYSIS) scripts/generate_report.py
	$(PYTHON) scripts/generate_report.py $< $@

# Utility targets
clean:
	rm -rf data/processed output

download: $(RAW_DATA)

process: $(CLEAN_DATA)

analyze: $(ANALYSIS)

help:
	@echo "Data Pipeline Makefile"
	@echo "Targets:"
	@echo "  all      - Run complete pipeline"
	@echo "  download - Download raw data"
	@echo "  process  - Clean and process data"
	@echo "  analyze  - Run analysis"
	@echo "  clean    - Remove generated files"
```

### Advanced Pipeline with Multiple Datasets
```makefile
# Multi-dataset Pipeline
.PHONY: all clean test

# Configuration
DATASETS = sales customers products
PYTHON = python3
DATE = $(shell date +%Y-%m-%d)

# Directories
RAW_DIR = data/raw
PROCESSED_DIR = data/processed
OUTPUT_DIR = output/$(DATE)

# File patterns
RAW_FILES = $(addprefix $(RAW_DIR)/,$(addsuffix .csv,$(DATASETS)))
PROCESSED_FILES = $(addprefix $(PROCESSED_DIR)/,$(addsuffix _clean.csv,$(DATASETS)))
ANALYSIS_FILES = $(addprefix $(OUTPUT_DIR)/,$(addsuffix _analysis.json,$(DATASETS)))

# Main targets
all: $(OUTPUT_DIR)/final_report.html

# Pattern rules
$(PROCESSED_DIR)/%_clean.csv: $(RAW_DIR)/%.csv scripts/clean_%.py
	mkdir -p $(PROCESSED_DIR)
	$(PYTHON) scripts/clean_$*.py $< $@

$(OUTPUT_DIR)/%_analysis.json: $(PROCESSED_DIR)/%_clean.csv scripts/analyze.py
	mkdir -p $(OUTPUT_DIR)
	$(PYTHON) scripts/analyze.py $< $@

# Final report
$(OUTPUT_DIR)/final_report.html: $(ANALYSIS_FILES) scripts/report.py
	$(PYTHON) scripts/report.py $(OUTPUT_DIR) $@

# Utility targets
clean:
	rm -rf $(PROCESSED_DIR) output

test:
	$(PYTHON) -m pytest tests/

install:
	pip install -r requirements.txt

status:
	@echo "Pipeline Status:"
	@echo "Raw files: $(words $(wildcard $(RAW_FILES))) / $(words $(RAW_FILES))"
	@echo "Processed files: $(words $(wildcard $(PROCESSED_FILES))) / $(words $(PROCESSED_FILES))"
	@echo "Analysis files: $(words $(wildcard $(ANALYSIS_FILES))) / $(words $(ANALYSIS_FILES))"
```

## Modern Alternatives

### just - A Command Runner
`just` is a modern alternative to Make with simpler syntax.

#### Installation
```bash
# macOS
brew install just

# Linux
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash
```

#### justfile Example
```just
# justfile - simpler than Makefile

# Variables
python := "python3"
data_dir := "data"

# Default recipe
default: process

# Download data
download:
    mkdir -p {{data_dir}}/raw
    curl -o {{data_dir}}/raw/data.csv https://example.com/data.csv

# Process data
process: download
    {{python}} scripts/process.py {{data_dir}}/raw/data.csv

# Clean up
clean:
    rm -rf {{data_dir}}/processed output

# Run tests
test:
    {{python}} -m pytest

# Show help
help:
    just --list
```

### Task Runners for Different Languages

#### Python: invoke
```python
# tasks.py
from invoke import task

@task
def download(c):
    """Download raw data"""
    c.run("mkdir -p data/raw")
    c.run("curl -o data/raw/data.csv https://example.com/data.csv")

@task(download)
def process(c):
    """Process downloaded data"""
    c.run("python scripts/process.py data/raw/data.csv")

@task
def clean(c):
    """Clean generated files"""
    c.run("rm -rf data/processed output")
```

#### Node.js: npm scripts
```json
{
  "scripts": {
    "download": "mkdir -p data/raw && curl -o data/raw/data.csv https://example.com/data.csv",
    "process": "npm run download && node scripts/process.js",
    "clean": "rm -rf data/processed output",
    "pipeline": "npm run process && node scripts/analyze.js"
  }
}
```

## Best Practices

### 1. Makefile Organization
```makefile
# Header with description
# Data Processing Pipeline Makefile
# Usage: make [target]

# Variables section
SHELL := /bin/bash
.DEFAULT_GOAL := help
.PHONY: all clean install test help

# Configuration
PYTHON := python3
DATA_DIR := data
OUTPUT_DIR := output

# Include other makefiles
include config.mk

# Targets organized by function
# ... rest of makefile
```

### 2. Error Handling
```makefile
# Stop on first error
.ONESHELL:

# Check dependencies
check-python:
	@which $(PYTHON) > /dev/null || (echo "Python not found" && exit 1)

process: check-python
	$(PYTHON) scripts/process.py
```

### 3. Parallel Execution
```makefile
# Enable parallel execution
MAKEFLAGS += -j4

# Process multiple files in parallel
all: file1.processed file2.processed file3.processed

%.processed: %.raw
	$(PYTHON) process.py $< $@
```

### 4. Documentation
```makefile
help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

clean: ## Remove generated files
	rm -rf output data/processed

install: ## Install dependencies
	pip install -r requirements.txt
```

## Common Patterns

### Conditional Execution
```makefile
# OS-specific commands
ifeq ($(OS),Windows_NT)
    RM = del /Q
    MKDIR = mkdir
else
    RM = rm -f
    MKDIR = mkdir -p
endif

clean:
	$(RM) *.tmp
```

### Timestamp-based Processing
```makefile
# Only process if source is newer
output/report.html: data/processed.csv scripts/report.py
	@echo "Generating report..."
	$(PYTHON) scripts/report.py $< $@
	@touch $@  # Update timestamp
```

### Configuration Management
```makefile
# Load configuration
include config.mk

# Default configuration
CONFIG ?= config/default.conf

process: $(CONFIG)
	$(PYTHON) scripts/process.py --config $<
```

## Exercise

Complete the exercise in `exercise.sh` to practice building data processing pipelines with Make.

## Quiz

Test your knowledge with `quiz.md`.

## Next Steps

Tomorrow we'll build a complete automated data pipeline project combining all the tools from Week 1.
