# Primary account provider (default)
provider "aws" {
  region = "ap-south-1"
  alias  = "primary"
}

# Cross-account provider using assume role
provider "aws" {
  region = "ap-south-1"
  alias  = "secondary"
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.secondary_account_id}:role/${var.cross_account_role_name}"
    session_name = "terraform-cross-account"
    external_id  = var.external_id
  }
}

# Different region in secondary account
provider "aws" {
  region = "us-east-1"
  alias  = "secondary_us_east"
  
  assume_role {
    role_arn     = "arn:aws:iam::${var.secondary_account_id}:role/${var.cross_account_role_name}"
    session_name = "terraform-cross-account-us"
    external_id  = var.external_id
  }
}

variable "secondary_account_id" {
  description = "AWS Account ID for secondary account"
  type        = string
  default     = "123456789012"  # Replace with actual account ID
}

variable "cross_account_role_name" {
  description = "Name of the cross-account role"
  type        = string
  default     = "TerraformCrossAccountRole"
}

variable "external_id" {
  description = "External ID for additional security"
  type        = string
  default     = "unique-external-id-12345"
}

# Resources in primary account
resource "aws_s3_bucket" "primary_bucket" {
  provider = aws.primary
  bucket   = "primary-account-bucket-${random_id.suffix.hex}"
  
  tags = {
    Account = "Primary"
    Purpose = "Cross-account example"
  }
}

# Cross-account IAM role in primary account
resource "aws_iam_role" "cross_account_access" {
  provider = aws.primary
  name     = "CrossAccountAccessRole"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.secondary_account_id}:root"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })
  
  tags = {
    Purpose = "Cross-account access"
  }
}

resource "aws_iam_role_policy" "cross_account_policy" {
  provider = aws.primary
  name     = "CrossAccountS3Access"
  role     = aws_iam_role.cross_account_access.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.primary_bucket.arn,
          "${aws_s3_bucket.primary_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Resources in secondary account
resource "aws_s3_bucket" "secondary_bucket" {
  provider = aws.secondary
  bucket   = "secondary-account-bucket-${random_id.suffix.hex}"
  
  tags = {
    Account = "Secondary"
    Purpose = "Cross-account example"
  }
}

# VPC in secondary account
resource "aws_vpc" "secondary_vpc" {
  provider   = aws.secondary
  cidr_block = "10.1.0.0/16"
  
  tags = {
    Name    = "secondary-account-vpc"
    Account = "Secondary"
  }
}

# Resource in different region of secondary account
resource "aws_s3_bucket" "secondary_us_east" {
  provider = aws.secondary_us_east
  bucket   = "secondary-us-east-${random_id.suffix.hex}"
  
  tags = {
    Account = "Secondary"
    Region  = "us-east-1"
  }
}

# Cross-account VPC peering (if both VPCs exist)
resource "aws_vpc_peering_connection" "cross_account" {
  provider    = aws.primary
  vpc_id      = data.aws_vpc.primary_default.id
  peer_vpc_id = aws_vpc.secondary_vpc.id
  peer_region = "ap-south-1"
  
  # Cross-account peering
  peer_owner_id = var.secondary_account_id
  
  tags = {
    Name = "cross-account-peering"
  }
}

# Accept peering connection in secondary account
resource "aws_vpc_peering_connection_accepter" "cross_account" {
  provider                  = aws.secondary
  vpc_peering_connection_id = aws_vpc_peering_connection.cross_account.id
  auto_accept               = true
  
  tags = {
    Name = "cross-account-peering-accepter"
  }
}

# Data sources to get account information
data "aws_caller_identity" "primary" {
  provider = aws.primary
}

data "aws_caller_identity" "secondary" {
  provider = aws.secondary
}

data "aws_vpc" "primary_default" {
  provider = aws.primary
  default  = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Outputs showing cross-account resources
output "account_info" {
  value = {
    primary_account_id   = data.aws_caller_identity.primary.account_id
    secondary_account_id = data.aws_caller_identity.secondary.account_id
    primary_user_id      = data.aws_caller_identity.primary.user_id
    secondary_user_id    = data.aws_caller_identity.secondary.user_id
  }
}

output "cross_account_resources" {
  value = {
    primary_bucket      = aws_s3_bucket.primary_bucket.bucket
    secondary_bucket    = aws_s3_bucket.secondary_bucket.bucket
    secondary_us_bucket = aws_s3_bucket.secondary_us_east.bucket
    secondary_vpc_id    = aws_vpc.secondary_vpc.id
    peering_connection  = aws_vpc_peering_connection.cross_account.id
  }
}
