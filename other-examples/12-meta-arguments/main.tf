provider "aws" {
  region = "ap-south-1"
}

# depends_on meta-argument
resource "aws_s3_bucket" "dependency_example" {
  bucket = "dependency-${random_id.suffix.hex}"
  
  # Explicit dependency
  depends_on = [aws_iam_role.s3_role]
}

resource "aws_iam_role" "s3_role" {
  name = "s3-access-role"
  
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
}

# count meta-argument
resource "aws_s3_bucket" "count_example" {
  count  = 3
  bucket = "count-bucket-${count.index}-${random_id.suffix.hex}"
  
  tags = {
    Name  = "Bucket-${count.index + 1}"
    Index = count.index
  }
}

# for_each meta-argument
variable "bucket_names" {
  default = ["logs", "backups", "archives"]
}

resource "aws_s3_bucket" "foreach_example" {
  for_each = toset(var.bucket_names)
  bucket   = "${each.value}-${random_id.suffix.hex}"
  
  tags = {
    Name    = each.value
    Purpose = each.key
  }
}

# provider meta-argument
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

resource "aws_s3_bucket" "provider_example" {
  provider = aws.us_east
  bucket   = "us-east-bucket-${random_id.suffix.hex}"
}

# lifecycle meta-argument
resource "aws_instance" "lifecycle_example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes       = [ami, tags]
  }
  
  tags = {
    Name = "lifecycle-example"
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

output "count_buckets" {
  value = aws_s3_bucket.count_example[*].bucket
}

output "foreach_buckets" {
  value = values(aws_s3_bucket.foreach_example)[*].bucket
}
