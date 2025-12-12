# Day 8: Git Basics - Quiz

Test your understanding of Git fundamentals, repository management, and version control concepts.

## Question 1: Git Initialization
What does `git init` do?

a) Downloads a repository from GitHub
b) Creates a new Git repository in the current directory
c) Initializes Git configuration
d) Creates the first commit

<details>
<summary>Answer</summary>
<b>b) Creates a new Git repository in the current directory</b>

`git init` initializes a new Git repository by creating a `.git` directory with all necessary Git metadata.
</details>

## Question 2: Git Areas
What are the three main areas in Git?

a) Local, Remote, Cloud
b) Working Directory, Staging Area, Repository
c) Files, Commits, Branches
d) Add, Commit, Push

<details>
<summary>Answer</summary>
<b>b) Working Directory, Staging Area, Repository</b>

Git has three main areas: Working Directory (your files), Staging Area (prepared changes), and Repository (committed snapshots).
</details>

## Question 3: Staging Files
Which command adds all modified files to the staging area?

a) `git add *`
b) `git add .`
c) `git add -A`
d) Both b and c are correct

<details>
<summary>Answer</summary>
<b>d) Both b and c are correct</b>

Both `git add .` and `git add -A` add all changes to staging. `git add -A` also includes deletions from anywhere in the repo.
</details>

## Question 4: Commit Messages
Which is the best commit message?

a) `git commit -m "fix"`
b) `git commit -m "updated files"`
c) `git commit -m "Fix data validation bug in CSV parser"`
d) `git commit -m "asdf"`

<details>
<summary>Answer</summary>
<b>c) `git commit -m "Fix data validation bug in CSV parser"`</b>

Good commit messages are descriptive, specific, and explain what the commit does and why.
</details>

## Question 5: .gitignore
What does this .gitignore pattern do: `*.log`?

a) Ignores all files ending with .log
b) Ignores only the file named "*.log"
c) Ignores log directories
d) Tracks all .log files

<details>
<summary>Answer</summary>
<b>a) Ignores all files ending with .log</b>

The `*` wildcard matches any characters, so `*.log` ignores all files with the .log extension.
</details>

## Question 6: Git Status
What does `git status` show?

a) Only committed files
b) Only staged files
c) Current state of working directory and staging area
d) Only modified files

<details>
<summary>Answer</summary>
<b>c) Current state of working directory and staging area</b>

`git status` shows which files are modified, staged, untracked, or ignored.
</details>

## Question 7: Viewing History
Which command shows a compact, one-line view of commit history?

a) `git log`
b) `git log --oneline`
c) `git history`
d) `git show`

<details>
<summary>Answer</summary>
<b>b) `git log --oneline`</b>

`git log --oneline` displays each commit on a single line with abbreviated hash and commit message.
</details>

## Question 8: Undoing Changes
How do you discard changes in the working directory for a specific file?

a) `git reset file.txt`
b) `git restore file.txt`
c) `git checkout file.txt`
d) Both b and c work

<details>
<summary>Answer</summary>
<b>d) Both b and c work</b>

Both `git restore file.txt` (modern) and `git checkout -- file.txt` (traditional) discard working directory changes.
</details>

## Question 9: Git Configuration
How do you set your name globally in Git?

a) `git config user.name "Your Name"`
b) `git config --global user.name "Your Name"`
c) `git set user.name "Your Name"`
d) `git user.name "Your Name"`

<details>
<summary>Answer</summary>
<b>b) `git config --global user.name "Your Name"`</b>

The `--global` flag sets configuration for all repositories on your system.
</details>

## Question 10: File Removal
What's the difference between `git rm` and `rm`?

a) No difference
b) `git rm` removes and stages the deletion, `rm` only removes the file
c) `git rm` is safer
d) `rm` works with Git, `git rm` doesn't

<details>
<summary>Answer</summary>
<b>b) `git rm` removes and stages the deletion, `rm` only removes the file</b>

`git rm` removes the file and stages the deletion for commit. Regular `rm` only removes the file from the filesystem.
</details>

## Practical Questions

### Question 11: Data Project Setup
You're starting a new data analysis project. What should you do first?

a) Create all your data files
b) `git init` and create .gitignore
c) Write all your code
d) Upload to GitHub

<details>
<summary>Answer</summary>
<b>b) `git init` and create .gitignore</b>

Initialize Git first and set up .gitignore to avoid accidentally committing large data files or sensitive information.
</details>

### Question 12: .gitignore for Data Projects
Which files should typically be in .gitignore for data projects?

a) Source code files
b) Data files, logs, and output files
c) README files
d) Configuration templates

<details>
<summary>Answer</summary>
<b>b) Data files, logs, and output files</b>

Data files are often large or sensitive, logs change frequently, and output files can be regenerated.
</details>

### Question 13: Commit Frequency
When should you commit your changes?

a) Only when the project is complete
b) Once per day
c) After each logical unit of work
d) Only when asked by your manager

<details>
<summary>Answer</summary>
<b>c) After each logical unit of work</b>

Commit frequently after completing logical units of work. This makes it easier to track changes and revert if needed.
</details>

### Question 14: Viewing Changes
You want to see what changes you made before committing. Which command should you use?

a) `git status`
b) `git diff`
c) `git log`
d) `git show`

<details>
<summary>Answer</summary>
<b>b) `git diff`</b>

`git diff` shows the actual changes (additions/deletions) in your working directory compared to the last commit.
</details>

### Question 15: Repository Structure
What indicates a directory is a Git repository?

a) Presence of source code files
b) Presence of .git directory
c) Presence of README file
d) Presence of .gitignore file

<details>
<summary>Answer</summary>
<b>b) Presence of .git directory</b>

The `.git` directory contains all Git metadata and indicates the directory is a Git repository.
</details>

## Scenario-Based Questions

### Question 16: Accidental Add
You accidentally added a large data file to staging. How do you remove it without losing the file?

a) `git rm data.csv`
b) `git restore --staged data.csv`
c) `git reset data.csv`
d) Both b and c work

<details>
<summary>Answer</summary>
<b>d) Both b and c work</b>

Both `git restore --staged` (modern) and `git reset` (traditional) remove files from staging without deleting them.
</details>

### Question 17: Lost Changes
You made changes to a file but haven't committed them. You want to see what you changed. What do you do?

a) `git log`
b) `git status`
c) `git diff`
d) `git show`

<details>
<summary>Answer</summary>
<b>c) `git diff`</b>

`git diff` shows the differences between your working directory and the last commit.
</details>

### Question 18: Configuration Issues
Git is asking for your name and email with every commit. What's wrong?

a) Git is broken
b) You haven't configured user.name and user.email
c) You need to reinstall Git
d) This is normal behavior

<details>
<summary>Answer</summary>
<b>b) You haven't configured user.name and user.email</b>

Git requires user identification for commits. Set it with `git config --global user.name` and `git config --global user.email`.
</details>

### Question 19: File History
You want to see the history of changes to a specific file. Which command should you use?

a) `git log filename`
b) `git log --follow filename`
c) `git history filename`
d) `git track filename`

<details>
<summary>Answer</summary>
<b>b) `git log --follow filename`</b>

`git log --follow filename` shows the commit history for a specific file, even across renames.
</details>

### Question 20: Repository Cleanup
Your repository has many untracked files you want to remove. What's the safest approach?

a) `git clean -f`
b) Check what would be removed first with `git clean -n`
c) `rm -rf *`
d) Manually delete each file

<details>
<summary>Answer</summary>
<b>b) Check what would be removed first with `git clean -n`</b>

Always use `git clean -n` (dry run) first to see what would be removed before using `git clean -f`.
</details>

## Score Your Knowledge

- **18-20 correct**: Expert level! You've mastered Git basics
- **15-17 correct**: Advanced understanding, ready for complex workflows
- **12-14 correct**: Good grasp, practice more with real projects
- **9-11 correct**: Basic understanding, review concepts and practice
- **0-8 correct**: Review the lesson and work through exercises again

## Real-World Applications

Practice these scenarios:

1. **New Project Setup**: Initialize a data science project with proper .gitignore
2. **Daily Workflow**: Make changes, stage selectively, commit with good messages
3. **Mistake Recovery**: Practice undoing changes at different stages
4. **History Exploration**: Use git log and git diff to understand project evolution
5. **File Management**: Practice adding, removing, and renaming files with Git

## Best Practices Checklist

- ✅ Configure Git with your name and email
- ✅ Create comprehensive .gitignore before first commit
- ✅ Write descriptive commit messages
- ✅ Commit frequently with logical units of work
- ✅ Use `git status` and `git diff` before committing
- ✅ Never commit sensitive data or large files
- ✅ Keep repository clean with appropriate .gitignore
- ✅ Use `git log` to understand project history
- ✅ Practice undoing changes safely
- ✅ Organize project structure before initializing Git

## Next Steps

1. Practice Git basics with your own projects
2. Learn about Git aliases for efficiency
3. Explore Git GUI tools for visualization
4. Set up a GitHub account for remote repositories
5. Move on to Day 9: Branching and Merging

Remember: Git is a powerful tool that becomes more valuable with practice. Start using it for all your projects, even small ones!
