# Day 9: Branching and Merging - Quiz

Test your understanding of Git branching, merging strategies, and collaborative workflows.

## Question 1: Branch Creation
Which command creates a new branch and switches to it immediately?

a) `git branch feature-name`
b) `git checkout feature-name`
c) `git checkout -b feature-name`
d) `git switch feature-name`

<details>
<summary>Answer</summary>
<b>c) `git checkout -b feature-name`</b>

The `-b` flag creates a new branch and switches to it. `git switch -c feature-name` is the modern equivalent.
</details>

## Question 2: Fast-Forward Merge
When does Git perform a fast-forward merge?

a) Always when merging
b) When the target branch has no new commits since branching
c) When using `--ff-only` flag
d) Both b and c are correct

<details>
<summary>Answer</summary>
<b>d) Both b and c are correct</b>

Fast-forward merges happen when the target branch hasn't diverged, or when explicitly requested with `--ff-only`.
</details>

## Question 3: Merge Conflict
What causes a merge conflict?

a) Different file names in branches
b) Same lines modified differently in both branches
c) Different commit messages
d) Different branch names

<details>
<summary>Answer</summary>
<b>b) Same lines modified differently in both branches</b>

Conflicts occur when Git cannot automatically resolve differences in the same lines of code.
</details>

## Question 4: Branch Listing
Which command shows all branches including remote ones?

a) `git branch`
b) `git branch -r`
c) `git branch -a`
d) `git branch --all`

<details>
<summary>Answer</summary>
<b>c) `git branch -a`</b>

`-a` shows all branches (local and remote). `-r` shows only remote branches.
</details>

## Question 5: Merge Strategies
What does `git merge --no-ff` do?

a) Prevents fast-forward merges
b) Creates a merge commit even when fast-forward is possible
c) Preserves branch history
d) All of the above

<details>
<summary>Answer</summary>
<b>d) All of the above</b>

`--no-ff` always creates a merge commit, preserving the branch structure and history.
</details>

## Question 6: Branch Deletion
Which command safely deletes a merged branch?

a) `git branch -D branch-name`
b) `git branch -d branch-name`
c) `git delete branch-name`
d) `git remove branch-name`

<details>
<summary>Answer</summary>
<b>b) `git branch -d branch-name`</b>

`-d` safely deletes only merged branches. `-D` force deletes any branch.
</details>

## Question 7: Conflict Resolution
What do the conflict markers `<<<<<<< HEAD` and `>>>>>>> branch-name` indicate?

a) Start and end of the conflict
b) Current branch version and merging branch version
c) Lines to keep and lines to delete
d) Git commands to run

<details>
<summary>Answer</summary>
<b>b) Current branch version and merging branch version</b>

`<<<<<<< HEAD` shows the current branch version, `>>>>>>> branch-name` shows the incoming branch version.
</details>

## Question 8: Branch Switching
What's the modern Git command to switch branches?

a) `git checkout branch-name`
b) `git switch branch-name`
c) `git change branch-name`
d) Both a and b work

<details>
<summary>Answer</summary>
<b>d) Both a and b work</b>

`git switch` is the modern command (Git 2.23+), but `git checkout` still works for backward compatibility.
</details>

## Question 9: Squash Merge
What does `git merge --squash` do?

a) Compresses the repository
b) Combines all commits from the feature branch into one commit
c) Deletes the feature branch
d) Creates multiple merge commits

<details>
<summary>Answer</summary>
<b>b) Combines all commits from the feature branch into one commit</b>

Squash merge takes all commits from the feature branch and combines them into a single commit.
</details>

## Question 10: Branch Comparison
How do you see commits in feature-branch that are not in main?

a) `git diff main feature-branch`
b) `git log main..feature-branch`
c) `git compare main feature-branch`
d) `git show main feature-branch`

<details>
<summary>Answer</summary>
<b>b) `git log main..feature-branch`</b>

The `..` syntax shows commits in the second branch that are not in the first branch.
</details>

## Practical Questions

### Question 11: Feature Development
You're working on a new feature. What's the recommended workflow?

a) Work directly on main branch
b) Create feature branch, develop, then merge back
c) Create multiple branches for each file
d) Use git stash for everything

<details>
<summary>Answer</summary>
<b>b) Create feature branch, develop, then merge back</b>

Feature branches isolate development work and allow safe experimentation without affecting the main codebase.
</details>

### Question 12: Merge Conflict Resolution
You encounter a merge conflict. What's the correct process?

a) Delete the conflicted files
b) Edit files to resolve conflicts, then git add and git commit
c) Use git reset to undo the merge
d) Create a new branch

<details>
<summary>Answer</summary>
<b>b) Edit files to resolve conflicts, then git add and git commit</b>

Resolve conflicts by editing files, removing conflict markers, then stage and commit the resolution.
</details>

### Question 13: Branch Naming
Which is the best branch naming convention?

a) `branch1`, `branch2`, `branch3`
b) `feature/user-authentication`, `bugfix/login-error`
c) `john-work`, `mary-changes`
d) `new`, `old`, `test`

<details>
<summary>Answer</summary>
<b>b) `feature/user-authentication`, `bugfix/login-error`</b>

Descriptive names with prefixes (feature/, bugfix/, hotfix/) clearly indicate the branch purpose.
</details>

### Question 14: Hotfix Workflow
A critical bug is found in production. What should you do?

a) Fix it directly on main branch
b) Create hotfix branch from main, fix, then merge to main and develop
c) Wait for the next release
d) Fix it on develop branch only

<details>
<summary>Answer</summary>
<b>b) Create hotfix branch from main, fix, then merge to main and develop</b>

Hotfix branches allow immediate fixes to production while preserving the development workflow.
</details>

### Question 15: Branch History
You want to see a visual representation of branch history. Which command is best?

a) `git log`
b) `git log --graph --oneline`
c) `git branch`
d) `git status`

<details>
<summary>Answer</summary>
<b>b) `git log --graph --oneline`</b>

The `--graph` flag shows branch structure visually, and `--oneline` keeps it compact and readable.
</details>

## Advanced Questions

### Question 16: Git Flow
In Git Flow, which branches are considered "main" branches?

a) main and feature
b) main and develop
c) develop and release
d) feature and hotfix

<details>
<summary>Answer</summary>
<b>b) main and develop</b>

Git Flow uses main (production) and develop (integration) as the two main branches that persist throughout the project.
</details>

### Question 17: Merge vs Rebase
When should you use merge instead of rebase?

a) When you want to preserve branch history
b) When working on shared branches
c) When you want to maintain context of feature development
d) All of the above

<details>
<summary>Answer</summary>
<b>d) All of the above</b>

Merging preserves history and context, and is safer for shared branches where rebase could cause issues.
</details>

### Question 18: Branch Protection
How can you prevent accidental commits to the main branch?

a) Delete the main branch
b) Use branch protection rules
c) Never create a main branch
d) Always work in feature branches

<details>
<summary>Answer</summary>
<b>b) Use branch protection rules</b>

Branch protection rules (available on platforms like GitHub) can prevent direct commits and require pull requests.
</details>

### Question 19: Conflict Prevention
What's the best way to minimize merge conflicts?

a) Never use branches
b) Keep feature branches small and merge frequently
c) Always use force push
d) Work on different files only

<details>
<summary>Answer</summary>
<b>b) Keep feature branches small and merge frequently</b>

Smaller, focused branches that are merged quickly reduce the chance of conflicts with other changes.
</details>

### Question 20: Release Management
You're preparing a release. Which workflow is most appropriate?

a) Merge all features directly to main
b) Create release branch, test, then merge to main and develop
c) Tag the current develop branch
d) Create a new repository for the release

<details>
<summary>Answer</summary>
<b>b) Create release branch, test, then merge to main and develop</b>

Release branches allow final testing and bug fixes without blocking new development on the develop branch.
</details>

## Score Your Knowledge

- **18-20 correct**: Expert level! You've mastered Git branching and merging
- **15-17 correct**: Advanced understanding, ready for complex team workflows
- **12-14 correct**: Good grasp, practice more with real projects
- **9-11 correct**: Basic understanding, review concepts and practice
- **0-8 correct**: Review the lesson and work through exercises again

## Real-World Applications

Practice these scenarios:

1. **Feature Development**: Create feature branch, develop, and merge back
2. **Parallel Development**: Multiple developers working on different features
3. **Release Preparation**: Create release branch, test, and deploy
4. **Hotfix Management**: Fix critical production bugs quickly
5. **Conflict Resolution**: Handle merge conflicts in team environment

## Best Practices Checklist

- ✅ Use descriptive branch names with prefixes
- ✅ Keep feature branches small and focused
- ✅ Merge frequently to avoid large conflicts
- ✅ Use appropriate merge strategies (ff, no-ff, squash)
- ✅ Test before merging to main branches
- ✅ Clean up merged branches regularly
- ✅ Document merge decisions in commit messages
- ✅ Use pull requests for code review
- ✅ Protect main branches from direct commits
- ✅ Follow consistent branching workflow in team

## Workflow Patterns

### Git Flow
- **Main branches**: main, develop
- **Supporting**: feature/*, release/*, hotfix/*
- **Best for**: Large teams, scheduled releases

### GitHub Flow
- **Main branch**: main
- **Supporting**: feature/*
- **Best for**: Continuous deployment, smaller teams

### GitLab Flow
- **Main branches**: main, production
- **Supporting**: feature/*, environment/*
- **Best for**: Multiple environments, staged deployments

## Next Steps

1. Practice branching workflows with team members
2. Set up branch protection rules on GitHub/GitLab
3. Learn about pull requests and code review
4. Explore advanced Git tools (rebase, cherry-pick)
5. Move on to Day 10: Remote Repositories

Remember: Good branching strategy is essential for team collaboration. Choose a workflow that fits your team size and deployment process!
