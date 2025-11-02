# Get latest Amazon Linux 2 AMI (if AMI not specified)
data "aws_ami" "amazon_linux" {
  count       = var.ami == "" ? 1 : 0
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
  ami                         = var.ami != "" ? var.ami : data.aws_ami.amazon_linux[0].id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.selected.id
  vpc_security_group_ids      = [data.aws_security_group.default.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = var.instance_name
  }
}
