# Day 28: Security and Configuration Management

**Duration**: 1 hour  
**Prerequisites**: Environment variables, file operations, basic cryptography concepts  
**Learning Goal**: Master secure configuration management and security best practices for data pipelines

## Overview

Security and configuration management are critical for production data pipelines. You'll learn to handle secrets, manage configurations across environments, implement encryption, and follow security best practices for data applications.

## Why Security Matters

**Common security risks in data pipelines**:
- Hardcoded credentials in source code
- Unencrypted sensitive data transmission
- Inadequate access controls and permissions
- Configuration drift across environments
- Exposed API keys and database passwords
- Insecure data storage and processing

**Benefits of proper security**:
- Protection of sensitive data and credentials
- Compliance with regulations (GDPR, HIPAA, SOX)
- Reduced risk of data breaches
- Consistent configurations across environments
- Audit trails and access logging

## Core Security Concepts

### The Security Triad

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Confidentiality** | Data privacy and access control | Encryption, authentication |
| **Integrity** | Data accuracy and consistency | Checksums, digital signatures |
| **Availability** | System uptime and accessibility | Redundancy, monitoring |

### Configuration Management Principles

```python
# ❌ Bad: Hardcoded secrets
DATABASE_URL = "postgresql://user:password123@localhost/db"
API_KEY = "sk-1234567890abcdef"

# ✅ Good: Environment-based configuration
import os
DATABASE_URL = os.getenv('DATABASE_URL')
API_KEY = os.getenv('API_KEY')
```

## Environment Variables and .env Files

### Basic Environment Variables

```bash
# Set environment variables
export DATABASE_URL="postgresql://user:pass@localhost/db"
export API_KEY="your-secret-key"
export DEBUG="false"

# Use in Python
import os

database_url = os.getenv('DATABASE_URL')
api_key = os.getenv('API_KEY', 'default-key')  # With default
debug = os.getenv('DEBUG', 'false').lower() == 'true'
```

### .env Files with python-dotenv

```python
# Install: pip install python-dotenv

# .env file
DATABASE_URL=postgresql://user:pass@localhost/db
API_KEY=your-secret-key
DEBUG=true
MAX_WORKERS=4

# Load in Python
from dotenv import load_dotenv
import os

load_dotenv()  # Load .env file

database_url = os.getenv('DATABASE_URL')
api_key = os.getenv('API_KEY')
debug = os.getenv('DEBUG', 'false').lower() == 'true'
max_workers = int(os.getenv('MAX_WORKERS', '1'))
```

### Environment-Specific Configuration

```python
import os
from dataclasses import dataclass
from typing import Optional

@dataclass
class Config:
    database_url: str
    api_key: str
    debug: bool
    max_workers: int
    log_level: str
    
    @classmethod
    def from_env(cls, env_file: Optional[str] = None):
        if env_file:
            from dotenv import load_dotenv
            load_dotenv(env_file)
        
        return cls(
            database_url=os.getenv('DATABASE_URL', ''),
            api_key=os.getenv('API_KEY', ''),
            debug=os.getenv('DEBUG', 'false').lower() == 'true',
            max_workers=int(os.getenv('MAX_WORKERS', '1')),
            log_level=os.getenv('LOG_LEVEL', 'INFO')
        )

# Usage
config = Config.from_env('.env.production')
```

## Secrets Management

### Basic Secret Handling

```python
import os
import getpass
from cryptography.fernet import Fernet

class SecretManager:
    def __init__(self):
        self.key = self._get_or_create_key()
        self.cipher = Fernet(self.key)
    
    def _get_or_create_key(self):
        key = os.getenv('ENCRYPTION_KEY')
        if key:
            return key.encode()
        
        # Generate new key (save this securely!)
        key = Fernet.generate_key()
        print(f"Generated new key: {key.decode()}")
        print("Save this key securely and set ENCRYPTION_KEY environment variable")
        return key
    
    def encrypt_secret(self, secret: str) -> str:
        return self.cipher.encrypt(secret.encode()).decode()
    
    def decrypt_secret(self, encrypted_secret: str) -> str:
        return self.cipher.decrypt(encrypted_secret.encode()).decode()
    
    def get_secret(self, key: str, encrypted: bool = False) -> str:
        value = os.getenv(key)
        if not value:
            # Prompt for secret if not in environment
            value = getpass.getpass(f"Enter {key}: ")
        
        if encrypted:
            return self.decrypt_secret(value)
        return value

# Usage
secret_manager = SecretManager()
db_password = secret_manager.get_secret('DB_PASSWORD', encrypted=True)
```

### AWS Secrets Manager Integration

```python
import boto3
import json
from botocore.exceptions import ClientError

class AWSSecretsManager:
    def __init__(self, region_name='us-east-1'):
        self.client = boto3.client('secretsmanager', region_name=region_name)
    
    def get_secret(self, secret_name: str) -> dict:
        try:
            response = self.client.get_secret_value(SecretId=secret_name)
            return json.loads(response['SecretString'])
        except ClientError as e:
            print(f"Error retrieving secret {secret_name}: {e}")
            return {}
    
    def create_secret(self, secret_name: str, secret_value: dict):
        try:
            self.client.create_secret(
                Name=secret_name,
                SecretString=json.dumps(secret_value)
            )
            print(f"Secret {secret_name} created successfully")
        except ClientError as e:
            print(f"Error creating secret {secret_name}: {e}")

# Usage
secrets = AWSSecretsManager()
db_config = secrets.get_secret('prod/database/credentials')
```

## Configuration Classes and Validation

### Pydantic Configuration

```python
# Install: pip install pydantic

from pydantic import BaseSettings, validator
from typing import Optional, List
import os

class DataPipelineConfig(BaseSettings):
    # Database settings
    database_url: str
    database_pool_size: int = 5
    
    # API settings
    api_key: str
    api_timeout: int = 30
    
    # Processing settings
    batch_size: int = 1000
    max_workers: int = 4
    
    # Security settings
    encryption_key: Optional[str] = None
    allowed_hosts: List[str] = ['localhost']
    
    # Environment
    environment: str = 'development'
    debug: bool = False
    log_level: str = 'INFO'
    
    @validator('database_url')
    def validate_database_url(cls, v):
        if not v.startswith(('postgresql://', 'mysql://', 'sqlite://')):
            raise ValueError('Invalid database URL format')
        return v
    
    @validator('environment')
    def validate_environment(cls, v):
        if v not in ['development', 'staging', 'production']:
            raise ValueError('Environment must be development, staging, or production')
        return v
    
    @validator('log_level')
    def validate_log_level(cls, v):
        if v not in ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL']:
            raise ValueError('Invalid log level')
        return v
    
    class Config:
        env_file = '.env'
        env_file_encoding = 'utf-8'

# Usage
config = DataPipelineConfig()
print(f"Environment: {config.environment}")
print(f"Database pool size: {config.database_pool_size}")
```

### Configuration Factory Pattern

```python
from abc import ABC, abstractmethod
import os

class ConfigBase(ABC):
    @abstractmethod
    def get_database_url(self) -> str:
        pass
    
    @abstractmethod
    def get_log_level(self) -> str:
        pass

class DevelopmentConfig(ConfigBase):
    def get_database_url(self) -> str:
        return "sqlite:///dev.db"
    
    def get_log_level(self) -> str:
        return "DEBUG"

class ProductionConfig(ConfigBase):
    def get_database_url(self) -> str:
        return os.getenv('DATABASE_URL')
    
    def get_log_level(self) -> str:
        return "INFO"

class ConfigFactory:
    @staticmethod
    def create_config() -> ConfigBase:
        env = os.getenv('ENVIRONMENT', 'development')
        
        if env == 'production':
            return ProductionConfig()
        else:
            return DevelopmentConfig()

# Usage
config = ConfigFactory.create_config()
database_url = config.get_database_url()
```

## Data Encryption and Security

### File Encryption

```python
from cryptography.fernet import Fernet
import os

class FileEncryption:
    def __init__(self, key: bytes = None):
        if key is None:
            key = os.getenv('ENCRYPTION_KEY', '').encode()
            if not key:
                key = Fernet.generate_key()
                print(f"Generated key: {key.decode()}")
        
        self.cipher = Fernet(key)
    
    def encrypt_file(self, input_path: str, output_path: str):
        with open(input_path, 'rb') as file:
            data = file.read()
        
        encrypted_data = self.cipher.encrypt(data)
        
        with open(output_path, 'wb') as file:
            file.write(encrypted_data)
    
    def decrypt_file(self, input_path: str, output_path: str):
        with open(input_path, 'rb') as file:
            encrypted_data = file.read()
        
        decrypted_data = self.cipher.decrypt(encrypted_data)
        
        with open(output_path, 'wb') as file:
            file.write(decrypted_data)

# Usage
encryptor = FileEncryption()
encryptor.encrypt_file('sensitive_data.csv', 'sensitive_data.csv.encrypted')
```

### Database Connection Security

```python
import sqlalchemy
from sqlalchemy import create_engine
from urllib.parse import quote_plus
import ssl

class SecureDatabaseConnection:
    def __init__(self, config):
        self.config = config
    
    def create_secure_engine(self):
        # URL encode password to handle special characters
        password = quote_plus(self.config.database_password)
        
        database_url = (
            f"postgresql://{self.config.database_user}:{password}"
            f"@{self.config.database_host}:{self.config.database_port}"
            f"/{self.config.database_name}"
        )
        
        # SSL configuration
        connect_args = {
            "sslmode": "require",
            "sslcert": self.config.ssl_cert_path,
            "sslkey": self.config.ssl_key_path,
            "sslrootcert": self.config.ssl_ca_path
        }
        
        engine = create_engine(
            database_url,
            connect_args=connect_args,
            pool_size=self.config.pool_size,
            max_overflow=self.config.max_overflow,
            pool_pre_ping=True,  # Verify connections
            echo=self.config.debug  # Log SQL in debug mode
        )
        
        return engine
```

## Access Control and Authentication

### API Key Management

```python
import hashlib
import secrets
import time
from typing import Dict, Optional

class APIKeyManager:
    def __init__(self):
        self.keys: Dict[str, dict] = {}
    
    def generate_api_key(self, user_id: str, permissions: list = None) -> str:
        # Generate secure random key
        key = secrets.token_urlsafe(32)
        
        # Hash for storage (never store plain keys)
        key_hash = hashlib.sha256(key.encode()).hexdigest()
        
        self.keys[key_hash] = {
            'user_id': user_id,
            'permissions': permissions or [],
            'created_at': time.time(),
            'last_used': None,
            'active': True
        }
        
        return key
    
    def validate_api_key(self, key: str) -> Optional[dict]:
        key_hash = hashlib.sha256(key.encode()).hexdigest()
        
        if key_hash in self.keys:
            key_info = self.keys[key_hash]
            if key_info['active']:
                key_info['last_used'] = time.time()
                return key_info
        
        return None
    
    def revoke_api_key(self, key: str):
        key_hash = hashlib.sha256(key.encode()).hexdigest()
        if key_hash in self.keys:
            self.keys[key_hash]['active'] = False

# Usage
api_manager = APIKeyManager()
key = api_manager.generate_api_key('user123', ['read', 'write'])
print(f"Generated API key: {key}")

# Validate key
key_info = api_manager.validate_api_key(key)
if key_info:
    print(f"Valid key for user: {key_info['user_id']}")
```

### Role-Based Access Control

```python
from enum import Enum
from typing import Set, Dict

class Permission(Enum):
    READ_DATA = "read_data"
    WRITE_DATA = "write_data"
    DELETE_DATA = "delete_data"
    ADMIN = "admin"

class Role:
    def __init__(self, name: str, permissions: Set[Permission]):
        self.name = name
        self.permissions = permissions

class User:
    def __init__(self, user_id: str, roles: Set[Role]):
        self.user_id = user_id
        self.roles = roles
    
    def has_permission(self, permission: Permission) -> bool:
        for role in self.roles:
            if permission in role.permissions:
                return True
        return False

class AccessControl:
    def __init__(self):
        # Define roles
        self.roles = {
            'viewer': Role('viewer', {Permission.READ_DATA}),
            'editor': Role('editor', {Permission.READ_DATA, Permission.WRITE_DATA}),
            'admin': Role('admin', {Permission.READ_DATA, Permission.WRITE_DATA, 
                                  Permission.DELETE_DATA, Permission.ADMIN})
        }
        
        self.users: Dict[str, User] = {}
    
    def create_user(self, user_id: str, role_names: list):
        roles = {self.roles[name] for name in role_names if name in self.roles}
        self.users[user_id] = User(user_id, roles)
    
    def check_permission(self, user_id: str, permission: Permission) -> bool:
        user = self.users.get(user_id)
        return user.has_permission(permission) if user else False

# Usage
access_control = AccessControl()
access_control.create_user('alice', ['editor'])
access_control.create_user('bob', ['viewer'])

# Check permissions
can_write = access_control.check_permission('alice', Permission.WRITE_DATA)
print(f"Alice can write data: {can_write}")
```

## Secure Logging and Auditing

### Secure Logging

```python
import logging
import json
import hashlib
from datetime import datetime
from typing import Any, Dict

class SecureLogger:
    def __init__(self, name: str):
        self.logger = logging.getLogger(name)
        self.setup_logging()
    
    def setup_logging(self):
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        handler.setFormatter(formatter)
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.INFO)
    
    def sanitize_data(self, data: Any) -> Any:
        """Remove or mask sensitive information"""
        if isinstance(data, dict):
            sanitized = {}
            for key, value in data.items():
                if any(sensitive in key.lower() for sensitive in 
                      ['password', 'key', 'token', 'secret', 'credential']):
                    sanitized[key] = '***REDACTED***'
                else:
                    sanitized[key] = self.sanitize_data(value)
            return sanitized
        elif isinstance(data, list):
            return [self.sanitize_data(item) for item in data]
        else:
            return data
    
    def log_event(self, event_type: str, message: str, **kwargs):
        """Log event with automatic sanitization"""
        sanitized_kwargs = self.sanitize_data(kwargs)
        
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'message': message,
            **sanitized_kwargs
        }
        
        self.logger.info(json.dumps(log_entry))
    
    def log_access(self, user_id: str, resource: str, action: str, success: bool):
        """Log access attempts for auditing"""
        self.log_event(
            'access_attempt',
            f"User {user_id} attempted {action} on {resource}",
            user_id=user_id,
            resource=resource,
            action=action,
            success=success
        )

# Usage
secure_logger = SecureLogger('data_pipeline')

# This will automatically redact the password
secure_logger.log_event('database_connection', 'Connecting to database', 
                       host='localhost', user='admin', password='secret123')
```

## Configuration Validation and Testing

### Configuration Testing

```python
import pytest
import os
from unittest.mock import patch

def test_config_validation():
    """Test configuration validation"""
    # Test valid configuration
    with patch.dict(os.environ, {
        'DATABASE_URL': 'postgresql://user:pass@localhost/db',
        'API_KEY': 'test-key',
        'ENVIRONMENT': 'development'
    }):
        config = DataPipelineConfig()
        assert config.environment == 'development'
        assert config.database_url.startswith('postgresql://')
    
    # Test invalid configuration
    with patch.dict(os.environ, {
        'DATABASE_URL': 'invalid-url',
        'ENVIRONMENT': 'invalid-env'
    }):
        with pytest.raises(ValueError):
            DataPipelineConfig()

def test_secret_encryption():
    """Test secret encryption/decryption"""
    secret_manager = SecretManager()
    
    original_secret = "my-secret-password"
    encrypted = secret_manager.encrypt_secret(original_secret)
    decrypted = secret_manager.decrypt_secret(encrypted)
    
    assert decrypted == original_secret
    assert encrypted != original_secret
```

## Security Best Practices

### Secure Development Checklist

```python
class SecurityChecker:
    def __init__(self):
        self.issues = []
    
    def check_hardcoded_secrets(self, code: str) -> list:
        """Check for hardcoded secrets in code"""
        issues = []
        
        # Common patterns for hardcoded secrets
        patterns = [
            'password=',
            'api_key=',
            'secret=',
            'token=',
            'key='
        ]
        
        lines = code.split('\n')
        for i, line in enumerate(lines, 1):
            for pattern in patterns:
                if pattern in line.lower() and '=' in line:
                    # Check if it's not using environment variables
                    if 'os.getenv' not in line and 'environ' not in line:
                        issues.append(f"Line {i}: Possible hardcoded secret")
        
        return issues
    
    def check_file_permissions(self, file_path: str) -> bool:
        """Check if file has secure permissions"""
        import stat
        
        file_stat = os.stat(file_path)
        mode = file_stat.st_mode
        
        # Check if file is readable by others
        if mode & stat.S_IROTH:
            return False
        
        # Check if file is writable by others
        if mode & stat.S_IWOTH:
            return False
        
        return True
    
    def validate_ssl_config(self, config: dict) -> list:
        """Validate SSL configuration"""
        issues = []
        
        if not config.get('ssl_enabled', False):
            issues.append("SSL is not enabled")
        
        if config.get('ssl_verify', True) is False:
            issues.append("SSL verification is disabled")
        
        return issues

# Usage
checker = SecurityChecker()

# Check code for hardcoded secrets
code_sample = """
database_url = "postgresql://user:password123@localhost/db"
api_key = os.getenv('API_KEY')
"""

issues = checker.check_hardcoded_secrets(code_sample)
for issue in issues:
    print(f"Security issue: {issue}")
```

### Production Security Configuration

```python
import os
from dataclasses import dataclass

@dataclass
class ProductionSecurityConfig:
    # SSL/TLS settings
    ssl_enabled: bool = True
    ssl_verify: bool = True
    ssl_cert_path: str = ""
    ssl_key_path: str = ""
    
    # Authentication
    require_auth: bool = True
    session_timeout: int = 3600  # 1 hour
    
    # Rate limiting
    rate_limit_enabled: bool = True
    max_requests_per_minute: int = 100
    
    # Logging
    log_sensitive_data: bool = False
    audit_enabled: bool = True
    
    # Data protection
    encrypt_at_rest: bool = True
    encrypt_in_transit: bool = True
    
    @classmethod
    def from_env(cls):
        return cls(
            ssl_enabled=os.getenv('SSL_ENABLED', 'true').lower() == 'true',
            ssl_verify=os.getenv('SSL_VERIFY', 'true').lower() == 'true',
            ssl_cert_path=os.getenv('SSL_CERT_PATH', ''),
            ssl_key_path=os.getenv('SSL_KEY_PATH', ''),
            require_auth=os.getenv('REQUIRE_AUTH', 'true').lower() == 'true',
            session_timeout=int(os.getenv('SESSION_TIMEOUT', '3600')),
            rate_limit_enabled=os.getenv('RATE_LIMIT_ENABLED', 'true').lower() == 'true',
            max_requests_per_minute=int(os.getenv('MAX_REQUESTS_PER_MINUTE', '100')),
            log_sensitive_data=os.getenv('LOG_SENSITIVE_DATA', 'false').lower() == 'true',
            audit_enabled=os.getenv('AUDIT_ENABLED', 'true').lower() == 'true',
            encrypt_at_rest=os.getenv('ENCRYPT_AT_REST', 'true').lower() == 'true',
            encrypt_in_transit=os.getenv('ENCRYPT_IN_TRANSIT', 'true').lower() == 'true'
        )

# Usage
security_config = ProductionSecurityConfig.from_env()
```

## Summary

Security and configuration management are fundamental for production data pipelines. Proper implementation protects sensitive data, ensures compliance, and maintains system integrity.

**Key takeaways**:
- Never hardcode secrets in source code
- Use environment variables and secure secret management
- Implement proper access controls and authentication
- Encrypt sensitive data at rest and in transit
- Use structured logging with automatic sanitization
- Validate configurations and test security measures
- Follow the principle of least privilege
- Implement comprehensive auditing and monitoring

**Next**: Day 29 will cover the final capstone project integrating all learned tools and concepts.
