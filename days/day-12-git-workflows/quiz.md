# Day 12 Quiz: Git Workflows

Test your understanding of Git workflows and release management.

## Question 1: Workflow Selection
Which Git workflow is best suited for a team of 6 developers working on a data analytics platform with monthly releases?

A) Feature Branch Workflow  
B) Gitflow Workflow  
C) Trunk-based Development  
D) Fork-based Workflow  

<details>
<summary>Answer</summary>

**B) Gitflow Workflow**

Gitflow is ideal for medium-sized teams (4-10 developers) with scheduled releases. It provides structure for parallel feature development and clear release management.
</details>

---

## Question 2: Gitflow Branches
In Gitflow, which branch should you create a new feature branch from?

A) main  
B) develop  
C) release  
D) master  

<details>
<summary>Answer</summary>

**B) develop**

In Gitflow, feature branches are created from the `develop` branch, which serves as the integration branch for all features.
</details>

---

## Question 3: Semantic Versioning
Given version 2.1.3, what would be the next version if you add a new feature that's backward compatible?

A) 2.1.4  
B) 2.2.0  
C) 3.0.0  
D) 2.1.3.1  

<details>
<summary>Answer</summary>

**B) 2.2.0**

In semantic versioning (MAJOR.MINOR.PATCH), adding a new backward-compatible feature increments the MINOR version.
</details>

---

## Question 4: Hotfix Process
In Gitflow, which branch should a hotfix be created from?

A) develop  
B) feature branch  
C) main  
D) release branch  

<details>
<summary>Answer</summary>

**C) main**

Hotfixes are created from the `main` branch because they need to fix issues in the current production code.
</details>

---

## Question 5: Git Tags
What is the correct command to create an annotated tag for version 1.0.0?

A) `git tag v1.0.0`  
B) `git tag -a v1.0.0 -m "Version 1.0.0"`  
C) `git tag --annotate v1.0.0`  
D) `git create-tag v1.0.0`  

<details>
<summary>Answer</summary>

**B) `git tag -a v1.0.0 -m "Version 1.0.0"`**

The `-a` flag creates an annotated tag, and `-m` provides the tag message.
</details>

---

## Question 6: Branch Naming
Which branch name follows best practices for a feature that adds user authentication?

A) `user-auth`  
B) `feature-user-auth`  
C) `feature/user-authentication`  
D) `new-feature`  

<details>
<summary>Answer</summary>

**C) `feature/user-authentication`**

This follows the convention of `type/descriptive-name` which is clear and organized.
</details>

---

## Question 7: Release Branch
In Gitflow, after finishing a release branch, which branches should it be merged into?

A) Only main  
B) Only develop  
C) Both main and develop  
D) All feature branches  

<details>
<summary>Answer</summary>

**C) Both main and develop**

Release branches are merged into both `main` (for production) and `develop` (to include release changes in future development).
</details>

---

## Question 8: Trunk-based Development
What is a key requirement for successful trunk-based development?

A) Long-lived feature branches  
B) Manual testing only  
C) Strong CI/CD pipeline  
D) Monthly releases  

<details>
<summary>Answer</summary>

**C) Strong CI/CD pipeline**

Trunk-based development requires robust automated testing and continuous integration to ensure code quality with frequent merges.
</details>

---

## Question 9: Branch Protection
Which of these is NOT typically included in branch protection rules?

A) Require pull request reviews  
B) Require status checks to pass  
C) Automatically delete branches  
D) Restrict direct pushes  

<details>
<summary>Answer</summary>

**C) Automatically delete branches**

Branch protection focuses on preventing unwanted changes, not automatic cleanup. Branch deletion is usually a separate process.
</details>

---

## Question 10: Workflow Comparison
Which workflow allows for the most parallel development?

A) Feature Branch Workflow  
B) Gitflow Workflow  
C) Trunk-based Development  
D) All are equal  

<details>
<summary>Answer</summary>

**B) Gitflow Workflow**

Gitflow explicitly supports parallel development with multiple feature branches, release branches, and hotfix branches all working simultaneously.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand Git workflows well.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're getting there. Practice more with the exercises.
- **Below 4**: Review the lesson material and try the exercises again.

## Next Steps

Tomorrow we'll dive into advanced Git techniques including conflict resolution, rebasing, and interactive Git operations in Day 13.
