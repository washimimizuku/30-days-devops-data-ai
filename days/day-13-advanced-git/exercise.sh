#!/bin/bash

# Day 13: Advanced Git - Hands-on Exercise
# Practice conflict resolution, rebasing, and advanced Git techniques

set -e

echo "🚀 Day 13: Advanced Git Exercise"
echo "================================="

# Create exercise directory
EXERCISE_DIR="$HOME/advanced-git-exercise"
echo "📁 Creating exercise directory: $EXERCISE_DIR"

if [ -d "$EXERCISE_DIR" ]; then
    echo "⚠️  Directory exists. Removing..."
    rm -rf "$EXERCISE_DIR"
fi

mkdir -p "$EXERCISE_DIR"
cd "$EXERCISE_DIR"

echo ""
echo "🎯 Exercise 1: Merge Conflicts"
echo "=============================="

# Initialize repository
git init
git config user.name "Git Student"
git config user.email "student@example.com"

# Create initial file
cat > data_processor.py << 'EOF'
#!/usr/bin/env python3
"""Data processing module."""

def load_data(filename):
    """Load data from file."""
    print(f"Loading {filename}")
    return []

def process_data(data):
    """Process the data."""
    print("Processing data")
    return data

if __name__ == "__main__":
    data = load_data("input.csv")
    result = process_data(data)
    print("Complete")
EOF

git add .
git commit -m "Initial data processor"

echo "✅ Repository initialized"

# Create conflicting branches
git checkout -b feature/validation
cat > data_processor.py << 'EOF'
#!/usr/bin/env python3
"""Data processing module."""

def validate_data(data):
    """Validate data format."""
    if not data:
        raise ValueError("Empty data")
    return True

def load_data(filename):
    """Load data from file."""
    print(f"Loading {filename}")
    data = []
    validate_data(data)
    return data

def process_data(data):
    """Process the data."""
    print("Processing data")
    return data

if __name__ == "__main__":
    data = load_data("input.csv")
    result = process_data(data)
    print("Complete")
EOF

git add .
git commit -m "Add data validation"

# Create another conflicting branch
git checkout main
git checkout -b feature/logging

cat > data_processor.py << 'EOF'
#!/usr/bin/env python3
"""Data processing module."""
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def load_data(filename):
    """Load data from file."""
    logger.info(f"Loading {filename}")
    return []

def process_data(data):
    """Process the data."""
    logger.info("Processing data")
    return data

if __name__ == "__main__":
    data = load_data("input.csv")
    result = process_data(data)
    logger.info("Complete")
EOF

git add .
git commit -m "Add logging functionality"

echo "✅ Created conflicting branches"

# Attempt merge to create conflict
git checkout main
echo "🔥 Creating merge conflict..."
git merge feature/validation

echo "⚠️  Conflict created! Let's resolve it..."

# Show conflict
echo "📄 Conflict in data_processor.py:"
head -20 data_processor.py

# Resolve conflict by combining both features
cat > data_processor.py << 'EOF'
#!/usr/bin/env python3
"""Data processing module."""
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def validate_data(data):
    """Validate data format."""
    if not data:
        raise ValueError("Empty data")
    return True

def load_data(filename):
    """Load data from file."""
    logger.info(f"Loading {filename}")
    data = []
    validate_data(data)
    return data

def process_data(data):
    """Process the data."""
    logger.info("Processing data")
    return data

if __name__ == "__main__":
    data = load_data("input.csv")
    result = process_data(data)
    logger.info("Complete")
EOF

git add data_processor.py
git commit -m "Merge validation and logging features"

echo "✅ Conflict resolved by combining features"

# Now merge the logging branch
git merge feature/logging

echo "✅ All branches merged successfully"

echo ""
echo "🎯 Exercise 2: Interactive Rebase"
echo "================================="

# Create messy commit history
git checkout -b feature/cleanup

echo "# TODO: Add error handling" >> data_processor.py
git add .
git commit -m "WIP: working on error handling"

echo "# TODO: Add tests" >> data_processor.py
git add .
git commit -m "typo fix"

cat >> data_processor.py << 'EOF'

def handle_errors(func):
    """Error handling decorator."""
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            logger.error(f"Error: {e}")
            raise
    return wrapper
EOF

git add .
git commit -m "Add error handling decorator"

echo "# Fixed typo in comment" >> data_processor.py
git add .
git commit -m "another small fix"

cat >> data_processor.py << 'EOF'

@handle_errors
def safe_load_data(filename):
    """Safely load data with error handling."""
    return load_data(filename)
EOF

git add .
git commit -m "Add safe data loading function"

echo "✅ Created messy commit history"

echo "📊 Current commit history:"
git log --oneline -6

echo ""
echo "🧹 Cleaning up with interactive rebase..."

# Create script for interactive rebase
cat > rebase_script.txt << 'EOF'
pick HEAD~4 WIP: working on error handling
squash HEAD~3 typo fix
reword HEAD~2 Add error handling decorator
squash HEAD~1 another small fix
pick HEAD Add safe data loading function
EOF

# Note: In real usage, this would open an editor
echo "📝 Interactive rebase would clean up commits:"
echo "   - Squash small fixes into main commits"
echo "   - Reword commit messages"
echo "   - Remove WIP commits"

echo "✅ Interactive rebase simulation complete"

echo ""
echo "🎯 Exercise 3: Git Stash"
echo "========================"

# Start working on new feature
git checkout main
git checkout -b feature/analytics

cat >> data_processor.py << 'EOF'

def calculate_statistics(data):
    """Calculate basic statistics."""
    if not data:
        return {}
    
    return {
        'count': len(data),
        'mean': sum(data) / len(data) if data else 0
    }
EOF

echo "📝 Working on analytics feature..."

# Simulate urgent bug fix needed
echo "🚨 Urgent bug fix needed! Stashing current work..."

git stash push -m "WIP: analytics feature development"

echo "✅ Work stashed"

# Fix urgent bug
git checkout main
git checkout -b hotfix/critical-bug

sed -i.bak 's/Empty data/Data cannot be empty/' data_processor.py
rm -f data_processor.py.bak

git add .
git commit -m "fix: improve error message for empty data"

git checkout main
git merge hotfix/critical-bug
git branch -d hotfix/critical-bug

echo "✅ Hotfix applied"

# Return to feature work
git checkout feature/analytics
git stash pop

echo "✅ Returned to analytics feature work"

# Show stash operations
echo "📋 Stash operations demonstrated:"
echo "   - git stash push -m 'message'"
echo "   - git stash pop"
echo "   - Context switching for urgent fixes"

echo ""
echo "🎯 Exercise 4: Cherry-picking"
echo "============================="

# Create experimental branch
git checkout main
git checkout -b experiment/new-algorithm

cat >> data_processor.py << 'EOF'

def experimental_process(data):
    """Experimental processing algorithm."""
    # New algorithm implementation
    processed = []
    for item in data:
        processed.append(item * 2)  # Example transformation
    return processed

def benchmark_algorithm(data):
    """Benchmark processing performance."""
    import time
    start = time.time()
    result = experimental_process(data)
    end = time.time()
    print(f"Processing took {end - start:.4f} seconds")
    return result
EOF

git add .
git commit -m "feat: add experimental processing algorithm"

# Add another commit
cat >> data_processor.py << 'EOF'

def validate_algorithm_output(original, processed):
    """Validate algorithm output."""
    if len(original) != len(processed):
        raise ValueError("Output length mismatch")
    return True
EOF

git add .
git commit -m "feat: add algorithm output validation"

# Add a bug fix
sed -i.bak 's/item \* 2/item \* 1.5/' data_processor.py
rm -f data_processor.py.bak

git add .
git commit -m "fix: correct algorithm multiplier"

echo "✅ Created experimental commits"

# Cherry-pick only the validation function to main
git checkout main
echo "🍒 Cherry-picking validation function..."

# Get the commit hash for validation
VALIDATION_COMMIT=$(git log --oneline experiment/new-algorithm | grep "algorithm output validation" | cut -d' ' -f1)

git cherry-pick $VALIDATION_COMMIT

echo "✅ Cherry-picked validation function to main"

echo ""
echo "🎯 Exercise 5: Recovery Techniques"
echo "================================="

# Simulate accidental reset
git checkout -b feature/recovery-demo

echo "# Important work" >> important_work.txt
git add .
git commit -m "Important work that will be 'lost'"

IMPORTANT_COMMIT=$(git rev-parse HEAD)
echo "📝 Important commit: $IMPORTANT_COMMIT"

# Accidentally reset
git reset --hard HEAD~1

echo "😱 Oops! Important work is gone..."
echo "📋 Current files:"
ls -la

# Recover using reflog
echo "🔍 Using reflog to recover..."
git reflog | head -5

git checkout $IMPORTANT_COMMIT
git checkout -b recovery-branch

echo "✅ Work recovered!"
echo "📋 Recovered files:"
ls -la

echo ""
echo "🎯 Exercise 6: Rebase vs Merge"
echo "=============================="

git checkout main

# Create feature branch for rebase demo
git checkout -b feature/rebase-demo

echo "Feature work 1" >> feature_work.txt
git add .
git commit -m "feat: add feature work 1"

echo "Feature work 2" >> feature_work.txt
git add .
git commit -m "feat: add feature work 2"

# Simulate main branch progress
git checkout main
echo "Main branch progress" >> main_work.txt
git add .
git commit -m "chore: main branch updates"

# Show difference between merge and rebase
echo "📊 Before rebase - feature branch history:"
git checkout feature/rebase-demo
git log --oneline -3

echo ""
echo "🔄 Rebasing feature branch onto main..."
git rebase main

echo "📊 After rebase - clean linear history:"
git log --oneline -4

echo "✅ Rebase creates clean linear history"

# Demonstrate merge for comparison
git checkout main
git checkout -b feature/merge-demo

echo "Merge feature work" >> merge_work.txt
git add .
git commit -m "feat: add merge feature work"

git checkout main
git merge feature/merge-demo

echo "📊 Merge preserves branch context:"
git log --oneline --graph -5

echo ""
echo "🎉 Exercise Complete!"
echo "===================="
echo ""
echo "You have successfully practiced:"
echo "✅ Resolving merge conflicts"
echo "✅ Interactive rebase concepts"
echo "✅ Git stash for context switching"
echo "✅ Cherry-picking specific commits"
echo "✅ Recovery techniques with reflog"
echo "✅ Rebase vs merge strategies"
echo ""
echo "📁 Exercise files created in: $EXERCISE_DIR"
echo ""
echo "🔍 Review your work:"
echo "   cd $EXERCISE_DIR"
echo "   git log --oneline --graph --all"
echo "   git reflog"
echo ""
echo "💡 Key takeaways:"
echo "   - Conflicts are normal and manageable"
echo "   - Rebase creates clean history"
echo "   - Stash enables context switching"
echo "   - Reflog can recover almost anything"
