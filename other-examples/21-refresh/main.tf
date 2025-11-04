provider "aws" {
  region = "ap-south-1"
}

# S3 bucket that might be modified outside Terraform
resource "aws_s3_bucket" "example" {
  bucket = "refresh-example-${random_id.suffix.hex}"
  
  tags = {
    Name        = "refresh-example"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
}

# Bucket versioning that might be changed manually
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket encryption that might be modified
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# EC2 instance that might be modified outside Terraform
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  tags = {
    Name        = "refresh-example-web"
    Environment = "test"
    ManagedBy   = "Terraform"
  }
  
  # This might be changed manually
  monitoring = false
}

# Security group that might have rules added manually
resource "aws_security_group" "web" {
  name        = "refresh-example-sg"
  description = "Security group for refresh example"
  vpc_id      = data.aws_vpc.default.id
  
  # These rules might be modified outside Terraform
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name      = "refresh-example-sg"
    ManagedBy = "Terraform"
  }
}

# IAM role that might have policies attached manually
resource "aws_iam_role" "example" {
  name = "refresh-example-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Name      = "refresh-example-role"
    ManagedBy = "Terraform"
  }
}

# IAM policy attachment that might be removed manually
resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# RDS instance that might be modified outside Terraform
resource "aws_db_instance" "example" {
  identifier     = "refresh-example-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_encrypted = false  # Might be changed to true manually
  
  db_name  = "exampledb"
  username = "admin"
  password = "password123"
  
  # These might be modified outside Terraform
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = true
  
  tags = {
    Name      = "refresh-example-db"
    ManagedBy = "Terraform"
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

resource "random_id" "suffix" {
  byte_length = 4
}

# Outputs to show current state
output "refresh_commands" {
  description = "Commands to refresh Terraform state"
  value = {
    refresh_all        = "terraform refresh"
    refresh_with_plan  = "terraform plan -refresh-only"
    apply_refresh_only = "terraform apply -refresh-only"
    plan_no_refresh    = "terraform plan -refresh=false"
  }
}

output "resource_info" {
  description = "Current resource information"
  value = {
    bucket_name     = aws_s3_bucket.example.bucket
    instance_id     = aws_instance.web.id
    security_group  = aws_security_group.web.id
    iam_role_arn    = aws_iam_role.example.arn
    db_identifier   = aws_db_instance.example.identifier
  }
}

output "drift_detection_tips" {
  description = "Tips for detecting configuration drift"
  value = {
    check_bucket_tags     = "aws s3api get-bucket-tagging --bucket ${aws_s3_bucket.example.bucket}"
    check_instance_tags   = "aws ec2 describe-instances --instance-ids ${aws_instance.web.id}"
    check_sg_rules        = "aws ec2 describe-security-groups --group-ids ${aws_security_group.web.id}"
    check_iam_policies    = "aws iam list-attached-role-policies --role-name ${aws_iam_role.example.name}"
    check_db_config       = "aws rds describe-db-instances --db-instance-identifier ${aws_db_instance.example.identifier}"
  }
}
