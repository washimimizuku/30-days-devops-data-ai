# Day 5: Environment Variables and PATH - Quiz

Test your understanding of environment variables, PATH configuration, and shell customization.

## Question 1: Environment Variables
Which command permanently sets an environment variable for the current session?

a) `set VAR=value`
b) `export VAR=value`
c) `VAR=value`
d) `env VAR=value`

<details>
<summary>Answer</summary>
<b>b) `export VAR=value`</b>

`export` makes the variable available to child processes. Without `export`, the variable is only available in the current shell.
</details>

## Question 2: PATH Variable
What does this command do: `export PATH="/new/dir:$PATH"`?

a) Replaces PATH with /new/dir
b) Adds /new/dir to the end of PATH
c) Adds /new/dir to the beginning of PATH
d) Creates a backup of PATH

<details>
<summary>Answer</summary>
<b>c) Adds /new/dir to the beginning of PATH</b>

Prepending to PATH gives the new directory highest priority in executable searches.
</details>

## Question 3: Shell Configuration Files
Which file is executed for interactive bash shells?

a) ~/.profile
b) ~/.bash_profile
c) ~/.bashrc
d) /etc/profile

<details>
<summary>Answer</summary>
<b>c) ~/.bashrc</b>

`.bashrc` is sourced for interactive non-login bash shells. `.bash_profile` is for login shells.
</details>

## Question 4: Variable Expansion
What does `${HOME:-/tmp}` mean?

a) Set HOME to /tmp
b) Use HOME if set, otherwise use /tmp
c) Use /tmp if HOME is set
d) Compare HOME with /tmp

<details>
<summary>Answer</summary>
<b>b) Use HOME if set, otherwise use /tmp</b>

The `${var:-default}` syntax provides a default value when the variable is unset or empty.
</details>

## Question 5: Aliases
Which alias definition is correct?

a) `alias ll = 'ls -la'`
b) `alias ll='ls -la'`
c) `alias 'll'='ls -la'`
d) `alias "ll"="ls -la"`

<details>
<summary>Answer</summary>
<b>b) `alias ll='ls -la'`</b>

Alias syntax requires no spaces around the equals sign, and the command should be quoted.
</details>

## Question 6: Functions vs Aliases
When should you use a function instead of an alias?

a) When you need parameters
b) When you need multiple commands
c) When you need conditional logic
d) All of the above

<details>
<summary>Answer</summary>
<b>d) All of the above</b>

Functions are more powerful than aliases and can handle parameters, multiple commands, and conditional logic.
</details>

## Question 7: Environment Inheritance
Which processes inherit environment variables?

a) Only the current shell
b) Child processes of the current shell
c) All processes on the system
d) Only processes started with export

<details>
<summary>Answer</summary>
<b>b) Child processes of the current shell</b>

Environment variables are inherited by child processes but not by parent or sibling processes.
</details>

## Question 8: Shell Startup Order
For a bash login shell, which file is read first?

a) ~/.bashrc
b) ~/.bash_profile
c) ~/.profile
d) /etc/profile

<details>
<summary>Answer</summary>
<b>d) /etc/profile</b>

System-wide configuration files like `/etc/profile` are read before user-specific files.
</details>

## Question 9: PATH Search Order
If the same executable exists in multiple PATH directories, which one runs?

a) The largest file
b) The most recently modified
c) The first one found in PATH order
d) The one with highest permissions

<details>
<summary>Answer</summary>
<b>c) The first one found in PATH order</b>

The shell searches PATH directories in order and executes the first matching executable found.
</details>

## Question 10: Unsetting Variables
How do you remove an environment variable?

a) `export VAR=""`
b) `unset VAR`
c) `delete VAR`
d) `VAR=null`

<details>
<summary>Answer</summary>
<b>b) `unset VAR`</b>

`unset` removes the variable entirely. Setting it to empty string (`""`) makes it exist but empty.
</details>

## Practical Questions

### Question 11: Development Environment
You want to set up a Python data science environment. Which variables would be most useful?

a) `PYTHONPATH`, `JUPYTER_CONFIG_DIR`, `DATA_HOME`
b) `PYTHON_HOME`, `JUPYTER_PATH`, `DATA_PATH`
c) `PY_PATH`, `JUPYTER_DIR`, `DATASET_HOME`
d) `PYTHON_DIR`, `NOTEBOOK_PATH`, `DATA_DIR`

<details>
<summary>Answer</summary>
<b>a) `PYTHONPATH`, `JUPYTER_CONFIG_DIR`, `DATA_HOME`</b>

These are standard environment variables recognized by Python, Jupyter, and commonly used for data directories.
</details>

### Question 12: PATH Troubleshooting
A command works when you specify the full path but not when you just type the command name. What's wrong?

a) The file doesn't have execute permissions
b) The directory isn't in PATH
c) The file is corrupted
d) The shell is wrong

<details>
<summary>Answer</summary>
<b>b) The directory isn't in PATH</b>

If the full path works but the command name doesn't, the directory containing the executable isn't in PATH.
</details>

### Question 13: Configuration Management
You want your custom aliases available in all new terminal sessions. Where should you put them?

a) In a script you run manually
b) In ~/.bashrc or ~/.zshrc
c) In /tmp/aliases
d) In the current terminal only

<details>
<summary>Answer</summary>
<b>b) In ~/.bashrc or ~/.zshrc</b>

Shell configuration files are automatically sourced when new interactive shells start.
</details>

### Question 14: Project Environments
What's the best way to set project-specific environment variables?

a) Modify ~/.bashrc for each project
b) Use a .env file in the project directory
c) Set them globally in /etc/environment
d) Hard-code them in scripts

<details>
<summary>Answer</summary>
<b>b) Use a .env file in the project directory</b>

Project-specific .env files keep configurations isolated and make projects portable.
</details>

### Question 15: Security Considerations
Where should you NOT store API keys and passwords?

a) In ~/.bashrc or ~/.zshrc
b) In version-controlled .env files
c) In shell history
d) All of the above

<details>
<summary>Answer</summary>
<b>d) All of the above</b>

Never store secrets in shell configs, version control, or command history. Use secure secret management tools.
</details>

## Scenario-Based Questions

### Question 16: Multi-User System
On a shared system, you want to add a directory to PATH for all users. Where should you modify PATH?

a) Each user's ~/.bashrc
b) /etc/profile or /etc/bash.bashrc
c) /tmp/global_path
d) The root user's ~/.bashrc

<details>
<summary>Answer</summary>
<b>b) /etc/profile or /etc/bash.bashrc</b>

System-wide configuration files affect all users. Individual user files only affect that user.
</details>

### Question 17: Cross-Platform Scripts
You're writing a script that should work on both macOS and Linux. How do you handle different PATH requirements?

a) Use separate scripts for each OS
b) Use conditional logic based on $OSTYPE
c) Hard-code all paths
d) Ignore the differences

<details>
<summary>Answer</summary>
<b>b) Use conditional logic based on $OSTYPE</b>

Checking `$OSTYPE` allows you to set OS-specific paths while keeping one script.
</details>

### Question 18: Environment Debugging
A script works in one terminal but not another. What should you check first?

a) File permissions
b) Environment variables and PATH
c) Network connectivity
d) Disk space

<details>
<summary>Answer</summary>
<b>b) Environment variables and PATH</b>

Different terminals may have different environments, especially if one sourced different configuration files.
</details>

### Question 19: Performance Optimization
Your PATH has 50+ directories and command lookup is slow. What should you do?

a) Add more directories
b) Remove unused directories and put frequently used ones first
c) Use absolute paths for everything
d) Switch to a different shell

<details>
<summary>Answer</summary>
<b>b) Remove unused directories and put frequently used ones first</b>

Shorter PATH with frequently used directories first improves command lookup performance.
</details>

### Question 20: Configuration Backup
What's the best practice for backing up shell configurations?

a) Copy files manually when you remember
b) Use version control (git) for dotfiles
c) Email them to yourself
d) Don't back them up

<details>
<summary>Answer</summary>
<b>b) Use version control (git) for dotfiles</b>

Version control provides history, synchronization across machines, and easy restoration.
</details>

## Score Your Knowledge

- **18-20 correct**: Expert level! You've mastered environment management
- **15-17 correct**: Advanced understanding, ready for complex setups
- **12-14 correct**: Good grasp, practice more advanced scenarios
- **9-11 correct**: Basic understanding, review concepts and practice
- **0-8 correct**: Review the lesson and work through exercises again

## Real-World Applications

Practice these scenarios:

1. **Data Science Setup**: Configure environment for Python, R, and Jupyter
2. **Multi-Project Management**: Handle different Python versions and dependencies
3. **Team Standardization**: Create shared environment configurations
4. **CI/CD Integration**: Set up environments for automated testing
5. **Cross-Platform Development**: Handle macOS, Linux, and Windows differences

## Best Practices Checklist

- ✅ Use descriptive variable names
- ✅ Document non-obvious configurations
- ✅ Keep configurations in version control
- ✅ Test configurations on fresh systems
- ✅ Use project-specific .env files
- ✅ Never store secrets in shell configs
- ✅ Organize PATH logically (user before system)
- ✅ Use functions for complex operations
- ✅ Make configurations modular and reusable
- ✅ Regular backup and sync configurations

## Next Steps

1. Set up your personal dotfiles repository
2. Create project templates with environment configs
3. Learn about direnv for automatic environment switching
4. Explore containerization for environment isolation
5. Move on to Day 6: Make and Task Automation

Remember: A well-configured environment is the foundation of productive development. Invest time in getting it right!
