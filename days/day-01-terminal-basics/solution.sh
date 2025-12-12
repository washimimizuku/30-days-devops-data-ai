#!/bin/bash

# Day 1: Terminal Basics - Solutions
# Complete solutions to all exercises

echo "=== Day 1: Terminal Basics Solutions ==="
echo ""

# Exercise 1: Navigation
echo "Exercise 1: Navigation"
echo "----------------------"

# Print current working directory
pwd

# List all files including hidden ones
ls -la

echo ""

# Exercise 2: Creating Files and Directories
echo "Exercise 2: Creating Files and Directories"
echo "-------------------------------------------"

# Create practice directory
mkdir practice

# Create three empty files
touch practice/data1.txt practice/data2.txt practice/data3.txt

# List contents
ls -l practice/

echo ""

# Exercise 3: Copying and Moving
echo "Exercise 3: Copying and Moving"
echo "-------------------------------"

# Copy data1.txt to backup
cp practice/data1.txt practice/data1_backup.txt

# Rename data2.txt
mv practice/data2.txt practice/renamed_data.txt

# Verify changes
ls -l practice/

echo ""

# Exercise 4: Viewing Files
echo "Exercise 4: Viewing Files"
echo "-------------------------"

# Create sample file
cat > practice/sample.txt << 'EOF'
Line 1: This is a sample file
Line 2: For practicing view commands
Line 3: It has multiple lines
Line 4: To demonstrate head and tail
Line 5: Keep practicing!
Line 6: You're doing great
Line 7: Almost there
Line 8: Just a few more lines
Line 9: Second to last
Line 10: Final line
EOF

echo "Created sample.txt"

# Display entire file
echo "Full file contents:"
cat practice/sample.txt

# Display first 3 lines
echo ""
echo "First 3 lines:"
head -n 3 practice/sample.txt

# Display last 3 lines
echo ""
echo "Last 3 lines:"
tail -n 3 practice/sample.txt

echo ""

# Exercise 5: File Permissions
echo "Exercise 5: File Permissions"
echo "----------------------------"

# Create script
cat > practice/test_script.sh << 'EOF'
#!/bin/bash
echo "This is a test script"
EOF

echo "Created test_script.sh"

# Make executable
chmod +x practice/test_script.sh

# List with permissions
ls -l practice/test_script.sh

# Run the script
echo "Running script:"
./practice/test_script.sh

echo ""

# Exercise 6: Wildcards
echo "Exercise 6: Wildcards"
echo "---------------------"

# List all .txt files
echo "All .txt files:"
ls practice/*.txt

# Count .txt files
echo ""
echo "Number of .txt files:"
ls practice/*.txt | wc -l

echo ""

# Exercise 7: Cleanup
echo "Exercise 7: Cleanup"
echo "-------------------"

# Remove practice directory
echo "Cleaning up practice directory..."
rm -r practice

echo "Cleanup complete!"

echo ""
echo "=== All Solutions Complete! ==="
echo ""
echo "Key concepts demonstrated:"
echo "- Navigation: pwd, cd, ls"
echo "- File operations: mkdir, touch, cp, mv, rm"
echo "- Viewing files: cat, head, tail"
echo "- Permissions: chmod"
echo "- Wildcards: *.txt pattern matching"
