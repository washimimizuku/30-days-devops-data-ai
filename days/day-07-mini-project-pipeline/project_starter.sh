#!/bin/bash

# Day 7: Mini Project - Automated Data Pipeline Starter
# This script sets up the project structure and provides guided implementation

echo "=== Day 7: Mini Project - Automated Data Pipeline ==="
echo "Building a complete ETL pipeline using Week 1 tools"
echo

# Project setup
PROJECT_NAME="data-pipeline-project"
echo "Creating project: $PROJECT_NAME"

# Create project structure
mkdir -p "$PROJECT_NAME"/{config,scripts/{download,clean,transform,validate,report,utils},data/{raw,clean,transformed,archive},output/{reports,charts,logs},tests,templates}

cd "$PROJECT_NAME"

echo "✓ Project structure created"

# Create configuration files
echo "Setting up configuration..."

cat > config/pipeline.conf << 'EOF'
#!/bin/bash
# Pipeline Configuration

# Project settings
PROJECT_NAME="data-pipeline-project"
VERSION="1.0.0"
ENVIRONMENT="${ENVIRONMENT:-development}"

# Directories
DATA_DIR="data"
RAW_DIR="$DATA_DIR/raw"
CLEAN_DIR="$DATA_DIR/clean"
TRANSFORMED_DIR="$DATA_DIR/transformed"
ARCHIVE_DIR="$DATA_DIR/archive"
OUTPUT_DIR="output"
REPORTS_DIR="$OUTPUT_DIR/reports"
CHARTS_DIR="$OUTPUT_DIR/charts"
LOGS_DIR="$OUTPUT_DIR/logs"

# Logging
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FILE="$LOGS_DIR/pipeline_$(date +%Y%m%d_%H%M%S).log"

# Processing settings
MAX_PARALLEL_JOBS="${MAX_PARALLEL_JOBS:-4}"
CHUNK_SIZE="${CHUNK_SIZE:-10000}"
TIMEOUT="${TIMEOUT:-300}"

# Data validation thresholds
MIN_RECORDS=100
MAX_ERROR_RATE=0.05
REQUIRED_COLUMNS="id,date,amount"

# Report settings
REPORT_TITLE="Data Pipeline Report"
REPORT_AUTHOR="Data Engineering Team"
INCLUDE_CHARTS=true
EOF

cat > config/data_sources.conf << 'EOF'
#!/bin/bash
# Data Sources Configuration

# Sales data source
SALES_URL="https://raw.githubusercontent.com/example/data/sales.csv"
SALES_FILE="$RAW_DIR/sales.csv"
SALES_BACKUP_URL="./sample_data/sales.csv"

# Customer data source  
CUSTOMERS_URL="https://api.example.com/customers"
CUSTOMERS_FILE="$RAW_DIR/customers.json"
CUSTOMERS_BACKUP_URL="./sample_data/customers.json"

# Product catalog
PRODUCTS_URL="https://raw.githubusercontent.com/example/data/products.csv"
PRODUCTS_FILE="$RAW_DIR/products.csv"
PRODUCTS_BACKUP_URL="./sample_data/products.csv"

# API configuration
API_KEY="${API_KEY:-demo_key}"
API_TIMEOUT=30
RETRY_COUNT=3
EOF

echo "✓ Configuration files created"

# Create sample data
echo "Creating sample data..."

mkdir -p sample_data

cat > sample_data/sales.csv << 'EOF'
id,date,customer_id,product_id,quantity,price,total
1,2023-12-01,C001,P001,2,999.99,1999.98
2,2023-12-01,C002,P002,5,25.50,127.50
3,2023-12-02,C003,P003,1,299.00,299.00
4,2023-12-02,C001,P004,2,199.99,399.98
5,2023-12-03,C004,P001,1,999.99,999.99
6,2023-12-03,C002,P005,3,75.00,225.00
7,2023-12-04,C005,P002,4,25.50,102.00
8,2023-12-04,C003,P006,1,89.99,89.99
EOF

cat > sample_data/customers.json << 'EOF'
{
  "customers": [
    {"id": "C001", "name": "Alice Johnson", "email": "alice@example.com", "region": "North", "tier": "Premium", "active": true},
    {"id": "C002", "name": "Bob Smith", "email": "bob@example.com", "region": "South", "tier": "Standard", "active": true},
    {"id": "C003", "name": "Charlie Brown", "email": "charlie@example.com", "region": "East", "tier": "Premium", "active": true},
    {"id": "C004", "name": "Diana Prince", "email": "diana@example.com", "region": "West", "tier": "Standard", "active": false},
    {"id": "C005", "name": "Eve Wilson", "email": "eve@example.com", "region": "North", "tier": "Premium", "active": true}
  ]
}
EOF

cat > sample_data/products.csv << 'EOF'
id,name,category,price,cost,margin,active
P001,Laptop,Electronics,999.99,600.00,0.40,true
P002,Mouse,Electronics,25.50,15.00,0.41,true
P003,Desk,Furniture,299.00,180.00,0.40,true
P004,Chair,Furniture,199.99,120.00,0.40,true
P005,Keyboard,Electronics,75.00,45.00,0.40,true
P006,Lamp,Furniture,89.99,54.00,0.40,false
EOF

echo "✓ Sample data created"

# Create utility functions
echo "Creating utility scripts..."

cat > scripts/utils/logging.sh << 'EOF'
#!/bin/bash
# Logging utilities

# Source configuration
source config/pipeline.conf

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

# Logging functions
log_info() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $message" | tee -a "$LOG_FILE"
}

log_warn() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $message" | tee -a "$LOG_FILE"
}

log_error() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $message" | tee -a "$LOG_FILE" >&2
}

log_success() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $message" | tee -a "$LOG_FILE"
}

# Performance logging
log_performance() {
    local operation="$1"
    local start_time="$2"
    local end_time="$3"
    local duration=$((end_time - start_time))
    
    log_info "Performance: $operation completed in ${duration}s"
}

# Error handling
setup_error_handling() {
    set -euo pipefail
    trap 'log_error "Pipeline failed at line $LINENO in $0"' ERR
}
EOF

cat > scripts/utils/validation.sh << 'EOF'
#!/bin/bash
# Data validation utilities

source scripts/utils/logging.sh

# File validation
validate_file() {
    local file="$1"
    local min_size="${2:-1}"
    
    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi
    
    if [[ ! -r "$file" ]]; then
        log_error "File not readable: $file"
        return 1
    fi
    
    local size=$(wc -c < "$file")
    if [[ $size -lt $min_size ]]; then
        log_error "File too small: $file ($size bytes)"
        return 1
    fi
    
    log_info "File validation passed: $file"
    return 0
}

# CSV validation
validate_csv() {
    local file="$1"
    local expected_columns="$2"
    
    validate_file "$file" || return 1
    
    # Check header
    local header=$(head -1 "$file")
    local actual_columns=$(echo "$header" | tr ',' '\n' | wc -l)
    local expected_count=$(echo "$expected_columns" | tr ',' '\n' | wc -l)
    
    if [[ $actual_columns -ne $expected_count ]]; then
        log_error "CSV column count mismatch in $file: expected $expected_count, got $actual_columns"
        return 1
    fi
    
    # Check for required columns
    for col in $(echo "$expected_columns" | tr ',' ' '); do
        if ! echo "$header" | grep -q "$col"; then
            log_error "Required column missing in $file: $col"
            return 1
        fi
    done
    
    log_info "CSV validation passed: $file"
    return 0
}

# JSON validation
validate_json() {
    local file="$1"
    
    validate_file "$file" || return 1
    
    if ! jq empty "$file" 2>/dev/null; then
        log_error "Invalid JSON format: $file"
        return 1
    fi
    
    log_info "JSON validation passed: $file"
    return 0
}

# Data quality checks
check_data_quality() {
    local file="$1"
    local file_type="$2"
    
    log_info "Checking data quality: $file"
    
    case "$file_type" in
        "csv")
            local total_lines=$(wc -l < "$file")
            local data_lines=$((total_lines - 1))  # Exclude header
            
            if [[ $data_lines -lt $MIN_RECORDS ]]; then
                log_warn "Low record count in $file: $data_lines (minimum: $MIN_RECORDS)"
            fi
            
            # Check for empty fields
            local empty_fields=$(awk -F',' 'NR>1 {for(i=1;i<=NF;i++) if($i=="") count++} END {print count+0}' "$file")
            local total_fields=$((data_lines * $(head -1 "$file" | tr ',' '\n' | wc -l)))
            local error_rate=$(echo "scale=4; $empty_fields / $total_fields" | bc -l 2>/dev/null || echo "0")
            
            if (( $(echo "$error_rate > $MAX_ERROR_RATE" | bc -l) )); then
                log_warn "High error rate in $file: $error_rate (threshold: $MAX_ERROR_RATE)"
            fi
            ;;
        "json")
            local record_count=$(jq '. | length' "$file" 2>/dev/null || echo "0")
            if [[ $record_count -lt $MIN_RECORDS ]]; then
                log_warn "Low record count in $file: $record_count (minimum: $MIN_RECORDS)"
            fi
            ;;
    esac
    
    log_success "Data quality check completed: $file"
}
EOF

echo "✓ Utility scripts created"

# Create core pipeline scripts
echo "Creating core pipeline scripts..."

cat > scripts/download/download_data.sh << 'EOF'
#!/bin/bash
# Data download script

source config/pipeline.conf
source config/data_sources.conf
source scripts/utils/logging.sh

setup_error_handling

download_file() {
    local url="$1"
    local output_file="$2"
    local backup_url="$3"
    
    log_info "Downloading: $url -> $output_file"
    
    # Create directory if needed
    mkdir -p "$(dirname "$output_file")"
    
    # Try primary URL
    if curl -f -s --connect-timeout "$API_TIMEOUT" "$url" -o "$output_file"; then
        log_success "Downloaded: $output_file"
        return 0
    fi
    
    # Try backup if primary fails
    log_warn "Primary download failed, trying backup: $backup_url"
    if [[ -f "$backup_url" ]]; then
        cp "$backup_url" "$output_file"
        log_success "Used backup file: $output_file"
        return 0
    fi
    
    log_error "Download failed: $url"
    return 1
}

main() {
    log_info "Starting data download process"
    
    # Download all data sources
    download_file "$SALES_URL" "$SALES_FILE" "$SALES_BACKUP_URL"
    download_file "$CUSTOMERS_URL" "$CUSTOMERS_FILE" "$CUSTOMERS_BACKUP_URL"  
    download_file "$PRODUCTS_URL" "$PRODUCTS_FILE" "$PRODUCTS_BACKUP_URL"
    
    log_success "Data download completed"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

cat > scripts/clean/clean_sales.sh << 'EOF'
#!/bin/bash
# Sales data cleaning script

source config/pipeline.conf
source scripts/utils/logging.sh
source scripts/utils/validation.sh

setup_error_handling

clean_sales_data() {
    local input_file="$1"
    local output_file="$2"
    
    log_info "Cleaning sales data: $input_file -> $output_file"
    
    # Validate input
    validate_csv "$input_file" "id,date,customer_id,product_id,quantity,price,total" || return 1
    
    # Create output directory
    mkdir -p "$(dirname "$output_file")"
    
    # Clean data using awk
    awk -F',' '
    BEGIN {
        OFS=","
        print "id,date,customer_id,product_id,quantity,price,total,revenue_check"
    }
    NR > 1 {
        # Skip empty lines
        if (NF == 0) next
        
        # Skip records with missing required fields
        if ($1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 == "" || $6 == "" || $7 == "") next
        
        # Validate numeric fields
        if ($5 <= 0 || $6 <= 0 || $7 <= 0) next
        
        # Calculate revenue check
        calculated_total = $5 * $6
        revenue_check = (calculated_total == $7) ? "OK" : "MISMATCH"
        
        # Output cleaned record
        print $1, $2, $3, $4, $5, $6, $7, revenue_check
    }' "$input_file" > "$output_file"
    
    # Log cleaning statistics
    local input_records=$(($(wc -l < "$input_file") - 1))
    local output_records=$(($(wc -l < "$output_file") - 1))
    local cleaned_records=$((input_records - output_records))
    
    log_info "Sales cleaning stats: $input_records input, $output_records output, $cleaned_records removed"
    
    # Validate output
    check_data_quality "$output_file" "csv"
    
    log_success "Sales data cleaned: $output_file"
}

main() {
    clean_sales_data "$RAW_DIR/sales.csv" "$CLEAN_DIR/sales_clean.csv"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

echo "✓ Core scripts created"

# Create Makefile
echo "Creating Makefile..."

cat > Makefile << 'EOF'
# Data Pipeline Makefile
# Automated ETL pipeline using shell tools

# Configuration
SHELL := /bin/bash
.DEFAULT_GOAL := help
.PHONY: all clean setup download clean-data transform validate report test help status

# Load configuration
include config/pipeline.conf

# Main targets
all: setup download clean-data transform validate report ## Run complete pipeline

setup: ## Setup pipeline environment
	@echo "Setting up pipeline environment..."
	@mkdir -p $(RAW_DIR) $(CLEAN_DIR) $(TRANSFORMED_DIR) $(ARCHIVE_DIR)
	@mkdir -p $(REPORTS_DIR) $(CHARTS_DIR) $(LOGS_DIR)
	@echo "✓ Pipeline environment ready"

download: setup ## Download raw data
	@echo "Downloading data..."
	@bash scripts/download/download_data.sh
	@echo "✓ Data download completed"

clean-data: download ## Clean raw data
	@echo "Cleaning data..."
	@bash scripts/clean/clean_sales.sh
	@bash scripts/clean/clean_customers.sh
	@bash scripts/clean/clean_products.sh
	@echo "✓ Data cleaning completed"

transform: clean-data ## Transform cleaned data
	@echo "Transforming data..."
	@bash scripts/transform/join_data.sh
	@bash scripts/transform/aggregate_data.sh
	@echo "✓ Data transformation completed"

validate: transform ## Validate processed data
	@echo "Validating data..."
	@bash scripts/validate/validate_pipeline.sh
	@echo "✓ Data validation completed"

report: validate ## Generate reports
	@echo "Generating reports..."
	@bash scripts/report/generate_reports.sh
	@echo "✓ Report generation completed"

# Utility targets
clean: ## Remove generated files
	@echo "Cleaning generated files..."
	@rm -rf $(CLEAN_DIR) $(TRANSFORMED_DIR) $(OUTPUT_DIR)
	@echo "✓ Cleanup completed"

test: ## Run pipeline tests
	@echo "Running tests..."
	@bash tests/test_pipeline.sh
	@echo "✓ Tests completed"

status: ## Show pipeline status
	@echo "=== Pipeline Status ==="
	@echo "Raw files:"
	@ls -la $(RAW_DIR)/ 2>/dev/null || echo "  No raw files found"
	@echo "Clean files:"
	@ls -la $(CLEAN_DIR)/ 2>/dev/null || echo "  No clean files found"
	@echo "Transformed files:"
	@ls -la $(TRANSFORMED_DIR)/ 2>/dev/null || echo "  No transformed files found"
	@echo "Reports:"
	@ls -la $(REPORTS_DIR)/ 2>/dev/null || echo "  No reports found"

help: ## Show this help message
	@echo "Data Pipeline - Automated ETL using Shell Tools"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'
EOF

echo "✓ Makefile created"

# Create README
cat > README.md << 'EOF'
# Data Pipeline Project

A complete automated ETL pipeline built using shell tools and Make.

## Overview

This project demonstrates a production-ready data pipeline that:
- Downloads data from multiple sources (CSV, JSON)
- Cleans and validates data quality
- Transforms and joins datasets
- Generates comprehensive reports
- Provides full automation and monitoring

## Quick Start

```bash
# Run complete pipeline
make all

# Run individual stages
make download
make clean-data
make transform
make validate
make report

# Check status
make status

# Clean up
make clean
```

## Project Structure

- `config/` - Configuration files
- `scripts/` - Pipeline scripts organized by function
- `data/` - Data storage (raw, clean, transformed)
- `output/` - Generated reports and logs
- `tests/` - Test scripts
- `sample_data/` - Sample datasets for testing

## Configuration

Edit `config/pipeline.conf` to customize:
- Data source URLs
- Processing parameters
- Validation thresholds
- Output formats

## Requirements

- Bash 4.0+
- Standard Unix tools (awk, sed, grep, curl, jq)
- Make
- bc (for calculations)

## Features

- ✅ Automated data download with fallback sources
- ✅ Comprehensive data cleaning and validation
- ✅ Error handling and logging
- ✅ Data quality monitoring
- ✅ HTML report generation
- ✅ Make-based automation
- ✅ Modular, reusable components

## Development

To extend the pipeline:
1. Add new scripts to appropriate `scripts/` subdirectory
2. Update Makefile with new targets
3. Add tests to `tests/` directory
4. Update configuration as needed

## Testing

```bash
make test
```

## Monitoring

Logs are written to `output/logs/` with timestamps.
Use `make status` to check pipeline state.
EOF

echo "✓ Documentation created"

# Create basic test
cat > tests/test_pipeline.sh << 'EOF'
#!/bin/bash
# Basic pipeline tests

source config/pipeline.conf
source scripts/utils/logging.sh

test_file_exists() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        log_success "TEST PASS: $description - $file exists"
        return 0
    else
        log_error "TEST FAIL: $description - $file missing"
        return 1
    fi
}

test_file_not_empty() {
    local file="$1"
    local description="$2"
    
    if [[ -s "$file" ]]; then
        log_success "TEST PASS: $description - $file not empty"
        return 0
    else
        log_error "TEST FAIL: $description - $file is empty"
        return 1
    fi
}

main() {
    log_info "Running pipeline tests..."
    
    local tests_passed=0
    local tests_failed=0
    
    # Test sample data exists
    if test_file_exists "sample_data/sales.csv" "Sample sales data"; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    if test_file_exists "sample_data/customers.json" "Sample customer data"; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Test configuration
    if test_file_exists "config/pipeline.conf" "Pipeline configuration"; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    # Test scripts
    if test_file_exists "scripts/download/download_data.sh" "Download script"; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    log_info "Test results: $tests_passed passed, $tests_failed failed"
    
    if [[ $tests_failed -eq 0 ]]; then
        log_success "All tests passed!"
        return 0
    else
        log_error "Some tests failed!"
        return 1
    fi
}

main "$@"
EOF

chmod +x tests/test_pipeline.sh

echo "✓ Tests created"

# Make scripts executable
find scripts -name "*.sh" -exec chmod +x {} \;

echo
echo "🎉 Project setup complete!"
echo
echo "Project created: $PROJECT_NAME"
echo
echo "Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. make help          # See available commands"
echo "3. make test          # Run basic tests"
echo "4. make all           # Run complete pipeline"
echo
echo "The project includes:"
echo "✓ Complete directory structure"
echo "✓ Configuration system"
echo "✓ Sample data for testing"
echo "✓ Utility functions for logging and validation"
echo "✓ Core pipeline scripts (download, clean)"
echo "✓ Make automation"
echo "✓ Basic test suite"
echo "✓ Documentation"
echo
echo "To complete the project, implement the remaining scripts:"
echo "- scripts/clean/clean_customers.sh"
echo "- scripts/clean/clean_products.sh"
echo "- scripts/transform/join_data.sh"
echo "- scripts/transform/aggregate_data.sh"
echo "- scripts/validate/validate_pipeline.sh"
echo "- scripts/report/generate_reports.sh"
echo
echo "Good luck with your mini project! 🚀"
