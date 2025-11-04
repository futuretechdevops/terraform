provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source = "./modules/vpc"
  
  name           = "my-app"
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnet_ids[0]

  tags = {
    Name = "web-server"
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

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}
