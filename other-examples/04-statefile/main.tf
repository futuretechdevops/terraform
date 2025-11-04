provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "state_demo" {
  bucket = "state-demo-${random_id.suffix.hex}"
  
  tags = {
    Purpose = "State file demonstration"
  }
}

resource "aws_s3_bucket_versioning" "state_demo" {
  bucket = aws_s3_bucket.state_demo.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Output to show state tracking
output "bucket_arn" {
  value = aws_s3_bucket.state_demo.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.state_demo.bucket_domain_name
}
