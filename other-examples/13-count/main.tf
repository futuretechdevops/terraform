provider "aws" {
  region = "ap-south-1"
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 3
}

variable "create_load_balancer" {
  description = "Whether to create load balancer"
  type        = bool
  default     = true
}

# Basic count usage
resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  tags = {
    Name = "web-server-${count.index + 1}"
    Index = count.index
  }
}

# Conditional resource creation with count
resource "aws_lb" "main" {
  count              = var.create_load_balancer ? 1 : 0
  name               = "main-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  
  tags = {
    Name = "main-load-balancer"
  }
}

# Count with list variable
variable "availability_zones" {
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.31.${count.index + 10}.0/24"
  availability_zone = var.availability_zones[count.index]
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
    AZ   = var.availability_zones[count.index]
  }
}

# Count with conditional logic
resource "aws_security_group" "web" {
  count       = var.instance_count > 0 ? 1 : 0
  name        = "web-security-group"
  description = "Security group for web servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Outputs using count
output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "List of public IP addresses"
  value       = aws_instance.web[*].public_ip
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = var.create_load_balancer ? aws_lb.main[0].dns_name : "No load balancer created"
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = aws_subnet.public[*].id
}
