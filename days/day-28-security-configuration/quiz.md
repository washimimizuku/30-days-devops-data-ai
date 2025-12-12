# Day 28 Quiz: Security and Configuration Management

Test your understanding of security best practices and configuration management.

## Questions

### 1. What is the main security risk of hardcoding credentials in source code?
a) Poor performance
b) Credentials exposed in version control
c) Difficult to maintain
d) Increased memory usage

### 2. Which Python library is commonly used for loading .env files?
a) `configparser`
b) `python-dotenv`
c) `os.environ`
d) `json`

### 3. What does the principle of "least privilege" mean in access control?
a) Users get maximum permissions by default
b) Users get only the minimum permissions needed
c) All users have the same permissions
d) Permissions are randomly assigned

### 4. Which encryption library is recommended for Python applications?
a) `hashlib`
b) `base64`
c) `cryptography`
d) `ssl`

### 5. What is the purpose of salting passwords?
a) Make passwords taste better
b) Prevent rainbow table attacks
c) Increase password length
d) Improve performance

### 6. Which environment variable approach is most secure?
a) Store in .env files committed to git
b) Hardcode in application
c) Use system environment variables or secret managers
d) Store in plain text files

### 7. What is a JWT token primarily used for?
a) Database encryption
b) File compression
c) Authentication and authorization
d) Network routing

### 8. Which file permission is most secure for configuration files?
a) 777 (readable/writable by everyone)
b) 644 (readable by everyone)
c) 600 (readable/writable by owner only)
d) 755 (executable by everyone)

### 9. What should you do with API keys in logs?
a) Log them for debugging
b) Encrypt them in logs
c) Redact or mask them
d) Store them separately

### 10. Which is the best practice for managing secrets in production?
a) Environment variables only
b) Dedicated secret management services (AWS Secrets Manager, HashiCorp Vault)
c) Configuration files
d) Database storage

## Answers

### 1. b) Credentials exposed in version control
**Explanation**: Hardcoded credentials in source code get committed to version control systems, making them visible to anyone with repository access and creating a permanent security risk.

### 2. b) `python-dotenv`
**Explanation**: The `python-dotenv` library is specifically designed to load environment variables from .env files, making configuration management easier and more secure.

### 3. b) Users get only the minimum permissions needed
**Explanation**: The principle of least privilege means granting users only the minimum access rights needed to perform their job functions, reducing security risks.

### 4. c) `cryptography`
**Explanation**: The `cryptography` library is the recommended choice for encryption in Python, providing secure, well-tested cryptographic primitives and high-level recipes.

### 5. b) Prevent rainbow table attacks
**Explanation**: Salt adds random data to passwords before hashing, making rainbow table attacks (precomputed hash lookups) ineffective against password databases.

### 6. c) Use system environment variables or secret managers
**Explanation**: System environment variables or dedicated secret management services provide secure ways to handle credentials without exposing them in code or version control.

### 7. c) Authentication and authorization
**Explanation**: JWT (JSON Web Tokens) are primarily used for securely transmitting authentication and authorization information between parties.

### 8. c) 600 (readable/writable by owner only)
**Explanation**: Permission 600 restricts file access to the owner only, preventing other users on the system from reading sensitive configuration data.

### 9. c) Redact or mask them
**Explanation**: API keys and other sensitive data should be redacted or masked in logs to prevent accidental exposure while maintaining log usefulness for debugging.

### 10. b) Dedicated secret management services
**Explanation**: Services like AWS Secrets Manager, HashiCorp Vault, or Azure Key Vault provide enterprise-grade secret management with features like rotation, auditing, and fine-grained access control.

## Scoring

- **8-10 correct**: Excellent! You have a strong understanding of security and configuration management.
- **6-7 correct**: Good job! Review the areas you missed, particularly around encryption and secret management.
- **4-5 correct**: You're making progress. Focus on understanding security principles and best practices.
- **0-3 correct**: Review the lesson material and study security fundamentals for data applications.

## Key Takeaways

1. **Never hardcode secrets** in source code or configuration files
2. **Environment variables** provide a secure way to manage configuration
3. **Encryption** protects sensitive data at rest and in transit
4. **Access control** should follow the principle of least privilege
5. **Secret management services** are preferred for production environments
6. **File permissions** should restrict access to sensitive configuration
7. **Logging** should never expose sensitive information
8. **Token-based authentication** provides secure, stateless authorization
9. **Configuration validation** prevents security misconfigurations
10. **Security auditing** helps detect and respond to threats

## Security Best Practices Checklist

### Configuration Management
- [ ] Use environment variables for configuration
- [ ] Separate configuration by environment (dev/staging/prod)
- [ ] Validate configuration on startup
- [ ] Use secure file permissions (600/640)
- [ ] Never commit secrets to version control

### Secret Management
- [ ] Use dedicated secret management services
- [ ] Rotate secrets regularly
- [ ] Encrypt secrets at rest
- [ ] Audit secret access
- [ ] Use strong, unique secrets

### Access Control
- [ ] Implement role-based access control (RBAC)
- [ ] Follow principle of least privilege
- [ ] Use strong authentication (MFA when possible)
- [ ] Implement session management
- [ ] Log all access attempts

### Data Protection
- [ ] Encrypt sensitive data at rest
- [ ] Use TLS/SSL for data in transit
- [ ] Implement proper key management
- [ ] Sanitize logs and error messages
- [ ] Validate all inputs

### Monitoring and Auditing
- [ ] Log security events
- [ ] Monitor for anomalies
- [ ] Implement alerting for security incidents
- [ ] Regular security assessments
- [ ] Incident response procedures
