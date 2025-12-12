# Day 1: Terminal Basics - Quiz

Test your understanding of terminal basics!

## Instructions

- Answer each question
- Check your answers at the bottom
- Review concepts you missed

---

## Questions

### Question 1: Navigation

What command shows your current directory location?

A) `cd`  
B) `ls`  
C) `pwd`  
D) `dir`

### Question 2: Listing Files

Which command shows hidden files (files starting with `.`)?

A) `ls`  
B) `ls -l`  
C) `ls -a`  
D) `ls -h`

### Question 3: Creating Directories

How do you create nested directories in one command?

A) `mkdir path/to/dir`  
B) `mkdir -p path/to/dir`  
C) `mkdir -r path/to/dir`  
D) `mkdir --nested path/to/dir`

### Question 4: File Operations

What's the difference between `cp` and `mv`?

A) `cp` is faster than `mv`  
B) `cp` copies files, `mv` moves/renames them  
C) `cp` works on directories, `mv` works on files  
D) There is no difference

### Question 5: Viewing Files

Which command is best for viewing a large log file that's constantly being updated?

A) `cat logfile.log`  
B) `less logfile.log`  
C) `head logfile.log`  
D) `tail -f logfile.log`

### Question 6: File Permissions

What does `chmod +x script.sh` do?

A) Makes the file readable  
B) Makes the file writable  
C) Makes the file executable  
D) Deletes the file

### Question 7: Wildcards

What does `*.txt` match?

A) Only files named "txt"  
B) All files ending with .txt  
C) All files starting with .txt  
D) All text files in subdirectories

### Question 8: Dangerous Commands

Which command is most dangerous and should be used carefully?

A) `ls -la`  
B) `cd ..`  
C) `rm -rf`  
D) `pwd`

### Question 9: File Viewing

What's the difference between `head` and `tail`?

A) `head` shows the beginning, `tail` shows the end  
B) `head` is faster than `tail`  
C) `head` works on text files, `tail` works on binary files  
D) There is no difference

### Question 10: Keyboard Shortcuts

What does `Ctrl+C` do in the terminal?

A) Copy text  
B) Clear the screen  
C) Cancel the current command  
D) Close the terminal

---

## Short Answer Questions

### Question 11

Write a command to create a directory called "data" with subdirectories "raw" and "processed" in one command.

Your answer:
```bash

```

### Question 12

Write a command to list all `.csv` files in the current directory, showing detailed information including file sizes.

Your answer:
```bash

```

### Question 13

Write a command to view the last 20 lines of a file called `app.log`.

Your answer:
```bash

```

### Question 14

Write a command to copy all `.txt` files from the current directory to a directory called `backup/`.

Your answer:
```bash

```

### Question 15

Write a command to make a script called `deploy.sh` executable.

Your answer:
```bash

```

---

## Practical Scenario

### Question 16

You need to:
1. Create a project directory structure: `project/src`, `project/tests`, `project/docs`
2. Create an empty file `project/README.md`
3. Make a script `project/src/run.sh` executable
4. List all files in the project directory recursively

Write the commands:

```bash
# Step 1:


# Step 2:


# Step 3:


# Step 4:


```

---

## Answers

### Multiple Choice Answers

1. **C** - `pwd` (Print Working Directory)
2. **C** - `ls -a` (shows all files including hidden)
3. **B** - `mkdir -p path/to/dir` (creates parent directories as needed)
4. **B** - `cp` copies files, `mv` moves/renames them
5. **D** - `tail -f logfile.log` (follows file updates in real-time)
6. **C** - Makes the file executable
7. **B** - All files ending with .txt
8. **C** - `rm -rf` (removes files/directories without confirmation)
9. **A** - `head` shows beginning, `tail` shows end
10. **C** - Cancel the current command

### Short Answer Answers

**Question 11:**
```bash
mkdir -p data/raw data/processed
# or
mkdir -p data/{raw,processed}
```

**Question 12:**
```bash
ls -lh *.csv
```

**Question 13:**
```bash
tail -n 20 app.log
# or
tail -20 app.log
```

**Question 14:**
```bash
cp *.txt backup/
```

**Question 15:**
```bash
chmod +x deploy.sh
```

### Practical Scenario Answer

**Question 16:**
```bash
# Step 1: Create directory structure
mkdir -p project/{src,tests,docs}

# Step 2: Create README
touch project/README.md

# Step 3: Create and make script executable
touch project/src/run.sh
chmod +x project/src/run.sh

# Step 4: List recursively
ls -R project/
# or
find project/ -type f
```

---

## Scoring

- **15-16 correct**: Excellent! You've mastered terminal basics
- **12-14 correct**: Good job! Review the concepts you missed
- **9-11 correct**: Not bad! Spend more time practicing
- **Below 9**: Review the lesson and try the exercises again

---

## What to Review

If you missed questions about:

- **Navigation** (Q1, Q2): Review `pwd`, `cd`, `ls` commands
- **File Operations** (Q3, Q4, Q14): Review `mkdir`, `cp`, `mv` commands
- **Viewing Files** (Q5, Q9, Q13): Review `cat`, `head`, `tail`, `less`
- **Permissions** (Q6, Q15): Review `chmod` command
- **Wildcards** (Q7, Q12): Review pattern matching with `*`, `?`, `[]`
- **Safety** (Q8): Review dangerous commands and best practices
- **Shortcuts** (Q10): Review keyboard shortcuts

---

**Ready for Day 2?** Move on to Shell Scripting!
