# Day 27 Quiz: Debugging and Profiling

Test your understanding of debugging and profiling tools for data applications.

## Questions

### 1. Which pdb command steps into a function call during debugging?
a) `n` (next)
b) `s` (step)
c) `c` (continue)
d) `l` (list)

### 2. What does cProfile measure in Python applications?
a) Memory usage only
b) CPU time and function calls
c) Disk I/O operations
d) Network latency

### 3. Which tool is best for line-by-line performance profiling?
a) cProfile
b) pdb
c) line_profiler
d) tracemalloc

### 4. What does `tracemalloc` track in Python?
a) CPU usage
b) Memory allocations
c) Function calls
d) File operations

### 5. Which pandas operation is generally more memory efficient?
a) `df.apply(lambda x: x**2)`
b) `df ** 2`
c) `[x**2 for x in df.values]`
d) `df.iterrows()` with manual calculation

### 6. What is the purpose of `pdb.set_trace()`?
a) Start performance profiling
b) Set a breakpoint for debugging
c) Measure memory usage
d) Log execution time

### 7. Which data type conversion typically saves the most memory in pandas?
a) int64 to int32
b) float64 to float32
c) object to category (for repeated values)
d) All save equal amounts

### 8. What does the `memory_profiler` decorator `@profile` do?
a) Optimizes memory usage automatically
b) Shows line-by-line memory consumption
c) Prevents memory leaks
d) Compresses data in memory

### 9. Which approach is best for debugging production data pipelines?
a) Print statements everywhere
b) Interactive debugging with pdb
c) Structured logging with context
d) Memory profiling only

### 10. What is the main benefit of using context managers for profiling?
a) Faster execution
b) Automatic cleanup and resource management
c) Better accuracy
d) Reduced memory usage

## Answers

### 1. b) `s` (step)
**Explanation**: The `s` command in pdb steps into function calls, allowing you to debug inside called functions. `n` (next) executes the next line without stepping into functions.

### 2. b) CPU time and function calls
**Explanation**: cProfile measures CPU time spent in functions and tracks the number of calls to each function, helping identify performance bottlenecks.

### 3. c) line_profiler
**Explanation**: line_profiler (used with `@profile` decorator and `kernprof`) provides line-by-line timing information, showing exactly which lines are slow.

### 4. b) Memory allocations
**Explanation**: tracemalloc tracks memory allocations and deallocations, helping identify memory usage patterns and potential memory leaks.

### 5. b) `df ** 2`
**Explanation**: Vectorized operations like `df ** 2` are much more memory and CPU efficient than apply functions or manual iteration.

### 6. b) Set a breakpoint for debugging
**Explanation**: `pdb.set_trace()` sets a breakpoint where execution will pause and drop into the interactive debugger.

### 7. c) object to category (for repeated values)
**Explanation**: Converting object columns with repeated values to category type can save significant memory, especially with low cardinality data.

### 8. b) Shows line-by-line memory consumption
**Explanation**: The `@profile` decorator from memory_profiler shows memory usage for each line of the decorated function.

### 9. c) Structured logging with context
**Explanation**: Production systems need structured logging that provides context without stopping execution, unlike interactive debugging.

### 10. b) Automatic cleanup and resource management
**Explanation**: Context managers ensure proper setup and cleanup of profiling resources, even if exceptions occur.

## Scoring

- **8-10 correct**: Excellent! You have a strong understanding of debugging and profiling techniques.
- **6-7 correct**: Good job! Review the areas you missed, particularly around memory optimization.
- **4-5 correct**: You're making progress. Focus on understanding the different tools and their specific use cases.
- **0-3 correct**: Review the lesson material and practice with the debugging and profiling tools.

## Key Takeaways

1. **Interactive debugging** with pdb is essential for finding bugs
2. **Performance profiling** identifies bottlenecks in data processing
3. **Memory profiling** prevents out-of-memory errors in large datasets
4. **Vectorized operations** are much faster than loops in pandas
5. **Data type optimization** can significantly reduce memory usage
6. **Structured logging** is crucial for production debugging
7. **Context managers** provide clean resource management
8. **Line-by-line profiling** pinpoints exact performance issues
9. **Memory tracking** helps optimize data pipeline efficiency
10. **Production debugging** requires different strategies than development

## Common Data Pipeline Issues

- **Memory leaks**: Use tracemalloc to track allocations
- **Slow processing**: Profile with cProfile to find bottlenecks
- **Data type inefficiency**: Optimize pandas dtypes for memory
- **Algorithm complexity**: Analyze Big O complexity of operations
- **I/O bottlenecks**: Profile file reading/writing operations
- **Vectorization opportunities**: Replace loops with pandas operations
- **Memory fragmentation**: Use chunked processing for large datasets
- **Resource cleanup**: Ensure proper garbage collection and resource management
