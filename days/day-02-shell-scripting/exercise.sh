#!/bin/bash

# Day 2: Shell Scripting Basics - Exercise
# Complete each section by writing the required code

echo "=== Day 2: Shell Scripting Exercise ==="
echo

# Create test data directory
mkdir -p test_data
cd test_data

# Create sample files for testing
echo -e "name,age,city\nAlice,25,NYC\nBob,30,LA\nCharlie,35,Chicago" > users.csv
echo -e "product,price,stock\nLaptop,999,10\nMouse,25,50\nKeyboard,75,30" > products.csv
echo "This is a log file with some errors" > app.log
echo "ERROR: Database connection failed" >> app.log
echo "INFO: Processing complete" >> app.log

echo "Test files created in test_data/"
echo

# Exercise 1: Basic Script Structure
echo "=== Exercise 1: Create a greeting script ==="
echo "TODO: Create a script that:"
echo "1. Uses proper shebang"
echo "2. Takes a name as first argument (\$1)"
echo "3. Prints 'Hello, [name]! Today is [current_date]'"
echo "4. If no name provided, print 'Hello, World!'"
echo

# Your code here:
# Create a file called greeting.sh

cat > greeting.sh << 'EOF'
#!/bin/bash
# TODO: Complete this script
name=$1
current_date=$(date +%Y-%m-%d)

if [ -z "$name" ]; then
    echo "Hello, World! Today is $current_date"
else
    echo "Hello, $name! Today is $current_date"
fi
EOF

chmod +x greeting.sh
echo "Test your greeting script:"
echo "./greeting.sh Alice"
echo "./greeting.sh"
echo

# Exercise 2: File Validation
echo "=== Exercise 2: File validator ==="
echo "TODO: Create a function that validates data files"
echo

validate_data_file() {
    # TODO: Complete this function
    local filename=$1
    
    # Check if file exists
    if [ ! -f "$filename" ]; then
        echo "✗ File $filename does not exist"
        return 1
    fi
    
    # Check if file is readable
    if [ ! -r "$filename" ]; then
        echo "✗ File $filename is not readable"
        return 1
    fi
    
    # Check if file is not empty
    if [ ! -s "$filename" ]; then
        echo "✗ File $filename is empty"
        return 1
    fi
    
    # If CSV, check for header
    if [[ "$filename" == *.csv ]]; then
        if ! head -1 "$filename" | grep -q ","; then
            echo "✗ CSV file $filename appears to have no header"
            return 1
        fi
    fi
    
    echo "✓ File $filename is valid"
    return 0
}

echo "Testing file validation:"
validate_data_file "users.csv"
validate_data_file "nonexistent.csv"
validate_data_file "products.csv"
echo

# Exercise 3: Data Processing Loop
echo "=== Exercise 3: Process multiple CSV files ==="
echo "TODO: Write a loop that processes all CSV files"
echo

echo "Processing CSV files:"
for csv_file in *.csv; do
    if [ -f "$csv_file" ]; then
        echo "Processing $csv_file..."
        
        # Count rows (excluding header)
        row_count=$(($(wc -l < "$csv_file") - 1))
        
        # Count columns
        col_count=$(head -1 "$csv_file" | tr ',' '\n' | wc -l)
        
        echo "  - Rows: $row_count"
        echo "  - Columns: $col_count"
        echo "  - Size: $(wc -c < "$csv_file") bytes"
    fi
done
echo

# Exercise 4: Log Analysis
echo "=== Exercise 4: Analyze log file ==="
echo "TODO: Create a script that analyzes app.log"
echo

analyze_log() {
    local logfile=$1
    
    if [ ! -f "$logfile" ]; then
        echo "Log file $logfile not found"
        return 1
    fi
    
    echo "Log Analysis for $logfile:"
    echo "  - Total lines: $(wc -l < "$logfile")"
    echo "  - Error count: $(grep -c "ERROR" "$logfile")"
    echo "  - Info count: $(grep -c "INFO" "$logfile")"
    
    # Check if errors exist
    if grep -q "ERROR" "$logfile"; then
        echo "  - ⚠️  Errors found in log!"
        echo "  - Error details:"
        grep "ERROR" "$logfile" | sed 's/^/    /'
        return 1
    else
        echo "  - ✓ No errors found"
        return 0
    fi
}

analyze_log "app.log"
echo

# Exercise 5: Backup Script
echo "=== Exercise 5: Create backup script ==="
echo "TODO: Write a backup script with timestamp"
echo

create_backup() {
    local source_dir=$1
    local backup_name="backup_$(date +%Y%m%d_%H%M%S)"
    
    if [ ! -d "$source_dir" ]; then
        echo "Source directory $source_dir not found"
        return 1
    fi
    
    echo "Creating backup: $backup_name"
    mkdir -p "../$backup_name"
    
    # Copy files
    cp -r "$source_dir"/* "../$backup_name"/ 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✓ Backup created successfully: $backup_name"
        echo "  - Files backed up: $(ls -1 "../$backup_name" | wc -l)"
        return 0
    else
        echo "✗ Backup failed"
        return 1
    fi
}

# Test backup (backup current directory)
create_backup "."
echo

# Exercise 6: Data Quality Check
echo "=== Exercise 6: Data quality checker ==="
echo "TODO: Create a comprehensive data quality script"
echo

check_data_quality() {
    local csv_file=$1
    local issues=0
    
    echo "Data Quality Report for $csv_file:"
    
    # Basic file checks
    if [ ! -f "$csv_file" ]; then
        echo "  ✗ File does not exist"
        return 1
    fi
    
    # Check for empty file
    if [ ! -s "$csv_file" ]; then
        echo "  ✗ File is empty"
        ((issues++))
    fi
    
    # Check for header
    if ! head -1 "$csv_file" | grep -q ","; then
        echo "  ✗ No CSV header detected"
        ((issues++))
    else
        echo "  ✓ CSV header found"
    fi
    
    # Check for consistent column count
    expected_cols=$(head -1 "$csv_file" | tr ',' '\n' | wc -l)
    inconsistent_rows=$(awk -F',' -v expected="$expected_cols" 'NR>1 && NF!=expected {print NR}' "$csv_file")
    
    if [ -n "$inconsistent_rows" ]; then
        echo "  ✗ Inconsistent column count in rows: $inconsistent_rows"
        ((issues++))
    else
        echo "  ✓ Consistent column count"
    fi
    
    # Summary
    if [ $issues -eq 0 ]; then
        echo "  ✓ Data quality: GOOD"
        return 0
    else
        echo "  ⚠️  Data quality: $issues issues found"
        return 1
    fi
}

echo "Checking data quality:"
check_data_quality "users.csv"
check_data_quality "products.csv"
echo

# Cleanup and summary
cd ..
echo "=== Exercise Complete ==="
echo "You've practiced:"
echo "✓ Shell script structure and shebang"
echo "✓ Variables and command substitution"
echo "✓ Conditionals and loops"
echo "✓ Functions and error handling"
echo "✓ File processing and validation"
echo "✓ Data quality checking"
echo
echo "Next: Run 'bash solution.sh' to see complete solutions"
echo "Then: Complete the quiz in quiz.md"
