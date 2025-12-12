# Project Structure

Understanding the organization of the 30 Days of Developer Tools bootcamp.

## Directory Layout

```
30-days-devtools-data-ai/
│
├── README.md                   # Main overview and getting started
├── QUICKSTART.md               # 5-minute setup guide
├── LICENSE                     # MIT License
├── .gitignore                  # Git ignore patterns
├── requirements.txt            # Python packages for Week 4
│
├── docs/                       # 📚 Documentation
│   ├── CURRICULUM.md           # Complete day-by-day curriculum
│   ├── SETUP.md                # Detailed installation guide
│   ├── TROUBLESHOOTING.md      # Common issues and solutions
│   ├── PROJECT_STRUCTURE.md    # This file
│   ├── CONTRIBUTING.md         # Contribution guidelines
│   └── GIT_SETUP.md            # Git workflow guide
│
├── tools/                      # 🛠️ Utilities and helpers
│   ├── test_setup.sh           # Verify tool installation
│   └── cheatsheet.md           # Quick reference for all tools
│
├── data/                       # 📊 Sample data files
│   ├── raw/                    # Original data files
│   │   └── .gitkeep
│   └── processed/              # Processed data files
│       └── .gitkeep
│
└── days/                       # 📖 30 Daily Lessons
    │
    ├── day-01-terminal-basics/
    │   ├── README.md           # Lesson content
    │   ├── exercise.sh         # Practice exercises
    │   ├── solution.sh         # Exercise solutions
    │   └── quiz.md             # Knowledge check
    │
    ├── day-02-shell-scripting/
    │   ├── README.md
    │   ├── exercise.sh
    │   ├── solution.sh
    │   └── quiz.md
    │
    ├── ... (days 03-06)
    │
    ├── day-07-mini-project-pipeline/
    │   ├── README.md           # Project requirements
    │   ├── starter/            # Starter code
    │   ├── solution/           # Complete solution
    │   └── data/               # Project data files
    │
    ├── ... (days 08-13)
    │
    ├── day-14-mini-project-git-workflow/
    │   ├── README.md
    │   ├── starter/
    │   └── solution/
    │
    ├── ... (days 15-20)
    │
    ├── day-21-mini-project-containerized-app/
    │   ├── README.md
    │   ├── starter/
    │   ├── solution/
    │   └── docker-compose.yml
    │
    ├── ... (days 22-29)
    │
    └── day-30-capstone-cicd-pipeline/
        ├── README.md
        ├── starter/
        ├── solution/
        ├── .github/
        │   └── workflows/
        └── docker-compose.yml
```

## File Types

### README.md Files

Each day's `README.md` contains:
- **Learning Objectives** - What you'll learn
- **Concepts** - Theory and explanations
- **Examples** - Code samples and demonstrations
- **Key Takeaways** - Summary of important points
- **Resources** - Links for further learning

### Exercise Files

- **exercise.sh** - Shell script exercises with TODO comments
- **exercise.py** - Python exercises (Week 4)
- **exercise.yml** - YAML/Docker Compose exercises (Week 3-4)

Students complete these files as they learn.

### Solution Files

- **solution.sh** - Complete solutions to exercises
- **solution.py** - Python solutions
- **solution.yml** - Configuration solutions

Reference these if stuck, but try exercises first!

### Quiz Files

- **quiz.md** - Multiple choice and short answer questions
- Tests understanding of concepts
- Answers at bottom of file

## Week Structure

### Week 1: Command Line & Shell (Days 1-7)

Focus on terminal skills and shell scripting.

**File types:**
- Shell scripts (.sh)
- Text files for processing
- Makefiles

**Project Day 7:**
- Complete automated data pipeline
- Combines all Week 1 skills

### Week 2: Git & Version Control (Days 8-14)

Focus on Git and collaboration workflows.

**File types:**
- Git repositories
- Markdown files
- Configuration files

**Project Day 14:**
- Collaborative Git workflow simulation
- Multiple branches and pull requests

### Week 3: Docker & Containers (Days 15-21)

Focus on containerization and Docker.

**File types:**
- Dockerfiles
- docker-compose.yml
- Container configurations

**Project Day 21:**
- Multi-container data application
- Database + processing + API

### Week 4: CI/CD & Professional Tools (Days 22-30)

Focus on automation, testing, and deployment.

**File types:**
- GitHub Actions workflows (.yml)
- Python test files
- Configuration files
- AWS CLI scripts

**Project Day 30:**
- Complete CI/CD pipeline
- Integrates all bootcamp skills

## Data Directory

### data/raw/

Original, unmodified data files used in exercises.

**Examples:**
- CSV files
- JSON files
- Log files
- Sample datasets

### data/processed/

Output from exercises and projects.

**Examples:**
- Cleaned data
- Transformed data
- Generated reports

**Note:** These directories are in `.gitignore` to avoid committing large data files.

## Tools Directory

### test_setup.sh

Verification script that checks:
- Essential command line tools
- Python installation
- Docker installation
- Optional tools

Run before starting: `bash tools/test_setup.sh`

### cheatsheet.md

Quick reference guide containing:
- Common commands for all tools
- Syntax examples
- Keyboard shortcuts
- Useful patterns

Keep this open while working!

## Docs Directory

### CURRICULUM.md

Complete curriculum with:
- Day-by-day breakdown
- Learning objectives
- Time estimates
- Tool coverage

### SETUP.md

Detailed installation instructions for:
- macOS
- Linux
- Windows (WSL2)
- All required tools

### TROUBLESHOOTING.md

Solutions for common issues:
- Command line problems
- Git issues
- Docker problems
- Python errors
- WSL2 issues

### GIT_SETUP.md

Git workflow guide:
- Forking the repository
- Daily commit workflow
- Branch strategies
- Collaboration tips

### CONTRIBUTING.md

Guidelines for contributing:
- Code of conduct
- How to report issues
- How to submit improvements
- Style guidelines

## Project Days Structure

Project days (7, 14, 21, 30) have additional structure:

```
day-XX-mini-project-name/
├── README.md           # Project requirements and instructions
├── starter/            # Starting point with TODO comments
│   ├── script.sh
│   ├── Dockerfile
│   └── ...
├── solution/           # Complete working solution
│   ├── script.sh
│   ├── Dockerfile
│   └── ...
├── data/               # Project-specific data (if needed)
└── tests/              # Tests to verify solution (if applicable)
```

## File Naming Conventions

### Shell Scripts
- `exercise.sh` - Practice exercises
- `solution.sh` - Complete solutions
- `script_name.sh` - Descriptive names for specific scripts

### Python Files
- `exercise.py` - Practice exercises
- `solution.py` - Complete solutions
- `test_*.py` - Test files (pytest convention)

### Docker Files
- `Dockerfile` - Container image definition
- `docker-compose.yml` - Multi-container orchestration
- `.dockerignore` - Files to exclude from build

### Configuration Files
- `.env` - Environment variables (not committed)
- `.env.example` - Example environment variables
- `config.yml` - Application configuration
- `Makefile` - Build automation

## Hidden Files

### .gitignore

Specifies files Git should ignore:
- Python cache files
- Virtual environments
- Data files
- IDE settings
- Environment variables

### .github/ (in project days)

GitHub-specific files:
- `workflows/` - GitHub Actions CI/CD
- `ISSUE_TEMPLATE/` - Issue templates
- `PULL_REQUEST_TEMPLATE.md` - PR template

## Navigation Tips

### Quick Navigation

```bash
# Go to bootcamp root
cd ~/30-days-devtools-data-ai

# Go to specific day
cd days/day-01-terminal-basics

# Go to docs
cd docs

# Go to tools
cd tools

# Go back to root from anywhere
cd ~/30-days-devtools-data-ai
```

### Finding Files

```bash
# Find all exercise files
find days/ -name "exercise.*"

# Find all README files
find days/ -name "README.md"

# Find all shell scripts
find days/ -name "*.sh"
```

## Working with the Structure

### Daily Workflow

1. **Navigate to day:**
   ```bash
   cd days/day-XX-topic-name
   ```

2. **Read lesson:**
   ```bash
   cat README.md
   # or open in editor
   ```

3. **Complete exercises:**
   ```bash
   # Edit exercise files
   nano exercise.sh
   
   # Run exercises
   bash exercise.sh
   ```

4. **Check solutions if stuck:**
   ```bash
   cat solution.sh
   ```

5. **Take quiz:**
   ```bash
   cat quiz.md
   ```

### Project Workflow

1. **Read project requirements:**
   ```bash
   cd days/day-XX-mini-project-name
   cat README.md
   ```

2. **Start with starter code:**
   ```bash
   cd starter/
   # Work on files here
   ```

3. **Test your solution:**
   ```bash
   # Run tests if provided
   bash test.sh
   ```

4. **Compare with solution:**
   ```bash
   cd ../solution/
   # Review complete implementation
   ```

## Customization

Feel free to:
- Add your own notes to README files
- Create additional practice exercises
- Organize data files your way
- Add helper scripts to tools/
- Create your own cheatsheets

**Tip:** If using Git, commit your customizations!

## Best Practices

### Keep It Organized

- Complete days in order
- Don't skip exercises
- Commit progress regularly
- Keep data/ directory clean

### Use the Resources

- Reference cheatsheet.md frequently
- Check troubleshooting.md when stuck
- Review previous days as needed
- Read documentation links

### Build Your Portfolio

- Fork the repository
- Commit daily progress
- Add your own projects
- Document your learning

---

## Questions?

- Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for issues
- Review [SETUP.md](./SETUP.md) for installation
- See [CURRICULUM.md](./CURRICULUM.md) for overview
- Read [README.md](../README.md) for getting started

---

**Happy learning!** 🚀
