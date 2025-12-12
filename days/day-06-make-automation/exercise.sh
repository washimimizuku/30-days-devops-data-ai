#!/bin/bash

# Day 6: Make and Task Automation - Exercise
# Practice building data processing pipelines with Make

echo "=== Day 6: Make and Task Automation Exercise ==="
echo

# Create test environment
mkdir -p make_automation_lab
cd make_automation_lab

echo "Creating data processing pipeline with Make..."

# Create directory structure
mkdir -p {data/{raw,processed},scripts,output,tests}

# Create sample data files
echo "Creating sample data files..."

# Sample CSV data
cat > data/raw/sales.csv << 'EOF'
date,product,category,price,quantity,customer_id
2023-12-01,Laptop,Electronics,999.99,2,C001
2023-12-01,Mouse,Electronics,25.50,5,C002
2023-12-02,Desk,Furniture,299.00,1,C003
2023-12-02,Chair,Furniture,199.99,2,C001
2023-12-03,Laptop,Electronics,999.99,1,C004
2023-12-03,Keyboard,Electronics,75.00,3,C002
EOF

# Sample JSON data
cat > data/raw/customers.json << 'EOF'
{
  "customers": [
    {"id": "C001", "name": "Alice Johnson", "region": "North", "tier": "Premium"},
    {"id": "C002", "name": "Bob Smith", "region": "South", "tier": "Standard"},
    {"id": "C003", "name": "Charlie Brown", "region": "East", "tier": "Premium"},
    {"id": "C004", "name": "Diana Prince", "region": "West", "tier": "Standard"}
  ]
}
EOF

# Create processing scripts
echo "Creating processing scripts..."

# Data cleaning script
cat > scripts/clean_sales.py << 'EOF'
#!/usr/bin/env python3
import sys
import pandas as pd

def clean_sales_data(input_file, output_file):
    print(f"Cleaning sales data: {input_file} -> {output_file}")
    
    # Read data
    df = pd.read_csv(input_file)
    
    # Clean data
    df['date'] = pd.to_datetime(df['date'])
    df['revenue'] = df['price'] * df['quantity']
    
    # Remove any rows with missing data
    df = df.dropna()
    
    # Sort by date
    df = df.sort_values('date')
    
    # Save cleaned data
    df.to_csv(output_file, index=False)
    print(f"Cleaned data saved: {len(df)} rows")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python clean_sales.py <input_file> <output_file>")
        sys.exit(1)
    
    clean_sales_data(sys.argv[1], sys.argv[2])
EOF

# JSON processing script
cat > scripts/process_customers.py << 'EOF'
#!/usr/bin/env python3
import sys
import json
import csv

def process_customers(input_file, output_file):
    print(f"Processing customers: {input_file} -> {output_file}")
    
    # Read JSON data
    with open(input_file, 'r') as f:
        data = json.load(f)
    
    # Convert to CSV
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['id', 'name', 'region', 'tier'])
        
        for customer in data['customers']:
            writer.writerow([
                customer['id'],
                customer['name'],
                customer['region'],
                customer['tier']
            ])
    
    print(f"Processed {len(data['customers'])} customers")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python process_customers.py <input_file> <output_file>")
        sys.exit(1)
    
    process_customers(sys.argv[1], sys.argv[2])
EOF

# Analysis script
cat > scripts/analyze_data.py << 'EOF'
#!/usr/bin/env python3
import sys
import pandas as pd
import json

def analyze_sales(sales_file, customers_file, output_file):
    print(f"Analyzing data: {sales_file}, {customers_file} -> {output_file}")
    
    # Read data
    sales = pd.read_csv(sales_file)
    customers = pd.read_csv(customers_file)
    
    # Merge data
    merged = sales.merge(customers, left_on='customer_id', right_on='id', how='left')
    
    # Calculate metrics
    analysis = {
        "total_revenue": float(merged['revenue'].sum()),
        "total_orders": len(merged),
        "avg_order_value": float(merged['revenue'].mean()),
        "revenue_by_category": merged.groupby('category')['revenue'].sum().to_dict(),
        "revenue_by_region": merged.groupby('region')['revenue'].sum().to_dict(),
        "revenue_by_tier": merged.groupby('tier')['revenue'].sum().to_dict(),
        "top_products": merged.groupby('product')['revenue'].sum().nlargest(3).to_dict()
    }
    
    # Save analysis
    with open(output_file, 'w') as f:
        json.dump(analysis, f, indent=2)
    
    print(f"Analysis complete. Total revenue: ${analysis['total_revenue']:.2f}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python analyze_data.py <sales_file> <customers_file> <output_file>")
        sys.exit(1)
    
    analyze_sales(sys.argv[1], sys.argv[2], sys.argv[3])
EOF

# Report generation script
cat > scripts/generate_report.py << 'EOF'
#!/usr/bin/env python3
import sys
import json
from datetime import datetime

def generate_report(analysis_file, output_file):
    print(f"Generating report: {analysis_file} -> {output_file}")
    
    # Read analysis
    with open(analysis_file, 'r') as f:
        data = json.load(f)
    
    # Generate HTML report
    html = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Sales Analysis Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 40px; }}
        .metric {{ background: #f5f5f5; padding: 10px; margin: 10px 0; border-radius: 5px; }}
        .section {{ margin: 20px 0; }}
        table {{ border-collapse: collapse; width: 100%; }}
        th, td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
        th {{ background-color: #f2f2f2; }}
    </style>
</head>
<body>
    <h1>Sales Analysis Report</h1>
    <p>Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    
    <div class="section">
        <h2>Summary Metrics</h2>
        <div class="metric">Total Revenue: ${data['total_revenue']:.2f}</div>
        <div class="metric">Total Orders: {data['total_orders']}</div>
        <div class="metric">Average Order Value: ${data['avg_order_value']:.2f}</div>
    </div>
    
    <div class="section">
        <h2>Revenue by Category</h2>
        <table>
            <tr><th>Category</th><th>Revenue</th></tr>
"""
    
    for category, revenue in data['revenue_by_category'].items():
        html += f"            <tr><td>{category}</td><td>${revenue:.2f}</td></tr>\n"
    
    html += """        </table>
    </div>
    
    <div class="section">
        <h2>Revenue by Region</h2>
        <table>
            <tr><th>Region</th><th>Revenue</th></tr>
"""
    
    for region, revenue in data['revenue_by_region'].items():
        html += f"            <tr><td>{region}</td><td>${revenue:.2f}</td></tr>\n"
    
    html += """        </table>
    </div>
    
    <div class="section">
        <h2>Top Products</h2>
        <table>
            <tr><th>Product</th><th>Revenue</th></tr>
"""
    
    for product, revenue in data['top_products'].items():
        html += f"            <tr><td>{product}</td><td>${revenue:.2f}</td></tr>\n"
    
    html += """        </table>
    </div>
</body>
</html>
"""
    
    # Save report
    with open(output_file, 'w') as f:
        f.write(html)
    
    print(f"Report generated: {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python generate_report.py <analysis_file> <output_file>")
        sys.exit(1)
    
    generate_report(sys.argv[1], sys.argv[2])
EOF

# Make scripts executable
chmod +x scripts/*.py

# Create requirements file
cat > requirements.txt << 'EOF'
pandas>=1.3.0
EOF

echo "Sample files and scripts created!"
echo

# Exercise 1: Basic Makefile
echo "=== Exercise 1: Basic Makefile ==="
echo "TODO: Create a simple Makefile with basic targets"
echo

echo "1.1 Create basic Makefile:"
# Your code here:
cat > Makefile << 'EOF'
# Basic Data Processing Makefile

# Variables
PYTHON = python3
DATA_DIR = data
SCRIPTS_DIR = scripts
OUTPUT_DIR = output

# Default target
.DEFAULT_GOAL := help

# Phony targets
.PHONY: all clean install test help

# Basic targets
hello:
	@echo "Hello from Make!"
	@echo "Current directory: $(PWD)"
	@echo "Python version: $(shell $(PYTHON) --version)"

clean:
	@echo "Cleaning up..."
	rm -rf $(DATA_DIR)/processed
	rm -rf $(OUTPUT_DIR)
	rm -f *.tmp *.log

install:
	@echo "Installing dependencies..."
	pip install -r requirements.txt

help:
	@echo "Available targets:"
	@echo "  hello    - Print hello message"
	@echo "  clean    - Remove generated files"
	@echo "  install  - Install Python dependencies"
	@echo "  help     - Show this help"
EOF

echo "1.2 Test basic Makefile:"
make hello
echo
make help

echo

# Exercise 2: File-based Targets
echo "=== Exercise 2: File-based Targets and Dependencies ==="
echo "TODO: Add file processing targets with dependencies"
echo

echo "2.1 Add data processing targets to Makefile:"
# Your code here:
cat >> Makefile << 'EOF'

# File-based targets
$(DATA_DIR)/processed/sales_clean.csv: $(DATA_DIR)/raw/sales.csv $(SCRIPTS_DIR)/clean_sales.py
	@echo "Cleaning sales data..."
	mkdir -p $(DATA_DIR)/processed
	$(PYTHON) $(SCRIPTS_DIR)/clean_sales.py $< $@

$(DATA_DIR)/processed/customers.csv: $(DATA_DIR)/raw/customers.json $(SCRIPTS_DIR)/process_customers.py
	@echo "Processing customer data..."
	mkdir -p $(DATA_DIR)/processed
	$(PYTHON) $(SCRIPTS_DIR)/process_customers.py $< $@

$(OUTPUT_DIR)/analysis.json: $(DATA_DIR)/processed/sales_clean.csv $(DATA_DIR)/processed/customers.csv $(SCRIPTS_DIR)/analyze_data.py
	@echo "Analyzing data..."
	mkdir -p $(OUTPUT_DIR)
	$(PYTHON) $(SCRIPTS_DIR)/analyze_data.py $(DATA_DIR)/processed/sales_clean.csv $(DATA_DIR)/processed/customers.csv $@

$(OUTPUT_DIR)/report.html: $(OUTPUT_DIR)/analysis.json $(SCRIPTS_DIR)/generate_report.py
	@echo "Generating report..."
	$(PYTHON) $(SCRIPTS_DIR)/generate_report.py $< $@

# Convenience targets
process-sales: $(DATA_DIR)/processed/sales_clean.csv

process-customers: $(DATA_DIR)/processed/customers.csv

analyze: $(OUTPUT_DIR)/analysis.json

report: $(OUTPUT_DIR)/report.html

all: $(OUTPUT_DIR)/report.html
EOF

echo "2.2 Test file-based targets:"
make process-sales
echo "Sales data processed:"
head -3 data/processed/sales_clean.csv

echo
make process-customers
echo "Customer data processed:"
head -3 data/processed/customers.csv

echo

# Exercise 3: Pattern Rules and Variables
echo "=== Exercise 3: Pattern Rules and Advanced Variables ==="
echo "TODO: Add pattern rules and improve variable usage"
echo

echo "3.1 Create advanced Makefile with pattern rules:"
# Your code here:
cat > Makefile.advanced << 'EOF'
# Advanced Data Processing Makefile

# Configuration
SHELL := /bin/bash
.DEFAULT_GOAL := help
.PHONY: all clean install test help status

# Variables
PYTHON := python3
DATE := $(shell date +%Y-%m-%d)
TIMESTAMP := $(shell date +%Y%m%d_%H%M%S)

# Directories
DATA_DIR := data
RAW_DIR := $(DATA_DIR)/raw
PROCESSED_DIR := $(DATA_DIR)/processed
SCRIPTS_DIR := scripts
OUTPUT_DIR := output
BACKUP_DIR := backup

# Files
RAW_SALES := $(RAW_DIR)/sales.csv
RAW_CUSTOMERS := $(RAW_DIR)/customers.json
CLEAN_SALES := $(PROCESSED_DIR)/sales_clean.csv
CLEAN_CUSTOMERS := $(PROCESSED_DIR)/customers.csv
ANALYSIS := $(OUTPUT_DIR)/analysis.json
REPORT := $(OUTPUT_DIR)/report.html

# Pattern rules
$(PROCESSED_DIR)/%_clean.csv: $(RAW_DIR)/%.csv $(SCRIPTS_DIR)/clean_%.py
	@echo "Processing $< -> $@"
	mkdir -p $(PROCESSED_DIR)
	$(PYTHON) $(SCRIPTS_DIR)/clean_$*.py $< $@

%.csv: %.json $(SCRIPTS_DIR)/process_customers.py
	@echo "Converting $< -> $@"
	$(PYTHON) $(SCRIPTS_DIR)/process_customers.py $< $@

# Main pipeline
all: $(REPORT) ## Run complete data pipeline

$(CLEAN_SALES): $(RAW_SALES) $(SCRIPTS_DIR)/clean_sales.py
	@echo "Cleaning sales data..."
	mkdir -p $(PROCESSED_DIR)
	$(PYTHON) $(SCRIPTS_DIR)/clean_sales.py $< $@

$(CLEAN_CUSTOMERS): $(RAW_CUSTOMERS) $(SCRIPTS_DIR)/process_customers.py
	@echo "Processing customers..."
	mkdir -p $(PROCESSED_DIR)
	$(PYTHON) $(SCRIPTS_DIR)/process_customers.py $< $@

$(ANALYSIS): $(CLEAN_SALES) $(CLEAN_CUSTOMERS) $(SCRIPTS_DIR)/analyze_data.py
	@echo "Running analysis..."
	mkdir -p $(OUTPUT_DIR)
	$(PYTHON) $(SCRIPTS_DIR)/analyze_data.py $(CLEAN_SALES) $(CLEAN_CUSTOMERS) $@

$(REPORT): $(ANALYSIS) $(SCRIPTS_DIR)/generate_report.py
	@echo "Generating report..."
	$(PYTHON) $(SCRIPTS_DIR)/generate_report.py $< $@

# Utility targets
clean: ## Remove all generated files
	@echo "Cleaning up..."
	rm -rf $(PROCESSED_DIR) $(OUTPUT_DIR)
	rm -f *.tmp *.log

install: ## Install Python dependencies
	@echo "Installing dependencies..."
	$(PYTHON) -m pip install -r requirements.txt

backup: ## Backup current results
	@echo "Creating backup..."
	mkdir -p $(BACKUP_DIR)
	tar -czf $(BACKUP_DIR)/pipeline_$(TIMESTAMP).tar.gz $(PROCESSED_DIR) $(OUTPUT_DIR) 2>/dev/null || true
	@echo "Backup created: $(BACKUP_DIR)/pipeline_$(TIMESTAMP).tar.gz"

status: ## Show pipeline status
	@echo "=== Pipeline Status ==="
	@echo "Date: $(DATE)"
	@echo "Raw files:"
	@ls -la $(RAW_DIR)/ 2>/dev/null || echo "  No raw files found"
	@echo "Processed files:"
	@ls -la $(PROCESSED_DIR)/ 2>/dev/null || echo "  No processed files found"
	@echo "Output files:"
	@ls -la $(OUTPUT_DIR)/ 2>/dev/null || echo "  No output files found"

test: ## Run basic tests
	@echo "Running tests..."
	@echo "Checking Python scripts..."
	@for script in $(SCRIPTS_DIR)/*.py; do \
		echo "  Checking $$script..."; \
		$(PYTHON) -m py_compile $$script || exit 1; \
	done
	@echo "All tests passed!"

help: ## Show this help message
	@echo "Data Processing Pipeline"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-12s %s\n", $$1, $$2}'
EOF

echo "3.2 Test advanced Makefile:"
make -f Makefile.advanced status
echo
make -f Makefile.advanced test

echo

# Exercise 4: Parallel Processing
echo "=== Exercise 4: Parallel Processing and Optimization ==="
echo "TODO: Create Makefile that can process multiple files in parallel"
echo

echo "4.1 Create multiple data files for parallel processing:"
# Your code here:

# Create additional sample files
for i in {1..3}; do
    cat > data/raw/dataset_$i.csv << EOF
id,value,category
1,$((RANDOM % 1000)),A
2,$((RANDOM % 1000)),B
3,$((RANDOM % 1000)),A
4,$((RANDOM % 1000)),C
5,$((RANDOM % 1000)),B
EOF
done

# Create generic processing script
cat > scripts/process_dataset.py << 'EOF'
#!/usr/bin/env python3
import sys
import pandas as pd
import time

def process_dataset(input_file, output_file):
    print(f"Processing {input_file} -> {output_file}")
    
    # Simulate processing time
    time.sleep(1)
    
    # Read and process data
    df = pd.read_csv(input_file)
    df['processed'] = True
    df['total'] = df['value'] * 2
    
    # Save processed data
    df.to_csv(output_file, index=False)
    print(f"Completed processing {input_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python process_dataset.py <input> <output>")
        sys.exit(1)
    
    process_dataset(sys.argv[1], sys.argv[2])
EOF

chmod +x scripts/process_dataset.py

echo "4.2 Create parallel processing Makefile:"
cat > Makefile.parallel << 'EOF'
# Parallel Processing Makefile

# Enable parallel execution
MAKEFLAGS += -j4

# Variables
PYTHON := python3
RAW_DIR := data/raw
PROCESSED_DIR := data/processed
SCRIPTS_DIR := scripts

# Find all dataset files
DATASETS := $(wildcard $(RAW_DIR)/dataset_*.csv)
PROCESSED := $(patsubst $(RAW_DIR)/%.csv,$(PROCESSED_DIR)/%_processed.csv,$(DATASETS))

.PHONY: all clean parallel-demo

# Default target
all: $(PROCESSED)

# Pattern rule for processing datasets
$(PROCESSED_DIR)/%_processed.csv: $(RAW_DIR)/%.csv $(SCRIPTS_DIR)/process_dataset.py
	@echo "Starting processing: $<"
	mkdir -p $(PROCESSED_DIR)
	$(PYTHON) $(SCRIPTS_DIR)/process_dataset.py $< $@

# Demo parallel processing
parallel-demo:
	@echo "Starting parallel processing demo..."
	@echo "Processing $(words $(DATASETS)) files in parallel..."
	@time make -j4 all
	@echo "Parallel processing complete!"

# Sequential processing for comparison
sequential-demo:
	@echo "Starting sequential processing demo..."
	@echo "Processing $(words $(DATASETS)) files sequentially..."
	@time make -j1 all
	@echo "Sequential processing complete!"

clean:
	rm -rf $(PROCESSED_DIR)

status:
	@echo "Datasets found: $(words $(DATASETS))"
	@echo "Processed files: $(words $(wildcard $(PROCESSED)))"
	@echo "Files to process: $(DATASETS)"
EOF

echo "4.3 Test parallel processing:"
make -f Makefile.parallel clean
echo "Testing parallel processing (this will take a few seconds)..."
time make -f Makefile.parallel all

echo

# Exercise 5: Alternative Task Runners
echo "=== Exercise 5: Alternative Task Runners ==="
echo "TODO: Explore alternatives to Make"
echo

echo "5.1 Create justfile (if just is available):"
# Your code here:
cat > justfile << 'EOF'
# justfile - Modern alternative to Make

# Variables
python := "python3"
data_dir := "data"
output_dir := "output"

# Default recipe
default: help

# Install dependencies
install:
    {{python}} -m pip install -r requirements.txt

# Clean generated files
clean:
    rm -rf {{data_dir}}/processed {{output_dir}}
    echo "Cleaned up generated files"

# Process sales data
process-sales:
    mkdir -p {{data_dir}}/processed
    {{python}} scripts/clean_sales.py {{data_dir}}/raw/sales.csv {{data_dir}}/processed/sales_clean.csv

# Process customer data
process-customers:
    mkdir -p {{data_dir}}/processed
    {{python}} scripts/process_customers.py {{data_dir}}/raw/customers.json {{data_dir}}/processed/customers.csv

# Run analysis
analyze: process-sales process-customers
    mkdir -p {{output_dir}}
    {{python}} scripts/analyze_data.py {{data_dir}}/processed/sales_clean.csv {{data_dir}}/processed/customers.csv {{output_dir}}/analysis.json

# Generate report
report: analyze
    {{python}} scripts/generate_report.py {{output_dir}}/analysis.json {{output_dir}}/report.html
    echo "Report generated: {{output_dir}}/report.html"

# Run complete pipeline
pipeline: report

# Show status
status:
    echo "=== Pipeline Status ==="
    ls -la {{data_dir}}/raw/ || echo "No raw files"
    ls -la {{data_dir}}/processed/ || echo "No processed files"
    ls -la {{output_dir}}/ || echo "No output files"

# Show available recipes
help:
    just --list
EOF

echo "5.2 Create Python invoke tasks:"
cat > tasks.py << 'EOF'
from invoke import task
import os

@task
def install(c):
    """Install Python dependencies"""
    c.run("python3 -m pip install -r requirements.txt")

@task
def clean(c):
    """Clean generated files"""
    c.run("rm -rf data/processed output")
    print("Cleaned up generated files")

@task
def process_sales(c):
    """Process sales data"""
    c.run("mkdir -p data/processed")
    c.run("python3 scripts/clean_sales.py data/raw/sales.csv data/processed/sales_clean.csv")

@task
def process_customers(c):
    """Process customer data"""
    c.run("mkdir -p data/processed")
    c.run("python3 scripts/process_customers.py data/raw/customers.json data/processed/customers.csv")

@task(process_sales, process_customers)
def analyze(c):
    """Run data analysis"""
    c.run("mkdir -p output")
    c.run("python3 scripts/analyze_data.py data/processed/sales_clean.csv data/processed/customers.csv output/analysis.json")

@task(analyze)
def report(c):
    """Generate HTML report"""
    c.run("python3 scripts/generate_report.py output/analysis.json output/report.html")
    print("Report generated: output/report.html")

@task(report)
def pipeline(c):
    """Run complete pipeline"""
    print("Pipeline completed successfully!")

@task
def status(c):
    """Show pipeline status"""
    print("=== Pipeline Status ===")
    
    for directory in ["data/raw", "data/processed", "output"]:
        print(f"\n{directory}:")
        if os.path.exists(directory):
            c.run(f"ls -la {directory}")
        else:
            print("  Directory not found")
EOF

echo "Alternative task runners created!"
echo "- justfile: Use 'just <recipe>' (if just is installed)"
echo "- tasks.py: Use 'invoke <task>' (if invoke is installed)"

echo

# Exercise 6: Complete Pipeline Test
echo "=== Exercise 6: Complete Pipeline Test ==="
echo "TODO: Test the complete data processing pipeline"
echo

echo "6.1 Run complete pipeline with Make:"
make -f Makefile.advanced clean
make -f Makefile.advanced all

echo
echo "6.2 Check results:"
if [ -f "output/report.html" ]; then
    echo "✓ Pipeline completed successfully!"
    echo "Generated files:"
    ls -la data/processed/
    ls -la output/
    
    echo
    echo "Report preview (first 10 lines):"
    head -10 output/report.html
else
    echo "✗ Pipeline failed - report not generated"
fi

echo
echo "6.3 Test pipeline status and backup:"
make -f Makefile.advanced status
make -f Makefile.advanced backup

# Cleanup
cd ..

echo
echo "=== Exercise Complete ==="
echo
echo "You've practiced:"
echo "✓ Basic Makefile syntax and structure"
echo "✓ File-based targets and dependencies"
echo "✓ Variables and automatic variables"
echo "✓ Pattern rules and functions"
echo "✓ Phony targets for task automation"
echo "✓ Parallel processing with Make"
echo "✓ Alternative task runners (just, invoke)"
echo "✓ Complete data processing pipeline automation"
echo
echo "Next: Run 'bash solution.sh' to see advanced Make techniques"
echo "Then: Complete the quiz in quiz.md"
