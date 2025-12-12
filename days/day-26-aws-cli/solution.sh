#!/bin/bash

# Day 26: AWS CLI Solutions
# Advanced patterns and production-ready implementations

set -e

echo "☁️ Day 26: AWS CLI Solutions"
echo "============================"

# Solution 1: Production Data Pipeline with AWS CLI
echo -e "\n🏭 Solution 1: Production Data Pipeline"

mkdir -p solution1-production-pipeline
cd solution1-production-pipeline

# Create comprehensive pipeline orchestrator
cat > pipeline_orchestrator.sh << 'EOF'
#!/bin/bash

# Production Data Pipeline Orchestrator
# Handles data ingestion, processing, and delivery with full error handling

set -e

# Configuration
CONFIG_FILE="${CONFIG_FILE:-pipeline_config.json}"
LOG_FILE="${LOG_FILE:-pipeline_$(date +%Y%m%d_%H%M%S).log}"
DRY_RUN="${DRY_RUN:-false}"

# Colors and logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        INFO)  echo -e "${GREEN}[INFO]${NC} $message" | tee -a "$LOG_FILE" ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} $message" | tee -a "$LOG_FILE" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} $message" | tee -a "$LOG_FILE" ;;
        DEBUG) echo -e "${BLUE}[DEBUG]${NC} $message" | tee -a "$LOG_FILE" ;;
    esac
}

# Load configuration
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log ERROR "Configuration file $CONFIG_FILE not found"
        exit 1
    fi
    
    BUCKET_RAW=$(jq -r '.buckets.raw' "$CONFIG_FILE")
    BUCKET_PROCESSED=$(jq -r '.buckets.processed' "$CONFIG_FILE")
    BUCKET_ARCHIVE=$(jq -r '.buckets.archive' "$CONFIG_FILE")
    LAMBDA_FUNCTION=$(jq -r '.lambda.function_name' "$CONFIG_FILE")
    SNS_TOPIC=$(jq -r '.notifications.sns_topic' "$CONFIG_FILE")
    
    log INFO "Configuration loaded from $CONFIG_FILE"
}

# AWS CLI wrapper with retry logic
aws_retry() {
    local max_attempts=3
    local delay=5
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if [[ "$DRY_RUN" == "true" ]]; then
            log DEBUG "DRY RUN: aws $*"
            return 0
        fi
        
        if aws "$@"; then
            return 0
        else
            local exit_code=$?
            log WARN "AWS command failed (attempt $attempt/$max_attempts): aws $*"
            
            if [[ $attempt -eq $max_attempts ]]; then
                log ERROR "AWS command failed after $max_attempts attempts"
                return $exit_code
            fi
            
            log INFO "Retrying in ${delay}s..."
            sleep $delay
            ((attempt++))
        fi
    done
}

# Data validation
validate_data() {
    local file_path=$1
    local file_type=$2
    
    log INFO "Validating $file_path as $file_type"
    
    case $file_type in
        "json")
            if jq empty "$file_path" 2>/dev/null; then
                log INFO "✅ Valid JSON file"
                return 0
            else
                log ERROR "❌ Invalid JSON file"
                return 1
            fi
            ;;
        "csv")
            if [[ $(head -1 "$file_path" | grep -c ",") -gt 0 ]]; then
                log INFO "✅ Valid CSV file"
                return 0
            else
                log ERROR "❌ Invalid CSV file"
                return 1
            fi
            ;;
        *)
            log WARN "Unknown file type: $file_type"
            return 0
            ;;
    esac
}

# Upload data with validation
upload_data() {
    local local_path=$1
    local s3_path=$2
    local file_type=$3
    
    log INFO "Uploading $local_path to $s3_path"
    
    # Validate before upload
    if ! validate_data "$local_path" "$file_type"; then
        log ERROR "Data validation failed for $local_path"
        return 1
    fi
    
    # Upload with metadata
    aws_retry s3 cp "$local_path" "$s3_path" \
        --metadata "upload-timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ),file-type=$file_type,pipeline-version=1.0"
    
    log INFO "✅ Upload completed: $s3_path"
}

# Process data with Lambda
process_data() {
    local input_prefix=$1
    local output_prefix=$2
    
    log INFO "Triggering data processing: $input_prefix -> $output_prefix"
    
    local payload=$(jq -n \
        --arg bucket_raw "$BUCKET_RAW" \
        --arg bucket_processed "$BUCKET_PROCESSED" \
        --arg input_prefix "$input_prefix" \
        --arg output_prefix "$output_prefix" \
        '{
            bucket_raw: $bucket_raw,
            bucket_processed: $bucket_processed,
            input_prefix: $input_prefix,
            output_prefix: $output_prefix,
            timestamp: now | strftime("%Y-%m-%dT%H:%M:%SZ")
        }')
    
    local response_file="lambda_response_$(date +%s).json"
    
    if aws_retry lambda invoke \
        --function-name "$LAMBDA_FUNCTION" \
        --payload "$payload" \
        "$response_file"; then
        
        local status_code=$(jq -r '.StatusCode' "$response_file" 2>/dev/null || echo "unknown")
        
        if [[ "$status_code" == "200" ]]; then
            log INFO "✅ Lambda processing completed successfully"
            return 0
        else
            log ERROR "❌ Lambda processing failed with status: $status_code"
            return 1
        fi
    else
        log ERROR "❌ Failed to invoke Lambda function"
        return 1
    fi
}

# Monitor processing status
monitor_processing() {
    local output_prefix=$1
    local timeout=${2:-300}  # 5 minutes default
    local start_time=$(date +%s)
    
    log INFO "Monitoring processing status for $output_prefix (timeout: ${timeout}s)"
    
    while true; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        
        if [[ $elapsed -gt $timeout ]]; then
            log ERROR "❌ Processing timeout after ${timeout}s"
            return 1
        fi
        
        # Check if output files exist
        if aws_retry s3 ls "s3://$BUCKET_PROCESSED/$output_prefix" --recursive | grep -q "."; then
            log INFO "✅ Processing completed (${elapsed}s)"
            return 0
        fi
        
        log DEBUG "Still processing... (${elapsed}s elapsed)"
        sleep 10
    done
}

# Archive processed data
archive_data() {
    local processed_prefix=$1
    local archive_prefix=$2
    
    log INFO "Archiving processed data: $processed_prefix -> $archive_prefix"
    
    aws_retry s3 sync "s3://$BUCKET_PROCESSED/$processed_prefix" "s3://$BUCKET_ARCHIVE/$archive_prefix" \
        --storage-class GLACIER
    
    log INFO "✅ Data archived to Glacier storage"
}

# Send notifications
send_notification() {
    local status=$1
    local message=$2
    
    log INFO "Sending notification: $status"
    
    local notification_payload=$(jq -n \
        --arg status "$status" \
        --arg message "$message" \
        --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            status: $status,
            message: $message,
            timestamp: $timestamp,
            pipeline: "data-processing-pipeline"
        }')
    
    aws_retry sns publish \
        --topic-arn "$SNS_TOPIC" \
        --message "$notification_payload" \
        --subject "Pipeline Status: $status"
    
    log INFO "✅ Notification sent"
}

# Main pipeline execution
main() {
    local batch_id=${1:-"batch_$(date +%Y%m%d_%H%M%S)"}
    
    log INFO "Starting data pipeline execution for batch: $batch_id"
    
    # Load configuration
    load_config
    
    # Create batch directories
    local raw_prefix="raw/$batch_id"
    local processed_prefix="processed/$batch_id"
    local archive_prefix="archive/$(date +%Y/%m/%d)/$batch_id"
    
    # Pipeline steps
    local step=1
    local total_steps=6
    
    # Step 1: Upload raw data
    log INFO "Step $((step++))/$total_steps: Uploading raw data"
    if [[ -d "./raw_data" ]]; then
        for file in ./raw_data/*; do
            if [[ -f "$file" ]]; then
                local filename=$(basename "$file")
                local extension="${filename##*.}"
                upload_data "$file" "s3://$BUCKET_RAW/$raw_prefix/$filename" "$extension"
            fi
        done
    else
        log WARN "No raw_data directory found, skipping upload"
    fi
    
    # Step 2: Process data
    log INFO "Step $((step++))/$total_steps: Processing data"
    if ! process_data "$raw_prefix" "$processed_prefix"; then
        send_notification "FAILED" "Data processing failed for batch $batch_id"
        exit 1
    fi
    
    # Step 3: Monitor processing
    log INFO "Step $((step++))/$total_steps: Monitoring processing"
    if ! monitor_processing "$processed_prefix"; then
        send_notification "FAILED" "Processing timeout for batch $batch_id"
        exit 1
    fi
    
    # Step 4: Validate output
    log INFO "Step $((step++))/$total_steps: Validating output"
    local output_count=$(aws_retry s3 ls "s3://$BUCKET_PROCESSED/$processed_prefix" --recursive | wc -l)
    log INFO "Found $output_count processed files"
    
    # Step 5: Archive data
    log INFO "Step $((step++))/$total_steps: Archiving data"
    archive_data "$processed_prefix" "$archive_prefix"
    
    # Step 6: Send success notification
    log INFO "Step $((step++))/$total_steps: Sending notification"
    send_notification "SUCCESS" "Pipeline completed successfully for batch $batch_id"
    
    log INFO "🎉 Pipeline execution completed successfully!"
    
    # Generate summary report
    cat > "pipeline_report_$batch_id.json" << EOF
{
    "batch_id": "$batch_id",
    "status": "SUCCESS",
    "start_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "raw_prefix": "$raw_prefix",
    "processed_prefix": "$processed_prefix",
    "archive_prefix": "$archive_prefix",
    "output_files": $output_count,
    "log_file": "$LOG_FILE"
}
EOF
    
    log INFO "📊 Pipeline report generated: pipeline_report_$batch_id.json"
}

# Error handling
trap 'log ERROR "Pipeline failed with exit code $?"; send_notification "FAILED" "Pipeline execution failed"; exit 1' ERR

# Execute main function
main "$@"
EOF

# Create configuration file
cat > pipeline_config.json << 'EOF'
{
    "buckets": {
        "raw": "data-pipeline-raw",
        "processed": "data-pipeline-processed",
        "archive": "data-pipeline-archive"
    },
    "lambda": {
        "function_name": "data-processor",
        "timeout": 300,
        "memory": 1024
    },
    "notifications": {
        "sns_topic": "arn:aws:sns:us-east-1:123456789012:pipeline-notifications"
    },
    "monitoring": {
        "cloudwatch_log_group": "/aws/lambda/data-processor",
        "metrics_namespace": "DataPipeline"
    }
}
EOF

chmod +x pipeline_orchestrator.sh

cd ..
echo "✅ Solution 1: Production data pipeline orchestrator"

# Solution 2: Advanced S3 Data Management
echo -e "\n📦 Solution 2: Advanced S3 Data Management"

mkdir -p solution2-s3-management
cd solution2-s3-management

# Create S3 data lifecycle manager
cat > s3_lifecycle_manager.py << 'EOF'
#!/usr/bin/env python3
"""
Advanced S3 Data Lifecycle Manager
Handles intelligent data tiering, cleanup, and optimization
"""

import boto3
import json
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Any
import argparse

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class S3LifecycleManager:
    def __init__(self, profile_name: str = None):
        session = boto3.Session(profile_name=profile_name)
        self.s3_client = session.client('s3')
        self.s3_resource = session.resource('s3')
        
    def analyze_bucket_usage(self, bucket_name: str) -> Dict[str, Any]:
        """Analyze bucket usage patterns and costs"""
        logger.info(f"Analyzing bucket usage: {bucket_name}")
        
        bucket = self.s3_resource.Bucket(bucket_name)
        
        analysis = {
            'bucket_name': bucket_name,
            'total_objects': 0,
            'total_size': 0,
            'storage_classes': {},
            'age_distribution': {
                '0-30_days': 0,
                '30-90_days': 0,
                '90-365_days': 0,
                '365+_days': 0
            },
            'file_types': {},
            'recommendations': []
        }
        
        now = datetime.now(datetime.now().astimezone().tzinfo)
        
        for obj in bucket.objects.all():
            analysis['total_objects'] += 1
            analysis['total_size'] += obj.size
            
            # Storage class analysis
            storage_class = obj.storage_class or 'STANDARD'
            analysis['storage_classes'][storage_class] = \
                analysis['storage_classes'].get(storage_class, 0) + 1
            
            # Age analysis
            age_days = (now - obj.last_modified).days
            if age_days <= 30:
                analysis['age_distribution']['0-30_days'] += 1
            elif age_days <= 90:
                analysis['age_distribution']['30-90_days'] += 1
            elif age_days <= 365:
                analysis['age_distribution']['90-365_days'] += 1
            else:
                analysis['age_distribution']['365+_days'] += 1
            
            # File type analysis
            file_ext = obj.key.split('.')[-1].lower() if '.' in obj.key else 'no_extension'
            analysis['file_types'][file_ext] = \
                analysis['file_types'].get(file_ext, 0) + 1
        
        # Generate recommendations
        self._generate_recommendations(analysis)
        
        return analysis
    
    def _generate_recommendations(self, analysis: Dict[str, Any]):
        """Generate optimization recommendations"""
        recommendations = []
        
        # Storage class recommendations
        old_objects = analysis['age_distribution']['90-365_days'] + \
                     analysis['age_distribution']['365+_days']
        
        if old_objects > 0:
            recommendations.append({
                'type': 'storage_optimization',
                'description': f'Consider moving {old_objects} old objects to IA or Glacier',
                'potential_savings': f'~{old_objects * 0.0125:.2f} USD/month'
            })
        
        # Lifecycle policy recommendation
        if analysis['total_objects'] > 1000:
            recommendations.append({
                'type': 'lifecycle_policy',
                'description': 'Implement automated lifecycle policies',
                'benefit': 'Automatic cost optimization'
            })
        
        analysis['recommendations'] = recommendations
    
    def create_lifecycle_policy(self, bucket_name: str, rules: List[Dict]) -> bool:
        """Create or update bucket lifecycle policy"""
        logger.info(f"Creating lifecycle policy for {bucket_name}")
        
        try:
            lifecycle_config = {'Rules': rules}
            
            self.s3_client.put_bucket_lifecycle_configuration(
                Bucket=bucket_name,
                LifecycleConfiguration=lifecycle_config
            )
            
            logger.info("✅ Lifecycle policy created successfully")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to create lifecycle policy: {e}")
            return False
    
    def optimize_bucket_costs(self, bucket_name: str, dry_run: bool = True) -> Dict[str, Any]:
        """Optimize bucket costs through intelligent tiering"""
        logger.info(f"Optimizing costs for bucket: {bucket_name} (dry_run: {dry_run})")
        
        optimization_results = {
            'bucket_name': bucket_name,
            'actions_taken': [],
            'estimated_savings': 0.0,
            'dry_run': dry_run
        }
        
        # Standard lifecycle rules for data pipelines
        lifecycle_rules = [
            {
                'ID': 'DataPipelineOptimization',
                'Status': 'Enabled',
                'Filter': {'Prefix': ''},
                'Transitions': [
                    {
                        'Days': 30,
                        'StorageClass': 'STANDARD_IA'
                    },
                    {
                        'Days': 90,
                        'StorageClass': 'GLACIER'
                    },
                    {
                        'Days': 365,
                        'StorageClass': 'DEEP_ARCHIVE'
                    }
                ],
                'AbortIncompleteMultipartUpload': {
                    'DaysAfterInitiation': 7
                }
            },
            {
                'ID': 'TempDataCleanup',
                'Status': 'Enabled',
                'Filter': {'Prefix': 'temp/'},
                'Expiration': {'Days': 7}
            }
        ]
        
        if not dry_run:
            if self.create_lifecycle_policy(bucket_name, lifecycle_rules):
                optimization_results['actions_taken'].append('lifecycle_policy_created')
        else:
            optimization_results['actions_taken'].append('lifecycle_policy_planned')
        
        return optimization_results
    
    def generate_cost_report(self, bucket_name: str) -> str:
        """Generate detailed cost analysis report"""
        analysis = self.analyze_bucket_usage(bucket_name)
        
        report = f"""
# S3 Bucket Cost Analysis Report

## Bucket: {bucket_name}
**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Summary
- **Total Objects:** {analysis['total_objects']:,}
- **Total Size:** {analysis['total_size'] / (1024**3):.2f} GB
- **Estimated Monthly Cost:** ${analysis['total_size'] * 0.023 / (1024**3):.2f}

## Storage Class Distribution
"""
        
        for storage_class, count in analysis['storage_classes'].items():
            percentage = (count / analysis['total_objects']) * 100
            report += f"- **{storage_class}:** {count:,} objects ({percentage:.1f}%)\n"
        
        report += "\n## Age Distribution\n"
        for age_range, count in analysis['age_distribution'].items():
            percentage = (count / analysis['total_objects']) * 100
            report += f"- **{age_range}:** {count:,} objects ({percentage:.1f}%)\n"
        
        report += "\n## Optimization Recommendations\n"
        for rec in analysis['recommendations']:
            report += f"- **{rec['type'].title()}:** {rec['description']}\n"
        
        return report

def main():
    parser = argparse.ArgumentParser(description='S3 Lifecycle Manager')
    parser.add_argument('--bucket', required=True, help='S3 bucket name')
    parser.add_argument('--profile', help='AWS profile name')
    parser.add_argument('--action', choices=['analyze', 'optimize', 'report'], 
                       default='analyze', help='Action to perform')
    parser.add_argument('--dry-run', action='store_true', help='Dry run mode')
    
    args = parser.parse_args()
    
    manager = S3LifecycleManager(args.profile)
    
    if args.action == 'analyze':
        analysis = manager.analyze_bucket_usage(args.bucket)
        print(json.dumps(analysis, indent=2, default=str))
    
    elif args.action == 'optimize':
        results = manager.optimize_bucket_costs(args.bucket, args.dry_run)
        print(json.dumps(results, indent=2))
    
    elif args.action == 'report':
        report = manager.generate_cost_report(args.bucket)
        with open(f's3_cost_report_{args.bucket}.md', 'w') as f:
            f.write(report)
        print(f"Report saved to s3_cost_report_{args.bucket}.md")

if __name__ == '__main__':
    main()
EOF

chmod +x s3_lifecycle_manager.py

cd ..
echo "✅ Solution 2: Advanced S3 data lifecycle management"

# Solution 3: Infrastructure as Code with AWS CLI
echo -e "\n🏗️ Solution 3: Infrastructure as Code"

mkdir -p solution3-infrastructure-as-code
cd solution3-infrastructure-as-code

# Create CloudFormation deployment manager
cat > deploy_infrastructure.sh << 'EOF'
#!/bin/bash

# Infrastructure as Code Deployment Manager
# Manages CloudFormation stacks for data pipeline infrastructure

set -e

# Configuration
STACK_PREFIX="data-pipeline"
TEMPLATE_DIR="./templates"
PARAMETERS_DIR="./parameters"
ENVIRONMENT="${ENVIRONMENT:-dev}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Deploy stack function
deploy_stack() {
    local stack_name=$1
    local template_file=$2
    local parameters_file=$3
    
    log_info "Deploying stack: $stack_name"
    
    # Check if stack exists
    if aws cloudformation describe-stacks --stack-name "$stack_name" &>/dev/null; then
        log_info "Stack exists, updating..."
        aws cloudformation update-stack \
            --stack-name "$stack_name" \
            --template-body "file://$template_file" \
            --parameters "file://$parameters_file" \
            --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
        
        aws cloudformation wait stack-update-complete --stack-name "$stack_name"
        log_info "✅ Stack updated successfully"
    else
        log_info "Creating new stack..."
        aws cloudformation create-stack \
            --stack-name "$stack_name" \
            --template-body "file://$template_file" \
            --parameters "file://$parameters_file" \
            --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
        
        aws cloudformation wait stack-create-complete --stack-name "$stack_name"
        log_info "✅ Stack created successfully"
    fi
}

# Main deployment
main() {
    local component=${1:-"all"}
    
    log_info "Deploying infrastructure for environment: $ENVIRONMENT"
    
    case $component in
        "storage"|"all")
            deploy_stack \
                "$STACK_PREFIX-storage-$ENVIRONMENT" \
                "$TEMPLATE_DIR/storage.yaml" \
                "$PARAMETERS_DIR/storage-$ENVIRONMENT.json"
            ;;
    esac
    
    case $component in
        "compute"|"all")
            deploy_stack \
                "$STACK_PREFIX-compute-$ENVIRONMENT" \
                "$TEMPLATE_DIR/compute.yaml" \
                "$PARAMETERS_DIR/compute-$ENVIRONMENT.json"
            ;;
    esac
    
    case $component in
        "monitoring"|"all")
            deploy_stack \
                "$STACK_PREFIX-monitoring-$ENVIRONMENT" \
                "$TEMPLATE_DIR/monitoring.yaml" \
                "$PARAMETERS_DIR/monitoring-$ENVIRONMENT.json"
            ;;
    esac
    
    log_info "🎉 Infrastructure deployment completed!"
}

main "$@"
EOF

# Create sample CloudFormation templates
mkdir -p templates parameters

cat > templates/storage.yaml << 'EOF'
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Data Pipeline Storage Infrastructure'

Parameters:
  Environment:
    Type: String
    Default: dev
    AllowedValues: [dev, staging, prod]
  
  DataRetentionDays:
    Type: Number
    Default: 90

Resources:
  # S3 Buckets
  RawDataBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-raw-${AWS::AccountId}'
      VersioningConfiguration:
        Status: Enabled
      LifecycleConfiguration:
        Rules:
          - Id: DataLifecycle
            Status: Enabled
            Transitions:
              - TransitionInDays: 30
                StorageClass: STANDARD_IA
              - TransitionInDays: 90
                StorageClass: GLACIER
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true

  ProcessedDataBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-processed-${AWS::AccountId}'
      VersioningConfiguration:
        Status: Enabled

Outputs:
  RawDataBucketName:
    Description: 'Raw data bucket name'
    Value: !Ref RawDataBucket
    Export:
      Name: !Sub '${AWS::StackName}-RawDataBucket'
  
  ProcessedDataBucketName:
    Description: 'Processed data bucket name'
    Value: !Ref ProcessedDataBucket
    Export:
      Name: !Sub '${AWS::StackName}-ProcessedDataBucket'
EOF

cat > parameters/storage-dev.json << 'EOF'
[
  {
    "ParameterKey": "Environment",
    "ParameterValue": "dev"
  },
  {
    "ParameterKey": "DataRetentionDays",
    "ParameterValue": "30"
  }
]
EOF

chmod +x deploy_infrastructure.sh

cd ..
echo "✅ Solution 3: Infrastructure as Code deployment manager"

echo -e "\n🎉 All Day 26 solutions completed!"
echo ""
echo "Solutions demonstrated:"
echo "1. Production data pipeline orchestrator with comprehensive error handling"
echo "2. Advanced S3 lifecycle management with cost optimization"
echo "3. Infrastructure as Code deployment with CloudFormation"
echo ""
echo "Key patterns covered:"
echo "- Robust error handling and retry logic"
echo "- Configuration-driven pipeline orchestration"
echo "- Intelligent cost optimization strategies"
echo "- Infrastructure automation and versioning"
echo "- Comprehensive logging and monitoring"
