#!/bin/bash

# Day 7: Complete Implementation Guide
# This script provides the complete implementation for all remaining pipeline components

echo "=== Day 7: Complete Pipeline Implementation ==="
echo "This guide provides complete implementations for all pipeline components"
echo

# Check if we're in a project directory
if [[ ! -f "config/pipeline.conf" ]]; then
    echo "❌ Please run this from within a pipeline project directory"
    echo "First run: bash project_starter.sh"
    exit 1
fi

echo "Implementing remaining pipeline components..."

# Create remaining cleaning scripts
echo "Creating customer cleaning script..."
cat > scripts/clean/clean_customers.sh << 'EOF'
#!/bin/bash
# Customer data cleaning script

source config/pipeline.conf
source scripts/utils/logging.sh
source scripts/utils/validation.sh

setup_error_handling

clean_customers_data() {
    local input_file="$1"
    local output_file="$2"
    
    log_info "Cleaning customer data: $input_file -> $output_file"
    
    # Validate input
    validate_json "$input_file" || return 1
    
    # Create output directory
    mkdir -p "$(dirname "$output_file")"
    
    # Clean and convert JSON to CSV
    jq -r '
    ["id","name","email","region","tier","active"] as $header |
    $header,
    (.customers[] | 
     select(.id != null and .name != null and .email != null) |
     select(.email | test("@")) |
     [.id, .name, .email, .region, .tier, .active]
    ) | @csv' "$input_file" > "$output_file"
    
    # Log cleaning statistics
    local input_records=$(jq '.customers | length' "$input_file")
    local output_records=$(($(wc -l < "$output_file") - 1))
    local cleaned_records=$((input_records - output_records))
    
    log_info "Customer cleaning stats: $input_records input, $output_records output, $cleaned_records removed"
    
    # Validate output
    check_data_quality "$output_file" "csv"
    
    log_success "Customer data cleaned: $output_file"
}

main() {
    clean_customers_data "$RAW_DIR/customers.json" "$CLEAN_DIR/customers_clean.csv"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

echo "Creating product cleaning script..."
cat > scripts/clean/clean_products.sh << 'EOF'
#!/bin/bash
# Product data cleaning script

source config/pipeline.conf
source scripts/utils/logging.sh
source scripts/utils/validation.sh

setup_error_handling

clean_products_data() {
    local input_file="$1"
    local output_file="$2"
    
    log_info "Cleaning product data: $input_file -> $output_file"
    
    # Validate input
    validate_csv "$input_file" "id,name,category,price,cost,margin,active" || return 1
    
    # Create output directory
    mkdir -p "$(dirname "$output_file")"
    
    # Clean data using awk
    awk -F',' '
    BEGIN {
        OFS=","
        print "id,name,category,price,cost,margin,active,margin_check"
    }
    NR > 1 {
        # Skip empty lines
        if (NF == 0) next
        
        # Skip records with missing required fields
        if ($1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 == "" || $6 == "") next
        
        # Validate numeric fields
        if ($4 <= 0 || $5 <= 0) next
        
        # Calculate margin check
        calculated_margin = ($4 - $5) / $4
        margin_diff = ($6 - calculated_margin)
        margin_check = (margin_diff < 0.01 && margin_diff > -0.01) ? "OK" : "MISMATCH"
        
        # Clean product name (remove extra spaces, quotes)
        gsub(/^[ \t"]+|[ \t"]+$/, "", $2)
        gsub(/[ \t]+/, " ", $2)
        
        # Output cleaned record
        print $1, $2, $3, $4, $5, $6, $7, margin_check
    }' "$input_file" > "$output_file"
    
    # Log cleaning statistics
    local input_records=$(($(wc -l < "$input_file") - 1))
    local output_records=$(($(wc -l < "$output_file") - 1))
    local cleaned_records=$((input_records - output_records))
    
    log_info "Product cleaning stats: $input_records input, $output_records output, $cleaned_records removed"
    
    # Validate output
    check_data_quality "$output_file" "csv"
    
    log_success "Product data cleaned: $output_file"
}

main() {
    clean_products_data "$RAW_DIR/products.csv" "$CLEAN_DIR/products_clean.csv"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

echo "Creating data transformation scripts..."
cat > scripts/transform/join_data.sh << 'EOF'
#!/bin/bash
# Data joining script

source config/pipeline.conf
source scripts/utils/logging.sh

setup_error_handling

join_sales_data() {
    log_info "Joining sales data with customers and products"
    
    local sales_file="$CLEAN_DIR/sales_clean.csv"
    local customers_file="$CLEAN_DIR/customers_clean.csv"
    local products_file="$CLEAN_DIR/products_clean.csv"
    local output_file="$TRANSFORMED_DIR/sales_enriched.csv"
    
    # Create output directory
    mkdir -p "$(dirname "$output_file")"
    
    # Join data using awk
    awk -F',' '
    BEGIN { OFS="," }
    
    # Read customers data
    FNR==NR && NR>1 {
        customers[$1] = $2 "," $3 "," $4 "," $5 "," $6
        next
    }
    
    # Read products data  
    FNR==NR && NR>1 {
        products[$1] = $2 "," $3 "," $4 "," $5 "," $6 "," $7 "," $8
        next
    }
    
    # Process sales data
    FNR!=NR {
        if (NR==1) {
            # Header
            print "sale_id,date,customer_id,customer_name,customer_email,customer_region,customer_tier,customer_active,product_id,product_name,product_category,product_price,product_cost,quantity,sale_price,total,revenue_check"
        } else {
            # Data rows
            sale_id = $1
            date = $2
            customer_id = $3
            product_id = $4
            quantity = $5
            sale_price = $6
            total = $7
            revenue_check = $8
            
            # Get customer info
            if (customer_id in customers) {
                split(customers[customer_id], cust_info, ",")
                customer_name = cust_info[1]
                customer_email = cust_info[2]
                customer_region = cust_info[3]
                customer_tier = cust_info[4]
                customer_active = cust_info[5]
            } else {
                customer_name = customer_email = customer_region = customer_tier = customer_active = "UNKNOWN"
            }
            
            # Get product info
            if (product_id in products) {
                split(products[product_id], prod_info, ",")
                product_name = prod_info[1]
                product_category = prod_info[2]
                product_price = prod_info[3]
                product_cost = prod_info[4]
            } else {
                product_name = product_category = product_price = product_cost = "UNKNOWN"
            }
            
            print sale_id, date, customer_id, customer_name, customer_email, customer_region, customer_tier, customer_active, product_id, product_name, product_category, product_price, product_cost, quantity, sale_price, total, revenue_check
        }
    }' "$customers_file" "$products_file" "$sales_file" > "$output_file"
    
    local output_records=$(($(wc -l < "$output_file") - 1))
    log_success "Data joining completed: $output_records enriched records in $output_file"
}

main() {
    join_sales_data
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

cat > scripts/transform/aggregate_data.sh << 'EOF'
#!/bin/bash
# Data aggregation script

source config/pipeline.conf
source scripts/utils/logging.sh

setup_error_handling

aggregate_sales_data() {
    log_info "Aggregating sales data for reporting"
    
    local input_file="$TRANSFORMED_DIR/sales_enriched.csv"
    local output_dir="$TRANSFORMED_DIR"
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Daily sales summary
    log_info "Creating daily sales summary"
    awk -F',' '
    NR>1 {
        date = $2
        total = $16
        quantity = $14
        
        daily_revenue[date] += total
        daily_quantity[date] += quantity
        daily_orders[date]++
    }
    END {
        print "date,total_revenue,total_quantity,total_orders,avg_order_value"
        for (date in daily_revenue) {
            avg_order = daily_revenue[date] / daily_orders[date]
            printf "%s,%.2f,%d,%d,%.2f\n", date, daily_revenue[date], daily_quantity[date], daily_orders[date], avg_order
        }
    }' "$input_file" | sort > "$output_dir/daily_summary.csv"
    
    # Customer summary
    log_info "Creating customer summary"
    awk -F',' '
    NR>1 {
        customer_id = $3
        customer_name = $4
        customer_region = $6
        customer_tier = $7
        total = $16
        quantity = $14
        
        customer_revenue[customer_id] += total
        customer_quantity[customer_id] += quantity
        customer_orders[customer_id]++
        customer_info[customer_id] = customer_name "," customer_region "," customer_tier
    }
    END {
        print "customer_id,customer_name,customer_region,customer_tier,total_revenue,total_quantity,total_orders,avg_order_value"
        for (customer_id in customer_revenue) {
            split(customer_info[customer_id], info, ",")
            avg_order = customer_revenue[customer_id] / customer_orders[customer_id]
            printf "%s,%s,%s,%s,%.2f,%d,%d,%.2f\n", customer_id, info[1], info[2], info[3], customer_revenue[customer_id], customer_quantity[customer_id], customer_orders[customer_id], avg_order
        }
    }' "$input_file" | sort > "$output_dir/customer_summary.csv"
    
    # Product summary
    log_info "Creating product summary"
    awk -F',' '
    NR>1 {
        product_id = $9
        product_name = $10
        product_category = $11
        total = $16
        quantity = $14
        
        product_revenue[product_id] += total
        product_quantity[product_id] += quantity
        product_orders[product_id]++
        product_info[product_id] = product_name "," product_category
    }
    END {
        print "product_id,product_name,product_category,total_revenue,total_quantity,total_orders,avg_order_value"
        for (product_id in product_revenue) {
            split(product_info[product_id], info, ",")
            avg_order = product_revenue[product_id] / product_orders[product_id]
            printf "%s,%s,%s,%.2f,%d,%d,%.2f\n", product_id, info[1], info[2], product_revenue[product_id], product_quantity[product_id], product_orders[product_id], avg_order
        }
    }' "$input_file" | sort > "$output_dir/product_summary.csv"
    
    # Regional summary
    log_info "Creating regional summary"
    awk -F',' '
    NR>1 {
        region = $6
        total = $16
        quantity = $14
        
        regional_revenue[region] += total
        regional_quantity[region] += quantity
        regional_orders[region]++
    }
    END {
        print "region,total_revenue,total_quantity,total_orders,avg_order_value"
        for (region in regional_revenue) {
            avg_order = regional_revenue[region] / regional_orders[region]
            printf "%s,%.2f,%d,%d,%.2f\n", region, regional_revenue[region], regional_quantity[region], regional_orders[region], avg_order
        }
    }' "$input_file" | sort > "$output_dir/regional_summary.csv"
    
    log_success "Data aggregation completed"
}

main() {
    aggregate_sales_data
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

echo "Creating validation script..."
cat > scripts/validate/validate_pipeline.sh << 'EOF'
#!/bin/bash
# Pipeline validation script

source config/pipeline.conf
source scripts/utils/logging.sh
source scripts/utils/validation.sh

setup_error_handling

validate_pipeline() {
    log_info "Starting pipeline validation"
    
    local validation_report="$OUTPUT_DIR/validation_report.txt"
    mkdir -p "$(dirname "$validation_report")"
    
    {
        echo "=== Pipeline Validation Report ==="
        echo "Generated: $(date)"
        echo "Environment: $ENVIRONMENT"
        echo ""
        
        # Validate raw data
        echo "Raw Data Validation:"
        validate_file "$RAW_DIR/sales.csv" && echo "✓ Sales data file exists" || echo "✗ Sales data file missing"
        validate_file "$RAW_DIR/customers.json" && echo "✓ Customer data file exists" || echo "✗ Customer data file missing"
        validate_file "$RAW_DIR/products.csv" && echo "✓ Product data file exists" || echo "✗ Product data file missing"
        echo ""
        
        # Validate cleaned data
        echo "Cleaned Data Validation:"
        validate_csv "$CLEAN_DIR/sales_clean.csv" "id,date,customer_id,product_id" && echo "✓ Cleaned sales data valid" || echo "✗ Cleaned sales data invalid"
        validate_csv "$CLEAN_DIR/customers_clean.csv" "id,name,email,region" && echo "✓ Cleaned customer data valid" || echo "✗ Cleaned customer data invalid"
        validate_csv "$CLEAN_DIR/products_clean.csv" "id,name,category,price" && echo "✓ Cleaned product data valid" || echo "✗ Cleaned product data invalid"
        echo ""
        
        # Validate transformed data
        echo "Transformed Data Validation:"
        validate_file "$TRANSFORMED_DIR/sales_enriched.csv" && echo "✓ Enriched sales data exists" || echo "✗ Enriched sales data missing"
        validate_file "$TRANSFORMED_DIR/daily_summary.csv" && echo "✓ Daily summary exists" || echo "✗ Daily summary missing"
        validate_file "$TRANSFORMED_DIR/customer_summary.csv" && echo "✓ Customer summary exists" || echo "✗ Customer summary missing"
        echo ""
        
        # Data quality checks
        echo "Data Quality Checks:"
        
        # Check record counts
        local sales_raw=$(($(wc -l < "$RAW_DIR/sales.csv") - 1))
        local sales_clean=$(($(wc -l < "$CLEAN_DIR/sales_clean.csv") - 1))
        local sales_enriched=$(($(wc -l < "$TRANSFORMED_DIR/sales_enriched.csv") - 1))
        
        echo "Record counts:"
        echo "  Raw sales: $sales_raw"
        echo "  Clean sales: $sales_clean"
        echo "  Enriched sales: $sales_enriched"
        
        # Check data loss
        local data_loss_pct=$(echo "scale=2; (($sales_raw - $sales_clean) * 100) / $sales_raw" | bc -l)
        echo "  Data loss: $data_loss_pct%"
        
        if (( $(echo "$data_loss_pct > 10" | bc -l) )); then
            echo "⚠️  High data loss detected!"
        else
            echo "✓ Data loss within acceptable range"
        fi
        
        # Check for data anomalies
        echo ""
        echo "Anomaly Detection:"
        
        # Check for negative values
        local negative_totals=$(awk -F',' 'NR>1 && $7 < 0 {count++} END {print count+0}' "$CLEAN_DIR/sales_clean.csv")
        if [[ $negative_totals -gt 0 ]]; then
            echo "⚠️  Found $negative_totals records with negative totals"
        else
            echo "✓ No negative totals found"
        fi
        
        # Check for revenue mismatches
        local revenue_mismatches=$(awk -F',' 'NR>1 && $8 == "MISMATCH" {count++} END {print count+0}' "$CLEAN_DIR/sales_clean.csv")
        if [[ $revenue_mismatches -gt 0 ]]; then
            echo "⚠️  Found $revenue_mismatches records with revenue calculation mismatches"
        else
            echo "✓ All revenue calculations match"
        fi
        
        echo ""
        echo "=== Validation Complete ==="
        
    } | tee "$validation_report"
    
    log_success "Pipeline validation completed: $validation_report"
}

main() {
    validate_pipeline
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

echo "Creating report generation script..."
cat > scripts/report/generate_reports.sh << 'EOF'
#!/bin/bash
# Report generation script

source config/pipeline.conf
source scripts/utils/logging.sh

setup_error_handling

generate_html_report() {
    log_info "Generating HTML report"
    
    local report_file="$REPORTS_DIR/pipeline_report.html"
    mkdir -p "$(dirname "$report_file")"
    
    # Calculate summary statistics
    local total_sales=$(awk -F',' 'NR>1 {sum += $7} END {printf "%.2f", sum}' "$CLEAN_DIR/sales_clean.csv")
    local total_orders=$(awk 'END {print NR-1}' "$CLEAN_DIR/sales_clean.csv")
    local avg_order_value=$(echo "scale=2; $total_sales / $total_orders" | bc -l)
    local unique_customers=$(awk -F',' 'NR>1 {customers[$3]=1} END {print length(customers)}' "$CLEAN_DIR/sales_clean.csv")
    local unique_products=$(awk -F',' 'NR>1 {products[$4]=1} END {print length(products)}' "$CLEAN_DIR/sales_clean.csv")
    
    # Generate HTML report
    cat > "$report_file" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data Pipeline Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        .metric-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 20px 0; }
        .metric-card { background: #ecf0f1; padding: 20px; border-radius: 8px; text-align: center; }
        .metric-value { font-size: 2em; font-weight: bold; color: #2980b9; }
        .metric-label { color: #7f8c8d; margin-top: 5px; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #3498db; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .status-ok { color: #27ae60; font-weight: bold; }
        .status-warn { color: #f39c12; font-weight: bold; }
        .status-error { color: #e74c3c; font-weight: bold; }
        .footer { margin-top: 40px; padding-top: 20px; border-top: 1px solid #ddd; color: #7f8c8d; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Data Pipeline Report</h1>
        <p><strong>Generated:</strong> $(date)</p>
        <p><strong>Environment:</strong> $ENVIRONMENT</p>
        
        <h2>📈 Executive Summary</h2>
        <div class="metric-grid">
            <div class="metric-card">
                <div class="metric-value">\$$total_sales</div>
                <div class="metric-label">Total Sales</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">$total_orders</div>
                <div class="metric-label">Total Orders</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">\$$avg_order_value</div>
                <div class="metric-label">Avg Order Value</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">$unique_customers</div>
                <div class="metric-label">Unique Customers</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">$unique_products</div>
                <div class="metric-label">Unique Products</div>
            </div>
        </div>
        
        <h2>📅 Daily Performance</h2>
        <table>
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Revenue</th>
                    <th>Orders</th>
                    <th>Avg Order Value</th>
                </tr>
            </thead>
            <tbody>
HTMLEOF

    # Add daily summary data
    awk -F',' 'NR>1 {printf "                <tr><td>%s</td><td>$%.2f</td><td>%d</td><td>$%.2f</td></tr>\n", $1, $2, $4, $5}' "$TRANSFORMED_DIR/daily_summary.csv" >> "$report_file"
    
    cat >> "$report_file" << HTMLEOF
            </tbody>
        </table>
        
        <h2>🏆 Top Customers</h2>
        <table>
            <thead>
                <tr>
                    <th>Customer</th>
                    <th>Region</th>
                    <th>Tier</th>
                    <th>Revenue</th>
                    <th>Orders</th>
                </tr>
            </thead>
            <tbody>
HTMLEOF

    # Add top customers (sorted by revenue, top 10)
    sort -t',' -k5 -nr "$TRANSFORMED_DIR/customer_summary.csv" | head -10 | awk -F',' 'NR>0 {printf "                <tr><td>%s</td><td>%s</td><td>%s</td><td>$%.2f</td><td>%d</td></tr>\n", $2, $3, $4, $5, $7}' >> "$report_file"
    
    cat >> "$report_file" << HTMLEOF
            </tbody>
        </table>
        
        <h2>🛍️ Product Performance</h2>
        <table>
            <thead>
                <tr>
                    <th>Product</th>
                    <th>Category</th>
                    <th>Revenue</th>
                    <th>Units Sold</th>
                    <th>Orders</th>
                </tr>
            </thead>
            <tbody>
HTMLEOF

    # Add product performance
    sort -t',' -k4 -nr "$TRANSFORMED_DIR/product_summary.csv" | awk -F',' 'NR>0 {printf "                <tr><td>%s</td><td>%s</td><td>$%.2f</td><td>%d</td><td>%d</td></tr>\n", $2, $3, $4, $5, $6}' >> "$report_file"
    
    cat >> "$report_file" << HTMLEOF
            </tbody>
        </table>
        
        <h2>🌍 Regional Analysis</h2>
        <table>
            <thead>
                <tr>
                    <th>Region</th>
                    <th>Revenue</th>
                    <th>Orders</th>
                    <th>Avg Order Value</th>
                </tr>
            </thead>
            <tbody>
HTMLEOF

    # Add regional data
    sort -t',' -k2 -nr "$TRANSFORMED_DIR/regional_summary.csv" | awk -F',' 'NR>0 {printf "                <tr><td>%s</td><td>$%.2f</td><td>%d</td><td>$%.2f</td></tr>\n", $1, $2, $4, $5}' >> "$report_file"
    
    cat >> "$report_file" << HTMLEOF
            </tbody>
        </table>
        
        <div class="footer">
            <p>Report generated by Data Pipeline v$VERSION</p>
            <p>For technical details, see the validation report and pipeline logs.</p>
        </div>
    </div>
</body>
</html>
HTMLEOF

    log_success "HTML report generated: $report_file"
}

generate_csv_export() {
    log_info "Generating CSV exports"
    
    local export_dir="$OUTPUT_DIR/exports"
    mkdir -p "$export_dir"
    
    # Copy summary files to exports
    cp "$TRANSFORMED_DIR/daily_summary.csv" "$export_dir/"
    cp "$TRANSFORMED_DIR/customer_summary.csv" "$export_dir/"
    cp "$TRANSFORMED_DIR/product_summary.csv" "$export_dir/"
    cp "$TRANSFORMED_DIR/regional_summary.csv" "$export_dir/"
    
    log_success "CSV exports created in: $export_dir"
}

main() {
    generate_html_report
    generate_csv_export
    
    log_success "All reports generated successfully"
    echo
    echo "📊 Reports available:"
    echo "  HTML Report: $REPORTS_DIR/pipeline_report.html"
    echo "  CSV Exports: $OUTPUT_DIR/exports/"
    echo "  Validation: $OUTPUT_DIR/validation_report.txt"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

# Make all scripts executable
find scripts -name "*.sh" -exec chmod +x {} \;

echo "✅ All pipeline components implemented!"
echo
echo "Complete pipeline now includes:"
echo "✓ Data download with fallback sources"
echo "✓ Comprehensive data cleaning (sales, customers, products)"
echo "✓ Data transformation and joining"
echo "✓ Data aggregation and summarization"
echo "✓ Pipeline validation and quality checks"
echo "✓ HTML report generation with statistics"
echo "✓ CSV exports for further analysis"
echo
echo "To test the complete pipeline:"
echo "1. make clean    # Clean any previous runs"
echo "2. make all      # Run complete pipeline"
echo "3. make status   # Check results"
echo
echo "The pipeline will:"
echo "• Download sample data (or use local backups)"
echo "• Clean and validate all data sources"
echo "• Join sales data with customer and product information"
echo "• Generate daily, customer, product, and regional summaries"
echo "• Validate data quality and pipeline integrity"
echo "• Create comprehensive HTML report with metrics"
echo "• Export summary data as CSV files"
echo
echo "🎉 Your complete ETL pipeline is ready!"
