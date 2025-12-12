# Day 1: Terminal Basics

Welcome to Day 1! Today you'll learn the fundamentals of working with the command line terminal.

## Learning Objectives

By the end of this lesson, you will be able to:
- Understand what the terminal is and why it's important
- Navigate the filesystem using command line
- Create, move, copy, and delete files and directories
- View file contents using various commands
- Understand and modify file permissions

## Prerequisites

- Terminal application installed (comes with macOS/Linux, WSL2 for Windows)
- Completed setup verification (`bash tools/test_setup.sh`)

## Concepts

### What is the Terminal?

The **terminal** (also called command line, shell, or console) is a text-based interface for interacting with your computer. While graphical interfaces (GUI) are intuitive, the terminal is:

- **Faster** for many tasks
- **More powerful** with advanced features
- **Scriptable** for automation
- **Universal** across systems
- **Essential** for data engineering and DevOps

### Terminal vs Shell vs Command Line

- **Terminal**: The application window
- **Shell**: The program that interprets commands (bash, zsh, etc.)
- **Command Line**: The text interface itself

### Basic Command Structure

```bash
command [options] [arguments]
```

Example:
```bash
ls -la /home/user
│  │   └─ argument (what to list)
│  └─ option (how to list)
└─ command (what to do)
```

## Navigation Commands

### pwd - Print Working Directory

Shows your current location in the filesystem.

```bash
pwd
# Output: /Users/username/30-days-devtools-data-ai
```

### cd - Change Directory

Move between directories.

```bash
# Go to home directory
cd ~

# Go to specific directory
cd /Users/username/Documents

# Go up one level
cd ..

# Go up two levels
cd ../..

# Go to previous directory
cd -

# Go to subdirectory
cd days/day-01-terminal-basics
```

**Tip:** Use Tab key for auto-completion!

### ls - List Files

View files and directories.

```bash
# Basic list
ls

# Long format (detailed)
ls -l

# Show hidden files
ls -a

# Long format with hidden files
ls -la

# Human-readable file sizes
ls -lh

# Sort by modification time
ls -lt

# Reverse sort
ls -lr
```

**Understanding ls -l output:**
```
-rw-r--r--  1 user  staff  1234 Dec  5 10:30 file.txt
│           │  │     │      │    │           └─ filename
│           │  │     │      │    └─ modification time
│           │  │     │      └─ file size (bytes)
│           │  │     └─ group
│           │  └─ owner
│           └─ number of links
└─ permissions
```

## File Operations

### touch - Create Empty File

```bash
# Create single file
touch file.txt

# Create multiple files
touch file1.txt file2.txt file3.txt

# Update timestamp of existing file
touch existing-file.txt
```

### mkdir - Make Directory

```bash
# Create single directory
mkdir my-folder

# Create nested directories
mkdir -p path/to/nested/folder

# Create multiple directories
mkdir folder1 folder2 folder3
```

### cp - Copy Files

```bash
# Copy file
cp source.txt destination.txt

# Copy to directory
cp file.txt /path/to/directory/

# Copy directory recursively
cp -r source-folder/ destination-folder/

# Copy with verbose output
cp -v file.txt copy.txt

# Copy and preserve attributes
cp -p file.txt copy.txt
```

### mv - Move/Rename Files

```bash
# Rename file
mv oldname.txt newname.txt

# Move file to directory
mv file.txt /path/to/directory/

# Move multiple files
mv file1.txt file2.txt /path/to/directory/

# Move directory
mv old-folder/ new-folder/
```

### rm - Remove Files

```bash
# Remove file
rm file.txt

# Remove multiple files
rm file1.txt file2.txt

# Remove directory and contents
rm -r folder/

# Force remove (no confirmation)
rm -f file.txt

# Force remove directory
rm -rf folder/

# Interactive mode (ask before each deletion)
rm -i file.txt
```

**⚠️ Warning:** `rm -rf` is dangerous! There's no undo. Be very careful!

## Viewing Files

### cat - Concatenate and Display

```bash
# Display entire file
cat file.txt

# Display multiple files
cat file1.txt file2.txt

# Display with line numbers
cat -n file.txt

# Concatenate files into new file
cat file1.txt file2.txt > combined.txt
```

### less - View File (Paginated)

```bash
# View file with pagination
less file.txt

# Navigation in less:
# Space - next page
# b - previous page
# / - search forward
# ? - search backward
# q - quit
```

### head - View Beginning of File

```bash
# First 10 lines (default)
head file.txt

# First 20 lines
head -n 20 file.txt

# First 5 lines
head -5 file.txt
```

### tail - View End of File

```bash
# Last 10 lines (default)
tail file.txt

# Last 20 lines
tail -n 20 file.txt

# Follow file (live updates)
tail -f logfile.log

# Follow with line numbers
tail -fn 50 logfile.log
```

**Use case:** `tail -f` is perfect for monitoring log files in real-time!

## File Permissions

### Understanding Permissions

```
-rw-r--r--
│││ │ │ │
│││ │ │ └─ others: read
│││ │ └─── group: read
│││ └───── owner: read, write
││└─────── group permissions
│└──────── owner permissions
└───────── file type (- = file, d = directory)
```

**Permission values:**
- `r` (read) = 4
- `w` (write) = 2
- `x` (execute) = 1

### chmod - Change Permissions

```bash
# Make file executable
chmod +x script.sh

# Remove execute permission
chmod -x script.sh

# Set specific permissions (rwxr-xr-x)
chmod 755 script.sh

# Set read/write for owner only (rw-------)
chmod 600 file.txt

# Common permissions:
# 644 - rw-r--r-- (files)
# 755 - rwxr-xr-x (executables)
# 700 - rwx------ (private)
```

### chown - Change Owner

```bash
# Change owner
chown username file.txt

# Change owner and group
chown username:groupname file.txt

# Change recursively
chown -R username folder/
```

## Useful Tips

### Wildcards

```bash
# * matches any characters
ls *.txt           # All .txt files
rm file*.txt       # file1.txt, file2.txt, etc.

# ? matches single character
ls file?.txt       # file1.txt, file2.txt, but not file10.txt

# [] matches character range
ls file[1-3].txt   # file1.txt, file2.txt, file3.txt
```

### Command History

```bash
# View command history
history

# Repeat last command
!!

# Repeat command 42 from history
!42

# Search history (Ctrl+R)
# Type to search, Enter to execute
```

### Keyboard Shortcuts

- `Ctrl+C` - Cancel current command
- `Ctrl+D` - Exit shell / End of input
- `Ctrl+L` - Clear screen (same as `clear`)
- `Ctrl+A` - Beginning of line
- `Ctrl+E` - End of line
- `Ctrl+U` - Delete to beginning of line
- `Ctrl+K` - Delete to end of line
- `Ctrl+R` - Search command history
- `Tab` - Auto-complete

## Practical Examples

### Example 1: Organize Project Files

```bash
# Create project structure
mkdir -p project/{src,tests,docs,data}

# Create files
touch project/README.md
touch project/src/main.py
touch project/tests/test_main.py

# View structure
ls -R project/
```

### Example 2: Find and View Log Files

```bash
# List all log files
ls -lh *.log

# View last 20 lines of latest log
tail -n 20 app.log

# Monitor log in real-time
tail -f app.log
```

### Example 3: Backup Files

```bash
# Create backup directory
mkdir -p backups/$(date +%Y-%m-%d)

# Copy files to backup
cp -r data/ backups/$(date +%Y-%m-%d)/

# Verify backup
ls -lh backups/$(date +%Y-%m-%d)/
```

## Key Takeaways

- ✅ The terminal is a powerful text-based interface
- ✅ `pwd`, `cd`, `ls` are essential for navigation
- ✅ `cp`, `mv`, `rm` manage files (be careful with `rm -rf`!)
- ✅ `cat`, `less`, `head`, `tail` view file contents
- ✅ File permissions control access (read, write, execute)
- ✅ Tab completion and keyboard shortcuts save time
- ✅ Wildcards (`*`, `?`, `[]`) match multiple files

## Practice Exercises

Now complete the exercises in `exercise.sh` to practice these commands!

## Resources

- **Bash Manual**: https://www.gnu.org/software/bash/manual/
- **Linux Command Line Basics**: https://ubuntu.com/tutorials/command-line-for-beginners
- **Explain Shell**: https://explainshell.com/ (explains any command)
- **TLDR Pages**: https://tldr.sh/ (simplified man pages)

## Next Steps

After completing the exercises and quiz:
1. ✅ Complete `exercise.sh`
2. ✅ Check your solutions against `solution.sh`
3. ✅ Take the quiz in `quiz.md`
4. ✅ Move on to Day 2: Shell Scripting

---

**Ready to practice?** Open `exercise.sh` and start coding!
