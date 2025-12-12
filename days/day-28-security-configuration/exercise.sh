#!/bin/bash

# Day 28: Security and Configuration Management
# Hands-on exercises for mastering security and configuration

set -e

echo "🔐 Day 28: Security and Configuration Management Exercises"
echo "========================================================="

# Exercise 1: Environment Variables and .env Files
echo -e "\n🌍 Exercise 1: Environment Variables and .env Files"
echo "Learning secure configuration management..."

mkdir -p exercise1-env-config
cd exercise1-env-config

# Create sample .env files for different environments
cat > .env.development << 'EOF'
# Development Environment Configuration
DATABASE_URL=sqlite:///dev.db
API_KEY=dev-api-key-12345
DEBUG=true
LOG_LEVEL=DEBUG
MAX_WORKERS=2
ENCRYPTION_KEY=dev-encryption-key-not-secure
EOF

cat > .env.production << 'EOF'
# Production Environment Configuration
DATABASE_URL=postgresql://user:secure_password@prod-db:5432/app
API_KEY=prod-api-key-67890
DEBUG=false
LOG_LEVEL=INFO
MAX_WORKERS=8
ENCRYPTION_KEY=prod-encryption-key-very-secure
EOF

# Create configuration management script
cat > config_manager.py << 'EOF'
#!/usr/bin/env python3
"""
Configuration Management Example
Demonstrates secure configuration loading
"""

import os
from dataclasses import dataclass
from typing import Optional

@dataclass
class AppConfig:
    database_url: str
    api_key: str
    debug: bool
    log_level: str
    max_workers: int
    encryption_key: str
    
    @classmethod
    def from_env(cls, env_file: Optional[str] = None):
        """Load configuration from environment variables"""
        if env_file:
            # Simulate loading .env file
            print(f"Loading configuration from {env_file}")
            with open(env_file, 'r') as f:
                for line in f:
                    if line.strip() and not line.startswith('#'):
                        key, value = line.strip().split('=', 1)
                        os.environ[key] = value
        
        return cls(
            database_url=os.getenv('DATABASE_URL', ''),
            api_key=os.getenv('API_KEY', ''),
            debug=os.getenv('DEBUG', 'false').lower() == 'true',
            log_level=os.getenv('LOG_LEVEL', 'INFO'),
            max_workers=int(os.getenv('MAX_WORKERS', '1')),
            encryption_key=os.getenv('ENCRYPTION_KEY', '')
        )
    
    def validate(self):
        """Validate configuration"""
        errors = []
        
        if not self.database_url:
            errors.append("DATABASE_URL is required")
        
        if not self.api_key:
            errors.append("API_KEY is required")
        
        if self.log_level not in ['DEBUG', 'INFO', 'WARNING', 'ERROR']:
            errors.append("Invalid LOG_LEVEL")
        
        if self.max_workers < 1:
            errors.append("MAX_WORKERS must be at least 1")
        
        return errors
    
    def display_safe(self):
        """Display configuration with sensitive data masked"""
        print("Configuration:")
        print(f"  Database URL: {self.mask_sensitive(self.database_url)}")
        print(f"  API Key: {self.mask_sensitive(self.api_key)}")
        print(f"  Debug: {self.debug}")
        print(f"  Log Level: {self.log_level}")
        print(f"  Max Workers: {self.max_workers}")
        print(f"  Encryption Key: {self.mask_sensitive(self.encryption_key)}")
    
    @staticmethod
    def mask_sensitive(value: str) -> str:
        """Mask sensitive values for display"""
        if len(value) <= 8:
            return '*' * len(value)
        return value[:4] + '*' * (len(value) - 8) + value[-4:]

def main():
    print("=== Configuration Management Demo ===")
    
    # Test development configuration
    print("\n1. Development Configuration:")
    dev_config = AppConfig.from_env('.env.development')
    dev_config.display_safe()
    
    errors = dev_config.validate()
    if errors:
        print("Validation errors:", errors)
    else:
        print("✅ Configuration is valid")
    
    # Test production configuration
    print("\n2. Production Configuration:")
    prod_config = AppConfig.from_env('.env.production')
    prod_config.display_safe()
    
    errors = prod_config.validate()
    if errors:
        print("Validation errors:", errors)
    else:
        print("✅ Configuration is valid")

if __name__ == "__main__":
    main()
EOF

# Run configuration demo
python config_manager.py
echo "✅ Configuration management demo completed"

cd ..

# Exercise 2: Secret Encryption and Management
echo -e "\n🔒 Exercise 2: Secret Encryption and Management"
echo "Learning to encrypt and manage secrets..."

mkdir -p exercise2-secrets
cd exercise2-secrets

# Install cryptography if not available
pip install cryptography > /dev/null 2>&1 || echo "Note: cryptography package needed for encryption"

# Create secret management system
cat > secret_manager.py << 'EOF'
#!/usr/bin/env python3
"""
Secret Management System
Demonstrates encryption and secure secret handling
"""

import os
import json
import base64
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

class SecretManager:
    def __init__(self, password: str = None):
        if password:
            self.key = self._derive_key_from_password(password)
        else:
            self.key = self._get_or_generate_key()
        
        self.cipher = Fernet(self.key)
    
    def _derive_key_from_password(self, password: str) -> bytes:
        """Derive encryption key from password"""
        salt = b'stable_salt_for_demo'  # In production, use random salt
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        return key
    
    def _get_or_generate_key(self) -> bytes:
        """Get existing key or generate new one"""
        key_file = 'encryption.key'
        
        if os.path.exists(key_file):
            with open(key_file, 'rb') as f:
                return f.read()
        else:
            key = Fernet.generate_key()
            with open(key_file, 'wb') as f:
                f.write(key)
            print(f"Generated new encryption key: {key_file}")
            return key
    
    def encrypt_secret(self, secret: str) -> str:
        """Encrypt a secret string"""
        encrypted = self.cipher.encrypt(secret.encode())
        return base64.urlsafe_b64encode(encrypted).decode()
    
    def decrypt_secret(self, encrypted_secret: str) -> str:
        """Decrypt a secret string"""
        encrypted_bytes = base64.urlsafe_b64decode(encrypted_secret.encode())
        decrypted = self.cipher.decrypt(encrypted_bytes)
        return decrypted.decode()
    
    def encrypt_file(self, input_file: str, output_file: str):
        """Encrypt a file"""
        with open(input_file, 'rb') as f:
            data = f.read()
        
        encrypted_data = self.cipher.encrypt(data)
        
        with open(output_file, 'wb') as f:
            f.write(encrypted_data)
        
        print(f"File encrypted: {input_file} -> {output_file}")
    
    def decrypt_file(self, input_file: str, output_file: str):
        """Decrypt a file"""
        with open(input_file, 'rb') as f:
            encrypted_data = f.read()
        
        decrypted_data = self.cipher.decrypt(encrypted_data)
        
        with open(output_file, 'wb') as f:
            f.write(decrypted_data)
        
        print(f"File decrypted: {input_file} -> {output_file}")
    
    def create_secret_store(self, secrets: dict, store_file: str):
        """Create encrypted secret store"""
        encrypted_secrets = {}
        
        for key, value in secrets.items():
            encrypted_secrets[key] = self.encrypt_secret(str(value))
        
        with open(store_file, 'w') as f:
            json.dump(encrypted_secrets, f, indent=2)
        
        print(f"Secret store created: {store_file}")
    
    def load_secret_store(self, store_file: str) -> dict:
        """Load and decrypt secret store"""
        with open(store_file, 'r') as f:
            encrypted_secrets = json.load(f)
        
        decrypted_secrets = {}
        for key, encrypted_value in encrypted_secrets.items():
            decrypted_secrets[key] = self.decrypt_secret(encrypted_value)
        
        return decrypted_secrets

def main():
    print("=== Secret Management Demo ===")
    
    # Create secret manager
    secret_manager = SecretManager()
    
    # Test secret encryption
    print("\n1. Secret Encryption:")
    original_secret = "my-super-secret-password"
    encrypted = secret_manager.encrypt_secret(original_secret)
    decrypted = secret_manager.decrypt_secret(encrypted)
    
    print(f"Original: {original_secret}")
    print(f"Encrypted: {encrypted}")
    print(f"Decrypted: {decrypted}")
    print(f"Match: {original_secret == decrypted}")
    
    # Test secret store
    print("\n2. Secret Store:")
    secrets = {
        'database_password': 'super_secure_db_password',
        'api_key': 'sk-1234567890abcdef',
        'encryption_key': 'another-secret-key'
    }
    
    secret_manager.create_secret_store(secrets, 'secrets.json')
    loaded_secrets = secret_manager.load_secret_store('secrets.json')
    
    print("Loaded secrets:")
    for key, value in loaded_secrets.items():
        masked_value = value[:4] + '*' * (len(value) - 8) + value[-4:] if len(value) > 8 else '*' * len(value)
        print(f"  {key}: {masked_value}")
    
    # Test file encryption
    print("\n3. File Encryption:")
    
    # Create sample sensitive file
    with open('sensitive_data.txt', 'w') as f:
        f.write("This is sensitive data that should be encrypted.\n")
        f.write("Database password: secret123\n")
        f.write("API key: sk-abcdef123456\n")
    
    secret_manager.encrypt_file('sensitive_data.txt', 'sensitive_data.txt.encrypted')
    secret_manager.decrypt_file('sensitive_data.txt.encrypted', 'sensitive_data_decrypted.txt')
    
    print("✅ Secret management demo completed")

if __name__ == "__main__":
    main()
EOF

# Run secret management demo
python secret_manager.py
echo "✅ Secret management demo completed"

cd ..

# Exercise 3: Access Control and Authentication
echo -e "\n👤 Exercise 3: Access Control and Authentication"
echo "Learning access control patterns..."

mkdir -p exercise3-access-control
cd exercise3-access-control

# Create access control system
cat > access_control.py << 'EOF'
#!/usr/bin/env python3
"""
Access Control System
Demonstrates role-based access control and API key management
"""

import hashlib
import secrets
import time
import json
from enum import Enum
from typing import Dict, Set, Optional
from dataclasses import dataclass, asdict

class Permission(Enum):
    READ_DATA = "read_data"
    WRITE_DATA = "write_data"
    DELETE_DATA = "delete_data"
    ADMIN = "admin"

@dataclass
class Role:
    name: str
    permissions: Set[Permission]
    
    def to_dict(self):
        return {
            'name': self.name,
            'permissions': [p.value for p in self.permissions]
        }

@dataclass
class User:
    user_id: str
    username: str
    roles: Set[Role]
    created_at: float
    active: bool = True
    
    def has_permission(self, permission: Permission) -> bool:
        if not self.active:
            return False
        
        for role in self.roles:
            if permission in role.permissions:
                return True
        return False
    
    def to_dict(self):
        return {
            'user_id': self.user_id,
            'username': self.username,
            'roles': [role.to_dict() for role in self.roles],
            'created_at': self.created_at,
            'active': self.active
        }

@dataclass
class APIKey:
    key_hash: str
    user_id: str
    permissions: Set[Permission]
    created_at: float
    last_used: Optional[float] = None
    active: bool = True
    
    def to_dict(self):
        return {
            'key_hash': self.key_hash,
            'user_id': self.user_id,
            'permissions': [p.value for p in self.permissions],
            'created_at': self.created_at,
            'last_used': self.last_used,
            'active': self.active
        }

class AccessControlSystem:
    def __init__(self):
        # Define standard roles
        self.roles = {
            'viewer': Role('viewer', {Permission.READ_DATA}),
            'editor': Role('editor', {Permission.READ_DATA, Permission.WRITE_DATA}),
            'admin': Role('admin', {Permission.READ_DATA, Permission.WRITE_DATA, 
                                  Permission.DELETE_DATA, Permission.ADMIN})
        }
        
        self.users: Dict[str, User] = {}
        self.api_keys: Dict[str, APIKey] = {}
        self.access_log = []
    
    def create_user(self, username: str, role_names: list) -> str:
        """Create a new user with specified roles"""
        user_id = secrets.token_hex(8)
        roles = {self.roles[name] for name in role_names if name in self.roles}
        
        user = User(
            user_id=user_id,
            username=username,
            roles=roles,
            created_at=time.time()
        )
        
        self.users[user_id] = user
        self.log_access(user_id, 'user_creation', 'create_user', True)
        
        return user_id
    
    def generate_api_key(self, user_id: str) -> Optional[str]:
        """Generate API key for user"""
        if user_id not in self.users:
            return None
        
        user = self.users[user_id]
        if not user.active:
            return None
        
        # Generate secure API key
        key = secrets.token_urlsafe(32)
        key_hash = hashlib.sha256(key.encode()).hexdigest()
        
        # Get user permissions from roles
        permissions = set()
        for role in user.roles:
            permissions.update(role.permissions)
        
        api_key = APIKey(
            key_hash=key_hash,
            user_id=user_id,
            permissions=permissions,
            created_at=time.time()
        )
        
        self.api_keys[key_hash] = api_key
        self.log_access(user_id, 'api_key_generation', 'generate_api_key', True)
        
        return key
    
    def validate_api_key(self, key: str) -> Optional[APIKey]:
        """Validate API key and return key info"""
        key_hash = hashlib.sha256(key.encode()).hexdigest()
        
        if key_hash in self.api_keys:
            api_key = self.api_keys[key_hash]
            if api_key.active:
                api_key.last_used = time.time()
                return api_key
        
        return None
    
    def check_permission(self, key: str, permission: Permission) -> bool:
        """Check if API key has specific permission"""
        api_key = self.validate_api_key(key)
        
        if api_key and permission in api_key.permissions:
            self.log_access(api_key.user_id, 'permission_check', permission.value, True)
            return True
        else:
            self.log_access('unknown', 'permission_check', permission.value, False)
            return False
    
    def revoke_api_key(self, key: str) -> bool:
        """Revoke an API key"""
        key_hash = hashlib.sha256(key.encode()).hexdigest()
        
        if key_hash in self.api_keys:
            self.api_keys[key_hash].active = False
            self.log_access(self.api_keys[key_hash].user_id, 'api_key_revocation', 'revoke_api_key', True)
            return True
        
        return False
    
    def log_access(self, user_id: str, resource: str, action: str, success: bool):
        """Log access attempts for auditing"""
        log_entry = {
            'timestamp': time.time(),
            'user_id': user_id,
            'resource': resource,
            'action': action,
            'success': success
        }
        
        self.access_log.append(log_entry)
    
    def get_access_log(self, user_id: str = None) -> list:
        """Get access log, optionally filtered by user"""
        if user_id:
            return [entry for entry in self.access_log if entry['user_id'] == user_id]
        return self.access_log
    
    def export_config(self, filename: str):
        """Export system configuration"""
        config = {
            'users': {uid: user.to_dict() for uid, user in self.users.items()},
            'api_keys': {hash_key: api_key.to_dict() for hash_key, api_key in self.api_keys.items()},
            'access_log': self.access_log
        }
        
        with open(filename, 'w') as f:
            json.dump(config, f, indent=2, default=str)
        
        print(f"Configuration exported to {filename}")

def main():
    print("=== Access Control System Demo ===")
    
    # Create access control system
    ac = AccessControlSystem()
    
    # Create users
    print("\n1. Creating Users:")
    alice_id = ac.create_user('alice', ['editor'])
    bob_id = ac.create_user('bob', ['viewer'])
    admin_id = ac.create_user('admin', ['admin'])
    
    print(f"Created users:")
    print(f"  Alice (editor): {alice_id}")
    print(f"  Bob (viewer): {bob_id}")
    print(f"  Admin: {admin_id}")
    
    # Generate API keys
    print("\n2. Generating API Keys:")
    alice_key = ac.generate_api_key(alice_id)
    bob_key = ac.generate_api_key(bob_id)
    admin_key = ac.generate_api_key(admin_id)
    
    print(f"Generated API keys:")
    print(f"  Alice: {alice_key[:8]}...")
    print(f"  Bob: {bob_key[:8]}...")
    print(f"  Admin: {admin_key[:8]}...")
    
    # Test permissions
    print("\n3. Testing Permissions:")
    
    test_cases = [
        (alice_key, Permission.READ_DATA, "Alice reading data"),
        (alice_key, Permission.WRITE_DATA, "Alice writing data"),
        (alice_key, Permission.DELETE_DATA, "Alice deleting data"),
        (bob_key, Permission.READ_DATA, "Bob reading data"),
        (bob_key, Permission.WRITE_DATA, "Bob writing data"),
        (admin_key, Permission.ADMIN, "Admin performing admin action")
    ]
    
    for key, permission, description in test_cases:
        has_permission = ac.check_permission(key, permission)
        status = "✅ ALLOWED" if has_permission else "❌ DENIED"
        print(f"  {description}: {status}")
    
    # Show access log
    print("\n4. Access Log:")
    log_entries = ac.get_access_log()
    for entry in log_entries[-5:]:  # Show last 5 entries
        timestamp = time.strftime('%H:%M:%S', time.localtime(entry['timestamp']))
        status = "SUCCESS" if entry['success'] else "FAILED"
        print(f"  {timestamp} - {entry['user_id'][:8]} - {entry['action']} - {status}")
    
    # Export configuration
    ac.export_config('access_control_config.json')
    
    print("\n✅ Access control demo completed")

if __name__ == "__main__":
    main()
EOF

# Run access control demo
python access_control.py
echo "✅ Access control demo completed"

cd ..

echo "✅ Exercises 1-3 complete: Security and configuration fundamentals"
echo "Continue with remaining exercises..."
