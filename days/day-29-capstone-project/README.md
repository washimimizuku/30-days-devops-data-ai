# Day 29: Capstone Project - Complete Data Pipeline

**Duration**: 2-3 hours  
**Prerequisites**: All previous days (1-28)  
**Learning Goal**: Build a complete, production-ready data pipeline integrating all learned tools and concepts

## Project Overview

You'll build **DataFlow Analytics** - a complete data processing pipeline that demonstrates mastery of all 28 days of developer tools. This project integrates:

- **Command Line & Shell** (Days 1-7): Automation and scripting
- **Git & Version Control** (Days 8-14): Code management and collaboration
- **Docker & Containers** (Days 15-21): Containerized deployment
- **CI/CD & Professional Tools** (Days 22-28): Testing, deployment, and security

## Project Architecture

```
DataFlow Analytics Pipeline
├── Data Ingestion (API + File processing)
├── Data Processing (ETL with validation)
├── Data Storage (Database + File system)
├── API Service (REST endpoints)
├── Monitoring & Logging
├── Security & Configuration
└── CI/CD Pipeline
```

## Project Requirements

### Core Features
1. **Data Ingestion**: Fetch data from APIs and process CSV files
2. **Data Processing**: Clean, transform, and validate data
3. **Data Storage**: Store processed data in database and files
4. **API Service**: Provide REST endpoints for data access
5. **Monitoring**: Health checks, metrics, and logging
6. **Security**: Authentication, encryption, and secure configuration

### Technical Requirements
1. **Containerized**: All services run in Docker containers
2. **Tested**: Unit tests, integration tests, and API tests
3. **Monitored**: Comprehensive logging and health checks
4. **Secure**: Proper secret management and access control
5. **Automated**: CI/CD pipeline with GitHub Actions
6. **Documented**: Clear README and API documentation

## Project Structure

```
dataflow-analytics/
├── README.md                    # Project documentation
├── docker-compose.yml          # Multi-service orchestration
├── Makefile                    # Task automation
├── .env.example               # Environment template
├── .gitignore                 # Git ignore rules
├── requirements.txt           # Python dependencies
│
├── .github/workflows/         # CI/CD pipelines
│   ├── ci.yml                # Continuous integration
│   └── deploy.yml            # Deployment pipeline
│
├── src/                      # Source code
│   ├── ingestion/           # Data ingestion service
│   ├── processing/          # Data processing service
│   ├── api/                 # REST API service
│   ├── common/              # Shared utilities
│   └── config/              # Configuration management
│
├── tests/                   # Test suites
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   └── api/                # API tests
│
├── data/                   # Data storage
│   ├── raw/               # Raw input data
│   ├── processed/         # Processed data
│   └── archive/           # Archived data
│
├── docker/                # Docker configurations
│   ├── ingestion/        # Ingestion service Dockerfile
│   ├── processing/       # Processing service Dockerfile
│   ├── api/              # API service Dockerfile
│   └── database/         # Database setup
│
├── scripts/              # Automation scripts
│   ├── setup.sh         # Environment setup
│   ├── deploy.sh        # Deployment script
│   └── test.sh          # Test runner
│
└── docs/                # Documentation
    ├── api.md          # API documentation
    ├── deployment.md   # Deployment guide
    └── architecture.md # System architecture
```

## Implementation Plan

### Phase 1: Foundation (30 minutes)
- Set up project structure
- Configure Git repository
- Create basic Docker setup
- Implement configuration management

### Phase 2: Core Services (60 minutes)
- Build data ingestion service
- Implement data processing pipeline
- Create REST API service
- Set up database integration

### Phase 3: Testing & Quality (30 minutes)
- Write unit and integration tests
- Implement API testing
- Add code quality checks
- Set up monitoring and logging

### Phase 4: Deployment & CI/CD (30 minutes)
- Create Docker Compose setup
- Implement CI/CD pipeline
- Add security measures
- Document the system

## Getting Started

### Prerequisites Check
```bash
# Verify required tools are installed
docker --version
docker-compose --version
git --version
python --version
make --version
```

### Project Initialization
```bash
# Create project directory
mkdir dataflow-analytics
cd dataflow-analytics

# Initialize Git repository
git init
git remote add origin https://github.com/yourusername/dataflow-analytics.git

# Create basic structure
mkdir -p src/{ingestion,processing,api,common,config}
mkdir -p tests/{unit,integration,api}
mkdir -p data/{raw,processed,archive}
mkdir -p docker/{ingestion,processing,api,database}
mkdir -p scripts docs .github/workflows
```

## Core Components

### 1. Configuration Management
```python
# src/config/settings.py
import os
from dataclasses import dataclass
from typing import Optional

@dataclass
class Settings:
    # Database
    database_url: str = os.getenv('DATABASE_URL', 'sqlite:///dataflow.db')
    
    # API
    api_host: str = os.getenv('API_HOST', '0.0.0.0')
    api_port: int = int(os.getenv('API_PORT', '8000'))
    
    # Security
    secret_key: str = os.getenv('SECRET_KEY', 'dev-secret-key')
    
    # Processing
    batch_size: int = int(os.getenv('BATCH_SIZE', '1000'))
    max_workers: int = int(os.getenv('MAX_WORKERS', '4'))
    
    # Monitoring
    log_level: str = os.getenv('LOG_LEVEL', 'INFO')
    
    @classmethod
    def load(cls) -> 'Settings':
        return cls()
```

### 2. Data Models
```python
# src/common/models.py
from dataclasses import dataclass
from datetime import datetime
from typing import Optional, Dict, Any

@dataclass
class DataRecord:
    id: str
    timestamp: datetime
    source: str
    data: Dict[str, Any]
    processed_at: Optional[datetime] = None
    status: str = 'raw'
    
@dataclass
class ProcessingResult:
    record_id: str
    success: bool
    processed_data: Optional[Dict[str, Any]] = None
    error_message: Optional[str] = None
    processing_time: float = 0.0
```

### 3. Data Ingestion Service
```python
# src/ingestion/service.py
import asyncio
import aiohttp
import pandas as pd
from pathlib import Path
from src.common.models import DataRecord
from src.config.settings import Settings

class IngestionService:
    def __init__(self, settings: Settings):
        self.settings = settings
        
    async def fetch_api_data(self, url: str) -> list:
        """Fetch data from external API"""
        async with aiohttp.ClientSession() as session:
            async with session.get(url) as response:
                return await response.json()
    
    def process_csv_file(self, file_path: Path) -> pd.DataFrame:
        """Process CSV file"""
        return pd.read_csv(file_path)
    
    async def ingest_data(self) -> list[DataRecord]:
        """Main ingestion process"""
        records = []
        
        # Fetch from API
        api_data = await self.fetch_api_data('https://api.example.com/data')
        for item in api_data:
            record = DataRecord(
                id=item['id'],
                timestamp=datetime.now(),
                source='api',
                data=item
            )
            records.append(record)
        
        return records
```

### 4. Data Processing Service
```python
# src/processing/service.py
import pandas as pd
from src.common.models import DataRecord, ProcessingResult
from src.config.settings import Settings

class ProcessingService:
    def __init__(self, settings: Settings):
        self.settings = settings
    
    def validate_data(self, data: dict) -> bool:
        """Validate data quality"""
        required_fields = ['id', 'value', 'category']
        return all(field in data for field in required_fields)
    
    def transform_data(self, data: dict) -> dict:
        """Transform and clean data"""
        transformed = data.copy()
        
        # Clean numeric values
        if 'value' in transformed:
            transformed['value'] = float(transformed['value'])
        
        # Normalize categories
        if 'category' in transformed:
            transformed['category'] = transformed['category'].lower().strip()
        
        return transformed
    
    def process_record(self, record: DataRecord) -> ProcessingResult:
        """Process a single data record"""
        try:
            if not self.validate_data(record.data):
                return ProcessingResult(
                    record_id=record.id,
                    success=False,
                    error_message="Data validation failed"
                )
            
            processed_data = self.transform_data(record.data)
            
            return ProcessingResult(
                record_id=record.id,
                success=True,
                processed_data=processed_data
            )
            
        except Exception as e:
            return ProcessingResult(
                record_id=record.id,
                success=False,
                error_message=str(e)
            )
```

### 5. REST API Service
```python
# src/api/service.py
from fastapi import FastAPI, HTTPException
from src.config.settings import Settings
from src.common.models import DataRecord

app = FastAPI(title="DataFlow Analytics API")
settings = Settings.load()

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "dataflow-api"}

@app.get("/data/{record_id}")
async def get_record(record_id: str):
    # Fetch record from database
    record = fetch_record_from_db(record_id)
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    return record

@app.post("/data/process")
async def trigger_processing():
    # Trigger data processing pipeline
    return {"message": "Processing triggered", "status": "started"}
```

## Docker Configuration

### Multi-Service Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  database:
    image: postgres:15
    environment:
      POSTGRES_DB: dataflow
      POSTGRES_USER: dataflow
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  ingestion:
    build: ./docker/ingestion
    environment:
      - DATABASE_URL=postgresql://dataflow:${DB_PASSWORD}@database:5432/dataflow
    depends_on:
      - database
    volumes:
      - ./data:/app/data

  processing:
    build: ./docker/processing
    environment:
      - DATABASE_URL=postgresql://dataflow:${DB_PASSWORD}@database:5432/dataflow
    depends_on:
      - database
      - ingestion

  api:
    build: ./docker/api
    environment:
      - DATABASE_URL=postgresql://dataflow:${DB_PASSWORD}@database:5432/dataflow
    ports:
      - "8000:8000"
    depends_on:
      - database

volumes:
  postgres_data:
```

## Testing Strategy

### Unit Tests
```python
# tests/unit/test_processing.py
import pytest
from src.processing.service import ProcessingService
from src.common.models import DataRecord
from src.config.settings import Settings

def test_data_validation():
    service = ProcessingService(Settings())
    
    valid_data = {'id': '123', 'value': 100, 'category': 'A'}
    assert service.validate_data(valid_data) == True
    
    invalid_data = {'id': '123', 'value': 100}  # Missing category
    assert service.validate_data(invalid_data) == False
```

### Integration Tests
```python
# tests/integration/test_pipeline.py
import pytest
from src.ingestion.service import IngestionService
from src.processing.service import ProcessingService

@pytest.mark.asyncio
async def test_end_to_end_pipeline():
    # Test complete data flow
    ingestion = IngestionService(Settings())
    processing = ProcessingService(Settings())
    
    # Ingest data
    records = await ingestion.ingest_data()
    assert len(records) > 0
    
    # Process data
    results = [processing.process_record(record) for record in records]
    assert all(result.success for result in results)
```

## CI/CD Pipeline

### GitHub Actions Workflow
```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Run tests
        run: |
          pytest tests/ --cov=src --cov-report=xml
      
      - name: Run security scan
        run: |
          bandit -r src/
          safety check
      
      - name: Build Docker images
        run: |
          docker-compose build
      
      - name: Run integration tests
        run: |
          docker-compose up -d
          sleep 30
          pytest tests/integration/
          docker-compose down

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production..."
          # Add deployment steps here
```

## Monitoring and Observability

### Health Checks
```python
# src/common/health.py
from dataclasses import dataclass
from typing import Dict, Any
import psutil
import time

@dataclass
class HealthStatus:
    service: str
    status: str
    timestamp: float
    details: Dict[str, Any]

class HealthChecker:
    def check_database(self) -> HealthStatus:
        # Check database connectivity
        pass
    
    def check_system_resources(self) -> HealthStatus:
        return HealthStatus(
            service="system",
            status="healthy",
            timestamp=time.time(),
            details={
                "cpu_percent": psutil.cpu_percent(),
                "memory_percent": psutil.virtual_memory().percent,
                "disk_percent": psutil.disk_usage('/').percent
            }
        )
```

## Security Implementation

### Authentication & Authorization
```python
# src/common/security.py
from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer
import jwt

security = HTTPBearer()

def verify_token(token: str = Depends(security)):
    try:
        payload = jwt.decode(token.credentials, settings.secret_key, algorithms=["HS256"])
        return payload
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

## Project Deliverables

### 1. Working Application
- All services running in Docker containers
- Data flowing through the complete pipeline
- API endpoints responding correctly
- Database storing processed data

### 2. Test Suite
- Unit tests with >80% coverage
- Integration tests for end-to-end flows
- API tests for all endpoints
- Performance benchmarks

### 3. CI/CD Pipeline
- Automated testing on every commit
- Security scanning and quality checks
- Automated deployment to staging
- Production deployment with approval

### 4. Documentation
- Comprehensive README with setup instructions
- API documentation with examples
- Architecture diagrams and explanations
- Deployment and operations guide

## Success Criteria

✅ **Functionality**: All core features working correctly  
✅ **Quality**: Tests passing with good coverage  
✅ **Security**: Proper authentication and secret management  
✅ **Performance**: System handles expected load  
✅ **Monitoring**: Health checks and logging implemented  
✅ **Automation**: CI/CD pipeline fully functional  
✅ **Documentation**: Clear and comprehensive docs  

## Next Steps

After completing this capstone project, you'll have:

1. **Portfolio Project**: A complete, production-ready data pipeline
2. **Practical Experience**: Hands-on use of all 28 days of tools
3. **Best Practices**: Real-world implementation patterns
4. **Deployment Skills**: End-to-end system deployment
5. **Professional Workflow**: Complete DevOps pipeline

## Bonus Challenges

For additional learning:
- Add real-time data streaming with Kafka
- Implement data visualization dashboard
- Add machine learning model integration
- Set up monitoring with Prometheus/Grafana
- Deploy to cloud platforms (AWS/GCP/Azure)

## Resources

- **Code Templates**: Available in exercise files
- **Sample Data**: Provided for testing
- **Configuration Examples**: Environment templates
- **Deployment Scripts**: Automation helpers

Ready to build your capstone project? Let's integrate everything you've learned into a production-ready data pipeline!
