provider "aws" {
  region = var.region
}

variable "region" {
  default = "ap-south-1"
}

variable "environment" {
  default = "dev"
}

variable "project" {
  default = "myapp"
}

# Local values for computed expressions
locals {
  # Common tags
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
  
  # Naming convention
  name_prefix = "${var.project}-${var.environment}"
  
  # Conditional logic
  instance_type = var.environment == "prod" ? "t3.medium" : "t2.micro"
  
  # Complex calculations
  subnet_cidrs = [
    for i in range(3) : cidrsubnet("10.0.0.0/16", 8, i)
  ]
  
  # String manipulation
  bucket_name = lower("${local.name_prefix}-bucket-${random_id.suffix.hex}")
}

resource "aws_s3_bucket" "example" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.instance_type
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web"
    Type = "WebServer"
  })
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
}

resource "aws_subnet" "public" {
  count      = length(local.subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = local.subnet_cidrs[count.index]
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-subnet-${count.index + 1}"
  })
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

output "bucket_name" {
  value = local.bucket_name
}

output "subnet_cidrs" {
  value = local.subnet_cidrs
}
