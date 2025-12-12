# Day 7: Mini Project - Automated Data Pipeline

**Duration**: 1.5-2 hours  
**Prerequisites**: Days 1-6 (All Week 1 tools)

## Project Overview

Build a complete automated data pipeline that combines all the tools learned in Week 1:
- **Terminal navigation** and **shell scripting** for automation
- **Text processing** (grep, sed, awk, jq) for data manipulation
- **Process management** for monitoring long-running jobs
- **Environment variables** for configuration
- **Make** for task automation and dependency management

## Learning Objectives

By the end of this project, you will have:
- Built a production-ready ETL pipeline using shell tools
- Implemented error handling and logging
- Created automated data validation and quality checks
- Generated comprehensive reports with visualizations
- Demonstrated proficiency with all Week 1 tools

## Project Requirements

### Core Features
1. **Data Ingestion**: Download/process multiple data sources (CSV, JSON)
2. **Data Cleaning**: Handle missing values, duplicates, format issues
3. **Data Transformation**: Aggregate, join, and enrich data
4. **Data Validation**: Quality checks and error reporting
5. **Report Generation**: HTML reports with charts and statistics
6. **Automation**: Complete pipeline orchestration with Make
7. **Monitoring**: Process monitoring and resource tracking
8. **Configuration**: Environment-based configuration management

### Technical Requirements
- Use only shell tools (no Python/R for core processing)
- Implement proper error handling and logging
- Create modular, reusable components
- Include comprehensive documentation
- Provide data quality validation
- Generate both technical and business reports

## Project Structure

```
data-pipeline-project/
├── README.md                 # Project documentation
├── Makefile                  # Pipeline automation
├── config/
│   ├── pipeline.conf         # Configuration settings
│   └── data_sources.conf     # Data source definitions
├── scripts/
│   ├── download/             # Data ingestion scripts
│   ├── clean/                # Data cleaning scripts
│   ├── transform/            # Data transformation scripts
│   ├── validate/             # Data validation scripts
│   ├── report/               # Report generation scripts
│   └── utils/                # Utility functions
├── data/
│   ├── raw/                  # Raw downloaded data
│   ├── clean/                # Cleaned data
│   ├── transformed/          # Transformed data
│   └── archive/              # Archived data
├── output/
│   ├── reports/              # Generated reports
│   ├── charts/               # Generated charts
│   └── logs/                 # Pipeline logs
├── tests/
│   └── test_pipeline.sh      # Pipeline tests
└── templates/
    └── report_template.html  # Report template
```

## Data Sources

The pipeline will process:
1. **Sales Data** (CSV): Transaction records with customer, product, and sales information
2. **Customer Data** (JSON): Customer demographics and preferences
3. **Product Catalog** (CSV): Product information and categories
4. **External API Data** (JSON): Market data or pricing information

## Pipeline Stages

### Stage 1: Data Ingestion
- Download data from multiple sources
- Validate file integrity and format
- Archive raw data with timestamps
- Log ingestion statistics

### Stage 2: Data Cleaning
- Remove duplicates and invalid records
- Handle missing values appropriately
- Standardize formats and encodings
- Generate cleaning reports

### Stage 3: Data Transformation
- Join datasets on common keys
- Calculate derived metrics
- Aggregate data by various dimensions
- Create analysis-ready datasets

### Stage 4: Data Validation
- Check data quality metrics
- Validate business rules
- Identify anomalies and outliers
- Generate validation reports

### Stage 5: Report Generation
- Create executive summary reports
- Generate detailed technical reports
- Produce data quality dashboards
- Export results in multiple formats

## Implementation Guidelines

### Shell Scripting Best Practices
```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
source config/pipeline.conf

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error handling
trap 'log "ERROR: Pipeline failed at line $LINENO"' ERR
```

### Text Processing Patterns
```bash
# CSV processing with awk
awk -F',' 'NR>1 && $3 > 0 {sum += $3; count++} END {print sum/count}' data.csv

# JSON processing with jq
jq '.customers[] | select(.active == true) | {id, name, region}' customers.json

# Data validation with grep
grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' dates.txt || echo "Invalid dates found"
```

### Make Integration
```makefile
# Pipeline orchestration
.PHONY: all clean download process validate report

all: report

download: data/raw/sales.csv data/raw/customers.json

process: data/clean/sales_clean.csv data/clean/customers_clean.csv

validate: output/validation_report.txt

report: output/reports/executive_summary.html
```

## Success Criteria

Your pipeline should:
- ✅ Process all data sources without manual intervention
- ✅ Handle errors gracefully with proper logging
- ✅ Complete full pipeline run in under 5 minutes
- ✅ Generate accurate and comprehensive reports
- ✅ Pass all data validation checks
- ✅ Be easily configurable for different environments
- ✅ Include proper documentation and help

## Deliverables

1. **Working Pipeline**: Complete automated data processing system
2. **Documentation**: README with setup and usage instructions
3. **Test Suite**: Validation scripts and test data
4. **Reports**: Sample output reports demonstrating functionality
5. **Presentation**: Brief demo of pipeline capabilities

## Getting Started

1. **Setup Project Structure**: Create directories and basic files
2. **Implement Core Scripts**: Start with data download and basic processing
3. **Add Make Automation**: Create Makefile for pipeline orchestration
4. **Implement Validation**: Add data quality checks and error handling
5. **Generate Reports**: Create HTML reports with statistics and charts
6. **Test and Refine**: Test with different data sets and edge cases

## Bonus Features

If you complete the core requirements, consider adding:
- **Incremental Processing**: Only process new/changed data
- **Data Lineage Tracking**: Track data transformations and dependencies
- **Performance Monitoring**: Detailed timing and resource usage metrics
- **Alert System**: Email/Slack notifications for pipeline failures
- **Configuration UI**: Web interface for pipeline configuration
- **Data Catalog**: Automated documentation of data schemas and metrics

## Resources

- **Sample Data**: Use the provided sample datasets or create your own
- **Templates**: HTML report templates and configuration examples
- **Testing**: Sample test cases and validation scenarios
- **Documentation**: Examples of good pipeline documentation

## Next Steps

After completing this project:
- Review your implementation with peers
- Identify areas for improvement
- Consider how Git version control (Week 2) could help manage the project
- Think about containerization and deployment strategies

This project demonstrates your mastery of fundamental developer tools for data engineering. Take your time to build something you're proud of!
