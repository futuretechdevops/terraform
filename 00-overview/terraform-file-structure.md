# Terraform File Structure Guide

## Standard File Organization

### Core Configuration Files

#### **main.tf**
- **Purpose**: Primary configuration file
- **Contains**: Resources, data sources, locals
- **Best Practice**: Keep resources logically grouped
```hcl
# Example main.tf
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```

#### **variables.tf**
- **Purpose**: Input variable definitions
- **Contains**: Variable declarations with types, defaults, descriptions
- **Best Practice**: Always include descriptions
```hcl
# Example variables.tf
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition     = contains(["t2.micro", "t2.small"], var.instance_type)
    error_message = "Instance type must be t2.micro or t2.small."
  }
}
```

#### **outputs.tf**
- **Purpose**: Output value definitions
- **Contains**: Values to return after apply
- **Best Practice**: Include descriptions and mark sensitive outputs
```hcl
# Example outputs.tf
output "instance_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.web.public_ip
}

output "database_password" {
  description = "Database password"
  value       = aws_db_instance.main.password
  sensitive   = true
}
```

#### **versions.tf**
- **Purpose**: Terraform and provider version constraints
- **Contains**: Required versions, provider configurations
- **Best Practice**: Pin versions for production
```hcl
# Example versions.tf
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

#### **provider.tf**
- **Purpose**: Provider configurations
- **Contains**: Provider settings, authentication
- **Best Practice**: Separate from versions.tf
```hcl
# Example provider.tf
provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
    }
  }
}
```

### Configuration Files

#### **terraform.tfvars**
- **Purpose**: Variable value assignments
- **Contains**: Actual values for variables
- **Security**: Don't commit sensitive values
```hcl
# Example terraform.tfvars
aws_region    = "us-east-1"
instance_type = "t2.micro"
environment   = "production"
```

#### **backend.tf**
- **Purpose**: Remote state configuration
- **Contains**: Backend settings
- **Best Practice**: Separate file for clarity
```hcl
# Example backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Auto-Generated Files

#### **.terraform/**
- **Purpose**: Terraform working directory
- **Contains**: Provider plugins, modules
- **Action**: Add to .gitignore

#### **terraform.tfstate**
- **Purpose**: Current state of infrastructure
- **Contains**: Resource mappings and metadata
- **Action**: Never commit to version control

#### **.terraform.lock.hcl**
- **Purpose**: Provider version lock file
- **Contains**: Exact provider versions used
- **Action**: Commit to version control

## File Naming Conventions

### Standard Names
```
project/
├── main.tf              # Primary resources
├── variables.tf         # Variable definitions
├── outputs.tf          # Output definitions
├── versions.tf         # Version constraints
├── provider.tf         # Provider configuration
├── backend.tf          # Backend configuration
├── terraform.tfvars    # Variable values
└── locals.tf           # Local values (optional)
```

### Resource-Specific Files
```
project/
├── networking.tf       # VPC, subnets, security groups
├── compute.tf         # EC2, ASG, launch templates
├── database.tf        # RDS, DynamoDB
├── storage.tf         # S3, EBS volumes
├── security.tf        # IAM roles, policies
└── monitoring.tf      # CloudWatch, alarms
```

### Environment-Specific Structure
```
project/
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
├── modules/
│   ├── vpc/
│   ├── ec2/
│   └── rds/
└── main.tf
```

## File Content Guidelines

### Variable Types
```hcl
# String
variable "name" {
  type = string
}

# Number
variable "port" {
  type = number
}

# Boolean
variable "enabled" {
  type = bool
}

# List
variable "subnets" {
  type = list(string)
}

# Map
variable "tags" {
  type = map(string)
}

# Object
variable "database" {
  type = object({
    name     = string
    port     = number
    encrypted = bool
  })
}
```

### Local Values
```hcl
# locals.tf
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
  
  name_prefix = "${var.project_name}-${var.environment}"
}
```

### Data Sources
```hcl
# Data sources in main.tf or separate data.tf
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

## Best Practices

### File Organization
- **Single Responsibility**: One concern per file
- **Logical Grouping**: Related resources together
- **Consistent Naming**: Follow team conventions
- **Size Management**: Split large files

### Security
- **Sensitive Variables**: Mark as sensitive
- **State Files**: Never commit to VCS
- **Credentials**: Use environment variables or IAM roles
- **Encryption**: Enable backend encryption

### Version Control
```gitignore
# .gitignore
.terraform/
*.tfstate
*.tfstate.*
crash.log
*.tfvars  # Only if contains sensitive data
```

### Documentation
- **Comments**: Explain complex logic
- **Descriptions**: All variables and outputs
- **README**: Setup and usage instructions
- **Examples**: Provide usage examples

## Module Structure
```
modules/
└── vpc/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    └── README.md
```

## Multi-Environment Structure
```
infrastructure/
├── modules/           # Reusable modules
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   └── production/
└── shared/           # Shared resources
```
