# Terraform Backends

Backends store Terraform state remotely for team collaboration and state locking.

## S3 Backend Features

- **Remote State**: Stored in S3 bucket
- **State Locking**: DynamoDB prevents concurrent modifications
- **Encryption**: State encrypted at rest
- **Versioning**: S3 versioning for state history

## Setup Steps

1. First run without backend to create S3/DynamoDB:
```bash
terraform init
terraform apply
```

2. Add backend configuration and migrate:
```bash
terraform init -migrate-state
```

## Backend Types

- **s3**: AWS S3 with DynamoDB locking
- **azurerm**: Azure Storage
- **gcs**: Google Cloud Storage
- **remote**: Terraform Cloud
