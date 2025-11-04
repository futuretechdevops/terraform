provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_types["dev"]
  
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  monitoring        = var.enable_monitoring

  tags = {
    Name = "web-${count.index + 1}"
  }
}

resource "aws_db_instance" "example" {
  identifier     = "mydb"
  engine         = var.database_config.engine
  engine_version = var.database_config.engine_version
  instance_class = var.database_config.instance_class
  
  allocated_storage = var.database_config.allocated_storage
  db_name          = "mydb"
  username         = "admin"
  password         = var.db_password
  
  skip_final_snapshot = true
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
