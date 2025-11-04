# AWS Authentication Methods

Multiple ways to authenticate Terraform with AWS.

## Authentication Methods

### 1. Environment Variables
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="ap-south-1"
```

### 2. AWS CLI Profile
```bash
aws configure --profile my-profile
# Then use profile in provider
```

### 3. IAM Roles (EC2/ECS/Lambda)
- Automatic when running on AWS services
- Uses instance/task role credentials

### 4. Assume Role
- Cross-account access
- Temporary credentials
- Enhanced security

## Best Practices

- **Never hardcode credentials** in Terraform files
- Use IAM roles when possible
- Rotate access keys regularly
- Use least privilege principle
- Enable MFA for sensitive operations

## Precedence Order

1. Provider configuration
2. Environment variables
3. Shared credentials file
4. EC2 instance profile
