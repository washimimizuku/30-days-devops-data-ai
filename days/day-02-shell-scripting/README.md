# Day 2: Shell Scripting Basics

**Duration**: 1 hour  
**Prerequisites**: Day 1 - Terminal Basics

## Learning Objectives

By the end of this lesson, you will:
- Write executable shell scripts with proper shebang
- Use variables and command substitution
- Implement conditionals and loops
- Handle exit codes and errors
- Create data validation scripts

## Concepts

### 1. Shell Scripts and Shebang

A shell script is a file containing shell commands. The shebang (`#!`) tells the system which interpreter to use.

```bash
#!/bin/bash
# This is a comment
echo "Hello, World!"
```

### 2. Variables and Command Substitution

```bash
# Variable assignment (no spaces around =)
name="data_file"
count=42

# Using variables
echo "Processing $name"
echo "Found ${count} records"

# Command substitution
current_date=$(date +%Y-%m-%d)
file_count=$(ls *.csv | wc -l)
```

### 3. Conditionals

```bash
# Basic if statement
if [ -f "data.csv" ]; then
    echo "File exists"
else
    echo "File not found"
fi

# Multiple conditions
if [ $count -gt 100 ] && [ -r "data.csv" ]; then
    echo "Large dataset and readable file"
fi
```

Common test operators:
- `-f file`: file exists
- `-d dir`: directory exists
- `-r file`: file is readable
- `-w file`: file is writable
- `-z string`: string is empty
- `$a -eq $b`: numbers equal
- `$a -gt $b`: a greater than b

### 4. Loops

```bash
# For loop with list
for file in *.csv; do
    echo "Processing $file"
done

# For loop with range
for i in {1..5}; do
    echo "Iteration $i"
done

# While loop
counter=1
while [ $counter -le 3 ]; do
    echo "Count: $counter"
    counter=$((counter + 1))
done
```

### 5. Exit Codes and Error Handling

```bash
# Check command success
if grep "error" logfile.txt; then
    echo "Errors found in log"
    exit 1  # Exit with error code
else
    echo "No errors found"
    exit 0  # Exit successfully
fi

# Using $? to check last command
ls nonexistent_file.txt
if [ $? -ne 0 ]; then
    echo "Command failed"
fi
```

### 6. Functions

```bash
validate_file() {
    local filename=$1
    if [ -f "$filename" ]; then
        echo "✓ $filename exists"
        return 0
    else
        echo "✗ $filename missing"
        return 1
    fi
}

# Call function
validate_file "data.csv"
```

## Data Processing Examples

### CSV Row Counter
```bash
#!/bin/bash
csv_file="$1"
if [ -f "$csv_file" ]; then
    rows=$(wc -l < "$csv_file")
    echo "$csv_file has $rows rows"
else
    echo "File $csv_file not found"
    exit 1
fi
```

### Data Backup Script
```bash
#!/bin/bash
source_dir="data"
backup_dir="backup_$(date +%Y%m%d)"

if [ -d "$source_dir" ]; then
    mkdir -p "$backup_dir"
    cp -r "$source_dir"/* "$backup_dir"/
    echo "Backup completed: $backup_dir"
else
    echo "Source directory not found"
    exit 1
fi
```

## Best Practices

1. **Always use shebang**: `#!/bin/bash`
2. **Quote variables**: `"$variable"` to handle spaces
3. **Check file existence**: Before processing files
4. **Use meaningful exit codes**: 0 for success, non-zero for errors
5. **Add comments**: Explain complex logic
6. **Make scripts executable**: `chmod +x script.sh`

## Exercise

Complete the exercise in `exercise.sh` to practice shell scripting fundamentals.

## Quiz

Test your knowledge with `quiz.md`.

## Next Steps

Tomorrow we'll learn text processing tools (grep, sed, awk, jq) to manipulate data files efficiently.
