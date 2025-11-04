provider "aws" {
  region = "ap-south-1"
}

# Basic resource
resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-bucket-${random_id.suffix.hex}"
}

# Resource with dependencies
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Resource with lifecycle rules
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes       = [ami]
  }

  tags = {
    Name = "web-server"
  }
}

# Resource with timeouts
resource "aws_db_instance" "example" {
  identifier     = "mydb"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  db_name          = "mydb"
  username         = "admin"
  password         = "password123"
  
  skip_final_snapshot = true

  timeouts {
    create = "40m"
    delete = "40m"
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
