#!/bin/bash

# Day 4: Process Management - Solutions
# Advanced process management techniques for data workflows

echo "=== Day 4: Process Management Solutions ==="
echo

# Create advanced test environment
mkdir -p advanced_process_lab
cd advanced_process_lab

echo "Creating advanced process management tools..."

# Create a sophisticated data pipeline simulator
cat > pipeline_simulator.py << 'EOF'
#!/usr/bin/env python3
import time
import sys
import os
import signal
import json
from datetime import datetime

class DataPipeline:
    def __init__(self, name, duration=60, cpu_intensive=False, memory_intensive=False):
        self.name = name
        self.duration = duration
        self.cpu_intensive = cpu_intensive
        self.memory_intensive = memory_intensive
        self.start_time = time.time()
        self.status_file = f"{name}_status.json"
        
        # Set up signal handlers
        signal.signal(signal.SIGTERM, self.graceful_shutdown)
        signal.signal(signal.SIGINT, self.graceful_shutdown)
        
    def graceful_shutdown(self, signum, frame):
        print(f"\n{self.name}: Received signal {signum}, shutting down gracefully...")
        self.save_status("interrupted")
        sys.exit(0)
        
    def save_status(self, status):
        data = {
            "name": self.name,
            "status": status,
            "start_time": self.start_time,
            "current_time": time.time(),
            "elapsed": time.time() - self.start_time,
            "pid": os.getpid()
        }
        with open(self.status_file, 'w') as f:
            json.dump(data, f, indent=2)
    
    def run(self):
        print(f"Starting pipeline: {self.name} (PID: {os.getpid()})")
        self.save_status("running")
        
        memory_data = []
        
        for i in range(self.duration):
            # Simulate different types of work
            if self.cpu_intensive:
                # CPU-intensive calculation
                result = sum(x**2 for x in range(1000))
            
            if self.memory_intensive:
                # Allocate some memory
                chunk = 'x' * (1024 * 100)  # 100KB chunks
                memory_data.append(chunk)
            
            # Progress reporting
            if i % 10 == 0:
                progress = (i / self.duration) * 100
                print(f"{self.name}: {progress:.1f}% complete - Processing batch {i}")
                self.save_status(f"running_{progress:.1f}%")
            
            time.sleep(1)
        
        print(f"{self.name}: Pipeline completed successfully!")
        self.save_status("completed")

if __name__ == "__main__":
    name = sys.argv[1] if len(sys.argv) > 1 else "default_pipeline"
    duration = int(sys.argv[2]) if len(sys.argv) > 2 else 30
    cpu_intensive = "--cpu" in sys.argv
    memory_intensive = "--memory" in sys.argv
    
    pipeline = DataPipeline(name, duration, cpu_intensive, memory_intensive)
    pipeline.run()
EOF

chmod +x pipeline_simulator.py

echo "=== Solution 1: Advanced Process Monitoring ==="

echo "1.1 Comprehensive process monitoring function:"
monitor_processes() {
    local pattern=${1:-"python"}
    local duration=${2:-30}
    local interval=${3:-5}
    
    echo "=== Process Monitoring Report ==="
    echo "Pattern: $pattern"
    echo "Duration: ${duration}s"
    echo "Interval: ${interval}s"
    echo "Started: $(date)"
    echo
    
    local end_time=$(($(date +%s) + duration))
    local report_file="process_monitor_$(date +%s).log"
    
    # Header for CSV log
    echo "timestamp,pid,cpu_percent,memory_percent,memory_rss_mb,command" > $report_file
    
    while [ $(date +%s) -lt $end_time ]; do
        echo "--- $(date '+%H:%M:%S') ---"
        
        # Find matching processes
        local pids=$(pgrep -f "$pattern")
        
        if [ -n "$pids" ]; then
            printf "%-8s %-8s %-8s %-10s %-12s %s\n" "PID" "CPU%" "MEM%" "RSS(MB)" "STATUS" "COMMAND"
            
            for pid in $pids; do
                # Get detailed process information
                local ps_info=$(ps -p $pid -o pid,%cpu,%mem,rss,stat,cmd --no-headers 2>/dev/null)
                
                if [ -n "$ps_info" ]; then
                    local cpu=$(echo "$ps_info" | awk '{print $2}')
                    local mem=$(echo "$ps_info" | awk '{print $3}')
                    local rss=$(echo "$ps_info" | awk '{print $4}')
                    local stat=$(echo "$ps_info" | awk '{print $5}')
                    local cmd=$(echo "$ps_info" | awk '{for(i=6;i<=NF;i++) printf "%s ", $i; print ""}')
                    
                    # Convert RSS to MB
                    local rss_mb=$((rss / 1024))
                    
                    printf "%-8s %-8s %-8s %-10s %-12s %s\n" "$pid" "$cpu" "$mem" "$rss_mb" "$stat" "$cmd"
                    
                    # Log to CSV
                    echo "$(date '+%Y-%m-%d %H:%M:%S'),$pid,$cpu,$mem,$rss_mb,\"$cmd\"" >> $report_file
                fi
            done
        else
            echo "No processes found matching '$pattern'"
        fi
        
        echo
        sleep $interval
    done
    
    echo "Monitoring complete. Detailed log saved to: $report_file"
}

echo "1.2 System resource dashboard:"
system_dashboard() {
    local duration=${1:-20}
    local interval=${2:-3}
    
    echo "=== System Resource Dashboard ==="
    
    local end_time=$(($(date +%s) + duration))
    
    while [ $(date +%s) -lt $end_time ]; do
        clear
        echo "=== System Dashboard - $(date) ==="
        echo
        
        # CPU Information
        echo "🖥️  CPU Usage:"
        if command -v top >/dev/null; then
            top -bn1 | grep "Cpu(s)" | head -1
        fi
        echo
        
        # Memory Information
        echo "💾 Memory Usage:"
        free -h | grep -E "(Mem|Swap)"
        echo
        
        # Load Average
        echo "⚡ System Load:"
        uptime
        echo
        
        # Disk Usage
        echo "💿 Disk Usage:"
        df -h | grep -E "(Filesystem|/dev/)"
        echo
        
        # Top Processes by CPU
        echo "🔥 Top CPU Processes:"
        ps aux --sort=-%cpu | head -6 | awk 'NR==1 || NR<=6 {printf "%-10s %-6s %-6s %s\n", $1, $3"%", $4"%", $11}'
        echo
        
        # Top Processes by Memory
        echo "🧠 Top Memory Processes:"
        ps aux --sort=-%mem | head -6 | awk 'NR==1 || NR<=6 {printf "%-10s %-6s %-6s %s\n", $1, $3"%", $4"%", $11}'
        
        sleep $interval
    done
}

echo "Starting system dashboard for 15 seconds..."
system_dashboard 15 3 &
DASHBOARD_PID=$!

echo

echo "=== Solution 2: Advanced Job Management ==="

echo "2.1 Sophisticated job scheduler:"
cat > job_scheduler.sh << 'SCHEDEOF'
#!/bin/bash

# Advanced job scheduler for data pipelines
SCHEDULER_DIR="scheduler_data"
JOB_QUEUE="$SCHEDULER_DIR/job_queue.txt"
ACTIVE_JOBS="$SCHEDULER_DIR/active_jobs.txt"
JOB_HISTORY="$SCHEDULER_DIR/job_history.txt"
MAX_CONCURRENT_JOBS=3

# Initialize scheduler
init_scheduler() {
    mkdir -p "$SCHEDULER_DIR"
    touch "$JOB_QUEUE" "$ACTIVE_JOBS" "$JOB_HISTORY"
    echo "[$(date)] Scheduler initialized" >> "$JOB_HISTORY"
}

# Add job to queue
add_job() {
    local job_name=$1
    local command=$2
    local priority=${3:-5}
    
    echo "$priority:$job_name:$command" >> "$JOB_QUEUE"
    echo "[$(date)] Job added: $job_name (priority: $priority)" >> "$JOB_HISTORY"
    echo "Job '$job_name' added to queue with priority $priority"
}

# Start next job from queue
start_next_job() {
    # Check if we can start more jobs
    local active_count=$(wc -l < "$ACTIVE_JOBS" 2>/dev/null || echo "0")
    
    if [ "$active_count" -ge "$MAX_CONCURRENT_JOBS" ]; then
        return 1
    fi
    
    # Get highest priority job
    if [ ! -s "$JOB_QUEUE" ]; then
        return 1
    fi
    
    local job_line=$(sort -nr "$JOB_QUEUE" | head -1)
    local priority=$(echo "$job_line" | cut -d':' -f1)
    local job_name=$(echo "$job_line" | cut -d':' -f2)
    local command=$(echo "$job_line" | cut -d':' -f3-)
    
    # Remove from queue
    grep -v "^$job_line$" "$JOB_QUEUE" > "$JOB_QUEUE.tmp" && mv "$JOB_QUEUE.tmp" "$JOB_QUEUE"
    
    # Start job
    echo "[$(date)] Starting job: $job_name" >> "$JOB_HISTORY"
    eval "$command" > "$SCHEDULER_DIR/${job_name}.log" 2>&1 &
    local pid=$!
    
    # Add to active jobs
    echo "$job_name:$pid:$(date +%s)" >> "$ACTIVE_JOBS"
    
    echo "Started job '$job_name' with PID $pid"
    return 0
}

# Check and clean up completed jobs
cleanup_jobs() {
    if [ ! -f "$ACTIVE_JOBS" ]; then
        return
    fi
    
    local temp_file="$ACTIVE_JOBS.tmp"
    > "$temp_file"
    
    while IFS=':' read -r job_name pid start_time; do
        if kill -0 "$pid" 2>/dev/null; then
            # Job still running
            echo "$job_name:$pid:$start_time" >> "$temp_file"
        else
            # Job completed
            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            echo "[$(date)] Job completed: $job_name (duration: ${duration}s)" >> "$JOB_HISTORY"
            echo "Job '$job_name' completed (duration: ${duration}s)"
        fi
    done < "$ACTIVE_JOBS"
    
    mv "$temp_file" "$ACTIVE_JOBS"
}

# Show scheduler status
show_status() {
    echo "=== Job Scheduler Status ==="
    echo "Max concurrent jobs: $MAX_CONCURRENT_JOBS"
    echo
    
    echo "Queued jobs: $(wc -l < "$JOB_QUEUE" 2>/dev/null || echo "0")"
    if [ -s "$JOB_QUEUE" ]; then
        echo "Queue contents:"
        sort -nr "$JOB_QUEUE" | while IFS=':' read -r priority name command; do
            echo "  Priority $priority: $name"
        done
    fi
    echo
    
    echo "Active jobs: $(wc -l < "$ACTIVE_JOBS" 2>/dev/null || echo "0")"
    if [ -s "$ACTIVE_JOBS" ]; then
        echo "Active job details:"
        while IFS=':' read -r job_name pid start_time; do
            local current_time=$(date +%s)
            local runtime=$((current_time - start_time))
            echo "  $job_name (PID: $pid, runtime: ${runtime}s)"
        done < "$ACTIVE_JOBS"
    fi
}

# Main scheduler loop
run_scheduler() {
    local duration=${1:-60}
    local check_interval=${2:-5}
    
    echo "Starting job scheduler for ${duration}s..."
    local end_time=$(($(date +%s) + duration))
    
    while [ $(date +%s) -lt $end_time ]; do
        cleanup_jobs
        
        # Try to start new jobs
        while start_next_job; do
            sleep 1
        done
        
        sleep $check_interval
    done
    
    echo "Scheduler stopping. Waiting for active jobs to complete..."
    
    # Wait for remaining jobs
    while [ -s "$ACTIVE_JOBS" ]; do
        cleanup_jobs
        if [ -s "$ACTIVE_JOBS" ]; then
            echo "Waiting for $(wc -l < "$ACTIVE_JOBS") jobs to complete..."
            sleep 5
        fi
    done
    
    echo "All jobs completed."
}

# Command handling
case "${1:-help}" in
    "init")
        init_scheduler
        ;;
    "add")
        add_job "$2" "$3" "$4"
        ;;
    "start")
        run_scheduler "$2" "$3"
        ;;
    "status")
        show_status
        ;;
    "cleanup")
        cleanup_jobs
        ;;
    *)
        echo "Usage: $0 {init|add|start|status|cleanup}"
        echo "  init                     - Initialize scheduler"
        echo "  add <name> <cmd> [pri]   - Add job to queue"
        echo "  start [duration] [int]   - Run scheduler"
        echo "  status                   - Show current status"
        echo "  cleanup                  - Clean completed jobs"
        ;;
esac
SCHEDEOF

chmod +x job_scheduler.sh

echo "2.2 Initialize and test job scheduler:"
./job_scheduler.sh init

# Add some test jobs
./job_scheduler.sh add "pipeline_1" "python3 pipeline_simulator.py pipeline_1 20" 8
./job_scheduler.sh add "pipeline_2" "python3 pipeline_simulator.py pipeline_2 15 --cpu" 6
./job_scheduler.sh add "pipeline_3" "python3 pipeline_simulator.py pipeline_3 25 --memory" 7
./job_scheduler.sh add "pipeline_4" "python3 pipeline_simulator.py pipeline_4 10" 9

echo
echo "2.3 Show scheduler status:"
./job_scheduler.sh status

echo
echo "2.4 Start scheduler (will run for 30 seconds):"
./job_scheduler.sh start 30 3 &
SCHEDULER_PID=$!

echo

echo "=== Solution 3: Process Health Monitoring ==="

echo "3.1 Advanced health monitoring system:"
cat > health_monitor.sh << 'HEALTHEOF'
#!/bin/bash

# Advanced process health monitoring
HEALTH_LOG="health_monitor.log"
ALERT_LOG="health_alerts.log"
CONFIG_FILE="health_config.conf"

# Default thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
RUNTIME_THRESHOLD=3600  # 1 hour
CHECK_INTERVAL=10

# Load configuration if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$HEALTH_LOG"
    
    if [ "$level" = "ALERT" ] || [ "$level" = "ERROR" ]; then
        echo "[$timestamp] [$level] $message" >> "$ALERT_LOG"
    fi
}

check_process_health() {
    local pattern=$1
    local pids=$(pgrep -f "$pattern")
    
    if [ -z "$pids" ]; then
        log_message "INFO" "No processes found matching '$pattern'"
        return 0
    fi
    
    for pid in $pids; do
        # Get process information
        local ps_info=$(ps -p $pid -o pid,%cpu,%mem,etime,cmd --no-headers 2>/dev/null)
        
        if [ -z "$ps_info" ]; then
            continue
        fi
        
        local cpu=$(echo "$ps_info" | awk '{print $2}' | cut -d'.' -f1)
        local mem=$(echo "$ps_info" | awk '{print $3}' | cut -d'.' -f1)
        local etime=$(echo "$ps_info" | awk '{print $4}')
        local cmd=$(echo "$ps_info" | awk '{for(i=5;i<=NF;i++) printf "%s ", $i}')
        
        # Convert elapsed time to seconds
        local runtime_seconds=0
        if [[ "$etime" =~ ^([0-9]+):([0-9]+)$ ]]; then
            # MM:SS format
            runtime_seconds=$(( ${BASH_REMATCH[1]} * 60 + ${BASH_REMATCH[2]} ))
        elif [[ "$etime" =~ ^([0-9]+):([0-9]+):([0-9]+)$ ]]; then
            # HH:MM:SS format
            runtime_seconds=$(( ${BASH_REMATCH[1]} * 3600 + ${BASH_REMATCH[2]} * 60 + ${BASH_REMATCH[3]} ))
        fi
        
        # Health checks
        local health_status="HEALTHY"
        local issues=()
        
        if [ "$cpu" -gt "$CPU_THRESHOLD" ]; then
            health_status="WARNING"
            issues+=("High CPU: ${cpu}%")
        fi
        
        if [ "$mem" -gt "$MEMORY_THRESHOLD" ]; then
            health_status="WARNING"
            issues+=("High Memory: ${mem}%")
        fi
        
        if [ "$runtime_seconds" -gt "$RUNTIME_THRESHOLD" ]; then
            health_status="WARNING"
            issues+=("Long Runtime: ${etime}")
        fi
        
        # Log health status
        if [ "$health_status" = "HEALTHY" ]; then
            log_message "INFO" "PID $pid: HEALTHY (CPU: ${cpu}%, MEM: ${mem}%, Runtime: $etime)"
        else
            local issue_str=$(IFS=', '; echo "${issues[*]}")
            log_message "ALERT" "PID $pid: $health_status - $issue_str"
        fi
        
        # Check for zombie processes
        local stat=$(ps -p $pid -o stat --no-headers 2>/dev/null)
        if [[ "$stat" =~ Z ]]; then
            log_message "ERROR" "PID $pid: ZOMBIE process detected"
        fi
    done
}

generate_health_report() {
    local report_file="health_report_$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "=== Process Health Report ==="
        echo "Generated: $(date)"
        echo "Configuration:"
        echo "  CPU Threshold: ${CPU_THRESHOLD}%"
        echo "  Memory Threshold: ${MEMORY_THRESHOLD}%"
        echo "  Runtime Threshold: ${RUNTIME_THRESHOLD}s"
        echo
        
        echo "=== System Overview ==="
        echo "Uptime: $(uptime)"
        echo "Memory: $(free -h | grep Mem)"
        echo "Load Average: $(cat /proc/loadavg)"
        echo
        
        echo "=== Recent Health Events ==="
        if [ -f "$HEALTH_LOG" ]; then
            tail -20 "$HEALTH_LOG"
        else
            echo "No health log found"
        fi
        
        echo
        echo "=== Recent Alerts ==="
        if [ -f "$ALERT_LOG" ]; then
            tail -10 "$ALERT_LOG"
        else
            echo "No alerts found"
        fi
        
    } > "$report_file"
    
    echo "Health report generated: $report_file"
}

monitor_continuously() {
    local pattern=$1
    local duration=${2:-300}  # 5 minutes default
    
    log_message "INFO" "Starting continuous monitoring for '$pattern' (duration: ${duration}s)"
    
    local end_time=$(($(date +%s) + duration))
    
    while [ $(date +%s) -lt $end_time ]; do
        check_process_health "$pattern"
        sleep "$CHECK_INTERVAL"
    done
    
    log_message "INFO" "Monitoring completed"
    generate_health_report
}

# Command handling
case "${1:-help}" in
    "check")
        check_process_health "$2"
        ;;
    "monitor")
        monitor_continuously "$2" "$3"
        ;;
    "report")
        generate_health_report
        ;;
    "config")
        echo "Creating default configuration..."
        cat > "$CONFIG_FILE" << 'CONFEOF'
# Health Monitor Configuration
CPU_THRESHOLD=80
MEMORY_THRESHOLD=80
RUNTIME_THRESHOLD=3600
CHECK_INTERVAL=10
CONFEOF
        echo "Configuration saved to $CONFIG_FILE"
        ;;
    *)
        echo "Usage: $0 {check|monitor|report|config}"
        echo "  check <pattern>           - Check health of matching processes"
        echo "  monitor <pattern> [dur]   - Monitor continuously"
        echo "  report                    - Generate health report"
        echo "  config                    - Create default config file"
        ;;
esac
HEALTHEOF

chmod +x health_monitor.sh

echo "3.2 Start health monitoring:"
./health_monitor.sh config
./health_monitor.sh monitor "python" 20 &
HEALTH_PID=$!

echo

# Wait for scheduler to complete
wait $SCHEDULER_PID 2>/dev/null

echo "=== Solution 4: Advanced Process Control ==="

echo "4.1 Graceful process shutdown system:"
graceful_shutdown() {
    local pattern=$1
    local timeout=${2:-30}
    
    echo "Initiating graceful shutdown for processes matching: $pattern"
    
    local pids=$(pgrep -f "$pattern")
    
    if [ -z "$pids" ]; then
        echo "No processes found matching '$pattern'"
        return 0
    fi
    
    echo "Found processes: $pids"
    
    # Send SIGTERM first
    echo "Sending SIGTERM..."
    for pid in $pids; do
        if kill -TERM "$pid" 2>/dev/null; then
            echo "  SIGTERM sent to PID $pid"
        fi
    done
    
    # Wait for graceful shutdown
    local waited=0
    while [ $waited -lt $timeout ]; do
        local remaining_pids=$(pgrep -f "$pattern")
        
        if [ -z "$remaining_pids" ]; then
            echo "All processes shut down gracefully"
            return 0
        fi
        
        echo "Waiting for shutdown... (${waited}s/${timeout}s)"
        sleep 5
        waited=$((waited + 5))
    done
    
    # Force kill remaining processes
    local remaining_pids=$(pgrep -f "$pattern")
    if [ -n "$remaining_pids" ]; then
        echo "Timeout reached. Force killing remaining processes..."
        for pid in $remaining_pids; do
            if kill -KILL "$pid" 2>/dev/null; then
                echo "  SIGKILL sent to PID $pid"
            fi
        done
        
        sleep 2
        
        # Final check
        local final_pids=$(pgrep -f "$pattern")
        if [ -z "$final_pids" ]; then
            echo "All processes terminated"
        else
            echo "Warning: Some processes may still be running: $final_pids"
        fi
    fi
}

echo "4.2 Test graceful shutdown:"
graceful_shutdown "pipeline_simulator" 15

# Wait for health monitor to complete
wait $HEALTH_PID 2>/dev/null

echo

# Cleanup
cd ..

echo "=== Advanced Solutions Complete ==="
echo
echo "Advanced techniques demonstrated:"
echo "✅ Comprehensive process monitoring with detailed metrics"
echo "✅ Real-time system resource dashboard"
echo "✅ Sophisticated job scheduler with priority queues"
echo "✅ Advanced health monitoring with alerting"
echo "✅ Graceful process shutdown with timeout handling"
echo "✅ Process status tracking and reporting"
echo "✅ Signal handling and cleanup procedures"
echo "✅ Configuration-driven monitoring systems"
echo
echo "🎯 You've mastered advanced process management for data engineering!"
