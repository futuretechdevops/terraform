# Basic VPC and Subnet - Single File

This example creates a custom VPC with public and private subnets using a single `main.tf` file.

## What This Creates

- **VPC**: Custom VPC with CIDR 10.0.0.0/16
- **Internet Gateway**: For internet access
- **Public Subnet**: 10.0.1.0/24 in us-east-1a (auto-assigns public IPs)
- **Private Subnet**: 10.0.2.0/24 in us-east-1b (no internet access)
- **Route Table**: Routes public subnet traffic to internet gateway

## Key Concepts

### VPC (Virtual Private Cloud)
- Isolated network environment in AWS
- Define your own IP address range
- Complete control over networking

### Subnets
- **Public Subnet**: Has route to Internet Gateway (internet access)
- **Private Subnet**: No direct internet access (more secure)

### Internet Gateway
- Allows communication between VPC and internet
- Required for public subnets

### Route Tables
- Control where network traffic is directed
- Public subnet routes 0.0.0.0/0 to Internet Gateway

## Prerequisites

### AWS Credentials Setup

Before running Terraform commands, configure AWS credentials:

**Option 1: AWS CLI Configuration**
```bash
aws configure
```
Provide:
- AWS Access Key ID
- AWS Secret Access Key  
- Default region: `ap-south-1`
- Default output format: `json`

**Option 2: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"
```

**Option 3: AWS Profile**
```bash
aws configure --profile terraform
export AWS_PROFILE=terraform
```

**Verify Credentials:**
```bash
aws sts get-caller-identity
```

## Commands to Run

```bash
# Initialize Terraform
terraform init

# See what will be created
terraform plan

# Create the infrastructure
terraform apply

# Clean up when done
terraform destroy
```

## Expected Outputs

After `terraform apply`, you'll see:
- VPC ID
- Public Subnet ID  
- Private Subnet ID

## Security Notes

- Never commit AWS credentials to version control
- Use IAM roles when possible
- Ensure your IAM user has VPC creation permissions
- Always run `terraform destroy` after testing to avoid charges

## Troubleshooting

**Error: "The security token included in the request is invalid"**
- Check AWS credentials configuration
- Verify credentials with: `aws sts get-caller-identity`
- Ensure correct region is set

## Cost

All resources in this example are free tier eligible.

## Next Steps

Check the multi-file version in `01-basic-vpc-subnet-multi` to see how to organize code better.
