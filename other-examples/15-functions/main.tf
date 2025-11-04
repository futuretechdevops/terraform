provider "aws" {
  region = "ap-south-1"
}

variable "environments" {
  default = ["dev", "staging", "prod"]
}

variable "ports" {
  default = [22, 80, 443, 8080]
}

locals {
  # String functions
  project_name = "myapp"
  bucket_name  = lower("${local.project_name}-${random_id.suffix.hex}")
  
  # Collection functions
  env_count    = length(var.environments)
  first_env    = element(var.environments, 0)
  sorted_ports = sort(var.ports)
  unique_ports = distinct(concat(var.ports, [80, 443]))
  
  # Numeric functions
  max_port = max(var.ports...)
  min_port = min(var.ports...)
  
  # Date/Time functions
  timestamp = timestamp()
  
  # Encoding functions
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name = local.project_name
  }))
  
  # Type conversion functions
  port_strings = [for port in var.ports : tostring(port)]
  port_set     = toset(local.port_strings)
  
  # Conditional functions
  instance_type = var.environments[0] == "prod" ? "t3.large" : "t2.micro"
  
  # Map functions
  env_configs = {
    for env in var.environments : env => {
      instance_type = env == "prod" ? "t3.large" : "t2.micro"
      min_size     = env == "prod" ? 3 : 1
    }
  }
  
  # Network functions
  vpc_cidr = "10.0.0.0/16"
  subnets = [
    for i in range(3) : cidrsubnet(local.vpc_cidr, 8, i)
  ]
  
  # File functions
  config_file = fileexists("${path.module}/config.json") ? 
                file("${path.module}/config.json") : 
                jsonencode({default = "config"})
}

# Resources using functions
resource "aws_s3_bucket" "example" {
  bucket = local.bucket_name
  
  tags = {
    Name        = title(local.project_name)
    Environment = join("-", var.environments)
    CreatedAt   = local.timestamp
    MaxPort     = local.max_port
  }
}

resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr
  
  tags = {
    Name = "${local.project_name}-vpc"
  }
}

resource "aws_subnet" "public" {
  count      = length(local.subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = local.subnets[count.index]
  
  availability_zone = data.aws_availability_zones.available.names[
    count.index % length(data.aws_availability_zones.available.names)
  ]
  
  tags = {
    Name = "${local.project_name}-subnet-${count.index + 1}"
    CIDR = local.subnets[count.index]
  }
}

resource "aws_security_group" "web" {
  name   = "${local.project_name}-sg"
  vpc_id = aws_vpc.main.id
  
  dynamic "ingress" {
    for_each = local.port_set
    content {
      from_port   = tonumber(ingress.value)
      to_port     = tonumber(ingress.value)
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  
  tags = {
    Name  = "${local.project_name}-security-group"
    Ports = join(",", local.port_strings)
  }
}

resource "aws_instance" "web" {
  for_each      = local.env_configs
  ami           = data.aws_ami.amazon_linux.id
  instance_type = each.value.instance_type
  subnet_id     = aws_subnet.public[0].id
  
  user_data = local.user_data
  
  tags = merge(
    {
      Name        = "${local.project_name}-${each.key}"
      Environment = each.key
    },
    each.key == "prod" ? { Backup = "required" } : {}
  )
}

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

resource "random_id" "suffix" {
  byte_length = 4
}

# Outputs demonstrating functions
output "function_examples" {
  value = {
    bucket_name    = local.bucket_name
    env_count      = local.env_count
    sorted_ports   = local.sorted_ports
    unique_ports   = local.unique_ports
    max_port       = local.max_port
    subnet_cidrs   = local.subnets
    timestamp      = local.timestamp
    config_exists  = fileexists("${path.module}/config.json")
  }
}
