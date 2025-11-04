terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Default AWS provider
provider "aws" {
  region = "ap-south-1"
}

# Aliased AWS provider for different region
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

# Random provider
provider "random" {}

# Resources using different providers
resource "aws_s3_bucket" "main" {
  bucket = "my-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "backup" {
  provider = aws.us_east
  bucket   = "my-backup-${random_id.suffix.hex}"
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "main_bucket" {
  value = aws_s3_bucket.main.bucket
}

output "backup_bucket" {
  value = aws_s3_bucket.backup.bucket
}
