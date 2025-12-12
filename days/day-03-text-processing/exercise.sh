#!/bin/bash

# Day 3: Text Processing Tools - Exercise
# Practice grep, sed, awk, jq, and csvkit

echo "=== Day 3: Text Processing Exercise ==="
echo

# Create test environment
mkdir -p text_processing_lab
cd text_processing_lab

# Create sample data files
echo "Creating sample data files..."

# Web server log
cat > access.log << 'EOF'
192.168.1.100 - - [12/Dec/2023:10:15:23 +0000] "GET /api/users HTTP/1.1" 200 1234
192.168.1.101 - - [12/Dec/2023:10:15:45 +0000] "POST /api/login HTTP/1.1" 401 89
192.168.1.102 - - [12/Dec/2023:10:16:12 +0000] "GET /api/data HTTP/1.1" 200 5678
192.168.1.100 - - [12/Dec/2023:10:16:34 +0000] "GET /api/users HTTP/1.1" 500 234
192.168.1.103 - - [12/Dec/2023:10:17:01 +0000] "DELETE /api/user/123 HTTP/1.1" 204 0
192.168.1.101 - - [12/Dec/2023:10:17:23 +0000] "POST /api/login HTTP/1.1" 200 156
EOF

# Sales data CSV
cat > sales.csv << 'EOF'
date,product,category,price,quantity,customer_id
2023-12-01,Laptop,Electronics,999.99,2,C001
2023-12-01,Mouse,Electronics,25.50,5,C002
2023-12-02,Desk,Furniture,299.00,1,C003
2023-12-02,Chair,Furniture,199.99,2,C001
2023-12-03,Laptop,Electronics,999.99,1,C004
2023-12-03,Keyboard,Electronics,75.00,3,C002
EOF

# Employee data JSON
cat > employees.json << 'EOF'
{
  "employees": [
    {"id": 1, "name": "Alice Johnson", "department": "Engineering", "salary": 85000, "active": true},
    {"id": 2, "name": "Bob Smith", "department": "Marketing", "salary": 65000, "active": true},
    {"id": 3, "name": "Charlie Brown", "department": "Engineering", "salary": 92000, "active": false},
    {"id": 4, "name": "Diana Prince", "department": "Sales", "salary": 78000, "active": true},
    {"id": 5, "name": "Eve Wilson", "department": "Engineering", "salary": 88000, "active": true}
  ]
}
EOF

# Application log with mixed content
cat > app.log << 'EOF'
2023-12-12 10:15:23 INFO Starting application
2023-12-12 10:15:24 INFO Database connection established
2023-12-12 10:15:30 ERROR Failed to load user profile for user_id=123
2023-12-12 10:15:35 WARN Cache miss for key: user_sessions
2023-12-12 10:15:40 INFO Processing batch job: data_export_20231212
2023-12-12 10:15:45 ERROR Database timeout after 30 seconds
2023-12-12 10:15:50 INFO Batch job completed successfully
2023-12-12 10:15:55 DEBUG Memory usage: 2.3GB
EOF

echo "Sample files created!"
echo

# Exercise 1: grep - Log Analysis
echo "=== Exercise 1: grep - Search and Filter ==="
echo "TODO: Use grep to analyze the access log"
echo

echo "1.1 Find all ERROR entries in app.log:"
# Your code here:
grep "ERROR" app.log

echo
echo "1.2 Count successful HTTP requests (status 200) in access.log:"
# Your code here:
grep " 200 " access.log | wc -l

echo
echo "1.3 Find all requests from IP 192.168.1.100:"
# Your code here:
grep "192.168.1.100" access.log

echo
echo "1.4 Find lines that DON'T contain 'INFO' in app.log:"
# Your code here:
grep -v "INFO" app.log

echo

# Exercise 2: sed - Text Transformation
echo "=== Exercise 2: sed - Stream Editing ==="
echo "TODO: Use sed to transform and clean data"
echo

echo "2.1 Replace all 'Electronics' with 'Tech' in sales.csv:"
# Your code here:
sed 's/Electronics/Tech/g' sales.csv

echo
echo "2.2 Extract just the IP addresses from access.log:"
# Your code here:
sed 's/^\([0-9.]*\).*/\1/' access.log

echo
echo "2.3 Remove the timestamp from app.log (keep only level and message):"
# Your code here:
sed 's/^[0-9-]* [0-9:]* //' app.log

echo

# Exercise 3: awk - Structured Data Processing
echo "=== Exercise 3: awk - Data Processing ==="
echo "TODO: Use awk to analyze structured data"
echo

echo "3.1 Calculate total sales revenue (price * quantity) from sales.csv:"
# Your code here:
awk -F',' 'NR>1 {total += $4 * $5} END {print "Total Revenue: $" total}' sales.csv

echo
echo "3.2 Show products with quantity > 2:"
# Your code here:
awk -F',' 'NR>1 && $5 > 2 {print $2, "qty:", $5}' sales.csv

echo
echo "3.3 Count requests by HTTP method from access.log:"
# Your code here:
awk '{print $6}' access.log | sed 's/"//g' | sort | uniq -c

echo
echo "3.4 Calculate average price by category:"
# Your code here:
awk -F',' 'NR>1 {sum[$3] += $4; count[$3]++} END {for (cat in sum) print cat ": $" sum[cat]/count[cat]}' sales.csv

echo

# Exercise 4: jq - JSON Processing
echo "=== Exercise 4: jq - JSON Manipulation ==="
echo "TODO: Use jq to extract and transform JSON data"
echo

echo "4.1 Extract all employee names:"
# Your code here:
jq -r '.employees[].name' employees.json

echo
echo "4.2 Find employees in Engineering department:"
# Your code here:
jq '.employees[] | select(.department == "Engineering")' employees.json

echo
echo "4.3 Calculate average salary of active employees:"
# Your code here:
jq '[.employees[] | select(.active == true) | .salary] | add / length' employees.json

echo
echo "4.4 Create summary by department:"
# Your code here:
jq 'group_by(.department) | map({department: .[0].department, count: length, avg_salary: (map(.salary) | add / length)})' employees.json <<< "$(jq '.employees' employees.json)"

echo

# Exercise 5: Combining Tools - Data Pipeline
echo "=== Exercise 5: Text Processing Pipeline ==="
echo "TODO: Combine multiple tools to solve complex problems"
echo

echo "5.1 Find top 3 IP addresses by request count:"
# Your code here:
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -3

echo
echo "5.2 Extract error messages and count by type:"
# Your code here:
grep "ERROR" app.log | sed 's/.*ERROR //' | sort | uniq -c

echo
echo "5.3 Convert active employees to CSV format:"
# Your code here:
echo "name,department,salary"
jq -r '.employees[] | select(.active == true) | [.name, .department, .salary] | @csv' employees.json

echo
echo "5.4 Create hourly request summary from access.log:"
# Your code here:
awk '{print $4}' access.log | sed 's/\[.*://' | sed 's/:.*//' | sort | uniq -c

echo

# Exercise 6: Advanced Text Processing
echo "=== Exercise 6: Advanced Patterns ==="
echo "TODO: Complex text processing scenarios"
echo

echo "6.1 Find sales records where revenue (price * qty) > 500:"
# Your code here:
awk -F',' 'NR>1 && ($4 * $5) > 500 {printf "%s: $%.2f (%.0f x $%.2f)\n", $2, $4*$5, $5, $4}' sales.csv

echo
echo "6.2 Extract unique customer IDs and their total spending:"
# Your code here:
awk -F',' 'NR>1 {total[$6] += $4 * $5} END {for (cust in total) printf "Customer %s: $%.2f\n", cust, total[cust]}' sales.csv | sort

echo
echo "6.3 Create a log summary report:"
# Your code here:
echo "=== Log Summary Report ==="
echo "Total log entries: $(wc -l < app.log)"
echo "INFO messages: $(grep -c "INFO" app.log)"
echo "ERROR messages: $(grep -c "ERROR" app.log)"
echo "WARN messages: $(grep -c "WARN" app.log)"
echo "First error: $(grep "ERROR" app.log | head -1 | awk '{print $1, $2}')"
echo "Last error: $(grep "ERROR" app.log | tail -1 | awk '{print $1, $2}')"

echo

# Exercise 7: Data Validation
echo "=== Exercise 7: Data Validation Pipeline ==="
echo "TODO: Validate data quality using text processing tools"
echo

echo "7.1 Check for missing values in sales.csv:"
# Your code here:
awk -F',' 'NR>1 {for(i=1;i<=NF;i++) if($i=="") print "Missing value in row " NR ", column " i}' sales.csv

echo "7.2 Validate email format in a sample file:"
# Create sample email data
echo -e "alice@company.com\nbob.smith@email.co.uk\ninvalid-email\ncharlie@domain.org" > emails.txt
# Your code here:
grep -E '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' emails.txt > valid_emails.txt
echo "Valid emails found: $(wc -l < valid_emails.txt)"
echo "Invalid emails:"
grep -vE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' emails.txt

echo

# Cleanup and summary
cd ..
echo "=== Exercise Complete ==="
echo
echo "You've practiced:"
echo "✓ grep - Pattern searching and filtering"
echo "✓ sed - Stream editing and text transformation"
echo "✓ awk - Structured data processing and calculations"
echo "✓ jq - JSON parsing and manipulation"
echo "✓ Pipeline combinations for complex data processing"
echo "✓ Data validation and quality checking"
echo
echo "Next: Run 'bash solution.sh' to see optimized solutions"
echo "Then: Complete the quiz in quiz.md"
