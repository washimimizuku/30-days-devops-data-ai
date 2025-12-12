# Day 4: Process Management

**Duration**: 1 hour  
**Prerequisites**: Day 3 - Text Processing Tools

## Learning Objectives

By the end of this lesson, you will:
- Monitor running processes with ps, top, and htop
- Manage processes with kill and pkill
- Run background jobs and control them
- Use nohup and screen/tmux for persistent sessions
- Monitor system resources
- Manage long-running data processing jobs

## Core Concepts

### 1. Process Monitoring

#### ps - Process Status
```bash
# Basic process listing
ps                          # Current terminal processes
ps aux                      # All processes (detailed)
ps -ef                      # All processes (different format)

# Filtering processes
ps aux | grep python        # Find Python processes
ps -u username              # Processes by user
ps -C python                # Processes by command name

# Useful columns in ps aux:
# USER PID %CPU %MEM VSZ RSS TTY STAT START TIME COMMAND
```

#### top - Real-time Process Monitor
```bash
top                         # Interactive process monitor

# Key commands in top:
# q - quit
# k - kill process (enter PID)
# M - sort by memory usage
# P - sort by CPU usage
# 1 - show individual CPU cores
# h - help
```

#### htop - Enhanced Process Monitor
```bash
htop                        # Better interface than top

# Features:
# - Color-coded display
# - Mouse support
# - Tree view of processes
# - Easy process management
# - System resource graphs
```

### 2. Process Management

#### kill - Terminate Processes
```bash
# Send signals to processes
kill PID                    # SIGTERM (graceful shutdown)
kill -9 PID                 # SIGKILL (force kill)
kill -15 PID                # SIGTERM (same as default)
kill -STOP PID              # Pause process
kill -CONT PID              # Resume process

# Common signals:
# SIGTERM (15) - Graceful termination
# SIGKILL (9)  - Force kill (cannot be ignored)
# SIGSTOP (19) - Pause process
# SIGCONT (18) - Resume process
```

#### pkill - Kill by Process Name
```bash
pkill python                # Kill all Python processes
pkill -f "data_processor"   # Kill by command line pattern
pkill -u username           # Kill all processes by user
pkill -9 jupyter            # Force kill Jupyter processes
```

### 3. Background Jobs

#### Running Jobs in Background
```bash
# Start process in background
python long_script.py &     # & runs in background
nohup python script.py &    # Continues after logout

# Job control
jobs                        # List active jobs
bg %1                       # Send job 1 to background
fg %1                       # Bring job 1 to foreground
Ctrl+Z                      # Suspend current job
bg                          # Resume suspended job in background
```

#### Job Management
```bash
# Check job status
jobs -l                     # List with PIDs
jobs -r                     # Running jobs only
jobs -s                     # Stopped jobs only

# Control specific jobs
fg %2                       # Foreground job 2
kill %1                     # Kill job 1
disown %1                   # Remove from job table
```

### 4. Persistent Sessions

#### nohup - No Hangup
```bash
# Run command immune to hangups
nohup python data_pipeline.py > output.log 2>&1 &

# Redirect output
nohup command > /dev/null 2>&1 &    # Discard output
nohup command >> logfile.log 2>&1 & # Append to log
```

#### screen - Terminal Multiplexer
```bash
# Basic screen usage
screen                      # Start new session
screen -S session_name      # Named session
screen -ls                  # List sessions
screen -r session_name      # Reattach to session

# Inside screen:
# Ctrl+A, D - Detach session
# Ctrl+A, C - Create new window
# Ctrl+A, N - Next window
# Ctrl+A, P - Previous window
# Ctrl+A, K - Kill current window
```

#### tmux - Terminal Multiplexer (Modern)
```bash
# Basic tmux usage
tmux                        # Start new session
tmux new -s session_name    # Named session
tmux ls                     # List sessions
tmux attach -t session_name # Attach to session

# Inside tmux:
# Ctrl+B, D - Detach session
# Ctrl+B, C - Create new window
# Ctrl+B, N - Next window
# Ctrl+B, P - Previous window
# Ctrl+B, X - Kill current pane
```

### 5. System Resource Monitoring

#### Memory and CPU
```bash
# Memory usage
free -h                     # Human readable memory info
cat /proc/meminfo          # Detailed memory info

# CPU information
lscpu                      # CPU architecture info
cat /proc/cpuinfo          # Detailed CPU info
uptime                     # System load averages

# Disk usage
df -h                      # Disk space usage
du -sh directory/          # Directory size
iostat                     # I/O statistics
```

#### System Load
```bash
# Load averages (1min, 5min, 15min)
uptime
w                          # Who's logged in + load
cat /proc/loadavg          # Raw load average data

# Understanding load:
# Load = 1.0 means 100% CPU utilization
# Load > number of cores = system overloaded
```

## Data Processing Examples

### Long-Running Data Pipeline
```bash
#!/bin/bash
# data_pipeline.sh

echo "Starting data pipeline at $(date)"

# Process large dataset
python process_data.py input.csv > processed.csv 2> errors.log &
PROCESS_PID=$!

echo "Data processing started (PID: $PROCESS_PID)"

# Monitor progress
while kill -0 $PROCESS_PID 2>/dev/null; do
    echo "Still processing... $(date)"
    sleep 30
done

echo "Pipeline completed at $(date)"
```

### Resource Monitoring Script
```bash
#!/bin/bash
# monitor_resources.sh

LOG_FILE="resource_monitor.log"

while true; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    memory_usage=$(free | grep Mem | awk '{printf "%.1f", ($3/$2) * 100.0}')
    
    echo "$timestamp,CPU:${cpu_usage}%,Memory:${memory_usage}%" >> $LOG_FILE
    sleep 60
done
```

### Process Health Check
```bash
#!/bin/bash
# health_check.sh

check_process() {
    local process_name=$1
    local pid=$(pgrep -f "$process_name")
    
    if [ -n "$pid" ]; then
        echo "✓ $process_name is running (PID: $pid)"
        
        # Check resource usage
        local cpu=$(ps -p $pid -o %cpu --no-headers)
        local mem=$(ps -p $pid -o %mem --no-headers)
        echo "  CPU: ${cpu}%, Memory: ${mem}%"
    else
        echo "✗ $process_name is not running"
        return 1
    fi
}

# Check critical processes
check_process "data_pipeline"
check_process "jupyter"
check_process "database"
```

## Best Practices

### 1. Process Management
- Use `SIGTERM` before `SIGKILL` for graceful shutdown
- Monitor resource usage of long-running jobs
- Use process groups for related processes
- Set up proper logging for background jobs

### 2. Background Jobs
- Always redirect output when using `&`
- Use `nohup` for processes that must survive logout
- Consider using `screen` or `tmux` for interactive sessions
- Monitor job completion with scripts

### 3. Resource Monitoring
- Set up alerts for high CPU/memory usage
- Monitor disk space for log files
- Use `nice` to adjust process priority
- Consider `systemd` for production services

### 4. Data Processing Jobs
- Implement progress reporting
- Use checkpoints for resumable processing
- Monitor input/output file sizes
- Set up error handling and notifications

## Common Patterns

### Batch Job Management
```bash
# Start multiple background jobs
for file in *.csv; do
    python process_file.py "$file" > "${file%.csv}.log" 2>&1 &
done

# Wait for all jobs to complete
wait
echo "All processing complete"
```

### Resource-Aware Processing
```bash
# Check available memory before starting
available_mem=$(free -m | awk 'NR==2{print $7}')
if [ $available_mem -lt 1000 ]; then
    echo "Insufficient memory, waiting..."
    sleep 60
fi

# Start memory-intensive process
python memory_intensive_job.py
```

## Exercise

Complete the exercise in `exercise.sh` to practice process management with data processing scenarios.

## Quiz

Test your knowledge with `quiz.md`.

## Next Steps

Tomorrow we'll learn about environment variables and PATH configuration to customize your development environment.
