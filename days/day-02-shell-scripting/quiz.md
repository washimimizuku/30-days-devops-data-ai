# Day 2: Shell Scripting Basics - Quiz

Test your understanding of shell scripting concepts. Choose the best answer for each question.

## Question 1: Shebang
What is the correct shebang for a bash script?

a) `#/bin/bash`
b) `#!/bin/bash`
c) `#! /bin/bash`
d) `# !/bin/bash`

<details>
<summary>Answer</summary>
<b>b) `#!/bin/bash`</b>

The shebang must start with `#!` immediately followed by the interpreter path with no spaces.
</details>

## Question 2: Variable Assignment
Which variable assignment is correct in bash?

a) `name = "Alice"`
b) `name= "Alice"`
c) `name ="Alice"`
d) `name="Alice"`

<details>
<summary>Answer</summary>
<b>d) `name="Alice"`</b>

Variable assignment in bash cannot have spaces around the equals sign.
</details>

## Question 3: Command Substitution
What's the modern way to capture command output in a variable?

a) `date=`date``
b) `date=$(date)`
c) `date=${date}`
d) `date=date`

<details>
<summary>Answer</summary>
<b>b) `date=$(date)`</b>

`$()` is the modern, preferred syntax for command substitution. Backticks work but are deprecated.
</details>

## Question 4: File Testing
Which test checks if a file exists and is readable?

a) `[ -f file ] && [ -r file ]`
b) `[ -e file ] || [ -r file ]`
c) `[ -f file ] || [ -r file ]`
d) `[ -d file ] && [ -r file ]`

<details>
<summary>Answer</summary>
<b>a) `[ -f file ] && [ -r file ]`</b>

`-f` tests if it's a regular file (exists), `-r` tests if readable. `&&` means both conditions must be true.
</details>

## Question 5: Exit Codes
What does `exit 0` mean in a script?

a) Exit with error
b) Exit successfully
c) Exit and restart
d) Exit after 0 seconds

<details>
<summary>Answer</summary>
<b>b) Exit successfully</b>

Exit code 0 indicates success. Non-zero exit codes (1, 2, etc.) indicate errors.
</details>

## Question 6: Loop Syntax
Which for loop syntax is correct for iterating over CSV files?

a) `for file in *.csv { echo $file }`
b) `for file in *.csv; do echo $file; done`
c) `for (file in *.csv) echo $file`
d) `for file = *.csv do echo $file end`

<details>
<summary>Answer</summary>
<b>b) `for file in *.csv; do echo $file; done`</b>

Bash for loops use `for var in list; do ... done` syntax.
</details>

## Question 7: String Comparison
How do you check if a string variable is empty?

a) `[ $string == "" ]`
b) `[ -z "$string" ]`
c) `[ empty $string ]`
d) `[ $string -eq null ]`

<details>
<summary>Answer</summary>
<b>b) `[ -z "$string" ]`</b>

`-z` tests if string length is zero (empty). Always quote variables to handle spaces safely.
</details>

## Question 8: Function Return
What's the correct way to return a value from a function?

a) `return "success"`
b) `return 0`
c) `echo "success"; return 0`
d) Both b and c are correct

<details>
<summary>Answer</summary>
<b>d) Both b and c are correct</b>

Functions return exit codes (0-255) with `return`. To return strings, use `echo` then `return 0`.
</details>

## Question 9: Conditional Logic
What does this condition check: `[ $count -gt 10 ] && [ -f "data.csv" ]`?

a) Count greater than 10 OR file exists
b) Count greater than 10 AND file exists
c) Count greater than 10 XOR file exists
d) Count not equal to 10 AND file exists

<details>
<summary>Answer</summary>
<b>b) Count greater than 10 AND file exists</b>

`-gt` means "greater than", `&&` means "AND" - both conditions must be true.
</details>

## Question 10: Best Practices
Which is the safest way to use a variable in a script?

a) `echo $filename`
b) `echo "$filename"`
c) `echo ${filename}`
d) `echo '$filename'`

<details>
<summary>Answer</summary>
<b>b) `echo "$filename"`</b>

Double quotes preserve the variable value while protecting against word splitting and pathname expansion. Single quotes would print the literal text.
</details>

## Practical Questions

### Question 11: Script Analysis
What will this script output if run with `./script.sh data.csv`?

```bash
#!/bin/bash
file=$1
if [ -f "$file" ]; then
    lines=$(wc -l < "$file")
    echo "File has $lines lines"
else
    echo "File not found"
fi
```

a) Always "File not found"
b) "File has X lines" if data.csv exists
c) Syntax error
d) Nothing

<details>
<summary>Answer</summary>
<b>b) "File has X lines" if data.csv exists</b>

The script checks if the first argument is a file, counts lines if it exists, or reports "File not found".
</details>

### Question 12: Debugging
What's wrong with this code?

```bash
count = 5
if [ $count -eq 5 ]; then
    echo "Count is five"
fi
```

a) Missing shebang
b) Space around equals in assignment
c) Wrong comparison operator
d) Missing quotes around variable

<details>
<summary>Answer</summary>
<b>b) Space around equals in assignment</b>

`count = 5` should be `count=5`. Spaces around `=` in variable assignment cause errors in bash.
</details>

## Score Your Knowledge

- **10-12 correct**: Excellent! You've mastered shell scripting basics
- **7-9 correct**: Good understanding, review the concepts you missed
- **4-6 correct**: Fair grasp, practice more with the exercises
- **0-3 correct**: Review the lesson material and try the exercises again

## Next Steps

1. Practice writing your own shell scripts
2. Experiment with different conditional tests
3. Try combining multiple concepts in one script
4. Move on to Day 3: Text Processing Tools

Remember: The best way to learn shell scripting is by doing. Start with simple scripts and gradually add complexity!
