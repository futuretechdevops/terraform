# Multi-Environment & Multi-Region Code Design

## Folder Structure Patterns

### Pattern 1: Environment-Based Structure
```
project/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   │   └── outputs.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── backend.tf
│   │   └── outputs.tf
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── backend.tf
│       └── outputs.tf
├── modules/
│   ├── vpc/
│   ├── ec2/
│   └── rds/
└── shared/
    ├── iam/
    └── route53/
```

### Pattern 2: Region-Environment Structure
```
project/
├── regions/
│   ├── us-east-1/
│   │   ├── dev/
│   │   │   ├── main.tf
│   │   │   ├── terraform.tfvars
│   │   │   └── backend.tf
│   │   ├── staging/
│   │   └── prod/
│   ├── us-west-2/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   └── ap-south-1/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── modules/
└── global/
    ├── iam/
    └── route53/
```

### Pattern 3: Service-Based Structure
```
project/
├── services/
│   ├── networking/
│   │   ├── environments/
│   │   │   ├── dev.tfvars
│   │   │   ├── staging.tfvars
│   │   │   └── prod.tfvars
│   │   ├── main.tf
│   │   └── backend.tf
│   ├── compute/
│   │   ├── environments/
│   │   ├── main.tf
│   │   └── backend.tf
│   └── database/
│       ├── environments/
│       ├── main.tf
│       └── backend.tf
└── shared/
```

## Backend Configuration Per Environment

### Separate Backend Files
```hcl
# environments/dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state-dev"
    key            = "infrastructure/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-dev"
    encrypt        = true
  }
}
```

```hcl
# environments/staging/backend.tf
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state-staging"
    key            = "infrastructure/staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-staging"
    encrypt        = true
  }
}
```

```hcl
# environments/prod/backend.tf
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state-prod"
    key            = "infrastructure/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-prod"
    encrypt        = true
  }
}
```

### Shared Backend with Different Keys
```hcl
# environments/dev/backend.tf
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

```hcl
# environments/prod/backend.tf
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "environments/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Backend Configuration with Variables
```hcl
# backend-config/dev.hcl
bucket         = "mycompany-terraform-state"
key            = "environments/dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
```

```bash
# Initialize with backend config
terraform init -backend-config=backend-config/dev.hcl
```

## Multi-Region Provider Configuration

### Provider Alias for Multi-Region
```hcl
# providers.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary region provider
provider "aws" {
  region = var.primary_region
  
  default_tags {
    tags = local.common_tags
  }
}

# Secondary region provider
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
  
  default_tags {
    tags = local.common_tags
  }
}

# Disaster recovery region
provider "aws" {
  alias  = "dr"
  region = var.dr_region
  
  default_tags {
    tags = merge(local.common_tags, {
      Purpose = "disaster-recovery"
    })
  }
}
```

### Using Provider Aliases
```hcl
# main.tf
# Resources in primary region (default provider)
resource "aws_vpc" "primary" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "${var.project_name}-primary-vpc"
  }
}

# Resources in secondary region
resource "aws_vpc" "secondary" {
  provider   = aws.secondary
  cidr_block = "10.1.0.0/16"
  
  tags = {
    Name = "${var.project_name}-secondary-vpc"
  }
}

# Resources in DR region
resource "aws_s3_bucket" "backup" {
  provider = aws.dr
  bucket   = "${var.project_name}-backup-${var.environment}"
}
```

### Cross-Region Data Sources
```hcl
# Get AMI from primary region
data "aws_ami" "primary" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Get AMI from secondary region
data "aws_ami" "secondary" {
  provider    = aws.secondary
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

## Environment-Specific Configuration

### Development Environment
```hcl
# environments/dev/terraform.tfvars
environment      = "dev"
aws_region      = "us-east-1"
instance_type   = "t2.micro"
min_size        = 1
max_size        = 2
desired_capacity = 1
enable_monitoring = false
backup_retention = 7

# Development-specific settings
enable_debug_logging = true
allow_ssh_from_anywhere = true
```

```hcl
# environments/dev/main.tf
module "infrastructure" {
  source = "../../modules/infrastructure"
  
  environment           = var.environment
  instance_type        = var.instance_type
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  enable_monitoring   = var.enable_monitoring
  backup_retention    = var.backup_retention
  
  # Dev-specific overrides
  enable_debug_logging     = var.enable_debug_logging
  allow_ssh_from_anywhere = var.allow_ssh_from_anywhere
}
```

### Production Environment
```hcl
# environments/prod/terraform.tfvars
environment      = "prod"
aws_region      = "us-east-1"
instance_type   = "t3.medium"
min_size        = 3
max_size        = 10
desired_capacity = 5
enable_monitoring = true
backup_retention = 30

# Production-specific settings
enable_debug_logging = false
allow_ssh_from_anywhere = false
enable_encryption = true
multi_az = true
```

```hcl
# environments/prod/main.tf
module "infrastructure" {
  source = "../../modules/infrastructure"
  
  environment           = var.environment
  instance_type        = var.instance_type
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  enable_monitoring   = var.enable_monitoring
  backup_retention    = var.backup_retention
  
  # Prod-specific settings
  enable_encryption = var.enable_encryption
  multi_az         = var.multi_az
}

# Production-only resources
module "monitoring" {
  source = "../../modules/monitoring"
  
  environment = var.environment
  vpc_id     = module.infrastructure.vpc_id
}
```

## Complete Multi-Environment Example

### Shared Module Structure
```hcl
# modules/infrastructure/main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

resource "aws_instance" "web" {
  count         = var.environment == "prod" ? 3 : 1
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id
  
  monitoring = var.enable_monitoring
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-web-${count.index + 1}"
  })
}
```

```hcl
# modules/infrastructure/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "backup_retention" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}
```

### Environment Deployment Scripts
```bash
#!/bin/bash
# scripts/deploy-dev.sh
cd environments/dev
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

```bash
#!/bin/bash
# scripts/deploy-prod.sh
cd environments/prod
terraform init
terraform plan -var-file="terraform.tfvars" -out=prod.tfplan
echo "Review the plan above. Press Enter to continue or Ctrl+C to cancel"
read
terraform apply prod.tfplan
```

## Multi-Region Deployment Example

### Global Infrastructure
```hcl
# global/main.tf
# Route53 hosted zone (global)
resource "aws_route53_zone" "main" {
  name = var.domain_name
  
  tags = local.common_tags
}

# CloudFront distribution (global)
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = aws_s3_bucket.primary.bucket_domain_name
    origin_id   = "S3-primary"
  }
  
  enabled = true
  
  tags = local.common_tags
}
```

### Regional Infrastructure
```hcl
# regions/us-east-1/main.tf
module "primary_region" {
  source = "../../modules/regional-infrastructure"
  
  providers = {
    aws = aws
  }
  
  region      = "us-east-1"
  environment = var.environment
  is_primary  = true
}

# Cross-region replication
resource "aws_s3_bucket_replication_configuration" "replication" {
  depends_on = [aws_s3_bucket_versioning.primary]
  
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.primary.id
  
  rule {
    id     = "replicate-to-secondary"
    status = "Enabled"
    
    destination {
      bucket        = aws_s3_bucket.secondary.arn
      storage_class = "STANDARD_IA"
    }
  }
}
```

## Best Practices

### Environment Isolation
```hcl
# Use separate AWS accounts for environments
provider "aws" {
  region  = var.aws_region
  profile = "dev-account"    # For development
}

provider "aws" {
  region  = var.aws_region
  profile = "prod-account"   # For production
}
```

### Variable Management
```hcl
# environments/common.tfvars
project_name = "myapp"
owner        = "platform-team"

# environments/dev/terraform.tfvars
environment = "dev"
# Include common variables
```

### Workspace Alternative
```bash
# Using Terraform workspaces
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Deploy to specific workspace
terraform workspace select dev
terraform apply -var-file="dev.tfvars"
```

### CI/CD Integration
```yaml
# .github/workflows/terraform.yml
name: Terraform
on:
  push:
    branches: [main]
    paths: ['environments/**']

jobs:
  dev:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy Dev
        run: |
          cd environments/dev
          terraform init
          terraform apply -auto-approve
        if: contains(github.event.head_commit.modified, 'environments/dev/')
  
  prod:
    runs-on: ubuntu-latest
    needs: dev
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v2
      - name: Deploy Prod
        run: |
          cd environments/prod
          terraform init
          terraform plan -out=prod.tfplan
          terraform apply prod.tfplan
```

## Deployment Strategies

### Blue-Green Deployment
```hcl
# environments/prod-blue/main.tf
module "infrastructure" {
  source = "../../modules/infrastructure"
  
  environment = "prod-blue"
  # ... other variables
}

# environments/prod-green/main.tf
module "infrastructure" {
  source = "../../modules/infrastructure"
  
  environment = "prod-green"
  # ... other variables
}
```

### Canary Deployment
```hcl
# Split traffic between versions
resource "aws_lb_target_group" "v1" {
  name = "${var.project_name}-v1"
  # ... configuration
}

resource "aws_lb_target_group" "v2" {
  name = "${var.project_name}-v2"
  # ... configuration
}

resource "aws_lb_listener_rule" "canary" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100
  
  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.v1.arn
        weight = 90  # 90% to v1
      }
      target_group {
        arn    = aws_lb_target_group.v2.arn
        weight = 10  # 10% to v2
      }
    }
  }
  
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
```

This structure provides complete separation between environments while maintaining code reusability and enabling safe, controlled deployments across multiple environments and regions.
