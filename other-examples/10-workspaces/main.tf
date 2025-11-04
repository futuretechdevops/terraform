provider "aws" {
  region = "ap-south-1"
}

# Workspace-specific configurations
locals {
  workspace_configs = {
    default = {
      instance_type = "t2.micro"
      min_size     = 1
      max_size     = 2
    }
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
  
  config = local.workspace_configs[terraform.workspace]
  
  # Workspace-aware naming
  name_prefix = "myapp-${terraform.workspace}"
}

resource "aws_s3_bucket" "app_data" {
  bucket = "${local.name_prefix}-data-${random_id.suffix.hex}"
  
  tags = {
    Environment = terraform.workspace
    Name        = "${local.name_prefix}-data"
  }
}

resource "aws_instance" "web" {
  count         = local.config.min_size
  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.config.instance_type
  
  tags = {
    Name        = "${local.name_prefix}-web-${count.index + 1}"
    Environment = terraform.workspace
    Workspace   = terraform.workspace
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "current_workspace" {
  value = terraform.workspace
}

output "instance_count" {
  value = local.config.min_size
}

output "instance_type" {
  value = local.config.instance_type
}

output "bucket_name" {
  value = aws_s3_bucket.app_data.bucket
}
