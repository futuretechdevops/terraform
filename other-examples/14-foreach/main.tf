provider "aws" {
  region = "ap-south-1"
}

# for_each with set
variable "user_names" {
  description = "Set of IAM user names"
  type        = set(string)
  default     = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "users" {
  for_each = var.user_names
  name     = each.key
  
  tags = {
    Name = each.value
    Type = "Developer"
  }
}

# for_each with map
variable "environments" {
  description = "Environment configurations"
  type = map(object({
    instance_type = string
    min_size     = number
    max_size     = number
  }))
  default = {
    dev = {
      instance_type = "t2.micro"
      min_size     = 1
      max_size     = 2
    }
    staging = {
      instance_type = "t3.small"
      min_size     = 2
      max_size     = 4
    }
    prod = {
      instance_type = "t3.medium"
      min_size     = 3
      max_size     = 10
    }
  }
}

resource "aws_launch_template" "app" {
  for_each      = var.environments
  name          = "${each.key}-launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = each.value.instance_type
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${each.key}-instance"
      Environment = each.key
    }
  }
}

# for_each with complex objects
variable "s3_buckets" {
  description = "S3 bucket configurations"
  type = map(object({
    versioning_enabled = bool
    encryption_enabled = bool
    public_access      = bool
  }))
  default = {
    "app-logs" = {
      versioning_enabled = true
      encryption_enabled = true
      public_access      = false
    }
    "static-assets" = {
      versioning_enabled = false
      encryption_enabled = false
      public_access      = true
    }
    "backups" = {
      versioning_enabled = true
      encryption_enabled = true
      public_access      = false
    }
  }
}

resource "aws_s3_bucket" "buckets" {
  for_each = var.s3_buckets
  bucket   = "${each.key}-${random_id.suffix.hex}"
  
  tags = {
    Name       = each.key
    Versioning = each.value.versioning_enabled
    Encryption = each.value.encryption_enabled
  }
}

resource "aws_s3_bucket_versioning" "buckets" {
  for_each = {
    for k, v in var.s3_buckets : k => v
    if v.versioning_enabled
  }
  
  bucket = aws_s3_bucket.buckets[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "buckets" {
  for_each = {
    for k, v in var.s3_buckets : k => v
    if v.encryption_enabled
  }
  
  bucket = aws_s3_bucket.buckets[each.key].id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# for_each with toset() function
variable "security_group_rules" {
  description = "List of ports to allow"
  type        = list(number)
  default     = [22, 80, 443, 8080]
}

resource "aws_security_group" "web" {
  name        = "web-security-group"
  description = "Security group for web servers"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "ingress" {
  for_each = toset([for port in var.security_group_rules : tostring(port)])
  
  type              = "ingress"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Outputs using for_each
output "user_arns" {
  description = "Map of user ARNs"
  value       = { for k, v in aws_iam_user.users : k => v.arn }
}

output "launch_template_ids" {
  description = "Map of launch template IDs"
  value       = { for k, v in aws_launch_template.app : k => v.id }
}

output "bucket_names" {
  description = "Map of bucket names"
  value       = { for k, v in aws_s3_bucket.buckets : k => v.bucket }
}
