# Terraform Data Sources

Data sources fetch information from existing infrastructure or external APIs.

## Common AWS Data Sources

- **aws_ami**: Get AMI information
- **aws_vpc**: Get VPC details
- **aws_subnets**: Get subnet information
- **aws_availability_zones**: Get AZ list
- **aws_region**: Get current region
- **aws_caller_identity**: Get AWS account info

## Benefits

- **Dynamic**: Always get current information
- **Flexible**: Adapt to existing infrastructure
- **Portable**: Work across different environments
- **Safe**: Read-only operations

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Key Points

- Data sources are read-only
- Executed during plan phase
- Can be filtered and sorted
- Useful for referencing existing resources
