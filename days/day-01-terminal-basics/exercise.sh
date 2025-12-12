#!/bin/bash

# Day 1: Terminal Basics - Exercises
# Complete the TODOs below to practice terminal commands

echo "=== Day 1: Terminal Basics Exercises ==="
echo ""

# Exercise 1: Navigation
echo "Exercise 1: Navigation"
echo "----------------------"

# TODO: Print your current working directory
# Hint: Use pwd command


# TODO: List all files in the current directory (including hidden files)
# Hint: Use ls with appropriate flags


echo ""

# Exercise 2: Creating Files and Directories
echo "Exercise 2: Creating Files and Directories"
echo "-------------------------------------------"

# TODO: Create a directory called "practice"
# Hint: Use mkdir


# TODO: Create three empty files in the practice directory:
#       - data1.txt
#       - data2.txt
#       - data3.txt
# Hint: Use touch command


# TODO: List the contents of the practice directory
# Hint: Use ls with the directory path


echo ""

# Exercise 3: Copying and Moving
echo "Exercise 3: Copying and Moving"
echo "-------------------------------"

# TODO: Copy data1.txt to data1_backup.txt in the practice directory
# Hint: Use cp command


# TODO: Move data2.txt to renamed_data.txt in the practice directory
# Hint: Use mv command


# TODO: List the practice directory to verify your changes
# Hint: Use ls


echo ""

# Exercise 4: Viewing Files
echo "Exercise 4: Viewing Files"
echo "-------------------------"

# Create a sample file with content for viewing
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

echo "Created sample.txt with 10 lines"

# TODO: Display the entire contents of practice/sample.txt
# Hint: Use cat


# TODO: Display only the first 3 lines of practice/sample.txt
# Hint: Use head with -n option


# TODO: Display only the last 3 lines of practice/sample.txt
# Hint: Use tail with -n option


echo ""

# Exercise 5: File Permissions
echo "Exercise 5: File Permissions"
echo "----------------------------"

# Create a script file
cat > practice/test_script.sh << 'EOF'
#!/bin/bash
echo "This is a test script"
EOF

echo "Created test_script.sh"

# TODO: Make test_script.sh executable
# Hint: Use chmod +x


# TODO: List the practice directory with detailed permissions
# Hint: Use ls -l


# TODO: Run the test script
# Hint: Use ./practice/test_script.sh


echo ""

# Exercise 6: Wildcards
echo "Exercise 6: Wildcards"
echo "---------------------"

# TODO: List all .txt files in the practice directory
# Hint: Use ls with wildcard pattern practice/*.txt


# TODO: Count how many .txt files are in the practice directory
# Hint: Use ls practice/*.txt | wc -l


echo ""

# Exercise 7: Cleanup (Optional)
echo "Exercise 7: Cleanup"
echo "-------------------"

# TODO: Remove the practice directory and all its contents
# Hint: Use rm -r (be careful!)
# Uncomment the line below when you're ready to clean up:
# rm -r practice

echo ""
echo "=== Exercises Complete! ==="
echo ""
echo "Check your solutions against solution.sh"
echo "Then take the quiz in quiz.md"
