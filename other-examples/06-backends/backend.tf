terraform {
  backend "s3" {
    bucket         = "futuretechnov2025"
    key            = "backends-example/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
