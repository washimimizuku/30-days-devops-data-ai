# Developer Tools Cheatsheet

Quick reference for all tools covered in the bootcamp.

## Command Line Basics

### Navigation
```bash
pwd                     # Print working directory
cd directory            # Change directory
cd ..                   # Go up one level
cd ~                    # Go to home directory
cd -                    # Go to previous directory
ls                      # List files
ls -la                  # List all files (detailed)
```

### File Operations
```bash
touch file.txt          # Create empty file
mkdir directory         # Create directory
mkdir -p path/to/dir    # Create nested directories
cp source dest          # Copy file
cp -r source dest       # Copy directory recursively
mv source dest          # Move/rename
rm file                 # Remove file
rm -r directory         # Remove directory recursively
rm -rf directory        # Force remove (be careful!)
```

### Viewing Files
```bash
cat file.txt            # Display entire file
less file.txt           # View file (paginated)
head file.txt           # First 10 lines
head -n 20 file.txt     # First 20 lines
tail file.txt           # Last 10 lines
tail -f file.log        # Follow file (live updates)
```

### File Permissions
```bash
chmod +x script.sh      # Make executable
chmod 755 script.sh     # rwxr-xr-x
chmod 644 file.txt      # rw-r--r--
chown user:group file   # Change owner
```

## Text Processing

### grep - Search
```bash
grep "pattern" file.txt                 # Search in file
grep -r "pattern" directory/            # Recursive search
grep -i "pattern" file.txt              # Case insensitive
grep -v "pattern" file.txt              # Invert match
grep -n "pattern" file.txt              # Show line numbers
grep -E "regex" file.txt                # Extended regex
```

### sed - Stream Editor
```bash
sed 's/old/new/' file.txt               # Replace first occurrence
sed 's/old/new/g' file.txt              # Replace all occurrences
sed -i 's/old/new/g' file.txt           # Edit file in-place
sed -n '10,20p' file.txt                # Print lines 10-20
sed '/pattern/d' file.txt               # Delete matching lines
```

### awk - Text Processing
```bash
awk '{print $1}' file.txt               # Print first column
awk -F',' '{print $1,$3}' file.csv      # CSV: print columns 1,3
awk '$3 > 100' file.txt                 # Filter rows
awk '{sum+=$1} END {print sum}' file    # Sum column
```

### jq - JSON Processing
```bash
jq '.' file.json                        # Pretty print
jq '.key' file.json                     # Extract key
jq '.[] | .name' file.json              # Extract from array
jq 'select(.age > 30)' file.json        # Filter
jq -r '.name' file.json                 # Raw output (no quotes)
```

### csvkit - CSV Tools
```bash
csvlook file.csv                        # Pretty print CSV
csvcut -c 1,3 file.csv                  # Select columns
csvgrep -c name -m "John" file.csv      # Filter rows
csvstat file.csv                        # Statistics
csvsql --query "SELECT * FROM file"     # SQL on CSV
```

## Process Management

```bash
ps aux                  # List all processes
ps aux | grep python    # Find Python processes
top                     # Interactive process viewer
htop                    # Better process viewer
kill PID                # Kill process by ID
kill -9 PID             # Force kill
pkill python            # Kill by name
jobs                    # List background jobs
bg                      # Resume job in background
fg                      # Bring job to foreground
command &               # Run in background
nohup command &         # Run immune to hangups
```

## Environment Variables

```bash
export VAR="value"      # Set variable
echo $VAR               # Print variable
printenv                # List all variables
env                     # List all variables
unset VAR               # Remove variable
export PATH=$PATH:/new  # Add to PATH
```

### Shell Configuration
```bash
~/.bashrc               # Bash configuration
~/.zshrc                # Zsh configuration
~/.bash_profile         # Bash login shell
source ~/.bashrc        # Reload configuration
```

## Git Commands

### Basics
```bash
git init                        # Initialize repository
git clone url                   # Clone repository
git status                      # Check status
git add file                    # Stage file
git add .                       # Stage all changes
git commit -m "message"         # Commit changes
git log                         # View history
git log --oneline               # Compact history
git diff                        # Show changes
```

### Branching
```bash
git branch                      # List branches
git branch name                 # Create branch
git checkout name               # Switch branch
git switch name                 # Switch branch (newer)
git checkout -b name            # Create and switch
git merge branch                # Merge branch
git branch -d name              # Delete branch
```

### Remote
```bash
git remote -v                   # List remotes
git remote add origin url       # Add remote
git push origin main            # Push to remote
git pull origin main            # Pull from remote
git fetch                       # Fetch changes
git clone url                   # Clone repository
```

### Advanced
```bash
git stash                       # Stash changes
git stash pop                   # Apply stashed changes
git rebase main                 # Rebase onto main
git cherry-pick commit          # Apply specific commit
git reset --hard HEAD           # Discard all changes
git revert commit               # Revert commit
```

## Docker Commands

### Container Basics
```bash
docker run image                # Run container
docker run -it image bash       # Interactive shell
docker run -d image             # Run in background
docker ps                       # List running containers
docker ps -a                    # List all containers
docker stop container           # Stop container
docker start container          # Start container
docker rm container             # Remove container
docker logs container           # View logs
docker exec -it container bash  # Execute command
```

### Image Management
```bash
docker images                   # List images
docker pull image               # Download image
docker build -t name .          # Build image
docker tag image new-name       # Tag image
docker push image               # Push to registry
docker rmi image                # Remove image
docker system prune             # Clean up
```

### Docker Compose
```bash
docker-compose up               # Start services
docker-compose up -d            # Start in background
docker-compose down             # Stop services
docker-compose ps               # List services
docker-compose logs             # View logs
docker-compose exec service sh  # Execute command
docker-compose build            # Build images
```

## Python Tools

### Virtual Environments
```bash
python3 -m venv venv            # Create venv
source venv/bin/activate        # Activate (Mac/Linux)
venv\Scripts\activate           # Activate (Windows)
deactivate                      # Deactivate
```

### Package Management
```bash
pip install package             # Install package
pip install -r requirements.txt # Install from file
pip freeze > requirements.txt   # Export packages
pip list                        # List packages
pip show package                # Package info
pip uninstall package           # Uninstall
```

### Poetry
```bash
poetry init                     # Initialize project
poetry add package              # Add dependency
poetry install                  # Install dependencies
poetry shell                    # Activate venv
poetry run python script.py     # Run in venv
```

### Testing
```bash
pytest                          # Run all tests
pytest test_file.py             # Run specific file
pytest -v                       # Verbose output
pytest -k "test_name"           # Run matching tests
pytest --cov                    # Coverage report
```

## AWS CLI

### S3
```bash
aws s3 ls                       # List buckets
aws s3 ls s3://bucket/          # List objects
aws s3 cp file s3://bucket/     # Upload file
aws s3 cp s3://bucket/file .    # Download file
aws s3 sync dir s3://bucket/    # Sync directory
aws s3 rm s3://bucket/file      # Delete file
```

### EC2
```bash
aws ec2 describe-instances      # List instances
aws ec2 start-instances --ids   # Start instance
aws ec2 stop-instances --ids    # Stop instance
```

### Configuration
```bash
aws configure                   # Configure credentials
aws configure list              # Show configuration
aws sts get-caller-identity     # Verify credentials
```

## API Testing

### curl
```bash
curl url                        # GET request
curl -X POST url                # POST request
curl -H "Header: value" url     # Add header
curl -d "data" url              # Send data
curl -o file url                # Save to file
curl -i url                     # Include headers
curl -u user:pass url           # Basic auth
```

### httpie
```bash
http url                        # GET request
http POST url                   # POST request
http url key=value              # Query params
http POST url key=value         # JSON body
http -a user:pass url           # Basic auth
http -f POST url file@path      # Upload file
```

## Debugging

### Python Debugger
```python
import pdb; pdb.set_trace()     # Set breakpoint
import ipdb; ipdb.set_trace()   # IPython debugger

# Debugger commands:
# n - next line
# s - step into
# c - continue
# l - list code
# p var - print variable
# q - quit
```

### Profiling
```bash
python -m cProfile script.py    # Profile script
python -m memory_profiler script.py  # Memory profile
```

## Make

```makefile
# Makefile syntax
target: dependencies
	command

.PHONY: target              # Phony target (not a file)

# Variables
VAR = value
$(VAR)                      # Use variable

# Common targets
all: build test             # Default target
clean:                      # Clean build artifacts
	rm -rf build/
install:                    # Install dependencies
	pip install -r requirements.txt
test:                       # Run tests
	pytest
```

## Keyboard Shortcuts

### Terminal
```
Ctrl+C          # Kill current process
Ctrl+Z          # Suspend process
Ctrl+D          # Exit shell / EOF
Ctrl+L          # Clear screen
Ctrl+A          # Beginning of line
Ctrl+E          # End of line
Ctrl+U          # Delete to beginning
Ctrl+K          # Delete to end
Ctrl+R          # Search history
Tab             # Auto-complete
```

### Vim (if using)
```
i               # Insert mode
Esc             # Normal mode
:w              # Save
:q              # Quit
:wq             # Save and quit
:q!             # Quit without saving
dd              # Delete line
yy              # Copy line
p               # Paste
/pattern        # Search
```

## Common Patterns

### Pipelines
```bash
# Chain commands
cat file | grep pattern | sort | uniq

# Count lines
wc -l file.txt

# Find and process
find . -name "*.txt" -exec grep "pattern" {} \;

# Process CSV
cat data.csv | csvcut -c 1,3 | csvgrep -c 1 -m "value"
```

### Loops
```bash
# For loop
for file in *.txt; do
    echo "Processing $file"
    cat "$file"
done

# While loop
while read line; do
    echo "$line"
done < file.txt
```

### Conditionals
```bash
# If statement
if [ -f file.txt ]; then
    echo "File exists"
else
    echo "File not found"
fi

# Test operators
-f file         # File exists
-d dir          # Directory exists
-z string       # String is empty
-n string       # String is not empty
$a -eq $b       # Numbers equal
$a -ne $b       # Numbers not equal
```

## Tips

- Use `man command` for detailed documentation
- Use `command --help` for quick help
- Use `tldr command` for simplified examples
- Use `history` to see command history
- Use `!!` to repeat last command
- Use `!$` for last argument of previous command
- Use `Ctrl+R` to search command history
- Use tab completion to save typing
- Use aliases for common commands: `alias ll='ls -la'`

## Resources

- **Bash**: https://www.gnu.org/software/bash/manual/
- **Git**: https://git-scm.com/doc
- **Docker**: https://docs.docker.com/
- **AWS CLI**: https://docs.aws.amazon.com/cli/
- **jq**: https://stedolan.github.io/jq/manual/
- **Python**: https://docs.python.org/3/

---

**Pro Tip**: Keep this cheatsheet open while working through the bootcamp!
