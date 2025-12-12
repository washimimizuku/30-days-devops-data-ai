# Day 25: API Testing - curl and httpie

**Duration**: 1 hour  
**Prerequisites**: Basic HTTP concepts, command line usage  
**Learning Goal**: Master API testing tools for data pipeline integration and debugging

## Overview

API testing is crucial for data pipelines that integrate with external services, microservices, and web APIs. You'll learn curl fundamentals and modern httpie workflows for testing REST APIs, handling authentication, and debugging data integrations.

## Why API Testing Matters

**Common data pipeline scenarios**:
- Testing data ingestion APIs
- Validating ML model endpoints
- Debugging webhook integrations
- Monitoring API health and performance
- Authenticating with cloud services
- Testing batch processing triggers

**Benefits of command-line API testing**:
- Fast debugging and exploration
- Scriptable and automatable
- Works in any environment
- No GUI dependencies
- Easy CI/CD integration

## Core Concepts

### HTTP Methods for Data APIs

| Method | Purpose | Data Pipeline Use |
|--------|---------|-------------------|
| **GET** | Retrieve data | Fetch datasets, check status |
| **POST** | Create/submit | Upload data, trigger jobs |
| **PUT** | Update/replace | Update configurations |
| **PATCH** | Partial update | Modify pipeline settings |
| **DELETE** | Remove | Clean up resources |

### Response Status Codes

```bash
# Success
200 OK          # Data retrieved successfully
201 Created     # Resource created (job started)
202 Accepted    # Request accepted (async processing)

# Client Errors
400 Bad Request # Invalid data format
401 Unauthorized # Missing/invalid auth
404 Not Found   # Endpoint doesn't exist
429 Too Many Requests # Rate limited

# Server Errors
500 Internal Server Error # API failure
502 Bad Gateway # Service unavailable
503 Service Unavailable # Temporary outage
```

## Tool Comparison

### curl vs httpie

| Feature | curl | httpie |
|---------|------|--------|
| **Syntax** | Complex flags | Human-friendly |
| **JSON** | Manual formatting | Automatic |
| **Output** | Raw | Pretty-printed |
| **Learning curve** | Steep | Gentle |
| **Scripting** | Excellent | Good |
| **Availability** | Universal | Needs installation |

## curl Fundamentals

### Basic Requests

```bash
# GET request
curl https://api.github.com/users/octocat

# POST with data
curl -X POST https://httpbin.org/post \
  -H "Content-Type: application/json" \
  -d '{"name": "test", "value": 123}'

# Save response to file
curl -o response.json https://api.github.com/users/octocat

# Follow redirects
curl -L https://bit.ly/shortened-url

# Show headers
curl -I https://httpbin.org/get
```

### Authentication

```bash
# Basic auth
curl -u username:password https://api.example.com/data

# Bearer token
curl -H "Authorization: Bearer YOUR_TOKEN" \
  https://api.example.com/protected

# API key in header
curl -H "X-API-Key: YOUR_KEY" \
  https://api.example.com/data

# API key in query
curl "https://api.example.com/data?api_key=YOUR_KEY"
```

### Data Upload

```bash
# Upload JSON file
curl -X POST https://api.example.com/upload \
  -H "Content-Type: application/json" \
  -d @data.json

# Upload CSV file
curl -X POST https://api.example.com/csv \
  -H "Content-Type: text/csv" \
  --data-binary @dataset.csv

# Multipart form upload
curl -X POST https://api.example.com/files \
  -F "file=@dataset.csv" \
  -F "description=Training data"
```

### Advanced curl Options

```bash
# Timeout settings
curl --connect-timeout 10 --max-time 30 \
  https://slow-api.example.com

# Retry on failure
curl --retry 3 --retry-delay 5 \
  https://unreliable-api.example.com

# Custom user agent
curl -A "DataPipeline/1.0" \
  https://api.example.com

# Verbose output for debugging
curl -v https://api.example.com/debug

# Silent mode (no progress)
curl -s https://api.example.com/data | jq '.'
```

## httpie - Modern HTTP Client

### Installation and Basic Usage

```bash
# Install httpie
pip install httpie

# Basic GET
http GET https://api.github.com/users/octocat

# POST with JSON (automatic)
http POST https://httpbin.org/post name=test value:=123

# Custom headers
http GET https://api.example.com \
  Authorization:"Bearer TOKEN" \
  User-Agent:"DataPipeline/1.0"
```

### JSON Handling

```bash
# Automatic JSON formatting
http POST https://httpbin.org/post \
  name=john \
  age:=30 \
  active:=true \
  tags:='["python", "data"]'

# Upload JSON file
http POST https://api.example.com/data < data.json

# Pretty print response
http --print=HhBb GET https://api.example.com/data
```

### Authentication

```bash
# Basic auth
http -a username:password GET https://api.example.com

# Bearer token
http GET https://api.example.com \
  Authorization:"Bearer YOUR_TOKEN"

# Custom auth header
http GET https://api.example.com \
  X-API-Key:YOUR_KEY
```

### File Operations

```bash
# Download file
http --download GET https://api.example.com/dataset.csv

# Upload file
http --form POST https://api.example.com/upload \
  file@dataset.csv \
  description="Training data"

# Stream large responses
http --stream GET https://api.example.com/large-dataset
```

## Data Pipeline API Testing

### Testing ML Model APIs

```bash
# Test model prediction endpoint
curl -X POST https://ml-api.example.com/predict \
  -H "Content-Type: application/json" \
  -d '{
    "features": [1.2, 3.4, 5.6, 7.8],
    "model_version": "v1.0"
  }'

# Batch prediction
http POST https://ml-api.example.com/batch-predict \
  instances:='[
    {"features": [1,2,3,4]},
    {"features": [5,6,7,8]}
  ]'

# Model health check
curl -f https://ml-api.example.com/health || echo "Model down"
```

### Data Ingestion APIs

```bash
# Upload dataset
curl -X POST https://data-api.example.com/datasets \
  -H "Content-Type: application/json" \
  -d '{
    "name": "customer_data",
    "format": "csv",
    "schema": {
      "id": "integer",
      "name": "string",
      "created_at": "timestamp"
    }
  }'

# Stream data upload
curl -X POST https://data-api.example.com/stream \
  -H "Content-Type: application/x-ndjson" \
  --data-binary @events.jsonl

# Check ingestion status
http GET https://data-api.example.com/jobs/12345/status
```

### Webhook Testing

```bash
# Test webhook endpoint
curl -X POST https://your-app.com/webhooks/data-ready \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Signature: sha256=..." \
  -d '{
    "event": "data.processed",
    "dataset_id": "abc123",
    "timestamp": "2024-01-15T10:30:00Z"
  }'

# Simulate webhook with httpie
http POST https://your-app.com/webhooks/model-trained \
  event=model.trained \
  model_id=model_v2 \
  accuracy:=0.95 \
  timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
```

## Testing Strategies

### API Health Monitoring

```bash
#!/bin/bash
# health_check.sh - Monitor API health

ENDPOINTS=(
  "https://api.example.com/health"
  "https://ml-api.example.com/health"
  "https://data-api.example.com/status"
)

for endpoint in "${ENDPOINTS[@]}"; do
  echo "Checking $endpoint..."
  
  response=$(curl -s -w "%{http_code}" -o /dev/null "$endpoint")
  
  if [ "$response" = "200" ]; then
    echo "✅ $endpoint is healthy"
  else
    echo "❌ $endpoint returned $response"
  fi
done
```

### Load Testing

```bash
# Simple load test with curl
for i in {1..100}; do
  curl -s https://api.example.com/data > /dev/null &
done
wait

# Measure response times
curl -w "@curl-format.txt" -s -o /dev/null \
  https://api.example.com/data

# curl-format.txt
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
```

### Authentication Testing

```bash
# Test different auth methods
test_auth() {
  local endpoint=$1
  local method=$2
  
  case $method in
    "basic")
      curl -u "$USER:$PASS" "$endpoint"
      ;;
    "bearer")
      curl -H "Authorization: Bearer $TOKEN" "$endpoint"
      ;;
    "apikey")
      curl -H "X-API-Key: $API_KEY" "$endpoint"
      ;;
  esac
}

# Test auth expiration
test_token_expiry() {
  local token=$1
  local endpoint=$2
  
  response=$(curl -s -w "%{http_code}" \
    -H "Authorization: Bearer $token" \
    -o /dev/null "$endpoint")
  
  if [ "$response" = "401" ]; then
    echo "Token expired, refreshing..."
    # Refresh token logic here
  fi
}
```

## Error Handling and Debugging

### Common Issues and Solutions

```bash
# SSL certificate issues
curl -k https://self-signed.example.com  # Skip verification
curl --cacert custom-ca.pem https://api.example.com

# Connection timeouts
curl --connect-timeout 10 --max-time 30 \
  https://slow-api.example.com

# Rate limiting
curl -H "X-RateLimit-Remaining: 0" \
  https://api.example.com || sleep 60

# Large response handling
curl -s https://api.example.com/large-data | \
  jq -c '.[] | select(.status == "active")'
```

### Debugging Techniques

```bash
# Verbose output
curl -v https://api.example.com/debug

# Trace requests
curl --trace-ascii trace.log https://api.example.com

# Save headers and body separately
curl -D headers.txt -o body.json https://api.example.com

# Test with different HTTP versions
curl --http1.1 https://api.example.com
curl --http2 https://api.example.com
```

## Automation and Scripting

### API Testing Scripts

```bash
#!/bin/bash
# api_test_suite.sh

BASE_URL="https://api.example.com"
API_KEY="your-api-key"

# Test data creation
test_create_dataset() {
  echo "Testing dataset creation..."
  
  response=$(curl -s -w "%{http_code}" \
    -X POST "$BASE_URL/datasets" \
    -H "X-API-Key: $API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"name": "test_dataset", "type": "csv"}' \
    -o create_response.json)
  
  if [ "$response" = "201" ]; then
    dataset_id=$(jq -r '.id' create_response.json)
    echo "✅ Dataset created: $dataset_id"
    return 0
  else
    echo "❌ Failed to create dataset: $response"
    return 1
  fi
}

# Test data upload
test_upload_data() {
  local dataset_id=$1
  
  echo "Testing data upload..."
  
  response=$(curl -s -w "%{http_code}" \
    -X POST "$BASE_URL/datasets/$dataset_id/upload" \
    -H "X-API-Key: $API_KEY" \
    -F "file=@test_data.csv" \
    -o upload_response.json)
  
  if [ "$response" = "200" ]; then
    echo "✅ Data uploaded successfully"
    return 0
  else
    echo "❌ Failed to upload data: $response"
    return 1
  fi
}

# Run tests
main() {
  if test_create_dataset; then
    dataset_id=$(jq -r '.id' create_response.json)
    test_upload_data "$dataset_id"
  fi
}

main "$@"
```

### CI/CD Integration

```yaml
# .github/workflows/api-tests.yml
name: API Tests

on: [push, pull_request]

jobs:
  api-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install httpie
        run: pip install httpie
      
      - name: Test API endpoints
        env:
          API_KEY: ${{ secrets.API_KEY }}
          BASE_URL: https://staging-api.example.com
        run: |
          # Health check
          http GET $BASE_URL/health
          
          # Authentication test
          http GET $BASE_URL/protected X-API-Key:$API_KEY
          
          # Data upload test
          echo "test,data" > test.csv
          http --form POST $BASE_URL/upload file@test.csv
```

## Best Practices

### Security

```bash
# Never log sensitive data
curl -s -H "Authorization: Bearer $TOKEN" \
  https://api.example.com/data 2>/dev/null

# Use environment variables
export API_KEY="your-secret-key"
curl -H "X-API-Key: $API_KEY" https://api.example.com

# Validate SSL certificates
curl --fail --show-error https://api.example.com
```

### Performance

```bash
# Reuse connections
curl --keepalive-time 60 https://api.example.com/data1
curl --keepalive-time 60 https://api.example.com/data2

# Compress responses
curl -H "Accept-Encoding: gzip" https://api.example.com/large-data

# Parallel requests
curl https://api.example.com/data1 & \
curl https://api.example.com/data2 & \
wait
```

### Maintainability

```bash
# Use configuration files
# .curlrc
user-agent = "DataPipeline/1.0"
connect-timeout = 10
max-time = 30
fail
show-error
```

## Summary

API testing with curl and httpie is essential for data pipeline development. These tools enable rapid debugging, automated testing, and integration validation.

**Key takeaways**:
- curl is universal and powerful for scripting
- httpie provides better user experience for interactive testing
- Authentication and error handling are critical
- Automation enables continuous API monitoring
- Security practices protect sensitive data

**Next**: Day 26 will cover AWS CLI for cloud resource management and data operations.
