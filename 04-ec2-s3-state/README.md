# EC2 Instance with S3 Remote State Backend

This example demonstrates creating an EC2 instance using existing default VPC with remote state management using S3 backend and DynamoDB for state locking. This example uses the backend infrastructure created by the `03-remote-state-backend` example.

## File Structure

```
04-ec2-s3-state/
├── versions.tf       # Terraform and provider versions
├── provider.tf       # AWS provider configuration
├── variables.tf      # Input variable definitions
├── main.tf          # EC2 instance and data sources
├── outputs.tf       # Output values
├── backend.tf       # Remote state configuration (references 03 example)
├── terraform.tfvars # Variable values
├── commands.txt     # Quick reference commands
└── README.md        # This file
```

## Prerequisites

### 1. Deploy Backend Infrastructure First
**IMPORTANT**: Before using this example, deploy the remote state backend:

```bash
# Navigate to backend infrastructure
cd ../03-remote-state-backend

# Deploy S3 bucket and DynamoDB table
terraform init
terraform apply

# Note the bucket name from outputs
```

### 2. AWS Credentials
Configure AWS credentials with permissions for:
- EC2 (create instances)
- S3 (read/write to state bucket)
- DynamoDB (read/write to lock table)

### 3. Key Pair
Ensure the key pair specified in `terraform.tfvars` exists:
```bash
# Check if key exists
aws ec2 describe-key-pairs --key-names futuretechdevops15 --region ap-south-1
```

## What This Creates

### Infrastructure Components
- **EC2 Instance**: Single t2.micro instance in default VPC
- **Uses Default VPC**: Leverages existing AWS default networking
- **Default Security Group**: Uses existing default security group
- **Public IP**: Instance gets public IP automatically

### Remote State Features
- **S3 Backend**: Stores state file in S3 bucket from 03-remote-state-backend
- **State Locking**: Uses DynamoDB for concurrent access protection
- **Encryption**: State file encrypted in S3
- **Versioning**: S3 versioning protects against state corruption

## Backend Configuration

This example references the backend infrastructure created by `03-remote-state-backend`:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique-12345"
    key            = "ec2/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
```

## Configuration Options

### AMI Selection
- **Auto-detection** (recommended): Leave `ami = ""` for latest Amazon Linux 2
- **Specific AMI**: Set `ami = "ami-xxxxxxxxx"` for specific AMI ID

### Variables Customization
Edit `terraform.tfvars`:
```hcl
aws_region    = "ap-south-1"
ami           = ""  # Auto-detect latest Amazon Linux 2
instance_type = "t2.micro"
key_name      = "your-key-name"
instance_name = "Your-Instance-Name"
```

## Commands to Run

### Step 1: Ensure Backend Infrastructure Exists
```bash
# Check if backend infrastructure is deployed
aws s3 ls s3://my-terraform-state-bucket-unique-12345
aws dynamodb describe-table --table-name terraform-lock-table --region ap-south-1
```

### Step 2: Deploy EC2 Instance
```bash
# Initialize with remote backend
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply

# View state (stored remotely)
terraform show
```

## Key Features

### Remote State Benefits
- **Team Collaboration**: Multiple users can work on same infrastructure
- **State Locking**: Prevents concurrent modifications
- **State History**: S3 versioning provides state history
- **Security**: Encrypted state storage
- **Centralized**: All team members use same state

### Default VPC Usage
- Uses existing AWS default VPC
- No need to create custom networking
- Automatically selects first available subnet
- Uses default security group

### Dynamic AMI Selection
- Automatically finds latest Amazon Linux 2 AMI
- No need to update hardcoded AMI IDs
- Works across different regions

## Outputs

After successful deployment:
- **instance_id**: EC2 instance identifier
- **public_ip**: Public IP address for SSH access
- **private_ip**: Private IP within VPC
- **ssh_command**: Ready-to-use SSH command
- **state_backend_info**: Information about remote state configuration

## State Management

### View State Information
```bash
# List resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.example

# View all state
terraform show
```

### State File Location
- **Remote**: `s3://my-terraform-state-bucket-unique-12345/ec2/terraform.tfstate`
- **Versioned**: Previous versions available in S3
- **Locked**: DynamoDB prevents concurrent access

## Security Considerations

### Default Security Group
The default security group typically allows:
- All inbound traffic from same security group
- All outbound traffic
- **Note**: May not allow SSH (port 22) from internet

### State Security
- State file encrypted in S3
- Access controlled via IAM
- DynamoDB table secured via IAM
- No sensitive data in state file (use sensitive variables)

## Troubleshooting

### Backend Initialization Errors
```bash
# Error: bucket doesn't exist
# Solution: Deploy 03-remote-state-backend first

# Error: DynamoDB table doesn't exist  
# Solution: Ensure 03-remote-state-backend is applied

# Error: Access denied
# Solution: Check IAM permissions for S3 and DynamoDB
```

### State Lock Issues
```bash
# Error: state locked
# Solution: Wait for other operation to complete or force unlock
terraform force-unlock LOCK_ID
```

### SSH Connection Issues
```bash
# Check security group allows SSH
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx

# Verify key pair exists
aws ec2 describe-key-pairs --key-names your-key-name
```

## Cost Considerations

- **EC2 t2.micro**: Free tier eligible (750 hours/month)
- **S3 Storage**: Minimal cost for state file (~$0.023/GB/month)
- **DynamoDB**: Pay-per-request, typically <$1/month
- **Data Transfer**: Minimal for state operations

## Cleanup

```bash
# Destroy EC2 infrastructure
terraform destroy

# State file remains in S3 for history
# Backend infrastructure (S3/DynamoDB) remains for other projects
```

## Learning Objectives

This example teaches:
- Using remote state backends
- State locking and team collaboration
- Working with existing AWS resources (default VPC)
- Dynamic resource selection (latest AMI)
- Production-ready Terraform practices
- State management and troubleshooting

## Next Steps

- Deploy multiple environments using same backend
- Explore state workspaces for environment separation
- Add custom VPC and security groups
- Implement CI/CD with remote state
- Add monitoring and logging
