# Day 6: Make and Task Automation - Quiz

Test your understanding of Make, Makefiles, and task automation concepts.

## Question 1: Makefile Syntax
What character must be used to indent commands in a Makefile?

a) 4 spaces
b) 2 spaces  
c) Tab character
d) Any whitespace

<details>
<summary>Answer</summary>
<b>c) Tab character</b>

Make requires commands to be indented with a tab character, not spaces. This is a common source of errors.
</details>

## Question 2: Target Dependencies
What does this Makefile rule mean: `output.txt: input.txt script.py`?

a) output.txt depends on input.txt and script.py
b) input.txt creates output.txt using script.py
c) script.py processes input.txt and output.txt
d) All files are equivalent

<details>
<summary>Answer</summary>
<b>a) output.txt depends on input.txt and script.py</b>

The target (output.txt) depends on the prerequisites (input.txt and script.py). Make will rebuild the target if any prerequisite is newer.
</details>

## Question 3: Automatic Variables
In a Makefile rule, what does `$@` represent?

a) All dependencies
b) First dependency
c) Target name
d) Last dependency

<details>
<summary>Answer</summary>
<b>c) Target name</b>

`$@` is the automatic variable for the target name. `$<` is first dependency, `$^` is all dependencies.
</details>

## Question 4: Phony Targets
What is the purpose of `.PHONY: clean` in a Makefile?

a) Makes clean target run faster
b) Tells Make that clean is not a file
c) Makes clean target run in parallel
d) Hides the clean target from help

<details>
<summary>Answer</summary>
<b>b) Tells Make that clean is not a file</b>

`.PHONY` declares targets that don't create files with the same name, preventing conflicts if such files exist.
</details>

## Question 5: Pattern Rules
What does this pattern rule do: `%.csv: %.json`?

a) Converts all CSV files to JSON
b) Converts any JSON file to CSV with same basename
c) Processes CSV and JSON files together
d) Creates a dependency between CSV and JSON files

<details>
<summary>Answer</summary>
<b>b) Converts any JSON file to CSV with same basename</b>

Pattern rules use `%` as a wildcard. This rule would convert `data.json` to `data.csv`.
</details>

## Question 6: Variable Assignment
What's the difference between `VAR = value` and `VAR := value` in Make?

a) No difference
b) `:=` is immediate assignment, `=` is recursive
c) `:=` is for strings, `=` is for numbers
d) `:=` is deprecated syntax

<details>
<summary>Answer</summary>
<b>b) `:=` is immediate assignment, `=` is recursive</b>

`:=` evaluates the value immediately, while `=` evaluates when the variable is used (recursive expansion).
</details>

## Question 7: Parallel Execution
How do you enable parallel execution in Make?

a) `make -p`
b) `make -j4`
c) `make --parallel`
d) `make -async`

<details>
<summary>Answer</summary>
<b>b) `make -j4`</b>

`-j` followed by a number enables parallel execution with that many jobs. `-j` alone uses unlimited parallelism.
</details>

## Question 8: Default Target
How do you specify the default target in a Makefile?

a) Use `.DEFAULT: target`
b) Put it first in the file
c) Use `.DEFAULT_GOAL := target`
d) Both b and c work

<details>
<summary>Answer</summary>
<b>d) Both b and c work</b>

The first target in a Makefile is the default, but you can also explicitly set it with `.DEFAULT_GOAL`.
</details>

## Question 9: File Timestamps
When does Make rebuild a target?

a) Every time you run make
b) When target is older than any dependency
c) When target doesn't exist
d) Both b and c

<details>
<summary>Answer</summary>
<b>d) Both b and c</b>

Make rebuilds targets when they don't exist or when any dependency is newer than the target.
</details>

## Question 10: Alternative Tools
What is `just` in the context of task automation?

a) A Make replacement with simpler syntax
b) A JavaScript task runner
c) A Python build tool
d) A shell script generator

<details>
<summary>Answer</summary>
<b>a) A Make replacement with simpler syntax</b>

`just` is a modern command runner that provides simpler syntax than Make for task automation.
</details>

## Practical Questions

### Question 11: Data Pipeline
You have a data pipeline: raw data → cleaned data → analysis → report. How would you structure this in Make?

a) One target that does everything
b) Separate targets with proper dependencies
c) Multiple Makefiles for each step
d) Shell scripts instead of Make

<details>
<summary>Answer</summary>
<b>b) Separate targets with proper dependencies</b>

Each step should be a separate target with dependencies on previous steps, allowing incremental builds and parallel execution.
</details>

### Question 12: Error Handling
What happens if a command in a Makefile rule fails?

a) Make continues with the next command
b) Make stops and reports an error
c) Make skips to the next target
d) Make ignores the error

<details>
<summary>Answer</summary>
<b>b) Make stops and reports an error</b>

By default, Make stops execution if any command returns a non-zero exit code. Use `-` prefix to ignore errors.
</details>

### Question 13: Variable Scope
Where can you define variables in a Makefile?

a) Only at the top of the file
b) Anywhere in the file
c) In a separate config file
d) Both b and c

<details>
<summary>Answer</summary>
<b>d) Both b and c</b>

Variables can be defined anywhere in a Makefile and can also be included from separate files using `include`.
</details>

### Question 14: Debugging
How do you debug a Makefile to see what Make is doing?

a) `make --debug`
b) `make -n` (dry run)
c) `make -d` (debug info)
d) Both b and c

<details>
<summary>Answer</summary>
<b>d) Both b and c</b>

`-n` shows what would be executed without running commands, `-d` shows detailed debug information.
</details>

### Question 15: Performance
Your Makefile is slow because it rebuilds everything. What's the likely cause?

a) Missing dependencies
b) Incorrect timestamps
c) Phony targets not declared
d) All of the above

<details>
<summary>Answer</summary>
<b>d) All of the above</b>

All these issues can cause unnecessary rebuilds. Proper dependencies, timestamp handling, and phony declarations are crucial.
</details>

## Advanced Questions

### Question 16: Complex Dependencies
You want to process multiple CSV files in parallel but generate a single report from all results. How do you structure this?

a) Sequential processing only
b) Parallel processing with proper dependency chain
c) Separate Makefiles for each file
d) Use shell scripts instead

<details>
<summary>Answer</summary>
<b>b) Parallel processing with proper dependency chain</b>

Process files in parallel, then have the report target depend on all processed files to ensure they complete first.
</details>

### Question 17: Environment Configuration
How do you handle different configurations for development vs production?

a) Separate Makefiles
b) Environment variables
c) Include files
d) All of the above

<details>
<summary>Answer</summary>
<b>d) All of the above</b>

All approaches work: separate Makefiles, environment variables for configuration, and include files for shared rules.
</details>

### Question 18: Modern Alternatives
When might you choose `just` over Make?

a) Simpler syntax requirements
b) Better error messages
c) No tab requirement
d) All of the above

<details>
<summary>Answer</summary>
<b>d) All of the above</b>

`just` offers simpler syntax, better error messages, and doesn't require tabs, making it more user-friendly than Make.
</details>

### Question 19: Integration
How do you integrate Make with CI/CD pipelines?

a) Run make commands in CI scripts
b) Use Make for local development only
c) Replace Make with CI-specific tools
d) Make is incompatible with CI/CD

<details>
<summary>Answer</summary>
<b>a) Run make commands in CI scripts</b>

Make integrates well with CI/CD by providing consistent commands that work both locally and in CI environments.
</details>

### Question 20: Best Practices
What's the most important best practice for Makefiles in data pipelines?

a) Use only phony targets
b) Proper dependency management
c) Avoid variables
d) Keep everything in one target

<details>
<summary>Answer</summary>
<b>b) Proper dependency management</b>

Correct dependencies ensure incremental builds, parallel execution, and reliable pipeline execution.
</details>

## Score Your Knowledge

- **18-20 correct**: Expert level! You've mastered Make and task automation
- **15-17 correct**: Advanced understanding, ready for complex pipelines
- **12-14 correct**: Good grasp, practice more advanced scenarios
- **9-11 correct**: Basic understanding, review concepts and practice
- **0-8 correct**: Review the lesson and work through exercises again

## Real-World Applications

Practice these scenarios:

1. **ETL Pipeline**: Create Make pipeline for extract, transform, load operations
2. **ML Workflow**: Automate data prep, training, validation, and deployment
3. **Report Generation**: Build system for automated report generation
4. **Multi-format Processing**: Handle CSV, JSON, Parquet files in one pipeline
5. **Environment Management**: Set up dev/staging/prod configurations

## Best Practices Checklist

- ✅ Use proper dependencies between targets
- ✅ Declare phony targets with `.PHONY`
- ✅ Use automatic variables (`$@`, `$<`, `$^`)
- ✅ Enable parallel execution where possible
- ✅ Include help target with documentation
- ✅ Handle errors appropriately
- ✅ Use pattern rules for repetitive tasks
- ✅ Keep Makefiles readable and documented
- ✅ Test with dry run (`make -n`) first
- ✅ Consider modern alternatives for new projects

## Next Steps

1. Build a complete data processing pipeline with Make
2. Explore advanced Make features (functions, conditionals)
3. Try modern alternatives like `just` or `invoke`
4. Integrate with Docker and CI/CD systems
5. Move on to Day 7: Mini Project - Automated Data Pipeline

Remember: Make is a powerful tool for automating repetitive tasks. Master the fundamentals, then explore modern alternatives that might better fit your workflow!
