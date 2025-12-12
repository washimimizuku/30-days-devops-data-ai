#!/bin/bash

# Day 4: Process Management - Exercise
# Practice monitoring and managing processes for data workflows

echo "=== Day 4: Process Management Exercise ==="
echo

# Create test environment
mkdir -p process_lab
cd process_lab

echo "Creating sample data processing scripts..."

# Create a long-running data processor
cat > data_processor.py << 'EOF'
#!/usr/bin/env python3
import time
import sys
import random

def process_data(duration=60):
    print(f"Starting data processing for {duration} seconds...")
    
    for i in range(duration):
        # Simulate data processing
        time.sleep(1)
        
        # Simulate progress
        if i % 10 == 0:
            progress = (i / duration) * 100
            print(f"Progress: {progress:.1f}% - Processing record {i*100}")
        
        # Simulate occasional errors
        if random.random() < 0.05:
            print(f"Warning: Slow processing at record {i*100}", file=sys.stderr)
    
    print("Data processing completed successfully!")

if __name__ == "__main__":
    duration = int(sys.argv[1]) if len(sys.argv) > 1 else 60
    process_data(duration)
EOF

chmod +x data_processor.py

# Create a memory-intensive script
cat > memory_test.py << 'EOF'
#!/usr/bin/env python3
import time
import sys

def consume_memory(mb=100):
    print(f"Consuming {mb}MB of memory...")
    
    # Allocate memory
    data = []
    for i in range(mb):
        # Allocate 1MB chunks
        chunk = 'x' * (1024 * 1024)
        data.append(chunk)
        
        if i % 10 == 0:
            print(f"Allocated {i}MB...")
        
        time.sleep(0.1)
    
    print(f"Memory allocated. Holding for 30 seconds...")
    time.sleep(30)
    print("Memory test completed")

if __name__ == "__main__":
    mb = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    consume_memory(mb)
EOF

chmod +x memory_test.py

# Create a CPU-intensive script
cat > cpu_test.py << 'EOF'
#!/usr/bin/env python3
import time
import math

def cpu_intensive_task(duration=30):
    print(f"Starting CPU-intensive task for {duration} seconds...")
    
    start_time = time.time()
    counter = 0
    
    while time.time() - start_time < duration:
        # CPU-intensive calculation
        result = math.sqrt(counter * math.pi)
        counter += 1
        
        # Progress update every 5 seconds
        elapsed = time.time() - start_time
        if int(elapsed) % 5 == 0 and elapsed > 0:
            print(f"CPU task running... {elapsed:.0f}s elapsed, {counter} calculations")
            time.sleep(1)  # Prevent spam
    
    print(f"CPU task completed. Performed {counter} calculations.")

if __name__ == "__main__":
    duration = int(sys.argv[1]) if len(sys.argv) > 1 else 30
    cpu_intensive_task(duration)
EOF

chmod +x cpu_test.py

echo "Sample scripts created!"
echo

# Exercise 1: Process Monitoring
echo "=== Exercise 1: Process Monitoring ==="
echo "TODO: Learn to monitor processes with ps, top, and system commands"
echo

echo "1.1 Current processes in this terminal:"
ps

echo
echo "1.2 Find all Python processes:"
# Your code here:
ps aux | grep python | grep -v grep

echo
echo "1.3 Show processes sorted by memory usage (top 5):"
# Your code here:
ps aux --sort=-%mem | head -6

echo
echo "1.4 System resource summary:"
echo "Memory usage:"
free -h
echo
echo "CPU information:"
lscpu | grep -E "(Model name|CPU\(s\)|Thread)"
echo
echo "System load:"
uptime

echo

# Exercise 2: Background Jobs
echo "=== Exercise 2: Background Jobs ==="
echo "TODO: Practice running and managing background processes"
echo

echo "2.1 Starting a long-running process in background:"
# Your code here:
python3 data_processor.py 30 > processor.log 2>&1 &
PROCESSOR_PID=$!
echo "Started data processor with PID: $PROCESSOR_PID"

echo
echo "2.2 Check active jobs:"
# Your code here:
jobs -l

echo
echo "2.3 Start another background process:"
# Your code here:
python3 cpu_test.py 20 > cpu_test.log 2>&1 &
CPU_PID=$!
echo "Started CPU test with PID: $CPU_PID"

echo
echo "2.4 Monitor both processes:"
echo "Active jobs:"
jobs
echo
echo "Process details:"
ps -p $PROCESSOR_PID,$CPU_PID -o pid,ppid,%cpu,%mem,time,cmd 2>/dev/null || echo "Some processes may have completed"

echo

# Exercise 3: Process Control
echo "=== Exercise 3: Process Control ==="
echo "TODO: Practice controlling running processes"
echo

echo "3.1 Start a process we can control:"
# Your code here:
python3 memory_test.py 50 > memory_test.log 2>&1 &
MEMORY_PID=$!
echo "Started memory test with PID: $MEMORY_PID"

sleep 2
echo
echo "3.2 Check if process is running:"
# Your code here:
if kill -0 $MEMORY_PID 2>/dev/null; then
    echo "✓ Process $MEMORY_PID is running"
    ps -p $MEMORY_PID -o pid,%cpu,%mem,cmd
else
    echo "✗ Process $MEMORY_PID is not running"
fi

echo
echo "3.3 Send STOP signal (pause process):"
# Your code here:
if kill -0 $MEMORY_PID 2>/dev/null; then
    kill -STOP $MEMORY_PID
    echo "Process $MEMORY_PID paused"
    sleep 2
    
    echo "Process status after STOP:"
    ps -p $MEMORY_PID -o pid,stat,cmd 2>/dev/null || echo "Process not found"
fi

echo
echo "3.4 Send CONT signal (resume process):"
# Your code here:
if kill -0 $MEMORY_PID 2>/dev/null; then
    kill -CONT $MEMORY_PID
    echo "Process $MEMORY_PID resumed"
    sleep 2
    
    echo "Process status after CONT:"
    ps -p $MEMORY_PID -o pid,stat,cmd 2>/dev/null || echo "Process not found"
fi

echo

# Exercise 4: Resource Monitoring
echo "=== Exercise 4: Resource Monitoring ==="
echo "TODO: Monitor system resources during process execution"
echo

echo "4.1 Create a resource monitoring function:"
# Your code here:
monitor_resources() {
    local duration=${1:-10}
    local interval=${2:-2}
    local log_file="resource_monitor.log"
    
    echo "Monitoring resources for ${duration}s (interval: ${interval}s)"
    echo "timestamp,cpu_usage,memory_usage,load_avg" > $log_file
    
    local end_time=$(($(date +%s) + duration))
    
    while [ $(date +%s) -lt $end_time ]; do
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Get CPU usage (approximate)
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "0")
        
        # Get memory usage percentage
        local memory_usage=$(free | grep Mem | awk '{printf "%.1f", ($3/$2) * 100.0}')
        
        # Get load average
        local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
        
        echo "$timestamp,$cpu_usage,$memory_usage,$load_avg" >> $log_file
        echo "[$timestamp] CPU: ${cpu_usage}%, Memory: ${memory_usage}%, Load: ${load_avg}"
        
        sleep $interval
    done
    
    echo "Resource monitoring complete. Log saved to $log_file"
}

echo "4.2 Start resource monitoring:"
monitor_resources 15 3 &
MONITOR_PID=$!

echo
echo "4.3 Start a resource-intensive process during monitoring:"
# Your code here:
python3 cpu_test.py 10 > intensive_cpu.log 2>&1 &
INTENSIVE_PID=$!

# Wait for monitoring to complete
wait $MONITOR_PID

echo
echo "4.4 Resource monitoring results:"
if [ -f "resource_monitor.log" ]; then
    echo "Resource usage during test:"
    cat resource_monitor.log
fi

echo

# Exercise 5: Process Health Checking
echo "=== Exercise 5: Process Health Checking ==="
echo "TODO: Create scripts to monitor process health"
echo

echo "5.1 Create a process health checker:"
# Your code here:
check_process_health() {
    local process_pattern=$1
    local max_cpu=${2:-80}
    local max_memory=${3:-80}
    
    echo "Checking health for processes matching: $process_pattern"
    
    # Find processes
    local pids=$(pgrep -f "$process_pattern")
    
    if [ -z "$pids" ]; then
        echo "❌ No processes found matching '$process_pattern'"
        return 1
    fi
    
    for pid in $pids; do
        # Get process info
        local cmd=$(ps -p $pid -o cmd --no-headers 2>/dev/null)
        local cpu=$(ps -p $pid -o %cpu --no-headers 2>/dev/null)
        local mem=$(ps -p $pid -o %mem --no-headers 2>/dev/null)
        
        if [ -n "$cmd" ]; then
            echo "Process PID $pid: $cmd"
            
            # Check CPU usage
            local cpu_int=$(echo "$cpu" | cut -d'.' -f1)
            if [ "$cpu_int" -gt "$max_cpu" ]; then
                echo "  ⚠️  High CPU usage: ${cpu}%"
            else
                echo "  ✅ CPU usage OK: ${cpu}%"
            fi
            
            # Check memory usage
            local mem_int=$(echo "$mem" | cut -d'.' -f1)
            if [ "$mem_int" -gt "$max_memory" ]; then
                echo "  ⚠️  High memory usage: ${mem}%"
            else
                echo "  ✅ Memory usage OK: ${mem}%"
            fi
        fi
    done
}

echo "5.2 Test health checker with current Python processes:"
check_process_health "python"

echo

# Exercise 6: Job Management Pipeline
echo "=== Exercise 6: Job Management Pipeline ==="
echo "TODO: Create a pipeline that manages multiple data processing jobs"
echo

echo "6.1 Create a job manager script:"
# Your code here:
cat > job_manager.sh << 'JOBEOF'
#!/bin/bash

# Job manager for data processing pipeline
JOB_LOG="job_manager.log"
PID_FILE="job_pids.txt"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $JOB_LOG
}

start_job() {
    local job_name=$1
    local command=$2
    
    log_message "Starting job: $job_name"
    
    # Start job in background
    eval "$command" > "${job_name}.log" 2>&1 &
    local pid=$!
    
    # Record PID
    echo "$job_name:$pid" >> $PID_FILE
    
    log_message "Job $job_name started with PID $pid"
    return $pid
}

check_jobs() {
    log_message "Checking job status..."
    
    if [ ! -f "$PID_FILE" ]; then
        log_message "No active jobs found"
        return
    fi
    
    while IFS=':' read -r job_name pid; do
        if kill -0 $pid 2>/dev/null; then
            log_message "Job $job_name (PID $pid) is running"
        else
            log_message "Job $job_name (PID $pid) has completed"
        fi
    done < $PID_FILE
}

wait_for_jobs() {
    log_message "Waiting for all jobs to complete..."
    
    if [ ! -f "$PID_FILE" ]; then
        return
    fi
    
    while IFS=':' read -r job_name pid; do
        if kill -0 $pid 2>/dev/null; then
            log_message "Waiting for job $job_name (PID $pid)..."
            wait $pid
            log_message "Job $job_name completed"
        fi
    done < $PID_FILE
    
    # Clean up
    rm -f $PID_FILE
    log_message "All jobs completed"
}

# Main execution
case "${1:-start}" in
    "start")
        log_message "=== Starting Data Processing Pipeline ==="
        
        # Start multiple jobs
        start_job "data_proc_1" "python3 data_processor.py 20"
        start_job "cpu_task_1" "python3 cpu_test.py 15"
        start_job "memory_task_1" "python3 memory_test.py 30"
        
        log_message "All jobs started"
        ;;
    "status")
        check_jobs
        ;;
    "wait")
        wait_for_jobs
        ;;
    *)
        echo "Usage: $0 {start|status|wait}"
        exit 1
        ;;
esac
JOBEOF

chmod +x job_manager.sh

echo "6.2 Start the job pipeline:"
./job_manager.sh start

echo
echo "6.3 Check job status:"
sleep 3
./job_manager.sh status

echo
echo "6.4 Monitor jobs until completion:"
./job_manager.sh wait

echo

# Cleanup running processes
echo "=== Cleaning up any remaining processes ==="
# Kill any remaining test processes
pkill -f "data_processor.py" 2>/dev/null
pkill -f "cpu_test.py" 2>/dev/null  
pkill -f "memory_test.py" 2>/dev/null

# Wait a moment for cleanup
sleep 2

cd ..

echo "=== Exercise Complete ==="
echo
echo "You've practiced:"
echo "✓ Process monitoring with ps and system commands"
echo "✓ Running and managing background jobs"
echo "✓ Process control with signals (STOP, CONT, TERM)"
echo "✓ Resource monitoring and logging"
echo "✓ Process health checking"
echo "✓ Job pipeline management"
echo
echo "Next: Run 'bash solution.sh' to see advanced process management techniques"
echo "Then: Complete the quiz in quiz.md"
