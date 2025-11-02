terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-unique-12345"
    key            = "ec2/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

# NOTE: This backend configuration references the S3 bucket and DynamoDB table
# created by the 03-remote-state-backend example. Ensure that infrastructure
# is deployed first before using this configuration.
