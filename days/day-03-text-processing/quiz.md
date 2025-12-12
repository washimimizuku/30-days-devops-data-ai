# Day 3: Text Processing Tools - Quiz

Test your understanding of grep, sed, awk, jq, and text processing pipelines.

## Question 1: grep Basics
Which grep command finds lines containing "error" (case insensitive) and shows line numbers?

a) `grep -n error file.txt`
b) `grep -i -n error file.txt`
c) `grep -in error file.txt`
d) Both b and c are correct

<details>
<summary>Answer</summary>
<b>d) Both b and c are correct</b>

Both `-i -n` and `-in` work. The `-i` flag makes it case insensitive, `-n` shows line numbers.
</details>

## Question 2: sed Substitution
What does `sed 's/old/new/g' file.txt` do?

a) Replace first occurrence of "old" with "new" in each line
b) Replace all occurrences of "old" with "new" in the entire file
c) Replace "old" with "new" globally in each line
d) Replace "old" with "new" and save to file

<details>
<summary>Answer</summary>
<b>c) Replace "old" with "new" globally in each line</b>

The `g` flag means "global" - replace all occurrences in each line, not just the first.
</details>

## Question 3: awk Field Separator
How do you process a CSV file with awk to print the second column?

a) `awk '{print $2}' file.csv`
b) `awk -F',' '{print $2}' file.csv`
c) `awk -d',' '{print $2}' file.csv`
d) `awk --delimiter=',' '{print $2}' file.csv`

<details>
<summary>Answer</summary>
<b>b) `awk -F',' '{print $2}' file.csv`</b>

`-F` sets the field separator. For CSV files, use `-F','` to split on commas.
</details>

## Question 4: jq Array Processing
Which jq command extracts all names from this JSON: `{"users": [{"name": "Alice"}, {"name": "Bob"}]}`?

a) `jq '.users.name'`
b) `jq '.users[].name'`
c) `jq '.users[*].name'`
d) Both b and c are correct

<details>
<summary>Answer</summary>
<b>d) Both b and c are correct</b>

Both `[]` and `[*]` iterate over array elements. `.users[].name` and `.users[*].name` both work.
</details>

## Question 5: Pipeline Combination
What does this pipeline do: `grep "ERROR" log.txt | awk '{print $1}' | sort | uniq -c`?

a) Count unique error messages
b) Count errors by timestamp
c) Sort error messages
d) Find first occurrence of each error

<details>
<summary>Answer</summary>
<b>b) Count errors by timestamp</b>

It finds ERROR lines, extracts the first field (timestamp), sorts them, and counts unique occurrences.
</details>

## Question 6: sed Line Operations
Which sed command deletes lines 2 through 5?

a) `sed '2-5d' file.txt`
b) `sed '2,5d' file.txt`
c) `sed 'd/2,5/' file.txt`
d) `sed 'delete 2-5' file.txt`

<details>
<summary>Answer</summary>
<b>b) `sed '2,5d' file.txt`</b>

In sed, `2,5d` means delete lines 2 through 5. The comma indicates a range.
</details>

## Question 7: awk Calculations
How do you sum the values in the third column of a file?

a) `awk '{sum += $3} END {print sum}' file.txt`
b) `awk '{total = total + $3} END {print total}' file.txt`
c) `awk 'BEGIN{sum=0} {sum += $3} END {print sum}' file.txt`
d) All of the above work

<details>
<summary>Answer</summary>
<b>d) All of the above work</b>

All three approaches correctly sum column 3. Variables are automatically initialized to 0 in awk.
</details>

## Question 8: grep Regular Expressions
Which pattern matches lines starting with a digit?

a) `grep "^[0-9]" file.txt`
b) `grep "^\d" file.txt`
c) `grep "^[0-9]*" file.txt`
d) `grep "^digit" file.txt`

<details>
<summary>Answer</summary>
<b>a) `grep "^[0-9]" file.txt`</b>

`^` means start of line, `[0-9]` matches any digit. `\d` doesn't work in basic grep (need `-E` for extended regex).
</details>

## Question 9: jq Filtering
How do you select objects where age > 25 from an array?

a) `jq '.[] | select(.age > 25)'`
b) `jq 'select(.age > 25)'`
c) `jq '.[] where .age > 25'`
d) `jq 'filter(.age > 25)'`

<details>
<summary>Answer</summary>
<b>a) `jq '.[] | select(.age > 25)'`</b>

`.[]` iterates over array elements, `select()` filters based on condition.
</details>

## Question 10: awk Built-in Variables
What does `NR` represent in awk?

a) Number of records processed so far
b) Number of fields in current record
c) Current record number
d) Both a and c are correct

<details>
<summary>Answer</summary>
<b>d) Both a and c are correct</b>

`NR` is the current record (line) number, which equals the number of records processed so far.
</details>

## Practical Questions

### Question 11: Data Processing
You have a CSV with columns: name,age,salary. How do you find people with salary > 50000?

a) `awk -F',' '$3 > 50000' file.csv`
b) `awk -F',' 'NR>1 && $3 > 50000' file.csv`
c) `grep -E ',5[0-9]{4},' file.csv`
d) Both a and b work, but b is better

<details>
<summary>Answer</summary>
<b>d) Both a and b work, but b is better</b>

Option b is better because `NR>1` skips the header row. Option a would try to compare the header "salary" > 50000.
</details>

### Question 12: Log Analysis
Which command counts unique IP addresses in an Apache log?

a) `awk '{print $1}' access.log | sort | uniq | wc -l`
b) `awk '{print $1}' access.log | uniq | wc -l`
c) `cut -d' ' -f1 access.log | sort | uniq -c`
d) Both a and c give useful results

<details>
<summary>Answer</summary>
<b>d) Both a and c give useful results</b>

Option a counts unique IPs, option c shows count per IP. Option b is wrong (needs sort before uniq).
</details>

### Question 13: JSON Transformation
How do you convert this JSON to CSV: `[{"name":"Alice","age":25},{"name":"Bob","age":30}]`?

a) `jq -r '.[] | [.name, .age] | @csv'`
b) `jq '.[] | .name + "," + .age'`
c) `jq -r 'map([.name, .age]) | @csv'`
d) Both a and c work

<details>
<summary>Answer</summary>
<b>a) `jq -r '.[] | [.name, .age] | @csv'`</b>

This iterates over array elements and formats each as CSV. Option c would create one CSV line with all data.
</details>

### Question 14: Complex Pipeline
What's wrong with this pipeline: `cat file.txt | grep "error" | sort | uniq -c | sort -n`?

a) Nothing, it's correct
b) Should use `sort -nr` for descending order
c) `cat` is unnecessary
d) Both b and c are issues

<details>
<summary>Answer</summary>
<b>d) Both b and c are issues</b>

`cat` is unnecessary (grep can read files directly), and `sort -nr` would show highest counts first.
</details>

### Question 15: Performance
Which is more efficient for large files?

a) `grep "pattern" file.txt | wc -l`
b) `grep -c "pattern" file.txt`
c) `awk '/pattern/ {count++} END {print count}' file.txt`
d) They're all equivalent

<details>
<summary>Answer</summary>
<b>b) `grep -c "pattern" file.txt`</b>

`grep -c` counts matches without outputting lines, making it more efficient than piping to `wc -l`.
</details>

## Score Your Knowledge

- **13-15 correct**: Expert level! You've mastered text processing
- **10-12 correct**: Advanced understanding, ready for complex tasks
- **7-9 correct**: Good grasp, practice more complex pipelines
- **4-6 correct**: Basic understanding, review concepts and practice
- **0-3 correct**: Review the lesson and work through exercises again

## Practical Challenges

Try these real-world scenarios:

1. **Log Analysis**: Find the top 5 IP addresses by request count in a web server log
2. **Data Cleaning**: Remove duplicate entries from a CSV file based on email column
3. **JSON Processing**: Extract nested data and calculate aggregates
4. **Performance Monitoring**: Analyze system logs to find peak usage hours
5. **Data Validation**: Check CSV files for missing values and format issues

## Next Steps

1. Practice combining multiple tools in pipelines
2. Learn regular expressions for advanced pattern matching
3. Explore csvkit for specialized CSV operations
4. Move on to Day 4: Process Management

Remember: Text processing is fundamental to data engineering. Master these tools and you'll handle any data format efficiently!
