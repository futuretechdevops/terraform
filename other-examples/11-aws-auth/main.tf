# Method 1: Default provider (uses AWS CLI/environment)
provider "aws" {
  region = "ap-south-1"
}

# Method 2: Explicit profile
provider "aws" {
  alias   = "profile_auth"
  region  = "ap-south-1"
  profile = "my-profile"
}

# Method 3: Assume role
provider "aws" {
  alias  = "assume_role"
  region = "ap-south-1"
  
  assume_role {
    role_arn     = "arn:aws:iam::123456789012:role/TerraformRole"
    session_name = "terraform-session"
  }
}

# Method 4: Cross-account assume role
provider "aws" {
  alias  = "cross_account"
  region = "us-east-1"
  
  assume_role {
    role_arn     = "arn:aws:iam::987654321098:role/CrossAccountRole"
    session_name = "cross-account-terraform"
    external_id  = "unique-external-id"
  }
}

# Resources using different auth methods
resource "aws_s3_bucket" "default_auth" {
  bucket = "default-auth-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "profile_auth" {
  provider = aws.profile_auth
  bucket   = "profile-auth-${random_id.suffix.hex}"
}

resource "aws_s3_bucket" "assume_role_auth" {
  provider = aws.assume_role
  bucket   = "assume-role-${random_id.suffix.hex}"
}

# Get current caller identity for each provider
data "aws_caller_identity" "default" {}

data "aws_caller_identity" "profile" {
  provider = aws.profile_auth
}

data "aws_caller_identity" "assume_role" {
  provider = aws.assume_role
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "default_account" {
  value = data.aws_caller_identity.default.account_id
}

output "default_user" {
  value = data.aws_caller_identity.default.user_id
}

output "assume_role_account" {
  value = data.aws_caller_identity.assume_role.account_id
}
