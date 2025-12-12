# Day 13 Quiz: Advanced Git

Test your understanding of advanced Git techniques and conflict resolution.

## Question 1: Merge Conflicts
What do the conflict markers `<<<<<<<`, `=======`, and `>>>>>>>` represent in a conflicted file?

A) Git commands to resolve conflicts  
B) Current branch, separator, and incoming branch changes  
C) File corruption indicators  
D) Merge commit boundaries  

<details>
<summary>Answer</summary>

**B) Current branch, separator, and incoming branch changes**

`<<<<<<< HEAD` shows current branch content, `=======` separates the versions, and `>>>>>>> branch-name` shows incoming changes.
</details>

---

## Question 2: Rebase vs Merge
When should you use `git rebase` instead of `git merge`?

A) When working on public/shared branches  
B) When you want to preserve branch history  
C) When cleaning up private feature branch history  
D) When merging release branches  

<details>
<summary>Answer</summary>

**C) When cleaning up private feature branch history**

Rebase is ideal for private branches to create clean linear history. Never rebase public/shared branches.
</details>

---

## Question 3: Interactive Rebase
Which interactive rebase command combines a commit with the previous one?

A) `pick`  
B) `edit`  
C) `squash`  
D) `reword`  

<details>
<summary>Answer</summary>

**C) `squash`**

`squash` combines the commit with the previous commit, allowing you to edit the combined commit message.
</details>

---

## Question 4: Git Stash
What's the difference between `git stash pop` and `git stash apply`?

A) No difference, they're aliases  
B) `pop` removes the stash after applying, `apply` keeps it  
C) `pop` applies to working directory, `apply` to staging area  
D) `pop` is for tracked files, `apply` for untracked  

<details>
<summary>Answer</summary>

**B) `pop` removes the stash after applying, `apply` keeps it**

`git stash pop` applies the stash and removes it from the stash list, while `git stash apply` keeps the stash for potential reuse.
</details>

---

## Question 5: Cherry-pick
What does `git cherry-pick abc1234` do?

A) Creates a new branch from commit abc1234  
B) Applies the changes from commit abc1234 to current branch  
C) Deletes commit abc1234 from its original branch  
D) Merges branch abc1234 into current branch  

<details>
<summary>Answer</summary>

**B) Applies the changes from commit abc1234 to current branch**

Cherry-pick takes the changes from a specific commit and applies them as a new commit on the current branch.
</details>

---

## Question 6: Recovery
If you accidentally delete a branch, what's the best way to recover it?

A) `git branch --recover`  
B) `git reflog` to find the commit, then create new branch  
C) `git reset --hard HEAD`  
D) Restore from backup only  

<details>
<summary>Answer</summary>

**B) `git reflog` to find the commit, then create new branch**

`git reflog` shows recent actions including deleted branches. You can checkout the commit and create a new branch from it.
</details>

---

## Question 7: Force Push Safety
What's safer than `git push --force`?

A) `git push --hard`  
B) `git push --force-with-lease`  
C) `git push --safe`  
D) `git push --override`  

<details>
<summary>Answer</summary>

**B) `git push --force-with-lease`**

`--force-with-lease` only force pushes if your local copy of the remote branch is up to date, preventing accidental overwrites.
</details>

---

## Question 8: Conflict Resolution
During a rebase, after resolving conflicts, what command continues the rebase?

A) `git rebase --resume`  
B) `git rebase --continue`  
C) `git commit --continue`  
D) `git add --continue`  

<details>
<summary>Answer</summary>

**B) `git rebase --continue`**

After resolving conflicts and staging the resolved files with `git add`, use `git rebase --continue` to proceed with the rebase.
</details>

---

## Question 9: Reset Types
What does `git reset --soft HEAD~1` do?

A) Removes last commit and all changes  
B) Removes last commit but keeps changes staged  
C) Removes last commit and unstages changes  
D) Creates a new commit undoing the last one  

<details>
<summary>Answer</summary>

**B) Removes last commit but keeps changes staged**

`--soft` reset moves the branch pointer but keeps changes in the staging area, allowing you to recommit with modifications.
</details>

---

## Question 10: Best Practices
Which is NOT a good practice for advanced Git usage?

A) Always rebase public branches for clean history  
B) Use meaningful commit messages  
C) Test code after rebasing  
D) Communicate with team before force pushing  

<details>
<summary>Answer</summary>

**A) Always rebase public branches for clean history**

Never rebase public/shared branches as it rewrites history and can cause problems for other developers who have based work on those commits.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You've mastered advanced Git techniques.
- **6-7 correct**: Good job! Review the areas you missed.
- **4-5 correct**: You're learning. Practice more with the exercises.
- **Below 4**: Review the lesson material and try the hands-on exercises.

## Next Steps

Tomorrow (Day 14) we'll put all Git knowledge together in a comprehensive collaborative project that simulates real-world team development scenarios.

## Key Takeaways

- Conflicts are normal and can be resolved systematically
- Interactive rebase is powerful for cleaning commit history
- Stash enables seamless context switching
- Recovery is possible with reflog and proper Git knowledge
- Always prioritize safety with force operations
- Communication is key in team Git workflows
