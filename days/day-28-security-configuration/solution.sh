#!/bin/bash

# Day 28: Security and Configuration Management Solutions
# Advanced patterns and production-ready implementations

set -e

echo "🔐 Day 28: Security and Configuration Management Solutions"
echo "========================================================="

# Solution 1: Enterprise Configuration Management
echo -e "\n🏢 Solution 1: Enterprise Configuration Management"

mkdir -p solution1-enterprise-config
cd solution1-enterprise-config

# Create comprehensive configuration system
cat > enterprise_config.py << 'EOF'
#!/usr/bin/env python3
"""
Enterprise Configuration Management System
Production-ready configuration with validation, encryption, and multi-environment support
"""

import os
import json
import yaml
from typing import Dict, Any, Optional, List
from dataclasses import dataclass, field
from pathlib import Path
import logging
from cryptography.fernet import Fernet
import hashlib

@dataclass
class ConfigValidationRule:
    field_name: str
    required: bool = True
    data_type: type = str
    allowed_values: Optional[List[Any]] = None
    min_length: Optional[int] = None
    max_length: Optional[int] = None
    pattern: Optional[str] = None

class ConfigurationManager:
    def __init__(self, config_dir: str = "config"):
        self.config_dir = Path(config_dir)
        self.config_dir.mkdir(exist_ok=True)
        self.logger = self._setup_logging()
        self.encryption_key = self._get_encryption_key()
        self.cipher = Fernet(self.encryption_key) if self.encryption_key else None
        
        # Define validation rules
        self.validation_rules = [
            ConfigValidationRule("database_url", required=True, min_length=10),
            ConfigValidationRule("api_key", required=True, min_length=8),
            ConfigValidationRule("environment", required=True, 
                               allowed_values=["development", "staging", "production"]),
            ConfigValidationRule("debug", required=False, data_type=bool),
            ConfigValidationRule("log_level", required=False, 
                               allowed_values=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]),
            ConfigValidationRule("max_workers", required=False, data_type=int),
        ]
    
    def _setup_logging(self) -> logging.Logger:
        logger = logging.getLogger(__name__)
        logger.setLevel(logging.INFO)
        
        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)
        
        return logger
    
    def _get_encryption_key(self) -> Optional[bytes]:
        key_file = self.config_dir / "encryption.key"
        
        if key_file.exists():
            return key_file.read_bytes()
        
        # Generate new key if none exists
        key = Fernet.generate_key()
        key_file.write_bytes(key)
        key_file.chmod(0o600)  # Restrict permissions
        
        self.logger.info(f"Generated new encryption key: {key_file}")
        return key
    
    def load_config(self, environment: str) -> Dict[str, Any]:
        """Load configuration for specific environment"""
        config_file = self.config_dir / f"{environment}.yaml"
        
        if not config_file.exists():
            raise FileNotFoundError(f"Configuration file not found: {config_file}")
        
        with open(config_file, 'r') as f:
            config = yaml.safe_load(f)
        
        # Decrypt sensitive values
        config = self._decrypt_config(config)
        
        # Validate configuration
        self._validate_config(config)
        
        self.logger.info(f"Loaded configuration for environment: {environment}")
        return config
    
    def save_config(self, environment: str, config: Dict[str, Any]):
        """Save configuration for specific environment"""
        # Encrypt sensitive values
        encrypted_config = self._encrypt_config(config.copy())
        
        config_file = self.config_dir / f"{environment}.yaml"
        
        with open(config_file, 'w') as f:
            yaml.dump(encrypted_config, f, default_flow_style=False)
        
        # Set secure permissions
        config_file.chmod(0o600)
        
        self.logger.info(f"Saved configuration for environment: {environment}")
    
    def _encrypt_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Encrypt sensitive configuration values"""
        if not self.cipher:
            return config
        
        sensitive_keys = ['password', 'key', 'secret', 'token', 'credential']
        
        for key, value in config.items():
            if isinstance(value, str) and any(sensitive in key.lower() for sensitive in sensitive_keys):
                if not value.startswith('encrypted:'):
                    encrypted_value = self.cipher.encrypt(value.encode()).decode()
                    config[key] = f"encrypted:{encrypted_value}"
        
        return config
    
    def _decrypt_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Decrypt sensitive configuration values"""
        if not self.cipher:
            return config
        
        for key, value in config.items():
            if isinstance(value, str) and value.startswith('encrypted:'):
                encrypted_value = value[10:]  # Remove 'encrypted:' prefix
                try:
                    decrypted_value = self.cipher.decrypt(encrypted_value.encode()).decode()
                    config[key] = decrypted_value
                except Exception as e:
                    self.logger.error(f"Failed to decrypt {key}: {e}")
        
        return config
    
    def _validate_config(self, config: Dict[str, Any]):
        """Validate configuration against rules"""
        errors = []
        
        for rule in self.validation_rules:
            value = config.get(rule.field_name)
            
            # Check required fields
            if rule.required and value is None:
                errors.append(f"Required field missing: {rule.field_name}")
                continue
            
            if value is None:
                continue
            
            # Check data type
            if not isinstance(value, rule.data_type):
                errors.append(f"Invalid type for {rule.field_name}: expected {rule.data_type.__name__}")
                continue
            
            # Check allowed values
            if rule.allowed_values and value not in rule.allowed_values:
                errors.append(f"Invalid value for {rule.field_name}: must be one of {rule.allowed_values}")
            
            # Check string length
            if isinstance(value, str):
                if rule.min_length and len(value) < rule.min_length:
                    errors.append(f"{rule.field_name} too short: minimum {rule.min_length} characters")
                if rule.max_length and len(value) > rule.max_length:
                    errors.append(f"{rule.field_name} too long: maximum {rule.max_length} characters")
        
        if errors:
            raise ValueError(f"Configuration validation failed: {'; '.join(errors)}")
    
    def create_template(self, environment: str):
        """Create configuration template"""
        template = {
            'database_url': 'postgresql://user:password@localhost:5432/dbname',
            'api_key': 'your-api-key-here',
            'environment': environment,
            'debug': environment == 'development',
            'log_level': 'DEBUG' if environment == 'development' else 'INFO',
            'max_workers': 2 if environment == 'development' else 8,
            'features': {
                'enable_caching': True,
                'enable_monitoring': environment == 'production',
                'enable_debug_toolbar': environment == 'development'
            }
        }
        
        self.save_config(environment, template)
        self.logger.info(f"Created configuration template: {environment}")
    
    def compare_configs(self, env1: str, env2: str) -> Dict[str, Any]:
        """Compare configurations between environments"""
        config1 = self.load_config(env1)
        config2 = self.load_config(env2)
        
        differences = {}
        all_keys = set(config1.keys()) | set(config2.keys())
        
        for key in all_keys:
            val1 = config1.get(key)
            val2 = config2.get(key)
            
            if val1 != val2:
                differences[key] = {
                    env1: val1,
                    env2: val2
                }
        
        return differences

def main():
    print("=== Enterprise Configuration Management ===")
    
    config_manager = ConfigurationManager()
    
    # Create templates for different environments
    print("\n1. Creating configuration templates...")
    for env in ['development', 'staging', 'production']:
        config_manager.create_template(env)
    
    # Load and display configurations
    print("\n2. Loading configurations...")
    for env in ['development', 'production']:
        try:
            config = config_manager.load_config(env)
            print(f"\n{env.upper()} Configuration:")
            for key, value in config.items():
                if 'password' in key.lower() or 'key' in key.lower():
                    print(f"  {key}: ***REDACTED***")
                else:
                    print(f"  {key}: {value}")
        except Exception as e:
            print(f"Error loading {env} config: {e}")
    
    # Compare configurations
    print("\n3. Comparing configurations...")
    try:
        differences = config_manager.compare_configs('development', 'production')
        if differences:
            print("Configuration differences:")
            for key, values in differences.items():
                print(f"  {key}:")
                for env, value in values.items():
                    display_value = "***REDACTED***" if any(sensitive in key.lower() 
                                                          for sensitive in ['password', 'key']) else value
                    print(f"    {env}: {display_value}")
        else:
            print("No differences found")
    except Exception as e:
        print(f"Error comparing configs: {e}")
    
    print("\n✅ Enterprise configuration management demo completed")

if __name__ == "__main__":
    main()
EOF

# Install required packages
pip install pyyaml cryptography > /dev/null 2>&1 || echo "Note: Install pyyaml and cryptography for full functionality"

chmod +x enterprise_config.py
python enterprise_config.py > enterprise_output.txt 2>&1
echo "✅ Enterprise configuration system created"

cd ..

# Solution 2: Advanced Security Framework
echo -e "\n🛡️ Solution 2: Advanced Security Framework"

mkdir -p solution2-security-framework
cd solution2-security-framework

# Create comprehensive security framework
cat > security_framework.py << 'EOF'
#!/usr/bin/env python3
"""
Advanced Security Framework
Comprehensive security implementation for data pipelines
"""

import os
import json
import time
import hashlib
import secrets
import logging
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64

@dataclass
class SecurityEvent:
    timestamp: float
    event_type: str
    user_id: str
    resource: str
    action: str
    success: bool
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None
    additional_data: Optional[Dict] = None

class SecurityAuditor:
    def __init__(self, log_file: str = "security_audit.log"):
        self.log_file = log_file
        self.events: List[SecurityEvent] = []
        self.logger = self._setup_logging()
    
    def _setup_logging(self) -> logging.Logger:
        logger = logging.getLogger('security_auditor')
        logger.setLevel(logging.INFO)
        
        # File handler for security events
        file_handler = logging.FileHandler(self.log_file)
        file_formatter = logging.Formatter(
            '%(asctime)s - SECURITY - %(levelname)s - %(message)s'
        )
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)
        
        return logger
    
    def log_event(self, event: SecurityEvent):
        """Log security event"""
        self.events.append(event)
        
        # Log to file
        event_data = asdict(event)
        self.logger.info(json.dumps(event_data))
    
    def detect_anomalies(self, user_id: str, time_window: int = 3600) -> List[str]:
        """Detect security anomalies for a user"""
        anomalies = []
        current_time = time.time()
        
        # Get recent events for user
        recent_events = [
            event for event in self.events
            if event.user_id == user_id and 
               current_time - event.timestamp <= time_window
        ]
        
        if not recent_events:
            return anomalies
        
        # Check for excessive failed attempts
        failed_attempts = [e for e in recent_events if not e.success]
        if len(failed_attempts) > 5:
            anomalies.append(f"Excessive failed attempts: {len(failed_attempts)}")
        
        # Check for unusual access patterns
        unique_resources = set(e.resource for e in recent_events)
        if len(unique_resources) > 10:
            anomalies.append(f"Accessing many resources: {len(unique_resources)}")
        
        # Check for rapid successive attempts
        timestamps = [e.timestamp for e in recent_events]
        if len(timestamps) > 1:
            intervals = [timestamps[i] - timestamps[i-1] for i in range(1, len(timestamps))]
            avg_interval = sum(intervals) / len(intervals)
            if avg_interval < 1:  # Less than 1 second between requests
                anomalies.append(f"Rapid successive attempts: {avg_interval:.2f}s average")
        
        return anomalies
    
    def generate_security_report(self, days: int = 7) -> Dict[str, Any]:
        """Generate security report"""
        cutoff_time = time.time() - (days * 24 * 3600)
        recent_events = [e for e in self.events if e.timestamp >= cutoff_time]
        
        if not recent_events:
            return {"message": "No events in specified time period"}
        
        # Calculate statistics
        total_events = len(recent_events)
        failed_events = len([e for e in recent_events if not e.success])
        success_rate = ((total_events - failed_events) / total_events) * 100
        
        # Group by event type
        event_types = {}
        for event in recent_events:
            event_types[event.event_type] = event_types.get(event.event_type, 0) + 1
        
        # Group by user
        user_activity = {}
        for event in recent_events:
            if event.user_id not in user_activity:
                user_activity[event.user_id] = {'total': 0, 'failed': 0}
            user_activity[event.user_id]['total'] += 1
            if not event.success:
                user_activity[event.user_id]['failed'] += 1
        
        return {
            'period_days': days,
            'total_events': total_events,
            'failed_events': failed_events,
            'success_rate': round(success_rate, 2),
            'event_types': event_types,
            'user_activity': user_activity,
            'top_users': sorted(user_activity.items(), 
                              key=lambda x: x[1]['total'], reverse=True)[:5]
        }

class SecureTokenManager:
    def __init__(self, secret_key: str = None):
        if secret_key:
            self.key = self._derive_key(secret_key)
        else:
            self.key = Fernet.generate_key()
        
        self.cipher = Fernet(self.key)
        self.tokens: Dict[str, Dict] = {}
    
    def _derive_key(self, secret: str) -> bytes:
        """Derive encryption key from secret"""
        salt = b'secure_token_salt'
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        return base64.urlsafe_b64encode(kdf.derive(secret.encode()))
    
    def create_token(self, user_id: str, permissions: List[str], 
                    expires_in: int = 3600) -> str:
        """Create secure token"""
        token_id = secrets.token_hex(16)
        expires_at = time.time() + expires_in
        
        token_data = {
            'token_id': token_id,
            'user_id': user_id,
            'permissions': permissions,
            'created_at': time.time(),
            'expires_at': expires_at
        }
        
        # Encrypt token data
        encrypted_data = self.cipher.encrypt(json.dumps(token_data).encode())
        token = base64.urlsafe_b64encode(encrypted_data).decode()
        
        # Store token info (for revocation)
        self.tokens[token_id] = {
            'user_id': user_id,
            'created_at': token_data['created_at'],
            'expires_at': expires_at,
            'active': True
        }
        
        return token
    
    def validate_token(self, token: str) -> Optional[Dict]:
        """Validate and decode token"""
        try:
            # Decrypt token
            encrypted_data = base64.urlsafe_b64decode(token.encode())
            decrypted_data = self.cipher.decrypt(encrypted_data)
            token_data = json.loads(decrypted_data.decode())
            
            # Check expiration
            if time.time() > token_data['expires_at']:
                return None
            
            # Check if token is revoked
            token_info = self.tokens.get(token_data['token_id'])
            if not token_info or not token_info['active']:
                return None
            
            return token_data
            
        except Exception:
            return None
    
    def revoke_token(self, token: str) -> bool:
        """Revoke a token"""
        token_data = self.validate_token(token)
        if token_data:
            token_id = token_data['token_id']
            if token_id in self.tokens:
                self.tokens[token_id]['active'] = False
                return True
        return False
    
    def cleanup_expired_tokens(self):
        """Remove expired tokens"""
        current_time = time.time()
        expired_tokens = [
            token_id for token_id, info in self.tokens.items()
            if current_time > info['expires_at']
        ]
        
        for token_id in expired_tokens:
            del self.tokens[token_id]
        
        return len(expired_tokens)

class DataEncryption:
    def __init__(self, key: bytes = None):
        self.key = key or Fernet.generate_key()
        self.cipher = Fernet(self.key)
    
    def encrypt_data(self, data: Any) -> str:
        """Encrypt any data type"""
        json_data = json.dumps(data, default=str)
        encrypted = self.cipher.encrypt(json_data.encode())
        return base64.urlsafe_b64encode(encrypted).decode()
    
    def decrypt_data(self, encrypted_data: str) -> Any:
        """Decrypt data"""
        encrypted_bytes = base64.urlsafe_b64decode(encrypted_data.encode())
        decrypted = self.cipher.decrypt(encrypted_bytes)
        return json.loads(decrypted.decode())
    
    def encrypt_file(self, input_path: str, output_path: str):
        """Encrypt file"""
        with open(input_path, 'rb') as f:
            data = f.read()
        
        encrypted_data = self.cipher.encrypt(data)
        
        with open(output_path, 'wb') as f:
            f.write(encrypted_data)
    
    def decrypt_file(self, input_path: str, output_path: str):
        """Decrypt file"""
        with open(input_path, 'rb') as f:
            encrypted_data = f.read()
        
        decrypted_data = self.cipher.decrypt(encrypted_data)
        
        with open(output_path, 'wb') as f:
            f.write(decrypted_data)

class SecurityFramework:
    def __init__(self):
        self.auditor = SecurityAuditor()
        self.token_manager = SecureTokenManager()
        self.encryption = DataEncryption()
    
    def authenticate_user(self, user_id: str, credentials: Dict) -> Optional[str]:
        """Authenticate user and return token"""
        # Simulate authentication (in real implementation, verify against database)
        if self._verify_credentials(user_id, credentials):
            permissions = self._get_user_permissions(user_id)
            token = self.token_manager.create_token(user_id, permissions)
            
            # Log successful authentication
            self.auditor.log_event(SecurityEvent(
                timestamp=time.time(),
                event_type='authentication',
                user_id=user_id,
                resource='auth_system',
                action='login',
                success=True
            ))
            
            return token
        else:
            # Log failed authentication
            self.auditor.log_event(SecurityEvent(
                timestamp=time.time(),
                event_type='authentication',
                user_id=user_id,
                resource='auth_system',
                action='login',
                success=False
            ))
            
            return None
    
    def _verify_credentials(self, user_id: str, credentials: Dict) -> bool:
        """Verify user credentials (mock implementation)"""
        # In real implementation, verify against secure storage
        mock_users = {
            'alice': {'password_hash': hashlib.sha256('password123'.encode()).hexdigest()},
            'bob': {'password_hash': hashlib.sha256('secret456'.encode()).hexdigest()}
        }
        
        user_data = mock_users.get(user_id)
        if not user_data:
            return False
        
        provided_hash = hashlib.sha256(credentials.get('password', '').encode()).hexdigest()
        return provided_hash == user_data['password_hash']
    
    def _get_user_permissions(self, user_id: str) -> List[str]:
        """Get user permissions (mock implementation)"""
        mock_permissions = {
            'alice': ['read_data', 'write_data'],
            'bob': ['read_data']
        }
        return mock_permissions.get(user_id, [])
    
    def authorize_action(self, token: str, resource: str, action: str) -> bool:
        """Authorize user action"""
        token_data = self.token_manager.validate_token(token)
        
        if not token_data:
            self.auditor.log_event(SecurityEvent(
                timestamp=time.time(),
                event_type='authorization',
                user_id='unknown',
                resource=resource,
                action=action,
                success=False
            ))
            return False
        
        # Check permissions
        required_permission = f"{action}_{resource}"
        has_permission = required_permission in token_data['permissions']
        
        self.auditor.log_event(SecurityEvent(
            timestamp=time.time(),
            event_type='authorization',
            user_id=token_data['user_id'],
            resource=resource,
            action=action,
            success=has_permission
        ))
        
        return has_permission

def main():
    print("=== Advanced Security Framework Demo ===")
    
    security = SecurityFramework()
    
    # Test authentication
    print("\n1. Authentication Test:")
    alice_token = security.authenticate_user('alice', {'password': 'password123'})
    bob_token = security.authenticate_user('bob', {'password': 'secret456'})
    failed_token = security.authenticate_user('alice', {'password': 'wrong'})
    
    print(f"Alice token: {'✅ Success' if alice_token else '❌ Failed'}")
    print(f"Bob token: {'✅ Success' if bob_token else '❌ Failed'}")
    print(f"Wrong password: {'✅ Success' if failed_token else '❌ Failed'}")
    
    # Test authorization
    print("\n2. Authorization Test:")
    if alice_token:
        can_read = security.authorize_action(alice_token, 'data', 'read')
        can_write = security.authorize_action(alice_token, 'data', 'write')
        can_delete = security.authorize_action(alice_token, 'data', 'delete')
        
        print(f"Alice can read: {'✅ Yes' if can_read else '❌ No'}")
        print(f"Alice can write: {'✅ Yes' if can_write else '❌ No'}")
        print(f"Alice can delete: {'✅ Yes' if can_delete else '❌ No'}")
    
    # Test data encryption
    print("\n3. Data Encryption Test:")
    sensitive_data = {
        'user_id': 'alice',
        'credit_card': '1234-5678-9012-3456',
        'ssn': '123-45-6789'
    }
    
    encrypted = security.encryption.encrypt_data(sensitive_data)
    decrypted = security.encryption.decrypt_data(encrypted)
    
    print(f"Original data: {sensitive_data}")
    print(f"Encrypted: {encrypted[:50]}...")
    print(f"Decrypted matches: {'✅ Yes' if decrypted == sensitive_data else '❌ No'}")
    
    # Generate security report
    print("\n4. Security Report:")
    report = security.auditor.generate_security_report(days=1)
    print(f"Total events: {report.get('total_events', 0)}")
    print(f"Success rate: {report.get('success_rate', 0)}%")
    
    if 'event_types' in report:
        print("Event types:")
        for event_type, count in report['event_types'].items():
            print(f"  {event_type}: {count}")
    
    print("\n✅ Security framework demo completed")

if __name__ == "__main__":
    main()
EOF

chmod +x security_framework.py
python security_framework.py > security_output.txt 2>&1
echo "✅ Advanced security framework created"

cd ..

echo -e "\n🎉 All Day 28 solutions completed!"
echo ""
echo "Solutions demonstrated:"
echo "1. Enterprise configuration management with encryption and validation"
echo "2. Advanced security framework with authentication, authorization, and auditing"
echo ""
echo "Key patterns covered:"
echo "- Multi-environment configuration management"
echo "- Secure secret encryption and storage"
echo "- Token-based authentication and authorization"
echo "- Security event logging and anomaly detection"
echo "- Data encryption for sensitive information"
