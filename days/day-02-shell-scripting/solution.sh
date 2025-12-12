#!/bin/bash

# Day 2: Shell Scripting Basics - Solutions
# Complete implementations for all exercises

echo "=== Day 2: Shell Scripting Solutions ==="
echo

# Create test environment
mkdir -p solutions_demo
cd solutions_demo

# Create sample data
echo -e "name,age,city\nAlice,25,NYC\nBob,30,LA\nCharlie,35,Chicago" > users.csv
echo -e "product,price,stock\nLaptop,999,10\nMouse,25,50\nKeyboard,75,30" > products.csv
echo -e "id,value\n1,100\n2,200\n3" > broken.csv  # Intentionally broken CSV
echo "This is a log file" > app.log
echo "ERROR: Database connection failed" >> app.log
echo "INFO: Processing complete" >> app.log
echo "ERROR: Timeout occurred" >> app.log

echo "=== Solution 1: Greeting Script ==="

cat > greeting.sh << 'EOF'
#!/bin/bash
# Greeting script with date

name=$1
current_date=$(date +%Y-%m-%d)

if [ -z "$name" ]; then
    echo "Hello, World! Today is $current_date"
else
    echo "Hello, $name! Today is $current_date"
fi
EOF

chmod +x greeting.sh

echo "Testing greeting script:"
./greeting.sh "Alice"
./greeting.sh
echo

echo "=== Solution 2: Advanced File Validator ==="

validate_data_file() {
    local filename=$1
    local errors=0
    
    echo "Validating: $filename"
    
    # Check if file exists
    if [ ! -f "$filename" ]; then
        echo "  ✗ File does not exist"
        return 1
    fi
    
    # Check if file is readable
    if [ ! -r "$filename" ]; then
        echo "  ✗ File is not readable"
        ((errors++))
    fi
    
    # Check if file is not empty
    if [ ! -s "$filename" ]; then
        echo "  ✗ File is empty"
        ((errors++))
    fi
    
    # For CSV files, additional checks
    if [[ "$filename" == *.csv ]]; then
        # Check for header
        if ! head -1 "$filename" | grep -q ","; then
            echo "  ✗ CSV file appears to have no header"
            ((errors++))
        else
            echo "  ✓ CSV header detected"
        fi
        
        # Check for consistent columns
        expected_cols=$(head -1 "$filename" | tr ',' '\n' | wc -l)
        while IFS= read -r line; do
            actual_cols=$(echo "$line" | tr ',' '\n' | wc -l)
            if [ "$actual_cols" -ne "$expected_cols" ]; then
                echo "  ✗ Inconsistent column count detected"
                ((errors++))
                break
            fi
        done < <(tail -n +2 "$filename")
    fi
    
    if [ $errors -eq 0 ]; then
        echo "  ✓ File validation passed"
        return 0
    else
        echo "  ✗ File validation failed ($errors errors)"
        return 1
    fi
}

echo "Testing file validation:"
validate_data_file "users.csv"
validate_data_file "broken.csv"
validate_data_file "nonexistent.csv"
echo

echo "=== Solution 3: CSV Processing Loop ==="

process_csv_files() {
    local csv_count=0
    local total_rows=0
    
    echo "Processing all CSV files:"
    
    for csv_file in *.csv; do
        if [ -f "$csv_file" ]; then
            ((csv_count++))
            echo "  Processing: $csv_file"
            
            # Count rows (excluding header)
            local rows=$(($(wc -l < "$csv_file") - 1))
            total_rows=$((total_rows + rows))
            
            # Count columns
            local cols=$(head -1 "$csv_file" | tr ',' '\n' | wc -l)
            
            # File size
            local size=$(wc -c < "$csv_file")
            
            echo "    - Data rows: $rows"
            echo "    - Columns: $cols"
            echo "    - Size: $size bytes"
            
            # Show first few data rows
            echo "    - Sample data:"
            head -3 "$csv_file" | tail -2 | sed 's/^/      /'
        fi
    done
    
    echo "Summary: $csv_count CSV files processed, $total_rows total data rows"
}

process_csv_files
echo

echo "=== Solution 4: Log Analysis Script ==="

analyze_log() {
    local logfile=$1
    
    if [ ! -f "$logfile" ]; then
        echo "Log file $logfile not found"
        return 1
    fi
    
    echo "Log Analysis Report: $logfile"
    echo "================================"
    
    # Basic stats
    local total_lines=$(wc -l < "$logfile")
    local error_count=$(grep -c "ERROR" "$logfile" 2>/dev/null || echo "0")
    local info_count=$(grep -c "INFO" "$logfile" 2>/dev/null || echo "0")
    local warn_count=$(grep -c "WARN" "$logfile" 2>/dev/null || echo "0")
    
    echo "Statistics:"
    echo "  - Total lines: $total_lines"
    echo "  - Errors: $error_count"
    echo "  - Info messages: $info_count"
    echo "  - Warnings: $warn_count"
    
    # Show errors if any
    if [ "$error_count" -gt 0 ]; then
        echo
        echo "Error Details:"
        grep "ERROR" "$logfile" | while read -r line; do
            echo "  ⚠️  $line"
        done
        echo
        echo "Status: ❌ ERRORS FOUND"
        return 1
    else
        echo
        echo "Status: ✅ NO ERRORS"
        return 0
    fi
}

analyze_log "app.log"
echo

echo "=== Solution 5: Backup Script ==="

create_backup() {
    local source_dir=${1:-.}  # Default to current directory
    local backup_base=${2:-backup}
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="${backup_base}_${timestamp}"
    
    echo "Creating backup: $backup_name"
    
    # Check source directory
    if [ ! -d "$source_dir" ]; then
        echo "  ✗ Source directory '$source_dir' not found"
        return 1
    fi
    
    # Create backup directory
    mkdir -p "../$backup_name"
    
    # Copy files with progress
    local file_count=0
    for file in "$source_dir"/*; do
        if [ -f "$file" ]; then
            cp "$file" "../$backup_name/"
            ((file_count++))
        fi
    done
    
    # Verify backup
    if [ $file_count -gt 0 ]; then
        echo "  ✓ Backup completed successfully"
        echo "    - Location: ../$backup_name"
        echo "    - Files backed up: $file_count"
        echo "    - Backup size: $(du -sh "../$backup_name" | cut -f1)"
        return 0
    else
        echo "  ✗ No files to backup"
        rmdir "../$backup_name" 2>/dev/null
        return 1
    fi
}

create_backup "." "solutions_backup"
echo

echo "=== Solution 6: Comprehensive Data Quality Checker ==="

check_data_quality() {
    local csv_file=$1
    local issues=0
    local warnings=0
    
    echo "Data Quality Assessment: $csv_file"
    echo "=================================="
    
    # File existence and basic checks
    if [ ! -f "$csv_file" ]; then
        echo "❌ CRITICAL: File does not exist"
        return 2
    fi
    
    if [ ! -r "$csv_file" ]; then
        echo "❌ CRITICAL: File is not readable"
        return 2
    fi
    
    if [ ! -s "$csv_file" ]; then
        echo "❌ CRITICAL: File is empty"
        return 2
    fi
    
    echo "✅ Basic file checks passed"
    
    # CSV structure checks
    local total_lines=$(wc -l < "$csv_file")
    echo "📊 Total lines: $total_lines"
    
    if [ "$total_lines" -lt 2 ]; then
        echo "⚠️  WARNING: File has no data rows (header only)"
        ((warnings++))
    fi
    
    # Header validation
    local header=$(head -1 "$csv_file")
    if echo "$header" | grep -q ","; then
        local col_count=$(echo "$header" | tr ',' '\n' | wc -l)
        echo "✅ CSV header detected ($col_count columns)"
        echo "📋 Columns: $(echo "$header" | tr ',' ' | ')"
    else
        echo "❌ ERROR: No CSV header detected"
        ((issues++))
    fi
    
    # Column consistency check
    if [ "$total_lines" -gt 1 ]; then
        local expected_cols=$(head -1 "$csv_file" | tr ',' '\n' | wc -l)
        local inconsistent_lines=0
        
        while IFS= read -r line_num; do
            ((inconsistent_lines++))
        done < <(awk -F',' -v expected="$expected_cols" 'NR>1 && NF!=expected {print NR}' "$csv_file")
        
        if [ "$inconsistent_lines" -gt 0 ]; then
            echo "❌ ERROR: $inconsistent_lines rows have inconsistent column count"
            ((issues++))
        else
            echo "✅ Column count is consistent"
        fi
    fi
    
    # Empty field check
    local empty_fields=$(awk -F',' 'NR>1 {for(i=1;i<=NF;i++) if($i=="") count++} END {print count+0}' "$csv_file")
    if [ "$empty_fields" -gt 0 ]; then
        echo "⚠️  WARNING: $empty_fields empty fields detected"
        ((warnings++))
    else
        echo "✅ No empty fields detected"
    fi
    
    # Final assessment
    echo
    echo "Quality Summary:"
    echo "  - Critical issues: $issues"
    echo "  - Warnings: $warnings"
    
    if [ "$issues" -eq 0 ] && [ "$warnings" -eq 0 ]; then
        echo "  - Overall quality: 🟢 EXCELLENT"
        return 0
    elif [ "$issues" -eq 0 ]; then
        echo "  - Overall quality: 🟡 GOOD (with warnings)"
        return 0
    else
        echo "  - Overall quality: 🔴 POOR (needs attention)"
        return 1
    fi
}

echo "Testing data quality checker:"
check_data_quality "users.csv"
echo
check_data_quality "broken.csv"
echo

# Cleanup
cd ..

echo "=== All Solutions Demonstrated ==="
echo
echo "Key concepts covered:"
echo "✅ Proper shebang usage"
echo "✅ Variable assignment and substitution"
echo "✅ Command substitution with \$()"
echo "✅ Conditional statements (if/else)"
echo "✅ Loops (for, while)"
echo "✅ Functions with parameters and return codes"
echo "✅ File testing and validation"
echo "✅ Error handling and exit codes"
echo "✅ String manipulation and text processing"
echo "✅ Real-world data processing scenarios"
echo
echo "🎯 You're now ready for Day 3: Text Processing Tools!"
