# Terraform AWS Provider
provider "aws" {
  region = "ap-south-1"   # Change if needed
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get all subnets inside default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get one subnet (first from the list)
data "aws_subnet" "selected" {
  id = element(data.aws_subnets.default.ids, 0)
}

# Get the default security group
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Create EC2 instance
resource "aws_instance" "example" {
  ami                    = "ami-0f5ee92e2d63afc18"  ##TODO: Amazon Linux 2 in ap-south-1
  instance_type          = "t2.micro"    ##TODO: Update it
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [data.aws_security_group.default.id]
  key_name               = "demo"  ##TODO: Update it
  associate_public_ip_address = true

  tags = {
    Name = "Terraform-EC2-Demo"
  }
}

