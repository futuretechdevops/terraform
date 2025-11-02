# Terraform Learning Guide

## What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool that allows you to define and provision infrastructure using declarative configuration files. Instead of manually creating resources through AWS console, you write code that describes what you want, and Terraform creates it for you.

## Key Advantages

- **Infrastructure as Code**: Version control your infrastructure
- **Multi-Cloud**: Works with AWS, Azure, GCP, and 100+ providers
- **Declarative**: Describe what you want, not how to build it
- **State Management**: Tracks what resources exist
- **Plan & Apply**: Preview changes before applying them
- **Reusable**: Create modules for repeated patterns

## Terraform Workflow

```
1. WRITE → 2. PLAN → 3. APPLY → 4. DESTROY (optional)
```

### 1. Write Configuration
- Create `.tf` files with resource definitions
- Define providers, resources, variables, outputs

### 2. Plan (terraform plan)
- Shows what Terraform will create/modify/destroy
- No actual changes made
- Review before applying

### 3. Apply (terraform apply)
- Creates/modifies infrastructure
- Updates state file
- Shows real-time progress

### 4. Destroy (terraform destroy)
- Removes all managed infrastructure
- Use when cleaning up resources

## Core Terraform Files

### main.tf
- **Purpose**: Primary configuration file
- **Contains**: Resources, data sources, providers
- **Example**: EC2 instances, S3 buckets, VPCs

### variables.tf
- **Purpose**: Input parameters for your configuration
- **Contains**: Variable definitions with types and defaults
- **Benefits**: Makes configurations reusable and flexible

### outputs.tf
- **Purpose**: Return values from your configuration
- **Contains**: Output definitions
- **Use Cases**: Display important information, pass data between modules

### terraform.tfvars
- **Purpose**: Actual values for variables
- **Contains**: Variable assignments
- **Security**: Don't commit sensitive values to version control

### versions.tf
- **Purpose**: Terraform and provider version constraints
- **Contains**: Required versions
- **Benefits**: Ensures consistent behavior across environments

## Basic Folder Structure

```
project/
├── main.tf           # Main configuration
├── variables.tf      # Variable definitions
├── outputs.tf        # Output definitions
├── versions.tf       # Version constraints
├── terraform.tfvars  # Variable values (don't commit if sensitive)
├── .terraform/       # Terraform working directory (auto-created)
├── terraform.tfstate # State file (auto-created)
└── README.md         # Documentation
```

## File Use Cases

### main.tf Example
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = var.instance_type
  
  tags = {
    Name = "WebServer"
  }
}
```

### variables.tf Example
```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
```

### outputs.tf Example
```hcl
output "instance_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.web.public_ip
}
```

## Essential Commands

```bash
terraform init      # Initialize working directory
terraform plan      # Show execution plan
terraform apply     # Apply changes
terraform destroy   # Destroy infrastructure
terraform fmt       # Format code
terraform validate  # Validate configuration
```

## Best Practices

1. **Always run `terraform plan` before `apply`**
2. **Use version control for `.tf` files**
3. **Don't commit `.tfstate` files or sensitive `.tfvars`**
4. **Use meaningful resource names**
5. **Add comments and documentation**
6. **Use modules for reusable components**

## Terraform Documentation

### Core Concepts
- **[Terraform Basic Concepts](terraform-basic-concepts.md)** - Variables, outputs, locals, functions, dependencies, data sources
- **[Terraform File Structure](terraform-file-structure.md)** - Complete guide to organizing .tf files
- **[Terraform CLI Basics](terraform-cli-basics.md)** - Essential commands and workflows
- **[Multi-Environment & Multi-Region](terraform-multi-env-region.md)** - Advanced deployment patterns and code organization

## AWS Resource References

For detailed information about AWS services and their Terraform usage, see these reference guides:

- **[Compute Resources](aws-compute-resources.md)** - EC2, Lambda, ECS, EKS, Auto Scaling
- **[Networking Resources](aws-networking-resources.md)** - VPC, Subnets, Load Balancers, Security Groups
- **[Storage Resources](aws-storage-resources.md)** - S3, EBS, EFS, FSx, Glacier
- **[Database Resources](aws-database-resources.md)** - RDS, DynamoDB, ElastiCache, DocumentDB
- **[Security Resources](aws-security-resources.md)** - IAM, KMS, Secrets Manager, WAF
- **[Monitoring Resources](aws-monitoring-resources.md)** - CloudWatch, CloudTrail, SNS, SQS
- **[Application Resources](aws-application-resources.md)** - API Gateway, CloudFront, Route 53, Cognito

## Next Steps

1. Start with `01-basic-ec2` example
2. Practice with `terraform init`, `plan`, `apply`
3. Modify variables and see changes
4. Explore more complex examples
5. Learn about modules and remote state

---
*Remember: Always destroy test resources to avoid AWS charges!*
