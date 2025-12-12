#!/bin/bash

# Day 27: Debugging and Profiling - Performance Optimization
# Hands-on exercises for mastering debugging and profiling tools

set -e

echo "🐛 Day 27: Debugging and Profiling Exercises"
echo "============================================="

# Exercise 1: Basic Debugging with pdb
echo -e "\n🔍 Exercise 1: Basic Debugging with pdb"
echo "Learning interactive debugging techniques..."

mkdir -p exercise1-debugging
cd exercise1-debugging

# Create sample data processing script with bugs
cat > buggy_data_processor.py << 'EOF'
#!/usr/bin/env python3
"""
Buggy data processor for debugging practice
Contains intentional bugs to practice debugging
"""

import pandas as pd
import numpy as np
import pdb

def load_data(filename):
    """Load data from CSV file"""
    print(f"Loading data from {filename}")
    try:
        data = pd.read_csv(filename)
        return data
    except FileNotFoundError:
        print(f"Error: File {filename} not found")
        return None

def clean_data(data):
    """Clean the data - contains bugs!"""
    if data is None:
        return None
    
    print("Cleaning data...")
    
    # Bug 1: Division by zero
    data['normalized'] = data['value'] / data['value'].mean()
    
    # Bug 2: Index error
    data['category_code'] = data['category'].map({'A': 1, 'B': 2, 'C': 3})
    
    # Bug 3: Memory inefficient operation
    cleaned = []
    for index, row in data.iterrows():
        if row['value'] > 0:
            cleaned.append(row)
    
    return pd.DataFrame(cleaned)

def analyze_data(data):
    """Analyze cleaned data"""
    if data is None or len(data) == 0:
        return None
    
    print("Analyzing data...")
    
    # Set breakpoint for debugging
    pdb.set_trace()
    
    analysis = {
        'count': len(data),
        'mean_value': data['value'].mean(),
        'std_value': data['value'].std(),
        'categories': data['category'].value_counts().to_dict()
    }
    
    return analysis

def main():
    # Create sample data
    sample_data = pd.DataFrame({
        'value': [10, 20, 0, 40, -5, 30],  # Contains zero and negative
        'category': ['A', 'B', 'D', 'A', 'B', 'C']  # Contains 'D' not in mapping
    })
    sample_data.to_csv('sample_data.csv', index=False)
    
    # Process data
    data = load_data('sample_data.csv')
    cleaned = clean_data(data)
    result = analyze_data(cleaned)
    
    print("Analysis result:", result)

if __name__ == "__main__":
    main()
EOF

# Create debugging guide
cat > debugging_guide.md << 'EOF'
# Debugging Guide

## Running the Buggy Script

1. Run the script: `python buggy_data_processor.py`
2. When pdb breakpoint is hit, try these commands:
   - `l` - list current code
   - `n` - next line
   - `s` - step into function
   - `p variable_name` - print variable
   - `pp variable_name` - pretty print variable
   - `c` - continue execution
   - `q` - quit debugger

## Common Bugs to Find

1. **Division by zero**: When mean is zero
2. **KeyError**: Unmapped category values
3. **Performance issue**: Inefficient DataFrame construction

## Debugging Tips

- Use `pdb.set_trace()` to set breakpoints
- Examine variables at each step
- Check data types and shapes
- Validate assumptions about data
EOF

echo "✅ Created buggy script for debugging practice"
echo "📖 See debugging_guide.md for instructions"

cd ..

# Exercise 2: Performance Profiling with cProfile
echo -e "\n⚡ Exercise 2: Performance Profiling with cProfile"
echo "Learning to identify performance bottlenecks..."

mkdir -p exercise2-profiling
cd exercise2-profiling

# Create performance test script
cat > performance_test.py << 'EOF'
#!/usr/bin/env python3
"""
Performance test script for profiling practice
Contains various performance bottlenecks
"""

import pandas as pd
import numpy as np
import time
import cProfile
import pstats
import io

def slow_data_generation():
    """Inefficient data generation"""
    data = []
    for i in range(10000):
        row = {
            'id': i,
            'value': np.random.randn(),
            'category': np.random.choice(['A', 'B', 'C']),
            'timestamp': time.time()
        }
        data.append(row)
    return pd.DataFrame(data)

def fast_data_generation():
    """Efficient data generation"""
    n = 10000
    return pd.DataFrame({
        'id': range(n),
        'value': np.random.randn(n),
        'category': np.random.choice(['A', 'B', 'C'], n),
        'timestamp': time.time()
    })

def inefficient_processing(df):
    """Inefficient data processing"""
    result = []
    for index, row in df.iterrows():
        if row['value'] > 0:
            processed_row = {
                'id': row['id'],
                'squared_value': row['value'] ** 2,
                'category': row['category']
            }
            result.append(processed_row)
    return pd.DataFrame(result)

def efficient_processing(df):
    """Efficient data processing"""
    mask = df['value'] > 0
    result = df[mask].copy()
    result['squared_value'] = result['value'] ** 2
    return result[['id', 'squared_value', 'category']]

def profile_function(func, *args, **kwargs):
    """Profile a function and return formatted results"""
    pr = cProfile.Profile()
    pr.enable()
    
    result = func(*args, **kwargs)
    
    pr.disable()
    
    # Format results
    s = io.StringIO()
    ps = pstats.Stats(pr, stream=s)
    ps.sort_stats('cumulative')
    ps.print_stats(10)  # Top 10 functions
    
    print(f"\n=== Profiling {func.__name__} ===")
    print(s.getvalue())
    
    return result

def benchmark_comparison():
    """Compare slow vs fast implementations"""
    print("🐌 Profiling slow data generation...")
    slow_data = profile_function(slow_data_generation)
    
    print("\n🚀 Profiling fast data generation...")
    fast_data = profile_function(fast_data_generation)
    
    print("\n🐌 Profiling inefficient processing...")
    profile_function(inefficient_processing, slow_data.head(1000))
    
    print("\n🚀 Profiling efficient processing...")
    profile_function(efficient_processing, fast_data.head(1000))

if __name__ == "__main__":
    benchmark_comparison()
EOF

# Run profiling
echo "Running performance profiling..."
python performance_test.py > profiling_results.txt 2>&1
echo "✅ Profiling results saved to profiling_results.txt"

cd ..

# Exercise 3: Memory Profiling
echo -e "\n🧠 Exercise 3: Memory Profiling"
echo "Learning to track memory usage..."

mkdir -p exercise3-memory-profiling
cd exercise3-memory-profiling

# Create memory profiling script
cat > memory_test.py << 'EOF'
#!/usr/bin/env python3
"""
Memory profiling test script
"""

import pandas as pd
import numpy as np
import tracemalloc
import gc
import sys

def memory_intensive_function():
    """Function that uses lots of memory"""
    print("Creating large datasets...")
    
    # Create multiple large DataFrames
    df1 = pd.DataFrame(np.random.randn(100000, 50))
    df2 = pd.DataFrame(np.random.randn(100000, 50))
    df3 = df1.copy()  # Memory duplication
    
    # Memory-intensive operations
    result = pd.concat([df1, df2, df3])
    result['sum'] = result.sum(axis=1)
    
    return result

def memory_efficient_function():
    """More memory-efficient version"""
    print("Creating datasets efficiently...")
    
    # Create one DataFrame at a time
    df1 = pd.DataFrame(np.random.randn(100000, 50))
    df1['sum'] = df1.sum(axis=1)
    
    df2 = pd.DataFrame(np.random.randn(100000, 50))
    df2['sum'] = df2.sum(axis=1)
    
    # Concatenate without creating copies
    result = pd.concat([df1, df2], ignore_index=True)
    
    return result

def track_memory_usage(func, description):
    """Track memory usage of a function"""
    print(f"\n=== {description} ===")
    
    # Start memory tracking
    tracemalloc.start()
    
    # Get initial memory
    process_memory_before = get_process_memory()
    
    # Run function
    result = func()
    
    # Get memory usage
    current, peak = tracemalloc.get_traced_memory()
    process_memory_after = get_process_memory()
    
    print(f"Traced memory - Current: {current / 1024 / 1024:.2f} MB")
    print(f"Traced memory - Peak: {peak / 1024 / 1024:.2f} MB")
    print(f"Process memory - Before: {process_memory_before:.2f} MB")
    print(f"Process memory - After: {process_memory_after:.2f} MB")
    print(f"Process memory - Increase: {process_memory_after - process_memory_before:.2f} MB")
    
    tracemalloc.stop()
    
    # Force garbage collection
    gc.collect()
    
    return result

def get_process_memory():
    """Get current process memory usage in MB"""
    try:
        import psutil
        process = psutil.Process()
        return process.memory_info().rss / 1024 / 1024
    except ImportError:
        # Fallback if psutil not available
        return 0

def main():
    print("Memory Profiling Exercise")
    print("=" * 40)
    
    # Test memory-intensive function
    result1 = track_memory_usage(
        memory_intensive_function, 
        "Memory Intensive Function"
    )
    
    # Clear memory
    del result1
    gc.collect()
    
    # Test memory-efficient function
    result2 = track_memory_usage(
        memory_efficient_function, 
        "Memory Efficient Function"
    )
    
    print(f"\nFinal result shape: {result2.shape}")

if __name__ == "__main__":
    main()
EOF

# Install required packages and run
echo "Installing memory profiling dependencies..."
pip install psutil > /dev/null 2>&1 || echo "Note: psutil not installed, using fallback"

echo "Running memory profiling test..."
python memory_test.py > memory_results.txt 2>&1
echo "✅ Memory profiling results saved to memory_results.txt"

cd ..

echo "✅ Exercises 1-3 complete: Basic debugging and profiling"
echo "Continue with remaining exercises..."
