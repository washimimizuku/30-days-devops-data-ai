# Day 26 Quiz: AWS CLI - Cloud Operations

Test your understanding of AWS CLI for data pipeline operations.

## Questions

### 1. Which command configures AWS CLI with a specific profile?
a) `aws config --profile myprofile`
b) `aws configure --profile myprofile`
c) `aws setup --profile myprofile`
d) `aws profile configure myprofile`

### 2. What is the correct way to upload a directory to S3 recursively?
a) `aws s3 cp ./data s3://bucket/ --recursive`
b) `aws s3 sync ./data s3://bucket/data/`
c) `aws s3 upload ./data s3://bucket/ -r`
d) Both a and b are correct

### 3. Which S3 storage class is most cost-effective for long-term archival?
a) STANDARD
b) STANDARD_IA
c) GLACIER
d) DEEP_ARCHIVE

### 4. How do you invoke a Lambda function with a JSON payload using AWS CLI?
a) `aws lambda run --function-name func --data '{"key":"value"}'`
b) `aws lambda invoke --function-name func --payload '{"key":"value"}' output.json`
c) `aws lambda execute --function func --input '{"key":"value"}'`
d) `aws lambda call func --json '{"key":"value"}'`

### 5. Which command starts an EC2 instance?
a) `aws ec2 run-instances --instance-ids i-123`
b) `aws ec2 start-instances --instance-ids i-123`
c) `aws ec2 launch-instances --instance-ids i-123`
d) `aws ec2 boot-instances --instance-ids i-123`

### 6. What does the `--dry-run` parameter do in AWS CLI commands?
a) Runs the command without output
b) Validates parameters without executing the action
c) Runs the command in test mode
d) Executes the command silently

### 7. Which command creates a CloudFormation stack?
a) `aws cf create-stack --stack-name mystack --template template.yaml`
b) `aws cloudformation create-stack --stack-name mystack --template-body file://template.yaml`
c) `aws stack create --name mystack --template template.yaml`
d) `aws cfn create-stack --stack mystack --template template.yaml`

### 8. How do you set up automatic retry for AWS CLI commands?
a) `--retry 3`
b) `--max-attempts 3`
c) Configure in ~/.aws/config with max_attempts
d) Both b and c are correct

### 9. Which command lists all S3 buckets?
a) `aws s3 list`
b) `aws s3 ls`
c) `aws s3api list-buckets`
d) Both b and c are correct

### 10. What is the best practice for storing AWS credentials?
a) Hard-code in scripts
b) Use environment variables or AWS profiles
c) Store in version control
d) Pass as command line arguments

## Answers

### 1. b) `aws configure --profile myprofile`
**Explanation**: The `aws configure` command with the `--profile` flag sets up credentials and configuration for a named profile, allowing you to manage multiple AWS accounts or roles.

### 2. d) Both a and b are correct
**Explanation**: Both `aws s3 cp --recursive` and `aws s3 sync` can upload directories. `sync` is often preferred as it only uploads changed files and can delete files that don't exist locally.

### 3. d) DEEP_ARCHIVE
**Explanation**: DEEP_ARCHIVE is the most cost-effective storage class for long-term archival, costing significantly less than GLACIER but with longer retrieval times (12+ hours).

### 4. b) `aws lambda invoke --function-name func --payload '{"key":"value"}' output.json`
**Explanation**: The `lambda invoke` command requires the `--payload` parameter for input data and an output file to store the response.

### 5. b) `aws ec2 start-instances --instance-ids i-123`
**Explanation**: `start-instances` starts stopped instances. `run-instances` creates new instances, while the other options don't exist.

### 6. b) Validates parameters without executing the action
**Explanation**: `--dry-run` performs validation and permission checks without actually executing the operation, useful for testing commands safely.

### 7. b) `aws cloudformation create-stack --stack-name mystack --template-body file://template.yaml`
**Explanation**: CloudFormation commands use the full service name `cloudformation`, and templates are specified with `--template-body file://` for local files.

### 8. d) Both b and c are correct
**Explanation**: You can set `--max-attempts` on individual commands or configure `max_attempts` in the AWS config file for automatic retry behavior.

### 9. d) Both b and c are correct
**Explanation**: Both `aws s3 ls` (high-level command) and `aws s3api list-buckets` (low-level API command) list S3 buckets, with different output formats.

### 10. b) Use environment variables or AWS profiles
**Explanation**: AWS credentials should never be hard-coded or stored in version control. Use AWS profiles, environment variables, or IAM roles for secure credential management.

## Scoring

- **8-10 correct**: Excellent! You have a strong understanding of AWS CLI operations for data pipelines.
- **6-7 correct**: Good job! Review the areas you missed, particularly around security and best practices.
- **4-5 correct**: You're making progress. Focus on understanding the different AWS services and their CLI commands.
- **0-3 correct**: Review the lesson material and practice with the AWS CLI documentation.

## Key Takeaways

1. **Profile management** enables multiple AWS account configurations
2. **S3 operations** are fundamental for data pipeline storage
3. **Storage classes** provide cost optimization for different access patterns
4. **Lambda functions** enable serverless data processing
5. **EC2 instances** provide scalable compute for batch processing
6. **Dry-run mode** allows safe command validation
7. **CloudFormation** enables infrastructure as code
8. **Retry mechanisms** improve reliability in automation
9. **Multiple command formats** (high-level vs API) serve different needs
10. **Security practices** protect credentials and access

## Common Data Pipeline Patterns

- **Data ingestion**: Upload datasets to S3 with metadata
- **Batch processing**: Start EC2 instances for large-scale processing
- **Serverless processing**: Use Lambda for event-driven data transformation
- **Data archival**: Implement lifecycle policies for cost optimization
- **Monitoring**: Use CloudWatch for pipeline observability
- **Infrastructure management**: Deploy resources with CloudFormation
- **Cost optimization**: Regular cleanup and intelligent storage tiering
- **Security**: IAM roles and policies for least privilege access
