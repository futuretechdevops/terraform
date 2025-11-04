provider "aws" {
  region = "ap-south-1"
}

# Get latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get current AWS region
data "aws_region" "current" {}

# Get current AWS caller identity
data "aws_caller_identity" "current" {}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.default.ids[0]

  tags = {
    Name   = "data-source-example"
    Region = data.aws_region.current.name
    Owner  = data.aws_caller_identity.current.user_id
  }
}

output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "current_region" {
  value = data.aws_region.current.name
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
