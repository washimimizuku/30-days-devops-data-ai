# Day 26: AWS CLI - Cloud Operations

**Duration**: 1 hour  
**Prerequisites**: Basic cloud concepts, command line usage  
**Learning Goal**: Master AWS CLI for data pipeline cloud operations and resource management

## Overview

AWS CLI is essential for data engineers working with cloud infrastructure. You'll learn to manage S3 storage, EC2 instances, Lambda functions, and other AWS services from the command line for automated data pipelines.

## Why AWS CLI Matters

**Data pipeline use cases**:
- Upload/download datasets to/from S3
- Manage EC2 instances for data processing
- Deploy Lambda functions for serverless processing
- Configure IAM roles and permissions
- Monitor CloudWatch logs and metrics
- Automate infrastructure with scripts

**Benefits of CLI over console**:
- Scriptable and automatable
- Version controllable configurations
- Faster for repetitive tasks
- CI/CD pipeline integration
- Consistent across environments

## Installation and Setup

### Install AWS CLI

```bash
# macOS
brew install awscli

# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Windows
# Download and run AWS CLI MSI installer

# Verify installation
aws --version
```

### Configuration

```bash
# Configure with access keys
aws configure
# AWS Access Key ID: YOUR_ACCESS_KEY
# AWS Secret Access Key: YOUR_SECRET_KEY
# Default region: us-east-1
# Default output format: json

# Configure specific profile
aws configure --profile data-pipeline
aws configure --profile production

# List configurations
aws configure list
aws configure list --profile data-pipeline
```

### Configuration Files

```bash
# ~/.aws/credentials
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY

[data-pipeline]
aws_access_key_id = PIPELINE_ACCESS_KEY
aws_secret_access_key = PIPELINE_SECRET_KEY

# ~/.aws/config
[default]
region = us-east-1
output = json

[profile data-pipeline]
region = us-west-2
output = table
```

## Core AWS Services for Data

### S3 - Object Storage

```bash
# List buckets
aws s3 ls

# Create bucket
aws s3 mb s3://my-data-bucket

# List objects in bucket
aws s3 ls s3://my-data-bucket/
aws s3 ls s3://my-data-bucket/datasets/ --recursive

# Upload files
aws s3 cp data.csv s3://my-data-bucket/
aws s3 cp ./datasets/ s3://my-data-bucket/datasets/ --recursive

# Download files
aws s3 cp s3://my-data-bucket/data.csv ./
aws s3 sync s3://my-data-bucket/datasets/ ./local-datasets/

# Delete objects
aws s3 rm s3://my-data-bucket/data.csv
aws s3 rm s3://my-data-bucket/datasets/ --recursive
```

### Advanced S3 Operations

```bash
# Sync with delete (mirror)
aws s3 sync ./local-data/ s3://my-data-bucket/data/ --delete

# Copy between buckets
aws s3 cp s3://source-bucket/data.csv s3://dest-bucket/

# Set storage class
aws s3 cp data.csv s3://my-data-bucket/ --storage-class GLACIER

# Multipart upload for large files
aws s3 cp large-dataset.zip s3://my-data-bucket/ --cli-write-timeout 0

# Presigned URLs
aws s3 presign s3://my-data-bucket/data.csv --expires-in 3600
```

### EC2 - Compute Instances

```bash
# List instances
aws ec2 describe-instances
aws ec2 describe-instances --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name,Type:InstanceType}'

# Launch instance
aws ec2 run-instances \
  --image-id ami-0abcdef1234567890 \
  --instance-type t3.medium \
  --key-name my-key-pair \
  --security-group-ids sg-12345678 \
  --subnet-id subnet-12345678 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=data-processor}]'

# Start/stop instances
aws ec2 start-instances --instance-ids i-1234567890abcdef0
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Terminate instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
```

### Lambda - Serverless Functions

```bash
# List functions
aws lambda list-functions

# Create function
aws lambda create-function \
  --function-name data-processor \
  --runtime python3.9 \
  --role arn:aws:iam::123456789012:role/lambda-execution-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip

# Update function code
aws lambda update-function-code \
  --function-name data-processor \
  --zip-file fileb://updated-function.zip

# Invoke function
aws lambda invoke \
  --function-name data-processor \
  --payload '{"key": "value"}' \
  response.json

# Get function logs
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/data-processor
```

## Data Pipeline Operations

### S3 Data Management

```bash
# Upload dataset with metadata
aws s3api put-object \
  --bucket my-data-bucket \
  --key datasets/customer-data.csv \
  --body customer-data.csv \
  --metadata dataset-type=training,version=1.0,created-by=data-team

# Get object metadata
aws s3api head-object \
  --bucket my-data-bucket \
  --key datasets/customer-data.csv

# Set lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket my-data-bucket \
  --lifecycle-configuration file://lifecycle.json

# lifecycle.json
{
  "Rules": [
    {
      "ID": "ArchiveOldData",
      "Status": "Enabled",
      "Filter": {"Prefix": "datasets/"},
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
```

### IAM - Identity and Access Management

```bash
# List users and roles
aws iam list-users
aws iam list-roles

# Create role for data pipeline
aws iam create-role \
  --role-name DataPipelineRole \
  --assume-role-policy-document file://trust-policy.json

# Attach policy to role
aws iam attach-role-policy \
  --role-name DataPipelineRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Create custom policy
aws iam create-policy \
  --policy-name DataPipelinePolicy \
  --policy-document file://data-pipeline-policy.json
```

### CloudWatch - Monitoring and Logs

```bash
# List log groups
aws logs describe-log-groups

# Get log events
aws logs filter-log-events \
  --log-group-name /aws/lambda/data-processor \
  --start-time 1640995200000

# Create custom metric
aws cloudwatch put-metric-data \
  --namespace "DataPipeline" \
  --metric-data MetricName=ProcessedRecords,Value=1000,Unit=Count

# List metrics
aws cloudwatch list-metrics --namespace "DataPipeline"
```

## Automation and Scripting

### Batch Operations

```bash
#!/bin/bash
# batch_s3_operations.sh

BUCKET="my-data-bucket"
LOCAL_DIR="./datasets"

# Upload all CSV files
for file in "$LOCAL_DIR"/*.csv; do
  filename=$(basename "$file")
  echo "Uploading $filename..."
  aws s3 cp "$file" "s3://$BUCKET/datasets/$filename"
done

# Set permissions
aws s3api put-bucket-acl --bucket "$BUCKET" --acl private

echo "Batch upload completed"
```

### Infrastructure as Code

```bash
# Deploy CloudFormation stack
aws cloudformation create-stack \
  --stack-name data-pipeline-infrastructure \
  --template-body file://infrastructure.yaml \
  --parameters ParameterKey=Environment,ParameterValue=production \
  --capabilities CAPABILITY_IAM

# Update stack
aws cloudformation update-stack \
  --stack-name data-pipeline-infrastructure \
  --template-body file://infrastructure.yaml

# Delete stack
aws cloudformation delete-stack \
  --stack-name data-pipeline-infrastructure
```

### Data Processing Workflows

```bash
#!/bin/bash
# data_processing_workflow.sh

set -e

BUCKET="data-processing-bucket"
INSTANCE_ID="i-1234567890abcdef0"

echo "Starting data processing workflow..."

# 1. Upload raw data
echo "Uploading raw data..."
aws s3 sync ./raw-data/ "s3://$BUCKET/raw/"

# 2. Start processing instance
echo "Starting EC2 instance..."
aws ec2 start-instances --instance-ids "$INSTANCE_ID"

# Wait for instance to be running
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
echo "Instance is running"

# 3. Trigger processing Lambda
echo "Triggering data processing..."
aws lambda invoke \
  --function-name data-processor \
  --payload '{"bucket": "'$BUCKET'", "input_prefix": "raw/", "output_prefix": "processed/"}' \
  processing-result.json

# 4. Wait for processing to complete (check S3 for output)
echo "Waiting for processing to complete..."
while ! aws s3 ls "s3://$BUCKET/processed/" > /dev/null 2>&1; do
  echo "Still processing..."
  sleep 30
done

# 5. Download processed data
echo "Downloading processed data..."
aws s3 sync "s3://$BUCKET/processed/" ./processed-data/

# 6. Stop instance to save costs
echo "Stopping EC2 instance..."
aws ec2 stop-instances --instance-ids "$INSTANCE_ID"

echo "Workflow completed successfully"
```

## Advanced Features

### Query and Filtering

```bash
# JMESPath queries
aws ec2 describe-instances \
  --query 'Reservations[].Instances[?State.Name==`running`].{ID:InstanceId,Name:Tags[?Key==`Name`].Value|[0]}'

# Filter S3 objects by date
aws s3api list-objects-v2 \
  --bucket my-data-bucket \
  --query 'Contents[?LastModified>=`2024-01-01`].{Key:Key,Size:Size,Modified:LastModified}'

# Get largest files in bucket
aws s3api list-objects-v2 \
  --bucket my-data-bucket \
  --query 'reverse(sort_by(Contents, &Size))[:5].{Key:Key,Size:Size}'
```

### Profiles and Regions

```bash
# Use specific profile
aws s3 ls --profile production

# Use specific region
aws ec2 describe-instances --region us-west-2

# Set session defaults
export AWS_PROFILE=data-pipeline
export AWS_DEFAULT_REGION=us-west-2
```

### Output Formats

```bash
# JSON output (default)
aws s3 ls --output json

# Table format
aws ec2 describe-instances --output table

# Text format for scripting
aws s3 ls --output text | awk '{print $4}'

# YAML format
aws cloudformation describe-stacks --output yaml
```

## Security Best Practices

### Credentials Management

```bash
# Use IAM roles instead of access keys when possible
aws sts assume-role \
  --role-arn arn:aws:iam::123456789012:role/DataPipelineRole \
  --role-session-name data-processing-session

# Rotate access keys regularly
aws iam create-access-key --user-name data-pipeline-user
aws iam delete-access-key --user-name data-pipeline-user --access-key-id OLD_KEY

# Use temporary credentials
aws sts get-session-token --duration-seconds 3600
```

### Encryption

```bash
# S3 server-side encryption
aws s3 cp data.csv s3://my-bucket/ --sse AES256

# KMS encryption
aws s3 cp data.csv s3://my-bucket/ --sse aws:kms --sse-kms-key-id alias/my-key

# Client-side encryption
aws s3 cp data.csv s3://my-bucket/ --sse-c AES256 --sse-c-key $(openssl rand -base64 32)
```

## Troubleshooting

### Common Issues

```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify permissions
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::123456789012:user/data-engineer \
  --action-names s3:GetObject \
  --resource-arns arn:aws:s3:::my-bucket/data.csv

# Debug with verbose output
aws s3 ls --debug

# Check service status
aws health describe-events --filter services=S3
```

### Error Handling in Scripts

```bash
#!/bin/bash
# error_handling_example.sh

set -e  # Exit on error

# Function to handle AWS CLI errors
handle_aws_error() {
  local exit_code=$1
  local command=$2
  
  case $exit_code in
    254)
      echo "Error: AWS CLI not found or not configured"
      ;;
    255)
      echo "Error: AWS CLI command failed: $command"
      ;;
    *)
      echo "Error: Command failed with exit code $exit_code"
      ;;
  esac
  
  exit $exit_code
}

# Example with error handling
if ! aws s3 ls s3://my-bucket/ > /dev/null 2>&1; then
  handle_aws_error $? "s3 ls"
fi

echo "Bucket exists and is accessible"
```

## Cost Optimization

### Monitoring Usage

```bash
# Get billing information
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost

# List unused resources
aws ec2 describe-instances \
  --query 'Reservations[].Instances[?State.Name==`stopped`].{ID:InstanceId,Type:InstanceType}'

# Find unattached EBS volumes
aws ec2 describe-volumes \
  --query 'Volumes[?State==`available`].{ID:VolumeId,Size:Size}'
```

### Resource Cleanup

```bash
#!/bin/bash
# cleanup_resources.sh

echo "Cleaning up unused AWS resources..."

# Delete old snapshots (older than 30 days)
aws ec2 describe-snapshots --owner-ids self \
  --query 'Snapshots[?StartTime<=`2024-01-01`].SnapshotId' \
  --output text | xargs -n1 aws ec2 delete-snapshot --snapshot-id

# Stop idle instances
aws ec2 describe-instances \
  --query 'Reservations[].Instances[?State.Name==`running`].InstanceId' \
  --output text | xargs -n1 aws ec2 stop-instances --instance-ids

echo "Cleanup completed"
```

## Summary

AWS CLI is essential for data engineers working with cloud infrastructure. It enables automation, scripting, and efficient resource management for data pipelines.

**Key takeaways**:
- Configure profiles for different environments
- Use S3 for scalable data storage and transfer
- Automate infrastructure with scripts and CloudFormation
- Implement proper security and access controls
- Monitor costs and optimize resource usage
- Handle errors gracefully in automation scripts

**Next**: Day 27 will cover debugging and profiling tools for data applications.
