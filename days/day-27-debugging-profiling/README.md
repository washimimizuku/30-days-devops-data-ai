# Day 27: Debugging and Profiling - Performance Optimization

**Duration**: 1 hour  
**Prerequisites**: Python basics, data processing concepts  
**Learning Goal**: Master debugging and profiling tools for optimizing data pipeline performance

## Overview

Debugging and profiling are essential for data engineers working with large datasets and complex pipelines. You'll learn to identify bottlenecks, memory issues, and performance problems using Python's built-in tools and specialized libraries.

## Why Debugging and Profiling Matter

**Common data pipeline issues**:
- Slow data processing and transformations
- Memory leaks in long-running processes
- CPU bottlenecks in computation-heavy tasks
- I/O bottlenecks in data loading/saving
- Inefficient algorithms and data structures

**Benefits of systematic debugging**:
- Faster pipeline execution
- Reduced resource consumption
- Better scalability and reliability
- Lower cloud computing costs
- Improved user experience

## Core Concepts

### Types of Performance Issues

| Issue Type | Symptoms | Tools |
|------------|----------|-------|
| **CPU Bound** | High CPU usage, slow computation | cProfile, py-spy |
| **Memory Bound** | High RAM usage, OOM errors | memory_profiler, tracemalloc |
| **I/O Bound** | Slow file/network operations | iostat, network monitoring |
| **Algorithm** | Poor time complexity | Big O analysis, benchmarking |

### Debugging vs Profiling

```python
# Debugging: Finding and fixing bugs
import pdb; pdb.set_trace()  # Interactive debugging
print(f"Debug: variable = {variable}")  # Print debugging

# Profiling: Measuring performance
import cProfile
cProfile.run('my_function()')  # Performance profiling
```

## Python Debugging Tools

### Built-in Debugger (pdb)

```python
import pdb

def process_data(data):
    pdb.set_trace()  # Breakpoint
    result = []
    for item in data:
        processed = item * 2
        result.append(processed)
    return result

# Interactive debugging commands:
# n - next line
# s - step into function
# c - continue execution
# l - list current code
# p variable - print variable
# q - quit debugger
```

### Advanced Debugging

```python
import pdb
import sys

# Post-mortem debugging
def risky_function():
    try:
        result = 10 / 0
    except:
        pdb.post_mortem()

# Conditional breakpoints
def process_batch(items):
    for i, item in enumerate(items):
        if i == 100:  # Break at specific iteration
            pdb.set_trace()
        process_item(item)

# Remote debugging
import pdb
pdb.set_trace = lambda: pdb.Pdb(stdin=sys.stdin, stdout=sys.stdout).set_trace()
```

### Logging for Debugging

```python
import logging
import time

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('pipeline.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

def process_dataset(dataset_path):
    logger.info(f"Starting processing: {dataset_path}")
    start_time = time.time()
    
    try:
        # Load data
        logger.debug("Loading data...")
        data = load_data(dataset_path)
        logger.info(f"Loaded {len(data)} records")
        
        # Process data
        logger.debug("Processing data...")
        result = transform_data(data)
        
        elapsed = time.time() - start_time
        logger.info(f"Processing completed in {elapsed:.2f}s")
        
        return result
        
    except Exception as e:
        logger.error(f"Processing failed: {e}", exc_info=True)
        raise
```

## Performance Profiling

### cProfile - Built-in Profiler

```python
import cProfile
import pstats
import io

def profile_function(func, *args, **kwargs):
    """Profile a function and return stats"""
    pr = cProfile.Profile()
    pr.enable()
    
    result = func(*args, **kwargs)
    
    pr.disable()
    
    # Get stats
    s = io.StringIO()
    ps = pstats.Stats(pr, stream=s)
    ps.sort_stats('cumulative')
    ps.print_stats()
    
    print(s.getvalue())
    return result

# Usage
def slow_data_processing():
    import pandas as pd
    import numpy as np
    
    # Generate sample data
    data = pd.DataFrame({
        'values': np.random.randn(100000),
        'categories': np.random.choice(['A', 'B', 'C'], 100000)
    })
    
    # Slow operations
    result = data.groupby('categories').agg({
        'values': ['mean', 'std', 'min', 'max']
    })
    
    return result

# Profile the function
profile_function(slow_data_processing)
```

### Line-by-Line Profiling

```python
# Install: pip install line_profiler
# Usage: kernprof -l -v script.py

@profile
def data_processing_pipeline(data):
    # Line 1: Load data
    df = pd.read_csv(data)
    
    # Line 2: Clean data
    df = df.dropna()
    
    # Line 3: Transform data
    df['processed'] = df['value'].apply(lambda x: x ** 2)
    
    # Line 4: Aggregate data
    result = df.groupby('category').sum()
    
    return result
```

### Memory Profiling

```python
# Install: pip install memory_profiler
from memory_profiler import profile
import pandas as pd
import numpy as np

@profile
def memory_intensive_function():
    # Create large dataset
    data = np.random.randn(1000000, 10)
    df = pd.DataFrame(data)
    
    # Memory-intensive operations
    df_copy = df.copy()  # Doubles memory usage
    df_processed = df.apply(lambda x: x ** 2)  # More memory
    
    # Memory-efficient alternative
    # df.loc[:, :] = df ** 2  # In-place operation
    
    return df_processed

# Run with: python -m memory_profiler script.py
```

### Built-in Memory Tracking

```python
import tracemalloc
import gc

def track_memory_usage():
    # Start tracing
    tracemalloc.start()
    
    # Your code here
    data = [i ** 2 for i in range(100000)]
    
    # Get current memory usage
    current, peak = tracemalloc.get_traced_memory()
    print(f"Current memory usage: {current / 1024 / 1024:.2f} MB")
    print(f"Peak memory usage: {peak / 1024 / 1024:.2f} MB")
    
    # Stop tracing
    tracemalloc.stop()
    
    # Force garbage collection
    gc.collect()

track_memory_usage()
```

## Data Pipeline Profiling

### Pandas Performance Optimization

```python
import pandas as pd
import numpy as np
import time

def benchmark_pandas_operations():
    # Generate test data
    n_rows = 1000000
    df = pd.DataFrame({
        'id': range(n_rows),
        'value': np.random.randn(n_rows),
        'category': np.random.choice(['A', 'B', 'C', 'D'], n_rows)
    })
    
    # Slow approach
    start = time.time()
    result_slow = df[df['value'] > 0].copy()
    result_slow['processed'] = result_slow['value'].apply(lambda x: x ** 2)
    slow_time = time.time() - start
    
    # Fast approach
    start = time.time()
    mask = df['value'] > 0
    result_fast = df[mask].copy()
    result_fast['processed'] = result_fast['value'] ** 2  # Vectorized
    fast_time = time.time() - start
    
    print(f"Slow approach: {slow_time:.3f}s")
    print(f"Fast approach: {fast_time:.3f}s")
    print(f"Speedup: {slow_time / fast_time:.1f}x")

benchmark_pandas_operations()
```

### I/O Performance Profiling

```python
import time
import pandas as pd
import pyarrow.parquet as pq

def benchmark_file_formats():
    # Generate test data
    df = pd.DataFrame({
        'id': range(100000),
        'value': np.random.randn(100000),
        'text': ['sample_text_' + str(i) for i in range(100000)]
    })
    
    formats = {
        'CSV': ('data.csv', lambda: df.to_csv('data.csv', index=False)),
        'Parquet': ('data.parquet', lambda: df.to_parquet('data.parquet')),
        'Pickle': ('data.pkl', lambda: df.to_pickle('data.pkl'))
    }
    
    results = {}
    
    for format_name, (filename, save_func) in formats.items():
        # Write benchmark
        start = time.time()
        save_func()
        write_time = time.time() - start
        
        # Read benchmark
        start = time.time()
        if format_name == 'CSV':
            pd.read_csv(filename)
        elif format_name == 'Parquet':
            pd.read_parquet(filename)
        elif format_name == 'Pickle':
            pd.read_pickle(filename)
        read_time = time.time() - start
        
        results[format_name] = {
            'write_time': write_time,
            'read_time': read_time,
            'total_time': write_time + read_time
        }
    
    # Print results
    for format_name, times in results.items():
        print(f"{format_name}: Write={times['write_time']:.3f}s, "
              f"Read={times['read_time']:.3f}s, "
              f"Total={times['total_time']:.3f}s")

benchmark_file_formats()
```

## Advanced Profiling Tools

### py-spy - Sampling Profiler

```bash
# Install: pip install py-spy

# Profile running Python process
py-spy record -o profile.svg --pid 12345

# Profile script execution
py-spy record -o profile.svg -- python data_pipeline.py

# Live profiling
py-spy top --pid 12345
```

### Scalene - Advanced Memory/CPU Profiler

```bash
# Install: pip install scalene

# Profile script with detailed memory tracking
scalene data_pipeline.py

# Profile with specific options
scalene --cpu-only data_pipeline.py
scalene --memory-only data_pipeline.py
```

### Custom Profiling Decorators

```python
import time
import functools
from memory_profiler import memory_usage

def timing_decorator(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.3f} seconds")
        return result
    return wrapper

def memory_decorator(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        mem_before = memory_usage()[0]
        result = func(*args, **kwargs)
        mem_after = memory_usage()[0]
        print(f"{func.__name__} used {mem_after - mem_before:.2f} MB")
        return result
    return wrapper

# Usage
@timing_decorator
@memory_decorator
def data_processing_task():
    import pandas as pd
    df = pd.DataFrame({'x': range(100000)})
    return df.sum()

data_processing_task()
```

## Debugging Data Issues

### Data Quality Debugging

```python
import pandas as pd
import numpy as np

def debug_data_quality(df):
    """Comprehensive data quality debugging"""
    print("=== DATA QUALITY REPORT ===")
    
    # Basic info
    print(f"Shape: {df.shape}")
    print(f"Memory usage: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    
    # Missing values
    missing = df.isnull().sum()
    if missing.any():
        print("\nMissing values:")
        print(missing[missing > 0])
    
    # Duplicates
    duplicates = df.duplicated().sum()
    if duplicates > 0:
        print(f"\nDuplicate rows: {duplicates}")
    
    # Data types
    print("\nData types:")
    print(df.dtypes.value_counts())
    
    # Numeric columns analysis
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    if len(numeric_cols) > 0:
        print("\nNumeric columns summary:")
        print(df[numeric_cols].describe())
    
    # Categorical columns analysis
    categorical_cols = df.select_dtypes(include=['object']).columns
    if len(categorical_cols) > 0:
        print("\nCategorical columns:")
        for col in categorical_cols:
            unique_count = df[col].nunique()
            print(f"{col}: {unique_count} unique values")
            if unique_count <= 10:
                print(f"  Values: {df[col].unique()}")

# Usage
sample_data = pd.DataFrame({
    'id': [1, 2, 3, 2, 5],  # Duplicate
    'value': [10, 20, np.nan, 40, 50],  # Missing value
    'category': ['A', 'B', 'C', 'B', 'D']
})

debug_data_quality(sample_data)
```

### Performance Bottleneck Detection

```python
import time
import pandas as pd
from contextlib import contextmanager

@contextmanager
def timer(description):
    start = time.time()
    yield
    elapsed = time.time() - start
    print(f"{description}: {elapsed:.3f}s")

def find_bottlenecks():
    # Generate test data
    df = pd.DataFrame({
        'id': range(100000),
        'value': np.random.randn(100000)
    })
    
    with timer("Data loading"):
        # Simulate data loading
        time.sleep(0.1)
    
    with timer("Data cleaning"):
        df_clean = df.dropna()
    
    with timer("Feature engineering"):
        df_clean['squared'] = df_clean['value'] ** 2
        df_clean['log'] = np.log(np.abs(df_clean['value']) + 1)
    
    with timer("Aggregation"):
        result = df_clean.groupby(pd.cut(df_clean['value'], bins=10)).agg({
            'squared': 'mean',
            'log': 'std'
        })
    
    with timer("Data saving"):
        # Simulate data saving
        time.sleep(0.05)
    
    return result

find_bottlenecks()
```

## Production Debugging

### Logging Best Practices

```python
import logging
import json
from datetime import datetime

class StructuredLogger:
    def __init__(self, name):
        self.logger = logging.getLogger(name)
        handler = logging.StreamHandler()
        formatter = logging.Formatter('%(message)s')
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.INFO)
    
    def log_event(self, event_type, message, **kwargs):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'message': message,
            **kwargs
        }
        self.logger.info(json.dumps(log_entry))

# Usage
logger = StructuredLogger('data_pipeline')

def process_batch(batch_id, data):
    logger.log_event('batch_start', 'Processing batch', 
                    batch_id=batch_id, record_count=len(data))
    
    try:
        # Process data
        result = transform_data(data)
        
        logger.log_event('batch_success', 'Batch processed successfully',
                        batch_id=batch_id, output_count=len(result))
        
        return result
        
    except Exception as e:
        logger.log_event('batch_error', 'Batch processing failed',
                        batch_id=batch_id, error=str(e))
        raise
```

### Health Checks and Monitoring

```python
import psutil
import time
from dataclasses import dataclass
from typing import Dict, Any

@dataclass
class SystemMetrics:
    cpu_percent: float
    memory_percent: float
    disk_usage: float
    timestamp: float

def get_system_metrics() -> SystemMetrics:
    return SystemMetrics(
        cpu_percent=psutil.cpu_percent(interval=1),
        memory_percent=psutil.virtual_memory().percent,
        disk_usage=psutil.disk_usage('/').percent,
        timestamp=time.time()
    )

def monitor_pipeline_health(func):
    def wrapper(*args, **kwargs):
        # Pre-execution metrics
        start_metrics = get_system_metrics()
        start_time = time.time()
        
        try:
            result = func(*args, **kwargs)
            
            # Post-execution metrics
            end_metrics = get_system_metrics()
            execution_time = time.time() - start_time
            
            # Log performance metrics
            print(f"Function: {func.__name__}")
            print(f"Execution time: {execution_time:.2f}s")
            print(f"CPU usage: {start_metrics.cpu_percent}% -> {end_metrics.cpu_percent}%")
            print(f"Memory usage: {start_metrics.memory_percent}% -> {end_metrics.memory_percent}%")
            
            return result
            
        except Exception as e:
            print(f"Function {func.__name__} failed: {e}")
            raise
    
    return wrapper

@monitor_pipeline_health
def data_processing_pipeline():
    # Simulate data processing
    import pandas as pd
    df = pd.DataFrame({'x': range(100000)})
    return df.sum()

data_processing_pipeline()
```

## Optimization Strategies

### Memory Optimization

```python
import pandas as pd
import numpy as np

def optimize_dataframe_memory(df):
    """Optimize DataFrame memory usage"""
    start_memory = df.memory_usage(deep=True).sum() / 1024**2
    
    for col in df.columns:
        col_type = df[col].dtype
        
        if col_type != 'object':
            c_min = df[col].min()
            c_max = df[col].max()
            
            if str(col_type)[:3] == 'int':
                if c_min > np.iinfo(np.int8).min and c_max < np.iinfo(np.int8).max:
                    df[col] = df[col].astype(np.int8)
                elif c_min > np.iinfo(np.int16).min and c_max < np.iinfo(np.int16).max:
                    df[col] = df[col].astype(np.int16)
                elif c_min > np.iinfo(np.int32).min and c_max < np.iinfo(np.int32).max:
                    df[col] = df[col].astype(np.int32)
            
            elif str(col_type)[:5] == 'float':
                if c_min > np.finfo(np.float32).min and c_max < np.finfo(np.float32).max:
                    df[col] = df[col].astype(np.float32)
        
        else:
            # Convert to category if beneficial
            if df[col].nunique() / len(df) < 0.5:
                df[col] = df[col].astype('category')
    
    end_memory = df.memory_usage(deep=True).sum() / 1024**2
    reduction = (start_memory - end_memory) / start_memory * 100
    
    print(f"Memory usage reduced from {start_memory:.2f} MB to {end_memory:.2f} MB")
    print(f"Reduction: {reduction:.1f}%")
    
    return df
```

### Parallel Processing

```python
import multiprocessing as mp
import pandas as pd
from concurrent.futures import ProcessPoolExecutor
import time

def process_chunk(chunk):
    """Process a chunk of data"""
    # Simulate processing
    return chunk.sum().sum()

def parallel_processing_example():
    # Generate large dataset
    df = pd.DataFrame(np.random.randn(1000000, 10))
    
    # Sequential processing
    start = time.time()
    sequential_result = process_chunk(df)
    sequential_time = time.time() - start
    
    # Parallel processing
    start = time.time()
    n_cores = mp.cpu_count()
    chunks = np.array_split(df, n_cores)
    
    with ProcessPoolExecutor(max_workers=n_cores) as executor:
        parallel_results = list(executor.map(process_chunk, chunks))
    
    parallel_result = sum(parallel_results)
    parallel_time = time.time() - start
    
    print(f"Sequential: {sequential_time:.3f}s")
    print(f"Parallel: {parallel_time:.3f}s")
    print(f"Speedup: {sequential_time / parallel_time:.1f}x")

parallel_processing_example()
```

## Summary

Debugging and profiling are essential skills for data engineers. Systematic performance analysis helps identify bottlenecks and optimize data pipeline efficiency.

**Key takeaways**:
- Use built-in tools (pdb, cProfile) for basic debugging and profiling
- Implement structured logging for production debugging
- Profile memory usage to prevent OOM errors
- Optimize data structures and algorithms for better performance
- Use parallel processing for CPU-intensive tasks
- Monitor system resources during pipeline execution

**Next**: Day 28 will cover security and configuration management for data applications.
