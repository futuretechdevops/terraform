# Provider
provider "aws" {
  region = "ap-south-1"
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get all subnets in default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Select one subnet
data "aws_subnet" "selected" {
  id = element(data.aws_subnets.default.ids, 0)
}

# Get default security group
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# EC2 instance
resource "aws_instance" "example" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [data.aws_security_group.default.id]
  key_name               = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }
}
