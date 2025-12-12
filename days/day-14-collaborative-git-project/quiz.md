# Day 14 Quiz: Collaborative Git Project

Test your understanding of the complete Git workflow and collaborative development practices.

## Question 1: Gitflow Branch Strategy
In the customer analytics project, which branch should you create feature branches from?

A) main  
B) develop  
C) release  
D) master  

<details>
<summary>Answer</summary>

**B) develop**

In Gitflow, all feature branches are created from the `develop` branch, which serves as the integration branch for ongoing development.
</details>

---

## Question 2: Merge Conflict Resolution
When merging the API feature caused conflicts in the analytics module, what's the correct resolution process?

A) Choose one version and discard the other  
B) Manually edit files to combine both functionalities  
C) Abort the merge and start over  
D) Use git reset to undo changes  

<details>
<summary>Answer</summary>

**B) Manually edit files to combine both functionalities**

Proper conflict resolution involves understanding both changes and combining them appropriately, not just picking one side.
</details>

---

## Question 3: Release Branch Purpose
What is the main purpose of the `release/v1.0.0` branch in the project?

A) Develop new features  
B) Fix bugs in production  
C) Prepare and stabilize code for release  
D) Backup the main branch  

<details>
<summary>Answer</summary>

**C) Prepare and stabilize code for release**

Release branches are used to prepare code for production, including version updates, documentation, and final testing.
</details>

---

## Question 4: Hotfix Workflow
Why was the hotfix branch created from `main` instead of `develop`?

A) It's faster to create from main  
B) Hotfixes need to fix current production code  
C) Develop branch might have unstable code  
D) Both B and C are correct  

<details>
<summary>Answer</summary>

**D) Both B and C are correct**

Hotfixes are created from `main` because they need to fix the current production code, and `develop` may contain unstable features not yet released.
</details>

---

## Question 5: Code Review Process
What should be included in a comprehensive code review checklist?

A) Only functionality testing  
B) Only code style checking  
C) Functionality, tests, documentation, security, and performance  
D) Only automated test results  

<details>
<summary>Answer</summary>

**C) Functionality, tests, documentation, security, and performance**

Comprehensive code reviews should cover all aspects of code quality, not just one dimension.
</details>

---

## Question 6: Version Tagging
What's the difference between `v1.0.0` and `v1.0.1` in semantic versioning?

A) Major version vs minor version  
B) Minor version vs patch version  
C) No difference, just different names  
D) Release version vs hotfix version  

<details>
<summary>Answer</summary>

**B) Minor version vs patch version**

In semantic versioning (MAJOR.MINOR.PATCH), v1.0.1 is a patch release that fixes bugs in v1.0.0 without adding new features.
</details>

---

## Question 7: Feature Integration
When integrating multiple features into develop, what's the best practice?

A) Merge all features simultaneously  
B) Merge features one at a time and test each integration  
C) Squash all commits into one  
D) Rebase all features onto main  

<details>
<summary>Answer</summary>

**B) Merge features one at a time and test each integration**

Integrating features incrementally allows you to identify and resolve conflicts more easily and test each integration step.
</details>

---

## Question 8: Documentation Strategy
Why is it important to update documentation during the release process?

A) It's required by Git  
B) Documentation should match the released functionality  
C) It makes the repository look professional  
D) It's only needed for public repositories  

<details>
<summary>Answer</summary>

**B) Documentation should match the released functionality**

Documentation should accurately reflect what users will experience in the released version, making it essential to update during releases.
</details>

---

## Question 9: Branch Cleanup
After completing the release, why were the feature branches deleted?

A) To save disk space  
B) They're no longer needed and clutter the repository  
C) Git requires branch deletion  
D) To prevent accidental commits  

<details>
<summary>Answer</summary>

**B) They're no longer needed and clutter the repository**

Once features are integrated and released, the feature branches serve no purpose and should be cleaned up to maintain a tidy repository.
</details>

---

## Question 10: Project Structure
Why was the project organized with separate modules (data_loader, analytics, visualizer, api)?

A) Git requires this structure  
B) It follows separation of concerns and makes code maintainable  
C) It's required for Python projects  
D) It makes testing easier only  

<details>
<summary>Answer</summary>

**B) It follows separation of concerns and makes code maintainable**

Modular structure makes code easier to understand, test, maintain, and allows team members to work on different components simultaneously.
</details>

---

## Scoring

- **8-10 correct**: Excellent! You understand collaborative Git workflows thoroughly.
- **6-7 correct**: Good job! Review the concepts you missed.
- **4-5 correct**: You're learning. Practice more with real projects.
- **Below 4**: Review the project walkthrough and try building it yourself.

## Reflection Questions

Consider these questions about your project experience:

1. **Workflow Efficiency**: Which part of the Gitflow process felt most natural? Most challenging?

2. **Conflict Resolution**: How would you handle conflicts differently in a real team environment?

3. **Code Quality**: What additional quality checks would you add to the review process?

4. **Release Management**: How would you improve the release preparation process?

5. **Team Collaboration**: What communication strategies would help in a real collaborative project?

## Next Steps

Week 3 starts with Docker fundamentals. You'll containerize this analytics platform and learn how Git workflows integrate with containerized development and deployment processes.

## Key Takeaways

- Gitflow provides structure for complex collaborative development
- Systematic conflict resolution prevents integration problems
- Code reviews ensure quality and knowledge sharing
- Proper release management includes versioning, documentation, and testing
- Hotfix processes enable rapid response to production issues
- Clean repository management improves team productivity
