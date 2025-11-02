# Terraform Basic Concepts

## Variables (var)

### Variable Declaration
```hcl
# variables.tf
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
```

### Variable Types
```hcl
# String
variable "region" {
  type = string
}

# Number
variable "port" {
  type = number
  default = 80
}

# Boolean
variable "enable_monitoring" {
  type = bool
  default = true
}

# List
variable "availability_zones" {
  type = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

# Map
variable "instance_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "web-app"
  }
}

# Object
variable "database_config" {
  type = object({
    name     = string
    port     = number
    encrypted = bool
  })
  default = {
    name     = "mydb"
    port     = 3306
    encrypted = true
  }
}
```

### Variable Usage
```hcl
# main.tf
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[0]
  
  tags = merge(var.tags, {
    Name = "web-server"
  })
}
```

### Variable Validation
```hcl
variable "instance_type" {
  type = string
  
  validation {
    condition = contains([
      "t2.micro", "t2.small", "t2.medium"
    ], var.instance_type)
    error_message = "Instance type must be t2.micro, t2.small, or t2.medium."
  }
}
```

## Outputs

### Basic Outputs
```hcl
# outputs.tf
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.web.public_ip
}

output "private_ips" {
  description = "Private IP addresses"
  value       = aws_instance.web[*].private_ip
}
```

### Sensitive Outputs
```hcl
output "database_password" {
  description = "Database password"
  value       = aws_db_instance.main.password
  sensitive   = true
}
```

### Conditional Outputs
```hcl
output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = var.create_lb ? aws_lb.main[0].dns_name : null
}
```

## Locals

### Basic Locals
```hcl
# locals.tf
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
  
  vpc_cidr = "10.0.0.0/16"
}
```

### Complex Locals
```hcl
locals {
  # Conditional logic
  instance_count = var.environment == "prod" ? 3 : 1
  
  # List manipulation
  public_subnets = [
    for i in range(var.subnet_count) : 
    cidrsubnet(local.vpc_cidr, 8, i)
  ]
  
  # Map transformation
  subnet_tags = {
    for subnet in local.public_subnets :
    subnet => {
      Name = "${local.name_prefix}-public-${index(local.public_subnets, subnet) + 1}"
      Type = "public"
    }
  }
}
```

### Using Locals
```hcl
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
  tags       = local.common_tags
}

resource "aws_instance" "web" {
  count         = local.instance_count
  ami           = "ami-12345678"
  instance_type = var.instance_type
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-${count.index + 1}"
  })
}
```

## Terraform Functions

### String Functions
```hcl
locals {
  # format() - String formatting
  server_name = format("%s-server-%02d", var.project_name, 1)
  # Result: "myproject-server-01"
  
  # join() - Join list elements
  dns_servers = join(",", var.dns_list)
  # Result: "8.8.8.8,8.8.4.4"
  
  # split() - Split string into list
  availability_zones = split(",", var.az_string)
  
  # upper() / lower() - Case conversion
  region_upper = upper(var.aws_region)
  
  # replace() - String replacement
  clean_name = replace(var.project_name, "_", "-")
}
```

### Collection Functions
```hcl
locals {
  # length() - Get collection length
  subnet_count = length(var.subnet_ids)
  
  # lookup() - Map lookup with default
  instance_type = lookup(var.instance_types, var.environment, "t2.micro")
  
  # merge() - Merge maps
  all_tags = merge(var.default_tags, var.custom_tags)
  
  # keys() / values() - Extract keys or values
  tag_keys = keys(var.tags)
  tag_values = values(var.tags)
  
  # contains() - Check if list contains value
  has_prod = contains(var.environments, "production")
}
```

### Numeric Functions
```hcl
locals {
  # max() / min() - Maximum/minimum values
  max_instances = max(var.min_size, var.desired_capacity)
  
  # ceil() / floor() - Round up/down
  storage_size = ceil(var.data_size_gb / 100) * 100
}
```

### Date/Time Functions
```hcl
locals {
  # timestamp() - Current timestamp
  created_at = timestamp()
  
  # formatdate() - Format timestamp
  backup_suffix = formatdate("YYYY-MM-DD", timestamp())
}
```

## Resource Dependencies

### Implicit Dependencies
```hcl
# VPC must be created before subnet
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Terraform automatically detects dependency
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id  # Implicit dependency
  cidr_block = "10.0.1.0/24"
}

# Instance depends on subnet
resource "aws_instance" "web" {
  ami       = "ami-12345678"
  subnet_id = aws_subnet.public.id  # Implicit dependency
}
```

### Explicit Dependencies (depends_on)
```hcl
# Use when Terraform can't detect dependency
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  # Explicit dependency
  depends_on = [
    aws_security_group.web,
    aws_key_pair.deployer
  ]
}

# Example: IAM role must exist before instance profile
resource "aws_iam_instance_profile" "web" {
  name = "web-profile"
  role = aws_iam_role.web.name
  
  depends_on = [aws_iam_role.web]
}
```

### Module Dependencies
```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}

module "ec2" {
  source    = "./modules/ec2"
  vpc_id    = module.vpc.vpc_id      # Implicit dependency
  subnet_id = module.vpc.subnet_id
  
  depends_on = [module.vpc]          # Explicit dependency
}
```

## Data Sources (data blocks)

### Basic Data Sources
```hcl
# Get latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Get current AWS region
data "aws_region" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
```

### Using Data Sources
```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  tags = {
    Name      = "web-server"
    Region    = data.aws_region.current.name
    AccountId = data.aws_caller_identity.current.account_id
  }
}
```

### Complex Data Sources
```hcl
# Get VPC by tag
data "aws_vpc" "selected" {
  tags = {
    Name = "production-vpc"
  }
}

# Get subnets in VPC
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
  
  tags = {
    Type = "private"
  }
}

# Get specific subnet
data "aws_subnet" "selected" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}
```

### Data Source with Variables
```hcl
data "aws_availability_zones" "available" {
  state = "available"
  
  filter {
    name   = "region-name"
    values = [var.aws_region]
  }
}

# Use in resource
resource "aws_subnet" "public" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
}
```

## Practical Examples

### Complete Example
```hcl
# variables.tf
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# locals.tf
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    CreatedAt   = formatdate("YYYY-MM-DD", timestamp())
  }
}

# data.tf
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# main.tf
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(local.common_tags, {
    Name = format("%s-public-%s", local.name_prefix, count.index + 1)
    Type = "public"
  })
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = lookup(var.instance_types, var.environment, "t2.micro")
  subnet_id     = aws_subnet.public[0].id
  
  depends_on = [aws_internet_gateway.main]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web"
  })
}

# outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "instance_details" {
  description = "Instance information"
  value = {
    id        = aws_instance.web.id
    public_ip = aws_instance.web.public_ip
    az        = aws_instance.web.availability_zone
  }
}
```

## Best Practices

### Variables
- Always include descriptions
- Use appropriate types
- Set sensible defaults
- Add validation rules
- Group related variables

### Outputs
- Include descriptions
- Mark sensitive outputs
- Use meaningful names
- Output useful information

### Locals
- Use for computed values
- Avoid complex logic
- Keep readable
- Use for common tags

### Functions
- Use built-in functions
- Avoid complex expressions
- Test in terraform console
- Document complex logic

### Dependencies
- Prefer implicit dependencies
- Use depends_on sparingly
- Document explicit dependencies
- Consider module boundaries

### Data Sources
- Use for external data
- Filter appropriately
- Handle missing data
- Cache when possible
