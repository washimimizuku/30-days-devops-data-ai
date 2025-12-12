#!/bin/bash

# Day 3: Text Processing Tools - Solutions
# Optimized implementations and advanced techniques

echo "=== Day 3: Text Processing Solutions ==="
echo

# Create test environment
mkdir -p solutions_lab
cd solutions_lab

# Create comprehensive sample data
echo "Creating enhanced sample data..."

# Web server access log with more variety
cat > access.log << 'EOF'
192.168.1.100 - - [12/Dec/2023:10:15:23 +0000] "GET /api/users HTTP/1.1" 200 1234 "Mozilla/5.0"
192.168.1.101 - - [12/Dec/2023:10:15:45 +0000] "POST /api/login HTTP/1.1" 401 89 "curl/7.68.0"
192.168.1.102 - - [12/Dec/2023:10:16:12 +0000] "GET /api/data HTTP/1.1" 200 5678 "Python-requests/2.25.1"
192.168.1.100 - - [12/Dec/2023:10:16:34 +0000] "GET /api/users HTTP/1.1" 500 234 "Mozilla/5.0"
192.168.1.103 - - [12/Dec/2023:10:17:01 +0000] "DELETE /api/user/123 HTTP/1.1" 204 0 "curl/7.68.0"
192.168.1.101 - - [12/Dec/2023:10:17:23 +0000] "POST /api/login HTTP/1.1" 200 156 "Mozilla/5.0"
192.168.1.104 - - [12/Dec/2023:10:18:45 +0000] "GET /api/reports HTTP/1.1" 403 45 "Python-requests/2.25.1"
192.168.1.100 - - [12/Dec/2023:10:19:12 +0000] "PUT /api/user/456 HTTP/1.1" 200 789 "curl/7.68.0"
EOF

# Enhanced sales data
cat > sales.csv << 'EOF'
date,product,category,price,quantity,customer_id,region
2023-12-01,Laptop,Electronics,999.99,2,C001,North
2023-12-01,Mouse,Electronics,25.50,5,C002,South
2023-12-02,Desk,Furniture,299.00,1,C003,East
2023-12-02,Chair,Furniture,199.99,2,C001,North
2023-12-03,Laptop,Electronics,999.99,1,C004,West
2023-12-03,Keyboard,Electronics,75.00,3,C002,South
2023-12-04,Monitor,Electronics,349.99,2,C005,North
2023-12-04,Lamp,Furniture,89.99,4,C003,East
EOF

# Complex JSON data
cat > company_data.json << 'EOF'
{
  "company": "TechCorp",
  "employees": [
    {"id": 1, "name": "Alice Johnson", "department": "Engineering", "salary": 85000, "active": true, "skills": ["Python", "AWS", "Docker"]},
    {"id": 2, "name": "Bob Smith", "department": "Marketing", "salary": 65000, "active": true, "skills": ["Analytics", "SQL"]},
    {"id": 3, "name": "Charlie Brown", "department": "Engineering", "salary": 92000, "active": false, "skills": ["Java", "Kubernetes"]},
    {"id": 4, "name": "Diana Prince", "department": "Sales", "salary": 78000, "active": true, "skills": ["CRM", "Analytics"]},
    {"id": 5, "name": "Eve Wilson", "department": "Engineering", "salary": 88000, "active": true, "skills": ["Python", "ML", "Docker"]}
  ],
  "projects": [
    {"name": "DataPipeline", "budget": 150000, "team": [1, 3, 5]},
    {"name": "WebApp", "budget": 80000, "team": [1, 2]},
    {"name": "Analytics", "budget": 120000, "team": [2, 4, 5]}
  ]
}
EOF

# Application log with structured data
cat > app.log << 'EOF'
2023-12-12 10:15:23.123 INFO [main] Application started successfully
2023-12-12 10:15:24.456 INFO [db] Database connection pool initialized (size=10)
2023-12-12 10:15:30.789 ERROR [auth] Failed to authenticate user_id=123, reason=invalid_token
2023-12-12 10:15:35.012 WARN [cache] Cache miss for key=user_sessions, fallback to database
2023-12-12 10:15:40.345 INFO [batch] Processing job: data_export_20231212 (records=50000)
2023-12-12 10:15:45.678 ERROR [db] Connection timeout after 30s, retrying... (attempt 1/3)
2023-12-12 10:15:50.901 INFO [batch] Job completed: data_export_20231212 (processed=50000, errors=0)
2023-12-12 10:15:55.234 DEBUG [memory] Heap usage: 2.3GB/4GB (57%)
2023-12-12 10:16:01.567 ERROR [api] Rate limit exceeded for IP=192.168.1.100 (requests=1000/hour)
EOF

echo "Enhanced sample files created!"
echo

echo "=== Solution 1: Advanced grep Techniques ==="

echo "1.1 Multi-pattern search with context:"
grep -E "(ERROR|WARN)" app.log -A 1 -B 1

echo
echo "1.2 Extract HTTP status codes and count them:"
grep -o " [0-9][0-9][0-9] " access.log | sort | uniq -c | sort -nr

echo
echo "1.3 Find failed requests (4xx, 5xx) with details:"
grep -E " [45][0-9][0-9] " access.log | awk '{print $1, $7, $9}' | sort

echo
echo "1.4 Case-insensitive search for user agents:"
grep -i "python\|curl" access.log | awk -F'"' '{print $6}' | sort | uniq -c

echo

echo "=== Solution 2: Advanced sed Operations ==="

echo "2.1 Clean and reformat log timestamps:"
sed 's/^\([0-9-]*\) \([0-9:]*\)\.[0-9]* \([A-Z]*\) \[\([^]]*\)\] \(.*\)/\1 \2 [\4] \3: \5/' app.log

echo
echo "2.2 Convert CSV to pipe-delimited with header transformation:"
sed '1s/.*/DATE|PRODUCT|CATEGORY|PRICE|QTY|CUSTOMER|REGION/; 2,$s/,/|/g' sales.csv

echo
echo "2.3 Extract and format IP addresses with request counts:"
sed 's/^\([0-9.]*\).*/\1/' access.log | sort | uniq -c | sed 's/^ *\([0-9]*\) \(.*\)/IP: \2 - Requests: \1/'

echo
echo "2.4 Anonymize sensitive data (replace IPs with placeholders):"
sed 's/192\.168\.1\.\([0-9]*\)/10.0.0.\1/g' access.log | head -3

echo

echo "=== Solution 3: Advanced awk Processing ==="

echo "3.1 Comprehensive sales analysis:"
awk -F',' '
BEGIN {print "=== Sales Analysis Report ==="}
NR==1 {next}
{
    # Track totals
    revenue = $4 * $5
    total_revenue += revenue
    category_revenue[$3] += revenue
    region_revenue[$7] += revenue
    customer_revenue[$6] += revenue
    
    # Track quantities
    total_quantity += $5
    category_quantity[$3] += $5
    
    # Track unique customers
    customers[$6] = 1
}
END {
    printf "Total Revenue: $%.2f\n", total_revenue
    printf "Total Quantity: %d\n", total_quantity
    printf "Unique Customers: %d\n", length(customers)
    
    print "\nRevenue by Category:"
    for (cat in category_revenue) {
        printf "  %s: $%.2f (%.1f%%)\n", cat, category_revenue[cat], 
               (category_revenue[cat]/total_revenue)*100
    }
    
    print "\nRevenue by Region:"
    for (region in region_revenue) {
        printf "  %s: $%.2f\n", region, region_revenue[region]
    }
    
    print "\nTop Customers:"
    PROCINFO["sorted_in"] = "@val_num_desc"
    for (customer in customer_revenue) {
        printf "  %s: $%.2f\n", customer, customer_revenue[customer]
    }
}' sales.csv

echo
echo "3.2 Web server log analysis:"
awk '
{
    # Extract components
    ip = $1
    timestamp = $4
    method = $6
    url = $7
    status = $9
    size = $10
    
    # Remove quotes and brackets
    gsub(/[\[\]"]/, "", timestamp)
    gsub(/"/, "", method)
    
    # Track statistics
    requests[ip]++
    methods[method]++
    status_codes[status]++
    total_bytes += size
    
    # Track errors
    if (status >= 400) {
        errors[ip]++
        error_urls[url]++
    }
}
END {
    print "=== Web Server Analysis ==="
    printf "Total requests: %d\n", NR
    printf "Total bytes served: %d\n", total_bytes
    
    print "\nTop IPs by request count:"
    PROCINFO["sorted_in"] = "@val_num_desc"
    count = 0
    for (ip in requests) {
        printf "  %s: %d requests", ip, requests[ip]
        if (ip in errors) printf " (%d errors)", errors[ip]
        print ""
        if (++count >= 3) break
    }
    
    print "\nHTTP Methods:"
    for (method in methods) {
        printf "  %s: %d\n", method, methods[method]
    }
    
    print "\nStatus Code Distribution:"
    for (status in status_codes) {
        printf "  %s: %d\n", status, status_codes[status]
    }
}' access.log

echo

echo "=== Solution 4: Advanced jq Processing ==="

echo "4.1 Department analysis with statistics:"
jq '
.employees 
| group_by(.department) 
| map({
    department: .[0].department,
    count: length,
    active_count: map(select(.active)) | length,
    avg_salary: (map(.salary) | add / length),
    total_salary: map(.salary) | add,
    skills: map(.skills[]) | unique
  })
' company_data.json

echo
echo "4.2 Project budget analysis:"
jq '
{
  total_budget: (.projects | map(.budget) | add),
  avg_budget: (.projects | map(.budget) | add / length),
  projects_by_budget: (.projects | sort_by(.budget) | reverse),
  team_utilization: (
    .projects 
    | map(.team | length) as $team_sizes
    | (.employees | length) as $total_employees
    | {
        avg_team_size: ($team_sizes | add / length),
        max_team_size: ($team_sizes | max),
        employee_utilization: (($team_sizes | add) / $total_employees)
      }
  )
}
' company_data.json

echo
echo "4.3 Employee skill matrix:"
jq -r '
.employees[] 
| select(.active) 
| [.name, (.skills | join(", "))] 
| @csv
' company_data.json | sed '1i"Employee","Skills"'

echo
echo "4.4 Cross-reference employees with projects:"
jq '
.projects[] as $project 
| .employees[] as $employee 
| select($project.team | index($employee.id)) 
| {
    project: $project.name,
    employee: $employee.name,
    department: $employee.department,
    budget_per_member: ($project.budget / ($project.team | length))
  }
' company_data.json

echo

echo "=== Solution 5: Complex Data Pipelines ==="

echo "5.1 Multi-stage log processing pipeline:"
# Extract error patterns, analyze frequency, and create report
grep "ERROR" app.log | \
sed 's/.*ERROR \[\([^]]*\)\] \(.*\)/\1: \2/' | \
awk -F': ' '{
    component = $1
    error = $2
    components[component]++
    errors[component] = errors[component] "\n  - " error
}
END {
    print "=== Error Analysis by Component ==="
    for (comp in components) {
        printf "%s: %d errors\n", comp, components[comp]
        printf "%s", errors[comp]
        print ""
    }
}' | head -20

echo
echo "5.2 Sales performance dashboard:"
# Combine multiple analyses into a dashboard
{
    echo "=== SALES DASHBOARD ==="
    echo "Generated: $(date)"
    echo
    
    # Top products by revenue
    echo "TOP PRODUCTS BY REVENUE:"
    awk -F',' 'NR>1 {revenue[$2] += $4*$5} END {
        PROCINFO["sorted_in"] = "@val_num_desc"
        for (product in revenue) printf "  %s: $%.2f\n", product, revenue[product]
    }' sales.csv
    
    echo
    echo "REGIONAL PERFORMANCE:"
    awk -F',' 'NR>1 {
        revenue[$7] += $4*$5
        orders[$7]++
    } END {
        for (region in revenue) 
            printf "  %s: $%.2f (%d orders, avg: $%.2f)\n", 
                   region, revenue[region], orders[region], revenue[region]/orders[region]
    }' sales.csv
    
    echo
    echo "DAILY TRENDS:"
    awk -F',' 'NR>1 {
        date = $1
        revenue[date] += $4*$5
        orders[date]++
    } END {
        for (date in revenue)
            printf "  %s: $%.2f (%d orders)\n", date, revenue[date], orders[date]
    }' sales.csv | sort
    
} > sales_dashboard.txt

echo "Dashboard saved to sales_dashboard.txt"
head -15 sales_dashboard.txt

echo

echo "=== Solution 6: Data Validation and Quality ==="

echo "6.1 Comprehensive CSV validation:"
validate_csv() {
    local file=$1
    local issues=0
    
    echo "Validating CSV: $file"
    
    # Check basic structure
    local total_lines=$(wc -l < "$file")
    local header_cols=$(head -1 "$file" | tr ',' '\n' | wc -l)
    
    echo "  Total lines: $total_lines"
    echo "  Expected columns: $header_cols"
    
    # Check each data row
    awk -F',' -v expected="$header_cols" '
    NR==1 {next}
    {
        if (NF != expected) {
            printf "  ❌ Row %d: %d columns (expected %d)\n", NR, NF, expected
            issues++
        }
        
        # Check for empty fields
        for (i=1; i<=NF; i++) {
            if ($i == "") {
                printf "  ⚠️  Row %d, Column %d: Empty value\n", NR, i
                warnings++
            }
        }
        
        # Data type validation (example for sales.csv)
        if (NF >= 4 && $4 !~ /^[0-9]+\.?[0-9]*$/) {
            printf "  ❌ Row %d: Invalid price format: %s\n", NR, $4
            issues++
        }
        if (NF >= 5 && $5 !~ /^[0-9]+$/) {
            printf "  ❌ Row %d: Invalid quantity format: %s\n", NR, $5
            issues++
        }
    }
    END {
        if (issues == 0 && warnings == 0) {
            print "  ✅ Validation passed"
        } else {
            printf "  Summary: %d issues, %d warnings\n", issues, warnings
        }
    }' "$file"
}

validate_csv "sales.csv"

echo
echo "6.2 Log anomaly detection:"
# Detect unusual patterns in logs
awk '
{
    # Extract hour from timestamp
    if (match($0, /[0-9]{2}:[0-9]{2}:[0-9]{2}/)) {
        hour = substr($0, RSTART, 2)
        hourly_count[hour]++
    }
    
    # Track log levels
    if (match($0, /(INFO|ERROR|WARN|DEBUG)/)) {
        level = substr($0, RSTART, RLENGTH)
        level_count[level]++
    }
    
    total_lines++
}
END {
    print "=== Log Anomaly Detection ==="
    
    # Check for unusual hourly distribution
    avg_per_hour = total_lines / 24
    print "Average logs per hour:", avg_per_hour
    
    for (hour in hourly_count) {
        if (hourly_count[hour] > avg_per_hour * 2) {
            printf "⚠️  High activity in hour %s: %d logs\n", hour, hourly_count[hour]
        }
    }
    
    # Check error rate
    error_rate = (level_count["ERROR"] / total_lines) * 100
    if (error_rate > 10) {
        printf "❌ High error rate: %.1f%%\n", error_rate
    } else {
        printf "✅ Error rate acceptable: %.1f%%\n", error_rate
    }
}' app.log

echo

# Cleanup
cd ..

echo "=== Advanced Solutions Complete ==="
echo
echo "Advanced techniques demonstrated:"
echo "✅ Multi-pattern grep with context"
echo "✅ Complex sed transformations"
echo "✅ Statistical analysis with awk"
echo "✅ Advanced jq queries and transformations"
echo "✅ Multi-stage data pipelines"
echo "✅ Data validation and quality checking"
echo "✅ Anomaly detection patterns"
echo "✅ Dashboard generation"
echo
echo "🎯 You've mastered text processing for data engineering!"
