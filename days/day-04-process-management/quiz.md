# Day 4: Process Management - Quiz

Test your understanding of process monitoring, job control, and system resource management.

## Question 1: Process Signals
Which signal should you send first when trying to gracefully terminate a process?

a) SIGKILL (9)
b) SIGTERM (15)
c) SIGSTOP (19)
d) SIGINT (2)

<details>
<summary>Answer</summary>
<b>b) SIGTERM (15)</b>

SIGTERM allows the process to clean up gracefully. SIGKILL should only be used as a last resort since it cannot be caught or ignored.
</details>

## Question 2: Background Jobs
What does the `&` symbol do when added to the end of a command?

a) Runs the command with higher priority
b) Runs the command in the background
c) Runs the command as root
d) Runs the command in a new terminal

<details>
<summary>Answer</summary>
<b>b) Runs the command in the background</b>

The `&` symbol starts the process in the background, allowing you to continue using the terminal while the process runs.
</details>

## Question 3: ps Command
Which `ps` command shows all processes with detailed information?

a) `ps`
b) `ps -ef`
c) `ps aux`
d) Both b and c are correct

<details>
<summary>Answer</summary>
<b>d) Both b and c are correct</b>

Both `ps -ef` and `ps aux` show all processes with detailed information, just in slightly different formats.
</details>

## Question 4: Job Control
How do you bring a background job to the foreground?

a) `bg %1`
b) `fg %1`
c) `jobs %1`
d) `kill %1`

<details>
<summary>Answer</summary>
<b>b) `fg %1`</b>

`fg %1` brings job number 1 to the foreground. `bg` sends jobs to background, `jobs` lists them, and `kill` terminates them.
</details>

## Question 5: nohup Command
What is the purpose of the `nohup` command?

a) Prevents a process from using too much CPU
b) Runs a process with no output
c) Allows a process to continue running after logout
d) Runs a process with higher priority

<details>
<summary>Answer</summary>
<b>c) Allows a process to continue running after logout</b>

`nohup` (no hangup) makes processes immune to hangup signals, so they continue running even after you log out.
</details>

## Question 6: System Load
What does a load average of 2.0 mean on a dual-core system?

a) System is 50% utilized
b) System is 100% utilized
c) System is 200% utilized (overloaded)
d) System has 2 processes running

<details>
<summary>Answer</summary>
<b>b) System is 100% utilized</b>

Load average represents the average number of processes waiting for CPU. On a dual-core system, 2.0 means both cores are fully utilized.
</details>

## Question 7: Process States
What does the 'Z' state mean in process status?

a) Zero CPU usage
b) Zombie process
c) Zipped/compressed process
d) Zone-restricted process

<details>
<summary>Answer</summary>
<b>b) Zombie process</b>

'Z' indicates a zombie process - one that has completed but still has an entry in the process table waiting for its parent to read its exit status.
</details>

## Question 8: Memory Monitoring
Which command shows memory usage in human-readable format?

a) `free`
b) `free -h`
c) `free -m`
d) Both b and c are correct

<details>
<summary>Answer</summary>
<b>d) Both b and c are correct</b>

`free -h` shows human-readable format (KB, MB, GB), while `free -m` shows in megabytes. Both are more readable than the default bytes.
</details>

## Question 9: pkill Command
What does `pkill -f "data_processor"` do?

a) Kills processes with PID containing "data_processor"
b) Kills processes whose command line contains "data_processor"
c) Kills processes owned by user "data_processor"
d) Kills processes in the "data_processor" group

<details>
<summary>Answer</summary>
<b>b) Kills processes whose command line contains "data_processor"</b>

The `-f` flag makes pkill match against the full command line, not just the process name.
</details>

## Question 10: Screen/tmux
What's the main advantage of using screen or tmux?

a) Faster process execution
b) Better security
c) Persistent terminal sessions
d) Automatic process monitoring

<details>
<summary>Answer</summary>
<b>c) Persistent terminal sessions</b>

Screen and tmux create persistent terminal sessions that survive network disconnections and allow you to detach/reattach to running sessions.
</details>

## Practical Questions

### Question 11: Process Monitoring
You want to find all Python processes and their memory usage. Which command is best?

a) `ps aux | grep python`
b) `ps -C python -o pid,cmd,%mem`
c) `pgrep python`
d) `top -p $(pgrep python)`

<details>
<summary>Answer</summary>
<b>b) `ps -C python -o pid,cmd,%mem`</b>

This command specifically finds processes by command name (-C python) and shows only the desired columns (pid, cmd, %mem).
</details>

### Question 12: Background Job Management
You started a long-running job with `python script.py &` but forgot to redirect output. What happens?

a) Output is lost
b) Output appears in terminal, potentially interfering with other commands
c) Output is automatically saved to a file
d) The job fails

<details>
<summary>Answer</summary>
<b>b) Output appears in terminal, potentially interfering with other commands</b>

Without output redirection, background jobs still send output to the terminal, which can interfere with your current work.
</details>

### Question 13: Resource Limits
A data processing job is consuming too much memory. What's the best approach?

a) Kill it immediately with `kill -9`
b) Send SIGTERM first, then SIGKILL if needed
c) Pause it with SIGSTOP and investigate
d) Reduce its priority with `nice`

<details>
<summary>Answer</summary>
<b>c) Pause it with SIGSTOP and investigate</b>

Pausing with SIGSTOP allows you to investigate the issue without losing work, then you can decide whether to optimize, restart, or terminate.
</details>

### Question 14: Long-Running Jobs
Which is the best way to start a data pipeline that must run overnight?

a) `python pipeline.py &`
b) `nohup python pipeline.py > pipeline.log 2>&1 &`
c) `screen -S pipeline python pipeline.py`
d) Both b and c are good options

<details>
<summary>Answer</summary>
<b>d) Both b and c are good options</b>

Both nohup with output redirection and screen sessions are excellent for long-running jobs. Screen allows interactive monitoring, while nohup is simpler.
</details>

### Question 15: System Performance
Your system load average is consistently above 4.0 on a 2-core system. What should you do?

a) Nothing, this is normal
b) Investigate which processes are causing high load
c) Restart the system
d) Add more memory

<details>
<summary>Answer</summary>
<b>b) Investigate which processes are causing high load</b>

Load > number of cores indicates the system is overloaded. You should identify resource-intensive processes and optimize or reschedule them.
</details>

## Scenario-Based Questions

### Question 16: Data Pipeline Monitoring
You're running multiple data processing jobs. How would you monitor them effectively?

a) Check `ps aux` manually every few minutes
b) Use `top` to watch real-time updates
c) Write a script to log process status periodically
d) Use `htop` for better visualization

<details>
<summary>Answer</summary>
<b>c) Write a script to log process status periodically</b>

For production data pipelines, automated monitoring with logging is most reliable. Manual monitoring doesn't scale and can miss issues.
</details>

### Question 17: Process Recovery
A critical data processing job crashed. What information would help you diagnose the issue?

a) Exit code of the process
b) System resource usage at time of crash
c) Error logs and output
d) All of the above

<details>
<summary>Answer</summary>
<b>d) All of the above</b>

Comprehensive diagnosis requires exit codes, resource usage patterns, and error logs to understand why the process failed.
</details>

### Question 18: Job Scheduling
You need to run 10 data processing jobs but your system can only handle 3 concurrent jobs. What's the best approach?

a) Run all 10 at once and let the system manage
b) Run them one at a time sequentially
c) Create a job queue system with concurrency limits
d) Use `nice` to lower priority of some jobs

<details>
<summary>Answer</summary>
<b>c) Create a job queue system with concurrency limits</b>

A proper job scheduler ensures optimal resource utilization while preventing system overload, maximizing throughput.
</details>

## Score Your Knowledge

- **16-18 correct**: Expert level! You've mastered process management
- **13-15 correct**: Advanced understanding, ready for production systems
- **10-12 correct**: Good grasp, practice more complex scenarios
- **7-9 correct**: Basic understanding, review concepts and practice
- **0-6 correct**: Review the lesson and work through exercises again

## Real-World Applications

Practice these scenarios:

1. **Data Pipeline Monitoring**: Set up monitoring for a multi-stage ETL pipeline
2. **Resource Management**: Handle memory-intensive ML training jobs
3. **Job Recovery**: Implement automatic restart for failed processes
4. **Performance Optimization**: Balance multiple concurrent data processing tasks
5. **System Health**: Create alerts for resource usage thresholds

## Next Steps

1. Practice with real data processing workloads
2. Learn about systemd for production process management
3. Explore container orchestration (Docker, Kubernetes)
4. Study advanced monitoring tools (Prometheus, Grafana)
5. Move on to Day 5: Environment Variables and PATH

Remember: Effective process management is crucial for reliable data engineering systems. Master these fundamentals before moving to more complex orchestration tools!
