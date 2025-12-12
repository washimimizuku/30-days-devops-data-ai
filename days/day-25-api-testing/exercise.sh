#!/bin/bash

# Day 25: API Testing - curl and httpie
# Hands-on exercises for mastering API testing tools

set -e

echo "🌐 Day 25: API Testing Exercises"
echo "================================"

# Exercise 1: curl Fundamentals
echo -e "\n📡 Exercise 1: curl Fundamentals"
echo "Testing basic HTTP operations with curl..."

mkdir -p exercise1-curl-basics
cd exercise1-curl-basics

# Test public APIs
echo "Testing GET requests..."
curl -s https://httpbin.org/get | jq '.' > get_response.json
echo "✅ GET request saved to get_response.json"

# Test POST with JSON
echo "Testing POST with JSON data..."
curl -X POST https://httpbin.org/post \
  -H "Content-Type: application/json" \
  -d '{"name": "data-pipeline", "version": "1.0", "active": true}' \
  -s | jq '.' > post_response.json
echo "✅ POST request saved to post_response.json"

# Test headers
echo "Testing custom headers..."
curl -H "X-Custom-Header: DataPipeline" \
  -H "User-Agent: Exercise/1.0" \
  -s https://httpbin.org/headers | jq '.' > headers_response.json
echo "✅ Headers test saved to headers_response.json"

# Test authentication
echo "Testing basic authentication..."
curl -u testuser:testpass \
  -s https://httpbin.org/basic-auth/testuser/testpass | jq '.' > auth_response.json
echo "✅ Auth test saved to auth_response.json"

cd ..

echo "✅ Exercise 1 complete: curl fundamentals"

# Exercise 2: httpie Modern Syntax
echo -e "\n🎯 Exercise 2: httpie Modern Syntax"
echo "Learning httpie's user-friendly syntax..."

# Check if httpie is installed
if ! command -v http &> /dev/null; then
    echo "Installing httpie..."
    pip install httpie
fi

mkdir -p exercise2-httpie
cd exercise2-httpie

# Basic GET with httpie
echo "Testing httpie GET request..."
http GET https://httpbin.org/get \
  User-Agent:DataPipeline/1.0 \
  X-Pipeline-ID:12345 > httpie_get.json
echo "✅ httpie GET saved to httpie_get.json"

# POST with automatic JSON
echo "Testing httpie POST with automatic JSON..."
http POST https://httpbin.org/post \
  name=ml-model \
  version:=2.1 \
  accuracy:=0.95 \
  features:='["feature1", "feature2", "feature3"]' > httpie_post.json
echo "✅ httpie POST saved to httpie_post.json"

# Form data upload
echo "Creating sample CSV for upload..."
cat > sample_data.csv << 'EOF'
id,name,value,category
1,item1,100,A
2,item2,200,B
3,item3,150,A
4,item4,300,C
EOF

echo "Testing form upload with httpie..."
http --form POST https://httpbin.org/post \
  file@sample_data.csv \
  description="Sample dataset for testing" > httpie_upload.json
echo "✅ httpie upload saved to httpie_upload.json"

cd ..

echo "✅ Exercise 2 complete: httpie modern syntax"

# Exercise 3: Data Pipeline API Simulation
echo -e "\n🔄 Exercise 3: Data Pipeline API Simulation"
echo "Simulating real data pipeline API interactions..."

mkdir -p exercise3-pipeline-apis
cd exercise3-pipeline-apis

# Create mock data
cat > training_data.json << 'EOF'
{
  "dataset_id": "train_001",
  "features": [
    {"name": "age", "type": "numeric", "min": 18, "max": 65},
    {"name": "income", "type": "numeric", "min": 20000, "max": 150000},
    {"name": "category", "type": "categorical", "values": ["A", "B", "C"]}
  ],
  "target": "conversion",
  "samples": 10000,
  "split": {"train": 0.8, "test": 0.2}
}
EOF

cat > prediction_request.json << 'EOF'
{
  "model_id": "rf_classifier_v1",
  "instances": [
    {"age": 35, "income": 75000, "category": "A"},
    {"age": 42, "income": 95000, "category": "B"},
    {"age": 28, "income": 55000, "category": "C"}
  ],
  "return_probabilities": true
}
EOF

# Test dataset upload simulation
echo "Simulating dataset upload..."
curl -X POST https://httpbin.org/post \
  -H "Content-Type: application/json" \
  -H "X-API-Key: fake-api-key-12345" \
  -d @training_data.json \
  -s | jq '.json' > dataset_upload_response.json
echo "✅ Dataset upload simulated"

# Test model prediction simulation
echo "Simulating model prediction..."
http POST https://httpbin.org/post \
  Content-Type:application/json \
  Authorization:"Bearer fake-jwt-token" \
  < prediction_request.json > prediction_response.json
echo "✅ Model prediction simulated"

# Test batch processing status
echo "Simulating batch job status check..."
curl -H "Authorization: Bearer fake-jwt-token" \
  -s "https://httpbin.org/get?job_id=batch_001&status=running" | \
  jq '.' > job_status.json
echo "✅ Job status check simulated"

cd ..

echo "✅ Exercise 3 complete: Data pipeline API simulation"

# Exercise 4: Error Handling and Debugging
echo -e "\n🐛 Exercise 4: Error Handling and Debugging"
echo "Learning to handle API errors and debug issues..."

mkdir -p exercise4-error-handling
cd exercise4-error-handling

# Test different HTTP status codes
echo "Testing various HTTP status codes..."

# Success case
curl -s -w "Status: %{http_code}\n" \
  https://httpbin.org/status/200 > success.log

# Client errors
curl -s -w "Status: %{http_code}\n" \
  https://httpbin.org/status/400 > bad_request.log 2>&1 || true

curl -s -w "Status: %{http_code}\n" \
  https://httpbin.org/status/401 > unauthorized.log 2>&1 || true

curl -s -w "Status: %{http_code}\n" \
  https://httpbin.org/status/404 > not_found.log 2>&1 || true

# Server errors
curl -s -w "Status: %{http_code}\n" \
  https://httpbin.org/status/500 > server_error.log 2>&1 || true

echo "✅ Status code tests completed"

# Test timeout handling
echo "Testing timeout scenarios..."
curl --connect-timeout 5 --max-time 10 \
  -s https://httpbin.org/delay/2 > timeout_success.json || echo "Request timed out"

# Test retry logic
echo "Testing retry with curl..."
curl --retry 3 --retry-delay 1 \
  -s https://httpbin.org/status/503 > retry_test.log 2>&1 || echo "All retries failed"

# Verbose debugging
echo "Testing verbose output for debugging..."
curl -v https://httpbin.org/get 2> debug_verbose.log > debug_response.json

echo "✅ Error handling tests completed"

cd ..

echo "✅ Exercise 4 complete: Error handling and debugging"

# Exercise 5: Authentication Methods
echo -e "\n🔐 Exercise 5: Authentication Methods"
echo "Testing different authentication approaches..."

mkdir -p exercise5-authentication
cd exercise5-authentication

# Basic authentication
echo "Testing basic authentication..."
curl -u demo:password \
  -s https://httpbin.org/basic-auth/demo/password | \
  jq '.' > basic_auth.json
echo "✅ Basic auth test completed"

# Bearer token simulation
echo "Testing bearer token authentication..."
http GET https://httpbin.org/bearer \
  Authorization:"Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.fake.token" > bearer_auth.json
echo "✅ Bearer token test completed"

# API key in header
echo "Testing API key in header..."
curl -H "X-API-Key: secret-api-key-12345" \
  -s https://httpbin.org/headers | \
  jq '.headers' > api_key_header.json
echo "✅ API key header test completed"

# API key in query parameter
echo "Testing API key in query parameter..."
http GET https://httpbin.org/get \
  api_key==secret-key-67890 > api_key_query.json
echo "✅ API key query test completed"

cd ..

echo "✅ Exercise 5 complete: Authentication methods"

# Exercise 6: Performance Testing and Monitoring
echo -e "\n⚡ Exercise 6: Performance Testing and Monitoring"
echo "Testing API performance and creating monitoring scripts..."

mkdir -p exercise6-performance
cd exercise6-performance

# Create curl timing format
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
         size_download: %{size_download}\n
         speed_download: %{speed_download}\n
EOF

# Test response times
echo "Testing API response times..."
curl -w "@curl-format.txt" -s -o response.json \
  https://httpbin.org/delay/1 > timing_results.txt
echo "✅ Timing test completed - check timing_results.txt"

# Create health check script
cat > health_check.sh << 'EOF'
#!/bin/bash

# API Health Check Script
ENDPOINTS=(
  "https://httpbin.org/status/200"
  "https://httpbin.org/get"
  "https://httpbin.org/json"
)

echo "🏥 API Health Check - $(date)"
echo "================================"

for endpoint in "${ENDPOINTS[@]}"; do
  echo -n "Checking $endpoint... "
  
  response=$(curl -s -w "%{http_code}" -o /dev/null "$endpoint")
  
  if [ "$response" = "200" ]; then
    echo "✅ Healthy (200)"
  else
    echo "❌ Unhealthy ($response)"
  fi
done

echo "Health check completed."
EOF

chmod +x health_check.sh
./health_check.sh > health_check_results.txt

# Simple load test
echo "Running simple load test..."
cat > load_test.sh << 'EOF'
#!/bin/bash

ENDPOINT="https://httpbin.org/get"
REQUESTS=10
CONCURRENT=3

echo "🚀 Load Test - $REQUESTS requests with $CONCURRENT concurrent"
echo "=============================================="

start_time=$(date +%s)

for i in $(seq 1 $REQUESTS); do
  if [ $((i % CONCURRENT)) -eq 0 ]; then
    wait  # Wait for previous batch to complete
  fi
  
  curl -s "$ENDPOINT" > "response_$i.json" &
done

wait  # Wait for all remaining requests

end_time=$(date +%s)
duration=$((end_time - start_time))

echo "Load test completed in ${duration} seconds"
echo "Average: $(echo "scale=2; $REQUESTS / $duration" | bc) requests/second"
EOF

chmod +x load_test.sh
./load_test.sh > load_test_results.txt

cd ..

echo "✅ Exercise 6 complete: Performance testing and monitoring"

# Create summary report
echo -e "\n📊 Creating Exercise Summary Report"

cat > api_testing_report.md << 'EOF'
# API Testing Exercise Report

## Completed Exercises

### 1. curl Fundamentals ✅
- Basic GET/POST requests
- Custom headers and authentication
- JSON data handling

### 2. httpie Modern Syntax ✅
- User-friendly HTTP client
- Automatic JSON formatting
- Form data uploads

### 3. Data Pipeline API Simulation ✅
- Dataset upload simulation
- Model prediction requests
- Batch job status monitoring

### 4. Error Handling and Debugging ✅
- HTTP status code testing
- Timeout and retry logic
- Verbose debugging output

### 5. Authentication Methods ✅
- Basic authentication
- Bearer token authentication
- API key authentication (header and query)

### 6. Performance Testing ✅
- Response time measurement
- Health check automation
- Simple load testing

## Key Files Created

- Response samples: `*/response*.json`
- Authentication tests: `*/auth*.json`
- Performance data: `*/timing_results.txt`
- Health check script: `*/health_check.sh`
- Load test script: `*/load_test.sh`

## Next Steps

1. Integrate these patterns into your data pipelines
2. Create automated API monitoring for production
3. Build comprehensive test suites for your APIs
4. Implement proper error handling in scripts

## Tools Mastered

- **curl**: Universal HTTP client for scripting
- **httpie**: Modern, user-friendly HTTP client
- **jq**: JSON processing for API responses
- **bash scripting**: Automation and error handling
EOF

echo "✅ Summary report created: api_testing_report.md"

echo -e "\n🎉 All Day 25 exercises completed!"
echo "You've practiced:"
echo "- curl fundamentals for HTTP requests"
echo "- httpie modern syntax and features"
echo "- Data pipeline API testing patterns"
echo "- Error handling and debugging techniques"
echo "- Various authentication methods"
echo "- Performance testing and monitoring"
echo ""
echo "Next: Day 26 - AWS CLI for cloud operations"
