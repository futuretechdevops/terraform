# AWS Storage Resources

## S3 (Simple Storage Service)
**Purpose**: Object storage service
**Terraform Resource**: `aws_s3_bucket`
**Use Cases**: File storage, static websites, backups
**Example**:
```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}
```

## EBS (Elastic Block Store)
**Purpose**: Block storage for EC2 instances
**Terraform Resource**: `aws_ebs_volume`
**Use Cases**: Database storage, file systems
**Example**:
```hcl
resource "aws_ebs_volume" "data" {
  availability_zone = "us-west-2a"
  size              = 40
  type              = "gp3"
}
```

## EFS (Elastic File System)
**Purpose**: Managed NFS file system
**Terraform Resource**: `aws_efs_file_system`
**Use Cases**: Shared storage, content repositories
**Example**:
```hcl
resource "aws_efs_file_system" "shared" {
  creation_token = "shared-storage"
}
```

## FSx
**Purpose**: Fully managed file systems
**Terraform Resource**: `aws_fsx_lustre_file_system`
**Use Cases**: High-performance computing, machine learning
**Example**:
```hcl
resource "aws_fsx_lustre_file_system" "hpc" {
  storage_capacity = 1200
  subnet_ids       = [aws_subnet.private.id]
}
```

## S3 Glacier
**Purpose**: Long-term archival storage
**Terraform Resource**: `aws_s3_bucket` with lifecycle
**Use Cases**: Data archiving, compliance
**Example**:
```hcl
resource "aws_s3_bucket_lifecycle_configuration" "archive" {
  bucket = aws_s3_bucket.data.id
  rule {
    id     = "archive"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }
}
```

## Storage Gateway
**Purpose**: Hybrid cloud storage
**Terraform Resource**: `aws_storagegateway_gateway`
**Use Cases**: On-premises to cloud integration
**Example**:
```hcl
resource "aws_storagegateway_gateway" "hybrid" {
  gateway_name = "hybrid-gateway"
  gateway_type = "FILE_S3"
}
```
