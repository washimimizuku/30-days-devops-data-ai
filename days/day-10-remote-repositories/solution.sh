#!/bin/bash

# Day 10: Remote Repositories - Solutions
# Advanced remote repository management and collaboration workflows

echo "=== Day 10: Remote Repositories Solutions ==="
echo "Advanced Git remote operations and enterprise collaboration workflows"
echo

# Create advanced remote project
PROJECT_NAME="enterprise-data-platform"
echo "Creating enterprise data platform: $PROJECT_NAME"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"
git init

# Configure Git with advanced settings
git config user.name "Senior Data Engineer"
git config user.email "senior@dataplatform.com"
git config push.default simple
git config pull.rebase true
git config branch.autosetupmerge always
git config branch.autosetuprebase always

echo "=== Solution 1: Enterprise Repository Setup ==="

echo "1.1 Creating enterprise-grade project structure:"
mkdir -p {src/{data_ingestion,data_processing,data_analysis,data_export},tests/{unit,integration,e2e},docs/{api,architecture,deployment},config/{dev,staging,prod},scripts/{deployment,monitoring,maintenance},infrastructure/{terraform,kubernetes,docker}}

# Create comprehensive .gitignore
cat > .gitignore << 'EOF'
# === Enterprise Data Platform .gitignore ===

# Data files and databases
data/
*.csv
*.tsv
*.json
*.jsonl
*.parquet
*.avro
*.orc
*.delta
*.sqlite
*.db
*.sql

# Credentials and secrets
*.pem
*.key
*.p12
*.pfx
config/*/secrets/
.env*
!.env.example
credentials.json
service-account*.json

# Build artifacts
build/
dist/
target/
*.egg-info/
__pycache__/
*.py[cod]
*$py.class

# IDE and editor files
.vscode/
.idea/
*.swp
*.swo
*~
.project
.pydevproject

# OS generated files
.DS_Store
.DS_Store?
._*
Thumbs.db
ehthumbs.db
Desktop.ini

# Logs and monitoring
logs/
*.log
*.log.*
monitoring/
metrics/

# Output and reports
output/
reports/
charts/
dashboards/
*.html
*.pdf
*.png
*.jpg
*.gif

# Virtual environments
venv/
env/
.venv/
.env/
ENV/

# Jupyter notebooks
.ipynb_checkpoints/
*.ipynb

# Testing
.coverage
.pytest_cache/
.tox/
htmlcov/
.nox/

# Documentation builds
docs/_build/
site/

# Terraform
*.tfstate
*.tfstate.*
.terraform/
.terraform.lock.hcl

# Kubernetes
*.kubeconfig

# Docker
.dockerignore
docker-compose.override.yml

# Package managers
node_modules/
.npm
.yarn/
package-lock.json
yarn.lock

# Cloud provider configs
.aws/
.gcp/
.azure/
EOF

# Create enterprise README
cat > README.md << 'EOF'
# Enterprise Data Platform

A comprehensive data engineering platform for enterprise-scale data processing and analytics.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Data Sources   │───▶│  Data Platform  │───▶│   Analytics     │
│                 │    │                 │    │                 │
│ • APIs          │    │ • Ingestion     │    │ • Dashboards    │
│ • Databases     │    │ • Processing    │    │ • Reports       │
│ • Files         │    │ • Storage       │    │ • ML Models     │
│ • Streams       │    │ • Orchestration │    │ • APIs          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Project Structure

```
├── src/                        # Source code
│   ├── data_ingestion/         # Data ingestion modules
│   ├── data_processing/        # ETL and data transformation
│   ├── data_analysis/          # Analytics and ML
│   └── data_export/            # Data export and APIs
├── tests/                      # Test suites
│   ├── unit/                   # Unit tests
│   ├── integration/            # Integration tests
│   └── e2e/                    # End-to-end tests
├── docs/                       # Documentation
│   ├── api/                    # API documentation
│   ├── architecture/           # System architecture
│   └── deployment/             # Deployment guides
├── config/                     # Configuration files
│   ├── dev/                    # Development environment
│   ├── staging/                # Staging environment
│   └── prod/                   # Production environment
├── scripts/                    # Utility scripts
│   ├── deployment/             # Deployment automation
│   ├── monitoring/             # Monitoring setup
│   └── maintenance/            # Maintenance tasks
└── infrastructure/             # Infrastructure as Code
    ├── terraform/              # Terraform configurations
    ├── kubernetes/             # Kubernetes manifests
    └── docker/                 # Docker configurations
```

## 🚀 Quick Start

### Prerequisites
- Python 3.9+
- Docker & Docker Compose
- Terraform (for infrastructure)
- kubectl (for Kubernetes)

### Local Development Setup
```bash
# Clone repository
git clone <repository-url>
cd enterprise-data-platform

# Set up Python environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Set up pre-commit hooks
pre-commit install

# Run tests
pytest tests/

# Start local development environment
docker-compose up -d
```

### Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit configuration
nano .env

# Load environment
source .env
```

## 🔄 Development Workflow

### Branch Strategy
We follow **Git Flow** with the following branches:
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: Feature development
- `release/*`: Release preparation
- `hotfix/*`: Critical production fixes

### Contribution Process
1. **Fork** the repository
2. **Create** feature branch from `develop`
3. **Implement** feature with tests
4. **Submit** pull request to `develop`
5. **Code review** and approval
6. **Merge** after CI/CD passes

### Code Quality Standards
- **Test Coverage**: Minimum 80%
- **Code Style**: Black, flake8, mypy
- **Documentation**: Docstrings for all public APIs
- **Security**: No secrets in code, security scanning
- **Performance**: Profiling for critical paths

## 🧪 Testing

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test categories
pytest tests/unit/
pytest tests/integration/
pytest tests/e2e/

# Run performance tests
pytest tests/performance/ --benchmark-only
```

## 📊 Monitoring & Observability

- **Metrics**: Prometheus + Grafana
- **Logging**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **Tracing**: Jaeger
- **Alerting**: PagerDuty integration
- **Health Checks**: Built-in health endpoints

## 🚢 Deployment

### Staging Deployment
```bash
# Deploy to staging
./scripts/deployment/deploy.sh staging

# Run smoke tests
./scripts/deployment/smoke-tests.sh staging
```

### Production Deployment
```bash
# Create release branch
git checkout develop
git checkout -b release/v1.2.0

# Deploy to production (requires approval)
./scripts/deployment/deploy.sh production

# Monitor deployment
./scripts/monitoring/check-deployment.sh production
```

## 📚 Documentation

- [API Documentation](docs/api/README.md)
- [Architecture Guide](docs/architecture/README.md)
- [Deployment Guide](docs/deployment/README.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Security Policy](SECURITY.md)

## 🔐 Security

- **Authentication**: OAuth 2.0 / OIDC
- **Authorization**: RBAC with fine-grained permissions
- **Encryption**: TLS 1.3, AES-256 at rest
- **Secrets Management**: HashiCorp Vault
- **Vulnerability Scanning**: Automated security scans
- **Compliance**: SOC 2, GDPR, HIPAA ready

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Security**: security@dataplatform.com
- **Documentation**: [Wiki](../../wiki)

---

**Enterprise Data Platform** - Powering data-driven decisions at scale.
EOF

echo "✓ Enterprise project structure created"
#!/bin/bash

# Day 10 Solutions - Part 2: Advanced remote workflows

echo "1.2 Create enterprise configuration files:"

# Requirements files
cat > requirements.txt << 'EOF'
# Core data processing
pandas>=2.0.0
numpy>=1.24.0
pyarrow>=12.0.0
polars>=0.18.0

# Database connectivity
sqlalchemy>=2.0.0
psycopg2-binary>=2.9.0
pymongo>=4.4.0
redis>=4.6.0

# Cloud providers
boto3>=1.28.0
google-cloud-storage>=2.10.0
azure-storage-blob>=12.17.0

# Data validation
pydantic>=2.0.0
great-expectations>=0.17.0

# API framework
fastapi>=0.100.0
uvicorn>=0.23.0

# Monitoring
prometheus-client>=0.17.0
structlog>=23.1.0

# Workflow orchestration
apache-airflow>=2.7.0
prefect>=2.11.0
EOF

cat > requirements-dev.txt << 'EOF'
# Include production requirements
-r requirements.txt

# Testing
pytest>=7.4.0
pytest-cov>=4.1.0
pytest-mock>=3.11.0
pytest-asyncio>=0.21.0
pytest-benchmark>=4.0.0

# Code quality
black>=23.7.0
flake8>=6.0.0
mypy>=1.5.0
isort>=5.12.0
pre-commit>=3.3.0

# Documentation
sphinx>=7.1.0
mkdocs>=1.5.0
mkdocs-material>=9.1.0

# Development tools
ipython>=8.14.0
jupyter>=1.0.0
notebook>=7.0.0

# Profiling and debugging
memory-profiler>=0.61.0
line-profiler>=4.1.0
py-spy>=0.3.0
EOF

# Environment template
cat > .env.example << 'EOF'
# Environment Configuration Template
# Copy to .env and customize for your environment

# Application
APP_NAME=enterprise-data-platform
APP_VERSION=1.0.0
APP_ENVIRONMENT=development
APP_DEBUG=true

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dataplatform
REDIS_URL=redis://localhost:6379/0

# Cloud Storage
AWS_REGION=us-west-2
AWS_S3_BUCKET=data-platform-bucket
GCP_PROJECT_ID=data-platform-project
AZURE_STORAGE_ACCOUNT=dataplatformstorage

# API Keys (use secrets management in production)
API_KEY_EXTERNAL_SERVICE=your-api-key-here
WEBHOOK_SECRET=your-webhook-secret

# Monitoring
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000
LOG_LEVEL=INFO

# Security
JWT_SECRET_KEY=your-jwt-secret-key
ENCRYPTION_KEY=your-encryption-key
EOF

echo "1.3 Create core data platform modules:"

# Data ingestion module
cat > src/data_ingestion/base_ingestion.py << 'EOF'
"""Base classes for data ingestion."""

from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional
import logging
from datetime import datetime
import structlog

logger = structlog.get_logger(__name__)

class BaseIngestionSource(ABC):
    """Base class for all data ingestion sources."""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.source_name = config.get('source_name', 'unknown')
        self.logger = logger.bind(source=self.source_name)
    
    @abstractmethod
    async def extract(self) -> List[Dict[str, Any]]:
        """Extract data from the source."""
        pass
    
    @abstractmethod
    def validate_config(self) -> bool:
        """Validate source configuration."""
        pass
    
    def get_metadata(self) -> Dict[str, Any]:
        """Get source metadata."""
        return {
            'source_name': self.source_name,
            'extraction_time': datetime.utcnow().isoformat(),
            'config': {k: v for k, v in self.config.items() if 'secret' not in k.lower()}
        }

class APIIngestionSource(BaseIngestionSource):
    """Ingest data from REST APIs."""
    
    def validate_config(self) -> bool:
        required_fields = ['api_url', 'api_key']
        return all(field in self.config for field in required_fields)
    
    async def extract(self) -> List[Dict[str, Any]]:
        """Extract data from API endpoint."""
        import aiohttp
        
        if not self.validate_config():
            raise ValueError("Invalid API configuration")
        
        url = self.config['api_url']
        headers = {'Authorization': f"Bearer {self.config['api_key']}"}
        
        async with aiohttp.ClientSession() as session:
            async with session.get(url, headers=headers) as response:
                if response.status == 200:
                    data = await response.json()
                    self.logger.info("API extraction successful", records=len(data))
                    return data if isinstance(data, list) else [data]
                else:
                    self.logger.error("API extraction failed", status=response.status)
                    raise Exception(f"API request failed with status {response.status}")

class DatabaseIngestionSource(BaseIngestionSource):
    """Ingest data from databases."""
    
    def validate_config(self) -> bool:
        required_fields = ['connection_string', 'query']
        return all(field in self.config for field in required_fields)
    
    async def extract(self) -> List[Dict[str, Any]]:
        """Extract data from database."""
        import pandas as pd
        from sqlalchemy import create_engine
        
        if not self.validate_config():
            raise ValueError("Invalid database configuration")
        
        engine = create_engine(self.config['connection_string'])
        
        try:
            df = pd.read_sql(self.config['query'], engine)
            records = df.to_dict('records')
            self.logger.info("Database extraction successful", records=len(records))
            return records
        except Exception as e:
            self.logger.error("Database extraction failed", error=str(e))
            raise
        finally:
            engine.dispose()
EOF

# Data processing module
cat > src/data_processing/pipeline.py << 'EOF'
"""Data processing pipeline framework."""

from typing import Dict, Any, List, Callable, Optional
import asyncio
from datetime import datetime
import structlog
from abc import ABC, abstractmethod

logger = structlog.get_logger(__name__)

class ProcessingStep(ABC):
    """Base class for processing steps."""
    
    def __init__(self, name: str, config: Dict[str, Any]):
        self.name = name
        self.config = config
        self.logger = logger.bind(step=name)
    
    @abstractmethod
    async def process(self, data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Process the data."""
        pass
    
    def get_metrics(self) -> Dict[str, Any]:
        """Get processing metrics."""
        return {
            'step_name': self.name,
            'processed_at': datetime.utcnow().isoformat()
        }

class DataValidationStep(ProcessingStep):
    """Validate data quality and schema."""
    
    async def process(self, data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Validate data records."""
        self.logger.info("Starting data validation", input_records=len(data))
        
        valid_records = []
        validation_errors = []
        
        required_fields = self.config.get('required_fields', [])
        
        for i, record in enumerate(data):
            try:
                # Check required fields
                missing_fields = [field for field in required_fields if field not in record]
                if missing_fields:
                    validation_errors.append({
                        'record_index': i,
                        'error': f"Missing required fields: {missing_fields}"
                    })
                    continue
                
                # Check data types if specified
                type_mapping = self.config.get('type_mapping', {})
                for field, expected_type in type_mapping.items():
                    if field in record:
                        if expected_type == 'int':
                            record[field] = int(record[field])
                        elif expected_type == 'float':
                            record[field] = float(record[field])
                        elif expected_type == 'str':
                            record[field] = str(record[field])
                
                valid_records.append(record)
                
            except Exception as e:
                validation_errors.append({
                    'record_index': i,
                    'error': str(e)
                })
        
        self.logger.info("Data validation completed", 
                        valid_records=len(valid_records),
                        validation_errors=len(validation_errors))
        
        if validation_errors and self.config.get('strict_validation', False):
            raise ValueError(f"Validation failed with {len(validation_errors)} errors")
        
        return valid_records

class DataTransformationStep(ProcessingStep):
    """Transform data records."""
    
    async def process(self, data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Transform data records."""
        self.logger.info("Starting data transformation", input_records=len(data))
        
        transformations = self.config.get('transformations', [])
        transformed_data = data.copy()
        
        for transformation in transformations:
            transform_type = transformation.get('type')
            
            if transform_type == 'add_field':
                field_name = transformation['field_name']
                field_value = transformation['field_value']
                for record in transformed_data:
                    record[field_name] = field_value
            
            elif transform_type == 'rename_field':
                old_name = transformation['old_name']
                new_name = transformation['new_name']
                for record in transformed_data:
                    if old_name in record:
                        record[new_name] = record.pop(old_name)
            
            elif transform_type == 'calculate_field':
                field_name = transformation['field_name']
                expression = transformation['expression']
                for record in transformed_data:
                    try:
                        # Simple expression evaluation (extend as needed)
                        if expression == 'timestamp':
                            record[field_name] = datetime.utcnow().isoformat()
                    except Exception as e:
                        self.logger.warning("Field calculation failed", 
                                          field=field_name, error=str(e))
        
        self.logger.info("Data transformation completed", output_records=len(transformed_data))
        return transformed_data

class DataPipeline:
    """Orchestrate data processing pipeline."""
    
    def __init__(self, name: str, steps: List[ProcessingStep]):
        self.name = name
        self.steps = steps
        self.logger = logger.bind(pipeline=name)
    
    async def execute(self, input_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Execute the complete pipeline."""
        self.logger.info("Starting pipeline execution", 
                        input_records=len(input_data),
                        steps=len(self.steps))
        
        start_time = datetime.utcnow()
        current_data = input_data
        step_metrics = []
        
        try:
            for step in self.steps:
                step_start = datetime.utcnow()
                current_data = await step.process(current_data)
                step_end = datetime.utcnow()
                
                step_metric = step.get_metrics()
                step_metric.update({
                    'duration_seconds': (step_end - step_start).total_seconds(),
                    'input_records': len(input_data) if step == self.steps[0] else None,
                    'output_records': len(current_data)
                })
                step_metrics.append(step_metric)
            
            end_time = datetime.utcnow()
            
            result = {
                'pipeline_name': self.name,
                'status': 'success',
                'start_time': start_time.isoformat(),
                'end_time': end_time.isoformat(),
                'duration_seconds': (end_time - start_time).total_seconds(),
                'input_records': len(input_data),
                'output_records': len(current_data),
                'step_metrics': step_metrics,
                'data': current_data
            }
            
            self.logger.info("Pipeline execution completed successfully",
                           duration=result['duration_seconds'],
                           output_records=len(current_data))
            
            return result
            
        except Exception as e:
            self.logger.error("Pipeline execution failed", error=str(e))
            raise
EOF

echo "✓ Core data platform modules created"

echo "=== Solution 2: Advanced Remote Configuration ==="

echo "2.1 Set up multiple remote repositories:"
# Create bare repositories to simulate different remotes
cd ..

# Create origin (main repository)
git clone --bare "$PROJECT_NAME" "${PROJECT_NAME}-origin.git"

# Create upstream (original/parent repository)
git clone --bare "$PROJECT_NAME" "${PROJECT_NAME}-upstream.git"

# Create backup repository
git clone --bare "$PROJECT_NAME" "${PROJECT_NAME}-backup.git"

cd "$PROJECT_NAME"

echo "2.2 Configure multiple remotes:"
git remote add origin "../${PROJECT_NAME}-origin.git"
git remote add upstream "../${PROJECT_NAME}-upstream.git"
git remote add backup "../${PROJECT_NAME}-backup.git"

echo "2.3 Set up remote tracking:"
git push -u origin main
git push backup main

echo "✓ Multiple remotes configured"
git remote -v
#!/bin/bash

# Day 10 Solutions - Part 3: Enterprise workflows and finalization

echo "=== Solution 3: Enterprise Collaboration Workflow ==="

echo "3.1 Create development team simulation:"
# Create multiple developer clones
cd ..

# Developer 1: Data Engineer
git clone "${PROJECT_NAME}-origin.git" "${PROJECT_NAME}-dev1"
cd "${PROJECT_NAME}-dev1"
git config user.name "Data Engineer 1"
git config user.email "dev1@dataplatform.com"
git remote add upstream "../${PROJECT_NAME}-upstream.git"

# Create feature branch for data ingestion enhancement
git checkout -b feature/enhanced-ingestion

cat > src/data_ingestion/streaming_ingestion.py << 'EOF'
"""Real-time streaming data ingestion."""

import asyncio
from typing import Dict, Any, AsyncGenerator
import structlog
from .base_ingestion import BaseIngestionSource

logger = structlog.get_logger(__name__)

class StreamingIngestionSource(BaseIngestionSource):
    """Ingest data from streaming sources."""
    
    def validate_config(self) -> bool:
        required_fields = ['stream_url', 'stream_format']
        return all(field in self.config for field in required_fields)
    
    async def extract(self) -> AsyncGenerator[Dict[str, Any], None]:
        """Extract streaming data."""
        if not self.validate_config():
            raise ValueError("Invalid streaming configuration")
        
        # Simulate streaming data
        for i in range(100):
            yield {
                'id': i,
                'timestamp': '2023-12-12T10:00:00Z',
                'value': i * 10,
                'source': self.source_name
            }
            await asyncio.sleep(0.1)  # Simulate real-time delay

class KafkaIngestionSource(BaseIngestionSource):
    """Ingest data from Apache Kafka."""
    
    def validate_config(self) -> bool:
        required_fields = ['kafka_brokers', 'topic', 'consumer_group']
        return all(field in self.config for field in required_fields)
    
    async def extract(self) -> AsyncGenerator[Dict[str, Any], None]:
        """Extract data from Kafka topic."""
        if not self.validate_config():
            raise ValueError("Invalid Kafka configuration")
        
        self.logger.info("Starting Kafka consumption",
                        topic=self.config['topic'],
                        consumer_group=self.config['consumer_group'])
        
        # Simulate Kafka messages
        for i in range(50):
            message = {
                'partition': 0,
                'offset': i,
                'key': f'key_{i}',
                'value': {
                    'event_id': f'event_{i}',
                    'event_type': 'user_action',
                    'timestamp': '2023-12-12T10:00:00Z',
                    'data': {'user_id': i, 'action': 'click'}
                }
            }
            yield message['value']
            await asyncio.sleep(0.05)
EOF

git add src/data_ingestion/streaming_ingestion.py
git commit -m "Add streaming data ingestion capabilities

- Implement real-time streaming data source
- Add Apache Kafka integration
- Support for high-throughput data ingestion
- Async generator pattern for memory efficiency"

git push -u origin feature/enhanced-ingestion

cd ..

# Developer 2: ML Engineer
git clone "${PROJECT_NAME}-origin.git" "${PROJECT_NAME}-dev2"
cd "${PROJECT_NAME}-dev2"
git config user.name "ML Engineer"
git config user.email "ml@dataplatform.com"
git remote add upstream "../${PROJECT_NAME}-upstream.git"

git checkout -b feature/ml-pipeline

cat > src/data_analysis/ml_pipeline.py << 'EOF'
"""Machine Learning pipeline for the data platform."""

from typing import Dict, Any, List, Optional, Tuple
import numpy as np
import pandas as pd
from abc import ABC, abstractmethod
import structlog
import joblib
from datetime import datetime

logger = structlog.get_logger(__name__)

class BaseMLModel(ABC):
    """Base class for ML models."""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.model_name = config.get('model_name', 'unknown')
        self.logger = logger.bind(model=self.model_name)
        self.model = None
        self.is_trained = False
    
    @abstractmethod
    def train(self, X: pd.DataFrame, y: pd.Series) -> Dict[str, Any]:
        """Train the model."""
        pass
    
    @abstractmethod
    def predict(self, X: pd.DataFrame) -> np.ndarray:
        """Make predictions."""
        pass
    
    def save_model(self, path: str) -> None:
        """Save trained model."""
        if not self.is_trained:
            raise ValueError("Model must be trained before saving")
        
        model_data = {
            'model': self.model,
            'config': self.config,
            'trained_at': datetime.utcnow().isoformat(),
            'model_name': self.model_name
        }
        
        joblib.dump(model_data, path)
        self.logger.info("Model saved", path=path)
    
    def load_model(self, path: str) -> None:
        """Load trained model."""
        model_data = joblib.load(path)
        self.model = model_data['model']
        self.config.update(model_data['config'])
        self.is_trained = True
        self.logger.info("Model loaded", path=path)

class AnomalyDetectionModel(BaseMLModel):
    """Anomaly detection using Isolation Forest."""
    
    def train(self, X: pd.DataFrame, y: Optional[pd.Series] = None) -> Dict[str, Any]:
        """Train anomaly detection model."""
        from sklearn.ensemble import IsolationForest
        from sklearn.preprocessing import StandardScaler
        
        self.logger.info("Training anomaly detection model", samples=len(X))
        
        # Preprocessing
        self.scaler = StandardScaler()
        X_scaled = self.scaler.fit_transform(X)
        
        # Model training
        contamination = self.config.get('contamination', 0.1)
        self.model = IsolationForest(
            contamination=contamination,
            random_state=42,
            n_estimators=100
        )
        
        self.model.fit(X_scaled)
        self.is_trained = True
        
        # Calculate training metrics
        train_predictions = self.model.predict(X_scaled)
        anomaly_count = np.sum(train_predictions == -1)
        
        metrics = {
            'training_samples': len(X),
            'anomalies_detected': int(anomaly_count),
            'anomaly_rate': float(anomaly_count / len(X)),
            'contamination_threshold': contamination
        }
        
        self.logger.info("Anomaly detection model trained", **metrics)
        return metrics
    
    def predict(self, X: pd.DataFrame) -> Tuple[np.ndarray, np.ndarray]:
        """Predict anomalies and anomaly scores."""
        if not self.is_trained:
            raise ValueError("Model must be trained before prediction")
        
        X_scaled = self.scaler.transform(X)
        predictions = self.model.predict(X_scaled)
        scores = self.model.score_samples(X_scaled)
        
        return predictions, scores

class PredictiveModel(BaseMLModel):
    """Predictive modeling using various algorithms."""
    
    def train(self, X: pd.DataFrame, y: pd.Series) -> Dict[str, Any]:
        """Train predictive model."""
        from sklearn.ensemble import RandomForestRegressor
        from sklearn.model_selection import train_test_split
        from sklearn.metrics import mean_squared_error, r2_score
        from sklearn.preprocessing import StandardScaler
        
        self.logger.info("Training predictive model", 
                        samples=len(X), features=len(X.columns))
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Preprocessing
        self.scaler = StandardScaler()
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        # Model training
        n_estimators = self.config.get('n_estimators', 100)
        self.model = RandomForestRegressor(
            n_estimators=n_estimators,
            random_state=42,
            n_jobs=-1
        )
        
        self.model.fit(X_train_scaled, y_train)
        self.is_trained = True
        
        # Evaluation
        y_pred = self.model.predict(X_test_scaled)
        
        metrics = {
            'training_samples': len(X_train),
            'test_samples': len(X_test),
            'mse': float(mean_squared_error(y_test, y_pred)),
            'r2_score': float(r2_score(y_test, y_pred)),
            'feature_importance': dict(zip(X.columns, self.model.feature_importances_))
        }
        
        self.logger.info("Predictive model trained", **{k: v for k, v in metrics.items() if k != 'feature_importance'})
        return metrics
    
    def predict(self, X: pd.DataFrame) -> np.ndarray:
        """Make predictions."""
        if not self.is_trained:
            raise ValueError("Model must be trained before prediction")
        
        X_scaled = self.scaler.transform(X)
        predictions = self.model.predict(X_scaled)
        
        return predictions

class MLPipeline:
    """End-to-end ML pipeline."""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.pipeline_name = config.get('pipeline_name', 'ml_pipeline')
        self.logger = logger.bind(pipeline=self.pipeline_name)
        self.models = {}
    
    def add_model(self, model_name: str, model: BaseMLModel) -> None:
        """Add model to pipeline."""
        self.models[model_name] = model
        self.logger.info("Model added to pipeline", model_name=model_name)
    
    async def train_pipeline(self, data: pd.DataFrame) -> Dict[str, Any]:
        """Train all models in pipeline."""
        self.logger.info("Starting ML pipeline training", samples=len(data))
        
        results = {}
        
        for model_name, model in self.models.items():
            try:
                if isinstance(model, AnomalyDetectionModel):
                    # Anomaly detection (unsupervised)
                    feature_cols = [col for col in data.columns if col != 'target']
                    X = data[feature_cols]
                    metrics = model.train(X)
                
                elif isinstance(model, PredictiveModel):
                    # Supervised learning
                    if 'target' not in data.columns:
                        self.logger.warning("No target column for supervised learning", 
                                          model=model_name)
                        continue
                    
                    feature_cols = [col for col in data.columns if col != 'target']
                    X = data[feature_cols]
                    y = data['target']
                    metrics = model.train(X, y)
                
                results[model_name] = {
                    'status': 'success',
                    'metrics': metrics
                }
                
            except Exception as e:
                self.logger.error("Model training failed", 
                                model=model_name, error=str(e))
                results[model_name] = {
                    'status': 'failed',
                    'error': str(e)
                }
        
        self.logger.info("ML pipeline training completed", 
                        models_trained=len([r for r in results.values() if r['status'] == 'success']))
        
        return results
    
    def get_pipeline_info(self) -> Dict[str, Any]:
        """Get pipeline information."""
        return {
            'pipeline_name': self.pipeline_name,
            'models': list(self.models.keys()),
            'config': self.config
        }
EOF

git add src/data_analysis/ml_pipeline.py
git commit -m "Add comprehensive ML pipeline framework

- Implement anomaly detection with Isolation Forest
- Add predictive modeling with Random Forest
- Support for model training, evaluation, and persistence
- Async pipeline execution with error handling
- Comprehensive logging and metrics collection"

git push -u origin feature/ml-pipeline

cd ..

echo "✓ Multiple developer features created"

echo "3.2 Simulate collaborative merge workflow:"
cd "$PROJECT_NAME"

# Fetch all remote changes
git fetch origin

# Merge streaming ingestion feature
git checkout -b integration/streaming-ingestion origin/feature/enhanced-ingestion
git checkout main
git merge --no-ff integration/streaming-ingestion
git push origin main

# Merge ML pipeline feature
git checkout -b integration/ml-pipeline origin/feature/ml-pipeline
git checkout main
git merge --no-ff integration/ml-pipeline
git push origin main

echo "✓ Features integrated into main branch"

echo "=== Solution 4: Advanced Remote Operations ==="

echo "4.1 Demonstrate advanced remote synchronization:"

# Create comprehensive documentation
cat > docs/architecture/REMOTE_WORKFLOW.md << 'EOF'
# Remote Repository Workflow

## Overview

This document describes the enterprise-grade remote repository workflow for the Data Platform project.

## Repository Structure

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Upstream      │    │     Origin      │    │   Developer     │
│  (Original)     │───▶│   (Your Fork)   │───▶│    (Local)      │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Remote Configuration

### Standard Remotes
- `origin`: Your main repository (fork or primary repo)
- `upstream`: Original repository (if forked)
- `backup`: Backup repository for disaster recovery

### Setup Commands
```bash
# Add remotes
git remote add origin git@github.com:yourorg/data-platform.git
git remote add upstream git@github.com:originalorg/data-platform.git
git remote add backup git@gitlab.com:yourorg/data-platform-backup.git

# Verify configuration
git remote -v
```

## Workflow Patterns

### Feature Development
1. **Sync with upstream**
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   git push origin main
   ```

2. **Create feature branch**
   ```bash
   git checkout -b feature/new-capability
   ```

3. **Develop and commit**
   ```bash
   git add .
   git commit -m "Add new capability"
   ```

4. **Push feature branch**
   ```bash
   git push -u origin feature/new-capability
   ```

5. **Create pull request**
   - Open PR from `feature/new-capability` to `main`
   - Request code review
   - Address feedback
   - Merge after approval

### Release Management
1. **Create release branch**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b release/v1.2.0
   ```

2. **Prepare release**
   - Update version numbers
   - Update CHANGELOG
   - Run final tests

3. **Merge to main and tag**
   ```bash
   git checkout main
   git merge --no-ff release/v1.2.0
   git tag -a v1.2.0 -m "Release version 1.2.0"
   git push origin main --tags
   ```

### Hotfix Workflow
1. **Create hotfix from main**
   ```bash
   git checkout main
   git checkout -b hotfix/critical-fix
   ```

2. **Fix and test**
   ```bash
   git add .
   git commit -m "Fix critical production issue"
   ```

3. **Merge to main and develop**
   ```bash
   git checkout main
   git merge --no-ff hotfix/critical-fix
   git push origin main
   
   git checkout develop
   git merge --no-ff hotfix/critical-fix
   git push origin develop
   ```

## Security Best Practices

### SSH Key Management
- Use Ed25519 keys: `ssh-keygen -t ed25519 -C "email@example.com"`
- Use strong passphrases
- Rotate keys regularly
- Use different keys for different services

### Repository Security
- Enable branch protection rules
- Require pull request reviews
- Enable status checks
- Restrict force pushes
- Use signed commits for releases

### Secrets Management
- Never commit secrets to repository
- Use environment variables
- Use secrets management tools (Vault, AWS Secrets Manager)
- Scan for secrets in CI/CD pipeline

## Troubleshooting

### Common Issues

#### Authentication Problems
```bash
# Test SSH connection
ssh -T git@github.com

# Re-add SSH key
ssh-add ~/.ssh/id_ed25519
```

#### Sync Issues
```bash
# Force sync with upstream
git fetch upstream
git reset --hard upstream/main
git push --force-with-lease origin main
```

#### Large File Issues
```bash
# Use Git LFS for large files
git lfs track "*.parquet"
git add .gitattributes
git commit -m "Track large files with LFS"
```

## Monitoring and Metrics

### Repository Health
- Monitor repository size
- Track commit frequency
- Monitor branch lifecycle
- Review merge conflicts

### Team Collaboration
- Pull request metrics
- Code review turnaround time
- Branch protection compliance
- Security scan results
EOF

git add docs/architecture/REMOTE_WORKFLOW.md
git commit -m "Add comprehensive remote workflow documentation

- Document enterprise repository structure
- Include security best practices
- Add troubleshooting guide
- Provide monitoring recommendations"

git push origin main
git push backup main

echo "✓ Advanced documentation and synchronization completed"

echo "4.2 Repository analysis and statistics:"
echo "Repository Statistics:"
echo "====================="
echo "Total commits: $(git rev-list --count --all)"
echo "Total branches: $(git branch -a | wc -l)"
echo "Total remotes: $(git remote | wc -l)"
echo "Repository size: $(du -sh .git | cut -f1)"
echo "Contributors: $(git shortlog -sn | wc -l)"

echo
echo "Remote Configuration:"
git remote -v

echo
echo "Branch Status:"
git branch -a

echo
echo "Recent Activity:"
git log --oneline --graph -10

# Combine all solution parts
cd ..
cat "${PROJECT_NAME}/solution.sh" "${PROJECT_NAME}/solution_part2.sh" "${PROJECT_NAME}/solution_part3.sh" > solution_combined.sh 2>/dev/null || echo "Combining solution parts..."
mv solution_combined.sh "${PROJECT_NAME}/solution.sh" 2>/dev/null || echo "Solution combined"
rm -f "${PROJECT_NAME}/solution_part2.sh" "${PROJECT_NAME}/solution_part3.sh" 2>/dev/null

cd "$PROJECT_NAME"

echo
echo "=== Advanced Solutions Complete ==="
echo
echo "Enterprise Git remote repository techniques demonstrated:"
echo "✅ Enterprise-grade project structure and configuration"
echo "✅ Multiple remote repository management"
echo "✅ Advanced collaboration workflows"
echo "✅ Streaming data ingestion capabilities"
echo "✅ Machine learning pipeline framework"
echo "✅ Comprehensive documentation and security practices"
echo "✅ Repository monitoring and analytics"
echo "✅ Professional development team simulation"
echo "✅ Advanced merge and integration strategies"
echo "✅ Disaster recovery and backup procedures"
echo
echo "🎯 You've mastered enterprise Git remote repository management!"
echo
echo "Key components implemented:"
echo "• Multi-remote repository architecture"
echo "• Real-time streaming data ingestion"
echo "• ML pipeline with anomaly detection and prediction"
echo "• Comprehensive security and workflow documentation"
echo "• Professional collaboration patterns"
echo "• Advanced Git operations and troubleshooting"
