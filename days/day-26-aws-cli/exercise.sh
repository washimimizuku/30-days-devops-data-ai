#!/bin/bash

# Day 26: AWS CLI - Cloud Operations
# Hands-on exercises for mastering AWS CLI

set -e

echo "☁️ Day 26: AWS CLI Exercises"
echo "============================"

# Note: These exercises use AWS CLI simulation and local testing
# For real AWS operations, you'll need valid AWS credentials

# Exercise 1: AWS CLI Setup and Configuration
echo -e "\n🔧 Exercise 1: AWS CLI Setup and Configuration"
echo "Setting up AWS CLI configuration (simulation)..."

mkdir -p exercise1-aws-setup
cd exercise1-aws-setup

# Check if AWS CLI is installed
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI is installed: $(aws --version)"
else
    echo "❌ AWS CLI not found. Install with:"
    echo "  macOS: brew install awscli"
    echo "  Linux: curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip' && unzip awscliv2.zip && sudo ./aws/install"
fi

# Create mock AWS configuration for learning
mkdir -p ~/.aws-mock

cat > ~/.aws-mock/credentials << 'EOF'
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

[data-pipeline]
aws_access_key_id = AKIAI44QH8DHBEXAMPLE
aws_secret_access_key = je7MtGbClwBF/2Zp9Utk/h3yCo8nvbEXAMPLEKEY

[production]
aws_access_key_id = AKIA_EXAMPLE_ACCESS_KEY_ID
aws_secret_access_key = EXAMPLE_SECRET_ACCESS_KEY_PLACEHOLDER
EOF

cat > ~/.aws-mock/config << 'EOF'
[default]
region = us-east-1
output = json

[profile data-pipeline]
region = us-west-2
output = table

[profile production]
region = us-east-1
output = json
EOF

echo "✅ Mock AWS configuration created in ~/.aws-mock/"
echo "📝 In real usage, run: aws configure"

# Create AWS CLI command reference
cat > aws_cli_reference.md << 'EOF'
# AWS CLI Quick Reference

## Configuration
```bash
aws configure                    # Configure default profile
aws configure --profile name     # Configure named profile
aws configure list              # Show current configuration
```

## S3 Operations
```bash
aws s3 ls                       # List buckets
aws s3 ls s3://bucket/          # List objects in bucket
aws s3 cp file.txt s3://bucket/ # Upload file
aws s3 cp s3://bucket/file.txt . # Download file
aws s3 sync ./dir s3://bucket/  # Sync directory
```

## EC2 Operations
```bash
aws ec2 describe-instances      # List instances
aws ec2 start-instances --instance-ids i-123
aws ec2 stop-instances --instance-ids i-123
```

## Lambda Operations
```bash
aws lambda list-functions       # List functions
aws lambda invoke --function-name name
```
EOF

cd ..
echo "✅ Exercise 1 complete: AWS CLI setup and configuration"

# Exercise 2: S3 Operations Simulation
echo -e "\n📦 Exercise 2: S3 Operations Simulation"
echo "Simulating S3 data operations..."

mkdir -p exercise2-s3-operations
cd exercise2-s3-operations

# Create sample datasets
echo "Creating sample datasets..."

cat > customer_data.csv << 'EOF'
id,name,email,signup_date,plan
1,John Doe,john@example.com,2024-01-15,premium
2,Jane Smith,jane@example.com,2024-01-16,basic
3,Bob Johnson,bob@example.com,2024-01-17,premium
4,Alice Brown,alice@example.com,2024-01-18,basic
5,Charlie Wilson,charlie@example.com,2024-01-19,premium
EOF

cat > sales_data.json << 'EOF'
{
  "sales": [
    {"date": "2024-01-15", "amount": 1250.00, "customer_id": 1},
    {"date": "2024-01-16", "amount": 750.50, "customer_id": 2},
    {"date": "2024-01-17", "amount": 2100.75, "customer_id": 3},
    {"date": "2024-01-18", "amount": 450.25, "customer_id": 4},
    {"date": "2024-01-19", "amount": 1800.00, "customer_id": 5}
  ],
  "total": 6350.50,
  "currency": "USD"
}
EOF

# Create S3 operations script (simulation)
cat > s3_operations.sh << 'EOF'
#!/bin/bash

# S3 Operations Script (Simulation)
# In real usage, replace with actual bucket names

BUCKET_NAME="my-data-pipeline-bucket"
LOCAL_DATA_DIR="./data"
S3_DATA_PREFIX="datasets"

echo "🪣 S3 Operations Simulation"
echo "=========================="

# Simulate bucket creation
echo "Creating bucket: $BUCKET_NAME"
echo "Command: aws s3 mb s3://$BUCKET_NAME"
echo "✅ Bucket created (simulated)"

# Simulate file upload
echo -e "\nUploading files to S3..."
for file in *.csv *.json; do
    if [[ -f "$file" ]]; then
        echo "Uploading $file..."
        echo "Command: aws s3 cp $file s3://$BUCKET_NAME/$S3_DATA_PREFIX/"
        echo "✅ $file uploaded (simulated)"
    fi
done

# Simulate directory sync
echo -e "\nSyncing directory to S3..."
echo "Command: aws s3 sync ./ s3://$BUCKET_NAME/$S3_DATA_PREFIX/ --exclude '*.sh'"
echo "✅ Directory synced (simulated)"

# Simulate listing objects
echo -e "\nListing S3 objects..."
echo "Command: aws s3 ls s3://$BUCKET_NAME/$S3_DATA_PREFIX/ --recursive"
echo "2024-01-20 10:30:00       1024 datasets/customer_data.csv"
echo "2024-01-20 10:30:01        512 datasets/sales_data.json"
echo "✅ Objects listed (simulated)"

# Simulate download
echo -e "\nDownloading from S3..."
mkdir -p downloaded
echo "Command: aws s3 cp s3://$BUCKET_NAME/$S3_DATA_PREFIX/customer_data.csv ./downloaded/"
cp customer_data.csv ./downloaded/
echo "✅ File downloaded (simulated)"

echo -e "\n📊 S3 operations completed!"
EOF

chmod +x s3_operations.sh
./s3_operations.sh

cd ..
echo "✅ Exercise 2 complete: S3 operations simulation"

# Exercise 3: EC2 Instance Management
echo -e "\n🖥️ Exercise 3: EC2 Instance Management"
echo "Learning EC2 instance operations..."

mkdir -p exercise3-ec2-management
cd exercise3-ec2-management

# Create EC2 management script
cat > ec2_management.sh << 'EOF'
#!/bin/bash

# EC2 Management Script (Simulation)

echo "🖥️ EC2 Instance Management"
echo "========================="

# Simulate listing instances
echo "Listing EC2 instances..."
echo "Command: aws ec2 describe-instances"

cat << 'INSTANCES'
{
    "Reservations": [
        {
            "Instances": [
                {
                    "InstanceId": "i-1234567890abcdef0",
                    "InstanceType": "t3.medium",
                    "State": {"Name": "running"},
                    "Tags": [{"Key": "Name", "Value": "data-processor"}]
                },
                {
                    "InstanceId": "i-0987654321fedcba0",
                    "InstanceType": "t3.large",
                    "State": {"Name": "stopped"},
                    "Tags": [{"Key": "Name", "Value": "ml-trainer"}]
                }
            ]
        }
    ]
}
INSTANCES

echo -e "\n✅ Instances listed (simulated)"

# Simulate starting instance
echo -e "\nStarting stopped instance..."
echo "Command: aws ec2 start-instances --instance-ids i-0987654321fedcba0"
echo "✅ Instance start initiated (simulated)"

# Simulate waiting for instance
echo -e "\nWaiting for instance to be running..."
echo "Command: aws ec2 wait instance-running --instance-ids i-0987654321fedcba0"
echo "✅ Instance is now running (simulated)"

# Simulate stopping instance
echo -e "\nStopping instance to save costs..."
echo "Command: aws ec2 stop-instances --instance-ids i-1234567890abcdef0"
echo "✅ Instance stop initiated (simulated)"

echo -e "\n🖥️ EC2 management completed!"
EOF

chmod +x ec2_management.sh
./ec2_management.sh

# Create instance monitoring script
cat > monitor_instances.sh << 'EOF'
#!/bin/bash

# Instance Monitoring Script

echo "📊 EC2 Instance Monitoring"
echo "========================="

# Simulate getting instance status
echo "Checking instance status..."
echo "Command: aws ec2 describe-instance-status"

cat << 'STATUS'
Instance ID: i-1234567890abcdef0
Status: running
System Status: ok
Instance Status: ok
Uptime: 2 hours 15 minutes

Instance ID: i-0987654321fedcba0
Status: stopped
System Status: not-applicable
Instance Status: not-applicable
Uptime: 0 minutes
STATUS

echo -e "\n✅ Instance status checked (simulated)"

# Simulate cost calculation
echo -e "\nEstimating costs..."
echo "t3.medium (running): $0.0416/hour × 2.25 hours = $0.094"
echo "t3.large (stopped): $0.00/hour × 0 hours = $0.000"
echo "Total estimated cost: $0.094"

echo -e "\n💰 Cost monitoring completed!"
EOF

chmod +x monitor_instances.sh
./monitor_instances.sh

cd ..
echo "✅ Exercise 3 complete: EC2 instance management"

# Exercise 4: Lambda Function Operations
echo -e "\n⚡ Exercise 4: Lambda Function Operations"
echo "Working with serverless functions..."

mkdir -p exercise4-lambda-operations
cd exercise4-lambda-operations

# Create sample Lambda function
cat > lambda_function.py << 'EOF'
import json
import boto3
from datetime import datetime

def lambda_handler(event, context):
    """
    Data processing Lambda function
    Processes incoming data and stores results in S3
    """
    
    # Extract data from event
    input_data = event.get('data', [])
    bucket = event.get('bucket', 'default-bucket')
    
    # Process data (example: calculate statistics)
    if input_data:
        total = sum(input_data)
        count = len(input_data)
        average = total / count if count > 0 else 0
        
        result = {
            'timestamp': datetime.utcnow().isoformat(),
            'total': total,
            'count': count,
            'average': average,
            'processed_by': 'lambda-data-processor'
        }
    else:
        result = {
            'timestamp': datetime.utcnow().isoformat(),
            'error': 'No data provided',
            'processed_by': 'lambda-data-processor'
        }
    
    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }
EOF

# Create deployment package
echo "Creating Lambda deployment package..."
zip -q lambda-function.zip lambda_function.py
echo "✅ Deployment package created: lambda-function.zip"

# Create Lambda operations script
cat > lambda_operations.sh << 'EOF'
#!/bin/bash

# Lambda Operations Script (Simulation)

FUNCTION_NAME="data-processor"
ROLE_ARN="arn:aws:iam::123456789012:role/lambda-execution-role"

echo "⚡ Lambda Function Operations"
echo "============================"

# Simulate function creation
echo "Creating Lambda function..."
echo "Command: aws lambda create-function \\"
echo "  --function-name $FUNCTION_NAME \\"
echo "  --runtime python3.9 \\"
echo "  --role $ROLE_ARN \\"
echo "  --handler lambda_function.lambda_handler \\"
echo "  --zip-file fileb://lambda-function.zip"
echo "✅ Function created (simulated)"

# Simulate function invocation
echo -e "\nInvoking Lambda function..."
echo "Command: aws lambda invoke \\"
echo "  --function-name $FUNCTION_NAME \\"
echo "  --payload '{\"data\": [10, 20, 30, 40, 50], \"bucket\": \"my-data-bucket\"}' \\"
echo "  response.json"

# Create mock response
cat > response.json << 'RESPONSE'
{
    "statusCode": 200,
    "body": "{\"timestamp\": \"2024-01-20T10:30:00.000Z\", \"total\": 150, \"count\": 5, \"average\": 30.0, \"processed_by\": \"lambda-data-processor\"}"
}
RESPONSE

echo "✅ Function invoked (simulated)"
echo "Response saved to response.json"

# Simulate getting function logs
echo -e "\nGetting function logs..."
echo "Command: aws logs filter-log-events --log-group-name /aws/lambda/$FUNCTION_NAME"
echo "2024-01-20 10:30:00 START RequestId: 12345678-1234-1234-1234-123456789012"
echo "2024-01-20 10:30:00 Processing data: [10, 20, 30, 40, 50]"
echo "2024-01-20 10:30:00 Calculated average: 30.0"
echo "2024-01-20 10:30:00 END RequestId: 12345678-1234-1234-1234-123456789012"
echo "✅ Logs retrieved (simulated)"

echo -e "\n⚡ Lambda operations completed!"
EOF

chmod +x lambda_operations.sh
./lambda_operations.sh

cd ..
echo "✅ Exercise 4 complete: Lambda function operations"

# Exercise 5: Data Pipeline Automation
echo -e "\n🔄 Exercise 5: Data Pipeline Automation"
echo "Creating automated data pipeline workflows..."

mkdir -p exercise5-pipeline-automation
cd exercise5-pipeline-automation

# Create comprehensive data pipeline script
cat > data_pipeline.sh << 'EOF'
#!/bin/bash

# Automated Data Pipeline Script
# Orchestrates data processing workflow using AWS services

set -e

# Configuration
BUCKET_NAME="data-pipeline-bucket"
LAMBDA_FUNCTION="data-processor"
EC2_INSTANCE="i-1234567890abcdef0"
LOG_GROUP="/aws/lambda/data-processor"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "🔄 Automated Data Pipeline"
echo "========================="

# Step 1: Upload raw data
log_info "Step 1: Uploading raw data to S3..."
echo "Command: aws s3 sync ./raw-data/ s3://$BUCKET_NAME/raw/"

# Create sample raw data
mkdir -p raw-data
cat > raw-data/batch_001.json << 'DATA'
{
  "batch_id": "batch_001",
  "timestamp": "2024-01-20T10:00:00Z",
  "records": [
    {"id": 1, "value": 100, "category": "A"},
    {"id": 2, "value": 200, "category": "B"},
    {"id": 3, "value": 150, "category": "A"},
    {"id": 4, "value": 300, "category": "C"}
  ]
}
DATA

echo "✅ Raw data uploaded (simulated)"

# Step 2: Start processing instance if needed
log_info "Step 2: Checking EC2 instance status..."
echo "Command: aws ec2 describe-instances --instance-ids $EC2_INSTANCE"
echo "Instance status: stopped"

log_info "Starting EC2 instance..."
echo "Command: aws ec2 start-instances --instance-ids $EC2_INSTANCE"
echo "✅ Instance start initiated (simulated)"

log_info "Waiting for instance to be ready..."
echo "Command: aws ec2 wait instance-running --instance-ids $EC2_INSTANCE"
sleep 2  # Simulate wait time
echo "✅ Instance is running (simulated)"

# Step 3: Trigger Lambda processing
log_info "Step 3: Triggering Lambda function..."
echo "Command: aws lambda invoke \\"
echo "  --function-name $LAMBDA_FUNCTION \\"
echo "  --payload '{\"bucket\": \"$BUCKET_NAME\", \"input_prefix\": \"raw/\", \"output_prefix\": \"processed/\"}' \\"
echo "  lambda-response.json"

cat > lambda-response.json << 'RESPONSE'
{
    "statusCode": 200,
    "body": "{\"message\": \"Processing completed\", \"processed_files\": 1, \"output_location\": \"s3://data-pipeline-bucket/processed/\"}"
}
RESPONSE

echo "✅ Lambda function triggered (simulated)"

# Step 4: Monitor processing
log_info "Step 4: Monitoring processing progress..."
echo "Command: aws logs filter-log-events --log-group-name $LOG_GROUP --start-time $(date -d '5 minutes ago' +%s)000"
echo "Processing batch_001.json..."
echo "Records processed: 4"
echo "Output written to s3://data-pipeline-bucket/processed/batch_001_processed.json"
echo "✅ Processing completed (simulated)"

# Step 5: Validate output
log_info "Step 5: Validating processed data..."
echo "Command: aws s3 ls s3://$BUCKET_NAME/processed/"

mkdir -p processed
cat > processed/batch_001_processed.json << 'PROCESSED'
{
  "batch_id": "batch_001",
  "processed_timestamp": "2024-01-20T10:05:00Z",
  "summary": {
    "total_records": 4,
    "categories": {"A": 2, "B": 1, "C": 1},
    "total_value": 750,
    "average_value": 187.5
  },
  "status": "completed"
}
PROCESSED

echo "✅ Output validated (simulated)"

# Step 6: Cleanup
log_info "Step 6: Cleaning up resources..."
echo "Command: aws ec2 stop-instances --instance-ids $EC2_INSTANCE"
echo "✅ Instance stopped to save costs (simulated)"

log_info "Pipeline completed successfully! 🎉"

# Generate pipeline report
cat > pipeline_report.md << 'REPORT'
# Data Pipeline Execution Report

## Pipeline Run: 2024-01-20 10:00:00

### Steps Completed:
1. ✅ Raw data uploaded to S3
2. ✅ EC2 instance started
3. ✅ Lambda function triggered
4. ✅ Data processing completed
5. ✅ Output validated
6. ✅ Resources cleaned up

### Statistics:
- Files processed: 1
- Records processed: 4
- Processing time: ~5 minutes
- Estimated cost: $0.05

### Output Location:
s3://data-pipeline-bucket/processed/

### Next Steps:
- Review processed data
- Update downstream systems
- Schedule next batch
REPORT

echo "📊 Pipeline report generated: pipeline_report.md"
EOF

chmod +x data_pipeline.sh
./data_pipeline.sh

cd ..
echo "✅ Exercise 5 complete: Data pipeline automation"

# Exercise 6: Cost Monitoring and Optimization
echo -e "\n💰 Exercise 6: Cost Monitoring and Optimization"
echo "Learning AWS cost management..."

mkdir -p exercise6-cost-optimization
cd exercise6-cost-optimization

# Create cost monitoring script
cat > cost_monitor.sh << 'EOF'
#!/bin/bash

# AWS Cost Monitoring Script (Simulation)

echo "💰 AWS Cost Monitoring"
echo "====================="

# Simulate cost analysis
echo "Getting cost and usage data..."
echo "Command: aws ce get-cost-and-usage \\"
echo "  --time-period Start=2024-01-01,End=2024-01-31 \\"
echo "  --granularity MONTHLY \\"
echo "  --metrics BlendedCost"

cat << 'COSTS'
Service Costs (January 2024):
- EC2 Instances: $45.67
- S3 Storage: $12.34
- Lambda Functions: $3.21
- Data Transfer: $8.90
- CloudWatch: $2.15
Total: $72.27
COSTS

echo -e "\n✅ Cost data retrieved (simulated)"

# Simulate resource optimization
echo -e "\nIdentifying optimization opportunities..."
echo "Command: aws ec2 describe-instances --query 'Reservations[].Instances[?State.Name==\`stopped\`]'"

cat << 'OPTIMIZATION'
Optimization Opportunities:
1. 2 stopped EC2 instances still incurring EBS costs
2. 3 unattached EBS volumes ($15/month)
3. Old snapshots older than 90 days ($8/month)
4. Unused Elastic IPs ($3.65/month)

Potential Monthly Savings: $26.65
OPTIMIZATION

echo -e "\n💡 Optimization recommendations generated"

# Create cost alert simulation
echo -e "\nSetting up cost alerts..."
echo "Command: aws budgets create-budget --account-id 123456789012 --budget file://budget.json"

cat > budget.json << 'BUDGET'
{
  "BudgetName": "DataPipelineBudget",
  "BudgetLimit": {
    "Amount": "100.00",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
BUDGET

echo "✅ Budget alert configured (simulated)"

echo -e "\n💰 Cost monitoring completed!"
EOF

chmod +x cost_monitor.sh
./cost_monitor.sh

# Create resource cleanup script
cat > cleanup_resources.sh << 'EOF'
#!/bin/bash

# Resource Cleanup Script (Simulation)

echo "🧹 AWS Resource Cleanup"
echo "======================"

# Simulate finding unused resources
echo "Finding unused EBS volumes..."
echo "Command: aws ec2 describe-volumes --query 'Volumes[?State==\`available\`]'"
echo "Found 3 unattached volumes (vol-123, vol-456, vol-789)"

echo -e "\nFinding old snapshots..."
echo "Command: aws ec2 describe-snapshots --owner-ids self --query 'Snapshots[?StartTime<=\`2023-10-01\`]'"
echo "Found 5 snapshots older than 90 days"

echo -e "\nFinding unused Elastic IPs..."
echo "Command: aws ec2 describe-addresses --query 'Addresses[?!InstanceId]'"
echo "Found 1 unassociated Elastic IP"

# Simulate cleanup actions
echo -e "\nCleaning up resources..."
echo "Deleting unattached volumes... (simulated)"
echo "Deleting old snapshots... (simulated)"
echo "Releasing unused Elastic IPs... (simulated)"

echo -e "\n✅ Cleanup completed!"
echo "Estimated monthly savings: $26.65"
EOF

chmod +x cleanup_resources.sh
./cleanup_resources.sh

cd ..
echo "✅ Exercise 6 complete: Cost monitoring and optimization"

# Create summary report
echo -e "\n📊 Creating Exercise Summary Report"

cat > aws_cli_report.md << 'EOF'
# AWS CLI Exercise Report

## Completed Exercises

### 1. AWS CLI Setup and Configuration ✅
- AWS CLI installation verification
- Mock configuration files created
- Profile management understanding
- Command reference guide

### 2. S3 Operations Simulation ✅
- Bucket creation and management
- File upload and download operations
- Directory synchronization
- Object listing and metadata

### 3. EC2 Instance Management ✅
- Instance listing and status checking
- Start/stop operations
- Cost monitoring and optimization
- Instance health monitoring

### 4. Lambda Function Operations ✅
- Function creation and deployment
- Function invocation and testing
- Log monitoring and debugging
- Serverless data processing

### 5. Data Pipeline Automation ✅
- End-to-end pipeline orchestration
- Multi-service integration
- Error handling and monitoring
- Automated reporting

### 6. Cost Monitoring and Optimization ✅
- Cost analysis and reporting
- Resource optimization identification
- Budget alerts and monitoring
- Automated cleanup procedures

## Key Skills Developed

- **AWS CLI Configuration**: Profile management and authentication
- **S3 Data Operations**: Scalable storage for data pipelines
- **EC2 Management**: Compute resources for data processing
- **Lambda Functions**: Serverless data processing
- **Pipeline Automation**: End-to-end workflow orchestration
- **Cost Optimization**: Resource monitoring and cleanup

## Real-World Applications

1. **Data Lake Management**: Use S3 for storing raw and processed data
2. **Batch Processing**: EC2 instances for large-scale data processing
3. **Real-time Processing**: Lambda functions for event-driven processing
4. **Cost Control**: Regular monitoring and optimization
5. **Infrastructure as Code**: Automated resource provisioning
6. **Monitoring and Alerting**: CloudWatch integration

## Next Steps

1. Set up real AWS account and credentials
2. Practice with actual AWS resources (free tier)
3. Implement infrastructure as code with CloudFormation
4. Integrate AWS CLI into CI/CD pipelines
5. Explore advanced services (EMR, Glue, Redshift)
6. Implement comprehensive monitoring and alerting

## Security Reminders

- Never commit AWS credentials to version control
- Use IAM roles instead of access keys when possible
- Implement least privilege access principles
- Regularly rotate access keys
- Enable CloudTrail for audit logging
- Use encryption for sensitive data
EOF

echo "✅ Summary report created: aws_cli_report.md"

echo -e "\n🎉 All Day 26 exercises completed!"
echo "You've practiced:"
echo "- AWS CLI setup and configuration"
echo "- S3 data storage and transfer operations"
echo "- EC2 instance management and monitoring"
echo "- Lambda serverless function operations"
echo "- End-to-end data pipeline automation"
echo "- Cost monitoring and resource optimization"
echo ""
echo "Next: Day 27 - Debugging and profiling tools"
