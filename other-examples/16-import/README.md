# Terraform Import

Import existing infrastructure into Terraform state.

## Import Methods

### 1. Command Line Import
```bash
# Import S3 bucket
terraform import aws_s3_bucket.existing_bucket bucket-name

# Import EC2 instance  
terraform import aws_instance.existing_instance i-1234567890abcdef0

# Import VPC
terraform import aws_vpc.existing_vpc vpc-12345678
```

### 2. Import Blocks (Terraform 1.5+)
```hcl
import {
  to = aws_s3_bucket.example
  id = "bucket-name"
}
```

### 3. Generate Configuration
```bash
# Generate config for existing resources
terraform plan -generate-config-out=generated.tf
```

## Import Process

1. **Write Resource Configuration**: Define resource block
2. **Run Import Command**: Link existing resource to configuration
3. **Verify State**: Check with `terraform plan`
4. **Adjust Configuration**: Match existing resource attributes

## Common Import IDs

- **S3 Bucket**: bucket-name
- **EC2 Instance**: i-1234567890abcdef0
- **VPC**: vpc-12345678
- **Security Group**: sg-12345678
- **IAM Role**: role-name

## Best Practices

- Import one resource at a time
- Verify configuration matches existing resource
- Use `terraform show` to see imported attributes
- Test with `terraform plan` before applying changes
