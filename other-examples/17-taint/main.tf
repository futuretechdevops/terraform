provider "aws" {
  region = "ap-south-1"
}

# Instance that might need to be tainted
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Web Server</h1>" > /var/www/html/index.html
  EOF
  )
  
  tags = {
    Name = "taint-example-web"
  }
}

# Database instance that might become corrupted
resource "aws_db_instance" "example" {
  identifier     = "taint-example-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  db_name          = "exampledb"
  username         = "admin"
  password         = "password123"
  
  skip_final_snapshot = true
  
  tags = {
    Name = "taint-example-db"
  }
}

# S3 bucket that might need recreation
resource "aws_s3_bucket" "example" {
  bucket = "taint-example-${random_id.suffix.hex}"
  
  tags = {
    Name = "taint-example-bucket"
  }
}

# Launch template that might need updating
resource "aws_launch_template" "web" {
  name_prefix   = "taint-example-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    echo "Launch template version 1" > /tmp/version.txt
  EOF
  )
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "taint-example-lt"
    }
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

output "taint_commands" {
  value = {
    web_instance     = "terraform taint aws_instance.web"
    database         = "terraform taint aws_db_instance.example"
    s3_bucket        = "terraform taint aws_s3_bucket.example"
    launch_template  = "terraform taint aws_launch_template.web"
  }
}

output "untaint_commands" {
  value = {
    web_instance     = "terraform untaint aws_instance.web"
    database         = "terraform untaint aws_db_instance.example"
    s3_bucket        = "terraform untaint aws_s3_bucket.example"
    launch_template  = "terraform untaint aws_launch_template.web"
  }
}
