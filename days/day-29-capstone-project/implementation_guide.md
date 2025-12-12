# Day 29: Implementation Guide

This guide walks you through implementing the complete DataFlow Analytics capstone project step by step.

## Phase 1: Project Setup (30 minutes)

### Step 1: Create Project Structure
```bash
# Run the setup script
./setup_project.sh

# Navigate to project
cd dataflow-analytics

# Set up development environment
./scripts/setup.sh
```

### Step 2: Implement Core Services

#### Configuration Service
```python
# src/config/database.py
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from .settings import Settings

settings = Settings.load()

engine = create_engine(settings.database_url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

#### Data Models
```python
# src/common/database_models.py
from sqlalchemy import Column, String, DateTime, JSON, Boolean, Float, Integer
from sqlalchemy.sql import func
from src.config.database import Base

class DataRecord(Base):
    __tablename__ = "data_records"
    
    id = Column(String(255), primary_key=True)
    timestamp = Column(DateTime, nullable=False)
    source = Column(String(100), nullable=False)
    data = Column(JSON, nullable=False)
    processed_at = Column(DateTime)
    status = Column(String(50), default='raw')
    created_at = Column(DateTime, server_default=func.now())

class ProcessingResult(Base):
    __tablename__ = "processing_results"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    record_id = Column(String(255), nullable=False)
    success = Column(Boolean, nullable=False)
    processed_data = Column(JSON)
    error_message = Column(String)
    processing_time = Column(Float)
    created_at = Column(DateTime, server_default=func.now())
```

## Phase 2: Core Services Implementation (60 minutes)

### Step 3: Data Ingestion Service
```python
# src/ingestion/service.py
import asyncio
import aiohttp
import pandas as pd
from datetime import datetime
from pathlib import Path
from typing import List
from sqlalchemy.orm import Session

from src.common.models import DataRecord, RecordStatus
from src.common.database_models import DataRecord as DBDataRecord
from src.config.database import get_db
from src.config.settings import Settings

class IngestionService:
    def __init__(self, settings: Settings):
        self.settings = settings
    
    async def fetch_api_data(self, url: str) -> List[dict]:
        """Fetch data from external API."""
        try:
            async with aiohttp.ClientSession() as session:
                async with session.get(url) as response:
                    if response.status == 200:
                        return await response.json()
                    else:
                        return []
        except Exception as e:
            print(f"Error fetching API data: {e}")
            return []
    
    def process_csv_file(self, file_path: Path) -> pd.DataFrame:
        """Process CSV file."""
        try:
            return pd.read_csv(file_path)
        except Exception as e:
            print(f"Error processing CSV file: {e}")
            return pd.DataFrame()
    
    def save_records(self, records: List[DataRecord], db: Session):
        """Save records to database."""
        for record in records:
            db_record = DBDataRecord(
                id=record.id,
                timestamp=record.timestamp,
                source=record.source,
                data=record.data,
                status=record.status.value
            )
            db.add(db_record)
        db.commit()
    
    async def run_ingestion(self):
        """Main ingestion process."""
        records = []
        
        # Process CSV files
        data_dir = Path("data/raw")
        for csv_file in data_dir.glob("*.csv"):
            df = self.process_csv_file(csv_file)
            for _, row in df.iterrows():
                record = DataRecord(
                    id=str(row['id']),
                    timestamp=datetime.now(),
                    source=f"csv:{csv_file.name}",
                    data=row.to_dict(),
                    status=RecordStatus.RAW
                )
                records.append(record)
        
        # Save to database
        db = next(get_db())
        self.save_records(records, db)
        
        return len(records)
```

### Step 4: Data Processing Service
```python
# src/processing/service.py
import time
from typing import List
from sqlalchemy.orm import Session
from sqlalchemy import and_

from src.common.models import ProcessingResult, RecordStatus
from src.common.database_models import DataRecord, ProcessingResult as DBProcessingResult
from src.config.database import get_db
from src.config.settings import Settings

class ProcessingService:
    def __init__(self, settings: Settings):
        self.settings = settings
    
    def validate_data(self, data: dict) -> bool:
        """Validate data quality."""
        required_fields = ['id', 'value']
        return all(field in data for field in required_fields)
    
    def transform_data(self, data: dict) -> dict:
        """Transform and clean data."""
        transformed = data.copy()
        
        # Clean numeric values
        if 'value' in transformed:
            try:
                transformed['value'] = float(transformed['value'])
            except (ValueError, TypeError):
                transformed['value'] = 0.0
        
        # Normalize categories
        if 'category' in transformed:
            transformed['category'] = str(transformed['category']).lower().strip()
        
        # Add processing metadata
        transformed['processed_timestamp'] = time.time()
        
        return transformed
    
    def process_record(self, record_data: dict) -> ProcessingResult:
        """Process a single data record."""
        start_time = time.time()
        
        try:
            if not self.validate_data(record_data):
                return ProcessingResult(
                    record_id=record_data.get('id', 'unknown'),
                    success=False,
                    error_message="Data validation failed",
                    processing_time=time.time() - start_time
                )
            
            processed_data = self.transform_data(record_data)
            
            return ProcessingResult(
                record_id=record_data['id'],
                success=True,
                processed_data=processed_data,
                processing_time=time.time() - start_time
            )
            
        except Exception as e:
            return ProcessingResult(
                record_id=record_data.get('id', 'unknown'),
                success=False,
                error_message=str(e),
                processing_time=time.time() - start_time
            )
    
    def process_batch(self, db: Session) -> int:
        """Process a batch of raw records."""
        # Get raw records
        raw_records = db.query(DataRecord).filter(
            DataRecord.status == 'raw'
        ).limit(self.settings.batch_size).all()
        
        processed_count = 0
        
        for db_record in raw_records:
            # Update status to processing
            db_record.status = 'processing'
            db.commit()
            
            # Process the record
            result = self.process_record(db_record.data)
            
            # Save processing result
            db_result = DBProcessingResult(
                record_id=db_record.id,
                success=result.success,
                processed_data=result.processed_data,
                error_message=result.error_message,
                processing_time=result.processing_time
            )
            db.add(db_result)
            
            # Update record status
            if result.success:
                db_record.status = 'processed'
                db_record.processed_at = datetime.now()
                processed_count += 1
            else:
                db_record.status = 'failed'
            
            db.commit()
        
        return processed_count
```

### Step 5: REST API Service
```python
# src/api/main.py
from fastapi import FastAPI, HTTPException, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
import time

from src.config.database import get_db
from src.config.settings import Settings
from src.common.database_models import DataRecord, ProcessingResult
from src.common.models import HealthStatus

settings = Settings.load()

app = FastAPI(
    title="DataFlow Analytics API",
    description="Complete data processing pipeline API",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    """Health check endpoint."""
    return HealthStatus(
        service="dataflow-api",
        status="healthy",
        timestamp=time.time(),
        details={"version": "1.0.0"}
    )

@app.get("/records")
async def get_records(
    status: Optional[str] = Query(None, description="Filter by status"),
    limit: int = Query(100, description="Number of records to return"),
    db: Session = Depends(get_db)
):
    """Get data records."""
    query = db.query(DataRecord)
    
    if status:
        query = query.filter(DataRecord.status == status)
    
    records = query.limit(limit).all()
    
    return {
        "records": [
            {
                "id": record.id,
                "timestamp": record.timestamp,
                "source": record.source,
                "status": record.status,
                "data": record.data
            }
            for record in records
        ],
        "count": len(records)
    }

@app.get("/records/{record_id}")
async def get_record(record_id: str, db: Session = Depends(get_db)):
    """Get a specific record."""
    record = db.query(DataRecord).filter(DataRecord.id == record_id).first()
    
    if not record:
        raise HTTPException(status_code=404, detail="Record not found")
    
    return {
        "id": record.id,
        "timestamp": record.timestamp,
        "source": record.source,
        "status": record.status,
        "data": record.data,
        "processed_at": record.processed_at
    }

@app.get("/stats")
async def get_stats(db: Session = Depends(get_db)):
    """Get pipeline statistics."""
    total_records = db.query(DataRecord).count()
    processed_records = db.query(DataRecord).filter(DataRecord.status == 'processed').count()
    failed_records = db.query(DataRecord).filter(DataRecord.status == 'failed').count()
    
    return {
        "total_records": total_records,
        "processed_records": processed_records,
        "failed_records": failed_records,
        "success_rate": (processed_records / total_records * 100) if total_records > 0 else 0
    }

@app.post("/process")
async def trigger_processing():
    """Trigger data processing."""
    # In a real implementation, this would trigger the processing service
    return {"message": "Processing triggered", "status": "started"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=settings.api_host, port=settings.api_port)
```

## Phase 3: Testing & Quality (30 minutes)

### Step 6: Implement Tests
```python
# tests/unit/test_processing.py
import pytest
from src.processing.service import ProcessingService
from src.config.settings import Settings

def test_data_validation():
    service = ProcessingService(Settings())
    
    valid_data = {'id': '123', 'value': 100, 'category': 'A'}
    assert service.validate_data(valid_data) == True
    
    invalid_data = {'id': '123'}  # Missing value
    assert service.validate_data(invalid_data) == False

def test_data_transformation():
    service = ProcessingService(Settings())
    
    input_data = {'id': '123', 'value': '100.5', 'category': '  A  '}
    result = service.transform_data(input_data)
    
    assert result['value'] == 100.5
    assert result['category'] == 'a'
    assert 'processed_timestamp' in result
```

```python
# tests/api/test_endpoints.py
import pytest
from fastapi.testclient import TestClient
from src.api.main import app

client = TestClient(app)

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "dataflow-api"
    assert data["status"] == "healthy"

def test_records_endpoint():
    response = client.get("/records")
    assert response.status_code == 200
    data = response.json()
    assert "records" in data
    assert "count" in data
```

## Phase 4: Deployment & CI/CD (30 minutes)

### Step 7: Build and Test
```bash
# Build Docker images
make build

# Run tests
make test

# Start services
make run

# Test API
curl http://localhost:8000/health
curl http://localhost:8000/records
```

### Step 8: Verify Complete Pipeline
```bash
# Check all services are running
docker-compose ps

# Check logs
docker-compose logs api
docker-compose logs ingestion
docker-compose logs processing

# Test database connection
docker-compose exec database psql -U dataflow -d dataflow -c "SELECT COUNT(*) FROM data_records;"
```

## Success Checklist

- [ ] Project structure created
- [ ] All services containerized
- [ ] Database schema created
- [ ] API endpoints working
- [ ] Tests passing
- [ ] CI/CD pipeline configured
- [ ] Documentation complete
- [ ] Health checks implemented
- [ ] Security measures in place
- [ ] Monitoring and logging active

## Next Steps

1. **Extend functionality**: Add real-time processing, ML models
2. **Improve monitoring**: Add Prometheus metrics, Grafana dashboards
3. **Scale deployment**: Deploy to Kubernetes, add load balancing
4. **Enhance security**: Add OAuth2, rate limiting, input validation
5. **Add features**: Data visualization, alerting, backup/restore

Congratulations! You've built a complete, production-ready data pipeline demonstrating mastery of all 30 days of developer tools! 🎉
