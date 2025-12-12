#!/bin/bash

# Day 27: Debugging and Profiling Solutions
# Advanced patterns and production-ready implementations

set -e

echo "🐛 Day 27: Debugging and Profiling Solutions"
echo "============================================="

# Solution 1: Production Debugging Framework
echo -e "\n🔧 Solution 1: Production Debugging Framework"

mkdir -p solution1-debugging-framework
cd solution1-debugging-framework

# Create comprehensive debugging framework
cat > debug_framework.py << 'EOF'
#!/usr/bin/env python3
"""
Production Debugging Framework
Comprehensive debugging and monitoring for data pipelines
"""

import logging
import json
import time
import traceback
import functools
from datetime import datetime
from contextlib import contextmanager
from typing import Any, Dict, Optional
import pandas as pd
import numpy as np

class DebugFramework:
    def __init__(self, log_level=logging.INFO):
        self.setup_logging(log_level)
        self.metrics = {}
        
    def setup_logging(self, level):
        """Setup structured logging"""
        logging.basicConfig(
            level=level,
            format='%(message)s',
            handlers=[
                logging.FileHandler('debug.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def log_event(self, event_type: str, message: str, **kwargs):
        """Log structured events"""
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'message': message,
            **kwargs
        }
        self.logger.info(json.dumps(log_entry))
    
    @contextmanager
    def debug_context(self, operation_name: str):
        """Context manager for debugging operations"""
        start_time = time.time()
        self.log_event('operation_start', f'Starting {operation_name}')
        
        try:
            yield
            elapsed = time.time() - start_time
            self.log_event('operation_success', f'Completed {operation_name}',
                          elapsed_time=elapsed)
        except Exception as e:
            elapsed = time.time() - start_time
            self.log_event('operation_error', f'Failed {operation_name}',
                          error=str(e), elapsed_time=elapsed,
                          traceback=traceback.format_exc())
            raise
    
    def debug_decorator(self, func):
        """Decorator for automatic debugging"""
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            with self.debug_context(func.__name__):
                return func(*args, **kwargs)
        return wrapper
    
    def validate_data(self, df: pd.DataFrame, name: str) -> Dict[str, Any]:
        """Comprehensive data validation"""
        validation_results = {
            'name': name,
            'shape': df.shape,
            'memory_usage_mb': df.memory_usage(deep=True).sum() / 1024**2,
            'missing_values': df.isnull().sum().to_dict(),
            'duplicates': df.duplicated().sum(),
            'dtypes': df.dtypes.to_dict()
        }
        
        # Check for common issues
        issues = []
        if validation_results['duplicates'] > 0:
            issues.append(f"Found {validation_results['duplicates']} duplicate rows")
        
        missing_total = sum(validation_results['missing_values'].values())
        if missing_total > 0:
            issues.append(f"Found {missing_total} missing values")
        
        validation_results['issues'] = issues
        
        self.log_event('data_validation', f'Validated {name}', **validation_results)
        return validation_results

# Example usage
debug = DebugFramework()

@debug.debug_decorator
def process_data(data_path: str):
    """Example data processing with debugging"""
    # Load data
    df = pd.read_csv(data_path)
    debug.validate_data(df, 'raw_data')
    
    # Clean data
    df_clean = df.dropna()
    debug.validate_data(df_clean, 'cleaned_data')
    
    # Process data
    df_clean['processed'] = df_clean['value'] * 2
    
    return df_clean

if __name__ == "__main__":
    # Create sample data
    sample_data = pd.DataFrame({
        'value': [1, 2, np.nan, 4, 5],
        'category': ['A', 'B', 'C', 'A', 'B']
    })
    sample_data.to_csv('sample.csv', index=False)
    
    # Process with debugging
    result = process_data('sample.csv')
    print("Processing completed with debugging")
EOF

chmod +x debug_framework.py
python debug_framework.py > debug_output.txt 2>&1
echo "✅ Debug framework created and tested"

cd ..

# Solution 2: Advanced Performance Profiler
echo -e "\n⚡ Solution 2: Advanced Performance Profiler"

mkdir -p solution2-performance-profiler
cd solution2-performance-profiler

# Create advanced profiling system
cat > performance_profiler.py << 'EOF'
#!/usr/bin/env python3
"""
Advanced Performance Profiler
Comprehensive performance analysis for data pipelines
"""

import cProfile
import pstats
import io
import time
import tracemalloc
import functools
import pandas as pd
import numpy as np
from typing import Dict, Any, Callable
from dataclasses import dataclass
from contextlib import contextmanager

@dataclass
class ProfileResult:
    function_name: str
    execution_time: float
    memory_peak: float
    memory_current: float
    cpu_stats: Dict[str, Any]

class PerformanceProfiler:
    def __init__(self):
        self.results = []
        
    @contextmanager
    def profile_context(self, name: str):
        """Context manager for profiling"""
        # Start profiling
        pr = cProfile.Profile()
        tracemalloc.start()
        start_time = time.time()
        
        pr.enable()
        
        try:
            yield
        finally:
            pr.disable()
            
            # Collect metrics
            execution_time = time.time() - start_time
            current_memory, peak_memory = tracemalloc.get_traced_memory()
            tracemalloc.stop()
            
            # Get CPU stats
            s = io.StringIO()
            ps = pstats.Stats(pr, stream=s)
            ps.sort_stats('cumulative')
            
            # Store results
            result = ProfileResult(
                function_name=name,
                execution_time=execution_time,
                memory_peak=peak_memory / 1024**2,  # MB
                memory_current=current_memory / 1024**2,  # MB
                cpu_stats=self._extract_cpu_stats(ps)
            )
            
            self.results.append(result)
            
    def _extract_cpu_stats(self, ps: pstats.Stats) -> Dict[str, Any]:
        """Extract key CPU statistics"""
        stats = ps.get_stats_profile()
        total_calls = sum(stat.callcount for stat in stats.values())
        total_time = sum(stat.totaltime for stat in stats.values())
        
        return {
            'total_calls': total_calls,
            'total_time': total_time,
            'avg_time_per_call': total_time / total_calls if total_calls > 0 else 0
        }
    
    def profile_function(self, func: Callable, *args, **kwargs):
        """Profile a single function"""
        with self.profile_context(func.__name__):
            return func(*args, **kwargs)
    
    def compare_implementations(self, implementations: Dict[str, Callable], *args, **kwargs):
        """Compare multiple implementations"""
        results = {}
        
        for name, func in implementations.items():
            print(f"Profiling {name}...")
            with self.profile_context(name):
                results[name] = func(*args, **kwargs)
        
        return results
    
    def generate_report(self) -> str:
        """Generate performance report"""
        if not self.results:
            return "No profiling results available"
        
        report = "Performance Profiling Report\n"
        report += "=" * 50 + "\n\n"
        
        for result in self.results:
            report += f"Function: {result.function_name}\n"
            report += f"Execution Time: {result.execution_time:.3f}s\n"
            report += f"Peak Memory: {result.memory_peak:.2f} MB\n"
            report += f"Current Memory: {result.memory_current:.2f} MB\n"
            report += f"Total Calls: {result.cpu_stats['total_calls']}\n"
            report += f"Total CPU Time: {result.cpu_stats['total_time']:.3f}s\n"
            report += "-" * 30 + "\n"
        
        return report

# Example implementations to compare
def slow_data_processing():
    """Slow implementation"""
    data = []
    for i in range(50000):
        data.append({'id': i, 'value': np.random.randn()})
    
    df = pd.DataFrame(data)
    result = []
    for _, row in df.iterrows():
        if row['value'] > 0:
            result.append(row['value'] ** 2)
    
    return result

def fast_data_processing():
    """Fast implementation"""
    df = pd.DataFrame({
        'id': range(50000),
        'value': np.random.randn(50000)
    })
    
    mask = df['value'] > 0
    result = (df.loc[mask, 'value'] ** 2).tolist()
    
    return result

def vectorized_data_processing():
    """Vectorized implementation"""
    values = np.random.randn(50000)
    mask = values > 0
    result = (values[mask] ** 2).tolist()
    
    return result

if __name__ == "__main__":
    profiler = PerformanceProfiler()
    
    # Compare implementations
    implementations = {
        'slow': slow_data_processing,
        'fast': fast_data_processing,
        'vectorized': vectorized_data_processing
    }
    
    results = profiler.compare_implementations(implementations)
    
    # Generate and save report
    report = profiler.generate_report()
    with open('performance_report.txt', 'w') as f:
        f.write(report)
    
    print("Performance comparison completed!")
    print(report)
EOF

chmod +x performance_profiler.py
python performance_profiler.py > profiler_output.txt 2>&1
echo "✅ Advanced performance profiler created and tested"

cd ..

# Solution 3: Memory Optimization System
echo -e "\n🧠 Solution 3: Memory Optimization System"

mkdir -p solution3-memory-optimization
cd solution3-memory-optimization

# Create memory optimization system
cat > memory_optimizer.py << 'EOF'
#!/usr/bin/env python3
"""
Memory Optimization System
Intelligent memory management for data processing
"""

import pandas as pd
import numpy as np
import gc
import tracemalloc
from typing import Dict, Any, Optional
import warnings

class MemoryOptimizer:
    def __init__(self):
        self.optimization_log = []
        
    def optimize_dataframe(self, df: pd.DataFrame, name: str = "DataFrame") -> pd.DataFrame:
        """Optimize DataFrame memory usage"""
        start_memory = df.memory_usage(deep=True).sum() / 1024**2
        
        optimizations = []
        df_optimized = df.copy()
        
        for col in df_optimized.columns:
            col_type = df_optimized[col].dtype
            
            if col_type != 'object':
                c_min = df_optimized[col].min()
                c_max = df_optimized[col].max()
                
                if str(col_type)[:3] == 'int':
                    # Optimize integer types
                    if c_min > np.iinfo(np.int8).min and c_max < np.iinfo(np.int8).max:
                        df_optimized[col] = df_optimized[col].astype(np.int8)
                        optimizations.append(f"{col}: {col_type} -> int8")
                    elif c_min > np.iinfo(np.int16).min and c_max < np.iinfo(np.int16).max:
                        df_optimized[col] = df_optimized[col].astype(np.int16)
                        optimizations.append(f"{col}: {col_type} -> int16")
                    elif c_min > np.iinfo(np.int32).min and c_max < np.iinfo(np.int32).max:
                        df_optimized[col] = df_optimized[col].astype(np.int32)
                        optimizations.append(f"{col}: {col_type} -> int32")
                
                elif str(col_type)[:5] == 'float':
                    # Optimize float types
                    if c_min > np.finfo(np.float32).min and c_max < np.finfo(np.float32).max:
                        df_optimized[col] = df_optimized[col].astype(np.float32)
                        optimizations.append(f"{col}: {col_type} -> float32")
            
            else:
                # Optimize object types to category
                unique_ratio = df_optimized[col].nunique() / len(df_optimized)
                if unique_ratio < 0.5:  # Less than 50% unique values
                    df_optimized[col] = df_optimized[col].astype('category')
                    optimizations.append(f"{col}: object -> category")
        
        end_memory = df_optimized.memory_usage(deep=True).sum() / 1024**2
        reduction = (start_memory - end_memory) / start_memory * 100
        
        optimization_result = {
            'name': name,
            'start_memory_mb': start_memory,
            'end_memory_mb': end_memory,
            'reduction_percent': reduction,
            'optimizations': optimizations
        }
        
        self.optimization_log.append(optimization_result)
        
        print(f"Optimized {name}:")
        print(f"  Memory: {start_memory:.2f} MB -> {end_memory:.2f} MB")
        print(f"  Reduction: {reduction:.1f}%")
        print(f"  Optimizations: {len(optimizations)}")
        
        return df_optimized
    
    def memory_efficient_read_csv(self, filepath: str, chunk_size: int = 10000) -> pd.DataFrame:
        """Memory-efficient CSV reading with optimization"""
        print(f"Reading {filepath} in chunks of {chunk_size}...")
        
        chunks = []
        for chunk in pd.read_csv(filepath, chunksize=chunk_size):
            optimized_chunk = self.optimize_dataframe(chunk, f"chunk_{len(chunks)}")
            chunks.append(optimized_chunk)
        
        # Concatenate optimized chunks
        result = pd.concat(chunks, ignore_index=True)
        
        # Final optimization
        result = self.optimize_dataframe(result, "final_dataframe")
        
        return result
    
    def track_memory_usage(self, func, *args, **kwargs):
        """Track memory usage of a function"""
        tracemalloc.start()
        gc.collect()  # Clean up before measurement
        
        start_memory = tracemalloc.get_traced_memory()[0]
        
        result = func(*args, **kwargs)
        
        current_memory, peak_memory = tracemalloc.get_traced_memory()
        tracemalloc.stop()
        
        memory_stats = {
            'start_memory_mb': start_memory / 1024**2,
            'current_memory_mb': current_memory / 1024**2,
            'peak_memory_mb': peak_memory / 1024**2,
            'memory_increase_mb': (current_memory - start_memory) / 1024**2
        }
        
        print(f"Memory usage for {func.__name__}:")
        for key, value in memory_stats.items():
            print(f"  {key}: {value:.2f} MB")
        
        return result, memory_stats
    
    def generate_optimization_report(self) -> str:
        """Generate memory optimization report"""
        if not self.optimization_log:
            return "No optimizations performed"
        
        report = "Memory Optimization Report\n"
        report += "=" * 50 + "\n\n"
        
        total_start_memory = sum(log['start_memory_mb'] for log in self.optimization_log)
        total_end_memory = sum(log['end_memory_mb'] for log in self.optimization_log)
        total_reduction = (total_start_memory - total_end_memory) / total_start_memory * 100
        
        report += f"Total Memory Saved: {total_start_memory - total_end_memory:.2f} MB\n"
        report += f"Total Reduction: {total_reduction:.1f}%\n\n"
        
        for log in self.optimization_log:
            report += f"DataFrame: {log['name']}\n"
            report += f"  Memory Reduction: {log['reduction_percent']:.1f}%\n"
            report += f"  Optimizations Applied: {len(log['optimizations'])}\n"
            for opt in log['optimizations']:
                report += f"    - {opt}\n"
            report += "\n"
        
        return report

# Example usage
def create_sample_data():
    """Create sample data for optimization testing"""
    np.random.seed(42)
    
    data = {
        'id': range(100000),  # Can be optimized to smaller int
        'small_int': np.random.randint(0, 100, 100000),  # Can be int8
        'large_float': np.random.randn(100000).astype(np.float64),  # Can be float32
        'category': np.random.choice(['A', 'B', 'C', 'D', 'E'], 100000),  # Can be category
        'sparse_category': np.random.choice(['X', 'Y'], 100000, p=[0.95, 0.05])  # Good for category
    }
    
    return pd.DataFrame(data)

if __name__ == "__main__":
    optimizer = MemoryOptimizer()
    
    # Create and optimize sample data
    print("Creating sample data...")
    df = create_sample_data()
    
    print(f"Original DataFrame memory: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    
    # Optimize DataFrame
    df_optimized = optimizer.optimize_dataframe(df, "sample_data")
    
    # Generate report
    report = optimizer.generate_optimization_report()
    with open('memory_optimization_report.txt', 'w') as f:
        f.write(report)
    
    print("\nOptimization completed!")
    print(report)
EOF

chmod +x memory_optimizer.py
python memory_optimizer.py > memory_output.txt 2>&1
echo "✅ Memory optimization system created and tested"

cd ..

echo -e "\n🎉 All Day 27 solutions completed!"
echo ""
echo "Solutions demonstrated:"
echo "1. Production debugging framework with structured logging"
echo "2. Advanced performance profiler with comprehensive metrics"
echo "3. Memory optimization system with intelligent data type conversion"
echo ""
echo "Key patterns covered:"
echo "- Structured logging and event tracking"
echo "- Comprehensive performance profiling"
echo "- Memory usage optimization and tracking"
echo "- Context managers for debugging"
echo "- Automated optimization recommendations"
