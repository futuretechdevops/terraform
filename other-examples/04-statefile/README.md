# Terraform State File

State file tracks resource metadata and enables Terraform to manage infrastructure.

## State File Contents

- **Resource mappings**: Configuration to real-world resources
- **Metadata**: Resource dependencies, creation order
- **Performance**: Cached attribute values
- **Locking**: Prevent concurrent modifications

## State Commands

```bash
# View state
terraform show
terraform state list

# Inspect specific resource
terraform state show aws_s3_bucket.state_demo

# Move resources in state
terraform state mv aws_s3_bucket.old aws_s3_bucket.new

# Remove from state (doesn't destroy)
terraform state rm aws_s3_bucket.state_demo

# Import existing resource
terraform import aws_s3_bucket.existing bucket-name
```

## State Storage

- **Local**: terraform.tfstate (default)
- **Remote**: S3, Terraform Cloud, etc.
- **Locking**: Prevents corruption from concurrent access

## Security

- Contains sensitive data
- Should be encrypted at rest
- Restrict access appropriately
