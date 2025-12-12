#!/bin/bash

# Day 25: API Testing Solutions
# Reference implementations and best practices

set -e

echo "🌐 Day 25: API Testing Solutions"
echo "================================"

# Solution 1: Production API Testing Framework
echo -e "\n🏗️ Solution 1: Production API Testing Framework"

mkdir -p solution1-testing-framework
cd solution1-testing-framework

# Create comprehensive API test framework
cat > api_test_framework.sh << 'EOF'
#!/bin/bash

# Production API Testing Framework
# Supports multiple environments, authentication methods, and reporting

set -e

# Configuration
CONFIG_FILE="${CONFIG_FILE:-api_config.json}"
REPORT_DIR="${REPORT_DIR:-reports}"
VERBOSE="${VERBOSE:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Load configuration
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file $CONFIG_FILE not found"
        exit 1
    fi
    
    BASE_URL=$(jq -r '.base_url' "$CONFIG_FILE")
    API_KEY=$(jq -r '.api_key' "$CONFIG_FILE")
    TIMEOUT=$(jq -r '.timeout // 30' "$CONFIG_FILE")
    RETRY_COUNT=$(jq -r '.retry_count // 3' "$CONFIG_FILE")
}

# Generic API test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local expected_status=$3
    local data_file=$4
    local description=$5
    
    log_info "Testing: $description"
    
    local curl_opts=(
        -s -w "%{http_code}|%{time_total}|%{size_download}"
        -X "$method"
        --connect-timeout 10
        --max-time "$TIMEOUT"
        --retry "$RETRY_COUNT"
        -H "X-API-Key: $API_KEY"
        -H "Content-Type: application/json"
    )
    
    if [[ -n "$data_file" && -f "$data_file" ]]; then
        curl_opts+=(-d "@$data_file")
    fi
    
    local response
    response=$(curl "${curl_opts[@]}" "$BASE_URL$endpoint" 2>/dev/null)
    
    local status_code time_total size_download
    IFS='|' read -r status_code time_total size_download <<< "$response"
    
    # Validate response
    if [[ "$status_code" == "$expected_status" ]]; then
        log_info "✅ PASS: $description (${time_total}s, ${size_download} bytes)"
        echo "$description,PASS,$status_code,$time_total,$size_download" >> "$REPORT_DIR/results.csv"
    else
        log_error "❌ FAIL: $description (expected $expected_status, got $status_code)"
        echo "$description,FAIL,$status_code,$time_total,$size_download" >> "$REPORT_DIR/results.csv"
    fi
}

# Main test execution
main() {
    load_config
    
    mkdir -p "$REPORT_DIR"
    echo "Test,Status,HTTP_Code,Time_Total,Size_Download" > "$REPORT_DIR/results.csv"
    
    log_info "Starting API test suite against $BASE_URL"
    
    # Health check
    test_endpoint "GET" "/health" "200" "" "Health Check"
    
    # Authentication test
    test_endpoint "GET" "/auth/verify" "200" "" "Authentication Verification"
    
    # Data operations
    test_endpoint "POST" "/data/upload" "201" "test_data.json" "Data Upload"
    test_endpoint "GET" "/data/list" "200" "" "Data List"
    
    log_info "Test suite completed. Results in $REPORT_DIR/results.csv"
}

main "$@"
EOF

# Create configuration file
cat > api_config.json << 'EOF'
{
  "base_url": "https://api.example.com/v1",
  "api_key": "test-api-key-12345",
  "timeout": 30,
  "retry_count": 3,
  "environments": {
    "staging": "https://staging-api.example.com/v1",
    "production": "https://api.example.com/v1"
  }
}
EOF

chmod +x api_test_framework.sh

cd ..
echo "✅ Solution 1: Production API testing framework"

# Solution 2: ML Model API Testing Suite
echo -e "\n🤖 Solution 2: ML Model API Testing Suite"

mkdir -p solution2-ml-api-testing
cd solution2-ml-api-testing

# Create ML-specific API testing
cat > ml_api_tester.py << 'EOF'
#!/usr/bin/env python3
"""
ML Model API Testing Suite
Comprehensive testing for machine learning model APIs
"""

import json
import time
import requests
import numpy as np
from typing import Dict, List, Any
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MLAPITester:
    def __init__(self, base_url: str, api_key: str = None):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        if api_key:
            self.session.headers.update({'Authorization': f'Bearer {api_key}'})
        
        self.results = []
    
    def test_health_check(self) -> bool:
        """Test model health endpoint"""
        try:
            response = self.session.get(f"{self.base_url}/health", timeout=10)
            success = response.status_code == 200
            
            self.results.append({
                'test': 'health_check',
                'success': success,
                'status_code': response.status_code,
                'response_time': response.elapsed.total_seconds()
            })
            
            logger.info(f"Health check: {'PASS' if success else 'FAIL'}")
            return success
            
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            return False
    
    def test_model_info(self) -> bool:
        """Test model information endpoint"""
        try:
            response = self.session.get(f"{self.base_url}/model/info", timeout=10)
            success = response.status_code == 200
            
            if success:
                info = response.json()
                required_fields = ['name', 'version', 'input_schema']
                success = all(field in info for field in required_fields)
            
            self.results.append({
                'test': 'model_info',
                'success': success,
                'status_code': response.status_code,
                'response_time': response.elapsed.total_seconds()
            })
            
            logger.info(f"Model info: {'PASS' if success else 'FAIL'}")
            return success
            
        except Exception as e:
            logger.error(f"Model info test failed: {e}")
            return False
    
    def test_single_prediction(self) -> bool:
        """Test single prediction endpoint"""
        try:
            # Generate test data
            test_data = {
                'features': [1.0, 2.0, 3.0, 4.0],
                'model_version': 'latest'
            }
            
            response = self.session.post(
                f"{self.base_url}/predict",
                json=test_data,
                timeout=30
            )
            
            success = response.status_code == 200
            
            if success:
                result = response.json()
                success = 'prediction' in result
            
            self.results.append({
                'test': 'single_prediction',
                'success': success,
                'status_code': response.status_code,
                'response_time': response.elapsed.total_seconds()
            })
            
            logger.info(f"Single prediction: {'PASS' if success else 'FAIL'}")
            return success
            
        except Exception as e:
            logger.error(f"Single prediction test failed: {e}")
            return False
    
    def test_batch_prediction(self) -> bool:
        """Test batch prediction endpoint"""
        try:
            # Generate batch test data
            batch_data = {
                'instances': [
                    {'features': [1.0, 2.0, 3.0, 4.0]},
                    {'features': [2.0, 3.0, 4.0, 5.0]},
                    {'features': [3.0, 4.0, 5.0, 6.0]}
                ],
                'model_version': 'latest'
            }
            
            response = self.session.post(
                f"{self.base_url}/predict/batch",
                json=batch_data,
                timeout=60
            )
            
            success = response.status_code == 200
            
            if success:
                result = response.json()
                success = 'predictions' in result and len(result['predictions']) == 3
            
            self.results.append({
                'test': 'batch_prediction',
                'success': success,
                'status_code': response.status_code,
                'response_time': response.elapsed.total_seconds()
            })
            
            logger.info(f"Batch prediction: {'PASS' if success else 'FAIL'}")
            return success
            
        except Exception as e:
            logger.error(f"Batch prediction test failed: {e}")
            return False
    
    def test_model_performance(self, num_requests: int = 10) -> Dict[str, float]:
        """Test model performance under load"""
        logger.info(f"Running performance test with {num_requests} requests")
        
        response_times = []
        successful_requests = 0
        
        test_data = {'features': [1.0, 2.0, 3.0, 4.0]}
        
        for i in range(num_requests):
            try:
                start_time = time.time()
                response = self.session.post(
                    f"{self.base_url}/predict",
                    json=test_data,
                    timeout=30
                )
                end_time = time.time()
                
                if response.status_code == 200:
                    successful_requests += 1
                    response_times.append(end_time - start_time)
                
            except Exception as e:
                logger.warning(f"Request {i+1} failed: {e}")
        
        if response_times:
            performance_stats = {
                'avg_response_time': np.mean(response_times),
                'min_response_time': np.min(response_times),
                'max_response_time': np.max(response_times),
                'p95_response_time': np.percentile(response_times, 95),
                'success_rate': successful_requests / num_requests
            }
        else:
            performance_stats = {
                'avg_response_time': 0,
                'min_response_time': 0,
                'max_response_time': 0,
                'p95_response_time': 0,
                'success_rate': 0
            }
        
        self.results.append({
            'test': 'performance',
            'success': performance_stats['success_rate'] > 0.9,
            'stats': performance_stats
        })
        
        logger.info(f"Performance test completed: {performance_stats}")
        return performance_stats
    
    def run_all_tests(self) -> Dict[str, Any]:
        """Run complete test suite"""
        logger.info("Starting ML API test suite")
        
        tests = [
            self.test_health_check,
            self.test_model_info,
            self.test_single_prediction,
            self.test_batch_prediction,
        ]
        
        passed = 0
        total = len(tests)
        
        for test in tests:
            if test():
                passed += 1
        
        # Run performance test
        perf_stats = self.test_model_performance()
        
        summary = {
            'total_tests': total,
            'passed_tests': passed,
            'success_rate': passed / total,
            'performance_stats': perf_stats,
            'detailed_results': self.results
        }
        
        logger.info(f"Test suite completed: {passed}/{total} tests passed")
        return summary

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='ML API Testing Suite')
    parser.add_argument('--url', required=True, help='Base URL of the ML API')
    parser.add_argument('--api-key', help='API key for authentication')
    parser.add_argument('--output', default='ml_test_results.json', help='Output file')
    
    args = parser.parse_args()
    
    tester = MLAPITester(args.url, args.api_key)
    results = tester.run_all_tests()
    
    with open(args.output, 'w') as f:
        json.dump(results, f, indent=2)
    
    print(f"Results saved to {args.output}")

if __name__ == '__main__':
    main()
EOF

chmod +x ml_api_tester.py

cd ..
echo "✅ Solution 2: ML model API testing suite"

# Solution 3: Advanced curl Scripting
echo -e "\n🔧 Solution 3: Advanced curl Scripting"

mkdir -p solution3-advanced-curl
cd solution3-advanced-curl

# Create advanced curl wrapper
cat > advanced_curl.sh << 'EOF'
#!/bin/bash

# Advanced curl wrapper with retry logic, logging, and error handling

set -e

# Configuration
MAX_RETRIES=3
RETRY_DELAY=2
TIMEOUT=30
LOG_FILE="api_requests.log"
VERBOSE=false

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --retries)
            MAX_RETRIES="$2"
            shift 2
            ;;
        --delay)
            RETRY_DELAY="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --log)
            LOG_FILE="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Logging function
log_request() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

# Advanced curl function with retry logic
curl_with_retry() {
    local url=$1
    local method=${2:-GET}
    local data_file=$3
    local headers=("${@:4}")
    
    local attempt=1
    local success=false
    
    while [[ $attempt -le $MAX_RETRIES && $success == false ]]; do
        log_request "Attempt $attempt/$MAX_RETRIES: $method $url"
        
        local curl_opts=(
            -s
            -w "%{http_code}|%{time_total}|%{size_download}|%{url_effective}"
            -X "$method"
            --connect-timeout 10
            --max-time "$TIMEOUT"
        )
        
        # Add headers
        for header in "${headers[@]}"; do
            curl_opts+=(-H "$header")
        done
        
        # Add data if provided
        if [[ -n "$data_file" && -f "$data_file" ]]; then
            curl_opts+=(-d "@$data_file")
        fi
        
        # Add verbose output if requested
        if [[ "$VERBOSE" == true ]]; then
            curl_opts+=(-v)
        fi
        
        local response
        if response=$(curl "${curl_opts[@]}" "$url" 2>/dev/null); then
            local status_code time_total size_download url_effective
            IFS='|' read -r status_code time_total size_download url_effective <<< "$response"
            
            if [[ "$status_code" =~ ^[23] ]]; then
                success=true
                log_request "SUCCESS: $status_code in ${time_total}s (${size_download} bytes)"
                echo "SUCCESS|$status_code|$time_total|$size_download"
                return 0
            else
                log_request "HTTP ERROR: $status_code"
            fi
        else
            log_request "NETWORK ERROR: curl failed"
        fi
        
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            log_request "Retrying in ${RETRY_DELAY}s..."
            sleep "$RETRY_DELAY"
        fi
        
        ((attempt++))
    done
    
    log_request "FAILED: All $MAX_RETRIES attempts failed"
    echo "FAILED|0|0|0"
    return 1
}

# Example usage functions
test_api_endpoints() {
    local base_url=$1
    local api_key=$2
    
    echo "Testing API endpoints at $base_url"
    
    # Health check
    echo "Testing health endpoint..."
    curl_with_retry "$base_url/health" "GET" "" "X-API-Key: $api_key"
    
    # Authentication test
    echo "Testing authentication..."
    curl_with_retry "$base_url/auth/verify" "GET" "" "Authorization: Bearer $api_key"
    
    # Data upload test
    if [[ -f "test_data.json" ]]; then
        echo "Testing data upload..."
        curl_with_retry "$base_url/data" "POST" "test_data.json" \
            "Content-Type: application/json" \
            "X-API-Key: $api_key"
    fi
}

# Main execution
main() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 [options] <base_url> [api_key]"
        echo "Options:"
        echo "  --retries N     Maximum retry attempts (default: 3)"
        echo "  --delay N       Delay between retries in seconds (default: 2)"
        echo "  --timeout N     Request timeout in seconds (default: 30)"
        echo "  --log FILE      Log file path (default: api_requests.log)"
        echo "  --verbose       Enable verbose output"
        exit 1
    fi
    
    local base_url=$1
    local api_key=${2:-""}
    
    # Create test data if it doesn't exist
    if [[ ! -f "test_data.json" ]]; then
        cat > test_data.json << 'EOD'
{
    "name": "test_dataset",
    "type": "training",
    "features": ["feature1", "feature2", "feature3"],
    "samples": 1000
}
EOD
    fi
    
    test_api_endpoints "$base_url" "$api_key"
}

# Run if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

chmod +x advanced_curl.sh

cd ..
echo "✅ Solution 3: Advanced curl scripting with retry logic"

echo -e "\n🎉 All Day 25 solutions completed!"
echo ""
echo "Solutions demonstrated:"
echo "1. Production API testing framework with comprehensive reporting"
echo "2. ML model API testing suite with performance benchmarking"
echo "3. Advanced curl scripting with retry logic and error handling"
echo ""
echo "Key patterns covered:"
echo "- Robust error handling and retry mechanisms"
echo "- Performance testing and monitoring"
echo "- Comprehensive logging and reporting"
echo "- Authentication and security testing"
echo "- ML-specific API testing patterns"
