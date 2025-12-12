# Day 3: Text Processing Tools

**Duration**: 1 hour  
**Prerequisites**: Day 2 - Shell Scripting Basics

## Learning Objectives

By the end of this lesson, you will:
- Search and filter text with grep
- Edit text streams with sed
- Process structured text with awk
- Manipulate JSON data with jq
- Handle CSV files with csvkit
- Build text processing pipelines

## Tools Overview

### 1. grep - Pattern Searching

Search for patterns in text files.

```bash
# Basic search
grep "error" logfile.txt
grep -i "ERROR" logfile.txt          # Case insensitive
grep -n "error" logfile.txt          # Show line numbers
grep -v "info" logfile.txt           # Invert match (exclude)
grep -c "error" logfile.txt          # Count matches

# Regular expressions
grep "^ERROR" logfile.txt            # Lines starting with ERROR
grep "ERROR$" logfile.txt            # Lines ending with ERROR
grep "[0-9]+" logfile.txt            # Lines with numbers
grep -E "(error|warning)" logfile.txt # Extended regex (OR)

# Multiple files
grep -r "TODO" src/                  # Recursive search
grep -l "error" *.log               # List files with matches
```

### 2. sed - Stream Editor

Edit text streams without opening files.

```bash
# Substitution
sed 's/old/new/' file.txt           # Replace first occurrence per line
sed 's/old/new/g' file.txt          # Replace all occurrences
sed 's/old/new/gi' file.txt         # Case insensitive replacement

# Line operations
sed '2d' file.txt                   # Delete line 2
sed '1,3d' file.txt                 # Delete lines 1-3
sed -n '2,5p' file.txt              # Print lines 2-5 only

# In-place editing
sed -i 's/old/new/g' file.txt       # Edit file directly
sed -i.bak 's/old/new/g' file.txt   # Create backup

# Advanced patterns
sed '/pattern/d' file.txt           # Delete lines matching pattern
sed '/start/,/end/d' file.txt       # Delete range between patterns
```

### 3. awk - Text Processing

Process structured text and perform calculations.

```bash
# Basic usage
awk '{print $1}' file.txt           # Print first column
awk '{print $1, $3}' file.txt       # Print columns 1 and 3
awk '{print NF}' file.txt           # Print number of fields per line

# Field separator
awk -F',' '{print $2}' data.csv     # Use comma as separator
awk -F: '{print $1}' /etc/passwd    # Use colon as separator

# Conditions
awk '$3 > 100' data.txt             # Lines where column 3 > 100
awk '/error/ {print $0}' log.txt    # Lines containing "error"
awk 'NR > 1' data.csv               # Skip header (line number > 1)

# Calculations
awk '{sum += $2} END {print sum}' data.txt    # Sum column 2
awk '{print $1, $2 * 1.1}' data.txt          # Calculate new values

# Built-in variables
# NR = line number, NF = number of fields, FS = field separator
```

### 4. jq - JSON Processor

Parse and manipulate JSON data.

```bash
# Basic queries
jq '.' data.json                    # Pretty print JSON
jq '.name' data.json                # Extract field
jq '.users[0]' data.json            # First array element
jq '.users[].name' data.json        # All user names

# Filtering
jq '.users[] | select(.age > 25)' data.json    # Filter by condition
jq '.[] | select(.status == "active")' data.json

# Transformations
jq '.users | length' data.json      # Array length
jq '.users | map(.name)' data.json  # Extract all names
jq '{name: .name, age: .age}' data.json # Create new object

# Output formats
jq -r '.name' data.json             # Raw output (no quotes)
jq -c '.' data.json                 # Compact output
```

### 5. csvkit - CSV Tools

Specialized tools for CSV manipulation.

```bash
# Installation (if needed)
pip install csvkit

# Basic operations
csvlook data.csv                    # Pretty print CSV
csvstat data.csv                    # Statistics
csvcut -c 1,3 data.csv             # Select columns
csvgrep -c name -m "Alice" data.csv # Filter rows

# Conversion
in2csv data.xlsx > data.csv         # Excel to CSV
csvjson data.csv > data.json        # CSV to JSON
```

## Data Processing Examples

### Log Analysis Pipeline
```bash
# Find errors, extract timestamps, count by hour
grep "ERROR" app.log | \
sed 's/.*\[\([0-9-]* [0-9]*\):.*/\1/' | \
awk '{print substr($2,1,2)}' | \
sort | uniq -c
```

### CSV Data Cleaning
```bash
# Remove empty lines, fix delimiters, extract specific columns
sed '/^$/d' messy.csv | \
sed 's/;/,/g' | \
csvcut -c name,age,city | \
csvgrep -c age -r '^[0-9]+$'
```

### JSON to CSV Conversion
```bash
# Extract user data from JSON API response
curl -s api.example.com/users | \
jq -r '.users[] | [.name, .age, .email] | @csv' > users.csv
```

## Common Patterns

### 1. Text Extraction
```bash
# Extract email addresses
grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' file.txt

# Extract IP addresses
grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' log.txt
```

### 2. Data Transformation
```bash
# Convert CSV to pipe-delimited
sed 's/,/|/g' data.csv

# Add line numbers
awk '{print NR ": " $0}' file.txt
```

### 3. Filtering and Aggregation
```bash
# Count unique values in column 2
awk '{print $2}' data.txt | sort | uniq -c

# Sum values by category
awk -F',' '{sum[$1] += $2} END {for (i in sum) print i, sum[i]}' data.csv
```

## Performance Tips

1. **Use appropriate tools**: grep for searching, awk for structured data
2. **Combine tools efficiently**: Use pipes to chain operations
3. **Avoid unnecessary processing**: Filter early in the pipeline
4. **Use built-in variables**: NR, NF, FS in awk
5. **Consider memory usage**: For large files, process line by line

## Exercise

Complete the exercise in `exercise.sh` to practice text processing with real data scenarios.

## Quiz

Test your knowledge with `quiz.md`.

## Next Steps

Tomorrow we'll learn process management to monitor and control long-running data processing jobs.
