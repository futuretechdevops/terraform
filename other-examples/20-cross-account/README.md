# Cross-Account Terraform

Manage resources across multiple AWS accounts using assume role.

## Setup Requirements

### 1. Create Cross-Account Role
In the target account, create an IAM role that can be assumed:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::SOURCE-ACCOUNT-ID:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "unique-external-id"
        }
      }
    }
  ]
}
```

### 2. Attach Permissions Policy
Attach necessary permissions to the cross-account role.

### 3. Configure Provider
Use assume_role in provider configuration.

## Provider Configuration

```hcl
provider "aws" {
  alias  = "cross_account"
  region = "ap-south-1"
  
  assume_role {
    role_arn     = "arn:aws:iam::TARGET-ACCOUNT:role/RoleName"
    session_name = "terraform-session"
    external_id  = "unique-external-id"
  }
}
```

## Use Cases

- **Multi-account Architecture**: Separate dev/staging/prod
- **Organizational Units**: Different business units
- **Security Isolation**: Separate sensitive workloads
- **Compliance**: Meet regulatory requirements
- **Resource Sharing**: Cross-account VPC peering, S3 access

## Best Practices

- Use external IDs for additional security
- Implement least privilege access
- Use separate state files per account
- Document cross-account dependencies
- Monitor cross-account access with CloudTrail

## Security Considerations

- Rotate external IDs regularly
- Use time-limited sessions
- Implement MFA requirements
- Audit cross-account access
- Use resource-based policies when possible
